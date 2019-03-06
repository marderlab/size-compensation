
close all
addpath('../')
clear ch ax

% make the figure
figure('outerposition',[300 300 800 1000],'PaperUnits','points','PaperSize',[800 1000]); hold on

ax.cartoon = subplot(6,1,1); hold on
ax.spiking_g = subplot(6,4,5); hold on
ax.spiking_V = subplot(6,4,6); hold on
ax.spiking_f = subplot(3,2,3); hold on
ax.spiking_Ca = subplot(3,2,5); hold on

ax.bursting_g = subplot(6,4,7); hold on
ax.bursting_V = subplot(6,4,8); hold on
ax.bursting_f = subplot(3,2,4); hold on
ax.bursting_Ca = subplot(3,2,6); hold on

figlib.pretty('plw',1,'lw',1,'fs',12)

% make a spiking neuron
x = singleCompartment.makeNeuron();
singleCompartment.disableControllers(x)
x.set('*gbar',[190 64 4.3 .62 0 1517 .125 1820])

% measure calcium levels in base model
x.dt = .1;
x.t_end = 10e3;
x.integrate;
V = x.integrate;
Ca0 = x.AB.Ca_average;
metrics0 = xtools.V2metrics(V,'sampling_rate',10);

time = (1:length(V))*1e-3*x.dt;
plot(ax.spiking_V,time,V,'k')
set(ax.spiking_V,'XLim',[0 1])


x.plotgbars(ax.spiking_g,'AB')

for i = 1:length(x.handles.gbar_plot)
	% make stem plots solid
	x.handles.gbar_plot(i).MarkerFaceColor = x.handles.gbar_plot(i).Color;
	x.handles.gbar_plot(i).LineWidth = 1;
end

model_hash = hashlib.md5hash(x.get('*gbar'));

% measure Calcium level set
singleCompartment.perturb.findCalciumNullcline(x);
load([model_hash '_calcium.voronoi'],'v','-mat')



% measure behaviour in a grid using xgrid
% we will encode behaviour using colours 


gridsize = 100;
g0 = x.get('*gbar');

x0 = sum(g0(2:3));
y0 = sum(g0([1 4 5 6 8]));

x_range = corelib.logrange(x0/100,x0*10,gridsize);
y_range = corelib.logrange(y0/100,y0*10,gridsize);



if exist('spiking_neuron_grid.mat','file')
	load('spiking_neuron_grid.mat','g','Ca','metrics')
else

	

	all_g = repmat(g0,1,100,100);


	for i = 1:gridsize
		for j = 1:gridsize
			all_g(:,i,j) =  singleCompartment.perturb.scaleG(g0,x_range(i),y_range(j));
		end
	end


	all_g = reshape(all_g,8,gridsize*gridsize);

	p = xgrid;
	p.cleanup;
	p.x = x;
	p.n_batches = 40;
	p.sim_func = @singleCompartment.measureMetrics;
	p.batchify(all_g,x.find('*gbar'));


	p.simulate;
	p.wait()


	[sim_data,metadata] = p.gather;
	metrics = sim_data{1};
	Ca = sim_data{2};
	g = sim_data{3};


	save('spiking_neuron_grid.mat','g','Ca','metrics')

end


% project g onto plane
xx = sum(g(2:3,:));
yy = sum(g([1 4 5 6 8],:));

f = log(metrics(5,:)./metrics0.firing_rate);



show_here = ax.spiking_f;
scatter(show_here,xx,yy,63,f,'filled','Marker','s')
set(show_here,'XScale','log','YScale','log')
c = parula;
c(1,:) = 1;
colormap(show_here,c);
caxis(show_here,[-.5 2])

ch.spiking_f = colorbar(show_here);
set(ch.spiking_f,'YTick',[-.5 log([25 50 100]/25)],'YTickLabel',{'Silent','25', '50','100'});
title(ch.spiking_f,'f (Hz)')

plot((show_here),x_range,y_range,'k:','LineWidth',2);
axis((show_here),'square');



show_here = ax.spiking_Ca; hold on

rel_ca = log2(Ca./Ca0);
rel_ca(rel_ca<-2) = -2;

scatter(show_here,xx,yy,63,rel_ca,'filled','Marker','s')

set(show_here,'XScale','log','YScale','log')
ch.spiking_Ca = colorbar(show_here);
colormap(show_here,colormaps.redblue);


