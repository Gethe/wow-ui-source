
UIPanelWindows["AchievementFrame"] = { area = "doublewide", pushable = 0, xoffset = 80, whileDead = 1 };

ACHIEVEMENTUI_CATEGORIES = {};

ACHIEVEMENTUI_GOLDBORDER_R = 1;
ACHIEVEMENTUI_GOLDBORDER_G = 0.675;
ACHIEVEMENTUI_GOLDBORDER_B = 0.125;
ACHIEVEMENTUI_GOLDBORDER_A = 1;

ACHIEVEMENTUI_REDBORDER_R = 0.7;
ACHIEVEMENTUI_REDBORDER_G = 0.15;
ACHIEVEMENTUI_REDBORDER_B = 0.05;
ACHIEVEMENTUI_REDBORDER_A = 1;

ACHIEVEMENTUI_BLUEBORDER_R = 0.129;
ACHIEVEMENTUI_BLUEBORDER_G = 0.671;
ACHIEVEMENTUI_BLUEBORDER_B = 0.875;
ACHIEVEMENTUI_BLUEBORDER_A = 1;

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

ACHIEVEMENT_COMPARISON_SUMMARY_ID = -1
ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID = -2

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
local IN_GUILD_VIEW;
local TEXTURES_OFFSET = 0;		-- 0.5 when in guild view

local ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS = 5;
local ACHIEVEMENT_FRAME_SHOW_ALL_RESULTS_INDEX = ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS + 1;

local displayStatCategories = {};

local guildMemberRequestFrame;

local trackedAchievements = {};
local achievementFunctions;
local function updateTrackedAchievements (...)
	local count = select("#", ...);

	for i = 1, count do
		trackedAchievements[select(i, ...)] = true;
	end
end

local function GetSafeScrollChildBottom(scrollChild)
	return scrollChild:GetBottom() or 0;
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
	AchievementFrame.wasShown = nil;
	AchievementFrameTab_OnClick = AchievementFrameComparisonTab_OnClick;
	AchievementFrameTab_OnClick(1);
	AchievementFrame_SetTabs();
	ShowUIPanel(AchievementFrame);
	--AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameSummary);
	AchievementFrameComparison_SetUnit(unit);
	AchievementFrameComparison_ForceUpdate();
end

function AchievementFrame_OnLoad (self)
	PanelTemplates_SetNumTabs(self, 3);
	self.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);

	AchievementFrameSummary.forceOnShow = AchievementFrameSummary_OnShow;
	AchievementFrameAchievements.forceOnShow = AchievementFrameAchievements_OnShow;

	self.searchResults.scrollFrame.update = AchievementFrame_UpdateFullSearchResults;
	self.searchResults.scrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.searchResults.scrollFrame, "AchievementFullSearchResultsButton", 0, 0);
end

function AchievementFrame_OnShow (self)
	PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_OPEN);
	AchievementFrameHeaderPoints:SetText(BreakUpLargeNumbers(GetTotalAchievementPoints()));
	if ( not AchievementFrame.wasShown ) then
		AchievementFrame.wasShown = true;
		AchievementCategoryButton_OnClick(AchievementFrameCategoriesContainerButton1);
	end
	UpdateMicroButtons();
	AchievementFrame_LoadTextures();
end

function AchievementFrame_OnHide (self)
	PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_CLOSE);
	AchievementFrame_HideSearchPreview();
	self.searchResults:Hide();
	self.searchBox:SetText("");
	UpdateMicroButtons();
	AchievementFrame_ClearTextures();
end

function AchievementFrame_ForceUpdate ()
	if ( AchievementFrameAchievements:IsShown() ) then
		AchievementFrameAchievements_ForceUpdate();
	elseif ( AchievementFrameStats:IsShown() ) then
		AchievementFrameStats_Update();
	elseif ( AchievementFrameComparison:IsShown() ) then
		AchievementFrameComparison_ForceUpdate();
	end
end

function AchievementFrame_SetTabs()
	AchievementFrameTab2:Show();
	AchievementFrameTab3:SetPoint("LEFT", AchievementFrameTab2, "RIGHT", -5, 0);
end

function AchievementFrame_UpdateTabs(clickedTab)
	AchievementFrame.searchResults:Hide();
	PanelTemplates_Tab_OnClick(_G["AchievementFrameTab"..clickedTab], AchievementFrame);
	local tab;
	for i = 1, 3 do
		tab = _G["AchievementFrameTab"..i];
		if ( i == clickedTab ) then
			tab.text:SetPoint("CENTER", 0, -5);
		else
			tab.text:SetPoint("CENTER", 0, -3);
		end
	end
end

function AchievementFrame_ToggleView()
	-- summary and scrollframes get toggled in their respective OnShow
	if ( IN_GUILD_VIEW ) then
		IN_GUILD_VIEW = nil;
		TEXTURES_OFFSET = 0;
		-- container backgrounds
		AchievementFrameAchievementsBackground:SetTexCoord(0, 1, 0, 0.5);
		AchievementFrameSummaryBackground:SetTexCoord(0, 1, 0, 0.5);
		-- header
		AchievementFrameHeaderPoints:SetVertexColor(1, 1, 1);
		AchievementFrameHeaderTitle:SetText(ACHIEVEMENT_TITLE);
		local shield = AchievementFrameHeaderShield;
		shield:SetTexture("Interface\\AchievementFrame\\UI-Achievement-TinyShield");
		shield:SetTexCoord(0, 0.625, 0, 0.625);
		shield:SetHeight(20);
	else
		IN_GUILD_VIEW = true;
		TEXTURES_OFFSET = 0.5;
		-- container background
		AchievementFrameAchievementsBackground:SetTexCoord(0, 1, 0.5, 1);
		AchievementFrameSummaryBackground:SetTexCoord(0, 1, 0.5, 1);
		-- header
		AchievementFrameHeaderPoints:SetVertexColor(0, 1, 0);
		AchievementFrameHeaderTitle:SetText(GUILD_ACHIEVEMENTS_TITLE);
		local shield = AchievementFrameHeaderShield;
		shield:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
		shield:SetTexCoord(0.63281250, 0.67187500, 0.13085938, 0.16601563);
		shield:SetHeight(18);
		-- guild emblem
		local bkgR, bkgG, bkgB, borderR, borderG, borderB, emblemR, emblemG, emblemB, emblemFilename = GetGuildLogoInfo();
		if ( emblemFilename ) then
			AchievementFrameGuildEmblemLeft:SetTexture(emblemFilename);
			AchievementFrameGuildEmblemRight:SetTexture(emblemFilename);
			AchievementFrameGuildEmblemLeft:SetVertexColor(0.4, 0.2, 0, 0.5);
			AchievementFrameGuildEmblemRight:SetVertexColor(0.4, 0.2, 0, 0.5);
		end
	end
	AchievementFrameHeaderPoints:SetText(BreakUpLargeNumbers(GetTotalAchievementPoints(IN_GUILD_VIEW)));
end

function AchievementFrameBaseTab_OnClick (id)
	AchievementFrame_UpdateTabs(id);

	local isSummary = false;
	local swappedView = false;
	if ( id == 1 ) then
		if ( IN_GUILD_VIEW ) then
			AchievementFrame_ToggleView();
		end
		achievementFunctions = ACHIEVEMENT_FUNCTIONS;
		AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES); -- This needs to happen before AchievementFrame_ShowSubFrame (fix for bug 157885)
		if ( achievementFunctions.selectedCategory == "summary" ) then
			isSummary = true;
			AchievementFrame_ShowSubFrame(AchievementFrameSummary);
		else
			AchievementFrame_ShowSubFrame(AchievementFrameAchievements);
		end
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-AchievementWatermark");
		AchievementFrameCategoriesBG:SetTexCoord(0, 0.5, 0, 1);
		AchievementFrameGuildEmblemLeft:Hide();
		AchievementFrameGuildEmblemRight:Hide();
	elseif ( id == 2) then
		if ( not IN_GUILD_VIEW ) then
			AchievementFrame_ToggleView();
		end
		achievementFunctions = GUILD_ACHIEVEMENT_FUNCTIONS;
		AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES); -- This needs to happen before AchievementFrame_ShowSubFrame (fix for bug 157885)
		if ( achievementFunctions.selectedCategory == "summary" ) then
			isSummary = true;
			AchievementFrame_ShowSubFrame(AchievementFrameSummary);
		else
			AchievementFrame_ShowSubFrame(AchievementFrameAchievements);
		end
		AchievementFrameWaterMark:SetTexture();
		AchievementFrameCategoriesBG:SetTexCoord(0.5, 1, 0, 1);
		AchievementFrameGuildEmblemLeft:Show();
		AchievementFrameGuildEmblemRight:Show();
	else
		achievementFunctions = STAT_FUNCTIONS;
		AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES); -- This needs to happen before AchievementFrame_ShowSubFrame (fix for bug 157885)
		if ( achievementFunctions.selectedCategory == "summary" ) then
			AchievementFrame_ShowSubFrame(AchievementFrameStats);
			achievementFunctions.selectedCategory = ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID;
			AchievementFrameStatsContainerScrollBar:SetValue(0);
		else
			AchievementFrame_ShowSubFrame(AchievementFrameStats);
		end
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-StatWatermark");
		AchievementFrameCategoriesBG:SetTexCoord(0, 0.5, 0, 1);
		AchievementFrameGuildEmblemLeft:Hide();
		AchievementFrameGuildEmblemRight:Hide();
	end

	AchievementFrameCategories_Update();

	if ( not isSummary ) then
		achievementFunctions.updateFunc();
	end

	SwitchAchievementSearchTab(id);
end

AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;

function AchievementFrameComparisonTab_OnClick (id)
	if ( IN_GUILD_VIEW ) then
		AchievementFrame_ToggleView();
		AchievementFrameGuildEmblemLeft:Hide();
		AchievementFrameGuildEmblemRight:Hide();
	end
	if ( id == 1 ) then
		achievementFunctions = COMPARISON_ACHIEVEMENT_FUNCTIONS;
		AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonContainer);
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-AchievementWatermark");
	elseif ( id == 2 ) then
		-- We don't have support for guild achievement comparison.  Just open up the non-comparison guild achievement tab.
		AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
		AchievementFrameTab_OnClick(2);
	elseif ( id == 3 ) then
		achievementFunctions = COMPARISON_STAT_FUNCTIONS;
		AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonStatsContainer);
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-StatWatermark");
	end
	AchievementFrameCategoriesBG:SetTexCoord(0, 0.5, 0, 1);
	AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES);
	AchievementFrameCategories_Update();
	AchievementFrame_UpdateTabs(id);

	achievementFunctions.updateFunc();
	SwitchAchievementSearchTab(id);
end

ACHIEVEMENTFRAME_SUBFRAMES = {
	"AchievementFrameSummary",
	"AchievementFrameAchievements",
	"AchievementFrameStats",
	"AchievementFrameComparison",
	"AchievementFrameComparisonContainer",
	"AchievementFrameComparisonStatsContainer"
};

function AchievementFrame_ShowSubFrame(...)
	local subFrame, show;
	for _, name in next, ACHIEVEMENTFRAME_SUBFRAMES  do
		subFrame = _G[name];
		show = false;
		for i=1, select("#", ...) do
			if ( subFrame ==  select(i, ...)) then
				show = true
			end
		end
		if ( show ) then
			-- force the OnShow to run if we need to swap views on the subFrame
			if ( subFrame.forceOnShow and subFrame.guildView ~= IN_GUILD_VIEW and subFrame:IsShown() ) then
				subFrame.forceOnShow();
			else
				subFrame:Show();
			end
		else
			subFrame:Hide();
		end
	end
end

-- [[ AchievementFrameCategories ]] --

function AchievementFrameCategories_OnLoad (self)
	self:SetBackdropBorderColor(ACHIEVEMENTUI_GOLDBORDER_R, ACHIEVEMENTUI_GOLDBORDER_G, ACHIEVEMENTUI_GOLDBORDER_B, ACHIEVEMENTUI_GOLDBORDER_A);
	self.buttons = {};
	self:RegisterEvent("ADDON_LOADED");
	self:SetScript("OnEvent", AchievementFrameCategories_OnEvent);
end

function AchievementFrameCategories_OnEvent (self, event, ...)
	if ( event == "ADDON_LOADED" ) then
		local addonName = ...;
		if ( addonName and addonName ~= "Blizzard_AchievementUI" ) then
			return;
		end

		AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES);

		AchievementFrameCategoriesContainerScrollBar.Show =
			function (self)
				ACHIEVEMENTUI_CATEGORIESWIDTH = 175;
				AchievementFrameCategories:SetWidth(175);
				AchievementFrameCategoriesContainer:GetScrollChild():SetWidth(175);
				AchievementFrameAchievements:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 22, 0);
				AchievementFrameStats:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 22, 0);
				AchievementFrameComparison:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 22, 0)
				AchievementFrameWaterMark:SetWidth(145);
				AchievementFrameWaterMark:SetTexCoord(0, 145/256, 0, 1);
				for _, button in next, AchievementFrameCategoriesContainer.buttons do
					AchievementFrameCategories_DisplayButton(button, button.element)
				end
				getmetatable(self).__index.Show(self);
			end

		AchievementFrameCategoriesContainerScrollBar.Hide =
			function (self)
				ACHIEVEMENTUI_CATEGORIESWIDTH = 197;
				AchievementFrameCategories:SetWidth(197);
				AchievementFrameCategoriesContainer:GetScrollChild():SetWidth(197);
				AchievementFrameAchievements:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 0, 0);
				AchievementFrameStats:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 0, 0);
				AchievementFrameComparison:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 0, 0)
				AchievementFrameWaterMark:SetWidth(167);
				AchievementFrameWaterMark:SetTexCoord(0, 167/256, 0, 1);
				for _, button in next, AchievementFrameCategoriesContainer.buttons do
					AchievementFrameCategories_DisplayButton(button, button.element);
				end
				getmetatable(self).__index.Hide(self);
			end

		AchievementFrameCategoriesContainerScrollBarBG:Show();
		AchievementFrameCategoriesContainer.update = AchievementFrameCategories_Update;
		HybridScrollFrame_CreateButtons(AchievementFrameCategoriesContainer, "AchievementCategoryTemplate", 0, 0, "TOP", "TOP", 0, 0, "TOP", "BOTTOM");
		AchievementFrameCategories_Update();
		self:UnregisterEvent(event)
	end
end

