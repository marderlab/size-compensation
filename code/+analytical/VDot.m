function Vd = Vdot(V, Ca, g);


Ca_in = .05;
Ca_out = 3000;
tau_Ca = 200;
f = 14.96;
A = .0628;

% compute E_Ca
RT_by_nF = (0.0431)*(11 + 273.15);
E_Ca = RT_by_nF*log((Ca_out)/(Ca));

p = [3 3 3 1 4 4 1 3];
q = [1 1 1 0 0 0 0 1];
E = [-80 E_Ca E_Ca -20 -80 -80 -50 50];

hinf = { @(V,Ca)1.0/(1.0+exp((V+56.9)/4.9));
     @(V,Ca)1.0/(1.0+exp((V+60.0)/6.2));
     @(V,Ca)1.0/(1.0+exp((V+32.1)/5.5));
                                @(V, Ca) 1;
                                @(V, Ca) 1;
                                @(V, Ca) 1;
                                @(V, Ca) 1;
    @(V,Ca)1.0/(1.0+exp((V+48.9)/5.18))};




minf =            {@(V,Ca)1.0/(1.0+exp((V+27.2)/-8.7));
           @(V,Ca)1.0/(1.0+exp((V+33.0)/-8.1));
           @(V,Ca)1.0/(1.0+exp((V+27.1)/-7.2));
            @(V,Ca)1.0/(1.0+exp((V+75.0)/5.5));
@(V,Ca)(Ca/(Ca+3.0))/(1.0+exp((V+28.3)/-12.6));
          @(V,Ca)1.0/(1.0+exp((V+12.3)/-11.8));
                                       @(V, Ca) 1;
         @(V,Ca)1.0/(1.0+exp((V+25.5)/-5.29))};


I = zeros(8,1);
for i = 1:8

    I(i) = g(i)*(minf{i}(V,Ca))^p(i);
    I(i) = I(i)*(hinf{i}(V,Ca))^q(i);
    I(i) = I(i)*(V-E(i));
end

Vd = (sum(I));