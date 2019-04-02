
addpath('../')
x = xolotl;
x.add('compartment','AB','A',1,'vol',1);
x.AB.add('bucholtz/CalciumMech','phi',1,'tau_Ca',500);

x.AB.add('prinz/NaV','gbar',620);
x.AB.add('prinz/CaS','gbar',16);
x.AB.add('prinz/Kd','gbar',567);
x.AB.add('Leak','gbar',.1,'E',-30);

x.snapshot('base');

x.stochastic_channels = 1;



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

[Ca0, firing_rate0, ~, ~, isis0] = measureCalcium(x);

if exist('stochastic_hh.mat','file')
	load('stochastic_hh.mat','A','g','Ca','firing_rate','isis')
else

	gridsize = 100;

	g_scale = logspace(-3,1,gridsize);
	A_scale = logspace(-3,1,gridsize);

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
	isis = sim_data{5};

	save('stochastic_hh.mat','A','g','Ca','firing_rate','isis')

end


x_range = [min(A) max(A)];
y_range = [min(g) max(g)];


figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on
clear ax
ax = subplot(2,2,1); hold on
plot_this = log10(1e3*isis(1,:));
scatter(ax,A,g,63,plot_this,'filled','Marker','s')
set(ax,'YScale','log','XScale','log')
ch = colorbar(ax);

[L,loc]=axlib.makeLogTickLabels((1e3*isis(1,:)));

axes(ax)
c = parula;
%c = brighten(c,.5);
colormap(c)
caxis([min(plot_this) max(plot_this)])
plot(ax,x_range,y_range,'k:')
axis(ax,'square')


title(ch,'ISI (ms)')
ch.YTick = loc;
ch.YTickLabel = L;

xlabel(ax,'Area (mm^2)')
ylabel(ax,'\Sigma g (uS)')





ax(2) = subplot(2,2,2); hold on
plot_this = log10(1e3*isis(2,:));
scatter(ax(2),A,g,63,plot_this,'filled','Marker','s')
ch = colorbar(ax(2));


[L,loc]=axlib.makeLogTickLabels((1e3*isis(2,:)));

ch.YTick = loc;
ch.YTickLabel = L;

axes(ax(2))
c = parula;
colormap(ax(2),c)
caxis([min(plot_this) max(plot_this)])
plot(ax(2),x_range,y_range,'k:')

title(ch,'\sigma_{ISI} (ms)')









ax(3) = subplot(2,2,3); hold on
plot_this = (Ca(2,:)./Ca(1,:));
scatter(ax(3),A,g,63,plot_this,'filled','Marker','s')
ch = colorbar(ax(3));

ch_f = ch;

[L,loc]=axlib.makeLogTickLabels((1e3*Ca(2,:)));

axes(ax(3))
c = parula;
c = brighten(c,.5);
colormap(ax(3),c)
caxis([0 max(plot_this)])

title(ch,'CV_{Ca} ')




% measure deviation from mean ISI
D1 = ((isis(1,:)-isis0(1))./isis0(1)); D1(D1 < -.5) = -.5; D1(D1 > .5) = .5; 
D2 = ((isis(2,:)-isis0(2))./isis0(2)); D2(D2 < -.5) = -.5; D2(D2 > .5) = .5; 

ax(4) = subplot(2,2,4); hold on
plot_this = D1 + D2;
scatter(ax(4),A,g,63,plot_this,'filled','Marker','s')

ch = colorbar(ax(4));

ch_f = ch;

[L,loc]=axlib.makeLogTickLabels((1e3*Ca(2,:)));

axes(ax(4))
c = colormaps.redblue;
c = brighten(c,.2);
colormap(ax(4),c)
caxis([-1 1])




figlib.pretty('plw',1,'lw',1)


for i = 1:4
	ax(i).XLim = [x_range(1)*.8 x_range(2)*1.2];
	ax(i).YLim = [y_range(1)*.8 y_range(2)*1.2];
	xlabel(ax(i),'Area (mm^2)')
	ylabel(ax(i),'\Sigma g (uS)')
	plot(ax(i),x_range,y_range,'k:')
	axis(ax(i),'square')
	set(ax(i),'YScale','log','XScale','log')

end