function AchievementFrameCategories_OnShow (self)
	AchievementFrameCategories_Update();
end

function AchievementFrameCategories_GetCategoryList (categories)
	local cats = achievementFunctions.categoryAccessor();

	for i in next, categories do
		categories[i] = nil;
	end
	if ( not achievementFunctions.noSummary ) then
		-- Insert the fake Summary category
		tinsert(categories, { ["id"] = "summary" });
	end

	for i, id in next, cats do
		local _, parent = GetCategoryInfo(id);
		if ( parent == -1 or parent == GUILD_CATEGORY_ID ) then
			tinsert(categories, { ["id"] = id });
		end
	end

	local _, parent;
	for i = #cats, 1, -1 do
		_, parent = GetCategoryInfo(cats[i]);
		for j, category in next, categories do
			if ( category.id == parent ) then
				category.parent = true;
				category.collapsed = true;
				tinsert(categories, j+1, { ["id"] = cats[i], ["parent"] = category.id, ["hidden"] = true});
			end
		end
	end
end

local displayCategories = {};
function AchievementFrameCategories_Update ()
	local scrollFrame = AchievementFrameCategoriesContainer

	local categories = ACHIEVEMENTUI_CATEGORIES;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	local displayCategories = displayCategories;

	for i in next, displayCategories do
		displayCategories[i] = nil;
	end

	local selection = achievementFunctions.selectedCategory;
	if ( selection == ACHIEVEMENT_COMPARISON_SUMMARY_ID or selection == ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID ) then
		selection = "summary";
	end

	local parent;
	if ( selection ) then
		for i, category in next, categories do
			if ( category.id == selection ) then
				parent = category.parent;
			end
		end
	end

	for i, category in next, categories do
		if ( not category.hidden ) then
			tinsert(displayCategories, category);
		elseif ( parent and category.id == parent ) then
			category.collapsed = false;
			tinsert(displayCategories, category);
		elseif ( parent and category.parent and category.parent == parent ) then
			category.hidden = false;
			tinsert(displayCategories, category);
		end
	end

	local numCategories = #displayCategories;
	local numButtons = #buttons;

	local totalHeight = numCategories * buttons[1]:GetHeight();
	local displayedHeight = 0;

	local element
	for i = 1, numButtons do
		element = displayCategories[i + offset];
		displayedHeight = displayedHeight + buttons[i]:GetHeight();
		if ( element ) then
			AchievementFrameCategories_DisplayButton(buttons[i], element);
			if ( selection and element.id == selection ) then
				buttons[i]:LockHighlight();
			else
				buttons[i]:UnlockHighlight();
			end
			buttons[i]:Show();
		else
			buttons[i].element = nil;
			buttons[i]:Hide();
		end
	end

	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);

	return displayCategories;
end

function AchievementFrameCategories_DisplayButton (button, element)
	if ( not element ) then
		button.element = nil;
		button:Hide();
		return;
	end

	button:Show();
	if ( type(element.parent) == "number" ) then
		button:SetWidth(ACHIEVEMENTUI_CATEGORIESWIDTH - 25);
		button.label:SetFontObject("GameFontHighlight");
		button.parentID = element.parent;
		button.background:SetVertexColor(0.6, 0.6, 0.6);
	else
		button:SetWidth(ACHIEVEMENTUI_CATEGORIESWIDTH - 10);
		button.label:SetFontObject("GameFontNormal");
		button.parentID = element.parent;
		button.background:SetVertexColor(1, 1, 1);
	end

	local categoryName, parentID, flags;
	local numAchievements, numCompleted;

	local id = element.id;

	-- kind of janky
	if ( id == "summary" ) then
		categoryName = ACHIEVEMENT_SUMMARY_CATEGORY;
		numAchievements, numCompleted = GetNumCompletedAchievements(IN_GUILD_VIEW);
	else
		categoryName, parentID, flags = GetCategoryInfo(id);
		numAchievements, numCompleted = AchievementFrame_GetCategoryTotalNumAchievements(id, true);
	end
	button.label:SetText(categoryName);
	button.categoryID = id;
	button.flags = flags;
	button.element = element;

	-- For the tooltip
	button.name = categoryName;
	if ( id == FEAT_OF_STRENGTH_ID ) then
		-- This is the feat of strength category since it's sorted to the end of the list
		button.text = FEAT_OF_STRENGTH_DESCRIPTION;
		button.showTooltipFunc = AchievementFrameCategory_FeatOfStrengthTooltip;
	elseif ( id == GUILD_FEAT_OF_STRENGTH_ID ) then
		button.text = GUILD_FEAT_OF_STRENGTH_DESCRIPTION;
		button.showTooltipFunc = AchievementFrameCategory_FeatOfStrengthTooltip;
	elseif ( AchievementFrame.selectedTab == 1 or AchievementFrame.selectedTab == 2 ) then
		button.text = nil;
		button.numAchievements = numAchievements;
		button.numCompleted = numCompleted;
		button.numCompletedText = numCompleted.."/"..numAchievements;
		button.showTooltipFunc = AchievementFrameCategory_StatusBarTooltip;
	else
		button.showTooltipFunc = nil;
	end
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
	local container = AchievementFrameCategoriesContainer;
	if ( not container:IsVisible() or not container.buttons ) then
		return;
	end

	for _, button in next, AchievementFrameCategoriesContainer.buttons do
		if ( button:IsMouseOver() and button.showTooltipFunc ) then
			button:showTooltipFunc();
			break;
		end
	end
end

function AchievementFrameCategories_SelectButton (button)
	local id = button.element.id;

	if ( type(button.element.parent) ~= "number" ) then
		-- Is top level category (can expand/contract)
		if ( button.isSelected and button.element.collapsed == false ) then
			button.element.collapsed = true;
			for i, category in next, ACHIEVEMENTUI_CATEGORIES do
				if ( category.parent == id ) then
					category.hidden = true;
				end
			end
		else
			for i, category in next, ACHIEVEMENTUI_CATEGORIES do
				if ( category.parent == id ) then
					category.hidden = false;
				elseif ( category.parent == true ) then
					category.collapsed = true;
				elseif ( category.parent ) then
					category.hidden = true;
				end
			end
			button.element.collapsed = false;
		end
	end

	local buttons = AchievementFrameCategoriesContainer.buttons;
	for _, button in next, buttons do
		button.isSelected = nil;
	end

	button.isSelected = true;

	if ( id == achievementFunctions.selectedCategory ) then
		-- If this category was selected already, bail after changing collapsed states
		return
	end

	--Intercept "summary" category
	if ( id == "summary" ) then
		if ( achievementFunctions == ACHIEVEMENT_FUNCTIONS or achievementFunctions == GUILD_ACHIEVEMENT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameSummary);
			achievementFunctions.selectedCategory = id;
			return;
		elseif (  achievementFunctions == STAT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameStats);
			achievementFunctions.selectedCategory = ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID;
			AchievementFrameStatsContainerScrollBar:SetValue(0);
		elseif ( achievementFunctions == COMPARISON_ACHIEVEMENT_FUNCTIONS ) then
			-- Put the summary stuff for comparison here, Derek!
			AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonContainer);
			achievementFunctions.selectedCategory = ACHIEVEMENT_COMPARISON_SUMMARY_ID;
			AchievementFrameComparisonContainerScrollBar:SetValue(0);
			AchievementFrameComparison_UpdateStatusBars(ACHIEVEMENT_COMPARISON_SUMMARY_ID);
		elseif ( achievementFunctions == COMPARISON_STAT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonStatsContainer);
			achievementFunctions.selectedCategory = ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID;
			AchievementFrameComparisonStatsContainerScrollBar:SetValue(0);
		end

	else
		if ( achievementFunctions == STAT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameStats);
		elseif ( achievementFunctions == ACHIEVEMENT_FUNCTIONS or achievementFunctions == GUILD_ACHIEVEMENT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameAchievements);
			if ( id == FEAT_OF_STRENGTH_ID or id == GUILD_FEAT_OF_STRENGTH_ID ) then
				AchievementFrameFilterDropDown:Hide();
				AchievementFrameHeaderLeftDDLInset:Hide();
			else
				AchievementFrameFilterDropDown:Show();
				AchievementFrameHeaderLeftDDLInset:Show();
			end
		elseif ( achievementFunctions == COMPARISON_ACHIEVEMENT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonContainer);
			AchievementFrameComparisonContainerScrollBar:SetValue(0);
			AchievementFrameComparison_UpdateStatusBars(id);
		else
			AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonStatsContainer);
			AchievementFrameComparisonStatsContainerScrollBar:SetValue(0);
		end
		achievementFunctions.selectedCategory = id;
	end

	if ( achievementFunctions.clearFunc ) then
		achievementFunctions.clearFunc();
	end
	AchievementFrameAchievementsContainerScrollBar:SetValue(0);
	achievementFunctions.updateFunc();
end

function AchievementFrameAchievements_OnShow()
	if ( AchievementFrameAchievements.guildView ~= IN_GUILD_VIEW ) then
		AchievementFrameAchievements_ToggleView();
	end
	if ( achievementFunctions.selectedCategory == FEAT_OF_STRENGTH_ID or achievementFunctions.selectedCategory == GUILD_FEAT_OF_STRENGTH_ID ) then
		AchievementFrameFilterDropDown:Hide();
		AchievementFrameHeaderLeftDDLInset:Hide();
	else
		AchievementFrameFilterDropDown:Show();
		AchievementFrameHeaderLeftDDLInset:Show();
	end
end

function AchievementFrameCategories_ClearSelection ()
	local buttons = AchievementFrameCategoriesContainer.buttons;
	for _, button in next, buttons do
		button.isSelected = nil;
		button:UnlockHighlight();
	end

	for i, category in next, ACHIEVEMENTUI_CATEGORIES do
		if ( category.parent == true ) then
			category.collapsed = true;
		elseif ( category.parent ) then
			category.hidden = true;
		end
	end
end

function AchievementFrameComparison_UpdateStatusBars (id)
	local numAchievements, numCompleted = GetCategoryNumAchievements(id);
	local name = GetCategoryInfo(id);

	if ( id == ACHIEVEMENT_COMPARISON_SUMMARY_ID ) then
		name = ACHIEVEMENT_SUMMARY_CATEGORY;
	end

	local statusBar = AchievementFrameComparisonSummaryPlayerStatusBar;
	statusBar:SetMinMaxValues(0, numAchievements);
	statusBar:SetValue(numCompleted);
	statusBar.title:SetText(string.format(ACHIEVEMENTS_COMPLETED_CATEGORY, name));
	statusBar.text:SetText(numCompleted.."/"..numAchievements);

	local friendCompleted = GetComparisonCategoryNumAchievements(id);

	statusBar = AchievementFrameComparisonSummaryFriendStatusBar;
	statusBar:SetMinMaxValues(0, numAchievements);
	statusBar:SetValue(friendCompleted);
	statusBar.text:SetText(friendCompleted.."/"..numAchievements);
end

-- [[ AchievementCategoryButton ]] --

function AchievementCategoryButton_OnLoad (button)
	button:EnableMouse(true);
	button:EnableMouseWheel(true);
	AchievementCategoryButton_Localize(button);
end

function AchievementCategoryButton_OnClick (button)
	AchievementFrameCategories_SelectButton(button);
	AchievementFrameCategories_Update();
end

-- [[ AchievementFrameAchievements ]] --

function AchievementFrameAchievements_OnLoad (self)
	AchievementFrameAchievementsContainerScrollBar.Show =
		function (self)
			AchievementFrameAchievements:SetWidth(504);
			for _, button in next, AchievementFrameAchievementsContainer.buttons do
				button:SetWidth(496);
			end
			getmetatable(self).__index.Show(self);
		end

	AchievementFrameAchievementsContainerScrollBar.Hide =
		function (self)
			AchievementFrameAchievements:SetWidth(530);
			for _, button in next, AchievementFrameAchievementsContainer.buttons do
				button:SetWidth(522);
			end
			getmetatable(self).__index.Hide(self);
		end

	self:RegisterEvent("ADDON_LOADED");
	AchievementFrameAchievementsContainerScrollBarBG:Show();
	AchievementFrameAchievementsContainer.update = AchievementFrameAchievements_Update;
	HybridScrollFrame_CreateButtons(AchievementFrameAchievementsContainer, "AchievementTemplate", 0, -2);
end

function AchievementFrameAchievements_OnEvent (self, event, ...)
	if (IsKioskModeEnabled()) then
		return;
	end
	if ( event == "ADDON_LOADED" ) then
		self:RegisterEvent("ACHIEVEMENT_EARNED");
		self:RegisterEvent("CRITERIA_UPDATE");
		self:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED");
		self:RegisterEvent("RECEIVED_ACHIEVEMENT_MEMBER_LIST");
		self:RegisterEvent("ACHIEVEMENT_SEARCH_UPDATED");

		updateTrackedAchievements(GetTrackedAchievements());
	elseif ( event == "ACHIEVEMENT_EARNED" ) then
		local achievementID = ...;
		AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES);
		AchievementFrameCategories_Update();
		AchievementFrameCategories_UpdateTooltip();
		-- This has to happen before AchievementFrameAchievements_ForceUpdate() in order to achieve the behavior we want, since it clears the selection for progressive achievements.
		local selection = AchievementFrameAchievements.selection;
		AchievementFrameAchievements_ForceUpdate();
		if ( AchievementFrameAchievementsContainer:IsVisible() and selection == achievementID ) then
			AchievementFrame_SelectAchievement(selection, true);
		end
		AchievementFrameHeaderPoints:SetText(BreakUpLargeNumbers(GetTotalAchievementPoints(IN_GUILD_VIEW)));

	elseif ( event == "CRITERIA_UPDATE" ) then
		if ( AchievementFrameAchievements.selection ) then
			local id = AchievementFrameAchievementsObjectives.id;
			local button = AchievementFrameAchievementsObjectives:GetParent();
			AchievementFrameAchievementsObjectives.id = nil;
			if ( self:IsVisible() ) then
				AchievementButton_DisplayObjectives(button, id, button.completed);
				AchievementFrameAchievements_Update();
			end
		else
			AchievementFrameAchievementsObjectives.id = nil; -- Force redraw
		end
	elseif ( event == "TRACKED_ACHIEVEMENT_LIST_CHANGED" ) then
		for k, v in next, trackedAchievements do
			trackedAchievements[k] = nil;
		end

		updateTrackedAchievements(GetTrackedAchievements());
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
		AchievementFrame.searchBox.fullSearchFinished = true;
		AchievementFrame_UpdateSearch(self);
	end

	if ( not AchievementMicroButton:IsShown() ) then
		AchievementMicroButton_Update();
	end
