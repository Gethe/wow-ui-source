UIDROPDOWNMENU_MAXBUTTONS = 1;
UIDROPDOWNMENU_MAXLEVELS = 3;
UIDROPDOWNMENU_BUTTON_HEIGHT = 16;
UIDROPDOWNMENU_BORDER_HEIGHT = 15;
-- The current open menu
UIDROPDOWNMENU_OPEN_MENU = nil;
-- The current menu being initialized
UIDROPDOWNMENU_INIT_MENU = nil;
-- Current level shown of the open menu
UIDROPDOWNMENU_MENU_LEVEL = 1;
-- Current value of the open menu
UIDROPDOWNMENU_MENU_VALUE = nil;
-- Time to wait to hide the menu
UIDROPDOWNMENU_SHOW_TIME = 2;
-- Default dropdown text height
UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = nil;
-- Default dropdown width padding
UIDROPDOWNMENU_DEFAULT_WIDTH_PADDING = 25;
-- List of open menus
OPEN_DROPDOWNMENUS = {};

local UIDropDownMenuDelegate = CreateFrame("FRAME");

function UIDropDownMenuDelegate_OnAttributeChanged (self, attribute, value)
	if ( attribute == "createframes" and value == true ) then
		UIDropDownMenu_CreateFrames(self:GetAttribute("createframes-level"), self:GetAttribute("createframes-index"));
	elseif ( attribute == "initmenu" ) then
		UIDROPDOWNMENU_INIT_MENU = value;
	elseif ( attribute == "openmenu" ) then
		UIDROPDOWNMENU_OPEN_MENU = value;
	end
end

UIDropDownMenuDelegate:SetScript("OnAttributeChanged", UIDropDownMenuDelegate_OnAttributeChanged);

function UIDropDownMenu_InitializeHelper(frame)
	-- This deals with the potentially tainted stuff!
	if ( frame ~= UIDROPDOWNMENU_OPEN_MENU ) then
		UIDROPDOWNMENU_MENU_LEVEL = 1;
	end

	-- Set the frame that's being intialized
	UIDropDownMenuDelegate:SetAttribute("initmenu", frame);

	-- Hide all the buttons
	local button, dropDownList;
	for i = 1, UIDROPDOWNMENU_MAXLEVELS, 1 do
		dropDownList = _G["DropDownList"..i];
		if ( i >= UIDROPDOWNMENU_MENU_LEVEL or frame ~= UIDROPDOWNMENU_OPEN_MENU ) then
			dropDownList.numButtons = 0;
			dropDownList.maxWidth = 0;
			for j=1, UIDROPDOWNMENU_MAXBUTTONS, 1 do
				button = _G["DropDownList"..i.."Button"..j];
				button:Hide();
			end
			dropDownList:Hide();
		end
	end
	frame:SetHeight(UIDROPDOWNMENU_BUTTON_HEIGHT * 2);
end

local function GetChild(frame, name, key)
	if (frame[key]) then
		return frame[key];
	elseif name then
		return _G[name..key];
	end

	return nil;
end

function UIDropDownMenu_Initialize(frame, initFunction, displayMode, level, menuList)
	frame.menuList = menuList;

	securecall("UIDropDownMenu_InitializeHelper", frame);

	-- Set the initialize function and call it.  The initFunction populates the dropdown list.
	if ( initFunction ) then
		UIDropDownMenu_SetInitializeFunction(frame, initFunction);
		initFunction(frame, level, frame.menuList);
	end

	--master frame
	if(level == nil) then
		level = 1;
	end

	local dropDownList = _G["DropDownList"..level];
	dropDownList.dropdown = frame;
	dropDownList.shouldRefresh = true;
	dropDownList:SetWindow(frame:GetWindow());

	UIDropDownMenu_SetDisplayMode(frame, displayMode);
end

function UIDropDownMenu_SetInitializeFunction(frame, initFunction)
	frame.initialize = initFunction;
end

function UIDropDownMenu_SetDisplayMode(frame, displayMode)
	-- Change appearance based on the displayMode
	-- Note: this is a one time change based on previous behavior.
	if ( displayMode == "MENU" ) then
		local name = frame:GetName();
		GetChild(frame, name, "Left"):Hide();
		GetChild(frame, name, "Middle"):Hide();
		GetChild(frame, name, "Right"):Hide();
		local button = GetChild(frame, name, "Button");
		local buttonName = button:GetName();
		GetChild(button, buttonName, "NormalTexture"):SetTexture(nil);
		GetChild(button, buttonName, "DisabledTexture"):SetTexture(nil);
		GetChild(button, buttonName, "PushedTexture"):SetTexture(nil);
		GetChild(button, buttonName, "HighlightTexture"):SetTexture(nil);
		local text = GetChild(frame, name, "Text");

		button:ClearAllPoints();
		button:SetPoint("LEFT", text, "LEFT", -9, 0);
		button:SetPoint("RIGHT", text, "RIGHT", 6, 0);
		frame.displayMode = "MENU";
	end
end

function UIDropDownMenu_SetFrameStrata(frame, frameStrata)
	frame.listFrameStrata = frameStrata;
end

function UIDropDownMenu_RefreshDropDownSize(self)
	self.maxWidth = UIDropDownMenu_GetMaxButtonWidth(self);
	self:SetWidth(self.maxWidth + 25);

	for i=1, UIDROPDOWNMENU_MAXBUTTONS, 1 do
		local icon = _G[self:GetName().."Button"..i.."Icon"];

		if ( icon.tFitDropDownSizeX ) then
			icon:SetWidth(self.maxWidth - 5);
		end
	end
end

-- If dropdown is visible then see if its timer has expired, if so hide the frame
function UIDropDownMenu_OnUpdate(self, elapsed)
	if ( self.shouldRefresh ) then
		UIDropDownMenu_RefreshDropDownSize(self);
		self.shouldRefresh = false;
	end
end

function UIDropDownMenuButtonInvisibleButton_OnEnter(self)
	CloseDropDownMenus(self:GetParent():GetParent():GetID() + 1);
	local parent = self:GetParent();
	if ( parent.tooltipTitle and parent.tooltipWhileDisabled) then
		if ( parent.tooltipOnButton ) then
			local tooltip = GetAppropriateTooltip();
			tooltip:SetOwner(parent, "ANCHOR_RIGHT");
			GameTooltip_SetTitle(tooltip, parent.tooltipTitle);
			if parent.tooltipInstruction then
				GameTooltip_AddInstructionLine(tooltip, parent.tooltipInstruction);
			end
			if parent.tooltipText then
				GameTooltip_AddNormalLine(tooltip, parent.tooltipText, true);
			end
			if parent.tooltipWarning then
				GameTooltip_AddColoredLine(tooltip, parent.tooltipWarning, RED_FONT_COLOR, true);
			end
			if parent.tooltipBackdropStyle then
				SharedTooltip_SetBackdropStyle(tooltip, parent.tooltipBackdropStyle);
			end
			tooltip:Show();
		end
	end
end

function UIDropDownMenuButtonInvisibleButton_OnLeave(self)
	GetAppropriateTooltip():Hide();
end

