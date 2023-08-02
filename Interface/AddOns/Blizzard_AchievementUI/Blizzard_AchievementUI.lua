
UIPanelWindows["AchievementFrame"] = { area = "doublewide", pushable = 0, xoffset = 80, whileDead = 1 };

ACHIEVEMENT_GOLD_BORDER_COLOR	= CreateColor(1, 0.675, 0.125);
ACHIEVEMENT_RED_BORDER_COLOR	= CreateColor(0.7, 0.15, 0.05);
ACHIEVEMENT_BLUE_BORDER_COLOR	= CreateColor(0.129, 0.671, 0.875);
ACHIEVEMENT_YELLOW_BORDER_COLOR = CreateColor(0.4, 0.2, 0.0);

ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT1 = GameFontNormal;
ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT2 = GameFontNormalSmall;
ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT1 = GameFontNormalSmall;
ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT2 = GameFontNormalSmall;

ACHIEVEMENTUI_CATEGORIESWIDTH = 175;

ACHIEVEMENTUI_PROGRESSIVEHEIGHT = 50;
ACHIEVEMENTUI_PROGRESSIVEWIDTH = 42;

ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS = 4;

ACHIEVEMENTUI_MAXCONTENTWIDTH = 330;
ACHIEVEMENTUI_CRITERIACHECKWIDTH = 20;
local ACHIEVEMENTUI_FONTHEIGHT;						-- set in AchievementButton_OnLoad
local ACHIEVEMENTUI_MAX_LINES_COLLAPSED = 3;		-- can show 3 lines of text when achievement is collapsed

ACHIEVEMENTUI_DEFAULTSUMMARYACHIEVEMENTS = {6, 503, 116, 545, 1017};
ACHIEVEMENTUI_SUMMARYCATEGORIES = {92, 96, 97, 95, 168, 169, 201, 155, 15117, 15246};
ACHIEVEMENTUI_DEFAULTGUILDSUMMARYACHIEVEMENTS = {5362, 4860, 4989, 4947};
ACHIEVEMENTUI_GUILDSUMMARYCATEGORIES = {15088, 15077, 15078, 15079, 15080, 15089};

ACHIEVEMENT_CATEGORY_NORMAL_R = 0;
ACHIEVEMENT_CATEGORY_NORMAL_G = 0;
ACHIEVEMENT_CATEGORY_NORMAL_B = 0;
ACHIEVEMENT_CATEGORY_NORMAL_A = .9;

ACHIEVEMENT_CATEGORY_HIGHLIGHT_R = 0;
ACHIEVEMENT_CATEGORY_HIGHLIGHT_G = .6;
ACHIEVEMENT_CATEGORY_HIGHLIGHT_B = 0;
ACHIEVEMENT_CATEGORY_HIGHLIGHT_A = .65;

ACHIEVEMENTBUTTON_LABELWIDTH = 320;

ACHIEVEMENT_COMPARISON_SUMMARY_ID = -1;
ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID = -2;

ACHIEVEMENT_FILTER_ALL = 1;
ACHIEVEMENT_FILTER_COMPLETE = 2;
ACHIEVEMENT_FILTER_INCOMPLETE = 3;

local FORCE_COLUMNS_MAX_WIDTH = 220;				-- if no columns normally, force 2 if max criteria width is <= this and number of criteria >= MIN_CRITERIA
local FORCE_COLUMNS_MIN_CRITERIA = 20;
local FORCE_COLUMNS_LEFT_OFFSET = -10;				-- offset for left column
local FORCE_COLUMNS_RIGHT_OFFSET = 24;				-- offset for right column
local FORCE_COLUMNS_RIGHT_COLUMN_SPACE = 150;		-- max room for first entry of the right column due to achievement shield

AchievementFrameFilterStrings = {ACHIEVEMENT_FILTER_ALL_EXPLANATION,
ACHIEVEMENT_FILTER_COMPLETE_EXPLANATION, ACHIEVEMENT_FILTER_INCOMPLETE_EXPLANATION};

local FEAT_OF_STRENGTH_ID = 81;
local GUILD_FEAT_OF_STRENGTH_ID = 15093;
local GUILD_CATEGORY_ID = 15076;
local TEXTURES_OFFSET = 0;		-- 0.5 when in guild view

local ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS = 5;
local ACHIEVEMENT_FRAME_SHOW_ALL_RESULTS_INDEX = ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS + 1;

local guildMemberRequestFrame;

local trackedAchievements = {};
local achievementFunctions;
local function updateTrackedAchievements(achievementIDs)
	trackedAchievements = {};
	for i, id in ipairs(achievementIDs) do
		trackedAchievements[id] = true;
	end
end

local AchievementCategoryIndex = 1;
local GuildCategoryIndex = 2;
local StatisticsCategoryIndex = 3;
local g_achievementSelectionBehavior = nil;
local g_achievementSelections = {{},{},{}};
local function GetSelectedAchievement(categoryIndex)
	local categoryIndex = achievementFunctions.categoryIndex;
	return g_achievementSelections[categoryIndex].id or 0;
end

local g_categorySelections = {{},{},{}};
local function GetSelectedCategory(categoryIndex)
	local categoryIndex = achievementFunctions.categoryIndex;
	return g_categorySelections[categoryIndex].id or 0;
end

local function SetSelectedAchievement(elementData)
	local categoryIndex = achievementFunctions.categoryIndex;
	g_achievementSelections[categoryIndex] = elementData or {};
end

local function ClearSelectedCategories()
	g_categorySelections = {{},{},{}};
end

local function InGuildView()
	return achievementFunctions == GUILD_ACHIEVEMENT_FUNCTIONS;
end

local function IsCategoryFeatOfStrength(category)
	return category == FEAT_OF_STRENGTH_ID or category == GUILD_FEAT_OF_STRENGTH_ID
end

local function AchievementFrameCategories_MakeCategoryList(source, fakeSummaryId)
	local categories = {};
	if fakeSummaryId then
		tinsert(categories, { id = fakeSummaryId });
	end

	for i, id in next, source do
		local _, parent = GetCategoryInfo(id);
		if ( parent == -1 or parent == GUILD_CATEGORY_ID ) then
			tinsert(categories, { id = id });
		end
	end

	local _, parent;
	for i = #source, 1, -1 do
		_, parent = GetCategoryInfo(source[i]);
		for j, category in next, categories do
			if ( category.id == parent ) then
				category.parent = true;
				category.collapsed = true;
				local elementData = {
					id = source[i],
					parent = category.id,
					hidden = true,
					isChild = (type(category.id) == "number"),
				};
				tinsert(categories, j+1, elementData);
			end
		end
	end
	return categories;
end

ACHIEVEMENT_FUNCTIONS = {
	categoryIndex = AchievementCategoryIndex,
	categories = AchievementFrameCategories_MakeCategoryList(GetCategoryList(), "summary"),
}

GUILD_ACHIEVEMENT_FUNCTIONS = {
	categoryIndex = GuildCategoryIndex,
	categories = AchievementFrameCategories_MakeCategoryList(GetGuildCategoryList(), "summary"),
}

STAT_FUNCTIONS = {
	categoryIndex = StatisticsCategoryIndex,
	categories = AchievementFrameCategories_MakeCategoryList(GetStatisticsCategoryList()),
}

COMPARISON_ACHIEVEMENT_FUNCTIONS = {
	categoryIndex = AchievementCategoryIndex,
	categories = AchievementFrameCategories_MakeCategoryList(GetCategoryList()),
}

COMPARISON_STAT_FUNCTIONS = {
	categoryIndex = StatisticsCategoryIndex,
	categories = AchievementFrameCategories_MakeCategoryList(GetStatisticsCategoryList()),
}

achievementFunctions = ACHIEVEMENT_FUNCTIONS;

local function AchievementFrame_GetOrSelectCurrentCategory()
	local category = GetSelectedCategory();
	if category == 0 then
		AchievementFrameCategories_SelectDefaultElementData();
		return GetSelectedCategory();
	end
	return category;
end

-- [[ AchievementFrame ]] --

function AchievementFrame_ToggleAchievementFrame(toggleStatFrame, toggleGuildView)
	AchievementFrameComparison:Hide();
	AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
	if ( not toggleStatFrame ) then
		if ( AchievementFrame:IsShown() and AchievementFrame.selectedTab == 1 ) then
			HideUIPanel(AchievementFrame);
		else
			AchievementFrame_SetTabs();
			ShowUIPanel(AchievementFrame);
			if ( toggleGuildView ) then
				AchievementFrameTab_OnClick(2);
			else
				AchievementFrameTab_OnClick(1);
			end
		end
		return;
	end
	if ( AchievementFrame:IsShown() and AchievementFrame.selectedTab == 3 ) then
		HideUIPanel(AchievementFrame);
	else
		ShowUIPanel(AchievementFrame);
		AchievementFrame_SetTabs();
		AchievementFrameTab_OnClick(3);
	end
end

function AchievementFrame_DisplayComparison (unit)
	ClearSelectedCategories();

	AchievementFrameTab_OnClick = AchievementFrameComparisonTab_OnClick;
	AchievementFrameTab_OnClick(1);
	AchievementFrame_SetComparisonTabs();
	ShowUIPanel(AchievementFrame);
	AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparison.AchievementContainer);
	AchievementFrameComparison_SetUnit(unit);
	AchievementFrameComparison_ForceUpdate();
end

function AchievementFrame_OnLoad (self)
	PanelTemplates_SetNumTabs(self, 3);
	self.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);

	self.PlaceholderHiddenDescription:SetWidth(ACHIEVEMENTUI_MAXCONTENTWIDTH);
end

function AchievementFrame_OnShow (self)
	PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_OPEN);
	AchievementFrame.Header.Points:SetText(BreakUpLargeNumbers(GetTotalAchievementPoints()));
	UpdateMicroButtons();
end

function AchievementFrame_OnHide (self)
	PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_CLOSE);
	AchievementFrame_HideSearchPreview();
	self.SearchResults:Hide();
	self.SearchBox:SetText("");
	UpdateMicroButtons();
end

function AchievementFrame_ForceUpdate ()
	if ( AchievementFrameAchievements:IsShown() ) then
		AchievementFrameAchievements_ForceUpdate();
	elseif ( AchievementFrameStats:IsShown() ) then
		AchievementFrameStats_UpdateDataProvider();
	elseif ( AchievementFrameComparison:IsShown() ) then
		AchievementFrameComparison_ForceUpdate();
	end
end

function AchievementFrame_SetTabs()
	PanelTemplates_ShowTab(AchievementFrame, 2);
	AchievementFrameTab3:SetPoint("LEFT", AchievementFrameTab2, "RIGHT", -5, 0);
end

function AchievementFrame_SetComparisonTabs()
	PanelTemplates_HideTab(AchievementFrame, 2);
	AchievementFrameTab3:SetPoint("LEFT", AchievementFrameTab1, "RIGHT", -5, 0);
end

function AchievementFrame_UpdateTabs(clickedTab)
	AchievementFrame.SearchResults:Hide();
	PanelTemplates_Tab_OnClick(_G["AchievementFrameTab"..clickedTab], AchievementFrame);
	for i = 1, 3 do
		local tab = _G["AchievementFrameTab"..i];
		local y = i == clickedTab and -5 or -3;
		tab.Text:SetPoint("CENTER", 0, y);
	end
end

function AchievementFrame_RefreshView()
	if InGuildView() then
		TEXTURES_OFFSET = 0.5;
		AchievementFrameAchievements.Background:SetTexCoord(0, 1, 0.5, 1);
		AchievementFrameSummary.Background:SetTexCoord(0, 1, 0.5, 1);
		AchievementFrame.Header.Points:SetVertexColor(0, 1, 0);
		AchievementFrame.Header.Title:SetText(GUILD_ACHIEVEMENTS_TITLE);
		local shield = AchievementFrame.Header.Shield;
		shield:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
		shield:SetTexCoord(0.63281250, 0.67187500, 0.13085938, 0.16601563);
		shield:SetHeight(18);
		local bkgR, bkgG, bkgB, borderR, borderG, borderB, emblemR, emblemG, emblemB, emblemFilename = GetGuildLogoInfo();
		if ( emblemFilename ) then
			AchievementFrameGuildEmblemLeft:SetTexture(emblemFilename);
			AchievementFrameGuildEmblemRight:SetTexture(emblemFilename);
			local r, g, b = ACHIEVEMENT_YELLOW_BORDER_COLOR:GetRGB();
			AchievementFrameGuildEmblemLeft:SetVertexColor(r, g, b, 0.5);
			AchievementFrameGuildEmblemRight:SetVertexColor(r, g, b, 0.5);
		end
	else
		TEXTURES_OFFSET = 0;
		AchievementFrameAchievements.Background:SetTexCoord(0, 1, 0, 0.5);
		AchievementFrameSummary.Background:SetTexCoord(0, 1, 0, 0.5);
		AchievementFrame.Header.Points:SetVertexColor(1, 1, 1);
		AchievementFrame.Header.Title:SetText(ACHIEVEMENT_TITLE);
		local shield = AchievementFrame.Header.Shield;
		shield:SetTexture("Interface\\AchievementFrame\\UI-Achievement-TinyShield");
		shield:SetTexCoord(0, 0.625, 0, 0.625);
		shield:SetHeight(20);
	end

	AchievementFrame.Header.Points:SetText(BreakUpLargeNumbers(GetTotalAchievementPoints(InGuildView())));
end

local function OpenToSelectedCategory()
	-- Build out the data provider of our new categories, then get or select an appropriate category.
	AchievementFrameCategories_UpdateDataProvider();
	return AchievementFrame_GetOrSelectCurrentCategory();
end

local function InitAchievementPage(category)
	local category = OpenToSelectedCategory();
	if category == "summary" then
		AchievementFrame_ShowSubFrame(AchievementFrameSummary);
		AchievementFrameSummary_Update();
	else
		AchievementFrame_ShowSubFrame(AchievementFrameAchievements);
		AchievementFrameAchievements_UpdateDataProvider();
		
		-- Restore selection
		local achievementId = GetSelectedAchievement();
		if achievementId > 0 then
			AchievementFrame_SelectAndScrollToAchievementId(AchievementFrameAchievements.ScrollBox, achievementId);
		end
	end

	AchievementFrame_RefreshView();
end;

function AchievementFrameBaseTab_OnClick (tabIndex)
	AchievementFrame_UpdateTabs(tabIndex);

	if tabIndex == AchievementCategoryIndex then
		achievementFunctions = ACHIEVEMENT_FUNCTIONS;
		InitAchievementPage(category);
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-AchievementWatermark");
		AchievementFrameCategoriesBG:SetTexCoord(0, 0.5, 0, 1);
		AchievementFrameGuildEmblemLeft:Hide();
		AchievementFrameGuildEmblemRight:Hide();
	elseif tabIndex == GuildCategoryIndex then
		achievementFunctions = GUILD_ACHIEVEMENT_FUNCTIONS;
		InitAchievementPage(category);
		AchievementFrameWaterMark:SetTexture();
		AchievementFrameCategoriesBG:SetTexCoord(0.5, 1, 0, 1);
		AchievementFrameGuildEmblemLeft:Show();
		AchievementFrameGuildEmblemRight:Show();
	elseif tabIndex == StatisticsCategoryIndex then
		achievementFunctions = STAT_FUNCTIONS;
		OpenToSelectedCategory();
		AchievementFrame_ShowSubFrame(AchievementFrameStats);
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-StatWatermark");
		AchievementFrameCategoriesBG:SetTexCoord(0, 0.5, 0, 1);
		AchievementFrameGuildEmblemLeft:Hide();
		AchievementFrameGuildEmblemRight:Hide();
	end

	SwitchAchievementSearchTab(tabIndex);
end

AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;

function AchievementFrameComparisonTab_OnClick (tabIndex)
	local oldGuildView = InGuildView();

	if tabIndex == AchievementCategoryIndex then
		achievementFunctions = COMPARISON_ACHIEVEMENT_FUNCTIONS;
		OpenToSelectedCategory();
		AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparison.AchievementContainer);
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-AchievementWatermark");
		AchievementFrameComparison_UpdateDataProvider();
	elseif tabIndex == StatisticsCategoryIndex then
		achievementFunctions = COMPARISON_STAT_FUNCTIONS;
		OpenToSelectedCategory();
		AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparison.StatContainer);
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-StatWatermark");
		AchievementFrameComparison_UpdateStatsDataProvider();
	end

	if oldGuildView then
		AchievementFrame_RefreshView();
		AchievementFrameGuildEmblemLeft:Hide();
		AchievementFrameGuildEmblemRight:Hide();
	end
	
	AchievementFrameCategoriesBG:SetTexCoord(0, 0.5, 0, 1);
	AchievementFrame_UpdateTabs(tabIndex);
	SwitchAchievementSearchTab(tabIndex);
end

