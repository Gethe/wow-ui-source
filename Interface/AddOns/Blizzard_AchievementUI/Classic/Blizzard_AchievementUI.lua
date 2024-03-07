local ACHIEVEMENTUI_FONTHEIGHT;						-- set in AchievementButton_OnLoad
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
	self.trackedAchievements = {};
	self.criteriaTable = {};
	self.miniTable = {};
	self.progressBarTable = {};
	self.metaCriteriaTable = {};
	self.displayCategories = {};
	PanelTemplates_UpdateTabs(self);

	AchievementFrame_ShowSubFrame(AchievementFrameSummary);

end

function AchievementFrameBaseTab_OnClick (id)
	PanelTemplates_Tab_OnClick(_G["AchievementFrameTab"..id], AchievementFrame);
	
	local isSummary = false
	if ( id == 1 ) then
		achievementFunctions = ACHIEVEMENT_FUNCTIONS;
		AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES); -- This needs to happen before AchievementFrame_ShowSubFrame (fix for bug 157885)
		if ( achievementFunctions.selectedCategory == "summary" ) then
			isSummary = true;
			AchievementFrame_ShowSubFrame(AchievementFrameSummary);
		else
			AchievementFrame_ShowSubFrame(AchievementFrameAchievements);
		end
		AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-AchievementWatermark");
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
	end
	
	AchievementFrameCategories_Update();
	
	if ( not isSummary ) then
		achievementFunctions.updateFunc();
	end
end

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
	PanelTemplates_Tab_OnClick(_G["AchievementFrameTab"..id], AchievementFrame);
	
	achievementFunctions.updateFunc();
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
			subFrame:Show();
		else
			subFrame:Hide();
		end
	end
end

-- [[ AchievementFrameCategories ]] --

function AchievementFrameCategories_OnLoad (self)
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
		numAchievements, numCompleted = GetNumCompletedAchievements();
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
	elseif ( AchievementFrame.selectedTab == 1 ) then
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
		if ( achievementFunctions == ACHIEVEMENT_FUNCTIONS ) then
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
		elseif ( achievementFunctions == ACHIEVEMENT_FUNCTIONS ) then
			AchievementFrame_ShowSubFrame(AchievementFrameAchievements);
			AchievementFrameAchievementsContainerScrollBar:SetValue(0);
			if ( id == FEAT_OF_STRENGTH_ID ) then
				AchievementFrameFilterDropDown:Hide();
				AchievementFrameHeaderRightDDLInset:Hide();
			else
				AchievementFrameFilterDropDown:Show();
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
	
	achievementFunctions.updateFunc();
end

function AchievementFrameAchievements_OnShow()
	if ( achievementFunctions.selectedCategory == FEAT_OF_STRENGTH_ID ) then
		AchievementFrameFilterDropDown:Hide();
		AchievementFrameHeaderRightDDLInset:Hide();
	else
		AchievementFrameFilterDropDown:Show();
		AchievementFrameHeaderRightDDLInset:Show();	
	end
end

-- [[ AchievementCategoryButton ]] --

function AchievementCategoryButton_OnLoad (button)
	button:EnableMouse(true);
	button:EnableMouseWheel(true);
	
	local buttonName = button:GetName();
	
	button.label = _G[buttonName .. "Label"];
	button.background = _G[buttonName.."Background"];
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
			AchievementFrameAchievements:SetWidth(530);
			for _, button in next, AchievementFrameAchievements.buttons do
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
		AchievementFrameHeaderPoints:SetText(GetTotalAchievementPoints());

	elseif ( event == "CRITERIA_UPDATE" and self:IsVisible() ) then
		if ( AchievementFrameAchievements.selection) then
			local id = AchievementFrameAchievementsObjectives.id;
			local button = AchievementFrameAchievementsObjectives:GetParent();
			AchievementFrameAchievementsObjectives.id = nil;
			AchievementButton_DisplayObjectives(button, id, button.completed);
			AchievementFrameAchievements_Update();
		else
			AchievementFrameAchievementsObjectives.id = nil; -- Force redraw
		end
	elseif ( event == "TRACKED_ACHIEVEMENT_LIST_CHANGED" ) then
		for k, v in next, AchievementFrame.trackedAchievements do
			AchievementFrame.trackedAchievements[k] = nil;
		end
		
		AchievementFrame_UpdateTrackedAchievements(GetTrackedAchievements());
	end
	
	
	if ( not AchievementMicroButton:IsShown() ) then
		AchievementMicroButton_Update();
	end
