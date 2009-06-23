
UIMENU_BUTTON_HEIGHT = 16;
UIMENU_BUTTON_WIDTH = 104;
UIMENU_BORDER_HEIGHT = 12;
UIMENU_BORDER_WIDTH = 12;

UIMENU_NUMBUTTONS = 32;
UIMENU_TIMEOUT = 2.0;

function UIMenu_Initialize(self)
	self.numButtons = 0;
	self.subMenu = "";
	local name = self:GetName();
	for i = 1, UIMENU_NUMBUTTONS, 1 do
		local button = _G[name.."Button"..i];
		button:SetWidth(UIMENU_BUTTON_WIDTH);
		button:SetHeight(UIMENU_BUTTON_HEIGHT);
		button:Hide();
		
		local shortcutString = _G[button:GetName().."ShortcutText"];
		shortcutString:Hide();
	end

	self:SetWidth(UIMENU_BUTTON_WIDTH + (UIMENU_BORDER_WIDTH * 2));
	self:SetHeight(UIMENU_BORDER_HEIGHT * 2);
end

function UIMenu_OnShow(self)
	self.timeleft = UIMENU_TIMEOUT;
	self.counting = 0;
end

function UIMenu_AddButton(self, text, shortcut, func, nested, value)
	local id = self.numButtons + 1;
	if ( id > UIMENU_NUMBUTTONS ) then
		message("Too many buttons in UIMenu: "..self:GetName());
		return;
	end

	self.numButtons = id;

	local button = _G[self:GetName().."Button"..id];
	if ( text ) then
		button:SetText(text);
	end
	button.func = func;
	button.nested = nested;
	button.value = value;
	button:Show();

	if ( shortcut ) then
		local shortcutString = _G[button:GetName().."ShortcutText"];
		shortcutString:SetText(shortcut);
		shortcutString:Show();
	end

	self:SetHeight((id * UIMENU_BUTTON_HEIGHT) + (UIMENU_BORDER_HEIGHT * 2));
end

function UIMenu_OnUpdate(self, elapsed)
	if ( self.counting == 1 ) then
		local timeleft = self.timeleft - elapsed;
		if ( timeleft <= 0 ) then
			self:Hide();
			return;
		end
		self.timeleft = timeleft;
	end
end

function UIMenuButton_OnLoad(self)
	self:SetPoint("TOP", self:GetParent(), "TOP", 0, -((self:GetID() - 1) * UIMENU_BUTTON_HEIGHT) - UIMENU_BORDER_HEIGHT);
end

function UIMenuButton_OnClick(self)
	local func = self.func;
	if ( func ) then
		func(self);
	end

	self:GetParent():Hide();
	PlaySound("UChatScrollButton");
end

function UIMenu_StartCounting(menu)
	menu.counting = 1;

	if ( menu.onlyAutoHideSelf ) then
		return;
	end
	local parentName = menu.parentMenu;
	if ( parentName ) then
		UIMenu_StartCounting(_G[parentName]);
	end
end

function UIMenu_StopCounting(menu)
	menu.counting = 0;
	menu.timeleft = UIMENU_TIMEOUT;

	local parentName = menu.parentMenu;
	if ( parentName ) then
		UIMenu_StopCounting(_G[parentName]);
	end
end

function UIMenuButton_OnEnter(self)
	local nested = self.nested;
	if ( nested ) then
		local menu = _G[nested];
		if ( not menu:IsShown() ) then
			local oldMenu = _G[self:GetParent().subMenu];
			if ( oldMenu ) then
				oldMenu:Hide();
			end

			self:GetParent().subMenu = nested;
			menu:ClearAllPoints();
			menu:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 10, -12);
			menu:Show();
			if ( menu:GetRight() and menu:GetRight() > GetScreenWidth() ) then
				-- flip the menu's anchor if it is running off the screen
				menu:ClearAllPoints();
				menu:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -10, -12);
			end
		end

		UIMenu_StopCounting(menu);
	else
		UIMenu_StopCounting(self:GetParent());
	end
end

function UIMenuButton_OnLeave(self)
	UIMenu_StartCounting(self:GetParent());
	
	local nested = self.nested;
	if ( nested ) then
		UIMenu_StartCounting(_G[nested]);
	end
end

function UIMenu_AutoSize(frame)
	if ( UIMenu_GetNumButtons(frame) == 0 ) then
		return;
	end
	local button, buttonName, shortcutText;
	local name = frame:GetName();
	local width;
	local maxWidth = 0;
	for i=1, UIMENU_NUMBUTTONS do
		buttonName = name.."Button"..i
		button = _G[buttonName];
		if ( button:IsShown() ) then
			width = button:GetTextWidth();
			shortcutText = _G[buttonName.."ShortcutText"];
			if ( shortcutText:GetText() ~= "" ) then
				width = width + shortcutText:GetWidth();
			end
			-- Add padding
			width = width + 20;
			if ( width > maxWidth ) then
				maxWidth = width;
			end
		end
	end
	for i=1, UIMENU_NUMBUTTONS do
		_G[name.."Button"..i]:SetWidth(maxWidth);
	end
	frame:SetWidth(maxWidth + (UIMENU_BORDER_WIDTH * 2));
end

function UIMenu_FinishInitializing(frame)
	if ( UIMenu_GetNumButtons(frame) == 0 ) then
		return false;
	end
	UIMenu_AutoSize(frame);
	return true;
end

function UIMenu_GetNumButtons(frame)
	if ( not frame.numButtons ) then
		return 0;
	end
	return frame.numButtons;
end
