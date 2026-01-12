%% CORROSION-FATIGUE WITH AREA LOSS + PIT GROWTH (Kt) + 10-YEAR SIM
clc; clear; close all;
%Define Parameters
% Base loading (nominal)
sigma_max0 = 400;     % MPa
sigma_min0 = 50;      % MPa
sigma_a0   = (sigma_max0 - sigma_min0)/2;   % nominal stress amplitude (MPa)
sigma_m0   = (sigma_max0 + sigma_min0)/2;   % nominal mean stress (MPa)

% Fatigue model (Basquin S-N: N = A*(sigma_a)^(-b))
A_sn = 1e14;          % tune/calibrate for your steel strand
b_sn = 5;             % slope

% Corrosion parameters (rate severity)
k_cor = 1e-4;
n_cor = 1.2;
Ea = 5000;            % J/mol
R  = 8.314;           % J/mol-K

% Coating degradation (barrier effectiveness)
f_coating = @(t) exp(-0.01*t);   % t in days

% Environment
Cl = 3.5;             % %
T  = 298;             % K

% Time settings (10 years)
years = 10;
t_days = 0:1:(365*years);
dt = 1;               % day
cycles_per_day = 1000;
%Corrosion severity rate CR(t)
CR = k_cor * (Cl^n_cor) * exp(-Ea/(R*T)) .* (1 - f_coating(t_days));

figure;
plot(t_days, CR, 'LineWidth', 2);
xlabel('Time (days)'); ylabel('Corrosion severity rate (scaled)');
title('Corrosion Severity Rate vs Time');
grid on;
%Geometry / Area loss model
% Assume circular wire/strand equivalent area
d0 = 10;                       % mm (equivalent diameter)
A0 = pi*(d0/2)^2;              % mm^2 initial area

% Map corrosion severity into thickness loss rate (mm/day)
% (This is a modeling choice; you can tune gamma)
gamma_thick = 5;               % mm per (severity unit)
thick_loss_rate = gamma_thick * CR;   % mm/day (scaled)

% Convert thickness loss into diameter reduction
% For simplicity: diameter decreases by 2 * thickness loss
d = zeros(size(t_days));
d(1) = d0;

for i = 2:length(t_days)
    d(i) = max(d(i-1) - 2*thick_loss_rate(i)*dt, 0.2); % prevent zero/negative
end

A = pi*(d/2).^2;               % mm^2 remaining cross-sectional area
area_ratio = A0 ./ A;          % stress amplification due to area loss
%Pit growth model -> Stress concentration Kt(t)
% Simple pit depth growth: p(t) accumulates with corrosion severity
p = zeros(size(t_days));       % pit depth (mm)

gamma_pit = 2;                 % mm per (severity unit) -> tune
for i = 2:length(t_days)
    p(i) = p(i-1) + gamma_pit * CR(i)*dt;
end

% Convert pit depth into stress concentration factor
% Kt = 1 + beta*(p/d)
beta = 8;                      % sensitivity of Kt to p/d -> tune
Kt = 1 + beta*(p./d);

% cap Kt to avoid unrealistic blow-up
Kt = min(Kt, 5);
%Updated stress amplitude and fatigue damage
D = zeros(size(t_days));
N_eff = zeros(size(t_days));

for i = 2:length(t_days)

    % Updated amplitude from:
    % 1) reduced area increases nominal stress
    % 2) pit causes stress concentration
    sigma_a = sigma_a0 * area_ratio(i) * Kt(i);

    % Basquin life at current effective amplitude
    N_eff(i) = A_sn * (sigma_a)^(-b_sn);

    % prevent tiny life causing numerical blow-up
    N_eff(i) = max(N_eff(i), 1e3);

    % Miner damage
    D(i) = D(i-1) + cycles_per_day / N_eff(i);
end

%Plots
figure;
plot(t_days, d, 'LineWidth', 2);
xlabel('Time (days)'); ylabel('Equivalent diameter (mm)');
title('Area Loss Model: Diameter Reduction Over Time');
grid on;

figure;
plot(t_days, Kt, 'LineWidth', 2);
xlabel('Time (days)'); ylabel('Stress concentration factor K_t');
title('Pit Growth Effect: Stress Concentration vs Time');
grid on;

figure;
plot(t_days, D, 'LineWidth', 2);
xlabel('Time (days)'); ylabel('Cumulative Damage D');
title('Corrosion-Fatigue Damage with Area Loss + Pit Growth');
grid on;

yline(1,'--','Failure (D=1)','LineWidth',1.5);
%Failure Day
failure_idx = find(D>=1, 1, 'first');
if isempty(failure_idx)
    disp('No failure predicted within simulation period');
else
    fprintf('Predicted failure occurs at day: %d (%.2f years)\n', ...
        t_days(failure_idx), t_days(failure_idx)/365);
end
%Quick Summary Metrics
fprintf('After %d years: D = %.3f, Diameter = %.2f mm, Kt = %.2f\n', ...
    years, D(end), d(end), Kt(end));
