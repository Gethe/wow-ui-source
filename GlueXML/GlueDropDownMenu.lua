GLUEDROPDOWNMENU_MAXLEVELS = 3;
GLUEDROPDOWNMENU_BUTTON_HEIGHT = 16;
GLUEDROPDOWNMENU_BORDER_HEIGHT = 15;
-- The current open menu
GLUEDROPDOWNMENU_OPEN_MENU = nil;
-- The current menu being initialized
GLUEDROPDOWNMENU_INIT_MENU = nil;
-- Current level shown of the open menu
GLUEDROPDOWNMENU_MENU_LEVEL = 1;
-- Current value of the open menu
GLUEDROPDOWNMENU_MENU_VALUE = nil;
-- Time to wait to hide the menu
GLUEDROPDOWNMENU_SHOW_TIME = 2;

function GlueDropDownMenu_Initialize(frame, initFunction, displayMode, level)
	if ( frame:GetName() ~= GLUEDROPDOWNMENU_OPEN_MENU ) then
		GLUEDROPDOWNMENU_MENU_LEVEL = 1;
	end

	-- Set the frame that's being intialized
	GLUEDROPDOWNMENU_INIT_MENU = frame:GetName();

	-- Hide all the buttons
	local button, dropDownList;
	for i = 1, GLUEDROPDOWNMENU_MAXLEVELS, 1 do
		dropDownList = _G["DropDownList"..i];
		if ( i >= GLUEDROPDOWNMENU_MENU_LEVEL or frame:GetName() ~= GLUEDROPDOWNMENU_OPEN_MENU ) then
			dropDownList.numButtons = 0;
			dropDownList.maxWidth = 0;
			for j=1, dropDownList.maxButtons, 1 do
				button = _G["DropDownList"..i.."Button"..j];
				button:Hide();
			end
		end
	end
	frame:SetHeight(GLUEDROPDOWNMENU_BUTTON_HEIGHT * 2);
	
	-- Set the initialize function and call it.  The initFunction populates the dropdown list.
	if ( initFunction ) then
		frame.initialize = initFunction;
		initFunction(frame, level);
	end

	--master frame dcw
	if(level == nil) then
		level = 1;
	end
	_G["DropDownList"..level].dropdown = frame;

	-- Change appearance based on the displayMode
	if ( displayMode == "MENU" ) then
		_G[frame:GetName().."Left"]:Hide();
		_G[frame:GetName().."Middle"]:Hide();
		_G[frame:GetName().."Right"]:Hide();
		_G[frame:GetName().."ButtonNormalTexture"]:SetTexture("");
		_G[frame:GetName().."ButtonDisabledTexture"]:SetTexture("");
		_G[frame:GetName().."ButtonPushedTexture"]:SetTexture("");
		_G[frame:GetName().."ButtonHighlightTexture"]:SetTexture("");
		_G[frame:GetName().."Button"]:ClearAllPoints();
		_G[frame:GetName().."Button"]:SetPoint("LEFT", frame:GetName().."Text", "LEFT", -9, 0);
		_G[frame:GetName().."Button"]:SetPoint("RIGHT", frame:GetName().."Text", "RIGHT", 6, 0);
		frame.displayMode = "MENU";
	end

end

-- If dropdown is visible then see if its timer has expired, if so hide the frame
function GlueDropDownMenu_OnUpdate(self, elapsed)
	if ( not self.showTimer or not self.isCounting ) then
		return;
	elseif ( self.showTimer < 0 ) then
		self:Hide();
		self.showTimer = nil;
		self.isCounting = nil;
	else
		self.showTimer = self.showTimer - elapsed;
	end
end

-- Start the countdown on a frame
function GlueDropDownMenu_StartCounting(frame)
	if ( frame.parent ) then
		GlueDropDownMenu_StartCounting(frame.parent);
	else
		frame.showTimer = GLUEDROPDOWNMENU_SHOW_TIME;
		frame.isCounting = 1;
	end
end

-- Stop the countdown on a frame
function GlueDropDownMenu_StopCounting(frame)
	if ( frame.parent ) then
		GlueDropDownMenu_StopCounting(frame.parent);
	else
		frame.isCounting = nil;
	end
