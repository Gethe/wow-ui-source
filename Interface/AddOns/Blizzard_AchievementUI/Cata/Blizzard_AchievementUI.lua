local ACHIEVEMENTUI_FONTHEIGHT;						-- set in AchievementButton_OnLoad
ACHIEVEMENTUI_CRITERIACHECKWIDTH = 20;

ACHIEVEMENTUI_SUMMARYCATEGORIES = {92, 96, 97, 95, 168, 169, 201, 155};
ACHIEVEMENTUI_DEFAULTGUILDSUMMARYACHIEVEMENTS = {5362, 4860, 4989, 4947};
ACHIEVEMENTUI_GUILDSUMMARYCATEGORIES = {15088, 15077, 15078, 15079, 15080, 15089};

local GUILD_FEAT_OF_STRENGTH_ID = 15093;
local GUILD_CATEGORY_ID = 15076;
local IN_GUILD_VIEW;
local TEXTURES_OFFSET = 0;		-- 0.5 when in guild view

local displayStatCategories = {};

local guildMemberRequestFrame;

-- [[ AchievementFrame ]] --

function AchievementFrame_ToggleAchievementFrame(toggleStatFrame)
	AchievementFrameComparison:Hide();
	AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
	if ( not toggleStatFrame ) then
		if ( AchievementFrame:IsShown() and AchievementFrame.selectedTab == 1 ) then
			HideUIPanel(AchievementFrame);
		else
			AchievementFrame_SetTabs();
			ShowUIPanel(AchievementFrame);
			AchievementFrameTab_OnClick(1);
		end
		return;
	end
	if ( AchievementFrame:IsShown() and AchievementFrame.selectedTab == 3 ) then
		HideUIPanel(AchievementFrame);
	else
		AchievementFrame_SetTabs();
		ShowUIPanel(AchievementFrame);
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
	self.trackedAchievements = {};
	self.criteriaTable = {};
	self.miniTable = {};
	self.progressBarTable = {};
	self.metaCriteriaTable = {};
	self.displayCategories = {};
	PanelTemplates_UpdateTabs(self);

	local function IsFilterSelected(filter)
		return ACHIEVEMENTUI_SELECTEDFILTER == filter.func;
	end

	local function SetFilterSelected(filter)
		if filter.func ~= ACHIEVEMENTUI_SELECTEDFILTER then
			ACHIEVEMENTUI_SELECTEDFILTER = filter.func;
			AchievementFrameAchievements_ForceUpdate();
		end
	end

	AchievementFrameFilterDropdown:SetWidth(112);
	AchievementFrameFilterDropdown:SetFrameLevel(AchievementFrameFilterDropdown:GetFrameLevel() + 1);
	AchievementFrameFilterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_ACHIEVEMENT_FILTER", block);

		for i, filter in ipairs(AchievementFrameFilters) do
			rootDescription:CreateRadio(filter.text, IsFilterSelected, SetFilterSelected, filter);
		end
	end);

	AchievementFrame_ShowSubFrame(AchievementFrameSummary);
	AchievementFrameSummary.forceOnShow = AchievementFrameSummary_OnShow;
	AchievementFrameAchievements.forceOnShow = AchievementFrameAchievements_OnShow;
end

function AchievementFrame_SetTabs()
	if ( not IsInGuild() or AchievementFrameComparison:IsShown() ) then
		AchievementFrameTab2:Hide();
		AchievementFrameTab3:SetPoint("LEFT", AchievementFrameTab1, "RIGHT", -5, 0);
	else
		AchievementFrameTab2:Show();
		AchievementFrameTab3:SetPoint("LEFT", AchievementFrameTab2, "RIGHT", -5, 0);
	end
end

function AchievementFrame_UpdateTabs(clickedTab)
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
	AchievementFrameHeaderPoints:SetText(GetTotalAchievementPoints(IN_GUILD_VIEW));
end

function AchievementFrameBaseTab_OnClick (id)
	AchievementFrame_UpdateTabs(id);
	
	local isSummary = false
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
		AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES);
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
end

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
	else
		achievementFunctions = COMPARISON_STAT_FUNCTIONS;
		AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonStatsContainer);
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-StatWatermark");
	end
	AchievementFrameCategoriesBG:SetTexCoord(0, 0.5, 0, 1);
	AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES);
	AchievementFrameCategories_Update();
	PanelTemplates_Tab_OnClick(_G["AchievementFrameTab"..id], AchievementFrame);
	AchievementFrame_UpdateTabs(id);

	achievementFunctions.updateFunc();
end

local subFramesList;
local function GetOrCreateAchievementSubFramesList()
	if not subFramesList then
		subFramesList = {
			AchievementFrameSummary,
			AchievementFrameAchievements,
			AchievementFrameStats,
			AchievementFrameComparison,
			AchievementFrameComparisonContainer,
			AchievementFrameComparisonStatsContainer
		};
	end
	return subFramesList;
end

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
	self:SetBackdropBorderColor(ACHIEVEMENT_GOLD_BORDER_COLOR:GetRGB());
	self.buttons = {};
	self:RegisterEvent("ADDON_LOADED");
	self:SetScript("OnEvent", AchievementFrameCategories_OnEvent);
