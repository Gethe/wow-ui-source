local AddonName = ...;

function BlackMarket_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowBlackMarketFrame()
	if BlackMarket_LoadUI() then
		BlackMarketFrame_Show();
	end
end

function HideBlackMarketFrame()
	if C_AddOns.IsAddOnLoaded(AddonName) then
		BlackMarketFrame_Hide();
	end
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "BlackMarketFrame",
		loadFunc = BlackMarket_LoadUI,
		showFunc = ShowBlackMarketFrame,
		hideFunc = HideBlackMarketFrame,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.BlackMarketAuctioneer, frameInfo);
end

RegisterWithPlayerInteractionManager();
