-- This is happening in this file instead of the base PlayerInteractionFrameManager
-- because the Rewards Shop is WoWHack only at the moment and this
-- registration doesn't require the frame. So it's a bit of a special case.
RegisterPlayerInteraction(Enum.PlayerInteractionType.RewardsShop,
	{
		frame = "CatalogShopFrame",
		showFunc = function()
			CatalogShopInboundInterface.ShowRewardsShop();
		end,
		hideFunc = function()
			CatalogShopInboundInterface.HideRewardsShop();
		end,
	});