
--FILE CONSTANTS
local HEADER_INDENT = 15;
local MAX_CREATURES_PER_ENCOUNTER = 9;

local SECTION_BUTTON_OFFSET = 6;
local SECTION_DESCRIPTION_OFFSET = 27;

local EJ_STYPE_ITEM = 0;
local EJ_STYPE_ENCOUNTER = 1;
local EJ_STYPE_CREATURE = 2;
local EJ_STYPE_SECTION = 3;
local EJ_STYPE_INSTANCE = 4;

local EJ_HTYPE_OVERVIEW = 3;

local EJ_NUM_INSTANCE_PER_ROW = 4;

local EJ_MAX_SECTION_MOVE = 320;

local EJ_TIER_INDEX_SHADOWLANDS = 9;

AJ_MAX_NUM_SUGGESTIONS = 3;

-- Priority list for *not my spec*
local overviewPriorities = {
	[1] = Enum.LFGRole.Damage,
	[2] = Enum.LFGRole.Healer,
	[3] = Enum.LFGRole.Tank,
	[4] = Constants.LFG_ROLEConstants.LFG_ROLE_NO_ROLE,
}

local NONE_FLAG = -1;
local flagsByRole = {
	[Enum.LFGRole.Damage] = 1,
	[Enum.LFGRole.Healer] = 2,
	[Enum.LFGRole.Tank] = 0,
	[Constants.LFG_ROLEConstants.LFG_ROLE_NO_ROLE] = NONE_FLAG,
}

local EJ_Tabs = {};

EJ_Tabs[1] = {frame="overviewScroll", button="overviewTab"};
EJ_Tabs[2] = {frame="LootContainer", button="lootTab"};
EJ_Tabs[3] = {frame="detailsScroll", button="bossTab"};
EJ_Tabs[4] = {frame="model", button="modelTab"};


local EJ_section_openTable = {};


local EJ_LINK_INSTANCE 		= 0;
local EJ_LINK_ENCOUNTER		= 1;
local EJ_LINK_SECTION 		= 3;

local EJ_DIFFICULTIES = {
	DifficultyUtil.ID.DungeonNormal,
	DifficultyUtil.ID.DungeonHeroic,
	DifficultyUtil.ID.DungeonMythic,
	DifficultyUtil.ID.DungeonChallenge,
	DifficultyUtil.ID.DungeonTimewalker,
	DifficultyUtil.ID.RaidLFR,
	DifficultyUtil.ID.Raid10Normal,
	DifficultyUtil.ID.Raid10Heroic,
	DifficultyUtil.ID.Raid25Normal,
	DifficultyUtil.ID.Raid25Heroic,
	DifficultyUtil.ID.PrimaryRaidLFR,
	DifficultyUtil.ID.PrimaryRaidNormal,
	DifficultyUtil.ID.PrimaryRaidHeroic,
	DifficultyUtil.ID.PrimaryRaidMythic,
	DifficultyUtil.ID.RaidTimewalker,
	DifficultyUtil.ID.Raid40,
};

local function IsEJDifficulty(difficultyID)
	return tContains(EJ_DIFFICULTIES, difficultyID);
end

local function GetEJDifficultySize(difficultyID)
	if difficultyID ~= DifficultyUtil.ID.RaidTimewalker and not DifficultyUtil.IsPrimaryRaid(difficultyID) then
		return DifficultyUtil.GetMaxPlayers(difficultyID);
	end
	return nil;
end

local function GetEJDifficultyString(difficultyID)
	local name = DifficultyUtil.GetDifficultyName(difficultyID);
	local size = GetEJDifficultySize(difficultyID);
	if size then
		return string.format(ENCOUNTER_JOURNAL_DIFF_TEXT, size, name);
	else
		return name;
	end
end

local EJ_TIER_DATA =
{
	[1] = { backgroundAtlas = "UI-EJ-Classic", r = 1.0, g = 0.8, b = 0.0 },
	[2] = { backgroundAtlas = "UI-EJ-BurningCrusade", r = 0.6, g = 0.8, b = 0.0 },
	[3] = { backgroundAtlas = "UI-EJ-WrathoftheLichKing", r = 0.2, g = 0.8, b = 1.0 },
	[4] = { backgroundAtlas = "UI-EJ-Cataclysm", r = 1.0, g = 0.4, b = 0.0 },
	[5] = { backgroundAtlas = "UI-EJ-MistsofPandaria", r = 0.0, g = 0.6, b = 0.2 },
	[6] = { backgroundAtlas = "UI-EJ-WarlordsofDraenor", r = 0.82, g = 0.55, b = 0.1 },
	[7] = { backgroundAtlas = "UI-EJ-Legion", r = 0.0, g = 0.6, b = 0.2 },
	[8] = { backgroundAtlas = "UI-EJ-BattleforAzeroth", r = 0.8, g = 0.4, b = 0.0 },
	[9] = { backgroundAtlas = "UI-EJ-Shadowlands", r = 0.278, g = 0.471, b = .937 },
	[10] = { backgroundAtlas = "UI-EJ-Dragonflight", r = 0.2, g = 0.8, b = 1.0 },
	[11] = { backgroundAtlas = "UI-EJ-Dragonflight", r = 0.2, g = 0.8, b = 1.0 },
}

function GetEJTierData(tier)
	return EJ_TIER_DATA[tier] or EJ_TIER_DATA[1];
end

ExpansionEnumToEJTierDataTableId = {
	[LE_EXPANSION_CLASSIC] = 1,
	[LE_EXPANSION_BURNING_CRUSADE] = 2,
	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = 3,
	[LE_EXPANSION_CATACLYSM] = 4,
	[LE_EXPANSION_MISTS_OF_PANDARIA] = 5,
	[LE_EXPANSION_WARLORDS_OF_DRAENOR] = 6,
	[LE_EXPANSION_LEGION] = 7,
	[LE_EXPANSION_BATTLE_FOR_AZEROTH] = 8,
	[LE_EXPANSION_SHADOWLANDS] = 9,
	[LE_EXPANSION_DRAGONFLIGHT] = 10,
}

function GetEJTierDataTableID(expansion)
	local data = ExpansionEnumToEJTierDataTableId[expansion];
	if data then
		return data;
	end

	return ExpansionEnumToEJTierDataTableId[LE_EXPANSION_CLASSIC];
end

local SlotFilterToSlotName = {
	[Enum.ItemSlotFilterType.Head] = INVTYPE_HEAD,
	[Enum.ItemSlotFilterType.Neck] = INVTYPE_NECK,
	[Enum.ItemSlotFilterType.Shoulder] = INVTYPE_SHOULDER,
	[Enum.ItemSlotFilterType.Cloak] = INVTYPE_CLOAK,
	[Enum.ItemSlotFilterType.Chest] = INVTYPE_CHEST,
	[Enum.ItemSlotFilterType.Wrist] = INVTYPE_WRIST,
	[Enum.ItemSlotFilterType.Hand] = INVTYPE_HAND,
	[Enum.ItemSlotFilterType.Waist] = INVTYPE_WAIST,
	[Enum.ItemSlotFilterType.Legs] = INVTYPE_LEGS,
	[Enum.ItemSlotFilterType.Feet] = INVTYPE_FEET,
	[Enum.ItemSlotFilterType.MainHand] = INVTYPE_WEAPONMAINHAND,
	[Enum.ItemSlotFilterType.OffHand] = INVTYPE_WEAPONOFFHAND,
	[Enum.ItemSlotFilterType.Finger] = INVTYPE_FINGER,
	[Enum.ItemSlotFilterType.Trinket] = INVTYPE_TRINKET,
	[Enum.ItemSlotFilterType.Other] = EJ_LOOT_SLOT_FILTER_OTHER,
}

local BOSS_LOOT_BUTTON_HEIGHT = 45;
local INSTANCE_LOOT_BUTTON_HEIGHT = 64;

EncounterJournalItemMixin = {};

function EncounterJournalItemMixin:Init(elementData)
	local index = elementData.index;
	if (EncounterJournal.encounterID) then
		self:SetHeight(BOSS_LOOT_BUTTON_HEIGHT);
		self.boss:Hide();
		self.bossTexture:Hide();
		self.bosslessTexture:Show();
	else
		self:SetHeight(INSTANCE_LOOT_BUTTON_HEIGHT);
		self.boss:Show();
		self.bossTexture:Show();
		self.bosslessTexture:Hide();
	end
	self.index = index;

	local itemInfo = C_EncounterJournal.GetLootInfoByIndex(self.index);
	if ( itemInfo and itemInfo.name ) then
		self.name:SetText(WrapTextInColorCode(itemInfo.name, itemInfo.itemQuality));
		self.icon:SetTexture(itemInfo.icon);
		if itemInfo.handError then
			self.slot:SetText(INVALID_EQUIPMENT_COLOR:WrapTextInColorCode(itemInfo.slot));
		else
			self.slot:SetText(itemInfo.slot);
		end
		if itemInfo.weaponTypeError then
			self.armorType:SetText(INVALID_EQUIPMENT_COLOR:WrapTextInColorCode(itemInfo.armorType));
		else
			self.armorType:SetText(itemInfo.armorType);
		end

		local numEncounters = EJ_GetNumEncountersForLootByIndex(self.index);
		if ( numEncounters == 1 ) then
			self.boss:SetFormattedText(BOSS_INFO_STRING, EJ_GetEncounterInfo(itemInfo.encounterID));
		elseif ( numEncounters == 2) then
			local itemInfoSecond = C_EncounterJournal.GetLootInfoByIndex(self.index, 2);
			local secondEncounterID = itemInfoSecond and itemInfoSecond.encounterID;
			if ( itemInfo.encounterID and secondEncounterID ) then
				self.boss:SetFormattedText(BOSS_INFO_STRING_TWO, EJ_GetEncounterInfo(itemInfo.encounterID), EJ_GetEncounterInfo(secondEncounterID));
			end
		elseif ( numEncounters > 2 ) then
			self.boss:SetFormattedText(BOSS_INFO_STRING_MANY, EJ_GetEncounterInfo(itemInfo.encounterID));
		end

		local itemName, _, quality = C_Item.GetItemInfo(itemInfo.link);
		SetItemButtonQuality(self, quality, itemInfo.link);
	else
		self.name:SetText(RETRIEVING_ITEM_INFO);
		self.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
		self.slot:SetText("");
		self.armorType:SetText("");
		self.boss:SetText("");
	end
	self.encounterID = itemInfo and itemInfo.encounterID;
	self.itemID = itemInfo and itemInfo.itemID;
	self.link = itemInfo and itemInfo.link;
	if self.showingTooltip then
		GameTooltip:SetAnchorType("ANCHOR_RIGHT");
		local useSpec = true;
		EncounterJournal_SetTooltipWithCompare(GameTooltip, self.link, useSpec);
	end
end

EncounterJournalItemHeaderMixin = {};

function EncounterJournalItemHeaderMixin:Init(elementData)
	self.name:SetText(elementData.text);
	if elementData.helpText then
		self.TipButton.elementData = elementData;
		self.TipButton:Show();
	else
		self.TipButton:Hide();
	end
end

EncounterBossButtonMixin = {};

function EncounterBossButtonMixin:Init(elementData)
	self.link = elementData.link;
	self:SetText(elementData.name);
	self.encounterID = elementData.bossID;

	--Use the boss' first creature as the button icon
	local bossImage = select(5, EJ_GetCreatureInfo(1, elementData.bossID)) or "Interface\\EncounterJournal\\UI-EJ-BOSS-Default";
	self.creature:SetTexture(bossImage);

	if (EncounterJournal.encounterID == elementData.bossID) then
		self:LockHighlight();
	else
		self:UnlockHighlight();
	end

	EncounterJournalBossButton_UpdateDifficultyOverlay(self);
end

MonthlyActivitiesTabButtonMixin = CreateFromMixins(PanelTabButtonMixin);

function MonthlyActivitiesTabButtonMixin:OnEnter()
	if not C_PlayerInfo.IsTravelersLogAvailable() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

		local factionGroup = UnitFactionGroup("player");
		local tradingPostLocation = factionGroup == "Alliance" and MONTHLY_ACTIVITIES_TRADING_POST_ALLIANCE or MONTHLY_ACTIVITIES_TRADING_POST_HORDE;
		GameTooltip_AddErrorLine(GameTooltip, MONTHLY_ACTIVITIES_UNAVAILABLE_TOOLTIP:format(tradingPostLocation));

		if AreMonthlyActivitiesRestricted() then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddErrorLine(GameTooltip, MONTHLY_ACTIVITIES_RESTRICTED_TOOLTIP);
		end

		GameTooltip:Show();
	end
end

function EncounterJournal_OnLoad(self)
	self:SetTitle(ADVENTURE_JOURNAL);
	self:SetPortraitToAsset([[Interface\EncounterJournal\UI-EJ-PortraitIcon]]);
	self:RegisterEvent("EJ_LOOT_DATA_RECIEVED");
	self:RegisterEvent("EJ_DIFFICULTY_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PORTRAITS_UPDATED");
	self:RegisterEvent("SEARCH_DB_LOADED");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");

	self.encounter.freeHeaders = {};
	self.encounter.usedHeaders = {};

	self.encounter.overviewFrame = self.encounter.info.overviewScroll.child;
	self.encounter.overviewFrame.isOverview = true;
	self.encounter.overviewFrame.overviews = {};
	self.encounter.info.overviewScroll.ScrollBar.scrollStep = 30;

	self.encounter.infoFrame = self.encounter.info.detailsScroll.child;
	self.encounter.info.detailsScroll.ScrollBar.scrollStep = 30;

	self.encounter.info.overviewTab:Click();

	-- Bosses
	do
		local info = self.encounter.info;
		local scrollBox = info.BossesScrollBox;
		local scrollBar = info.BossesScrollBar;

		local view = CreateScrollBoxListLinearView();
		view:SetElementInitializer("EncounterBossButtonTemplate", function(button, elementData)
			button:Init(elementData);
		end);
		view:SetPadding(10,0,0,20,15);

		ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view);
	end

	-- Items
	do
		local view = CreateScrollBoxListLinearView();
		view:SetElementExtentCalculator(function(dataIndex, elementData)
			if elementData.header then
				return BOSS_LOOT_BUTTON_HEIGHT;
			elseif EncounterJournal.encounterID then
				return BOSS_LOOT_BUTTON_HEIGHT;
			else
				return INSTANCE_LOOT_BUTTON_HEIGHT;
			end
		end);
		view:SetElementFactory(function(factory, elementData)
			if elementData.header then
				factory("EncounterItemDividerTemplate", function(button, elementData)
					button:Init(elementData);
				end);
			else
				factory("EncounterItemTemplate", function(button, elementData)
					button:Init(elementData);
				end);
			end
		end);

		local lootContainer = self.encounter.info.LootContainer;
		local scrollBox = lootContainer.ScrollBox;
		local scrollBar = lootContainer.ScrollBar;
		ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view);
	end

	-- Search
	do
		local view = CreateScrollBoxListLinearView();
		view:SetElementInitializer("EncounterSearchLGTemplate", function(button, elementData)
			button:Init(elementData);
		end);

		local scrollBox = EncounterJournal.searchResults.ScrollBox;
		local scrollBar = EncounterJournal.searchResults.ScrollBar;
		local panExtent = buttonHeight;
		ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view);
	end

	-- Dungeons/Raids
	do
		local TopPad = 5;
		local Pad = 0;
		local Spacing = 15;
		local view = CreateScrollBoxListGridView(4, TopPad, Pad, Pad, Pad, Spacing, Spacing);

		local function Initializer(button, elementData)
			button.name:SetText(elementData.name);
			button.bgImage:SetTexture(elementData.buttonImage);
			button.instanceID = elementData.instanceID;
			button.tooltipTitle = elementData.name;
			button.tooltipText = elementData.description;
			button.link = elementData.link;
			button:Show();
			if ( EncounterJournal.localizeInstanceButton ) then
				EncounterJournal.localizeInstanceButton(button);
			end

			local modifiedInstanceInfo = C_ModifiedInstance.GetModifiedInstanceInfoFromMapID(elementData.mapID)
			if (modifiedInstanceInfo) then
				button.ModifiedInstanceIcon.info = modifiedInstanceInfo;
				button.ModifiedInstanceIcon.name = name;
				local atlas = button.ModifiedInstanceIcon:GetIconTextureAtlas();
				button.ModifiedInstanceIcon.Icon:SetAtlas(atlas, true)
				button.ModifiedInstanceIcon:SetSize(button.ModifiedInstanceIcon.Icon:GetSize());
			end
			button.ModifiedInstanceIcon:SetShown(modifiedInstanceInfo ~= nil);

		end

		view:SetElementInitializer("EncounterInstanceButtonTemplate", Initializer);

		ScrollUtil.InitScrollBoxWithScrollBar(self.instanceSelect.ScrollBox, self.instanceSelect.ScrollBar, view);
	end

	-- Dungeons/Raids description
	do
		local instance = self.encounter.instance;
		local loreScrollingFont = instance.LoreScrollingFont;
		loreScrollingFont:SetTextColor(CreateColor(.13, .07, .01));

		local scrollBox = loreScrollingFont:GetScrollBox();
		local scrollBar = instance.LoreScrollBar;
		ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, scrollBar);
	end

	do
		EncounterJournal.searchBox:SetSearchResultsFrame(EncounterJournal.searchResults);
		EncounterJournal.searchBox:SetScript("OnTextChanged", EncounterJournalSearchBox_OnTextChanged);
		EncounterJournal.searchBox:SetScript("OnEditFocusGained", EncounterJournalSearchBox_OnEditFocusGained);
		EncounterJournal.searchBox:SetScript("OnHide", EncounterJournalSearchBox_OnHide);
		EncounterJournal.searchBox.searchProgress.bar:SetScript("OnUpdate", 
			EncounterJournalSearchBoxSearchProgressBar_OnUpdate);
	end

	local homeData = {
		name = HOME,
		OnClick = function()
			if self.selectedTab then
				EJ_ContentTab_Select(self.selectedTab);
			else
				MonthlyActivitiesFrame_OpenFrame();
			end
		end,
	}
	NavBar_Initialize(self.navBar, "NavButtonTemplate", homeData, self.navBar.home, self.navBar.overflow);

	-- initialize tabs
	local instanceSelect = self.instanceSelect;
	PanelTemplates_SetNumTabs(self, 5);
	EJ_ContentTab_OnClick(self.MonthlyActivitiesTab);
	self.maxTabWidth = self:GetWidth() / #self.Tabs;

	self.LootJournalViewDropdown:SetWidth(180);
	self.instanceSelect.ExpansionDropdown:SetWidth(160);
	self.encounter.info.difficulty:SetWidth(100);

	local lootContainer = self.encounter.info.LootContainer;
	lootContainer.filter:SetPoint("TOPLEFT", self, "TOPRIGHT", -356, -77);

	lootContainer.slotFilter:SetWidth(90);
	lootContainer.slotFilter:SetPoint("LEFT", lootContainer.filter, "RIGHT", 10, 0);

	-- check if tabs are active
	local dungeonInstanceID = EJ_GetInstanceByIndex(1, false);
	if( not dungeonInstanceID ) then
		EJ_ContentTab_SetEnabled(self.dungeonsTab, false);
	end
	local raidInstanceID = EJ_GetInstanceByIndex(1, true);
	if( not raidInstanceID ) then
		EJ_ContentTab_SetEnabled(self.raidsTab, false);
	end
	-- set the monthly activities frame to open by default if available, or default to Suggested Content
	if C_PlayerInfo.IsTravelersLogAvailable() then
		MonthlyActivitiesFrame_OpenFrame();
	else
		EJSuggestFrame_OpenFrame();
	end

	-- add lock icon to tab if necessary
	if AreMonthlyActivitiesRestricted() then
		self.MonthlyActivitiesTab:SetText(CreateAtlasMarkup("activities-icon-lock", 17, 22) .. MONTHLY_ACTIVITIES_TAB);
	end
