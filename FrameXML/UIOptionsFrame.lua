-- Note: If you're looking to modify any of the actual interface options, you probably want UIOptionsPanels.lua

-- Yay for magic numbers. 404 is the normal height of InterfaceOptionsFrameCategory (250) + the normal height of InterfaceOptionsFrameAddOns (135)  + the offset between the two (24 at the time of this comment)
INTERFACEOPTIONS_MAXCATEGORYHEIGHT = 409;
INTERFACEOPTIONS_DEFAULTCATEGORYHEIGHT = 250;

local blizzardCategories = {};
local addOnCategories = {};

function InterfaceOptionsFrameCancel_OnClick ()
	--Iterate through registered panels and run their cancel methods in a taint-safe fashion

	for _, category in next, blizzardCategories do
		securecall("pcall", category.cancel, category);
	end
	
	for _, category in next, addOnCategories do
		securecall("pcall", category.cancel, category);
	end
			
	InterfaceOptionsFrame_Show();
end

function InterfaceOptionsFrameOkay_OnClick ()
	--Iterate through registered panels and run their okay methods in a taint-safe fashion

	for _, category in next, blizzardCategories do
		securecall("pcall", category.okay, category);
	end
	
	for _, category in next, addOnCategories do
		securecall("pcall", category.okay, category);
	end
	
	InterfaceOptionsFrame_Show();
end

function InterfaceOptionsFrameDefaults_OnClick ()
	--Iterate through registered panels and run their default methods in a taint-safe fashion

	for _, category in next, blizzardCategories do
		securecall("pcall", category.default, category);
	end
	
	for _, category in next, addOnCategories do
		securecall("pcall", category.default, category);
	end
	
	--Run the OnShow method of the currently displayed panel so that it can update and values that were changed. D
	local displayedFrame = InterfaceOptionsFramePanelContainer.displayedFrame;
	if ( displayedFrame and displayedFrame.GetScript ) then
		local script = displayedFrame:GetScript("OnShow");
		if ( script ) then
			securecall(script, displayedFrame);
		end
	end
end

function InterfaceOptionsFrame_OnLoad ()
	--Make sure all the UVars get their default values set, since systems that require them to be defined will be loaded before anything in UIOptionsPanels
	InterfaceOptionsFrame_InitializeUVars();
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
	ShowUIPanel(GameMenuFrame);
	UpdateMicroButtons();
end

function InterfaceOptionsFrame_Show ()
	if ( InterfaceOptionsFrame:IsShown() ) then
		InterfaceOptionsFrame:Hide();
	else
		InterfaceOptionsFrame:Show();
	end
end