local subFramesList;
local function GetOrCreateAchievementSubFramesList()
	if not subFramesList then
		subFramesList = {
			AchievementFrameSummary,
			AchievementFrameAchievements,
			AchievementFrameStats,
			AchievementFrameComparison,
			AchievementFrameComparison.AchievementContainer,
			AchievementFrameComparison.StatContainer
		};
	end
	return subFramesList;
end

function AchievementFrame_ShowSubFrame(...)
	for _, subFrame in ipairs(GetOrCreateAchievementSubFramesList()) do
		show = false;
		for i = 1, select("#", ...) do
			if subFrame == select(i, ...) then
				show = true;
				break;
			end
		end
		subFrame:SetShown(show);
	end
end

-- [[ AchievementFrameCategories ]] --

AchievementCategoryTemplateMixin = {};

function AchievementCategoryTemplateMixin:OnLoad()
	AchievementCategoryButton_Localize(self.Button);

	self.Button:SetScript("OnClick", function()
		AchievementFrameCategories_OnCategoryClicked(self);
	end);
end

function AchievementCategoryTemplateMixin:OnClick(buttonName, down)
	AchievementFrameCategories_OnCategoryClicked(self);
end

function AchievementCategoryTemplateMixin:Init(elementData)
	if ( elementData.isChild ) then
		self.Button:SetWidth(ACHIEVEMENTUI_CATEGORIESWIDTH - 25);
		self.Button.Label:SetFontObject("GameFontHighlight");
		self.parentID = elementData.parent;
		self.Button.Background:SetVertexColor(0.6, 0.6, 0.6);
	else
		self.Button:SetWidth(ACHIEVEMENTUI_CATEGORIESWIDTH - 10);
		self.Button.Label:SetFontObject("GameFontNormal");
		self.parentID = elementData.parent;
		self.Button.Background:SetVertexColor(1, 1, 1);
	end

	local categoryName, parentID, flags;
	local numAchievements, numCompleted;

	local id = elementData.id;

	-- kind of janky
	if ( id == "summary" ) then
		categoryName = ACHIEVEMENT_SUMMARY_CATEGORY;
		numAchievements, numCompleted = GetNumCompletedAchievements(InGuildView());
	else
		categoryName, parentID, flags = GetCategoryInfo(id);
		numAchievements, numCompleted = AchievementFrame_GetCategoryTotalNumAchievements(id, true);
	end

	self.Button.Label:SetText(categoryName);
	self.categoryID = id;
	self.flags = flags;

	-- For the tooltip
	self.Button.name = categoryName;
	if ( id == FEAT_OF_STRENGTH_ID ) then
		-- This is the feat of strength category since it's sorted to the end of the list
		self.Button.text = FEAT_OF_STRENGTH_DESCRIPTION;
		self.Button.showTooltipFunc = AchievementFrameCategory_FeatOfStrengthTooltip;
	elseif ( id == GUILD_FEAT_OF_STRENGTH_ID ) then
		self.Button.text = GUILD_FEAT_OF_STRENGTH_DESCRIPTION;
		self.Button.showTooltipFunc = AchievementFrameCategory_FeatOfStrengthTooltip;
	elseif ( AchievementFrame.selectedTab == 1 or AchievementFrame.selectedTab == 2 ) then
		self.Button.text = nil;
		self.Button.numAchievements = numAchievements;
		self.Button.numCompleted = numCompleted;
		self.Button.numCompletedText = numCompleted.."/"..numAchievements;
		self.Button.showTooltipFunc = AchievementFrameCategory_StatusBarTooltip;
	else
		self.Button.showTooltipFunc = nil;
	end

	self:UpdateSelectionState(elementData.selected);
end

function AchievementCategoryTemplateMixin:UpdateSelectionState(selected)
	if selected then
		self.Button:LockHighlight();
	else
		self.Button:UnlockHighlight();
	end
end

AchievementCategoryTemplateButtonMixin = {};

function AchievementCategoryTemplateButtonMixin:OnEnter()
    if ( self.showTooltipFunc ) then
		self.showTooltipFunc(self);
	end
end

function AchievementCategoryTemplateButtonMixin:OnLeave()
	GameTooltip:SetMinimumWidth(0, false);
	GameTooltip:Hide();
end

function AchievementFrameCategories_OnLoad (self)
	self:RegisterEvent("ADDON_LOADED");

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("AchievementCategoryTemplate", function(frame, elementData)
		frame:Init(elementData);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function AchievementFrameCategories_ExpandToCategory(category)
	local categories = achievementFunctions.categories;
	local index, elementData = FindInTableIf(categories, function(elementData)
		return elementData.id == category;
	end);

	if elementData and elementData.isChild then
		local openID = elementData.parent;
		for index, iterElementData in ipairs(categories) do
			iterElementData.hidden = iterElementData.isChild and iterElementData.parent ~= openID;
		end
	end
end

function AchievementFrameCategories_SelectElementData(elementData, ignoreCollapse)
	local categoryIndex = achievementFunctions.categoryIndex;
	local selection = g_categorySelections[categoryIndex];
	local category = elementData.id;
	local categoryChanged = selection.id ~= category;

	-- Don't modify any collapsed state if we're transitioning from a child to it's parent.
	local changeCollapsed = not ignoreCollapse and not (elementData.parent and selection.parent == category);
	local oldCollapsed = elementData.collapsed;
	local isChild = elementData.isChild;
	
	local categories = achievementFunctions.categories;
	for index, iterElementData in ipairs(categories) do
		if iterElementData.selected then
			iterElementData.selected = false;
			local frame = AchievementFrameCategories.ScrollBox:FindFrame(iterElementData);
			if frame then
				frame:UpdateSelectionState(false);
			end
		end

		if not isChild and changeCollapsed then
			if not iterElementData.isChild then
				iterElementData.collapsed = true;
			end
		end
	end

	if not isChild then
		local newCollapsed = newCollapsed;
		if changeCollapsed then
			newCollapsed = not oldCollapsed;
			if not elementData.isChild then
				elementData.collapsed = newCollapsed;
			end
		end

		for index, iterElementData in ipairs(categories) do
			if iterElementData.parent == category then
				iterElementData.hidden = newCollapsed;
			elseif iterElementData.parent ~= nil and iterElementData.isChild then
				iterElementData.hidden = true;
			end
		end
	end

	elementData.selected = true;
	g_categorySelections[categoryIndex] = elementData;

	local frame = AchievementFrameCategories.ScrollBox:FindFrame(elementData);
	if frame then
		frame:UpdateSelectionState(true);
	end
	
	-- No change in the contents of the list. We only changed the selection.
	if not isChild and changeCollapsed then
		AchievementFrameCategories_UpdateDataProvider();
	end

	if categoryChanged then
		AchievementFrameCategories_OnCategoryChanged(category);
	end
end

function AchievementFrameCategories_OnCategoryClicked(button)
	AchievementFrameCategories_SelectElementData(button:GetElementData());
end

function AchievementFrameCategories_OnShow (self)
	AchievementFrameCategories_UpdateDataProvider();
	AchievementFrame_GetOrSelectCurrentCategory();
end

function AchievementFrameCategories_SelectDefaultElementData()
	if not AchievementFrameCategories.ScrollBox:HasDataProvider() then
		AchievementFrameCategories_UpdateDataProvider();
	end

	local elementData = AchievementFrameCategories.ScrollBox:ScrollToElementDataIndex(1, ScrollBoxConstants.AlignCenter, ScrollBoxConstants.NoScrollInterpolation);
	if elementData then
		AchievementFrameCategories_SelectElementData(elementData);
	end
end

function AchievementFrameCategories_UpdateDataProvider ()
	local newDataProvider = CreateDataProvider();
	for index, category in ipairs(achievementFunctions.categories) do
		if not category.hidden then
			newDataProvider:Insert(category);
		end;
	end

	AchievementFrameCategories.ScrollBox:SetDataProvider(newDataProvider);
end

function AchievementFrameCategory_StatusBarTooltip(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip:SetMinimumWidth(128, true);
	GameTooltip:SetText(self.name, 1, 1, 1, nil, true);
	GameTooltip_ShowStatusBar(GameTooltip, 0, self.numAchievements, self.numCompleted, self.numCompletedText);
	GameTooltip:Show();
end

function AchievementFrameCategory_FeatOfStrengthTooltip(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip:SetText(self.name, 1, 1, 1);
	GameTooltip:AddLine(self.text, nil, nil, nil, true);
	GameTooltip:Show();
end

function AchievementFrameCategories_UpdateTooltip()
	AchievementFrameCategories.ScrollBox:ForEachFrame(function(frame, elementData)
		if frame.showTooltipFunc and frame:IsMouseOver() then
			frame:showTooltipFunc();
		end
	end);
end

function AchievementFrameCategories_OnCategoryChanged(category)
	if ( category == "summary" ) then
		if ( achievementFunctions == ACHIEVEMENT_FUNCTIONS or achievementFunctions == GUILD_ACHIEVEMENT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameSummary);
			AchievementFrameSummary_Update();
		end
	else
		if ( achievementFunctions == ACHIEVEMENT_FUNCTIONS or achievementFunctions == GUILD_ACHIEVEMENT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameAchievements);
			AchievementFrameAchievements_UpdateDataProvider();
			if IsCategoryFeatOfStrength(category) then
				AchievementFrameFilterDropDown:Hide();
				AchievementFrame.Header.LeftDDLInset:Hide();
			else
				AchievementFrameFilterDropDown:Show();
				AchievementFrame.Header.LeftDDLInset:Show();
			end
		elseif ( achievementFunctions == COMPARISON_ACHIEVEMENT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparison.AchievementContainer);
			AchievementFrameComparison_UpdateDataProvider();
			AchievementFrameComparison_UpdateStatusBars(category);
		elseif ( achievementFunctions == STAT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameStats);
			AchievementFrameStats_UpdateDataProvider();
		else
			AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparison.StatContainer);
			AchievementFrameComparison_UpdateStatsDataProvider();
		end
		
		local numAchievements, numCompleted, completedOffset = ACHIEVEMENTUI_SELECTEDFILTER(category);
		local fosShown = numAchievements == 0 and IsCategoryFeatOfStrength(category);
		AchievementFrameAchievementsFeatOfStrengthText:SetShown(fosShown);
		if fosShown then
			local asGuild = AchievementFrame.selectedTab == 2;
			AchievementFrameAchievementsFeatOfStrengthText:SetText(asGuild and GUILD_FEAT_OF_STRENGTH_DESCRIPTION or FEAT_OF_STRENGTH_DESCRIPTION);
		end
	end
end

local AchievementFrameShownEvents =
{
	"ACHIEVEMENT_EARNED",
	"CRITERIA_UPDATE",
	"RECEIVED_ACHIEVEMENT_MEMBER_LIST",
	"ACHIEVEMENT_SEARCH_UPDATED",
};

function AchievementFrameAchievements_OnShow(self)
	FrameUtil.RegisterFrameForEvents(self, AchievementFrameShownEvents);

	if IsCategoryFeatOfStrength(GetSelectedCategory()) then
		AchievementFrameFilterDropDown:Hide();
		AchievementFrame.Header.LeftDDLInset:Hide();
	else
		AchievementFrameFilterDropDown:Show();
		AchievementFrame.Header.LeftDDLInset:Show();
	end
end

function AchievementFrameAchievements_OnHide(self)
	FrameUtil.UnregisterFrameForEvents(self, AchievementFrameShownEvents);

	AchievementFrameFilterDropDown:Hide();
	AchievementFrame.Header.LeftDDLInset:Hide();
end

function AchievementFrameComparison_UpdateStatusBars (id)
	local numAchievements, numCompleted = GetCategoryNumAchievements(id);
	local name = GetCategoryInfo(id);

	if ( id == ACHIEVEMENT_COMPARISON_SUMMARY_ID ) then
		name = ACHIEVEMENT_SUMMARY_CATEGORY;
	end

	local statusBar = AchievementFrameComparison.Summary.Player.StatusBar;
	statusBar:SetMinMaxValues(0, numAchievements);
	statusBar:SetValue(numCompleted);
	statusBar.Title:SetText(string.format(ACHIEVEMENTS_COMPLETED_CATEGORY, name));
	statusBar.Text:SetText(numCompleted.."/"..numAchievements);

	local friendCompleted = GetComparisonCategoryNumAchievements(id);
	statusBar = AchievementFrameComparison.Summary.Friend.StatusBar;
	statusBar:SetMinMaxValues(0, numAchievements);
	statusBar:SetValue(friendCompleted);
	statusBar.Text:SetText(friendCompleted.."/"..numAchievements);
end

-- [[ AchievementFrameAchievements ]] --

function AchievementFrameAchievements_OnLoad (self)
	self:RegisterEvent("ADDON_LOADED");

	local function AchievementResetter(button)
		if SelectionBehaviorMixin.IsIntrusiveSelected(button) then
			local objectives = button:GetObjectiveFrame();
			objectives:Clear();
		end
	end

	local view = CreateScrollBoxListLinearView();
	view:SetElementExtentCalculator(function(dataIndex, elementData)
		if SelectionBehaviorMixin.IsElementDataIntrusiveSelected(elementData) then
			return AchievementTemplateMixin.CalculateSelectedHeight(elementData);
		else
			return ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT;
		end
	end);
	local function AchievementInitializer(button, elementData)
		button:Init(elementData);
	end;
	view:SetElementInitializer("AchievementTemplate", AchievementInitializer);
	view:SetElementResetter(AchievementResetter);
	view:SetPadding(2,0,0,4,0);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	
	g_achievementSelectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox, SelectionBehaviorFlags.Deselectable, SelectionBehaviorFlags.Intrusive);
	g_achievementSelectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, function(o, elementData, selected)
		if selected then
			SetSelectedAchievement(elementData);
		else
			SetSelectedAchievement(nil);
		end

		local button = self.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end
	end, self);

	ScrollUtil.AddResizableChildrenBehavior(self.ScrollBox);
end

function AchievementFrameAchievements_GetSelectedElementData()
	return g_achievementSelectionBehavior:GetFirstSelectedElementData();
end

function AchievementFrameAchievements_GetSelectedAchievementId()
	local elementData = AchievementFrameAchievements_GetSelectedElementData();
	return elementData and elementData.id or 0;
end

function AchievementFrameAchievements_OnAchievementEarned(achievementId)
	AchievementFrameAchievements_UpdateDataProvider();

	if AchievementFrameAchievements_GetSelectedAchievementId() == achievementId then
		AchievementFrame_SelectAndScrollToAchievementId(AchievementFrameAchievements.ScrollBox, achievementId);
	end

	AchievementFrameCategories_UpdateTooltip();

	AchievementFrame.Header.Points:SetText(BreakUpLargeNumbers(GetTotalAchievementPoints(InGuildView())));
end

function AchievementFrameAchievements_OnCriteriaUpdate()
	local selectedElementData = AchievementFrameAchievements_GetSelectedElementData();
	if selectedElementData then
		local button = AchievementFrameAchievements.ScrollBox:FindFrame(selectedElementData);
		if button then
			button:Init(selectedElementData);
		end
	end
end

function AchievementFrameAchievements_UpdateTrackedAchievements()
	if (Kiosk.IsEnabled()) then
		return;
	end

	updateTrackedAchievements(C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement));
end

function AchievementFrameAchievements_OnEvent (self, event, ...)
	if (Kiosk.IsEnabled()) then
		return;
	end
	if ( event == "ADDON_LOADED" ) then
		AchievementFrameAchievements_UpdateTrackedAchievements();
	elseif ( event == "ACHIEVEMENT_EARNED" ) then
		if not AchievementFrameCategories.ScrollBox:HasDataProvider() then
			AchievementFrameCategories_UpdateDataProvider();
		end

		local achievementID = ...;
		AchievementFrameAchievements_OnAchievementEarned(achievementID);
	elseif ( event == "CRITERIA_UPDATE" ) then
		AchievementFrameAchievements_OnCriteriaUpdate();
	elseif ( event == "RECEIVED_ACHIEVEMENT_MEMBER_LIST" ) then
		local achievementID = ...;
		-- check if we initiated the request from a meta criteria and we're still over it
		if ( guildMemberRequestFrame and guildMemberRequestFrame.id == achievementID ) then
			-- update the tooltip
			local func = guildMemberRequestFrame:GetScript("OnEnter");
			if ( func ) then
				func(guildMemberRequestFrame);
			end
		end
	elseif ( event == "ACHIEVEMENT_SEARCH_UPDATED" ) then
		AchievementFrame.SearchBox.fullSearchFinished = true;
		AchievementFrame_UpdateSearch(self);
	end
end

function AchievementFrameAchievementsBackdrop_OnLoad (self)
	self:SetFrameLevel(self:GetFrameLevel()+1);
end