end

do
	local function GetClassFilter()
		local filterClassID, filterSpecID = EJ_GetLootFilter();
		return filterClassID;
	end
	
	local function GetSpecFilter()
		local filterClassID, filterSpecID = EJ_GetLootFilter();
		return filterSpecID;
	end
	
	local function SetClassAndSpecFilter(classID, specID)
		EJ_SetLootFilter(classID, specID);
		EncounterJournal_OnFilterChanged(EncounterJournal);
	end

	function EncounterJournal_SetupLootFilterDropdown(self)
		local dropdown = self.encounter.info.LootContainer.filter;
		ClassMenu.InitClassSpecDropdown(dropdown, GetClassFilter, GetSpecFilter, SetClassAndSpecFilter);
	end
end

local function GetLootSlotsPresent()
	local slotFilter = C_EncounterJournal.GetSlotFilter();
	C_EncounterJournal.ResetSlotFilter();

	local isLootSlotPresent = {};
	for index = 1, EJ_GetNumLoot() do
		local itemInfo = C_EncounterJournal.GetLootInfoByIndex(index);
		local filterType = itemInfo and itemInfo.filterType;
		if filterType then
			isLootSlotPresent[filterType] = true;
		end
	end
	C_EncounterJournal.SetSlotFilter(slotFilter);
	return isLootSlotPresent;
end

function EncounterJournal_SetupLootSlotFilterDropdown(self)
	local function IsSelected(filter)
		return C_EncounterJournal.GetSlotFilter() == filter;
	end

	local function SetSelected(filter)
		EncounterJournal_SetSlotFilterInternal(self, filter);
	end

	local dropdown = self.encounter.info.LootContainer.slotFilter;
	dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_EJ_LOOT_SLOT_FILTER");

		rootDescription:CreateRadio(ALL_INVENTORY_SLOTS, IsSelected, SetSelected, Enum.ItemSlotFilterType.NoFilter);

		local isLootSlotPresent = GetLootSlotsPresent();
		for filter, name in pairs(SlotFilterToSlotName) do
			if isLootSlotPresent[filter] or filter == slotFilter then
				rootDescription:CreateRadio(name, IsSelected, SetSelected, filter);
			end
		end
	end);
end

function EncounterJournal_SetupDifficultyDropdown(self)
	local dropdown = EncounterJournal.encounter.info.difficulty;

	local function IsSelected(difficultyID)
		return EJ_GetDifficulty() == difficultyID;
	end

	local function SetSelected(difficultyID)
		EncounterJournal_SelectDifficulty(self, difficultyID);
	end

	dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_EJ_DIFFICULTY");

		for index, difficultyID in ipairs(EJ_DIFFICULTIES) do
			if EJ_IsValidInstanceDifficulty(difficultyID) then
				local text = GetEJDifficultyString(difficultyID);
				rootDescription:CreateRadio(text, IsSelected, SetSelected, difficultyID);
			end
		end
	end);
end

local function SetLootJournalViewInternal(view)
	local activeViewPanel, inactiveViewPanel = EncounterJournal_GetLootJournalPanels(view);
	EncounterJournal.LootJournalViewDropdown:SetParent(activeViewPanel);
	EncounterJournal.LootJournalViewDropdown:SetPoint("TOPLEFT", 15, -9);

	-- if no previous view then it's the init, no need to change which frame is shown
	if EncounterJournal.lootJournalView then
		activeViewPanel:Show();
		inactiveViewPanel:Hide();
	end

	EncounterJournal.lootJournalView = view;
end

function EncounterJournal_SetupLootJournalViewDropdown(self)
	local function IsSelected(view)
		return EncounterJournal_GetLootJournalView() == view;
	end

	local function SetSelected(view)
		SetLootJournalViewInternal(view);
	end

	self.LootJournalViewDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_EJ_LOOT_JOURNAL");

		rootDescription:CreateRadio(LOOT_JOURNAL_ITEM_SETS, IsSelected, SetSelected, LOOT_JOURNAL_ITEM_SETS);
		rootDescription:CreateRadio(LOOT_JOURNAL_POWERS, IsSelected, SetSelected, LOOT_JOURNAL_POWERS);
	end);
end

local function ExpansionDropdown_SelectInternal(self, tier)
	EJ_SelectTier(tier);
	local instanceSelect = EncounterJournal.instanceSelect;
	EJ_ContentTab_SetEnabled(EncounterJournal.dungeonsTab, true);
	EJ_ContentTab_SetEnabled(EncounterJournal.raidsTab, true);

	local tierData = GetEJTierData(tier);
	instanceSelect.bg:SetAtlas(tierData.backgroundAtlas, true);

	-- Item Set tab uses the tier dropdown, but we do not want to show instances when changing tiers on that tab.
	if EncounterJournal_IsDungeonTabSelected(EncounterJournal) or EncounterJournal_IsRaidTabSelected(EncounterJournal) then
		EncounterJournal_ListInstances();
	else
		-- Only Shadowlands uses the 'Powers' tab, if switching off of that make sure to go back to Item Sets.
		EncounterJournal_CheckAndDisplayLootJournalViewDropdown(self);
	end
end

function EncounterJournal_SetupExpansionDropdown(self)
	local function IsSelected(tier)
		return tier == EJ_GetCurrentTier();
	end

	local function SetSelected(tier)
		ExpansionDropdown_SelectInternal(self, tier);
	end

	self.instanceSelect.ExpansionDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_EJ_EXPANSION");

		for tier = 1, EJ_GetNumTiers() do
			local text = EJ_GetTierInfo(tier);
			rootDescription:CreateRadio(text, IsSelected, SetSelected, tier);
		end
	end);
end

function EncounterItemTemplate_DividerFrameTipOnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.elementData.text, 1, 1, 1);
	GameTooltip:AddLine(self.elementData.helpText, nil, nil, nil, true);
	GameTooltip:Show();
end

function EncounterJournal_GetLootJournalView()
	return EncounterJournal.lootJournalView;
end

function EncounterJournal_SetLootJournalView(view)
	SetLootJournalViewInternal(view);
	EncounterJournal_SetupLootJournalViewDropdown(EncounterJournal);
end

function EncounterJournal_GetLootJournalPanels(view)
	local self = EncounterJournal;
	if not view then
		view = self.lootJournalView;
	end
	if view == LOOT_JOURNAL_POWERS then
		return self.LootJournal, self.LootJournalItems;
	else
		return self.LootJournalItems, self.LootJournal;
	end
end

function EncounterJournal_EnableExpansionDropdown()
	EncounterJournal.instanceSelect.ExpansionDropdown:Enable();
end

function EncounterJournal_DisableExpansionDropdown()
	EncounterJournal.instanceSelect.ExpansionDropdown:Disable();
end

function EncounterJournal_HasChangedContext(instanceID, instanceType, difficultyID)
	if ( instanceType == "none" ) then
		-- we've gone from a dungeon to the open world
		return EncounterJournal.lastInstance ~= nil;
	elseif ( instanceID ~= 0 and (instanceID ~= EncounterJournal.lastInstance or EncounterJournal.lastDifficulty ~= difficultyID) ) then
		-- dungeon or difficulty has changed
		return true;
	end
	return false;
end

function EncounterJournal_ResetDisplay(instanceID, instanceType, difficultyID)
	if ( instanceType == "none" ) then
		EncounterJournal.lastInstance = nil;
		EncounterJournal.lastDifficulty = nil;
		MonthlyActivitiesFrame_OpenFrame();
	else
		EJ_ContentTab_SelectAppropriateInstanceTab(instanceID);

		EncounterJournal_DisplayInstance(instanceID);
		EncounterJournal.lastInstance = instanceID;
		-- try to set difficulty to current instance difficulty
		if ( EJ_IsValidInstanceDifficulty(difficultyID) ) then
			EJ_SetDifficulty(difficultyID);
		end
		EncounterJournal.lastDifficulty = difficultyID;
	end
end

function EncounterJournal_OnShow(self)
	if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.EncounterJournal) then
		return;
	end

	if PlayerGetTimerunningSeasonID() then
		C_EncounterJournal.InitalizeSelectedTier();
	end
	C_EncounterJournal.OnOpen();

	self:RegisterEvent("SPELL_TEXT_UPDATE");
	if ( tonumber(GetCVar("advJournalLastOpened")) == 0 ) then
		SetCVar("advJournalLastOpened", GetServerTime() );
	end
	MainMenuMicroButton_HideAlert(EJMicroButton);
	MicroButtonPulseStop(EJMicroButton);

	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	EncounterJournal_LootUpdate();

	if not self.lootJournalView then
		EncounterJournal_SetLootJournalView(LOOT_JOURNAL_ITEM_SETS);
	end

	local instanceSelect = EncounterJournal.instanceSelect;

	--automatically navigate to the current dungeon if you are in one;
	local instanceID = AdventureGuideUtil.GetCurrentJournalInstance();
	local _, instanceType, difficultyID = GetInstanceInfo();
	if ( instanceID and EncounterJournal_HasChangedContext(instanceID, instanceType, difficultyID) ) then
		EncounterJournal_ResetDisplay(instanceID, instanceType, difficultyID);
		EncounterJournal.queuedPortraitUpdate = nil;
	elseif ( self.encounter.overviewFrame:IsShown() and EncounterJournal.overviewDefaultRole and not EncounterJournal.encounter.overviewFrame.linkSection ) then
		local spec, role;

		spec = GetSpecialization();
		if (spec) then
			role = GetSpecializationRoleEnum(spec);
		else
			role = Enum.LFGRole.Damage;
		end

		if ( EncounterJournal.overviewDefaultRole ~= role ) then
			EncounterJournal_ToggleHeaders(EncounterJournal.encounter.overviewFrame);
		end
	end

	if ( EncounterJournal.queuedPortraitUpdate ) then
		-- fixes portraits when switching between fullscreen and windowed mode
		EncounterJournal.queuedPortraitUpdate = false;
		EncounterJournal_UpdatePortraits();
	end

	local tierData = GetEJTierData(EJ_GetCurrentTier());
	if ( not EncounterJournal.suggestTab:IsEnabled() or EncounterJournal.suggestFrame:IsShown() ) then
		tierData = GetEJTierData(EJSuggestTab_GetPlayerTierIndex());
	end
	instanceSelect.bg:SetAtlas(tierData.backgroundAtlas, true);

	local shouldShowPowerTab, powerID = EJMicroButton:ShouldShowPowerTab();
	if shouldShowPowerTab then
		self.LootJournal:SetPendingPowerID(powerID);
		EJ_ContentTab_Select(EncounterJournal.LootJournalTab:GetID());
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_FIRST_RUNEFORGE_LEGENDARY_POWER, true);
	elseif EncounterJournal.instanceSelect:IsShown() then
		EJ_ContentTab_Select(self.selectedTab);
	end

	EncounterJournal_CheckAndDisplayTradingPostTab();
	EncounterJournal_CheckAndDisplaySuggestedContentTab();

	-- Request raid locks to show the defeated overlay for bosses the player has killed this week.
	RequestRaidInfo();

	EncounterJournal_SetupLootJournalViewDropdown(self);
	EncounterJournal_SetupExpansionDropdown(self);
	EncounterJournal_SetupLootFilterDropdown(self);
	EncounterJournal_SetupLootSlotFilterDropdown(self);
	EncounterJournal_SetupDifficultyDropdown(self);
end

function EncounterJournal_CheckAndDisplaySuggestedContentTab()
	EncounterJournal.dungeonsTab:ClearAllPoints();
	if PlayerGetTimerunningSeasonID() then
		PanelTemplates_HideTab(EncounterJournal, EncounterJournal.suggestTab:GetID());
		EncounterJournal.dungeonsTab:SetPoint("LEFT", EncounterJournal.MonthlyActivitiesTab, "RIGHT");
	else
		PanelTemplates_ShowTab(EncounterJournal, EncounterJournal.suggestTab:GetID());
		EncounterJournal.dungeonsTab:SetPoint("LEFT", EncounterJournal.suggestTab, "RIGHT", 3, 0);
	end
end

function EncounterJournal_CheckAndDisplayTradingPostTab()
	EncounterJournal.suggestTab:ClearAllPoints();
	if C_PlayerInfo.IsTradingPostAvailable() then
		PanelTemplates_ShowTab(EncounterJournal, EncounterJournal.MonthlyActivitiesTab:GetID());
		PanelTemplates_SetTabEnabled(EncounterJournal, EncounterJournal.MonthlyActivitiesTab:GetID(), C_PlayerInfo.IsTravelersLogAvailable());
		EncounterJournal.suggestTab:SetPoint("LEFT", EncounterJournal.MonthlyActivitiesTab, "RIGHT", 3, 0);
	else
		PanelTemplates_HideTab(EncounterJournal, EncounterJournal.MonthlyActivitiesTab:GetID());
		EncounterJournal.suggestTab:SetPoint("LEFT", EncounterJournal.MonthlyActivitiesTab, "LEFT");
	end
end

function EncounterJournal_OnHide(self)
	C_EncounterJournal.OnClose();
	self:UnregisterEvent("SPELL_TEXT_UPDATE");
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	self.searchBox:Clear();
	EJ_EndSearch();
	self.shouldDisplayDifficulty = nil;
end

function EncounterJournal_IsSuggestTabSelected(self)
	return self.selectedTab == self.suggestTab:GetID();
