UIPanelWindows["AchievementFrame"] = { area = "doublewide", pushable = 0, width = 840, xoffset = 80, whileDead = 1 };

ACHIEVEMENTUI_CATEGORIES = {};

ACHIEVEMENTUI_GOLDBORDER_R = 1;
ACHIEVEMENTUI_GOLDBORDER_G = 0.675;
ACHIEVEMENTUI_GOLDBORDER_B = 0.125;
ACHIEVEMENTUI_GOLDBORDER_A = 1;

ACHIEVEMENTUI_REDBORDER_R = 0.7;
ACHIEVEMENTUI_REDBORDER_G = 0.15;
ACHIEVEMENTUI_REDBORDER_B = 0.05;
ACHIEVEMENTUI_REDBORDER_A = 1;

ACHIEVEMENTUI_CATEGORIESWIDTH = 175;

ACHIEVEMENTUI_PROGRESSIVEHEIGHT = 50;
ACHIEVEMENTUI_PROGRESSIVEWIDTH = 42;

ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS = 5;

ACHIEVEMENTUI_MAXCONTENTWIDTH = 330;

ACHIEVEMENTUI_DEFAULTSUMMARYACHIEVEMENTS = {6, 503, 116, 545, 1017};

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

-- [[ AchievementFrame ]] --

function AchievementFrame_ToggleAchievementFrame(toggleStatFrame)
	AchievementFrameComparison:Hide();
	AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
	if ( not toggleStatFrame ) then
		if ( AchievementFrame:IsShown() and AchievementFrame.selectedTab == 1 ) then
			HideUIPanel(AchievementFrame);
		else
			ShowUIPanel(AchievementFrame);
			AchievementFrameTab_OnClick(1);
		end
		return;
	end
	if ( AchievementFrame:IsShown() and AchievementFrame.selectedTab == 2 ) then
		HideUIPanel(AchievementFrame);
	else
		ShowUIPanel(AchievementFrame);
		AchievementFrameTab_OnClick(2);
	end
end

function AchievementFrame_DisplayComparison (unit)
	AchievementFrame.wasShown = nil;
	AchievementFrameTab_OnClick = AchievementFrameComparisonTab_OnClick;
	AchievementFrameTab_OnClick(1);
	ShowUIPanel(AchievementFrame);
	--AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameSummary);
	AchievementFrameComparison_SetUnit(unit);
	AchievementFrameComparison_ForceUpdate();
end

function AchievementFrame_OnLoad (self)
	PanelTemplates_SetNumTabs(self, 2);
	self.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
end

function AchievementFrame_OnShow (self)
	PlaySound("AchievementMenuOpen");
	AchievementFrameHeaderPoints:SetText(GetTotalAchievementPoints());
	if ( not AchievementFrame.wasShown ) then
		AchievementFrame.wasShown = true;
		AchievementCategoryButton_OnClick(AchievementFrameCategoriesContainerButton1);
	end
	UpdateMicroButtons();
	AchievementFrame_LoadTextures();
end

function AchievementFrame_OnHide (self)
	PlaySound("AchievementMenuClose");
	UpdateMicroButtons();
	AchievementFrame_ClearTextures();
end

function AchievementFrameBaseTab_OnClick (id)
	PanelTemplates_Tab_OnClick(getglobal("AchievementFrameTab"..id), AchievementFrame);
	
	local isSummary = false
	if ( id == 1 ) then
		achievementFunctions = ACHIEVEMENT_FUNCTIONS;
		if ( achievementFunctions.selectedCategory == "summary" ) then
			isSummary = true;
			AchievementFrame_ShowSubFrame(AchievementFrameSummary);
		else
			AchievementFrame_ShowSubFrame(AchievementFrameAchievements);
		end
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-AchievementWatermark");
	else
		achievementFunctions = STAT_FUNCTIONS;
		if ( achievementFunctions.selectedCategory == "summary" ) then
			isSummary = true;
			AchievementFrame_ShowSubFrame(AchievementFrameSummary);
		else
			AchievementFrame_ShowSubFrame(AchievementFrameStats);
		end
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-StatWatermark");
	end
	
	AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES);
	AchievementFrameCategories_Update();
	
	if ( not isSummary ) then
		achievementFunctions.updateFunc();
	end
end

AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;

function AchievementFrameComparisonTab_OnClick (id)
	if ( id == 1 ) then
		achievementFunctions = COMPARISON_ACHIEVEMENT_FUNCTIONS;
		AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonContainer);
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-AchievementWatermark");
	else
		achievementFunctions = COMPARISON_STAT_FUNCTIONS;
		AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonStatsContainer);
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-StatWatermark");
	end
	
	AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES);
	AchievementFrameCategories_Update();
	PanelTemplates_Tab_OnClick(getglobal("AchievementFrameTab"..id), AchievementFrame);
	
	achievementFunctions.updateFunc();
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
		subFrame = getglobal(name);
		show = false;
		for i=1, select("#", ...) do
			if ( subFrame ==  select(i, ...)) then
				show = true
			end
		end
		if ( show ) then
			subFrame:Show();
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
	-- Insert the fake Summary category
	tinsert(categories, { ["id"] = "summary" });

	for i, id in next, cats do
		local _, parent = GetCategoryInfo(id);
		if ( parent == -1 ) then
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
	
	HybridScrollFrame_Update(scrollFrame, numCategories, totalHeight, displayedHeight);
	
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
	-- kind of janky
	if ( element.id == "summary" ) then
		categoryName = ACHIEVEMENT_SUMMARY_CATEGORY;
		numAchievements, numCompleted = GetNumCompletedAchievements();
	else
		categoryName, parentID, flags = GetCategoryInfo(element.id);
		numAchievements, numCompleted = GetCategoryNumAchievements(element.id);
	end
	button.label:SetText(categoryName);
	button.categoryID = element.id;
	button.flags = flags;
	button.element = element;

	-- For the tooltip
	button.name = categoryName;
	if ( AchievementFrame_IsFeatOfStrength() ) then
		-- This is the feat of strength category since it's sorted to the end of the list
		button.text = FEAT_OF_STRENGTH_DESCRIPTION;
		button.showTooltipFunc = AchievementFrameCategory_FeatOfStrengthTooltip;
	elseif ( AchievementFrame.selectedTab == 1 or button.name == ACHIEVEMENT_SUMMARY_CATEGORY ) then
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
	GameTooltip:SetMinimumWidth(128, 1);
	GameTooltip:SetText(self.name, nil, nil, nil, nil, 1);
	GameTooltip_ShowStatusBar(GameTooltip, 0, self.numAchievements, self.numCompleted, self.numCompletedText);
	GameTooltip:Show();