end

function AchievementFrameCategories_GetCategoryList (categories)
	local cats = achievementFunctions.categoryAccessor();
	
	for i in next, categories do
		categories[i] = nil;
	end
	-- Insert the fake Summary category
	tinsert(categories, { ["id"] = "summary" });

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
	for _, categoryButton in next, buttons do
		categoryButton.isSelected = nil;
	end
	
	button.isSelected = true;
	
	if ( id == achievementFunctions.selectedCategory ) then
		-- If this category was selected already, bail after changing collapsed states
		return
	end
	
	--Intercept "summary" category
	if ( id == "summary" ) then
		if ( achievementFunctions == ACHIEVEMENT_FUNCTIONS or achievementFunctions == GUILD_ACHIEVEMENT_FUNCTIONS) then
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
			AchievementFrameStatsContainerScrollBar:SetValue(0);
		elseif ( achievementFunctions == ACHIEVEMENT_FUNCTIONS or achievementFunctions == GUILD_ACHIEVEMENT_FUNCTIONS) then
			AchievementFrame_ShowSubFrame(AchievementFrameAchievements);
			AchievementFrameAchievementsContainerScrollBar:SetValue(0);
			if ( id == FEAT_OF_STRENGTH_ID or id == GUILD_FEAT_OF_STRENGTH_ID) then
				AchievementFrameFilterDropdown:Hide();
				AchievementFrameHeaderRightDDLInset:Hide();
			else
				AchievementFrameFilterDropdown:Show();
				AchievementFrameHeaderRightDDLInset:Show();
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
		AchievementFrameFilterDropdown:Hide();
		AchievementFrameHeaderRightDDLInset:Hide();
	else
		AchievementFrameFilterDropdown:Show();
		AchievementFrameHeaderRightDDLInset:Show();	
	end
end

-- [[ AchievementCategoryButton ]] --

function AchievementCategoryButton_OnLoad (button)
	button:EnableMouse(true);
	button:EnableMouseWheel(true);
	AchievementCategoryButton_Localize(button);
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
	if ( event == "ADDON_LOADED" ) then
		self:RegisterEvent("ACHIEVEMENT_EARNED");
		self:RegisterEvent("CRITERIA_UPDATE");
		self:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED");
		self:RegisterEvent("RECEIVED_ACHIEVEMENT_MEMBER_LIST");
		
		AchievementFrame_UpdateTrackedAchievements(GetTrackedAchievements());
	elseif ( event == "ACHIEVEMENT_EARNED" and self:IsVisible()) then
		local achievementID = ...;
		AchievementFrameCategories_Update();
		AchievementFrameCategories_UpdateTooltip();
		-- This has to happen before AchievementFrameAchievements_ForceUpdate() in order to achieve the behavior we want, since it clears the selection for progressive achievements.
		local selection = AchievementFrameAchievements.selection;
		AchievementFrameAchievements_ForceUpdate();
		if ( AchievementFrameAchievementsContainer:IsShown() and selection == achievementID ) then
			AchievementFrame_SelectAchievement(selection, true);
		end
		AchievementFrameHeaderPoints:SetText(GetTotalAchievementPoints(IN_GUILD_VIEW));

	elseif ( event == "CRITERIA_UPDATE" and self:IsVisible() ) then
		if ( AchievementFrameAchievements.selection) then
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
		for k, v in next, AchievementFrame.trackedAchievements do
			AchievementFrame.trackedAchievements[k] = nil;
		end
		
		AchievementFrame_UpdateTrackedAchievements(GetTrackedAchievements());
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
	end
	
	
	if ( not AchievementMicroButton:IsShown() ) then
		AchievementMicroButton_Update();
	end
end

function AchievementFrameAchievementsBackdrop_OnLoad (self)
	self:SetBackdropBorderColor(ACHIEVEMENT_GOLD_BORDER_COLOR:GetRGB());
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

function AchievementFrameAchievements_ToggleView()
	if ( AchievementFrameAchievements.guildView ) then
		AchievementFrameAchievements.guildView = nil;
		for _, button in next, AchievementFrameAchievementsContainer.buttons do
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
			local bottomTsunami = _G[name.."BottomTsunami1"];
			bottomTsunami:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			bottomTsunami:SetTexCoord(0, 0.72265, 0.51953125, 0.58203125);
			bottomTsunami:SetAlpha(0.35);
			local topTsunami = _G[name.."TopTsunami1"];
			topTsunami:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			topTsunami:SetTexCoord(0.72265, 0, 0.58203125, 0.51953125);
			topTsunami:SetAlpha(0.3);
			-- glow
			button.glow:SetTexCoord(0, 1, 0.00390625, 0.25390625);
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
			local bottomTsunami = _G[name.."BottomTsunami1"];
			bottomTsunami:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			bottomTsunami:SetTexCoord(0, 0.72265, 0.58984375, 0.65234375);
			bottomTsunami:SetAlpha(0.2);
			local topTsunami = _G[name.."TopTsunami1"];
			topTsunami:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			topTsunami:SetTexCoord(0.72265, 0, 0.65234375, 0.58984375);
			topTsunami:SetAlpha(0.15);
			-- glow
			button.glow:SetTexCoord(0, 1, 0.26171875, 0.51171875);
		end
	end
	AchievementFrameAchievementsContainerScrollBar:SetValue(0);
	AchievementFrameAchievements_Update();