end

function EncounterJournal_IsDungeonTabSelected(self)
	return self.selectedTab == self.dungeonsTab:GetID();
end

function EncounterJournal_IsRaidTabSelected(self)
	return self.selectedTab == self.raidsTab:GetID();
end

function EncounterJournal_IsLootTabSelected(self)
	return self.selectedTab == self.LootJournalTab:GetID();
end

local function EncounterJournal_IsHeaderTypeOverview(headerType)
	return headerType == EJ_HTYPE_OVERVIEW;
end

local function EncounterJournal_GetRootAfterOverviews(rootSectionID)
	local nextSectionID = rootSectionID;

	repeat
		local info = C_EncounterJournal.GetSectionInfo(nextSectionID);
		local isOverview = info and EncounterJournal_IsHeaderTypeOverview(info.headerType);
		if isOverview then
			nextSectionID = info.siblingSectionID;
		end
	until not isOverview;

	return nextSectionID;
end

local function EncounterJournal_CheckForOverview(rootSectionID)
	local sectionInfo = C_EncounterJournal.GetSectionInfo(rootSectionID);
	return sectionInfo and EncounterJournal_IsHeaderTypeOverview(sectionInfo.headerType);
end

local function EncounterJournal_SearchForOverview(instanceID)
	local bossIndex = 1;
	local _, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex);
	while bossID do
		local _, _, _, rootSectionID = EJ_GetEncounterInfo(bossID);

		if (EncounterJournal_CheckForOverview(rootSectionID)) then
			return true;
		end

		bossIndex = bossIndex + 1;
		_, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex);
	end

	return false;
end

local function EncounterJournal_UpdateSpellText(self, spellID)
	if self.encounter.encounterID then
		local rootSectionID = select(4, EJ_GetEncounterInfo(self.encounter.encounterID));
		if (EncounterJournal_CheckForOverview(rootSectionID)) then
			if self.encounter.overviewFrame.spellID == spellID then
				local sectionInfo = C_EncounterJournal.GetSectionInfo(rootSectionID);
				EncounterJournal_SetBullets(self.encounter.overviewFrame.overviewDescription, sectionInfo.description, false);
			end
		end
	end

	-- Overview frames
	for overviewIndex, overview in ipairs(self.encounter.overviewFrame.overviews) do
		if overview.spellID == spellID then
			local sectionInfo = C_EncounterJournal.GetSectionInfo(overview.sectionID);
			EncounterJournal_SetDescriptionWithBullets(overview, sectionInfo.description);
		end
	end

	-- Section info
	EncounterJournal.encounter.infoFrame.updatingSpells = true;
	for headerIndex, header in ipairs(self.encounter.usedHeaders) do
		if header.spellID == spellID then
			local sectionInfo = C_EncounterJournal.GetSectionInfo(header.myID);
			local description = sectionInfo.description:gsub("|cffffffff(.-)|r", "%1");
			header.description:SetText(description);
			if EJ_section_openTable[header.myID] then
				EncounterJournal_ToggleHeaders(header);
				EncounterJournal_ToggleHeaders(header);
			end
		end
	end
	EncounterJournal.encounter.infoFrame.updatingSpells = nil;
end

function EncounterJournal_OnEvent(self, event, ...)
	if  event == "EJ_LOOT_DATA_RECIEVED" then
		local itemID = ...
		if itemID and not EJ_IsLootListOutOfDate() then
			EncounterJournal_LootCallback(itemID);

			if EncounterJournal.searchResults:IsShown() then
				EncounterJournal_SearchUpdate();
			elseif EncounterJournal.searchBox:IsSearchPreviewShown() then
				EncounterJournal_UpdateSearchPreview();
			end
		else
			EncounterJournal_LootUpdate();
		end
	elseif event == "EJ_DIFFICULTY_UPDATE" then
		--fix the difficulty buttons
		EncounterJournal_UpdateDifficulty(...);
	elseif event == "UNIT_PORTRAIT_UPDATE" then
		local unit = ...;
		if not unit then
			EncounterJournal_UpdatePortraits();
		end
	elseif event == "PORTRAITS_UPDATED" then
		EncounterJournal_UpdatePortraits();
	elseif event == "SEARCH_DB_LOADED" then
		EncounterJournal_RestartSearchTracking();
	elseif event == "UI_MODEL_SCENE_INFO_UPDATED" then
		local forceUpdate = true;
		EncounterJournal_ShowCreatures(forceUpdate);
	elseif event == "SPELL_TEXT_UPDATE" then
		local spellID = ...;
		EncounterJournal_UpdateSpellText(self, spellID);
	end
end

function EncounterJournal_UpdateDifficulty(newDifficultyID)
	if IsEJDifficulty(newDifficultyID) then
		EncounterJournal_SetupDifficultyDropdown(EncounterJournal);
		EncounterJournal_Refresh();
	end
end

function EncounterJournal_GetCreatureButton(index)
	if index > MAX_CREATURES_PER_ENCOUNTER then
		return nil;
	end

	local self = EncounterJournal.encounter.info;
	local button = self.creatureButtons[index];
	if (not button) then
		button = CreateFrame("BUTTON", nil, self, "EncounterCreatureButtonTemplate");
		button:SetPoint("TOPLEFT", self.creatureButtons[index-1], "BOTTOMLEFT", 0, 8);
		self.creatureButtons[index] = button;
	end
	return button;
end

function EncounterJournal_FindCreatureButtonForDisplayInfo(displayInfo)
	for index, button in ipairs(EncounterJournal.encounter.info.creatureButtons) do
		if button.displayInfo == displayInfo then
			return button;
		end
	end

	return nil;
end

function EncounterJournal_UpdatePortraits()
	if ( EncounterJournal:IsShown() ) then
		local creatures = EncounterJournal.encounter.info.creatureButtons;
		for i = 1, #creatures do
			local button = creatures[i];
			if ( button and button:IsShown() ) then
				SetPortraitTextureFromCreatureDisplayID(button.creature, button.displayInfo);
			else
				break;
			end
		end
		local usedHeaders = EncounterJournal.encounter.usedHeaders;
		for _, header in pairs(usedHeaders) do
			if ( header.button.portrait.displayInfo ) then
				SetPortraitTextureFromCreatureDisplayID(header.button.portrait.icon, header.button.portrait.displayInfo);
			end
		end
	else
		EncounterJournal.queuedPortraitUpdate = true;
	end
end

local infiniteLoopPolice = false; --design might make a tier that has no instances at all sigh
function EncounterJournal_ListInstances()
	local instanceSelect = EncounterJournal.instanceSelect;

	EncounterJournal_SetupExpansionDropdown(EncounterJournal);
	EncounterJournal.encounter:Hide();
	instanceSelect:Show();

	local dataIndex = 1;
	local showRaid = EncounterJournal_IsRaidTabSelected(EncounterJournal);
	local instanceID, name, description, _, buttonImage, _, _, _, link, _, mapID = EJ_GetInstanceByIndex(dataIndex, showRaid);

	--No instances in this tab
	if not instanceID and not infiniteLoopPolice then
		--disable this tab and select the other one.
		infiniteLoopPolice = true;
		if ( showRaid ) then
			EJ_ContentTab_SetEnabled(EncounterJournal.raidsTab, false);
			EJ_ContentTab_Select(EncounterJournal.dungeonsTab:GetID());
		else
			EJ_ContentTab_SetEnabled(EncounterJournal.dungeonsTab, false);
			EJ_ContentTab_Select(EncounterJournal.raidsTab:GetID());
		end
		return;
	end
	infiniteLoopPolice = false;

	local dataProvider = CreateDataProvider();
	while instanceID ~= nil do
		dataProvider:Insert({
			instanceID = instanceID,
			name = name,
			description = description,
			buttonImage = buttonImage,
			link = link,
			mapID = mapID,
		});

		dataIndex = dataIndex + 1;
		instanceID, name, description, _, buttonImage, _, _, _, link, _, mapID = EJ_GetInstanceByIndex(dataIndex, showRaid);
	end

	instanceSelect.ScrollBox:Show(); -- Scrollbox children will not have resolvable rects unless the scrollbox is shown first
	instanceSelect.ScrollBox:SetDataProvider(dataProvider);

	--check if the other tab is empty
	local otherInstanceID = EJ_GetInstanceByIndex(1, not showRaid);
	--No instances in the other tab
	if not otherInstanceID then
		--disable the other tab.
		if ( showRaid ) then
			EJ_ContentTab_SetEnabled(EncounterJournal.dungeonsTab, false);
		else
			EJ_ContentTab_SetEnabled(EncounterJournal.raidsTab, false);
		end
	end
end

function EncounterJournalInstanceButton_OnClick(self)
	NavBar_Reset(EncounterJournal.navBar);
	EncounterJournal_DisplayInstance(EncounterJournal.instanceID);
end

local function EncounterJournal_SetupIconFlags(sectionID, infoHeaderButton)
	local iconFlags = C_EncounterJournal.GetSectionIconFlags(sectionID);
	local textRightAnchor;

	for index, icon in ipairs(infoHeaderButton.icons) do
		local iconFlag = iconFlags and iconFlags[index];

		icon:SetShown(iconFlag ~= nil);

		if iconFlag then
			textRightAnchor = icon;

			icon:Show();
			icon.tooltipTitle = _G["ENCOUNTER_JOURNAL_SECTION_FLAG"..iconFlag];
			icon.tooltipText = _G["ENCOUNTER_JOURNAL_SECTION_FLAG_DESCRIPTION"..iconFlag];

			EncounterJournal_SetFlagIcon(icon.icon, iconFlag);
		end
	end

	if textRightAnchor then
		infoHeaderButton.title:SetPoint("RIGHT", textRightAnchor, "LEFT", -5, 0);
	else
		infoHeaderButton.title:SetPoint("RIGHT", infoHeaderButton, "RIGHT", -5, 0);
	end
end

local function UpdateDifficultyAnchoring(difficultyFrame)
	local infoFrame = difficultyFrame:GetParent();
	infoFrame.reset:ClearAllPoints();

	if difficultyFrame:IsShown() then
		infoFrame.reset:SetPoint("RIGHT", difficultyFrame, "LEFT", -12, -3);
	else
		infoFrame.reset:SetPoint("TOPRIGHT", infoFrame, "TOPRIGHT", -21, -10);
	end
end

local function UpdateDifficultyVisibility()
	local shouldDisplayDifficulty = select(9, EJ_GetInstanceInfo());

	-- As long as the current tab isn't the model tab, which always suppresses the difficulty, then update the shown state.
	local info = EncounterJournal.encounter.info;
	info.difficulty:SetShown(shouldDisplayDifficulty and (info.tab ~= 4));

	UpdateDifficultyAnchoring(info.difficulty);
end

local IconIndexByDifficulty = {
	[15] = 3, -- Heroic
	[16] = 12, -- Mythic
};

local function GetIconIndexForDifficultyID(difficultyID)
	return IconIndexByDifficulty[difficultyID];
end

local function PopulateBossDataProvider()
	local dataProvider = CreateDataProvider();

	local index = 1;
	while index do
		local name, description, bossID, rootSectionID, link = EJ_GetEncounterInfoByIndex(index);
		if bossID and bossID > 0 then
			dataProvider:Insert({index=index, name=name, description=description, bossID=bossID, rootSectionID=rootSectionID, link=link});
			index = index + 1;
		else
			break;
		end
	end

	return dataProvider;
end

function EncounterJournal_DisplayInstance(instanceID, noButton)
	EJ_HideNonInstancePanels();

	local difficultyID = EJ_GetDifficulty();

	local self = EncounterJournal.encounter;
	EncounterJournal.instanceSelect:Hide();
	EncounterJournal.encounter:Show();
	EncounterJournal.creatureDisplayID = 0;

	EncounterJournal.instanceID = instanceID;
	EncounterJournal.encounterID = nil;
	EJ_SelectInstance(instanceID);
	EncounterJournal_LootUpdate();
	EncounterJournal_ClearDetails();

	local instanceName, description, bgImage, _, loreImage, buttonImage, dungeonAreaMapID = EJ_GetInstanceInfo();

	self.instance.title:SetText(instanceName);
	self.instance.titleBG:SetWidth(self.instance.title:GetStringWidth() + 80);
	self.instance.loreBG:SetTexture(loreImage);

	self.info.instanceTitle:ClearAllPoints();
	local iconIndex = GetIconIndexForDifficultyID(difficultyID);
	local hasDifficultyIcon = iconIndex ~= nil;
	self.info.difficultyIcon:SetShown(hasDifficultyIcon);
	if hasDifficultyIcon then
		self.info.instanceTitle:SetPoint("LEFT", self.info.difficultyIcon, "RIGHT", -6, -0);
		EncounterJournal_SetFlagIcon(self.info.difficultyIcon, iconIndex);
	else
		self.info.instanceTitle:SetPoint("TOPLEFT", 65, -20);
	end

	self.info.instanceTitle:SetText(instanceName);
	self.instance.mapButton:SetShown(dungeonAreaMapID and dungeonAreaMapID > 0);

	local loreScrollingFont = self.instance.LoreScrollingFont;
	loreScrollingFont:SetText(description);

	self.instance.LoreScrollBar:SetShown(loreScrollingFont:HasScrollableExtent());


	self.info.instanceButton.instanceID = instanceID;
	self.info.instanceButton.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
	self.info.instanceButton.icon:SetTexture(buttonImage);

	self.info.model.dungeonBG:SetTexture(bgImage);

	UpdateDifficultyVisibility();

	local dataProvider = PopulateBossDataProvider();
	local hasBossAbilities = dataProvider:FindByPredicate(function(elementData)
		return elementData.rootSectionID > 0;
	end);
	self.info.BossesScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.overviewTab, true);
	--disable model tab and abilities tab, no boss selected
	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.modelTab, false);
	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.bossTab, false);
	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.lootTab, C_EncounterJournal.InstanceHasLoot());

	if (EncounterJournal_SearchForOverview(instanceID)) then
		EJ_Tabs[1].frame = "overviewScroll";
		EJ_Tabs[3].frame = "detailsScroll"; -- flip them back
		self.info[EJ_Tabs[1].button].tooltip = OVERVIEW;
		self.info[EJ_Tabs[3].button]:Show();
		self.info[EJ_Tabs[4].button]:SetPoint("TOP", self.info[EJ_Tabs[3].button], "BOTTOM", 0, 2)
		self.info.overviewFound = true;
	else
		EJ_Tabs[1].frame = "detailsScroll";
		EJ_Tabs[3].frame = "overviewScroll"; -- flip these so detailsScroll won't get hidden, overview will never be shown here
		if ( hasBossAbilities ) then
			self.info[EJ_Tabs[1].button].tooltip = ABILITIES;
		else
			self.info[EJ_Tabs[1].button].tooltip = OVERVIEW;
		end
		self.info[EJ_Tabs[3].button]:Hide();
		self.info[EJ_Tabs[4].button]:SetPoint("TOP", self.info[EJ_Tabs[2].button], "BOTTOM", 0, 2)
		self.info.overviewFound = false;
	end

	self.instance:Show();
	self.info.overviewScroll:Hide();
	self.info.detailsScroll:Hide();
	self.info.LootContainer:Hide();
	self.info.rightShadow:Hide();

	if (self.info.tab < 3) then
		self.info[EJ_Tabs[self.info.tab].button]:Click()
	else
		self.info.overviewTab:Click();
	end

	if not noButton then
		local buttonData = {
			id = instanceID,
			name = instanceName,
			OnClick = EJNAV_RefreshInstance,
			listFunc = EJNAV_GetInstanceList,
		}
		NavBar_AddButton(EncounterJournal.navBar, buttonData);
	end
end

