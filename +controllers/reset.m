% resets all conductances in a model

function reset(x, g)

if nargin == 1
	g = 0;
end


gL = x.AB.Leak.gbar;

x.set('*gbar',g);
x.set('*Controller.m',g*x.AB.A);

x.AB.Leak.gbar = gL;