
INTERFACEOPTIONS_ADDONCATEGORIES = {};

local blizzardCategories = {};

local next = next;
local function SecureNext(elements, key)
	return securecall(next, elements, key);
end

local tinsert = tinsert;
local strlower = strlower;


-- [[ InterfaceOptionsList functions ]] --

function InterfaceOptionsList_DisplayPanel (frame)	
	if ( InterfaceOptionsFramePanelContainer.displayedPanel ) then
		InterfaceOptionsFramePanelContainer.displayedPanel:Hide();
	end

	InterfaceOptionsFramePanelContainer.displayedPanel = frame;

	frame:SetParent(InterfaceOptionsFramePanelContainer);
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", InterfaceOptionsFramePanelContainer, "TOPLEFT");
	frame:SetPoint("BOTTOMRIGHT", InterfaceOptionsFramePanelContainer, "BOTTOMRIGHT");
	frame:Show();
end

function InterfaceOptionsListButton_OnClick (self, mouseButton)
	if ( mouseButton == "RightButton" ) then
		if ( self.element.hasChildren ) then
			OptionsListButtonToggle_OnClick(self.toggle);
		end
		return;
	end

	local parent = self:GetParent();
	local buttons = parent.buttons;

	OptionsList_ClearSelection(InterfaceOptionsFrameCategories, InterfaceOptionsFrameCategories.buttons);
	OptionsList_ClearSelection(InterfaceOptionsFrameAddOns, InterfaceOptionsFrameAddOns.buttons);
	OptionsList_SelectButton(parent, self);

	InterfaceOptionsList_DisplayPanel(self.element);
end

function InterfaceOptionsListButton_ToggleSubCategories (self)
	local element = self.element;

	element.collapsed = not element.collapsed;
	local collapsed = element.collapsed;

	for _, category in SecureNext, blizzardCategories do
		if ( category.parent == element.name ) then
			if ( collapsed ) then
				category.hidden = true;
			else
				category.hidden = false;
			end
		end
	end

	for _, category in SecureNext, INTERFACEOPTIONS_ADDONCATEGORIES do
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


--Table to reuse! Yay reuse!
local displayedElements = {}

function InterfaceCategoryList_Update ()
	--Redraw the scroll lists
	local offset = FauxScrollFrame_GetOffset(InterfaceOptionsFrameCategoriesList);
	local buttons = InterfaceOptionsFrameCategories.buttons;
	local element;

	for i, element in SecureNext, displayedElements do
		displayedElements[i] = nil;
	end

	for i, element in SecureNext, blizzardCategories do
		if ( not element.hidden ) then
			tinsert(displayedElements, element);
		end
	end

	local numButtons = #buttons;
	local numCategories = #displayedElements;

	if ( numCategories > numButtons and ( not InterfaceOptionsFrameCategoriesList:IsShown() ) ) then
		OptionsList_DisplayScrollBar(InterfaceOptionsFrameCategories);
	elseif ( numCategories <= numButtons and ( InterfaceOptionsFrameCategoriesList:IsShown() ) ) then
		OptionsList_HideScrollBar(InterfaceOptionsFrameCategories);	
	end

	FauxScrollFrame_Update(InterfaceOptionsFrameCategoriesList, numCategories, numButtons, buttons[1]:GetHeight());

	local selection = InterfaceOptionsFrameCategories.selection;
	if ( selection ) then
		-- Store the currently selected element and clear all the buttons, we're redrawing.
		OptionsList_ClearSelection(InterfaceOptionsFrameCategories, InterfaceOptionsFrameCategories.buttons);
	end

	for i = 1, numButtons do
		element = displayedElements[i + offset];
		if ( not element ) then
			OptionsList_HideButton(buttons[i]);
		else
			OptionsList_DisplayButton(buttons[i], element);

			if ( selection ) and ( selection == element ) and ( not InterfaceOptionsFrameCategories.selection ) then
				OptionsList_SelectButton(InterfaceOptionsFrameCategories, buttons[i]);
			end
		end
		
	end

	if ( selection ) then
		-- If there was a selected element before we cleared the button highlights, restore it, 'cause we're done.
		-- Note: This theoretically might already have been done by OptionsList_SelectButton, but in the event that the selected button hasn't been drawn, this is still necessary.
		InterfaceOptionsFrameCategories.selection = selection;
	end
