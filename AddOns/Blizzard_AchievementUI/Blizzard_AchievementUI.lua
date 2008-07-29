local desaturateSupported = IsDesaturateSupported();

ACHIEVEMENTUI_CATEGORIES = {};
ACHIEVEMENTUI_ACHIEVEMENTS = {};

ACHIEVEMENTUI_GOLDBORDER_R = 1;
ACHIEVEMENTUI_GOLDBORDER_G = 0.675;
ACHIEVEMENTUI_GOLDBORDER_B = 0.125;
ACHIEVEMENTUI_GOLDBORDER_A = 1;

ACHIEVEMENTUI_REDBORDER_R = 0.7;
ACHIEVEMENTUI_REDBORDER_G = 0.15;
ACHIEVEMENTUI_REDBORDER_B = 0.05;
ACHIEVEMENTUI_REDBORDER_A = 1;

-- Temporary access method

SlashCmdList["ACHIEVEMENTUI"] = function() if ( AchievementFrame:IsShown() ) then AchievementFrame:Hide(); else AchievementFrame:Show(); end end;
SLASH_ACHIEVEMENTUI1 = "/ach";
SLASH_ACHIEVEMENTUI2 = "/achieve";
SLASH_ACHIEVEMENTUI3 = "/achievement";
SLASH_ACHIEVEMENTUI4 = "/achievements";


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
		
		AchievementFrameCategories_Populate(self);
		AchievementFrameCategories_RefreshDisplay(self);
		AchievementFrameCategories_SelectButton(self.buttons[1]);
		self:UnregisterEvent(event)		
	end
end

function AchievementFrameCategories_Populate (categoryList)
	local buttons, categories = categoryList.buttons, ACHIEVEMENTUI_CATEGORIES;
	assert(buttons and categories);
	
	GetCategoryList(categories);
	
	local numButtons, numCategories = #buttons, #categories;
	
	if ( numButtons >= numCategories ) then
		-- Hide unused buttons if there are any.
		for i = numCategories + 1, numButtons do
			buttons[i]:Hide();
		end
	elseif ( numButtons == 0 ) then
			-- No buttons. Create our first button and use it to figure out how many more we can create.
			local button = AchievementFrameCategories_CreateButton(categoryList);
			
			local buttonHeight = button:GetHeight();
			local categoryHeight = categoryList:GetHeight();
			
			for i = 2, math.min(math.floor(categoryHeight/buttonHeight), numCategories) do
				AchievementFrameCategories_CreateButton(categoryList);
			end
	else
		-- Create new buttons if we need them. max(numButtons, 1) is for when initializing the CategoryList.
		local buttonHeight = buttons[1]:GetHeight();
		local categoryHeight = categoryList:GetHeight();
		
		for i = numButtons, math.min(math.floor(categoryHeight/buttonHeight), numCategories) do
			AchievementFrameCategories_CreateButton(categoryList);
		end
	end
end

function AchievementFrameCategories_RefreshDisplay (categoryList)
	local buttons, categories = categoryList.buttons, ACHIEVEMENTUI_CATEGORIES;
	assert(buttons and categories);
	
	local numCategories = #categories;
	
	for i = 1, numCategories do
		-- Gonna need to put an offset in here when this list gets scrollable.
		AchievementFrameCategories_DisplayButton(buttons[i], categories[i]);
	end
end

function AchievementFrameCategories_DisplayButton (button, categoryID)
	assert(button and categoryID);
	local categoryName, parentID, flags = GetCategoryInfo(categoryID);
	button.label:SetText(categoryName);
	button.categoryID = categoryID;
	button.parentID = parentID;
	button.flags = flags;
end

function AchievementFrameCategories_SelectButton (button)
	local categoryList = button:GetParent();
	
	AchievementFrameCategories_ClearSelection (categoryList);
	button.isSelected = true;
	button:SetBackdropColor(ACHIEVEMENT_CATEGORY_HIGHLIGHT_R, ACHIEVEMENT_CATEGORY_HIGHLIGHT_G, ACHIEVEMENT_CATEGORY_HIGHLIGHT_B, ACHIEVEMENT_CATEGORY_HIGHLIGHT_A);

	AchievementFrame.selectedCategory = button.categoryID;
	AchievementFrameAchievementsList.offset = 0;
	AchievementFrameAchievementsListScrollBar:SetValue(0);
	AchievementFrameAchievements_Update();
	-- Do other stuff here to display the achievements within the category over on AchievementFrameAchievements.