function EncounterJournal_DisplayEncounter(encounterID, noButton)
	local self = EncounterJournal.encounter;

	local ename, description, _, rootSectionID = EJ_GetEncounterInfo(encounterID);
	if (EncounterJournal.encounterID == encounterID) then
		--navbar is already set to the right button, don't add another
		noButton = true;
	elseif (EncounterJournal.encounterID) then
		--make sure the previous navbar button is the instance button
		NavBar_OpenTo(EncounterJournal.navBar, EncounterJournal.instanceID);
	end
	EncounterJournal.encounterID = encounterID;
	EJ_SelectEncounter(encounterID);
	EncounterJournal_LootUpdate();
	EncounterJournal_ClearDetails();

	self.info.encounterTitle:SetText(ename);

	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.overviewTab, (rootSectionID > 0));
	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.lootTab, C_EncounterJournal.InstanceHasLoot());

	local sectionInfo = C_EncounterJournal.GetSectionInfo(rootSectionID);

	local overviewFound;
	if (sectionInfo and EncounterJournal_IsHeaderTypeOverview(sectionInfo.headerType)) then
		self.overviewFrame.spellID = sectionInfo.spellID;
		self.overviewFrame.loreDescription:SetHeight(0);
		self.overviewFrame.loreDescription:SetWidth(self.overviewFrame:GetWidth() - 5);
		self.overviewFrame.loreDescription:SetText(description);
		self.overviewFrame.overviewDescription:SetWidth(self.overviewFrame:GetWidth() - 5);
		self.overviewFrame.overviewDescription.Text:SetWidth(self.overviewFrame:GetWidth() - 5);
		EncounterJournal_SetBullets(self.overviewFrame.overviewDescription, sectionInfo.description, false);
		local bulletHeight = 0;
		if (self.overviewFrame.Bullets and #self.overviewFrame.Bullets > 0) then
			for i = 1, #self.overviewFrame.Bullets do
				bulletHeight = bulletHeight + self.overviewFrame.Bullets[i]:GetHeight();
			end
			local bullet = self.overviewFrame.Bullets[1];
			bullet:ClearAllPoints();
			bullet:SetPoint("TOPLEFT", self.overviewFrame.overviewDescription, "BOTTOMLEFT", 0, -9);
		end
		self.overviewFrame.descriptionHeight = self.overviewFrame.loreDescription:GetHeight() + self.overviewFrame.overviewDescription:GetHeight() + bulletHeight + 42;
		self.overviewFrame.rootOverviewSectionID = rootSectionID;
		rootSectionID = EncounterJournal_GetRootAfterOverviews(rootSectionID);
		overviewFound = true;
	end

	self.infoFrame.description:SetWidth(self.infoFrame:GetWidth() -5);
	self.infoFrame.description:SetText(description);
	self.infoFrame.descriptionHeight = self.infoFrame.description:GetHeight();

	self.infoFrame.encounterID = encounterID;
	self.infoFrame.rootSectionID = rootSectionID;
	self.infoFrame.expanded = false;

	do
		local dataProvider = PopulateBossDataProvider();
		self.info.BossesScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	end

	-- Setup Creatures
	local id, name, displayInfo, iconImage, uiModelSceneID;
	for i=1,MAX_CREATURES_PER_ENCOUNTER do
		id, name, description, displayInfo, iconImage, uiModelSceneID = EJ_GetCreatureInfo(i);

		if id then
			local button = EncounterJournal_GetCreatureButton(i);
			SetPortraitTextureFromCreatureDisplayID(button.creature, displayInfo);
			button.name = name;
			button.id = id;
			button.description = description;
			button.displayInfo = displayInfo;
			button.uiModelSceneID = uiModelSceneID;
		end
	end

	--enable model and abilities tab
	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.modelTab, true);
	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.bossTab, true);

	if (overviewFound) then
		EncounterJournal_ToggleHeaders(self.overviewFrame);
		self.overviewFrame:Show();
	else
		self.overviewFrame:Hide();
	end

	EncounterJournal_ToggleHeaders(self.infoFrame);

	self:Show();

	--make sure we stay on the tab we were on
	self.info[EJ_Tabs[self.info.tab].button]:Click()

	if not noButton then
		local buttonData = {
			id = encounterID,
			name = ename,
			OnClick = EJNAV_RefreshEncounter,
			listFunc = EJNAV_GetEncounterList,
		}
		NavBar_AddButton(EncounterJournal.navBar, buttonData);
	end
end

function EncounterJournal_DisplayCreature(self, forceUpdate)
	if EncounterJournal.encounter.info.shownCreatureButton then
		EncounterJournal.encounter.info.shownCreatureButton:Enable();
	end

	local modelScene = EncounterJournal.encounter.info.model;

	if self.displayInfo and (EncounterJournal.creatureDisplayID ~= self.displayInfo or forceUpdate) then
		modelScene:SetFromModelSceneID(self.uiModelSceneID, forceUpdate);

		local creature = modelScene:GetActorByTag("creature");
		if creature then
			creature:SetModelByCreatureDisplayID(self.displayInfo, forceUpdate);
		end

		EncounterJournal.creatureDisplayID = self.displayInfo;
	end

	modelScene.imageTitle:SetText(self.name);

	local isGMClient = IsGMClient();
	modelScene.modelName:SetShown(isGMClient);
	modelScene.modelDisplayId:SetShown(isGMClient);
	modelScene.modelNameLabel:SetShown(isGMClient);
	modelScene.modelDisplayIdLabel:SetShown(isGMClient);

	if (isGMClient) then
		local numActors = modelScene:GetNumActors();
		local actor = (numActors > 0) and modelScene:GetActorAtIndex(1);
		local displayID = actor and actor:GetModelFileID() or "";
		local name = actor and actor:GetModelPath() or "";

		modelScene.modelName:SetText(name);
		modelScene.modelDisplayId:SetText(displayID);

		if (modelScene.modelName:IsTruncated()) then
			local pos = string.find(name, "\\[^\\]*$");
			name = name:sub(1, pos - 1) .. "\\\n" .. name:sub(pos + 1);
			modelScene.modelName:SetText(name);
		end
	end

	self:Disable();
	EncounterJournal.encounter.info.shownCreatureButton = self;

	-- Ensure that the models tab properly updates the selected button (it's possible to display creatures here
	-- that only have a portrait/creature button on the abilities tab).
	local creatureButton = EncounterJournal_FindCreatureButtonForDisplayInfo(self.displayInfo);
	if creatureButton and creatureButton:IsShown() then
		creatureButton:Click();
	end
end

function EncounterJournal_ShowCreatures(forceUpdate)
	for index, creatureButton in ipairs(EncounterJournal.encounter.info.creatureButtons) do
		if (creatureButton.displayInfo) then
			creatureButton:Show();
			if index == 1 then
				EncounterJournal_DisplayCreature(creatureButton, forceUpdate);
			end
		end
	end
end

function EncounterJournal_HideCreatures(clearDisplayInfo)
	for index, creatureButton in ipairs(EncounterJournal.encounter.info.creatureButtons) do
		creatureButton:Hide();

		if clearDisplayInfo then
			creatureButton.displayInfo = nil;
			creatureButton.uiModelSceneID = nil;
		end
	end
end

local toggleTempList = {};
local headerCount = 0;

function EncounterJournal_UpdateButtonState(self)
	local oldtex = self.textures.expanded;
	if self:GetParent().expanded then
		self.tex = self.textures.expanded;
		oldtex = self.textures.collapsed;
		self.expandedIcon:SetTextColor(PAPER_FRAME_EXPANDED_COLOR:GetRGB());
		self.title:SetTextColor(PAPER_FRAME_EXPANDED_COLOR:GetRGB());
	else
		self.tex = self.textures.collapsed;
		self.expandedIcon:SetTextColor(PAPER_FRAME_COLLAPSED_COLOR:GetRGB());
		self.title:SetTextColor(PAPER_FRAME_COLLAPSED_COLOR:GetRGB());
	end

	oldtex.up[1]:Hide();
	oldtex.up[2]:Hide();
	oldtex.up[3]:Hide();
	oldtex.down[1]:Hide();
	oldtex.down[2]:Hide();
	oldtex.down[3]:Hide();


	self.tex.up[1]:Show();
	self.tex.up[2]:Show();
	self.tex.up[3]:Show();
	self.tex.down[1]:Hide();
	self.tex.down[2]:Hide();
	self.tex.down[3]:Hide();
end

function EncounterJournal_OnClick(self)
	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		if self.link then
			ChatEdit_InsertLink(self.link);
		end
		return;
	end

	EncounterJournal_ToggleHeaders(self:GetParent())
	self:GetScript("OnShow")(self);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function EncounterJournal_OnHyperlinkEnter(self, link, text, fontString, left, bottom, width, height)
	self.tooltipFrame:SetOwner(self, "ANCHOR_PRESERVE");
	self.tooltipFrame:ClearAllPoints();
	self.tooltipFrame:SetPoint("BOTTOMLEFT", fontString, "TOPLEFT", left + width, bottom);
	self.tooltipFrame:SetHyperlink(link, EJ_GetDifficulty(), EJ_GetContentTuningID());
end

function EncounterJournal_CleanBullets(self, start, keep)
	if (not self.Bullets) then return end
    start = start or 1;
	for i = start, #self.Bullets do
		self.Bullets[i]:Hide();
		if (not keep) then
			if (not self.BulletCache) then
				self.BulletCache = {};
			end
			self.Bullets[i]:ClearAllPoints();
			tinsert(self.BulletCache, self.Bullets[i]);
			self.Bullets[i] = nil;
		end
	end
end

