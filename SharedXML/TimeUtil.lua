-- Set to false in some locale specific files.
TIME_UTIL_WHITE_SPACE_STRIPPABLE = true;

SECONDS_PER_MIN = 60;
SECONDS_PER_HOUR = 60 * SECONDS_PER_MIN;
SECONDS_PER_DAY = 24 * SECONDS_PER_HOUR;
SECONDS_PER_MONTH = 30 * SECONDS_PER_DAY;
SECONDS_PER_YEAR = 12 * SECONDS_PER_MONTH;

function SecondsToMinutes(seconds)
	return seconds / SECONDS_PER_MIN;
end

function MinutesToSeconds(minutes)
	return minutes * SECONDS_PER_MIN;
end

function HasTimePassed(testTime, amountOfTime)
	return ((time() - testTime) >= amountOfTime);
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
-- convertToLower: converts the format string to lowercase.
function SecondsFormatterMixin:Init(approximationSeconds, defaultAbbreviation, roundUpLastUnit, convertToLower)
	self.approximationSeconds = approximationSeconds or 0;
	self.defaultAbbreviation = defaultAbbreviation or SecondsFormatter.Abbreviation.None;
	self.roundUpLastUnit = roundUpLastUnit or false;
	self.stripIntervalWhitespace = false;
	self.convertToLower = convertToLower or false;
end

function SecondsFormatterMixin:SetStripIntervalWhitespace(strip)
	self.stripIntervalWhitespace = strip;
end

function SecondsFormatterMixin:GetStripIntervalWhitespace()
	return self.stripIntervalWhitespace;
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

function SecondsFormatterMixin:GetDesiredUnitCount(seconds)
	return 2;
end

function SecondsFormatterMixin:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Seconds;
end

function SecondsFormatterMixin:GetFormatString(interval, abbreviation, convertToLower)
	local intervalDescription = self:GetIntervalDescription(interval);
	local formatString = intervalDescription.formatString[abbreviation];
	if convertToLower then
		formatString = formatString:lower();
	end
	local strip = TIME_UTIL_WHITE_SPACE_STRIPPABLE and self:GetStripIntervalWhitespace();
	return strip and formatString:gsub(" ", "") or formatString;
end

function SecondsFormatterMixin:FormatZero(abbreviation, toLower)
	local minInterval = self:GetMinInterval(seconds);
	local formatString = self:GetFormatString(minInterval, abbreviation);
	return formatString:format(0);
end

function SecondsFormatterMixin:FormatMillseconds(millseconds, abbreviation)
	return self:Format(millseconds/1000, abbreviation);
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

		local formatString = self:GetFormatString(interval, abbreviation, self.convertToLower);
		local unit = formatString:format(math.ceil(seconds / self:GetIntervalSeconds(interval)));
		return string.format(LESS_THAN_OPERAND, unit);
	end
	
	local output = "";
	local appendedCount = 0;
	local desiredCount = self:GetDesiredUnitCount(seconds);
	local convertToLower = self.convertToLower;

	local currentInterval = maxInterval;
	while ((appendedCount < desiredCount) and (currentInterval >= minInterval)) do
		local intervalDescription = self:GetIntervalDescription(currentInterval);
		local intervalSeconds = intervalDescription.seconds;
		if (seconds >= intervalSeconds) then
			appendedCount = appendedCount + 1;
			if (output ~= "") then
				output = output..TIME_UNIT_DELIMITER;
			end

			local formatString = self:GetFormatString(currentInterval, abbreviation, convertToLower);
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

	-- Return the zero format if an acceptable representation couldn't be formed.
	if (output == "") then
		return self:FormatZero(abbreviation);
	end

	return output;
end

function ConvertSecondsToUnits(timestamp)
	timestamp = math.max(timestamp, 0);
	local days = math.floor(timestamp / SECONDS_PER_DAY);
	timestamp = timestamp - (days * SECONDS_PER_DAY);
	local hours = math.floor(timestamp / SECONDS_PER_HOUR);
	timestamp = timestamp - (hours * SECONDS_PER_HOUR);
	local minutes = math.floor(timestamp / SECONDS_PER_MIN);
	timestamp = timestamp - (minutes * SECONDS_PER_MIN);
	local seconds = math.floor(timestamp);
	local milliseconds = timestamp - seconds;
	return {
		days=days,
		hours=hours,
		minutes=minutes,
		seconds=seconds,
		milliseconds=milliseconds,
	}
