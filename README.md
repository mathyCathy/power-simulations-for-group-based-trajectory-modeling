# power-simulations-for-group-based-trajectory-modeling
Simulations to assess power and feasibility for group-based trajectory modeling. This is a very specific data scenario, which reflects our proposed study.

* The group-based trajectory model consists of three latent groups, with linear trajectories that are characterized as worsening (slope<0), stable (slope=0), and improving (slope>0).
* Each individual is assumed to have data on the continuous outcome (standardized with mean 0, without loss of generality) collected at two time points (baseline, 1-year). Random intercepts are included to account for within-individual clustering.

[traj_plot_for_sims.tiff](https://github.com/user-attachments/files/28080258/traj_plot_for_sims.tiff)

<!-- ABOUT THE PROJECT -->
## Underlying assumptions and math

* The marginal density for the outcome data $y$ is a mixture-model given by: $$f(y) = \sum_{k=1}^3 Pr(C=k)Pr(Y=y|C=k),$$ where $C$ is one of three distinct latent classes that each individual belongs. 
* The outcome distributions conditional on the class membership, $C_i = k$, are based on a linear mixed effects model with random intercepts for each participant: $$Y_{ij,k} = \beta_{0,k} + \beta_{0i,k} + \beta_{1,k} (\mathrm{time_{ij}}) + \epsilon_{ij,k},$$ for individuals $i=1,\dots,N$ and crossover period $j=1,\dots,J$, where each individual has a random effect $\beta_{0i,k} \sim N(0,\sigma_u^2)$ and $\epsilon_{ij,k} \sim N(0,\sigma_e^2)$ is random noise. 
* Note that the intracluster coefficient is given by $$\mathrm{ICC}=\displaystyle\frac{\sigma_u^2}{\sigma_u^2 + \sigma_e^2}.$$ So for power calculation simulations, we can determine the value of $\sigma_u^2$ by setting the ICC and $\sigma_e$, which is commonly done in power calculations, as follows: $$\sigma_u^2 = \displaystyle\frac{\sigma_e^2 \cdot \mathrm{ICC}}{(1-\mathrm{ICC})}.$$

<!-- SIMULATION APPROACH -->
## Simulation approach

For one simulated dataset:
* Assume N=450 subjects, the projected sample size.
* Randomly assign each subject to one of three latent classes. Since we do not know ahead of time the distribution of the classes, we assumed classes are equally distributed here.
* For each individual, draw a random effect from $N(0,\sigma_u^2)$ distribution.
* Calculate the individual-specific outcome $Y_{ij,k}$ based on the model and random noise drawn from $N(0,\sigma_e^2)$
* Fit the group-based trajectory model using `lcmm` package in R.
* Save the slope estimates and p-values. (For these power calculations, we focus on the "worsening" or "improving" slopes. Since the "stable" trajectory is assumed to have slope 0, these calculations provide estimates of type I error.)

Do this $R$ times. 
* Estimate power for the two slope parameters; for each parameter, report the proportion of simulated data sets where the estimated slope had p-value<0.05 (i.e., rejected the null when the true slope was non-zero).
