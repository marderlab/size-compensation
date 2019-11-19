%%
% In this document we compare open loog regulation of ion channels to closed loop
% to check whether there is some advantage to using homeostasis to compensate for 
% size changes

addpath(pwd)

x = xolotl.examples.BurstingNeuron('CalciumMech','buchholtz');


figure('outerposition',[300 300 901 1200],'PaperUnits','points','PaperSize',[901 1200]); hold on
subplot(4,2,1); hold on
x.t_end = 3e3;
V = x.integrate;

time = (1:length(V))*1e-3*(x.dt);
plot(time,V,'k')


channels = x.AB.find('conductance');
for i = 1:length(channels)
	x.AB.(channels{i}).add('OpenLoopController','tau_g',Inf,'tau_m',Inf);
end

controllers.configure(x)


x.AB.add('LinearGrowth','rate',1e-6)
%x.AB.add('LinearGrowth','rate',1.9e-7)

x.set('*start',1e6)
x.set('*stop',9e7)

x.t_end = 500e3;
x.output_type = 1;
x.dt = 10;
data = x.integrate;

A = data.AB.LinearGrowth;

time = (1:length(A))*x.dt*1e-3;


subplot(4,1,2); hold on
plot(time,A,'k')
ylabel('Area (mm^2)')

subplot(4,1,3); hold on
plot(time,data.AB.NaV.OpenLoopController(:,2))
ylabel('g_{NaV}')
set(gca,'YLim',[900 1100])


x.t_end = 3e3;
x.dt = .1;
x.output_type = 0;
V = x.integrate;
time = (1:length(V))*1e-3*(x.dt);
subplot(4,2,8); hold on
plot(time,V,'r')



figlib.pretty('PlotLineWidth',1)





return



% OK, now we will vary the noise in the initial conditions and 
% see how robust open loop control is to this 

N = 100;
M = 50; % number of noise levels
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