function UIDropDownMenuButton_OnEnter(self)
	if ( self.hasArrow ) then
		local level =  self:GetParent():GetID() + 1;
		local listFrame = _G["DropDownList"..level];
		if ( not listFrame or not listFrame:IsShown() or select(2, listFrame:GetPoint(1)) ~= self ) then
			ToggleDropDownMenu(self:GetParent():GetID() + 1, self.value, nil, nil, nil, nil, self.menuList, self, nil, self.menuListDisplayMode);
		end
	else
		CloseDropDownMenus(self:GetParent():GetID() + 1);
	end
	self.Highlight:Show();
	if ( self.tooltipTitle and not self.noTooltipWhileEnabled and not UIDropDownMenuButton_ShouldShowIconTooltip(self) ) then
		if ( self.tooltipOnButton ) then
			local tooltip = GetAppropriateTooltip();
			tooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip_SetTitle(tooltip, self.tooltipTitle);
			if self.tooltipInstruction then
				GameTooltip_AddInstructionLine(tooltip, self.tooltipInstruction);
			end
			if self.tooltipText then
				GameTooltip_AddNormalLine(tooltip, self.tooltipText, true);
			end
			if self.tooltipWarning then
				GameTooltip_AddColoredLine(tooltip, self.tooltipWarning, RED_FONT_COLOR, true);
			end
			if self.tooltipBackdropStyle then
				SharedTooltip_SetBackdropStyle(tooltip, self.tooltipBackdropStyle);
			end
			tooltip:Show();
		end
	end

	if ( self.mouseOverIcon ~= nil ) then
		self.Icon:SetTexture(self.mouseOverIcon);
		self.Icon:Show();
	end

	GetValueOrCallFunction(self, "funcOnEnter", self);
	self.NewFeature:Hide();
end

function UIDropDownMenuButton_OnLeave(self)
	self.Highlight:Hide();
	GetAppropriateTooltip():Hide();

	if ( self.mouseOverIcon ~= nil ) then
		if ( self.icon ~= nil ) then
			self.Icon:SetTexture(self.icon);
		else
			self.Icon:Hide();
		end
	end

	GetValueOrCallFunction(self, "funcOnLeave", self);
end

function UIDropDownMenuButton_ShouldShowIconTooltip(self)
	if self.Icon and (self.iconTooltipTitle or self.iconTooltipText) and (self.icon or self.mouseOverIcon) then
		return GetMouseFocus() == self.Icon;
	end
	return false;
end

function UIDropDownMenuButtonIcon_OnEnter(self)
	local button = self:GetParent();
	if not button then
		return;
	end

	local shouldShowIconTooltip = UIDropDownMenuButton_ShouldShowIconTooltip(button);

	if shouldShowIconTooltip then

		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(button, "ANCHOR_RIGHT");
		if button.iconTooltipTitle then
			GameTooltip_SetTitle(tooltip, button.iconTooltipTitle);
		end
		if button.iconTooltipText then
			GameTooltip_AddNormalLine(tooltip, button.iconTooltipText, true);
		end
		if button.iconTooltipBackdropStyle then
			SharedTooltip_SetBackdropStyle(tooltip, button.iconTooltipBackdropStyle);
		end
		tooltip:Show();
	end

	UIDropDownMenuButton_OnEnter(button);
end

function UIDropDownMenuButtonIcon_OnLeave(self)
	local button = self:GetParent();
	if not button then
		return;
	end

	UIDropDownMenuButton_OnLeave(button);
end

--[[
List of button attributes
======================================================
info.text = [STRING]  --  The text of the button
info.value = [ANYTHING]  --  The value that UIDROPDOWNMENU_MENU_VALUE is set to when the button is clicked
info.func = [function()]  --  The function that is called when you click the button
info.checked = [nil, true, function]  --  Check the button if true or function returns true
info.isNotRadio = [nil, true]  --  Check the button uses radial image if false check box image if true
info.isTitle = [nil, true]  --  If it's a title the button is disabled and the font color is set to yellow
info.disabled = [nil, true]  --  Disable the button and show an invisible button that still traps the mouseover event so menu doesn't time out
info.tooltipWhileDisabled = [nil, 1] -- Show the tooltip, even when the button is disabled.
info.hasArrow = [nil, true]  --  Show the expand arrow for multilevel menus
info.arrowXOffset = [nil, NUMBER] -- Number of pixels to shift the button's icon to the left or right (positive numbers shift right, negative numbers shift left).
info.hasColorSwatch = [nil, true]  --  Show color swatch or not, for color selection
info.r = [1 - 255]  --  Red color value of the color swatch
info.g = [1 - 255]  --  Green color value of the color swatch
info.b = [1 - 255]  --  Blue color value of the color swatch
info.colorCode = [STRING] -- "|cAARRGGBB" embedded hex value of the button text color. Only used when button is enabled
info.swatchFunc = [function()]  --  Function called by the color picker on color change
info.hasOpacity = [nil, 1]  --  Show the opacity slider on the colorpicker frame
info.opacity = [0.0 - 1.0]  --  Percentatge of the opacity, 1.0 is fully shown, 0 is transparent
info.opacityFunc = [function()]  --  Function called by the opacity slider when you change its value
info.cancelFunc = [function(previousValues)] -- Function called by the colorpicker when you click the cancel button (it takes the previous values as its argument)
info.notClickable = [nil, 1]  --  Disable the button and color the font white
info.notCheckable = [nil, 1]  --  Shrink the size of the buttons and don't display a check box
info.owner = [Frame]  --  Dropdown frame that "owns" the current dropdownlist
info.keepShownOnClick = [nil, 1]  --  Don't hide the dropdownlist after a button is clicked
info.tooltipTitle = [nil, STRING] -- Title of the tooltip shown on mouseover
info.tooltipText = [nil, STRING] -- Text of the tooltip shown on mouseover
info.tooltipWarning = [nil, STRING] -- Warning-style text of the tooltip shown on mouseover
info.tooltipInstruction = [nil, STRING] -- Instruction-style text of the tooltip shown on mouseover
info.tooltipOnButton = [nil, 1] -- Show the tooltip attached to the button instead of as a Newbie tooltip.
info.tooltipBackdropStyle = [nil, TABLE] -- Optional Backdrop style of the tooltip shown on mouseover
info.justifyH = [nil, "CENTER"] -- Justify button text
info.arg1 = [ANYTHING] -- This is the first argument used by info.func
info.arg2 = [ANYTHING] -- This is the second argument used by info.func
info.fontObject = [FONT] -- font object replacement for Normal and Highlight
info.menuList = [TABLE] -- This contains an array of info tables to be displayed as a child menu
info.menuListDisplayMode = [nil, "MENU"] -- If menuList is set, show the sub drop down with an override display mode.
info.noClickSound = [nil, 1]  --  Set to 1 to suppress the sound when clicking the button. The sound only plays if .func is set.
info.padding = [nil, NUMBER] -- Number of pixels to pad the text on the right side
info.topPadding = [nil, NUMBER] -- Extra spacing between buttons.
info.leftPadding = [nil, NUMBER] -- Number of pixels to pad the button on the left side
info.minWidth = [nil, NUMBER] -- Minimum width for this line
info.customFrame = frame -- Allows this button to be a completely custom frame, should inherit from UIDropDownCustomMenuEntryTemplate and override appropriate methods.
info.icon = [TEXTURE] -- An icon for the button.
info.iconXOffset = [nil, NUMBER] -- Number of pixels to shift the button's icon to the left or right (positive numbers shift right, negative numbers shift left).
info.iconTooltipTitle = [nil, STRING] -- Title of the tooltip shown on icon mouseover
info.iconTooltipText = [nil, STRING] -- Text of the tooltip shown on icon mouseover
info.iconTooltipBackdropStyle = [nil, TABLE] -- Optional Backdrop style of the tooltip shown on icon mouseover
info.mouseOverIcon = [TEXTURE] -- An override icon when a button is moused over.
info.ignoreAsMenuSelection [nil, true] -- Never set the menu text/icon to this, even when this button is checked
info.registerForRightClick [nil, true] -- Register dropdown buttons for right clicks
info.registerForAnyClick [nil, true] -- Register dropdown buttons for any clicks
]]

