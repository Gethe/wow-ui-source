RecentAlliesUtil = {};

-- Temp Assets Start --

local tempInteractionNames = {
	[Enum.RolodexType.None] = "None",
	[Enum.RolodexType.PartyMember] = "Same party",
	[Enum.RolodexType.RaidMember] = "Same raid",
	[Enum.RolodexType.Trade] = "Traded",
	[Enum.RolodexType.Whisper] = "Whispered",
	[Enum.RolodexType.PublicOrderFilledByOther] = "Filled your Public Crafting Order",
	[Enum.RolodexType.PublicOrderFilledByYou] = "Filled their Public Crafting Order",
	[Enum.RolodexType.PersonalOrderFilledByOther] = "Filled your Crafting Order",
	[Enum.RolodexType.PersonalOrderFilledByYou] = "Filled their Crafting Order",
	[Enum.RolodexType.GuildOrderFilledByOther] = "Filled your Crafting Order",
	[Enum.RolodexType.GuildOrderFilledByYou] = "Filled their Crafting Order",
	[Enum.RolodexType.CreatureKill] = "Fought together",
	[Enum.RolodexType.CompleteDungeon] = "Completed Dungeon Together",
	[Enum.RolodexType.KillRaidBoss] = "Raided Together",
	[Enum.RolodexType.KillLfrBoss] = "Raided Together",
	[Enum.RolodexType.CompleteDelve] = "Did a Delve together",
	[Enum.RolodexType.CompleteArena] = "Did Arena together",
	[Enum.RolodexType.CompleteBg] = "Fought in Battleground together",
	[Enum.RolodexType.Duel] = "Dueled",
	[Enum.RolodexType.PetBattle] = "Pet Battled",
	[Enum.RolodexType.PvPKill] = "PvPed together",
};

function RecentAlliesUtil.GetInteractionName(interactionType)
	return tempInteractionNames[interactionType] or "";
end

-- Temp Assets End --

local recentAlliesTimeFormatter = CreateFromMixins(SecondsFormatterMixin);
recentAlliesTimeFormatter:Init(
	SECONDS_PER_HOUR,
	SecondsFormatter.Abbreviation.None
);

function RecentAlliesUtil.GetFormattedTime(time)
	if not time then
		return "";
	end

	-- Show hours if the time is under a day, otherwise show days
	local bestInterval = time < SECONDS_PER_DAY and SecondsFormatter.Interval.Hours or SecondsFormatter.Interval.Days;
	recentAlliesTimeFormatter:SetMinInterval(bestInterval);
	return recentAlliesTimeFormatter:Format(time);
end

-- Basic interactions simply display the name of the interaction and the location (if available)
local function GenerateBasicContextString(interactionData)
	local contextString = RecentAlliesUtil.GetInteractionName(interactionData.type);
	if interactionData.contextData.locationName then
		contextString = RECENT_ALLY_TOOLTIP_INTERACTION_WITH_CONTEXT_FORMAT:format(contextString, interactionData.contextData.locationName);
	end

	return contextString;
end

local function GetItemNameColored(item)
	if not item or not item:GetItemName() then
		return "";
	end

	local itemQualityColor = item:GetItemQualityColor();
	return itemQualityColor and itemQualityColor.color:WrapTextInColorCode(item:GetItemName()) or HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(item:GetItemName());
end

-- Crafting order interactions try to add the relevant item (if possible)
-- Assumes item data is already loaded
local function GenerateCraftingOrderContextString(interactionData)
	local contextString = RecentAlliesUtil.GetInteractionName(interactionData.type);
	if interactionData.contextData.itemID then
		local item = Item:CreateFromItemID(interactionData.contextData.itemID);
		contextString = RECENT_ALLY_TOOLTIP_INTERACTION_WITH_CONTEXT_FORMAT:format(contextString, GetItemNameColored(item));
	end

	return contextString;
end

local function GenerateRaidInteractionContextString(interactionData)
	local contextString = RecentAlliesUtil.GetInteractionName(interactionData.type);
	if interactionData.contextData.locationName and interactionData.contextData.activityDifficultyID then
		local raidName =  interactionData.contextData.locationName;
		local difficultyName = DifficultyUtil.GetDifficultyName(interactionData.contextData.activityDifficultyID);
		if difficultyName then
			raidName = RECENT_ALLY_RAID_NAME_STRING_FORMAT:format(raidName, difficultyName);
		end

		contextString = RECENT_ALLY_TOOLTIP_INTERACTION_WITH_CONTEXT_FORMAT:format(contextString, raidName);
	end

	return contextString;
