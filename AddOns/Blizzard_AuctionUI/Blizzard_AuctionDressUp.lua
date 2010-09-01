
local DressUpItemLink_orig = DressUpItemLink;

function DressUpItemLink(link)
	if ( not link ) then
		return;
	end
	if ( AuctionFrame:IsShown() ) then
		if ( not AuctionDressUpFrame:IsShown() ) then
			ShowUIPanel(AuctionDressUpFrame);
			AuctionDressUpModel:SetUnit("player");
		end
		AuctionDressUpModel:TryOn(link);
	else
		DressUpItemLink_orig(link);
	end
end

function SetAuctionDressUpBackground()
	local race, raceFileName = UnitRace("player");
	local texture = DressUpTexturePath(raceFileName);
	AuctionDressUpBackgroundTop:SetTexture(texture..1);
	AuctionDressUpBackgroundBot:SetTexture(texture..3);
end

function AuctionDressUpFrame_OnShow()
	UIPanelWindows["AuctionFrame"].width = 1020;
	UpdateUIPanelPositions(AuctionFrame);
	PlaySound("igCharacterInfoOpen");
end

function AuctionDressUpFrame_OnHide()
	UIPanelWindows["AuctionFrame"].width = 840;
	UpdateUIPanelPositions();
	PlaySound("igCharacterInfoClose");
end