end

--[[
List of button attributes
======================================================
info.text = [STRING]  --  The text of the button
info.value = [ANYTHING]  --  The value that GLUEDROPDOWNMENU_MENU_VALUE is set to when the button is clicked
info.func = [function()]  --  The function that is called when you click the button
info.checked = [nil, 1]  --  Check the button
info.isTitle = [nil, 1]  --  If it's a title the button is disabled and the font color is set to yellow
info.disabled = [nil, 1]  --  Disable the button and show an invisible button that still traps the mouseover event so menu doesn't time out
info.hasArrow = [nil, 1]  --  Show the expand arrow for multilevel menus
info.hasColorSwatch = [nil, 1]  --  Show color swatch or not, for color selection
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
info.justifyH = [nil, "CENTER"] -- Justify button text
info.isNotRadio = [nil, true]  --  Check the button uses radial image if false check box image if true

]]--

local GlueDropDownMenu_ButtonInfo = {};

function GlueDropDownMenu_CreateInfo()
	-- Reuse the same table to prevent memory churn
	local info = GlueDropDownMenu_ButtonInfo;

	for k,v in pairs(info) do
		info[k] = nil;
	end

	return info;
end

function GlueDropDownMenu_AddButton(info, level)
	--[[
	Might to uncomment this if there are performance issues 
	if ( not GLUEDROPDOWNMENU_OPEN_MENU ) then
		return;
	end
	]]
	if ( not level ) then
		level = 1;
	end
	
	local listFrame = _G["DropDownList"..level];
	local listFrameName = listFrame:GetName();
	local index = listFrame.numButtons + 1;
	local width;

	-- If too many levels error out
	if ( level > GLUEDROPDOWNMENU_MAXLEVELS ) then
		message("Too many levels in GlueDropDownMenu: "..GLUEDROPDOWNMENU_OPEN_MENU);
		return;
	end

	-- If not enough buttons then create one!
	if ( index > listFrame.maxButtons ) then
		CreateFrame("BUTTON", listFrameName .. "Button" .. index, listFrame, "GlueDropDownMenuButtonTemplate"):SetID(index);
		listFrame.maxButtons = index;
	end
	
	-- Set the number of buttons in the listframe
	listFrame.numButtons = index;
	
	local button = _G[listFrameName.."Button"..index];
	local normalText = _G[button:GetName().."NormalText"];
	local icon = _G[button:GetName().."Icon"];
	-- This button is used to capture the mouse OnEnter/OnLeave events if the dropdown button is disabled, since a disabled button doesn't receive any events
	-- This is used specifically for drop down menu time outs
	local invisibleButton = _G[button:GetName().."InvisibleButton"];
	
	-- Default settings
	button:SetDisabledFontObject(GlueFontDisableSmallLeft);
	invisibleButton:Hide();
	button:Enable();
	
	-- If not clickable then disable the button and set it white
	if ( info.notClickable ) then
		info.disabled = 1;
		button:SetDisabledFontObject(GlueFontHighlightSmallLeft);
	end

	-- Set the text color and disable it if its a title
	if ( info.isTitle ) then
		info.disabled = 1;
		button:SetDisabledFontObject(GlueFontNormalSmallLeft);
	end
	
	-- Disable the button if disabled and turn off the colorCode
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
		if ( info.colorCode ) then
			button:SetText(info.colorCode..info.text.."|r");
		else
			button:SetText(info.text);
		end
		-- Determine the maximum width of a button
		width = normalText:GetWidth() + 60;
		-- Add padding if has and expand arrow or color swatch
		if ( info.hasArrow or info.hasColorSwatch ) then
			width = width + 50 - 30;
		end
		if ( info.notCheckable ) then
			width = width - 30;
		end
		-- Set icon
		if ( info.icon ) then
			icon:SetSize(16,16);
			icon:SetTexture(info.icon);
			icon:ClearAllPoints();
			icon:SetPoint("RIGHT");

			if ( info.iconInfo.tCoordLeft ) then
				icon:SetTexCoord(info.iconInfo.tCoordLeft, info.iconInfo.tCoordRight, info.iconInfo.tCoordTop, info.iconInfo.tCoordBottom);
			else
				icon:SetTexCoord(0, 1, 0, 1);
			end
			icon:Show();
			-- Add padding for the icon
			width = width + 10;
		else
			icon:Hide();
		end
		if ( width > listFrame.maxWidth ) then
			listFrame.maxWidth = width;
		end
		-- Check to see if there is a replacement font
		if ( info.fontObject ) then
			button:SetNormalFontObject(info.fontObject);
			button:SetHighlightFontObject(info.fontObject);
		else
			button:SetNormalFontObject(GlueFontHighlightSmallLeft);
			button:SetHighlightFontObject(GlueFontHighlightSmallLeft);
		end
	else
		button:SetText("");
		icon:Hide();
	end
	
	button.iconOnly = nil;
	button.icon = nil;
	button.iconInfo = nil;
	if (info.iconOnly and info.icon) then
		button.iconOnly = true;
		button.icon = info.icon;
		button.iconInfo = info.iconInfo;
		GlueDropDownMenu_SetIconImage(icon, info.icon, info.iconInfo);
		icon:ClearAllPoints();
		icon:SetPoint("LEFT");

		-- Add padding if has and expand arrow or color swatch
		width = icon:GetWidth();
		if ( info.hasArrow or info.hasColorSwatch ) then
			width = width + 50 - 30;
		end
		if ( info.notCheckable ) then
			width = width - 30;
		end
		if ( width > listFrame.maxWidth ) then
			listFrame.maxWidth = width;
		end
	end

	-- Pass through attributes
	button.func = info.func;
	button.owner = info.owner;
	button.hasOpacity = info.hasOpacity;
	button.opacity = info.opacity;
	button.opacityFunc = info.opacityFunc;
	button.cancelFunc = info.cancelFunc;
	button.swatchFunc = info.swatchFunc;
	button.keepShownOnClick = info.keepShownOnClick;
	button.tooltipTitle = info.tooltipTitle;
	button.tooltipText = info.tooltipText;

	if ( info.value ) then
		button.value = info.value;
	elseif ( info.text ) then
		button.value = info.text;
	else
		button.value = nil;
	end
	
	-- Show the expand arrow if it has one
	if ( info.hasArrow ) then
		_G[listFrameName.."Button"..index.."ExpandArrow"]:Show();
	else
		_G[listFrameName.."Button"..index.."ExpandArrow"]:Hide();
	end
	button.hasArrow = info.hasArrow;
	
	-- If not checkable move everything over to the left to fill in the gap where the check would be
	local xPos = 5;
	local yPos = -((button:GetID() - 1) * GLUEDROPDOWNMENU_BUTTON_HEIGHT) - GLUEDROPDOWNMENU_BORDER_HEIGHT;
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
		displayInfo:SetPoint("LEFT", button, "LEFT", 27, 0);
	end

	-- Adjust offset if displayMode is menu
	local frame = _G[GLUEDROPDOWNMENU_OPEN_MENU];
	if ( frame and frame.displayMode == "MENU" ) then
		if ( not info.notCheckable ) then
			xPos = xPos - 6;
		end
	end
	
	-- If no open frame then set the frame to the currently initialized frame
	if ( not frame ) then
		frame = _G[GLUEDROPDOWNMENU_INIT_MENU];
	end

	button:SetPoint("TOPLEFT", button:GetParent(), "TOPLEFT", xPos, yPos);

	-- See if button is selected by id or name
	if ( frame ) then
		if ( GlueDropDownMenu_GetSelectedName(frame) ) then
			if ( button:GetText() == GlueDropDownMenu_GetSelectedName(frame) ) then
				info.checked = 1;
			end
		elseif ( GlueDropDownMenu_GetSelectedID(frame) ) then
			if ( button:GetID() == GlueDropDownMenu_GetSelectedID(frame) ) then
				info.checked = 1;
			end
		elseif ( GlueDropDownMenu_GetSelectedValue(frame) ) then
			if ( button.value == GlueDropDownMenu_GetSelectedValue(frame) ) then
				info.checked = 1;
			end
		end
	end

	
	if( not info.notCheckable )then
		if info.isNotRadio then
			_G[listFrameName.."Button"..index.."Check"]:SetTexCoord(0.0, 0.5, 0.0, 0.5);
			_G[listFrameName.."Button"..index.."UnCheck"]:SetTexCoord(0.5, 1.0, 0.0, 0.5);
		else
			_G[listFrameName.."Button"..index.."Check"]:SetTexCoord(0.0, 0.5, 0.5, 1.0);
			_G[listFrameName.."Button"..index.."UnCheck"]:SetTexCoord(0.5, 1.0, 0.5, 1.0);
		end
		
		
		-- Show the check if checked
		if ( info.checked ) then
			button:LockHighlight();
			_G[listFrameName.."Button"..index.."Check"]:Show();
			_G[listFrameName.."Button"..index.."UnCheck"]:Hide();
		else
			button:UnlockHighlight();
			_G[listFrameName.."Button"..index.."Check"]:Hide();
			_G[listFrameName.."Button"..index.."UnCheck"]:Show();
		end
	else
		_G[listFrameName.."Button"..index.."Check"]:Hide();
		_G[listFrameName.."Button"..index.."UnCheck"]:Hide();
	end
	button.checked = info.checked;

	-- If has a colorswatch, show it and vertex color it
	local colorSwatch = _G[listFrameName.."Button"..index.."ColorSwatch"];
	if ( info.hasColorSwatch ) then
		_G["DropDownList"..level.."Button"..index.."ColorSwatch".."NormalTexture"]:SetVertexColor(info.r, info.g, info.b);
		button.r = info.r;
		button.g = info.g;
		button.b = info.b;
		colorSwatch:Show();
	else
		colorSwatch:Hide();
	end

	-- Set the height of the listframe
	listFrame:SetHeight((index * GLUEDROPDOWNMENU_BUTTON_HEIGHT) + (GLUEDROPDOWNMENU_BORDER_HEIGHT * 2));

	button:Show();
