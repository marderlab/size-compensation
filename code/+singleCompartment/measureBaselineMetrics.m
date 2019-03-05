% measures activity of a neuron

function metrics = measureBaselineMetrics(x)

% measure metrics of this base model
disp('Measuring metrics of base model....')
x.t_end = 20e3;
x.integrate;
x.dt = .1;
V = x.integrate;
x.snapshot('base');
metrics = xtools.V2metrics(V,'sampling_rate',10);
