library(lmerTest)
library(psych)

reci_pre_data<-read.table("Brain_predictions_for_E2_and_PCare.txt",header=T)
para_data = read.table("Params_Neural_Utility_Model.txt",header=T)


### Generate predictions of Neural utility model ###

subjects = unique(para_data$Subject)

for (nsub in 1:length(subjects)){
  sub = subjects[nsub]
  sub_data = subset(reci_pre_data,reci_pre_data$Subject==sub)
  sub_para = subset(para_data,para_data$Subject==sub)
  
  Theta = sub_para[1,2]; # weight for greedy
  Phi = sub_para[1,3]; # weight for Communal concern
 
  cost = sub_data[,5] # The colume number for trial-by-trial benefactor's cost
  condition = sub_data[,4] # The colume number indicating repayment possible (1) and impossible (0) conditions
  
  E2_pre = sub_data[,8]; # The colume number for brain predicted (cross validated) trial-by-trial E2
  PCare_pre = sub_data[,7]; #The colume number for brain predicted (cross validated) trial-by-trial perceived care (Re-scaled to 0-25)
  
  pre_reci = matrix(0,length(cost),1)
  
  for (t in 1:length(cost)){
  
  allR = 0:250   
  allR = allR/10
  
  U = Theta*((25-allR)/25) - (1-Theta)*(Phi * ((PCare_pre[t]-allR)/25)^2 + (1 - Phi)*((E2_pre[t]-allR)/25)^2) ;
  I = which(U==max(U),arr.ind=T)
  pre_reci[t] = (I-1)/10;
  }
  
  if (nsub==1){
    results = pre_reci
  }else{
    results = rbind(results,pre_reci)
  }
}

reci_pre_data$Neural_Utility_Model_prediction = results



### Estimate the performances of neural utility model (MNU) and direct brain model for reciprocity (MR) ###

r_MNU = c()
AIC_MNU = c()

r_MR = c()
AIC_MR = c()

k = 1

for(sub in unique(reci_pre_data$Subject)){
  
  sub_data  = subset(reci_pre_data,reci_pre_data$Subject==sub)
  
  sub_lm_MNU = lm(Reciprocity ~ Neural_Utility_Model_prediction,data = sub_data)
  summary(sub_lm_MNU)
  AIC_MNU[k]= AIC(sub_lm_MNU)
  
  if (summary(sub_lm_MNU)$coef[2,1]>0){
    r_MNU[k] = sqrt(summary(sub_lm_MNU)$r.squared)
  }else{
    r_MNU[k] = -sqrt(summary(sub_lm_MNU)$r.squared)
  }
 
  
  sub_lm_MR = lm(Reciprocity ~ Brain_pre_Reci,data = sub_data)
  summary(sub_lm_MR)
  AIC_MR[k]= AIC(sub_lm_MR)
  if (summary(sub_lm_MR)$coef[2,1]>0){
    r_MR[k] = sqrt(summary(sub_lm_MR)$r.squared)
  }else{
    r_MR[k] = -sqrt(summary(sub_lm_MR)$r.squared)
  }
  
  k = k+1
  
}

r_MNU_aver = mean(r_MNU) 
r_MNU_SE = sd(r_MNU)/sqrt(length(r_MNU))

r_MR_aver = mean(r_MR)
r_MR_SE = sd(r_MR)/sqrt(length(r_MR))

AIC_MNU_aver = mean(AIC_MNU) 
AIC_MNU_SE = sd(AIC_MNU)/sqrt(length(AIC_MNU))

AIC_MR_aver = mean(AIC_MR)  
AIC_MR_SE = sd(AIC_MR)/sqrt(length(AIC_MR))

z_MNU =  fisherz(r_MNU)
z_MNU_aver = mean(z_MNU)
z_MNU_SE = sd(z_MNU)/sqrt(length(z_MNU))

z_MR =  fisherz(r_MR)
z_MR_aver = mean(z_MR)
z_MR_SE = sd(z_MR)/sqrt(length(z_MR))

r_MNU_aver_trans = fisherz2r(z_MNU_aver)
r_MR_aver_trans = fisherz2r(z_MR_aver)


t_MNU = t.test(z_MNU, mu = 0, alternative = "two.sided")$statistic
p_MNU = t.test(z_MNU, mu = 0, alternative = "two.sided")$p.value

t_MR = t.test(z_MR, mu = 0, alternative = "two.sided")$statistic
p_MR = t.test(z_MR, mu = 0, alternative = "two.sided")$p.value



### parameter permutation across participants ###

nperm = 5000

r_perm = matrix(NA,nperm,1)

for(j in 1:nperm){
  
  subjects = unique(para_data$Subject)
  subjects_perm = sample(subjects)
  
  k = 1
  r_perm_sub = c()
  
  for (nsub in 1:length(subjects)){
    
    sub = subjects[nsub]
    sub_perm = subjects_perm[nsub]
    sub_data = subset(reci_pre_data,reci_pre_data$Subject==sub)
    sub_para = subset(para_data,para_data$Subject==sub_perm) # Use permuted parameter for this subject
    
    Theta = sub_para[1,2]; # weight for greedy
    Phi = sub_para[1,3]; # weight for Communal concern
    
    cost = sub_data[,5] # The colume number for trial-by-trial benefactor's cost
    condition = sub_data[,4] # The colume number indicating repayment possible (1) and impossible (0) conditions
    
    E2_pre = sub_data[,8]; # The colume number for brain predicted (cross validated) trial-by-trial E2
    PCare_pre = sub_data[,7]; #The colume number for brain predicted (cross validated) trial-by-trial perceived care (Re-scaled to 0-25)
    
    pre_reci = matrix(0,length(cost),1)
    
    for (t in 1:length(cost)){
      
      allR = 0:250   
      allR = allR/10
      
      U = Theta*((25-allR)/25) - (1-Theta)*(Phi*((PCare_pre[t]-allR)/25)^2 + (1-Phi)*((E2_pre[t]-allR)/25)^2) ;
      I = which(U==max(U),arr.ind=T)
      pre_reci[t] = (I-1)/10;
    }
    
    sub_data$Neural_Utility_Model_prediction_perm = pre_reci
    sub_lm = lm(Reciprocity ~ Neural_Utility_Model_prediction_perm,data = sub_data)
    summary(sub_lm)
    
    if (summary(sub_lm)$coef[2,1]>0){
      r_perm_sub[k] = sqrt(summary(sub_lm)$r.squared)
    }else{
      r_perm_sub[k] = -sqrt(summary(sub_lm)$r.squared)
    }
    k = k+1
  }

  r_perm[j,1] = mean(r_perm_sub)

  }
  

z_perm = fisherz(r_perm)

p_perm_z = length(z_perm[z_perm>z_MNU_aver])/nperm

print(p_perm_z)



### Plot ###

hist(r_perm,xlim = c(0.14,0.2))
abline(v = r_MNU_aver_trans,lwd =1, col = "blue")
abline(v = r_MR_aver_trans,lwd =1, col = "red")


dev.copy(pdf,'Neural_Utility_hist_r_MNU.pdf',width = 5, height = 5)
dev.off()