end

function GlueDropDownMenu_Refresh(frame, useValue)
	local button, checked, checkImage, uncheckImage;
	local somethingChecked = nil; 
	-- Just redraws the existing menu

	local listFrame = _G["DropDownList"..GLUEDROPDOWNMENU_MENU_LEVEL];
	for i=1, listFrame.maxButtons do
		button = _G["DropDownList"..GLUEDROPDOWNMENU_MENU_LEVEL.."Button"..i];
		checked = nil;


		if(i <= listFrame.numButtons) then
			-- See if checked or not
			if ( GlueDropDownMenu_GetSelectedName(frame) ) then
				if ( button:GetText() == GlueDropDownMenu_GetSelectedName(frame) ) then
					checked = 1;
				end
			elseif ( GlueDropDownMenu_GetSelectedID(frame) ) then
				if ( button:GetID() == GlueDropDownMenu_GetSelectedID(frame) ) then
					checked = 1;
				end
			elseif ( GlueDropDownMenu_GetSelectedValue(frame) ) then
				if ( button.value == GlueDropDownMenu_GetSelectedValue(frame) ) then
					checked = 1;
				end
			end
		end

		
		if ( not button.notCheckable ) then	
			-- If checked show check image
			checkImage = _G["DropDownList"..GLUEDROPDOWNMENU_MENU_LEVEL.."Button"..i.."Check"];
			uncheckImage = _G["DropDownList"..GLUEDROPDOWNMENU_MENU_LEVEL.."Button"..i.."UnCheck"];	
			if ( checked ) then
				somethingChecked = true;
				local icon = _G[frame:GetName().."Icon"];
				if (button.iconOnly and icon and button.icon) then
					GlueDropDownMenu_SetIconImage(icon, button.icon, button.iconInfo);
				elseif ( useValue ) then
					GlueDropDownMenu_SetText(frame, button.value);
					icon:Hide();
				else
					GlueDropDownMenu_SetText(frame, button:GetText());
					icon:Hide();
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
	end
	if(somethingChecked == nil) then
		GlueDropDownMenu_SetText( frame, VIDEO_QUALITY_LABEL6 );
	end