caxis((show_here),[-4 4])


plot((show_here),x_range,y_range,'k:','LineWidth',2);
axis((show_here),'square');

set(ch.spiking_Ca,'YTick',[-4:2:4],'YTickLabel',{'<1/16','1/4', 'Target','4X','16X'});
title(ch.spiking_Ca,'<[Ca^{2+}]>')



% plot level set
xx = v.boundaries(1).regions.x;
yy = v.boundaries(1).regions.y;
xx(xx==max(xx)) = NaN;
yy(yy==max(yy)) = NaN;
plot(show_here,xx,yy,'k')

XLim = [min(x_range)*.8 max(x_range)*1.2];
YLim = [min(y_range)*.8 max(y_range)*1.2];

set(show_here,'XLim',XLim,'YLim',YLim,'XTick',[10 100 1e3])
set(ax.spiking_f,'XLim',XLim,'YLim',YLim,'XTick',[10 100 1e3])
xlabel(show_here,'$\Sigma \bar{g}_{Ca} (\mu S/mm^2)$','interpreter','latex')
ylabel(show_here,'$\Sigma \bar{g}_{others} (\mu S/mm^2)$','interpreter','latex')
ylabel(ax.spiking_f,'$\Sigma \bar{g}_{others} (\mu S/mm^2)$','interpreter','latex')






% make a bursting neuron
x = singleCompartment.makeNeuron();
singleCompartment.disableControllers(x)
x.set('*gbar',[379 165 2.35 .72 297 1713 .46 1370])
model_hash = hashlib.md5hash(x.get('*gbar'));

% measure calcium levels in base model
x.dt = .1;
x.t_end = 10e3;
x.integrate;
V = x.integrate;
Ca0 = x.AB.Ca_average;
metrics0 = xtools.V2metrics(V,'sampling_rate',10);

% show gbars
x.plotgbars(ax.bursting_g,'AB')

for i = 1:length(x.handles.gbar_plot)
	% make stem plots solid
	x.handles.gbar_plot(i).MarkerFaceColor = x.handles.gbar_plot(i).Color;
	x.handles.gbar_plot(i).LineWidth = 1;
end

% show voltage trace
time = (1:length(V))*1e-3*x.dt;
plot(ax.bursting_V,time,V,'k')
set(ax.bursting_V,'XLim',[0 2])

% measure Calcium level set
singleCompartment.perturb.findCalciumNullcline(x);
load([model_hash '_calcium.voronoi'],'v','-mat')


% measure behaviour in a grid using xgrid
% we will encode behaviour using colours 

gridsize = 100;
g0 = x.get('*gbar');

x0 = sum(g0(2:3));
y0 = sum(g0([1 4 5 6 8]));

x_range = corelib.logrange(x0/100,x0*10,gridsize);
y_range = corelib.logrange(y0/100,y0*10,gridsize);

if exist('bursting_neuron_grid.mat','file')
	load('bursting_neuron_grid.mat','g','Ca','metrics')
else


	all_g = repmat(g0,1,100,100);

	for i = 1:gridsize
		for j = 1:gridsize
			all_g(:,i,j) =  singleCompartment.perturb.scaleG(g0,x_range(i),y_range(j));
		end
	end


	all_g = reshape(all_g,8,gridsize*gridsize);

	p = xgrid;
	p.cleanup;
	p.x = x;
	p.n_batches = 40;
	p.sim_func = @singleCompartment.measureMetrics;
	p.batchify(all_g,x.find('*gbar'));


	p.simulate;
	p.wait()


	[sim_data,metadata] = p.gather;
	metrics = sim_data{1};
	Ca = sim_data{2};
	g = sim_data{3};


	save('bursting_neuron_grid.mat','g','Ca','metrics')

end


% project g onto plane
xx = sum(g(2:3,:));
yy = sum(g([1 4 5 6 8],:));

f = metrics(5,:);
f = f/max(f);


regularity = metrics(9,:)./metrics(11,:);
regularity = log(regularity);
regularity = regularity/max(regularity);


spike_peak = metrics(19,:);
spike_peak = spike_peak - min(spike_peak);
spike_peak = spike_peak/max(spike_peak);

C = zeros(length(xx),3);
C(:,3) = f;
C(:,1) = 1-regularity;
C(:,2) = spike_peak;

