% this function is meant to consolidate all
% the voronoi diagrams where we compute
% the calcium nullclines in a single compartment
% model with no integral control
% so we can plot them all together

function alldata = consolidateCalciumNullclines(allfiles)


h = hashlib.md5hash([allfiles.name]);

% check if hashed dump exists
if exist([allfiles(1).folder filesep  h '_consolidated.calcium_nullclines'],'file') == 2
	load([allfiles(1).folder filesep  h '_consolidated.calcium_nullclines'],'alldata','-mat')
	return
end

alldata = struct;
alldata.x = NaN;
alldata.y = NaN;
alldata.firing_rate = NaN;
alldata.isi_mean = NaN;
alldata.min_V_mean = NaN;
alldata.isi_std = NaN;
alldata.spike_peak_mean = NaN;
alldata.spike_peak_std = NaN;
alldata.x0 = NaN;
alldata.y0 = NaN;

v = struct;

for i = length(allfiles):-1:1

	disp(i)

	load([allfiles(i).folder filesep allfiles(i).name],'v','-mat')


	x0 = sum(v.data.g0(2:3));
	y0 = sum(v.data.g0([1 4 5 6 8]));

	alldata(i).x = v.boundaries(1).regions(1).x/x0;
	alldata(i).y = v.boundaries(1).regions(1).y/y0;


	alldata(i).x0 = x0;
	alldata(i).y0 = y0;

	alldata(i).firing_rate = v.data.metrics_base.firing_rate;
	alldata(i).isi_mean = v.data.metrics_base.isi_mean;
	alldata(i).isi_std = v.data.metrics_base.isi_std;
	alldata(i).min_V_mean = v.data.metrics_base.min_V_mean;
	alldata(i).spike_peak_mean = v.data.metrics_base.spike_peak_mean;
	alldata(i).spike_peak_std = v.data.metrics_base.spike_peak_std;


end

% save
save([allfiles(1).folder filesep  h '_consolidated.calcium_nullclines'],'alldata','-v7.3')