end

function GlueDropDownMenu_SetIconImage(icon, texture, info)
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

function GlueDropDownMenu_SetSelectedName(frame, name, useValue)
	frame.selectedName = name;
	frame.selectedID = nil;
	frame.selectedValue = nil;
	GlueDropDownMenu_Refresh(frame, useValue);
end

function GlueDropDownMenu_SetSelectedValue(frame, value, useValue)
	-- useValue will set the value as the text, not the name
	frame.selectedName = nil;
	frame.selectedID = nil;
	frame.selectedValue = value;
	GlueDropDownMenu_Refresh(frame, useValue);
end

function GlueDropDownMenu_SetSelectedID(frame, id, useValue)
	frame.selectedID = id;
	frame.selectedName = nil;
	frame.selectedValue = nil;
	GlueDropDownMenu_Refresh(frame, useValue);
end

function GlueDropDownMenu_GetSelectedName(frame)
	return frame.selectedName;
end

function GlueDropDownMenu_GetSelectedID(frame)
	if ( frame.selectedID ) then
		return frame.selectedID;
	else
		-- If no explicit selectedID then try to send the id of a selected value or name
		local button;
		
		local listFrame = _G["DropDownList"..GLUEDROPDOWNMENU_MENU_LEVEL];
		for i=1, listFrame.maxButtons do
			button = _G["DropDownList"..GLUEDROPDOWNMENU_MENU_LEVEL.."Button"..i];
			-- See if checked or not
			if ( GlueDropDownMenu_GetSelectedName(frame) ) then
				if ( button:GetText() == GlueDropDownMenu_GetSelectedName(frame) ) then
					return i;
				end
			elseif ( GlueDropDownMenu_GetSelectedValue(frame) ) then
				if ( button.value == GlueDropDownMenu_GetSelectedValue(frame) ) then
					return i;
				end
			end
		end
	end