end

function AchievementFrameAchievementsBackdrop_OnLoad (self)
	self:SetBackdropBorderColor(ACHIEVEMENTUI_GOLDBORDER_R, ACHIEVEMENTUI_GOLDBORDER_G, ACHIEVEMENTUI_GOLDBORDER_B, ACHIEVEMENTUI_GOLDBORDER_A);
	self:SetFrameLevel(self:GetFrameLevel()+1);
end

function AchievementFrameAchievements_Update ()
	local category = achievementFunctions.selectedCategory;
	if ( category == "summary" ) then
		return;
	end
	local scrollFrame = AchievementFrameAchievementsContainer

	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numAchievements, numCompleted, completedOffset = ACHIEVEMENTUI_SELECTEDFILTER(category);
	local numButtons = #buttons;

	-- If the current category is feats of strength and there are no entries then show the explanation text
	if ( AchievementFrame_IsFeatOfStrength() and numAchievements == 0 ) then
		if ( AchievementFrame.selectedTab == 1 ) then
			AchievementFrameAchievementsFeatOfStrengthText:SetText(FEAT_OF_STRENGTH_DESCRIPTION);
		else
			AchievementFrameAchievementsFeatOfStrengthText:SetText(GUILD_FEAT_OF_STRENGTH_DESCRIPTION);
		end
		AchievementFrameAchievementsFeatOfStrengthText:Show();
	else
		AchievementFrameAchievementsFeatOfStrengthText:Hide();
	end

	local selection = AchievementFrameAchievements.selection;
	if ( selection ) then
		AchievementButton_ResetObjectives();
	end

	local extraHeight = scrollFrame.largeButtonHeight or ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT

	local achievementIndex;
	local displayedHeight = 0;
	for i = 1, numButtons do
		achievementIndex = i + offset + completedOffset;
		if ( achievementIndex > numAchievements + completedOffset ) then
			buttons[i]:Hide();
		else
			AchievementButton_DisplayAchievement(buttons[i], category, achievementIndex, selection);
			displayedHeight = displayedHeight + buttons[i]:GetHeight();
		end
	end

	local totalHeight = numAchievements * ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT;
	totalHeight = totalHeight + (extraHeight - ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT);

	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);

	if ( selection ) then
		AchievementFrameAchievements.selection = selection;
	else
		HybridScrollFrame_CollapseButton(scrollFrame);
	end
end

function AchievementFrameAchievements_ForceUpdate ()
	if ( AchievementFrameAchievements.selection ) then
		local nextID = GetNextAchievement(AchievementFrameAchievements.selection);
		local id, _, _, completed = GetAchievementInfo(AchievementFrameAchievements.selection);
		if ( nextID and completed ) then
			AchievementFrameAchievements.selection = nil;
		end
	end
	AchievementFrameAchievementsObjectives:Hide();
	AchievementFrameAchievementsObjectives.id = nil;

	local buttons = AchievementFrameAchievementsContainer.buttons;
	for i, button in next, buttons do
		button.id = nil;
	end

	AchievementFrameAchievements_Update();
end

function AchievementFrameAchievements_ClearSelection ()
	AchievementButton_ResetObjectives();
	for _, button in next, AchievementFrameAchievementsContainer.buttons do
		button:Collapse();
		if ( not button:IsMouseOver() ) then
			button.highlight:Hide();
		end
		button.selected = nil;
		if ( not button.tracked:GetChecked() ) then
			button.tracked:Hide();
		end
		button.description:Show();
		button.hiddenDescription:Hide();
	end

	AchievementFrameAchievements.selection = nil;
end

function AchievementFrameAchievements_SetupButton(button)
	local name = button:GetName();
	-- reset button info to get proper saturation/desaturation
	button.completed = nil;
	button.id = nil;
	-- title
	button.titleBar:SetAlpha(0.8);
	-- icon frame
	button.icon.frame:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame");
	button.icon.frame:SetTexCoord(0, 0.5625, 0, 0.5625);
	button.icon.frame:SetPoint("CENTER", -1, 2);
	-- tsunami
	local tsunami = _G[name.."BottomTsunami1"];
	tsunami:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
	tsunami:SetTexCoord(0, 0.72265, 0.51953125, 0.58203125);
	tsunami:SetAlpha(0.35);
	local tsunami = _G[name.."TopTsunami1"];
	tsunami:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
	tsunami:SetTexCoord(0.72265, 0, 0.58203125, 0.51953125);
	tsunami:SetAlpha(0.3);
	-- glow
	button.glow:SetTexCoord(0, 1, 0.00390625, 0.25390625);
end

function AchievementFrameAchievements_ToggleView()
	if ( AchievementFrameAchievements.guildView ) then
		AchievementFrameAchievements.guildView = nil;
		for _, button in next, AchievementFrameAchievementsContainer.buttons do
			AchievementFrameAchievements_SetupButton(button);
		end
	else
		AchievementFrameAchievements.guildView = true;
		for _, button in next, AchievementFrameAchievementsContainer.buttons do
			local name = button:GetName();
			-- reset button info to get proper saturation/desaturation
			button.completed = nil;
			button.id = nil;
			-- title
			button.titleBar:SetAlpha(1);
			-- icon frame
			button.icon.frame:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
			button.icon.frame:SetTexCoord(0.25976563, 0.40820313, 0.50000000, 0.64453125);
			button.icon.frame:SetPoint("CENTER", 2, 2);
			-- tsunami
			local tsunami = _G[name.."BottomTsunami1"];
			tsunami:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			tsunami:SetTexCoord(0, 0.72265, 0.58984375, 0.65234375);
			tsunami:SetAlpha(0.2);
			local tsunami = _G[name.."TopTsunami1"];
			tsunami:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			tsunami:SetTexCoord(0.72265, 0, 0.65234375, 0.58984375);
			tsunami:SetAlpha(0.15);
			-- glow
			button.glow:SetTexCoord(0, 1, 0.26171875, 0.51171875);
		end
	end
	AchievementFrameAchievementsContainerScrollBar:SetValue(0);
	AchievementFrameAchievements_Update();
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
	self.icon:SetTexCoord(.5, 1, TEXTURES_OFFSET, TEXTURES_OFFSET + 0.5);
end

function AchievementShield_Saturate (self)
	self.icon:SetTexCoord(0, .5, TEXTURES_OFFSET, TEXTURES_OFFSET + 0.5);
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

function AchievementButton_UpdatePlusMinusTexture (button)
	local id = button.id;
	if ( not id ) then
		return; -- This happens when we create buttons
	end

	local display = false;
	if ( GetAchievementNumCriteria(id) ~= 0 ) then
		display = true;
	elseif ( button.completed and GetPreviousAchievement(id) ) then
		display = true;
	elseif ( not button.completed and GetAchievementGuildRep(id) ) then
		display = true;
	end

	if ( display ) then
		button.plusMinus:Show();
		if ( button.collapsed and button.saturatedStyle ) then
			button.plusMinus:SetTexCoord(0, .5, TEXTURES_OFFSET, TEXTURES_OFFSET + 0.25);
		elseif ( button.collapsed ) then
			button.plusMinus:SetTexCoord(.5, 1, TEXTURES_OFFSET, TEXTURES_OFFSET + 0.25);
		elseif ( button.saturatedStyle ) then
			button.plusMinus:SetTexCoord(0, .5, TEXTURES_OFFSET + 0.25, TEXTURES_OFFSET + 0.50);
		else
			button.plusMinus:SetTexCoord(.5, 1, TEXTURES_OFFSET + 0.25, TEXTURES_OFFSET + 0.50);
		end
	else
		button.plusMinus:Hide();
	end
end

function AchievementButton_Collapse (self)
	if ( self.collapsed ) then
		return;
	end

	self.collapsed = true;
	AchievementButton_UpdatePlusMinusTexture(self);
	self:SetHeight(ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT);
	self.background:SetTexCoord(0, 1, 1-(ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT / 256), 1);
	if ( not self.tracked:GetChecked() ) then
		self.tracked:Hide();
	end
	self.tabard:Hide();
	self.guildCornerL:Hide();
	self.guildCornerR:Hide();
end

function AchievementButton_Expand (self, height)
	if ( not self.collapsed and self:GetHeight() == height ) then
		return;
	end

	self.collapsed = nil;
	AchievementButton_UpdatePlusMinusTexture(self);
	if ( IN_GUILD_VIEW ) then
		if ( height < GUILDACHIEVEMENTBUTTON_MINHEIGHT ) then
			height = GUILDACHIEVEMENTBUTTON_MINHEIGHT;
		end
		if ( self.completed ) then
			self.tabard:Show();
			self.shield:SetFrameLevel(self.tabard:GetFrameLevel() + 1);
			SetLargeGuildTabardTextures("player", self.tabard.emblem, self.tabard.background, self.tabard.border);
		end
		self.guildCornerL:Show();
		self.guildCornerR:Show();
	end
	self:SetHeight(height);
	self.background:SetTexCoord(0, 1, max(0, 1-(height / 256)), 1);
end

function AchievementButton_Saturate (self)
	if ( IN_GUILD_VIEW ) then
		self.background:SetTexture("Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal");
		self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.titleBar:SetTexCoord(0, 1, 0.83203125, 0.91015625);
		self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
		self.shield.points:SetVertexColor(0, 1, 0);
		self.saturatedStyle = "guild";
	else
		self.background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
		if ( self.accountWide ) then
			self.titleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
			self.titleBar:SetTexCoord(0, 1, 0, 0.375);
			self:SetBackdropBorderColor(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B, ACHIEVEMENTUI_BLUEBORDER_A);
			self.saturatedStyle = "account";
		else
			self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			self.titleBar:SetTexCoord(0, 1, 0.66015625, 0.73828125);
			self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
			self.saturatedStyle = "normal";
		end
		self.shield.points:SetVertexColor(1, 1, 1);
	end
	self.glow:SetVertexColor(1.0, 1.0, 1.0);
	self.icon:Saturate();
	self.shield:Saturate();
	self.reward:SetVertexColor(1, .82, 0);
	self.label:SetVertexColor(1, 1, 1);
	self.description:SetTextColor(0, 0, 0, 1);
	self.description:SetShadowOffset(0, 0);
	AchievementButton_UpdatePlusMinusTexture(self);
end

function AchievementButton_Desaturate (self)
	self.saturatedStyle = nil;
	if ( IN_GUILD_VIEW ) then
		self.background:SetTexture("Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal-Desaturated");
		self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.titleBar:SetTexCoord(0, 1, 0.74609375, 0.82421875);
	else
		self.background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
		if ( self.accountWide ) then
			self.titleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
			self.titleBar:SetTexCoord(0, 1, 0.40625, 0.78125);
		else
			self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			self.titleBar:SetTexCoord(0, 1, 0.91796875, 0.99609375);
		end
	end
	self.glow:SetVertexColor(.22, .17, .13);
	self.icon:Desaturate();
	self.shield:Desaturate();
	self.shield.points:SetVertexColor(.65, .65, .65);
	self.reward:SetVertexColor(.8, .8, .8);
	self.label:SetVertexColor(.65, .65, .65);
	self.description:SetTextColor(1, 1, 1, 1);
	self.description:SetShadowOffset(1, -1);
	AchievementButton_UpdatePlusMinusTexture(self);
	self:SetBackdropBorderColor(.5, .5, .5);
end

function AchievementButton_OnLoad (self)
	self.dateCompleted = self.shield.dateCompleted;
	if ( not ACHIEVEMENTUI_FONTHEIGHT ) then
		local _, fontHeight = self.description:GetFont();
		ACHIEVEMENTUI_FONTHEIGHT = fontHeight;
	end
	self.description:SetHeight(ACHIEVEMENTUI_FONTHEIGHT * ACHIEVEMENTUI_MAX_LINES_COLLAPSED);
	self.description:SetWidth(ACHIEVEMENTUI_MAXCONTENTWIDTH);
	self.hiddenDescription:SetWidth(ACHIEVEMENTUI_MAXCONTENTWIDTH);

	self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
	self.Collapse = AchievementButton_Collapse;
	self.Expand = AchievementButton_Expand;
	self.Saturate = AchievementButton_Saturate;
	self.Desaturate = AchievementButton_Desaturate;

	self:Collapse();
end

function AchievementButton_OnClick (self, button, down, ignoreModifiers)
	if(IsModifiedClick() and not ignoreModifiers) then
		local handled = nil;
		if ( IsModifiedClick("CHATLINK") ) then
			local achievementLink = GetAchievementLink(self.id);
			if ( achievementLink ) then
				handled = ChatEdit_InsertLink(achievementLink);
				if ( not handled and SocialPostFrame and Social_IsShown() ) then
					Social_InsertLink(achievementLink);
					handled = true;
				end
			end
		end
		if ( not handled and IsModifiedClick("QUESTWATCHTOGGLE") ) then
			AchievementButton_ToggleTracking(self.id);
		end
		return;
	end

	if ( self.selected ) then
		if ( not self:IsMouseOver() ) then
			self.highlight:Hide();
		end
		AchievementFrameAchievements_ClearSelection()
		HybridScrollFrame_CollapseButton(AchievementFrameAchievementsContainer);
		AchievementFrameAchievements_Update();
		return;
	end
	AchievementFrameAchievements_ClearSelection()
	AchievementFrameAchievements_SelectButton(self);
	AchievementButton_DisplayAchievement(self, achievementFunctions.selectedCategory, self.index, self.id);
	HybridScrollFrame_ExpandButton(AchievementFrameAchievementsContainer, ((self.index - 1) * ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT), self:GetHeight());
	AchievementFrameAchievements_Update();
	if ( not ignoreModifiers ) then
		AchievementFrameAchievements_AdjustSelection();
	end
end

function AchievementButton_ToggleTracking (id)
	if ( trackedAchievements[id] ) then
		RemoveTrackedAchievement(id);
		AchievementFrameAchievements_ForceUpdate();
		return;
	end

	local count = GetNumTrackedAchievements();

	if ( count >= MAX_TRACKED_ACHIEVEMENTS ) then
		UIErrorsFrame:AddMessage(format(ACHIEVEMENT_WATCH_TOO_MANY, MAX_TRACKED_ACHIEVEMENTS), 1.0, 0.1, 0.1, 1.0);
		return;
	end

	local _, _, _, completed, _, _, _, _, _, _, _, isGuild, wasEarnedByMe = GetAchievementInfo(id)
	if ( (completed and isGuild) or wasEarnedByMe ) then
		UIErrorsFrame:AddMessage(ERR_ACHIEVEMENT_WATCH_COMPLETED, 1.0, 0.1, 0.1, 1.0);
		return;
	end

	AddTrackedAchievement(id);
	AchievementFrameAchievements_ForceUpdate();

	return true;
