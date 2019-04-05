function [f0, Ca0, all_f, isi_mean, isi_std, Ca_mean, Ca_std, metrics0, metrics] = varySizeMeasureBehaviour(x,~,~)

x.AB.A = 0.0628;
x.AB.vol = 0.0628;
x.dt = .1;
x.sim_dt = .05;
x.t_end = 1e4;

% first measure the firing rate in the noiseless case
x.stochastic_channels = 0;
x.reset;
x.integrate;
[V,Ca] = x.integrate;
f0 = xtools.findNSpikes(V)/(x.t_end*1e-3);
Ca0 = [mean(Ca(:,1)); std(Ca(:,1))];
metrics0 = structlib.vectorise(xtools.V2metrics(V,'sampling_rate',round(1./x.dt)));


N = 20;
all_sizes = logspace(-4,-1,N);
all_f = NaN*all_sizes;
isi_mean = NaN*all_sizes;
isi_std = NaN*all_sizes;
Ca_mean = NaN*all_sizes;
Ca_std = NaN*all_sizes;
metrics =  repmat(metrics0,1,N)*NaN;

for i = 1:N

	x.AB.A = all_sizes(i);
	x.AB.vol = all_sizes(i);
	x.stochastic_channels = 1;

	x.reset;
	x.integrate;
	[V,Ca] = x.integrate;

	nspikes = xtools.findNSpikes(V);

	all_f(i) = nspikes/(x.t_end*1e-3);

	Ca_mean(i) = mean(Ca(:,1));
	Ca_std(i) = std(Ca(:,1));


	spiketimes = xtools.findNSpikeTimes(V,nspikes);
	isis = diff(spiketimes);

	isi_mean(i) = mean(isis);
	isi_std(i) = std(isis);

	metrics(:,i) = structlib.vectorise(xtools.V2metrics(V,'sampling_rate',round(1./x.dt)));

end

metrics = metrics(:);