classdef perturb

	methods (Static)

		status = analyzeWithoutControl(x);
		status = analyzeWithControl(x);

		v = configureVoronoiSegment(data, x0, y0);

		segmentAndSave(v, x0, y0, save_name);


		% this function is meant to be called by voronoiSegment
		varargout = measureMetrics(sigma_Ca, sigma_others, data);


		% dense sampling in a grid
		status = denseSampleWithoutControl(x)


		status = findCalciumNullcline(x)

		[R, results] =  measureCalcium(sigma_Ca, sigma_others, data)


		% test function for similar neurons
		status = similarNeuronTestFunc(x);


		% deletes channels one by one and measures
		% metrics
		status = deleteChannels(x)


		g = scaleG(g0,sigma_Ca,sigma_others)

		% helper functions
		alldata = consolidateCalciumNullclines(allfiles)
		alldata = consolidatePerturbationMaps(allfiles)


		% analytically compute line
		% of silent neurons
		[X,Y] = findSilentSolutionsAnalytically(g);

	end



end % end classdef 

