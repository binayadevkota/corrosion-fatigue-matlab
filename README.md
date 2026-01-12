# Corrosion–Fatigue Degradation Modeling of Steel Strands (MATLAB)

This repository contains a physics-informed MATLAB model developed to study the interaction between corrosion and fatigue in steel strands subjected to cyclic loading under aggressive environments.

The model focuses on capturing qualitative trends and degradation mechanisms rather than providing calibrated life predictions.

## Key Features
- Time-dependent coating degradation and corrosion severity modeling
- Corrosion-induced cross-sectional area loss
- Pit-growth-based stress concentration effects
- Stress-dependent fatigue life using Basquin S–N relationship
- Nonlinear fatigue damage accumulation using Miner’s rule
- Long-term (multi-year) degradation simulation

## Modeling Approach

1. Corrosion Modeling
   Corrosion severity evolves over time as the protective coating degrades, leading to increased exposure of the steel surface.

2. Area Loss 
   Progressive corrosion reduces the effective cross-sectional area, increasing nominal stress under constant loading.

3. Pit Growth and Stress Concentration 
   Corrosion pits are modeled as local defects that introduce stress concentration factors, accelerating fatigue crack initiation.

4. Fatigue Damage Accumulation 
   Fatigue life is evaluated dynamically using a stress-based S–N curve, and cumulative damage is tracked using Miner’s rule.


## 🛠 Tools Used
- MATLAB
- Fatigue theory (S–N curves)
- Damage accumulation (Miner’s rule)


