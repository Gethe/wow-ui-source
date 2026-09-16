function ShouldUseSilverUnitFrame(classification)
	return (classification == "rareelite" or classification == "rare" );
end

function ShouldShowStar(classification)
	return false;
end

function GetBossPortraitFrameData(unit, classification)
	if UnitIsBossMob(unit) then
		return "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged", 11, -4;
	elseif ShouldUseSilverUnitFrame(classification) then
		return "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare-Silver-Winged", 8, -7;
	elseif classification == "elite" then
		return "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold", 0, 1;
	end

	return nil;
end

function ShouldShowBattlePetIcon()
	return false;
end
