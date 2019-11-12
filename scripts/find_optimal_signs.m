% In this script, we compute how the mean intracellular calcium
% changes as we vary each channel form its reference value

close all
clearvars
addpath('../')

g0 = [379 165 2.35 .72 297 1713 .46 1370];

% control -- integral controller
x = singleCompartment.makeNeuron('controller_type','IntegralController');
x.set('*gbar',g0)
x.reset;


% measure average calcium in baseline model
x.t_end = 20e3;
x.integrate;
x.t_end = 100e3;
x.integrate;
Ca_target = x.AB.Ca_average;


channels_to_vary = setdiff(x.AB.find('conductance'),'Leak');

g_space = logspace(-1,1,21);
all_Ca_average = NaN(length(g_space),length(channels_to_vary));

for i = 1:length(channels_to_vary)
	disp(['Varying ' channels_to_vary{i}])

	this_g0 = x.AB.(channels_to_vary{i}).gbar;

	parfor j = 1:length(g_space)

		disp(j)

		x.set('*gbar',g0);

		this_g = this_g0*g_space(j);
		x.set(['AB.' channels_to_vary{i} '.gbar'], this_g);

		x.reset;
		x.set('t_end',10e3);
		x.integrate;
		x.set('t_end',100e3);
		x.integrate;
		all_Ca_average(j,i) = x.AB.Ca_average;

	end

end


% plot them all
figure('outerposition',[300 300 1200 1200],'PaperUnits','points','PaperSize',[1200 1200]); hold on
for i = 1:length(channels_to_vary)
	subplot(3,3,i); hold on
	plot(g_space,all_Ca_average(:,i))
	
	title(channels_to_vary{i})
	plot(g_space,g_space*0 + Ca_target,'k:')
	set(gca,'XScale','log','YScale','log','YLim',[1 1e3])

	if i == 4
		ylabel('<[Ca^{2+}]> (uM)')
	end
end

figlib.pretty()
