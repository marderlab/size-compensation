%%
% In this script, we show that stochastic channels matter even in large
% neurons because some neuron models may have very small conductance
% densities (especially for Leak and HCurrent)


addpath('../')



if exist('stochastic_vs_deterministic_bursters.mat','file') == 2
	load('stochastic_vs_deterministic_bursters.mat')
else


	if ~exist('n','var')
		 n = neuroDB; n.prefix = 'prinz/'; n.data_dump = '/code/neuron-db/prinz/';
	end


	do_these = (n.results.burst_period > 990 & n.results.burst_period < 1010 & n.results.duty_cycle_mean > .19 & n.results.duty_cycle_mean < .21);

	all_g = n.results.all_g(do_these,:);


	x = xolotl.examples.BurstingNeuron('prinz');
	x.AB.add('Leak');


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

