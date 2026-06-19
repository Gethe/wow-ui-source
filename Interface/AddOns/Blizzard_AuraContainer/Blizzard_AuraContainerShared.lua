local _addonName, addonTbl = ...;

do
	local DefaultAuraDurationFormatter = C_StringUtil.CreateSecondsFormatter();
	addonTbl.DefaultAuraDurationFormatter = DefaultAuraDurationFormatter;

	-- This curve is set up to format durations with an inflated bound on
	-- interval brackets, such that values <= 90 seconds render as seconds
	-- values (eg. '90 s'). The '+1' on the curve points is to because
	-- curves promote to the next interval on exact matches, and we want 90
	-- to render as '90 s' and not '1 m'.
	local maxIntervalSecondsMultiplier = 1.5;
	local maxIntervalCurve = C_CurveUtil.CreateCurve();
	maxIntervalCurve:AddPoint(1 + (maxIntervalSecondsMultiplier * SECONDS_PER_MIN), Enum.SecondsFormatterInterval.Minutes);
	maxIntervalCurve:AddPoint(1 + (maxIntervalSecondsMultiplier * SECONDS_PER_HOUR), Enum.SecondsFormatterInterval.Hours);
	maxIntervalCurve:AddPoint(1 + (maxIntervalSecondsMultiplier * SECONDS_PER_DAY), Enum.SecondsFormatterInterval.Days);

	DefaultAuraDurationFormatter:SetDefaultAbbreviation(Enum.SecondsFormatterAbbreviation.OneLetter);
	DefaultAuraDurationFormatter:SetMinInterval(Enum.SecondsFormatterInterval.Seconds);
	DefaultAuraDurationFormatter:SetMaxIntervalCurve(maxIntervalCurve);
	DefaultAuraDurationFormatter:SetDesiredUnitCount(1);
end