function EncounterJournal_SetBullets(object, description, hideBullets)
	local parent = object:GetParent();

	if (not string.find(description, "$bullet;")) then
		object.Text:SetText(description);
		object.textString = description;
		object:SetHeight(object.Text:GetContentHeight());
		EncounterJournal_CleanBullets(parent);
		return;
	end

	local desc = strtrim(string.match(description, "(.-)$bullet;"));

	if (desc) then
		object.Text:SetText(desc);
		object.textString = desc;
		object:SetHeight(object.Text:GetContentHeight());
	end

	local bullets = {}
	for v in string.gmatch(description,"$bullet;([^$]+)") do
		tinsert(bullets, v);
	end

	local k = 1;
	local skipped = 0;
	for j = 1,#bullets do
		local text = strtrim(bullets[j]).."|n|n";
		if (text and text ~= "") then
			local bullet;
			bullet = parent.Bullets and parent.Bullets[k];
			if (not bullet) then
				if (parent.BulletCache and #parent.BulletCache > 0) then
					-- We only need to check for BulletCache because the BulletCache is created when we clean the bullets, so the BulletCache existing also means the Bullets exist.
					parent.Bullets[k] = tremove(parent.BulletCache);
					bullet = parent.Bullets[k];
				else
					bullet = CreateFrame("Frame", nil, parent, "EncounterOverviewBulletTemplate");
				end
				bullet:SetWidth(parent:GetWidth() - 13);
				bullet.Text:SetWidth(bullet:GetWidth() - 26);
			end
			bullet:ClearAllPoints();
			if (k == 1) then
				if (parent.button) then
					bullet:SetPoint("TOPLEFT", parent.button, "BOTTOMLEFT", 13, -9 - object:GetHeight());
				else
					bullet:SetPoint("TOPLEFT", parent, "TOPLEFT", 13, -9 - object:GetHeight());
				end
			else
				bullet:SetPoint("TOP", parent.Bullets[k-1], "BOTTOM", 0, 0);
			end
			bullet.Text:SetText(text);
			if (bullet.Text:GetContentHeight() ~= 0) then
				bullet:SetHeight(bullet.Text:GetContentHeight());
			end

			if (hideBullets) then
				bullet:Hide();
			else
				bullet:Show();
			end
			k = k + 1;
		else
			skipped = skipped + 1;
		end
	end

	EncounterJournal_CleanBullets(parent, (#bullets - skipped) + 1);
end

function EncounterJournal_SetDescriptionWithBullets(infoHeader, description)
	EncounterJournal_SetBullets(infoHeader.overviewDescription, description, true);

	infoHeader.descriptionBG:ClearAllPoints();
	infoHeader.descriptionBG:SetPoint("TOPLEFT", infoHeader.button, "BOTTOMLEFT", 1, 0);
	if (infoHeader.Bullets and #infoHeader.Bullets > 0) then
		infoHeader.descriptionBG:SetPoint("BOTTOMRIGHT", infoHeader.Bullets[#infoHeader.Bullets], -1, -11);
	else
		infoHeader.descriptionBG:SetPoint("BOTTOMRIGHT", infoHeader.overviewDescription, 9, -11);
	end
	infoHeader.descriptionBG:Hide();
	infoHeader.descriptionBGBottom:Hide();
end

function EncounterJournal_SetUpOverview(self, overviewSectionID, index)
	local infoHeader;
	if not self.overviews[index] then -- create a new header;
		infoHeader = CreateFrame("FRAME", "EncounterJournalOverviewInfoHeader"..index, EncounterJournal.encounter.overviewFrame, "EncounterInfoTemplate");
		infoHeader.description:Hide();
		infoHeader.overviewDescription:Hide();
		infoHeader.descriptionBG:Hide();
		infoHeader.descriptionBGBottom:Hide();
		infoHeader.button.abilityIcon:Hide();
		infoHeader.button.portrait:Hide();
		infoHeader.button.portrait.name = nil;
		infoHeader.button.portrait.displayInfo = nil;
		infoHeader.button.portrait.uiModelSceneID = nil;
		infoHeader.button.icon2:Hide();
		infoHeader.button.icon3:Hide();
		infoHeader.button.icon4:Hide();
		infoHeader.overviewIndex = index;
		infoHeader.isOverview = true;

		local textLeftAnchor = infoHeader.button.expandedIcon;
		local textRightAnchor = infoHeader.button.icon1;
		infoHeader.button.title:SetPoint("LEFT", textLeftAnchor, "RIGHT", 5, 0);
		infoHeader.button.title:SetPoint("RIGHT", textRightAnchor, "LEFT", -5, 0);

		self.overviews[index] = infoHeader;
	else
		infoHeader = self.overviews[index];
	end

	infoHeader.button.expandedIcon:SetText("+");
	infoHeader.expanded = false;

	infoHeader:ClearAllPoints();
	if (index == 1) then
		infoHeader:SetPoint("TOPLEFT", 0, -15 - self.descriptionHeight - SECTION_BUTTON_OFFSET);
		infoHeader:SetPoint("TOPRIGHT", 0, -15 - self.descriptionHeight - SECTION_BUTTON_OFFSET);
	else
		infoHeader:SetPoint("TOPLEFT", self.overviews[index-1], "BOTTOMLEFT", 0, -9);
		infoHeader:SetPoint("TOPRIGHT", self.overviews[index-1], "BOTTOMRIGHT", 0, -9);
	end

	infoHeader.description:Hide();

	for i = 1, #infoHeader.Bullets do
		infoHeader.Bullets[i]:Hide();
	end

	wipe(infoHeader.Bullets);
	local sectionInfo = C_EncounterJournal.GetSectionInfo(overviewSectionID);

	if (not sectionInfo) then
		infoHeader:Hide();
		return;
	end

	EncounterJournal_SetupIconFlags(overviewSectionID, infoHeader.button);

	infoHeader.spellID = sectionInfo.spellID;
	infoHeader.button.title:SetText(sectionInfo.title);
	infoHeader.button.link = sectionInfo.link;
	infoHeader.sectionID = overviewSectionID;

	infoHeader.overviewDescription:SetWidth(infoHeader:GetWidth() - 20);
	EncounterJournal_SetDescriptionWithBullets(infoHeader, sectionInfo.description);
	infoHeader:Show();
end

local function GetOverviewSections(rootOverviewSectionID)
	local overviewSections = {};
	local overviewInfo = C_EncounterJournal.GetSectionInfo(rootOverviewSectionID);
	local nextSectionID = overviewInfo.firstChildSectionID;

	while nextSectionID do
		local currentSectionID = nextSectionID; -- cache current one to get icons
		local sectionInfo = C_EncounterJournal.GetSectionInfo(nextSectionID);
		nextSectionID = sectionInfo and sectionInfo.siblingSectionID;

		if sectionInfo then
			if not sectionInfo.filteredByDifficulty then
				local iconFlags = C_EncounterJournal.GetSectionIconFlags(currentSectionID);
				overviewSections[currentSectionID] = iconFlags and iconFlags[1] or NONE_FLAG;
			end
		end
	end

	return overviewSections;
end

local function GetOverviewSectionIDForRole(overviewSections, role)
	for sectionID, flag in pairs(overviewSections) do
		if (flag == flagsByRole[role]) then
			return sectionID;
		end
	end
	return nil;
end

local function SetUpSectionsForRole(self, overviewSections, role, currentIndex)
	local roleSectionID = GetOverviewSectionIDForRole(overviewSections, role);
	while ( roleSectionID ) do
		EncounterJournal_SetUpOverview(self, roleSectionID, currentIndex);
		currentIndex = currentIndex + 1;
		overviewSections[roleSectionID] = nil;
		roleSectionID = GetOverviewSectionIDForRole(overviewSections, role);
	end
	return currentIndex;
end

function EncounterJournal_ToggleHeaders(self, doNotShift)
	local numAdded = 0;
	local infoHeader, parentID, _;
	local hWidth = self:GetWidth();
	local nextSectionID;
	local topLevelSection = false;

	local isOverview = self.isOverview;

	local hideHeaders;
	if (not self.isOverview or (self.isOverview and self.overviewIndex)) then
		self.expanded = not self.expanded;
		hideHeaders = not self.expanded;
	end

	if hideHeaders then
		self.button.expandedIcon:SetText("+");
		self.description:Hide();
		if (self.overviewDescription) then
			self.overviewDescription:Hide();
		end
		self.descriptionBG:Hide();
		self.descriptionBGBottom:Hide();

		EncounterJournal_CleanBullets(self, nil, true);

		if (self.overviewIndex) then
			local overview = EncounterJournal.encounter.overviewFrame.overviews[self.overviewIndex + 1];

			if (overview) then
				overview:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -9);
			end
		else
			EncounterJournal_ClearChildHeaders(self);
		end
	else
		if (not isOverview) then
			if strlen(self.description:GetText() or "") > 0 then
				self.description:Show();
				if (self.overviewDescription) then
					self.overviewDescription:Hide();
				end
				if self.button then
					self.descriptionBG:Show();
					self.descriptionBGBottom:Show();
					self.button.expandedIcon:SetText("-");
				end
			elseif self.button then
				self.description:Hide();
				if (self.overviewDescription) then
					self.overviewDescription:Hide();
				end
				self.descriptionBG:Hide();
				self.descriptionBGBottom:Hide();
				self.button.expandedIcon:SetText("-");
			end
		else
			if (self.overviewIndex) then
				self.button.expandedIcon:SetText("-");
				for i = 1, #self.Bullets do
					self.Bullets[i]:Show();
				end
				self.description:Hide();
				self.overviewDescription:Show();
				self.descriptionBG:Show();
				self.descriptionBGBottom:Show();

				local overview = EncounterJournal.encounter.overviewFrame.overviews[self.overviewIndex + 1];

				if (overview) then
					if (self.Bullets and #self.Bullets > 0) then
						overview:SetPoint("TOPLEFT", self.Bullets[#self.Bullets], "BOTTOMLEFT", -13, -18);
					else
						local yoffset = -18 - self:GetHeight();
						overview:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, yoffset);
					end
				end
				EncounterJournal_UpdateButtonState(self.button);
			end
		end

		-- Get Section Info
		if (not isOverview) then
			local freeHeaders = EncounterJournal.encounter.freeHeaders;
			local usedHeaders = EncounterJournal.encounter.usedHeaders;

			local listEnd = #usedHeaders;

			if self.myID then  -- this is from a button click
				local sectionInfo = C_EncounterJournal.GetSectionInfo(self.myID);
				nextSectionID = sectionInfo and sectionInfo.firstChildSectionID;
				parentID = self.myID;
				self.description:SetWidth(self:GetWidth() -20);
				hWidth = hWidth - HEADER_INDENT;
			else
				--This sets the base encounter header
				parentID = self.encounterID;
				nextSectionID = self.rootSectionID;
				topLevelSection = true;
			end

			while nextSectionID do
				local sectionInfo = C_EncounterJournal.GetSectionInfo(nextSectionID);
				if not sectionInfo then
					break;
				end

				if not sectionInfo.filteredByDifficulty then --ignore all sections that should not be shown with our current difficulty settings, but do not stop iteration
					if #freeHeaders == 0 then -- create a new header;
						headerCount = headerCount + 1; -- the is a file local
						infoHeader = CreateFrame("FRAME", "EncounterJournalInfoHeader"..headerCount, EncounterJournal.encounter.infoFrame, "EncounterInfoTemplate");
						infoHeader:Hide();
					else
						infoHeader = freeHeaders[#freeHeaders];
						freeHeaders[#freeHeaders] = nil;
					end

					numAdded = numAdded + 1;
					toggleTempList[#toggleTempList+1] = infoHeader;

					infoHeader.spellID = sectionInfo.spellID;
					infoHeader.button.link = sectionInfo.link;
					infoHeader.parentID = parentID;
					infoHeader.myID = nextSectionID;
					-- Spell names can show up in white, which clashes with the parchment, strip out white color codes.
					local description;
					if sectionInfo.description then
						description = sectionInfo.description:gsub("|cffffffff(.-)|r", "%1");
					else
						description = RETRIEVING_DATA;
					end
					infoHeader.description:SetText(description);
					infoHeader.button.title:SetText(sectionInfo.title);

					if topLevelSection then
						infoHeader.button.title:SetFontObject("GameFontNormalMed3");
					else
						infoHeader.button.title:SetFontObject("GameFontNormal");
					end

					--All headers start collapsed
					infoHeader.expanded = false
					infoHeader.description:Hide();
					infoHeader.descriptionBG:Hide();
					infoHeader.descriptionBGBottom:Hide();
					infoHeader.button.expandedIcon:SetText("+");

					for i = 1, #infoHeader.Bullets do
						infoHeader.Bullets[i]:Hide();
					end

					local textLeftAnchor = infoHeader.button.expandedIcon;
					--Show ability Icon
					if sectionInfo.abilityIcon then
						infoHeader.button.abilityIcon:SetTexture(sectionInfo.abilityIcon);
						infoHeader.button.abilityIcon:Show();
						textLeftAnchor = infoHeader.button.abilityIcon;
					else
						infoHeader.button.abilityIcon:Hide();
					end

					--Show Creature Portrait
					if sectionInfo.creatureDisplayID ~= 0 then
						SetPortraitTextureFromCreatureDisplayID(infoHeader.button.portrait.icon, sectionInfo.creatureDisplayID);
						infoHeader.button.portrait.name = sectionInfo.title;
						infoHeader.button.portrait.displayInfo = sectionInfo.creatureDisplayID;
						infoHeader.button.portrait.uiModelSceneID = sectionInfo.uiModelSceneID;
						infoHeader.button.portrait:Show();
						textLeftAnchor = infoHeader.button.portrait;
						infoHeader.button.abilityIcon:Hide();
					else
						infoHeader.button.portrait:Hide();
						infoHeader.button.portrait.name = nil;
						infoHeader.button.portrait.displayInfo = nil;
						infoHeader.button.portrait.uiModelSceneID = nil;
					end
					infoHeader.button.title:SetPoint("LEFT", textLeftAnchor, "RIGHT", 5, 0);

					EncounterJournal_SetupIconFlags(nextSectionID, infoHeader.button);

					infoHeader.index = nil;
					infoHeader:SetWidth(hWidth);

					-- If this section has not be seen and should start open
					if EJ_section_openTable[infoHeader.myID] == nil and sectionInfo.startsOpen then
						EJ_section_openTable[infoHeader.myID] = true;
					end

					--toggleNested?
					if EJ_section_openTable[infoHeader.myID]  then
						infoHeader.expanded = false; -- setting false to expand it in EncounterJournal_ToggleHeaders
						numAdded = numAdded + EncounterJournal_ToggleHeaders(infoHeader, true);
					end

					infoHeader:Show();
				end -- if not filteredByDifficulty

				nextSectionID = sectionInfo.siblingSectionID;
			end

			if not doNotShift and numAdded > 0 then
				--fix the usedlist
				local startIndex = self.index or 0;
				for i=listEnd,startIndex+1,-1 do
					usedHeaders[i+numAdded] = usedHeaders[i];
					usedHeaders[i+numAdded].index = i + numAdded;
					usedHeaders[i] = nil
				end
				for i=1,numAdded do
					usedHeaders[startIndex + i] = toggleTempList[i];
					usedHeaders[startIndex + i].index = startIndex + i;
					toggleTempList[i] = nil;
				end
			end

			if topLevelSection and usedHeaders[1] then
				usedHeaders[1]:SetPoint("TOPRIGHT", 0 , -8 - EncounterJournal.encounter.infoFrame.descriptionHeight - SECTION_BUTTON_OFFSET);
			end
		elseif (not self.overviewIndex) then
			for i = 1, #self.overviews do
				self.overviews[i]:Hide();
			end

			EncounterJournal.overviewDefaultRole = nil;

			if (not self.rootOverviewSectionID) then
				return;
			end

			local spec, role;

			spec = GetSpecialization();
			if (spec) then
				role = GetSpecializationRoleEnum(spec);
			else
				role = Enum.LFGRole.Damage;
			end

			local overviewSections = GetOverviewSections(self.rootOverviewSectionID);
			-- character role
			local nextIndex = SetUpSectionsForRole(self, overviewSections, role, 1);
			local hasRoleSection = nextIndex > 1;
			-- other roles
			for i, otherRole in ipairs(overviewPriorities) do
				if (otherRole ~= role) then
					nextIndex = SetUpSectionsForRole(self, overviewSections, otherRole, nextIndex);
				end
			end

			if (self.linkSection) then
				for i = 1, 3 do
					local overview = self.overviews[i];
					if (overview.sectionID == self.linkSection) then
						overview.expanded = false;
							EncounterJournal_ToggleHeaders(overview);
						overview.cbCount = 0;
						overview.flashAnim:Play();
						overview:SetScript("OnUpdate", EncounterJournal_FocusSectionCallback);
					else
						overview.expanded = true;
							EncounterJournal_ToggleHeaders(overview);
						overview.flashAnim:Stop();
						overview:SetScript("OnUpdate", nil);
					end
				end
				self.linkSection = nil;
			elseif self.overviews and self.overviews[1] then
				self.overviews[1].expanded = false;
				EncounterJournal.overviewDefaultRole = role;
				if ( hasRoleSection ) then
					EncounterJournal_ToggleHeaders(self.overviews[1]);
				end
			end
		end
	end

	if (not isOverview) then
		if self.myID then
			EJ_section_openTable[self.myID] = self.expanded;
		end

		if not doNotShift then
			EncounterJournal_ShiftHeaders(self.index or 1);

			--check to see if it is offscreen
			if self.index and not EncounterJournal.encounter.infoFrame.updatingSpells then
				local scrollValue = EncounterJournal.encounter.info.detailsScroll:GetVerticalScroll();
				local cutoff = EncounterJournal.encounter.info.detailsScroll:GetHeight() + scrollValue;

				local _, _, _, _, anchorY = self:GetPoint(1);
				anchorY = anchorY - self:GetHeight();
				if self.description:IsShown() then
					anchorY = anchorY - self.description:GetHeight() - SECTION_DESCRIPTION_OFFSET;
				end

				if cutoff < abs(anchorY) then
					self.frameCount = 0;
					self:SetScript("OnUpdate", EncounterJournal_MoveSectionUpdate);
				end
			end
		end
		return numAdded;
	else
		return 0;
	end
end

function EncounterJournal_ShiftHeaders(index)
	local usedHeaders = EncounterJournal.encounter.usedHeaders;
	if not usedHeaders[index] then
		return;
	end

	local _, _, _, _, anchorY = usedHeaders[index]:GetPoint(1);
	for i=index,#usedHeaders-1 do
		anchorY = anchorY - usedHeaders[i]:GetHeight();
		if usedHeaders[i].description:IsShown() then
			anchorY = anchorY - usedHeaders[i].description:GetHeight() - SECTION_DESCRIPTION_OFFSET;
		else
			anchorY = anchorY - SECTION_BUTTON_OFFSET;
		end

		usedHeaders[i+1]:SetPoint("TOPRIGHT", 0 , anchorY);
	end
end

function EncounterJournal_ResetHeaders()
	for key,_ in pairs(EJ_section_openTable) do
		EJ_section_openTable[key] = nil;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	EncounterJournal_Refresh();
end

function EncounterJournal_FocusSection(sectionID)
	if (not EncounterJournal_CheckForOverview(sectionID)) then
		local usedHeaders = EncounterJournal.encounter.usedHeaders;
		for _, section in pairs(usedHeaders) do
			if section.myID == sectionID then
				section.cbCount = 0;
				section.flashAnim:Play();
				section:SetScript("OnUpdate", EncounterJournal_FocusSectionCallback);
			else
				section.flashAnim:Stop();
				section:SetScript("OnUpdate", nil);
			end
		end
	end
end

function EncounterJournal_FocusSectionCallback(self)
	if self.cbCount > 0 then
		local _, _, _, _, anchorY = self:GetPoint(1);
		local scrollFrame = self:GetParent():GetParent();
		anchorY = abs(anchorY) - (scrollFrame:GetHeight() / 2);
		scrollFrame:SetVerticalScroll(anchorY);
		self:SetScript("OnUpdate", nil);
	end
	self.cbCount = self.cbCount + 1;
end

function EncounterJournal_MoveSectionUpdate(self)

	if self.frameCount > 0 then
		local _, _, _, _, anchorY = self:GetPoint(1);
		local height = min(EJ_MAX_SECTION_MOVE, self:GetHeight() + self.description:GetHeight() + SECTION_DESCRIPTION_OFFSET);
		local scrollValue = abs(anchorY) - (EncounterJournal.encounter.info.detailsScroll:GetHeight()-height);
		EncounterJournal.encounter.info.detailsScroll:SetVerticalScroll(scrollValue);
		self:SetScript("OnUpdate", nil);
	end
	self.frameCount = self.frameCount + 1;
end

function EncounterJournal_ClearChildHeaders(self, doNotShift)
	local usedHeaders = EncounterJournal.encounter.usedHeaders;
	local freeHeaders = EncounterJournal.encounter.freeHeaders;
	local numCleared = 0
	for key,header in pairs(usedHeaders) do
		if header.parentID == self.myID then
			if header.expanded then
				numCleared = numCleared + EncounterJournal_ClearChildHeaders(header, true)
			end
			header:Hide();
			usedHeaders[key] = nil;
			freeHeaders[#freeHeaders+1] = header;
			numCleared = numCleared + 1;
		end
	end

	if numCleared > 0 and not doNotShift then
		local placeIndex = self.index + 1;
		local shiftHeader = usedHeaders[placeIndex + numCleared];
		while shiftHeader do
			usedHeaders[placeIndex] = shiftHeader;
			usedHeaders[placeIndex].index = placeIndex;
			usedHeaders[placeIndex + numCleared] = nil;
			placeIndex = placeIndex + 1;
			shiftHeader = usedHeaders[placeIndex + numCleared];
		end
	end
	return numCleared
end

function EncounterJournal_ClearDetails()
	EncounterJournal.encounter.instance:Hide();
	EncounterJournal.encounter.infoFrame.description:SetText("");
	EncounterJournal.encounter.info.encounterTitle:SetText("");

	EncounterJournal.encounter.info.overviewScroll.ScrollBar:ScrollToBegin();
	EncounterJournal.encounter.info.detailsScroll.ScrollBar:ScrollToBegin();

	local freeHeaders = EncounterJournal.encounter.freeHeaders;
	local usedHeaders = EncounterJournal.encounter.usedHeaders;

	for key,used in pairs(usedHeaders) do
		used:Hide();
		usedHeaders[key] = nil;
		freeHeaders[#freeHeaders+1] = used;
	end

	local clearDisplayInfo = true;
	EncounterJournal_HideCreatures(clearDisplayInfo);

	EncounterJournal.searchResults:Hide();
	EncounterJournal.searchBox:Close();
end

function EncounterJournal_TabClicked(self, button)
	local tabType = self:GetID();
	EncounterJournal_SetTab(tabType);
	PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
end

function EncounterJournal_SetTab(tabType)
	local info = EncounterJournal.encounter.info;
	info.tab = tabType;
	for key, data in pairs(EJ_Tabs) do
		if key == tabType then
			info[data.frame]:Show();
			info[data.button].selected:Show();
			info[data.button].unselected:Hide();
			info[data.button]:LockHighlight();
		else
			info[data.frame]:Hide();
			info[data.button].selected:Hide();
			info[data.button].unselected:Show();
			info[data.button]:UnlockHighlight();
		end
	end

	UpdateDifficultyVisibility();
end

function EncounterJournal_SetTabEnabled(tab, enabled)
	tab:SetEnabled(enabled);
	tab:GetDisabledTexture():SetDesaturated(not enabled);
	tab.unselected:SetDesaturated(not enabled);
	if not enabled then
		EncounterJournal_ValidateSelectedTab();
	end
end

function EncounterJournal_ValidateSelectedTab()
	local info = EncounterJournal.encounter.info;
	local selectedTabButton = info[EJ_Tabs[info.tab].button];
	if not selectedTabButton:IsEnabled() then
		for index, data in ipairs(EJ_Tabs) do
			local tabButton = info[data.button];
			if tabButton:IsEnabled() then
				EncounterJournal_SetTab(index);
				break;
			end
		end
	end
end

function EncounterJournal_LootCallback(itemID)
	local scrollBox = EncounterJournal.encounter.info.LootContainer.ScrollBox;
	local button = scrollBox:FindFrameByPredicate(function(button, elementData)
		return button.itemID == itemID;
	end);
	if button then
		button:Init(button:GetElementData());
	end
end

function EncounterJournal_LootUpdate()
	EncounterJournal_UpdateFilterString();

	local scrollBox = EncounterJournal.encounter.info.LootContainer.ScrollBox;

	local dataProvider = CreateDataProvider();
	local loot = {};
	local perPlayerLoot = {};
	local veryRareLoot = {};
	local extremelyRareLoot = {};
	local seasonalLoot = {};
	local currentSeason = C_SeasonInfo.GetCurrentDisplaySeasonID();
	local currentSeasonExpansion = C_SeasonInfo.GetCurrentDisplaySeasonExpansion();

	for i = 1, EJ_GetNumLoot() do
		local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i);
		if itemInfo.displaySeasonID then
			-- The loot is flagged to be for a specific season, see if it matches the current one.
			if itemInfo.displaySeasonID == currentSeason then
				tinsert(seasonalLoot, i);
			end
		elseif itemInfo.displayAsPerPlayerLoot then
			tinsert(perPlayerLoot, i);
		elseif itemInfo.displayAsExtremelyRare then
			tinsert(extremelyRareLoot, i);
		elseif itemInfo.displayAsVeryRare then
			tinsert(veryRareLoot, i);
		else
			tinsert(loot, i);
		end
	end

	for _,val in ipairs(loot) do
		dataProvider:Insert({index=val});
	end

	local seasonalHeaderTitle;
	local uiSeason = PVPUtil.GetCurrentSeasonNumber();
	if #seasonalLoot > 0 and currentSeason and currentSeasonExpansion then
		seasonalHeaderTitle = EXPANSION_SEASON_NAME:format(GetExpansionName(currentSeasonExpansion), uiSeason);
	end

	local lootCategories = { 
		{ loot=veryRareLoot,		headerTitle=EJ_ITEM_CATEGORY_VERY_RARE },
		{ loot=extremelyRareLoot,	headerTitle=EJ_ITEM_CATEGORY_EXTREMELY_RARE },
		{ loot=perPlayerLoot,		headerTitle=BONUS_LOOT_TOOLTIP_TITLE,			helpText=BONUS_LOOT_TOOLTIP_BODY },
		{ loot=seasonalLoot,		headerTitle=seasonalHeaderTitle },
	};

	for _,category in ipairs(lootCategories) do
		if #category.loot > 0 then
			dataProvider:Insert({header=true, text=category.headerTitle, helpText=category.helpText});
			for _,val in ipairs(category.loot) do
				dataProvider:Insert({index=val});
			end
		end
	end

	scrollBox:SetDataProvider(dataProvider);
end

function EncounterJournal_Loot_OnUpdate(self)
	if GameTooltip:IsOwned(self) then
		if IsModifiedClick("DRESSUP") then
			ShowInspectCursor();
		else
			ResetCursor();
		end
	end
end

function EncounterJournal_Loot_OnClick(self)
	if (EncounterJournal.encounterID ~= self.encounterID) then
		PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
		EncounterJournal_DisplayEncounter(self.encounterID);
	end
end

function EncounterJournal_SetTooltipWithCompare(tooltip, link, useSpec)
	if not link then
		return;
	end
	
	local classID, specID;
	if useSpec then
		classID, specID = EJ_GetLootFilter();
		if specID == 0 then
			local spec = GetSpecialization();
			if spec and classID == select(3, UnitClass("player")) then
				specID = GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player"));
			else
				specID = -1;
			end
		end
	end
	local tooltipInfo = CreateBaseTooltipInfo("GetHyperlink", link, classID, specID);
	tooltipInfo.compareItem = true;
	tooltip:ProcessInfo(tooltipInfo);
end

function EncounterJournal_SetFlagIcon(texture, index)
	local iconSize = 32;
	local columns = 256/iconSize;
	local rows = 64/iconSize;
	local l = mod(index, columns) / columns;
	local r = l + (1/columns);
	local t = floor(index/columns) / rows;
	local b = t + (1/rows);
	texture:SetTexCoord(l,r,t,b);
end

function EncounterJournal_Refresh(self)
	EncounterJournal_LootUpdate();

	if EncounterJournal.encounterID then
		EncounterJournal_DisplayEncounter(EncounterJournal.encounterID, true)
	elseif EncounterJournal.instanceID then
		EncounterJournal_DisplayInstance(EncounterJournal.instanceID, true);
	end
end

function EncounterJournal_GetSearchDisplay(index)
	local spellID, name, icon, path, typeText, displayInfo, itemID, _;
	local id, stype, _, instanceID, encounterID, itemLink = EJ_GetSearchResult(index);
	if stype == EJ_STYPE_INSTANCE then
		name, _, _, icon = EJ_GetInstanceInfo(id);
		typeText = ENCOUNTER_JOURNAL_INSTANCE;
	elseif stype == EJ_STYPE_ENCOUNTER then
		name = EJ_GetEncounterInfo(id);
		typeText = ENCOUNTER_JOURNAL_ENCOUNTER;
		path = EJ_GetInstanceInfo(instanceID);
		icon = "Interface\\EncounterJournal\\UI-EJ-GenericSearchCreature"
	elseif stype == EJ_STYPE_SECTION then
		local sectionInfo = C_EncounterJournal.GetSectionInfo(id);
		spellID = sectionInfo and sectionInfo.spellID;
		displayInfo = sectionInfo and sectionInfo.creatureDisplayID or 0;
		name = sectionInfo and sectionInfo.title;
		if displayInfo > 0 then
			typeText = ENCOUNTER_JOURNAL_ENCOUNTER_ADD;
			displayInfo = nil;
			icon = "Interface\\EncounterJournal\\UI-EJ-GenericSearchCreature";
		else
			typeText = ENCOUNTER_JOURNAL_ABILITY;
			if (sectionInfo) then
				icon = sectionInfo.abilityIcon;
			end
		end
		path = EJ_GetInstanceInfo(instanceID).." > "..EJ_GetEncounterInfo(encounterID);
	elseif stype == EJ_STYPE_ITEM then
		local lootInfo = C_EncounterJournal.GetLootInfo(id);
		itemID = lootInfo.itemID;
		name = lootInfo.name and WrapTextInColorCode(lootInfo.name, lootInfo.itemQuality);
		icon = lootInfo.icon;
		typeText = ENCOUNTER_JOURNAL_ITEM;
		path = EJ_GetInstanceInfo(instanceID).." > "..EJ_GetEncounterInfo(encounterID);
	elseif stype == EJ_STYPE_CREATURE then
		for i=1,MAX_CREATURES_PER_ENCOUNTER do
			local cId, cName, _, cDisplayInfo = EJ_GetCreatureInfo(i, encounterID);
			if cId == id then
				name = cName
				break;
			end
		end
		icon = "Interface\\EncounterJournal\\UI-EJ-GenericSearchCreature"
		typeText = ENCOUNTER_JOURNAL_ENCOUNTER
		path = EJ_GetInstanceInfo(instanceID).." > "..EJ_GetEncounterInfo(encounterID);
	end
	return spellID, name, icon, path, typeText, displayInfo, itemID, stype, itemLink;
end

function EncounterJournal_SelectSearch(index)
	local _;
	local id, stype, difficultyID, instanceID, encounterID = EJ_GetSearchResult(index);
	local sectionID, creatureID, itemID;
	if stype == EJ_STYPE_INSTANCE then
		instanceID = id;
	elseif stype == EJ_STYPE_SECTION then
		sectionID = id;
	elseif stype == EJ_STYPE_ITEM then
		itemID = id;
	elseif stype == EJ_STYPE_CREATURE then
		creatureID = id;
	end

	EncounterJournal_OpenJournal(difficultyID, instanceID, encounterID, sectionID, creatureID, itemID);
	EncounterJournal.searchResults:Hide();
end

EncounterSearchResultLGMixin = {};

function EncounterSearchResultLGMixin:Init(elementData)
	local index = elementData.index;
	local spellID, name, icon, path, typeText, displayInfo, itemID, stype, itemLink = EncounterJournal_GetSearchDisplay(index);
	if stype == EJ_STYPE_INSTANCE then
		self.icon:SetTexCoord(0.16796875, 0.51171875, 0.03125, 0.71875);
	else
		self.icon:SetTexCoord(0, 1, 0, 1);
	end

	self.spellID = spellID;
	self.name:SetText(name);
	self.resultType:SetText(typeText);
	self.path:SetText(path);
	self.icon:SetTexture(icon);
	self.link = itemLink;
	if displayInfo and displayInfo > 0 then
		SetPortraitTextureFromCreatureDisplayID(self.icon, displayInfo);
	end
	self:SetID(index);

	if self.showingTooltip then
		if itemLink then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			EncounterJournal_SetTooltipWithCompare(GameTooltip, itemLink);
		else
			GameTooltip:Hide();
		end
	end
end

function EncounterJournal_SearchUpdate()
	local scrollBox = EncounterJournal.searchResults.ScrollBox;
	local dataProvider = CreateDataProviderByIndexCount(EJ_GetNumSearchResults());
	scrollBox:SetDataProvider(dataProvider);
end

function EncounterJournal_ShowFullSearch()
	local numResults = EJ_GetNumSearchResults();
	if numResults == 0 then
		EncounterJournal.searchResults:Hide();
		return;
	end

	EncounterJournal.searchResults.TitleText:SetText(string.format(ENCOUNTER_JOURNAL_SEARCH_RESULTS, EncounterJournal.searchBox:GetText(), numResults));
	EncounterJournal.searchResults:Show();
	EncounterJournal_SearchUpdate();
	EncounterJournal.searchBox:Close();
end

function EncounterJournal_RestartSearchTracking()
	if EJ_IsSearchFinished() then
		EncounterJournal_ShowSearch();
	else
		EncounterJournal.searchBox.searchPreviewUpdateDelay = 0;
		EncounterJournal.searchBox:SetScript("OnUpdate", EncounterJournalSearchBox_OnUpdate);

		--Since we just restarted the search we hide the progress bar until the search delay is done.
		EncounterJournal.searchBox:HideSearchProgress();
	end
end

function EncounterJournal_ShowSearch()
	if EncounterJournal.searchResults:IsShown() then
		EncounterJournal_ShowFullSearch();
	else
		EncounterJournal_UpdateSearchPreview();
	end
end

-- There is a delay before the search is updated to avoid a search progress bar if the search
-- completes within the grace period.
local ENCOUNTER_JOURNAL_SEARCH_PREVIEW_UPDATE_DELAY = 0.6;
function EncounterJournalSearchBox_OnUpdate(self, elapsed)
	if EJ_IsSearchFinished() then
		EncounterJournal_ShowSearch();
		self.searchPreviewUpdateDelay = nil;
		self:SetScript("OnUpdate", nil);
		return;
	end

	self.searchPreviewUpdateDelay = (self.searchPreviewUpdateDelay or 0) + elapsed;

	if self.searchPreviewUpdateDelay > ENCOUNTER_JOURNAL_SEARCH_PREVIEW_UPDATE_DELAY then
		self.searchPreviewUpdateDelay = nil;
		self:SetScript("OnUpdate", nil);
		EncounterJournal_UpdateSearchPreview();
		return;
	end
end

-- If the searcher does not finish within the update delay then a search progress bar is displayed that
-- will fill until the search is finished and then display the search preview results.
function EncounterJournalSearchBoxSearchProgressBar_OnUpdate(self, elapsed)
	if EJ_GetSearchSize() == 0 then
		self:SetValue(0);
		return;
	end

	local _, maxValue = self:GetMinMaxValues();
	self:SetValue((EJ_GetSearchProgress() / EJ_GetSearchSize()) * maxValue);

	--If we don't already have the max number of search previews keep checking if
	--we have new results we can display (unless we are delaying updates).
	if (self.previousResults == nil) or (self.previousResults < EncounterJournal.searchBox:GetSearchButtonCount()) and
		(EncounterJournal.searchBox.searchPreviewUpdateDelay == nil) then
		local numResults = EJ_GetNumSearchResults();
		if (self.previousResults == nil and numResults > 0) or (numResults ~= self.previousResults) then
			EncounterJournal_UpdateSearchPreview();
		end

		self.previousResults = numResults;
	end

	if self:GetValue() >= maxValue then
		self:SetScript("OnUpdate", nil);
		self:SetValue(0);
		EncounterJournal.searchBox:HideSearchProgress();
		EncounterJournal_ShowSearch();
	end
end

function EncounterJournalSearchBox_OnTextChanged(editBox)
	local valid, text = SearchBoxListMixin.OnTextChanged(editBox);
	if valid then
		EJ_SetSearch(text);
		EncounterJournal_RestartSearchTracking();
	else
		EJ_ClearSearch();
		EncounterJournal.searchResults:Hide();
	end
end

function EncounterJournalSearchBox_OnEditFocusGained(editBox)
	SearchBoxListMixin.OnFocusGained(editBox);

	EncounterJournal_UpdateSearchPreview();
end

function EncounterJournalSearchBox_OnHide(editBox)
	editBox.searchPreviewUpdateDelay = nil;
	editBox:SetScript("OnUpdate", nil);
end

function EncounterJournal_UpdateSearchPreview()
	if not EncounterJournal.searchBox:IsCurrentTextValidForSearch() then
		EncounterJournal.searchBox:HideSearchPreview();
		EncounterJournal.searchResults:Hide();
		return;
	end

	local numResults = EJ_GetNumSearchResults();
	if numResults == 0 and EJ_IsSearchFinished() then
		EncounterJournal.searchBox:HideSearchPreview();
		return;
	end

	for index, button in ipairs(EncounterJournal.searchBox:GetButtons()) do
		if index <= numResults then
			local spellID, name, icon, path, typeText, displayInfo, itemID, stype, itemLink = EncounterJournal_GetSearchDisplay(index);
			button.spellID = spellID;
			button.name:SetText(name);
			button.icon:SetTexture(icon);
			button.link = itemLink;
			if displayInfo and displayInfo > 0 then
				SetPortraitTextureFromCreatureDisplayID(button.icon, displayInfo);
			end
			button:SetID(index);
			button:Show();
		else
			button:Hide();
		end
	end

	local dbLoaded = EJ_GetSearchSize() > 0;
	EncounterJournal.searchBox:UpdateSearchPreview(EJ_IsSearchFinished(), dbLoaded, numResults);
end

function EncounterJournal_ClearSearch()
	EncounterJournal.searchResults:Hide();
	EncounterJournal.searchBox:HideSearchPreview();
end

function EncounterJournalSearchBoxShowAllResults_OnEnter(self)
	EncounterJournal.searchBox:SetSearchPreviewSelectionToAllResults();
end

function EncounterJournal_OpenToPowerID(powerID)
	ShowUIPanel(EncounterJournal);
	EJ_ContentTab_Select(EncounterJournal.LootJournalTab:GetID());
	EncounterJournal_SetLootJournalView(LOOT_JOURNAL_POWERS);
	EncounterJournal.LootJournal:OpenToPowerID(powerID);
end

function EncounterJournal_OpenJournal(difficultyID, instanceID, encounterID, sectionID, creatureID, itemID, tierIndex)
	EJ_HideNonInstancePanels();
	ShowUIPanel(EncounterJournal);
	if instanceID then
		NavBar_Reset(EncounterJournal.navBar);
		EJ_ContentTab_SelectAppropriateInstanceTab(instanceID);

		EncounterJournal_DisplayInstance(instanceID);

		if difficultyID then
			EJ_SetDifficulty(difficultyID);
		end

		if encounterID then
			if sectionID then
				if (EncounterJournal_CheckForOverview(sectionID)) then
					EncounterJournal.encounter.overviewFrame.linkSection = sectionID;
				else
					local sectionPath = {EJ_GetSectionPath(sectionID)};
					for _, id in pairs(sectionPath) do
						EJ_section_openTable[id] = true;
					end
				end
			end
			EncounterJournal_DisplayEncounter(encounterID);
		end
		if sectionID then
			if (EncounterJournal_CheckForOverview(sectionID) or not EncounterJournal_SearchForOverview(instanceID)) then
				EncounterJournal.encounter.info.overviewTab:Click();
			else
				EncounterJournal.encounter.info.bossTab:Click();
			end
			EncounterJournal_FocusSection(sectionID);
		elseif itemID then
			EncounterJournal.encounter.info.lootTab:Click();
		end
	elseif tierIndex then
		EncounterJournal_ExpansionDropdown_Select(EncounterJournal, tierIndex+1);
	else
		EncounterJournal_ListInstances();
	end
end

function EncounterJournal_SelectDifficulty(self, value)
	EJ_SetDifficulty(value);
end

-- TODO: Fix for Level Squish
function EJSuggestTab_GetPlayerTierIndex()
	return GetEJTierDataTableID(GetExpansionForLevel(UnitLevel("player")));
end

function EJ_ContentTab_OnClick(self)
	C_EncounterJournal.SetTab(self:GetID());
	EJ_ContentTab_Select(self:GetID());
end

function EJ_ContentTab_Select(id)
	PanelTemplates_SetTab(EncounterJournal, id);
	EncounterJournal.selectedTab = id;

	local instanceSelect = EncounterJournal.instanceSelect;

	-- Setup background
	local tierData;
	if ( id == EncounterJournal.suggestTab:GetID() or id == EncounterJournal.MonthlyActivitiesTab:GetID()) then
		tierData = GetEJTierData(EJSuggestTab_GetPlayerTierIndex());
	else
		tierData = GetEJTierData(EJ_GetCurrentTier());
	end
	instanceSelect.bg:SetAtlas(tierData.backgroundAtlas, true);
	EncounterJournal.encounter:Hide();
	instanceSelect:Show();

	local showMonthlyActivities = id == EncounterJournal.MonthlyActivitiesTab:GetID();
	local showSuggestedContent = id == EncounterJournal.suggestTab:GetID();
	local showRaid = id == EncounterJournal.raidsTab:GetID();
	local showDungeons = id == EncounterJournal.dungeonsTab:GetID();
	local showLoot = id == EncounterJournal.LootJournalTab:GetID();

	if showMonthlyActivities then
		EJ_HideSuggestPanel();
		EJ_HideLootJournalPanel();
	elseif showSuggestedContent then
		EJ_HideLootJournalPanel();
		EncounterJournal.suggestFrame:Show();
		EncounterJournal_DisableExpansionDropdown();
	elseif showLoot then
		EJ_HideSuggestPanel();
		EncounterJournal_CheckAndDisplayLootJournalViewDropdown(EncounterJournal);
		EJ_ShowLootJournalPanel();
		EncounterJournal_EnableExpansionDropdown();
	elseif showDungeons or showRaid then
		EJ_HideNonInstancePanels();
		EncounterJournal_ListInstances();
		EncounterJournal_EnableExpansionDropdown();
	end

	-- Update title bar with the current tab name
	EJInstanceSelect_UpdateTitle(id);

	NavBar_Reset(EncounterJournal.navBar);

	local showNavBar = (id == EncounterJournal.dungeonsTab:GetID() or id == EncounterJournal.raidsTab:GetID());
	EncounterJournal.navBar:SetShown(showNavBar);

	local showSearchBox = (id == EncounterJournal.dungeonsTab:GetID() or id == EncounterJournal.raidsTab:GetID() or id == EncounterJournal.LootJournalTab:GetID());
	EncounterJournal.searchBox:SetShown(showSearchBox);

	instanceSelect.ExpansionDropdown:SetShown(showDungeons or showRaid or showLoot);
	instanceSelect.bg:SetShown(showSuggestedContent or showDungeons or showRaid);
	EncounterJournal.MonthlyActivitiesFrame:SetShown(showMonthlyActivities);

	local showInstanceSelect = (id == EncounterJournal.dungeonsTab:GetID() or id == EncounterJournal.raidsTab:GetID());
	instanceSelect.ScrollBox:SetShown(showInstanceSelect);
	instanceSelect.ScrollBar:SetShown(showInstanceSelect);

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

    EventRegistry:TriggerEvent("EncounterJournal.TabSet", EncounterJournal, id);
end

function EJ_ContentTab_SelectAppropriateInstanceTab(instanceID)
	local isRaid = select(11, EJ_GetInstanceInfo(instanceID));
	local desiredTabID = isRaid and EncounterJournal.raidsTab:GetID() or EncounterJournal.dungeonsTab:GetID();
	EJ_ContentTab_Select(desiredTabID);
end

function EJ_ContentTab_SetEnabled(self, enabled)
	PanelTemplates_SetTabEnabled(EncounterJournal, self:GetID(), enabled);
end

function EJ_HideSuggestPanel()
	local instanceSelect = EncounterJournal.instanceSelect;
	local suggestTab = EncounterJournal.suggestTab;
	if ( not suggestTab:IsEnabled() or EncounterJournal.suggestFrame:IsShown() ) then
		suggestTab:Enable();
		EncounterJournal.suggestFrame:Hide();

		EncounterJournal_EnableExpansionDropdown();

		local tierData = GetEJTierData(EJ_GetCurrentTier());
		instanceSelect.bg:SetAtlas(tierData.backgroundAtlas, true);
		instanceSelect.ScrollBox:Show();
		instanceSelect.ScrollBar:Show();

		EncounterJournal.suggestFrame:Hide();
	end
end

function EJ_HideLootJournalPanel()
	if ( EncounterJournal.LootJournal ) then
		EncounterJournal.LootJournal:Hide();
	end
	if ( EncounterJournal.LootJournalItems ) then
		EncounterJournal.LootJournalItems:Hide();
	end
end

function EJ_ShowLootJournalPanel()
	EncounterJournal_DisableExpansionDropdown();

	local tierData = GetEJTierData(EJSuggestTab_GetPlayerTierIndex());
	EncounterJournal.instanceSelect.bg:SetAtlas(tierData.backgroundAtlas, true);

	local activeLootPanel = EncounterJournal_GetLootJournalPanels();
	activeLootPanel:Show();
end

function EJ_HideNonInstancePanels()
	EJ_HideSuggestPanel();
	EJ_HideLootJournalPanel();
	EncounterJournal.MonthlyActivitiesFrame:Hide();
end

function EncounterJournal_ExpansionDropdown_Select(self, tier)
	ExpansionDropdown_SelectInternal(self, tier);
	EncounterJournal_SetupExpansionDropdown(EncounterJournal);
end

function EncounterJournal_OnFilterChanged(self)
	EncounterJournal_LootUpdate();
end

function EncounterJournal_SetClassAndSpecFilter(self, classID, specID)
	EJ_SetLootFilter(classID, specID);
	EncounterJournal_OnFilterChanged(self);
end

function EncounterJournal_SetSlotFilterInternal(self, slot)
	C_EncounterJournal.SetSlotFilter(slot);
	EncounterJournal_OnFilterChanged(self);
end

function EncounterJournal_SetSlotFilter(self, slot)
	EncounterJournal_SetSlotFilterInternal(self, slot);
	EncounterJournal_SetupLootSlotFilterDropdown(self);
end

function EncounterJournal_UpdateFilterString()
	local name, _;
	local classID, specID = EJ_GetLootFilter();

	if (specID > 0) then
		_, name = GetSpecializationInfoByID(specID, UnitSex("player"))
	elseif (classID > 0) then
		local classInfo = C_CreatureInfo.GetClassInfo(classID);
		if classInfo then
			name = classInfo.className;
		end
	end

	local classClearFilter = EncounterJournal.encounter.info.LootContainer.classClearFilter;
	local scrollBox = EncounterJournal.encounter.info.LootContainer.ScrollBox;
	if name then
		classClearFilter.text:SetText(string.format(EJ_CLASS_FILTER, name));
		classClearFilter:Show();

		scrollBox:SetPoint("TOPLEFT", classClearFilter, "BOTTOMLEFT", 14, 7);
	else
		classClearFilter:Hide();
		scrollBox:SetPoint("TOPLEFT", 0, 0);
	end
end

function EncounterJournal_CheckAndDisplayLootJournalViewDropdown(self)
	local isIndexShadowlands = EJ_GetCurrentTier() == EJ_TIER_INDEX_SHADOWLANDS;
	if not isIndexShadowlands and EncounterJournal.lootJournalView == LOOT_JOURNAL_POWERS then
		EncounterJournal_SetLootJournalView(LOOT_JOURNAL_ITEM_SETS);
	end

	self.LootJournalViewDropdown:SetShown(isIndexShadowlands);
end

----------------------------------------
--------------Nav Bar Func--------------
----------------------------------------
function EJNAV_RefreshInstance()
	EncounterJournal_DisplayInstance(EncounterJournal.instanceID, true);
end

function EJNAV_SelectInstance(self, index, navBar)
	local instanceID = EJ_GetInstanceByIndex(index, EJ_InstanceIsRaid());

	--Clear any previous selection.
	NavBar_Reset(navBar);

	EncounterJournal_DisplayInstance(instanceID);
end

function EJNAV_GetInstanceList(self)
	local list = { };
	local _, name = EJ_GetInstanceByIndex(1, EJ_InstanceIsRaid());
	while name do
		local entry = { text = name, id = #list + 1, func = EJNAV_SelectInstance };
		tinsert(list, entry);
		_, name = EJ_GetInstanceByIndex(#list + 1, EJ_InstanceIsRaid());
	end
	return list;
end

function EJNAV_RefreshEncounter()
	EncounterJournal_DisplayInstance(EncounterJournal.encounterID);
end

function EJNAV_SelectEncounter(self, index, navBar)
	local _, _, bossID = EJ_GetEncounterInfoByIndex(index);
	EncounterJournal_DisplayEncounter(bossID);
end

function EJNAV_GetEncounterList(self)
	local list = { };
	local name = EJ_GetEncounterInfoByIndex(1);
	while name do
		local entry = { text = name, id = #list + 1, func = EJNAV_SelectEncounter };
		tinsert(list, entry);
		name = EJ_GetEncounterInfoByIndex(#list + 1);
	end
	return list;
end

-------------------------------------------------
--------------Suggestion Panel Func--------------
-------------------------------------------------
function EJSuggestFrame_OnLoad(self)
	self.suggestions = {};

	self:RegisterEvent("AJ_REWARD_DATA_RECEIVED");
	self:RegisterEvent("AJ_REFRESH_DISPLAY");
	self:RegisterEvent("AJ_OPEN_COLLECTIONS_ACTION");
end

function EJSuggestFrame_OnEvent(self, event, ...)
	if ( event == "AJ_REFRESH_DISPLAY" ) then
		if EncounterJournal_IsSuggestTabSelected(EncounterJournal) then
			EJSuggestFrame_RefreshDisplay();
			local newAdventureNotice = ...;
			if ( newAdventureNotice ) then
				EJMicroButton:UpdateNewAdventureNotice();
			end
		end
	elseif ( event == "AJ_REWARD_DATA_RECEIVED" ) then
		EJSuggestFrame_RefreshRewards()
	elseif ( event == "AJ_OPEN_COLLECTIONS_ACTION" ) then
		if not CollectionsJournal then
			CollectionsJournal_LoadUI();
		end
		WardrobeCollectionFrame:ShowItemTrackingHelptipOnShow();
		ToggleCollectionsJournal();
	end
end

function EJSuggestFrame_OnShow(self)
	EJMicroButton:ClearNewAdventureNotice();

	C_AdventureJournal.UpdateSuggestions();
	EJSuggestFrame_RefreshDisplay();
	EncounterJournal_SetupLootSlotFilterDropdown(EncounterJournal);
end

function EJSuggestFrame_NextSuggestion()
	if ( C_AdventureJournal.GetPrimaryOffset() < C_AdventureJournal.GetNumAvailableSuggestions()-1 ) then
		C_AdventureJournal.SetPrimaryOffset(C_AdventureJournal.GetPrimaryOffset()+1);
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
	end
end

function EJSuggestFrame_PrevSuggestion()
	if( C_AdventureJournal.GetPrimaryOffset() > 0 ) then
		C_AdventureJournal.SetPrimaryOffset(C_AdventureJournal.GetPrimaryOffset()-1);
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
	end
end

function EJSuggestFrame_OnMouseWheel( self, value )
	if ( value > 0 ) then
		EJSuggestFrame_PrevSuggestion();
	else
		EJSuggestFrame_NextSuggestion()
	end
end

function EJSuggestFrame_OpenFrame()
	EJ_ContentTab_Select(EncounterJournal.suggestTab:GetID());
end

function EJSuggestFrame_UpdateRewards(suggestion)
	local rewardData = C_AdventureJournal.GetReward( suggestion.index );
	suggestion.reward.data = rewardData;
	if ( rewardData ) then
		local texture = rewardData.itemIcon or rewardData.currencyIcon or
						"Interface\\Icons\\achievement_guildperk_mobilebanking";
		if ( rewardData.isRewardTable ) then
			texture = "Interface\\Icons\\achievement_guildperk_mobilebanking";
		end
		suggestion.reward.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
		suggestion.reward.icon:SetTexture(texture);
		suggestion.reward:Show();
	end
end

AdventureJournal_LeftTitleFonts = {
	"DestinyFontHuge",		-- 32pt font
	"QuestFont_Enormous",	-- 30pt font
	"QuestFont_Super_Huge",	-- 24pt font
};

local AdventureJournal_RightTitleFonts = {
	"QuestFont_Huge", 	-- 18pt font
	"Fancy16Font",		-- 16pt font
};

local AdventureJournal_RightDescriptionFonts = {
	"SystemFont_Med1",	-- 12pt font
	-- "SystemFont_Small", -- 10pt font
};

function EJSuggestFrame_RefreshDisplay()
	local instanceSelect = EncounterJournal.instanceSelect;
	local tab = EncounterJournal.suggestTab;
	local tierData = GetEJTierData(EJSuggestTab_GetPlayerTierIndex());
	instanceSelect.bg:SetAtlas(tierData.backgroundAtlas, true);

	local self = EncounterJournal.suggestFrame;
	C_AdventureJournal.GetSuggestions(self.suggestions);

	-- hide all the display info
	for i = 1, AJ_MAX_NUM_SUGGESTIONS do
		local suggestion = self["Suggestion"..i];
		suggestion.centerDisplay:Hide();
		if ( i == 1 ) then
			-- the left suggestion's button isn't on the centerDisplay frame
			suggestion.button:Hide();
		else
			suggestion.centerDisplay.button:Hide();
		end
		suggestion.reward:Hide();
		suggestion.icon:Hide();
		suggestion.iconRing:Hide();
	end

	-- setup the primary suggestion display
	if ( #self.suggestions > 0 ) then
		local suggestion = self.Suggestion1;
		local data = self.suggestions[1];

		local centerDisplay = suggestion.centerDisplay;
		local titleText = centerDisplay.title.text;
		local descText = centerDisplay.description.text;

		centerDisplay:SetHeight(suggestion:GetHeight());
		centerDisplay:Show();
		centerDisplay.title:SetHeight(0);
		centerDisplay.description:SetHeight(0);
		titleText:SetText(data.title);
		descText:SetText(data.description);

		-- find largest font that will not go past 2 lines
		for i = 1, #AdventureJournal_LeftTitleFonts do
			titleText:SetFontObject(AdventureJournal_LeftTitleFonts[i]);
			local numLines = titleText:GetNumLines();
			if ( numLines <= 2 and not titleText:IsTruncated() ) then
				break;
			end
		end

		-- resize the title to be 2 lines at most
		local numLines = min(2, titleText:GetNumLines());
		local fontHeight = select(2, titleText:GetFont());
		centerDisplay.title:SetHeight(numLines * fontHeight + 2);
		centerDisplay.description:SetHeight(descText:GetStringHeight());

		-- adjust the center display to keep the text centered
		local top = centerDisplay.title:GetTop();
		local bottom = centerDisplay.description:GetBottom();
		centerDisplay:SetHeight(top - bottom);

		if ( data.buttonText and #data.buttonText > 0 ) then
			suggestion.button:SetText( data.buttonText );

			local btnWidth = max( suggestion.button:GetTextWidth()+42, 150 );
			btnWidth = min( btnWidth, centerDisplay:GetWidth() );
			suggestion.button:SetWidth( btnWidth );
			suggestion.button:Show();
		end

		suggestion.icon:Show();
		suggestion.iconRing:Show();
		if ( data.iconPath ) then
			suggestion.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
			suggestion.icon:SetTexture(data.iconPath);
		else
			suggestion.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
			suggestion.icon:SetTexture(QUESTION_MARK_ICON);
		end

		suggestion.prevButton:SetEnabled(C_AdventureJournal.GetPrimaryOffset() > 0);
		suggestion.nextButton:SetEnabled(C_AdventureJournal.GetPrimaryOffset() < C_AdventureJournal.GetNumAvailableSuggestions()-1);

		if ( titleText:IsTruncated() ) then
			centerDisplay.title:SetScript("OnEnter", EJSuggestFrame_SuggestionTextOnEnter);
			centerDisplay.title:SetScript("OnLeave", GameTooltip_Hide);
		else
			centerDisplay.title:SetScript("OnEnter", nil);
			centerDisplay.title:SetScript("OnLeave", nil);
		end

		EJSuggestFrame_UpdateRewards(suggestion);
	else
		local suggestion = self.Suggestion1;
		suggestion.prevButton:SetEnabled(false);
		suggestion.nextButton:SetEnabled(false);
	end

	-- setup secondary suggestions display
	if ( #self.suggestions > 1 ) then
		local minTitleIndex = 1;
		local minDescIndex = 1;

		for i = 2, #self.suggestions do
			local suggestion = self["Suggestion"..i];
			if ( not suggestion ) then
				break;
			end

			suggestion.centerDisplay:Show();

			local data = self.suggestions[i];
			suggestion.centerDisplay.title.text:SetText(data.title);
			suggestion.centerDisplay.description.text:SetText(data.description ~= "" and data.description or " ");

			-- find largest font that will not truncate the title
			for fontIndex = minTitleIndex, #AdventureJournal_RightTitleFonts do
				suggestion.centerDisplay.title.text:SetFontObject(AdventureJournal_RightTitleFonts[fontIndex]);
				minTitleIndex = fontIndex
				if (not suggestion.centerDisplay.title.text:IsTruncated()) then
					break;
				end
			end

			-- find largest font that will not go past 4 lines
			for fontIndex = minDescIndex, #AdventureJournal_RightDescriptionFonts do
				suggestion.centerDisplay.description.text:SetFontObject(AdventureJournal_RightDescriptionFonts[fontIndex]);
				minDescIndex = fontIndex;
				if ( suggestion.centerDisplay.description.text:GetNumLines() <= 4 and
						not suggestion.centerDisplay.description.text:IsTruncated() ) then
					break;
				end
			end

			if ( data.buttonText and #data.buttonText > 0 ) then
				suggestion.centerDisplay.button:SetText( data.buttonText );

				local btnWidth = max(suggestion.centerDisplay.button:GetTextWidth()+42, 116);
				btnWidth = min( btnWidth, suggestion.centerDisplay:GetWidth() );
				suggestion.centerDisplay.button:SetWidth( btnWidth );
				suggestion.centerDisplay.button:Show();
			end

			suggestion.icon:Show();
			suggestion.iconRing:Show();
			if ( data.iconPath ) then
				suggestion.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
				suggestion.icon:SetTexture(data.iconPath);
			else
				suggestion.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
				suggestion.icon:SetTexture(QUESTION_MARK_ICON);
			end

			EJSuggestFrame_UpdateRewards(suggestion);
		end
		-- set the fonts to be the same for both right side sections
		-- adjust the center display to keep the text centered
		for i = 2, #self.suggestions do
			local suggestion = self["Suggestion"..i];
			suggestion.centerDisplay:SetHeight(suggestion:GetHeight());

			local title = suggestion.centerDisplay.title;
			local description = suggestion.centerDisplay.description;
			title.text:SetFontObject(AdventureJournal_RightTitleFonts[minTitleIndex]);
			description.text:SetFontObject(AdventureJournal_RightDescriptionFonts[minDescIndex]);
			local fontHeight = select(2, title.text:GetFont());
			title:SetHeight(fontHeight);
			local numLines = min(4, description.text:GetNumLines());
			fontHeight = select(2, description.text:GetFont());
			description:SetHeight(numLines * fontHeight);

			-- adjust the center display to keep the text centered
			local top = title:GetTop();
			local bottom = description:GetBottom();
			if ( suggestion.centerDisplay.button:IsShown() ) then
				bottom = suggestion.centerDisplay.button:GetBottom();
			end

			if ( title.text:IsTruncated() ) then
				title:SetScript("OnEnter", EJSuggestFrame_SuggestionTextOnEnter);
				title:SetScript("OnLeave", GameTooltip_Hide);
			else
				title:SetScript("OnEnter", nil);
				title:SetScript("OnLeave", nil);
			end

			if ( description.text:IsTruncated() ) then
				description:SetScript("OnEnter", EJSuggestFrame_SuggestionTextOnEnter);
				description:SetScript("OnLeave", GameTooltip_Hide);
			else
				description:SetScript("OnEnter", nil);
				description:SetScript("OnLeave", nil);
			end

			suggestion.centerDisplay:SetHeight(top - bottom);
		end
	end
end

function EJSuggestFrame_SuggestionTextOnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.text:GetText(), 1, 1, 1, 1, true);
	GameTooltip:Show();
end

function EJSuggestFrame_RefreshRewards()
	for i = 1, AJ_MAX_NUM_SUGGESTIONS do
		local suggestion = EncounterJournal.suggestFrame["Suggestion"..i];
		suggestion.reward:Hide();
		EJSuggestFrame_UpdateRewards(suggestion);
	end
end

function EJSuggestFrame_OnClick(self)
	C_AdventureJournal.ActivateEntry(self.index);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function AdventureJournal_Reward_OnEnter(self)
	local rewardData = self.data;
	if ( rewardData ) then
		local frame = EncounterJournalTooltip;
		frame:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0);
		frame.clickText:Hide();

		local suggestion = EncounterJournal.suggestFrame.suggestions[self:GetParent().index];

		local rewardHeaderText = "";
		if ( rewardData.rewardDesc ) then
			rewardHeaderText = rewardData.rewardDesc;
		elseif ( rewardData.isRewardTable ) then
			if ( not suggestion.hideDifficulty and suggestion.difficultyID and suggestion.difficultyID > 1 ) then
				local difficultyStr = DifficultyUtil.GetDifficultyName(suggestion.difficultyID);
				if( rewardData.itemLevel ) then
					rewardHeaderText = format(AJ_LFG_REWARD_DIFFICULTY_TEXT, suggestion.title, difficultyStr, rewardData.itemLevel);
				elseif ( rewardData.minItemLevel ) then
					rewardHeaderText = format(AJ_LFG_REWARD_DIFFICULTY_IRANGE_TEXT, suggestion.title, difficultyStr, rewardData.minItemLevel, rewardData.maxItemLevel);
				end
			else
				if( rewardData.itemLevel ) then
					rewardHeaderText = format(AJ_LFG_REWARD_DEFAULT_TEXT, suggestion.title, rewardData.itemLevel);
				elseif ( rewardData.minItemLevel ) then
					rewardHeaderText = format(AJ_LFG_REWARD_DEFAULT_IRANGE_TEXT, suggestion.title, rewardData.minItemLevel, rewardData.maxItemLevel);
				end
			end

			if( rewardData.itemLink ) then
				rewardHeaderText = rewardHeaderText..AJ_SAMPLE_REWARD_TEXT;
			end
		end

		if ( rewardData.itemLink and rewardData.currencyType ) then
			local itemName, _, quality = C_Item.GetItemInfo(rewardData.itemLink);
			frame.Item1.text:SetText(itemName);
			frame.Item1.text:Show();
			frame.Item1.icon:SetTexture(rewardData.itemIcon);
			frame.Item1.tooltip:Hide();
			frame.Item1:SetSize(256, 28);
			frame.Item1:Show();

			if ( rewardData.itemQuantity and rewardData.itemQuantity > 1 ) then
				frame.Item1.Count:SetText(rewardData.itemQuantity);
				frame.Item1.Count:Show();
			else
				frame.Item1.Count:Hide();
			end

			SetItemButtonQuality(frame.Item1, quality, rewardData.itemLink);

			if (quality > Enum.ItemQuality.Common and BAG_ITEM_QUALITY_COLORS[quality]) then
				frame.Item1.text:SetTextColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
			end

			local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(rewardData.currencyType);
			quality = currencyInfo.quality;
			frame.Item2.icon:SetTexture(currencyInfo.iconFileID);
			frame.Item2.text:SetText(currencyInfo.name);
			frame.Item2:Show();

			SetItemButtonQuality(frame.Item2, quality);
			if (quality > Enum.ItemQuality.Common and BAG_ITEM_QUALITY_COLORS[quality]) then
				frame.Item2.text:SetTextColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
			end

			if ( rewardData.currencyQuantity and rewardData.currencyQuantity > 1 ) then
				frame.Item2.Count:SetText(rewardData.currencyQuantity);
				frame.Item2.Count:Show();
			else
				frame.Item2.Count:Hide();
			end
			local height = 100;

			frame:SetWidth(256);

			if ( rewardHeaderText and rewardHeaderText ~= "" ) then
				frame.headerText:SetText(rewardHeaderText);
				frame.Item1:SetPoint("TOPLEFT", frame.headerText, "BOTTOMLEFT", 0, -16);
				height = height + frame.headerText:GetHeight();
				frame.headerText:Show();
			else
				frame.headerText:Hide();
				frame.Item1:SetPoint("TOPLEFT", 11, -10);
			end

			frame:SetHeight(height);
		elseif ( rewardData.itemLink or rewardData.currencyType ) then
			frame.Item2:Hide();
			frame.Item1:Show();
			frame.Item1.text:Hide();

			local tooltip = frame.Item1.tooltip;
			tooltip:SetOwner(frame.Item1, "ANCHOR_NONE");
			frame.Item1.UpdateTooltip = function() AdventureJournal_Reward_OnEnter(self) end;
			if ( rewardData.itemLink ) then
				EncounterJournal_SetTooltipWithCompare(tooltip, rewardData.itemLink);

				local quality = select(3, C_Item.GetItemInfo(rewardData.itemLink));
				SetItemButtonQuality(frame.Item1, quality, rewardData.itemLink);

				if ( rewardData.itemQuantity and rewardData.itemQuantity > 1 ) then
					frame.Item1.Count:SetText(rewardData.itemQuantity);
					frame.Item1.Count:Show();
				else
					frame.Item1.Count:Hide();
				end

				self:SetScript("OnUpdate", EncounterJournal_AJ_OnUpdate);
				frame.Item1.icon:SetTexture(rewardData.itemIcon);
			elseif ( rewardData.currencyType ) then
				tooltip:SetCurrencyByID(rewardData.currencyType);

				local quality = C_CurrencyInfo.GetCurrencyInfo(rewardData.currencyType).quality;

				SetItemButtonQuality(frame.Item1, quality);

				if ( rewardData.currencyQuantity and rewardData.currencyQuantity > 1 ) then
					frame.Item1.Count:SetText(rewardData.currencyQuantity);
					frame.Item1.Count:Show();
				else
					frame.Item1.Count:Hide();
				end

				frame.Item1.icon:SetTexture(rewardData.currencyIcon);
			end

			frame:SetWidth(tooltip:GetWidth()+54);

			if ( rewardHeaderText and rewardHeaderText ~= "" ) then
				frame.headerText:SetText(rewardHeaderText);
				frame.headerText:Show();
				frame.Item1:SetPoint("TOPLEFT", frame.headerText, "BOTTOMLEFT", 0, -16);
			else
				frame.headerText:Hide();
				frame.Item1:SetPoint("TOPLEFT", 11, -10);
			end

			tooltip:SetPoint("TOPLEFT", frame.Item1.icon, "TOPRIGHT", 0, 10);
			tooltip:Show();

			frame.Item1:SetSize(tooltip:GetWidth()+44, tooltip:GetHeight());

			local height = tooltip:GetHeight() + 6;
			if ( frame.headerText:IsShown() ) then
				height = height + frame.headerText:GetHeight() + 14;
			end
			if (rewardData.isRewardTable) then
				frame.clickText:Show();
				self.iconRingHighlight:Show();
				height = height + 24;
			end

			frame:SetHeight(height);
		elseif ( rewardHeaderText and rewardHeaderText ~= "" ) then
			frame:SetWidth(256);
			frame.Item1:Hide();
			frame.Item2:Hide();

			frame.headerText:SetText(rewardHeaderText);
			frame:SetHeight(frame.headerText:GetStringHeight()+20); -- add padding for tooltip border
			frame.headerText:Show();
		else
			return;
		end
		frame:Show();
	end
end

function EncounterJournal_AJ_OnUpdate(self)
	local frame = EncounterJournalTooltip;
	local tooltip = frame.Item1.tooltip;
end

function AdventureJournal_Reward_OnLeave(self)
	EncounterJournalTooltip:Hide();
	self:SetScript("OnUpdate", nil);
	ResetCursor();

	self.iconRingHighlight:Hide();
end

function AdventureJournal_Reward_OnMouseDown(self)
	local index = self:GetParent().index;
	local data = EncounterJournal.suggestFrame.suggestions[index];
	if ( data.ej_instanceID ) then
		EncounterJournal_DisplayInstance(data.ej_instanceID);
		-- try to set difficulty to current instance difficulty
		if ( EJ_IsValidInstanceDifficulty(data.difficultyID) ) then
			EJ_SetDifficulty(data.difficultyID);
		end

		-- select the loot tab
		EncounterJournal.encounter.info[EJ_Tabs[2].button]:Click();
	elseif ( data.isRandomDungeon ) then
		EJ_ContentTab_Select(EncounterJournal.dungeonsTab:GetID());
		EncounterJournal_ExpansionDropdown_Select(EncounterJournal, data.expansionLevel);
	end
end

function EncounterJournalBossButton_UpdateDifficultyOverlay(self)
	if self.encounterID then
		local name, description, bossID, rootSectionID, link, journalInstanceID, dungeonEncounterID, mapID = EJ_GetEncounterInfo(self.encounterID);
		local difficultyID = EJ_GetDifficulty();
		local defeatedOnCurrentDifficulty = mapID and dungeonEncounterID and C_RaidLocks.IsEncounterComplete(mapID, dungeonEncounterID, difficultyID);
		local hasDefeatedBoss = defeatedOnCurrentDifficulty and IsEJDifficulty(difficultyID);
		self.DefeatedOverlay:SetShown(hasDefeatedBoss);
		if hasDefeatedBoss then
			local difficultyName = DifficultyUtil.GetDifficultyName(difficultyID);
			self.DefeatedOverlay.tooltipText = ENCOUNTER_JOURNAL_ENCOUNTER_STATUS_DEFEATED_TOOLTIP:format(difficultyName);
		end
	end
end

function EncounterJournalBossButton_OnShow(self)
	self:RegisterEvent("UPDATE_INSTANCE_INFO");
end

function EncounterJournalBossButton_OnHide(self)
	self:UnregisterEvent("UPDATE_INSTANCE_INFO");
end

function EncounterJournalBossButton_OnEvent(self, event)
	if event == "UPDATE_INSTANCE_INFO" then
		EncounterJournalBossButton_UpdateDifficultyOverlay(self)
	end
end

function EncounterJournalBossButton_OnClick(self)
	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		if self.link then
			ChatEdit_InsertLink(self.link);
		end
		return;
	end
	local _, _, _, rootSectionID = EJ_GetEncounterInfo(self.encounterID);
	if ( rootSectionID == 0 ) then
		EncounterJournal_SetTab(EncounterJournal.encounter.info.lootTab:GetID());
	end
	EncounterJournal_DisplayEncounter(self.encounterID);
	PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
end

function EncounterJournalBossButtonDefeatedOverlay_OnEnter(self)
	if self.tooltipText then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

		local wrap = true;
		GameTooltip_AddNormalLine(GameTooltip, self.tooltipText, wrap);
		GameTooltip:Show();
	end
end

EncounterJournalScrollBarOldMixin = {};

function EncounterJournalScrollBarOldMixin:OnLoad()
	self.trackBG:SetVertexColor(ENCOUNTER_JOURNAL_SCROLL_BAR_BACKGROUND_COLOR:GetRGBA());
end

ModifiedInstanceIconMixin = { };
function ModifiedInstanceIconMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, self.name, HIGHLIGHT_FONT_COLOR);
	GameTooltip_AddNormalLine(GameTooltip, self.info.description);
	GameTooltip:Show();
end

function ModifiedInstanceIconMixin:GetIconTextureAtlas()
	return GetFinalNameFromTextureKit("%s-large", self.info.uiTextureKit);
end

function ModifiedInstanceIconMixin:OnLeave()
	GameTooltip:Hide();
end

function EJInstanceSelect_UpdateTitle(tabId)
	local showTitle = true;
	local instanceSelect = EncounterJournal.instanceSelect;
	if ( tabId == EncounterJournal.suggestTab:GetID()) then
		instanceSelect.Title:SetText(AJ_SUGGESTED_CONTENT_TAB);
	elseif ( tabId == EncounterJournal.raidsTab:GetID()) then
		instanceSelect.Title:SetText(RAIDS);
	elseif ( tabId == EncounterJournal.dungeonsTab:GetID()) then
		instanceSelect.Title:SetText(DUNGEONS);
	elseif ( tabId == EncounterJournal.MonthlyActivitiesTab:GetID()) then
		showTitle = false; -- MonthlyActivities frame has a unique header bar so we hide this title
	elseif (tabId == EncounterJournal.LootJournalTab:GetID()) then
		instanceSelect.Title:SetText(LOOT_JOURNAL_ITEM_SETS);
	end

	instanceSelect.Title:SetShown(showTitle);
end