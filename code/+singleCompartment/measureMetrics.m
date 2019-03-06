% measures metrics of a single compartment neuron
% spiker/burster
% meant to be called by xgrid

function [metrics, Ca, this_g] = measureMetrics(x)


x.reset;
x.dt = .1;
x.sim_dt = .1;
x.t_end = 10e3;
x.integrate;

V = x.integrate;


disp('Measuring metrics...')
metrics = (xtools.V2metrics(V,'sampling_rate',10));
disp(['firing rate = ' strlib.oval(metrics.firing_rate)])
metrics = structlib.vectorise(metrics);

this_g = x.get('*gbar');

Ca = x.AB.Ca_average;



disp('All done!')