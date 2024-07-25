MapLegendMixin = { };

function MapLegendMixin:OnLoad()
	self.BackButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		self:OnBackClicked();
	  end);

	self:SetupCategories();
	self.ScrollFrame.ScrollChild:Layout();

	self.ScrollFrame:UpdateScrollChildRect();
end

--Legend Category data
--Add more pin types here! Data Structure:
--  Atlas - Atlas name to use for icon
--  Name - Global String for Icon Label
--  Tooltip - Global String for Icon Tooltip
--  TemplateNames - Table of asscotiated Map Pin Template names
--      Note: when adding a new template for the legend, be sure the template inherits LegendHighlightableMapPoiPinTemplate and also calls LegendHighlightablePoiPinMixin:OnLegendPinMouseEnter/Leave
--  MetaData - Table of needed meta data to differentiate between different pins with the same template. If no meta data exists, all pins with the given template names will highlight
--      Note: when adding new meta data types, be sure to update MapLegendButtonMixin:MetaDataMatches to check the new data comparison
--  BackgroundAtlas - Optional Atlas name for background to icon
local QuestsCategoryData = {
  {Atlas = "Quest-Campaign-Available", fixedWidth = 28, fixedHeight = 28, Name = MAP_LEGEND_CAMPAIGN,   Tooltip = MAP_LEGEND_CAMPAIGN_TOOLTIP,    TemplateNames = {"QuestPinTemplate","QuestOfferPinTemplate"},  MetaData = {questClassification = Enum.QuestClassification.Campaign }},
  {Atlas = "UI-QuestPoiImportant-QuestBang", fixedWidth = 28, fixedHeight = 32,  Name = MAP_LEGEND_IMPORTANT,  Tooltip = MAP_LEGEND_IMPORTANT_TOOLTIP,   TemplateNames = {"QuestPinTemplate","QuestOfferPinTemplate"},  MetaData = {questClassification = Enum.QuestClassification.Important}},
  {Atlas = "UI-QuestPoiLegendary-QuestBang",  Name = MAP_LEGEND_LEGENDARY,  Tooltip = MAP_LEGEND_LEGENDARY_TOOLTIP,   TemplateNames = {"QuestPinTemplate","QuestOfferPinTemplate"}, MetaData = {questClassification = Enum.QuestClassification.Legendary}},
  {Atlas = "UI-QuestPoiWrapper-QuestBang",    Name = MAP_LEGEND_META,       Tooltip = MAP_LEGEND_META_TOOLTIP,        TemplateNames = {"QuestPinTemplate","QuestOfferPinTemplate"}, MetaData = {questClassification = Enum.QuestClassification.Meta}},
  {Atlas = "UI-QuestPoiRecurring-QuestBang",    Name = MAP_LEGEND_REPEATABLE, Tooltip = MAP_LEGEND_REPEATABLE_TOOLTIP,        TemplateNames = {"QuestPinTemplate","QuestOfferPinTemplate"}, MetaData = {questClassification = Enum.QuestClassification.Recurring}},
  {Atlas = "QuestNormal", fixedWidth = 28, fixedHeight = 28, Name = MAP_LEGEND_LOCALSTORY, Tooltip = MAP_LEGEND_LOCALSTORY_TOOLTIP,  TemplateNames = {"QuestPinTemplate","QuestOfferPinTemplate"}, MetaData = {questClassification = Enum.QuestClassification.Normal}},
  {Atlas = "Quest-In-Progress-Icon-yellow",   Name = MAP_LEGEND_INPROGRESS, Tooltip = MAP_LEGEND_INPROGRESS_TOOLTIP,  TemplateNames = {"QuestPinTemplate"},                         MetaData = {Style = POIButtonUtil.Style.QuestInProgress},     BackgroundAtlas = "UI-QuestPoi-QuestNumber"},
  {Atlas = "UI-QuestPoi-QuestBangTurnIn",     Name = MAP_LEGEND_TURNIN,     Tooltip = MAP_LEGEND_TURNIN_TOOLTIP,      TemplateNames = {"QuestPinTemplate"},                         MetaData = {Style = POIButtonUtil.Style.QuestComplete},       BackgroundAtlas = "UI-QuestPoi-QuestNumber"}
};

