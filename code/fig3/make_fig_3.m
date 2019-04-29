

close all
addpath('../')

model_hash = '0dea7e804b9255ac7bba7df3c3b015ff';


% show model without regulation 


load([model_hash '_0.voronoi'],'-mat')

x0 = sum(v.data.g0(2:3));
y0 = sum(v.data.g0([1 4 5 6 8]));

fig_handle= figure('outerposition',[300 300 902 1200],'PaperUnits','points','PaperSize',[902 1200]); hold on
ax.noreg = subplot(3,2,3); hold on
ax.flow = subplot(3,2,4); hold on
ax.diff = subplot(3,2,5); hold on
ax.general = subplot(3,2,6); hold on

v.plotBoundaries(ax.noreg)
p = ax.noreg.Children;
uistack(p(2),'top')
c = lines(10);


for i = 1:length(p)
	if i == 2
		p(i).FaceAlpha = .35;
		p(i).FaceColor = c(5,:);
	else
		p(i).FaceAlpha = .35;
	end
end

% subtract the nice polygon from the not nice one
new_shape = subtract(p(1).Shape,p(2).Shape);
p(1).Shape = new_shape;


x = singleCompartment.makeNeuron();
singleCompartment.disableControllers(x)
x.t_end = 5e3;

v0 = v;

% plot equi-calcium line

load([ model_hash '_calcium.voronoi'],'-mat')

X = v.boundaries(1).regions.x;
Y = v.boundaries(1).regions.y;
X(mathlib.aeq(X,x0*10)) = NaN;
plot(ax.noreg,X,Y,'r','LineWidth',2)
plot(ax.flow,X,Y,'r','LineWidth',2)

set(ax.noreg,'XScale','log','YScale','log','XLim',v.x_range,'YLim',v.y_range)


% plot the integral control solutioon

load([model_hash '_1.voronoi'],'-mat')

v.plotBoundaries(ax.flow)
set(ax.flow,'XScale','log','YScale','log')


p = ax.flow.Children;
for i = 1:length(p)
	if i == 5
		p(i).FaceColor = c(5,:);
	end
end




x = singleCompartment.makeNeuron();
x.set('*gbar',v.data.g0)
x.reset
x.integrate;
singleCompartment.configureControllers(x);
x.t_end = 5e3;





plot(ax.noreg,[v.x_range(1) v.x_range(2)], [v.y_range(1) v.y_range(2)],'k--');
plot(ax.flow,[v.x_range(1) v.x_range(2)], [v.y_range(1) v.y_range(2)],'k--');
plot(ax.diff,[v.x_range(1) v.x_range(2)], [v.y_range(1) v.y_range(2)],'k--');


% now subtract one map from the other
R0 = v0.findBoundaries;
R = v.findBoundaries;

v_diff = voronoiSegment;
v_diff.x_range = v.x_range;
v_diff.y_range = v.y_range;

v_diff.n_classes = 4;


RD = NaN*R;
RD(R0 ~= 3 & R == 3) = 1; % sensitive to perturb, comp. restores function
RD(R0 ~= 3 & R ~= 3) = 2; % sensitive to perturb, comp. pathalogical
RD(R0 == 3 & R ~= 3) = 3; % robust to perturb, comp. pathalogical
RD(R0 == 3 & R == 3) = 4; % robust to perturb, comp. restores function

v_diff.traceBoundaries(RD);

c = parula(5);
% c(1,:) = [0    0.6706    0];
c(2,:) = [255 174 0]/255;
c(3,:) = [0.9569    0 0 ];
c(4,:) = [0    0.4980   0];
v_diff.plotBoundaries(ax.diff,c,.8);




% show some trajectories
% pick points at random in the nice region
N = 15;

all_x = corelib.logrange(v.x_range(1),v.x_range(2),N);
all_y = corelib.logrange(v.y_range(1),v.y_range(2),N);

xx = v.boundaries(3).regions.x;
yy = v.boundaries(3).regions.y;


for i = 1:N
	for j = 1:N

		% which region is this point in? 
		this_color = [];
		for idx = 1:length(p)
			if ~isa(p(idx),'matlab.graphics.primitive.Polygon')
				continue
			end
			xx = p(idx).Shape.Vertices(:,1);
			yy = p(idx).Shape.Vertices(:,2);

			if inpolygon(all_x(i),all_y(j),xx,yy)
				this_color = p(idx).FaceColor;
				break
			end

		end

		if isempty(this_color)
			continue
		end

		this_color = 'k';

		g = singleCompartment.perturb.scaleG(v.data.g0,all_x(i),all_y(j));
		x.set('*gbar',g)
		x.set('*Controller.m',g*x.AB.A)
		x.AB.CaT.E = 30;
		x.AB.CaS.E = 30;
		x.reset;
		x.t_end = 1e3;
		[~,~,C] = x.integrate;
		C(:,7) = [];
		g = C(:,2:2:end);
		X = sum(g(:,[2:3]),2); 
		Y = sum(g(:,[1 4 5 6 8]),2); 

		plotlib.trajectory(ax.flow,X,Y,'Color',this_color,'ArrowLength',.015,'LineWidth',1,'norm_x',false,'norm_y',false,'n_arrows',1);
		drawnow


	end
end


% plot final points
xx = sum(v.results.gbar(:,[2 3]),2);
yy = sum(v.results.gbar(:,[1 4 5 6 8]),2);
plot(ax.flow,xx,yy,'k+')



axis(ax.noreg,'square')
axis(ax.flow,'square')
axis(ax.diff,'square')