end

function AchievementFrameAchievementsBackdrop_OnLoad (self)
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
	for _, button in next, AchievementFrameAchievements.buttons do
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

-- [[ Achievement Icon ]] --

function AchievementIcon_OnLoad (self)
	local name = self:GetName();
	self.bling = _G[name .. "Bling"];
	self.texture = _G[name .. "Texture"];
	self.frame = _G[name .. "Overlay"];
	
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

-- [[ AchievementButton ]] --

ACHIEVEMENTBUTTON_DESCRIPTIONHEIGHT = 20;
ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT = 84;
ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT = 15;
ACHIEVEMENTBUTTON_METAROWHEIGHT = 14;
ACHIEVEMENTBUTTON_MAXHEIGHT = 232;
ACHIEVEMENTBUTTON_TEXTUREHEIGHT = 128;

function AchievementButton_UpdatePlusMinusTexture (button)
	local id = button.id;
	if ( not id ) then
		return; -- This happens when we create buttons
	end

	local display = false;
	if ( GetAchievementNumCriteria(id) ~= 0 ) then
		display = true;
	elseif ( GetPreviousAchievement(id) and button.completed ) then
		display = true;
	end
	
	if ( display ) then
		button.plusMinus:Show();			
		if ( button.collapsed and button.saturated ) then
			button.plusMinus:SetTexCoord(0, .5, 0, .5);
		elseif ( button.collapsed ) then
			button.plusMinus:SetTexCoord(.5, 1, 0, .5);
		elseif ( button.saturated ) then
			button.plusMinus:SetTexCoord(0, .5, .5, 1);
		else
			button.plusMinus:SetTexCoord(.5, 1, .5, 1);
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
	_G[self:GetName() .. "Background"]:SetTexCoord(0, 1, 1-(ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT / 256), 1);
	_G[self:GetName() .. "Glow"]:SetTexCoord(0, 1, 0, ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT / 128);
	
	if ( not self.tracked:GetChecked() ) then
		self.tracked:Hide();
	end
end

function AchievementButton_Expand (self, height)
	if ( not self.collapsed ) then
		return;
	end
	
	self.collapsed = nil;
	AchievementButton_UpdatePlusMinusTexture(self);
	self:SetHeight(height);
	_G[self:GetName() .. "Background"]:SetTexCoord(0, 1, max(0, 1-(height / 256)), 1);
	_G[self:GetName() .. "Glow"]:SetTexCoord(0, 1, 0, (height+5) / 128);
end

function AchievementButton_Saturate (self)
	local name = self:GetName();
	self.saturated = true;	
	_G[name .. "TitleBackground"]:SetTexCoord(0, 0.9765625, 0, 0.3125);
	_G[name .. "Background"]:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
	_G[name .. "Glow"]:SetVertexColor(1.0, 1.0, 1.0);
	self.icon:Saturate();
	self.shield:Saturate();
	self.shield.points:SetVertexColor(1, 1, 1);
	self.reward:SetVertexColor(1, .82, 0);
	self.label:SetVertexColor(1, 1, 1);
	self.description:SetTextColor(0, 0, 0, 1);
	self.description:SetShadowOffset(0, 0);
	AchievementButton_UpdatePlusMinusTexture(self);
	self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
end

