
% measures the surface area and volume of a fractal neuron


function [A,V] = fractalAV(L, min_L, fractal_shrink, atomic)


assert(fractal_shrink<1,'fractal_shrink must be < 1')

this_L = L;

[A, V] = atomic(this_L);

n_branches = 2;

while this_L > min_L


	this_L = fractal_shrink*this_L;

	[~,this_V,this_A] = atomic(this_L);

	A = A + this_A*n_branches;
	V = V + this_V*n_branches;

	n_branches = n_branches*2;



end