end

function AchievementFrameCategories_ClearSelection (categoryList)
	assert(categoryList and categoryList.buttons);
	
	local buttons = categoryList.buttons;
	
	for _, button in next, buttons do
		button.isSelected = nil;
		button:SetBackdropColor(ACHIEVEMENT_CATEGORY_NORMAL_R, ACHIEVEMENT_CATEGORY_NORMAL_G, ACHIEVEMENT_CATEGORY_NORMAL_B, ACHIEVEMENT_CATEGORY_NORMAL_A);
	end
end

function AchievementFrameCategories_CreateButton (categoryList)
	-- These constants are only used here. Move them outside of this function if you want to use them somewhere else. Keeping them here saves global lookups.
	local ACHIEVEMENT_CATEGORY_OFFSET_X = 0;
	local ACHIEVEMENT_CATEGORY_OFFSET_Y = 0;
	local ACHIEVEMENT_CATEGORY_INITIAL_OFFSET_X = 5;
	local ACHIEVEMENT_CATEGORY_INITIAL_OFFSET_Y = -5;


	local buttons = categoryList.buttons;
	
	local numButtons = #buttons;
	local nextButtonName = categoryList:GetName() .. "Button" .. (numButtons + 1);
	
	local button = CreateFrame("FRAME", nextButtonName, categoryList, "AchievementCategoryTemplate");
	if ( numButtons == 0 ) then
		--First button
		button:SetPoint("TOPLEFT", categoryList, "TOPLEFT", ACHIEVEMENT_CATEGORY_INITIAL_OFFSET_X, ACHIEVEMENT_CATEGORY_INITIAL_OFFSET_Y);
	else
		--Some other button :P
		button:SetPoint("TOPLEFT", buttons[numButtons], "BOTTOMLEFT", ACHIEVEMENT_CATEGORY_OFFSET_X, ACHIEVEMENT_CATEGORY_OFFSET_Y);
	end
	
	tinsert(buttons, button);
	
	return button;
end

-- [[ AchievementCategoryButton ]] --

ACHIEVEMENT_CATEGORY_NORMAL_R = 0;
ACHIEVEMENT_CATEGORY_NORMAL_G = 0;
ACHIEVEMENT_CATEGORY_NORMAL_B = 0;
ACHIEVEMENT_CATEGORY_NORMAL_A = .9;

ACHIEVEMENT_CATEGORY_HIGHLIGHT_R = 0;
ACHIEVEMENT_CATEGORY_HIGHLIGHT_G = .6;
ACHIEVEMENT_CATEGORY_HIGHLIGHT_B = 0;
ACHIEVEMENT_CATEGORY_HIGHLIGHT_A = .65;

function AchievementCategoryButton_OnLoad (button)
	button:SetBackdropBorderColor(ACHIEVEMENTUI_GOLDBORDER_R, ACHIEVEMENTUI_GOLDBORDER_G, ACHIEVEMENTUI_GOLDBORDER_B, ACHIEVEMENTUI_GOLDBORDER_A);
	button:SetBackdropColor(ACHIEVEMENT_CATEGORY_NORMAL_R, ACHIEVEMENT_CATEGORY_NORMAL_G, ACHIEVEMENT_CATEGORY_NORMAL_B, ACHIEVEMENT_CATEGORY_NORMAL_A);
	button:EnableMouse(true);
	button:EnableMouseWheel(true);
	
	local buttonName = button:GetName();
	
	button.label = getglobal(buttonName .. "Label");
end

-- These functions simulate button behaviors for our frames.

