

function [X,Y] = findSilentSolutionsAnalytically(g)



% make a neuron model

x = singleCompartment.makeNeuron();
x.set('*gbar',g);

singleCompartment.configureControllers(x)

x0 = sum(g(2:3));
y0 = sum(g([1 4 5 6 8]));



Ca_target = x.AB.Ca_target;

% calculate iCa

I_Ca = (-Ca_target + x.AB.CalciumMech1.Ca_in)/x.AB.CalciumMech1.f;

% compute E_Ca
RT_by_nF = (0.0431)*(11 + 273.15);
E_Ca = RT_by_nF*log((x.AB.Ca_out)/(Ca_target));


% get gsting functions for every channels
channels = x.AB.find('conductance');
p = [3 3 3 1 4 4 1 3];
q = [1 1 1 0 0 0 0 1];
E = [-80 E_Ca E_Ca -20 -80 -80 -50 50];
clear m h
for i = setdiff(1:8,7)
	[m{i}, h{i}] = x.getGatingFunctions(['prinz/' channels{i}]);
	if nargin(h{i}) == 1
		h{i} = @(V,Ca) 1;
	end
end
m{7} = @(V,Ca) 1;
h{7} = @(V,Ca) 1;


% find where window currents are possible
% we will only look for solutions here
all_V = linspace(-100,100,100);
CaS_w = NaN*all_V;
CaT_w = NaN*all_V;
for i = 1:length(all_V)
	CaS_w(i) = (m{2}(all_V(i),Ca_target)^p(2))*(h{2}(all_V(i),Ca_target));
	CaT_w(i) = (m{3}(all_V(i),Ca_target)^p(3))*(h{3}(all_V(i),Ca_target));
end
M = max([CaT_w CaS_w]);
CaS_w = CaS_w/M;
CaT_w = CaT_w/M;
C = CaS_w + CaT_w; C = C/max(C);
min_V = all_V(find(C>1e-2,1,'first'));
max_V = all_V(find(C>1e-2,1,'last'));
all_V = linspace(min_V,max_V,100);


% find the location along the x-axis where
% we start seeing zeros in the Cadot equation 
x_range = [x0/100 x0*10];

x_min = x_range(1);
x_max = x_range(2);


this_x = x_min;

for i = 1:10
	this_g = singleCompartment.perturb.scaleG(g,this_x,y0);

	E_Ca_eq = 0*all_V - I_Ca;

	for k = 1:length(all_V)

		V = all_V(k);

		% also compute the error on the calcium current eq
		for l = 2:3
			E_Ca_eq(k) = E_Ca_eq(k) + this_g(l)*((m{l}(V,Ca_target))^p(l))*(h{l}(V,Ca_target)^q(l))*(V - E_Ca)*x.AB.A;
		end
	end

	nzeros = length(computeOnsOffs(E_Ca_eq>0));

	this_x = (x_min + x_max)/2;
	if nzeros == 0
		x_min = this_x;
	else
		x_max = this_x;
	end

end

min_x_Ca = this_x;




% now discretize y and find the x at 
% each value for y
min_y = y0/100;
max_y = y0*10;
all_y = logspace(log10(min_y),log10(max_y),10);

x_sol = NaN*min_y;


for i = 1:length(all_y)
	disp(i)

	% nested search on x

	x_min = min_x_Ca;
	x_max = x_range(2);

	for j = 1:5

		all_x = logspace(log10(x_min),log10(x_max),10);
		min_dist = NaN*(all_x);

		smallest_delta_V = Inf;
		best_x = NaN;

		for k = 1:length(all_x)

			this_x = all_x(k);
			this_g = singleCompartment.perturb.scaleG(g,this_x,all_y(i));

			E_Ca_eq = 0*all_V - I_Ca;
			E_V_eq = 0*all_V;

			
			parfor kk = 1:length(all_V)

				V = all_V(kk);
				% compute Vdot here
				for l = 1:8
					E_V_eq(kk) = E_V_eq(kk) + this_g(l)*((m{l}(V,Ca_target))^p(l))*(h{l}(V,Ca_target)^q(l))*(V - E(l));
				end

				% also compute the error on the calcium current eq
				for l = 2:3
					E_Ca_eq(kk) = E_Ca_eq(kk) + this_g(l)*((m{l}(V,Ca_target))^p(l))*(h{l}(V,Ca_target)^q(l))*(V - E_Ca)*x.AB.A;
				end


			end

			% find the smallest distance b/w Vdot and Cadot
			V_Ca = all_V(find(abs(diff(E_Ca_eq>0))));
			V_V = all_V(find(abs(diff(E_V_eq>0))));
			this_delta_V = min(pdist2(V_V(:),V_Ca(:)));

			if smallest_delta_V > this_delta_V
				smallest_delta_V = this_delta_V;
				best_x = this_x;
			end


		end % loop over all_x

		x_min = (x_min + best_x)/2;
		x_max = (x_max + best_x)/2;

	end % j loop, N refinements
	x_sol(i) = best_x;

end % loop over all_y


keyboard