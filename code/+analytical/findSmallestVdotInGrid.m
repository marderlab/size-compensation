function smallest_v_dot = findSmallestVdotInGrid(g0, x_range, y_range, Ca_zeros, Ca_target, grid_x, grid_y)


all_x = corelib.logrange(x_range(1),x_range(2),grid_x);
all_y = corelib.logrange(y_range(1),y_range(2),grid_y);

Ca_zero_offset =  2*nanmax(Ca_zeros.zero_locs);
lower_branch = Ca_zeros.zero_locs;
upper_branch = -Ca_zeros.zero_locs + Ca_zero_offset;
rm_this = isnan(lower_branch);
lower_branch(rm_this) = [];
upper_branch(rm_this) = [];
Ca_zero_x = Ca_zeros.all_g_Ca(~rm_this);


smallest_v_dot = NaN(length(all_x),length(all_y));

for i = 1:length(all_x)

	% what are the zeros for the Ca eq? 
	V_Ca = [interp1(Ca_zero_x,lower_branch,all_x(i)) interp1(Ca_zero_x,upper_branch,all_x(i))];
	if any(isnan(V_Ca))
		continue
	end


	corelib.textbar(i,length(all_x))

	parfor j = 1:length(all_y)

		g = singleCompartment.perturb.scaleG(g0,all_x(i),all_y(j));

		vdot1 = abs(analytical.VDot(V_Ca(1),Ca_target, g));
		vdot2 = abs(analytical.VDot(V_Ca(2),Ca_target, g));

		smallest_v_dot(i,j) = min([vdot1 vdot2]);


	end
end