function AchievementFrameAchievements_UpdateDataProvider()
	local category = AchievementFrame_GetOrSelectCurrentCategory();
	if category == "summary" then
		return;
	end

	local numAchievements, numCompleted, completedOffset = ACHIEVEMENTUI_SELECTEDFILTER(category);
	local fosShown = numAchievements == 0 and IsCategoryFeatOfStrength(category);
	AchievementFrameAchievementsFeatOfStrengthText:SetShown(fosShown);
	if fosShown then
		local asGuild = AchievementFrame.selectedTab == 2;
		AchievementFrameAchievementsFeatOfStrengthText:SetText(asGuild and GUILD_FEAT_OF_STRENGTH_DESCRIPTION or FEAT_OF_STRENGTH_DESCRIPTION);
	end

	local newDataProvider = CreateDataProvider();
	for index = 1, numAchievements do
		if index <= numAchievements then
			local filteredIndex = index + completedOffset;
			local id = GetAchievementInfo(category, filteredIndex);
			newDataProvider:Insert({category = category, index = filteredIndex, id = id});
		end
	end
	AchievementFrameAchievements.ScrollBox:SetDataProvider(newDataProvider);
end

-- Called from the options menu or once the complete filter is changed.
function AchievementFrameAchievements_ForceUpdate()
	AchievementFrameAchievements_UpdateDataProvider();

	local achievementId = GetSelectedAchievement();
	if achievementId > 0 then
		AchievementFrame_SelectAndScrollToAchievementId(AchievementFrameAchievements.ScrollBox, achievementId);
	end
end

-- [[ Achievement Icon ]] --

function AchievementIcon_Desaturate (self)
	self.bling:SetVertexColor(.6, .6, .6, 1);
	self.frame:SetVertexColor(.75, .75, .75, 1);
	self.texture:SetVertexColor(.55, .55, .55, 1);
end

function AchievementIcon_Saturate (self)
	self.bling:SetVertexColor(1, 1, 1, 1);
	self.frame:SetVertexColor(1, 1, 1, 1);
	self.texture:SetVertexColor(1, 1, 1, 1);
end

function AchievementIcon_OnLoad (self)
	self.Desaturate = AchievementIcon_Desaturate;
	self.Saturate = AchievementIcon_Saturate;
end

-- [[ Achievement Shield ]] --

function AchievementShield_Desaturate (self)
	self.Icon:SetTexCoord(.5, 1, TEXTURES_OFFSET, TEXTURES_OFFSET + 0.5);
end

function AchievementShield_Saturate (self)
	self.Icon:SetTexCoord(0, .5, TEXTURES_OFFSET, TEXTURES_OFFSET + 0.5);
end

function AchievementShield_OnLoad (self)
	self.Desaturate = AchievementShield_Desaturate;
	self.Saturate = AchievementShield_Saturate;
end

-- [[ AchievementButton ]] --

ACHIEVEMENTBUTTON_DESCRIPTIONHEIGHT = 20;
ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT = 84;
ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT = 15;
ACHIEVEMENTBUTTON_METAROWHEIGHT = 28;
ACHIEVEMENTBUTTON_MAXHEIGHT = 232;
ACHIEVEMENTBUTTON_TEXTUREHEIGHT = 128;
GUILDACHIEVEMENTBUTTON_MINHEIGHT = 128;

AchievementTemplateMixin = {};

function AchievementTemplateMixin:OnLoad()
	self.DateCompleted = self.Shield.DateCompleted;

	AchievementButton_Localize(self);

	if ( not ACHIEVEMENTUI_FONTHEIGHT ) then
		local _, fontHeight = self.Description:GetFont();
		ACHIEVEMENTUI_FONTHEIGHT = fontHeight;
	end
	self.Description:SetHeight(ACHIEVEMENTUI_FONTHEIGHT * ACHIEVEMENTUI_MAX_LINES_COLLAPSED);
	self.Description:SetWidth(ACHIEVEMENTUI_MAXCONTENTWIDTH);
	self.HiddenDescription:SetWidth(ACHIEVEMENTUI_MAXCONTENTWIDTH);

	self.Tracked:SetScript("OnClick", GenerateClosure(self.OnCheckClicked, self));
	self.Shield:SetScript("OnClick", GenerateClosure(self.OnShieldClicked, self));

	self:Collapse();
end

function AchievementTemplateMixin:ProcessClick(buttonName, down)
	local handled = false;
	if IsModifiedClick() then
		local elementData = self:GetElementData();
		if IsModifiedClick("CHATLINK") then
			local achievementLink = GetAchievementLink(elementData.id);
			if achievementLink then
				handled = ChatEdit_InsertLink(achievementLink);
				if not handled and SocialPostFrame and Social_IsShown() then
					Social_InsertLink(achievementLink);
					handled = true;
				end
			end
		end
		if not handled and IsModifiedClick("QUESTWATCHTOGGLE") then
			self:ToggleTracking(elementData.id);
			handled = true;
		end
	end

	if not handled then
		g_achievementSelectionBehavior:ToggleSelect(self);
	end
end

function AchievementTemplateMixin:OnClick(buttonName, down)
	self:ProcessClick(buttonName, down);
end

function AchievementTemplateMixin:OnEnter()
	self.Highlight:Show();
    EventRegistry:TriggerEvent("AchievementFrameAchievement.OnEnter", self, self.id);
end

function AchievementTemplateMixin:OnLeave()
	if not self:IsSelected() then
		self.Highlight:Hide();
	end
    EventRegistry:TriggerEvent("AchievementFrameAchievement.OnLeave", self);
end

function AchievementTemplateMixin:UpdatePlusMinusTexture()
	local id = self.id;
	if ( not id ) then
		return; -- This happens when we create buttons
	end

	local display = false;
	if ( GetAchievementNumCriteria(id) ~= 0 ) then
		display = true;
	elseif ( self.completed and GetPreviousAchievement(id) ) then
		display = true;
	elseif ( not self.completed and GetAchievementGuildRep(id) ) then
		display = true;
	end

	if ( display ) then
		self.PlusMinus:Show();
		if ( self.collapsed and self.saturatedStyle ) then
			self.PlusMinus:SetTexCoord(0, .5, TEXTURES_OFFSET, TEXTURES_OFFSET + 0.25);
		elseif ( self.collapsed ) then
			self.PlusMinus:SetTexCoord(.5, 1, TEXTURES_OFFSET, TEXTURES_OFFSET + 0.25);
		elseif ( self.saturatedStyle ) then
			self.PlusMinus:SetTexCoord(0, .5, TEXTURES_OFFSET + 0.25, TEXTURES_OFFSET + 0.50);
		else
			self.PlusMinus:SetTexCoord(.5, 1, TEXTURES_OFFSET + 0.25, TEXTURES_OFFSET + 0.50);
		end
	else
		self.PlusMinus:Hide();
	end
end

function AchievementTemplateMixin:SetSelected(selected)
	self:Init(self:GetElementData());

	SetFocusedAchievement(self.id);
end

function AchievementTemplateMixin:IsSelected()
	return SelectionBehaviorMixin.IsIntrusiveSelected(self);
end

function AchievementTemplateMixin:GetObjectiveFrame()
	if self.useOffscreenObjectiveFrame then
		return AchievementFrameAchievementsObjectivesOffScreen;
	end
	return AchievementFrameAchievementsObjectives;
end

function AchievementTemplateMixin:Init(elementData)
	self.index = elementData.index;
	self.id = elementData.id;
	local category = elementData.category;

	-- reset button info to get proper saturation/desaturation
	self.completed = nil;

	-- title
	if InGuildView() then
		self.TitleBar:SetAlpha(1);
		self.Icon.frame:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
		self.Icon.frame:SetTexCoord(0.25976563, 0.40820313, 0.50000000, 0.64453125);
		self.Icon.frame:SetPoint("CENTER", 2, 2);
		local tsunami = self.BottomTsunami1;
		tsunami:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		tsunami:SetTexCoord(0, 0.72265, 0.58984375, 0.65234375);
		tsunami:SetAlpha(0.2);
		local tsunami = self.TopTsunami1;
		tsunami:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		tsunami:SetTexCoord(0.72265, 0, 0.65234375, 0.58984375);
		tsunami:SetAlpha(0.15);
		self.Glow:SetTexCoord(0, 1, 0.26171875, 0.51171875);
	else
		self.TitleBar:SetAlpha(0.8);
		self.Icon.frame:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame");
		self.Icon.frame:SetTexCoord(0, 0.5625, 0, 0.5625);
		self.Icon.frame:SetPoint("CENTER", -1, 2);
		local tsunami = self.BottomTsunami1;
		tsunami:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		tsunami:SetTexCoord(0, 0.72265, 0.51953125, 0.58203125);
		tsunami:SetAlpha(0.35);
		local tsunami = self.TopTsunami1;
		tsunami:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		tsunami:SetTexCoord(0.72265, 0, 0.58203125, 0.51953125);
		tsunami:SetAlpha(0.3);
		self.Glow:SetTexCoord(0, 1, 0.00390625, 0.25390625);
	end

	local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy;
	if self.index then
		id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(category, self.index);
	else
		-- Social
		id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(self.id);
		category = GetAchievementCategory(self.id);
	end

	local saturatedStyle;
	if ( bit.band(flags, ACHIEVEMENT_FLAGS_ACCOUNT) == ACHIEVEMENT_FLAGS_ACCOUNT ) then
		self.accountWide = true;
		saturatedStyle = "account";
	else
		self.accountWide = nil;
		if ( InGuildView() ) then
			saturatedStyle = "guild";
		else
			saturatedStyle = "normal";
		end
	end
	self.Label:SetWidth(ACHIEVEMENTBUTTON_LABELWIDTH);
	self.Label:SetText(name);

	if ( GetPreviousAchievement(id) ) then
		-- If this is a progressive achievement, show the total score.
		AchievementShield_SetPoints(AchievementButton_GetProgressivePoints(id), self.Shield.Points, AchievementPointsFont, AchievementPointsFontSmall);
	else
		AchievementShield_SetPoints(points, self.Shield.Points, AchievementPointsFont, AchievementPointsFontSmall);
	end

	if ( points > 0 ) then
		self.Shield.Icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
	else
		self.Shield.Icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
	end

	if ( isGuild ) then
		self.Shield.Points:Show();
		self.Shield.wasEarnedByMe = nil;
		self.Shield.earnedBy = nil;
	else
		self.Shield.wasEarnedByMe = not (completed and not wasEarnedByMe);
		self.Shield.earnedBy = earnedBy;
	end

	self.Shield.id = id;
	self.Description:SetText(description);
	self.HiddenDescription:SetText(description);
	self.numLines = ceil(self.HiddenDescription:GetHeight() / ACHIEVEMENTUI_FONTHEIGHT);
	self.Icon.texture:SetTexture(icon);
	if ( completed or wasEarnedByMe ) then
		self.completed = true;
		self.DateCompleted:SetText(FormatShortDate(day, month, year));
		self.DateCompleted:Show();
		if ( self.saturatedStyle ~= saturatedStyle ) then
			self:Saturate();
		end
	else
		self.completed = nil;
		self.DateCompleted:Hide();
		self:Desaturate();
	end

	if ( rewardText == "" ) then
		self.Reward:Hide();
		self.RewardBackground:Hide();
	else
		self.Reward:SetText(rewardText);
		self.Reward:Show();
		self.RewardBackground:Show();
		if ( self.completed ) then
			self.RewardBackground:SetVertexColor(1, 1, 1);
		else
			self.RewardBackground:SetVertexColor(0.35, 0.35, 0.35);
		end
	end

	local noSound = true;
	if ( C_ContentTracking.IsTracking(Enum.ContentTrackingType.Achievement, id) ) then
		self:SetAsTracked(true, noSound);
	else
		self:SetAsTracked(false, noSound);
		self.Tracked:Hide();
	end

	self:UpdatePlusMinusTexture();

	if SelectionBehaviorMixin.IsElementDataIntrusiveSelected(elementData) then
		local height = self:DisplayObjectives(self.id, self.completed);
		self:Expand(height);

		self.Highlight:Show();

		if ( not completed or (not wasEarnedByMe and not isGuild) ) then
			self.Tracked:Show();
		end
	else
		local objectives = self:GetObjectiveFrame();
		if objectives.id == self.id then
			objectives:Hide();
		end

		if ( not self:IsMouseOver() ) then
			self.Highlight:Hide();
		end

		self:Collapse();
	end
end

function AchievementTemplateMixin:Collapse()
	if ( self.collapsed ) then
		return;
	end

	self.collapsed = true;
	self:UpdatePlusMinusTexture();
	self:SetHeight(ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT);
	self.Background:SetTexCoord(0, 1, 1-(ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT / 256), 1);
	if ( not self.Tracked:GetChecked() ) then
		self.Tracked:Hide();
	end
	self.Tabard:Hide();
	self.GuildCornerL:Hide();
	self.GuildCornerR:Hide();
	
	self.Description:Show();
	self.HiddenDescription:Hide();

	if ( not self:IsMouseOver() ) then
		self.Highlight:Hide();
	end
end

function AchievementTemplateMixin:Expand(height)
	if ( not self.collapsed and self:GetHeight() == height ) then
		return;
	end

	self.collapsed = nil;
	self:UpdatePlusMinusTexture()
	if ( InGuildView() ) then
		if ( height < GUILDACHIEVEMENTBUTTON_MINHEIGHT ) then
			height = GUILDACHIEVEMENTBUTTON_MINHEIGHT;
		end
		if ( self.completed ) then
			self.Tabard:Show();
			self.Shield:SetFrameLevel(self.Tabard:GetFrameLevel() + 1);
			SetLargeGuildTabardTextures("player", self.Tabard.Emblem, self.Tabard.Background, self.Tabard.Border);
		end
		self.GuildCornerL:Show();
		self.GuildCornerR:Show();
	end
	self:SetHeight(height);
	self:GetHeight(); -- debug check
	self.Background:SetTexCoord(0, 1, max(0, 1-(height / 256)), 1);

	self.HiddenDescription:Show();
	self.Description:Hide();
end

function AchievementTemplateMixin:Saturate()
	if ( InGuildView() ) then
		self.Background:SetTexture("Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal");
		self.TitleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.TitleBar:SetTexCoord(0, 1, 0.83203125, 0.91015625);
		self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
		self.Shield.Points:SetVertexColor(0, 1, 0);
		self.saturatedStyle = "guild";
	else
		self.Background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
		if ( self.accountWide ) then
			self.TitleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
			self.TitleBar:SetTexCoord(0, 1, 0, 0.375);
			self:SetBackdropBorderColor(ACHIEVEMENT_BLUE_BORDER_COLOR:GetRGB());
			self.saturatedStyle = "account";
		else
			self.TitleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			self.TitleBar:SetTexCoord(0, 1, 0.66015625, 0.73828125);
			self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
			self.saturatedStyle = "normal";
		end
		self.Shield.Points:SetVertexColor(1, 1, 1);
	end
	self.Glow:SetVertexColor(1.0, 1.0, 1.0);
	self.Icon:Saturate();
	self.Shield:Saturate();
	self.Reward:SetVertexColor(1, .82, 0);
	self.Label:SetVertexColor(1, 1, 1);
	self.Description:SetTextColor(0, 0, 0, 1);
	self.Description:SetShadowOffset(0, 0);
	self:UpdatePlusMinusTexture();
end

function AchievementTemplateMixin:Desaturate()
	self.saturatedStyle = nil;
	if ( InGuildView() ) then
		self.Background:SetTexture("Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal-Desaturated");
		self.TitleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.TitleBar:SetTexCoord(0, 1, 0.74609375, 0.82421875);
	else
		self.Background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
		if ( self.accountWide ) then
			self.TitleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
			self.TitleBar:SetTexCoord(0, 1, 0.40625, 0.78125);
		else
			self.TitleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			self.TitleBar:SetTexCoord(0, 1, 0.91796875, 0.99609375);
		end
	end
	self.Glow:SetVertexColor(.22, .17, .13);
	self.Icon:Desaturate();
	self.Shield:Desaturate();
	self.Shield.Points:SetVertexColor(.65, .65, .65);
	self.Reward:SetVertexColor(.8, .8, .8);
	self.Label:SetVertexColor(.65, .65, .65);
	self.Description:SetTextColor(1, 1, 1, 1);
	self.Description:SetShadowOffset(1, -1);
	self:UpdatePlusMinusTexture();
	self:SetBackdropBorderColor(.5, .5, .5);
end

