
function g = scaleG(g0,sigma_Ca,sigma_others, gbar_x, gbar_y)


if nargin == 3
	gbar_x = [2 3];
	gbar_y = [1 4 5 6 8];
end

g0(gbar_x) = g0(gbar_x)/sum(g0(gbar_x));
g0(gbar_y) = g0(gbar_y)/sum(g0(gbar_y));
g(gbar_x) = g0(gbar_x)*sigma_Ca;
g(gbar_y) = g0(gbar_y)*sigma_others;
g(7) = g0(7);