end

function GlueDropDownMenu_GetSelectedValue(frame)
	return frame.selectedValue;
end

function GlueDropDownMenuButton_OnClick(self)
	local func = self.func;
	if ( func ) then
		func(self);
	else
		return;
	end
	
	local checked = self.checked;
	if ( type (checked) == "function" ) then
		checked = checked(self);
	end

	if ( self.keepShownOnClick ) then
		if not self.notCheckable then
			if ( checked ) then
				_G[self:GetName().."Check"]:Hide();
				_G[self:GetName().."UnCheck"]:Show();
				checked = nil;
			else
				_G[self:GetName().."Check"]:Show();
				_G[self:GetName().."UnCheck"]:Hide();
				checked = 1;
			end
		end
	else
		self:GetParent():Hide();
	end
	PlaySound("UChatScrollButton");
end

function HideDropDownMenu(level)
	local listFrame = _G["DropDownList"..level];
	listFrame:Hide();
end

function ToggleDropDownMenu(self, level, value, dropDownFrame, anchorName, xOffset, yOffset)
	if ( not level ) then
		level = 1;
	end
	GLUEDROPDOWNMENU_MENU_LEVEL = level;
	GLUEDROPDOWNMENU_MENU_VALUE = value;
	local listFrame = _G["DropDownList"..level];
	local listFrameName = "DropDownList"..level;
	local tempFrame;
	local point, relativePoint, relativeTo;
	if ( not dropDownFrame ) then
		tempFrame = self:GetParent();
	else
		tempFrame = dropDownFrame;
	end
	if ( listFrame:IsShown() and (GLUEDROPDOWNMENU_OPEN_MENU == tempFrame:GetName()) ) then
		listFrame:Hide();
	else
		-- Set the dropdownframe scale
		local uiScale = 1.0;
		listFrame:SetScale(uiScale);
		
		-- Hide the listframe anyways since it is redrawn OnShow() 
		listFrame:Hide();
		
		-- Frame to anchor the dropdown menu to
		local anchorFrame;

		-- Display stuff
		-- Level specific stuff
		if ( level == 1 ) then
			if ( not dropDownFrame ) then
				dropDownFrame = self:GetParent();
			end
			GLUEDROPDOWNMENU_OPEN_MENU = dropDownFrame:GetName();
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
					relativeTo = GLUEDROPDOWNMENU_OPEN_MENU.."Left";
				end
				if ( dropDownFrame.relativePoint ) then
					relativePoint = dropDownFrame.relativePoint;
				end
			elseif ( anchorName == "cursor" ) then
				relativeTo = "UIParent";
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
				relativeTo = anchorName;
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
				dropDownFrame = _G[GLUEDROPDOWNMENU_OPEN_MENU];
			end
			listFrame:ClearAllPoints();
			-- If this is a dropdown button, not the arrow anchor it to itself
			if ( strsub(self:GetParent():GetName(), 0,12) == "DropDownList" and strlen(self:GetParent():GetName()) == 13 ) then
				anchorFrame = self:GetName();
			else
				anchorFrame = self:GetParent():GetName();
			end
			listFrame:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 0, 0);
		end
		
		-- Change list box appearance depending on display mode
		if ( dropDownFrame and dropDownFrame.displayMode == "MENU" ) then
			_G[listFrameName.."Backdrop"]:Hide();
			_G[listFrameName.."MenuBackdrop"]:Show();
		else
			_G[listFrameName.."Backdrop"]:Show();
			_G[listFrameName.."MenuBackdrop"]:Hide();
		end

		GlueDropDownMenu_Initialize((dropDownFrame or self), dropDownFrame.initialize, nil, level);
		-- If no items in the drop down don't show it
		if ( listFrame.numButtons == 0 ) then
			return;
		end

		-- Check to see if the dropdownlist is off the screen, if it is anchor it to the top of the dropdown button
		listFrame:Show();
		local x, y = listFrame:GetCenter();
		
		--  If level 1 can only go off the bottom of the screen
		if ( level == 1 ) then
			local anchorPoint = "TOPLEFT";
			
			listFrame:ClearAllPoints();
			if ( anchorName == "cursor" ) then
				listFrame:SetPoint(anchorPoint, relativeTo, "BOTTOMLEFT", xOffset, yOffset);
			else
				listFrame:SetPoint(anchorPoint, relativeTo, relativePoint, xOffset, yOffset);
			end
		else
			local anchorPoint, relativePoint, offsetX, offsetY;
			if ( offscreenY and offscreenX ) then
				anchorPoint = "BOTTOMRIGHT";
				relativePoint = "BOTTOMLEFT";
				offsetX = -11;
				offsetY = -14;
			elseif ( offscreenY ) then
				anchorPoint = "BOTTOMLEFT";
				relativePoint = "BOTTOMRIGHT";
				offsetX = 0;
				offsetY = -14;
			elseif ( offscreenX ) then
				anchorPoint = "TOPRIGHT";
				relativePoint = "TOPLEFT";
				offsetX = -11;
				offsetY = 14;
			else
				anchorPoint = "TOPLEFT";
				relativePoint = "TOPRIGHT";
				offsetX = 0;
				offsetY = 14;
			end
			
			listFrame:ClearAllPoints();
			listFrame:SetPoint(anchorPoint, anchorFrame, relativePoint, offsetX, offsetY);
		end
	end