end

function AchievementButton_DisplayAchievement (button, category, achievement, selectionID, renderOffScreen)
	local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(category, achievement);

	if ( not id ) then
		button:Hide();
		return;
	else
		button:Show();
	end

	button.index = achievement;
	button.element = true;

	if ( button.id ~= id ) then
		local saturatedStyle;
		if ( bit.band(flags, ACHIEVEMENT_FLAGS_ACCOUNT) == ACHIEVEMENT_FLAGS_ACCOUNT ) then
			button.accountWide = true;
			saturatedStyle = "account";
		else
			button.accountWide = nil;
			if ( IN_GUILD_VIEW ) then
				saturatedStyle = "guild";
			else
				saturatedStyle = "normal";
			end
		end
		button.id = id;
		button.label:SetWidth(ACHIEVEMENTBUTTON_LABELWIDTH);
		button.label:SetText(name)

		if ( GetPreviousAchievement(id) ) then
			-- If this is a progressive achievement, show the total score.
			AchievementShield_SetPoints(AchievementButton_GetProgressivePoints(id), button.shield.points, AchievementPointsFont, AchievementPointsFontSmall);
		else
			AchievementShield_SetPoints(points, button.shield.points, AchievementPointsFont, AchievementPointsFontSmall);
		end

		if ( points > 0 ) then
			button.shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
		else
			button.shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
		end

		if ( isGuild ) then
			button.shield.points:Show();
			button.shield.wasEarnedByMe = nil;
			button.shield.earnedBy = nil;
		else
			button.shield.wasEarnedByMe = not (completed and not wasEarnedByMe);
			button.shield.earnedBy = earnedBy;
		end

		button.shield.id = id;
		button.description:SetText(description);
		button.hiddenDescription:SetText(description);
		button.numLines = ceil(button.hiddenDescription:GetHeight() / ACHIEVEMENTUI_FONTHEIGHT);
		button.icon.texture:SetTexture(icon);
		if ( completed or wasEarnedByMe ) then
			button.completed = true;
			button.dateCompleted:SetText(FormatShortDate(day, month, year));
			button.dateCompleted:Show();
			if ( button.saturatedStyle ~= saturatedStyle ) then
				button:Saturate();
			end
		else
			button.completed = nil;
			button.dateCompleted:Hide();
			button:Desaturate();
		end

		if ( rewardText == "" ) then
			button.reward:Hide();
			button.rewardBackground:Hide();
		else
			button.reward:SetText(rewardText);
			button.reward:Show();
			button.rewardBackground:Show();
			if ( button.completed ) then
				button.rewardBackground:SetVertexColor(1, 1, 1);
			else
				button.rewardBackground:SetVertexColor(0.35, 0.35, 0.35);
			end
		end

		if ( IsTrackedAchievement(id) ) then
			button.check:Show();
			button.label:SetWidth(button.label:GetStringWidth() + 4); -- This +4 here is to fudge around any string width issues that arize from resizing a string set to its string width. See bug 144418 for an example.
			button.tracked:SetChecked(true);
			button.tracked:Show();
		else
			button.check:Hide();
			button.tracked:SetChecked(false);
			button.tracked:Hide();
		end

		AchievementButton_UpdatePlusMinusTexture(button);
	end

	if ( id == selectionID ) then
		local achievements = AchievementFrameAchievements;

		achievements.selection = button.id;
		achievements.selectionIndex = button.index;
		button.selected = true;
		button.highlight:Show();
		local height = AchievementButton_DisplayObjectives(button, button.id, button.completed, renderOffScreen);
		if ( height == ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT ) then
			button:Collapse();
		else
			button:Expand(height);
		end
		if ( not completed or (not wasEarnedByMe and not isGuild) ) then
			button.tracked:Show();
		end
	elseif ( button.selected ) then
		button.selected = nil;
		if ( not button:IsMouseOver() ) then
			button.highlight:Hide();
		end
		button:Collapse();
		button.description:Show();
		button.hiddenDescription:Hide();
	end

	return id;
end

function AchievementFrameAchievements_SelectButton (button)
	local achievements = AchievementFrameAchievements;

	achievements.selection = button.id;
	achievements.selectionIndex = button.index;
	button.selected = true;


	SetFocusedAchievement(button.id);
end

function AchievementButton_ResetObjectives ()
	AchievementFrameAchievementsObjectives:Hide();
end

function AchievementButton_DisplayObjectives (button, id, completed, renderOffScreen)
	local objectives = AchievementFrameAchievementsObjectives;
	if (renderOffScreen) then
		objectives = AchievementFrameAchievementsObjectivesOffScreen;
	end
	local topAnchor = button.hiddenDescription;
	objectives:ClearAllPoints();
	objectives:SetParent(button);
	objectives:Show();
	objectives.completed = completed;
	local height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT;
	if ( objectives.id == id and not renderOffScreen ) then
		local ACHIEVEMENTMODE_CRITERIA = 1;
		if ( objectives.mode == ACHIEVEMENTMODE_CRITERIA ) then
			if ( objectives:GetHeight() > 0 ) then
				objectives:SetPoint("TOP", topAnchor, "BOTTOM", 0, -8);
				objectives:SetPoint("LEFT", "$parentIcon", "RIGHT", -5, 0);
				objectives:SetPoint("RIGHT", "$parentShield", "LEFT", -10, 0);
			end
		else
			objectives:SetPoint("TOP", topAnchor, "BOTTOM", 0, -8);
		end
	elseif ( completed and GetPreviousAchievement(id) ) then
		objectives:SetHeight(0);
		AchievementButton_ResetCriteria(renderOffScreen);
		AchievementButton_ResetProgressBars(renderOffScreen);
		AchievementButton_ResetMiniAchievements(renderOffScreen);
		AchievementButton_ResetMetas(renderOffScreen);
		-- Don't show previous achievements when we render this offscreeen
		if ( not renderOffScreen ) then
			AchievementObjectives_DisplayProgressiveAchievement(objectives, id);
		end
		objectives:SetPoint("TOP", topAnchor, "BOTTOM", 0, -8);
	else
		objectives:SetHeight(0);
		AchievementButton_ResetCriteria(renderOffScreen);
		AchievementButton_ResetProgressBars(renderOffScreen);
		AchievementButton_ResetMiniAchievements(renderOffScreen);
		AchievementButton_ResetMetas(renderOffScreen);
		AchievementObjectives_DisplayCriteria(objectives, id, renderOffScreen);
		if ( objectives:GetHeight() > 0 ) then
			objectives:SetPoint("TOP", topAnchor, "BOTTOM", 0, -8);
			objectives:SetPoint("LEFT", "$parentIcon", "RIGHT", -5, -25);
			objectives:SetPoint("RIGHT", "$parentShield", "LEFT", -10, 0);
		end
	end
	height = height + objectives:GetHeight();

	if ( height ~= ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT or button.numLines > ACHIEVEMENTUI_MAX_LINES_COLLAPSED ) then
		button.hiddenDescription:Show();
		button.description:Hide();
		local descriptionHeight = button.hiddenDescription:GetHeight();
		height = height + descriptionHeight - ACHIEVEMENTBUTTON_DESCRIPTIONHEIGHT;
		if ( button.reward:IsShown() ) then
			height = height + 4;
		end
	end

	-- Don't cache if we are rendering offscreen
	if (not renderOffScreen) then
		objectives.id = id;
	end
	return height;
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

local criteriaTable = {}
local criteriaTableOffScreen = {};

function AchievementButton_ResetCriteria (renderOffScreen)
	if (renderOffScreen) then
		AchievementFrameAchievementsObjectivesOffScreen.repCriteria:Hide();
		AchievementButton_ResetTable(criteriaTableOffScreen);
	else
		AchievementFrameAchievementsObjectives.repCriteria:Hide();
		AchievementButton_ResetTable(criteriaTable);
	end
end

function AchievementButton_GetCriteria (index, renderOffScreen)
	local criTable = criteriaTable;
	local offscreenName = "";
	if (renderOffScreen) then
		criTable = criteriaTableOffScreen;
		offscreenName = "OffScreen";
	end

	if ( criTable[index] ) then
		return criTable[index];
	end

	local frame = CreateFrame("FRAME", "AchievementFrameCriteria" .. offscreenName .. index, AchievementFrameAchievements, "AchievementCriteriaTemplate");
	AchievementFrame_LocalizeCriteria(frame);
	criTable[index] = frame;

	return frame;
end

-- The smallest table in WoW.
local miniTable = {}

function AchievementButton_ResetMiniAchievements (renderOffScreen)
	-- We don't render mini achievements offscreen, so don't reset it if renderOffScreen is true
	if (not renderOffScreen) then
		AchievementButton_ResetTable(miniTable);
	end
end

function AchievementButton_GetMiniAchievement (index)
	local miniTable = miniTable;
	if ( miniTable[index] ) then
		return miniTable[index];
	end

	local frame = CreateFrame("FRAME", "AchievementFrameMiniAchievement" .. index, AchievementFrameAchievements, "MiniAchievementTemplate");
	AchievementButton_LocalizeMiniAchievement(frame);
	miniTable[index] = frame;

	return frame;
end

local progressBarTable = {};
local progressBarTableOffScreen = {};

function AchievementButton_ResetProgressBars (renderOffScreen)
	if (renderOffScreen) then
		AchievementButton_ResetTable(progressBarTableOffScreen);
	else
		AchievementButton_ResetTable(progressBarTable);
	end
end

function AchievementButton_GetProgressBar (index, renderOffScreen)
	local pgTable = progressBarTable;
	local offscreenName = "";
	if (renderOffScreen) then
		pgTable = progressBarTableOffScreen;
		offscreenName = "OffScreen";
	end
	if ( pgTable[index] ) then
		return pgTable[index];
	end

	local frame = CreateFrame("STATUSBAR", "AchievementFrameProgressBar" .. offscreenName .. index, AchievementFrameAchievements, "AchievementProgressBarTemplate");
	AchievementButton_LocalizeProgressBar(frame);
	pgTable[index] = frame;

	return frame;
end

local metaCriteriaTable = {};
local metaCriteriaTableOffScreen = {};

function AchievementButton_ResetMetas (renderOffScreen)
	if (renderOffScreen) then
		AchievementButton_ResetTable(metaCriteriaTableOffScreen);
	else
		AchievementButton_ResetTable(metaCriteriaTable);
	end
end

function AchievementButton_GetMeta (index, renderOffScreen)
	local mcTable = metaCriteriaTable;
	local offscreenName = "";
	if (renderOffScreen) then
		mcTable = metaCriteriaTableOffScreen;
		offscreenName = "OffScreen";
	end
	if ( not mcTable[index] ) then
		local frame = CreateFrame("BUTTON", "AchievementFrameMeta" .. offscreenName .. index, AchievementFrameAchievements, "MetaCriteriaTemplate");
		AchievementButton_LocalizeMetaAchievement(frame);
		mcTable[index] = frame;
	end

	if ( mcTable[index].guildView ~= IN_GUILD_VIEW ) then
		AchievementButton_ToggleMetaView(mcTable[index]);
	end
	return mcTable[index];
end

function AchievementButton_ToggleMetaView(frame)
	if ( IN_GUILD_VIEW ) then
		frame.border:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
		frame.border:SetTexCoord(0.89062500, 0.97070313, 0.00195313, 0.08203125);
	else
		frame.border:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Progressive-IconBorder");
		frame.border:SetTexCoord(0, 0.65625, 0, 0.65625);
	end
	frame.guildView = IN_GUILD_VIEW;
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
		local miniAchievement = AchievementButton_GetMiniAchievement(index);

		miniAchievement:Show();
		miniAchievement:SetParent(objectivesFrame);
		miniAchievement.icon:SetTexture(iconpath);
		if ( index == 1 ) then
			miniAchievement:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", -4, -4);
		elseif ( mod(index, 6) == 1 ) then
			miniAchievement:SetPoint("TOPLEFT", miniTable[index - 6], "BOTTOMLEFT", 0, -8);
		else
			miniAchievement:SetPoint("TOPLEFT", miniTable[index-1], "TOPRIGHT", 4, 0);
		end

		if ( points > 0 ) then
			miniAchievement.points:SetText(points);
			miniAchievement.points:Show();
			miniAchievement.shield:SetTexture([[Interface\AchievementFrame\UI-Achievement-Progressive-Shield]]);
		else
			miniAchievement.points:Hide();
			miniAchievement.shield:SetTexture([[Interface\AchievementFrame\UI-Achievement-Progressive-Shield-NoPoints]]);
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
		AchievementFrameAchievementsContainerScrollBar:SetValue(0);
		AchievementFrameAchievements_ForceUpdate();
		AchievementFrameFilterDropDown.value = value;
	end
end