function UIDropDownMenu_CreateInfo()
	return {};
end

function UIDropDownMenu_CreateFrames(level, index)
	while ( level > UIDROPDOWNMENU_MAXLEVELS ) do
		UIDROPDOWNMENU_MAXLEVELS = UIDROPDOWNMENU_MAXLEVELS + 1;
		local newList = CreateFrame("Button", "DropDownList"..UIDROPDOWNMENU_MAXLEVELS, nil, "UIDropDownListTemplate");
		newList:SetFrameStrata("FULLSCREEN_DIALOG");
		newList:SetToplevel(true);
		newList:Hide();
		newList:SetID(UIDROPDOWNMENU_MAXLEVELS);
		newList:SetWidth(180)
		newList:SetHeight(10)
		for i=1, UIDROPDOWNMENU_MAXBUTTONS do
			local newButton = CreateFrame("Button", "DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Button"..i, newList, "UIDropDownMenuButtonTemplate");
			newButton:SetID(i);
		end
	end

	while ( index > UIDROPDOWNMENU_MAXBUTTONS ) do
		UIDROPDOWNMENU_MAXBUTTONS = UIDROPDOWNMENU_MAXBUTTONS + 1;
		for i=1, UIDROPDOWNMENU_MAXLEVELS do
			local newButton = CreateFrame("Button", "DropDownList"..i.."Button"..UIDROPDOWNMENU_MAXBUTTONS, _G["DropDownList"..i], "UIDropDownMenuButtonTemplate");
			newButton:SetID(UIDROPDOWNMENU_MAXBUTTONS);
		end
	end
end

function UIDropDownMenu_AddSeparator(level)
	local separatorInfo = {
		hasArrow = false;
		dist = 0;
		isTitle = true;
		isUninteractable = true;
		notCheckable = true;
		iconOnly = true;
		icon = "Interface\\Common\\UI-TooltipDivider-Transparent";
		tCoordLeft = 0;
		tCoordRight = 1;
		tCoordTop = 0;
		tCoordBottom = 1;
		tSizeX = 0;
		tSizeY = 8;
		tFitDropDownSizeX = true;
		iconInfo = {
			tCoordLeft = 0,
			tCoordRight = 1,
			tCoordTop = 0,
			tCoordBottom = 1,
			tSizeX = 0,
			tSizeY = 8,
			tFitDropDownSizeX = true
		},
	};

	UIDropDownMenu_AddButton(separatorInfo, level);
end

function UIDropDownMenu_AddSpace(level)
	local spaceInfo = {
		hasArrow = false,
		dist = 0,
		isTitle = true,
		isUninteractable = true,
		notCheckable = true,
	};

	UIDropDownMenu_AddButton(spaceInfo, level);
end