end

function InterfaceAddOnsList_Update ()
	-- Might want to merge this into InterfaceCategoryList_Update depending on whether or not things get differentiated.
	local offset = FauxScrollFrame_GetOffset(InterfaceOptionsFrameAddOnsList);
	local buttons = InterfaceOptionsFrameAddOns.buttons;
	local element;

	for i, element in SecureNext, displayedElements do
		displayedElements[i] = nil;
	end

	for i, element in SecureNext, INTERFACEOPTIONS_ADDONCATEGORIES do
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
		OptionsList_DisplayScrollBar(InterfaceOptionsFrameAddOns);
	elseif ( numAddOnCategories <= numButtons and ( InterfaceOptionsFrameAddOnsList:IsShown() ) ) then
		-- Hide the scrollbar, there's nothing to scroll.
		OptionsList_HideScrollBar(InterfaceOptionsFrameAddOns);
	end

	FauxScrollFrame_Update(InterfaceOptionsFrameAddOnsList, numAddOnCategories, numButtons, buttons[1]:GetHeight());

	local selection = InterfaceOptionsFrameAddOns.selection;
	if ( selection ) then
		OptionsList_ClearSelection(InterfaceOptionsFrameAddOns, InterfaceOptionsFrameAddOns.buttons);
	end

	for i = 1, #buttons do
		element = displayedElements[i + offset]
		if ( not element ) then
			OptionsList_HideButton(buttons[i]);
		else
			OptionsList_DisplayButton(buttons[i], element);
			
			if ( selection ) and ( selection == element ) and ( not InterfaceOptionsFrameAddOns.selection ) then
				OptionsList_SelectButton(InterfaceOptionsFrameAddOns, buttons[i]);
			end
		end
	end

	if ( selection ) then
		InterfaceOptionsFrameAddOns.selection = selection;
	end
end


-- [[ InterfaceOptionsFrame ]] --

function InterfaceOptionsFrame_Show ()
	if ( InterfaceOptionsFrame:IsShown() ) then
		InterfaceOptionsFrame:Hide();
	else
		InterfaceOptionsFrame:Show();
	end
end

local function InterfaceOptionsFrame_RunOkayForCategory (category)
	pcall(category.okay, category);
end

local function InterfaceOptionsFrame_RunDefaultForCategory (category)
	pcall(category.default, category);
end

local function InterfaceOptionsFrame_RunCancelForCategory (category)
	pcall(category.cancel, category);
end

local function InterfaceOptionsFrame_RunRefreshForCategory (category)
	pcall(category.refresh, category);
end

function InterfaceOptionsFrameOkay_OnClick (self, button, apply)
	--Iterate through registered panels and run their okay methods in a taint-safe fashion

	for _, category in SecureNext, blizzardCategories do
		securecall(InterfaceOptionsFrame_RunOkayForCategory, category);
	end

	for _, category in SecureNext, INTERFACEOPTIONS_ADDONCATEGORIES do
		securecall(InterfaceOptionsFrame_RunOkayForCategory, category);
	end

	if ( InterfaceOptionsFrame.gameRestart ) then
		StaticPopup_Show("CLIENT_RESTART_ALERT");
		InterfaceOptionsFrame.gameRestart = nil;
	elseif ( InterfaceOptionsFrame.logout ) then
		StaticPopup_Show("CLIENT_LOGOUT_ALERT");
		InterfaceOptionsFrame.logout = nil;
	end

	if ( not apply ) then
		InterfaceOptionsFrame_Show();
	end
end

function InterfaceOptionsFrameCancel_OnClick (self, button)
	--Iterate through registered panels and run their cancel methods in a taint-safe fashion

	for _, category in SecureNext, blizzardCategories do
		securecall(InterfaceOptionsFrame_RunCancelForCategory, category);
	end

	for _, category in SecureNext, INTERFACEOPTIONS_ADDONCATEGORIES do
		securecall(InterfaceOptionsFrame_RunCancelForCategory, category);
	end

	InterfaceOptionsFrame.gameRestart = nil;
	InterfaceOptionsFrame.logout = nil;

	InterfaceOptionsFrame_Show();
