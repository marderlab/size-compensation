
close all
addpath('../')

figure('outerposition',[300 300 900 701],'PaperUnits','points','PaperSize',[900 701]); hold on
clear ax
for i = 1:4
	ax(i) = subplot(2,2,i); hold on
	axis(ax(i),'square')
end


figlib.pretty('plw',1,'lw',1,'fs',14)



% make a bursting neuron
g0 = [379 165 2.35 .72 297 1713 .46 1370];
x = singleCompartment.makeNeuron();
x.set('*gbar',g0)
singleCompartment.configureControllers(x)

model_hash = hashlib.md5hash(x.get('*gbar'));


Ca_target = x.AB.Ca_target;

% find the minimum g_Ca where we have a zero in the calcium equation 

x0 = sum(g0(2:3));
y0 = sum(g0([1 4 5 6 8]));

x_range = [900 x0*10];
y_range = [y0/100 x0*10];

if exist('zeros_in_Ca.mat','file') == 2
	load('zeros_in_Ca.mat','all_g_Ca','zero_locs')
else
	
	all_g_Ca = corelib.logrange(x_range(1),x_range(2),1e3);
	zero_locs = NaN(2,length(all_g_Ca));

	parfor i = 1:length(all_g_Ca)
		disp(i)
		[n_zeros, zl ] = analytical.countZerosInCalciumODE(g0,all_g_Ca(i),Ca_target);
		if n_zeros == 2
			zero_locs(:,i) = zl;
		end

	end

	save('zeros_in_Ca.mat','all_g_Ca','zero_locs')

end


% show the zeros of the calcium equation
plot(ax(1),all_g_Ca,zero_locs,'k','LineWidth',1.5)
xlabel(ax(1),'$\Sigma \bar{g}_{Ca} (\mu S/mm^2)$','interpreter','latex')
ylabel(ax(1),'$V\bigl|_{\dot{Ca}=0} (mV)$','interpreter','latex')
set(ax(1),'XScale','log')

% the two branches are symmetric, so we can throw one away
zero_locs(2,:) = [];
Ca_zeros.zero_locs = zero_locs;
Ca_zeros.all_g_Ca = all_g_Ca;




if exist('smallest_v_dot.mat','file') == 2
	load('smallest_v_dot.mat','smallest_v_dot')
else
	smallest_v_dot = analytical.findSmallestVdotInGrid(g0, x_range, y_range, Ca_zeros, Ca_target, 1e3, 5e3);
	save('smallest_v_dot.mat','smallest_v_dot');
end

all_y = corelib.logrange(y_range(1),y_range(2),5e3);
all_x = NaN*all_y;

grid_x = corelib.logrange(x_range(1),x_range(2),1e3);

for i = 1:length(all_y)
	[value,idx]=min(smallest_v_dot(:,i));
	if value > .1
		continue
	end
	all_x(i) = grid_x(idx);
end


rm_this = isnan(all_x);
all_x(rm_this) = [];
all_y(rm_this) = [];


% plot the calciun nullcine 
model_hash = '0dea7e804b9255ac7bba7df3c3b015ff';


load(['../fig3/' model_hash '_1.voronoi'],'-mat')

v.plotBoundaries(ax(2))
set(ax(2),'XScale','log','YScale','log')
c = lines(10);
p = ax(2).Children;
for i = 1:length(p)
	if i == 5
		p(i).FaceColor = c(5,:);
	end
	p(i).FaceAlpha = .5;
end

for i = 1:12
	p(i).FaceAlpha = .15;
end


% plot equi-calcium line

load(['../fig3/' model_hash '_calcium.voronoi'],'-mat')

X = v.boundaries(1).regions.x;
Y = v.boundaries(1).regions.y;
rm_this = X == max(X);
X(rm_this) = [];
Y(rm_this) = [];

plot(ax(2),X,Y,'r','LineWidth',1.5)
set(ax(2),'XScale','log','YScale','log')
axis(ax(2),'square')

x0 = sum(g0(2:3));
y0 = sum(g0([1 4 5 6 8]));

x_range = [x0/100 x0*10];
y_range = [y0/100 y0*10];
set(ax(2),'XLim',x_range,'YLim',y_range,'XTick',[10 100 1e3])
set(ax(1),'XLim',x_range,'XTick',[10 100 1e3],'YLim',[-50 -0])