end

function AchievementFrameCategory_ComparisonStatusBarTooltip(self)
	-- To be written once we have the info from Pat
end

function AchievementFrameCategory_FeatOfStrengthTooltip(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip:SetText(self.name, 1, 1, 1);
	GameTooltip:AddLine(self.text, nil, nil, nil, 1);
	GameTooltip:Show();
end

function AchievementFrameCategories_UpdateTooltip()
	if ( not AchievementFrameCategoriesContainer.buttons ) then
		return;
	end
	
	for _, button in next, AchievementFrameCategoriesContainer.buttons do
		if ( MouseIsOver(button) and button.showTooltipFunc ) then
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
	--Intercept "summary" category
	if ( id == "summary" ) then
		if ( achievementFunctions == STAT_FUNCTIONS or achievementFunctions == ACHIEVEMENT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameSummary);
			achievementFunctions.selectedCategory = id;
			return;
		elseif ( achievementFunctions == COMPARISON_ACHIEVEMENT_FUNCTIONS ) then
			-- Put the summary stuff for comparison here, Derek!
			AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonContainer);
			achievementFunctions.selectedCategory = ACHIEVEMENT_COMPARISON_SUMMARY_ID;
			AchievementFrameComparisonContainerScrollBar:SetValue(0);
			AchievementFrameCategories_SelectComparisonButton(button, ACHIEVEMENT_COMPARISON_SUMMARY_ID);
		elseif ( achievementFunctions == COMPARISON_STAT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonStatsContainer);
			achievementFunctions.selectedCategory = ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID;
			AchievementFrameComparisonStatsContainerScrollBar:SetValue(0);
		end
		
	else
		if ( achievementFunctions == STAT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameStats);
		elseif ( achievementFunctions == ACHIEVEMENT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameAchievements);
		elseif ( achievementFunctions == COMPARISON_ACHIEVEMENT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonContainer);
			AchievementFrameComparisonContainerScrollBar:SetValue(0);
			AchievementFrameCategories_SelectComparisonButton(button, id);
		else
			AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonStatsContainer);
			AchievementFrameComparisonStatsContainerScrollBar:SetValue(0);
		end
		achievementFunctions.selectedCategory = id;
	end
	
	if ( achievementFunctions.clearFunc ) then
		achievementFunctions.clearFunc();
	end
	achievementFunctions.updateFunc();
	
	AchievementFrameAchievementsContainerScrollBar:SetValue(0);
end

function AchievementFrameCategories_SelectComparisonButton (button, id)
	local numAchievements, numCompleted = GetCategoryNumAchievements(id);
	
	local statusBar = AchievementFrameComparisonSummaryPlayerStatusBar;
	statusBar:SetMinMaxValues(0, numAchievements);
	statusBar:SetValue(numCompleted);
	statusBar.title:SetText(string.format(ACHIEVEMENTS_COMPLETED_CATEGORY, button.name));
	statusBar.text:SetText(numCompleted.."/"..numAchievements);
	
	AchievementFrameComparison_UpdateFriendStatusBar(id);
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

function AchievementFrameComparison_UpdateFriendStatusBar (id)
	local numAchievements, numCompleted = GetCategoryNumAchievements(id);
	local friendCompleted = GetComparisonCategoryNumAchievements(id);

	local statusBar = AchievementFrameComparisonSummaryFriendStatusBar;
	statusBar:SetMinMaxValues(0, numAchievements);
	statusBar:SetValue(friendCompleted);
	statusBar.text:SetText(friendCompleted.."/"..numAchievements);
end

-- [[ AchievementCategoryButton ]] --

function AchievementCategoryButton_OnLoad (button)
	button:EnableMouse(true);
	button:EnableMouseWheel(true);
	
	local buttonName = button:GetName();
	
	button.label = getglobal(buttonName .. "Label");
	button.background = getglobal(buttonName.."Background");
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
			for _, button in next, AchievementFrameAchievements.buttons do
				button:SetWidth(496);
			end
			getmetatable(self).__index.Show(self);
		end
		
	AchievementFrameAchievementsContainerScrollBar.Hide = 
		function (self)
			AchievementFrameAchievements:SetWidth(527);
			for _, button in next, AchievementFrameAchievements.buttons do
				button:SetWidth(519);
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
	elseif ( event == "ACHIEVEMENT_EARNED" ) then
		local achievementID = ...;
		AchievementFrameCategories_Update();
		AchievementFrameCategories_UpdateTooltip();
		-- This has to happen before AchievementFrameAchievements_ForceUpdate() in order to achieve the behavior we want, since it clears the selection for progressive achievements.
		local selection = AchievementFrameAchievements.selection;
		AchievementFrameAchievements_ForceUpdate();
		if ( AchievementFrameAchievementsContainer:IsShown() and selection == achievementID ) then
			AchievementFrame_SelectAchievement(selection);
		end
		AchievementFrameHeaderPoints:SetText(GetTotalAchievementPoints());

	elseif ( event == "CRITERIA_UPDATE" ) then
		if ( AchievementFrameAchievements.selection ) then
			local id = AchievementFrameAchievementsObjectives.id;
			local button = AchievementFrameAchievementsObjectives:GetParent();
			AchievementFrameAchievementsObjectives.id = nil;
			AchievementButton_DisplayObjectives(button, id, button.completed);
		end
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
	local numAchievements, numCompleted = GetCategoryNumAchievements(category);
	local numButtons = #buttons;
	
	-- If the current category is feats of strength and there are no entries then show the explanation text
	if ( AchievementFrame_IsFeatOfStrength() and numAchievements == 0 ) then
		AchievementFrameAchievementsFeatOfStrengthText:Show();
	else
		AchievementFrameAchievementsFeatOfStrengthText:Hide();
	end
	
	local selection = AchievementFrameAchievements.selection;
	if ( selection ) then
		AchievementButton_ResetObjectives();
	end
	
	local extraHeight = scrollFrame.largeButtonHeight or ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT
	
	local displayedHeight = 0;
	for i = 1, numButtons do
		achievementIndex = i + offset;
		local id = AchievementButton_DisplayAchievement(buttons[i], category, achievementIndex, selection);
		displayedHeight = displayedHeight + buttons[i]:GetHeight();
	end
	
	local totalHeight = numAchievements * ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT;
	totalHeight = totalHeight + (extraHeight - ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT);
	
	HybridScrollFrame_Update(scrollFrame, numAchievements, totalHeight, displayedHeight);

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
	for _, button in next, AchievementFrameAchievements.buttons do
		button:Collapse();
		if ( not MouseIsOver(button) ) then
			button.highlight:Hide();
		end
		button.selected = nil;
		if ( not button.tracked:GetChecked() ) then
			button.tracked:Hide();
		end
	end
	
	AchievementFrameAchievements.selection = nil;
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
	local name = self:GetName();
	self.bling = getglobal(name .. "Bling");
	self.texture = getglobal(name .. "Texture");
	self.frame = getglobal(name .. "Overlay");
	
	self.Desaturate = AchievementIcon_Desaturate;
	self.Saturate = AchievementIcon_Saturate;
