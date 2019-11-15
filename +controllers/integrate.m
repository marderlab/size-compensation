
% integrates a model and measures things after a while

function [all_g, all_burst_periods, all_duty_cycle, all_Ca] = integrate(x, thing_to_vary, values, N, integration_time)

hash = hashlib.md5hash([hashlib.md5hash(thing_to_vary) hashlib.md5hash(values) x.hash]);

if exist(['.cache/' hash '.cache'],'file') == 2
	load(['.cache/' hash '.cache'],'-mat','all_g','all_Ca','all_burst_periods','all_duty_cycle')
	return
end

if ~exist('N','var')
	N = 1000;
end

if ~exist('integration_time','var')
	integration_time = 500e3;
end


all_g = NaN(N,8);
all_burst_periods = NaN(N,1);
all_duty_cycle = NaN(N,1);
all_Ca = NaN(N,1);


parfor i = 1:N

	x.set('*tau_g',5e3)
	controllers.reset(x)
	x.set(thing_to_vary,values(i,:));
	if strcmp(thing_to_vary,'*gbar')
		% also reset mRNA
		g = x.get('*gbar');
		x.set('*Controller.m',g*x.AB.A);
	end
	x.set('t_end',integration_time);
	x.integrate;


	% turn control off and measure behaviour
	x.set('*tau_g',Inf)
	x.set('t_end',20e3);
	V = x.integrate;
	m = xtools.V2metrics(V,'sampling_rate',1/x.dt);
	all_burst_periods(i) = m.burst_period;
	all_duty_cycle(i) = m.duty_cycle_mean;

	all_g(i,:) = x.get('*gbar');

	all_Ca(i) = x.AB.Ca_average;


end


% save into cache
save(['.cache/' hash '.cache'],'all_g','all_Ca','all_burst_periods','all_duty_cycle')