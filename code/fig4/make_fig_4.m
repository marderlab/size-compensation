

clear ax
addpath('../')
close all

figure('outerposition',[300 300 1800 600],'PaperUnits','points','PaperSize',[1800 600]); hold on
for i = 3:-1:1
	ax(i) = subplot(1,3,i); hold on
	axis(ax(i),'square')
end

figlib.pretty('plw',1,'lw',1,'fs',16)

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
load([save_name '_calcium.voronoi'],'-mat','v')

X = v.boundaries(1).regions.x;
Y = v.boundaries(1).regions.y;

rm_this = X == max(X) | X == min(X) | Y == max(Y);
X(rm_this) = [];
Y(rm_this) = [];




% segment space
status = singleCompartment.perturb.analyzeWithControl(x, gbar_x, gbar_y);
x.set('*gbar',[379 165 2.35 .72 297 1713 .46 1370])
gbar = x.get('*gbar');
save_name = hashlib.md5hash([gbar(:); gbar_x(:); gbar_y(:)]);
load([save_name '_1.voronoi'],'-mat','v')
v.plotBoundaries(ax(1))
axlib.resolveOverlappingPolyShapes(ax(1))




c = lines(10);

p = ax(1).Children;

for i = 1:length(p)
	p(i).FaceAlpha = .35;
	if i == 4
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
N = 15;
all_x = corelib.logrange(v.x_range(1),v.x_range(2),N);
all_y = corelib.logrange(v.y_range(1),v.y_range(2),N);


for i = 1:N
	for j = 1:N

		this_color = 'k';

		g = singleCompartment.perturb.scaleG(v.data.g0,all_x(i),all_y(j),gbar_x,gbar_y);
		x.set('*gbar',g)
		x.set('*Controller.m',g*x.AB.A)
		x.AB.CaT.E = 30;
		x.AB.CaS.E = 30;
		x.reset;
		x.t_end = 1e3;
		[~,~,C] = x.integrate;
		C(:,7) = [];
		g = C(:,2:2:end);
		X = sum(g(:,gbar_x),2); 
		Y = sum(g(:,gbar_y),2); 

		plotlib.trajectory(ax(1),X,Y,'Color',this_color,'ArrowLength',.015,'LineWidth',1,'norm_x',false,'norm_y',false,'n_arrows',1);
		drawnow

	end
end





















% another projection

% make a bursting neuron
x = singleCompartment.makeNeuron();
singleCompartment.disableControllers(x)
x.set('*gbar',[379 165 2.35 .72 297 1713 .46 1370])
model_hash = hashlib.md5hash(x.get('*gbar'));

gbar_x = [1 5 6];
gbar_y = [2 3 4 8];

% measure the calcium level set 
% segment space
status = singleCompartment.perturb.findCalciumNullcline(x, gbar_x, gbar_y);
x.set('*gbar',[379 165 2.35 .72 297 1713 .46 1370])
gbar = x.get('*gbar');
save_name = hashlib.md5hash([gbar(:); gbar_x(:); gbar_y(:)]);
load([save_name '_calcium.voronoi'],'-mat','v')


X = v.boundaries(1).regions.x;
Y = v.boundaries(1).regions.y;

rm_this = Y == max(Y);
X(rm_this) = [];
Y(rm_this) = [];



% segment space
status = singleCompartment.perturb.analyzeWithControl(x, gbar_x, gbar_y);
x.set('*gbar',[379 165 2.35 .72 297 1713 .46 1370])
gbar = x.get('*gbar');
save_name = hashlib.md5hash([gbar(:); gbar_x(:); gbar_y(:)]);
load([save_name '_1.voronoi'],'-mat','v')
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
N = 15;
all_x = corelib.logrange(v.x_range(1),v.x_range(2),N);
all_y = corelib.logrange(v.y_range(1),v.y_range(2),N);


for i = 1:N
	for j = 1:N

		this_color = 'k';

		g = singleCompartment.perturb.scaleG(v.data.g0,all_x(i),all_y(j),gbar_x,gbar_y);
		x.set('*gbar',g)
		x.set('*Controller.m',g*x.AB.A)
		x.AB.CaT.E = 30;
		x.AB.CaS.E = 30;
		x.reset;
		x.t_end = 1e3;
		[~,~,C] = x.integrate;
		C(:,7) = [];
		g = C(:,2:2:end);
		X = sum(g(:,gbar_x),2); 
		Y = sum(g(:,gbar_y),2); 

		plotlib.trajectory(ax(2),X,Y,'Color',this_color,'ArrowLength',.015,'LineWidth',1,'norm_x',false,'norm_y',false,'n_arrows',1);
		drawnow

	end
end

figlib.tight()

figlib.label('x_offset',-.01,'y_offset',-.06,'font_size',30)