end

-- [[ Achievement Shield ]] --

function AchievementShield_Desaturate (self)
	self.icon:SetTexCoord(.5, 1, 0, 1);
end

function AchievementShield_Saturate (self)
	self.icon:SetTexCoord(0, .5, 0, 1);
end

function AchievementShield_OnLoad (self)
	local name = self:GetName();
	self.icon = getglobal(name .. "Icon");
	self.points = getglobal(name .. "Points");
	
	self.Desaturate = AchievementShield_Desaturate;
	self.Saturate = AchievementShield_Saturate;
end

-- [[ AchievementButton ]] --

ACHIEVEMENTBUTTON_DESCRIPTIONHEIGHT = 20;
ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT = 84;
ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT = 15;
ACHIEVEMENTBUTTON_MAXHEIGHT = 232;
ACHIEVEMENTBUTTON_TEXTUREHEIGHT = 128;

function AchievementButton_Collapse (self)
	if ( self.collapsed ) then
		return;
	end
	
	self.collapsed = true;
	
	self:SetHeight(ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT);
	
	getglobal(self:GetName() .. "Background"):SetTexCoord(0, 1, 1-(ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT / 256), 1);
	getglobal(self:GetName() .. "Glow"):SetTexCoord(0, 1, 0, ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT / 128);
	
	if ( not self.tracked:GetChecked() ) then
		self.tracked:Hide();
	end
	
end

function AchievementButton_Expand (self, height)
	if ( not self.collapsed ) then
		return;
	end
	
	self.collapsed = nil;
	self:SetHeight(height);
	
	getglobal(self:GetName() .. "Background"):SetTexCoord(0, 1, max(0, 1-(height / 256)), 1);
	getglobal(self:GetName() .. "Glow"):SetTexCoord(0, 1, 0, (height+5) / 128);
end

function AchievementButton_Saturate (self)
	local name = self:GetName();
	getglobal(name .. "TitleBackground"):SetTexCoord(0, 0.9765625, 0, 0.3125);
	getglobal(name .. "Background"):SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
	getglobal(name .. "Glow"):SetVertexColor(1.0, 1.0, 1.0);
	self.icon:Saturate();
	self.shield:Saturate();
	self.shield.points:SetVertexColor(1, 1, 1);
	self.reward:SetVertexColor(1, .82, 0);
	self.label:SetVertexColor(1, 1, 1);
	self.description:SetTextColor(0, 0, 0, 1);
	self.description:SetShadowOffset(0, 0);
	self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
end

function AchievementButton_Desaturate (self)
	local name = self:GetName();
	getglobal(name .. "TitleBackground"):SetTexCoord(0, 0.9765625, 0.34375, 0.65625);
	getglobal(name .. "Background"):SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
	getglobal(name .. "Glow"):SetVertexColor(.22, .17, .13);
	self.icon:Desaturate();
	self.shield:Desaturate();
	self.shield.points:SetVertexColor(.65, .65, .65);
	self.reward:SetVertexColor(.8, .8, .8);
	self.label:SetVertexColor(.65, .65, .65);
	self.description:SetTextColor(1, 1, 1, 1); 
	self.description:SetShadowOffset(1, -1);
	self:SetBackdropBorderColor(.5, .5, .5);
end

function AchievementButton_OnLoad (self)
	local name = self:GetName();
	
	self.label = getglobal(name .. "Label");
	self.description = getglobal(name .. "Description");
	self.hiddenDescription = getglobal(name .. "HiddenDescription");
	self.reward = getglobal(name .. "Reward");
	self.rewardBackground = getglobal(name.."RewardBackground");
	self.icon = getglobal(name .. "Icon");
	self.shield = getglobal(name .. "Shield");
	self.objectives = getglobal(name .. "Objectives");
	self.highlight = getglobal(name .. "Highlight");
	self.dateCompleted = getglobal(name .. "DateCompleted")
	self.tracked = getglobal(name .. "Tracked");
	self.check = getglobal(name .. "Check");
	
	self.dateCompleted:ClearAllPoints();
	self.dateCompleted:SetPoint("TOP", self.shield, "BOTTOM", -3, 6);
	
	self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
	self.Collapse = AchievementButton_Collapse;
	self.Expand = AchievementButton_Expand;
	self.Saturate = AchievementButton_Saturate;
	self.Desaturate = AchievementButton_Desaturate;
	
	self:Collapse();
	self:Desaturate();
	
	AchievementFrameAchievements.buttons = AchievementFrameAchievements.buttons or {};
	tinsert(AchievementFrameAchievements.buttons, self);
end

function AchievementButton_OnClick (self, ignoreModifiers)
	if(IsModifiedClick() and not ignoreModifiers) then
		if ( IsModifiedClick("CHATLINK") and ChatFrameEditBox:IsVisible() ) then
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
		if ( not MouseIsOver(self) ) then
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
end

function AchievementButton_ToggleTracking (id)
	local currTrack = GetTrackedAchievement();
	if ( currTrack == id ) then
		SetTrackedAchievement(0);
	else
		SetTrackedAchievement(id);
	end
	AchievementFrameAchievements_ForceUpdate();
