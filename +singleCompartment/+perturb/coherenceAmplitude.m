% 

function [metrics, gbar, Ca_error] = coherenceAmplitude(x,~,~)


x.reset;


% also configure integral controllers
g = x.get('*gbar');
x.set('*Controller.m',g*x.AB.A)
x.AB.CaT.E = 30;
x.AB.CaS.E = 30;

T = 0;

x.t_end = 1e4;

goon = true;
while goon


	x.integrate;
	T = T + x.t_end;

	Ca_avg = x.AB.Ca_average;


	if T > 1e6 | abs(Ca_avg/x.AB.Ca_target - 1) < .01
		goon = false;
	end

end


% measure the metrics 
x.t_end = 20e3;
x.dt = .1;
x.integrate;
V = x.integrate;
metrics = xtools.V2metrics(V,'sampling_rate',1/x.dt);


% informational
disp(['Burst period is: ' strlib.oval(metrics.burst_period)])
disp(['Duty cycle is: ' strlib.oval(metrics.duty_cycle_mean)])

metrics = structlib.vectorise(metrics);

Ca_error = abs(x.AB.Ca_average/x.AB.Ca_target - 1);
gbar = x.get('*gbar');


