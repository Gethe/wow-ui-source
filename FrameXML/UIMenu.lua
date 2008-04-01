
UIMENU_BUTTON_HEIGHT = 16;
UIMENU_BUTTON_WIDTH = 104;
UIMENU_BORDER_HEIGHT = 12;
UIMENU_BORDER_WIDTH = 12;

UIMENU_NUMBUTTONS = 32;
UIMENU_TIMEOUT = 2.0;

function UIMenu_Initialize()
	this.numButtons = 0;
	this.subMenu = "";
	local name = this:GetName();
	for i = 1, UIMENU_NUMBUTTONS, 1 do
		local button = getglobal(name.."Button"..i);
		button:SetWidth(UIMENU_BUTTON_WIDTH);
		button:SetHeight(UIMENU_BUTTON_HEIGHT);
		button:Hide();
		
		local shortcutString = getglobal(button:GetName().."ShortcutText");
		shortcutString:Hide();
	end

	this:SetWidth(UIMENU_BUTTON_WIDTH + (UIMENU_BORDER_WIDTH * 2));
	this:SetHeight(UIMENU_BORDER_HEIGHT * 2);
end

function UIMenu_OnShow()
	this.timeleft = UIMENU_TIMEOUT;
	this.counting = 1;
end

function UIMenu_AddButton(text, shortcut, func, nested)
	local id = this.numButtons + 1;
	if ( id > UIMENU_NUMBUTTONS ) then
		_ERRORMESSAGE("Too many buttons in UIMenu: "..this:GetName());
		return;
	end

	this.numButtons = id;

	local button = getglobal(this:GetName().."Button"..id);
	if ( text ) then
		button:SetText(text);
	end
	button.func = func;
	button.nested = nested;
	button:Show();

	if ( shortcut ) then
		local shortcutString = getglobal(button:GetName().."ShortcutText");
		shortcutString:SetText(shortcut);
		shortcutString:Show();
	end

	this:SetHeight((id * UIMENU_BUTTON_HEIGHT) + (UIMENU_BORDER_HEIGHT * 2));
end

function UIMenu_OnUpdate(elapsed)
	if ( this.counting == 1 ) then
		local timeleft = this.timeleft - elapsed;
		if ( timeleft <= 0 ) then
			this:Hide();
			return;
		end
		this.timeleft = timeleft;
	end
end

function UIMenuButton_OnLoad()
	this:SetPoint("TOP", this:GetParent():GetName(), "TOP", 0, -((this:GetID() - 1) * UIMENU_BUTTON_HEIGHT) - UIMENU_BORDER_HEIGHT);
end

function UIMenuButton_OnClick()
	local func = this.func;
	if ( func ) then
		func();
	end

	this:GetParent():Hide();
	PlaySound("UChatScrollButton");
end

function UIMenu_StartCounting(menu)
	menu.counting = 1;

	local parentName = menu.parentMenu;
	if ( parentName ) then
		UIMenu_StartCounting(getglobal(parentName));
	end
end

function UIMenu_StopCounting(menu)
	menu.counting = 0;
	menu.timeleft = UIMENU_TIMEOUT;

	local parentName = menu.parentMenu;
	if ( parentName ) then
		UIMenu_StopCounting(getglobal(parentName));
	end
end

function UIMenuButton_OnEnter()
	local nested = this.nested;
	if ( nested ) then
		local menu = getglobal(nested);
		if ( not menu:IsVisible() ) then
			local oldMenu = getglobal(this:GetParent().subMenu);
			if ( oldMenu ) then
				oldMenu:Hide();
			end

			this:GetParent().subMenu = nested;
			menu:SetPoint("BOTTOMLEFT", this:GetName(), "BOTTOMRIGHT", 10, -12);
			menu:Show();
		end

		UIMenu_StopCounting(menu);
	else
		UIMenu_StopCounting(this:GetParent());
	end
end

function UIMenuButton_OnLeave()
	UIMenu_StartCounting(this:GetParent());
	
	local nested = this.nested;
	if ( nested ) then
		UIMenu_StartCounting(getglobal(nested));
	end
end