-- Mirrors the implementations of AchievementObjectives_DisplayCriteria and
-- AchievementObjectives_DisplayProgressiveAchievement.
function AchievementTemplateMixin.CalculateSelectedHeight(elementData)
	local totalHeight = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT;
	local objectivesHeight = 0;
	

	-- text check width
	if ( not AchievementFrame.textCheckWidth ) then
		AchievementFrame.PlaceholderName:SetText("- ");
		AchievementFrame.textCheckWidth = AchievementFrame.PlaceholderName:GetStringWidth();
	end


	local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(elementData.category, elementData.index);
	if completed and GetPreviousAchievement(id) then
		local achievementCount = 1;
		
		local nextID = id;
		while GetPreviousAchievement(nextID) do
			achievementCount = achievementCount + 1;
			nextID = GetPreviousAchievement(nextID);
		end

		local MaxAchievementsPerRow = 6;
		objectivesHeight = math.ceil(achievementCount / MaxAchievementsPerRow) * ACHIEVEMENTUI_PROGRESSIVEHEIGHT;
	else
		local numExtraCriteriaRows = 0;
		local maxCriteriaWidth = 0;
		local textStrings = 0;
		local progressBars = 0;
		local metas = 0;
		local numMetaRows = 0;
		local numCriteriaRows = 0;
		if not completed then
			local requiresRep = GetAchievementGuildRep(id);
			if requiresRep then
				numExtraCriteriaRows = numExtraCriteriaRows + 1;
			end
		end

		local numCriteria = GetAchievementNumCriteria(id);
		for i = 1, numCriteria do
			local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(id, i);
	
			if criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID then
				metas = metas + 1;
				if metas == 1 or (math.fmod(metas, 2) ~= 0) then
					numMetaRows = numMetaRows + 1;
				end
	
			elseif bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR then
				progressBars = progressBars + 1;
				numCriteriaRows = numCriteriaRows + 1;
			else
				textStrings = textStrings + 1;
					
				local stringWidth = 0;
				if completed then
					maxCriteriaContentWidth = ACHIEVEMENTUI_MAXCONTENTWIDTH - ACHIEVEMENTUI_CRITERIACHECKWIDTH;
					AchievementFrame.PlaceholderName:SetText(criteriaString);
					stringWidth = min(AchievementFrame.PlaceholderName:GetStringWidth(),maxCriteriaContentWidth);
				else
					maxCriteriaContentWidth = ACHIEVEMENTUI_MAXCONTENTWIDTH - AchievementFrame.textCheckWidth;
					local dashedString = "- "..criteriaString;
					AchievementFrame.PlaceholderName:SetText(dashedString);
					stringWidth = min(AchievementFrame.PlaceholderName:GetStringWidth() - AchievementFrame.textCheckWidth, maxCriteriaContentWidth);	-- don't want the "- " to be included in the width
				end

				if AchievementFrame.PlaceholderName:GetWidth() > maxCriteriaContentWidth then
					AchievementFrame.PlaceholderName:SetWidth(maxCriteriaContentWidth);
				end
	
				maxCriteriaWidth = max(maxCriteriaWidth, stringWidth + ACHIEVEMENTUI_CRITERIACHECKWIDTH);
				numCriteriaRows = numCriteriaRows + 1;
			end
		end
		
		if textStrings > 0 and progressBars > 0 then
		elseif textStrings > 1 then
			local numColumns = floor(ACHIEVEMENTUI_MAXCONTENTWIDTH / maxCriteriaWidth);
			local forceColumns = numColumns == 1 and textStrings >= FORCE_COLUMNS_MIN_CRITERIA and maxCriteriaWidth <= FORCE_COLUMNS_MAX_WIDTH;
			if forceColumns then
				numColumns = 2;
			end
			
			if numColumns > 1 then
				numCriteriaRows = ceil(numCriteriaRows/numColumns);
			end
		end

		numCriteriaRows = numCriteriaRows + numExtraCriteriaRows;

		local height = numMetaRows * ACHIEVEMENTBUTTON_METAROWHEIGHT + numCriteriaRows * ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT;
		if metas > 0 or progressBars > 0 then
			height = height + 10;
		end

		objectivesHeight = height;
	end

	totalHeight = totalHeight + objectivesHeight;

	AchievementFrame.PlaceholderHiddenDescription:SetText(description);
	local numLines = ceil(AchievementFrame.PlaceholderHiddenDescription:GetHeight() / ACHIEVEMENTUI_FONTHEIGHT);
	if (totalHeight ~= ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT) or (numLines > ACHIEVEMENTUI_MAX_LINES_COLLAPSED) then
		local descriptionHeight = AchievementFrame.PlaceholderHiddenDescription:GetHeight();
		totalHeight = totalHeight + descriptionHeight - ACHIEVEMENTBUTTON_DESCRIPTIONHEIGHT;

		if rewardText ~= "" then
			totalHeight = totalHeight + 4;
		end
	end

	if InGuildView() and  totalHeight < GUILDACHIEVEMENTBUTTON_MINHEIGHT then
		return GUILDACHIEVEMENTBUTTON_MINHEIGHT;
	end
	return totalHeight;
end

function AchievementTemplateMixin:DisplayObjectives(id, completed)
	local objectivesFrame = self:GetObjectiveFrame();
	local topAnchor = self.HiddenDescription;
	objectivesFrame:ClearAllPoints();
	objectivesFrame.completed = completed;
	local height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT;

	if ( completed and GetPreviousAchievement(id) ) then
		objectivesFrame:Clear();
		objectivesFrame:SetParent(self);
		AchievementObjectives_DisplayProgressiveAchievement(objectivesFrame, id);
		objectivesFrame:SetPoint("TOP", topAnchor, "BOTTOM", 0, -8);
	else
		objectivesFrame:Clear();
		objectivesFrame:SetParent(self);
		AchievementObjectives_DisplayCriteria(objectivesFrame, id);
		if ( objectivesFrame:GetHeight() > 0 ) then
			objectivesFrame:SetPoint("TOP", topAnchor, "BOTTOM", 0, -8);
			objectivesFrame:SetPoint("LEFT", self.Icon, "RIGHT", -5, -25);
			objectivesFrame:SetPoint("RIGHT", self.Shield, "LEFT", -10, 0);
		end
	end

	objectivesFrame:Show();

	height = height + objectivesFrame:GetHeight();

	if ( height ~= ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT or self.numLines > ACHIEVEMENTUI_MAX_LINES_COLLAPSED ) then
		local descriptionHeight = self.HiddenDescription:GetHeight();
		height = height + descriptionHeight - ACHIEVEMENTBUTTON_DESCRIPTIONHEIGHT;
		if ( self.Reward:IsShown() ) then
			height = height + 4;
		end
	end

	objectivesFrame.id = id;
	return height;
end

function AchievementTemplateMixin:ToggleTracking()
	local id = self.id;
	if ( trackedAchievements[id] ) then
		C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, id, Enum.ContentTrackingStopType.Manual);
		self:SetAsTracked(false);
		return;
	end

	local count = #C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement);
	if ( count >= Constants.ContentTrackingConsts.MaxTrackedAchievements ) then
		UIErrorsFrame:AddMessage(format(ACHIEVEMENT_WATCH_TOO_MANY, Constants.ContentTrackingConsts.MaxTrackedAchievements), 1.0, 0.1, 0.1, 1.0);
		return;
	end

	local _, _, _, completed, _, _, _, _, _, _, _, isGuild, wasEarnedByMe = GetAchievementInfo(id)
	if ( (completed and isGuild) or wasEarnedByMe ) then
		UIErrorsFrame:AddMessage(ERR_ACHIEVEMENT_WATCH_COMPLETED, 1.0, 0.1, 0.1, 1.0);
		return;
	end

	self:SetAsTracked(true);
	local trackingError = C_ContentTracking.StartTracking(Enum.ContentTrackingType.Achievement, id);
	if trackingError then
		ContentTrackingUtil.DisplayTrackingError(trackingError);
	end

	return true;
end

function AchievementTemplateMixin:SetAsTracked(tracked, noSound)
	self.Check:SetShown(tracked);
	self.Tracked:ApplyChecked(tracked, noSound);
	if tracked then
		self.Tracked:Show();
	elseif not SelectionBehaviorMixin.IsIntrusiveSelected(self) then
		self.Tracked:Hide();
	end

	self.Label:SetWidth(self.Label:GetStringWidth() + 4); -- This +4 here is to fudge around any string width issues that arize from resizing a string set to its string width. See bug 144418 for an example.
end

function AchievementTemplateMixin:OnCheckClicked(o, buttonName, down)
	self:ToggleTracking();
end

function AchievementTemplateMixin:OnShieldClicked(o, buttonName, down)
	self:ProcessClick(buttonName, down);
end

AchivementButtonCheckMixin = {};

function AchivementButtonCheckMixin:ApplyChecked(checked, noSound)
	if not noSound then
		if checked then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		end
	end
	self:SetChecked(checked);
end

function AchivementButtonCheckMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( self:GetChecked() ) then
		GameTooltip:SetText(UNTRACK_ACHIEVEMENT_TOOLTIP, nil, nil, nil, nil, true);
	else
		GameTooltip:SetText(TRACK_ACHIEVEMENT_TOOLTIP, nil, nil, nil, nil, true);
	end
end

function AchivementButtonCheckMixin:OnLeave()
	GameTooltip:Hide();
end

function AchievementShield_SetPoints(points, pointString, normalFont, smallFont)
	if ( points == 0 ) then
		pointString:SetText("");
		return;
	end
	if ( points < 100 ) then
		pointString:SetFontObject(normalFont);
	else
		pointString:SetFontObject(smallFont);
	end
	pointString:SetText(points);
end

function AchievementButton_ResetTable (t)
	for k, v in next, t do
		v:Hide();
	end
end

AchievementsObjectivesMixin = {};

function AchievementsObjectivesMixin:OnLoad()
	self.pools = CreateFramePoolCollection();
	self.pools:CreatePool("FRAME", self, "AchievementCriteriaTemplate");
	self.pools:CreatePool("STATUSBAR", self, "AchievementProgressBarTemplate");
	self.pools:CreatePool("FRAME", self, "MiniAchievementTemplate");
	self.pools:CreatePool("BUTTON", self, "MetaCriteriaTemplate");
	self:Clear();
end

function AchievementsObjectivesMixin:OnHide()
	self:Clear();
end

function AchievementsObjectivesMixin:Clear()
	self.pools:ReleaseAll();
	self.criterias = {};
	self.progressBars = {};
	self.miniAchivements = {};
	self.metas = {};

	self.RepCriteria:Hide();

	self:ClearAllPoints();
	self:SetHeight(0);
end

function AchievementsObjectivesMixin:GetElementAtIndex(template, collection, index, localizer)
	local found = collection[index];
	if found then
		return found;
	end

	local pool = self.pools:GetPool(template);
	local frame = pool:Acquire();
	table.insert(collection, frame);
	localizer(frame);
	frame:Show();
	return frame;
end

function AchievementsObjectivesMixin:GetCriteria(index)
	return self:GetElementAtIndex("AchievementCriteriaTemplate", self.criterias, index, AchievementFrame_LocalizeCriteria);
end

function AchievementsObjectivesMixin:GetProgressBar(index)
	return self:GetElementAtIndex("AchievementProgressBarTemplate", self.progressBars, index, AchievementButton_LocalizeProgressBar);
end

function AchievementsObjectivesMixin:GetMiniAchievement(index)
	return self:GetElementAtIndex("MiniAchievementTemplate", self.miniAchivements, index, AchievementButton_LocalizeMiniAchievement);
end

function AchievementsObjectivesMixin:GetMeta(index)
	local frame = self:GetElementAtIndex("MetaCriteriaTemplate", self.metas, index, AchievementButton_LocalizeMetaAchievement);
	
	if ( InGuildView() ) then
		frame.Border:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
		frame.Border:SetTexCoord(0.89062500, 0.97070313, 0.00195313, 0.08203125);
	else
		frame.Border:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Progressive-IconBorder");
		frame.Border:SetTexCoord(0, 0.65625, 0, 0.65625);
	end

	return frame;
end

function AchievementButton_GetProgressivePoints(achievementID)
	local points;
	local _, _, progressivePoints, completed = GetAchievementInfo(achievementID);

	while GetPreviousAchievement(achievementID) do
		achievementID = GetPreviousAchievement(achievementID);
		_, _, points, completed = GetAchievementInfo(achievementID);
		progressivePoints = progressivePoints+points;
	end

	if ( progressivePoints ) then
		return progressivePoints;
	else
		return 0;
	end
end

local achievementList = {};

function AchievementObjectives_DisplayProgressiveAchievement (objectivesFrame, id)
	local ACHIEVEMENTMODE_PROGRESSIVE = 2;
	local achievementID = id;

	local achievementList = achievementList;
	for i in next, achievementList do
		achievementList[i] = nil;
	end

	tinsert(achievementList, 1, achievementID);
	while GetPreviousAchievement(achievementID) do
		tinsert(achievementList, 1, GetPreviousAchievement(achievementID));
		achievementID = GetPreviousAchievement(achievementID);
	end

	local i = 0;
	for index, achievementID in ipairs(achievementList) do
		local _, achievementName, points, completed, month, day, year, description, flags, iconpath = GetAchievementInfo(achievementID);
		flags = flags or 0;		-- bug 360115
		local miniAchievement = objectivesFrame:GetMiniAchievement(index);

		miniAchievement:Show();
		miniAchievement:ClearAllPoints();
		miniAchievement:SetParent(objectivesFrame);
		miniAchievement.Icon:SetTexture(iconpath);
		if ( index == 1 ) then
			miniAchievement:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", -4, -4);
		elseif ( mod(index, 6) == 1 ) then
			miniAchievement:SetPoint("TOPLEFT", objectivesFrame:GetMiniAchievement(index-6), "BOTTOMLEFT", 0, -8);
		else
			miniAchievement:SetPoint("TOPLEFT", objectivesFrame:GetMiniAchievement(index-1), "TOPRIGHT", 4, 0);
		end

		if ( points > 0 ) then
			miniAchievement.Points:SetText(points);
			miniAchievement.Points:Show();
			miniAchievement.Shield:SetTexture([[Interface\AchievementFrame\UI-Achievement-Progressive-Shield]]);
		else
			miniAchievement.Points:Hide();
			miniAchievement.Shield:SetTexture([[Interface\AchievementFrame\UI-Achievement-Progressive-Shield-NoPoints]]);
		end

		miniAchievement.numCriteria = 0;
		if ( not ( bit.band(flags, ACHIEVEMENT_FLAGS_HAS_PROGRESS_BAR) == ACHIEVEMENT_FLAGS_HAS_PROGRESS_BAR ) ) then
			for i = 1, GetAchievementNumCriteria(achievementID) do
				local criteriaString, criteriaType, completed = GetAchievementCriteriaInfo(achievementID, i);
				if ( completed == false ) then
					criteriaString = "|CFF808080 - " .. criteriaString .. "|r";
				else
					criteriaString = "|CFF00FF00 - " .. criteriaString .. "|r";
				end
				miniAchievement["criteria" .. i] = criteriaString;
				miniAchievement.numCriteria = i;
			end
		end
		miniAchievement.name = achievementName;
		miniAchievement.desc = description;
		if ( month ) then
			miniAchievement.date = FormatShortDate(day, month, year);
		end
		i = index;
	end

	objectivesFrame:SetHeight(math.ceil(i/6) * ACHIEVEMENTUI_PROGRESSIVEHEIGHT);
	objectivesFrame:SetWidth(min(i, 6) * ACHIEVEMENTUI_PROGRESSIVEWIDTH);
	objectivesFrame.mode = ACHIEVEMENTMODE_PROGRESSIVE;
end

function AchievementFrame_GetCategoryNumAchievements_All (categoryID)
	local numAchievements, numCompleted, numIncomplete = GetCategoryNumAchievements(categoryID);
	return numAchievements, numCompleted, 0;
end

function AchievementFrame_GetCategoryNumAchievements_Complete (categoryID)
	local numAchievements, numCompleted, numIncomplete = GetCategoryNumAchievements(categoryID);
	return numCompleted, numCompleted, 0;
end

function AchievementFrame_GetCategoryNumAchievements_Incomplete (categoryID)
	local numAchievements, numCompleted, numIncomplete = GetCategoryNumAchievements(categoryID);
	return numIncomplete, 0, numAchievements-numIncomplete;
end

ACHIEVEMENTUI_SELECTEDFILTER = AchievementFrame_GetCategoryNumAchievements_All;

AchievementFrameFilters = { {text=ACHIEVEMENTFRAME_FILTER_ALL, func= AchievementFrame_GetCategoryNumAchievements_All},
 {text=ACHIEVEMENTFRAME_FILTER_COMPLETED, func=AchievementFrame_GetCategoryNumAchievements_Complete},
{text=ACHIEVEMENTFRAME_FILTER_INCOMPLETE, func=AchievementFrame_GetCategoryNumAchievements_Incomplete} };

function AchievementFrameFilterDropDown_OnLoad (self)
	self.relativeTo = "AchievementFrameFilterDropDown"
	self.xOffset = -14;
	self.yOffset = 10;
	UIDropDownMenu_Initialize(self, AchievementFrameFilterDropDown_Initialize);
end