function AchievementCategoryButton_OnEnter (button)
	button:SetBackdropColor(ACHIEVEMENT_CATEGORY_HIGHLIGHT_R, ACHIEVEMENT_CATEGORY_HIGHLIGHT_G, ACHIEVEMENT_CATEGORY_HIGHLIGHT_B, ACHIEVEMENT_CATEGORY_HIGHLIGHT_A); 
end

function AchievementCategoryButton_OnLeave (button)
	if ( not button.mouseDown and not button.isSelected ) then
		button:SetBackdropColor(ACHIEVEMENT_CATEGORY_NORMAL_R, ACHIEVEMENT_CATEGORY_NORMAL_G, ACHIEVEMENT_CATEGORY_NORMAL_B, ACHIEVEMENT_CATEGORY_NORMAL_A);
	end
end

function AchievementCategoryButton_OnMouseDown (button, mouseButton)
	button.mouseDown = true;
	button:SetBackdropColor(ACHIEVEMENT_CATEGORY_HIGHLIGHT_R, ACHIEVEMENT_CATEGORY_HIGHLIGHT_G, ACHIEVEMENT_CATEGORY_HIGHLIGHT_B, ACHIEVEMENT_CATEGORY_HIGHLIGHT_A); 
end

function AchievementCategoryButton_OnMouseUp (button, mouseButton)
	button.mouseDown = nil;
	if ( MouseIsOver(button) ) then
		-- This would be a click!
		AchievementFrameCategories_SelectButton(button);
	else
		button:SetBackdropColor(ACHIEVEMENT_CATEGORY_NORMAL_R, ACHIEVEMENT_CATEGORY_NORMAL_G, ACHIEVEMENT_CATEGORY_NORMAL_B, ACHIEVEMENT_CATEGORY_NORMAL_A);
	end
end

-- [[ AchievementFrameAchievements ]] --

function AchievementFrameAchievements_OnLoad (self)
	self:SetBackdropBorderColor(ACHIEVEMENTUI_GOLDBORDER_R, ACHIEVEMENTUI_GOLDBORDER_G, ACHIEVEMENTUI_GOLDBORDER_B, ACHIEVEMENTUI_GOLDBORDER_A);
end

local displayedElements = {};

function AchievementFrameAchievements_Update (category)
	category = category or AchievementFrame.selectedCategory;
		
	local achievements = ACHIEVEMENTUI_ACHIEVEMENTS
	local offset = FauxScrollFrame_GetOffset(AchievementFrameAchievementsList) or 0;
	local buttons = AchievementFrameAchievements.buttons;
	local numAchievements, numCompleted = GetCategoryNumAchievements(category);
	local numButtons = #buttons;
	
	if ( numAchievements > numButtons ) then
		AchievementFrameAchievements_DisplayScrollBar();
	else
		AchievementFrameAchievements_HideScrollBar()
	end
	
	FauxScrollFrame_Update(AchievementFrameAchievementsList, numAchievements, numButtons, ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT);
	
	local selection = AchievementFrameAchievements.selection;
	if ( selection ) then
		AchievementFrameAchievements_ClearSelection();
	end
	
	local totalHeight = 0;
	
	for i = 1, numButtons do
		achievementIndex = i + offset;
		local id = AchievementButton_DisplayAchievement(buttons[i], category, achievementIndex);
		if ( id == selection and not AchievementFrameAchievements.selection ) then
			AchievementFrameAchievements_SelectButton(AchievementFrameAchievements, buttons[i]);
		end
		totalHeight = totalHeight + buttons[i]:GetHeight();
	end
	
	-- Update the height of the scrollChild.
	buttons[1]:GetParent():SetHeight(totalHeight);
	AchievementFrameAchievementsContainer:UpdateScrollChildRect();
	
	if ( selection ) then
		AchievementFrameAchievements.selection = selection;
	end
end

function AchievementFrameAchievements_HideScrollBar ()
	local list = AchievementFrameAchievementsList;
	
	if ( not list:IsShown() ) then
		return;
	end
	
	AchievementFrameAchievements:SetWidth(AchievementFrameAchievements:GetWidth() + list:GetWidth());
	
	local buttons = AchievementFrameAchievements.buttons;
	local newWidth = buttons[1]:GetWidth() + list:GetWidth();
	for i, button in next, buttons do
		button:SetWidth(newWidth);
	end
	
	list:Hide();
