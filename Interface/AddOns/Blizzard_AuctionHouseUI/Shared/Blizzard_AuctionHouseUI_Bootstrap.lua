local AddonName = ...;

function AuctionHouseFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowAuctionHouseFrame()
	if AuctionHouseFrame_LoadUI() then
		ShowUIPanel(AuctionHouseFrame);
	end
end

function HideAuctionHouseFrame()
	if C_AddOns.IsAddOnLoaded(AddonName) then
		HideUIPanel(AuctionHouseFrame);
	end
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "AuctionHouseFrame",
		loadFunc = AuctionHouseFrame_LoadUI,
		showFunc = ShowAuctionHouseFrame,
		hideFunc = HideAuctionHouseFrame,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.Auctioneer, frameInfo);
	AddPlayerInteractionConditions(Enum.PlayerInteractionType.Auctioneer,
		{
			showCondition = function()
				if GameLimitedMode_IsActive() then
					UIErrorsFrame:AddExternalErrorMessage(ERR_FEATURE_RESTRICTED_TRIAL);
					C_AuctionHouse.CloseAuctionHouse();
					return false;
				end

				return true;
			end,
		});
end

RegisterWithPlayerInteractionManager();