end

-- [[ Achievement Icon ]] --

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

-- [[ AchievementButton ]] --
GUILDACHIEVEMENTBUTTON_MINHEIGHT = 128;

function AchievementButton_UpdatePlusMinusTexture (button)
	local id = button.id;
	if ( not id ) then
		return; -- This happens when we create buttons
	end
	local display = false;
	local crit = GetAchievementNumCriteria(id);
	if ( crit ~= 0 ) then
		display = true;
	elseif ( button.completed and GetPreviousAchievement(id) ) then
		display = true;
	elseif ( not button.completed and GetAchievementGuildRep(id) ) then
		display = true;
	end
	
	if ( display ) then
		button.plusMinus:Show();			
		if ( button.collapsed and button.saturated ) then
			button.plusMinus:SetTexCoord(0, .5, TEXTURES_OFFSET, TEXTURES_OFFSET + 0.25);
		elseif ( button.collapsed ) then
			button.plusMinus:SetTexCoord(.5, 1, TEXTURES_OFFSET, TEXTURES_OFFSET + 0.25);
		elseif ( button.saturated ) then
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
	if ( not self.collapsed ) then
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
		self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
		self.shield.points:SetVertexColor(0, 1, 0);
		self.saturatedStyle = "guild";
	else
		self.background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
		if ( self.accountWide ) then
			self.titleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
			self.titleBar:SetTexCoord(0, 1, 0, 0.375);
			self:SetBackdropBorderColor(ACHIEVEMENT_BLUE_BORDER_COLOR:GetRGB());
			self.saturatedStyle = "account";
		else
			self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			self.titleBar:SetTexCoord(0, 1, 0.66015625, 0.73828125);
			self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
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
	self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
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
	
	self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
	self.Collapse = AchievementButton_Collapse;
	self.Expand = AchievementButton_Expand;
	self.Saturate = AchievementButton_Saturate;
	self.Desaturate = AchievementButton_Desaturate;
	
	self:Collapse();
	self:Desaturate();
	
	AchievementFrameAchievements.buttons = AchievementFrameAchievements.buttons or {};
	tinsert(AchievementFrameAchievements.buttons, self);
end

function AchievementButton_OnClick (self, button, down, ignoreModifiers)
	if(IsModifiedClick() and not ignoreModifiers) then
		if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
			local achievementLink = GetAchievementLink(self.id);
			if ( achievementLink ) then
				ChatEdit_InsertLink(achievementLink);
			end
		elseif ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
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
	if ( AchievementFrame.trackedAchievements[id] ) then
		RemoveTrackedAchievement(id);
		AchievementFrameAchievements_ForceUpdate();
		WatchFrame_Update();
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
	WatchFrame_Update();
	
	return true;
end
	
function AchievementButton_DisplayAchievement (button, category, achievement, selectionID)
	local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(category, achievement);
	if ( not id ) then
		button:Hide();
		return;
	else
		button:Show();
	end

	button.index = achievement;
	button.element = true;
	
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
	
	if ( button.id ~= id ) then
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
		if ( (completed and not button.completed) or wasEarnedByMe) then
			button.completed = true;
			button.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
			button.dateCompleted:Show();
			if ( button.saturatedStyle ~= saturatedStyle ) then
				button:Saturate();
			end
		elseif ( completed ) then
			button.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
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
		local height = AchievementButton_DisplayObjectives(button, button.id, button.completed);
		if ( height == ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT ) then
			button:Collapse();
		else
			button:Expand(height);
		end
		if ( not completed ) then
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

function AchievementButton_DisplayObjectives (button, id, completed)
	local objectives = AchievementFrameAchievementsObjectives;
	local topAnchor = button.hiddenDescription;
	objectives:ClearAllPoints();
	objectives:SetParent(button);
	objectives:Show();
	objectives.completed = completed;
	local height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT;
	if ( objectives.id == id ) then
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
		AchievementButton_ResetCriteria();
		AchievementButton_ResetProgressBars();
		AchievementButton_ResetMiniAchievements();
		AchievementButton_ResetMetas();
		AchievementObjectives_DisplayProgressiveAchievement(objectives, id);
		objectives:SetPoint("TOP", topAnchor, "BOTTOM", 0, -8);
	else
		objectives:SetHeight(0);	
		AchievementButton_ResetCriteria();
		AchievementButton_ResetProgressBars();
		AchievementButton_ResetMiniAchievements();
		AchievementButton_ResetMetas();
		AchievementObjectives_DisplayCriteria(objectives, id);
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
	
	objectives.id = id;
	return height;
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
	
	if ( IN_GUILD_VIEW ) then
		frame.Border:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
		frame.Border:SetTexCoord(0.89062500, 0.97070313, 0.00195313, 0.08203125);
	else
		frame.Border:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Progressive-IconBorder");
		frame.Border:SetTexCoord(0, 0.65625, 0, 0.65625);
	end

	return frame;