end

function InterfaceOptionsFrameDefaults_OnClick (self, button)
	StaticPopup_Show("CONFIRM_RESET_INTERFACE_SETTINGS");
end

function InterfaceOptionsFrame_SetAllToDefaults ()
	--Iterate through registered panels and run their default methods in a taint-safe fashion

	for _, category in SecureNext, blizzardCategories do
		securecall(InterfaceOptionsFrame_RunDefaultForCategory, category);
	end

	for _, category in SecureNext, INTERFACEOPTIONS_ADDONCATEGORIES do
		securecall(InterfaceOptionsFrame_RunDefaultForCategory, category);
	end

	--Refresh the categories to pick up changes made.
	InterfaceOptionsOptionsFrame_RefreshCategories();
	InterfaceOptionsOptionsFrame_RefreshAddOns();
end

function InterfaceOptionsFrame_SetCurrentToDefaults ()
	local displayedPanel = InterfaceOptionsFramePanelContainer.displayedPanel;
	if ( not displayedPanel or not displayedPanel.default ) then
		return;
	end

	displayedPanel.default(displayedPanel);
	--Run the refresh method to refresh any values that were changed.
	displayedPanel.refresh(displayedPanel);
end

function InterfaceOptionsOptionsFrame_RefreshCategories ()
	for _, category in SecureNext, blizzardCategories do
		securecall(InterfaceOptionsFrame_RunRefreshForCategory, category);
	end
end

function InterfaceOptionsOptionsFrame_RefreshAddOns ()
	for _, category in SecureNext, INTERFACEOPTIONS_ADDONCATEGORIES do
		securecall(InterfaceOptionsFrame_RunRefreshForCategory, category);
	end
end

uvarInfo = {
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
	["SHOW_COMBAT_TEXT"] = { default = "1", cvar = "enableCombatText", event = "SHOW_COMBAT_TEXT_TEXT" },
	["COMBAT_TEXT_SHOW_LOW_HEALTH_MANA"] = { default = "1", cvar = "fctLowManaHealth", event = "COMBAT_TEXT_SHOW_LOW_HEALTH_MANA_TEXT" },
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
	["SHOW_ARENA_ENEMY_FRAMES"] = { default = "1", cvar = "showArenaEnemyFrames", event = "SHOW_ARENA_ENEMY_FRAMES_TEXT" },
	["SHOW_ARENA_ENEMY_CASTBAR"] = { default = "1", cvar = "showArenaEnemyCastbar", event = "SHOW_ARENA_ENEMY_CASTBAR_TEXT" },
	["SHOW_ARENA_ENEMY_PETS"] = { default = "1", cvar = "showArenaEnemyPets", event = "SHOW_ARENA_ENEMY_PETS_TEXT" },
	["SHOW_CASTABLE_DEBUFFS"] = { default = "0", cvar = "showCastableDebuffs", event = "SHOW_CASTABLE_DEBUFFS_TEXT" },
}

function InterfaceOptionsFrame_InitializeUVars ()
	-- Setup UVars that keep settings
	for uvar, setting in SecureNext, uvarInfo do
		_G[uvar] = setting.default;
	end
end

function InterfaceOptionsFrame_LoadUVars ()
	local variable, cvarValue
	for uvar, setting in SecureNext, uvarInfo do
		variable = _G[uvar];
		cvarValue = GetCVar(setting.cvar);
		if ( cvarValue == setting.default and variable ~= setting.default ) then
			SetCVar(setting.cvar, variable, setting.event)
			if ( setting.func ) then
				setting.func()
			end
		elseif ( cvarValue ~= setting.default or ( not ( _G[uvar] ) ) ) then
			if ( setting.func ) then
				setting.func()
			end
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

