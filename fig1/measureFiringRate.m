


function [R, results] = measureFiringRate(A,g,data)


results = Data();

x = data.x;
x.AB.A = A;
x.AB.vol = A;
x.AB.NaV.gbar = g*(data.g0_NaV/data.g0_HH)/A;
x.AB.Kd.gbar = g*(data.g0_Kd/data.g0_HH)/A;
x.AB.CaS.gbar = g*(data.g0_CaS/data.g0_HH)/A;

x.reset;
x.t_end = 10e3;
x.dt = .1;
x.sim_dt = .05;
x.integrate;

V = x.integrate;


f = xtools.findNSpikes(V)/(x.t_end*1e-3);


if f == 0 
	R = 1;
elseif f < 35
	R = 2;
elseif f < 45
	R = 3;
else
	R = 4;
end