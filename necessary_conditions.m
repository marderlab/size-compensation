
%%
% In this figure, we show the necessary conditions for feedback co-regulation to be robust to size changes. 


% get lots of bursting neuron models with some narrow set of parameters

if exist('bursting_neurons.mat','file') == 2
	load('bursting_neurons.mat','all_g')
else

	n = neuroDB;
	n.DataDump = '/code/neuron-db/prinz/';

	min_T = .9e3;
	max_T = 1.1e3;
	min_dc = .19;
	max_dc = .21;
	n_spikes = 10;



	use_these = n.results.burst_period > min_T & n.results.burst_period < max_T & n.results.duty_cycle_mean > min_dc & n.results.duty_cycle_mean < max_dc & n.results.n_spikes_per_burst_mean == n_spikes; 

	all_g = n.results.all_g(use_these,:);

	save('bursting_neurons.mat','all_g')

end


% now compute the calcium as we scale all g

n_models = size(all_g,1);
scale_factor = logspace(-1,.5,202);
all_Ca = NaN(n_models,length(scale_factor));
all_burst_periods = NaN(n_models,length(scale_factor));
all_duty_cycles = NaN(n_models,length(scale_factor));

x = xolotl.examples.BurstingNeuron();
x.t_end = 10e3;

if exist('bursting_neurons_all_Ca.mat','file') == 2
	load('bursting_neurons_all_Ca.mat','all_Ca')
else

	for i = 1:n_models

		corelib.textbar(i,n_models)

		parfor j = 1:length(scale_factor)

			x.reset;
			x.set('*gbar',all_g(i,:)*scale_factor(j));
			x.integrate;
			V = x.integrate;

			all_Ca(i,j) = x.AB.Ca_average;


			metrics = xtools.V2metrics(V,'sampling_rate',1/x.dt);

			all_burst_periods(i,j) = metrics.burst_period;
			all_duty_cycles(i,j) = metrics.duty_cycle_mean;

		end
	end

	save('bursting_neurons_all_Ca.mat','all_Ca')
end


% normalize by target
target_Ca = all_Ca(:,51);
for i = 1:n_models
	all_Ca(i,:) = all_Ca(i,:)/target_Ca(i);
end

