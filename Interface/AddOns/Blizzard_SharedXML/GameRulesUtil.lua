
GameRulesUtil = {};

GameRulesUtil.ActionButtonTypeOverlayStrategy = {
	None = 0, -- By default we show nothing.
	HighlightMana = 1, -- Show a special icon for mana spenders and a default icon for everything else.
	ManaAndEnergy = 2, -- Show a special icon for mana spenders and energy spenders and no icon for everything else.
};

-- The queue status system is a way to skin/adjust the dungeon finder eye and the dungeon
-- finder dungeon ready dialog. This is based on game mode directly instead of a game rule
-- because the display information is very specific to the game mode.
GameRulesUtil.QueueStatusModeKey = {
	TitleOrCategoryCallback = "titleOrCategoryCallback",
	TeleportOutText = "teleportOutText",
	TeleportInText = "teleportInText",
	LeaveText = "leaveText",
	OverrideLFGLabelText = "overrideLFGLabelText",
	OverrideLFGNumEncounters = "overrideLFGNumEncounters",
};

GameRulesUtil.QueueStatusModeInfo = {
	[Enum.GameMode.Standard] = {
		-- [GameRulesUtil.QueueStatusModeKey.TitleOrCategoryCallback] = nil,
		[GameRulesUtil.QueueStatusModeKey.TeleportOutText] = TELEPORT_OUT_OF_DUNGEON,
		[GameRulesUtil.QueueStatusModeKey.TeleportInText] = TELEPORT_TO_DUNGEON,
		[GameRulesUtil.QueueStatusModeKey.LeaveText] = INSTANCE_PARTY_LEAVE,
		-- [GameRulesUtil.QueueStatusModeKey.OverrideLFGLabelText] = nil,
		-- [GameRulesUtil.QueueStatusModeKey.OverrideLFGNumEncounters] = nil,
	},
	[Enum.GameMode.WoWHack] = {
		[GameRulesUtil.QueueStatusModeKey.TitleOrCategoryCallback] = QUEUE_STATUS_WOWHACK_TITLE,
		[GameRulesUtil.QueueStatusModeKey.TeleportOutText] = QUEUE_STATUS_WOWHACK_TELEPORT_OUT,
		[GameRulesUtil.QueueStatusModeKey.TeleportInText] = QUEUE_STATUS_WOWHACK_TELEPORT_IN,
		[GameRulesUtil.QueueStatusModeKey.LeaveText] = QUEUE_STATUS_WOWHACK_LEAVE,
		[GameRulesUtil.QueueStatusModeKey.OverrideLFGLabelText] = "",
		[GameRulesUtil.QueueStatusModeKey.OverrideLFGNumEncounters] = 0,
	},
};

GameRulesUtil.GameModeToAccountStore = {
	[Enum.GameMode.Plunderstorm] = Constants.AccountStoreConsts.PlunderstormStoreFrontID,
	[Enum.GameMode.WoWHack] = Constants.AccountStoreConsts.WowhackStoreFrontID,
};

function GameRulesUtil.ShouldShowPlayerCastBar()
	return not C_GameRules.IsGameRuleActive(Enum.GameRule.PlayerCastBarDisabled);
end

function GameRulesUtil.ShouldShowTargetCastBar()
	return GetCVar("showTargetCastbar") and not C_GameRules.IsGameRuleActive(Enum.GameRule.TargetCastBarDisabled);
end

function GameRulesUtil.ShouldShowNamePlateCastBar()
	return not C_GameRules.IsGameRuleActive(Enum.GameRule.NameplateCastBarDisabled);
end

function GameRulesUtil.ShouldShowAddOns()
	if C_AddOns.GetNumAddOns() <= 0 then
		return false;
	end

	if IsTestBuild() then
		return true;
	end

	return not C_GameRules.IsGameRuleActive(Enum.GameRule.UserAddonsDisabled);
end

function GameRulesUtil.ShouldShowSplashScreen()
	if not C_GameRules.IsStandard() then
		return false;
	end

	return C_SplashScreen and C_SplashScreen.CanViewSplashScreen() and not IsCharacterNewlyBoosted();
end

