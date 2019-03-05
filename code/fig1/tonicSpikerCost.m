function C = tonicSpikerCost(x,~)



x.reset;
x.closed_loop = true;
x.integrate;
[V,Ca] = x.integrate;

m = xtools.V2metrics(V);


% firing rate cost
C = 100*xfit.binCost([4 20],m.firing_rate);

% calcium cost
C =  C + 100*xfit.binCost([.9 10],mean(Ca(:,1))/.2);

C = C + 10*xfit.binCost([0 .1],m.isi_std/m.isi_mean);

if isnan(C)
	C = 1e4;
end