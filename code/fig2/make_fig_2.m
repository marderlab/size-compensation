

close all
clearvars
addpath('../')

model_hash = '0dea7e804b9255ac7bba7df3c3b015ff';


% show model without regulation 


load([model_hash '_0.voronoi'],'-mat')

x0 = sum(v.data.g0(2:3));
y0 = sum(v.data.g0([1 4 5 6 8]));

fig_handle= figure('outerposition',[300 300 1201 812],'PaperUnits','points','PaperSize',[1201 812]); hold on
ax.noreg = subplot(2,3,4); hold on
ax.flow = subplot(2,3,5); hold on
ax.diff = subplot(2,3,6); hold on
ax.cartoon = subplot(2,2,1); hold on


I = imread('integral-control.png');
figlib.showImageInAxes(ax.cartoon,I)


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

x.t_end = 1e3;

this_color = 'k';

for i = 1:N

	plot_data = struct;
	plot_data.X = [];
	plot_data.Y = [];

	parfor j = 1:N

		g = singleCompartment.perturb.scaleG(v.data.g0,all_x(i),all_y(j));
		x.set('*gbar',g)
		x.set('*Controller.m',g*x.AB.A)
		x.set('AB.CaT.E',30);
		x.set('AB.CaS.E',30);
		x.reset;
		
		[~,~,C] = x.integrate;
		C(:,7) = [];
		g = C(:,2:2:end);
		X = sum(g(:,[2:3]),2); 
		Y = sum(g(:,[1 4 5 6 8]),2); 

		plot_data(j).X = X;
		plot_data(j).Y = Y;
	end

	for j = 1:N
		plotlib.trajectory(ax.flow,plot_data(j).X,plot_data(j).Y,'Color',this_color,'ArrowLength',.015,'LineWidth',1,'norm_x',false,'norm_y',false,'n_arrows',1);
		
	end
	drawnow

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






% show example traces to understand the behaviour segmentation 

ax.example(1) = subplot(4,4,3); hold on
ax.example(2) = subplot(4,4,4); hold on
ax.example(3) = subplot(4,4,7); hold on
ax.example(4) = subplot(4,4,8); hold on

singleCompartment.disableControllers(x);
idx = [1 4 7 10];
for i = 1:4
	set(ax.example(i),'XLim',[0 1],'YLim',[-85 50])
	ax.example(i).Position(4) = .1;
	if i < 3
		ax.example(i).XColor = 'w';
	else
		time_x = xlabel('Time (s)');
	end

	if i == 3
		ylabel_handle = ylabel(ax.example(i),'V_m (mV)');
	end


end

for i = [2:2:4]
	ax.example(i).YColor = 'w';
	ax.example(i).YTickLabel = {};
end

g0 = v.data.g0;

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
x.t_end = 10.3e3;
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
	h(i) = scatter(ax.example(i),.1,30,300,'MarkerEdgeAlpha',1,'MarkerFaceColor',c(5,:),'MarkerFaceAlpha',.35,'MarkerEdgeColor','k');
end

h(2).MarkerFaceColor = c(1,:);
h(3).MarkerFaceColor = c(4,:);
h(4).MarkerFaceColor = c(2,:);


xlabel(ax.noreg,'$\mathrm{\Sigma \bar{g}_{Ca} (\mu S/mm^2)}$','interpreter','latex')
ylabel(ax.noreg,'$\mathrm{\Sigma \bar{g} - \Sigma \bar{g}_{Ca} (\mu S/mm^2)}$','interpreter','latex')


xlabel(ax.diff,'$\mathrm{\Sigma \bar{g}_{Ca} (\mu S/mm^2)}$','interpreter','latex')
%ylabel(ax.diff,'$\mathrm{\Sigma \bar{g} - \Sigma \bar{g}_{Ca} (\mu S/mm^2)}$','interpreter','latex')

xlabel(ax.flow,'$\mathrm{\Sigma \bar{g}_{Ca} (\mu S/mm^2)}$','interpreter','latex')
%ylabel(ax.flow,'$\mathrm{\Sigma \bar{g}  - \Sigma \bar{g}_{Ca} (\mu S/mm^2)}$','interpreter','latex')



figlib.pretty('PlotLineWidth',1,'LineWidth',1,'FontSize',19)


axlib.label(ax.example(1),'b','y_offset',.03,'font_size',26,'x_offset',-.04);
axlib.label(ax.noreg,'c','y_offset',-.03,'font_size',26,'x_offset',-.02);
axlib.label(ax.flow,'d','y_offset',-.03,'font_size',26,'x_offset',-.02);
axlib.label(ax.diff,'e','y_offset',-.03,'font_size',26,'x_offset',-.02);
axlib.label(ax.cartoon,'a','y_offset',-.03,'font_size',26,'x_offset',-0);

ax.cartoon.Position = [.08 .55 .35 .35];

ax.example(4).Box = 'off';

for i = 3:4
	ax.example(i).Position(2) = .6;
end

time_x.Position(1) = -.2;
ylabel_handle.Position(2) = 110;



plot(ax.noreg,[v.x_range(1) v.x_range(2)], [v.y_range(1) v.y_range(2)],'k--');
plot(ax.flow,[v.x_range(1) v.x_range(2)], [v.y_range(1) v.y_range(2)],'k--');
plot(ax.diff,[v.x_range(1) v.x_range(2)], [v.y_range(1) v.y_range(2)],'w--');


th = text(5,150,'⟵ Size change ⟶ ','Rotation',45,'Parent',ax.noreg,'FontSize',14);