

close all
addpath('../')

model_hash = '0dea7e804b9255ac7bba7df3c3b015ff';


% show model without regulation 


load([model_hash '_0.voronoi'],'-mat')

x0 = sum(v.data.g0(2:3));
y0 = sum(v.data.g0([1 4 5 6 8]));

figure('outerposition',[300 300 1400 700],'PaperUnits','points','PaperSize',[1400 701]); hold on
ax.noreg = subplot(1,3,1); hold on
ax.flow = subplot(1,3,2); hold on
ax.diff = subplot(1,3,3); hold on


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


figlib.pretty('plw',1,'lw',1,'fs',18)


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

c = prism;
c(1:2,:) = [];
c(3,:) = [0 0 0];
c(4,:) = [0 0 1];
v_diff.plotBoundaries(ax.diff,c);




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


xlabel(ax.noreg,'$\Sigma \bar{g}_{Ca} (\mu S/mm^2)$','interpreter','latex')
ylabel(ax.noreg,'$\Sigma \bar{g}_{others} (\mu S/mm^2)$','interpreter','latex')


xlabel(ax.diff,'$\Sigma \bar{g}_{Ca} (\mu S/mm^2)$','interpreter','latex')
ylabel(ax.diff,'$\Sigma \bar{g}_{others} (\mu S/mm^2)$','interpreter','latex')

xlabel(ax.flow,'$\Sigma \bar{g}_{Ca} (\mu S/mm^2)$','interpreter','latex')
ylabel(ax.flow,'$\Sigma \bar{g}_{others} (\mu S/mm^2)$','interpreter','latex')

axis(ax.noreg,'square')
axis(ax.flow,'square')
axis(ax.diff,'square')


ax.diff.Position(2) = .25;
ax.flow.Position(2) = .25;
ax.noreg.Position(2) = .25;

ax.diff.XTick = ax.flow.XTick;

set(ax.flow,'XLim',[v.x_range(1),v.x_range(2)],'YLim',[v.y_range(1),v.y_range(2)])
set(ax.noreg,'XLim',[v.x_range(1),v.x_range(2)],'YLim',[v.y_range(1),v.y_range(2)])
set(ax.diff,'XLim',[v.x_range(1),v.x_range(2)],'YLim',[v.y_range(1),v.y_range(2)])


title(ax.noreg,'Without regulation')
title(ax.flow,'With regulation')

figlib.label('y_offset',-.13,'font_size',34,'x_offset',-.02)

% add a new axis for the text labels
ax.txt = axes;
ax.txt.Position = [ax.diff.Position(1)-.05 0 .3 .3];
clear th
th(1) = text(ax.txt,0,.2,'Sensitive to perturbation, compensation restores function','Color',[.8 .8 0]);
th(2) = text(ax.txt,0,.4,'Sensitive to perturbation, compensation pathalogical','Color',c(2,:));
th(3) = text(ax.txt,0,.6,'Robust to perturbation, compensation pathalogical','Color',c(3,:));
th(4) = text(ax.txt,0,.8,'Robust to perturbation, compensation restores function','Color',c(4,:));


for i = 1:4
	th(i).FontWeight = 'bold';
	th(i).FontSize = 17;
end
axis(ax.txt,'off')