end

function CloseDropDownMenus(level)
	if ( not level ) then
		level = 1;
	end
	for i=level, GLUEDROPDOWNMENU_MAXLEVELS do
		_G["DropDownList"..i]:Hide();
	end
end

function GlueDropDownMenu_SetWidth(frame, width)
	_G[frame:GetName().."Middle"]:SetWidth(width);
	frame:SetWidth(width + 25 + 25);
	_G[frame:GetName().."Text"]:SetWidth(width - 25);
	frame.noResize = 1;
end

function GlueDropDownMenu_SetButtonWidth(width, frame)
	if ( width == "TEXT" ) then
		width = _G[frame:GetName().."Text"]:GetWidth();
	end
	
	_G[frame:GetName().."Button"]:SetWidth(width);
	frame.noResize = 1;
end


function GlueDropDownMenu_SetText(frame, text)
	local filterText = _G[frame:GetName().."Text"];
	filterText:SetText(text);
end

function GlueDropDownMenu_GetText(frame)
	local filterText = _G[frame:GetName().."Text"];
	return filterText:GetText();
end

function GlueDropDownMenu_ClearAll(frame)
	-- Previous code refreshed the menu quite often and was a performance bottleneck
	frame.selectedID = nil;
	frame.selectedName = nil;
	frame.selectedValue = nil;
	GlueDropDownMenu_SetText(frame, "");

	local button, checkImage, uncheckImage;
	
	local listFrame = _G["DropDownList"..GLUEDROPDOWNMENU_MENU_LEVEL];
	for i=1, listFrame.maxButtons do
		button = _G["DropDownList"..GLUEDROPDOWNMENU_MENU_LEVEL.."Button"..i];
		button:UnlockHighlight();

		checkImage = _G["DropDownList"..GLUEDROPDOWNMENU_MENU_LEVEL.."Button"..i.."Check"];
		checkImage:Hide();
		uncheckImage = _G["DropDownList"..GLUEDROPDOWNMENU_MENU_LEVEL.."Button"..i.."UnCheck"];
		uncheckImage:Hide();
	end
