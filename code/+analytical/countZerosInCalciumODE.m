% counts the # of zeros in the calcium ODE in a single 
% compartment model

function [n_zeros, zero_locations] = countZerosInCalciumODE(g0,X,Ca_target)

% calculate the gbars
g = singleCompartment.perturb.scaleG(g0,X,X);


F = @(V) analytical.Cadot(V, g(2), g(3), Ca_target);



all_v = linspace(-80,50,1e4);
all_cadot = NaN*all_v;
for i = 1:length(all_v)
	all_cadot(i) = F(all_v(i));
end

zero_locations = all_v(find(diff(all_cadot>0)));
n_zeros = length(zero_locations);
