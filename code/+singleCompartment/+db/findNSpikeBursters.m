% finds a bunch of bursting neurons with similar
% voltage dynamics using the neuron-db
% project

function all_show_these = findNSpikeBursters(n)


n_spikes_per_burst = 3:15;



T_bins = 500:100:2e3;
DC_bins = .05:.01:.3;

all_show_these = [];
for i = 1:length(n_spikes_per_burst)




	show_these = find(n.results.burst_period_std./n.results.burst_period < .01 ...
	            & n.results.duty_cycle_std./n.results.duty_cycle_mean < .01 ...
	            & n.results.n_spikes_per_burst_mean == n_spikes_per_burst(i) ...
	            & n.results.n_spikes_per_burst_std == 0 ...
	            & n.results.min_V_in_burst_mean > n.results.min_V_mean ...
	            & n.results.spike_peak_std < 1 ...
	            & n.results.min_V_mean < -60);  


	% use the maximum of this distribution
	H = histcounts2(n.results.burst_period(show_these),n.results.duty_cycle_mean(show_these),T_bins,DC_bins);

	[x,y] = find(H == max(H(:)));

	x = x(1);
	y = y(1);

	only_these = (n.results.burst_period(show_these) > T_bins(x)-50 ...
				& n.results.burst_period(show_these) < T_bins(x)+50 ...
				& n.results.duty_cycle_mean(show_these) > DC_bins(y)-.005...
				& n.results.duty_cycle_mean(show_these) < DC_bins(y)+.005);



	show_these = show_these(only_these);

	if length(show_these) < 300
		continue
	end

	show_these = show_these(1:300);


	all_show_these = [all_show_these; show_these];



end


