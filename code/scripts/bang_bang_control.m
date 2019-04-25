
g0 = [379 165 2.35 .72 297 1713 .46 1370];

% control -- integral controller
x = singleCompartment.makeNeuron('controller_type','IntegralController');
x.set('*gbar',g0)
x.reset
x.integrate;
singleCompartment.configureControllers(x,10e3);
x.t_end = 5e3;


% segment space
gbar_x = [2 3];
gbar_y = [1 4 5 6 8];
status = singleCompartment.perturb.analyzeWithControl(x, gbar_x, gbar_y);







x = singleCompartment.makeNeuron('controller_type','BangBangController');
x.set('*gbar',g0)
x.reset
x.integrate;
singleCompartment.configureControllers(x,10e3);
x.t_end = 5e3;


% segment space
gbar_x = [2 3];
gbar_y = [1 4 5 6 8];
status = singleCompartment.perturb.analyzeWithControl(x, gbar_x, gbar_y);


save_name = hashlib.md5hash([x.hash hashlib.md5hash([gbar_x(:); gbar_y(:)])]);

load([save_name '_1.voronoi'],'-mat')


% show different models that are "nice" as in recover to original behaviour
all_g = v.results.gbar;
nice_g = v.results.gbar(v.R == 3,:);

for i = 1:length(nice_g)
	corelib.textbar(i,length(nice_g))
	x.reset;
	singleCompartment.disableControllers(x);
	x.set('*gbar',nice_g(i,:))
	data(i) = porcupine(x);
end


figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600])
polarplot(NaN,NaN)
hold on
c = lines;
for i = 1:length(data)
	for j = 1:8
		polarplot(data(i).theta(j),log10(data(i).radius(j)),'LineStyle','none','Marker','o','Color',c(j,:))
	end
end













% proportional controller
x = singleCompartment.makeNeuron('controller_type','ProportionalController');
x.set('*gbar',g0)
x.reset
x.integrate;
singleCompartment.configureControllers(x,10e3);
x.t_end = 5e3;


% segment space
gbar_x = [2 3];
gbar_y = [1 4 5 6 8];
status = singleCompartment.perturb.analyzeWithControl(x, gbar_x, gbar_y);
