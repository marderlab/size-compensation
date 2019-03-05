% finds a tonically spiking neuron at 10Hz



x = xolotl;
x.add('compartment','AB','A',0.0628,'vol',.0628);
x.AB.add('bucholtz/CalciumMech','phi',1,'tau_Ca',200);

x.AB.add('prinz/NaV','gbar',1e3);
x.AB.add('prinz/CaS','gbar',100);
x.AB.add('prinz/Kd','gbar',500);
x.AB.add('Leak','gbar',.01,'E',-30);



p = xfit;
p.sim_func = @tonicSpikerCost;
p.x = x;
p.parameter_names = {'AB.NaV.gbar','AB.Kd.gbar','AB.CaS.gbar'};
p.lb = [1e3    100   100];
p.ub = [2e3    2e3 1e3];

p.options.UseParallel = true;
p.fit