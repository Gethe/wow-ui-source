
NAVBAR_WIDTHBUFFER = 20;


function NavBar_Initialize(self, template, homeData, homeButton, overflowButton)
	self.template = template;
	self.freeButtons = {};
	self.navList = {};
	self.widthBuffer = NAVBAR_WIDTHBUFFER;
	
	local name = self:GetName();

	if not self.dropDown then
		local dropDownName = name and name.."DropDown" or nil;
		self.dropDown = CreateFrame("Frame", dropDownName, self, "UIDropDownMenuTemplate");
		UIDropDownMenu_Initialize(self.dropDown, NavBar_DropDown_Initialize, "MENU");
	end
	
	if not homeButton then
		local homeButtonName = name and name.."HomeButton" or nil;
		homeButton = CreateFrame("BUTTON", homeButtonName, self, self.template);
		homeButton:SetWidth(homeButton.text:GetStringWidth()+30);
	end
	homeButton:SetText(homeData.name or HOME);

	if not overflowButton then
		local overflowButtonName = name and name.."OverflowButton" or nil;
		overflowButton = CreateFrame("DROPDOWNTOGGLEBUTTON", overflowButtonName, self, self.template);
		overflowButton:SetWidth(30);
		
		-- LOOK AT CLICK
	end
	
	
	if not homeButton:GetScript("OnEnter") then
		homeButton:SetScript("OnEnter",	NavBar_ButtonOnEnter);
	end
	
	if not homeButton:GetScript("OnLeave") then
		homeButton:SetScript("OnLeave",	NavBar_ButtonOnLeave);
	end

	if ( self.oldStyle ) then
		homeButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		overflowButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	else
		homeButton:RegisterForClicks("LeftButtonUp");
	end
	overflowButton.listFunc = NavBar_ListOverFlowButtons;
	homeButton:ClearAllPoints();
	overflowButton:ClearAllPoints();
	homeButton:SetPoint("LEFT", self, "LEFT", 0, 0);
	overflowButton:SetPoint("LEFT", self, "LEFT", 0, 0);
	overflowButton:Hide();
		
	homeButton.oldClick = homeButton:GetScript("OnClick");
	homeButton:SetScript("OnClick", NavBar_ButtonOnClick);
	overflowButton:SetScript("OnMouseDown", NavBar_ToggleMenu);
	self.homeButton = homeButton;
	self.overflowButton = overflowButton;
	

	self.navList[#self.navList+1] = homeButton;
	homeButton.myclick = homeData.OnClick;
	homeButton.listFunc = homeData.listFunc;
	homeButton.data = homeData;
	homeButton:Show();

	if Kiosk.IsEnabled() then
		self.KioskOverlay:Show();
	end
end



function NavBar_Reset(self)
	for index=2,#self.navList do
		self.navList[index]:Hide();
		tinsert(self.freeButtons, self.navList[index])
		self.navList[index] = nil;
	end
	NavBar_CheckLength(self);
end


function NavBar_AddButton(self, buttonData)
	local navButton = self.freeButtons[#self.freeButtons];
	if navButton then
		self.freeButtons[#self.freeButtons] = nil;
	end
	
	if not navButton then
		local name = self:GetName();
		local buttonName = name and name.."Button"..(#self.navList+1);
		navButton = CreateFrame("BUTTON", buttonName, self, self.template);
		navButton.oldClick = navButton:GetScript("OnClick");
		navButton:SetScript("OnClick", NavBar_ButtonOnClick);
		if ( self.oldStyle ) then
			navButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		else
			navButton:RegisterForClicks("LeftButtonUp");
		end
		
		if not navButton:GetScript("OnEnter") then
			navButton:SetScript("OnEnter",	NavBar_ButtonOnEnter);
		end
		
		if not navButton:GetScript("OnLeave") then
			navButton:SetScript("OnLeave", NavBar_ButtonOnLeave);
		end
		
		if ( self.textMaxWidth ) then
			navButton.text:SetWidth(self.textMaxWidth);
		end
	end
	

	--Set up the button
	local navParent = self.navList[#self.navList];
	self.navList[#self.navList+1] = navButton;
	navButton.navParent = navParent;

	navButton:SetText(buttonData.name);
	local buttonExtraWidth;
	if ( buttonData.listFunc and not self.oldStyle ) then
		navButton.MenuArrowButton:Show();
		buttonExtraWidth = 53;
	else
		navButton.MenuArrowButton:Hide();
		buttonExtraWidth = 30;
	end
	navButton:SetWidth(navButton.text:GetStringWidth() + buttonExtraWidth);
	navButton.myclick = buttonData.OnClick;
	navButton.listFunc = buttonData.listFunc;
	navButton.id = buttonData.id;
	navButton.data = buttonData;
	
	navButton:Show();
	NavBar_CheckLength(self);
end

function NavBar_ClearTrailingButtons(list, freeList, button)
	for index=#list,1,-1 do
		if not list[index] or button == list[index] then
			break
		end
		
		list[index]:Hide();
		tinsert(freeList, list[index])
		list[index] = nil;
	end
	NavBar_CheckLength(button:GetParent());
end

function NavBar_OpenTo(self, id)
	local button;
	local found = false;
	for i=1, #self.navList do
		button = self.navList[i];
		if (button.id and button.id == id) then
			found = true;
			break;
		end
	end
	
	if (found) then
		NavBar_ClearTrailingButtons(self.navList, self.freeButtons, button)
	end
end

function NavBar_ButtonOnClick(self, button)
	local parent = self:GetParent()
	if button == "LeftButton" then
		NavBar_ClearTrailingButtons(parent.navList, parent.freeButtons, self);
		
		if self.oldClick then
			self:oldClick(button);
		end
		
		if self.myclick then
			self:myclick(button);
		end
	end
end


function NavBar_ButtonOnEnter(self)
	if self.text:IsTruncated() then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		GameTooltip:AddLine(self.text:GetText(), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:Show();
	end
end

function NavBar_ButtonOnLeave(self)
	if self.text:IsTruncated() then
		GameTooltip:Hide();
	end
end



function NavBar_CheckLength(self)
	local width = 0;
	local collapsedWidth;
	local maxWidth = self:GetWidth() - self.widthBuffer;
	local xoffset;
	
	local lastShown;
	local collapsed = false;
	
	for i=#self.navList,1,-1 do
		local currentWidth = width;
		width = width + self.navList[i]:GetWidth();
		
		if width > maxWidth then
			self.navList[i]:Hide();
			collapsed = true;
			if not collapsedWidth then -- store the width for adding the offset button
				collapsedWidth = currentWidth;
			end
		else
			self.navList[i]:Show();
			if lastShown then
				local lastButton = self.navList[lastShown];
				xoffset = self.navList[i].xoffset or 0
				lastButton:SetPoint("LEFT", self.navList[i], "RIGHT", xoffset, 0);
				self.navList[i]:SetFrameLevel(lastButton:GetFrameLevel()+1);
			else
				self.navList[i]:SetFrameLevel(self:GetFrameLevel()+1);
			end
			lastShown = i;
		end
		
		if i<#self.navList then
			if self.navList[i].selected then
				self.navList[i].selected:Hide();
			end
			self.navList[i]:Enable();
		else
			if self.navList[i].selected then
				self.navList[i].selected:Show();
			end
			
			self.navList[i]:SetButtonState("NORMAL");
			self.navList[i]:Disable();
		end
	end
	
	if collapsed then
		if collapsedWidth + self.overflowButton:GetWidth() > maxWidth then
			--No room for the overflow button
			self.navList[lastShown]:Hide();
			lastShown = lastShown + 1;
		end
		
		self.overflowButton:Show();
			
		--There should only ever be no lastShown if a single button is longer than maxWidth by itself.
		if ( lastShown ) then
			local lastButton = self.navList[lastShown];	
			
			--There should only ever be no lastButton when there is lastShown if a single button is less than maxWidth
			--but it's width plus the width of the overflow button is longer than maxWidth.  In this case the single button
			--is hidden to make room for the overflowButton.
			if ( lastButton ) then
				xoffset = self.overflowButton.xoffset or 0
				lastButton:SetPoint("LEFT", self.overflowButton, "RIGHT", xoffset, 0);
				self.overflowButton:SetFrameLevel(lastButton:GetFrameLevel()+1);
			end
		end
	else
		self.overflowButton:Hide();
	end
end




function NavBar_ListOverFlowButtons(self)
	local navBar = self:GetParent();
	local list = { };
	for i, button in ipairs(navBar.navList) do
		if not button:IsShown() then
			local entry = { text = button:GetText(), id = i, func = NavBar_OverflowItemOnClick };
			tinsert(list, entry);
		else
			break;
		end
	end
	return list;
end


function NavBar_ToggleMenu(self, button)
	self:GetParent().dropDown.buttonOwner = self;
	ToggleDropDownMenu(nil, nil, self:GetParent().dropDown, self, 20, 3);
end


function NavBar_DropDown_Initialize(self, level)
	local navButton = self.buttonOwner;
	if not navButton or not navButton.listFunc then
		return;
	end

	local info = UIDropDownMenu_CreateInfo();
	info.func = NavBar_DropDown_Click;
	info.owner = navButton;
	info.notCheckable = true;
	local list = navButton:listFunc();
	if ( list ) then
		for i, entry in ipairs(list) do
			info.text = entry.text;
			info.arg1 = entry.id;
			info.arg2 = entry.func;
			UIDropDownMenu_AddButton(info, level);
		end
	end
end


function NavBar_DropDown_Click(self, index, func)
	local navButton = self.owner;
	local navBar = navButton:GetParent();
	
	if func ~= NavBar_OverflowItemOnClick then
		NavBar_ClearTrailingButtons(navBar.navList, navBar.freeButtons, navButton);
	end
	func(self, index, navBar);
end



function NavBar_OverflowItemOnClick(junk, index, navBar)
	local button = navBar.navList[index];
	if button then
		button:Click();
	end
end