function AchievementFrameFilterDropDown_Initialize (self)
	local info = UIDropDownMenu_CreateInfo();
	for i, filter in ipairs(AchievementFrameFilters) do
		info.text = filter.text;
		info.value = i;
		info.func = AchievementFrameFilterDropDownButton_OnClick;
		info.tooltipOnButton = 1;
		info.tooltipTitle = ACHIEVEMENT_FILTER_TITLE;
		info.tooltipText = AchievementFrameFilterStrings[i];
		if ( filter.func == ACHIEVEMENTUI_SELECTEDFILTER ) then
			info.checked = 1;
			UIDropDownMenu_SetText(self, filter.text);
			self.value =  i;
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
end

function AchievementFrameFilterDropDownButton_OnClick (self)
	AchievementFrame_SetFilter(self.value);
end

function AchievementFrame_SetFilter(value)
	local func = AchievementFrameFilters[value].func;
	if ( func ~= ACHIEVEMENTUI_SELECTEDFILTER ) then
		ACHIEVEMENTUI_SELECTEDFILTER = func;
		UIDropDownMenu_SetText(AchievementFrameFilterDropDown, AchievementFrameFilters[value].text)
		AchievementFrameAchievements_ForceUpdate();
		AchievementFrameFilterDropDown.value = value;
	end
end

function AchievementObjectives_DisplayCriteria (objectivesFrame, id)
	if ( not id ) then
		return;
	end

	local yOffset = 0;
	local ACHIEVEMENTMODE_CRITERIA = 1;
	local numMetaRows = 0;
	local numCriteriaRows = 0;
	local numExtraCriteriaRows = 0;

	local function AddExtraCriteriaRow()
		numExtraCriteriaRows = numExtraCriteriaRows + 1;
		yOffset = -numExtraCriteriaRows * ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT;
	end

	local requiresRep, hasRep, repLevel;
	if ( not objectivesFrame.completed ) then
		requiresRep, hasRep, repLevel = GetAchievementGuildRep(id);
		if ( requiresRep ) then
			local gender = UnitSex("player");
			local factionStandingtext = GetText("FACTION_STANDING_LABEL"..repLevel, gender);
			objectivesFrame.RepCriteria:SetFormattedText(ACHIEVEMENT_REQUIRES_GUILD_REPUTATION, factionStandingtext);
			if ( hasRep ) then
				objectivesFrame.RepCriteria:SetTextColor(0, 1, 0);
			else
				objectivesFrame.RepCriteria:SetTextColor(1, 0, 0);
			end
			objectivesFrame.RepCriteria:Show();
			AddExtraCriteriaRow();
		end
	end

	local numCriteria = GetAchievementNumCriteria(id);
	if ( numCriteria == 0 and not requiresRep ) then
		objectivesFrame.mode = ACHIEVEMENTMODE_CRITERIA;
		objectivesFrame:SetHeight(0);
		return;
	end

	-- text check width
	if ( not objectivesFrame.textCheckWidth ) then
		local criteria = objectivesFrame:GetCriteria(1);
		criteria.Name:SetText("- ");
		objectivesFrame.textCheckWidth = criteria.Name:GetStringWidth();
	end

	local frameLevel = objectivesFrame:GetFrameLevel() + 1;

	local textStrings, progressBars, metas = 0, 0, 0;
	local firstMetaCriteria;

	local maxCriteriaWidth = 0;
	local yPos;
	for i = 1, numCriteria do
		local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(id, i);

		if ( criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID ) then
			metas = metas + 1;
			local metaCriteria = objectivesFrame:GetMeta(metas);
			metaCriteria:ClearAllPoints();

			if ( metas == 1 ) then
				-- this will be anchored below, we need to know how many text criteria there are
				firstMetaCriteria = metaCriteria;
				numMetaRows = numMetaRows + 1;
			elseif ( math.fmod(metas, 2) == 0 ) then
				local anchorMeta = objectivesFrame:GetMeta(metas-1);
				metaCriteria:SetPoint("LEFT", anchorMeta, "RIGHT", 35, 0);
			else
				local anchorMeta = objectivesFrame:GetMeta(metas-2);
				metaCriteria:SetPoint("TOPLEFT", anchorMeta, "BOTTOMLEFT", -0, 2);
				numMetaRows = numMetaRows + 1;
			end

			local id, achievementName, points, achievementCompleted, month, day, year, description, flags, iconpath = GetAchievementInfo(assetID);

			if ( month ) then
				metaCriteria.date = FormatShortDate(day, month, year)
			else
				metaCriteria.date = nil;
			end

			metaCriteria.id = id;
			metaCriteria.Label:SetText(achievementName);
			metaCriteria.Icon:SetTexture(iconpath);

			-- have to check if criteria is completed here, can't just check if achievement is completed.
			-- This is because the criteria could have modifiers on it that prevent completion even though the achievement is earned.
			if ( objectivesFrame.completed and completed ) then
				metaCriteria.Check:Show();
				metaCriteria.Border:SetVertexColor(1, 1, 1, 1);
				metaCriteria.Icon:SetVertexColor(1, 1, 1, 1);
				metaCriteria.Label:SetShadowOffset(0, 0)
				metaCriteria.Label:SetTextColor(0, 0, 0, 1);
			elseif ( completed ) then
				metaCriteria.Check:Show();
				metaCriteria.Border:SetVertexColor(1, 1, 1, 1);
				metaCriteria.Icon:SetVertexColor(1, 1, 1, 1);
				metaCriteria.Label:SetShadowOffset(1, -1)
				metaCriteria.Label:SetTextColor(0, 1, 0, 1);
			else
				metaCriteria.Check:Hide();
				metaCriteria.Border:SetVertexColor(.75, .75, .75, 1);
				metaCriteria.Icon:SetVertexColor(.55, .55, .55, 1);
				metaCriteria.Label:SetShadowOffset(1, -1)
				metaCriteria.Label:SetTextColor(.6, .6, .6, 1);
			end

			metaCriteria:SetParent(objectivesFrame);
			metaCriteria:Show();
		elseif ( bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR ) then
			-- Display this criteria as a progress bar!
			progressBars = progressBars + 1;
			local progressBar = objectivesFrame:GetProgressBar(progressBars);

			if ( progressBars == 1 ) then
				progressBar:SetPoint("TOP", objectivesFrame, "TOP", 4, -4 + yOffset);
			else
				progressBar:SetPoint("TOP", objectivesFrame:GetProgressBar(progressBars-1), "BOTTOM", 0, 0);
			end

			progressBar.Text:SetText(string.format("%s", quantityString));
			progressBar:SetMinMaxValues(0, reqQuantity);
			progressBar:SetValue(quantity);

			progressBar:SetParent(objectivesFrame);
			progressBar:Show();

			numCriteriaRows = numCriteriaRows + 1;
		else
			textStrings = textStrings + 1;
			local criteria = objectivesFrame:GetCriteria(textStrings);
			criteria:ClearAllPoints();
			if ( textStrings == 1 ) then
				if ( numCriteria == 1 ) then
					criteria:SetPoint("TOP", objectivesFrame, "TOP", -14, yOffset);
				else
					criteria:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 0, yOffset);
				end

			else
				criteria:SetPoint("TOPLEFT", objectivesFrame:GetCriteria(textStrings-1), "BOTTOMLEFT", 0, 0);
			end

			if ( objectivesFrame.completed and completed ) then
				criteria.Name:SetTextColor(0, 0, 0, 1);
				criteria.Name:SetShadowOffset(0, 0);
			elseif ( completed ) then
				criteria.Name:SetTextColor(0, 1, 0, 1);
				criteria.Name:SetShadowOffset(1, -1);
			else
				criteria.Name:SetTextColor(.6, .6, .6, 1);
				criteria.Name:SetShadowOffset(1, -1);
			end

			local stringWidth = 0;
			local maxCriteriaContentWidth;
			if ( completed ) then
				maxCriteriaContentWidth = ACHIEVEMENTUI_MAXCONTENTWIDTH - ACHIEVEMENTUI_CRITERIACHECKWIDTH;
				criteria.Check:SetPoint("LEFT", 18, -3);
				criteria.Name:SetPoint("LEFT", criteria.Check, "RIGHT", 0, 2);
				criteria.Check:Show();
				criteria.Name:SetText(criteriaString);
				stringWidth = min(criteria.Name:GetStringWidth(),maxCriteriaContentWidth);
			else
				maxCriteriaContentWidth = ACHIEVEMENTUI_MAXCONTENTWIDTH - objectivesFrame.textCheckWidth;
				criteria.Check:SetPoint("LEFT", 0, -3);
				criteria.Name:SetPoint("LEFT", criteria.Check, "RIGHT", 5, 2);
				criteria.Check:Hide();
				criteria.Name:SetText("- "..criteriaString);
				stringWidth = min(criteria.Name:GetStringWidth() - objectivesFrame.textCheckWidth,maxCriteriaContentWidth);	-- don't want the "- " to be included in the width
			end
			if ( criteria.Name:GetWidth() > maxCriteriaContentWidth ) then
				criteria.Name:SetWidth(maxCriteriaContentWidth);
			end
			criteria:SetParent(objectivesFrame);
			criteria:Show();
			criteria:SetWidth(stringWidth + ACHIEVEMENTUI_CRITERIACHECKWIDTH);
			maxCriteriaWidth = max(maxCriteriaWidth, stringWidth + ACHIEVEMENTUI_CRITERIACHECKWIDTH);
			numCriteriaRows = numCriteriaRows + 1;
		end
	end

	if ( textStrings > 0 and progressBars > 0 ) then
		-- If we have text criteria and progressBar criteria, display the progressBar criteria first and position the textStrings under them.
		local criTable = objectivesFrame:GetCriteria(1);
		criTable:ClearAllPoints();
		if ( textStrings == 1 ) then
			criTable:SetPoint("TOP", objectivesFrame:GetProgressBar(progressBars), "BOTTOM", -14, -4);
		else
			criTable:SetPoint("TOP", objectivesFrame:GetProgressBar(progressBars), "BOTTOM", 0, -4);
			criTable:SetPoint("LEFT", objectivesFrame, "LEFT", 0, 0);
		end
	elseif ( textStrings > 1 ) then
		-- Figure out if we can make multiple columns worth of criteria instead of one long one
		local numColumns = floor(ACHIEVEMENTUI_MAXCONTENTWIDTH/maxCriteriaWidth);
		-- But if we have a lot of criteria, force 2 columns
		local forceColumns = false;
		if ( numColumns == 1 and textStrings >= FORCE_COLUMNS_MIN_CRITERIA and maxCriteriaWidth <= FORCE_COLUMNS_MAX_WIDTH ) then
			numColumns = 2;
			forceColumns = true;
			-- if top right criteria would run into the achievement shield, move them all down 1 row
			-- this assumes description is 1 or 2 lines, otherwise this wouldn't be a problem
			-- If uncommented, you'll need to account for this in AchievementTemplateMixin.CalculateSelectedHeight.
			--if ( AchievementButton_GetCriteria(2).Name:GetStringWidth() > FORCE_COLUMNS_RIGHT_COLUMN_SPACE and progressBars == 0 ) then
			--	AddExtraCriteriaRow();
			--end
		end
		if ( numColumns > 1 ) then
			local step;
			local rows = 1;
			local position = 0;
			local criTable = objectivesFrame.criterias;
			for i=1, #criTable do
				position = position + 1;
				if ( position > numColumns ) then
					position = position - numColumns;
					rows = rows + 1;
				end

				if ( rows == 1 ) then
					criTable[i]:ClearAllPoints();
					local xOffset = 0;
					if ( forceColumns ) then
						if ( position == 1 ) then
							xOffset = FORCE_COLUMNS_LEFT_OFFSET;
						elseif ( position == 2 ) then
							xOffset = FORCE_COLUMNS_RIGHT_OFFSET;
						end
					end
					criTable[i]:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", (position - 1)*(ACHIEVEMENTUI_MAXCONTENTWIDTH/numColumns) + xOffset, yOffset);
				else
					criTable[i]:ClearAllPoints();
					criTable[i]:SetPoint("TOPLEFT", criTable[position + ((rows - 2) * numColumns)], "BOTTOMLEFT", 0, 0);
				end
			end
			numCriteriaRows = ceil(numCriteriaRows/numColumns);
		end
	end

	numCriteriaRows = numCriteriaRows + numExtraCriteriaRows;

	if ( firstMetaCriteria ) then
		local yOffsetMeta = -8 - numCriteriaRows * ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT;
		if ( metas == 1 ) then
			firstMetaCriteria:SetPoint("TOP", objectivesFrame, "TOP", 0, yOffsetMeta);
		else
			firstMetaCriteria:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 20, yOffsetMeta);
		end
	end

	local height = numMetaRows * ACHIEVEMENTBUTTON_METAROWHEIGHT + numCriteriaRows * ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT;
	if ( metas > 0 or progressBars > 0 ) then
		height = height + 10;
	end

	objectivesFrame:SetHeight(height);
	objectivesFrame.mode = ACHIEVEMENTMODE_CRITERIA;
end

-- [[ StatsFrames ]]--

AchievementStatTemplateMixin = {};

function AchievementStatTemplateMixin:OnLoad()
	self.Value:SetVertexColor(1, 0.97, 0.6);
	self:SetPushedTextOffset(0,0);
end

function AchievementStatTemplateMixin:OnClick()
	if ( self.isHeader ) then
		local category = self.id;
		AchievementFrame_UpdateAndSelectCategory(category);
	end
end

function AchievementStatTemplateMixin:OnEnter()
	if ( self.Text:IsTruncated() ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.Text:GetText(), 1, 1, 1, 1, true);
	end
end

function AchievementStatTemplateMixin:OnLeave()
	GameTooltip:Hide();
end

function AchievementStatTemplateMixin:Init(elementData)
	local category = elementData.id;
	local colorIndex = elementData.colorIndex;
	if elementData.header then
		-- show header
		self.Left:Show();
		self.Middle:Show();
		self.Right:Show();
		local text;
		if ( category == ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID ) then
			text = ACHIEVEMENT_SUMMARY_CATEGORY;
		else
			text = GetCategoryInfo(category);
		end
		self.Title:SetText(text);
		self.Title:Show();
		self.Value:SetText("");
		self:SetText("");
		self:SetHeight(24);
		self.Background:Hide();
		self.isHeader = true;
		self.id = category;
	else
		local id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(category);
		
		self.id = id;

		self:SetText(name);
		self.Background:Show();
		-- Color every other line yellow
		if ( colorIndex == 1 ) then
			self.Background:SetTexCoord(0, 1, 0.1875, 0.3671875);
			self.Background:SetBlendMode("BLEND");
			self.Background:SetAlpha(1.0);
			self:SetHeight(24);
		else
			self.Background:SetTexCoord(0, 1, 0.375, 0.5390625);
			self.Background:SetBlendMode("ADD");
			self.Background:SetAlpha(0.5);
			self:SetHeight(24);
		end

		-- Figure out the criteria
		-- Just show the first criteria for now
		local criteriaString, criteriaType, completed, quantityNumber, reqQuantity, charName, flags, assetID, quantity;
		if ( not isSummary ) then
			quantity = GetStatistic(id);
		else
			criteriaString, criteriaType, completed, quantityNumber, reqQuantity, charName, flags, assetID, quantity = GetAchievementCriteriaInfo(category);
		end
		if ( not quantity ) then
			quantity = "--";
		end
		self.Value:SetText(quantity);

		-- Hide the header images
		self.Title:Hide();
		self.Left:Hide();
		self.Middle:Hide();
		self.Right:Hide();
		self.isHeader = false;
	end
end

function AchievementFrameStats_OnEvent (self, event, ...)
	if ( event == "CRITERIA_UPDATE" ) then
		AchievementFrameStats_UpdateDataProvider();
	end
end

