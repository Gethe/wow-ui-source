
function InspectPaperDollFrame_SetLevel()
	if (not InspectFrame.unit) then
		return;
	end

	local unit, level, effectiveLevel, sex = InspectFrame.unit, UnitLevel(InspectFrame.unit), UnitLevel(InspectFrame.unit), UnitSex(InspectFrame.unit);
	local race = UnitRace(InspectFrame.unit);
	
	local classDisplayName, class = UnitClass(InspectFrame.unit); 
	local specName, _;
	
	if ( level == -1 or effectiveLevel == -1 ) then
		level = "??";
	elseif ( effectiveLevel ~= level ) then
		level = EFFECTIVE_LEVEL_FORMAT:format(effectiveLevel, level);
	end

	InspectLevelText:SetFormattedText(PLAYER_LEVEL, level, race, classDisplayName);
end
