% makeNeuron
% makes a single-compartment
% 8 channel neuron with integral controllers


function x = makeNeuron()

prefix = 'prinz/';

% make xolotl object 
A = 0.0628;
channels = {'NaV','CaT','CaS','ACurrent','KCa','Kd','HCurrent'};
E =         [50   30  30 -80 -80 -80   -20];
x = xolotl;
x.add('compartment','AB','Cm',10,'A',A);
% add Calcium mechanism
x.AB.add('prinz/CalciumMech');
for i = 1:length(channels)
	x.AB.add([prefix channels{i}],'gbar',rand*10,'E',E(i));
end
x.AB.add('Leak','gbar',0);


x.AB.add('CalciumSensor');

x.t_end = 20e3;

channels = x.AB.find('conductance');
for i = 1:length(channels)
	x.AB.(channels{i}).add('oleary/IntegralController','tau_g',5e3);
end