local LimitedCategoryData = {
  {Atlas = "worldquest-icon",               Name = MAP_LEGEND_WORLDQUEST,     Tooltip = MAP_LEGEND_WORLDQUEST_TOOLTIP,      TemplateNames = {"WorldQuestPinTemplate", "WorldMap_WorldQuestPinTemplate"},  BackgroundAtlas = "UI-QuestPoi-QuestNumber"},
  {Atlas = "vignettekillboss",              Name = MAP_LEGEND_WORLDBOSS,      Tooltip = MAP_LEGEND_WORLDBOSS_TOOLTIP,       TemplateNames = {"WorldQuestPinTemplate", "WorldMap_WorldQuestPinTemplate"},  MetaData = {worldQuestType = Enum.QuestTagType.WorldBoss}},
  {Atlas = "Bonus-Objective-Star",           Name = MAP_LEGEND_BONUSOBJECTIVE, Tooltip = MAP_LEGEND_BONUSOBJECTIVE_TOOLTIP,  TemplateNames = {"BonusObjectivePinTemplate"}, BackgroundAtlas = "UI-QuestPoi-QuestNumber"},
  {Atlas = "minimap-genericevent-hornicon", Name = MAP_LEGEND_EVENT,          Tooltip = MAP_LEGEND_EVENT_TOOLTIP,           TemplateNames = {"AreaPOIEventPinTemplate"}, MetaData = {AtlasPrefix="UI-EventPoi"}},
  {Atlas = "VignetteKill",                  Name = MAP_LEGEND_RARE,           Tooltip = MAP_LEGEND_RARE_TOOLTIP,            TemplateNames = {"VignettePinTemplate"},                                      MetaData = {Atlas="VignetteKill"}},
  {Atlas = "VignetteKillElite",             Name = MAP_LEGEND_RAREELITE,      Tooltip = MAP_LEGEND_RAREELITE_TOOLTIP,       TemplateNames = {"VignettePinTemplate"},                                      MetaData = {Atlas="VignetteKillElite"}},
};

local ActivitiesCategoryData = {
  {Atlas = "Dungeon",                  Name = MAP_LEGEND_DUNGEON,   Tooltip = MAP_LEGEND_DUNGEON_TOOLTIP,   TemplateNames = {"DungeonEntrancePinTemplate"}, MetaData = {isRaid = false}},
  {Atlas = "Raid",                     Name = MAP_LEGEND_RAID,      Tooltip = MAP_LEGEND_RAID_TOOLTIP,      TemplateNames = {"DungeonEntrancePinTemplate"}, MetaData = {isRaid = true}},
  {Atlas = "poi-hub",                  Name = MAP_LEGEND_HUB,       Tooltip = MAP_LEGEND_HUB_TOOLTIP,       TemplateNames = {"QuestHubPinTemplate"}},
  {Atlas = "ArchBlob",                 Name = MAP_LEGEND_DIGSITE,   Tooltip = MAP_LEGEND_DIGSITE_TOOLTIP,   TemplateNames = {"DigSitePinTemplate"}},
  {Atlas = "WildBattlePetCapturable", fixedWidth = 28, fixedHeight = 28, Name = MAP_LEGEND_PETBATTLE, Tooltip = MAP_LEGEND_PETBATTLE_TOOLTIP, TemplateNames = {"PetTamerPinTemplate"}},
  {Atlas = "delves-regular",		   Name = MAP_LEGEND_DELVE,		Tooltip = MAP_LEGEND_DELVE_TOOLTIP,		TemplateNames = {"DelveEntrancePinTemplate", "AreaPOIPinTemplate"}, MetaData = {AtlasPrefix="delves-"}},	
};

local MovementCategoryData = {
  {Atlas = "TaxiNode_Continent_Neutral",  Name = MAP_LEGEND_TELEPORT,     Tooltip = MAP_LEGEND_TELEPORT_TOOLTIP,    TemplateNames = {"AreaPOIPinTemplate"}, MetaData = {AtlasPrefix = "TaxiNode_Continent"}},
  {Atlas = "CaveUnderground-Up",          Name = MAP_LEGEND_CAVE,         Tooltip = MAP_LEGEND_CAVE_TOOLTIP,        TemplateNames = {"MapLinkPinTemplate"}},
  {Atlas = "FlightPath",                  Name = MAP_LEGEND_FLIGHTPOINT,  Tooltip = MAP_LEGEND_FLIGHTPOINT_TOOLTIP, TemplateNames = {"FlightPointPinTemplate"}},
};

--Legend Data
--Add more categories here! Data Structure:
--  CategoryTitle = Global String Title to display
--  CategoryData = Legend Catagory Data table defined above
local MapLegendData = {
  {CategoryTitle = MAP_LEGEND_CATEGORY_QUESTS,      CategoryData = QuestsCategoryData},
  {CategoryTitle = MAP_LEGEND_CATEGORY_LTA,         CategoryData = LimitedCategoryData},
  {CategoryTitle = MAP_LEGEND_CATEGORY_ACTIVITIES,  CategoryData = ActivitiesCategoryData},
  {CategoryTitle = MAP_LEGEND_CATEGORY_MOVEMENT,    CategoryData = MovementCategoryData},
};

