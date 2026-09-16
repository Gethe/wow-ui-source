function ShouldUseSilverUnitFrame(classification)
	return (classification == "rareelite");
end

function ShouldShowStar(classification)
	return (classification == "rareelite" or classification == "rare" );
end

function GetBossPortraitFrameData(unit, classification)
	if (UnitIsBossMob(unit)) then
		return "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged", 8, -8;
	elseif (ShouldUseSilverUnitFrame(classification)) then
		return "ui-hud-unitframe-target-portraiton-boss-rare-silver", -11, -8;
	elseif (classification == "elite") then
		return "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold", -11, -8;
	end

	return nil;
end

function ShouldShowBattlePetIcon()
	return true;
end