end

function AchievementButton_ResetCriteria ()
	AchievementFrameAchievementsObjectives.repCriteria:Hide();
	AchievementButton_ResetTable(AchievementFrame.criteriaTable);
end

function AchievementButton_GetMeta (index)
	local metaCriteriaTable = AchievementFrame.metaCriteriaTable;
	if ( not metaCriteriaTable[index] ) then
		local frame = CreateFrame("BUTTON", "AchievementFrameMeta" .. index, AchievementFrameAchievements, "MetaCriteriaTemplate");
		AchievementButton_LocalizeMetaAchievement(frame);
		metaCriteriaTable[index] = frame;
	end
	
	if ( metaCriteriaTable[index].guildView ~= IN_GUILD_VIEW ) then
		AchievementButton_ToggleMetaView(metaCriteriaTable[index]);
	end
	return metaCriteriaTable[index];
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

local achievementList = {};

function AchievementObjectives_DisplayProgressiveAchievement (objectivesFrame, id)
	local ACHIEVEMENTMODE_PROGRESSIVE = 2;
	local baseAchievementID = id;

	local achievementList = achievementList;
	for i in next, achievementList do
		achievementList[i] = nil;
	end
	
	tinsert(achievementList, 1, baseAchievementID);
	while GetPreviousAchievement(baseAchievementID) do
		tinsert(achievementList, 1, GetPreviousAchievement(baseAchievementID));
		baseAchievementID = GetPreviousAchievement(baseAchievementID);
	end
	
	local i = 0;
	for index, achievementID in ipairs(achievementList) do
		local _, achievementName, points, completed, month, day, year, description, flags, iconpath = GetAchievementInfo(achievementID);
		flags = flags or 0;		-- bug 360115. grabbed from mainline to avoid future issues
		local miniAchievement = AchievementButton_GetMiniAchievement(index);
		
		miniAchievement:Show();
		miniAchievement:SetParent(objectivesFrame);
		miniAchievement.icon:SetTexture(iconpath);
		if ( index == 1 ) then
			miniAchievement:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", -4, -4);
		elseif ( index == 7 ) then
			miniAchievement:SetPoint("TOPLEFT", AchievementFrame.miniTable[1], "BOTTOMLEFT", 0, -8);
		else
			miniAchievement:SetPoint("TOPLEFT", AchievementFrame.miniTable[index-1], "TOPRIGHT", 4, 0);
		end
		
		miniAchievement.points:SetText(points);
		
		miniAchievement.numCriteria = 0;
		if ( bit.band(flags, ACHIEVEMENT_FLAGS_HAS_PROGRESS_BAR) ~= ACHIEVEMENT_FLAGS_HAS_PROGRESS_BAR ) then
			for j = 1, GetAchievementNumCriteria(achievementID) do
				local criteriaString, criteriaType, criteriaCompleted = GetAchievementCriteriaInfo(achievementID, j);
				if ( criteriaCompleted == false ) then
					criteriaString = "|CFF808080 - " .. criteriaString;
				else
					criteriaString = "|CFF00FF00 - " .. criteriaString;
				end
				miniAchievement["criteria" .. j] = criteriaString;
				miniAchievement.numCriteria = j;
			end
		end
		miniAchievement.name = achievementName;
		miniAchievement.desc = description;
		if ( month ) then
			miniAchievement.date = string.format(SHORTDATE, day, month, year);
		end
		i = index;
	end
	
	objectivesFrame:SetHeight(math.ceil(i/6) * ACHIEVEMENTUI_PROGRESSIVEHEIGHT);
	objectivesFrame:SetWidth(min(i, 6) * ACHIEVEMENTUI_PROGRESSIVEWIDTH);
	objectivesFrame.mode = ACHIEVEMENTMODE_PROGRESSIVE;
end

