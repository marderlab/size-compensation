% classifies the metrics of a model
% and compares it to a baseline metrics
%
% output code:
% 1 --- silent
% 2 --- Spiker
% 3 --- Canonical Burster
% 4 --- Other

function R = classifyMetrics(metrics_base,metrics)


if isnan(metrics_base.burst_period)
	% base model is spiker
	if metrics.firing_rate == 0
		R = 1;
		return
	else
		% not silent
		if abs(metrics_base.firing_rate - metrics.firing_rate)/metrics_base.firing_rate < .1
			R = 2;
			return
		else
			% not a regular spiker -- some sort of burster
			R = 4;
			return
		end
	end



else
	% base model is a burster
	if metrics.firing_rate == 0
		R = 1;
		return
	else
		% some sort of non-silent cell
		if (metrics.isi_std/metrics.isi_mean) < .1
			% regular spiker
			R = 2;
			return
		else
			% some sort of burster
			if abs(metrics_base.burst_period - metrics.burst_period)/metrics_base.burst_period < .2 && abs(metrics_base.duty_cycle_mean - metrics.duty_cycle_mean)/metrics_base.duty_cycle_mean < .2
				R = 3;
				return
			else
				R = 4;
				return
			end

		end

	end

end