plot(ax(2),all_x,all_y,'k','LineWidth',1.5)
xlabel(ax(2),'$\Sigma \bar{g}_{Ca} (\mu S/mm^2)$','interpreter','latex')
ylabel(ax(2),'$\Sigma \bar{g}_{others} (\mu S/mm^2)$','interpreter','latex')

plot(ax(2),[v.x_range(1) v.x_range(2)], [v.y_range(1) v.y_range(2)],'k--');


Ca_zero_offset =  2*nanmax(Ca_zeros.zero_locs);
lower_branch = Ca_zeros.zero_locs;
upper_branch = -Ca_zeros.zero_locs + Ca_zero_offset;

% show the voltage and calcium dynamics along the analytical fixed point set

show_at_these_y = [130 400];



set(ax(3),'XScale','log','XLim',[100 200],'YLim',[-50 -0])
M = {'p','d'};

for i = 1:length(show_at_these_y)

	Y = show_at_these_y(i);
	X = interp1(all_y,all_x,Y);

	plot(ax(2),X,Y,'Marker',M{i},'Color','b','MarkerSize',10,'MarkerFaceColor','b')


	g = singleCompartment.perturb.scaleG(g0,X,Y);
	x.set('*gbar',g)
	x.reset;
	x.AB.Ca = Ca_target;
	singleCompartment.disableControllers(x);

	x.AB.V = interp1(all_g_Ca,upper_branch,X);

	x.integrate;
	x.AB.Ca = Ca_target;
	x.AB.V = interp1(all_g_Ca,upper_branch,X);
	[V,Ca] = x.integrate;

	plot(ax(3),Ca(:,1),V,'Color','k');

	plot(ax(3),Ca(1,1),V(1),'Marker',M{i},'Color','b','MarkerSize',10,'MarkerFaceColor','b')

end



plot(ax(3),[Ca_target Ca_target],[-70 -10],'k--')

xlabel(ax(3),'$[Ca^{2+}] (\mu M)$','interpreter','latex')

ylabel(ax(3),'$V_m (mV)$','interpreter','latex')


% now go smoothly along the predicted line
% and measure behaviour everywhere



if exist('bifurcation_data.mat','file') == 2

	load('bifurcation_data.mat','show_at_these_y','all_V','all_spiketimes')
else
	show_at_these_y = corelib.logrange(min(all_y),max(all_y),1e3);

	x.t_end = 5e3;
	x.dt = .1;
	all_V = NaN(length(show_at_these_y),500);
	all_spiketimes = NaN(length(show_at_these_y),100);

	for i = 1:length(show_at_these_y)
		corelib.textbar(i,length(show_at_these_y))

		Y = show_at_these_y(i);
		X = interp1(all_y,all_x,Y);


		g = singleCompartment.perturb.scaleG(g0,X,Y);
		x.set('*gbar',g)
		x.reset;
		x.AB.Ca = Ca_target;
		singleCompartment.disableControllers(x);

		x.AB.V = interp1(all_g_Ca,upper_branch,X);

		x.integrate;
		x.AB.Ca = Ca_target;
		x.AB.V = interp1(all_g_Ca,upper_branch,X);
		[V,Ca] = x.integrate;

		all_spiketimes(i,:) = xtools.findNSpikeTimes(V,100);

		all_V(i,:) = V(1:100:end);

	end

	save('bifurcation_data.mat','show_at_these_y','all_V','all_spiketimes')

end


% plot(ax(5),show_at_these_y,diff(all_spiketimes')*.05,'k.')
% xlabel(ax(5),'$\Sigma \bar{g}_{others} (\mu S/mm^2)$','interpreter','latex')
% ylabel(ax(5),'ISI (ms)')
% set(ax(5),'YScale','log','XLim',[min(show_at_these_y) max(show_at_these_y)])
% set(ax(5),'XScale','log','XLim',[min(all_y),max(all_y)])

plot(ax(4),show_at_these_y,all_V,'.','MarkerSize',1,'Color',[.5 .5 .5])
xlabel(ax(4),'$\Sigma \bar{g}_{others} (\mu S/mm^2)$','interpreter','latex')
ylabel(ax(4),'$V_m (mV)$','interpreter','latex')
set(ax(4),'YScale','linear','XLim',[min(show_at_these_y) max(show_at_these_y)])

set(ax(4),'XScale','log','XLim',[min(all_y),max(all_y)])


figlib.label('x_offset',-.03,'y_offset',-.02,'font_size',24)