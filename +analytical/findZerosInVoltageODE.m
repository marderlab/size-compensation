

function [zero_locations, stability] = findZerosInVoltageODE(g0,X,Y, Ca_target)




g = singleCompartment.perturb.scaleG(g0,X,Y);

f = @(x) (analytical.VDot(x,Ca_target, g));

% get the approximate positions of the zeros
[zero_locations, stability] = mathlib.findFixedPointsInODE(f, [-80, 50], 1);

