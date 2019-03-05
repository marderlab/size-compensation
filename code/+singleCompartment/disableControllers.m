% turn off all integral controllers

function disableControllers(x)


x.set('*Controller.tau_g',Inf)
x.set('*Controller.tau_m',Inf)
x.set('*Controller.m',0)

comps = x.find('compartment');

for i = 1:length(comps)
	x.(comps{i}).Ca_target = NaN;
end