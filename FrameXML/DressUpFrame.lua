function DressUpItem(item)
	if ( AuctionFrame:IsVisible() ) then
		if ( not AuctionDressUpFrame:IsVisible() ) then
			ShowUIPanel(AuctionDressUpFrame);
		end
		AuctionDressUpModel:TryOn(item);
	else
		if ( not DressUpFrame:IsVisible() ) then
			ShowUIPanel(DressUpFrame);
		end
		DressUpModel:TryOn(item);
	end
end

function DressUpItemLink(link)
	if ( not link ) then
		return;
	end
	local item = gsub(link, ".*item:(%d+).*", "%1", 1);
	DressUpItem(item);
end

function SetDressUpBackground(isAuctionFrame)
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

	local texture = "Interface\\DressUpFrame\\DressUpBackground-"..fileName;
	if ( isAuctionFrame ) then
		AuctionDressUpBackgroundTop:SetTexture(texture..1);
		AuctionDressUpBackgroundBot:SetTexture(texture..3);
	else
		DressUpBackgroundTopLeft:SetTexture(texture..1);
		DressUpBackgroundTopRight:SetTexture(texture..2);
		DressUpBackgroundBotLeft:SetTexture(texture..3);
		DressUpBackgroundBotRight:SetTexture(texture..4);
	end
end
