ScriptBenchmarkMixin = {};

function ScriptBenchmarkMixin:OnStart(_iterationCount)
	-- Derive and implement to run any logic before your benchmark has started.
end

function ScriptBenchmarkMixin:OnIterationStart(_iteration, _iterationCount)
	-- Derive and implement to run any logic before an iteration of your benchmark has started.
end

function ScriptBenchmarkMixin:OnIterationFinish(_iteration, _iterationCount, _iterationResults)
	-- Derive and implement to run any logic after an iteration of your benchmark has finished.
end

function ScriptBenchmarkMixin:OnFinish(_iterationCount, _benchmarkResults)
	-- Derive and implement to run any logic after your benchmark has finished.
end

function ScriptBenchmarkMixin:RunIteration(...)
	-- Derive and implement the actual details of your benchmark here.
end

BenchmarkUtil = {};

function BenchmarkUtil.RunBenchmark(benchmark, iterationCount, ...)
	local benchmarkResults = table.create(iterationCount);

	benchmark:OnStart(iterationCount);

	for iteration = 1, iterationCount do
		benchmark:OnIterationStart(iteration, iterationCount);
		local iterationResults = C_AddOnProfiler.MeasureCall(benchmark.RunIteration, benchmark, ...);
		benchmark:OnIterationFinish(iteration, iterationCount, iterationResults);
		benchmarkResults[iteration] = iterationResults;
	end

	benchmark:OnFinish(iterationCount, benchmarkResults);
	return benchmarkResults;
end

function BenchmarkUtil.SummarizeResults(benchmarkResults)
	local summary = {};
	summary.results = benchmarkResults;
	summary.iterationCount = #benchmarkResults;

	for column, samples in pairs(BenchmarkUtil.TransposeResults(benchmarkResults)) do
		summary[column] = BenchmarkUtil.CalculateStatistics(samples);
	end

	return summary;
end

function BenchmarkUtil.TransposeResults(benchmarkResults)
	local columns = { "elapsedMilliseconds", "elapsedTicks", "allocatedBytes", "deallocatedBytes" };
	local data = {};

	for _, column in ipairs(columns) do
		data[column] = {};
	end

	for iteration = 1, #benchmarkResults do
		local iterationResults = benchmarkResults[iteration];

		for column, samples in pairs(data) do
			samples[iteration] = iterationResults[column];
		end
	end

	return data;
end

function BenchmarkUtil.CalculateMinMaxMean(samples)
	local min = math.huge;
	local max = -math.huge;
	local sum = 0;
	local count = #samples;

	if count <= 0 then
		return 0, 0, 0;
	end

	for i = 1, count do
		local v = samples[i];
		min = math.min(min, v);
		max = math.max(max, v);
		sum = sum + v;
	end

	local mean = sum / count;
	return min, max, mean;
end

function BenchmarkUtil.CalculateStandardDeviation(samples, mean)
	local variance = 0;
	local count = #samples;

	if count <= 1 then
		return 0;
	end

	for i = 1, count do
		local v = samples[i];
		variance = variance + ((v - mean)^2);
	end

	return math.sqrt(variance / (count - 1));
end

function BenchmarkUtil.CalculateConfidenceInterval(standardDeviation, sampleCount)
	-- 1.96 here represents the 97.5th percentile point (95% confidence interval).
	return sampleCount > 0 and (1.96 * (standardDeviation / math.sqrt(sampleCount))) or 0;
end

function BenchmarkUtil.CalculateStatistics(samples)
	local stats = {};
	stats.samples = samples;
	stats.sampleCount = #samples;
	stats.min, stats.max, stats.mean = BenchmarkUtil.CalculateMinMaxMean(samples);
	stats.standardDeviation = BenchmarkUtil.CalculateStandardDeviation(samples, stats.mean);
	stats.confidenceInterval = BenchmarkUtil.CalculateConfidenceInterval(stats.standardDeviation, stats.sampleCount);
	return stats;
end