end

function AchievementFrameAchievements_DisplayScrollBar ()
	local list = AchievementFrameAchievementsList;
	
	if ( list:IsShown() ) then
		return;
	end
	
	AchievementFrameAchievements:SetWidth(AchievementFrameAchievements:GetWidth() - list:GetWidth());	
	
	local buttons = AchievementFrameAchievements.buttons;
	local newWidth = buttons[1]:GetWidth() - list:GetWidth();
	for i, button in next, buttons do
		button:SetWidth(newWidth);
	end
	
	list:Show();
end

		-- local id, name, points, completed, month, day, year, hour, minute, description, flags = GetAchievementInfo(category, i + offset);
		-- if ( id ) then
			-- achievements[category][id] = achievements[category][id] or {};
			-- local achievement = achievements[category][id]
			-- achievement["name"] = name;
			-- achievement["points"] = points;
			-- achievement["completed"] = (completed and true);
			-- achievement["month"] = month;
			-- achievement["day"] = day;
			-- achievement["year"] = year;
			-- achievement["hour"] = hour;
			-- achievement["minute"] = minute;
			-- achievement["desc"] = description;
			-- achievement["flags"] = flags;
			
			-- AchievementButton_DisplayAchievement(self.buttons[i], achievement);
		-- end
	-- end
-- end

function AchievementFrameAchievements_SelectButton (self, button)
	for _, button in next, self.buttons do
		button:Collapse();
		button.selected = nil;
	end
	
	self.selection = button.id;
	button.selected = true;
	button:Expand();
	
	AchievementButton_DisplayCriteria(button);
end

function AchievementFrameAchievements_ClearSelection ()
	for _, button in next, AchievementFrameAchievements.buttons do
		button:Collapse();
		button.selected = nil;
	end
	
	AchievementFrameAchievements.selection = nil;
end

-- [[ Achievement Icon ]] --
if ( desaturateSupported ) then
	function AchievementIcon_Desaturate (self)
		self.bling:SetDesaturated(true);
		self.frame:SetDesaturated(true);
		self.texture:SetDesaturated(true);
	end

	function AchievementIcon_Saturate (self)
		self.bling:SetDesaturated(false);
		self.frame:SetDesaturated(false);
		self.texture:SetDesaturated(false);
	end
else
	function AchievementIcon_Desaturate (self)
		self.bling:SetVertexColor(.3, .35, .5, 1);
		self.frame:SetVertexColor(.3, .35, .5, 1);
		self.texture:SetVertexColor(.3, .35, .5, 1);
	end

	function AchievementIcon_Saturate (self)
		self.bling:SetVertexColor(1, 1, 1, 1);
		self.frame:SetVertexColor(1, 1, 1, 1);
		self.texture:SetVertexColor(1, 1, 1, 1);
	end
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

if ( desaturateSupported ) then
	function AchievementShield_Desaturate (self)
		self.icon:SetDesaturated(true);
	end

	function AchievementShield_Saturate (self)
		self.icon:SetDesaturated(false);
	end
else
	function AchievementShield_Desaturate (self)
		self.icon:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Shield-Desaturated");
	end
	
	function AchievementShield_Saturate (self)
		self.icon:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Shield");
	end
end

function AchievementShield_OnLoad (self)
	local name = self:GetName();
	self.icon = getglobal(name .. "Icon");
	self.points = getglobal(name .. "Points");
	
	self.Desaturate = AchievementShield_Desaturate;
	self.Saturate = AchievementShield_Saturate;
end

-- [[ AchievementButton ]] --

ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT = 82;
ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT = 15;
ACHIEVEMENTBUTTON_MAXHEIGHT = 232;
ACHIEVEMENTBUTTON_TEXTUREHEIGHT = 128;

ACHIEVEMENTBUTTON_TSUNAMI_MINALPHA = .15;
ACHIEVEMENTBUTTON_TSUNAMI_MAXALPHA = .25;
	
