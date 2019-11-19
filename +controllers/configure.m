% configures controllers in a model

function configure(x)

x.t_end = 20e3;
x.integrate;
x.integrate;

x.AB.Ca_target = x.AB.Ca_average;


tau_m = 5e6./x.get('*gbar');
x.set('*tau_m',tau_m);
x.set('*tau_g',5e3)

x.set('*Controller.m',x.get('*gbar')*x.AB.A)