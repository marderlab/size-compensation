


function [Ca, firing_rate, A, g] = measureCalcium(x)




g = x.get('*gbar')*x.AB.A;
A = x.AB.A;

% need to set the volume to the same as the area
x.AB.vol = A;

x.reset;
x.t_end = 10e3;
x.dt = .1;
x.sim_dt = .05;
x.integrate;

V = x.integrate;


firing_rate = xtools.findNSpikes(V)/(x.t_end*1e-3);
Ca = x.AB.Ca_average;