function AchievementObjectives_DisplayCriteria (objectivesFrame, id, renderOffScreen)
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
			objectivesFrame.repCriteria:SetFormattedText(ACHIEVEMENT_REQUIRES_GUILD_REPUTATION, factionStandingtext);
			if ( hasRep ) then
				objectivesFrame.repCriteria:SetTextColor(0, 1, 0);
			else
				objectivesFrame.repCriteria:SetTextColor(1, 0, 0);
			end
			objectivesFrame.repCriteria:Show();
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
		local criteria = AchievementButton_GetCriteria(1, renderOffScreen);
		criteria.name:SetText("- ");
		objectivesFrame.textCheckWidth = criteria.name:GetStringWidth();
	end

	local frameLevel = objectivesFrame:GetFrameLevel() + 1;

	-- Why textStrings? You try naming anything just "string" and see how happy you are.
	local textStrings, progressBars, metas = 0, 0, 0;
	local firstMetaCriteria;

	local maxCriteriaWidth = 0;
	local yPos;
	for i = 1, numCriteria do
		local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(id, i);

		if ( criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID ) then
			metas = metas + 1;
			local metaCriteria = AchievementButton_GetMeta(metas, renderOffScreen);
			metaCriteria:ClearAllPoints();

			if ( metas == 1 ) then
				-- this will be anchored below, we need to know how many text criteria there are
				firstMetaCriteria = metaCriteria;
				numMetaRows = numMetaRows + 1;
			elseif ( math.fmod(metas, 2) == 0 ) then
				local anchorMeta = AchievementButton_GetMeta(metas-1, renderOffScreen);
				metaCriteria:SetPoint("LEFT", anchorMeta, "RIGHT", 35, 0);
			else
				local anchorMeta = AchievementButton_GetMeta(metas-2, renderOffScreen);
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
			metaCriteria.label:SetText(achievementName);
			metaCriteria.icon:SetTexture(iconpath);

			-- have to check if criteria is completed here, can't just check if achievement is completed.
			-- This is because the criteria could have modifiers on it that prevent completion even though the achievement is earned.
			if ( objectivesFrame.completed and completed ) then
				metaCriteria.check:Show();
				metaCriteria.border:SetVertexColor(1, 1, 1, 1);
				metaCriteria.icon:SetVertexColor(1, 1, 1, 1);
				metaCriteria.label:SetShadowOffset(0, 0)
				metaCriteria.label:SetTextColor(0, 0, 0, 1);
			elseif ( completed ) then
				metaCriteria.check:Show();
				metaCriteria.border:SetVertexColor(1, 1, 1, 1);
				metaCriteria.icon:SetVertexColor(1, 1, 1, 1);
				metaCriteria.label:SetShadowOffset(1, -1)
				metaCriteria.label:SetTextColor(0, 1, 0, 1);
			else
				metaCriteria.check:Hide();
				metaCriteria.border:SetVertexColor(.75, .75, .75, 1);
				metaCriteria.icon:SetVertexColor(.55, .55, .55, 1);
				metaCriteria.label:SetShadowOffset(1, -1)
				metaCriteria.label:SetTextColor(.6, .6, .6, 1);
			end

			metaCriteria:SetParent(objectivesFrame);
			metaCriteria:Show();
		elseif ( bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR ) then
			-- Display this criteria as a progress bar!
			progressBars = progressBars + 1;
			local progressBar = AchievementButton_GetProgressBar(progressBars, renderOffScreen);

			if ( progressBars == 1 ) then
				progressBar:SetPoint("TOP", objectivesFrame, "TOP", 4, -4 + yOffset);
			else
				progressBar:SetPoint("TOP", AchievementButton_GetProgressBar(progressBars-1, renderOffScreen), "BOTTOM", 0, 0);
			end

			progressBar.text:SetText(string.format("%s", quantityString));
			progressBar:SetMinMaxValues(0, reqQuantity);
			progressBar:SetValue(quantity);

			progressBar:SetParent(objectivesFrame);
			progressBar:Show();

			numCriteriaRows = numCriteriaRows + 1;
		else
			textStrings = textStrings + 1;
			local criteria = AchievementButton_GetCriteria(textStrings, renderOffScreen);
			criteria:ClearAllPoints();
			if ( textStrings == 1 ) then
				if ( numCriteria == 1 ) then
					criteria:SetPoint("TOP", objectivesFrame, "TOP", -14, yOffset);
				else
					criteria:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 0, yOffset);
				end

			else
				criteria:SetPoint("TOPLEFT", AchievementButton_GetCriteria(textStrings-1, renderOffScreen), "BOTTOMLEFT", 0, 0);
			end

			if ( objectivesFrame.completed and completed ) then
				criteria.name:SetTextColor(0, 0, 0, 1);
				criteria.name:SetShadowOffset(0, 0);
			elseif ( completed ) then
				criteria.name:SetTextColor(0, 1, 0, 1);
				criteria.name:SetShadowOffset(1, -1);
			else
				criteria.name:SetTextColor(.6, .6, .6, 1);
				criteria.name:SetShadowOffset(1, -1);
			end

			local stringWidth = 0;
			local maxCriteriaContentWidth;
			if ( completed ) then
				maxCriteriaContentWidth = ACHIEVEMENTUI_MAXCONTENTWIDTH - ACHIEVEMENTUI_CRITERIACHECKWIDTH;
				criteria.check:SetPoint("LEFT", 18, -3);
				criteria.name:SetPoint("LEFT", criteria.check, "RIGHT", 0, 2);
				criteria.check:Show();
				criteria.name:SetText(criteriaString);
				stringWidth = min(criteria.name:GetStringWidth(),maxCriteriaContentWidth);
			else
				maxCriteriaContentWidth = ACHIEVEMENTUI_MAXCONTENTWIDTH - objectivesFrame.textCheckWidth;
				criteria.check:SetPoint("LEFT", 0, -3);
				criteria.name:SetPoint("LEFT", criteria.check, "RIGHT", 5, 2);
				criteria.check:Hide();
				criteria.name:SetText("- "..criteriaString);
				stringWidth = min(criteria.name:GetStringWidth() - objectivesFrame.textCheckWidth,maxCriteriaContentWidth);	-- don't want the "- " to be included in the width
			end
			if ( criteria.name:GetWidth() > maxCriteriaContentWidth ) then
				criteria.name:SetWidth(maxCriteriaContentWidth);
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
		local criTable = AchievementButton_GetCriteria(1, renderOffScreen);
		criTable:ClearAllPoints();
		if ( textStrings == 1 ) then
			criTable:SetPoint("TOP", AchievementButton_GetProgressBar(progressBars, renderOffScreen), "BOTTOM", -14, -4);
		else
			criTable:SetPoint("TOP", AchievementButton_GetProgressBar(progressBars, renderOffScreen), "BOTTOM", 0, -4);
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
			if ( AchievementButton_GetCriteria(2, renderOffScreen).name:GetStringWidth() > FORCE_COLUMNS_RIGHT_COLUMN_SPACE and progressBars == 0 ) then
				AddExtraCriteriaRow();
			end
		end
		if ( numColumns > 1 ) then
			local step;
			local rows = 1;
			local position = 0;
			local criTable = criteriaTable;
			if (renderOffScreen) then
				criTable = criteriaTableOffScreen;
			end
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

function AchievementFrameStats_OnEvent (self, event, ...)
	if ( event == "CRITERIA_UPDATE" and self:IsVisible() ) then
		AchievementFrameStats_Update();
	end
end

function AchievementFrameStats_OnLoad (self)
	AchievementFrameStatsContainerScrollBar.Show =
		function (self)
			AchievementFrameStats:SetWidth(504);
			for _, button in next, AchievementFrameStats.buttons do
				button:SetWidth(496);
			end
			getmetatable(self).__index.Show(self);
		end

	AchievementFrameStatsContainerScrollBar.Hide =
		function (self)
			AchievementFrameStats:SetWidth(530);
			for _, button in next, AchievementFrameStats.buttons do
				button:SetWidth(522);
			end
			getmetatable(self).__index.Hide(self);
		end

	self:RegisterEvent("CRITERIA_UPDATE");
	AchievementFrameStatsContainerScrollBarBG:Show();
	AchievementFrameStatsContainer.update = AchievementFrameStats_Update;
	HybridScrollFrame_CreateButtons(AchievementFrameStatsContainer, "StatTemplate");
end


function AchievementFrameStats_Update ()
	local category = achievementFunctions.selectedCategory;
	local scrollFrame = AchievementFrameStatsContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local statHeight = 24;

	local numStats, numCompleted = GetCategoryNumAchievements(category);

	local categories = ACHIEVEMENTUI_CATEGORIES;
	-- clear out table
	if ( achievementFunctions.lastCategory ~= category ) then
		local statCat;
		for i in next, displayStatCategories do
			displayStatCategories[i] = nil;
		end
		-- build a list of shown category and stat id's

		tinsert(displayStatCategories, {id = category, header = true});
		for i=1, numStats do
			local quantity, skip, id = GetStatistic(category, i);
			if ( not skip ) then
				tinsert(displayStatCategories, {id = id});
			end
		end
		-- add all the subcategories and their stat id's
		for i, cat in next, categories do
			if ( cat.parent == category ) then
				tinsert(displayStatCategories, {id = cat.id, header = true});
				numStats = GetCategoryNumAchievements(cat.id);
				for k=1, numStats do
					local quantity, skip, id = GetStatistic(cat.id, k);
					if ( not skip ) then
						tinsert(displayStatCategories, {id = id});
					end
				end
			end
		end
		achievementFunctions.lastCategory = category;
	end

	-- iterate through the displayStatCategories and display them
	local selection = AchievementFrameStats.selection;
	local statCount = #displayStatCategories;
	local statIndex, id, button;
	local stat;

	local totalHeight = statCount * statHeight;
	local displayedHeight = numButtons * statHeight;
	for i = 1, numButtons do
		button = buttons[i];
		statIndex = offset + i;
		if ( statIndex <= statCount ) then
			stat = displayStatCategories[statIndex];
			if ( stat.header ) then
				AchievementFrameStats_SetHeader(button, stat.id);
			else
				AchievementFrameStats_SetStat(button, stat.id, nil, statIndex)
			end
			button:Show();
		else
			button:Hide();
		end
	end
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function AchievementFrameStats_SetStat(button, category, index, colorIndex, isSummary)
	--Remove these variables when we know for sure we don't need them
	local id, name, points, completed, month, day, year, description, flags, icon;
	if ( not isSummary ) then
		if ( not index ) then
			id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(category);
		else
			id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(category, index);
		end

	else
		-- This is on the summary page
		id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfoFromCriteria(category);
	end

	if (not id) then
		return;
	end

	button.id = id;

	if ( not colorIndex ) then
		if ( not index ) then
			message("Error, need a color index or index");
		end
		colorIndex = index;
	end
	button:SetText(name);
	button.background:Show();
	-- Color every other line yellow
	if ( mod(colorIndex, 2) == 1 ) then
		button.background:SetTexCoord(0, 1, 0.1875, 0.3671875);
		button.background:SetBlendMode("BLEND");
		button.background:SetAlpha(1.0);
		button:SetHeight(24);
	else
		button.background:SetTexCoord(0, 1, 0.375, 0.5390625);
		button.background:SetBlendMode("ADD");
		button.background:SetAlpha(0.5);
		button:SetHeight(24);
	end

	-- Figure out the criteria
	local numCriteria = GetAchievementNumCriteria(id);
	if ( numCriteria == 0 ) then
		-- This is no good!
	end
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
	button.value:SetText(quantity);

	-- Hide the header images
	button.title:Hide();
	button.left:Hide();
	button.middle:Hide();
	button.right:Hide();
	button.isHeader = false;
end

function AchievementFrameStats_SetHeader(button, id)
	-- show header
	button.left:Show();
	button.middle:Show();
	button.right:Show();
	local text;
	if ( id == ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID ) then
		text = ACHIEVEMENT_SUMMARY_CATEGORY;
	else
		text = GetCategoryInfo(id);
	end
	button.title:SetText(text);
	button.title:Show();
	button.value:SetText("");
	button:SetText("");
	button:SetHeight(24);
	button.background:Hide();
	button.isHeader = true;
	button.id = id;
end

function AchievementStatButton_OnLoad(self, parentFrame)
	self.value:SetVertexColor(1, 0.97, 0.6);
	parentFrame.buttons = parentFrame.buttons or {};
	tinsert(parentFrame.buttons, self);
end

function AchievementStatButton_OnClick(self)
	if ( self.isHeader ) then
		achievementFunctions.selectedCategory = self.id;
		AchievementFrameCategories_Update();
		AchievementFrameStats_Update();
	elseif ( self.summary ) then
		AchievementFrame_SelectSummaryStatistic(self.id);
	end
end

function AchievementStatButton_OnEnter(self)
	if ( self.text:IsTruncated() ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.text:GetText(), 1, 1, 1, 1, true);
	end
end

-- [[ Summary Frame ]] --
function AchievementFrameSummary_OnShow()
	if ( achievementFunctions ~= COMPARISON_ACHIEVEMENT_FUNCTIONS and achievementFunctions ~= COMPARISON_STAT_FUNCTIONS ) then
		if ( AchievementFrameSummary.guildView ~= IN_GUILD_VIEW ) then
			AchievementFrameSummary_ToggleView();
		elseif ( AchievementFrameSummary.guildView ) then
			AchievementFrameSummary_UpdateSummaryCategories(ACHIEVEMENTUI_GUILDSUMMARYCATEGORIES);
		else
			AchievementFrameSummary_UpdateSummaryCategories(ACHIEVEMENTUI_SUMMARYCATEGORIES);
		end
		AchievementFrameSummary:SetWidth(530);
		AchievementFrameSummary_Update();
	else
		AchievementFrameComparisonDark:Hide();
		AchievementFrameComparisonWatermark:Hide();
		AchievementFrameComparison:SetWidth(650);
		AchievementFrameSummary:SetWidth(650);
		AchievementFrameSummary_Update(true);
	end
end

function AchievementFrameSummary_Update(isCompare)
	AchievementFrameSummaryCategoriesStatusBar_Update();
	AchievementFrameSummary_UpdateAchievements(GetLatestCompletedAchievements(IN_GUILD_VIEW));
end