end
	
function AchievementButton_DisplayAchievement (button, category, achievement, selectionID)
	local id, name, points, completed, month, day, year, description, flags, icon, rewardText = GetAchievementInfo(category, achievement);
	if ( not id ) then
		button:Hide();
		return;
	else
		button:Show();
	end
		
	button.index = achievement;
	button.element = true;
	
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
	
		button.description:SetText(description);
		button.hiddenDescription:SetText(description);
		if ( button.hiddenDescription:GetWidth() > ACHIEVEMENTUI_MAXCONTENTWIDTH ) then
			button.description:SetWidth(ACHIEVEMENTUI_MAXCONTENTWIDTH);
		else
			button.description:SetWidth(0);
		end
	
		button.icon.texture:SetTexture(icon);
		if ( completed and not button.completed ) then
			button.completed = true;
			button.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
			button.dateCompleted:Show();
			button:Saturate();
		elseif ( completed ) then
			button.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
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
		
		local tracked = GetTrackedAchievement();
		if ( tracked == id ) then
			button.check:Show();
			button.label:SetWidth(button.label:GetStringWidth() + 4); -- This +4 here is to fudge around any string width issues that arize from resizing a string set to its string width. See bug 144418 for an example.
			button.tracked:SetChecked(true);
		else
			button.check:Hide();
			button.tracked:SetChecked(false);
			button.tracked:Hide();
		end
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
		button.tracked:Show();
	elseif ( button.selected ) then
		button.selected = nil;
		if ( not MouseIsOver(button) ) then
			button.highlight:Hide();
		end
		button:Collapse();
		button.tracked:Hide();
	end
	
	return id;
end

function AchievementFrameAchievements_SelectButton (button)
	local achievements = AchievementFrameAchievements;
	
	achievements.selection = button.id;
	achievements.selectionIndex = button.index;
	button.selected = true;
end

function AchievementButton_ResetObjectives ()
	AchievementFrameAchievementsObjectives:Hide();
end

function AchievementButton_DisplayObjectives (button, id, completed)
	local objectives = AchievementFrameAchievementsObjectives;
	
	objectives:ClearAllPoints();
	objectives:SetParent(button);
	objectives:Show();
	objectives.completed = completed;
	local height = 0;
	if ( objectives.id == id ) then
		local ACHIEVEMENTMODE_CRITERIA = 1;
		if ( objectives.mode == ACHIEVEMENTMODE_CRITERIA ) then
			if ( objectives:GetHeight() > 0 ) then
				objectives:SetPoint("TOP", "$parentDescription", "BOTTOM", 0, -8);
				objectives:SetPoint("LEFT", "$parentIcon", "RIGHT", -5, 0);
				objectives:SetPoint("RIGHT", "$parentShield", "LEFT", -10, 0);
			end
			height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT + objectives:GetHeight();
		else
			objectives:SetPoint("TOP", 0, -50);
			height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT + objectives:GetHeight();
		end
	elseif ( completed and GetPreviousAchievement(id) ) then
		objectives:SetHeight(0);
		AchievementButton_ResetCriteria();
		AchievementButton_ResetProgressBars();
		AchievementButton_ResetMiniAchievements();
		AchievementButton_ResetMetas();
		AchievementObjectives_DisplayProgressiveAchievement(objectives, id);
		objectives:SetPoint("TOP", 0, -50);
		height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT + objectives:GetHeight();
	else
		objectives:SetHeight(0);	
		AchievementButton_ResetCriteria();
		AchievementButton_ResetProgressBars();
		AchievementButton_ResetMiniAchievements();
		AchievementButton_ResetMetas();
		AchievementObjectives_DisplayCriteria(objectives, id);
		if ( objectives:GetHeight() > 0 ) then
			objectives:SetPoint("TOP", "$parentDescription", "BOTTOM", 0, -8);
			objectives:SetPoint("LEFT", "$parentIcon", "RIGHT", -5, -25);
			objectives:SetPoint("RIGHT", "$parentShield", "LEFT", -10, 0);
		end
		height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT + objectives:GetHeight();
	end

	if ( height ~= ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT ) then		
		local descriptionHeight = button.description:GetHeight();
		height = height + descriptionHeight - ACHIEVEMENTBUTTON_DESCRIPTIONHEIGHT;
	end
	
	objectives.id = id;
	return height;
end

function AchievementShield_SetPoints(points, pointString, normalFont, smallFont)
	if ( points == 0 ) then
		pointString:SetText("");
		return;
	end
	if ( points <= 100 ) then
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

function AchievementButton_ResetCriteria ()
	AchievementButton_ResetTable(criteriaTable);
end

function AchievementButton_GetCriteria (index)
	local criteriaTable = criteriaTable;
	
	if ( criteriaTable[index] ) then
		return criteriaTable[index];
	end
	
	local frame = CreateFrame("FRAME", "AchievementFrameCriteria" .. index, AchievementFrameAchievements, "AchievementCriteriaTemplate");
	AchievementFrame_LocalizeCriteria(frame);
	criteriaTable[index] = frame;
	
	return frame;
end

-- The smallest table in WoW.
local miniTable = {}

function AchievementButton_ResetMiniAchievements ()
	AchievementButton_ResetTable(miniTable);
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

function AchievementButton_ResetProgressBars ()
	AchievementButton_ResetTable(progressBarTable);
end

function AchievementButton_GetProgressBar (index)
	local progressBarTable = progressBarTable;
	if ( progressBarTable[index] ) then
		return progressBarTable[index];
	end
	
	local frame = CreateFrame("STATUSBAR", "AchievementFrameProgressBar" .. index, AchievementFrameAchievements, "AchievementProgressBarTemplate");
	AchievementButton_LocalizeProgressBar(frame);
	progressBarTable[index] = frame;
	
	return frame;
end

local metaCriteriaTable = {};

function AchievementButton_ResetMetas ()
	AchievementButton_ResetTable(metaCriteriaTable);
end