function UIDropDownMenu_AddButton(info, level)
	--[[
	Might to uncomment this if there are performance issues
	if ( not UIDROPDOWNMENU_OPEN_MENU ) then
		return;
	end
	]]
	if ( not level ) then
		level = 1;
	end

	local listFrame = _G["DropDownList"..level];
	local index = listFrame and (listFrame.numButtons + 1) or 1;
	local width;

	UIDropDownMenuDelegate:SetAttribute("createframes-level", level);
	UIDropDownMenuDelegate:SetAttribute("createframes-index", index);
	UIDropDownMenuDelegate:SetAttribute("createframes", true);

	listFrame = listFrame or _G["DropDownList"..level];
	local listFrameName = listFrame:GetName();

	-- Set the number of buttons in the listframe
	listFrame.numButtons = index;

	local button = _G[listFrameName.."Button"..index];
	local normalText = _G[button:GetName().."NormalText"];
	local icon = _G[button:GetName().."Icon"];
	-- This button is used to capture the mouse OnEnter/OnLeave events if the dropdown button is disabled, since a disabled button doesn't receive any events
	-- This is used specifically for drop down menu time outs
	local invisibleButton = _G[button:GetName().."InvisibleButton"];

	-- Default settings
	button:SetDisabledFontObject(GameFontDisableSmallLeft);
	invisibleButton:Hide();
	button:Enable();

	if ( info.registerForAnyClick ) then
		button:RegisterForClicks("AnyUp");
	elseif ( info.registerForRightClick ) then
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	else
		button:RegisterForClicks("LeftButtonUp");
	end

	-- If not clickable then disable the button and set it white
	if ( info.notClickable ) then
		info.disabled = true;
		button:SetDisabledFontObject(GameFontHighlightSmallLeft);
	end

	-- Set the text color and disable it if its a title
	if ( info.isTitle ) then
		info.disabled = true;
		button:SetDisabledFontObject(GameFontNormalSmallLeft);
	end

	-- Disable the button if disabled and turn off the color code
	if ( info.disabled ) then
		button:Disable();
		invisibleButton:Show();
		info.colorCode = nil;
	end

	-- If there is a color for a disabled line, set it
	if( info.disablecolor ) then
		info.colorCode = info.disablecolor;
	end

	-- Configure button
	if ( info.text ) then
		-- look for inline color code this is only if the button is enabled
		if ( info.colorCode ) then
			button:SetText(info.colorCode..info.text.."|r");
		else
			button:SetText(info.text);
		end

		-- Set icon
		if ( info.icon or info.mouseOverIcon ) then
			icon:SetSize(16,16);
			if(info.icon and C_Texture.GetAtlasInfo(info.icon)) then
				icon:SetAtlas(info.icon);
			else
				icon:SetTexture(info.icon);
			end
			icon:ClearAllPoints();
			icon:SetPoint("RIGHT", info.iconXOffset or 0, 0);

			if ( info.tCoordLeft ) then
				icon:SetTexCoord(info.tCoordLeft, info.tCoordRight, info.tCoordTop, info.tCoordBottom);
			else
				icon:SetTexCoord(0, 1, 0, 1);
			end
			icon:Show();
		else
			icon:Hide();
		end

		-- Check to see if there is a replacement font
		if ( info.fontObject ) then
			button:SetNormalFontObject(info.fontObject);
			button:SetHighlightFontObject(info.fontObject);
		else
			button:SetNormalFontObject(GameFontHighlightSmallLeft);
			button:SetHighlightFontObject(GameFontHighlightSmallLeft);
		end
	else
		button:SetText("");
		icon:Hide();
	end

	button.iconOnly = nil;
	button.icon = nil;
	button.iconInfo = nil;

	if (info.iconInfo) then
		icon.tFitDropDownSizeX = info.iconInfo.tFitDropDownSizeX;
	else
		icon.tFitDropDownSizeX = nil;
	end
	if (info.iconOnly and info.icon) then
		button.iconOnly = true;
		button.icon = info.icon;
		button.iconInfo = info.iconInfo;

		UIDropDownMenu_SetIconImage(icon, info.icon, info.iconInfo);
		icon:ClearAllPoints();
		icon:SetPoint("LEFT");
	end

	-- Pass through attributes
	button.func = info.func;
	button.funcOnEnter = info.funcOnEnter;
	button.funcOnLeave = info.funcOnLeave;
	button.owner = info.owner;
	button.hasOpacity = info.hasOpacity;
	button.opacity = info.opacity;
	button.opacityFunc = info.opacityFunc;
	button.cancelFunc = info.cancelFunc;
	button.swatchFunc = info.swatchFunc;
	button.keepShownOnClick = info.keepShownOnClick;
	button.tooltipTitle = info.tooltipTitle;
	button.tooltipText = info.tooltipText;
	button.tooltipInstruction = info.tooltipInstruction;
	button.tooltipWarning = info.tooltipWarning;
	button.tooltipBackdropStyle = info.tooltipBackdropStyle;
	button.arg1 = info.arg1;
	button.arg2 = info.arg2;
	button.hasArrow = info.hasArrow;
	button.arrowXOffset = info.arrowXOffset;
	button.hasColorSwatch = info.hasColorSwatch;
	button.notCheckable = info.notCheckable;
	button.menuList = info.menuList;
	button.menuListDisplayMode = info.menuListDisplayMode;
	button.tooltipWhileDisabled = info.tooltipWhileDisabled;
	button.noTooltipWhileEnabled = info.noTooltipWhileEnabled;
	button.tooltipOnButton = info.tooltipOnButton;
	button.noClickSound = info.noClickSound;
	button.padding = info.padding;
	button.icon = info.icon;
	button.iconTooltipTitle = info.iconTooltipTitle;
	button.iconTooltipText = info.iconTooltipText;
	button.iconTooltipBackdropStyle = info.iconTooltipBackdropStyle;
	button.iconXOffset = info.iconXOffset;
	button.mouseOverIcon = info.mouseOverIcon;
	button.ignoreAsMenuSelection = info.ignoreAsMenuSelection;
	button.showNewLabel = info.showNewLabel;

	if ( info.value ~= nil) then
		button.value = info.value;
	elseif ( info.text ) then
		button.value = info.text;
	else
		button.value = nil;
	end

	local expandArrow = _G[listFrameName.."Button"..index.."ExpandArrow"];
	expandArrow:SetPoint("RIGHT", info.arrowXOffset or 0, 0);
	expandArrow:SetShown(info.hasArrow);
	expandArrow:SetEnabled(not info.disabled);

	-- If not checkable move everything over to the left to fill in the gap where the check would be
	local xPos = 5;
	local buttonHeight = (info.topPadding or 0) + UIDROPDOWNMENU_BUTTON_HEIGHT;
	local yPos = -((button:GetID() - 1) * buttonHeight) - UIDROPDOWNMENU_BORDER_HEIGHT;
	local displayInfo = normalText;
	if (info.iconOnly) then
		displayInfo = icon;
	end

	displayInfo:ClearAllPoints();
	if ( info.notCheckable ) then
		if ( info.justifyH and info.justifyH == "CENTER" ) then
			displayInfo:SetPoint("CENTER", button, "CENTER", -7, 0);
		else
			displayInfo:SetPoint("LEFT", button, "LEFT", 0, 0);
		end
		xPos = xPos + 10;

	else
		xPos = xPos + 12;
		displayInfo:SetPoint("LEFT", button, "LEFT", 20, 0);
	end

	-- Adjust offset if displayMode is menu
	local frame = UIDROPDOWNMENU_OPEN_MENU;
	if ( frame and frame.displayMode == "MENU" ) then
		if ( not info.notCheckable ) then
			xPos = xPos - 6;
		end
	end

	-- If no open frame then set the frame to the currently initialized frame
	frame = frame or UIDROPDOWNMENU_INIT_MENU;

	if ( info.leftPadding ) then
		xPos = xPos + info.leftPadding;
	end
	button:SetPoint("TOPLEFT", button:GetParent(), "TOPLEFT", xPos, yPos);

	-- See if button is selected by id or name
	if ( frame ) then
		if ( UIDropDownMenu_GetSelectedName(frame) ) then
			if ( button:GetText() == UIDropDownMenu_GetSelectedName(frame) ) then
				info.checked = 1;
			end
		elseif ( UIDropDownMenu_GetSelectedID(frame) ) then
			if ( button:GetID() == UIDropDownMenu_GetSelectedID(frame) ) then
				info.checked = 1;
			end
		elseif ( UIDropDownMenu_GetSelectedValue(frame) ~= nil ) then
			if ( button.value == UIDropDownMenu_GetSelectedValue(frame) ) then
				info.checked = 1;
			end
		end
	end

	if not info.notCheckable then
		local check = _G[listFrameName.."Button"..index.."Check"];
		local uncheck = _G[listFrameName.."Button"..index.."UnCheck"];
		if ( info.disabled ) then
			check:SetDesaturated(true);
			check:SetAlpha(0.5);
			uncheck:SetDesaturated(true);
			uncheck:SetAlpha(0.5);
		else
			check:SetDesaturated(false);
			check:SetAlpha(1);
			uncheck:SetDesaturated(false);
			uncheck:SetAlpha(1);
		end

		if info.customCheckIconAtlas or info.customCheckIconTexture then
			check:SetTexCoord(0, 1, 0, 1);
			uncheck:SetTexCoord(0, 1, 0, 1);

			if info.customCheckIconAtlas then
				check:SetAtlas(info.customCheckIconAtlas);
				uncheck:SetAtlas(info.customUncheckIconAtlas or info.customCheckIconAtlas);
			else
				check:SetTexture(info.customCheckIconTexture);
				uncheck:SetTexture(info.customUncheckIconTexture or info.customCheckIconTexture);
			end
		elseif info.isNotRadio then
			check:SetTexCoord(0.0, 0.5, 0.0, 0.5);
			check:SetTexture("Interface\\Common\\UI-DropDownRadioChecks");
			uncheck:SetTexCoord(0.5, 1.0, 0.0, 0.5);
			uncheck:SetTexture("Interface\\Common\\UI-DropDownRadioChecks");
		else
			check:SetTexCoord(0.0, 0.5, 0.5, 1.0);
			check:SetTexture("Interface\\Common\\UI-DropDownRadioChecks");
			uncheck:SetTexCoord(0.5, 1.0, 0.5, 1.0);
			uncheck:SetTexture("Interface\\Common\\UI-DropDownRadioChecks");
		end

		-- Checked can be a function now
		local checked = info.checked;
		if ( type(checked) == "function" ) then
			checked = checked(button);
		end

		-- Show the check if checked
		if ( checked ) then
			button:LockHighlight();
			check:Show();
			uncheck:Hide();
		else
			button:UnlockHighlight();
			check:Hide();
			uncheck:Show();
		end
	else
		_G[listFrameName.."Button"..index.."Check"]:Hide();
		_G[listFrameName.."Button"..index.."UnCheck"]:Hide();
	end
	button.checked = info.checked;
	button.NewFeature:SetShown(button.showNewLabel);

	-- If has a colorswatch, show it and vertex color it
	local colorSwatch = _G[listFrameName.."Button"..index.."ColorSwatch"];
	if ( info.hasColorSwatch ) then
		_G["DropDownList"..level.."Button"..index.."ColorSwatch"].Color:SetVertexColor(info.r, info.g, info.b);
		button.r = info.r;
		button.g = info.g;
		button.b = info.b;
		colorSwatch:Show();
	else
		colorSwatch:Hide();
	end

	UIDropDownMenu_CheckAddCustomFrame(listFrame, button, info);

	button:SetShown(button.customFrame == nil);

	button.minWidth = info.minWidth;

	width = max(UIDropDownMenu_GetButtonWidth(button), info.minWidth or 0);
	--Set maximum button width
	if ( width > listFrame.maxWidth ) then
		listFrame.maxWidth = width;
	end

	local customFrameCount = listFrame.customFrames and #listFrame.customFrames or 0;
	local height = ((index - customFrameCount) * buttonHeight) + (UIDROPDOWNMENU_BORDER_HEIGHT * 2);
	for frameIndex = 1, customFrameCount do
		local frame = listFrame.customFrames[frameIndex];
		height = height + frame:GetPreferredEntryHeight();
	end

	-- Set the height of the listframe
	listFrame:SetHeight(height);

	return button;
