

acc_data= read.table("./Binary_classification_AvsS_accuracy.txt",header=T)

b <- sum(acc_data$Accuracy_sign > 0)
n <- sum(acc_data$Accuracy_sign != 0)
a = binom.test(b, n, alternative = "greater") 
observed_prob = a$estimate

### Permutation ###
sign = c(1,-1)
sample(sign)

nperm = 5000
prob_perm = matrix(NA,1,nperm)

for (j in 1:nperm) {
  for (i in 1:length(acc_data$Accuracy_sign)){
    acc_data$Accuracy_sign_perm[i] = acc_data$Accuracy_sign[i]*sample(sign)[1]
  }
  b_perm <- sum(acc_data$Accuracy_sign_perm > 0)
  n_perm <- sum(acc_data$Accuracy_sign_perm != 0)
  a = binom.test(b_perm, n_perm, alternative = "greater") 
  prob_perm[1,j] = a$estimate
}

p_perm = length(prob_perm[prob_perm > observed_prob])/nperm