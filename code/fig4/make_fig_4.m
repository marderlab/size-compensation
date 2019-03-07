

clear ax
addpath('../')
close all

figure('outerposition',[300 300 1000 600],'PaperUnits','points','PaperSize',[1000 600]); hold on
for i = 4:-1:1
	ax(i) = subplot(2,2,i); hold on
	axis(ax(i),'square')
end

figlib.pretty('plw',1,'lw',1,'fs',12)

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