end

function UIDropDownMenu_CheckAddCustomFrame(self, button, info)
	local customFrame = info.customFrame;
	button.customFrame = customFrame;
	if customFrame then
		customFrame:SetOwningButton(button);
		customFrame:ClearAllPoints();
		customFrame:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
		customFrame:Show();

		UIDropDownMenu_RegisterCustomFrame(self, customFrame);
	end
end

function UIDropDownMenu_RegisterCustomFrame(self, customFrame)
	self.customFrames = self.customFrames or {}
	table.insert(self.customFrames, customFrame);
end

function UIDropDownMenu_GetMaxButtonWidth(self)
	local maxWidth = 0;
	for i=1, self.numButtons do
		local button = _G[self:GetName().."Button"..i];
		local width = UIDropDownMenu_GetButtonWidth(button);
		if ( width > maxWidth ) then
			maxWidth = width;
		end
	end
	return maxWidth;
end

function UIDropDownMenu_GetButtonWidth(button)
	local minWidth = button.minWidth or 0;
	if button.customFrame and button.customFrame:IsShown() then
		return math.max(minWidth, button.customFrame:GetPreferredEntryWidth());
	end

	if not button:IsShown() then
		return 0;
	end

	local width;
	local buttonName = button:GetName();
	local icon = _G[buttonName.."Icon"];
	local normalText = _G[buttonName.."NormalText"];

	if ( button.iconOnly and icon ) then
		width = icon:GetWidth();
	elseif ( normalText and normalText:GetText() ) then
		width = normalText:GetWidth() + 40;

		if ( button.icon ) then
			-- Add padding for the icon
			width = width + 10;
		end
	else
		return minWidth;
	end

	-- Add padding if has and expand arrow or color swatch
	if ( button.hasArrow or button.hasColorSwatch ) then
		width = width + 10;
	end
	if (button.showNewLabel) then
		width = width + button.NewFeature.Label:GetUnboundedStringWidth();
	end
	if ( button.notCheckable ) then
		width = width - 30;
	end
	if ( button.padding ) then
		width = width + button.padding;
	end

	return math.max(minWidth, width);
end

function UIDropDownMenu_Refresh(frame, useValue, dropdownLevel)
	local maxWidth = 0;
	local somethingChecked = nil;
	if ( not dropdownLevel ) then
		dropdownLevel = UIDROPDOWNMENU_MENU_LEVEL;
	end

	local listFrame = _G["DropDownList"..dropdownLevel];
	listFrame.numButtons = listFrame.numButtons or 0;
	-- Just redraws the existing menu
	for i=1, UIDROPDOWNMENU_MAXBUTTONS do
		local button = _G["DropDownList"..dropdownLevel.."Button"..i];
		local checked = nil;

		if(i <= listFrame.numButtons) then
			-- See if checked or not
			if ( UIDropDownMenu_GetSelectedName(frame) ) then
				if ( button:GetText() == UIDropDownMenu_GetSelectedName(frame) ) then
					checked = 1;
				end
			elseif ( UIDropDownMenu_GetSelectedID(frame) ) then
				if ( button:GetID() == UIDropDownMenu_GetSelectedID(frame) ) then
					checked = 1;
				end
			elseif ( UIDropDownMenu_GetSelectedValue(frame) ) then
				if ( button.value == UIDropDownMenu_GetSelectedValue(frame) ) then
					checked = 1;
				end
			end
		end
		if (button.checked and type(button.checked) == "function") then
			checked = button.checked(button);
		end

		if not button.notCheckable and button:IsShown() then
			-- If checked show check image
			local checkImage = _G["DropDownList"..dropdownLevel.."Button"..i.."Check"];
			local uncheckImage = _G["DropDownList"..dropdownLevel.."Button"..i.."UnCheck"];
			if ( checked ) then
				if not button.ignoreAsMenuSelection then
					somethingChecked = true;
					local icon = GetChild(frame, frame:GetName(), "Icon");
					if (button.iconOnly and icon and button.icon) then
						UIDropDownMenu_SetIconImage(icon, button.icon, button.iconInfo);
					elseif ( useValue ) then
						UIDropDownMenu_SetText(frame, button.value);
						icon:Hide();
					else
						UIDropDownMenu_SetText(frame, button:GetText());
						icon:Hide();
					end
				end
				button:LockHighlight();
				checkImage:Show();
				uncheckImage:Hide();
			else
				button:UnlockHighlight();
				checkImage:Hide();
				uncheckImage:Show();
			end
		end

		local normalText = _G[button:GetName().."NormalText"];
		button.NewFeature:SetShown(button.showNewLabel);
		button.NewFeature:SetPoint("LEFT", normalText, "RIGHT", 20, 0);

		if ( button:IsShown() ) then
			local width = UIDropDownMenu_GetButtonWidth(button);
			if ( width > maxWidth ) then
				maxWidth = width;
			end
		end
	end
	if(somethingChecked == nil) then
		UIDropDownMenu_SetText(frame, VIDEO_QUALITY_LABEL6);
		local icon = GetChild(frame, frame:GetName(), "Icon");
		icon:Hide();
	end
	if (not frame.noResize) then
		for i=1, UIDROPDOWNMENU_MAXBUTTONS do
			local button = _G["DropDownList"..dropdownLevel.."Button"..i];
			button:SetWidth(maxWidth);
		end
		UIDropDownMenu_RefreshDropDownSize(_G["DropDownList"..dropdownLevel]);
	end
end

function UIDropDownMenu_RefreshAll(frame, useValue)
	for dropdownLevel = UIDROPDOWNMENU_MENU_LEVEL, 2, -1 do
		local listFrame = _G["DropDownList"..dropdownLevel];
		if ( listFrame:IsShown() ) then
			UIDropDownMenu_Refresh(frame, nil, dropdownLevel);
		end
	end
	-- useValue is the text on the dropdown, only needs to be set once
	UIDropDownMenu_Refresh(frame, useValue, 1);
end

function UIDropDownMenu_SetIconImage(icon, texture, info)
	icon:SetTexture(texture);
	if ( info.tCoordLeft ) then
		icon:SetTexCoord(info.tCoordLeft, info.tCoordRight, info.tCoordTop, info.tCoordBottom);
	else
		icon:SetTexCoord(0, 1, 0, 1);
	end
	if ( info.tSizeX ) then
		icon:SetWidth(info.tSizeX);
	else
		icon:SetWidth(16);
	end
	if ( info.tSizeY ) then
		icon:SetHeight(info.tSizeY);
	else
		icon:SetHeight(16);
	end
	icon:Show();
end