function InterfaceOptionsList_OnLoad (categoryFrame)
	local name = categoryFrame:GetName();
	
	--Setup random things!
	categoryFrame.scrollBar = getglobal(name .. "ListScrollBar");
	categoryFrame:SetBackdropBorderColor(.6, .6, .6, 1);
	getglobal(name .. "Label"):SetText(categoryFrame.labelText);
	
	--Create buttons for scrolling
	local buttons = {};
	local button = CreateFrame("BUTTON", name .. "Button1", categoryFrame, "InterfaceOptionsButtonTemplate");
	button:SetPoint("TOPLEFT", categoryFrame, 0, -4);
	categoryFrame.buttonHeight = button:GetHeight();
	tinsert(buttons, button);
	
	local maxButtons = (categoryFrame:GetHeight() - 4) / categoryFrame.buttonHeight;
	for i = 2, maxButtons do
		button = CreateFrame("BUTTON", name .. "Button" .. i, categoryFrame, "InterfaceOptionsButtonTemplate");
		button:SetPoint("TOPLEFT", buttons[#buttons], "BOTTOMLEFT");
		tinsert(buttons, button);
	end
	
	categoryFrame.buttons = buttons;	
end

function InterfaceCategoryList_Update ()
	--Redraw the scroll lists
	local offset = FauxScrollFrame_GetOffset(InterfaceOptionsFrameCategoriesList);
	local buttons = InterfaceOptionsFrameCategories.buttons;
	local element;
	
	for i = 1, #buttons do
		element = blizzardCategories[i + offset];
		if ( ( not element ) or element.hidden ) then
			InterfaceOptionsList_HideButton(buttons[i]);
		else
			InterfaceOptionsList_DisplayButton(buttons[i], element);
		end
	end
end

function InterfaceAddOnsList_Update ()
	-- Might want to merge this into InterfaceCategoryList_Update depending on whether or not things get differentiated.
	local offset = FauxScrollFrame_GetOffset(InterfaceOptionsFrameAddOnsList);
	local buttons = InterfaceOptionsFrameAddOns.buttons;
	local element;
	
	local numAddOnCategories = #addOnCategories;
	local numButtons = #buttons;
	
	-- Hide the AddOns list if it's empty and make the Category list taller
	if ( InterfaceOptionsFrameAddOns:IsShown() and numAddOnCategories == 0 ) then
		InterfaceOptionsFrameAddOns:Hide();
		InterfaceOptionsFrameCategories:SetHeight(INTERFACEOPTIONS_MAXCATEGORYHEIGHT);
		
		-- Don't need to do the rest of this stuff if this is going to be hidden. 
		return;
	elseif ( ( not InterfaceOptionsFrameAddOns:IsShown() ) and numAddOnCategories > 0 ) then
		InterfaceOptionsFrameAddOns:Show();
		InterfaceOptionsFrameCategories:SetHeight(INTERFACEOPTIONS_DEFAULTCATEGORYHEIGHT);
	end
	
	if ( numAddOnCategories > numButtons and ( not InterfaceOptionsFrameAddOnsList:IsShown() ) ) then
		-- We need to show the scroll bar, we have more elements than buttons.
		InterfaceOptionsList_DisplayScrollBar(InterfaceOptionsFrameAddOns);
	elseif ( numAddOnCategories <= numButtons and ( InterfaceOptionsFrameAddOnsList:IsShown() ) ) then
		-- Hide the scrollbar, there's nothing to scroll.
		InterfaceOptionsList_HideScrollBar(InterfaceOptionsFrameAddOns);
	end
	
	for i = 1, #buttons do
		element = addOnCategories[i + offset]
		if ( ( not element ) or element.hidden ) then
			InterfaceOptionsList_HideButton(buttons[i]);
		else
			InterfaceOptionsList_DisplayButton(buttons[i], element);
		end
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
	local list = getglobal(frame:getName() .. "List");
	list:Hide();
	
	local listWidth = list:GetWidth();
	
	for _, button in next, frame.buttons do
		button:SetWidth(button:GetWidth() - listWidth);
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
		button:SetTextFontObject("GameFontHighlightSmall");
		button:SetHighlightFontObject("GameFontHighlightSmall");
		button.text:SetPoint("LEFT", 16, 2);
	else
		button:SetTextFontObject("GameFontNormal");
		button:SetHighlightFontObject("GameFontHighlight");
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

function InterfaceOptionsListButton_OnClick (button)
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


function InterfaceOptions_AddCategory (frame)
	if ( issecure() ) then
		local parent = frame.parent;
		if ( parent ) then
			for i = 1, #blizzardCategories do
				if ( blizzardCategories[i].name == parent ) then
					blizzardCategories[i].hasChildren = true;
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
		
		local parent = frame.parent;
		if ( parent ) then
			for i = 1, #addOnCategories do
				if ( addOnCategories[i].name == parent ) then
					addOnCategories[i].hasChildren = true;
					tinsert(addOnCategories, i + 1, frame);
					InterfaceAddOnsList_Update();
					return;
				end
			end
		end
		
		tinsert(addOnCategories, frame);
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

	for _, category in next, addOnCategories do
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
	-- UVars that keep settings
	SIMPLE_CHAT = "0";
	CHAT_LOCKED = "0"
	REMOVE_CHAT_DELAY = "0";
	SHOW_NEWBIE_TIPS = "1";
	LOCK_ACTIONBAR = "0";
	SHOW_BUFF_DURATIONS = "0";
	ALWAYS_SHOW_MULTIBARS = "0";
	SHOW_PARTY_PETS = "1";
	QUEST_FADING_DISABLE = "0";
	SHOW_PARTY_BACKGROUND = "0";
	HIDE_PARTY_INTERFACE = "0";
	SHOW_TARGET_OF_TARGET = "0";
	SHOW_TARGET_OF_TARGET_STATE = "5";
	WORLD_PVP_OBJECTIVES_DISPLAY = "2";
	AUTO_QUEST_WATCH = "1";
	LOOT_UNDER_MOUSE = "0";
	AUTO_LOOT_DEFAULT = "0";
	SHOW_PARTY_TEXT = "0";
	
	-- Combat text uvars
	SHOW_COMBAT_TEXT = "0";
	COMBAT_TEXT_SHOW_LOW_HEALTH_MANA = "1";
	COMBAT_TEXT_SHOW_AURAS = "1";
	COMBAT_TEXT_SHOW_AURA_FADE = "0";
	COMBAT_TEXT_SHOW_COMBAT_STATE = "1";
	COMBAT_TEXT_SHOW_DODGE_PARRY_MISS = "0";
	COMBAT_TEXT_SHOW_RESISTANCES = "0";
	COMBAT_TEXT_SHOW_REPUTATION = "0";
	COMBAT_TEXT_SHOW_REACTIVES = "0";
	COMBAT_TEXT_SHOW_FRIENDLY_NAMES = "0";
	COMBAT_TEXT_SHOW_COMBO_POINTS = "0";
	COMBAT_TEXT_SHOW_MANA = "0";
	COMBAT_TEXT_FLOAT_MODE = "1";
	COMBAT_TEXT_SHOW_HONOR_GAINED = "1";
end
