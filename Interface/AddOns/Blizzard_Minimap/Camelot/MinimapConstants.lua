MinimapConstants = {};

MinimapConstants.ALWAYS_ON_FILTERS = {
	[Enum.MinimapTrackingFilter.AccountCompletedQuests] = true,
	[Enum.MinimapTrackingFilter.QuestPOIs] = true,
};

MinimapConstants.CONDITIONAL_FILTERS = {
	[Enum.MinimapTrackingFilter.Target] = true,
};

MinimapConstants.OPTIONAL_FILTERS = {
	[Enum.MinimapTrackingFilter.Repair] = true,
	[Enum.MinimapTrackingFilter.Innkeeper] = true,
	[Enum.MinimapTrackingFilter.TaxiNode] = true,
	[Enum.MinimapTrackingFilter.Stablemaster] = true,
	[Enum.MinimapTrackingFilter.Battlemaster] = true,
	[Enum.MinimapTrackingFilter.TrainerClass] = true,
	[Enum.MinimapTrackingFilter.TrainerProfession] = true,
	[Enum.MinimapTrackingFilter.Auctioneer] = true,
	[Enum.MinimapTrackingFilter.Banker] = true,
	[Enum.MinimapTrackingFilter.AccountCompletedQuests] = false,
	[Enum.MinimapTrackingFilter.TrivialQuests] = true,
	[Enum.MinimapTrackingFilter.Mailbox] = true,
};
