SECONDS_PER_MIN = 60;
SECONDS_PER_HOUR = 3600;
SECONDS_PER_DAY = 86400;

function SecondsToMinutes(seconds)
	return seconds / SECONDS_PER_MIN;
end

function MinutesToSeconds(minutes)
	return minutes * SECONDS_PER_MIN;
end

SecondsFormatter = {};
SecondsFormatter.Abbreviation = 
{
	None = 1, -- seconds, minutes, hours...
	Truncate = 2, -- sec, min, hr...
	OneLetter = 3, -- s, m, h...
}

SecondsFormatter.Interval = {
	Seconds = 1,
	Minutes = 2,
	Hours = 3,
	Days = 4,
}

SecondsFormatter.IntervalDescription = {
	[SecondsFormatter.Interval.Seconds] = {seconds = 1, formatString = { D_SECONDS, SECONDS_ABBR, SECOND_ONELETTER_ABBR}},
	[SecondsFormatter.Interval.Minutes] = {seconds = SECONDS_PER_MIN, formatString = {D_MINUTES, MINUTES_ABBR, MINUTE_ONELETTER_ABBR}},
	[SecondsFormatter.Interval.Hours] = {seconds = SECONDS_PER_HOUR, formatString = {D_HOURS, HOURS_ABBR, HOUR_ONELETTER_ABBR}},
	[SecondsFormatter.Interval.Days] = {seconds = SECONDS_PER_DAY, formatString = {D_DAYS, DAYS_ABBR, DAY_ONELETTER_ABBR}},
}

--[[ Seconds formatter to standardize representations of seconds. When adding a new formatter
please consider if a prexisting formatter suits your needs, otherwise, before adding a new formatter,
consider adding it to a file appropriate to it's intended use. For example, "WorldQuestsSecondsFormatter"
could be added to QuestUtil.h so it's immediately apparent the scenarios the formatter is appropriate.]]

SecondsFormatterMixin = {}
-- defaultAbbreviation: the default abbreviation for the format. Can be overrridden in SecondsFormatterMixin:Format()
-- approximationSeconds: threshold for representing the seconds as an approximation (ex. "< 2 hours").
-- roundUpLastUnit: determines if the last unit in the output format string is ceiled (floored by default).
function SecondsFormatterMixin:OnLoad(approximationSeconds, defaultAbbreviation, roundUpLastUnit)
	self.approximationSeconds = approximationSeconds or 0;
	self.defaultAbbreviation = defaultAbbreviation or SecondsFormatter.Abbreviation.None;
	self.roundUpLastUnit = roundUpLastUnit or false;
end

function SecondsFormatterMixin:GetMaxInterval()
	return #SecondsFormatter.IntervalDescription;
end

function SecondsFormatterMixin:GetIntervalDescription(interval)
	return SecondsFormatter.IntervalDescription[interval];
end

function SecondsFormatterMixin:GetIntervalSeconds(interval)
	local intervalDescription = self:GetIntervalDescription(interval);
	return intervalDescription and intervalDescription.seconds or nil;
end

function SecondsFormatterMixin:CanApproximate(seconds)
	return (seconds > 0 and seconds < self:GetApproximationSeconds());
end

function SecondsFormatterMixin:GetDefaultAbbreviation()
	return self.defaultAbbreviation;
end

function SecondsFormatterMixin:GetApproximationSeconds()
	return self.approximationSeconds;
end

function SecondsFormatterMixin:CanRoundUpLastUnit()
	return self.roundUpLastUnit;
end

--Derive
-- Returns the desired number of units to append to the format string.
function SecondsFormatterMixin:GetDesiredUnitCount(seconds)
	assert(false, "Implement GetDesiredUnitCount() in derived object.")
end

--Derive
-- Returns the smallest interval to be displayed in the format string.
function SecondsFormatterMixin:GetMinInterval(seconds)
	assert(false, "Implement GetMinInterval() in derived object.");
end

function SecondsFormatterMixin:GetFormatString(interval, abbreviation)
	local intervalDescription = self:GetIntervalDescription(interval);
	return intervalDescription.formatString[abbreviation];
end

function SecondsFormatterMixin:FormatZero(abbreviation)
	local minInterval = self:GetMinInterval(seconds);
	local formatString = self:GetFormatString(minInterval, abbreviation);
	return formatString:format(0);
end

function SecondsFormatterMixin:Format(seconds, abbreviation)
	if (seconds == nil) then
		return "";
	end

	seconds = math.ceil(seconds);
	abbreviation = abbreviation or self:GetDefaultAbbreviation();

	if (seconds <= 0) then
		return self:FormatZero(abbreviation);
	end

	local minInterval = self:GetMinInterval(seconds);
	local maxInterval = self:GetMaxInterval();

	if (self:CanApproximate(seconds)) then
		local interval = math.max(minInterval, SecondsFormatter.Interval.Minutes);
		while (interval < maxInterval) do
			local nextInterval = interval + 1; 
			if (seconds > self:GetIntervalSeconds(nextInterval)) then
				interval = nextInterval;
			else
				break;
			end
		end

		local formatString = self:GetFormatString(interval, abbreviation);
		local unit = formatString:format(math.ceil(seconds / self:GetIntervalSeconds(interval)));
		return string.format(LESS_THAN_OPERAND, unit);
	end
	
	local output = "";
	local appendedCount = 0;
	local desiredCount = self:GetDesiredUnitCount(seconds);

	local currentInterval = maxInterval;
	while ((appendedCount < desiredCount) and (currentInterval >= minInterval)) do
		local intervalDescription = self:GetIntervalDescription(currentInterval);
		local intervalSeconds = intervalDescription.seconds;
		if (seconds >= intervalSeconds) then
			appendedCount = appendedCount + 1;
			if (output ~= "") then
				output = output..TIME_UNIT_DELIMITER;
			end

			local formatString = self:GetFormatString(currentInterval, abbreviation);
			local quotient = seconds / intervalSeconds;
			if (quotient > 0) then
				if (self:CanRoundUpLastUnit() and ((minInterval == currentInterval) or (appendedCount == desiredCount))) then
					output = output..formatString:format(math.ceil(quotient));
				else
					output = output..formatString:format(math.floor(quotient));
				end
			else
				break;
			end

			seconds = math.fmod(seconds, intervalSeconds);
		end

		currentInterval = currentInterval - 1;
	end

	-- Return the 0 format if an acceptable representation couldn't be formed.
	if (output == "") then
		return self:FormatZero(abbreviation);
	end

	return output;
end

---[[
-- console: script print(SampleSecondsFormatter:Format(500));
-- output: "20 Hr"
--SampleSecondsFormatter
--SampleSecondsFormatter = CreateFromMixins(SecondsFormatterMixin);
--SampleSecondsFormatter:OnLoad(SECONDS_PER_MIN * 10, SecondsFormatter.Abbreviation.Truncate, true);
--function SampleSecondsFormatter:GetDesiredUnitCount(seconds)
--	return seconds > SECONDS_PER_DAY and 2 or 1;
--end
--
--function SampleSecondsFormatter:GetMinInterval(seconds)
--	return SecondsFormatter.Interval.Seconds;
--end
---]]