function AchievementButton_Desaturate (self)
	local name = self:GetName();
	self.saturated = nil;
	_G[name .. "TitleBackground"]:SetTexCoord(0, 0.9765625, 0.34375, 0.65625);
	_G[name .. "Background"]:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
	_G[name .. "Glow"]:SetVertexColor(.22, .17, .13);
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
	local name = self:GetName();
	self.label = _G[name .. "Label"];
	self.description = _G[name .. "Description"];
	self.hiddenDescription = _G[name .. "HiddenDescription"];
	self.reward = _G[name .. "Reward"];
	self.rewardBackground = _G[name.."RewardBackground"];
	self.icon = _G[name .. "Icon"];
	self.shield = _G[name .. "Shield"];
	self.objectives = _G[name .. "Objectives"];
	self.highlight = _G[name .. "Highlight"];
	self.dateCompleted = _G[name .. "DateCompleted"]
	self.tracked = _G[name .. "Tracked"];
	self.check = _G[name .. "Check"];
	self.plusMinus = _G[name .. "PlusMinus"];
	
	self.dateCompleted:ClearAllPoints();
	self.dateCompleted:SetPoint("TOP", self.shield, "BOTTOM", -3, 6);
	if ( not ACHIEVEMENTUI_FONTHEIGHT ) then
		local _, fontHeight = self.description:GetFont();
		ACHIEVEMENTUI_FONTHEIGHT = fontHeight;
	end
	self.description:SetHeight(ACHIEVEMENTUI_FONTHEIGHT * ACHIEVEMENTUI_MAX_LINES_COLLAPSED);
	self.description:SetWidth(ACHIEVEMENTUI_MAXCONTENTWIDTH);			
	self.hiddenDescription:SetWidth(ACHIEVEMENTUI_MAXCONTENTWIDTH);
	
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
	
	local _, _, _, completed = GetAchievementInfo(id)
	if ( completed ) then
		UIErrorsFrame:AddMessage(ERR_ACHIEVEMENT_WATCH_COMPLETED, 1.0, 0.1, 0.1, 1.0);
		return;
	end
	
	AddTrackedAchievement(id);
	AchievementFrameAchievements_ForceUpdate();
	WatchFrame_Update();
	
	return true;
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
		button.numLines = ceil(button.hiddenDescription:GetHeight() / ACHIEVEMENTUI_FONTHEIGHT);
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
				objectives:SetPoint("TOP", "$parentHiddenDescription", "BOTTOM", 0, -8);
				objectives:SetPoint("LEFT", "$parentIcon", "RIGHT", -5, 0);
				objectives:SetPoint("RIGHT", "$parentShield", "LEFT", -10, 0);
			end
			height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT + objectives:GetHeight();
		else
			objectives:SetPoint("TOP", "$parentHiddenDescription", "BOTTOM", 0, -8);
			height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT + objectives:GetHeight();
		end
	elseif ( completed and GetPreviousAchievement(id) ) then
		objectives:SetHeight(0);
		AchievementButton_ResetCriteria();
		AchievementButton_ResetProgressBars();
		AchievementButton_ResetMiniAchievements();
		AchievementButton_ResetMetas();
		AchievementObjectives_DisplayProgressiveAchievement(objectives, id);
		objectives:SetPoint("TOP", "$parentHiddenDescription", "BOTTOM", 0, -8);
		height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT + objectives:GetHeight();
	else
		objectives:SetHeight(0);	
		AchievementButton_ResetCriteria();
		AchievementButton_ResetProgressBars();
		AchievementButton_ResetMiniAchievements();
		AchievementButton_ResetMetas();
		AchievementObjectives_DisplayCriteria(objectives, id);
		if ( objectives:GetHeight() > 0 ) then
			objectives:SetPoint("TOP", "$parentHiddenDescription", "BOTTOM", 0, -8);
			objectives:SetPoint("LEFT", "$parentIcon", "RIGHT", -5, -25);
			objectives:SetPoint("RIGHT", "$parentShield", "LEFT", -10, 0);
		end
		height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT + objectives:GetHeight();
	end

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

function AchievementButton_ResetCriteria ()
	AchievementButton_ResetTable(AchievementFrame.criteriaTable);
end