function UIDropDownMenu_SetSelectedName(frame, name, useValue)
	frame.selectedName = name;
	frame.selectedID = nil;
	frame.selectedValue = nil;
	UIDropDownMenu_Refresh(frame, useValue);
end

function UIDropDownMenu_SetSelectedValue(frame, value, useValue)
	-- useValue will set the value as the text, not the name
	frame.selectedName = nil;
	frame.selectedID = nil;
	frame.selectedValue = value;
	UIDropDownMenu_Refresh(frame, useValue);
end

function UIDropDownMenu_SetSelectedID(frame, id, useValue)
	frame.selectedID = id;
	frame.selectedName = nil;
	frame.selectedValue = nil;
	UIDropDownMenu_Refresh(frame, useValue);
end

function UIDropDownMenu_GetSelectedName(frame)
	return frame.selectedName;
end

function UIDropDownMenu_GetSelectedID(frame)
	if ( frame.selectedID ) then
		return frame.selectedID;
	else
		-- If no explicit selectedID then try to send the id of a selected value or name
		local listFrame = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL];
		for i=1, listFrame.numButtons do
			local button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i];
			-- See if checked or not
			if ( UIDropDownMenu_GetSelectedName(frame) ) then
				if ( button:GetText() == UIDropDownMenu_GetSelectedName(frame) ) then
					return i;
				end
			elseif ( UIDropDownMenu_GetSelectedValue(frame) ) then
				if ( button.value == UIDropDownMenu_GetSelectedValue(frame) ) then
					return i;
				end
			end
		end
	end
end

function UIDropDownMenu_GetSelectedValue(frame)
	return frame.selectedValue;
end

function UIDropDownMenuButton_OnClick(self, mouseButton)
	local checked = self.checked;
	if ( type (checked) == "function" ) then
		checked = checked(self);
	end


	if ( self.keepShownOnClick ) then
		if not self.notCheckable then
			if ( checked ) then
				_G[self:GetName().."Check"]:Hide();
				_G[self:GetName().."UnCheck"]:Show();
				checked = false;
			else
				_G[self:GetName().."Check"]:Show();
				_G[self:GetName().."UnCheck"]:Hide();
				checked = true;
			end
		end
	else
		self:GetParent():Hide();
	end

	if ( type (self.checked) ~= "function" ) then
		self.checked = checked;
	end

	-- saving this here because func might use a dropdown, changing this self's attributes
	local playSound = true;
	if ( self.noClickSound ) then
		playSound = false;
	end

	local func = self.func;
	if ( func ) then
		func(self, self.arg1, self.arg2, checked, mouseButton);
	else
		return;
	end

	if ( playSound ) then
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end
end

function HideDropDownMenu(level)
	local listFrame = _G["DropDownList"..level];
	listFrame:Hide();
end

function ToggleDropDownMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay, overrideDisplayMode)
	if ( not level ) then
		level = 1;
	end
	UIDropDownMenuDelegate:SetAttribute("createframes-level", level);
	UIDropDownMenuDelegate:SetAttribute("createframes-index", 0);
	UIDropDownMenuDelegate:SetAttribute("createframes", true);
	UIDROPDOWNMENU_MENU_LEVEL = level;
	UIDROPDOWNMENU_MENU_VALUE = value;
	local listFrameName = "DropDownList"..level;
	local listFrame = _G[listFrameName];
	UIDropDownMenu_ClearCustomFrames(listFrame);

	local tempFrame;
	local point, relativePoint, relativeTo;
	if ( not dropDownFrame ) then
		tempFrame = button:GetParent();
	else
		tempFrame = dropDownFrame;
	end
	if ( listFrame:IsShown() and (UIDROPDOWNMENU_OPEN_MENU == tempFrame) ) then
		listFrame:Hide();
	else
		-- Set the dropdownframe scale
		local uiScale;
		local uiParentScale = UIParent:GetScale();
		if ( GetCVar("useUIScale") == "1" ) then
			uiScale = tonumber(GetCVar("uiscale"));
			if ( uiParentScale < uiScale ) then
				uiScale = uiParentScale;
			end
		else
			uiScale = uiParentScale;
		end
		listFrame:SetScale(uiScale);

		-- Hide the listframe anyways since it is redrawn OnShow()
		listFrame:Hide();

		-- Frame to anchor the dropdown menu to
		local anchorFrame;

		-- Display stuff
		-- Level specific stuff
		if ( level == 1 ) then
			UIDropDownMenuDelegate:SetAttribute("openmenu", dropDownFrame);
			listFrame:ClearAllPoints();
			-- If there's no specified anchorName then use left side of the dropdown menu
			if ( not anchorName ) then
				-- See if the anchor was set manually using setanchor
				if ( dropDownFrame.xOffset ) then
					xOffset = dropDownFrame.xOffset;
				end
				if ( dropDownFrame.yOffset ) then
					yOffset = dropDownFrame.yOffset;
				end
				if ( dropDownFrame.point ) then
					point = dropDownFrame.point;
				end
				if ( dropDownFrame.relativeTo ) then
					relativeTo = dropDownFrame.relativeTo;
				else
					relativeTo = GetChild(UIDROPDOWNMENU_OPEN_MENU, UIDROPDOWNMENU_OPEN_MENU:GetName(), "Left");
				end
				if ( dropDownFrame.relativePoint ) then
					relativePoint = dropDownFrame.relativePoint;
				end
			elseif ( anchorName == "cursor" ) then
				relativeTo = nil;
				local cursorX, cursorY = GetCursorPosition();
				cursorX = cursorX/uiScale;
				cursorY =  cursorY/uiScale;

				if ( not xOffset ) then
					xOffset = 0;
				end
				if ( not yOffset ) then
					yOffset = 0;
				end
				xOffset = cursorX + xOffset;
				yOffset = cursorY + yOffset;
			else
				-- See if the anchor was set manually using setanchor
				if ( dropDownFrame.xOffset ) then
					xOffset = dropDownFrame.xOffset;
				end
				if ( dropDownFrame.yOffset ) then
					yOffset = dropDownFrame.yOffset;
				end
				if ( dropDownFrame.point ) then
					point = dropDownFrame.point;
				end
				if ( dropDownFrame.relativeTo ) then
					relativeTo = dropDownFrame.relativeTo;
				else
					relativeTo = anchorName;
				end
				if ( dropDownFrame.relativePoint ) then
					relativePoint = dropDownFrame.relativePoint;
				end
			end
			if ( not xOffset or not yOffset ) then
				xOffset = 8;
				yOffset = 22;
			end
			if ( not point ) then
				point = "TOPLEFT";
			end
			if ( not relativePoint ) then
				relativePoint = "BOTTOMLEFT";
			end
			listFrame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
		else
			if ( not dropDownFrame ) then
				dropDownFrame = UIDROPDOWNMENU_OPEN_MENU;
			end
			listFrame:ClearAllPoints();
			-- If this is a dropdown button, not the arrow anchor it to itself
			if ( strsub(button:GetParent():GetName(), 0,12) == "DropDownList" and strlen(button:GetParent():GetName()) == 13 ) then
				anchorFrame = button;
			else
				anchorFrame = button:GetParent();
			end
			point = "TOPLEFT";
			relativePoint = "TOPRIGHT";
			listFrame:SetPoint(point, anchorFrame, relativePoint, 0, 0);
		end

		if dropDownFrame.hideBackdrops then
			_G[listFrameName.."Backdrop"]:Hide();
			_G[listFrameName.."MenuBackdrop"]:Hide();
		else
			-- Change list box appearance depending on display mode
			local displayMode = overrideDisplayMode or (dropDownFrame and dropDownFrame.displayMode) or nil;
			if ( displayMode == "MENU" ) then
				_G[listFrameName.."Backdrop"]:Hide();
				_G[listFrameName.."MenuBackdrop"]:Show();
			else
				_G[listFrameName.."Backdrop"]:Show();
				_G[listFrameName.."MenuBackdrop"]:Hide();
			end
		end

		UIDropDownMenu_Initialize(dropDownFrame, dropDownFrame.initialize, nil, level, menuList);
		-- If no items in the drop down don't show it
		if ( listFrame.numButtons == 0 ) then
			return;
		end

		listFrame.onShow = dropDownFrame.listFrameOnShow;

		-- Check to see if the dropdownlist is off the screen, if it is anchor it to the top of the dropdown button
		listFrame:Show();
		-- Hack since GetCenter() is returning coords relative to 1024x768
		local x, y = listFrame:GetCenter();
		-- Hack will fix this in next revision of dropdowns
		if ( not x or not y ) then
			listFrame:Hide();
			return;
		end

		listFrame.onHide = dropDownFrame.onHide;

		-- Set the listframe frameStrata
		if dropDownFrame.listFrameStrata then
			listFrame.baseFrameStrata = listFrame:GetFrameStrata();
			listFrame:SetFrameStrata(dropDownFrame.listFrameStrata);
		end

		--  We just move level 1 enough to keep it on the screen. We don't necessarily change the anchors.
		if ( level == 1 ) then
			local offLeft = listFrame:GetLeft()/uiScale;
			local offRight = (GetScreenWidth() - listFrame:GetRight())/uiScale;
			local offTop = (GetScreenHeight() - listFrame:GetTop())/uiScale;
			local offBottom = listFrame:GetBottom()/uiScale;

			local xAddOffset, yAddOffset = 0, 0;
			if ( offLeft < 0 ) then
				xAddOffset = -offLeft;
			elseif ( offRight < 0 ) then
				xAddOffset = offRight;
			end

			if ( offTop < 0 ) then
				yAddOffset = offTop;
			elseif ( offBottom < 0 ) then
				yAddOffset = -offBottom;
			end

			listFrame:ClearAllPoints();
			if ( anchorName == "cursor" ) then
				listFrame:SetPoint(point, relativeTo, relativePoint, xOffset + xAddOffset, yOffset + yAddOffset);
			else
				listFrame:SetPoint(point, relativeTo, relativePoint, xOffset + xAddOffset, yOffset + yAddOffset);
			end
		else
			-- Determine whether the menu is off the screen or not
			local offscreenY, offscreenX;
			if ( (y - listFrame:GetHeight()/2) < 0 ) then
				offscreenY = 1;
			end
			if ( listFrame:GetRight() > GetScreenWidth() ) then
				offscreenX = 1;
			end
			if ( offscreenY and offscreenX ) then
				point = gsub(point, "TOP(.*)", "BOTTOM%1");
				point = gsub(point, "(.*)LEFT", "%1RIGHT");
				relativePoint = gsub(relativePoint, "TOP(.*)", "BOTTOM%1");
				relativePoint = gsub(relativePoint, "(.*)RIGHT", "%1LEFT");
				xOffset = -11;
				yOffset = -14;
			elseif ( offscreenY ) then
				point = gsub(point, "TOP(.*)", "BOTTOM%1");
				relativePoint = gsub(relativePoint, "TOP(.*)", "BOTTOM%1");
				xOffset = 0;
				yOffset = -14;
			elseif ( offscreenX ) then
				point = gsub(point, "(.*)LEFT", "%1RIGHT");
				relativePoint = gsub(relativePoint, "(.*)RIGHT", "%1LEFT");
				xOffset = -11;
				yOffset = 14;
			else
				xOffset = 0;
				yOffset = 14;
			end

			listFrame:ClearAllPoints();
			listFrame.parentLevel = tonumber(strmatch(anchorFrame:GetName(), "DropDownList(%d+)"));
			listFrame.parentID = anchorFrame:GetID();
			listFrame:SetPoint(point, anchorFrame, relativePoint, xOffset, yOffset);
		end
	end
