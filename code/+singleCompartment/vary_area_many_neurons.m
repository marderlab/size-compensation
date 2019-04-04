%%
% In this document, we use the neuroDB database
% to pick up a whole lot of neurons, vary their area
% while using stochastic channels, and see how
% dynamics changes with size

addpath('../')

if ~exist('data','var')
	data = Data('/code/neuron-db/prinz/df8371758ecaeeed680f0d2fcf580236.data');
end

all_firing_rates = [2 5 10 20 30];

N = 1e3;
firing_rate_tol = .05;

all_g = [];
all_f = [];

for i = 1:length(all_firing_rates)

	thisf = all_firing_rates(i);

	pick_me = data.firing_rate > thisf*(1-firing_rate_tol) & ...
	  		  data.firing_rate < thisf*(1+firing_rate_tol) & ...
	  		  data.isi_std./data.isi_mean <1e-3;

	pick_me = find(pick_me);

	if length(pick_me) > N
		pick_me = pick_me(1:N);
	end


	all_g = [all_g; data.all_g(pick_me,:)];
	all_f = [all_f; data.firing_rate(pick_me,:)];


end


x = xolotl.examples.BurstingNeuron('prinz');
x.AB.add('Leak');


 x.set('*gbar',data.all_g(pick_me(40),:))