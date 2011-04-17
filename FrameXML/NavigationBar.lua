
NAVBAR_WIDTHBUFFER = 20;


function NavBar_Initialize(self, template, homeData, homeButton, overflowButton)
	self.template = template;
	self.freeButtons = {};
	self.navList = {};
	self.widthBuffer = NAVBAR_WIDTHBUFFER;
	
	if not self.dropDown then
		self.dropDown = CreateFrame("Frame", self:GetName().."DropDown", self, "UIDropDownMenuTemplate");
		UIDropDownMenu_Initialize(self.dropDown, NavBar_DropDown_Initialize, "MENU");
	end
	
	if not homeButton then
		homeButton = CreateFrame("BUTTON", self:GetName().."HomeButton", self, self.template);
		homeButton:SetText(homeData.name or HOME);
		homeButton:SetWidth(homeButton.text:GetStringWidth()+30);
	end
	
	if not overflowButton then
		overflowButton = CreateFrame("BUTTON", self:GetName().."OverflowButton", self, self.template);
		overflowButton:SetWidth(30);
		
		-- LOOK AT CLICK
	end
	
	
	if not homeButton:GetScript("OnEnter") then
		homeButton:SetScript("OnEnter",	NavBar_ButtonOnEnter);
	end
	
	if not homeButton:GetScript("OnLeave") then
		homeButton:SetScript("OnLeave",	NavBar_ButtonOnLeave);
	end

	homeButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	overflowButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	overflowButton.listFunc = NavBar_ListOverFlowButtons;
	homeButton:ClearAllPoints();
	overflowButton:ClearAllPoints();
	homeButton:SetPoint("LEFT", self, "LEFT", 0, 0);
	overflowButton:SetPoint("LEFT", self, "LEFT", 0, 0);
	overflowButton:Hide();
		
	homeButton.oldClick = homeButton:GetScript("OnClick");
	overflowButton.oldClick = overflowButton:GetScript("OnClick");
	homeButton:SetScript("OnClick", NavBar_ButtonOnClick);
	overflowButton:SetScript("OnClick", NavBar_ToggleMenu);
	self.homeButton = homeButton;
	self.overflowButton = overflowButton;
	

	self.navList[#self.navList+1] = homeButton;
	homeButton.myclick = homeData.OnClick;
	homeButton.listFunc = homeData.listFunc;
	homeButton.data = homeData;
	homeButton:Show();
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
		navButton = CreateFrame("BUTTON", self:GetName().."Button"..(#self.navList+1), self, self.template);
		navButton.oldClick = navButton:GetScript("OnClick");
		navButton:SetScript("OnClick", NavBar_ButtonOnClick);
		navButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		
		if not navButton:GetScript("OnEnter") then
			navButton:SetScript("OnEnter",	NavBar_ButtonOnEnter);
		end
		
		if not navButton:GetScript("OnLeave") then
			navButton:SetScript("OnLeave", NavBar_ButtonOnLeave);
		end
	end
	

	--Set up the button
	local navParent = self.navList[#self.navList];
	self.navList[#self.navList+1] = navButton;
	
	navButton:SetText(buttonData.name);
	navButton:SetWidth(navButton.text:GetStringWidth()+30);
	
	navButton.myclick = buttonData.OnClick;
	navButton.listFunc = buttonData.listFunc;
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

function NavBar_ButtonOnClick(self, button)
	local parent = self:GetParent()
	CloseDropDownMenus();
	if button == "LeftButton" then
		NavBar_ClearTrailingButtons(parent.navList, parent.freeButtons, self);
		
		if self.oldClick then
			self:oldClick(button);
		end
		
		if self.myclick then
			self:myclick(button);
		end
	elseif button == "RightButton" then
		NavBar_ToggleMenu(self);
	end
end


function NavBar_ButtonOnEnter(self)
	if self.text:IsTruncated() then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		GameTooltip:AddLine(self.text:GetText(), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
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
		width = width + self.navList[i]:GetWidth();
		
		if width > maxWidth then
			self.navList[i]:Hide();
			collapsed = true;
			if not collapsedWidth then -- store the width for adding the offset button
				collapsedWidth = width;
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
	
		local lastButton = self.navList[lastShown];
		self.overflowButton:Show();
		xoffset = self.overflowButton.xoffset or 0
		lastButton:SetPoint("LEFT", self.overflowButton, "RIGHT", xoffset, 0);
		self.overflowButton:SetFrameLevel(lastButton:GetFrameLevel()+1);
	else
		self.overflowButton:Hide();
	end
end




function NavBar_ListOverFlowButtons(self, index)
	local navBar = self:GetParent();
	
	local button = navBar.navList[index];
	if not button:IsShown() then
		return button:GetText(), NavBar_OverflowItemOnClick;
	end
end


function NavBar_ToggleMenu(self)
	CloseDropDownMenus();
	self:GetParent().dropDown.buttonOwner = self;
	ToggleDropDownMenu(nil, nil, self:GetParent().dropDown, self:GetName(), 20, 3);
end


function NavBar_DropDown_Initialize(self, level)
	local navButton = self.buttonOwner;
	if not navButton or not navButton.listFunc then
		return;
	end

	
	local info = UIDropDownMenu_CreateInfo();
	local index = 1;
	local text, func = navButton:listFunc(index);
	while text do
		info.text = text;
		info.func = NavBar_DropDown_Click;
		info.arg1 = index;
		info.arg2 = func;
		info.owner = navButton;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info, level);
		
		index = index + 1;
		text, func = navButton:listFunc(index);
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
