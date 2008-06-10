
function DressUpItem(item)
	if ( not DressUpFrame:IsVisible() ) then
		ShowUIPanel(DressUpFrame);
		DressUpModel:SetUnit("player");
	end
	DressUpModel:TryOn(item);
end

function DressUpItemLink(link)
	if ( not link ) then
		return;
	end
	local item = gsub(link, ".*item:(%d+).*", "%1", 1);
	DressUpItem(item);
end

function DressUpTexturePath()
	-- HACK!!!
	local race, fileName = UnitRace("player");
	if ( fileName == "Gnome" or fileName == "GNOME" ) then
		fileName = "Dwarf";
	elseif ( fileName == "Troll" or fileName == "TROLL" ) then
		fileName = "Orc";
	end
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