function AchievementFrameSummary_UpdateSummaryCategories(categories)
	for i = 1, 12 do
		local statusBar = _G["AchievementFrameSummaryCategoriesCategory"..i];
		if ( i <= #categories ) then
			local categoryName = GetCategoryInfo(categories[i]);
			statusBar.label:SetText(categoryName);
			statusBar:Show();
			statusBar:SetID(categories[i]);
			AchievementFrameSummaryCategory_OnShow(statusBar);	-- to calculate progress
		else
			statusBar:Hide();
		end
	end
end

function AchievementFrameSummary_ToggleView()
	local tCategories;
 	if ( AchievementFrameSummary.guildView ) then
		AchievementFrameSummary.guildView = nil;
		tCategories = ACHIEVEMENTUI_SUMMARYCATEGORIES;
		-- recent achievements
		for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			local button = _G["AchievementFrameSummaryAchievement"..i];
			button.icon.frame:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame");
			button.icon.frame:SetTexCoord(0, 0.5625, 0, 0.5625);
			button.icon.frame:SetPoint("CENTER", -1, 2);
			button.glow:SetTexCoord(0, 1, 0.00390625, 0.25390625);
			button.titleBar:SetAlpha(0.5);
		end
	else
		AchievementFrameSummary.guildView = true;
		tCategories = ACHIEVEMENTUI_GUILDSUMMARYCATEGORIES;
		-- recent achievements
		for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			local button = _G["AchievementFrameSummaryAchievement"..i];
			if ( button ) then
				AchievementFrameSummaryAchievement_SetGuildTextures(button)
			end
		end
	end
	AchievementFrameSummary_UpdateSummaryCategories(tCategories);
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
			if ( AchievementFrameSummary.guildView ) then
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
				if ( IN_GUILD_VIEW ) then
					saturatedStyle = "guild";
				else
					saturatedStyle = "normal";
				end
			end

			button.label:SetText(name);
			button.description:SetText(description);
			AchievementShield_SetPoints(points, button.shield.points, GameFontNormal, GameFontNormalSmall);
			if ( points > 0 ) then
				button.shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
			else
				button.shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
			end

			if ( isGuild ) then
				button.shield.wasEarnedByMe = nil;
				button.shield.earnedBy = nil;
			else
				button.shield.wasEarnedByMe = not (completed and not wasEarnedByMe);
				button.shield.earnedBy = earnedBy;
			end

			button.icon.texture:SetTexture(icon);
			button.id = id;

			if ( completed ) then
				button.dateCompleted:SetText(FormatShortDate(day, month, year));
			else
				button.dateCompleted:SetText("");
			end

			if ( button.saturatedStyle ~= saturatedStyle ) then
				button:Saturate();
			end
			button.tooltipTitle = nil;
			button:Show();
		else
			local tAchievements;
			if ( IN_GUILD_VIEW ) then
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
					button.label:SetText(name);
					button.description:SetText(description);
					AchievementShield_SetPoints(points, button.shield.points, GameFontNormal, GameFontNormalSmall);
					if ( points > 0 ) then
						button.shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
					else
						button.shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
					end
					button.shield.wasEarnedByMe = not (completed and not wasEarnedByMe);
					button.shield.earnedBy = earnedBy;
					button.icon.texture:SetTexture(icon);
					button.id = id;
					if ( month ) then
						button.dateCompleted:SetText(FormatShortDate(day, month, year));
					else
						button.dateCompleted:SetText("");
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
	local total, completed = GetNumCompletedAchievements(IN_GUILD_VIEW);
	AchievementFrameSummaryCategoriesStatusBar:SetMinMaxValues(0, total);
	AchievementFrameSummaryCategoriesStatusBar:SetValue(completed);
	AchievementFrameSummaryCategoriesStatusBarText:SetText(BreakUpLargeNumbers(completed).."/"..BreakUpLargeNumbers(total));
end

function AchievementFrameSummaryAchievement_OnLoad(self)
	AchievementComparisonPlayerButton_OnLoad(self);
	AchievementFrameSummaryAchievements.buttons = AchievementFrameSummaryAchievements.buttons or {};
	tinsert(AchievementFrameSummaryAchievements.buttons, self);
	self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, 0.5);
	self.titleBar:SetVertexColor(1,1,1,0.5);
	self.dateCompleted:Show();
end

function AchievementFrameSummaryAchievement_SetGuildTextures(button)
	button.icon.frame:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
	button.icon.frame:SetTexCoord(0.25976563, 0.40820313, 0.50000000, 0.64453125);
	button.icon.frame:SetPoint("CENTER", 0, 2);
	button.glow:SetTexCoord(0, 1, 0.26171875, 0.51171875);
	button.titleBar:SetAlpha(1);
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
	self.highlight:Show();
	if ( self.tooltipTitle ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltipTitle,1,1,1);
		GameTooltip:AddLine(self.tooltip, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

function AchievementFrameSummaryCategoryButton_OnClick (self)
	local id = self:GetParent():GetID();
	for _, button in next, AchievementFrameCategoriesContainer.buttons do
		if ( button.categoryID == id ) then
			button:Click();
			return;
		end
	end
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

	for _, category in next, ACHIEVEMENTUI_CATEGORIES do
		if ( category.parent == id ) then
			numAchievements, numCompleted = GetCategoryNumAchievements(category.id, showAll);
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

	self.text:SetText(string.format("%d/%d", totalCompleted, totalAchievements));
	self:SetMinMaxValues(0, totalAchievements);
	self:SetValue(totalCompleted);
	self:RegisterEvent("ACHIEVEMENT_EARNED");
end

function AchievementFrameSummaryCategory_OnHide (self)
	self:UnregisterEvent("ACHIEVEMENT_EARNED");
end

function AchievementFrame_SelectAchievement(id, forceSelect, isComparison)
	if ( not AchievementFrame:IsShown() and not forceSelect ) then
		return;
	end

	local _, _, _, achCompleted, _, _, _, _, flags = GetAchievementInfo(id);
	if ( achCompleted and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_INCOMPLETE].func) ) then
		AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
	elseif ( (not achCompleted) and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_COMPLETE].func) ) then
		AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
	end

	local tabIndex = 1;
	local category = GetAchievementCategory(id);
	if ( bit.band(flags, ACHIEVEMENT_FLAGS_GUILD) == ACHIEVEMENT_FLAGS_GUILD ) then
		tabIndex = 2;
	end

	if ( isComparison ) then
		AchievementFrameTab_OnClick = AchievementFrameComparisonTab_OnClick;
	else
		AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
	end

	AchievementFrameTab_OnClick(tabIndex);
	AchievementFrameSummary:Hide();

	if ( not isComparison ) then
		AchievementFrameAchievements:Show();
	end

	-- Figure out if this is part of a progressive achievement; if it is and it's incomplete, make sure the previous level was completed. If not, find the first incomplete achievement in the chain and display that instead.
	id = AchievementFrame_FindDisplayedAchievement(id);

	AchievementFrameCategories_ClearSelection();

	local categoryIndex, parent, hidden = 0;
	for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
		if ( entry.id == category ) then
			parent = entry.parent;
		end
	end

	for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
		if ( entry.id == parent ) then
			entry.collapsed = false;
		elseif ( entry.parent == parent ) then
			entry.hidden = false;
		elseif ( entry.parent == true ) then
			entry.collapsed = true;
		elseif ( entry.parent ) then
			entry.hidden = true;
		end
	end

	achievementFunctions.selectedCategory = category;
	AchievementFrameCategoriesContainerScrollBar:SetValue(0);
	AchievementFrameCategories_Update();

	local shown = false;
	local found = false;
	while ( not shown ) do
		found = false;
		for _, button in next, AchievementFrameCategoriesContainer.buttons do
			if ( button.categoryID == category ) then
				found = true;
			end
			if ( button.categoryID == category and math.ceil(button:GetBottom()) >= math.ceil(GetSafeScrollChildBottom(AchievementFrameAchievementsContainerScrollChild)) ) then
				shown = true;
			end
		end

		if ( not shown ) then
			local _, maxVal = AchievementFrameCategoriesContainerScrollBar:GetMinMaxValues();
			if ( AchievementFrameCategoriesContainerScrollBar:GetValue() == maxVal ) then
				--assert(false)
				if ( not found ) then
					return;
				else
					shown = true;
				end
			elseif AchievementFrameCategoriesContainerScrollBar:IsVisible() then
				HybridScrollFrame_OnMouseWheel(AchievementFrameCategoriesContainer, -1);
			else
				break;
			end
		end
	end

	local container, child, scrollBar = AchievementFrameAchievementsContainer, AchievementFrameAchievementsContainerScrollChild, AchievementFrameAchievementsContainerScrollBar;
	if ( isComparison ) then
		container = AchievementFrameComparisonContainer;
		child = AchievementFrameComparisonContainerScrollChild;
		scrollBar = AchievementFrameComparisonContainerScrollBar;
	end

	achievementFunctions.clearFunc();
	scrollBar:SetValue(0);
	achievementFunctions.updateFunc();

	local shown = false;
	local previousScrollValue;
	while ( not shown ) do
		for _, button in next, container.buttons do
			if ( button.id == id and math.ceil(button:GetTop()) >= math.ceil(GetSafeScrollChildBottom(child)) ) then
				if ( not isComparison ) then
					-- The "True" here ignores modifiers, so you don't accidentally track or link this achievement. :P
					AchievementButton_OnClick(button, nil, nil, true);
				end

				-- We found the button!
				shown = button;
				break;
			end
		end

		local _, maxVal = scrollBar:GetMinMaxValues();
		if ( shown ) then
			-- If we can, move the achievement we're scrolling to to the top of the screen.
			local newHeight = scrollBar:GetValue() + container:GetTop() - shown:GetTop();
			newHeight = min(newHeight, maxVal);
			scrollBar:SetValue(newHeight);
		else
			local scrollValue = scrollBar:GetValue();
			if ( scrollValue == maxVal or scrollValue == previousScrollValue ) then
				--assert(false, "Failed to find achievement " .. id .. " while jumping!")
				return;
			else
				previousScrollValue = scrollValue;
				HybridScrollFrame_OnMouseWheel(container, -1);
			end
		end
	end
end

function AchievementFrameAchievements_FindSelection()
	local _, maxVal = AchievementFrameAchievementsContainerScrollBar:GetMinMaxValues();
	local scrollHeight = AchievementFrameAchievementsContainer:GetHeight();
	local newHeight = 0;
	AchievementFrameAchievementsContainerScrollBar:SetValue(0);
	while ( true ) do
		for _, button in next, AchievementFrameAchievementsContainer.buttons do
			if ( button.selected ) then
				newHeight = AchievementFrameAchievementsContainerScrollBar:GetValue() + AchievementFrameAchievementsContainer:GetTop() - button:GetTop();
				newHeight = min(newHeight, maxVal);
				AchievementFrameAchievementsContainerScrollBar:SetValue(newHeight);
				return;
			end
		end
		if ( not AchievementFrameAchievementsContainerScrollBar:IsVisible() or AchievementFrameAchievementsContainerScrollBar:GetValue() == maxVal ) then
			return;
		else
			newHeight = newHeight + scrollHeight;
			newHeight = min(newHeight, maxVal);
			AchievementFrameAchievementsContainerScrollBar:SetValue(newHeight);
		end
	end
end

function AchievementFrameAchievements_AdjustSelection()
	local selectedButton;
	-- check if selection is visible
	for _, button in next, AchievementFrameAchievementsContainer.buttons do
		if ( button.selected ) then
			selectedButton = button;
			break;
		end
	end

	if ( not selectedButton ) then
		AchievementFrameAchievements_FindSelection();
	else
		local newHeight;
		if ( selectedButton:GetTop() > AchievementFrameAchievementsContainer:GetTop() ) then
			newHeight = AchievementFrameAchievementsContainerScrollBar:GetValue() + AchievementFrameAchievementsContainer:GetTop() - selectedButton:GetTop();
		elseif ( selectedButton:GetBottom() < AchievementFrameAchievementsContainer:GetBottom() ) then
			if ( selectedButton:GetHeight() > AchievementFrameAchievementsContainer:GetHeight() ) then
				newHeight = AchievementFrameAchievementsContainerScrollBar:GetValue() + AchievementFrameAchievementsContainer:GetTop() - selectedButton:GetTop();
			else
				newHeight = AchievementFrameAchievementsContainerScrollBar:GetValue() + AchievementFrameAchievementsContainer:GetBottom() - selectedButton:GetBottom();
			end
		end
		if ( newHeight ) then
			local _, maxVal = AchievementFrameAchievementsContainerScrollBar:GetMinMaxValues();
			newHeight = min(newHeight, maxVal);
			AchievementFrameAchievementsContainerScrollBar:SetValue(newHeight);
		end
	end
end

function AchievementFrame_SelectSummaryStatistic (criteriaId, isComparison)
	local id = GetAchievementInfoFromCriteria(criteriaId);
	AchievementFrame_SelectStatisticByAchievementID(id, isComparison);
end

function AchievementFrame_SelectStatisticByAchievementID(achievementID, isComparison)
	if ( isComparison ) then
		AchievementFrameTab_OnClick = AchievementFrameComparisonTab_OnClick;
		AchievementFrameComparisonStatsContainer:Show();
		AchievementFrameComparisonSummary:Hide();
	else
		AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
		AchievementFrameStats:Show();
		AchievementFrameSummary:Hide();
	end

	AchievementFrameTab_OnClick(3);

	AchievementFrameCategories_ClearSelection();


	local category = GetAchievementCategory(achievementID);

	local categoryIndex, parent, hidden = 0;

	local categoryIndex, parent, hidden = 0;
	for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
		if ( entry.id == category ) then
			parent = entry.parent;
		end
	end

	for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
		if ( entry.id == parent ) then
			entry.collapsed = false;
		elseif ( entry.parent == parent ) then
			entry.hidden = false;
		elseif ( entry.parent == true ) then
			entry.collapsed = true;
		elseif ( entry.parent ) then
			entry.hidden = true;
		end
	end

	achievementFunctions.selectedCategory = category;
	AchievementFrameCategories_Update();
	AchievementFrameCategoriesContainerScrollBar:SetValue(0);

	local shown = false;
	while ( not shown ) do
		for _, button in next, AchievementFrameCategoriesContainer.buttons do
			if ( button.categoryID == category and math.ceil(button:GetBottom()) >= math.ceil(GetSafeScrollChildBottom(AchievementFrameAchievementsContainerScrollChild)) ) then
				shown = true;
			end
		end

		if ( not shown ) then
			local _, maxVal = AchievementFrameCategoriesContainerScrollBar:GetMinMaxValues();
			if ( AchievementFrameCategoriesContainerScrollBar:GetValue() == maxVal ) then
				assert(false)
			elseif AchievementFrameCategoriesContainerScrollBar:IsVisible() then
				HybridScrollFrame_OnMouseWheel(AchievementFrameCategoriesContainer, -1);
			else
				break;
			end
		end
	end

	local container, child, scrollBar = AchievementFrameStatsContainer, AchievementFrameStatsContainerScrollChild, AchievementFrameStatsContainerScrollBar;
	if ( isComparison ) then
		container = AchievementFrameComparisonStatsContainer;
		child = AchievementFrameComparisonStatsContainerScrollChild;
		scrollBar = AchievementFrameComparisonStatsContainerScrollBar;
	end

	achievementFunctions.updateFunc();
	scrollBar:SetValue(0);

	local shown = false;
	while ( not shown ) do
		for _, button in next, container.buttons do
			if ( button.id == achievementID and math.ceil(button:GetBottom()) >= math.ceil(GetSafeScrollChildBottom(child)) ) then
				if ( not isComparison ) then
					AchievementStatButton_OnClick(button);
				end

				-- We found the button! MAKE IT SHOWN ZOMG!
				shown = button;
			end
		end

		if ( shown and scrollBar:IsShown() ) then
			-- If we can, move the achievement we're scrolling to to the top of the screen.
			scrollBar:SetValue(scrollBar:GetValue() + container:GetTop() - shown:GetTop());
		elseif ( not shown ) then
			local _, maxVal = scrollBar:GetMinMaxValues();
			if ( scrollBar:GetValue() == maxVal ) then
				assert(false)
			elseif scrollBar:IsVisible() then
				HybridScrollFrame_OnMouseWheel(container, -1);
			else
				break;
			end
		end
	end
