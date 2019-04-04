
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


figure('outerposition',[300 300 1403 901],'PaperUnits','points','PaperSize',[1403 901]); hold on

clear ax


% firing rate
ax = subplot(2,3,1); hold on
plot_this = (firing_rate(1,:));
scatter(ax,A,g,63,plot_this,'filled','Marker','s')
set(ax,'YScale','log','XScale','log')
ch = colorbar(ax);

[L,loc]=axlib.makeLogTickLabels((1e3*isis(1,:)));

axes(ax)
c = parula;
%c = brighten(c,.5);
colormap(c)
caxis([min(plot_this) max(plot_this)])


title(ch,'f (Hz)')
% ch.YTick = loc;
% ch.YTickLabel = L;



ax(2) = subplot(2,3,2); hold on
plot_this = log10(1e3*isis(1,:));
scatter(ax(2),A,g,63,plot_this,'filled','Marker','s')
set(ax(2),'YScale','log','XScale','log')
ch = colorbar(ax(2));

[L,loc]=axlib.makeLogTickLabels((1e3*isis(1,:)));

axes(ax(2))
c = parula;
%c = brighten(c,.5);
colormap(c)
caxis([min(plot_this) max(plot_this)])


title(ch,'ISI (ms)')
ch.YTick = loc;
ch.YTickLabel = L;





ax(3) = subplot(2,3,3); hold on
plot_this = log10(1e3*isis(2,:));
scatter(ax(3),A,g,63,plot_this,'filled','Marker','s')
ch = colorbar(ax(3));


[L,loc]=axlib.makeLogTickLabels((1e3*isis(2,:)));

ch.YTick = loc;
ch.YTickLabel = L;

axes(ax(3))
c = parula;
colormap(ax(3),c)
caxis([min(plot_this) max(plot_this)])

title(ch,'\sigma_{ISI} (ms)')









ax(4) = subplot(2,3,4); hold on
plot_this = log2(Ca(1,:)/Ca0(1));
plot_this(plot_this<-2) = -2;
plot_this(plot_this>2) = 2;
scatter(ax(4),A,g,63,plot_this,'filled','Marker','s')
ch = colorbar(ax(4));

axes(ax(4))
c = colormaps.redblue;
c = brighten(c,.2);
colormap(ax(4),c)
caxis([-3 3])

title(ch,'<[Ca^{2+}]> ')




ax(5) = subplot(2,3,5); hold on
% find lines corresponding to various things and plot those

clear l

% plot Calcium line
A_space = unique(A);
ff = fit(x_range(:),y_range(:),'poly1');
Y = NaN*A_space;
for i = 1:length(A_space)
	candidates = Ca(1,(A==A_space(i)));
	candidates_Y = g(1,(A==A_space(i)));
	Y(i) = candidates_Y(corelib.closest(candidates,Ca0(1,:)));
end

l(1) = plot(ax(5),A_space,Y,'DisplayName','<[Ca^{2+}]> = Ca_{target}','LineWidth',2);


% plot firing rate line
Y = NaN*A_space;
for i = 1:length(A_space)
	candidates = firing_rate(1,(A==A_space(i)));
	candidates_Y = g(1,(A==A_space(i)));

	% % ignore some extranouse points
	% candidates(candidates_Y > 2*ff(A_space(i))) = Inf;
	Y(i) = candidates_Y(corelib.closest(candidates,firing_rate0(1,:)));
end
l(2) = plot(ax(5),A_space,Y,'DisplayName','f = f_{target}','LineWidth',2);

% plot line of equi-ISI variability
Y = NaN*A_space;
for i = 1:length(A_space)
	candidates = isis(2,(A==A_space(i)));
	candidates_Y = g(1,(A==A_space(i)));

	Y(i) = candidates_Y(corelib.closest(candidates,isis0(2,:)));
end
l(3) = plot(ax(5),A_space,Y,'DisplayName','\sigma_{ISI} = \sigma_{ISI}(target)','LineWidth',2);

lh = legend;

figlib.pretty('plw',1,'lw',1)


for i = 1:length(ax)
	ax(i).XLim = [x_range(1)*.8 x_range(2)*1.2];
	ax(i).YLim = [y_range(1)*.8 y_range(2)*1.2];
	xlabel(ax(i),'Area (mm^2)')
	ylabel(ax(i),'\Sigma g (uS)')
	plot(ax(i),x_range,y_range,'k:','DisplayName','constant channel density');
	axis(ax(i),'square')
	set(ax(i),'YScale','log','XScale','log');

end


lh.Location = 'eastoutside';

ax(5).Position(3:4) = ax(1).Position(3:4);