-- Note: If you're looking to modify any of the actual interface options, you probably want UIOptionsPanels.lua

local blizzardCategories = {};
INTERFACEOPTIONS_ADDONCATEGORIES = {};
INTERFACEOPTIONSLIST_BUTTONHEIGHT = 18;

function InterfaceOptionsFrameCancel_OnClick ()
	--Iterate through registered panels and run their cancel methods in a taint-safe fashion

	for _, category in next, blizzardCategories do
		securecall("pcall", category.cancel, category);
	end
	
	for _, category in next, INTERFACEOPTIONS_ADDONCATEGORIES do
		securecall("pcall", category.cancel, category);
	end
			
	InterfaceOptionsFrame_Show();
end

function InterfaceOptionsFrameOkay_OnClick ()
	--Iterate through registered panels and run their okay methods in a taint-safe fashion

	for _, category in next, blizzardCategories do
		securecall("pcall", category.okay, category);
	end
	
	for _, category in next, INTERFACEOPTIONS_ADDONCATEGORIES do
		securecall("pcall", category.okay, category);
	end

	InterfaceOptionsFrame_Show();
end

function InterfaceOptionsFrameDefaults_OnClick ()
	StaticPopup_Show("CONFIRM_RESET_SETTINGS");
end

function InterfaceOptionsFrame_SetAllToDefaults ()
	--Iterate through registered panels and run their default methods in a taint-safe fashion

	for _, category in next, blizzardCategories do
		securecall("pcall", category.default, category);
	end
	
	for _, category in next, INTERFACEOPTIONS_ADDONCATEGORIES do
		securecall("pcall", category.default, category);
	end
	
	--Run the OnShow method of the currently displayed panel so that it can update any values that were changed.
	local displayedFrame = InterfaceOptionsFramePanelContainer.displayedFrame;
	if ( displayedFrame and displayedFrame.GetScript ) then
		local script = displayedFrame:GetScript("OnShow");
		if ( script ) then
			securecall(script, displayedFrame);
		end
	end
end

function InterfaceOptionsFrame_SetCurrentToDefaults ()
	local displayedFrame = InterfaceOptionsFramePanelContainer.displayedFrame;
	
	if ( not displayedFrame or not displayedFrame.default ) then
		return;
	end
	
	securecall("pcall", displayedFrame.default, displayedFrame);
	if ( displayedFrame and displayedFrame.GetScript ) then
		local script = displayedFrame:GetScript("OnShow");
		if ( script ) then
			securecall(script, displayedFrame);
		end
	end
end

function InterfaceOptionsFrame_OnLoad (self)
	--Make sure all the UVars get their default values set, since systems that require them to be defined will be loaded before anything in UIOptionsPanels
	self:RegisterEvent("VARIABLES_LOADED");
	InterfaceOptionsFrame_InitializeUVars();
	PanelTemplates_SetNumTabs(self, 2);
	InterfaceOptionsFrame.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);	
end

function InterfaceOptionsFrame_OnShow ()
	--Refresh the two category lists and display the "Controls" group of options if nothing is selected.
	InterfaceCategoryList_Update();
	InterfaceAddOnsList_Update();
	if ( not InterfaceOptionsFramePanelContainer.displayedFrame ) then
		InterfaceOptionsFrameCategories.buttons[1]:Click();
	end
end

function InterfaceOptionsFrame_OnHide ()
	--Yay for playing sounds
	PlaySound("gsTitleOptionExit");
	
	if ( InterfaceOptionsFrame.lastFrame ) then
		ShowUIPanel(InterfaceOptionsFrame.lastFrame);
		InterfaceOptionsFrame.lastFrame = nil;
	end
	
	UpdateMicroButtons();
end

