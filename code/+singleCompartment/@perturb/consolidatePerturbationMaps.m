% this function is meant to consolidate all
% the voronoi diagrams where we compute
% the calcium nullclines in a single compartment
% model with no integral control
% so we can plot them all together

function alldata = consolidatePerturbationMaps(allfiles)


h = GetMD5([allfiles.name]);

% check if hashed dump exists
if exist([allfiles(1).folder filesep h '_consolidated.perturbation_map'],'file') == 2
	load([allfiles(1).folder filesep h '_consolidated.perturbation_map'],'alldata','-mat')
	return
end

all_maps = struct;


for i = length(allfiles):-1:1

	disp(i)

	clear v
	load([allfiles(i).folder filesep allfiles(i).name],'v','-mat')


	x0 = sum(v.data.g0(2:3));
	y0 = sum(v.data.g0([1 4 5 6 8]));


	% normalize all boundaries
	for j = 1:length(v.boundaries)
		for k = 1:length(v.boundaries(j).regions)
			v.boundaries(j).regions(k).x = (v.boundaries(j).regions(k).x)/x0;
			v.boundaries(j).regions(k).y = (v.boundaries(j).regions(k).y)/y0;
		end
	end

	all_maps(i).boundaries = v.boundaries;

end

% build an average map
N = 1e2;
all_x = logspace(-2,1,N);
all_y = logspace(-2,1,N);

[all_x, all_y] = meshgrid(all_x,all_y);
all_x = all_x(:);
all_y = all_y(:);

p_silent = 0*all_x;
p_canonical = 0*all_x;
p_spiking = 0*all_x;
p_other = 0*all_x;


for k = 1:length(all_maps)

	textbar(k,length(all_maps))

	% is this point in any silent region?
	for m = 1:length(all_maps(k).boundaries(1).regions)
		p_silent = p_silent + inpolygon(all_x,all_y,all_maps(k).boundaries(1).regions(m).x,all_maps(k).boundaries(1).regions(m).y);
	end

	% is this point in any spiker region?
	for m = 1:length(all_maps(k).boundaries(2).regions)
		p_spiking = p_spiking + inpolygon(all_x,all_y,all_maps(k).boundaries(2).regions(m).x,all_maps(k).boundaries(2).regions(m).y);
	end

	% is this point in any canonical region?
	for m = 1:length(all_maps(k).boundaries(3).regions)
		p_canonical = p_canonical + inpolygon(all_x,all_y,all_maps(k).boundaries(3).regions(m).x,all_maps(k).boundaries(3).regions(m).y);
	end


	% is this point in any other region?
	for m = 1:length(all_maps(k).boundaries(4).regions)
		p_other = p_other + inpolygon(all_x,all_y,all_maps(k).boundaries(4).regions(m).x,all_maps(k).boundaries(4).regions(m).y);
	end

end




% normalize
alldata = struct;
alldata.p_canonical = p_canonical/length(all_maps);
alldata.p_other = p_other/length(all_maps);
alldata.p_silent = p_silent/length(all_maps);
alldata.p_spiking = p_spiking/length(all_maps);

alldata.all_maps = all_maps;
alldata.all_x = all_x;
alldata.all_y = all_y;

% save
save([allfiles(1).folder filesep  h '_consolidated.perturbation_map'],'alldata')