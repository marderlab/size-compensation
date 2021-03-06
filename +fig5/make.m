

clear ax
addpath('../')
close all


try
	data_loc = getpref('size_comp','data');
catch
	error('Tell this script where the data is using setpref>size_comp>data/')
end


figure('outerposition',[300 300 800 801],'PaperUnits','points','PaperSize',[800 801]); hold on
for i = 4:-1:1
	ax(i) = subplot(2,2,i); hold on
	
end

axis(ax(1),'square')
axis(ax(2),'square')
axis(ax(4),'square')






% now we look at generalized perturbations 

g0 = [379 165 2.35 .72 297 1713 .46 1370];

% control -- integral controller
x = singleCompartment.makeNeuron('controller_type','oleary/IntegralController');
x.set('*gbar',g0)
x.reset
x.integrate;
singleCompartment.configureControllers(x,5e3);
x.t_end = 5e3;


% measure the metrics 
x.t_end = 20e3;
x.dt = .1;
x.integrate;
V = x.integrate;
metrics0 = xtools.V2metrics(V,'sampling_rate',1/x.dt);

% make a matrix of all the gbars corresponding to the perturbations 
N = 100;
all_mu = linspace(-.90,.90,N); % fraction
all_sigma = corelib.logrange(1e-3,.20,N); % fraction



all_gbar = repmat(g0,N*N,1);

idx = 1;

for i = 1:N
	for j = 1:N

		all_gbar(idx,:) = (randn(8,1)*all_sigma(i) + all_mu(j)) + 1;
		all_gbar(idx,:) = all_gbar(idx,:) .*g0;
		idx = idx + 1;
	end
end



all_gbar = abs(all_gbar);
all_gbar(:,7) = g0(7);
all_gbar = all_gbar';

if exist(fullfile(data_loc,'generalized_perturbations.mat'),'file') == 2

	load(fullfile(data_loc,'generalized_perturbations.mat'),'data','params')
else

	p = xgrid;
	p.cleanup;
	p.x = x;


	p.sim_func = @singleCompartment.perturb.coherenceAmplitude;

	parameters_to_vary = x.find('*gbar');

	p.batchify(all_gbar,parameters_to_vary);


	p.simulate;
	p.wait;


	[data, params] = p.gather;


	save(fullfile(data_loc,'generalized_perturbations.mat'),'data','params')
end

metrics = data{1};
gbar = data{2};

Ca_error  = data{3};

% back calculate mean and std of perturbation 
all_gbar = params./g0';
all_gbar(7,:) = [];
all_gbar = all_gbar - 1;

all_mu = mean(all_gbar);
all_sigma = std(all_gbar);



sh = scatter(ax(3),all_sigma,metrics(1,:),34,all_mu,'filled','Marker','o');
set(ax(3),'XScale','log')
ylabel(ax(3),'Burst period (ms)')
xlabel(ax(3),'$\sigma_{perturbation}$','interpreter','latex')
lh = plotlib.horzline(ax(3),metrics0.burst_period);
lh.LineStyle = '-.';
lh.Color = 'k';
ch = colorbar;
colormap(ax(3),(colormaps.redblue))
colormap(ch,colormaps.redblue)

sh.MarkerEdgeColor = [.5 .5 .5];

ax(3).YTick = 600:200:1400;

ax(3).XLim(2) = max(all_sigma);
ax(3).XTick = logspace(-4,-1,4);

title(ch,'$\mu_{perturb}$','interpreter','latex')
caxis([-.9 .9])

ch.Position = [.2 .28 .018 .14];











% now we show calcium nullclines for a whole bunch of very similar neurons
% but with different properties in the standard projection

allfiles = dir(fullfile(data_loc,'perturb-similar-bursters','*calcium.voronoi'));
alldata = singleCompartment.perturb.consolidateCalciumNullclines(allfiles);






% plot guide lines
plot(ax(4),[1/100 10],[1 1],'k')
plot(ax(4),[1 1],[1/100 10],'k')
plot(ax(4),[1/100 10],[1/100 10],'k:')



for i = 1:length(alldata)
	plot(ax(4),alldata(i).x,alldata(i).y,'Color',[0 0 0 .05])
end
set(ax(4),'XScale','log','YScale','log','XLim',[1/100 10],'YLim',[1/100 10])
xlabel(ax(4),'$\Sigma \bar{g}_{Ca}$ (fold change)','interpreter','latex')
ylabel(ax(4),'$\Sigma \bar{g} - \Sigma \bar{g}_{Ca}$  (fold change)','interpreter','latex')



% make a bursting neuron
x = singleCompartment.makeNeuron();
singleCompartment.disableControllers(x)
x.set('*gbar',[379 165 2.35 .72 297 1713 .46 1370])
model_hash = hashlib.md5hash(x.get('*gbar'));

gbar_x = [1 3 5];
gbar_y = [2 4 6 8];