function MapLegendMixin:SetupCategories()
	for index, data in ipairs(MapLegendData) do
		local category = CreateFrame("Frame", data.CategoryTitle, self.ScrollFrame.ScrollChild, "MapLegendCategoryTemplate", index);
		category.TitleText:SetText(data.CategoryTitle);
		category.layoutIndex = index;
		category:Show();

		local buttons = {};
		for i, categoryData in ipairs(data.CategoryData) do
			local button = CreateFrame("Button", categoryData.Name, category, "MapLegendButtonTemplate", i);
			button:InitilizeButton(categoryData, i);
			table.insert(buttons, button);
		end

		local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, 2, 0, 5);
		local anchor = CreateAnchor("TOPLEFT", category, "TOPLEFT", 0, 0);
		AnchorUtil.GridLayout(buttons, anchor, layout);

		category:Layout();
	end
end

function MapLegendMixin:OnBackClicked()
	EventRegistry:TriggerEvent("HideMapLegend");
end

MapLegendButtonMixin = { };

function MapLegendButtonMixin:OnEnter()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	GameTooltip_SetTitle(tooltip, self.nameText);
	GameTooltip_AddNormalLine(tooltip, self.tooltipText);
	tooltip:Show();
	self:HighlightMapPins();
end

function MapLegendButtonMixin:OnLeave()
	GetAppropriateTooltip():Hide();
	self:ClearHighlights();
end

function MapLegendButtonMixin:InitilizeButton(buttonInfo, index)
	self.Icon:SetAtlas(buttonInfo.Atlas, TextureKitConstants.UseAtlasSize);
	if buttonInfo.fixedWidth and buttonInfo.fixedHeight then
		self.Icon:SetSize(buttonInfo.fixedWidth, buttonInfo.fixedHeight);
	end

	if (buttonInfo.BackgroundAtlas) then
		self.IconBack:SetAtlas(buttonInfo.BackgroundAtlas, TextureKitConstants.UseAtlasSize);
		self.IconBack:Show();
	end
	self:SetText(buttonInfo.Name);
	self:Show();
	self.nameText = buttonInfo.Name;
	self.layoutIndex = index;
	self.tooltipText = buttonInfo.Tooltip;
	self.templates = buttonInfo.TemplateNames;
	--metadata
	self.metaData = buttonInfo.MetaData;

	EventRegistry:RegisterCallback("MapLegendPinOnEnter", self.HighlightSelfForPin, self);
	EventRegistry:RegisterCallback("MapLegendPinOnLeave", self.RemoveSelfHighlight, self);
end

function MapLegendButtonMixin:HighlightSelfForPin(pin)
	for i, templateName in ipairs(self.templates) do
		if pin.pinTemplate == templateName then
			if self:MetaDataMatches(pin) then
				self:SetHighlightLocked(true);
			end
		end
	end
end

function MapLegendButtonMixin:RemoveSelfHighlight()
	self:SetHighlightLocked(false);
end

function MapLegendButtonMixin:HighlightMapPins()
	self.highlightedPins = {};
	for i, templateName in ipairs(self.templates) do
		for pin in WorldMapFrame:EnumeratePinsByTemplate(templateName) do
			--check metadata comparisons. Returns true if data matches or no data exists
			if self:MetaDataMatches(pin) then
				pin:ShowMapLegendGlow();
				table.insert(self.highlightedPins, pin);
			end
		end
	end
end

function MapLegendButtonMixin:MetaDataMatches(pin)
	if self.metaData then
		if self.metaData.Style and pin.GetStyle and pin:GetStyle() == self.metaData.Style then
			return true;
		end
		if self.metaData.questClassification and pin.GetQuestClassification and pin:GetQuestClassification() == self.metaData.questClassification then
			return true;
		end
		if self.metaData.isRaid ~= nil and pin.isRaid ~= nil and self.metaData.isRaid == pin.isRaid then
			return true;
		end
		if self.metaData.worldQuestType and pin.worldQuestType and pin.worldQuestType == self.metaData.worldQuestType then
			return true;
		end
		if self.metaData.Atlas and pin.poiInfo and self.metaData.Atlas == pin.poiInfo.atlasName then
			return true;
		end
		if self.metaData.AtlasPrefix and pin.poiInfo and pin.poiInfo.atlasName then
			if string.find(pin.poiInfo.atlasName, self.metaData.AtlasPrefix, 1, true) == 1 then
				return true;
			end
		end
		return false;
	else --return true if button has no meta data
		return true;
	end
end

function MapLegendButtonMixin:ClearHighlights()
	if self.highlightedPins then
		for i, pin in ipairs(self.highlightedPins) do
			pin:HideMapLegendGlow();
		end
	end
end