show_here = ax.bursting_f;
scatter(show_here,xx,yy,63,C,'filled','Marker','s')
set(show_here,'XScale','log','YScale','log')
axis((show_here),'square');

plot(ax.bursting_f,x_range,y_range,'k:','LineWidth',2);


% show calcium
show_here = ax.bursting_Ca; hold on

rel_ca = log2(Ca./Ca0);
rel_ca(rel_ca<-2) = -2;

scatter(show_here,xx,yy,63,rel_ca,'filled','Marker','s')

set(show_here,'XScale','log','YScale','log')
ch.bursting_Ca = colorbar(show_here);
colormap(show_here,colormaps.redblue);
ch.bursting_Ca.Position = [.92 .11 .01 .1];

caxis((show_here),[-4 4])


plot((show_here),x_range,y_range,'k:','LineWidth',2);
axis((show_here),'square');

set(ch.bursting_Ca,'YTick',[-4:2:4],'YTickLabel',{'<1/16','1/4', 'Target','4X','16X'});
title(ch.bursting_Ca,'<[Ca^{2+}]>')


xx = v.boundaries(1).regions.x;
yy = v.boundaries(1).regions.y;
xx(xx==max(xx)) = NaN;
yy(yy==max(yy)) = NaN;
plot(show_here,xx,yy,'k')


XLim = [min(x_range)*.8 max(x_range)*1.2];
YLim = [min(y_range)*.8 max(y_range)*1.2];

set(show_here,'XLim',XLim,'YLim',YLim,'XTick',[10 100 1e3])
xlabel(show_here,'$\Sigma \bar{g}_{Ca} (\mu S/mm^2)$','interpreter','latex')
ylabel(show_here,'$\Sigma \bar{g}_{others} (\mu S/mm^2)$','interpreter','latex')

set(ax.bursting_f,'XLim',XLim,'YLim',YLim,'XTick',[10 100 1e3])

ylabel(ax.bursting_f,'$\Sigma \bar{g}_{others} (\mu S/mm^2)$','interpreter','latex')

axlib.makeEphys(ax.bursting_V)
axlib.makeEphys(ax.spiking_V,'time_scale',.5)








% cosmetic fixes
ax.spiking_g.Position = [.1 .73 .15 .05];
ax.spiking_g.YLim = [.1 1e4];
ax.spiking_g.YTick = [1 100 1e3];
ax.spiking_g.YMinorTick = 'off';

ax.spiking_V.Position = [.3 .73 .1 .05];

ax.bursting_g.Position = [.6 .73 .15 .05];
ax.bursting_g.YLim = [.1 1e4];
ax.bursting_g.YTick = [1 100 1e3];
ax.bursting_g.YMinorTick = 'off';

ax.bursting_V.Position = [.8 .73 .1 .05];

ylabel(ax.bursting_g,'$\bar{g} (\mu S/mm^2)$','interpreter','latex')

ax.spiking_Ca.Position = [.1 .05 .3 .3];
ax.bursting_Ca.Position = [.6 .05 .3 .3];
ax.spiking_f.Position = [.1 .35 .3 .3];
ax.bursting_f.Position = [.6 .35 .3 .3];

ch.spiking_Ca.Position = [.43 .11 .01 .1];

ch.spiking_f.Position = [.43 .41 .01 .1];

% create fake axes over the bursting f plot to put colorbars there
for i = 1:3
	fake_axes(i) = axes;
	fake_axes(i).Position = ax.bursting_f.Position;
	fake_axes(i).Position(1) = 1;
	set(fake_axes(i),'YTick',[],'YColor','w')

	% create the colormaps we need
	C = zeros(100,3);
	for j = 1:3
		C(:,j) = linspace(1,0,100);
	end
	C(:,i) = 1;
	colormap(fake_axes(i),C);


	fake_colorbar(i) = colorbar(fake_axes(i));
	fake_colorbar(i).YTick = [];
	fake_colorbar(i).Location = 'northoutside';
end

for i = 1:3
	fake_colorbar(i).Position = [.51 + i*.1 .64 .09 .01];
end

th = title(fake_colorbar(1),'ISI regularity');
th.Position = [20 10 0];
th = title(fake_colorbar(2),'Peak voltage');
th.Position = [20 10 0];
th = title(fake_colorbar(3),'Firing rate');
th.Position = [20 10 0];