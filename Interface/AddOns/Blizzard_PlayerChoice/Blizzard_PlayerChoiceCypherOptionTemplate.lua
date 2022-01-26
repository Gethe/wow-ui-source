PlayerChoiceCypherOptionTemplateMixin = {};

local animationInfos =
{
	Pixels1 =
	{
		animType = "Translation",
		baseDuration = 13,
		durationDiff = 4,
		XOfs = 0,
		YOfs = 250,
	},
	Pixels2 =
	{
		animType = "Translation",
		baseDuration = 8,
		durationDiff = 3,
		XOfs = 0,
		YOfs = 250,
	},
	Wisps =
	{
		animType = "Translation",
		baseDuration = 13,
		durationDiff = 4,
		XOfs = 0,
		YOfs = 500,
	},
	Wisps2 =
	{
		animType = "Translation",
		baseDuration = 20,
		durationDiff = 4,
		XOfs = 0,
		YOfs = 500,
	},
	ArtworkGlow =
	{
		animType = "Rotation",
		baseDuration = 10,
		durationDiff = 4,
		radians = 2 * math.pi,
	},
	ArtworkSparkles =
	{
		animType = "Rotation",
		baseDuration = 15,
		durationDiff = 4,
		radians = -(2 * math.pi),
	},
};

function PlayerChoiceCypherOptionTemplateMixin:CypherChoiceOnLoad()
	-- Set up animations with variable durations and delays so that not all options' animations are in-sync
	for asset, info in pairs(animationInfos) do
		local newGroup = self:CreateAnimationGroup();
		newGroup:SetLooping("REPEAT");
		table.insert(self.PassiveAnimations, newGroup);

		local animType = info.animType;
		local newAnim = newGroup:CreateAnimation(animType);
		newAnim:SetTarget(self[asset]);
		local duration = math.random(info.baseDuration - info.durationDiff, info.baseDuration + info.durationDiff);
		newAnim:SetDuration(duration);

		if animType == "Translation" then
			newAnim:SetOffset(info.XOfs, info.YOfs);
		elseif animType == "Rotation" then
			newAnim:SetRadians(info.radians);
		end
	end
end

-- override of template method
function PlayerChoiceCypherOptionTemplateMixin:GetRarityDescriptionString()
	if self.optionInfo.rarity == nil or self.optionInfo.rarity == Enum.PlayerChoiceRarity.Common then
		-- Common cypher enhancements do not show a quality string, but need spacing for description text to align.
		return PLAYER_CHOICE_QUALITY_STRING_EMPTY;
	end
	return PlayerChoicePowerChoiceTemplateMixin.GetRarityDescriptionString(self);
end


local rarityToPortraitBackgroundPostfix = 
{
	[Enum.PlayerChoiceRarity.Common] = "-Common",
	[Enum.PlayerChoiceRarity.Uncommon] = "-Uncommon",
	[Enum.PlayerChoiceRarity.Rare] = "-Rare",
	[Enum.PlayerChoiceRarity.Epic] = "-Epic",
};

-- override of template method
function PlayerChoiceCypherOptionTemplateMixin:GetTextureKitRegionTable()
	local textureRegions = PlayerChoicePowerChoiceTemplateMixin.GetTextureKitRegionTable(self);

	textureRegions.CircleBorder = "UI-Frame-%s-Portrait-Border"; -- overrides base behavior for CircleBorder
	textureRegions.RarityGlow = "UI-Frame-%s-Portrait-FX-Back"..(rarityToPortraitBackgroundPostfix[self.optionInfo.rarity] or "-Common");

	return textureRegions;
end