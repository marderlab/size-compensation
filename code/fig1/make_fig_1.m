
addpath('../')

close all

x = xolotl;
x.add('compartment','AB','A',0.0628,'vol',.0628);
x.AB.add('bucholtz/CalciumMech','phi',1,'tau_Ca',500);

x.AB.add('prinz/NaV','gbar',620);
x.AB.add('prinz/CaS','gbar',16);
x.AB.add('prinz/Kd','gbar',567);
x.AB.add('Leak','gbar',.1,'E',-30);

x.snapshot('base');

clear data
data.x = x;

data.g0_NaV = x.AB.NaV.gbar*x.AB.A;
data.g0_CaS = x.AB.CaS.gbar*x.AB.A;
data.g0_Kd = x.AB.Kd.gbar*x.AB.A;
data.g0_HH = data.g0_NaV + data.g0_Kd + data.g0_CaS;
data.A0 = x.AB.A;
x.integrate;
x.integrate;
data.Ca_average = x.AB.Ca_average;

x_range = [data.A0/100 data.A0*10];
y_range = [data.g0_HH/100 data.g0_HH*10];



figure('outerposition',[300 300 700 900],'PaperUnits','points','PaperSize',[700 900]); hold on
clear ax
for i = 6:-1:1
	ax(i) = subplot(3,2,i); hold on
end

figlib.pretty('plw',1,'lw',1,'fs',12)

% show spiking and silent cell
x.AB.A = data.A0/10;
x.AB.vol =  data.A0/10;
x.AB.NaV.gbar = (data.g0_NaV/x.AB.A)/10;
x.AB.Kd.gbar = (data.g0_Kd/x.AB.A)/10;
x.AB.CaS.gbar = (data.g0_CaS/x.AB.A)/10;

x.integrate;
V = x.integrate;
time = (1:length(V))*x.dt*1e-3;
plot(ax(1),time,V,'k')
set(ax(1),'XLim',[0 .3],'YLim',[-80 50])
axlib.makeEphys(ax(1),'time_scale',.1,'voltage_scale',30)

% now show the cell when it is much bigger
x.AB.A = data.A0*2;
x.AB.vol =  data.A0*2;
x.AB.NaV.gbar = (data.g0_NaV/x.AB.A)/10;
x.AB.Kd.gbar = (data.g0_Kd/x.AB.A)/10;
x.AB.CaS.gbar = (data.g0_CaS/x.AB.A)/10;


x.integrate;
V = x.integrate;
time = (1:length(V))*x.dt*1e-3;
plot(ax(2),time,V,'k')
set(ax(2),'XLim',[0 .3],'YLim',[-80 50])
axlib.makeEphys(ax(2),'time_scale',.1,'voltage_scale',30)

ax(1).Position(4) = .075;
ax(2).Position(4) = .075;




% measure calcium and firing rate everywhere in a grid

if exist('Ca_grid.mat','file')
	load('Ca_grid.mat','A','g','Ca','firing_rate')