function AchievementButton_GetMeta (index)
	local metaCriteriaTable = metaCriteriaTable;
	if ( metaCriteriaTable[index] ) then
		return metaCriteriaTable[index];
	end
	
	local frame = CreateFrame("BUTTON", "AchievementFrameMeta" .. index, AchievementFrameAchievements, "MetaCriteriaTemplate");
	AchievementButton_LocalizeMetaAchievement(frame);
	metaCriteriaTable[index] = frame;
	
	return frame;
end

function AchievementButton_GetProgressivePoints(achievementID)
	local progressivePoints;
	local _, _, progressivePoints, completed = GetAchievementInfo(achievementID);

	while GetPreviousAchievement(achievementID) do
		achievementID = GetPreviousAchievement(achievementID);
		_, _, points, completed = GetAchievementInfo(achievementID);
		progressivePoints = progressivePoints+points;
	end
	if ( progressivePoints > 0 ) then
		return progressivePoints;
	else
		return nil;
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
		
		local miniAchievement = AchievementButton_GetMiniAchievement(index);
		
		miniAchievement:Show();
		miniAchievement:SetParent(objectivesFrame);
		getglobal(miniAchievement:GetName() .. "Icon"):SetTexture(iconpath);
		if ( index == 1 ) then
			miniAchievement:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", -4, -4);
		elseif ( index == 7 ) then
			miniAchievement:SetPoint("TOPLEFT", miniTable[1], "BOTTOMLEFT", 0, -8);
		else
			miniAchievement:SetPoint("TOPLEFT", miniTable[index-1], "TOPRIGHT", 4, 0);
		end
		
		miniAchievement.points:SetText(points);
		
		for i = 1, GetAchievementNumCriteria(achievementID) do
			local criteriaString, criteriaType, completed = GetAchievementCriteriaInfo(achievementID, i);
			if ( completed == false ) then
				criteriaString = "|CFF808080 - " .. criteriaString;
			else
				criteriaString = "|CFF00FF00 - " .. criteriaString;
			end
			miniAchievement["criteria" .. i] = criteriaString;
			miniAchievement.numCriteria = i;
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

	local ACHIEVEMENTMODE_CRITERIA = 1;
	local numCriteria = GetAchievementNumCriteria(id);
	
	if ( numCriteria == 0 ) then
		objectivesFrame.mode = ACHIEVEMENTMODE_CRITERIA;
		objectivesFrame:SetHeight(0);
		return;
	end
	
	local frameLevel = objectivesFrame:GetFrameLevel() + 1;
	
	-- Why textStrings? You try naming anything just "string" and see how happy you are.
	local textStrings, progressBars, metas = 0, 0, 0;
	
	local numRows = 0;
	local maxCriteriaWidth = 0;
	local yPos;
	for i = 1, numCriteria do	
		local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(id, i);
		
		if ( criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID ) then
			metas = metas + 1;
			local metaCriteria = AchievementButton_GetMeta(metas);
			
			if ( metas == 1 ) then
				metaCriteria:SetPoint("TOP", objectivesFrame, "TOP", 0, -4);
				numRows = numRows + 2;
			elseif ( math.fmod(metas, 2) == 0 ) then
				yPos = -((metas/2 - 1) * 28) - 8;
				metaCriteriaTable[metas-1]:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 20, yPos);
				metaCriteria:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 210, yPos);
			else
				metaCriteria:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 20, -(math.ceil(metas/2 - 1) * 28) - 8);
				numRows = numRows + 2;
			end
			
			local id, achievementName, points, completed, month, day, year, description, flags, iconpath = GetAchievementInfo(assetID);
			
			if ( month ) then
				metaCriteria.date = string.format(SHORTDATE, day, month, year);
			else
				metaCriteria.date = nil;
			end
			
			metaCriteria.id = id;
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
		elseif ( bit.band(flags, ACHIEVEMENT_CRITERIA_PROGRESS_BAR) == ACHIEVEMENT_CRITERIA_PROGRESS_BAR ) then
			-- Display this criteria as a progress bar!
			progressBars = progressBars + 1;
			local progressBar = AchievementButton_GetProgressBar(progressBars);
			
			if ( progressBars == 1 ) then
				progressBar:SetPoint("TOP", objectivesFrame, "TOP", 4, -4);
			else
				progressBar:SetPoint("TOP", progressBarTable[progressBars-1], "BOTTOM", 0, 0);
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
					criteria:SetPoint("TOP", objectivesFrame, "TOP", 0, 0);
				else
					criteria:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 0, 0);
				end
				
			else
				criteria:SetPoint("TOPLEFT", criteriaTable[textStrings-1], "BOTTOMLEFT", 0, 0);
			end
			
			if ( completed ) then
				criteria.check:SetPoint("LEFT", 18, -3);
				criteria.name:SetPoint("LEFT", criteria.check, "RIGHT", 0, 2);
				criteria.check:Show();
				criteria.name:SetText(criteriaString);
			else
				criteria.check:SetPoint("LEFT", 0, -3);
				criteria.name:SetPoint("LEFT", criteria.check, "RIGHT", 5, 2);
				criteria.check:Hide();
				criteria.name:SetText("- "..criteriaString);
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
				
			criteria:SetParent(objectivesFrame);
			criteria:Show();
			local stringWidth = criteria.name:GetStringWidth()
			criteria:SetWidth(stringWidth + criteria.check:GetWidth());
			maxCriteriaWidth = max(maxCriteriaWidth, stringWidth + criteria.check:GetWidth());

			numRows = numRows + 1;
		end
	end

	if ( textStrings > 0 and progressBars > 0 ) then
		-- If we have text criteria and progressBar criteria, display the progressBar criteria first and position the textStrings under them.
		criteriaTable[1]:SetPoint("TOP", progressBarTable[progressBars], "BOTTOM", 0, -4);
	elseif ( textStrings > 1 ) then
		-- Figure out if we can make multiple columns worth of criteria instead of one long one
		local numColumns = floor(ACHIEVEMENTUI_MAXCONTENTWIDTH/maxCriteriaWidth);
		if ( numColumns > 1 ) then
			local step;
			local rows = 1;
			local position = 0;
			for i=1, #criteriaTable do
				position = position + 1;
				if ( position > numColumns ) then
					position = position - numColumns;
					rows = rows + 1;
				end
				
				if ( rows == 1 ) then
					criteriaTable[i]:ClearAllPoints();
					criteriaTable[i]:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", (position - 1)*(ACHIEVEMENTUI_MAXCONTENTWIDTH/numColumns), 0);
				else
					criteriaTable[i]:ClearAllPoints();
					criteriaTable[i]:SetPoint("TOPLEFT", criteriaTable[position + ((rows - 2) * numColumns)], "BOTTOMLEFT", 0, 0);
				end
			end
			numRows = ceil(numRows/numColumns);
		end
	end
	
	objectivesFrame:SetHeight(numRows * ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT);
	objectivesFrame.mode = ACHIEVEMENTMODE_CRITERIA;
