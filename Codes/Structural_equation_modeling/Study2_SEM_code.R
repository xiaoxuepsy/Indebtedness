library(ggplot2)
library(lavaan)

reg_data= read.table("./Study2_behavioral_data.txt",header=T)

out <-data.frame()
for(i in unique(reg_data$Subject) ){
  sub_dat <- reg_data[reg_data$Subject==i,]
  out<-rbind(out,scale(sub_dat,center = T,scale=F))
}


SEM_data = data.frame(cbind(scale(reg_data$Coplayer_cost),scale(reg_data$Condition),scale(reg_data$Efficiency),scale(out$Second_order_belief),scale(out$Perceived_care),scale(out$Obligation),scale(out$Gratitude),scale(out$Guilt),scale(out$Indebtedness)))
names(SEM_data)=c('Cost','Cond','Eff','E2','Pcare','Obligation','Gratitude','Guilt','Indebtedness')


model <- ' # outcome model
Obligation ~ c11*Cost+c12*Cond+c13*Cond:Cost  + b1*E2
Gratitude ~ c21*Cost+c22*Cond+c23*Cond:Cost  + b2*Pcare
Guilt ~ c31*Cost+c32*Cond+c33*Cond:Cost  + b3*Pcare
# mediator
E2 ~ a11*Cost+ a12*Cond+ a13*Cond:Cost
Pcare ~ a21*Cost+ a22*Cond+ a23*Cond:Cost
#E2 ~~ Pcare

# indirect effect (a*b)
CostE2Obligation := a11*b1
CondE2Obligation := a12*b1
intE2Obligation := a13*b1

CostPCareGratitude := a21*b2
CondPCareGratitude := a22*b2
intPCareGratitude := a23*b2

CostPCareGuilt := a21*b3
CondPCareGuilt := a22*b3
intPCareGuilt := a23*b3


ab := (a11+a12+a13)*b1 + (a21+a22+a23)*b2 + (a21+a22+a23)*b3

abE2Obligation := (a11+a12+a13)*b1
abPCareGratitude := (a21+a22+a23)*b2
abPCareGuilt := (a21+a22+a23)*b3

# total effect
totalCostObligation := c11 + a11*b1 
totalCondObligation := c12 + a12*b1 
totalintObligation := c13 + a13*b1 


totalCostGratitude := c21 + a21*b2 
totalCondGratitude := c22 + a22*b2 
totalintGratitude := c23 + a23*b2 


totalCostGuilt := c31 + a21*b3 
totalCondGuilt := c32 + a22*b3 
totalintGuilt := c33 + a23*b3 

totalE2Obligation := (c11+c12+c13) + (a11+a12+a13)*b1 
totalPCareGratitude :=  (c21+c22+c23) + (a21+a22+a23)*b2
totalPCareGuilt := (c31+c32+c33) + (a21+a22+a23)*b3

# c plus effect
plusCostObligation := c11 
plusCondObligation := c12 
plusintObligation := c13 


plusCostGratitude := c21 
plusCondGratitude := c22 
plusintGratitude := c23 


plusCostGuilt := c31 
plusCondGuilt := c32 
plusintGuilt := c33

plusE2Obligation := (c11+c12+c13) 
plusPCareGratitude :=  (c21+c22+c23) 
plusPCareGuilt := (c31+c32+c33)

plus := (c11+c12+c13) + (c21+c22+c23) + (c31+c32+c33) 

total := (c11+c12+c13) + (a11+a12+a13)*b1 + (c21+c22+c23) + (a21+a22+a23)*b2 + (c31+c32+c33) + (a21+a22+a23)*b3

ECE2 := a11+a12+a13
ECPCare := a21+a22+a23
'
fit <- sem(model, data = SEM_data)
summary(fit, fit.measures = T, standardized = T)
boot.fit <- parameterEstimates(fit, boot.ci.type = 'bca.simple')
fitMeasures(fit,c("chisq","df","pvalue","cfi","nfi","ifi","rmsea","EVCI"))

dev.new() #新建一个图形窗口
#绘制路径图
library(semPlot)
semPaths(fit,what = "std", 
         rotation = 2, 
         edge.color = "black", 
         esize = 0.5, 
         edge.label.cex = 1, 
         exoVar = F )         

