% densely sample the 2D space
% without any integral control
% using a log-distributed grid

function status = denseSampleWithoutControl(x)

status = 1;


gbar = x.get('*gbar');
save_name = hashlib.md5hash(gbar);


if exist([save_name '_dense.voronoi'],'file')
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


% make a grid of points to start from
[X,Y] = meshgrid(logspace(log10(v.x_range(1)),log10(v.x_range(2)),50), logspace(log10(v.y_range(1)),log10(v.y_range(2)),50));
X = X(:);
Y = Y(:);

singleCompartment.perturb.segmentAndSave(v, X, Y, [save_name '_dense.voronoi']);

% clean up the start file
delete([save_name '.start'])