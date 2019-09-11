function C = Cadot(V,g_CaS, g_CaT, Ca_target)


Ca_in = .05;
Ca_out = 3000;
tau_Ca = 200;
f = 14.96;
A = .0628;

% compute E_Ca
RT_by_nF = (0.0431)*(11 + 273.15);
E_Ca = RT_by_nF*log((Ca_out)/(Ca_target));


minf_CaS = @(V) 1.0/(1.0+exp((V+33.0)/-8.1));
hinf_CaS = @(V)1.0/(1.0+exp((V+60.0)/6.2));

minf_CaT = @(V)1.0/(1.0+exp((V+27.1)/-7.2));
hinf_CaT = @(V)1.0/(1.0+exp((V+32.1)/5.5));

i_CaS = g_CaS*(minf_CaS(V)^3)*(hinf_CaS(V))*(V-E_Ca);
i_CaT = g_CaT*(minf_CaT(V)^3)*(hinf_CaT(V))*(V-E_Ca);

i_Ca = i_CaS + i_CaT;

C = (-f*i_Ca*A - Ca_target + Ca_in)/tau_Ca;
