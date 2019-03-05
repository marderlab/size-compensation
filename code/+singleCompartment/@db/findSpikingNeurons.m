% this function uses the neuroDb
% to find a whole set of spiking neurons
% where they have tightly tuned firing rates
% at various firing rates. 
% for each firing rate group, it makes
% sure there are 300 models 

function all_show_these = findSpikingNeurons(n)


firing_rate_means = 25:5:100;
firing_rate_tolerance = .5; % Hz


all_show_these = [];
for i = 1:length(firing_rate_means)

	fa = firing_rate_means(i) - firing_rate_tolerance;
	fz = firing_rate_means(i) + firing_rate_tolerance;

	show_these = find(n.results.isi_std./n.results.isi_mean < .01...
				& n.results.firing_rate > fa ...
				& n.results.firing_rate < fz); 

	if length(show_these) < 300
		continue
	end

	all_show_these = [all_show_these; show_these(1:300)];

end