local function collapseTsunamis (tsunamiTable)
	for i, tsunami in next, tsunamiTable do
		tsunami:Hide();
	end
end

local function expandTsunamis (tsunamiTable, rows)
	assert(tsunamiTable)
	
	rows = rows or 3;
	
	local alphaRange = (ACHIEVEMENTBUTTON_TSUNAMI_MAXALPHA - ACHIEVEMENTBUTTON_TSUNAMI_MINALPHA) / rows;
	
	-- We use rows + 1 here because we always have one tsunami shown.
	for i = 1, rows do
		local tsunami = tsunamiTable[i];
		tsunami:Show();
		tsunami:SetVertexColor(1, 1, 1, ACHIEVEMENTBUTTON_TSUNAMI_MINALPHA + (alphaRange * (i-1)));
	end
end

function AchievementButton_Collapse (self)
	if ( self.collapsed ) then
		return;
	end
	
	self.collapsed = true;
	
	self:SetHeight(ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT);
	
	getglobal(self:GetName() .. "Background"):SetTexCoord(0, 1, 0, (ACHIEVEMENTBUTTON_TEXTUREHEIGHT * (ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT / ACHIEVEMENTBUTTON_MAXHEIGHT)) / ACHIEVEMENTBUTTON_TEXTUREHEIGHT);
	
	collapseTsunamis(self.rightTsunamis);
	collapseTsunamis(self.leftTsunamis);
end

function AchievementButton_Expand (self, rows)
	if ( not self.collapsed ) then
		return;
	end
	
	rows = rows or 3;
	
	self.collapsed = nil;
	
	local height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT + (ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT*rows);
	
	self:SetHeight(height);
	getglobal(self:GetName() .. "Background"):SetTexCoord(0, 1, 0, (ACHIEVEMENTBUTTON_TEXTUREHEIGHT * (ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT / height)) / ACHIEVEMENTBUTTON_TEXTUREHEIGHT);
	
	
	expandTsunamis(self.rightTsunamis, rows);
	expandTsunamis(self.leftTsunamis, rows);
end

if ( desaturateSupported ) then
	function AchievementButton_Saturate (self)
		local name = self:GetName();
		
		getglobal(name .. "RewardBackground"):SetDesaturated(false);
		getglobal(name .. "TitleBackground"):SetDesaturated(false);
		getglobal(name .. "Background"):SetDesaturated(false);
		getglobal(name .. "BackgroundOverlay"):Hide();
		self.icon:Saturate();
		self.shield:Saturate();
		self.reward:SetVertexColor(1, .82, 0, 1);
		self.description:SetVertexColor(0, 0, 0, 1);
		self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
	end

	function AchievementButton_Desaturate (self)
		local name = self:GetName();
		
		getglobal(name .. "RewardBackground"):SetDesaturated(true);
		getglobal(name .. "TitleBackground"):SetDesaturated(true);
		getglobal(name .. "Background"):SetDesaturated(true);
		getglobal(name .. "BackgroundOverlay"):Show();
		self.icon:Desaturate();
		self.shield:Desaturate();
		self.reward:SetVertexColor(.8, .8, .8, 1);
		self.description:SetVertexColor(1, 1, 1, 1);
		self:SetBackdropBorderColor(.5, .5, .5, 1);
	end
else
	function AchievementButton_Saturate (self)
		local name = self:GetName();
		
		getglobal(name .. "RewardBackground"):SetVertexColor(.2, .31, .5, .5);
		getglobal(name .. "TitleBackground"):SetVertexColor(.2, .31, .5, .5);
		getglobal(name .. "Background"):SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
		getglobal(name .. "BackgroundOverlay"):Hide();
		self.icon:Saturate();
		self.shield:Saturate();
		self.reward:SetVertexColor(1, .82, 0, 1);
		self.description:SetVertexColor(0, 0, 0, 1);
		self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
	end
	
	function AchievementButton_Desaturate (self)
		local name = self:GetName();
	
		getglobal(name .. "RewardBackground"):SetVertexColor(.2, .31, .5, .5);
		getglobal(name .. "TitleBackground"):SetVertexColor(.2, .31, .5, .5);
		getglobal(name .. "Background"):SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated");
		getglobal(name .. "BackgroundOverlay"):Show();
		self.icon:Desaturate();
		self.shield:Desaturate();
		self.reward:SetVertexColor(.8, .8, .8, 1);
		self.description:SetVertexColor(1, 1, 1, 1);
		self:SetBackdropBorderColor(.5, .5, .5, 1);
	end
