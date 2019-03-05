% makes the 2D perturbation diagram
% with integral control
% 
function status = analyzeWithControl(x)

status = 1;


gbar = x.get('*gbar');
save_name = GetMD5(gbar);


if exist([save_name '_1.voronoi'],'file')
	disp('Already done, skipping...')
	status = 0;
	return
end

x.reset;

% write to disk just so we know where it's writing
save([save_name '.start'],'status')


disp('==========================================')

% turn off all integral controllers
singleCompartment.configureControllers(x);

% measure metrics of base
clear data
data.metrics_base = singleCompartment.measureBaselineMetrics(x);
data.x = x;
data.g0 = gbar;

% informational
disp(['Burst period is: ' oval(data.metrics_base.burst_period)])
disp(['Duty cycle is: ' oval(data.metrics_base.duty_cycle_mean)])

% the two axes we are varying things in 
% are sigma_g_ca and sigma_g_others
% x is the sum of all the calcium channels
% and y is the sum of all the other channels


% configure voronoiSegment 
x0 = (x.AB.CaS.gbar + x.AB.CaT.gbar);
y0 = sum(gbar) - x0;

v = singleCompartment.perturb.configureVoronoiSegment(data, x0, y0);
v.max_fun_eval = 400;

x0 = logspace(-.9,0,10)*x0;
y0 = logspace(-.9,0,10)*y0;
singleCompartment.perturb.segmentAndSave(v, x0, y0, [save_name '_1.voronoi']);


% clean up the start file
delete([save_name '.start'])