% makes the 2D perturbation diagram
% with integral control
% 
function status = analyzeWithControl(x, gbar_x, gbar_y)

status = 1;


gbar = x.get('*gbar');
%save_name = hashlib.md5hash([gbar(:); gbar_x(:); gbar_y(:)]);

save_name = hashlib.md5hash([x.hash hashlib.md5hash([gbar_x(:); gbar_y(:)])]);

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
data.gbar_x = gbar_x;
data.gbar_y = gbar_y;

% informational
disp(['Burst period is: ' strlib.oval(data.metrics_base.burst_period)])
disp(['Duty cycle is: ' strlib.oval(data.metrics_base.duty_cycle_mean)])

% the two axes we are varying things in 
% are determined by gbar_x and gbar_y


% configure voronoiSegment 

x0 = sum(data.g0(gbar_x));
y0 = sum(data.g0(gbar_y));

v = singleCompartment.perturb.configureVoronoiSegment(data, x0, y0);
v.max_fun_eval = 400;

x0 = logspace(-.9,0,10)*x0;
y0 = logspace(-.9,0,10)*y0;
singleCompartment.perturb.segmentAndSave(v, x0, y0, [save_name '_1.voronoi']);


% clean up the start file
delete([save_name '.start'])