MinimapConstants = {};

MinimapConstants.ALWAYS_ON_FILTERS = {
	[Enum.MinimapTrackingFilter.QuestPOIs] = true,
	[Enum.MinimapTrackingFilter.TaxiNode] = true,
	[Enum.MinimapTrackingFilter.Innkeeper] = true,
	[Enum.MinimapTrackingFilter.ItemUpgrade] = true,
	[Enum.MinimapTrackingFilter.Battlemaster] = true,
	[Enum.MinimapTrackingFilter.Stablemaster] = true,
};

MinimapConstants.CONDITIONAL_FILTERS = {
	[Enum.MinimapTrackingFilter.Target] = true,
	[Enum.MinimapTrackingFilter.Digsites] = true,
	[Enum.MinimapTrackingFilter.Repair] = true,
};

MinimapConstants.OPTIONAL_FILTERS = {
	[Enum.MinimapTrackingFilter.Banker] = true,
	[Enum.MinimapTrackingFilter.Auctioneer] = true,
	[Enum.MinimapTrackingFilter.Barber] = true,
	[Enum.MinimapTrackingFilter.TrainerProfession] = true,
	[Enum.MinimapTrackingFilter.AccountCompletedQuests] = true,
	[Enum.MinimapTrackingFilter.TrivialQuests] = true,
	[Enum.MinimapTrackingFilter.Transmogrifier] = true,
	[Enum.MinimapTrackingFilter.Mailbox] = true,
};
