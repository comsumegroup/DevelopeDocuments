rm(list=ls())
#setwd("")
#example: setwd("D:/mobilecomsup/positioncode")


gdata1=function(num.file,num.file.select,num.obs.each)
{
  file.ind=sample(1:num.file,size=num.file.select,replace=F)
  
  data1=read.table(paste("positionRecords_",file.ind[1],".txt",sep=""))
  selected.ind=sample(1:nrow(data1),num.obs.each,replace=F)
  selected.obs=data1[selected.ind, ]
  
  for(i in file.ind[-1])
  {
    datai=read.table(paste("positionRecords_",i,".txt",sep=""))
    selected.ind=sample(1:nrow(datai),num.obs.each,replace=F)
    selected.obs=rbind(selected.obs,datai[selected.ind, ])
  }
  
  return(selected.obs=selected.obs)
  
}

kmclust=function(selected.obs,num.group,num.peop)
{
  type.ind=rep(1:3,num.peop)
  real.group.ind=t(selected.obs[1,type.ind==1])
  
  relation=matrix(0,nrow=num.peop,ncol=num.peop)
  
  for(k in 1:nrow(selected.obs))
  {
    one.obs=selected.obs[k, ]
    x_coordinate=t(one.obs[type.ind==2])
    y_coordinate=t(one.obs[type.ind==3])
    xy=cbind(x_coordinate,y_coordinate)
    rownames(xy)=1:nrow(xy)
    colnames(xy)=c("x","y")
    
	# �ò�ξ���Ľ����Ϊ��ʼ���۵�
    dist0=dist(xy)
    hc.ind=cutree(hclust(dist0),num.group)  
    init.cen=matrix(0,nrow=num.group,ncol=ncol(xy))
    for(j in 1:num.group)
    {
      
      if(is.vector(xy[which(hc.ind==j), ]))
      {init.cen[j, ]=apply(t(xy[which(hc.ind==j), ]),2,mean)}
      else
        init.cen[j, ]=apply(xy[which(hc.ind==j), ],2,mean)  
    }
    
    km=kmeans(xy,centers=init.cen,nstart=40)
    kmclust=km$clust
    
    KMCLUST1=as.matrix(kmclust)%*%rep(1,num.peop)
    KMCLUST2=matrix(1,nrow=num.peop,ncol=1)%*%kmclust
    
    relation=relation+(KMCLUST1==KMCLUST2)  
    
  }
  relation=relation-diag(rep(nrow(selected.obs),num.peop))
  
  return(list(adjacent.matrix=relation,
              real.group.ind=real.group.ind))
}
# para settings 11.15.2015

#�ܵ��ļ���
num.file=200

#ÿ�������ļ��ļ�¼����
record.each.file=1000 

#ѡȡ���ļ�����
num.file.select=20

#ÿ���ļ�ѡȡ�ļ�¼����
num.obs.each=10

#Ⱥ�����
num.group=150

#�����ظ����еĴ���
num.simulation=20
# ������
num.peop=ncol(read.table("positionRecords_1.txt"))/3

# output


ADJACENCY=matrix(0,nrow=num.peop,ncol=num.peop)

for(i in 1:num.simulation)
{
  selected.obs=gdata1(num.file,
                      num.file.select=num.file.select,
                      num.obs.each=num.obs.each)
  km.result=kmclust(selected.obs=selected.obs,num.group=num.group,
                    num.peop = num.peop)
  ADJACENCY=ADJACENCY+km.result$adjacent.matrix
  if(i==1)
  {
    groupid=km.result$real.group.ind
  }
  
}

ADJACENCY=ADJACENCY/num.simulation
Groupid=as.matrix(cbind(1:length(groupid),groupid))

# write.table(ADJACENCY,file="adjacency.txt",quote=F,row.name=F,col.names = F)
# write.table(Groupid,file="groupid.txt",quote=F,row.name=F,col.names = F)