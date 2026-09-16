
function InspectPaperDollFrame_SetLevel()
	if (not InspectFrame.unit) then
		return;
	end

	local unit, level, effectiveLevel, sex = InspectFrame.unit, UnitLevel(InspectFrame.unit), UnitLevel(InspectFrame.unit), UnitSex(InspectFrame.unit);
	local race = UnitRace(InspectFrame.unit);
	local primaryTalentTree = C_SpecializationInfo.GetSpecialization(true);
	
	local classDisplayName, class = UnitClass(InspectFrame.unit); 
	local classColor = RAID_CLASS_COLORS[class];
	local classColorString = format("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255);
	local specName, _;

	if (primaryTalentTree) then
		_, specName = C_SpecializationInfo.GetSpecializationInfo(primaryTalentTree, true);
	end
	
	if ( level == -1 or effectiveLevel == -1 ) then
		level = "??";
	elseif ( effectiveLevel ~= level ) then
		level = EFFECTIVE_LEVEL_FORMAT:format(effectiveLevel, level);
	end
	
	if (specName and specName ~= "") then
		InspectLevelText:SetFormattedText(PLAYER_LEVEL, level, classColorString, specName, classDisplayName);
	else
		InspectLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC, level, classColorString, classDisplayName);
	end
end
