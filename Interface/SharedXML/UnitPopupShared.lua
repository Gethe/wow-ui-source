UnitPopupManager = { };
UnitPopupMenus = { };
function UnitPopupManager:CheckAddSubsection(dropdownMenu, info, menuLevel, currentButton, index, previousButton, menuButtons)
	local hasButtonsThatStillNeedToShow = false;
	--Checking if there are any buttons that are supposed to show after this that are not a subsection title or separator
	for startIndex = index, #menuButtons do
		local button = menuButtons[startIndex];
		if(not button.isSubsectionSeparator and not button.isSubsectionTitle and button:CanShow()) then
			hasButtonsThatStillNeedToShow = true;
		end
	end

	--Add the separator  as long as the previous button wasn't a separator
	if hasButtonsThatStillNeedToShow and currentButton.isSubsectionSeparator and (not previousButton or (previousButton and not previousButton.isSubsectionSeparator)) then
		UIDropDownMenu_AddSeparator(menuLevel);
	end

	--Add the title as long as the previous button wasn't a title
	if (hasButtonsThatStillNeedToShow) and (currentButton.isSubsectionTitle and info) and (not previousButton or (previousButton and not previousButton.isSubsectionTitle)) then
		self:AddDropDownButton(info, dropdownMenu, currentButton, index, UIDROPDOWNMENU_MENU_LEVEL);
	end
end

function UnitPopupManager:ShowMenu(dropdownMenu, which, unit, name, userData)
	local server = nil;
	dropdownMenu.which = which;
	dropdownMenu.unit = unit;
	self.mostRecentDropdownMenu = nil;

	if ( unit ) then
		name, server = UnitNameUnmodified(unit);
	elseif ( name ) then
		local n, s = strmatch(name, "^([^-]+)-(.*)");
		if ( n ) then
			name = n;
			server = s;
		end
	end
	dropdownMenu.name = name;
	dropdownMenu.userData = userData;
	dropdownMenu.server = server;
	dropdownMenu.accountInfo = nil;
	dropdownMenu.accountInfo = UnitPopupSharedUtil.GetBNetAccountInfo();
	dropdownMenu.isMobile = UnitPopupSharedUtil.GetIsMobile();
	self.mostRecentDropdownMenu = dropdownMenu;
	local menu = self:GetMenu(which);
	local menuButtons = menu:GetButtons();
	self.currentlyShowingMenu = menu;
	if(not menuButtons) then
		return;
	end

	local count = 0;
	for index, buttonMixin in ipairs(menuButtons) do
		if( buttonMixin:CanShow() and not buttonMixin:IsCloseCommand() ) then
			count = count + 1;
		end
	end
	if ( count < 1 ) then
		return;
	end

	local info;
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		local nestedDropdownMenu = menuButtons[UIDROPDOWNMENU_MENU_VALUE];
		if(not nestedDropdownMenu) then
			return;
		end

		self.currentlyShowingMenu = nestedDropdownMenu;
		local nestedDropdownMenus = nestedDropdownMenu:GetButtons();
		if(not nestedDropdownMenus) then
			return;
		end

		OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL] = {which = dropdownMenu.which, unit = dropdownMenu.unit};
		local previousButton;
		for nestedIndex, button in ipairs(nestedDropdownMenus) do
			if( button:CanShow() ) then
				self:CheckAddSubsection(dropdownMenu, info, UIDROPDOWNMENU_MENU_LEVEL, button, nestedIndex, previousButton, nestedDropdownMenus);
				info = UIDropDownMenu_CreateInfo();
				info.owner = UIDROPDOWNMENU_MENU_VALUE;
				if (not button.isSubsection) then
					self:AddDropDownButton(info, dropdownMenu, button, nestedIndex, UIDROPDOWNMENU_MENU_LEVEL);
				end
				previousButton = button;
			end
		end
		return;
	end

	self:AddDropDownTitle(unit, name, userData);

	OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL] = {which = dropdownMenu.which, unit = dropdownMenu.unit};
	info = UIDropDownMenu_CreateInfo();
	local tooltipText;
	local previousButton = nil;
	for index, button in ipairs(menuButtons) do
		if( button:CanShow() ) then
			self:CheckAddSubsection(dropdownMenu, info, UIDROPDOWNMENU_MENU_LEVEL, button, index, previousButton, menuButtons);
			if (not button.isSubsection) then
				self:AddDropDownButton(info, dropdownMenu, button, index, UIDROPDOWNMENU_MENU_LEVEL);
			end

			previousButton = button;
		end
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function UnitPopupManager:AddDropDownTitle(unit, name, userData)
	if ( unit or name ) then
		local info = UIDropDownMenu_CreateInfo();

		local titleText = name;
		if not titleText and unit then
			titleText = UnitNameUnmodified(unit) or UnitName(unit);
		end

		info.text = titleText or UNKNOWN;
		info.isTitle = true;
		info.notCheckable = true;

		if not IsOnGlueScreen() then
			local class;
			if unit and UnitIsPlayer(unit) then
				class = select(2, UnitClass(unit));
			end

			if not class and userData and userData.guid then
				class = select(2, GetPlayerInfoByGUID(userData.guid));
			end
			if class then
				local colorCode = select(4, GetClassColor(class));
				info.disablecolor = "|c" .. colorCode;
			end
		end
		
		UIDropDownMenu_AddButton(info);
	end
end

