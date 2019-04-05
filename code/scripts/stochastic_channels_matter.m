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