end

local function GenerateDelveInteractionContextString(interactionData)
	local contextString = RecentAlliesUtil.GetInteractionName(interactionData.type);
	if interactionData.contextData.locationName and interactionData.contextData.activityDifficultyLevel then
		local delveName =  interactionData.contextData.locationName
		local tierString = RECENT_ALLY_DELVE_TIER_LABEL:format(interactionData.contextData.activityDifficultyLevel);
		local fullDelveName = RECENT_ALLY_DELVE_NAME_STRING_FORMAT:format(delveName, tierString);
		contextString = RECENT_ALLY_TOOLTIP_INTERACTION_WITH_CONTEXT_FORMAT:format(contextString, fullDelveName);
	end

	return contextString;
end

local function GenerateMythicPlusDungeonInteractionContextString(interactionData)
	local contextString = RecentAlliesUtil.GetInteractionName(interactionData.type);
	if interactionData.contextData.locationName and interactionData.contextData.activityDifficultyLevel then
		local dungeonName =  interactionData.contextData.locationName
		local keystoneLevelString = CHALLENGE_MODE_ITEM_POWER_LEVEL:format(interactionData.contextData.activityDifficultyLevel);
		local fullDungeonName = RECENT_ALLY_MYTHIC_PLUS_DUNGEON_NAME_STRING_FORMAT:format(dungeonName, keystoneLevelString);
		contextString = RECENT_ALLY_TOOLTIP_INTERACTION_WITH_CONTEXT_FORMAT:format(contextString, fullDungeonName);
	end

	return contextString;
end

local InteractionTypeToContextStringGenerator = {
	[Enum.RolodexType.None] = GenerateBasicContextString,
	[Enum.RolodexType.PartyMember] = GenerateBasicContextString,
	[Enum.RolodexType.RaidMember] = GenerateBasicContextString,
	[Enum.RolodexType.Trade] = GenerateBasicContextString,
	[Enum.RolodexType.Whisper] = GenerateBasicContextString,
	[Enum.RolodexType.PublicOrderFilledByOther] = GenerateCraftingOrderContextString,
	[Enum.RolodexType.PublicOrderFilledByYou] = GenerateCraftingOrderContextString,
	[Enum.RolodexType.PersonalOrderFilledByOther] = GenerateCraftingOrderContextString,
	[Enum.RolodexType.PersonalOrderFilledByYou] = GenerateCraftingOrderContextString,
	[Enum.RolodexType.GuildOrderFilledByOther] = GenerateCraftingOrderContextString,
	[Enum.RolodexType.GuildOrderFilledByYou] = GenerateCraftingOrderContextString,
	[Enum.RolodexType.CreatureKill] = GenerateBasicContextString,
	[Enum.RolodexType.CompleteDungeon] = GenerateMythicPlusDungeonInteractionContextString,
	[Enum.RolodexType.KillRaidBoss] = GenerateRaidInteractionContextString,
	[Enum.RolodexType.KillLfrBoss] = GenerateRaidInteractionContextString,
	[Enum.RolodexType.CompleteDelve] = GenerateDelveInteractionContextString,
	[Enum.RolodexType.CompleteArena] = GenerateBasicContextString,
	[Enum.RolodexType.CompleteBg] = GenerateBasicContextString,
	[Enum.RolodexType.Duel] = GenerateBasicContextString,
	[Enum.RolodexType.PetBattle] = GenerateBasicContextString,
	[Enum.RolodexType.PvPKill] = GenerateBasicContextString,
};

local function GetContextStringGeneratorForInteractionType(interactionType)
	return InteractionTypeToContextStringGenerator[interactionType];
end

function RecentAlliesUtil.GenerateContextStringForInteraction(interactionData)
	local contextStringGenerator = GetContextStringGeneratorForInteractionType(interactionData.type);
	return contextStringGenerator and contextStringGenerator(interactionData) or "";
end