function GameRulesUtil.EJIsDisabled()
	if C_GameRules.IsGameRuleActive(Enum.GameRule.EncounterJournalDisabled) then
		return true;
	end

	-- At least one tab needs to be active for the Encounter Journal to be enabled.
	local tabFunctions = {
		GameRulesUtil.EJShouldShowTravelersLog,
		GameRulesUtil.EJShouldShowSuggestedContent,
		GameRulesUtil.EJShouldShowDungeons,
		GameRulesUtil.EJShouldShowRaids,
		GameRulesUtil.EJShouldShowItemSets,
	};

	for _, func in ipairs(tabFunctions) do
		if func() then
			return false;
		end
	end

	return true;
end

function GameRulesUtil.EJShouldShowTravelersLog()
	return C_PlayerInfo.IsTradingPostAvailable();
end

function GameRulesUtil.EJShouldShowSuggestedContent()
	if PlayerIsTimerunning() then
		return false;
	end

	return not C_GameRules.IsGameRuleActive(Enum.GameRule.EjSuggestedContentDisabled);
end

function GameRulesUtil.EJShouldShowDungeons()
	return not C_GameRules.IsGameRuleActive(Enum.GameRule.EjDungeonsDisabled);
end

function GameRulesUtil.EJShouldShowRaids()
	return not C_GameRules.IsGameRuleActive(Enum.GameRule.EjRaidsDisabled);
end

function GameRulesUtil.EJShouldShowItemSets()
	return not C_GameRules.IsGameRuleActive(Enum.GameRule.EjItemSetsDisabled);
end

function GameRulesUtil.CanShowExperienceBar()
	return not IsPlayerAtEffectiveMaxLevel() and not IsXPUserDisabled() and not C_GameRules.IsGameRuleActive(Enum.GameRule.ExperienceBarDisabled);
end

function GameRulesUtil.GetActionButtonTypeOverlayStrategy()
	if not C_GameRules.IsGameRuleActive(Enum.GameRule.ActionButtonTypeOverlayStrategy) then
		return GameRulesUtil.ActionButtonTypeOverlayStrategy.None;
	end

	return C_GameRules.GetGameRuleAsFloat(Enum.GameRule.ActionButtonTypeOverlayStrategy);
end

function GameRulesUtil.AllowBelowMinimumActionBarIcons()
	local activeGameMode = C_GameRules.GetActiveGameMode();
	return (activeGameMode == Enum.GameMode.Plunderstorm) or (activeGameMode == Enum.GameMode.WoWHack);
end

function GameRulesUtil.GetQueueStatusModeInfo()
	local activeGameMode = C_GameRules.GetActiveGameMode();
	return GameRulesUtil.QueueStatusModeInfo[activeGameMode] or GameRulesUtil.QueueStatusModeInfo[Enum.GameMode.Standard];
end

function GameRulesUtil.GetQueueStatusInfo(key)
	local modeInfo = GameRulesUtil.GetQueueStatusModeInfo();
	return modeInfo[key];
end

function GameRulesUtil.GetOverrideLFGCategoryName(category)
	local titleOrCategoryCallback = GameRulesUtil.GetQueueStatusInfo(GameRulesUtil.QueueStatusModeKey.TitleOrCategoryCallback);
	if type(titleOrCategoryCallback) == "function" then
		return titleOrCategoryCallback(category);
	end

	return titleOrCategoryCallback;
end

function GameRulesUtil.GetActiveAccountStore()
	local activeGameMode = C_GameRules.GetActiveGameMode();
	return GameRulesUtil.GameModeToAccountStore[activeGameMode];
end

-- System callbacks can be registered here to be called when game rules change.
local registeredSystemCallbacks = {};
function GameRulesUtil.RegisterSystemCallback(systemCallback)
	table.insert(registeredSystemCallbacks, systemCallback);
end

-- As of adding this comment, game rules are only updated when the active game mode changes.
function GameRulesUtil.OnActiveGameModeUpdated()
	for _, systemCallback in ipairs(registeredSystemCallbacks) do
		systemCallback();
	end
end

EventRegistry:RegisterFrameEventAndCallback("ACTIVE_GAME_MODE_UPDATED", GameRulesUtil.OnActiveGameModeUpdated, GameRulesUtil);
