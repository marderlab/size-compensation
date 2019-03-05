function v = configureVoronoiSegment(data, x0, y0)


disp('Configuring voronoiSegment....')


x_range = [x0/100 x0*10];
y_range = [y0/100 y0*10];


v = voronoiSegment;
v.data = data;

v.n_seed = 4;
v.sim_func = @singleCompartment.perturb.measureMetrics;
v.y_range = y_range;
v.x_range = x_range;
v.n_classes = 4;
v.make_plot = true;
v.labels = {'Silent','Spiker','Canonical','Other'};
v.max_fun_eval = 300;