% measure the calcium level set 
% segment space
status = singleCompartment.perturb.findCalciumNullcline(x, gbar_x, gbar_y);
x.set('*gbar',[379 165 2.35 .72 297 1713 .46 1370])
gbar = x.get('*gbar');
save_name = hashlib.md5hash([gbar(:); gbar_x(:); gbar_y(:)]);
load(fullfile(data_loc,[save_name '_calcium.voronoi']),'-mat','v')

X = v.boundaries(1).regions.x;
Y = v.boundaries(1).regions.y;

rm_this = X == max(X) | X == min(X) | Y == max(Y);
X(rm_this) = [];
Y(rm_this) = [];



% segment space
status = singleCompartment.perturb.analyzeWithControl(x, gbar_x, gbar_y);
x.set('*gbar',[379 165 2.35 .72 297 1713 .46 1370])
gbar = x.get('*gbar');
save_name = hashlib.md5hash([x.hash hashlib.md5hash([gbar_x(:); gbar_y(:)])]);
load(fullfile(data_loc,[save_name '_1.voronoi']),'-mat','v')
v.plotBoundaries(ax(1))
axlib.resolveOverlappingPolyShapes(ax(1))




c = lines(10);

p = ax(1).Children;

for i = 1:length(p)
	p(i).FaceAlpha = .35;
	if i == 3
		p(i).FaceColor = c(5,:);
	end
end

plot(ax(1),X,Y,'r','LineWidth',2)

plot(ax(1),v.x_range,v.y_range,'k:')
ax(1).XTick = [10 100 1e3];
xlabel(ax(1),'$\bar{g}_{A} + \bar{g}_{CaT} + \bar{g}_{KCa} (\mu S/mm^2)$','interpreter','latex')

ylabel(ax(1),'$\bar{g}_{CaS} + \bar{g}_{H} + \bar{g}_{Kd} + \bar{g}_{NaV} (\mu S/mm^2)$','interpreter','latex')


x = singleCompartment.makeNeuron();
x.set('*gbar',v.data.g0)
x.reset
x.integrate;
singleCompartment.configureControllers(x);
x.t_end = 5e3;

% show some trajectories
% pick points at random in the nice region
N = 12;
all_x = corelib.logrange(v.x_range(1),v.x_range(2),N);
all_y = corelib.logrange(v.y_range(1),v.y_range(2),N);


this_color = 'k';

x.t_end = 1e3;

for i = 1:N

	plot_data = struct;
	plot_data.X = [];
	plot_data.Y = [];

	x.integrate;

	parfor j = 1:N

		g = singleCompartment.perturb.scaleG(v.data.g0,all_x(i),all_y(j),gbar_x,gbar_y);
		x.set('*gbar',g)
		x.set('*Controller.m',g*x.AB.A)
		x.set('AB.CaT.E',30);
		x.set('AB.CaS.E',30);
		x.reset;
		
		[~,~,C] = x.integrate;
		C(:,7) = [];
		g = C(:,2:2:end);
		X = sum(g(:,gbar_x),2); 
		Y = sum(g(:,gbar_y),2); 

		plot_data(j).X = X;
		plot_data(j).Y = Y;
	end

	for j = 1:N
		plotlib.trajectory(ax(1),plot_data(j).X,plot_data(j).Y,'Color',this_color,'ArrowLength',.015,'LineWidth',1,'NormX',false,'NormY',false,'NArrows',1);
		
	end
	drawnow

end












% another projection

% make a bursting neuron
x = singleCompartment.makeNeuron();
singleCompartment.disableControllers(x)
x.set('*gbar',[379 165 2.35 .72 297 1713 .46 1370])

gbar_x = [1 5 6];
gbar_y = [2 3 4 8];

% measure the calcium level set 
% segment space
status = singleCompartment.perturb.findCalciumNullcline(x, gbar_x, gbar_y);
x.set('*gbar',[379 165 2.35 .72 297 1713 .46 1370])
gbar = x.get('*gbar');
save_name = hashlib.md5hash([gbar(:); gbar_x(:); gbar_y(:)]);
load(fullfile(data_loc,[save_name '_calcium.voronoi']),'-mat','v')


X = v.boundaries(1).regions.x;
Y = v.boundaries(1).regions.y;

rm_this = Y == max(Y);
X(rm_this) = [];
Y(rm_this) = [];



% segment space
status = singleCompartment.perturb.analyzeWithControl(x, gbar_x, gbar_y);
x.set('*gbar',[379 165 2.35 .72 297 1713 .46 1370])
gbar = x.get('*gbar');
save_name = hashlib.md5hash([x.hash hashlib.md5hash([gbar_x(:); gbar_y(:)])]);
load(fullfile(data_loc,[save_name '_1.voronoi']),'-mat','v')
v.plotBoundaries(ax(2))
axlib.resolveOverlappingPolyShapes(ax(2))



c = lines(10);

p = ax(2).Children;

for i = 1:length(p)
	p(i).FaceAlpha = .35;
	if i == 11
		p(i).FaceColor = c(5,:);
	end
end