function AchievementFrameStats_OnLoad (self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("AchievementStatTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	view:SetPadding(2,0,0,4,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function AchievementFrameStats_OnShow(self)
	self:RegisterEvent("CRITERIA_UPDATE");
end

function AchievementFrameStats_OnHide(self)
	self:UnregisterEvent("CRITERIA_UPDATE");
end

function AchievementFrameStats_UpdateDataProvider ()
	local category = AchievementFrame_GetOrSelectCurrentCategory();
	if category == "summary" then
		return;
	end

	local numStats = GetCategoryNumAchievements(category);
	local categories = {};

	if ( achievementFunctions.lastCategory ~= category ) then
		-- build a list of shown category and stat id's
		tinsert(categories, {id = category, header = true});
		for i=1, numStats do
			local quantity, skip, id = GetStatistic(category, i);
			if ( not skip ) then
				tinsert(categories, {id = id});
			end
		end

		-- add all the subcategories and their stat id's
		for i, cat in next, STAT_FUNCTIONS.categories do
			if ( cat.parent == category ) then
				tinsert(categories, {id = cat.id, header = true});
				numStats = GetCategoryNumAchievements(cat.id);
				for k=1, numStats do
					local quantity, skip, id = GetStatistic(cat.id, k);
					if ( not skip ) then
						tinsert(categories, {id = id});
					end
				end
			end
		end
		achievementFunctions.lastCategory = category;
		
		local newDataProvider = CreateDataProvider();
		for index = 1, #categories do
			local stat = categories[index];
			stat.colorIndex = mod(index, 2);
			newDataProvider:Insert(stat);
		end
		AchievementFrameStats.ScrollBox:SetDataProvider(newDataProvider);
	end
end


-- [[ Summary Frame ]] --
function AchievementFrameSummary_OnShow()
	if ( achievementFunctions ~= COMPARISON_ACHIEVEMENT_FUNCTIONS and achievementFunctions ~= COMPARISON_STAT_FUNCTIONS ) then
		AchievementFrameSummary:SetWidth(530);
	else
		AchievementFrameComparisonDark:Hide();
		AchievementFrameComparisonWatermark:Hide();
		AchievementFrameComparison:SetWidth(650);
		AchievementFrameSummary:SetWidth(650);
	end
end

function AchievementFrameSummary_Update()
	AchievementFrameSummary_Refresh();
	AchievementFrameSummaryCategoriesStatusBar_Update();
	AchievementFrameSummary_UpdateAchievements(GetLatestCompletedAchievements(InGuildView()));
end

function AchievementFrameSummary_UpdateSummaryProgressBars(categories)
	for i = 1, 12 do
		local statusBar = _G["AchievementFrameSummaryCategoriesCategory"..i];
		if ( i <= #categories ) then
			local categoryName = GetCategoryInfo(categories[i]);
			statusBar.Label:SetText(categoryName);
			statusBar:Show();
			statusBar:SetID(categories[i]);
			AchievementFrameSummaryCategory_OnShow(statusBar);	-- to calculate progress
		else
			statusBar:Hide();
		end
	end
end

function AchievementFrameSummary_Refresh()
 	if not InGuildView() then
		for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			local button = _G["AchievementFrameSummaryAchievement"..i];
			if ( button ) then
				button.Icon.frame:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame");
				button.Icon.frame:SetTexCoord(0, 0.5625, 0, 0.5625);
				button.Icon.frame:SetPoint("CENTER", -1, 2);
				button.Glow:SetTexCoord(0, 1, 0.00390625, 0.25390625);
				button.TitleBar:SetAlpha(0.5);
			end
		end
		AchievementFrameSummary_UpdateSummaryProgressBars(ACHIEVEMENTUI_SUMMARYCATEGORIES);
	else
		for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			local button = _G["AchievementFrameSummaryAchievement"..i];
			if ( button ) then
				AchievementFrameSummaryAchievement_SetGuildTextures(button)
			end
		end
		AchievementFrameSummary_UpdateSummaryProgressBars(ACHIEVEMENTUI_GUILDSUMMARYCATEGORIES);
	end
end

function AchievementFrameSummary_UpdateAchievements(...)
	local numAchievements = select("#", ...);
	local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy;
	local buttons = AchievementFrameSummaryAchievements.buttons;
	local button, anchorTo, achievementID;
	local defaultAchievementCount = 1;

	for i=1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
		if ( buttons ) then
			button = buttons[i];
		end
		if ( not button ) then
			button = CreateFrame("Button", "AchievementFrameSummaryAchievement"..i, AchievementFrameSummaryAchievements, "SummaryAchievementTemplate");
			if ( i == 1 ) then
				button:SetPoint("TOPLEFT",AchievementFrameSummaryAchievementsHeader, "BOTTOMLEFT", 18, 2 );
				button:SetPoint("TOPRIGHT",AchievementFrameSummaryAchievementsHeader, "BOTTOMRIGHT", -18, 2 );
			else
				anchorTo = _G["AchievementFrameSummaryAchievement"..i-1];
				button:SetPoint("TOPLEFT",anchorTo, "BOTTOMLEFT", 0, 3 );
				button:SetPoint("TOPRIGHT",anchorTo, "BOTTOMRIGHT", 0, 3 );
			end
			if ( InGuildView() ) then
				AchievementFrameSummaryAchievement_SetGuildTextures(button);
			end
			if ( not buttons ) then
				buttons = AchievementFrameSummaryAchievements.buttons;
			end
			button.isSummary = true;
			AchievementFrameSummary_LocalizeButton(button);
		end;

		if ( i <= numAchievements ) then
			achievementID = select(i, ...);
			id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID);

			local saturatedStyle;
			if ( bit.band(flags, ACHIEVEMENT_FLAGS_ACCOUNT) == ACHIEVEMENT_FLAGS_ACCOUNT ) then
				button.accountWide = true;
				saturatedStyle = "account";
			else
				button.accountWide = nil;
				if ( InGuildView() ) then
					saturatedStyle = "guild";
				else
					saturatedStyle = "normal";
				end
			end

			button.Label:SetText(name);
			button.Description:SetText(description);
			AchievementShield_SetPoints(points, button.Shield.Points, GameFontNormal, GameFontNormalSmall);
			if ( points > 0 ) then
				button.Shield.Icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
			else
				button.Shield.Icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
			end

			if ( isGuild ) then
				button.Shield.wasEarnedByMe = nil;
				button.Shield.earnedBy = nil;
			else
				button.Shield.wasEarnedByMe = not (completed and not wasEarnedByMe);
				button.Shield.earnedBy = earnedBy;
			end

			button.Icon.texture:SetTexture(icon);
			button.id = id;

			if ( completed ) then
				button.DateCompleted:SetText(FormatShortDate(day, month, year));
			else
				button.DateCompleted:SetText("");
			end

			if ( button.saturatedStyle ~= saturatedStyle ) then
				button:Saturate();
			end
			button.tooltipTitle = nil;
			button:Show();
		else
			local tAchievements;
			if ( InGuildView() ) then
				tAchievements = ACHIEVEMENTUI_DEFAULTGUILDSUMMARYACHIEVEMENTS;
			else
				tAchievements = ACHIEVEMENTUI_DEFAULTSUMMARYACHIEVEMENTS;
			end
			for i=defaultAchievementCount, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
				achievementID = tAchievements[defaultAchievementCount];
				if ( not achievementID ) then
					break;
				end
				id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID);
				if ( completed ) then
					defaultAchievementCount = defaultAchievementCount+1;
				else
					button.Label:SetText(name);
					button.Description:SetText(description);
					AchievementShield_SetPoints(points, button.Shield.Points, GameFontNormal, GameFontNormalSmall);
					if ( points > 0 ) then
						button.Shield.Icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
					else
						button.Shield.Icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
					end
					button.Shield.wasEarnedByMe = not (completed and not wasEarnedByMe);
					button.Shield.earnedBy = earnedBy;
					button.Icon.texture:SetTexture(icon);
					button.id = id;
					if ( month ) then
						button.DateCompleted:SetText(FormatShortDate(day, month, year));
					else
						button.DateCompleted:SetText("");
					end
					button:Show();
					defaultAchievementCount = defaultAchievementCount+1;
					button:Desaturate();
					button.tooltipTitle = SUMMARY_ACHIEVEMENT_INCOMPLETE;
					button.tooltip = SUMMARY_ACHIEVEMENT_INCOMPLETE_TEXT;
					break;
				end
			end
		end
	end
	if ( numAchievements == 0 ) then
		AchievementFrameSummaryAchievementsEmptyText:Show();
	else
		AchievementFrameSummaryAchievementsEmptyText:Hide();
	end
end

function AchievementFrameSummaryCategoriesStatusBar_Update()
	local total, completed = GetNumCompletedAchievements(InGuildView());
	AchievementFrameSummaryCategoriesStatusBar:SetMinMaxValues(0, total);
	AchievementFrameSummaryCategoriesStatusBar:SetValue(completed);
	AchievementFrameSummaryCategoriesStatusBarText:SetText(BreakUpLargeNumbers(completed).."/"..BreakUpLargeNumbers(total));
end

function AchievementFrameSummaryAchievement_OnLoad(self)
	AchievementComparisonPlayerButton_OnLoad(self);
	AchievementFrameSummaryAchievements.buttons = AchievementFrameSummaryAchievements.buttons or {};
	tinsert(AchievementFrameSummaryAchievements.buttons, self);
	self.TitleBar:SetVertexColor(1,1,1,0.5);
	self.DateCompleted:Show();
end

function AchievementFrameSummaryAchievement_SetGuildTextures(button)
	button.Icon.frame:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
	button.Icon.frame:SetTexCoord(0.25976563, 0.40820313, 0.50000000, 0.64453125);
	button.Icon.frame:SetPoint("CENTER", 0, 2);
	button.Glow:SetTexCoord(0, 1, 0.26171875, 0.51171875);
	button.TitleBar:SetAlpha(1);
end

function AchievementFrameSummaryAchievement_OnClick(self)
	if ( IsModifiedClick("CHATLINK") ) then
		local achievementLink = GetAchievementLink(self.id);
		if ( achievementLink ) then
			if ( ChatEdit_InsertLink(achievementLink) ) then
				return;
			elseif ( SocialPostFrame and Social_IsShown() ) then
				Social_InsertLink(achievementLink);
				return;
			end
		end
	end

	local id = self.id
	local nextID, completed = GetNextAchievement(id);
	if ( nextID and completed ) then
		local newID;
		while ( nextID and completed ) do
			newID, completed = GetNextAchievement(nextID);
			if ( completed ) then
				nextID = newID;
			end
		end
		id = nextID;
	end

	AchievementFrame_SelectAchievement(id);
end

function AchievementFrameSummaryAchievement_OnEnter(self)
	self.Highlight:Show();
	if ( self.tooltipTitle ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltipTitle,1,1,1);
		GameTooltip:AddLine(self.tooltip, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

function AchievementFrameSummaryCategoryButton_OnClick (self)
	local category = self:GetParent():GetID();
	AchievementFrame_UpdateAndSelectCategory(category);
end

function AchievementFrameSummaryCategory_OnLoad (self)
	self:SetMinMaxValues(0, 100);
	self:SetValue(0);
end

function AchievementFrame_GetCategoryTotalNumAchievements (id, showAll)
	-- Not recursive because we only have one deep and this saves time.
	local totalAchievements, totalCompleted = 0, 0;
	local numAchievements, numCompleted = GetCategoryNumAchievements(id, showAll);
	totalAchievements = totalAchievements + numAchievements;
	totalCompleted = totalCompleted + numCompleted;

	local categories = achievementFunctions.categories;
	for index, elementData in ipairs(categories) do
		if ( elementData.parent == id ) then
			numAchievements, numCompleted = GetCategoryNumAchievements(elementData.id, showAll);
			totalAchievements = totalAchievements + numAchievements;
			totalCompleted = totalCompleted + numCompleted;
		end
	end

	return totalAchievements, totalCompleted;
end

function AchievementFrameSummaryCategory_OnEvent (self, event, ...)
	AchievementFrameSummaryCategory_OnShow(self);
end

function AchievementFrameSummaryCategory_OnShow (self)
	local totalAchievements, totalCompleted = AchievementFrame_GetCategoryTotalNumAchievements(self:GetID(), true);

	self.Text:SetText(string.format("%d/%d", totalCompleted, totalAchievements));
	self:SetMinMaxValues(0, totalAchievements);
	self:SetValue(totalCompleted);
	self:RegisterEvent("ACHIEVEMENT_EARNED");
end

function AchievementFrameSummaryCategory_OnHide (self)
	self:UnregisterEvent("ACHIEVEMENT_EARNED");
end

AchievementMetaCriteriaMixin = {};

function AchievementMetaCriteriaMixin:OnClick()
	AchievementFrame_SelectAchievement(self.id);
end

function AchievementMetaCriteriaMixin:OnEnter()
	if self.date then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:AddLine(string.format(ACHIEVEMENT_META_COMPLETED_DATE, self.date), 1, 1, true);
		AchievementFrameAchievements_CheckGuildMembersTooltip(self);
		GameTooltip:Show();
	end
end

function AchievementMetaCriteriaMixin:OnLeave()
	GameTooltip:Hide();
	guildMemberRequestFrame = nil;
end

function AchievementFrame_UpdateAndSelectCategory(category)
	local currentCategory = GetSelectedCategory();
	if currentCategory == category then
		return;
	end

	-- Assume the category is not in our data provider.
	AchievementFrameCategories_ExpandToCategory(category);
	AchievementFrameCategories_UpdateDataProvider();

	-- Select the category.
	local scrollBox = AchievementFrameCategories.ScrollBox;
	local dataProvider = scrollBox:GetDataProvider();
	if dataProvider then
		local elementData = dataProvider:FindElementDataByPredicate(function(elementData)
			return elementData.id == category;
		end);
		if elementData then
			AchievementFrameCategories_SelectElementData(elementData);
			scrollBox:ScrollToElementData(elementData, ScrollBoxConstants.AlignCenter, ScrollBoxConstants.NoScrollInterpolation);
		end
	end
end

function AchievementFrame_SelectAchievement(id, forceSelect)
	if ( (not AchievementFrame:IsShown() and not forceSelect) or (not C_AchievementInfo.IsValidAchievement(id)) ) then
		return;
	end
	
	local achCompleted = select(4, GetAchievementInfo(id));
	if ( achCompleted and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_INCOMPLETE].func) ) then
		AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
	elseif ( (not achCompleted) and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_COMPLETE].func) ) then
		AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
	end
	
	-- Figure out if this is part of a progressive achievement; if it is and it's incomplete, make sure the previous level was completed. 
	-- If not, find the first incomplete achievement in the chain and display that instead.
	local displayedId = AchievementFrame_FindDisplayedAchievement(id);
	local category = GetAchievementCategory(displayedId);
	AchievementFrame_UpdateAndSelectCategory(category);

	-- Scroll to the achievement and select it.
	local scrollBox = nil;
	if AchievementFrameComparison:IsShown() then
		AchievementFrame_SelectAndScrollToAchievementId(AchievementFrameComparison.AchievementContainer.ScrollBox, displayedId);
	else
		AchievementFrame_SelectAndScrollToAchievementId(AchievementFrameAchievements.ScrollBox, displayedId);
	end
end

function AchievementFrame_SelectAndScrollToAchievementId(scrollBox, achievementId)
	local dataProvider = scrollBox:GetDataProvider();
	if dataProvider then
		local elementData = dataProvider:FindElementDataByPredicate(function(elementData)
			return elementData.id == achievementId;
		end);
		if elementData then
			g_achievementSelectionBehavior:SelectElementData(elementData);
			-- Selection expands and modifies the size. We need to update the scroll box for the alignment to be correct.
			scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
			scrollBox:ScrollToElementData(elementData, ScrollBoxConstants.AlignCenter, ScrollBoxConstants.NoScrollInterpolation);
		end
	end
end

function AchievementFrame_ViewStatisticByAchievementID(achievementID)
	local category = GetAchievementCategory(achievementID);
	AchievementFrame_UpdateAndSelectCategory(category);

	local scrollBox = nil;
	if AchievementFrameComparison:IsShown() then
		scrollBox = AchievementFrameComparison.StatContainer.ScrollBox;
	else
		scrollBox = AchievementFrameStats.ScrollBox;
	end

	local achievementElementData = scrollBox:ScrollToElementDataByPredicate(function(elementData)
		return elementData.id == achievementID;
	end, ScrollBoxConstants.AlignCenter, ScrollBoxConstants.NoScrollInterpolation);
end

AchievementComparisonTemplateMixin = {};

function AchievementComparisonTemplateMixin:OnLoad()
	AchievementComparisonButton_Localize(self);
end

function AchievementComparisonTemplateMixin:Init(elementData)
	local category = elementData.category;
	local index = elementData.index;
	local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(category, index);

	assertsafe(id ~= nil, "Missing AchievementInfo for category '%d' index '%d'", category, index);

	if ( GetPreviousAchievement(id) ) then
		-- If this is a progressive achievement, show the total score.
		points = AchievementButton_GetProgressivePoints(id);
	end
	
	if ( self.id ~= id ) then
		self.id = id;
	
		local player = self.Player;
		local friend = self.Friend;
	
		local saturatedStyle = "normal";
		if ( bit.band(flags, ACHIEVEMENT_FLAGS_ACCOUNT) == ACHIEVEMENT_FLAGS_ACCOUNT ) then
			player.accountWide = true;
			friend.accountWide = true;
			saturatedStyle = "account";
		else
			player.accountWide = nil;
			friend.accountWide = nil;
		end
	
		local friendCompleted, friendMonth, friendDay, friendYear = GetAchievementComparisonInfo(id);
		player.Label:SetText(name);
	
		player.Description:SetText(description);
	
		player.Icon.texture:SetTexture(icon);
		friend.Icon.texture:SetTexture(icon);
	
		if ( points > 0 ) then
			player.Shield.Icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
			friend.Shield.Icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
		else
			player.Shield.Icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
			friend.Shield.Icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
		end
		AchievementShield_SetPoints(points, player.Shield.Points, ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT1, ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT2);
		AchievementShield_SetPoints(points, friend.Shield.Points, ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT1, ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT2);
	
		player.Shield.wasEarnedByMe = not (completed and not wasEarnedByMe);
		player.Shield.earnedBy = earnedBy;
	
		if ( completed ) then
			player.completed = true;
			player.DateCompleted:SetText(FormatShortDate(day, month, year));
			player.DateCompleted:Show();
			if ( player.saturatedStyle ~= saturatedStyle ) then
				player:Saturate();
			end
		else
			player.completed = nil;
			player.DateCompleted:Hide();
			player:Desaturate();
		end
	
		if ( friendCompleted ) then
			friend.completed = true;
			friend.Status:SetText(FormatShortDate(friendDay, friendMonth, friendYear));
			if ( friend.saturatedStyle ~= saturatedStyle ) then
				friend:Saturate();
			end
		else
			friend.completed = nil;
			friend.Status:SetText(INCOMPLETE);
			friend:Desaturate();
		end
	end