end

function CloseDropDownMenus(level)
	if ( not level ) then
		level = 1;
	end
	for i=level, UIDROPDOWNMENU_MAXLEVELS do
		_G["DropDownList"..i]:Hide();
	end
end

local function UIDropDownMenu_ContainsMouse()
	for i = 1, UIDROPDOWNMENU_MAXLEVELS do
		local dropdown = _G["DropDownList"..i];
		if dropdown:IsShown() and dropdown:IsMouseOver() then
			return true;
		end
	end

	return false;
end

function UIDropDownMenu_HandleGlobalMouseEvent(button, event)
	if event == "GLOBAL_MOUSE_DOWN" and (button == "LeftButton" or button == "RightButton") then
		if not UIDropDownMenu_ContainsMouse() then
			CloseDropDownMenus();
		end
	end
end

function UIDropDownMenu_OnShow(self)
	if ( self.onShow ) then
		self.onShow();
		self.onShow = nil;
	end

	for i=1, UIDROPDOWNMENU_MAXBUTTONS do
		if (not self.noResize) then
			_G[self:GetName().."Button"..i]:SetWidth(self.maxWidth);
		end
	end

	if (not self.noResize) then
		self:SetWidth(self.maxWidth+25);
	end

	if ( self:GetID() > 1 ) then
		self.parent = _G["DropDownList"..(self:GetID() - 1)];
	end
	EventRegistry:TriggerEvent("UIDropDownMenu.Show", self);
end

function UIDropDownMenu_OnHide(self)
	local id = self:GetID()
	if ( self.onHide ) then
		self.onHide(id+1);
		self.onHide = nil;
	end
	if ( self.baseFrameStrata ) then
		self:SetFrameStrata(self.baseFrameStrata);
		self.baseFrameStrata = nil;
	end
	CloseDropDownMenus(id+1);
	OPEN_DROPDOWNMENUS[id] = nil;
	if (id == 1) then
		UIDROPDOWNMENU_OPEN_MENU = nil;
	end
	UIDropDownMenu_ClearCustomFrames(self);
	EventRegistry:TriggerEvent("UIDropDownMenu.Hide");
end

function UIDropDownMenu_ClearCustomFrames(self)
	if self.customFrames then
		for index, frame in ipairs(self.customFrames) do
			frame:Hide();
		end

		self.customFrames = nil;
	end
end

function UIDropDownMenu_MatchTextWidth(frame, minWidth, maxWidth)
	local frameName = frame:GetName();
	local newWidth = GetChild(frame, frameName, "Text"):GetUnboundedStringWidth() + UIDROPDOWNMENU_DEFAULT_WIDTH_PADDING;

	if minWidth or maxWidth then
		newWidth = Clamp(newWidth, minWidth or newWidth, maxWidth or newWidth);
	end

	UIDropDownMenu_SetWidth(frame, newWidth);
end

function UIDropDownMenu_SetWidth(frame, width, padding)
	local frameName = frame:GetName();
	GetChild(frame, frameName, "Middle"):SetWidth(width);
	if ( padding ) then
		frame:SetWidth(width + padding);
	else
		frame:SetWidth(width + UIDROPDOWNMENU_DEFAULT_WIDTH_PADDING + UIDROPDOWNMENU_DEFAULT_WIDTH_PADDING);
	end
	if ( padding ) then
		GetChild(frame, frameName, "Text"):SetWidth(width);
	else
		GetChild(frame, frameName, "Text"):SetWidth(width - UIDROPDOWNMENU_DEFAULT_WIDTH_PADDING);
	end
	frame.noResize = 1;
