
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

function DressUpTexturePath()
	-- HACK
	local displayRace, fileName = UnitRace("player");
	if ( not fileName ) then
		fileName = "Orc";
	end
	-- END HACK

	return "Interface\\DressUpFrame\\DressUpBackground-"..fileName;
end

function SetDressUpBackground()
	local texture = DressUpTexturePath();
	DressUpBackgroundTopLeft:SetTexture(texture..1);
	DressUpBackgroundTopRight:SetTexture(texture..2);
	DressUpBackgroundBotLeft:SetTexture(texture..3);
	DressUpBackgroundBotRight:SetTexture(texture..4);
end