end

function GlueDropDownMenu_JustifyText(justification, frame)
	local text = _G[frame:GetName().."Text"];
	text:ClearAllPoints();
	if ( justification == "LEFT" ) then
		text:SetPoint("LEFT", frame:GetName().."Left", "LEFT", 27, 2);
	elseif ( justification == "RIGHT" ) then
		text:SetPoint("RIGHT", frame:GetName().."Right", "RIGHT", -43, 2);
	elseif ( justification == "CENTER" ) then
		text:SetPoint("CENTER", frame:GetName().."Middle", "CENTER", -5, 2);
	end
end

function GlueDropDownMenu_SetAnchor(self, xOffset, yOffset, point, relativeTo, relativePoint)
	self.xOffset = xOffset;
	self.yOffset = yOffset;
	self.point = point;
	self.relativeTo = relativeTo;
	self.relativePoint = relativePoint;
end

function GlueDropDownMenu_GetCurrentDropDown(self)
	if ( GLUEDROPDOWNMENU_OPEN_MENU ) then
		return _G[GLUEDROPDOWNMENU_OPEN_MENU];
	end
	
	-- If no dropdown then use this
	return self;
end

function GlueDropDownMenuButton_GetChecked(self)
	return _G[self:GetName().."Check"]:IsShown();
end

function GlueDropDownMenuButton_GetName(self)
	return _G[self:GetName().."NormalText"]:GetText();
end

function GlueDropDownMenuButton_OpenColorPicker(self, button)
	CloseMenus();
	if ( not button ) then
		button = self;
	end
	GLUEDROPDOWNMENU_MENU_VALUE = button.value;
	ColorPickerFrame.func = button.swatchFunc;
	ColorPickerFrame.hasOpacity = button.hasOpacity;
	ColorPickerFrame.opacityFunc = button.opacityFunc;
	ColorPickerFrame.opacity = button.opacity;
	ColorPickerFrame:SetColorRGB(button.r, button.g, button.b);
	ColorPickerFrame.previousValues = {r = button.r, g = button.g, b = button.b, opacity = button.opacity};
	ColorPickerFrame.cancelFunc = button.cancelFunc;
	ShowUIPanel(ColorPickerFrame);
end

function GlueDropDownMenu_DisableButton(level, id)
	_G["DropDownList"..level.."Button"..id]:Disable();
end

function GlueDropDownMenu_EnableButton(level, id)
	_G["DropDownList"..level.."Button"..id]:Enable();
end

function GlueDropDownMenu_SetButtonText(level, id, text, colorCode)
	local button = _G["DropDownList"..level.."Button"..id];
	if ( colorCode ) then
		button:SetText(colorCode..text.."|r");
	else
		button:SetText(text);
	end
end

function GlueDropDownMenu_DisableDropDown(dropDown)
	local label = _G[dropDown:GetName().."Label"];
	if ( label ) then
		label:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	_G[dropDown:GetName().."Text"]:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	_G[dropDown:GetName().."Button"]:Disable();
	dropDown.isDisabled = 1;
end

function GlueDropDownMenu_EnableDropDown(dropDown)
	local label = _G[dropDown:GetName().."Label"];
	if ( label ) then
		label:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	_G[dropDown:GetName().."Text"]:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	_G[dropDown:GetName().."Button"]:Enable();
	dropDown.isDisabled = nil;
end