end

-- [[ StatsFrames ]]--

function AchievementFrameStats_OnEvent (self, event, ...)
	if ( event == "CRITERIA_UPDATE" and self:IsShown() ) then
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
			AchievementFrameStats:SetWidth(527);
			for _, button in next, AchievementFrameStats.buttons do
				button:SetWidth(519);
			end
			getmetatable(self).__index.Hide(self);
		end
		
	self:RegisterEvent("CRITERIA_UPDATE");
	AchievementFrameStatsContainerScrollBarBG:Show();
	AchievementFrameStatsContainer.update = AchievementFrameStats_Update;
	HybridScrollFrame_CreateButtons(AchievementFrameStatsContainer, "StatTemplate");
end

local displayStatCategories = {};

function AchievementFrameStats_Update ()
	local category = achievementFunctions.selectedCategory;
	local scrollFrame = AchievementFrameStatsContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local statHeight = 24;
	
	local numStats, numCompleted = GetCategoryNumAchievements(category);
	
	categories = ACHIEVEMENTUI_CATEGORIES;
	-- clear out table
	if ( achievementFunctions.lastCategory ~= category ) then
		local statCat;
		for i in next, displayStatCategories do
			displayStatCategories[i] = nil;
		end
		-- build a list of shown category and stat id's
		
		tinsert(displayStatCategories, {id = category, header = true});
		for i=1, numStats do
			tinsert(displayStatCategories, {id = GetAchievementInfo(category, i)});
		end
		-- add all the subcategories and their stat id's
		for i, cat in next, categories do
			if ( cat.parent == category ) then
				tinsert(displayStatCategories, {id = cat.id, header = true});
				numStats = GetCategoryNumAchievements(cat.id);
				for k=1, numStats do
					tinsert(displayStatCategories, {id = GetAchievementInfo(cat.id, k)});
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
				AchievementFrameStats_SetStat(button, stat.id, nil, statIndex);
			end
			button:Show();
		else
			button:Hide();
		end
	end
	HybridScrollFrame_Update(scrollFrame, statCount, totalHeight, displayedHeight);
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
	button.title:SetText(GetCategoryInfo(id));
	button.title:Show();
	button.value:SetText("");
	button:SetText("");
	button:SetHeight(24);
	button.background:Hide();
	button.isHeader = true;
	button.id = id;
end

function AchievementStatButton_OnLoad(self, parentFrame)
	local name = self:GetName();
	self.background = getglobal(name.."BG");
	self.left = getglobal(name.."HeaderLeft");
	self.middle = getglobal(name.."HeaderMiddle");
	self.right = getglobal(name.."HeaderRight");
	self.text = getglobal(name.."Text");
	self.title = getglobal(name.."Title");
	self.value = getglobal(name.."Value");
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

-- [[ Summary Frame ]] --
function AchievementFrameSummary_OnShow()
	if ( achievementFunctions ~= COMPARISON_ACHIEVEMENT_FUNCTIONS and achievementFunctions ~= COMPARISON_STAT_FUNCTIONS ) then
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
	AchievementFrameSummaryStatusBar_Update();
	AchievementFrameSummary_UpdateAchievements(GetLatestCompletedAchievements());
	AchievementFrameSummary_UpdateStats(GetLatestUpdatedStats());
end

function AchievementFrameSummary_UpdateAchievements(...)
	local numAchievements = select("#", ...);
	local id, name, points, completed, month, day, year, description, flags, icon;
	local buttons = AchievementFrameSummaryAchievements.buttons;
	local button, achievementID;
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
				anchorTo = getglobal("AchievementFrameSummaryAchievement"..i-1);
				button:SetPoint("TOPLEFT",anchorTo, "BOTTOMLEFT", 0, 3 );
				button:SetPoint("TOPRIGHT",anchorTo, "BOTTOMRIGHT", 0, 3 );
			end
			
			if ( not buttons ) then
				buttons = AchievementFrameSummaryAchievements.buttons;
			end
			AchievementFrameSummary_LocalizeButton(button);
		end;
		
		if ( i <= numAchievements ) then
			achievementID = select(i, ...);
			id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(achievementID);
			button.label:SetText(name);
			button.description:SetText(description);
			AchievementShield_SetPoints(points, button.shield.points, GameFontNormal, GameFontNormalSmall);
			if ( points > 0 ) then
				button.shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
			else
				button.shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
			end
			button.icon.texture:SetTexture(icon);
			button.id = id;

			if ( completed ) then
				button.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
			else
				button.dateCompleted:SetText("");
			end
			
			button:Saturate();
			button.tooltipTitle = nil;
			button:Show();
		else
			for i=defaultAchievementCount, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
				achievementID = ACHIEVEMENTUI_DEFAULTSUMMARYACHIEVEMENTS[defaultAchievementCount];
				if ( not achievementID ) then
					break;
				end
				id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(achievementID);
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

function AchievementFrameSummary_UpdateStats(...)
	local numStats = select("#", ...);
	local buttons = AchievementFrameSummaryStats.buttons;
	local stat, statID, anchorTo;
	
	for i=1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
		if ( buttons ) then
			stat = buttons[i];
		end
		if ( not stat ) then
			stat = CreateFrame("Button", "AchievementFrameSummaryStat"..i, AchievementFrameSummaryStats, "SummaryStatTemplate");
			if ( i == 1 ) then
				stat:SetPoint("TOPLEFT",AchievementFrameSummaryStatsHeader, "BOTTOMLEFT", 0, 0 );
				stat:SetPoint("TOPRIGHT",AchievementFrameSummaryStatsHeader, "BOTTOMRIGHT", 0, 0 );
			else
				anchorTo = getglobal("AchievementFrameSummaryStat"..i-1);
				stat:SetPoint("TOPLEFT",anchorTo, "BOTTOMLEFT", 0, 0 );
				stat:SetPoint("TOPRIGHT",anchorTo, "BOTTOMRIGHT", 0, 0 );
			end
			if ( not buttons ) then
				buttons = AchievementFrameSummaryStats.buttons;
			end
		end;
		if ( i <= numStats ) then
			statID = select(i, ...);
			AchievementFrameStats_SetStat(stat, statID, nil, i, 1);
			stat.id = statID;
			stat:Show();
		else
			stat:Hide();
		end
	end
	if ( numStats == 0 ) then
		AchievementFrameSummaryStatsEmptyText:Show();
	else
		AchievementFrameSummaryStatsEmptyText:Hide();
	end
