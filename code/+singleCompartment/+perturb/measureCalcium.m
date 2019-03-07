% similar to measure Metrics,
% but returns a label based on wheter the calcium
% is above or below the reference calcium 

function [R, results] =  measureCalcium(X, Y, data)

R = 0;

x = data.x;
x.reset('base');
g0 = data.g0;
g = data.g0;



% scale the channels based on where we are in the 2D space
g = singleCompartment.perturb.scaleG(g0,X,Y, data.gbar_x, data.gbar_y);
x.set('*gbar',g)


if isinf(min(x.get('*Controller.tau_m')))


	x.t_end = 20e3;
	x.dt = .1;
	x.integrate;

	V = x.integrate;

	metrics = xtools.V2metrics(V,'sampling_rate',10);
	metrics.Ca_average = x.AB.Ca_average;
	results = Data(metrics);

else

	error('Expected Controllers to be off')

end


disp(['Ca here = ' strlib.oval(x.AB.Ca_average)])

if x.AB.Ca_average > data.Ca_target
	R = 1;
else
	R = 2;
end