plot(ax(2),X,Y,'r.')
plot(ax(2),v.x_range,v.y_range,'k:')


xlabel(ax(2),'$\bar{g}_{A} + \bar{g}_{Kca} + \bar{g}_{Kd} (\mu S/mm^2)$','interpreter','latex')

ylabel(ax(2),'$\bar{g}_{CaS} + \bar{g}_{CaT} + \bar{g}_{H} + \bar{g}_{NaV} (\mu S/mm^2)$','interpreter','latex')


x = singleCompartment.makeNeuron();
x.set('*gbar',v.data.g0)
x.reset
x.integrate;
singleCompartment.configureControllers(x);
x.t_end = 5e3;

% show some trajectories
% pick points at random in the nice region
N = 12;
all_x = corelib.logrange(v.x_range(1),v.x_range(2),N);
all_y = corelib.logrange(v.y_range(1),v.y_range(2),N);

this_color = 'k';

x.t_end = 1e3;

for i = 1:N

	plot_data = struct;
	plot_data.X = [];
	plot_data.Y = [];

	parfor j = 1:N

		g = singleCompartment.perturb.scaleG(v.data.g0,all_x(i),all_y(j),gbar_x,gbar_y);
		x.set('*gbar',g)
		x.set('*Controller.m',g*x.AB.A)
		x.set('AB.CaT.E',30);
		x.set('AB.CaS.E',30);
		x.reset;
		
		[~,~,C] = x.integrate;
		C(:,7) = [];
		g = C(:,2:2:end);
		X = sum(g(:,gbar_x),2); 
		Y = sum(g(:,gbar_y),2); 

		plot_data(j).X = X;
		plot_data(j).Y = Y;
	end

	for j = 1:N
		plotlib.trajectory(ax(2),plot_data(j).X,plot_data(j).Y,'Color',this_color,'ArrowLength',.015,'LineWidth',1,'NormX',false,'NormY',false,'NArrows',1);
		
	end
	drawnow

end

























figlib.pretty('PlotLineWidth',1,'LineWidth',1,'FontSize',15)



axlib.label(ax(1),'a','XOffset',-.05,'YOffset',0,'FontSize',24);
axlib.label(ax(2),'b','XOffset',-.05,'YOffset',0,'FontSize',24);
axlib.label(ax(3),'c','XOffset',-.05,'YOffset',0,'FontSize',24);
axlib.label(ax(4),'d','XOffset',-.05,'YOffset',0,'FontSize',24);

ax(3).YLim = [600 1500];










































% show CVs of metrics and parameters in a supplement
g0 = [alldata.g0];


figure('outerposition',[300 300 901 901],'PaperUnits','points','PaperSize',[901 901]); hold on

ax = figlib.gridAxes(8);

channels = {'A','CaS','CaT','H','KCa','Kd','L','NaV'};

for i = 1:7
	for j = i+1:8
		plot(ax(i,j),g0(i,:),g0(j,:),'k.')
		if i > 1
			set(ax(i,j),'YTickLabel',{})
		else
			ylabel(ax(i,j),['$\bar{g}_{' channels{j} '}$'],'interpreter','latex')
		end
		if j < 8
			set(ax(i,j),'XTickLabel',{})
		else
			xlabel(ax(i,j),['$\bar{g}_{' channels{i} '}$'],'interpreter','latex')
		end
		ax(i,j).XLim(1) = 0;
		axis(ax(i,j),'square')
	end
	
end




clear S
axs = subplot(2,2,2); hold on
S(1) = barh(axs,1,statlib.cv([alldata.nspikes]),'FaceColor','r','EdgeColor','r');
S(2) = barh(axs,2,statlib.cv([alldata.burst_period]),'FaceColor','r','EdgeColor','r');
S(3) = barh(axs,3,statlib.cv([alldata.duty_cycle]),'FaceColor','r','EdgeColor','r');


S(4) = barh(axs,4,statlib.cv(g0(3,:)),'FaceColor','k','EdgeColor','k');
S(5) = barh(axs,5,statlib.cv(g0(4,:)),'FaceColor','k','EdgeColor','k');
S(6) = barh(axs,6,statlib.cv(g0(5,:)),'FaceColor','k','EdgeColor','k');

S(7) = barh(axs,7,statlib.cv(g0(8,:)./g0(6,:)),'FaceColor','k','EdgeColor','k');
S(8) = barh(axs,8,statlib.cv(g0(8,:)./g0(5,:)),'FaceColor','k','EdgeColor','k');

axs.XScale = 'log';
axs.Position = [.675 .675 .25 .25];
axs.XLim = [.01 1];

xlabel(axs,'CV')
set(axs,'YTick',[1:8],'YTickLabel',{'#spikes','burst period','duty cycle','CaT','H','KCa','NaV/Kd','NaV/KCa'})

for i = 1:length(S)
	S(i).LineWidth = 1.5;
	S(i).BarWidth = .5;
end


figlib.pretty('PlotLineWidth',1,'LineWidth',1,'FontSize',15)