function AchievementObjectives_DisplayCriteria (objectivesFrame, id)
	if ( not id ) then
		return;
	end

	local initialOffset = 0;
	local ACHIEVEMENTMODE_CRITERIA = 1;
	local numCriteria = GetAchievementNumCriteria(id);
	local numRows = 0;
	local extraRows = 0;

	local requiresRep, hasRep, repLevel;
	if ( not objectivesFrame.completed ) then
		requiresRep, hasRep, repLevel = GetAchievementGuildRep(id);
		if ( requiresRep ) then
			initialOffset = -ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT;
			local gender = UnitSex("player");
			local factionStandingtext = GetText("FACTION_STANDING_LABEL"..repLevel, gender);
			objectivesFrame.repCriteria:SetFormattedText(ACHIEVEMENT_REQUIRES_GUILD_REPUTATION, factionStandingtext);
			if ( hasRep ) then
				objectivesFrame.repCriteria:SetTextColor(0, 1, 0);
			else
				objectivesFrame.repCriteria:SetTextColor(1, 0, 0);
			end
			objectivesFrame.repCriteria:Show();
			extraRows = 1;
		end
	end

	if ( numCriteria == 0 and not requiresRep) then
		objectivesFrame.mode = ACHIEVEMENTMODE_CRITERIA;
		objectivesFrame:SetHeight(0);
		return;
	end

	-- text check width
	if ( not objectivesFrame.textCheckWidth ) then
		local criteria = AchievementButton_GetCriteria(1);
		criteria.name:SetText("- ");
		objectivesFrame.textCheckWidth = criteria.name:GetStringWidth();
	end
	
	
	local frameLevel = objectivesFrame:GetFrameLevel() + 1;
	
	-- Why textStrings? You try naming anything just "string" and see how happy you are.
	local textStrings, progressBars, metas = 0, 0, 0;
	
	local maxCriteriaWidth = 0;
	local yPos;
	for i = 1, numCriteria do	
		local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, criteriaFlags, assetID, quantityString = GetAchievementCriteriaInfo(id, i);
		
		if ( criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID ) then
			metas = metas + 1;
			local metaCriteria = AchievementButton_GetMeta(metas);
			
			if ( metas == 1 ) then
				metaCriteria:SetPoint("TOP", objectivesFrame, "TOP", 0, -4 + initialOffset);
				numRows = numRows + 2;
			elseif ( math.fmod(metas, 2) == 0 ) then
				yPos = -((metas/2 - 1) * 28) - 8;
				AchievementFrame.metaCriteriaTable[metas-1]:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 20, yPos + initialOffset);
				metaCriteria:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 210, yPos + initialOffset);
			else
				metaCriteria:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 20, -(math.ceil(metas/2 - 1) * 28) - 8 + initialOffset);
				numRows = numRows + 2;
			end
			
			local achievementId, achievementName, points, achievementCompleted, month, day, year, description, flags, iconpath = GetAchievementInfo(assetID);
			
			if ( month ) then
				metaCriteria.date = string.format(SHORTDATE, day, month, year);
			else
				metaCriteria.date = nil;
			end
			
			metaCriteria.id = achievementId;
			metaCriteria.label:SetText(achievementName);
			metaCriteria.icon:SetTexture(iconpath);

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
		elseif ( bit.band(criteriaFlags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR ) then
			-- Display this criteria as a progress bar!
			progressBars = progressBars + 1;
			local progressBar = AchievementButton_GetProgressBar(progressBars);
			
			if ( progressBars == 1 ) then
				progressBar:SetPoint("TOP", objectivesFrame, "TOP", 4, -4 + initialOffset);
			else
				progressBar:SetPoint("TOP", AchievementFrame.progressBarTable[progressBars-1], "BOTTOM", 0, 0);
			end
			
			progressBar.text:SetText(string.format("%s", quantityString));
			progressBar:SetMinMaxValues(0, reqQuantity);
			progressBar:SetValue(quantity);
			
			progressBar:SetParent(objectivesFrame);
			progressBar:Show();
			
			numRows = numRows + 1;
		else
			textStrings = textStrings + 1;
			local criteria = AchievementButton_GetCriteria(textStrings);
			criteria:ClearAllPoints();
			if ( textStrings == 1 ) then
				if ( numCriteria == 1 ) then
					criteria:SetPoint("TOP", objectivesFrame, "TOP", -14, initialOffset);
				else
					criteria:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 0, initialOffset);
				end
				
			else
				criteria:SetPoint("TOPLEFT", AchievementFrame.criteriaTable[textStrings-1], "BOTTOMLEFT", 0, 0);
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
			if ( completed ) then
				criteria.check:SetPoint("LEFT", 18, -3);
				criteria.name:SetPoint("LEFT", criteria.check, "RIGHT", 0, 2);
				criteria.check:Show();
				criteria.name:SetText(criteriaString);
				stringWidth = criteria.name:GetStringWidth();
			else
				criteria.check:SetPoint("LEFT", 0, -3);
				criteria.name:SetPoint("LEFT", criteria.check, "RIGHT", 5, 2);
				criteria.check:Hide();
				if( criteriaString ~= '') then
					criteria.name:SetText("- "..criteriaString);
				else
					criteria.name:SetText("  ");
				end
				stringWidth = criteria.name:GetStringWidth() - objectivesFrame.textCheckWidth;	-- don't want the "- " to be included in the width
			end
				
			criteria:SetParent(objectivesFrame);
			criteria:Show();
			criteria:SetWidth(stringWidth + ACHIEVEMENTUI_CRITERIACHECKWIDTH);
			maxCriteriaWidth = max(maxCriteriaWidth, stringWidth + ACHIEVEMENTUI_CRITERIACHECKWIDTH);

			numRows = numRows + 1;
		end
	end

	if ( textStrings > 0 and progressBars > 0 ) then
		-- If we have text criteria and progressBar criteria, display the progressBar criteria first and position the textStrings under them.
		AchievementFrame.criteriaTable[1]:ClearAllPoints();
		if ( textStrings == 1 ) then
			AchievementFrame.criteriaTable[1]:SetPoint("TOP", AchievementFrame.progressBarTable[progressBars], "BOTTOM", -14, -4);
		else
			AchievementFrame.criteriaTable[1]:SetPoint("TOP", AchievementFrame.progressBarTable[progressBars], "BOTTOM", 0, -4);
			AchievementFrame.criteriaTable[1]:SetPoint("LEFT", objectivesFrame, "LEFT", 0, 0);
		end		
	elseif ( textStrings > 1 ) then
		-- Figure out if we can make multiple columns worth of criteria instead of one long one
		local numColumns = floor(ACHIEVEMENTUI_MAXCONTENTWIDTH/maxCriteriaWidth);
		if ( numColumns > 1 ) then
			local step;
			local rows = 1;
			local position = 0;
			for i=1, #AchievementFrame.criteriaTable do
				position = position + 1;
				if ( position > numColumns ) then
					position = position - numColumns;
					rows = rows + 1;
				end
				
				if ( rows == 1 ) then
					AchievementFrame.criteriaTable[i]:ClearAllPoints();
					AchievementFrame.criteriaTable[i]:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", (position - 1)*(ACHIEVEMENTUI_MAXCONTENTWIDTH/numColumns), initialOffset);
				else
					AchievementFrame.criteriaTable[i]:ClearAllPoints();
					AchievementFrame.criteriaTable[i]:SetPoint("TOPLEFT", AchievementFrame.criteriaTable[position + ((rows - 2) * numColumns)], "BOTTOMLEFT", 0, 0);
				end
			end
			numRows = ceil(numRows/numColumns);
		end
	end

	numRows = numRows + extraRows;
	if ( metas > 0 or progressBars > 0) then
		objectivesFrame:SetHeight(numRows * ACHIEVEMENTBUTTON_METAROWHEIGHT + 10);
	else
		objectivesFrame:SetHeight(numRows * ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT);
	end
	objectivesFrame.mode = ACHIEVEMENTMODE_CRITERIA;
