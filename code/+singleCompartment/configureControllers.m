% configure the controllers of a 
% single compartment neuron
% assuming it is created using
% singleCompartment.makeNeuron()

function configureControllers(x, tau_m0)

if nargin < 2
	tau_m0 = 5e3;
end

comp_name = x.Children;

assert(length(comp_name) == 1,'This function will only work for single compartment models')

comp_name = comp_name{1};

gbar = x.get('*gbar');

% first turn off all controllers
singleCompartment.disableControllers(x);


x.t_end = 20e3;
x.dt = .1;

% measure metrics of this base model
x.t_end = 20e3;
x.integrate;
x.dt = .1;
x.snapshot('base');

% measure calcium target in the base model
x.(comp_name).Ca_target = x.(comp_name).Ca_average;


% configure controllers
tau_m = (tau_m0*max(gbar))./gbar;
x.set('*Controller.tau_m',tau_m);
x.set('*Controller.tau_g',tau_m0);
x.set('*Controller.m',gbar*x.(comp_name).A)
x.(comp_name).Leak.(x.(comp_name).Leak.Children{1}).tau_g = Inf;

