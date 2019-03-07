% makes the 2D perturbation diagram
% without any integral control
% 
function status = analyzeWithoutControl(x, gbar_x, gbar_y)

status = 1;


x.t_end = 20e3;
x.dt = .1;

gbar = x.get('*gbar');
save_name = hashlib.md5hash(gbar);

disp(['Saving using: ' save_name])

if exist([save_name '_0.voronoi'],'file')
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
data.x = x;
data.g0 = gbar;
data.gbar_x = gbar_x;
data.gbar_y = gbar_y;


% informational
disp(['Burst period is: ' strlib.oval(data.metrics_base.burst_period)])
disp(['Duty cycle is: ' strlib.oval(data.metrics_base.duty_cycle_mean)])

% the two axes we are varying things in 
% are sigma_g_ca and sigma_g_others
% x is the sum of all the calcium channels
% and y is the sum of all the other channels


% configure voronoiSegment 
x0 = sum(data.g0(gbar_x));
y0 = sum(data.g0(gbar_y));

v = singleCompartment.perturb.configureVoronoiSegment(data, x0, y0);


x0 = logspace(-.9,0,10)*x0;
y0 = logspace(-.9,0,10)*y0;
singleCompartment.perturb.segmentAndSave(v, x0, y0, [save_name '_0.voronoi']);


% clean up the start file
delete([save_name '.start'])