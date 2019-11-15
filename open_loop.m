%%
% In this document we compare open loog regulation of ion channels to closed loop
% to check whether there is some advantage to using homeostasis to compensate for 
% size changes

addpath(pwd)

x = xolotl.examples.BurstingNeuron;

channels = x.AB.find('conductance');
for i = 1:length(channels)
	x.AB.(channels{i}).add('OpenLoopController','tau_g',Inf,'tau_m',Inf);
end

controllers.configure(x)



% OK, now we will vary the noise in the initial conditions and 
% see how robust open loop control is to this 

N = 10;
M = 15; % number of noise levels
noise_levels = repmat(logspace(-2,2,M),N,1);
noise_levels = noise_levels(:);

all_g0 = zeros(N*M,8);
for i = 1:length(noise_levels)
	all_g0(i,:) = rand(8,1)*noise_levels(i);
end
all_g0(:,7) = 0;


RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1984)); 

[all_g, all_burst_periods, all_duty_cycles, all_Ca] = controllers.integrate(x, '*gbar', all_g0, N*M, 350e3);

% reshape
noise_levels = reshape(noise_levels,N,M);
all_burst_periods = reshape(all_burst_periods,N,M);
all_duty_cycles = reshape(all_duty_cycles,N,M);



all_burst_periods(isnan(all_burst_periods)) = eps;
all_duty_cycles(isnan(all_duty_cycles)) = eps;

% make plot
figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
clear ax
ax(1) = subplot(3,2,1); hold on
plotlib.errorShade(noise_levels(1,:),mean(1e3./all_burst_periods),std(1e3./all_burst_periods)); set(gca,'XScale','log','YScale','linear')
set(gca,'YLim',[0 5])

ax(1) = subplot(3,2,3); hold on
plotlib.errorShade(noise_levels(1,:),mean(all_duty_cycles),std(all_duty_cycles)); set(gca,'XScale','log','YScale','linear')
set(gca,'YLim',[0 1])


% now do it with integral feedback controller

x = xolotl.examples.BurstingNeuron;

channels = x.AB.find('conductance');
for i = 1:length(channels)
	x.AB.(channels{i}).add('IntegralController','tau_g',Inf,'tau_m',Inf);
end

controllers.configure(x)


% OK, now we will vary the noise in the initial conditions and 
% see how robust open loop control is to this 


[all_g, all_burst_periods, all_duty_cycles, all_Ca] = controllers.integrate(x, '*gbar', all_g0, N*M, 350e3);

% reshape
noise_levels = reshape(noise_levels,N,M);
all_burst_periods = reshape(all_burst_periods,N,M);
all_duty_cycles = reshape(all_duty_cycles,N,M);



all_burst_periods(isnan(all_burst_periods)) = eps;
all_duty_cycles(isnan(all_duty_cycles)) = eps;

% make plot
figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
clear ax
ax(1) = subplot(3,2,1); hold on
plotlib.errorShade(noise_levels(1,:),mean(1e3./all_burst_periods),std(1e3./all_burst_periods),'Color','b'); set(gca,'XScale','log','YScale','linear')
set(gca,'YLim',[0 5])

ax(1) = subplot(3,2,3); hold on
plotlib.errorShade(noise_levels(1,:),mean(all_duty_cycles),std(all_duty_cycles),'Color','b'); 
set(gca,'XScale','log','YScale','linear')
set(gca,'YLim',[0 1])
