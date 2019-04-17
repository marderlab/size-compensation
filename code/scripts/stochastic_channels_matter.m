%%
% In this script, I check if the stochasticity of channels matters
% in bursting neurons at the default size, and then make the sizes smaller


addpath('../')

x = xolotl.examples.BurstingNeuron('prefix','prinz','CalciumMech','bucholtz');
x.AB.add('Leak','gbar',0);

if exist('stochastic_vs_deterministic_bursters.mat','file') == 2
	load('stochastic_vs_deterministic_bursters.mat')
else


	if ~exist('n','var')
		 n = neuroDB; n.prefix = 'prinz/'; n.data_dump = '/code/neuron-db/prinz/';
	end


	do_these = (n.results.burst_period > 990 & n.results.burst_period < 1010 & n.results.duty_cycle_mean > .19 & n.results.duty_cycle_mean < .21);

	all_g = n.results.all_g(do_these,:);



	p = xgrid;
	p.cleanup;

	p = xgrid;
	p.cleanup;
	p.x = x;
	p.sim_func = @singleCompartment.compareDeterministicStochastic;
	parameters_to_vary = x.find('*gbar');
	p.batchify(all_g',parameters_to_vary);

	p.simulate;
	p.wait;

	[data, all_g] = p.gather;


	save('stochastic_vs_deterministic_bursters.mat','all_g','data')

end


Ca_mean = data{1};
burst_period = data{2};
duty_cycle = data{3};
n_spikes_per_burst = data{4};
firing_rate = data{5};

% throw away badly behaved models
rm_this = burst_period(1,:) < 900 | burst_period(1,:) > 1100 | duty_cycle(1,:) < .19 | duty_cycle(1,:) > .21;
Ca_mean(:,rm_this) = [];
burst_period(:,rm_this) = [];
duty_cycle(:,rm_this) = [];
n_spikes_per_burst(:,rm_this) = [];
firing_rate(:,rm_this) = [];
all_g(:,rm_this) = [];




%%
% I'm choosing several hundred models with very similar behaviour. The following figure shows some of them. 

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

x.t_end = 5e3;
for i = 1:8
	subplot(2,4,i); hold on
	x.reset;
	x.set('*gbar',all_g(:,i));
	x.integrate;
	V = x.integrate;
	a = find(V>0,1,'first');
	V(1:a) = [];
	time = (1:length(V))*x.dt*1e-3;
	plot(time,V,'k')
	set(gca,'XLim',[0 1.8])
	axis off
end


figlib.pretty('plw',1)







figure('outerposition',[300 300 1200 903],'PaperUnits','points','PaperSize',[1200 903]); hold on
subplot(2,3,1); hold on
plot(Ca_mean(1,:),Ca_mean(2,:),'k.')
set(gca,'XScale','log','YScale','log','XLim',[10 1e3],'YLim',[10 1e3])
plotlib.drawDiag;
xlabel('[Ca^{2+}] (deterministic) (uM)')
ylabel('[Ca^{2+}] (stochastic) (uM)')

subplot(2,3,2); hold on
plot(firing_rate(1,:),firing_rate(2,:),'k.')
set(gca,'XScale','log','YScale','log','XLim',[10 1e3],'YLim',[10 1e3])
plotlib.drawDiag;
xlabel('f (Hz) (deterministic)')
ylabel('f (Hz) (stochastic)')

subplot(2,3,3); hold on
plot(n_spikes_per_burst(1,:),n_spikes_per_burst(2,:),'k.')
set(gca,'XScale','log','YScale','log','XLim',[1 100],'YLim',[1 100])
plotlib.drawDiag;
xlabel('#spikes/burst (deterministic)')
ylabel('#spikes/burst (stochastic)')


subplot(2,3,4); hold on
plot(burst_period(1,:),burst_period(2,:),'k.')
set(gca,'XScale','linear','YScale','linear','XLim',[1 3e3],'YLim',[1 3e3])
plotlib.drawDiag;
xlabel('Burst period (ms) (deterministic)')
ylabel('Burst period (ms) (stochastic)')


subplot(2,3,5); hold on
plot(duty_cycle(1,:),duty_cycle(2,:),'k.')
set(gca,'XScale','linear','YScale','linear','XLim',[0 1],'YLim',[0 1])
plotlib.drawDiag;
xlabel('Duty cycle) (deterministic)')
ylabel('Duty cycle) (stochastic)')


subplot(2,3,6); hold on
plot(duty_cycle,burst_period,'Color',[.8 .8 .8])
plot(duty_cycle(1,:),burst_period(1,:),'k.')
ylabel('Burst period (ms)')
xlabel('Duty cycle)')
set(gca,'XLim',[0 1])


figlib.pretty('plw',1,'lw',1)



%%
% now we vary sizes in all these neurons and measure behaviour 

x = xolotl.examples.BurstingNeuron('prefix','prinz','CalciumMech','bucholtz');
x.AB.add('Leak','gbar',0);

if exist('vary_size_in_stochastic_bursters.mat','file') == 2
	load('vary_size_in_stochastic_bursters.mat')
else


	if ~exist('n','var')
		 n = neuroDB; n.prefix = 'prinz/'; n.data_dump = '/code/neuron-db/prinz/';
	end


	do_these = (n.results.burst_period > 990 & n.results.burst_period < 1010 & n.results.duty_cycle_mean > .19 & n.results.duty_cycle_mean < .21);

	all_g = n.results.all_g(do_these,:);



	p = xgrid;
	p.cleanup;
	p.x = x;
	p.sim_func = @singleCompartment.varySizeMeasureBehaviour;
	parameters_to_vary = x.find('*gbar');
	p.batchify(all_g',parameters_to_vary);

	p.simulate;
	p.wait;

	[data, all_g] = p.gather;


	save('vary_size_in_stochastic_bursters.mat','all_g','data')

end


f0 = data{1};
Ca0 = data{2};
all_f = data{3};
isi_mean = data{4};
isi_std = data{5};
Ca_mean = data{6};
Ca_std = data{7};
metrics0 = data{8};
metrics = data{9};

metrics = reshape(metrics,20,size(metrics,1)/20,size(metrics,2));
metrics = metrics(:,1:20,:);

N = 20;
all_sizes = logspace(-4,-1,N);

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

% plot burst periods means
subplot(2,3,1); hold on
plot(all_sizes,squeeze(metrics(1,:,:)),'Color',[.8 .8 .8])
plot(all_sizes,nanmean(squeeze(metrics(1,:,:)),2),'k','LineWidth',3)
set(gca,'XScale','log','YLim',[0 1.5e3])

e = nanstd(metrics0(1,:))/sqrt(size(metrics0,2));
plotlib.errorShade(all_sizes,0*all_sizes + nanmean(metrics0(1,:)), 0*all_sizes + e);

xlabel('Cell size (mm^2)')
ylabel('Burst period (ms)')

% plot burst periods stds
subplot(2,3,2); hold on
plot(all_sizes,squeeze(metrics(2,:,:)),'Color',[.8 .8 .8])
plot(all_sizes,nanmean(squeeze(metrics(2,:,:)),2),'k','LineWidth',3)
set(gca,'XScale','log','YScale','log','YLim',[1 1e3])

e = nanstd(metrics0(2,:))/sqrt(size(metrics0,2));
plotlib.errorShade(all_sizes,0*all_sizes + nanmean(metrics0(2,:)), 0*all_sizes + e);

xlabel('Cell size (mm^2)')
ylabel('\sigma (Burst period) (ms)')


% duty cycle
subplot(2,3,3); hold on
plot(all_sizes,squeeze(metrics(3,:,:)),'Color',[.8 .8 .8])
plot(all_sizes,nanmean(squeeze(metrics(3,:,:)),2),'k','LineWidth',3)
set(gca,'XScale','log','YScale','linear','YLim',[0 1])

e = nanstd(metrics0(3,:))/sqrt(size(metrics0,2));
plotlib.errorShade(all_sizes,0*all_sizes + nanmean(metrics0(3,:)), 0*all_sizes + e);


ylabel('Duty cycle')

% plot calcium
subplot(2,3,4); hold on
idx = corelib.closest(all_sizes,.0628);
plot(all_sizes,Ca_mean./Ca_mean(idx,:),'Color',[.8 .8 .8])
plot(all_sizes,mean(Ca_mean./Ca_mean(idx,:),2),'k','LineWidth',3)
set(gca,'XScale','log','YScale','linear','YLim',[.1 3])

ylabel('<[Ca]>/<[Ca]>_{baseline}')
xlabel('Cell size (mm^2)')


% compare constancy of duty cycles and burst periods
subplot(2,3,5); hold on
X = abs(log(squeeze(metrics(3,1,:))./squeeze(metrics(3,20,:))));
Y = abs(log(squeeze(metrics(1,1,:))./squeeze(metrics(1,20,:))));

scatter(X,Y,23,'Marker','o','MarkerFaceAlpha',.01,'MarkerFaceColor','k','MarkerEdgeColor','k','MarkerEdgeAlpha',.3)
set(gca,'XLim',[0 .5],'YLim',[0 .5],'YScale','linear','XScale','linear')
l = plotlib.drawDiag;
l.Color = 'r';
l.LineStyle = '-';

xlabel('Error in duty cycle (a.u.)')
ylabel('Error in burst period (a.u.)')

figlib.pretty()




%%
% What about some of these models more or less susceptible to size changes? 


% measure correlations b/w all pairs of ratios and the error in the duty
% cycles

m_dc = abs(log(squeeze(metrics(3,1,:))./squeeze(metrics(3,20,:))));
s_dc = abs(log(squeeze(metrics(4,1,:))./squeeze(metrics(4,20,:))));

C = NaN(8,8);

for i = 1:8
	for j = 1:8
		X = all_g(i,:)./all_g(j,:);
		C(i,j) = statlib.correlation(X(:),E_dc,'Type','Pearson');
	end
end

plotlib.cplot(R(:,1),R(:,2),E_dc)



return

%% 
% Now we look at temperatire

x = xolotl;
x.add('compartment','AB','A',0.0628);

x.AB.add('prinz/CalciumMech');

x.AB.add('prinz-temperature/NaV','gbar',1000);
x.AB.add('prinz-temperature/CaT','gbar',25);
x.AB.add('prinz-temperature/CaS','gbar',60);
x.AB.add('prinz-temperature/ACurrent','gbar',500);
x.AB.add('prinz-temperature/KCa','gbar',50);
x.AB.add('prinz-temperature/Kd','gbar',1000);
x.AB.add('prinz-temperature/HCurrent','gbar',.1);

x.set('*Q_g',1)
x.set('*Q_tau_m',2)
x.set('*Q_tau_h',2)


if exist('vary_temperature_bursters.mat','file') == 2
	load('vary_temperature_bursters.mat')
else





	p = xgrid;
	p.cleanup;
	p.x = x;
	p.sim_func = @varyTemperatureMeasureBehaviour;
	parameters_to_vary = x.find('*gbar');
	p.batchify(all_g',parameters_to_vary);

	p.simulate;
	p.wait;

	[data, all_g] = p.gather;


	save('vary_temperature_bursters.mat','all_g','data')

end




%%
% Now we vary the size of a very large number of bursting neurons and see which ones falter when we make them smaller. 


x = xolotl.examples.BurstingNeuron('prefix','prinz','CalciumMech','bucholtz');
x.AB.add('Leak','gbar',0);

if exist('vary_size_in_many_bursters.mat','file') == 2
	load('vary_size_in_many_bursters.mat')
else


	if ~exist('n','var')
		 n = neuroDB; n.prefix = 'prinz/'; n.data_dump = '/code/neuron-db/prinz/';
	end


	do_these = (n.results.burst_period > 950 & n.results.burst_period < 1050 & n.results.duty_cycle_mean > .19 & n.results.duty_cycle_mean < .21);

	all_g = n.results.all_g(do_these,:);


	p = xgrid;
	p.cleanup;
	p.x = x;
	p.sim_func = @singleCompartment.twoSizesMeasureMetrics;
	parameters_to_vary = x.find('*gbar');
	p.n_batches = 20;
	p.batchify(all_g',parameters_to_vary);

	p.simulate;
	p.wait;

	[data, all_g] = p.gather;


	save('vary_size_in_many_bursters.mat','all_g','data')

end

metrics0 = data{1};
metrics_big = data{2};
metrics_small = data{3};

metrics_small = reshape(metrics_small,20,20,size(metrics_small,2));
metrics_big = reshape(metrics_big,20,20,size(metrics_big,2));

% exclude some bad neurons
bad_neurons = metrics0(1,:) < 950 | metrics0(1,:) > 1050 | isnan(metrics0(1,:));

metrics0(:,bad_neurons) = [];
metrics_big(:,:,bad_neurons) = [];
metrics_small(:,:,bad_neurons) = [];
all_g(:,bad_neurons) = [];



figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

% compare determinstic and stochastic

det_period_mean = metrics0(1,:);
big_period_mean = squeeze(mean(metrics_big(1,:,:)));
big_period_std = squeeze(std(metrics_big(1,:,:)));

small_period_mean = squeeze(mean(metrics_small(1,:,:)));
small_period_std = squeeze(std(metrics_small(1,:,:)));

small_dc_mean = squeeze(mean(metrics_small(3,:,:)));
big_dc_mean = squeeze(mean(metrics_big(3,:,:)));
small_dc_std = squeeze(std(metrics_small(3,:,:)));
big_dc_std = squeeze(std(metrics_big(3,:,:)));

subplot(2,3,1); hold on
plot(det_period_mean,big_period_mean,'k.')
xlabel('Deterministic')
title('Mean burst period')
ylabel('Large stochastic')
plotlib.drawDiag
set(gca,'XLim',[500 1500],'YLim',[500 1500])
axis square


subplot(2,3,2); hold on
plot(small_period_mean,big_period_mean,'k.')
xlabel('Small stochastic')
title('Mean burst period')
ylabel('Large stochastic')
plotlib.drawDiag;
set(gca,'XLim',[500 1500],'YLim',[500 1500])
axis square


subplot(2,3,3); hold on
plot(small_period_std./small_period_mean,big_period_std./big_period_mean,'k.')
xlabel('Small stochastic')
title('CV burst period')
ylabel('Large stochastic')
plotlib.drawDiag;
set(gca,'XLim',[0 .2],'YLim',[0 .2])
axis square

subplot(2,3,4); hold on
plot(metrics0(3,:),big_dc_mean,'k.')
xlabel('Deterministic')
title('Mean duty cycle')
ylabel('Large stochastic')
plotlib.drawDiag
set(gca,'XLim',[0 .4],'YLim',[0 .4])
axis square



subplot(2,3,5); hold on
plot(small_dc_mean,big_dc_mean,'k.')
xlabel('Small stochastic')
title('Mean duty cycle')
ylabel('Large stochastic')
plotlib.drawDiag;
set(gca,'XLim',[0 .4],'YLim',[0 .4])
axis square



subplot(2,3,6); hold on
plot(small_dc_std./small_dc_mean,big_dc_std./big_dc_mean,'k.')
xlabel('Small stochastic')
title('CV Duty cycle')
ylabel('Large stochastic')
plotlib.drawDiag;
set(gca,'XLim',[0 .2],'YLim',[0 .2])
axis square


figlib.pretty


%
% Is the change in duty cycle more or less than the change in the burst period?

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

X = abs(log(small_dc_mean./big_dc_mean));
Y = abs(log(small_period_mean./big_period_mean));
plot(X,Y,'k.')








% compare neurons that are stable with size and those that are not
% w.r.t burst period

[~,idx] = sort(abs(big_period_mean - small_period_mean));

temp = big_period_mean - small_period_mean;
temp(isnan(temp)) = 0;
[~,idx2] = sort((temp),'descend');

% this one is weird
idx2(3) = [];

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

x.stochastic_channels = 1;

for i = 1:4

	subplot(4,2,(i-1)*2+1); hold on

	x.set('*gbar',all_g(:,idx(i)));
	x.reset;

	x.AB.A = 1e-1;
	x.AB.vol = 1e-1;

	x.integrate;
	V = x.integrate;


	time = (1:length(V))*1e-3*x.dt;
	plot(time, V,'k')


	x.reset;
	x.AB.A = 1e-4;
	x.AB.vol = 1e-4;
	x.integrate;
	V = x.integrate;
	plot(time, V+150,'r')

	if i == 4
		axlib.makeEphys(gca);
	else
		axis off
	end


	subplot(4,2,(i-1)*2+2); hold on

	x.set('*gbar',all_g(:,idx2(i)));
	x.reset;

	x.AB.A = 1e-1;
	x.AB.vol = 1e-1;

	x.integrate;
	V = x.integrate;


	time = (1:length(V))*1e-3*x.dt;
	plot(time, V,'k')


	x.reset;
	x.AB.A = 1e-4;
	x.AB.vol = 1e-4;
	x.integrate;
	V = x.integrate;
	plot(time, V+150,'r')

	if i == 4
		axlib.makeEphys(gca);
	else 
		axis off
	end

end

figlib.pretty