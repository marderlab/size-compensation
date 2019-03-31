addpath('../')

%% Changing size in neurons with finite numbers of channels
% In previous documents, I have considered single compartment models of neurons where the voltage evolves according to:

%%
% $$ C_{m}\frac{dV}{dt}=\sum_{i=1}^{n}\bar{g}_{i}m^{p}h^{q}(E_{i}-V) $$ 
%

%%
% and have noted that this equation does not depend on the size of the neuron, and therefore we can recast size-dependency as dependency on channel densities. However, this reformulation is true only in the limit of very large neurons, where there are effectively infinite numbers of channels, no matter what the channel density. This approximation is invalid when:

%%
% * neurons are small, and thus can only have a small number of channels in them
% * conductance densities are low, which means a small number of channels
% 

%%
% This is important because Chow and White have previously shown that stochasticity in channel gating can lead to qualitatively different behavior when the neuron is small, even when we keep all parameters the same. This is because the ODE shown above is actually a deterministic approximation of a stochastic system with N independent channels. 

%%
% One way to model stochasticity arising from finite numbers of channels is to use the approximate Langevin formulation originally proposed by Fox and Lu. This SDE can be solved using the Euler-Mayurama method 

%%
% $$ x(t+\delta t)=x(t)+\delta t\left[\alpha(1-x)-\beta x \right]+\sqrt{\delta t}\sqrt{\frac{\alpha(1-x)+\beta x}{N}\xi} $$

%%
% where $N$ is the number of channels, $x$ is the gating variable, and $\xi$ is a Gaussian random variable with unit variance, and $\alpha$ and $\beta$ are the forward and reverse reaction rates. 


%% Changing neuron size changes the behavior of a cell
% The first thing I do is to reproduce the original result from Chow and White, for the neuron model we are using (they used the original Hodgkin-Huxley model). In the following figure, we see that a nicely-bursting neuron changes its spiking behaviour as its area and volume are decreased, ultimately being entirely dominated by noise. Note that all parameters of the model (other than size) are fixed, and there are no free parameters governing the amplitude of the additive noise in the Langevin equations -- these are directly computed from the number of channels, which is a pure function of the channel density and size of the neuron. 

x = singleCompartment.makeNeuron();
g0 = [379 165 2.35 .72 297 1713 .46 1370];
x.set('*gbar',g0)


x.stochastic_channels = 1;
x.approx_channels = 0;
x.t_end = 1e4;
x.dt = .1;

if exist('stochastic_channels_changing_size.mat','file') == 2
	load('stochastic_channels_changing_size.mat')
else
	N = 5;
	all_sizes = logspace(-6,-1,30);
	all_f = NaN(length(all_sizes),N);
	all_Ca = NaN(length(all_sizes),N);

	
	for i = 1:N
		corelib.textbar(i,N)
		for j = 1:length(all_sizes)
			x.reset;
			x.AB.A = all_sizes(j);
			x.AB.vol = all_sizes(j);
			V = x.integrate;
			all_f(j,i) = xtools.findNSpikes(V);
			all_Ca(j,i) = x.AB.Ca_average;
		end
	end
	save('stochastic_channels_changing_size.mat','all_sizes','all_f','all_Ca')
end



figure('outerposition',[300 300 1200 800],'PaperUnits','points','PaperSize',[1200 800]); hold on

show_sizes = corelib.logrange(min(all_sizes),max(all_sizes),4);

for i = 1:4
	ax = subplot(4,2,2*(i-1)+1); hold on
	x.reset;
	x.AB.A = show_sizes(i);
	x.AB.vol = show_sizes(i);
	V = x.integrate;
	time = (1:length(V))*1e-3*x.dt;
	plot(time,V,'k')
	set(gca,'YLim',[-90 50],'XLim',[8 10])
	title(['Area = ' strlib.oval(x.AB.A) 'mm^2'])
	axlib.makeEphys(ax,'voltage_position',-90)
end

ax = subplot(2,2,2); hold on
errorbar(all_sizes,mean(all_f,2),corelib.sem(all_f'))
set(gca,'XScale','log','YScale','log')
ylabel(ax,'Firing rate (Hz)')
ax.Position = [.6 .52 .25 .3];


ax = subplot(2,2,4); hold on
errorbar(all_sizes,mean(all_Ca,2),corelib.sem(all_Ca'))
set(gca,'XScale','log','YScale','log')
ylabel(ax,'[Ca^2^+] (uM)')
xlabel(ax,'Size (mm^2)')
ax.Position = [.6 .12 .25 .3];

figlib.pretty('plw',1,'lw',1)



%%
% We are now interested in the case where the cell is not so small that its dynamics is entirely dominated by noise, but where it is small enough that the finite number of channels is possesses causes it to significantly deviate from asymptotic behaviour. We have previously shown that in the deterministic case, the line of constant conductance density is equivalent to the set of models that behave identically, and this set is globally attractive for the slow dynamical system of conductances when we configure regulatory mechanisms. 

%%
% This is clearly not true anymore (since the line of constant density does not correspond to the set of identical voltage dynamics, see previous figure). The question I ask in this section is this: can integral control tune conductances so that it can drive the neuron to the desired activity, no matter that the size is? 


% set it to the biggest size and configure integral controllers
x.set('*gbar',g0)
x.AB.A = show_sizes(end);
x.AB.vol = show_sizes(end);

singleCompartment.configureControllers(x);


x.t_end = 100e3;

all_Ca_error = NaN*all_sizes;
all_gbar = NaN*all_sizes;


if exist('stochastic_channels_integral_control.mat','file') == 2
	load('stochastic_channels_integral_control.mat')

else


	for i = 1:length(all_sizes)
		corelib.textbar(i,length(all_sizes))
		x.AB.A = all_sizes(i);
		x.AB.vol = all_sizes(i);
		x.reset;

		x.set('*gbar',g0/1000)
		x.AB.Leak.gbar = g0(7);


		x.integrate;

		all_Ca_error(i) = x.AB.Ca_average/x.AB.Ca_target;
		all_gbar(i) = mean(x.get('*gbar')./g0(:));

	end
	save('stochastic_channels_integral_control.mat','all_gbar','all_Ca_error')

end


figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(1,2,1); hold on
plot(all_sizes,all_Ca_error,'ko-')
set(gca,'XScale','log','YScale','log')
plotlib.horzline(1);
xlabel('Cell size (mm^2)')
ylabel('<[Ca]>/Ca_{target}')

subplot(1,2,2); hold on
plot(all_sizes,all_gbar,'ko-')
xlabel('Cell size (mm^2)')
ylabel('$<\bar{g}/\bar{g_{0}}>$','interpreter','latex')
set(gca,'XScale','log','YScale','log')
plotlib.horzline(1);

figlib.pretty('plw',1,'lw',1)


%%
% What we see from this figure is that even though integral control seems to be able to compensate for small cells, and can change conductances so that it achieves the target Calcium levels, it does so by massively increasing conductance densities, to the point where conductance densities are unrealistically high. 

%%
% What it is actually doing is matching conductances to the originally configured model, and in doing so also matches the number of channels. However, this means that in small cells this leads to ridiculously high channel densities, which is unrealistic. 