end

function UIDropDownMenu_SetButtonWidth(frame, width)
	local frameName = frame:GetName();
	if ( width == "TEXT" ) then
		width = GetChild(frame, frameName, "Text"):GetWidth();
	end

	GetChild(frame, frameName, "Button"):SetWidth(width);
	frame.noResize = 1;
end

function UIDropDownMenu_SetText(frame, text)
	local frameName = frame:GetName();
	GetChild(frame, frameName, "Text"):SetText(text);
end

function UIDropDownMenu_GetText(frame)
	local frameName = frame:GetName();
	return GetChild(frame, frameName, "Text"):GetText();
end

function UIDropDownMenu_ClearAll(frame)
	-- Previous code refreshed the menu quite often and was a performance bottleneck
	frame.selectedID = nil;
	frame.selectedName = nil;
	frame.selectedValue = nil;
	UIDropDownMenu_SetText(frame, "");

	local button, checkImage, uncheckImage;
	for i=1, UIDROPDOWNMENU_MAXBUTTONS do
		button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i];
		button:UnlockHighlight();

		checkImage = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i.."Check"];
		checkImage:Hide();
		uncheckImage = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i.."UnCheck"];
		uncheckImage:Hide();
	end
end

function UIDropDownMenu_JustifyText(frame, justification, customXOffset, customYOffset)
	local frameName = frame:GetName();
	local text = GetChild(frame, frameName, "Text");
	text:ClearAllPoints();
	if ( justification == "LEFT" ) then
		text:SetPoint("LEFT", GetChild(frame, frameName, "Left"), "LEFT", customXOffset or 27, customYOffset or 2);
		text:SetJustifyH("LEFT");
	elseif ( justification == "RIGHT" ) then
		text:SetPoint("RIGHT", GetChild(frame, frameName, "Right"), "RIGHT", customXOffset or -43, customYOffset or 2);
		text:SetJustifyH("RIGHT");
	elseif ( justification == "CENTER" ) then
		text:SetPoint("CENTER", GetChild(frame, frameName, "Middle"), "CENTER", customXOffset or -5, customYOffset or 2);
		text:SetJustifyH("CENTER");
	end
end

function UIDropDownMenu_SetAnchor(dropdown, xOffset, yOffset, point, relativeTo, relativePoint)
	dropdown.xOffset = xOffset;
	dropdown.yOffset = yOffset;
	dropdown.point = point;
	dropdown.relativeTo = relativeTo;
	dropdown.relativePoint = relativePoint;
end

function UIDropDownMenu_GetCurrentDropDown()
	if ( UIDROPDOWNMENU_OPEN_MENU ) then
		return UIDROPDOWNMENU_OPEN_MENU;
	elseif ( UIDROPDOWNMENU_INIT_MENU ) then
		return UIDROPDOWNMENU_INIT_MENU;
	end
end

function UIDropDownMenuButton_GetChecked(self)
	return _G[self:GetName().."Check"]:IsShown();
end

function UIDropDownMenuButton_GetName(self)
	return _G[self:GetName().."NormalText"]:GetText();
end

function UIDropDownMenuButton_OpenColorPicker(self, button)
	CloseMenus();
	if ( not button ) then
		button = self;
	end
	UIDROPDOWNMENU_MENU_VALUE = button.value;
	ColorPickerFrame:SetupColorPickerAndShow(button);
end

function UIDropDownMenu_DisableButton(level, id)
	UIDropDownMenu_SetDropdownButtonEnabled(_G["DropDownList"..level.."Button"..id], false);
end

function UIDropDownMenu_EnableButton(level, id)
	UIDropDownMenu_SetDropdownButtonEnabled(_G["DropDownList"..level.."Button"..id], true);
end

function UIDropDownMenu_SetDropdownButtonEnabled(button, enabled)
	if enabled then
		button:Enable();
	else
		button:Disable();
	end
end

function UIDropDownMenu_SetButtonText(level, id, text, colorCode)
	local button = _G["DropDownList"..level.."Button"..id];
	if ( colorCode) then
		button:SetText(colorCode..text.."|r");
	else
		button:SetText(text);
	end
end

function UIDropDownMenu_SetButtonNotClickable(level, id)
	_G["DropDownList"..level.."Button"..id]:SetDisabledFontObject(GameFontHighlightSmallLeft);
end

function UIDropDownMenu_SetButtonClickable(level, id)
	_G["DropDownList"..level.."Button"..id]:SetDisabledFontObject(GameFontDisableSmallLeft);
end

function UIDropDownMenu_SetDropDownEnabled(dropDown, enabled, disabledtooltip)
	if enabled then
		UIDropDownMenu_EnableDropDown(dropDown);
	else
		UIDropDownMenu_DisableDropDown(dropDown, disabledtooltip);
	end
end

function UIDropDownMenu_DisableDropDown(dropDown, disabledtooltip)
	UIDropDownMenu_SetDropDownEnabled(dropDown, false, disabledtooltip);
end

function UIDropDownMenu_EnableDropDown(dropDown)
	UIDropDownMenu_SetDropDownEnabled(dropDown, true);
end

function UIDropDownMenu_SetDropDownEnabled(dropDown, enabled, disabledTooltip)
	local dropDownName = dropDown:GetName();
	local label = GetChild(dropDown, dropDownName, "Label");
	if label then
		label:SetVertexColor((enabled and NORMAL_FONT_COLOR or GRAY_FONT_COLOR):GetRGB());
	end

	local icon = GetChild(dropDown, dropDownName, "Icon");
	if icon then
		icon:SetVertexColor((enabled and HIGHLIGHT_FONT_COLOR or GRAY_FONT_COLOR):GetRGB());
	end

	local text = GetChild(dropDown, dropDownName, "Text");
	if text then
		text:SetVertexColor((enabled and HIGHLIGHT_FONT_COLOR or GRAY_FONT_COLOR):GetRGB());
	end

	local button = GetChild(dropDown, dropDownName, "Button");
	if button then
		button:SetEnabled(enabled);

		-- Clear any previously set disabledTooltip (it will be reset below if needed).
		if button:GetMotionScriptsWhileDisabled() then
			button:SetMotionScriptsWhileDisabled(false);
			button:SetScript("OnEnter", nil);
			button:SetScript("OnLeave", nil);
		end
	end

	if enabled then
		dropDown.isDisabled = nil;
	else
		dropDown.isDisabled = 1;

		if button then
			if disabledTooltip then
				button:SetMotionScriptsWhileDisabled(true);
				button:SetScript("OnEnter", function()
					GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
					GameTooltip_AddErrorLine(GameTooltip, disabledTooltip);
					GameTooltip:Show();
				end);

				button:SetScript("OnLeave", GameTooltip_Hide);
			end
		end
	end
end

function UIDropDownMenu_IsEnabled(dropDown)
	return not dropDown.isDisabled;
end

function UIDropDownMenu_GetValue(id)
	--Only works if the dropdown has just been initialized, lame, I know =(
	local button = _G["DropDownList1Button"..id];
	if ( button ) then
		return _G["DropDownList1Button"..id].value;
	else
		return nil;
	end
end