end

function AchievementFrameComparison_OnLoad (self)
	do
		local view = CreateScrollBoxListLinearView();
		view:SetElementInitializer("AchievementComparisonTemplate", function(frame, elementData)
			frame:Init(elementData);
		end);
		ScrollUtil.InitScrollBoxListWithScrollBar(self.AchievementContainer.ScrollBox, self.AchievementContainer.ScrollBar, view);
	end

	do
		local view = CreateScrollBoxListLinearView();
		view:SetElementInitializer("AchievementComparisonStatTemplate", function(frame, elementData)
			frame:Init(elementData);
		end);
		ScrollUtil.InitScrollBoxListWithScrollBar(self.StatContainer.ScrollBox, self.StatContainer.ScrollBar, view);
	end

	self:RegisterEvent("INSPECT_ACHIEVEMENT_READY");
end

local AchievementFrameComparisonShownEvents =
{
	"ACHIEVEMENT_EARNED",
	"UNIT_PORTRAIT_UPDATE",
	"PORTRAITS_UPDATED",
	"DISPLAY_SIZE_CHANGED",
};

function AchievementFrameComparison_OnShow(self)
	AchievementFrameStats:Hide();
	AchievementFrameAchievements:Hide();
	AchievementFrame:SetWidth(890);
	SetUIPanelAttribute(AchievementFrame, "xOffset", 38);
	UpdateUIPanelPositions(AchievementFrame);
	AchievementFrame.isComparison = true;
	C_AchievementInfo.SetPortraitTexture(AchievementFrameComparisonHeaderPortrait);
	FrameUtil.RegisterFrameForEvents(self, AchievementFrameComparisonShownEvents);
	AchievementFrameComparison_ForceUpdate();
end

function AchievementFrameComparison_OnHide(self)
	AchievementFrame.selectedTab = nil;
	AchievementFrame:SetWidth(768);
	SetUIPanelAttribute(AchievementFrame, "xOffset", 80);
	UpdateUIPanelPositions(AchievementFrame);
	AchievementFrame.isComparison = false;
	ClearAchievementComparisonUnit();
	FrameUtil.UnregisterFrameForEvents(self, AchievementFrameComparisonShownEvents);
end

function AchievementFrameComparison_OnEvent (self, event, ...)
	if event == "INSPECT_ACHIEVEMENT_READY" then
		ClearSelectedCategories();
		local category = AchievementFrame_GetOrSelectCurrentCategory();
		AchievementFrameComparison_UpdateStatusBars(category);
		AchievementFrameComparisonHeader.Points:SetText(GetComparisonAchievementPoints());
	elseif event == "DISPLAY_SIZE_CHANGED" then
		C_AchievementInfo.SetPortraitTexture(AchievementFrameComparisonHeaderPortrait);
	elseif event == "PORTRAITS_UPDATED" then
		C_AchievementInfo.SetPortraitTexture(AchievementFrameComparisonHeaderPortrait);
	elseif event == "UNIT_PORTRAIT_UPDATE" then
		local updateUnit = ...;
		if UnitName(updateUnit) == AchievementFrameComparisonHeaderName:GetText() then
			C_AchievementInfo.SetPortraitTexture(AchievementFrameComparisonHeaderPortrait);
		end
	end

	AchievementFrameComparison_ForceUpdate();
end

function AchievementFrameComparison_SetUnit (unit)
	ClearAchievementComparisonUnit();
	SetAchievementComparisonUnit(unit);

	AchievementFrameComparisonHeader.Points:SetText(GetComparisonAchievementPoints());
	AchievementFrameComparisonHeaderName:SetText(GetUnitName(unit));
	C_AchievementInfo.SetPortraitTexture(AchievementFrameComparisonHeaderPortrait);
	AchievementFrameComparisonHeaderPortrait.unit = unit;
	AchievementFrameComparisonHeaderPortrait.race = UnitRace(unit);
	AchievementFrameComparisonHeaderPortrait.sex = UnitSex(unit);
end

function AchievementFrameComparison_ForceUpdate ()
	if ( achievementFunctions == COMPARISON_ACHIEVEMENT_FUNCTIONS ) then
		AchievementFrameComparison_UpdateDataProvider();
	elseif ( achievementFunctions == COMPARISON_STAT_FUNCTIONS ) then
		AchievementFrameComparison_UpdateStatsDataProvider();
	end
end

function AchievementFrameComparison_UpdateDataProvider ()
	local category = AchievementFrame_GetOrSelectCurrentCategory();
	if category == "summary" then
		return;
	end

	local numAchievements = GetCategoryNumAchievements(category);
	local newDataProvider = CreateDataProvider();
	for index = 1, numAchievements do
		newDataProvider:Insert({ index = index, category = category });
	end
	AchievementFrameComparison.AchievementContainer.ScrollBox:SetDataProvider(newDataProvider);
end

function AchievementFrameComparison_UpdateStatsDataProvider ()
	local category = GetSelectedCategory();
	local numStats = GetCategoryNumAchievements(category);

	local categories = {};
	if ( achievementFunctions.lastCategory ~= category ) then
		-- build a list of shown category and stat id's
		tinsert(categories, {id = category, header = true});

		for i = 1, numStats do
			tinsert(categories, {id = GetAchievementInfo(category, i)});
		end
		achievementFunctions.lastCategory = category;
	end

	-- add all the subcategories and their stat id's
	for i, cat in next, achievementFunctions.categories do
		if ( cat.parent == category ) then
			tinsert(categories, {id = cat.id, header = true});
			numStats = GetCategoryNumAchievements(cat.id);
			for k=1, numStats do
				tinsert(categories, {id = GetAchievementInfo(cat.id, k)});
			end
		end
	end

	local newDataProvider = CreateDataProvider();
	for index = 1, #categories do
		local stat = categories[index];
		stat.colorIndex = mod(index, 2);
		newDataProvider:Insert(stat);
	end
	AchievementFrameComparison.StatContainer.ScrollBox:SetDataProvider(newDataProvider);
end

function AchievementFrameComparisonStat_OnLoad (self)
	self.Value:SetVertexColor(1, 0.97, 0.6);
	self.FriendValue:SetVertexColor(1, 0.97, 0.6);
end

AchivementComparisonStatMixin = {};

function AchivementComparisonStatMixin:Init(elementData)
	local category = elementData.id;
	local colorIndex = elementData.colorIndex;
	if elementData.header then
		self.Left:Show();
		self.Middle:Show();
		self.Right:Show();
		self.Left2:Show();
		self.Middle2:Show();
		self.Right2:Show();
		self.Title:SetText(GetCategoryInfo(category));
		self.Title:Show();
		self.FriendValue:SetText("");
		self.Value:SetText("");
		self.Text:SetText("");
		self:SetHeight(24);
		self.Background:Hide();
		self.isHeader = true;
		self.id = id;
	else
		local id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(category);

		self.id = id;

		self.Background:Show();
		-- Color every other line yellow
		if ( colorIndex == 1 ) then
			self.Background:SetTexCoord(0, 1, 0.1875, 0.3671875);
			self.Background:SetBlendMode("BLEND");
			self.Background:SetAlpha(1.0);
			self:SetHeight(24);
		else
			self.Background:SetTexCoord(0, 1, 0.375, 0.5390625);
			self.Background:SetBlendMode("ADD");
			self.Background:SetAlpha(0.5);
			self:SetHeight(24);
		end

		-- Figure out the criteria
		local numCriteria = GetAchievementNumCriteria(id);
		if ( numCriteria == 0 ) then
			-- This is no good!
		end
		-- Just show the first criteria for now
		local criteriaString, criteriaType, completed, quantityNumber, reqQuantity, charName, flags, assetID, quantity, friendQuantity;
		if ( not isSummary ) then
			friendQuantity = GetComparisonStatistic(id);
			quantity = GetStatistic(id);
		else
			criteriaString, criteriaType, completed, quantityNumber, reqQuantity, charName, flags, assetID, quantity = GetAchievementCriteriaInfo(category);
		end
		if ( not quantity ) then
			quantity = "--";
		end
		if ( not friendQuantity ) then
			friendQuantity = "--";
		end

		self.Value:SetText(quantity);

		-- We're gonna use self.text here to measure string width for friendQuantity. This saves us many strings!
		self.Text:SetText(friendQuantity);
		local width = self.Text:GetStringWidth();
		if ( width > self.FriendValue:GetWidth() ) then
			self.FriendValue:SetFontObject("AchievementFont_Small");
			self.Mouseover:Show();
			self.Mouseover.tooltip = friendQuantity;
		else
			self.FriendValue:SetFontObject("GameFontHighlightRight");
			self.Mouseover:Hide();
			self.Mouseover.tooltip = nil;
		end

		self.Text:SetText(name);
		self.FriendValue:SetText(friendQuantity);

		-- Hide the header images
		self.Title:Hide();
		self.Left:Hide();
		self.Middle:Hide();
		self.Right:Hide();
		self.Left2:Hide();
		self.Middle2:Hide();
		self.Right2:Hide();
		self.isHeader = false;
	end
end

function AchievementComparisonPlayerButton_Saturate (self)
	local name = self:GetName();
	if ( InGuildView() ) then
		self.Background:SetTexture("Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal");
		self.TitleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.TitleBar:SetTexCoord(0, 1, 0.83203125, 0.91015625);
		self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
		self.Shield.Points:SetVertexColor(0, 1, 0);
		self.saturatedStyle = "guild";
	else
		self.Background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
		self.Shield.Points:SetVertexColor(1, 1, 1);
		if ( self.accountWide ) then
			self.TitleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
			self.TitleBar:SetTexCoord(0, 1, 0, 0.375);
			self:SetBackdropBorderColor(ACHIEVEMENT_BLUE_BORDER_COLOR:GetRGB());
			self.saturatedStyle = "account";
		else
			self.TitleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			self.TitleBar:SetTexCoord(0, 1, 0.66015625, 0.73828125);
			self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
			self.saturatedStyle = "normal";
		end
	end
	if ( self.isSummary ) then
		if ( self.accountWide ) then
			self.TitleBar:SetAlpha(1);
		else
			self.TitleBar:SetAlpha(0.5);
		end
	end
	self.Glow:SetVertexColor(1.0, 1.0, 1.0);
	self.Icon:Saturate();
	self.Shield:Saturate();
	self.Label:SetVertexColor(1, 1, 1);
	self.Description:SetTextColor(0, 0, 0, 1);
	self.Description:SetShadowOffset(0, 0);
end

function AchievementComparisonPlayerButton_Desaturate (self)
	self.saturatedStyle = nil;
	local name = self:GetName();
	if ( InGuildView() ) then
		self.Background:SetTexture("Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal-Desaturated");
		self.TitleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.TitleBar:SetTexCoord(0, 1, 0.74609375, 0.82421875);
	else
		self.Background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
		if ( self.accountWide ) then
			self.TitleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
			self.TitleBar:SetTexCoord(0, 1, 0.40625, 0.78125);
		else
			self.TitleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			self.TitleBar:SetTexCoord(0, 1, 0.91796875, 0.99609375);
		end
	end
	if ( self.isSummary ) then
		if ( self.accountWide ) then
			self.TitleBar:SetAlpha(1);
		else
			self.TitleBar:SetAlpha(0.5);
		end
	end
	self.Glow:SetVertexColor(.22, .17, .13);
	self.Icon:Desaturate();
	self.Shield:Desaturate();
	self.Shield.Points:SetVertexColor(.65, .65, .65);
	self.Label:SetVertexColor(.65, .65, .65);
	self.Description:SetTextColor(1, 1, 1, 1);
	self.Description:SetShadowOffset(1, -1);
	self:SetBackdropBorderColor(.5, .5, .5);
end

function AchievementComparisonPlayerButton_OnLoad (self)
	self.Saturate = AchievementComparisonPlayerButton_Saturate;
	self.Desaturate = AchievementComparisonPlayerButton_Desaturate;

	self:Desaturate();
end

function AchievementComparisonFriendButton_Saturate (self)
	if ( self.accountWide ) then
		self.TitleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
		self.TitleBar:SetTexCoord(0.3, 0.575, 0, 0.375);
		self.saturatedStyle = "account";
		self:SetBackdropBorderColor(ACHIEVEMENT_BLUE_BORDER_COLOR:GetRGB());
	else
		self.TitleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.TitleBar:SetTexCoord(0.3, 0.575, 0.66015625, 0.73828125);
		self.saturatedStyle = "normal";
		self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
	end
	self.Background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
	self.Glow:SetVertexColor(1.0, 1.0, 1.0);
	self.Icon:Saturate();
	self.Shield:Saturate();
	self.Shield.Points:SetVertexColor(1, 1, 1);
	self.Status:SetVertexColor(1, .82, 0);
end

function AchievementComparisonFriendButton_Desaturate (self)
	self.saturatedStyle = nil;
	if ( self.accountWide ) then
		self.TitleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
		self.TitleBar:SetTexCoord(0.3, 0.575, 0.40625, 0.78125);
	else
		self.TitleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.TitleBar:SetTexCoord(0.3, 0.575, 0.74609375, 0.82421875);
	end
	self.Background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
	self.Glow:SetVertexColor(.22, .17, .13);
	self.Icon:Desaturate();
	self.Shield:Desaturate();
	self.Shield.Points:SetVertexColor(.65, .65, .65);
	self.Status:SetVertexColor(.65, .65, .65);
	self:SetBackdropBorderColor(.5, .5, .5);
end

function AchievementComparisonFriendButton_OnLoad (self)
	self.Saturate = AchievementComparisonFriendButton_Saturate;
	self.Desaturate = AchievementComparisonFriendButton_Desaturate;

	self:Desaturate();
end

function AchievementFrame_IsComparison()
	return AchievementFrame.isComparison;
end

--
-- Guild Members Display
--

function AchievementMeta_OnLeave(self)
	GameTooltip:Hide();
	guildMemberRequestFrame = nil;
end

function AchievementShield_OnEnter(self)
	local parent = self:GetParent();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( parent.accountWide ) then
		if ( parent.completed ) then
			GameTooltip:AddLine(ACCOUNT_WIDE_ACHIEVEMENT_COMPLETED);
		else
			GameTooltip:AddLine(ACCOUNT_WIDE_ACHIEVEMENT);
		end
		GameTooltip:Show();
		return;
	end
	if ( self.earnedBy ) then
		GameTooltip:AddLine(format(ACHIEVEMENT_EARNED_BY,self.earnedBy));
		local me = UnitName("player")
		if ( not self.wasEarnedByMe ) then
			GameTooltip:AddLine(format(ACHIEVEMENT_NOT_COMPLETED_BY, me));
		elseif ( me ~= self.earnedBy ) then
			GameTooltip:AddLine(format(ACHIEVEMENT_COMPLETED_BY, me));
		end
		GameTooltip:Show();
		return;
	end
	-- pass-through to the achievement button
	local func = parent:GetScript("OnEnter");
	if ( func ) then
		func(parent);
	end

	AchievementFrameAchievements_CheckGuildMembersTooltip(self);
	GameTooltip:Show();
end

function AchievementShield_OnLeave(self)
	-- pass-through to the achievement button
	local parent = self:GetParent();
	local func = parent:GetScript("OnLeave");
	if ( func ) then
		func(parent);
	end
	GameTooltip:Hide();
	guildMemberRequestFrame = nil;
end


function AchievementFrameFilterDropDown_OnEnter(self)
	local currentFilter = AchievementFrameFilterDropDown.value;
	GameTooltip:SetOwner(AchievementFrameFilterDropDown, "ANCHOR_RIGHT", -18, 0);
	GameTooltip:AddLine(AchievementFrameFilterStrings[currentFilter]);
	GameTooltip:Show();
end

