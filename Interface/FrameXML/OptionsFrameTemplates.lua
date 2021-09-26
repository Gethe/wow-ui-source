-- if you change something here you probably want to change the glue version too

local next = next;
local function SecureNext(elements, key)
	-- not totally necessary in all cases in this file (since Interface Options are independent), but
	-- it's used anyway to keep things consistent, plus it's not a huge performance hindrance
	return securecall(next, elements, key);
end


-- [[ functions for OptionsFrameTemplates controls ]] --

function OptionsList_OnLoad (self, buttonTemplate)
	local name = self:GetName();

	--Setup random things!
	self.scrollFrame = _G[name .. "List"];
	self:SetBackdropBorderColor(.6, .6, .6, 1);
	_G[name.."Bottom"]:SetVertexColor(.66, .66, .66);

	--Create buttons for scrolling
	local buttons = {};
	local button = CreateFrame("BUTTON", name .. "Button1", self, buttonTemplate or "OptionsListButtonTemplate");
	button:SetPoint("TOPLEFT", self, 0, -8);
	self.buttonHeight = button:GetHeight();
	tinsert(buttons, button);

	local maxButtons = (self:GetHeight() - 8) / self.buttonHeight;
	for i = 2, maxButtons do
		button = CreateFrame("BUTTON", name .. "Button" .. i, self, buttonTemplate or "OptionsListButtonTemplate");
		button:SetPoint("TOPLEFT", buttons[#buttons], "BOTTOMLEFT");
		tinsert(buttons, button);
	end

	self.buttonHeight = button:GetHeight();
	self.buttons = buttons;
end

function OptionsList_DisplayScrollBar (frame)
	local list = frame.scrollFrame;
	list:Show();

	local listWidth = list:GetWidth();

	for _, button in SecureNext, frame.buttons do
		button:SetWidth(button:GetWidth() - listWidth);
	end
end

function OptionsList_HideScrollBar (frame)
	local list = frame.scrollFrame;
	list:Hide();

	local listWidth = list:GetWidth();

	for _, button in SecureNext, frame.buttons do
		button:SetWidth(button:GetWidth() + listWidth);
	end
end

function OptionsList_HideButton (button)
	-- Sparse for now, who knows what will end up here?
	button:Hide();
end

function OptionsList_DisplayButton (button, element)
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

function OptionsList_DisplayPanel (panel)
	local panelContainer = panel:GetParent();
	if ( panelContainer.displayedPanel ) then
		panelContainer.displayedPanel:Hide();
	end
	panelContainer.displayedPanel = panel;

	panel:ClearAllPoints();
	panel:SetPoint("TOPLEFT", panelContainer, "TOPLEFT");
	panel:SetPoint("BOTTOMRIGHT", panelContainer, "BOTTOMRIGHT");
	panel:Show();
end

function OptionsList_ClearSelection (listFrame, buttons)
	for _, button in SecureNext, buttons do
		button.highlight:SetVertexColor(.196, .388, .8);
		button:UnlockHighlight();
	end

	listFrame.selection = nil;
end

function OptionsList_SelectButton (listFrame, button)
	button.highlight:SetVertexColor(1, 1, 0);
	button:LockHighlight()

	listFrame.selection = button.element;
end

function OptionsListScroll_Update (frame)
	local parent = frame:GetParent();
	parent:update();
end

function OptionsListButton_OnLoad (self, toggleFunc)
	self.text = _G[self:GetName() .. "Text"];
	self.highlight = self:GetHighlightTexture();
	self.highlight:SetVertexColor(.196, .388, .8);
	self.text:SetPoint("RIGHT", "$parentToggle", "LEFT", -2, 0);
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");

	self.toggleFunc = toggleFunc or OptionsListButton_ToggleSubCategories;
end

function OptionsListButton_OnClick (self, mouseButton)
	if ( mouseButton == "RightButton" ) then
		if ( self.element.hasChildren ) then
			OptionsListButtonToggle_OnClick(self.toggle);
		end
		return;
	end

	local listFrame = self:GetParent();

	OptionsList_ClearSelection(listFrame, listFrame.buttons);
	OptionsList_SelectButton(listFrame, self);

	OptionsList_DisplayPanel(self.element);
end

function OptionsListButton_OnEnter (self)
	if (self.text:IsTruncated()) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self:GetText(), NORMAL_FONT_COLOR[1], NORMAL_FONT_COLOR[2], NORMAL_FONT_COLOR[3], 1, true);
	end
end

function OptionsListButton_OnLeave (self)
	GameTooltip:Hide();
end

function OptionsListButton_ToggleSubCategories (self)
	local element = self.element;

	element.collapsed = not element.collapsed;

	local collapsed = element.collapsed;

	local categoryFrame = self:GetParent();
	local optionsFrame = categoryFrame:GetParent();
	local categoryList = optionsFrame.categoryList;
	for _, category in SecureNext, categoryList do
		if ( category.parent == element.name ) then
			if ( collapsed ) then
				category.hidden = true;
			else
				category.hidden = false;
			end
		end
	end

	categoryFrame:update();
end

function OptionsListButtonToggle_OnClick (self)
	local button = self:GetParent();
	button:toggleFunc();
end


-- [[ OptionsFrameTemplate ]] --

-- NOTE: the difference between "category" and "panel" is mostly a terminology difference
-- let's say we have a set of options called foo
-- "category" is used when referring to foo as data
-- "panel" is used when referring to the frame that displays foo

function OptionsFrame_OnLoad(self)
	local name = self:GetName();

	self.categoryFrame = _G[name.."CategoryFrame"];
	self.panelContainer = _G[name.."PanelContainer"];

	self.okay = _G[name.."Okay"];
	self.cancel = _G[name.."Cancel"];
	self.apply = _G[name.."Apply"];
	self.default = _G[name.."Default"];

	self.categoryList = { };

	self:SetFrameLevel(UIErrorsFrame:GetFrameLevel() - 1);
end

function OptionsFrame_OnShow (self)
	--Refresh the category frames and display the first category if nothing is displayed.
	self.categoryFrame:update();
	if ( not self.panelContainer.displayedPanel ) then
		OptionsListButton_OnClick(self.categoryFrame.buttons[1]);
	end
	--Refresh the categories to pick up changes made while the options frame was hidden.
	OptionsFrame_RefreshCategories(self);
end

function OptionsFrame_OnHide (self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT);

	if ( self.lastFrame ) then
		ShowUIPanel(self.lastFrame);
		self.lastFrame = nil;
	end

	UpdateMicroButtons();
end

local function OptionsFrame_RunOkayForCategory (category)
	pcall(category.okay, category);
end

local function OptionsFrame_RunCancelForCategory (category)
	pcall(category.cancel, category);
end

local function OptionsFrame_RunDefaultForCategory (category)
	pcall(category.default, category, nil);
end

local function OptionsFrame_RunRefreshForCategory (category)
	pcall(category.refresh, category);
end

function OptionsFrameOkay_OnClick (self, apply)
	--Iterate through registered panels and run their okay methods in a taint-safe fashion
	for _, category in SecureNext, self.categoryList do
		-- But if the apply button was used, category has to support it
		if ( not apply or category.hasApply ) then
			securecall(OptionsFrame_RunOkayForCategory, category);
		end
	end
end

function OptionsFrameCancel_OnClick (self)
	--Iterate through registered panels and run their cancel methods in a taint-safe fashion
	for _, category in SecureNext, self.categoryList do
		securecall(OptionsFrame_RunCancelForCategory, category);
	end
end

function OptionsFrameDefault_OnClick (self)
	-- NOTE: defer setting defaults until a popup dialog button is clicked
end

function OptionsFrame_SetAllToDefaults (self)
	--Iterate through registered panels and run their default methods in a taint-safe fashion
	for _, category in SecureNext, self.categoryList do
		securecall(OptionsFrame_RunDefaultForCategory, category);
	end

	--Refresh the categories to pick up changes made.
	OptionsFrame_RefreshCategories(self);
end

function OptionsFrame_SetCurrentToDefaults (self)
	local displayedPanel = self.panelContainer.displayedPanel;
	if ( not displayedPanel or not displayedPanel.default ) then
		return;
	end

	displayedPanel.default(displayedPanel, nil);
	--Run the refresh method to refresh any values that were changed.
	displayedPanel.refresh(displayedPanel);
end

function OptionsFrame_SetCurrentToClassic (self)
	local displayedPanel = self.panelContainer.displayedPanel;
	if ( not displayedPanel or not displayedPanel.classic ) then
		return;
	end

	displayedPanel.classic(displayedPanel);
end

function OptionsFrame_RefreshCategories (self)
	for _, category in SecureNext, self.categoryList do
		securecall(OptionsFrame_RunRefreshForCategory, category);
	end
end

--Table to reuse! Yay reuse!
local displayedElements = {};
function OptionsCategoryFrame_Update (self)
	--Redraw the scroll lists
	local categoryList = self:GetParent().categoryList;

	local element;
	for i, element in SecureNext, displayedElements do
		displayedElements[i] = nil;
	end
	for i, element in SecureNext, categoryList do
		if ( not element.hidden ) then
			tinsert(displayedElements, element);
		end
	end

	local scrollFrame = self.scrollFrame;
	local buttons = self.buttons;
	local numButtons = #buttons;
	local numCategories = #displayedElements;
	if ( numCategories > numButtons and ( not scrollFrame:IsShown() ) ) then
		OptionsList_DisplayScrollBar(self);
	elseif ( numCategories <= numButtons and ( scrollFrame:IsShown() ) ) then
		OptionsList_HideScrollBar(self);
	end

	FauxScrollFrame_Update(scrollFrame, numCategories, numButtons, buttons[1]:GetHeight());

	local selection = self.selection;
	if ( selection ) then
		-- Store the currently selected element and clear all the buttons, we're redrawing.
		OptionsList_ClearSelection(self, self.buttons);
	end

	local offset = FauxScrollFrame_GetOffset(scrollFrame);
	for i = 1, numButtons do
		element = displayedElements[i + offset];
		if ( not element ) then
			OptionsList_HideButton(buttons[i]);
		else
			OptionsList_DisplayButton(buttons[i], element);

			if ( selection and selection == element and not self.selection ) then
				OptionsList_SelectButton(self, buttons[i]);
			end
		end
	end

	if ( selection ) then
		-- If there was a selected element before we cleared the button highlights, restore it, 'cause we're done.
		-- Note: This theoretically might already have been done by OptionsList_SelectButton, but in the event that the selected button hasn't been drawn, this is still necessary.
		self.selection = selection;
	end
end

function OptionsFrame_OpenToCategory (self, panel)
	local panelName;
	if ( type(panel) == "string" ) then
		panelName = panel;
		panel = nil;
	end
	if ( not panelName or panel ) then
		return;
	end

	local categoryList = self.categoryList;

	local elementToDisplay;
	for i, element in SecureNext, categoryList do
		if ( element == panel or (panelName and element.name and element.name == panelName) ) then
			elementToDisplay = element;
			break;
		end
	end
	if ( not elementToDisplay ) then
		return;
	end

	local buttons = self.categoryFrame.buttons
	for i, button in SecureNext, buttons do
		if ( button.element == elementToDisplay ) then
			button:Click();
		elseif ( elementToDisplay.parent and button.element and (button.element.name == elementToDisplay.parent and button.element.collapsed) ) then
			button.toggle:Click();
		end
	end

	if ( not self:IsShown() ) then
		self:Show();
	end
end

function OptionsFrame_AddCategory (self, panel)
	if ( not issecure() ) then
		-- disallow any non-blizzard code to enter here...
		-- we may want to change this in the future if we merge this with Interface Options
	end
	local parent = panel.parent;
	if ( parent ) then
		for i = 1, #self.categoryList do
			if ( self.categoryList[i].name == parent ) then
				if ( self.categoryList[i].hasChildren ) then
					panel.hidden = self.categoryList[i].collapsed;
				else
					panel.hidden = true;
					self.categoryList[i].hasChildren = true;
					self.categoryList[i].collapsed = true;
				end
				tinsert(self.categoryList, i + 1, panel);
				self.categoryFrame:update();
				return;
			end
		end
	end

	tinsert(self.categoryList, panel);
	self.categoryFrame:update();
end