function UnitPopupManager:AddDropDownButton(info, dropdownMenu, button, buttonIndex, level)
	if (not level) then
		level = 1;
	end
	local dropdownMenuButton = button;
	info.text = dropdownMenuButton:GetText();
	info.value = buttonIndex;
	info.owner = nil;
	info.func = function() dropdownMenuButton:OnClick() end;
	info.notCheckable = not dropdownMenuButton:IsCheckable();

	local color = dropdownMenuButton:GetColor();
	if ( color and color.r) then
		info.colorCode = string.format("|cFF%02x%02x%02x",  color.r*255,  color.g*255,  color.b*255);
	else
		info.colorCode = nil;
	end
	-- Icons
	local textureCoords = dropdownMenuButton:GetTextureCoords();
	if ( dropdownMenuButton:IsIconOnly() and textureCoords ) then
		info.iconOnly = 1;
		info.icon = dropdownMenuButton:GetIcon();
		info.iconInfo =  {
			tCoordLeft = textureCoords.tCoordLeft,
			tCoordRight = textureCoords.tCoordRight,
			tCoordTop = textureCoords.tCoordTop,
			tCoordBottom = textureCoords.tCoordBottom,
			tSizeX = textureCoords.tSizeX,
			tSizeY = textureCoords.tSizeY,
			tFitDropDownSizeX = textureCoords.tFitDropDownSizeX
		};
	else
		info.iconOnly = nil;
		info.icon = dropdownMenuButton:GetIcon();
		info.tCoordLeft = textureCoords.tCoordLeft;
		info.tCoordRight = textureCoords.tCoordRight;
		info.tCoordTop = textureCoords.tCoordTop;
		info.tCoordBottom = textureCoords.tCoordBottom;
		info.iconInfo = nil;
	end

	-- Checked conditions
	if (level == 1) then
		info.checked = nil;
	end

	info.checked = info.checked or dropdownMenuButton:IsChecked();
	info.hasArrow = dropdownMenuButton:IsNested();
	info.isNotRadio = dropdownMenuButton:IsNotRadio();
	info.isTitle = dropdownMenuButton:IsTitle();
	if(not info.isTitle) then
		if (level == 1) then
			info.disabled = nil;
		end
	end

	info.tooltipTitle = dropdownMenuButton:GetText();
	info.tooltipText = dropdownMenuButton:GetTooltipText();
	info.customFrame = dropdownMenuButton:GetCustomFrame();
	if info.customFrame then
		local guid = UnitPopupSharedUtil.GetGUID();
		local playerLocation = UnitPopupSharedUtil:TryCreatePlayerLocation(guid);
		local contextData = {
			guid = guid,
			playerLocation = playerLocation,
			voiceChannelID = dropdownMenu.voiceChannelID,
			voiceMemberID = dropdownMenu.voiceMemberID,
			voiceChannel = dropdownMenu.voiceChannel,
		};

		info.customFrame:SetContextData(contextData);
	end

	info.tooltipWhileDisabled = dropdownMenuButton:TooltipWhileDisabled();
	info.noTooltipWhileEnabled = dropdownMenuButton:NoTooltipWhileEnabled();
	info.tooltipOnButton = dropdownMenuButton:TooltipOnButton();
	info.tooltipInstruction = dropdownMenuButton:TooltipInstruction();
	info.tooltipWarning = dropdownMenuButton:TooltipWarning();
	info.hasArrow = dropdownMenuButton:HasArrow() or dropdownMenuButton:IsNested();
	info.disabled = not UnitPopupSharedUtil:IsEnabled(dropdownMenuButton);
	local addedButton = UIDropDownMenu_AddButton(info, level);
	button:SetCurrentButton(addedButton);
end

function UnitPopupManager:OnUpdate(elapsed)
	if ( not DropDownList1:IsShown() ) then
		return;
	end

	if ( not UnitPopup_HasVisibleMenu() ) then
		return;
	end
	for level, dropdownFrame in pairs(OPEN_DROPDOWNMENUS) do
		if(dropdownFrame) then
			local menu = self:GetMenu(dropdownFrame.which);
			local topLevelButtons = menu:GetButtons();
			local menuButtons;
			if(level == 2) then
				local nestedMenu = topLevelButtons[UIDROPDOWNMENU_MENU_VALUE];
				local nestedMenusButtons = nestedMenu and nestedMenu:GetButtons();
				menuButtons = nestedMenusButtons;
			else
				menuButtons =  topLevelButtons;
			end
			if (menuButtons) then
				for index, button in ipairs(menuButtons) do
					local shown = button:CanShow();
					if(shown) then
						if (not button.isSubsection) then
							local currentButton = button:GetCurrentButton();
							if currentButton then
								UIDropDownMenu_SetDropdownButtonEnabled(currentButton, UnitPopupSharedUtil:IsEnabled(button));
							end
						end
					end
				end
			end
		end
	end
end

function UnitPopupManager:GetMostRecentDropdownMenu()
	return self.mostRecentDropdownMenu;
end

function UnitPopupManager:GetMenu(which)
	return UnitPopupMenus[which];
end

function UnitPopupManager:RegisterMenu(which, menu)
	UnitPopupMenus[which] = menu;
end

local g_mostRecentPopupMenu;
function UnitPopup_OnUpdate (elapsed)
	UnitPopupManager:OnUpdate(elapsed);
end

function UnitPopup_ShowMenu (dropdownMenu, which, unit, name, userData)
	UnitPopupManager:ShowMenu(dropdownMenu, which, unit, name, userData);
end

function UnitPopup_HasVisibleMenu()
	return UnitPopupManager:GetMostRecentDropdownMenu() == UIDROPDOWNMENU_OPEN_MENU;
end
