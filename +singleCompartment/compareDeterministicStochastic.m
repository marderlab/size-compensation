% this function compares determinisitc and stochastic simulations
% of bursting neurons 

function [Ca_mean, burst_period, duty_cycle, n_spikes_per_burst, firing_rate] = compareDeterministicStochastic(x,~,~)

% placehodlers
Ca_mean = [NaN; NaN];
burst_period = [NaN; NaN];
duty_cycle = [NaN; NaN];
n_spikes_per_burst = [NaN; NaN];
firing_rate = [NaN; NaN];

% ensure we do things right
x.AB.A = 0.0628;
x.AB.vol = 0.0628;
x.dt = .1;
x.sim_dt = .05;
x.t_end = 1e4;
x.approx_channels = 0;

% first measure metrics in the noiseless case
x.stochastic_channels = 0;
x.reset;
x.integrate;
[V,Ca] = x.integrate;
metrics = xtools.V2metrics(V,'sampling_rate',round(1/x.dt));

Ca_mean(1) = mean(Ca(:,1));
burst_period(1) = metrics.burst_period;
duty_cycle(1) = metrics.duty_cycle_mean;
n_spikes_per_burst(1) = metrics.n_spikes_per_burst_mean;
firing_rate(1) = xtools.findNSpikes(V)/(x.t_end*1e-3*x.dt);


% now the stochastic case
x.stochastic_channels = 1;
x.reset;
x.integrate;
[V,Ca] = x.integrate;
metrics = xtools.V2metrics(V,'sampling_rate',round(1/x.dt));

Ca_mean(2) = mean(Ca(:,1));
burst_period(2) = metrics.burst_period;
duty_cycle(2) = metrics.duty_cycle_mean;
n_spikes_per_burst(2) = metrics.n_spikes_per_burst_mean;
firing_rate(2) = xtools.findNSpikes(V)/(x.t_end*1e-3*x.dt);

disp('Calcium levels = ')
disp(Ca_mean)

disp('DONE')