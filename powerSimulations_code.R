library(dplyr) # for data management
library(lcmm) # for group-based trajectory modeling

# Simulation based power for Aim 1 based on group-based trajectory modeling
# The purpose is to demonstrate that the projected sample size of N=450
# is sufficient to fit the group-based trajectory modeling with three groups and linear trajectories (slope>0, slope=0, slope<0)
# and that the non-zero slopes can be estimated with good power (80%+) when the effect sizes are small.

# Assume:
# Each of N individuals has measurements at bl, 12m (2 time points)

# For the outcome:
# For Aim 1, we are looking at continuous muscle measures (mass, fat, frailty)
# WLOG, we can just look at a standardized continuous outcome (SD = 1), will allow us to translate to effect size.

# As a first stab, let's look at 
# Three trajectory clusters:
# * negative slope - Class 1
# * stable (slope = 0) - Class 2
# * positive slope - Class 3
# Where the trends are linear

# For Class c:
# y_ij.c = b0.c + b1.c * time + error_ij + u_i
# where 
# c: class
# i: individual
# j: repeated measurement 1, or 2


# Inputs:
# N: sample size
# group_dist: distribution of three latent groups 
# b1.1: slope (effect size) of first group
# b1.3: slope (effect size) of third group
# s_error: standard deviation of random error
# icc: intracluster correlation
# R: number of simulated data sets

# Returns:
# matrix of dimension Rx12, where the columns are:
# b0.1, b0.2, b0.3: intercepts of the three trajectory groups
# b1.1, b1.2, b1.3: slopes of the three trajectory groups
# corresponding p-values which allow us to estimate power

simPower_aim1 <- function(N = 450,
                          group_dist = c(1/3, 1/3, 1/3),
                          b1.1 = -0.5,
                          b1.3 = 0.2,
                          s_error = 0.2, 
                          icc = 0.1, 
                          R = 500){
  
  # Negative slope group
  b0.1 = 0 # intercept
  
  # Stable
  b0.2 = 0.8 # intercept, medium effect size
  b1.2 = 0 # no slope
  
  # Positive slope group
  b0.3 = 0 # intercept
  
  # matrix to hold relevant simulation results
  paramNames = c("b0.1", "b0.2", "b0.3", "b1.1", "b1.2", "b1.3")
  simResults = matrix(NA, nrow = R, ncol = length(paramNames)*2) 
  colnames(simResults) = c(paramNames, 
                           paste0(paramNames, "_pval"))
  
  for (r in 1:R){
    
    set.seed(r)
    
    # SIMULATE DATA
    
    # sample latent classes
    class = sample(paste0("C", 1:3), N, replace = TRUE, prob = group_dist)
    
    # empty data frame to hold the simulated data
    sim_dat = data.frame(id = NULL, class = NULL, time = NULL, y_u = NULL)
    
    # simulate data for each individual, one at a time
    # Generate: 
    # y_i.c = b0.c + b1.c * 0 + u_i
    # y_i.c = b0.c + b1.c * 0.5 + u_i
    # y_i.c = b0.c + b1.c * 1 + u_i
    # Then at end of the day, add error_ij to entire dataset
    for (i in 1:N){
      
      class_i = class[i]
      
      # random error
      # icc = s_u^2 / (s_u^2 + s_error ^2) => s_u^2 = s_error^2 * icc / (1 - icc)
      s_u = sqrt(s_error^2 * icc / (1 - icc)) 
      u_i = rnorm(1, mean = 0, sd = s_u) # based on s_error and icc
      time = c(0, 1) # values collected at baseline and 1 year
      
      if (class_i == "C1") y_u = b0.1 + b1.1 * time + u_i
      if (class_i == "C2") y_u = b0.2 + b1.2 * time + u_i
      if (class_i == "C3") y_u = b0.3 + b1.3 * time + u_i
      
      dat_i = data.frame(id = i, class = rep(class_i, 2), time, y_u)
      sim_dat = bind_rows(sim_dat, dat_i)
    }
    
    error = rnorm(2*N, mean = 0, sd = s_error) # add error
    sim_dat = sim_dat %>% mutate(y = y_u + error) # final simulated dataset
    
    # fit true model
    m1 = hlme(y ~ time, subject = "id", data = sim_dat) # lcmm package requires fitting a base model
    tmp_m3 <- hlme(y ~ time, subject = "id", data = sim_dat, 
                   ng = 3, mixture=~time, B=m1)
    tmp_coef = summary(tmp_m3) # get table of estimates and p-values
    
    # it's a little tricky because different implementation of the latent class trajectory may give different order
    # that's fine for usual implementation, but annoying for simulations
    # try to order using the estimated slopes
    tmp_estSlopes = tmp_coef[4:6, 1]
    tmp_estSlopes_dat = data.frame(est_order = 1:3, tmp_estSlopes) %>% arrange(tmp_estSlopes)
    # save results
    if (sum(tmp_estSlopes_dat$est_order == c(1:3))==3) simResults[r,] = c(tmp_coef[,1], tmp_coef[,4]) 
    if (sum(tmp_estSlopes_dat$est_order == c(3,2,1))==3) simResults[r,] = c(tmp_coef[c(c(3,2,1), c(3,2,1)+3),1], 
                                                                            tmp_coef[c(c(3,2,1), c(3,2,1)+3),4]) 
    if (sum(tmp_estSlopes_dat$est_order == c(1,3,2))==3) simResults[r,] = c(tmp_coef[c(c(1,3,2), c(1,3,2)+3),1], 
                                                                            tmp_coef[c(c(1,3,2), c(1,3,2)+3),4]) 
    if (sum(tmp_estSlopes_dat$est_order == c(2,1,3))==3) simResults[r,] = c(tmp_coef[c(c(2,1,3), c(2,1,3)+3),1], 
                                                                            tmp_coef[c(c(2,1,3), c(2,1,3)+3),4]) 
    if (sum(tmp_estSlopes_dat$est_order == c(2,3,1))==3) simResults[r,] = c(tmp_coef[c(c(2,3,1), c(2,3,1)+3),1], 
                                                                            tmp_coef[c(c(2,3,1), c(2,3,1)+3),4]) 
    if (sum(tmp_estSlopes_dat$est_order == c(3,1,2))==3) simResults[r,] = c(tmp_coef[c(c(3,1,2), c(3,1,2)+3),1], 
                                                                            tmp_coef[c(c(3,1,2), c(3,1,2)+3),4]) 
  }
  
  return(simResults) 
  
}


# sim_run = simPower_aim1(N = 450,
#                         group_dist = c(1/3, 1/3, 1/3),
#                         b1.1 = -0.5, # slope for group 1: medium effect size
#                         b1.3 = 0.2, # slope for group 3: small effect size
#                         s_error = 0.2,  
#                         icc = 0.1, 
#                         R = 100 # number of simulated datasets
# )
# # power for slope terms
# apply(sim_run[,10:12], 2, function(x) mean(x < 0.05))
