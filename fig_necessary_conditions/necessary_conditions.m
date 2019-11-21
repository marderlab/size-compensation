
%%
% In this figure, we show the necessary conditions for feedback co-regulation to be robust to size changes. 


close all
clearvars

% get lots of bursting neuron models with some narrow set of parameters

if exist('bursting_neurons.mat','file') == 2
	load('bursting_neurons.mat','all_g')
else

	n = neuroDB;
	n.DataDump = '/code/neuron-db/prinz/';

	min_T = .9e3;
	max_T = 1.1e3;
	min_dc = .19;
	max_dc = .21;
	n_spikes = 10;



	use_these = n.results.burst_period > min_T & n.results.burst_period < max_T & n.results.duty_cycle_mean > min_dc & n.results.duty_cycle_mean < max_dc & n.results.n_spikes_per_burst_mean == n_spikes; 

	all_g = n.results.all_g(use_these,:);

	save('bursting_neurons.mat','all_g')

end






% now compute the calcium as we scale all g

n_models = size(all_g,1);
scale_factor = logspace(-1,.5,202);
all_Ca = NaN(n_models,length(scale_factor));
all_burst_periods = NaN(n_models,length(scale_factor));
all_duty_cycles = NaN(n_models,length(scale_factor));

x = xolotl.examples.BurstingNeuron();
x.t_end = 10e3;

if exist('bursting_neurons_all_Ca.mat','file') == 2
	load('bursting_neurons_all_Ca.mat','all_Ca','all_burst_periods','all_duty_cycles')
else

	for i = 1:n_models

		corelib.textbar(i,n_models)

		parfor j = 1:length(scale_factor)

			x.reset;
			x.set('*gbar',all_g(i,:)*scale_factor(j));
			x.integrate;
			V = x.integrate;

			all_Ca(i,j) = x.AB.Ca_average;


			metrics = xtools.V2metrics(V,'sampling_rate',1/x.dt);

			all_burst_periods(i,j) = metrics.burst_period;
			all_duty_cycles(i,j) = metrics.duty_cycle_mean;

		end
	end

	save('bursting_neurons_all_Ca.mat','all_Ca','all_burst_periods','all_duty_cycles')
end


% normalize by target
target_Ca = all_Ca(:,scale_factor == 1);
T0 = all_burst_periods(:,scale_factor == 1);
DC0 = all_duty_cycles(:,scale_factor == 1);


for i = 1:n_models
	all_Ca(i,:) = all_Ca(i,:)/target_Ca(i);
	all_burst_periods(i,:) = all_burst_periods(i,:)/T0(i);
	all_duty_cycles(i,:) = all_duty_cycles(i,:)/DC0(i);

end


% show how many corssings there are
n_crossings = zeros(n_models,1);
for i = 1:n_models
	n_crossings(i) = length(find(diff(all_Ca(i,:)>1) > 0));
end
% build a cumulative histogram
n_models_with_n_crossings = NaN(100,1);
for i = 1:100
	n_models_with_n_crossings(i) = sum(n_crossings == i);
end
n_models_with_n_crossings = cumsum(n_models_with_n_crossings);
n_models_with_n_crossings = n_models_with_n_crossings/n_models_with_n_crossings(end);


fixed_point_locs = 0*all_Ca;
for i = 1:n_models
	stable_fp = (find(diff(all_Ca(i,:)>1) > 0));
	fixed_point_locs(i,stable_fp) = 1;

	unstable_fp = (find(diff(all_Ca(i,:)>1) < 0));
	fixed_point_locs(i,unstable_fp) = -1;
end



figure('outerposition',[300 300 1200 1301],'PaperUnits','points','PaperSize',[1200 1301]); hold on
clear ax


% show the illustratvie graph
ax(1) = subplot(3,3,1); hold on


plotlib.trajectory(linspace(1,2,100),linspace(1,2,100),'NArrows',1);
xlabel('g_1')
ylabel('g_2')
plot([1,2],[1,2],'ko','MarkerFaceColor','k')
set(gca,'XLim',[0.5 2.5],'YLim',[0.5 2.5])
text(2.05,2.15,'g(t+\Deltat)','FontSize',20);
text(1,.9,'g(t)','FontSize',20);
plot([1 2],[1 1],'k:')
plot([2 2],[1 2],'k:')
ax(1).XTick = [];
ax(1).YTick = [];

% show two example traces first
show_this = 148;
ax(2) = subplot(3,3,2); hold on
plot(scale_factor,all_Ca(show_this,:),'Color',[.5 .5 .5],'LineWidth',4)
plotlib.horzline(1,'k:');
plotlib.vertline(1,'k:');
xlabel('Scale factor on conductances')
ylabel('<Ca>/Ca_T')

% indicate locations of stable fixed points
idx = fixed_point_locs(show_this,:) == 1;
scatter(scale_factor(idx),all_Ca(show_this,idx),64,'MarkerFaceColor','w','MarkerEdgeColor','k','LineWidth',2)

