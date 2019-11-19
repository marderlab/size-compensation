

%%
% The point of this figure is to show that activity-dependent feedback regulation on the conductances is useful, in that you don't need to fine-tune the growth rate. In fact, it works for any growth rate. 


addpath('../')

clearvars
close all

x = xolotl;
x.add('compartment','AB','A',0.0628,'vol',.0628);
x.AB.add('buchholtz/CalciumMech','phi',1,'tau_Ca',500);

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



figure('outerposition',[300 300 1555 900],'PaperUnits','points','PaperSize',[1555 900]); hold on
clear ax
for i = 6:-1:1
	ax(i) = subplot(2,3,i); hold on
end

figlib.pretty('PlotLineWidth',1,'LineWidth',1,'FontSize',15)





% measure calcium and firing rate everywhere in a grid

if exist('Ca_grid.mat','file') == 2
	load('Ca_grid.mat','all_A','g','Ca','firing_rate')
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


	firing_rate = NaN(gridsize);
	Ca = NaN(gridsize);

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

	x.dt = .1;
	x.sim_dt = .1;
	x.t_end = 10e3;
	x.closed_loop = true;


	parfor i = 1:gridsize
		disp(i)
		for j = 1:gridsize
			% set params
			x.set('AB.A',all_A(i,j));
			x.set('AB.vol',all_A(i,j));
			x.set('AB.NaV.gbar',all_gbar_NaV(i,j));
			x.set('AB.Kd.gbar',all_gbar_Kd(i,j));
			x.set('AB.CaS.gbar',all_gbar_CaS(i,j));

			% simulate
			x.reset;
			x.integrate;
			V = x.integrate;


			firing_rate(i,j) = xtools.findNSpikes(V)/(x.t_end*1e-3);
			Ca(i,j) = x.AB.Ca_average;

		end
	end


	g = (all_g_CaS + all_g_NaV + all_g_Kd);
	save('Ca_grid.mat','all_A','g','Ca','firing_rate')

end

A = all_A(:);


show_here = [1 3 6];
for i = 1:length(show_here)
	scatter(ax(show_here(i)),A,g(:),63,firing_rate(:),'filled','Marker','s')
	set(ax(1),'YScale','log','XScale','log')

	if i == 1
		ch_f = colorbar(ax(1));
	end


	axes(ax(show_here(i)))
	c = parula;
	c = brighten(c,.5);
	c(1:3,:) = 1;
	colormap(ax(show_here(i)),c)
	caxis(ax(show_here(i)),[30 50])

end



set(ch_f,'YTick',30:5:50,'YTickLabel',{'Silent','35','40','45','50'})
title(ch_f,'f (Hz)')

for i = [1 3 4 6]
	xlabel(ax(i),'Area (mm^2)')
	ylabel(ax(i),'\Sigma g (\muS)')
end

% now show the calcium everywhere



scatter(ax(4),A,g(:),63,log2(Ca(:)./data.Ca_average),'filled','Marker','s')
set(ax(4),'YScale','log','XScale','log')
ch_Ca = colorbar(ax(4));
colormap(ax(4),colormaps.redblue);
caxis(ax(4),[-6 6])
plot(ax(4),x_range,y_range,'k:');
axis(ax(4),'square');

set(ch_Ca,'YTick',[-6:3:6],'YTickLabel',{'1/64','1/8', 'Target','8X','64X'});
title(ch_Ca,'<[Ca^{2+}]>')



growth_rates = [1e-7 5e-6 1e-6 5e-5];

% configure open loop controllers
xopen = copy(x);

xopen.AB.NaV.add('OpenLoopController')
xopen.AB.Kd.add('OpenLoopController')
xopen.AB.CaS.add('OpenLoopController')
xopen.AB.Leak.add('OpenLoopController')
xopen.AB.add('LinearGrowth','rate',0);

singleCompartment.configureControllers(xopen);


% start is and grow it (make cell bigger)
xopen.AB.A = data.A0/10;
xopen.AB.vol =  data.A0/10;
xopen.AB.NaV.gbar = (data.g0_NaV/xopen.AB.A)/10;
xopen.AB.Kd.gbar = (data.g0_Kd/xopen.AB.A)/10;
xopen.AB.CaS.gbar = (data.g0_CaS/xopen.AB.A)/10;

xopen.set('*area_max',data.A0*2);


xopen.set('*tau_g',10e3)

xopen.snapshot('small');

% indicate first point on all plots
for i = [1 3 4 6]
	ph = plot(ax(i),data.A0/10,sum(xopen.get('*gbar'))*xopen.AB.A,'ko');
	ph.MarkerFaceColor = 'k';
end



for i = 1:length(growth_rates)

	xopen.reset('small')

	xopen.t_end = 1e6;
	xopen.dt = 1;
	xopen.AB.LinearGrowth.rate = growth_rates(i);
	xopen.output_type = 1;
	results = xopen.integrate;

	g = results.AB.NaV.OpenLoopController(:,2) + results.AB.Kd.OpenLoopController(:,2) + results.AB.CaS.OpenLoopController(:,2);
	g = g.*results.AB.LinearGrowth;


	plot(ax(3),results.AB.LinearGrowth,g,'k')

	% indicate last point
	plot(ax(3),results.AB.LinearGrowth(end),g(end),'ko')



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

x.set('*area_max',data.A0*2);


x.set('*tau_g',20e3)

x.snapshot('small');



for i = 1:length(growth_rates)

	x.reset('small')

	x.t_end = 1e6;
	x.dt = 1;
	x.AB.LinearGrowth.rate = growth_rates(i);
	x.output_type = 1;
	results = x.integrate;

	g = results.AB.NaV.IntegralController(:,2) + results.AB.Kd.IntegralController(:,2) + results.AB.CaS.IntegralController(:,2);
	g = g.*results.AB.LinearGrowth;


	plot(ax(6),results.AB.LinearGrowth,g,'k')

	% indicate last point
	plot(ax(6),results.AB.LinearGrowth(end),g(end),'ko')


end




for i = [1 3 4 6]
	ax(i).XLim = [x_range(1)*.8 x_range(2)*1.2];
	ax(i).YLim = [y_range(1)*.8 y_range(2)*1.2];
	ax(i).XTick = [1e-3 1e-2 1e-1];
	ax(i).XScale = 'log';
	ax(i).YScale = 'log';
	plot(ax(i),x_range,y_range,'k:')
	axis(ax(i),'square')
end







ch_f.Position = [.3 .6 .01 .1];
ch_Ca.Position = [.34 .12 .01 .1];



I = imread('open_loop.png');
figlib.showImageInAxes(ax(2),I)

I = imread('closed_loop.png');
figlib.showImageInAxes(ax(5),I)


figlib.label('x_offset',.01,'font_size',28)