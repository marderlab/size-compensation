function [metrics0, metrics_big, metrics_small] = twoSizesMeasureMetrics(x,~,~)

% turn off aprooximations
x.approx_channels = 0;


x.AB.A = 1e-1;
x.AB.vol = 1e-1;
x.dt = .1;
x.sim_dt = .05;
x.t_end = 1e4;

% first measure the firing rate in the noiseless case
x.stochastic_channels = 0;
x.reset;
x.integrate;
V = x.integrate;
metrics0 = structlib.vectorise(xtools.V2metrics(V,'sampling_rate',round(1./x.dt)));

% number of repetitions
N = 20;

metrics_small =  repmat(metrics0,1,N)*NaN;
metrics_big =  repmat(metrics0,1,N)*NaN;

% "big"
x.AB.A = 1e-1;
x.AB.vol = 1e-1;
x.stochastic_channels = 1;

for i = 1:N

	x.reset;
	x.integrate;
	V = x.integrate;

	metrics_big(:,i) = structlib.vectorise(xtools.V2metrics(V,'sampling_rate',round(1./x.dt)));

end


% small
x.AB.A = 1e-4;
x.AB.vol = 1e-4;
for i = 1:N

	x.reset;
	x.integrate;
	V = x.integrate;

	metrics_small(:,i) = structlib.vectorise(xtools.V2metrics(V,'sampling_rate',round(1./x.dt)));

end

metrics_big = metrics_big(:);
metrics_small = metrics_small(:);

disp('DONE!')