a = annotation('textarrow',[0.3 0.5],[0.6 0.5],'String','Single stable fixed point');
a.Position = [0.49    0.7441   -0.0116    0.0207];
a.FontSize = 14;


ax(3) = subplot(3,3,3); hold on
show_this = 184;
plot(scale_factor,all_Ca(show_this,:),'Color',[.5 .5 .5],'LineWidth',4)
plotlib.horzline(1,'k:');
plotlib.vertline(1,'k:');
idx = fixed_point_locs(show_this,:) == 1;
scatter(scale_factor(idx),all_Ca(show_this,idx),64,'MarkerFaceColor','w','MarkerEdgeColor','k','LineWidth',2)
xlabel('Scale factor on conductances')
ylabel('<Ca>/Ca_T')

a = annotation('textarrow',[0.3 0.5],[0.6 0.5],'String',['Multiple stable'  newline  'fixed points']);
a.Position = [0.775    0.8   -0.0187    0.0533];
a.FontSize = 14;



a = annotation('arrow',[0.3 0.5],[0.6 0.5]);
a.Position = [0.7801    0.8    0.0704    0.05];



ax(4) = subplot(3,3,4); hold on
plotlib.errorShade(scale_factor,mean(all_Ca),std(all_Ca),'Color',[.5 .5 .5]);

xlabel('Scale factor on conductances')
ylabel('<Ca>/Ca_T')



ax(5) = subplot(3,3,5); hold on
plot(1:length(n_models_with_n_crossings),n_models_with_n_crossings,'ko-')
set(gca,'XLim',[0 5])
xlabel('# stable fixed points')
ylabel('Cumulative probability')


% plot duty cycle and period for all stable fixed points

ax(6) = subplot(3,3,6); hold on
scatter(all_burst_periods(:),all_Ca(:),15,'MarkerEdgeColor',[1 0 0],'MarkerEdgeAlpha',.1,'Marker','.')
set(gca,'XScale','log','YScale','log');
xlabel('Burst period (norm)')
ylabel('<Ca>/Ca_T')
plotlib.horzline(1,'Color','k');
plotlib.vertline(1,'Color','k');


ax(7) = subplot(3,3,7); hold on
scatter(all_duty_cycles(:),all_Ca(:),15,'MarkerEdgeColor',[0 0 1],'MarkerEdgeAlpha',.1,'Marker','.')
set(gca,'XScale','log','YScale','log')
xlabel('Duty cycle (norm)')
ylabel('<Ca>/Ca_T')
plotlib.horzline(1,'Color','k');
plotlib.vertline(1,'Color','k');




ax(8) = subplot(3,3,8); hold on
scatter(all_burst_periods(fixed_point_locs == 1),all_duty_cycles(fixed_point_locs == 1),24,'MarkerFaceColor','k','MarkerFaceAlpha',.1,'MarkerEdgeColor','k','MarkerEdgeAlpha',.1)
xlabel('Burst period (norm)')
ylabel('Duty cycle (norm)')
plotlib.horzline(1,'k:');
plotlib.vertline(1,'k:');
set(gca,'XColor','r')
set(gca,'YColor','b')

ax(9) = subplot(3,3,9); hold on
% compute error at all stable fixed points
error_T = abs(all_burst_periods(fixed_point_locs == 1) - 1);
error_DC = abs(all_duty_cycles(fixed_point_locs == 1) - 1);



[hy,hx] = histcounts(error_T,1e3);
Y = cumsum(hy); Y = Y/Y(end);
plot(hx(2:end),Y,'r');

[hy,hx] = histcounts(error_DC,1e3);
Y = cumsum(hy); Y = Y/Y(end);
plot(hx(2:end),Y,'b');
set(gca,'YLim',[0 1])
ylabel('Cumulative probability')
xlabel('Fractional error at fixed point')
legend({'Burst period','Duty cycle'},'Location','southeast')


figlib.pretty('FontSize',16)

set(ax(4),'XScale','log','YScale','log','XLim',[scale_factor(1) scale_factor(end)])
plotlib.horzline(ax(4),1,'k:');
plotlib.vertline(ax(4),1,'k:');
ax(5).YLim = [0 1];

for i = 1:9
	axis(ax(i),'square')
end


figlib.label('x_offset',.01,'font_size',28)






return

% how do we pick neuron models so that we get only one fixed point? 
figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

for i = 1:8
	subplot(2,4,i); hold on

	this_g = all_g(:,i);

	bin_edges = linspace(min(this_g),max(this_g),30);
	bin_centers = bin_edges(1:end-1) + mean(diff(bin_edges))/2;

	YM = NaN(length(bin_edges)-1,1);
	YS = YM;


	for j = 1:length(YM)

		this  = n_crossings(this_g>bin_edges(j) & this_g<bin_edges(j+1));
		YM(j) = mean(this);
		YS(j) = std(this);

	end

	rm_this = isnan(YM);


	plotlib.errorShade(bin_centers(~rm_this),YM(~rm_this),YS(~rm_this))

end