else

	gridsize = 100;

	Ca = NaN(gridsize);

	g_scale = logspace(-2,1,gridsize);
	A_scale = logspace(-2,1,gridsize);

	% make matrices
	all_g_NaV = NaN(gridsize);
	all_g_Kd = NaN(gridsize);
	all_g_CaS = NaN(gridsize);
	all_A = NaN(gridsize);


	for i = 1:gridsize
		for j = 1:gridsize
			all_A(i,j) = A_scale(i)*data.A0;

			all_g_NaV(i,j) = g_scale(j)*data.g0_NaV;
			all_g_CaS(i,j) = g_scale(j)*data.g0_CaS;
			all_g_Kd(i,j) = g_scale(j)*data.g0_Kd;

		end
	end

	% convert to gbar
	all_gbar_NaV = all_g_NaV./all_A;
	all_gbar_CaS = all_g_CaS./all_A;
	all_gbar_Kd = all_g_Kd./all_A;


	p = xgrid;
	p.cleanup;
	p.x = x;
	p.sim_func = @measureCalcium;
	parameters_to_vary = {'AB.A','AB.NaV.gbar','AB.CaS.gbar','AB.Kd.gbar'};
	p.batchify([all_A(:) all_gbar_NaV(:) all_gbar_CaS(:) all_gbar_Kd(:)]',parameters_to_vary);

	p.simulate;
	p.wait()


	[sim_data,metadata] = p.gather;
	Ca = sim_data{1};
	firing_rate = sim_data{2};
	A = sim_data{3};
	g = sim_data{4};
	g = sum(g([1:2 4],:));

	save('Ca_grid.mat','A','g','Ca','firing_rate')

end


scatter(ax(3),A,g,63,firing_rate,'filled','Marker','s')
set(ax(3),'YScale','log','XScale','log')
ch = colorbar(ax(3));


axes(ax(3))
c = parula;
c = brighten(c,.5);
c(1,:) = 1;
colormap(c)
caxis([30 50])
plot(ax(3),x_range,y_range,'k:')
axis(ax(3),'square')


set(ch,'YTick',30:5:50,'YTickLabel',{'Silent','35','40','45','50'})
title(ch,'Firing rate (Hz)')

xlabel(ax(3),'Area (mm^2)')
ylabel(ax(3),'\Sigma g (uS)')




% if exist('fig1.voronoi','file')
% 	load('fig1.voronoi','-mat')


% else


% 	v = voronoiSegment;
% 	v.data = data;

% 	v.n_seed = 4;
% 	v.sim_func = @measureFiringRate;
% 	v.y_range = y_range;
% 	v.x_range = x_range;
% 	v.n_classes = 4;
% 	v.make_plot = true;
% 	v.labels = {'Silent','<35Hz','35-45Hz','>45Hz'};
% 	v.max_fun_eval = 300;

% 	v.find(corelib.logrange(x_range,30),corelib.logrange(y_range,30))
% 	v.findBoundaries()
% 	pause(3)
% 	delete(v.handles.fig)

% 	save('fig1.voronoi','v')


% end


% v.plotBoundaries(ax(3))
% axis(ax(3),'square')
% xlabel(ax(3),'Area (mm^2)')
% ylabel(ax(3),'\Sigma g (uS)')


ax(3).XLim = x_range; 
ax(3).YLim = y_range;
ax(3).XTick = [1e-3 1e-2 1e-1];


% draw an arrow on it
xx = linspace(data.A0/10,data.A0*2,1e3);
yy = (data.g0_HH/10)*(1+0*xx);
plotlib.trajectory(ax(3),xx,yy,'n_arrows',3,'ArrowLength',.03,'norm_y',false,'norm_x',false,'LineWidth',1.5);



for show_here = 5:6
	scatter(ax(show_here),A,g,63,log2(Ca./data.Ca_average),'filled','Marker','s')
	set(ax(show_here),'YScale','log','XScale','log')
	ch = colorbar(ax(show_here));
	colormap(ax(show_here),colormaps.redblue);
	caxis(ax(show_here),[-6 6])
	plot(ax(show_here),x_range,y_range,'k:');
	axis(ax(show_here),'square');

	set(ch,'YTick',[-6:3:6],'YTickLabel',{'1/64','1/8', 'Target','8X','64X'});
	title(ch,'<[Ca^{2+}]>')

	xlabel(ax(show_here),'Area (mm^2)')
	ylabel(ax(show_here),'\Sigma g (uS)')


end
delete(ch)


I = imread('integral-control.png');
figlib.showImageInAxes(ax(4),I)


% add a new axes showing the first plot
ax_cartoon = axes;
I = imread('cartoon.png');
figlib.showImageInAxes(ax_cartoon,I);

ax_cartoon.Position = [.2 .56 .62 .652];

ax(1).Position(3) = .2;
ax(2).Position(3) = .2;
ax(2).Position(1) = .66;


% show that the diagonal is globally attractive 
% it is, and we have verified that trajectories end on the diagonal
% to illustrate this, draw lines from random points that end up on the diagonal

ff = fit(x_range(:),y_range(:),'poly1');
% pick random points in the space
xx = logspace(-2.7,log10(.5),10);
yy = 0*xx;
yy(2:2:end) = 2;
yy(1:2:end) = 500;

n_arrows = [3 1 2 1 2 2 1 2 1 3];


for i = 1:10
	this_x = ones(1e3,1)*xx(i); % no motion in x
	this_y = corelib.logrange(yy(i),ff(xx(i)),1e3);
	plotlib.trajectory(ax(5),this_x,this_y,'ArrowLength',.03,'n_arrows',n_arrows(i),'norm_y',false,'norm_x',false);
end


% configure integral controllers
x.reset('base')
x.AB.NaV.add('oleary/IntegralController')
x.AB.Kd.add('oleary/IntegralController')
x.AB.CaS.add('oleary/IntegralController')
x.AB.Leak.add('oleary/IntegralController')
x.AB.add('LinearGrowth','rate',0);

singleCompartment.configureControllers(x);


% start is and grow it (make cell bigger)
x.AB.A = data.A0/10;
x.AB.vol =  data.A0/10;
x.AB.NaV.gbar = (data.g0_NaV/x.AB.A)/10;
x.AB.Kd.gbar = (data.g0_Kd/x.AB.A)/10;
x.AB.CaS.gbar = (data.g0_CaS/x.AB.A)/10;

x.t_end = 1e6;
x.dt = 1;
x.AB.LinearGrowth.rate = 2e-7;
x.output_type = 1;
results = x.integrate;

g = results.AB.NaV.IntegralController(:,2) + results.AB.Kd.IntegralController(:,2) + results.AB.CaS.IntegralController(:,2);
g = g.*results.AB.LinearGrowth;


[lh, arrows] = plotlib.trajectory(ax(6),results.AB.LinearGrowth,g,'n_arrows',4);



% now configure an exponential growth term
x.AB.LinearGrowth.destroy;
x.AB.add('ExpGrowth','rate',0);

x.AB.A = data.A0/10;
x.AB.vol =  data.A0/10;
x.AB.NaV.gbar = (data.g0_NaV/x.AB.A)/10;
x.AB.Kd.gbar = (data.g0_Kd/x.AB.A)/10;
x.AB.CaS.gbar = (data.g0_CaS/x.AB.A)/10;

singleCompartment.configureControllers(x);

x.t_end = 1e6;
x.dt = 1;
x.AB.ExpGrowth.rate = 3e-6;
x.output_type = 1;
results = x.integrate;

g = results.AB.NaV.IntegralController(:,2) + results.AB.Kd.IntegralController(:,2) + results.AB.CaS.IntegralController(:,2);
g = g.*results.AB.ExpGrowth;

[lh, arrows] = plotlib.trajectory(ax(6),results.AB.ExpGrowth,g,'n_arrows',3,'LineWidth',2);