end

function AchievementFrameSummaryStatusBar_Update()
	local total, completed = GetNumCompletedAchievements();
	AchievementFrameSummaryStatusBar:SetMinMaxValues(0, total);
	AchievementFrameSummaryStatusBar:SetValue(completed);
	AchievementFrameSummaryStatusBarText:SetText(completed.."/"..total);
end

function AchievementFrameSummaryAchievement_OnLoad(self)
	AchievementComparisonPlayerButton_OnLoad(self);
	self.highlight = getglobal(self:GetName().."Highlight");
	AchievementFrameSummaryAchievements.buttons = AchievementFrameSummaryAchievements.buttons or {};
	tinsert(AchievementFrameSummaryAchievements.buttons, self);
	self:Saturate();
	self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, 0.5);
	self.titleBar:SetVertexColor(1,1,1,0.5);
	self.dateCompleted:Show();
end

function AchievementFrameSummaryAchievement_OnClick(self)
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
		GameTooltip:AddLine(self.tooltip, nil, nil, nil, 1);
		GameTooltip:Show();
	end
end

function AchievementFrame_SelectAchievement(id)
	if ( not AchievementFrame:IsShown() ) then
		return;
	end
	
	AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
	AchievementFrameTab_OnClick(1);
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
	
	AchievementFrameCategories_ClearSelection();
	local category = GetAchievementCategory(id);
	
	local categoryIndex, parent, hidden = 0;
	for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
		if ( entry.id == category ) then
			index = i;
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
	
	AchievementFrameAchievements_ClearSelection();	
	AchievementFrameAchievements_Update();
	AchievementFrameAchievementsContainerScrollBar:SetValue(0);

	local shown = false;
	while ( not shown ) do
		for _, button in next, AchievementFrameAchievementsContainer.buttons do
			if ( button.id == id and math.ceil(button:GetTop()) >= math.ceil(AchievementFrameAchievementsContainer:GetBottom())) then
				-- The "True" here ignores modifiers, so you don't accidentally track or link this achievement. :P
				AchievementButton_OnClick(button, true);
				
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
			if ( AchievementFrameAchievementsContainerScrollBar:GetValue() == maxVal ) then
				assert(false, "Failed to find achievement " .. id .. " while jumping!")
			else
				HybridScrollFrame_OnMouseWheel(AchievementFrameAchievementsContainer, -1);
			end			
		end
	end
end

function AchievementFrame_SelectSummaryStatistic (criteriaId)
	AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
	AchievementFrameTab_OnClick(2);
	AchievementFrameStats:Show();
	AchievementFrameSummary:Hide();
	
	AchievementFrameCategories_ClearSelection();
	
	local id = GetAchievementInfoFromCriteria(criteriaId);
	local category = GetAchievementCategory(id);
	
	local categoryIndex, parent, hidden = 0;
	
	local categoryIndex, parent, hidden = 0;
	for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
		if ( entry.id == category ) then
			index = i;
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
	
	local shown, i = false, 1;
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
	AchievementFrame:SetAttribute("UIPanelLayout-xOffset", 38);
	UpdateUIPanelPositions(AchievementFrame);
	AchievementFrame.isComparison = true;
end

function AchievementFrameComparison_OnHide ()
	AchievementFrame.selectedTab = nil;
	AchievementFrame:SetWidth(768);
	AchievementFrame:SetAttribute("UIPanelLayout-xOffset", 80);
	UpdateUIPanelPositions(AchievementFrame);
	AchievementFrame.isComparison = false;
end

function AchievementFrameComparison_OnEvent (self, event, ...)
	if ( event == "INSPECT_ACHIEVEMENT_READY" ) then
		AchievementFrameComparisonHeaderPoints:SetText(GetComparisonAchievementPoints());
		AchievementFrameComparison_UpdateFriendStatusBar(achievementFunctions.selectedCategory)
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local updateUnit = ...;
		if ( updateUnit and updateUnit == AchievementFrameComparisonHeaderPortrait.unit and UnitName(updateUnit) == AchievementFrameComparisonHeaderName:GetText() ) then
			SetPortraitTexture(AchievementFrameComparisonHeaderPortrait, updateUnit);
		end
	end
	
	AchievementFrameComparison_ForceUpdate();
end

function AchievementFrameComparison_SetUnit (unit)
	ClearAchievementComparisonUnit();
	SetAchievementComparisonUnit(unit);
	
	AchievementFrameComparisonHeaderPoints:SetText(GetComparisonAchievementPoints());
	AchievementFrameComparisonHeaderName:SetText(UnitName(unit));
	SetPortraitTexture(AchievementFrameComparisonHeaderPortrait, unit);
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
		
	local buttonHeight = buttons[1]:GetHeight();
	for i = 1, numButtons do
		achievementIndex = i + offset;
		AchievementFrameComparison_DisplayAchievement(buttons[i], category, achievementIndex);
	end
	
	HybridScrollFrame_Update(scrollFrame, numAchievements, buttonHeight*numAchievements, buttonHeight*numButtons);
end

ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT1 = GameFontNormal;
ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT2 = GameFontNormalSmall;
ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT1 = GameFontNormalSmall;
ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT2 = GameFontNormalSmall;