function AchievementButton_GetMeta (index)
	local metaCriteriaTable = AchievementFrame.metaCriteriaTable;
	if ( metaCriteriaTable[index] ) then
		return metaCriteriaTable[index];
	end
	
	local frame = CreateFrame("BUTTON", "AchievementFrameMeta" .. index, AchievementFrameAchievements, "MetaCriteriaTemplate");
	AchievementButton_LocalizeMetaAchievement(frame);
	metaCriteriaTable[index] = frame;
	
	return frame;
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
		flags = flags or 0;		-- bug 360115. grabbed from mainline to avoid future issues
		local miniAchievement = AchievementButton_GetMiniAchievement(index);
		
		miniAchievement:Show();
		miniAchievement:SetParent(objectivesFrame);
		_G[miniAchievement:GetName() .. "Icon"]:SetTexture(iconpath);
		if ( index == 1 ) then
			miniAchievement:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", -4, -4);
		elseif ( index == 7 ) then
			miniAchievement:SetPoint("TOPLEFT", AchievementFrame.miniTable[1], "BOTTOMLEFT", 0, -8);
		else
			miniAchievement:SetPoint("TOPLEFT", AchievementFrame.miniTable[index-1], "TOPRIGHT", 4, 0);
		end
		
		miniAchievement.points:SetText(points);
		
		miniAchievement.numCriteria = 0;
		if ( not ( bit.band(flags, ACHIEVEMENT_FLAGS_HAS_PROGRESS_BAR) == ACHIEVEMENT_FLAGS_HAS_PROGRESS_BAR ) ) then
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
				AchievementFrame.metaCriteriaTable[metas-1]:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 20, yPos);
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
		elseif ( bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR ) then
			-- Display this criteria as a progress bar!
			progressBars = progressBars + 1;
			local progressBar = AchievementButton_GetProgressBar(progressBars);
			
			if ( progressBars == 1 ) then
				progressBar:SetPoint("TOP", objectivesFrame, "TOP", 4, -4);
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
					criteria:SetPoint("TOP", objectivesFrame, "TOP", -14, 0);
				else
					criteria:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 0, 0);
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
					AchievementFrame.criteriaTable[i]:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", (position - 1)*(ACHIEVEMENTUI_MAXCONTENTWIDTH/numColumns), 0);
				else
					AchievementFrame.criteriaTable[i]:ClearAllPoints();
					AchievementFrame.criteriaTable[i]:SetPoint("TOPLEFT", AchievementFrame.criteriaTable[position + ((rows - 2) * numColumns)], "BOTTOMLEFT", 0, 0);
				end
			end
			numRows = ceil(numRows/numColumns);
		end
	end

	if ( metas > 0 ) then
		objectivesFrame:SetHeight(numRows * ACHIEVEMENTBUTTON_METAROWHEIGHT + 10);
	else
		objectivesFrame:SetHeight(numRows * ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT);
	end
	objectivesFrame.mode = ACHIEVEMENTMODE_CRITERIA;
end

-- [[ StatsFrames ]]--

function AchievementStatButton_OnLoad(self, parentFrame)
	local name = self:GetName();
	self.background = _G[name.."BG"];
	self.left = _G[name.."HeaderLeft"];
	self.middle = _G[name.."HeaderMiddle"];
	self.right = _G[name.."HeaderRight"];
	self.text = _G[name.."Text"];
	self.title = _G[name.."Title"];
	self.value = _G[name.."Value"];
	self.value:SetVertexColor(1, 0.97, 0.6);
	parentFrame.buttons = parentFrame.buttons or {};
	tinsert(parentFrame.buttons, self);
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
	AchievementFrameSummaryCategoriesStatusBar_Update();
	AchievementFrameSummary_UpdateAchievements(GetLatestCompletedAchievements());
end

function AchievementFrameSummary_UpdateAchievements(...)
	local numAchievements = select("#", ...);
	local id, name, points, completed, month, day, year, description, flags, icon;
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

function AchievementFrameSummaryCategoriesStatusBar_Update()
	local total, completed = GetNumCompletedAchievements();
	AchievementFrameSummaryCategoriesStatusBar:SetMinMaxValues(0, total);
	AchievementFrameSummaryCategoriesStatusBar:SetValue(completed);
	AchievementFrameSummaryCategoriesStatusBarText:SetText(completed.."/"..total);
end

function AchievementFrameSummaryAchievement_OnLoad(self)
	AchievementComparisonPlayerButton_OnLoad(self);
	self.highlight = _G[self:GetName().."Highlight"];
	AchievementFrameSummaryAchievements.buttons = AchievementFrameSummaryAchievements.buttons or {};
	tinsert(AchievementFrameSummaryAchievements.buttons, self);
	self:Saturate();
	self.titleBar:SetVertexColor(1,1,1,0.5);
	self.dateCompleted:Show();
end

function AchievementFrameSummaryCategory_OnLoad (self)
	self:SetMinMaxValues(0, 100);
	self:SetValue(0);
	local name = self:GetName();
	self.text = _G[name .. "Text"];
	
	local categoryName = GetCategoryInfo(self:GetID());
	_G[name .. "Label"]:SetText(categoryName);
end

function AchievementFrame_SelectAchievement(id, forceSelect)
	if ( not AchievementFrame:IsShown() and not forceSelect ) then
		return;
	end
	
	local _, _, _, achCompleted = GetAchievementInfo(id);
	if ( achCompleted and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_INCOMPLETE].func) ) then
		AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
	elseif ( (not achCompleted) and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_COMPLETE].func) ) then
		AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
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
				return;
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
	ClearAchievementComparisonUnit();
end