ax.flow.XTick = [10 100 1e3];
ax.noreg.XTick = [10 100 1e3];
ax.diff.XTick = [10 100 1e3];

ax.flow.XMinorTick = 'on';
ax.noreg.XMinorTick = 'on';
ax.diff.XMinorTick = 'on';

set(ax.flow,'XLim',[v.x_range(1),v.x_range(2)],'YLim',[v.y_range(1),v.y_range(2)])
set(ax.noreg,'XLim',[v.x_range(1),v.x_range(2)],'YLim',[v.y_range(1),v.y_range(2)])
set(ax.diff,'XLim',[v.x_range(1),v.x_range(2)],'YLim',[v.y_range(1),v.y_range(2)])


title(ax.noreg,'Without regulation')
title(ax.flow,'With regulation')






% now we look at generalized perturbations 

g0 = [379 165 2.35 .72 297 1713 .46 1370];

% control -- integral controller
x = singleCompartment.makeNeuron('controller_type','IntegralController');
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

if exist('generalized_perturbations.mat','file') == 2

	load('generalized_perturbations.mat','data','params')
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


	save('generalized_perturbations.mat','data','params')
end

metrics = data{1};
gbar = data{2};

Ca_error  = data{3};

% back calcualte mean and std of perturbation 
all_gbar = params./g0';
all_gbar(7,:) = [];
all_gbar = all_gbar - 1;

all_mu = mean(all_gbar);
all_sigma = std(all_gbar);



sh = scatter(ax.general,all_sigma,metrics(1,:),34,all_mu,'filled','Marker','o');
set(ax.general,'XScale','log')
ylabel('Burst period (ms)')
xlabel('\sigma_{perturbtion}')
lh = plotlib.horzline(ax.general,metrics0.burst_period);
lh.LineStyle = '-.';
lh.Color = 'k';
ch = colorbar;

colormap(ax.general,(colormaps.redblue))

sh.MarkerEdgeColor = [.5 .5 .5];

ax.general.YTick = 600:200:1400;

ax.general.XLim(2) = max(all_sigma);
ax.general.XTick = logspace(-4,-1,4);

title(ch,'\mu_{perturb}')
ch.YLim = [-.9 .9];

ch.Position = [.65 .28 .018 .14];



% show example traces to understand the behaviour segmentation 

singleCompartment.disableControllers(x);

for i = 1:4
	ax.example(i) = subplot(3,4,i); hold on
	set(ax.example(i),'XLim',[0 1],'YLim',[-80 50])
	ax.example(i).Position(4) = .1;
	if i > 1
		axis(ax.example(i),'off')
	end

end

% canonical
x.reset;
x.set('*gbar',g0);
x.t_end = 9.5e3;
x.integrate;
x.t_end = 2e3;
V = x.integrate;

time = (1:length(V))*x.dt*1e-3;
plot(ax.example(1),time,V,'k')


% silent
g = singleCompartment.perturb.scaleG(g0,10,100, [2 3], [1 4 5 6 8]);
x.reset;
x.set('*gbar',g);
x.t_end = 9.5e3;
x.integrate;
x.t_end = 2e3;
V = x.integrate;

time = (1:length(V))*x.dt*1e-3;
plot(ax.example(2),time,V,'k')


% other bursting
g = singleCompartment.perturb.scaleG(g0,1e3,1e4, [2 3], [1 4 5 6 8]);
x.reset;
x.set('*gbar',g);
x.t_end = 10e3;
x.integrate;
x.t_end = 2e3;
V = x.integrate;

time = (1:length(V))*x.dt*1e-3;
plot(ax.example(3),time,V,'k')


% one spike bursting
g = singleCompartment.perturb.scaleG(g0,1e2,1e2, [2 3], [1 4 5 6 8]);
x.reset;
x.set('*gbar',g);
x.t_end = 9.5e3;
x.integrate;
x.t_end = 2e3;
V = x.integrate;

time = (1:length(V))*x.dt*1e-3;
plot(ax.example(4),time,V,'k')


c= lines;
clear h
for i = 1:4
	h(i) = scatter(ax.example(i),.1,30,240,'MarkerEdgeAlpha',0,'MarkerFaceColor',c(5,:),'MarkerFaceAlpha',.35);
end

h(2).MarkerFaceColor = c(1,:);
h(3).MarkerFaceColor = c(4,:);
h(4).MarkerFaceColor = c(2,:);


xlabel(ax.noreg,'$\mathrm{\Sigma \bar{g}_{Ca} (\mu S/mm^2)}$','interpreter','latex')
ylabel(ax.noreg,'$\mathrm{\Sigma \bar{g}_{others} (\mu S/mm^2)}$','interpreter','latex')


xlabel(ax.diff,'$\mathrm{\Sigma \bar{g}_{Ca} (\mu S/mm^2)}$','interpreter','latex')
ylabel(ax.diff,'$\mathrm{\Sigma \bar{g}_{others} (\mu S/mm^2)}$','interpreter','latex')

xlabel(ax.flow,'$\mathrm{\Sigma \bar{g}_{Ca} (\mu S/mm^2)}$','interpreter','latex')
ylabel(ax.flow,'$\mathrm{\Sigma \bar{g}_{others} (\mu S/mm^2)}$','interpreter','latex')



figlib.pretty('plw',1,'lw',1,'fs',18)


figlib.label('y_offset',-.03,'font_size',26,'x_offset',-.02,'ignore_these',ax.example)


ax.general.YLim = [400 1600];

ylabel(ax.example(1),'V_m (mV)')
xlabel(ax.example(1),'Time (s)')

ch.Position = [.63 .23 .018 .075];