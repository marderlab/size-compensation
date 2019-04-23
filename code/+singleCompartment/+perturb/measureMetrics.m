% given a certain sigma_g and sigma_others,
% configures the gbars in that model so that
% these conditions are met, and then measures
% the metrics of this model
% if integral controllers are configured, the model
% is allowed to reach steady state first. 

function varargout =  measureMetrics(X, Y, data)

	R = 1;

	x = data.x;
	x.reset('base');
	g0 = data.g0;
	g = data.g0;

	% scale the channels based on where we are in the 2D space
	g = singleCompartment.perturb.scaleG(g0,X,Y, data.gbar_x, data.gbar_y);
	x.set('*gbar',g);


	if isinf(min(x.get('*Controller.tau_m')))


		x.t_end = 20e3;
		x.dt = .1;
		x.integrate;

		V = x.integrate;

		metrics = xtools.V2metrics(V,'sampling_rate',10);
		metrics.Ca_average = x.AB.Ca_average;
		results = Data(metrics);

	else

		
		% also configure integral controllers
		x.set('*Controller.m',g*x.AB.A)
		x.AB.CaT.E = 30;
		x.AB.CaS.E = 30;

		T = 0;

		x.t_end = 1e4;
		x.dt = 10;

		goon = true;
		while goon


			x.integrate;
			T = T + x.t_end;

			Ca_avg = x.AB.Ca_average;

	
			if T > 1e6 | abs(Ca_avg(end)/x.AB.Ca_target - 1) < .01
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


		metrics.Ca_error = abs(x.AB.Ca_average/x.AB.Ca_target - 1);
		metrics.gbar = x.get('*gbar');
		results = Data(metrics);

	end


	varargout{2} = results;
	if nargout == 3
		varargout{3} = V;
	end

	varargout{1} = singleCompartment.classifyMetrics(data.metrics_base,metrics);




end