function AchievementFrameComparison_DisplayAchievement (button, category, index)
	local id, name, points, completed, month, day, year, description, flags, icon, rewardText = GetAchievementInfo(category, index);
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
		
		local friendCompleted, friendMonth, friendDay, friendYear = GetAchievementComparisonInfo(id, 1);
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
		
		if ( completed and not player.completed ) then
			player.completed = true;
			player.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
			player.dateCompleted:Show();
			player:Saturate();
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
			friend:Saturate();
		elseif ( friendCompleted ) then
			friend.status:SetText(string.format(SHORTDATE, friendDay, friendMonth, friendYear));
		else
			friend.completed = nil;
			friend.status:SetText(INCOMPLETE);
			friend:Desaturate();
		end
	end
end

local displayStatCategories = {};
function AchievementFrameComparison_UpdateStats ()
	local category = achievementFunctions.selectedCategory;
	local scrollFrame = AchievementFrameComparisonStatsContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local headerHeight = 24;
	local statHeight = 23;
	local totalHeight = 0;	
	local numStats, numCompleted = GetCategoryNumAchievements(category);

	categories = ACHIEVEMENTUI_CATEGORIES;
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
	HybridScrollFrame_Update(scrollFrame, statCount, totalHeight, displayedHeight);
end

function AchievementFrameComparisonStat_OnLoad (self)
	local name = self:GetName();
	self.background = getglobal(name.."BG");
	self.left = getglobal(name.."HeaderLeft");
	self.middle = getglobal(name.."HeaderMiddle");
	self.right = getglobal(name.."HeaderRight");
	self.left2 = getglobal(name.."HeaderLeft2");
	self.middle2 = getglobal(name.."HeaderMiddle2");
	self.right2 = getglobal(name.."HeaderRight2");
	self.text = getglobal(name.."Text");
	self.title = getglobal(name.."Title");
	self.value = getglobal(name.."Value");
	self.value:SetVertexColor(1, 0.97, 0.6);
	self.friendValue = getglobal(name.."ComparisonValue");
	self.friendValue:SetVertexColor(1, 0.97, 0.6);
	self.mouseover = getglobal(name.. "Mouseover");
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
	getglobal(name .. "TitleBackground"):SetTexCoord(0, 0.9765625, 0, 0.3125);
	getglobal(name .. "Background"):SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
	getglobal(name .. "Glow"):SetVertexColor(1.0, 1.0, 1.0);
	self.icon:Saturate();
	self.shield:Saturate();
	self.shield.points:SetVertexColor(1, 1, 1);
	self.label:SetVertexColor(1, 1, 1);
	self.description:SetTextColor(0, 0, 0, 1);
	self.description:SetShadowOffset(0, 0);
	self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
end

function AchievementComparisonPlayerButton_Desaturate (self)
	local name = self:GetName();
	getglobal(name .. "TitleBackground"):SetTexCoord(0, 0.9765625, 0.34375, 0.65625);
	getglobal(name .. "Background"):SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
	getglobal(name .. "Glow"):SetVertexColor(.22, .17, .13);
	self.icon:Desaturate();
	self.shield:Desaturate();
	self.shield.points:SetVertexColor(.65, .65, .65);
	self.label:SetVertexColor(.65, .65, .65);
	self.description:SetTextColor(1, 1, 1, 1);
	self.description:SetShadowOffset(1, -1);
	self:SetBackdropBorderColor(.5, .5, .5);
end

function AchievementComparisonPlayerButton_OnLoad (self)
	local name = self:GetName();
	
	self.label = getglobal(name .. "Label");
	self.description = getglobal(name .. "Description");
	self.icon = getglobal(name .. "Icon");
	self.shield = getglobal(name .. "Shield");
	self.dateCompleted = getglobal(name .. "DateCompleted");
	self.titleBar = getglobal(name .. "TitleBackground");
	
	self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
	self.Saturate = AchievementComparisonPlayerButton_Saturate;
	self.Desaturate = AchievementComparisonPlayerButton_Desaturate;
	
	self:Desaturate();
	
	-- AchievementFrameComparison.buttons = AchievementFrameComparison.buttons or {};
	-- tinsert(AchievementFrameComparison.buttons, self);
end

function AchievementComparisonFriendButton_Saturate (self)
	local name = self:GetName();
	getglobal(name .. "TitleBackground"):SetTexCoord(0.3, 0.575, 0, 0.3125);
	getglobal(name .. "Background"):SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
	getglobal(name .. "Glow"):SetVertexColor(1.0, 1.0, 1.0);
	self.icon:Saturate();
	self.shield:Saturate();
	self.shield.points:SetVertexColor(1, 1, 1);
	self.status:SetVertexColor(1, .82, 0);
	self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
end

function AchievementComparisonFriendButton_Desaturate (self)
	local name = self:GetName();
	getglobal(name .. "TitleBackground"):SetTexCoord(0.3, 0.575, 0.34375, 0.65625);
	getglobal(name .. "Background"):SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
	getglobal(name .. "Glow"):SetVertexColor(.22, .17, .13);
	self.icon:Desaturate();
	self.shield:Desaturate();
	self.shield.points:SetVertexColor(.65, .65, .65);
	self.status:SetVertexColor(.65, .65, .65);
	self:SetBackdropBorderColor(.5, .5, .5);
end

function AchievementComparisonFriendButton_OnLoad (self)
	local name = self:GetName();
	
	self.status = getglobal(name .. "Status");
	self.icon = getglobal(name .. "Icon");
	self.shield = getglobal(name .. "Shield");
	
	self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
	self.Saturate = AchievementComparisonFriendButton_Saturate;
	self.Desaturate = AchievementComparisonFriendButton_Desaturate;
	
	self:Desaturate();
end

function AchievementFrame_IsComparison()
	return AchievementFrame.isComparison;
end

function AchievementFrame_IsFeatOfStrength()
	if ( AchievementFrame.selectedTab == 1 and achievementFunctions.selectedCategory == displayCategories[#displayCategories].id ) then
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

STAT_FUNCTIONS = {
	categoryAccessor = GetStatisticsCategoryList,
	clearFunc = nil,
	updateFunc = AchievementFrameStats_Update,
	selectedCategory = "summary";
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
		file="Interface\\AchievementFrame\\UI-Achievement-AchievementBackground",
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
		getglobal(v.name):SetTexture(nil);
	end
end

function AchievementFrame_LoadTextures()
	for k, v in pairs(ACHIEVEMENT_TEXTURES_TO_LOAD) do
		if ( v.file ) then
			getglobal(v.name):SetTexture(v.file);
		end
	end
end
