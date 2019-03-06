% this function deletes channels
% one by one, without and without 
% integral control,
% and measures metrics when deleted
% and after recovery 

function status = deleteChannels(x)

gbar = x.get('*gbar');
save_name = hashlib.md5hash(gbar);

status = 1;

x.t_end = 20e3;
x.dt = .1;



singleCompartment.disableControllers(x);

metrics_base = singleCompartment.measureBaselineMetrics(x);
metrics_base = x.AB.Ca_average;


channels = x.AB.find('conductance');

for i = 1:length(channels)

	x.set('*gbar',gbar);
	x.AB.(channels{i}).gbar = 0;

	V = x.integrate;

	this_metrics = xtools.V2metrics(V,'sampling_rate',10);	
	this_metrics.Ca_average = x.AB.Ca_average;

	if i == 1
		metrics = Data(this_metrics);
	else
		metrics + this_metrics;
	end



end


save([save_name '_0.knockout'],'metrics','metrics_base','gbar')

x.set('*gbar',gbar);

singleCompartment.configureControllers(x);


channels = x.AB.find('conductance');

for i = 1:length(channels)

	x.set('*gbar',gbar);
	x.AB.(channels{i}).gbar = 0;

	x.t_end = 1e5;
	x.integrate;

	x.t_end = 20e3;
	V = x.integrate;

	this_metrics = xtools.V2metrics(V,'sampling_rate',10);	
	this_metrics.Ca_average = x.AB.Ca_average;
	this_metrics.gbar = x.get('*gbar');

	if i == 1
		metrics = Data(this_metrics);
	else
		metrics + this_metrics;
	end



end

save([save_name '_1.knockout'],'metrics','metrics_base','gbar')
