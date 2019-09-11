% finds the Calcium nullcline in 2D space
% or where the average Calcium activity is
% the same as in the reference model 

function status = findCalciumNullcline(x, gbar_x, gbar_y)

status = 1;

if nargin == 1
	gbar_x = [2 3];
	gbar_y = [1 4 5 6 8];
end


x.t_end = 20e3;
x.dt = .1;

gbar = x.get('*gbar');
save_name = hashlib.md5hash([gbar(:); gbar_x(:); gbar_y(:)]);



disp(['Saving using: ' save_name])

if exist([save_name '_calcium.voronoi'],'file')
	disp('Already done, skipping...')
	status = 0;
	return
end

x.reset;

% write to disk just so we know where it's writing
save([save_name '.start'],'status')


disp('==========================================')

% turn off all integral controllers
singleCompartment.disableControllers(x);

% measure metrics of base
clear data
data.metrics_base = singleCompartment.measureBaselineMetrics(x);

if data.metrics_base.firing_rate == 0
	disp('Bad model, skipping...')
	delete([save_name '.start'])
	save([save_name '.bad_model'],'status')
	return
end

data.x = x;
data.g0 = gbar;
data.gbar_x = gbar_x;
data.gbar_y = gbar_y;

% measure baseline calcium
x.integrate;
data.Ca_target = x.AB.Ca_average;

% informational
disp(['Burst period is: ' strlib.oval(data.metrics_base.burst_period)])
disp(['Duty cycle is: ' strlib.oval(data.metrics_base.duty_cycle_mean)])

% the two axes we are varying things in 
% are determined by gbar_x and gbar_y

% configure voronoiSegment 
x0 = sum(data.g0(gbar_x));
y0 = sum(data.g0(gbar_y));

v = singleCompartment.perturb.configureVoronoiSegment(data, x0, y0);
v.sim_func = @singleCompartment.perturb.measureCalcium;
v.n_classes = 2;
v.labels = {'Above','Below'};
v.max_fun_eval = 200;

% seed
x0 = logspace(-.9,.4,10)*x0;
y0 = logspace(-.9,.4,10)*y0;

singleCompartment.perturb.segmentAndSave(v, x0, y0, [save_name '_calcium.voronoi']);

% clean up the start file
delete([save_name '.start'])


