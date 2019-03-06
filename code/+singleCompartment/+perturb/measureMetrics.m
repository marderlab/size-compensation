% given a certain sigma_g and sigma_others,
% configures the gbars in that model so that
% these conditions are met, and then measures
% the metrics of this model
% if integral controllers are configured, the model
% is allowed to reach steady state first. 

function varargout =  measureMetrics(sigma_Ca, sigma_others, data)

	R = 1;

	x = data.x;
	x.reset('base');
	g0 = data.g0;
	g = data.g0;

	% scale calcium channels
	g0(2:3) = g0(2:3)/sum(g0(2:3));
	g0([1 4 5 6 8]) = g0([1 4 5 6 8])/sum(g0([1 4 5 6 8]));
	g(2:3) = g0(2:3)*sigma_Ca;
	g([1 4 5 6 8]) = g0([1 4 5 6 8])*sigma_others;
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

		x.t_end = 1e5;
		x.dt = 10;

		goon = true;
		while goon


			[~,~,C] = x.integrate;

			Ca_avg = C(:,7);
			C(:,7) = [];

			T = T + x.t_end;
			if T > 1e6 | abs(Ca_avg(end)/x.AB.Ca_target - 1) < .01
				goon = false;
			end

		end


		% measure the metrics 
		x.t_end = 20e3;
		x.dt = .1;
		x.integrate;
		V = x.integrate;
		metrics = xtools.V2metrics(V,'sampling_rate',10);

		% informational
		disp(['Burst period is: ' oval(metrics.burst_period)])
		disp(['Duty cycle is: ' oval(metrics.duty_cycle_mean)])


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