end

-- [[ StatsFrames ]]--

function AchievementStatButton_OnLoad(self, parentFrame)
	self.value:SetVertexColor(1, 0.97, 0.6);
	parentFrame.buttons = parentFrame.buttons or {};
	tinsert(parentFrame.buttons, self);
end

-- [[ Summary Frame ]] --
function AchievementFrameSummary_OnShow()
	if ( achievementFunctions ~= COMPARISON_ACHIEVEMENT_FUNCTIONS and achievementFunctions ~= COMPARISON_STAT_FUNCTIONS ) then
		if ( AchievementFrameSummary.guildView ~= IN_GUILD_VIEW ) then
			AchievementFrameSummary_ToggleView();
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
	-- categories
	for i = 1, 8 do
		local statusBar = _G["AchievementFrameSummaryCategoriesCategory"..i];
		if ( tCategories[i] ) then
			local categoryName = GetCategoryInfo(tCategories[i]);
			statusBar.label:SetText(categoryName);
			statusBar:Show();
			statusBar:SetID(tCategories[i]);
			AchievementFrameSummaryCategory_OnShow(statusBar);	-- to calculate progress
		else
			statusBar:Hide();
		end
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
			if ( AchievementFrameSummary.guildView ) then
				AchievementFrameSummaryAchievement_SetGuildTextures(button);
			end
			if ( not buttons ) then
				buttons = AchievementFrameSummaryAchievements.buttons;
			end
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
				button.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
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
			for j=defaultAchievementCount, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
				achievementID = tAchievements[defaultAchievementCount];
				if ( not achievementID ) then
					break;
				end
				id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID);
				if ( completed ) then
					defaultAchievementCount = defaultAchievementCount+1;
				else
					id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(achievementID);
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
						button.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
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
	AchievementFrameSummaryCategoriesStatusBarText:SetText(completed.."/"..total);
end

function AchievementFrameSummaryAchievement_OnLoad(self)
	AchievementComparisonPlayerButton_OnLoad(self);
	AchievementFrameSummaryAchievements.buttons = AchievementFrameSummaryAchievements.buttons or {};
	tinsert(AchievementFrameSummaryAchievements.buttons, self);
	self:Saturate();
	self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
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

function AchievementFrameSummaryCategory_OnLoad (self)
	self:SetMinMaxValues(0, 100);
	self:SetValue(0);
	
	local categoryName = GetCategoryInfo(self:GetID());
	self.label:SetText(categoryName);
end

