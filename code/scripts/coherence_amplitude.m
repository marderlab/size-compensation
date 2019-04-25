% this script makes a figure of probability of recovery
% as function of perturbation coherence and amplitude
% this of this as a more generalized version of the basin of 
% attraction plot


g0 = [379 165 2.35 .72 297 1713 .46 1370];

% control -- integral controller
x = singleCompartment.makeNeuron('controller_type','IntegralController');
x.set('*gbar',g0)
x.reset
x.integrate;
singleCompartment.configureControllers(x,5e3);
x.t_end = 5e3;


% measure the metrics 
x.t_end = 20e3;
x.dt = .1;
x.integrate;
V = x.integrate;
metrics0 = xtools.V2metrics(V,'sampling_rate',1/x.dt);

% make a matrix of all the gbars corresponding to the perturbations 
N = 100;
all_mu = linspace(-.90,.90,N); % fraction
all_sigma = corelib.logrange(1e-3,.20,N); % fraction



all_gbar = repmat(g0,N*N,1);

idx = 1;

for i = 1:N
	for j = 1:N

		all_gbar(idx,:) = (randn(8,1)*all_sigma(i) + all_mu(j)) + 1;
		all_gbar(idx,:) = all_gbar(idx,:) .*g0;
		idx = idx + 1;
	end
end



all_gbar = abs(all_gbar);
all_gbar(:,7) = g0(7);
all_gbar = all_gbar';

if exist('generalized_perturbations.mat','file') == 2

	load('generalized_perturbations.mat','data','params')
else

	p = xgrid;
	p.cleanup;
	p.x = x;


	p.sim_func = @singleCompartment.perturb.coherenceAmplitude;

	parameters_to_vary = x.find('*gbar');

	p.batchify(all_gbar,parameters_to_vary);


	p.simulate;
	p.wait;


	[data, params] = p.gather;


	save('generalized_perturbations.mat','data','params')
end

metrics = data{1};
gbar = data{2};

Ca_error  = data{3};

% back calcualte mean and std of perturbation 
all_gbar = params./g0';
all_gbar(7,:) = [];
all_gbar = all_gbar - 1;

all_mu = mean(all_gbar);
all_sigma = std(all_gbar);


figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(1,2,1); hold on

scatter(all_sigma,metrics(1,:),34,all_mu,'filled','Marker','o')
set(gca,'XScale','log')

subplot(1,2,2); hold on
scatter(all_sigma,metrics(3,:),34,all_mu,'filled','Marker','o')
set(gca,'XScale','log')