uvarInfo = {
	["SIMPLE_CHAT"] = { default = "0", cvar = "useSimpleChat", event = "SIMPLE_CHAT_TEXT" },
	["CHAT_LOCKED"] = { default = "0", cvar = "chatLocked", event = "CHAT_LOCKED_TEXT" },
	["REMOVE_CHAT_DELAY"] = { default = "0", cvar = "removeChatDelay", event = "REMOVE_CHAT_DELAY_TEXT" },
	["SHOW_NEWBIE_TIPS"] = { default = "1", cvar = "showNewbieTips", event = "SHOW_NEWBIE_TIPS_TEXT" },
	["LOCK_ACTIONBAR"] = { default = "0", cvar = "lockActionBars", event = "LOCK_ACTIONBAR_TEXT" },
	["SHOW_BUFF_DURATIONS"] = { default = "0", cvar = "buffDurations", event = "SHOW_BUFF_DURATION_TEXT" },
	["ALWAYS_SHOW_MULTIBARS"] = { default = "0", cvar = "alwaysShowActionBars", event = "ALWAYS_SHOW_MULTIBARS_TEXT" },
	["SHOW_PARTY_PETS"] = { default = "1", cvar = "showPartyPets", event = "SHOW_PARTY_PETS_TEXT" },
	["QUEST_FADING_DISABLE"] = { default = "0", cvar = "questFadingDisable", event = "SHOW_QUEST_FADING_TEXT" },
	["SHOW_PARTY_BACKGROUND"] = { default = "0", cvar = "showPartyBackground", event = "SHOW_PARTY_BACKGROUND_TEXT" },
	["HIDE_PARTY_INTERFACE"] = { default = "0", cvar = "hidePartyInRaid", event = "HIDE_PARTY_INTERFACE_TEXT" },
	["SHOW_TARGET_OF_TARGET"] = { default = "0", cvar = "showTargetOfTarget", event = "SHOW_TARGET_OF_TARGET_TEXT" },
	["SHOW_TARGET_OF_TARGET_STATE"] = { default = "5", cvar = "targetOfTargetMode", event = "SHOW_TARGET_OF_TARGET_STATE" },
	["WORLD_PVP_OBJECTIVES_DISPLAY"] = { default = "2", cvar = "displayWorldPVPObjectives", event = "WORLD_PVP_OBJECTIVES_DISPLAY" },
	["AUTO_QUEST_WATCH"] = { default = "1", cvar = "autoQuestWatch", event = "AUTO_QUEST_WATCH_TEXT" },
	["LOOT_UNDER_MOUSE"] = { default = "0", cvar = "lootUnderMouse", event = "LOOT_UNDER_MOUSE_TEXT" },
	["AUTO_LOOT_DEFAULT"] = { default = "0", cvar = "autoLootDefault", event = "AUTO_LOOT_DEFAULT_TEXT" },
	["SHOW_COMBAT_TEXT"] = { default = "0", cvar = "enableCombatText", event = "SHOW_COMBAT_TEXT_TEXT" },
	["COMBAT_TEXT_SHOW_LOW_HEALTH_MANA"] = { default = "0", cvar = "fctLowManaHealth", event = "COMBAT_TEXT_SHOW_LOW_HEALTH_MANA_TEXT" },
	["COMBAT_TEXT_SHOW_AURAS"] = { default = "0", cvar = "fctAuras", event = "COMBAT_TEXT_SHOW_AURAS_TEXT" },
	["COMBAT_TEXT_SHOW_AURA_FADE"] = { default = "0", cvar = "fctAuras", event = "COMBAT_TEXT_SHOW_AURAS_TEXT" },
	["COMBAT_TEXT_SHOW_COMBAT_STATE"] = { default = "0", cvar = "fctCombatState", event = "COMBAT_TEXT_SHOW_COMBAT_STATE_TEXT" },
	["COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"] = { default = "0", cvar = "fctDodgeParryMiss", event = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS_TEXT" },
	["COMBAT_TEXT_SHOW_RESISTANCES"] = { default = "0", cvar = "fctDamageReduction", event = "COMBAT_TEXT_SHOW_RESISTANCES_TEXT" },
	["COMBAT_TEXT_SHOW_REPUTATION"] = { default = "0", cvar = "fctRepChanges", event = "COMBAT_TEXT_SHOW_REPUTATION_TEXT" },
	["COMBAT_TEXT_SHOW_REACTIVES"] = { default = "0", cvar = "fctReactives", event = "COMBAT_TEXT_SHOW_REACTIVES_TEXT" },
	["COMBAT_TEXT_SHOW_FRIENDLY_NAMES"] = { default = "0", cvar = "fctFriendlyHealers", event = "COMBAT_TEXT_SHOW_FRIENDLY_NAMES_TEXT" },
	["COMBAT_TEXT_SHOW_COMBO_POINTS"] = { default = "0", cvar = "fctComboPoints", event = "COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT" },
	["COMBAT_TEXT_SHOW_ENERGIZE"] = { default = "0", cvar = "fctEnergyGains", event = "COMBAT_TEXT_SHOW_ENERGIZE_TEXT" },
	["COMBAT_TEXT_SHOW_PERIODIC_ENERGIZE"] = { default = "0", cvar = "fctPeriodicEnergyGains", event = "COMBAT_TEXT_SHOW_PERIODIC_ENERGIZE_TEXT" },
	["COMBAT_TEXT_FLOAT_MODE"] = { default = "1", cvar = "combatTextFloatMode", event = "COMBAT_TEXT_FLOAT_MODE" },
	["COMBAT_TEXT_SHOW_HONOR_GAINED"] = { default = "0", cvar = "fctHonorGains", event = "COMBAT_TEXT_SHOW_HONOR_GAINED_TEXT" },
	["ALWAYS_SHOW_MULTIBARS"] = { default = "0", cvar = "alwaysShowActionBars", },
	["SHOW_CASTABLE_BUFFS"] = { default = "0", cvar = "showCastableBuffs", event = "SHOW_CASTABLE_BUFFS_TEXT" },
	["SHOW_DISPELLABLE_DEBUFFS"] = { default = "1", cvar = "showDispelDebuffs", event = "SHOW_DISPELLABLE_DEBUFFS_TEXT" },
}

 function InterfaceOptionsFrame_OnEvent (self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		InterfaceOptionsFrame_LoadUVars();
	end
end

function InterfaceOptionsFrame_Show ()
	if ( InterfaceOptionsFrame:IsShown() ) then
		InterfaceOptionsFrame:Hide();
	else
		InterfaceOptionsFrame:Show();
	end
end

function InterfaceOptionsFrame_TabOnClick ()
	if ( InterfaceOptionsFrame.selectedTab == 1 ) then
		InterfaceOptionsFrameCategories:Show();
		InterfaceOptionsFrameAddOns:Hide();
		InterfaceOptionsFrameTab1TabSpacer:Show();
		InterfaceOptionsFrameTab2TabSpacer1:Hide();
		InterfaceOptionsFrameTab2TabSpacer2:Hide();		
	else
		InterfaceOptionsFrameCategories:Hide();
		InterfaceOptionsFrameAddOns:Show();
		InterfaceOptionsFrameTab1TabSpacer:Hide();
		InterfaceOptionsFrameTab2TabSpacer1:Show();
		InterfaceOptionsFrameTab2TabSpacer2:Show();
	end
end

function InterfaceOptionsFrame_OpenToFrame (frame)
	local frameName;
	if ( type(frame) == "string" ) then
		frameName = frame;
		frame = nil;
	end
	
	assert(frameName or frame, 'Usage: InterfaceOptionsFrame_OpenToFrame("categoryName" or frame)');
	
	local blizzardElement, elementToDisplay
	
	for i, element in next, blizzardCategories do
		if ( element == frame or (frameName and element.name and element.name == frameName) ) then
			elementToDisplay = element;
			blizzardElement = true;
			break;
		end
	end
	
	if ( not elementToDisplay ) then
		for i, element in next, INTERFACEOPTIONS_ADDONCATEGORIES do
			if ( element == frame or (frameName and element.name and element.name == frameName) ) then
				elementToDisplay = element;
				break;
			end
		end
	end
	
	if ( not elementToDisplay ) then
		return;
	end
	
	if ( blizzardElement ) then
		InterfaceOptionsFrameTab1:Click();
		local buttons = InterfaceOptionsFrameCategories.buttons
		for i, button in next, buttons do
			if ( button.element == elementToDisplay ) then
				button:Click();
			elseif ( elementToDisplay.parent and button.element and (button.element.name == elementToDisplay.parent and button.element.collapsed) ) then
				button.toggle:Click();
			end
		end
		
		if ( not InterfaceOptionsFrame:IsShown() ) then
			InterfaceOptionsFrame_Show();
		end
	else
		InterfaceOptionsFrameTab2:Click();
		local buttons = InterfaceOptionsFrameAddOns.buttons
		for i, button in next, buttons do
			if ( button.element == elementToDisplay ) then
				button:Click();
			elseif ( elementToDisplay.parent and button.element and (button.element.name == elementToDisplay.parent and button.element.collapsed) ) then
				button.toggle:Click();
			end
		end
		
		if ( not InterfaceOptionsFrame:IsShown() ) then
			InterfaceOptionsFrame_Show();
		end
	end
end

function InterfaceOptionsList_OnLoad (categoryFrame)
	local name = categoryFrame:GetName();
	
	--Setup random things!
	categoryFrame.scrollBar = getglobal(name .. "ListScrollBar");
	categoryFrame:SetBackdropBorderColor(.6, .6, .6, 1);
	getglobal(name.."Bottom"):SetVertexColor(.66, .66, .66);
	
	--Create buttons for scrolling
	local buttons = {};
	local button = CreateFrame("BUTTON", name .. "Button1", categoryFrame, "InterfaceOptionsButtonTemplate");
	button:SetPoint("TOPLEFT", categoryFrame, 0, -8);
	categoryFrame.buttonHeight = button:GetHeight();
	tinsert(buttons, button);
	
	local maxButtons = (categoryFrame:GetHeight() - 8) / categoryFrame.buttonHeight;
	for i = 2, maxButtons do
		button = CreateFrame("BUTTON", name .. "Button" .. i, categoryFrame, "InterfaceOptionsButtonTemplate");
		button:SetPoint("TOPLEFT", buttons[#buttons], "BOTTOMLEFT");
		tinsert(buttons, button);
	end
	
	categoryFrame.buttons = buttons;	
end

--Table to reuse! Yay reuse!
local displayedElements = {}

function InterfaceCategoryList_Update ()
	--Redraw the scroll lists
	local offset = FauxScrollFrame_GetOffset(InterfaceOptionsFrameCategoriesList);
	local buttons = InterfaceOptionsFrameCategories.buttons;
	local element;
	
	for i, element in next, displayedElements do
		displayedElements[i] = nil;
	end
	
	for i, element in next, blizzardCategories do
		if ( not element.hidden ) then
			tinsert(displayedElements, element);
		end
	end
	
	local numButtons = #buttons;
	local numCategories = #displayedElements;
	
	if ( numCategories > numButtons and ( not InterfaceOptionsFrameCategoriesList:IsShown() ) ) then
		InterfaceOptionsList_DisplayScrollBar(InterfaceOptionsFrameCategories);
	elseif ( numCategories <= numButtons and ( InterfaceOptionsFrameCategoriesList:IsShown() ) ) then
		InterfaceOptionsList_HideScrollBar(InterfaceOptionsFrameCategories);	
	end
	
	FauxScrollFrame_Update(InterfaceOptionsFrameCategoriesList, numCategories, numButtons, buttons[1]:GetHeight());
	
	local selection = InterfaceOptionsFrameCategories.selection;
	if ( selection ) then
		-- Store the currently selected element and clear all the buttons, we're redrawing.
		InterfaceOptionsList_ClearSelection(InterfaceOptionsFrameCategories, InterfaceOptionsFrameCategories.buttons);
	end
		
	
	for i = 1, numButtons do
		element = displayedElements[i + offset];
		if ( not element ) then
			InterfaceOptionsList_HideButton(buttons[i]);
		else
			InterfaceOptionsList_DisplayButton(buttons[i], element);
			
			if ( selection ) and ( selection == element ) and ( not InterfaceOptionsFrameCategories.selection ) then
				InterfaceOptionsList_SelectButton(InterfaceOptionsFrameCategories, buttons[i]);
			end
		end
		
	end
	
	if ( selection ) then
		-- If there was a selected element before we cleared the button highlights, restore it, 'cause we're done.
		-- Note: This theoretically might already have been done by InterfaceOptionsList_SelectButton, but in the event that the selected button hasn't been drawn, this is still necessary.
		InterfaceOptionsFrameCategories.selection = selection;
	end
end

function InterfaceAddOnsList_Update ()
	-- Might want to merge this into InterfaceCategoryList_Update depending on whether or not things get differentiated.
	local offset = FauxScrollFrame_GetOffset(InterfaceOptionsFrameAddOnsList);
	local buttons = InterfaceOptionsFrameAddOns.buttons;
	local element;
	
	for i, element in next, displayedElements do
		displayedElements[i] = nil;
	end
	
	for i, element in next, INTERFACEOPTIONS_ADDONCATEGORIES do
		if ( not element.hidden ) then
			tinsert(displayedElements, element);
		end
	end
	
	local numAddOnCategories = #displayedElements;
	local numButtons = #buttons;
	
	-- Show the AddOns tab if it's not empty.
	if ( ( InterfaceOptionsFrameTab2 and not InterfaceOptionsFrameTab2:IsShown() ) and numAddOnCategories > 0 ) then
		InterfaceOptionsFrameCategoriesTop:Hide();
		InterfaceOptionsFrameAddOnsTop:Hide();
		InterfaceOptionsFrameTab1:Show();
		InterfaceOptionsFrameTab2:Show();
	end
	
	if ( numAddOnCategories > numButtons and ( not InterfaceOptionsFrameAddOnsList:IsShown() ) ) then
		-- We need to show the scroll bar, we have more elements than buttons.
		InterfaceOptionsList_DisplayScrollBar(InterfaceOptionsFrameAddOns);
	elseif ( numAddOnCategories <= numButtons and ( InterfaceOptionsFrameAddOnsList:IsShown() ) ) then
		-- Hide the scrollbar, there's nothing to scroll.
		InterfaceOptionsList_HideScrollBar(InterfaceOptionsFrameAddOns);
	end
	
	FauxScrollFrame_Update(InterfaceOptionsFrameAddOnsList, numAddOnCategories, numButtons, buttons[1]:GetHeight());
	
	local selection = InterfaceOptionsFrameAddOns.selection;
	if ( selection ) then
		InterfaceOptionsList_ClearSelection(InterfaceOptionsFrameAddOns, InterfaceOptionsFrameAddOns.buttons);
	end
	
	for i = 1, #buttons do
		element = displayedElements[i + offset]
		if ( not element ) then
			InterfaceOptionsList_HideButton(buttons[i]);
		else
			InterfaceOptionsList_DisplayButton(buttons[i], element);
			
			if ( selection ) and ( selection == element ) and ( not InterfaceOptionsFrameAddOns.selection ) then
				InterfaceOptionsList_SelectButton(InterfaceOptionsFrameAddOns, buttons[i]);
			end
		end
	end
	
	if ( selection ) then
		InterfaceOptionsFrameAddOns.selection = selection;
	end
end

function InterfaceOptionsList_DisplayScrollBar (frame)
	local list = getglobal(frame:GetName() .. "List");
	list:Show();

	local listWidth = list:GetWidth();
	
	for _, button in next, frame.buttons do
		button:SetWidth(button:GetWidth() - listWidth);
	end
end

function InterfaceOptionsList_HideScrollBar (frame)
	local list = getglobal(frame:GetName() .. "List");
	list:Hide();
	
	local listWidth = list:GetWidth();
	
	for _, button in next, frame.buttons do
		button:SetWidth(button:GetWidth() + listWidth);
	end
end

function InterfaceOptionsList_HideButton (button)
	-- Sparse for now, who knows what will end up here?
	button:Hide();
end

function InterfaceOptionsList_DisplayButton (button, element)
	-- Do display things
	button:Show();
	button.element = element;
	
	if (element.parent) then
		button:SetNormalFontObject(GameFontHighlightSmall);
		button:SetHighlightFontObject(GameFontHighlightSmall);
		button.text:SetPoint("LEFT", 16, 2);
	else
		button:SetNormalFontObject(GameFontNormal);
		button:SetHighlightFontObject(GameFontHighlight);
		button.text:SetPoint("LEFT", 8, 2);
	end
	button.text:SetText(element.name);
	
	if (element.hasChildren) then
		if (element.collapsed) then
			button.toggle:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
			button.toggle:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-DOWN");
		else
			button.toggle:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
			button.toggle:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-DOWN");		
		end
		button.toggle:Show();
	else
		button.toggle:Hide();
	end
end

function InterfaceOptionsListButton_OnClick (mouseButton, button)
	if ( mouseButton == "RightButton" ) then
		if ( button.element.hasChildren ) then
			button.toggle:Click();
		end
		return;
	end
	
	local parent = button:GetParent();
	local buttons = parent.buttons;
	
	InterfaceOptionsList_ClearSelection(InterfaceOptionsFrameCategories, InterfaceOptionsFrameCategories.buttons);
	InterfaceOptionsList_ClearSelection(InterfaceOptionsFrameAddOns, InterfaceOptionsFrameAddOns.buttons);
	InterfaceOptionsList_SelectButton(parent, button);
	
	InterfaceOptionsList_DisplayFrame(button.element);
end

function InterfaceOptionsList_DisplayFrame (frame)	
	if ( InterfaceOptionsFramePanelContainer.displayedFrame ) then
		InterfaceOptionsFramePanelContainer.displayedFrame:Hide();
	end
	
	InterfaceOptionsFramePanelContainer.displayedFrame = frame;
	
	frame:SetParent(InterfaceOptionsFramePanelContainer);
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", InterfaceOptionsFramePanelContainer, "TOPLEFT");
	frame:SetPoint("BOTTOMRIGHT", InterfaceOptionsFramePanelContainer, "BOTTOMRIGHT");
	frame:Show();
end

function InterfaceOptionsList_ClearSelection (listFrame, buttons)
	for _, button in next, buttons do
		button:UnlockHighlight();
	end
	
	listFrame.selection = nil;
end

function InterfaceOptionsList_SelectButton (listFrame, button)
	button:LockHighlight()

	listFrame.selection = button.element;
end
---------------------------------------------------------------------------------------------------
-- HOWTO: Add new categories of options
--
-- The new Interface Options frames allows authors to place their configuration
-- frames (aka "panels") alongside the panels for modifying the default UI.
--
-- Adding a new panel to the Interface Options frame is a fairly straightforward process.
-- Any frame can be used as a panel as long as it implements the required values and methods.
-- Once a frame is ready to be used as a panel, it must be registered using the function
-- InterfaceOptions_AddCategory, i.e. InterfaceOptions_AddCategory(panel)
--
-- Panels can be designated as sub-categories of existing options. These panels are listed
-- with smaller text, offset, and tied to parent categories. The parent categories can be expanded
-- or collapsed to toggle display of their sub-categories.
--
-- When players select a category of options from the Interface Options frame, the panel associated
-- with that category will be anchored to the right hand side of the Interface Options frame and shown.
--
-- The following members and methods are used by the Interface Options frame to display and organize panels.
--
-- panel.name - string (required)	
--	The name of the AddOn or group of configuration options. 
--	This is the text that will display in the AddOn options list.
--
-- panel.parent - string (optional)
--	Name of the parent of the AddOn or group of configuration options. 
--	This identifies "panel" as the child of another category.
--	If the parent category doesn't exist, "panel" will be displayed as a regular category.
--
-- panel.okay - function (optional)
--	This method will run when the player clicks "okay" in the Interface Options. 
--
-- panel.cancel - function (optional)
--	This method will run when the player clicks "cancel" in the Interface Options. 
--	Use this to revert their changes.
--
-- panel.default - function (optional)
--	This method will run when the player clicks "defaults". 
--	Use this to revert their changes to your defaults.
--					
-- EXAMPLE -- Use XML to create a frame, and through its OnLoad function, make the frame a panel.
--
--	MyAddOn.xml
--		<Frame name="ExamplePanel">
--			<Scripts>
--				<OnLoad>
--					ExamplePanel_OnLoad(self);
--				</OnLoad>
--			</Scripts>
--		</Frame>
--
--	MyAddOn.lua
--		function ExamplePanel_OnLoad (panel)
--			panel.name = "My AddOn"
--			InterfaceOptions_AddCategory(panel);
--		end
--
-- EXAMPLE -- Dynamically create a frame and use it as a subcategory for "My AddOn".
--
--	local panel = CreateFrame("FRAME", "ExampleSubCategory");
--	panel.name = "My SubCategory";
--	panel.parent = "My AddOn";
--
--	InterfaceOptions_AddCategory(panel);
--
-- EXAMPLE -- Create a frame with a control, an okay and a cancel method
--
--	--[[ Create a frame to use as the panel ]] -- 
--	local panel = CreateFrame("FRAME", "ExamplePanel");
--	panel.name = "My AddOn";
--
--	-- [[ When the player clicks okay, set the original value to the current setting ]] --
--	panel.okay = 
--		function (self)
--			self.originalValue = MY_VARIABLE;
--		end
--
--	-- [[ When the player clicks cancel, set the current setting to the original value ]] --
--	panel.cancel =
--		function (self)
--			MY_VARIABLE = self.originalValue;
--		end
--
--	-- [[ Add the panel to the Interface Options ]] --
--	InterfaceOptions_AddCategory(panel);
-------------------------------------------------------------------------------------------------


function InterfaceOptions_AddCategory (frame, addOn)
	if ( issecure() and ( not addOn ) ) then
		local parent = frame.parent;
		if ( parent ) then
			for i = 1, #blizzardCategories do
				if ( blizzardCategories[i].name == parent ) then
					if ( blizzardCategories[i].hasChildren ) then
						frame.hidden = ( blizzardCategories[i].collapsed );
					else
						frame.hidden = true;
						blizzardCategories[i].hasChildren = true;
						blizzardCategories[i].collapsed = true;
					end
					tinsert(blizzardCategories, i + 1, frame);
					InterfaceCategoryList_Update();
					return;
				end
			end
		end
		
		tinsert(blizzardCategories, frame);
		InterfaceCategoryList_Update();
	elseif ( not type(frame) == "table" or not frame.name ) then
		--Check to make sure that AddOn interface panels have the necessary attributes to work with the system.
		return;
	else
		frame.okay = frame.okay or function () end;
		frame.cancel = frame.cancel or function () end;
		frame.default = frame.default or function () end;
		
		local categories = INTERFACEOPTIONS_ADDONCATEGORIES;
		
		local name = strlower(frame.name);
		local parent = frame.parent;
		if ( parent ) then
			for i = 1, #categories do
				if ( categories[i].name == parent ) then
					if ( not categories[i].hasChildren ) then
						frame.hidden = true;
						categories[i].hasChildren = true;
						categories[i].collapsed = true;
						tinsert(categories, i + 1, frame);
						InterfaceAddOnsList_Update();
						return;						
					end
					
					frame.hidden = ( categories[i].collapsed );
					
					local j = i + 1;
					while ( categories[j] and categories[j].parent == parent ) do
						-- Skip to the end of the list of children, add this there.
						j = j + 1;
					end
					
					tinsert(categories, j, frame);
					InterfaceAddOnsList_Update();
					return;
				end
			end
		end
		
		for i = 1, #categories do
			if ( ( not categories[i].parent ) and ( name < strlower(categories[i].name) ) ) then
				tinsert(categories, i, frame);
				InterfaceAddOnsList_Update();
				return;
			end
		end
					
		tinsert(categories, frame);
		InterfaceAddOnsList_Update();
	end
end

function InterfaceOptions_ToggleSubCategories (button)
	local element = button:GetParent().element;
	
	element.collapsed = not element.collapsed;
	local collapsed = element.collapsed;
	
	for _, category in next, blizzardCategories do
		if ( category.parent == element.name ) then
			if ( collapsed ) then
				category.hidden = true;
			else
				category.hidden = false;
			end
		end
	end

	for _, category in next, INTERFACEOPTIONS_ADDONCATEGORIES do
		if ( category.parent == element.name ) then
			if ( collapsed ) then
				category.hidden = true;
			else
				category.hidden = false;
			end
		end
	end
	
	InterfaceCategoryList_Update();
	InterfaceAddOnsList_Update();
end

function BlizzardOptionsPanel_ResetControl (control)
	if ( control.value and control.currValue and ( control.value ~= control.currValue ) ) then
		control:SetValue(control.currValue);
	end
end

function BlizzardOptionsPanel_DefaultControl (control)
	if ( control:GetValue() ~= control.defaultValue ) then
		control:SetValue(control.defaultValue);
	end
end

function BlizzardOptionsPanel_UpdateCurrentControlValue (control)
	control.currValue = control.value;
end

local function BlizzardOptionsPanel_Okay (self)
	for _, control in next, self.controls do
		securecall(BlizzardOptionsPanel_UpdateCurrentControlValue, control);
	end
end

local function BlizzardOptionsPanel_Cancel (self)
	for _, control in next, self.controls do
		securecall(BlizzardOptionsPanel_ResetControl, control);
	end
end

local function BlizzardOptionsPanel_Default (self)
	for _, control in next, self.controls do
		securecall(BlizzardOptionsPanel_DefaultControl, control);
	end
end

function InterfaceOptionsFrame_SetupBlizzardPanel (frame)
	frame.okay = BlizzardOptionsPanel_Okay;
	frame.cancel = BlizzardOptionsPanel_Cancel;
	frame.default = BlizzardOptionsPanel_Default;
end

function InterfaceOptionsFrame_InitializeUVars ()
	-- Setup UVars that keep settings
	for uvar, setting in next, uvarInfo do
		setglobal(uvar, setting.default);
	end
end

function InterfaceOptionsFrame_LoadUVars ()
	local variable, cvarValue
	for uvar, setting in next, uvarInfo do
		variable = getglobal(uvar);
		cvarValue = GetCVar(setting.cvar);
		if ( cvarValue == setting.default and variable ~= setting.default ) then
			SetCVar(setting.cvar, variable, setting.event)
			if ( setting.func ) then
				setting.func()
			end
		elseif ( cvarValue ~= setting.default or ( not ( getglobal(uvar) ) ) ) then
			if ( setting.func ) then
				setting.func()
			end
		end
	end
end