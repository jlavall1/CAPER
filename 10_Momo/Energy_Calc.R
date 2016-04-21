data=read.csv(file.choose(),header=TRUE)
data[,4]=data[,2]^2
data[,5]=data[,3]^2
data[,6]=data[,2]*data[,3]
colnames(data)=c("PU_E","VI","CI","VI2","CI2","VI_CI")
n=length(data[,1])
m=n-round(n*0.1)
index1=sort(sample(n,m))

#index1=sample(data[],n,m)
#	sample randomly for training & testing data:

train.data=data[index1,]
test.data=data[-index1,]

fit1=lm(PU_E~VI+CI,train.data)
summary(fit1)
coeff=summary(fit1)$coefficients[,1]
coeff

fit2=lm(PU_E~VI+CI+VI2+CI2+VI_CI,train.data)
summary(fit2)

fit3=lm(PU_E~CI+CI2,train.data)
summary(fit3)
coeff=summary(fit3)$coefficients[,1]