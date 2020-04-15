


function [Ca, firing_rate, A, g, isis] = measureCalcium(x)


g = x.get('*gbar')*x.AB.A;
A = x.AB.A;

x.closed_loop = true;

x.t_end = 10e3;
x.dt = .1;
x.sim_dt = .05;

% need to set the volume to the same as the area
x.AB.vol = A;

if x.stochastic_channels == 0


	x.reset;
	x.integrate;

	V = x.integrate;


	firing_rate = xtools.findNSpikes(V)/(x.t_end*1e-3);
	Ca = x.AB.Ca_average;

	isis = diff(xtools.findNSpikeTimes(V,xtools.findNSpikes(V))*1e-3*x.dt);

	return

end

% now we're doing if stochastic_channels == 1
disp('stochastic channels...')
N = 10;

all_Ca = NaN(N,1);
all_Ca_std = NaN(N,1);

all_firing_rate = NaN(N,1);
all_isis = [];

for i = 1:N

	disp(i)

	x.reset;
	x.integrate;
	[V, Ca] = x.integrate;

	all_firing_rate(i) = xtools.findNSpikes(V)/(x.t_end*1e-3);
	all_Ca(i) = x.AB.Ca_average;

	all_Ca_std(i) = std(Ca(:,1));


	this_isis = diff(xtools.findNSpikeTimes(V,xtools.findNSpikes(V))*1e-3*x.dt);
	all_isis = [all_isis; this_isis];

end


Ca = [nanmean(all_Ca); nanmean(all_Ca_std)];

firing_rate = [nanmean(all_firing_rate); nanstd(all_firing_rate)];


isis = [nanmean(all_isis); nanstd(all_isis)];


disp('DONE')
disp('Mean ISI = ')
disp(mean(all_isis))

disp('std ISI = ')
disp(std(all_isis))