function InterfaceOptionsFrame_OnEvent (self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		InterfaceOptionsFrame_LoadUVars();
	end
end

function InterfaceOptionsFrame_OnShow (self)
	--Refresh the two category lists and display the "Controls" group of options if nothing is selected.
	InterfaceCategoryList_Update();
	InterfaceAddOnsList_Update();
	if ( not InterfaceOptionsFramePanelContainer.displayedPanel ) then
		InterfaceOptionsFrame_OpenToCategory(CONTROLS_LABEL);
	end
	--Refresh the categories to pick up changes made while the options frame was hidden.
	InterfaceOptionsOptionsFrame_RefreshCategories();
	InterfaceOptionsOptionsFrame_RefreshAddOns();
end

function InterfaceOptionsFrame_OnHide (self)
	OptionsFrame_OnHide(InterfaceOptionsFrame);

	if ( InterfaceOptionsFrame.gameRestart ) then
		StaticPopup_Show("CLIENT_RESTART_ALERT");
		InterfaceOptionsFrame.gameRestart = nil;
	elseif ( InterfaceOptionsFrame.logout ) then
		StaticPopup_Show("CLIENT_LOGOUT_ALERT");
		InterfaceOptionsFrame.logout = nil;
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

function InterfaceOptionsFrame_OpenToCategory (panel)
	local panelName;
	if ( type(panel) == "string" ) then
		panelName = panel;
		panel = nil;
	end

	assert(panelName or panel, 'Usage: InterfaceOptionsFrame_OpenToCategory("categoryName" or panel)');

	local blizzardElement, elementToDisplay

	for i, element in SecureNext, blizzardCategories do
		if ( element == panel or (panelName and element.name and element.name == panelName) ) then
			elementToDisplay = element;
			blizzardElement = true;
			break;
		end
	end

	if ( not elementToDisplay ) then
		for i, element in SecureNext, INTERFACEOPTIONS_ADDONCATEGORIES do
			if ( element == panel or (panelName and element.name and element.name == panelName) ) then
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
		local buttons = InterfaceOptionsFrameCategories.buttons;
		for i, button in SecureNext, buttons do
			if ( button.element == elementToDisplay ) then
				InterfaceOptionsListButton_OnClick(button);
			elseif ( elementToDisplay.parent and button.element and (button.element.name == elementToDisplay.parent and button.element.collapsed) ) then
				OptionsListButtonToggle_OnClick(button.toggle);
			end
		end
		
		if ( not InterfaceOptionsFrame:IsShown() ) then
			InterfaceOptionsFrame_Show();
		end
	else
		InterfaceOptionsFrameTab2:Click();
		local buttons = InterfaceOptionsFrameAddOns.buttons;
		for i, button in SecureNext, buttons do
			if ( button.element == elementToDisplay ) then
				InterfaceOptionsListButton_OnClick(button);
			elseif ( elementToDisplay.parent and button.element and (button.element.name == elementToDisplay.parent and button.element.collapsed) ) then
				OptionsListButtonToggle_OnClick(button.toggle);
			end
		end

		if ( not InterfaceOptionsFrame:IsShown() ) then
			InterfaceOptionsFrame_Show();
		end
	end
end


---------------------------------------------------------------------------------------------------
-- HOWTO: Add new categories of options
--
-- The new Interface Options frame allows authors to place their configuration
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
-- panel.refresh - function (optional)
--  This method will run when the Interface Options frame calls its OnShow function and after defaults
--  have been applied via the panel.default method described above.
--  Use this to refresh your panel's UI in case settings were changed without player interaction.
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


function InterfaceOptions_AddCategory (frame, addOn, position)
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

		if ( position ) then
			tinsert(blizzardCategories, position, frame);
		else
			tinsert(blizzardCategories, frame);
		end

		InterfaceCategoryList_Update();
	elseif ( not type(frame) == "table" or not frame.name ) then
		--Check to make sure that AddOn interface panels have the necessary attributes to work with the system.
		return;
	else
		frame.okay = frame.okay or function () end;
		frame.cancel = frame.cancel or function () end;
		frame.default = frame.default or function () end;
		frame.refresh = frame.refresh or function () end;

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

		if ( position ) then
			tinsert(categories, position, frame);
		else
			tinsert(categories, frame);
		end
		InterfaceAddOnsList_Update();
	end
end
