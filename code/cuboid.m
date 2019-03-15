
% implements a cuboid whose long edge is 4 times 
% its short edge, which is a square
% L is the long edge length

function [A,V, A_without_end_cap] = cuboid(L)

A = (L.^2).*(9/8);
V = (L.^3)/16;

A_without_end_cap = (L.^2)*(17/16);