function AchievementFrame_SelectAchievement(id, forceSelect)
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
	
	AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
	AchievementFrameTab_OnClick(tabIndex);
	AchievementFrameSummary:Hide();
	AchievementFrameAchievements:Show();

	-- Figure out if this is part of a progressive achievement; if it is and it's incomplete, make sure the previous level was completed. If not, find the first incomplete achievement in the chain and display that instead.
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
		local nextID;
		nextID, completed = GetNextAchievement(id);
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
	
	local shown, i = false, 1;
	while ( not shown ) do
		for _, button in next, AchievementFrameCategoriesContainer.buttons do
			if ( button.categoryID == category and math.ceil(button:GetBottom()) >= math.ceil(AchievementFrameAchievementsContainer:GetBottom())) then
				shown = true;
			end
		end
		
		if ( not shown ) then
			local _, maxVal = AchievementFrameCategoriesContainerScrollBar:GetMinMaxValues();
			if ( AchievementFrameCategoriesContainerScrollBar:GetValue() == maxVal ) then
				return;
			else
				HybridScrollFrame_OnMouseWheel(AchievementFrameCategoriesContainer, -1);
			end			
		end
		
		-- Remove me if everything's working fine
		i = i + 1;
		if ( i > 100 ) then
			return;
		end
	end		
	
	AchievementFrameAchievements_ClearSelection();	
	AchievementFrameAchievementsContainerScrollBar:SetValue(0);
	AchievementFrameAchievements_Update();
	
	shown = false;
	local previousScrollValue;
	while ( not shown ) do
		for _, button in next, AchievementFrameAchievementsContainer.buttons do
			if ( button.id == id and math.ceil(button:GetTop()) >= math.ceil(AchievementFrameAchievementsContainer:GetBottom())) then
				-- The "True" here ignores modifiers, so you don't accidentally track or link this achievement. :P
				AchievementButton_OnClick(button, nil, nil, true);
				
				-- We found the button!
				shown = button;
				break;
			end
		end			
		
		local _, maxVal = AchievementFrameAchievementsContainerScrollBar:GetMinMaxValues();
		if ( shown ) then
			-- If we can, move the achievement we're scrolling to to the top of the screen.
			local newHeight = AchievementFrameAchievementsContainerScrollBar:GetValue() + AchievementFrameAchievementsContainer:GetTop() - shown:GetTop();
			newHeight = min(newHeight, maxVal);
			AchievementFrameAchievementsContainerScrollBar:SetValue(newHeight);
		else
			local scrollValue = AchievementFrameAchievementsContainerScrollBar:GetValue();
			if ( scrollValue == maxVal or scrollValue == previousScrollValue ) then
				return;
			else
				previousScrollValue = scrollValue;
				HybridScrollFrame_OnMouseWheel(AchievementFrameAchievementsContainer, -1);
			end			
		end
	end
end

function AchievementFrame_SelectSummaryStatistic (criteriaId)
	AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
	AchievementFrameTab_OnClick(3);
	AchievementFrameStats:Show();
	AchievementFrameSummary:Hide();
	
	AchievementFrameCategories_ClearSelection();
	
	local id = GetAchievementInfoFromCriteria(criteriaId);
	local category = GetAchievementCategory(id);
	
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
	
	local shown, i = false, 1;
	while ( not shown ) do
		for _, button in next, AchievementFrameCategoriesContainer.buttons do
			if ( button.categoryID == category and math.ceil(button:GetBottom()) >= math.ceil(AchievementFrameAchievementsContainer:GetBottom())) then
				shown = true;
			end
		end
		
		if ( not shown ) then
			local _, maxVal = AchievementFrameCategoriesContainerScrollBar:GetMinMaxValues();
			if ( AchievementFrameCategoriesContainerScrollBar:GetValue() == maxVal ) then
				assert(false)
			else
				HybridScrollFrame_OnMouseWheel(AchievementFrameCategoriesContainer, -1);
			end			
		end
		
		-- Remove me if everything's working fine
		i = i + 1;
		if ( i > 100 ) then
			assert(false);
		end
	end		
	
	AchievementFrameStats_Update();
	AchievementFrameStatsContainerScrollBar:SetValue(0);
	
	shown, i = false, 1;
	while ( not shown ) do
		for _, button in next, AchievementFrameStatsContainer.buttons do
			if ( button.id == id and math.ceil(button:GetBottom()) >= math.ceil(AchievementFrameStatsContainer:GetBottom())) then
				AchievementStatButton_OnClick(button);
				
				-- We found the button! MAKE IT SHOWN ZOMG!
				shown = button;
			end
		end			
		
		if ( shown and AchievementFrameStatsContainerScrollBar:IsShown() ) then
			-- If we can, move the achievement we're scrolling to to the top of the screen.
			AchievementFrameStatsContainerScrollBar:SetValue(AchievementFrameStatsContainerScrollBar:GetValue() + AchievementFrameStatsContainer:GetTop() - shown:GetTop());
		elseif ( not shown ) then
			local _, maxVal = AchievementFrameStatsContainerScrollBar:GetMinMaxValues();
			if ( AchievementFrameStatsContainerScrollBar:GetValue() == maxVal ) then
				assert(false)
			else
				HybridScrollFrame_OnMouseWheel(AchievementFrameStatsContainer, -1);
			end			
		end
		
		-- Remove me if everything's working fine.
		i = i + 1;
		if ( i > 100 ) then
			assert(false);
		end
	end
end

function AchievementFrameComparison_OnLoad (self)
	AchievementFrameComparisonContainer_OnLoad(self);
	AchievementFrameComparisonStatsContainer_OnLoad(self);
	self:RegisterEvent("ACHIEVEMENT_EARNED");
	self:RegisterEvent("INSPECT_ACHIEVEMENT_READY");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
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
	if ( event == "INSPECT_ACHIEVEMENT_READY" ) then
		AchievementFrameComparisonHeaderPoints:SetText(GetComparisonAchievementPoints());
		AchievementFrameComparison_UpdateStatusBars(achievementFunctions.selectedCategory)
	elseif ( event == "UNIT_PORTRAIT_UPDATE" or event == "DISPLAY_SIZE_CHANGED" ) then
		local updateUnit = ...;
		if ( not updateUnit or UnitName(updateUnit) == AchievementFrameComparisonHeaderName:GetText() ) then
			SetPortraitTexture(AchievementFrameComparisonHeaderPortrait, "player");
		end
	end
	
	AchievementFrameComparison_ForceUpdate();
