EncounterTimelineUtil = {};

function EncounterTimelineUtil.GetViewOrientationSetup(viewOrientation, iconDirection)
	return EncounterTimelineViewOrientations[viewOrientation][iconDirection];
end

function EncounterTimelineUtil.CalculateLineBreakDuration(lineBreakIndex, lineBreakCount, shortTrackDuration)
	-- Art placement for the line break masks should be such that they begin
	-- at the one second remaining mark on the timeline and then break once
	-- every two seconds thereafter.
	--
	-- If, however, the short track duration is very small due to the user
	-- opting to only show short timeline events then we want to instead
	-- make each break only one second apart.

	local startDuration = 1;
	local breakDuration = 2;

	if (((lineBreakCount - 1) * breakDuration) + startDuration) > shortTrackDuration then
		breakDuration = 1;
	end

	return ((lineBreakIndex - 1) * breakDuration) + startDuration;
end