end

function SecondsToClock(seconds, displayZeroHours)
	local units = ConvertSecondsToUnits(seconds);
	if units.hours > 0 or displayZeroHours then
		return format(HOURS_MINUTES_SECONDS, units.hours, units.minutes, units.seconds);
	else
		return format(MINUTES_SECONDS, units.minutes, units.seconds);
	end
end

function SecondsToTime(seconds, noSeconds, notAbbreviated, maxCount, roundUp)
	local time = "";
	local count = 0;
	local tempTime;
	seconds = roundUp and ceil(seconds) or floor(seconds);
	maxCount = maxCount or 2;
	if ( seconds >= 86400  ) then
		count = count + 1;
		if ( count == maxCount and roundUp ) then
			tempTime = ceil(seconds / 86400);
		else
			tempTime = floor(seconds / 86400);
		end
		if ( notAbbreviated ) then
			time = D_DAYS:format(tempTime);
		else
			time = DAYS_ABBR:format(tempTime);
		end
		seconds = mod(seconds, 86400);
	end
	if ( count < maxCount and seconds >= 3600  ) then
		count = count + 1;
		if ( time ~= "" ) then
			time = time..TIME_UNIT_DELIMITER;
		end
		if ( count == maxCount and roundUp ) then
			tempTime = ceil(seconds / 3600);
		else
			tempTime = floor(seconds / 3600);
		end
		if ( notAbbreviated ) then
			time = time..D_HOURS:format(tempTime);
		else
			time = time..HOURS_ABBR:format(tempTime);
		end
		seconds = mod(seconds, 3600);
	end
	if ( count < maxCount and seconds >= 60  ) then
		count = count + 1;
		if ( time ~= "" ) then
			time = time..TIME_UNIT_DELIMITER;
		end
		if ( count == maxCount and roundUp ) then
			tempTime = ceil(seconds / 60);
		else
			tempTime = floor(seconds / 60);
		end
		if ( notAbbreviated ) then
			time = time..D_MINUTES:format(tempTime);
		else
			time = time..MINUTES_ABBR:format(tempTime);
		end
		seconds = mod(seconds, 60);
	end
	if ( count < maxCount and seconds > 0 and not noSeconds ) then
		if ( time ~= "" ) then
			time = time..TIME_UNIT_DELIMITER;
		end
		if ( notAbbreviated ) then
			time = time..D_SECONDS:format(seconds);
		else
			time = time..SECONDS_ABBR:format(seconds);
		end
	end
	return time;
end

function MinutesToTime(mins, hideDays)
	local time = "";
	local count = 0;
	local tempTime;
	-- only show days if hideDays is false
	if ( mins > 1440 and not hideDays ) then
		tempTime = floor(mins / 1440);
		time = TIME_UNIT_DELIMITER .. format(DAYS_ABBR, tempTime);
		mins = mod(mins, 1440);
		count = count + 1;
	end
	if ( mins > 60  ) then
		tempTime = floor(mins / 60);
		time = time .. TIME_UNIT_DELIMITER .. format(HOURS_ABBR, tempTime);
		mins = mod(mins, 60);
		count = count + 1;
	end
	if ( count < 2 ) then
		tempTime = mins;
		time = time .. TIME_UNIT_DELIMITER .. format(MINUTES_ABBR, tempTime);
		count = count + 1;
	end
	return time;
end

function SecondsToTimeAbbrev(seconds)
	local tempTime;
	if ( seconds >= 86400  ) then
		tempTime = ceil(seconds / 86400);
		return DAY_ONELETTER_ABBR, tempTime;
	end
	if ( seconds >= 3600  ) then
		tempTime = ceil(seconds / 3600);
		return HOUR_ONELETTER_ABBR, tempTime;
	end
	if ( seconds >= 60  ) then
		tempTime = ceil(seconds / 60);
		return MINUTE_ONELETTER_ABBR, tempTime;
	end
	return SECOND_ONELETTER_ABBR, seconds;
end

function FormatShortDate(day, month, year)
	if (year) then
		if (LOCALE_enGB) then
			return SHORTDATE_EU:format(day, month, year);
		else
			return SHORTDATE:format(day, month, year);
		end
	else
		if (LOCALE_enGB) then
			return SHORTDATENOYEAR_EU:format(day, month);
		else
			return SHORTDATENOYEAR:format(day, month);
		end
	end
end