end

function AchievementFrameComparison_SetUnit (unit)
	ClearAchievementComparisonUnit();
	SetAchievementComparisonUnit(unit);
	
	AchievementFrameComparisonHeaderPoints:SetText(GetComparisonAchievementPoints());
	AchievementFrameComparisonHeaderName:SetText(UnitName(unit));
	SetPortraitTexture(AchievementFrameComparisonHeaderPortrait, "player");
	AchievementFrameComparisonHeaderPortrait.unit = unit;
	AchievementFrameComparisonHeaderPortrait.race = UnitRace(unit);
	AchievementFrameComparisonHeaderPortrait.sex = UnitSex(unit);
end

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
		
		if ( completed and not player.completed ) then
			player.completed = true;
			player.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
			player.dateCompleted:Show();
			if ( player.saturatedStyle ~= saturatedStyle ) then
				player:Saturate();
			end
		elseif ( completed ) then
			player.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
		else
			player.completed = nil;
			player.dateCompleted:Hide();
			player:Desaturate();
		end
		
		if ( friendCompleted and not friend.completed ) then
			friend.completed = true;
			friend.status:SetText(string.format(SHORTDATE, friendDay, friendMonth, friendYear));
			if ( friend.saturatedStyle ~= saturatedStyle ) then
				friend:Saturate();
			end
		elseif ( friendCompleted ) then
			friend.status:SetText(string.format(SHORTDATE, friendDay, friendMonth, friendYear));
		else
			friend.completed = nil;
			friend.status:SetText(INCOMPLETE);
			friend:Desaturate();
		end
	end
end

function AchievementFrameComparisonStat_OnLoad (self)
	self.value:SetVertexColor(1, 0.97, 0.6);
	self.friendValue:SetVertexColor(1, 0.97, 0.6);
end

function AchievementComparisonPlayerButton_Saturate (self)
	local name = self:GetName();
	if ( IN_GUILD_VIEW ) then
		self.background:SetTexture("Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal");
		self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.titleBar:SetTexCoord(0, 1, 0.83203125, 0.91015625);
		self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
		self.shield.points:SetVertexColor(0, 1, 0);
		self.saturatedStyle = "guild";
	else
		self.background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
		if ( self.accountWide ) then
			self.titleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
			self.titleBar:SetTexCoord(0, 1, 0, 0.375);
			self:SetBackdropBorderColor(ACHIEVEMENT_BLUE_BORDER_COLOR:GetRGB());
			self.saturatedStyle = "account";
		else
			self.shield.points:SetVertexColor(1, 1, 1);
			self.titleBar:SetTexCoord(0, 1, 0.66015625, 0.73828125);
			self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
			self.saturatedStyle = "normal";
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
	self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
	self.Saturate = AchievementComparisonPlayerButton_Saturate;
	self.Desaturate = AchievementComparisonPlayerButton_Desaturate;
	
	
	self.Saturate = AchievementComparisonPlayerButton_Saturate;
	self.Desaturate = AchievementComparisonPlayerButton_Desaturate;
	
	self:Desaturate();
end

function AchievementComparisonFriendButton_Saturate (self)
	if ( self.accountWide ) then
		self.titleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
		self.titleBar:SetTexCoord(0.3, 0.575, 0, 0.375);
		self.saturatedStyle = "account";
		self:SetBackdropBorderColor(ACHIEVEMENT_BLUE_BORDER_COLOR:GetRGB());
	else
		self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.titleBar:SetTexCoord(0.3, 0.575, 0.66015625, 0.73828125);
		self.saturatedStyle = "normal";
		self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
	end
	self.background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
	self.glow:SetVertexColor(1.0, 1.0, 1.0);
	self.icon:Saturate();
	self.shield:Saturate();
	self.shield.points:SetVertexColor(1, 1, 1);
	self.status:SetVertexColor(1, .82, 0);
	self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
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
	self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
	self.Saturate = AchievementComparisonFriendButton_Saturate;
	self.Desaturate = AchievementComparisonFriendButton_Desaturate;
	
	self:Desaturate();
end

function AchievementFrame_IsFeatOfStrength()
	if ( ( AchievementFrame.selectedTab == 1 or AchievementFrame.selectedTab == 2 ) and achievementFunctions.selectedCategory == AchievementFrame.displayCategories[#AchievementFrame.displayCategories].id ) then
		return true;
	end
	return false;
end

GUILD_ACHIEVEMENT_FUNCTIONS = {
	categoryAccessor = GetGuildCategoryList,
	clearFunc = AchievementFrameAchievements_ClearSelection,
	updateFunc = AchievementFrameAchievements_Update,
	selectedCategory = "summary";
}

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

--
-- Guild Members Display
--

function AchievementMeta_OnEnter(self)
	if ( self.date ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:AddLine(string.format(ACHIEVEMENT_META_COMPLETED_DATE, self.date), 1, 1, 1);
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