end

function AchievementFrameComparison_OnLoad (self)
	AchievementFrameComparisonContainer_OnLoad(self);
	AchievementFrameComparisonStatsContainer_OnLoad(self);
	self:RegisterEvent("ACHIEVEMENT_EARNED");
	self:RegisterEvent("INSPECT_ACHIEVEMENT_READY");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PORTRAITS_UPDATED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function AchievementFrameComparisonContainer_OnLoad (parent)
	AchievementFrameComparisonContainerScrollBar.Show =
		function (self)
			AchievementFrameComparison:SetWidth(626);
			AchievementFrameComparisonSummaryPlayer:SetWidth(498);
			for _, button in next, AchievementFrameComparisonContainer.buttons do
				button:SetWidth(616);
				button.player:SetWidth(498);
			end
			getmetatable(self).__index.Show(self);
		end

	AchievementFrameComparisonContainerScrollBar.Hide =
		function (self)
			AchievementFrameComparison:SetWidth(650);
			AchievementFrameComparisonSummaryPlayer:SetWidth(522);
			for _, button in next, AchievementFrameComparisonContainer.buttons do
				button:SetWidth(640);
				button.player:SetWidth(522);
			end
			getmetatable(self).__index.Hide(self);
		end

	AchievementFrameComparisonContainerScrollBarBG:Show();
	AchievementFrameComparisonContainer.update = AchievementFrameComparison_Update;
	HybridScrollFrame_CreateButtons(AchievementFrameComparisonContainer, "ComparisonTemplate", 0, -2);
end

function AchievementFrameComparisonStatsContainer_OnLoad (parent)
	AchievementFrameComparisonStatsContainerScrollBar.Show =
		function (self)
			AchievementFrameComparison:SetWidth(626);
			for _, button in next, AchievementFrameComparisonStatsContainer.buttons do
				button:SetWidth(616);
			end
			getmetatable(self).__index.Show(self);
		end

	AchievementFrameComparisonStatsContainerScrollBar.Hide =
		function (self)
			AchievementFrameComparison:SetWidth(650);
			for _, button in next, AchievementFrameComparisonStatsContainer.buttons do
				button:SetWidth(640);
			end
			getmetatable(self).__index.Hide(self);
		end

	AchievementFrameComparisonStatsContainerScrollBarBG:Show();
	AchievementFrameComparisonStatsContainer.update = AchievementFrameComparison_UpdateStats;
	HybridScrollFrame_CreateButtons(AchievementFrameComparisonStatsContainer, "ComparisonStatTemplate", 0, -2);
end

function AchievementFrameComparison_OnShow ()
	AchievementFrameStats:Hide();
	AchievementFrameAchievements:Hide();
	AchievementFrame:SetWidth(890);
	SetUIPanelAttribute(AchievementFrame, "xOffset", 38);
	UpdateUIPanelPositions(AchievementFrame);
	AchievementFrame.isComparison = true;
end

function AchievementFrameComparison_OnHide ()
	AchievementFrame.selectedTab = nil;
	AchievementFrame:SetWidth(768);
	SetUIPanelAttribute(AchievementFrame, "xOffset", 80);
	UpdateUIPanelPositions(AchievementFrame);
	AchievementFrame.isComparison = false;
	ClearAchievementComparisonUnit();
end

function AchievementFrameComparison_OnEvent (self, event, ...)
	if event == "INSPECT_ACHIEVEMENT_READY" then
		AchievementFrameComparisonHeaderPoints:SetText(GetComparisonAchievementPoints());
		AchievementFrameComparison_UpdateStatusBars(achievementFunctions.selectedCategory)
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

	AchievementFrameComparisonHeaderPoints:SetText(GetComparisonAchievementPoints());
	AchievementFrameComparisonHeaderName:SetText(GetUnitName(unit));
	C_AchievementInfo.SetPortraitTexture(AchievementFrameComparisonHeaderPortrait);
	AchievementFrameComparisonHeaderPortrait.unit = unit;
	AchievementFrameComparisonHeaderPortrait.race = UnitRace(unit);
	AchievementFrameComparisonHeaderPortrait.sex = UnitSex(unit);
end

function AchievementFrameComparison_ClearSelection ()
	-- Doesn't do anything WHEE~!
end

function AchievementFrameComparison_ForceUpdate ()
	if ( achievementFunctions == COMPARISON_ACHIEVEMENT_FUNCTIONS ) then
		local buttons = AchievementFrameComparisonContainer.buttons;
		for i, button in next, buttons do
			button.id = nil;
		end

		AchievementFrameComparison_Update();
	elseif ( achievementFunctions == COMPARISON_STAT_FUNCTIONS ) then
		AchievementFrameComparison_UpdateStats();
	end
end

function AchievementFrameComparison_Update ()
	local category = achievementFunctions.selectedCategory;
	if ( not category or category == "summary" ) then
		return;
	end
	local scrollFrame = AchievementFrameComparisonContainer

	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numAchievements, numCompleted = GetCategoryNumAchievements(category);
	local numButtons = #buttons;

	local achievementIndex;
	local buttonHeight = buttons[1]:GetHeight();
	for i = 1, numButtons do
		achievementIndex = i + offset;
		AchievementFrameComparison_DisplayAchievement(buttons[i], category, achievementIndex);
	end

	HybridScrollFrame_Update(scrollFrame, buttonHeight*numAchievements, buttonHeight*numButtons);
end

ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT1 = GameFontNormal;
ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT2 = GameFontNormalSmall;
ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT1 = GameFontNormalSmall;
ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT2 = GameFontNormalSmall;

function AchievementFrameComparison_DisplayAchievement (button, category, index)
	local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(category, index);
	if ( not id ) then
		button:Hide();
		return;
	else
		button:Show();
	end

	if ( GetPreviousAchievement(id) ) then
		-- If this is a progressive achievement, show the total score.
		points = AchievementButton_GetProgressivePoints(id);
	end

	if ( button.id ~= id ) then
		button.id = id;

		local player = button.player;
		local friend = button.friend;

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
		player.label:SetText(name);

		player.description:SetText(description);

		player.icon.texture:SetTexture(icon);
		friend.icon.texture:SetTexture(icon);

		if ( points > 0 ) then
			player.shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
			friend.shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
		else
			player.shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
			friend.shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
		end
		AchievementShield_SetPoints(points, player.shield.points, ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT1, ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT2);
		AchievementShield_SetPoints(points, friend.shield.points, ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT1, ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT2);

		player.shield.wasEarnedByMe = not (completed and not wasEarnedByMe);
		player.shield.earnedBy = earnedBy;

		if ( completed ) then
			player.completed = true;
			player.dateCompleted:SetText(FormatShortDate(day, month, year));
			player.dateCompleted:Show();
			if ( player.saturatedStyle ~= saturatedStyle ) then
				player:Saturate();
			end
		else
			player.completed = nil;
			player.dateCompleted:Hide();
			player:Desaturate();
		end

		if ( friendCompleted ) then
			friend.completed = true;
			friend.status:SetText(FormatShortDate(friendDay, friendMonth, friendYear));
			if ( friend.saturatedStyle ~= saturatedStyle ) then
				friend:Saturate();
			end
		else
			friend.completed = nil;
			friend.status:SetText(INCOMPLETE);
			friend:Desaturate();
		end
	end
end

function AchievementFrameComparison_UpdateStats ()
	local category = achievementFunctions.selectedCategory;
	local scrollFrame = AchievementFrameComparisonStatsContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local headerHeight = 24;
	local statHeight = 24;
	local totalHeight = 0;
	local numStats, numCompleted = GetCategoryNumAchievements(category);

	local categories = ACHIEVEMENTUI_CATEGORIES;
	-- clear out table
	if ( achievementFunctions.lastCategory ~= category ) then
		local statCat;
		for i in next, displayStatCategories do
			displayStatCategories[i] = nil;
		end
		-- build a list of shown category and stat id's

		tinsert(displayStatCategories, {id = category, header = true});
		totalHeight = totalHeight+headerHeight;

		for i=1, numStats do
			tinsert(displayStatCategories, {id = GetAchievementInfo(category, i)});
			totalHeight = totalHeight+statHeight;
		end
		achievementFunctions.lastCategory = category;
		achievementFunctions.lastHeight = totalHeight;
	else
		totalHeight = achievementFunctions.lastHeight;
	end

	-- add all the subcategories and their stat id's
	for i, cat in next, categories do
		if ( cat.parent == category ) then
			tinsert(displayStatCategories, {id = cat.id, header = true});
			totalHeight = totalHeight+headerHeight;
			numStats = GetCategoryNumAchievements(cat.id);
			for k=1, numStats do
				tinsert(displayStatCategories, {id = GetAchievementInfo(cat.id, k)});
				totalHeight = totalHeight+statHeight;
			end
		end
	end

	-- iterate through the displayStatCategories and display them
	local statCount = #displayStatCategories;
	local statIndex, id, button;
	local stat;
	local displayedHeight = 0;
	for i = 1, numButtons do
		button = buttons[i];
		statIndex = offset + i;
		if ( statIndex <= statCount ) then
			stat = displayStatCategories[statIndex];
			if ( stat.header ) then
				AchievementFrameComparisonStats_SetHeader(button, stat.id);
			else
				AchievementFrameComparisonStats_SetStat(button, stat.id, nil, statIndex);
			end
			button:Show();
		else
			button:Hide();
		end
		displayedHeight = displayedHeight+button:GetHeight();
	end
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function AchievementFrameComparisonStat_OnLoad (self)
	self.value:SetVertexColor(1, 0.97, 0.6);
	self.friendValue:SetVertexColor(1, 0.97, 0.6);
end

function AchievementFrameComparisonStats_SetStat (button, category, index, colorIndex, isSummary)
--Remove these variables when we know for sure we don't need them
	local id, name, points, completed, month, day, year, description, flags, icon;
	if ( not isSummary ) then
		if ( not index ) then
			id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(category);
		else
			id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(category, index);
		end

	else
		-- This is on the summary page
		id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfoFromCriteria(category);
	end

	button.id = id;

	if ( not colorIndex ) then
		if ( not index ) then
			message("Error, need a color index or index");
		end
		colorIndex = index;
	end

	button.background:Show();
	-- Color every other line yellow
	if ( mod(colorIndex, 2) == 1 ) then
		button.background:SetTexCoord(0, 1, 0.1875, 0.3671875);
		button.background:SetBlendMode("BLEND");
		button.background:SetAlpha(1.0);
		button:SetHeight(24);
	else
		button.background:SetTexCoord(0, 1, 0.375, 0.5390625);
		button.background:SetBlendMode("ADD");
		button.background:SetAlpha(0.5);
		button:SetHeight(24);
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

	button.value:SetText(quantity);

	-- We're gonna use button.text here to measure string width for friendQuantity. This saves us many strings!
	button.text:SetText(friendQuantity);
	local width = button.text:GetStringWidth();
	if ( width > button.friendValue:GetWidth() ) then
		button.friendValue:SetFontObject("AchievementFont_Small");
		button.mouseover:Show();
		button.mouseover.tooltip = friendQuantity;
	else
		button.friendValue:SetFontObject("GameFontHighlightRight");
		button.mouseover:Hide();
		button.mouseover.tooltip = nil;
	end

	button.text:SetText(name);
	button.friendValue:SetText(friendQuantity);


	-- Hide the header images
	button.title:Hide();
	button.left:Hide();
	button.middle:Hide();
	button.right:Hide();
	button.left2:Hide();
	button.middle2:Hide();
	button.right2:Hide();
	button.isHeader = false;
end

function AchievementFrameComparisonStats_SetHeader(button, id)
	-- show header
	button.left:Show();
	button.middle:Show();
	button.right:Show();
	button.left2:Show();
	button.middle2:Show();
	button.right2:Show();
	button.title:SetText(GetCategoryInfo(id));
	button.title:Show();
	button.friendValue:SetText("");
	button.value:SetText("");
	button.text:SetText("");
	button:SetHeight(24);
	button.background:Hide();
	button.isHeader = true;
	button.id = id;
end

function AchievementComparisonPlayerButton_Saturate (self)
	local name = self:GetName();
	if ( IN_GUILD_VIEW ) then
		self.background:SetTexture("Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal");
		self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.titleBar:SetTexCoord(0, 1, 0.83203125, 0.91015625);
		self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
		self.shield.points:SetVertexColor(0, 1, 0);
		self.saturatedStyle = "guild";
	else
		self.background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
		self.shield.points:SetVertexColor(1, 1, 1);
		if ( self.accountWide ) then
			self.titleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
			self.titleBar:SetTexCoord(0, 1, 0, 0.375);
			self:SetBackdropBorderColor(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B, ACHIEVEMENTUI_BLUEBORDER_A);
			self.saturatedStyle = "account";
		else
			self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			self.titleBar:SetTexCoord(0, 1, 0.66015625, 0.73828125);
			self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
			self.saturatedStyle = "normal";
		end
	end
	if ( self.isSummary ) then
		if ( self.accountWide ) then
			self.titleBar:SetAlpha(1);
		else
			self.titleBar:SetAlpha(0.5);
		end
	end
	self.glow:SetVertexColor(1.0, 1.0, 1.0);
	self.icon:Saturate();
	self.shield:Saturate();
	self.label:SetVertexColor(1, 1, 1);
	self.description:SetTextColor(0, 0, 0, 1);
	self.description:SetShadowOffset(0, 0);
end

