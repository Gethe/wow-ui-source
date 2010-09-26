
function DressUpItemLink(link)
	if ( not link or not IsDressableItem(link) ) then
		return;
	end
	if ( not DressUpFrame:IsShown() ) then
		ShowUIPanel(DressUpFrame);
		DressUpModel:SetUnit("player");
	end
	DressUpModel:TryOn(link);
end

function DressUpTexturePath(raceFileName)
	-- HACK
	if ( not raceFileName ) then
		raceFileName = "Orc";
	end
	-- END HACK

	return "Interface\\DressUpFrame\\DressUpBackground-"..raceFileName;
end

function SetDressUpBackground()
	local race, fileName = UnitRace("player");
	local texture = DressUpTexturePath(fileName);
	DressUpBackgroundTopLeft:SetTexture(texture..1);
	DressUpBackgroundTopRight:SetTexture(texture..2);
	DressUpBackgroundBotLeft:SetTexture(texture..3);
	DressUpBackgroundBotRight:SetTexture(texture..4);
end