function AchievementFrameAchievements_CheckGuildMembersTooltip(requestFrame)
	if ( InGuildView() ) then
		local achievementId = requestFrame.id;
		local _, achievementName, points, achievementCompleted, month, day, year, description, flags, iconpath = GetAchievementInfo(achievementId);
		-- check if achievement has names, only if completed
		if ( achievementCompleted and bit.band(flags, ACHIEVEMENT_FLAGS_SHOW_GUILD_MEMBERS) == ACHIEVEMENT_FLAGS_SHOW_GUILD_MEMBERS ) then
			local numMembers = GetGuildAchievementNumMembers(achievementId);
			if ( numMembers == 0 ) then
				-- we may not have the members from the server yet
				guildMemberRequestFrame = requestFrame;
				GetGuildAchievementMembers(achievementId);
			else
				-- add a line break if the tooltip shows completed date (meta tooltip)
				if ( GameTooltip:NumLines() > 0 ) then
					GameTooltip:AddLine(" ");
				end
				GameTooltip:AddLine(GUILD_ACHIEVEMENT_EARNED_BY, 1, 1, 1);
				local leftMemberName;
				for i = 1, numMembers do
					if ( leftMemberName ) then
						GameTooltip:AddDoubleLine(leftMemberName, GetGuildAchievementMemberInfo(achievementId, i));
						leftMemberName = nil;
					else
						leftMemberName = GetGuildAchievementMemberInfo(achievementId, i);
					end
				end
				-- check for leftover name
				if ( leftMemberName ) then
					GameTooltip:AddLine(leftMemberName);
				end
			end
		-- otherwise check if criteria has names
		elseif ( bit.band(flags, ACHIEVEMENT_FLAGS_SHOW_CRITERIA_MEMBERS) == ACHIEVEMENT_FLAGS_SHOW_CRITERIA_MEMBERS ) then
			local numCriteria = GetAchievementNumCriteria(achievementId);
			local firstName = true;
			for i = 1, numCriteria do
				local criteriaString, _, completed, _, _, charName = GetAchievementCriteriaInfo(achievementId, i);
				if ( completed and charName ) then
					if ( firstName ) then
						if ( achievementCompleted ) then
							GameTooltip:AddLine(GUILD_ACHIEVEMENT_EARNED_BY, 1, 1, 1);
						else
							GameTooltip:AddLine(INCOMPLETE, 1, 1, 1);
						end
						firstName = false;
					end
					GameTooltip:AddDoubleLine(criteriaString, charName, 0, 1, 0);
				end
			end
		end
	end
end

-- If this achievement is part of a chain, find the first incomplete achievement in the chain.
function AchievementFrame_FindDisplayedAchievement(baseAchievementID)
	local id = baseAchievementID;
	local _, _, _, completed = GetAchievementInfo(id);
	if ( not completed and GetPreviousAchievement(id) ) then
		local prevID = GetPreviousAchievement(id);
		_, _, _, completed = GetAchievementInfo(prevID);
		while ( prevID and not completed ) do
			id = prevID;
			prevID = GetPreviousAchievement(id);
			if ( prevID ) then
				_, _, _, completed = GetAchievementInfo(prevID);
			end
		end
	elseif ( completed ) then
		local nextID, completed = GetNextAchievement(id);
		if ( nextID and completed ) then
			local newID
			while ( nextID and completed ) do
				newID, completed = GetNextAchievement(nextID);
				if ( completed ) then
					nextID = newID;
				end
			end
			id = nextID;
		end
	end

	return id;
end

function AchievementFrame_HideSearchPreview()
	local searchPreviewContainer = AchievementFrame.SearchPreviewContainer;
	local searchPreviews = searchPreviewContainer.searchPreviews;
	searchPreviewContainer:Hide();

	for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
		searchPreviews[index]:Hide();
	end

	searchPreviewContainer.ShowAllSearchResults:Hide();
	AchievementFrame.searchProgressBar:Hide();
end

function AchievementFrame_UpdateSearchPreview()
	if ( not AchievementFrame.SearchBox:HasFocus() or strlen(AchievementFrame.SearchBox:GetText()) < MIN_CHARACTER_SEARCH) then
		AchievementFrame_HideSearchPreview();
		return;
	end

	AchievementFrame.SearchBox.searchPreviewUpdateDelay = 0;

	if ( AchievementFrame.SearchBox:GetScript("OnUpdate") == nil ) then
		AchievementFrame.SearchBox:SetScript("OnUpdate", AchievementFrameSearchBox_OnUpdate);
	end
end

-- There is a delay before the search is updated to avoid a search progress bar if the search
-- completes within the grace period.
local ACHIEVEMENT_SEARCH_PREVIEW_UPDATE_DELAY = 0.3;
function AchievementFrameSearchBox_OnUpdate (self, elapsed)
	if ( self.fullSearchFinished ) then
		AchievementFrame_ShowSearchPreviewResults();
		self.searchPreviewUpdateDelay = 0;
		self:SetScript("OnUpdate", nil);
		return;
	end

	self.searchPreviewUpdateDelay = self.searchPreviewUpdateDelay + elapsed;

	if ( self.searchPreviewUpdateDelay > ACHIEVEMENT_SEARCH_PREVIEW_UPDATE_DELAY ) then
		self.searchPreviewUpdateDelay = 0;
		self:SetScript("OnUpdate", nil);

		if ( AchievementFrame.searchProgressBar:GetScript("OnUpdate") == nil ) then
			AchievementFrame.searchProgressBar:SetScript("OnUpdate", AchievementFrameSearchProgressBar_OnUpdate);

			local searchPreviewContainer = AchievementFrame.SearchPreviewContainer;
			local searchPreviews = searchPreviewContainer.searchPreviews;
			for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
				searchPreviews[index]:Hide();
			end

			searchPreviewContainer.ShowAllSearchResults:Hide();

			searchPreviewContainer.BorderAnchor:SetPoint("BOTTOM", 0, -5);
			searchPreviewContainer.Background:Show();
			searchPreviewContainer:Show();

			AchievementFrame.searchProgressBar:Show();
			return;
		end
	end
end

-- If the searcher does not finish within the update delay then a search progress bar is displayed that
-- will fill until the search is finished and then display the search preview results.
function AchievementFrameSearchProgressBar_OnUpdate(self, elapsed)
	local _, maxValue = self:GetMinMaxValues();
	local actualProgress = GetAchievementSearchProgress() / GetAchievementSearchSize() * maxValue;
	local displayedProgress = self:GetValue();

	self:SetValue(actualProgress);

	if ( self:GetValue() >= maxValue ) then
		self:SetScript("OnUpdate", nil);
		self:SetValue(0);
		AchievementFrame_ShowSearchPreviewResults();
	end
end

function AchievementFrame_ShowSearchPreviewResults()
	AchievementFrame.searchProgressBar:Hide();

	local numResults = GetNumFilteredAchievements();

	if ( numResults > 0 ) then
		AchievementFrame_SetSearchPreviewSelection(1);
	end

	local searchPreviewContainer = AchievementFrame.SearchPreviewContainer;
	local searchPreviews = searchPreviewContainer.searchPreviews;
	local lastButton;
	for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
		local searchPreview = searchPreviews[index];
		if ( index <= numResults ) then
			local achievementID = GetFilteredAchievementID(index);
			local _, name, _, _, _, _, _, description, _, icon, _, _, _, _ = GetAchievementInfo(achievementID);
			searchPreview.Name:SetText(name);
			searchPreview.Icon:SetTexture(icon);
			searchPreview.achievementID = achievementID;
			searchPreview:Show();
			lastButton = searchPreview;
		else
			searchPreview.achievementID = nil;
			searchPreview:Hide();
		end
	end

	if ( numResults > 5 ) then
		searchPreviewContainer.ShowAllSearchResults:Show();
		lastButton = searchPreviewContainer.ShowAllSearchResults;
		searchPreviewContainer.ShowAllSearchResults.Text:SetText(string.format(ENCOUNTER_JOURNAL_SHOW_SEARCH_RESULTS, numResults));
	else
		searchPreviewContainer.ShowAllSearchResults:Hide();
	end

	if (lastButton) then
		searchPreviewContainer.BorderAnchor:SetPoint("BOTTOM", lastButton, "BOTTOM", 0, -5);
		searchPreviewContainer.Background:Hide();
		searchPreviewContainer:Show();
	else
		searchPreviewContainer:Hide();
	end
end

function AchievementFrameSearchBox_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);

	if ( strlen(self:GetText()) >= MIN_CHARACTER_SEARCH ) then
		AchievementFrame.SearchBox.fullSearchFinished = SetAchievementSearchString(self:GetText());
		if ( not AchievementFrame.SearchBox.fullSearchFinished ) then
			AchievementFrame_UpdateSearchPreview();
		else
			AchievementFrame_ShowSearchPreviewResults();
		end
	else
		AchievementFrame_HideSearchPreview();
	end
end

AchievementFullSearchResultsButtonMixin = {};

function AchievementFullSearchResultsButtonMixin:Init(elementData)
	local index = elementData.index;

	local achievementID = GetFilteredAchievementID(index);
	local _, name, _, completed, _, _, _, description, _, icon, _, _, _, _ = GetAchievementInfo(achievementID);
	
	self.Name:SetText(name);
	self.Icon:SetTexture(icon);
	self.achievementID = achievementID;
	
	if ( completed ) then
		self.ResultType:SetText(ACHIEVEMENTFRAME_FILTER_COMPLETED);
	else
		self.ResultType:SetText(ACHIEVEMENTFRAME_FILTER_INCOMPLETE);
	end
	
	local categoryID = GetAchievementCategory(achievementID);
	local categoryName, parentCategoryID = GetCategoryInfo(categoryID);
	path = categoryName;
	while ( not (parentCategoryID == -1) ) do
		categoryName, parentCategoryID = GetCategoryInfo(parentCategoryID);
		path = categoryName.." > "..path;
	end
	
	self.Path:SetText(path);
end

function AchievementFrameSearchBoxContainer_OnLoad(self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("AchievementFullSearchResultsButtonTemplate", function(button, elementData)
		button:Init(elementData);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function AchievementFrameSearchBox_OnLoad(self)
	SearchBoxTemplate_OnLoad(self);
	self.HasStickyFocus = function()
		local ancestry = self:GetParent().SearchPreviewContainer;
		return DoesAncestryInclude(ancestry, GetMouseFocus());
	end
end

function AchievementFrameSearchBox_OnShow(self)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 7);
	AchievementFrame_SetSearchPreviewSelection(1);
	self.fullSearchFinished = false;
	self.searchPreviewUpdateDelay = 0;
end

function AchievementFrameSearchBox_OnEnterPressed(self)
	-- If the search is not finished yet we have to wait to show the full search results.
	if ( not self.fullSearchFinished or strlen(self:GetText()) < MIN_CHARACTER_SEARCH ) then
		return;
	end

	local searchPreviewContainer = AchievementFrame.SearchPreviewContainer;
	if ( self.selectedIndex == ACHIEVEMENT_FRAME_SHOW_ALL_RESULTS_INDEX ) then
		if ( searchPreviewContainer.ShowAllSearchResults:IsShown() ) then
			searchPreviewContainer.ShowAllSearchResults:Click();
		end
	else
		local preview = searchPreviewContainer.searchPreviews[self.selectedIndex];
		if ( preview:IsShown() ) then
			preview:Click();
		end
	end
end

function AchievementFrameSearchBox_OnFocusLost(self)
	SearchBoxTemplate_OnEditFocusLost(self);
	AchievementFrame_HideSearchPreview();
end

function AchievementFrameSearchBox_OnFocusGained(self)
	SearchBoxTemplate_OnEditFocusGained(self);
	AchievementFrame.SearchResults:Hide();
	AchievementFrame_UpdateSearchPreview();
end

function AchievementFrameSearchBox_OnKeyDown(self, key)
	if ( key == "UP" ) then
		AchievementFrame_SetSearchPreviewSelection(AchievementFrame.SearchBox.selectedIndex - 1);
	elseif ( key == "DOWN" ) then
		AchievementFrame_SetSearchPreviewSelection(AchievementFrame.SearchBox.selectedIndex + 1);
	end
end

function AchievementFrame_SetSearchPreviewSelection(selectedIndex)
	local searchPreviewContainer = AchievementFrame.SearchPreviewContainer;
	local searchPreviews = searchPreviewContainer.searchPreviews;
	local numShown = 0;
	for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
		local searchPreview = searchPreviews[index];
		searchPreview.SelectedTexture:Hide();

		if ( searchPreview:IsShown() ) then
			numShown = numShown + 1;
		end
	end

	if ( searchPreviewContainer.ShowAllSearchResults:IsShown() ) then
		numShown = numShown + 1;
	end

	searchPreviewContainer.ShowAllSearchResults.SelectedTexture:Hide();
	
	if ( numShown <= 0 ) then
		-- Default to the first entry.
		selectedIndex = 1;
	else
		selectedIndex = (selectedIndex - 1) % numShown + 1;
	end

	AchievementFrame.SearchBox.selectedIndex = selectedIndex;

	if ( selectedIndex == ACHIEVEMENT_FRAME_SHOW_ALL_RESULTS_INDEX ) then
		searchPreviewContainer.ShowAllSearchResults.SelectedTexture:Show();
	else
		searchPreviewContainer.searchPreviews[selectedIndex].SelectedTexture:Show();
	end
end

function AcheivementFullSearchResultsButton_OnClick(self)
	if (self.achievementID) then
		AchievementFrame_SelectSearchItem(self.achievementID);
		AchievementFrame.SearchResults:Hide();
	end
end

function AchievementFrame_ShowFullSearch()
	AchievementFrame_UpdateFullSearchResults();

	if ( GetNumFilteredAchievements() == 0 ) then
		AchievementFrame.SearchResults:Hide();
		return;
	end

	AchievementFrame_HideSearchPreview();
	AchievementFrame.SearchBox:ClearFocus();
	AchievementFrame.SearchResults:Show();
end

function AchievementFrameSearch_InitButton(button, result)
	local achievementID = GetFilteredAchievementID(index);
	local _, name, _, completed, _, _, _, description, _, icon, _, _, _, _ = GetAchievementInfo(achievementID);

	result.Name:SetText(name);
	result.Icon:SetTexture(icon);
	result.achievementID = achievementID;

	if ( completed ) then
		result.resultType:SetText(ACHIEVEMENTFRAME_FILTER_COMPLETED);
	else
		result.resultType:SetText(ACHIEVEMENTFRAME_FILTER_INCOMPLETE);
	end

	local categoryID = GetAchievementCategory(achievementID);
	local categoryName, parentCategoryID = GetCategoryInfo(categoryID);
	path = categoryName;
	while ( not (parentCategoryID == -1) ) do
		categoryName, parentCategoryID = GetCategoryInfo(parentCategoryID);
		path = categoryName.." > "..path;
	end

	result.path:SetText(path);
end

function AchievementFrame_UpdateFullSearchResults()
	local numResults = GetNumFilteredAchievements();

	local newDataProvider = CreateDataProviderByIndexCount(numResults);
	AchievementFrame.SearchResults.ScrollBox:SetDataProvider(newDataProvider);

	AchievementFrame.SearchResults.TitleText:SetText(string.format(ENCOUNTER_JOURNAL_SEARCH_RESULTS, AchievementFrame.SearchBox:GetText(), numResults));
end

function AchievementFrame_SelectSearchItem(id)
	local isStatistic = select(15, GetAchievementInfo(id));
	if isStatistic then
		AchievementFrame_ViewStatisticByAchievementID(id);
	else
		AchievementFrame_SelectAchievement(id, true);
	end
end

function AchievementSearchPreviewButton_OnShow(self)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10);
end

function AchievementSearchPreviewButton_OnLoad(self)
	local searchPreviewContainer = AchievementFrame.SearchPreviewContainer;
	local searchPreviews = searchPreviewContainer.searchPreviews;
	for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
		if ( searchPreviews[index] == self ) then
			self.previewIndex = index;
			break;
		end
	end
end

function AchievementSearchPreviewButton_OnEnter(self)
	AchievementFrame_SetSearchPreviewSelection(self.previewIndex);
end

function AchievementSearchPreviewButton_OnClick(self)
	if ( self.achievementID ) then
		AchievementFrame_SelectSearchItem(self.achievementID);
		AchievementFrame.SearchResults:Hide();
		AchievementFrame_HideSearchPreview();
		AchievementFrame.SearchBox:ClearFocus();
	end
end

function AchievementFrameShowAllSearchResults_OnEnter()
	AchievementFrame_SetSearchPreviewSelection(ACHIEVEMENT_FRAME_SHOW_ALL_RESULTS_INDEX);
end

function AchievementFrame_UpdateSearch(self)
	if ( AchievementFrame.SearchResults:IsShown() ) then
		AchievementFrame_UpdateFullSearchResults();
	else
		AchievementFrame_UpdateSearchPreview();
	end
end