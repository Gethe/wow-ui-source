
local blueBarAtlas = "UI-HUD-ExperienceBar-Fill-Reputation-Faction-Blue";
local barAtlases =
{
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Red",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Red",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Orange",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Yellow",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Green",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Green",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Green",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Green",
};

local blueGainFlareAtlas = "UI-HUD-ExperienceBar-Flare-Rested-2x-Flipbook";
local gainFlareAtlases =
{
	"UI-HUD-ExperienceBar-Flare-Faction-Orange-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-Faction-Orange-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-Faction-Orange-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-ArtifactPower-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-Reputation-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-Reputation-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-Reputation-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-Reputation-2x-Flipbook",
};

local blueLevelUpAtlas = "UI-HUD-ExperienceBar-Fill-Rested-2x-Flipbook";
local levelUpAtlases =
{
	"UI-HUD-ExperienceBar-Fill-Honor-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-Honor-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-Honor-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-ArtifactPower-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-Reputation-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-Reputation-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-Reputation-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-Reputation-2x-Flipbook",
};

function ReputationStatusBarMixin:UpdateBarTextures(reactionLevel, overrideUseBlueBar)
	local deferUntilNextLevelYes = true;
	self.StatusBar:SetBarTexture(overrideUseBlueBar and blueBarAtlas or barAtlases[reactionLevel], deferUntilNextLevelYes);
	self.StatusBar:SetAnimationTextures(overrideUseBlueBar and blueGainFlareAtlas or gainFlareAtlases[reactionLevel],
		overrideUseBlueBar and blueLevelUpAtlas or levelUpAtlases[reactionLevel],
		deferUntilNextLevelYes);
end
