# power-simulations-for-group-based-trajectory-modeling
Simulations to assess power and feasibility for group-based trajectory modeling. This is a very specific data scenario, which reflects our proposed study.

* The group-based trajectory model consists of three latent groups, with linear trajectories that are characterized as worsening (slope<0), stable (slope=0), and improving (slope>0).
* Each individual is assumed to have data on the continuous outcome (standardized with mean 0, without loss of generality) collected at two time points (baseline, 1-year). Random intercepts are included to account for within-individual clustering.

<!-- ABOUT THE PROJECT -->
## Underlying assumptions and math

* The marginal density for the outcome data $y$ is a mixture-model given by: $$f(y) = \sum_{k=1}^3 Pr(C=k)Pr(Y=y|C=k),$$ where $C$ is one of three distinct latent classes that each individual belongs. 
* The outcome distributions conditional on the class membership are based on a linear mixed effects model with random intercepts for each participant: $$E(Y_{ij}|C=k) = \beta_{0,k} + \beta_{0i,k} + \beta_{1,k} (\mathrm{time_{ij}}) + \xi_{j},$$ for individuals $i=1,\dots,N$ and crossover period $j=1,\dots,J$, where each individual has a random effect $\beta_{0i} \sim N(0,\sigma^2)$. We allow for variation in the outcome prevalence during each crossover period given by $\xi_{j}$, but I will probably not use in the power calculations. 
* Note that for a logistic GLMM, the intracluster coefficient is given by $$\mathrm{ICC}=\displaystyle\frac{\sigma^2}{\sigma^2 + \sigma_e^2},$$ where $\sigma_e^2 = \pi^2/3$. So for power calculation simulations, we can determine the value of $\sigma^2$ by setting the ICC, which is commonly done in power calculations, as follows: $$\sigma^2 = \displaystyle\frac{\sigma_e^2 \cdot \mathrm{ICC}}{(1-\mathrm{ICC})}.$$
* There will be 4 crossover periods consisting of all possible combinations of the following treatments: RC, LC, V, V. There are 12 possible combinations. (This is similar to complete 3X3 crossover design.) For the primary comparison, we will be comparing treatment V vs. treatment C (viewing RC and LC as the same).
* We expect to be able to recruit N=100 subjects. Let's consider the simplest case where we randomize 8 patients to each of the 12 possible combinations, which results in a sample size of 96 patients (pretty close to 100). The goal is to calculate power based on this sample size and estimated outcome prevalences (RC and LC: 20% outcome prevalence [set as reference], V: 35% outcome prevalence).

<!-- SIMULATION APPROACH -->
## Simulation approach

For one simulated dataset:
* Randomize 96 patients to the 12 possible crossover patterns. 
* Generate individual-specific random effects for the 96 individuals.
* Based on the treatment data, individual-specific random effects and the GLMM model above, estimate the individual- and period-specific probability of outcome $E(Y_{ij})=P(Y_{ij}=1)$ and use these to determine the outcome $Y_{ij}$ (0 or 1) based on a Bernoulli distribution.
* Fit the logistic random effects model to the simulated data.

Do this $R$ times. 
* Save treatment estimates, p-values, and estimated random effect variance to assess bias, power, and ICC, respectively. 