function AchievementComparisonPlayerButton_Desaturate (self)
	self.saturatedStyle = nil;
	local name = self:GetName();
	if ( IN_GUILD_VIEW ) then
		self.background:SetTexture("Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal-Desaturated");
		self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.titleBar:SetTexCoord(0, 1, 0.74609375, 0.82421875);
	else
		self.background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
		if ( self.accountWide ) then
			self.titleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
			self.titleBar:SetTexCoord(0, 1, 0.40625, 0.78125);
		else
			self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			self.titleBar:SetTexCoord(0, 1, 0.91796875, 0.99609375);
		end
	end
	if ( self.isSummary ) then
		if ( self.accountWide ) then
			self.titleBar:SetAlpha(1);
		else
			self.titleBar:SetAlpha(0.5);
		end
	end
	self.glow:SetVertexColor(.22, .17, .13);
	self.icon:Desaturate();
	self.shield:Desaturate();
	self.shield.points:SetVertexColor(.65, .65, .65);
	self.label:SetVertexColor(.65, .65, .65);
	self.description:SetTextColor(1, 1, 1, 1);
	self.description:SetShadowOffset(1, -1);
	self:SetBackdropBorderColor(.5, .5, .5);
end

function AchievementComparisonPlayerButton_OnLoad (self)
	self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
	self.Saturate = AchievementComparisonPlayerButton_Saturate;
	self.Desaturate = AchievementComparisonPlayerButton_Desaturate;

	self:Desaturate();

	-- AchievementFrameComparison.buttons = AchievementFrameComparison.buttons or {};
	-- tinsert(AchievementFrameComparison.buttons, self);
end

function AchievementComparisonFriendButton_Saturate (self)
	if ( self.accountWide ) then
		self.titleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
		self.titleBar:SetTexCoord(0.3, 0.575, 0, 0.375);
		self.saturatedStyle = "account";
		self:SetBackdropBorderColor(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B, ACHIEVEMENTUI_BLUEBORDER_A);
	else
		self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.titleBar:SetTexCoord(0.3, 0.575, 0.66015625, 0.73828125);
		self.saturatedStyle = "normal";
		self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
	end
	self.background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
	self.glow:SetVertexColor(1.0, 1.0, 1.0);
	self.icon:Saturate();
	self.shield:Saturate();
	self.shield.points:SetVertexColor(1, 1, 1);
	self.status:SetVertexColor(1, .82, 0);
end

function AchievementComparisonFriendButton_Desaturate (self)
	self.saturatedStyle = nil;
	if ( self.accountWide ) then
		self.titleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
		self.titleBar:SetTexCoord(0.3, 0.575, 0.40625, 0.78125);
	else
		self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.titleBar:SetTexCoord(0.3, 0.575, 0.74609375, 0.82421875);
	end
	self.background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
	self.glow:SetVertexColor(.22, .17, .13);
	self.icon:Desaturate();
	self.shield:Desaturate();
	self.shield.points:SetVertexColor(.65, .65, .65);
	self.status:SetVertexColor(.65, .65, .65);
	self:SetBackdropBorderColor(.5, .5, .5);
end

function AchievementComparisonFriendButton_OnLoad (self)
	self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
	self.Saturate = AchievementComparisonFriendButton_Saturate;
	self.Desaturate = AchievementComparisonFriendButton_Desaturate;

	self:Desaturate();
end

function AchievementFrame_IsComparison()
	return AchievementFrame.isComparison;
end

function AchievementFrame_IsFeatOfStrength()
	if ( ( AchievementFrame.selectedTab == 1 or AchievementFrame.selectedTab == 2 ) and achievementFunctions.selectedCategory == displayCategories[#displayCategories].id ) then
		return true;
	end
	return false;
end

ACHIEVEMENT_FUNCTIONS = {
	categoryAccessor = GetCategoryList,
	clearFunc = AchievementFrameAchievements_ClearSelection,
	updateFunc = AchievementFrameAchievements_Update,
	selectedCategory = "summary";
}

GUILD_ACHIEVEMENT_FUNCTIONS = {
	categoryAccessor = GetGuildCategoryList,
	clearFunc = AchievementFrameAchievements_ClearSelection,
	updateFunc = AchievementFrameAchievements_Update,
	selectedCategory = "summary";
}

STAT_FUNCTIONS = {
	categoryAccessor = GetStatisticsCategoryList,
	clearFunc = nil,
	updateFunc = AchievementFrameStats_Update,
	selectedCategory = 130;
	noSummary = true;
}

COMPARISON_ACHIEVEMENT_FUNCTIONS = {
	categoryAccessor = GetCategoryList,
	clearFunc = AchievementFrameComparison_ClearSelection,
	updateFunc = AchievementFrameComparison_Update,
	selectedCategory = -1,
}

COMPARISON_STAT_FUNCTIONS = {
	categoryAccessor = GetStatisticsCategoryList,
	clearFunc = AchievementFrameComparison_ClearSelection,
	updateFunc = AchievementFrameComparison_UpdateStats,
	selectedCategory = -2,
}

achievementFunctions = ACHIEVEMENT_FUNCTIONS;


ACHIEVEMENT_TEXTURES_TO_LOAD = {
	{
		name="AchievementFrameAchievementsBackground",
		file="Interface\\AchievementFrame\\UI-Achievement-AchievementBackground",
	},
	{
		name="AchievementFrameSummaryBackground",
		file="Interface\\AchievementFrame\\UI-Achievement-AchievementBackground",
	},
	{
		name="AchievementFrameComparisonBackground",
		file="Interface\\AchievementFrame\\UI-Achievement-AchievementBackground",
	},
	{
		name="AchievementFrameCategoriesBG",
		file="Interface\\AchievementFrame\\UI-Achievement-Parchment",
	},
	{
		name="AchievementFrameWaterMark",
	},
	{
		name="AchievementFrameHeaderLeft",
		file="Interface\\AchievementFrame\\UI-Achievement-Header",
	},
	{
		name="AchievementFrameHeaderRight",
		file="Interface\\AchievementFrame\\UI-Achievement-Header",
	},
	{
		name="AchievementFrameHeaderPointBorder",
		file="Interface\\AchievementFrame\\UI-Achievement-Header",
	},
	{
		name="AchievementFrameComparisonWatermark",
		file="Interface\\AchievementFrame\\UI-Achievement-StatsComparisonBackground",
	},
}

function AchievementFrame_ClearTextures()
	for k, v in pairs(ACHIEVEMENT_TEXTURES_TO_LOAD) do
		_G[v.name]:SetTexture(nil);
	end
end

function AchievementFrame_LoadTextures()
	for k, v in pairs(ACHIEVEMENT_TEXTURES_TO_LOAD) do
		if ( v.file ) then
			_G[v.name]:SetTexture(v.file);
		end
	end
end

--
-- Guild Members Display
--

function AchievementMeta_OnEnter(self)
	if ( self.date ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:AddLine(string.format(ACHIEVEMENT_META_COMPLETED_DATE, self.date), 1, 1, true);
		AchievementFrameAchievements_CheckGuildMembersTooltip(self);
		GameTooltip:Show();
	end
end

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
	if ( IN_GUILD_VIEW ) then
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
	AchievementFrame.searchPreviewContainer:Hide();

	for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
		AchievementFrame.searchPreview[index]:Hide();
	end

	AchievementFrame.showAllSearchResults:Hide();
	AchievementFrame.searchProgressBar:Hide();
end

function AchievementFrame_UpdateSearchPreview()
	if ( not AchievementFrame.searchBox:HasFocus() or strlen(AchievementFrame.searchBox:GetText()) < MIN_CHARACTER_SEARCH) then
		AchievementFrame_HideSearchPreview();
		return;
	end

	AchievementFrame.searchBox.searchPreviewUpdateDelay = 0;

	if ( AchievementFrame.searchBox:GetScript("OnUpdate") == nil ) then
		AchievementFrame.searchBox:SetScript("OnUpdate", AchievementFrameSearchBox_OnUpdate);
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

			for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
				AchievementFrame.searchPreview[index]:Hide();
			end

			AchievementFrame.showAllSearchResults:Hide();

			AchievementFrame.searchPreviewContainer.borderAnchor:SetPoint("BOTTOM", 0, -5);
			AchievementFrame.searchPreviewContainer.background:Show();
			AchievementFrame.searchPreviewContainer:Show();

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

	local lastButton;
	for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
		local searchPreview = AchievementFrame.searchPreview[index];
		if ( index <= numResults ) then
			local achievementID = GetFilteredAchievementID(index);
			local _, name, _, _, _, _, _, description, _, icon, _, _, _, _ = GetAchievementInfo(achievementID);
			searchPreview.name:SetText(name);
			searchPreview.icon:SetTexture(icon);
			searchPreview.achievementID = achievementID;
			searchPreview:Show();
			lastButton = searchPreview;
		else
			searchPreview.achievementID = nil;
			searchPreview:Hide();
		end
	end

	if ( numResults > 5 ) then
		AchievementFrame.showAllSearchResults:Show();
		lastButton = AchievementFrame.showAllSearchResults;
		AchievementFrame.showAllSearchResults.text:SetText(string.format(ENCOUNTER_JOURNAL_SHOW_SEARCH_RESULTS, numResults));
	else
		AchievementFrame.showAllSearchResults:Hide();
	end

	if (lastButton) then
		AchievementFrame.searchPreviewContainer.borderAnchor:SetPoint("BOTTOM", lastButton, "BOTTOM", 0, -5);
		AchievementFrame.searchPreviewContainer.background:Hide();
		AchievementFrame.searchPreviewContainer:Show();
	else
		AchievementFrame.searchPreviewContainer:Hide();
	end
end

function AchievementFrameSearchBox_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);

	if ( strlen(self:GetText()) >= MIN_CHARACTER_SEARCH ) then
		AchievementFrame.searchBox.fullSearchFinished = SetAchievementSearchString(self:GetText());
		if ( not AchievementFrame.searchBox.fullSearchFinished ) then
			AchievementFrame_UpdateSearchPreview();
		else
			AchievementFrame_ShowSearchPreviewResults();
		end
	else
		AchievementFrame_HideSearchPreview();
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

	if ( self.selectedIndex == ACHIEVEMENT_FRAME_SHOW_ALL_RESULTS_INDEX ) then
		if ( AchievementFrame.showAllSearchResults:IsShown() ) then
			AchievementFrame.showAllSearchResults:Click();
		end
	else
		local preview = AchievementFrame.searchPreview[self.selectedIndex];
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
	AchievementFrame.searchResults:Hide();
	AchievementFrame_UpdateSearchPreview();
end

function AchievementFrameSearchBox_OnKeyDown(self, key)
	if ( key == "UP" ) then
		AchievementFrame_SetSearchPreviewSelection(AchievementFrame.searchBox.selectedIndex - 1);
	elseif ( key == "DOWN" ) then
		AchievementFrame_SetSearchPreviewSelection(AchievementFrame.searchBox.selectedIndex + 1);
	end
end

function AchievementFrame_SetSearchPreviewSelection(selectedIndex)
	local numShown = 0;
	for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
		AchievementFrame.searchPreview[index].selectedTexture:Hide();

		if ( AchievementFrame.searchPreview[index]:IsShown() ) then
			numShown = numShown + 1;
		end
	end

	if ( AchievementFrame.showAllSearchResults:IsShown() ) then
		numShown = numShown + 1;
	end

	AchievementFrame.showAllSearchResults.selectedTexture:Hide();
	
	if ( numShown <= 0 ) then
		-- Default to the first entry.
		selectedIndex = 1;
	else
		selectedIndex = (selectedIndex - 1) % numShown + 1;
	end

	AchievementFrame.searchBox.selectedIndex = selectedIndex;

	if ( selectedIndex == ACHIEVEMENT_FRAME_SHOW_ALL_RESULTS_INDEX ) then
		AchievementFrame.showAllSearchResults.selectedTexture:Show();
	else
		AchievementFrame.searchPreview[selectedIndex].selectedTexture:Show();
	end
end

function AcheivementFullSearchResultsButton_OnClick(self)
	if (self.achievementID) then
		AchievementFrame_SelectSearchItem(self.achievementID);
		AchievementFrame.searchResults:Hide();
	end
end

function AchievementFrame_ShowFullSearch()
	AchievementFrame_UpdateFullSearchResults();

	if ( GetNumFilteredAchievements() == 0 ) then
		AchievementFrame.searchResults:Hide();
		return;
	end

	AchievementFrame_HideSearchPreview();
	AchievementFrame.searchBox:ClearFocus();
	AchievementFrame.searchResults:Show();
end

function AchievementFrame_UpdateFullSearchResults()
	local numResults = GetNumFilteredAchievements();

	local scrollFrame = AchievementFrame.searchResults.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local results = scrollFrame.buttons;
	local result, index;

	for i = 1,#results do
		result = results[i];
		index = offset + i;
		if ( index <= numResults ) then
			local achievementID = GetFilteredAchievementID(index);
			local _, name, _, completed, _, _, _, description, _, icon, _, _, _, _ = GetAchievementInfo(achievementID);

			result.name:SetText(name);
			result.icon:SetTexture(icon);
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

			result:Show();
		else
			result:Hide();
		end
	end

	local totalHeight = numResults * 49;
	HybridScrollFrame_Update(scrollFrame, totalHeight, 270);

	AchievementFrame.searchResults.titleText:SetText(string.format(ENCOUNTER_JOURNAL_SEARCH_RESULTS, AchievementFrame.searchBox:GetText(), numResults));
end

function AchievementFrame_SelectSearchItem(id)
	local isStatistic = select(15, GetAchievementInfo(id));
	if ( isStatistic ) then
		AchievementFrame_SelectStatisticByAchievementID(id, AchievementFrameComparison:IsShown());
	else
		AchievementFrame_SelectAchievement(id, true, AchievementFrameComparison:IsShown());
	end
end

function AchievementSearchPreviewButton_OnShow(self)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10);
end

function AchievementSearchPreviewButton_OnLoad(self)
	for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
		if ( AchievementFrame.searchPreview[index] == self ) then
			self.previewIndex = index;
		end
	end
end

function AchievementSearchPreviewButton_OnEnter(self)
	AchievementFrame_SetSearchPreviewSelection(self.previewIndex);
end

function AchievementSearchPreviewButton_OnClick(self)
	if ( self.achievementID ) then
		AchievementFrame_SelectSearchItem(self.achievementID);
		AchievementFrame.searchResults:Hide();
		AchievementFrame_HideSearchPreview();
		AchievementFrame.searchBox:ClearFocus();
	end
end

function AchievementFrameShowAllSearchResults_OnEnter()
	AchievementFrame_SetSearchPreviewSelection(ACHIEVEMENT_FRAME_SHOW_ALL_RESULTS_INDEX);
end

function AchievementFrame_UpdateSearch(self)
	if ( AchievementFrame.searchResults:IsShown() ) then
		AchievementFrame_UpdateFullSearchResults();
	else
		AchievementFrame_UpdateSearchPreview();
	end
end