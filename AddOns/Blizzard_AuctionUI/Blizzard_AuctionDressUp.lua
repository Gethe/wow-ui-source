
local DressUpItem_orig = DressUpItem;

function DressUpItem(item)
	if ( AuctionFrame:IsVisible() ) then
		if ( not AuctionDressUpFrame:IsVisible() ) then
			ShowUIPanel(AuctionDressUpFrame);
			AuctionDressUpModel:SetUnit("player");
		end
		AuctionDressUpModel:TryOn(item);
	else
		DressUpItem_orig(item);
	end
end

function SetAuctionDressUpBackground()
	local texture = DressUpTexturePath();
	AuctionDressUpBackgroundTop:SetTexture(texture..1);
	AuctionDressUpBackgroundBot:SetTexture(texture..3);
end