function AchievementFrameComparison_OnEvent (self, event, ...)
	if ( event == "INSPECT_ACHIEVEMENT_READY" ) then
		AchievementFrameComparisonHeaderPoints:SetText(GetComparisonAchievementPoints());
		AchievementFrameComparison_UpdateStatusBars(achievementFunctions.selectedCategory)
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

function AchievementFrameComparisonStat_OnLoad (self)
	local name = self:GetName();
	self.background = _G[name.."BG"];
	self.left = _G[name.."HeaderLeft"];
	self.middle = _G[name.."HeaderMiddle"];
	self.right = _G[name.."HeaderRight"];
	self.left2 = _G[name.."HeaderLeft2"];
	self.middle2 = _G[name.."HeaderMiddle2"];
	self.right2 = _G[name.."HeaderRight2"];
	self.text = _G[name.."Text"];
	self.title = _G[name.."Title"];
	self.value = _G[name.."Value"];
	self.value:SetVertexColor(1, 0.97, 0.6);
	self.friendValue = _G[name.."ComparisonValue"];
	self.friendValue:SetVertexColor(1, 0.97, 0.6);
	self.mouseover = _G[name.. "Mouseover"];
end

function AchievementComparisonPlayerButton_Saturate (self)
	local name = self:GetName();
	_G[name .. "TitleBackground"]:SetTexCoord(0, 0.9765625, 0, 0.3125);
	_G[name .. "Background"]:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
	_G[name .. "Glow"]:SetVertexColor(1.0, 1.0, 1.0);
	self.icon:Saturate();
	self.shield:Saturate();
	self.shield.points:SetVertexColor(1, 1, 1);
	self.label:SetVertexColor(1, 1, 1);
	self.description:SetTextColor(0, 0, 0, 1);
	self.description:SetShadowOffset(0, 0);
	self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
end

function AchievementComparisonPlayerButton_Desaturate (self)
	local name = self:GetName();
	_G[name .. "TitleBackground"]:SetTexCoord(0, 0.9765625, 0.34375, 0.65625);
	_G[name .. "Background"]:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
	_G[name .. "Glow"]:SetVertexColor(.22, .17, .13);
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
	
	self.label = _G[name .. "Label"];
	self.description = _G[name .. "Description"];
	self.icon = _G[name .. "Icon"];
	self.shield = _G[name .. "Shield"];
	self.dateCompleted = _G[name .. "DateCompleted"];
	self.titleBar = _G[name .. "TitleBackground"];
	
	
	self.Saturate = AchievementComparisonPlayerButton_Saturate;
	self.Desaturate = AchievementComparisonPlayerButton_Desaturate;
	
	self:Desaturate();
end

function AchievementComparisonFriendButton_Saturate (self)
	local name = self:GetName();
	_G[name .. "TitleBackground"]:SetTexCoord(0.3, 0.575, 0, 0.3125);
	_G[name .. "Background"]:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
	_G[name .. "Glow"]:SetVertexColor(1.0, 1.0, 1.0);
	self.icon:Saturate();
	self.shield:Saturate();
	self.shield.points:SetVertexColor(1, 1, 1);
	self.status:SetVertexColor(1, .82, 0);
	self:SetBackdropBorderColor(ACHIEVEMENT_RED_BORDER_COLOR:GetRGB());
end

function AchievementComparisonFriendButton_Desaturate (self)
	local name = self:GetName();
	_G[name .. "TitleBackground"]:SetTexCoord(0.3, 0.575, 0.34375, 0.65625);
	_G[name .. "Background"]:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
	_G[name .. "Glow"]:SetVertexColor(.22, .17, .13);
	self.icon:Desaturate();
	self.shield:Desaturate();
	self.shield.points:SetVertexColor(.65, .65, .65);
	self.status:SetVertexColor(.65, .65, .65);
	self:SetBackdropBorderColor(.5, .5, .5);
end

function AchievementComparisonFriendButton_OnLoad (self)
	local name = self:GetName();
	
	self.status = _G[name .. "Status"];
	self.icon = _G[name .. "Icon"];
	self.shield = _G[name .. "Shield"];
	
	self.Saturate = AchievementComparisonFriendButton_Saturate;
	self.Desaturate = AchievementComparisonFriendButton_Desaturate;
	
	self:Desaturate();
end

function AchievementFrame_IsFeatOfStrength()
	if ( AchievementFrame.selectedTab == 1 and achievementFunctions.selectedCategory == AchievementFrame.displayCategories[#AchievementFrame.displayCategories].id ) then
		return true;
	end
	return false;
end

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