end

function AchievementButton_OnLoad (self)
	local name = self:GetName();
	AchievementButton_CreateTextures(self, name);
	
	self.label = getglobal(name .. "Label");
	self.description = getglobal(name .. "Description");
	self.reward = getglobal(name .. "Reward");
	self.icon = getglobal(name .. "Icon");
	self.shield = getglobal(name .. "Shield");
	
	self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
	self.Collapse = AchievementButton_Collapse;
	self.Expand = AchievementButton_Expand;
	self.Saturate = AchievementButton_Saturate;
	self.Desaturate = AchievementButton_Desaturate;
	
	self:Collapse();
	self:Desaturate();
	
	-- self:GetParent():GetParent() is AchievementFrameAchievements
	--local AchievementFrameAchievements = self:GetParent():GetParent();
	AchievementFrameAchievements.buttons = AchievementFrameAchievements.buttons or {};
	tinsert(AchievementFrameAchievements.buttons, self);
end

function AchievementButton_CreateTextures (self, name)
	local name = name or self:GetName();
	self.rightTsunamis = self.rightTsunamis or { getglobal(name .. "RightTsunami1") };
	self.leftTsunamis = self.leftTsunamis or { getglobal(name .. "LeftTsunami1") };	
	
	local numTsunamis = #self.rightTsunamis;
	local numTsunamisNeeded = (self:GetHeight() - ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT) / ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT;
	
	for i = numTsunamis + 1, numTsunamisNeeded + 1 do
		local tsunami = self:CreateTexture(name .. "RightTsunami" .. i, "BACKGROUND", "AchievementRightTsunamiTemplate");
		tsunami:ClearAllPoints();
		tsunami:SetPoint("TOPLEFT", self.rightTsunamis[i-1], "BOTTOMLEFT");
		tinsert(self.rightTsunamis, tsunami);
		
		tsunami = self:CreateTexture(name .. "LeftTsunami" .. i, "BACKGROUND", "AchievementLeftTsunamiTemplate");
		tsunami:ClearAllPoints();
		tsunami:SetPoint("TOPLEFT", self.leftTsunamis[i-1], "BOTTOMLEFT");
		tinsert(self.leftTsunamis, tsunami);
	end
end

function AchievementButton_OnClick (self)
	AchievementFrameAchievements_SelectButton(AchievementFrameAchievements, self);
end

function AchievementButton_DisplayAchievement (button, category, achievement)
	local id, name, points, completed, month, day, year, hour, minute, description, flags = GetAchievementInfo(category, achievement);
	-- assert(button and achievement)
	button.id = id;
	button.label:SetText(name)
	button.description:SetText(description);
	button.shield.points:SetText(points);
	if ( completed ) then
		button:Saturate();
	else
		button:Desaturate();
	end
	
	return id;
end

function AchievementButton_DisplayCriteria (self)

end

function AchievementList_OnMouseWheel (delta, scrollBar)
	ScrollFrameTemplate_OnMouseWheel(delta, scrollBar);
	
	-- local minVal, maxVal = scrollBar:GetMinMaxValues();
	-- local value = scrollBar:GetValue();
	
	-- msg({minVal, maxVal, value})
	
	-- if ( maxVal == value and not scrollBar.maxed ) then
		-- scrollBar.mined = nil;
		-- scrollBar.maxed = true;
		-- AchievementFrameAchievementsContainer:SetVerticalScroll(AchievementFrameAchievementsContainer:GetVerticalScrollRange())
	-- elseif ( minVal == value and not scrollBar.mined ) then
		-- scrollBar.mined = true;
		-- scrollBar.maxed = nil;
		-- AchievementFrameAchievementsContainer:SetVerticalScroll(0)
	-- end
end
