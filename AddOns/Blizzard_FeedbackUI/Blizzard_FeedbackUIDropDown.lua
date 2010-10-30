
-- [[ Versioning ]]
if ( not BQAE_DropDown or (not BQAE_DROPDOWN_VERSION or BQAE_DROPDOWN_VERSION < 1.1) ) then
BQAE_DROPDOWN_VERSION = 1.1;

BQAE_DISPLAYDELAY = 3.5;
BQAE_DROPDOWN_WIDTH = 143;
BQAE_DROPDOWN_HEIGHT = 30;

BQAE_DROPDOWN_BUTTONWIDTH = 119;
BQAE_DROPDOWN_BUTTONHEIGHT = 18;

BQAE_DROPDOWN_EXPANDARROW_WIDTH = 24;
BQAE_DROPDOWN_EXPANDARROW_HEIGHT = 24;

BQAE_DROPDOWN_DEFAULT_NOSELECTION = "None";

BQAE_DropDown = CreateFrame("Frame", nil);
BQAE_DropDown:Hide();

local function GetTopMostChild(start, exclude)
	if (type(start["GetChildren"]) ~= "function") then return 0; end
	local level = 0;
	for count, child in next, { start:GetChildren() } do
		if (tostring(child) ~= tostring(exclude)) then
			if (type(child["GetFrameLevel"]) == "function" 
				and child:GetFrameLevel() > level)
			then
				level = child:GetFrameLevel();
				local kidsLevels = GetTopMostChild(child, exclude);
				if (kidsLevels > level) then
					level = kidsLevels;
				end
			end
		end
	end
	return level;
end


function BQAE_DropDown:Init(frame, parent, label, width)
	local dropdown = CreateFrame("Frame", frame, parent);
	
	setmetatable(dropdown, self);
    self.__index=self;
	
	dropdown.name = frame;
	dropdown.parent = (parent or UIParent)
	dropdown.buttons = {};
	dropdown.selected = nil;
	dropdown.enabled = true;
	
	dropdown.EVENT_VALCHANGED = function() end;
	
	dropdown.set_ListDisplayDelay = BQAE_DISPLAYDELAY;
	dropdown.set_DefaultNoSelect = BQAE_DROPDOWN_DEFAULT_NOSELECTION;
	dropdown.set_UseNoSelect = false;
	
	dropdown:SetupFrame();
	dropdown:SetupListFrame();
	
	dropdown:SetLabel(label);
	dropdown:SetWidth(width or BQAE_DROPDOWN_WIDTH);
	-- dropdown:AdjustButtonWidth(width or BQAE_DROPDOWN_WIDTH);

	return dropdown;
end

function BQAE_DropDown:SetupFrame()
	-- self.frame = CreateFrame("Frame", self.name, self.parent);
	self.origSetWidth = self.SetWidth;
	self.SetWidth = 
	function(self, width)
		self:origSetWidth(width);
		for index, button in next, self.buttons do
			button:SetWidth(width - 16);
		end
	end
		
	if (not self.name) then
		self.name = "BQAE_DROPDOWN_AUTO_NAME_" .. string.sub(tostring(self), 8);
	end
	-- self.frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
							-- edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
							-- tile = true, tileSize = 16, edgeSize = 16, 
							-- insets = { left = 5, right = 5, top = 5, bottom = 5 }});
							
	-- self:SetWidth(BQAE_DROPDOWN_BUTTONWIDTH + BQAE_DROPDOWN_EXPANDARROW_WIDTH);
	self:SetHeight(BQAE_DROPDOWN_EXPANDARROW_HEIGHT);
	
	self.leftTexture = self:CreateTexture();
	self.leftTexture:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame");
	self.leftTexture:SetPoint("TOPLEFT", -16, 19);
	self.leftTexture:SetWidth(25);
	self.leftTexture:SetHeight(64);
	self.leftTexture:SetTexCoord(0, 0.1953125, 0, 1);
	
	self.rightTexture = self:CreateTexture();
	self.rightTexture:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame");
	self.rightTexture:SetPoint("TOPRIGHT", 16, 19);
	self.rightTexture:SetWidth(25);
	self.rightTexture:SetHeight(64);
	self.rightTexture:SetTexCoord(0.8046875, 1, 0, 1);
	
	self.middleTexture = self:CreateTexture();
	self.middleTexture:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame");
	self.middleTexture:SetPoint("LEFT", self.leftTexture, "RIGHT");
	self.middleTexture:SetPoint("RIGHT", self.rightTexture, "LEFT");
	self.middleTexture:SetHeight(64);
	self.middleTexture:SetTexCoord(0.1953125, 0.8046875, 0, 1);
	
	self.button = CreateFrame("Button", string.format("%s%s", self.name, "Button"), self);
	self.button:SetPoint("RIGHT");
	self.button:SetWidth(BQAE_DROPDOWN_EXPANDARROW_WIDTH);
	self.button:SetHeight(BQAE_DROPDOWN_EXPANDARROW_HEIGHT);
	self.button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up");
	self.button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down");
	self.button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled");
	self.button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
	
	self.text = self:CreateFontString(nil, "OVERLAY");
    self.text:SetPoint("LEFT", 8, 0)
    self.text:SetPoint("RIGHT", self.button, "LEFT", -4, 0)
    self.text:SetHeight(16);
    self.text:SetJustifyH("RIGHT")
    self.text:SetJustifyV("CENTER")
    self.text:SetFontObject("GameFontHighlightSmall");
	
	self.label = self:CreateFontString(nil, "OVERLAY");
	self.label:SetFontObject("GameFontNormal");
	self.label:SetHeight(16);
	self.label:SetJustifyH("RIGHT");
	self.label:SetJustifyV("CENTER");
	self.label:SetPoint("RIGHT", self, "LEFT", -8, 0);
	
	if ( self.set_UseNoSelect ) then
		self.text:SetText(self.set_DefaultNoSelect);
	end
	
	
	self.button:SetScript("OnClick", 
		function() 
			if ( not self.enabled) then return; end
			if ( self.list:IsVisible() ) then
				self.list:Hide();
			else
				self.list:SetFrameStrata("TOOLTIP");
				self.list:Show();
				self:SetFrameLevel(GetTopMostChild(self:GetParent(), self) + 1);
			end
			PlaySound("igMainMenuOptionCheckBoxOn");
		end);
	
end


function BQAE_DropDown:SetupListFrame()
	self.list = CreateFrame("Frame", string.format("%s%s", self.name, "List"), self);
	self.list.name = string.format("%s%s", self.name, "List");
    self.list:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
							edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
							tile = true, tileSize = 16, edgeSize = 16, 
							insets = { left = 5, right = 5, top = 5, bottom = 5 }});
	self.list:SetBackdropColor(0.0, 0.0, 0.0);
	self.list:SetFrameStrata("TOOLTIP");
	self.list:SetClampedToScreen(true);
	self.list:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 4);
	self.list:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 4);
	self.list:SetHeight(0);
	self.list:Hide();
	
	self.list:SetScript("OnShow",
				function() 
					self.list:SetScript("OnUpdate", 
						function ()
							local mouseFrame = GetMouseFocus();
							if ( mouseFrame ) then
								if ( mouseFrame.GetParent and mouseFrame:GetParent() == self.list ) then
									self.showDelay = nil;
								else
									self.showDelay = (self.showDelay or (GetTime() + self.set_ListDisplayDelay));
								end
							end
							if ( self.showDelay and self.showDelay <= GetTime() ) then
								self.showDelay = nil;
								self.list:Hide();
								self:SetScript("OnUpdate", nil);
							end
						end);
				end);
	self.list:SetScript("OnHide",
				function()
					self.showDelay = nil;
					self.list:SetScript("OnUpdate", nil);
				end);
	
end

-- BQAE_DropDown:AddButton(text, func [, icon])
-- BQAE_DropDown:AddButton(text, value, func [, icon])
function BQAE_DropDown:AddButton(text, value, func, icon)
	if ( type(value) == "function" ) then
		icon = func;
		func = value;
		value = text;
	end

	local button = getglobal(string.format("%s%s%d", self.list.name, "Button", #self.buttons + 1));
	if ( not button ) then
		button = CreateFrame("Button", string.format("%s%s%d", self.list.name, "Button", (#self.buttons + 1)), self.list);
	end

	button:SetWidth(BQAE_DROPDOWN_BUTTONWIDTH);
	button:SetHeight(BQAE_DROPDOWN_BUTTONHEIGHT);
	button:Show();
		
	if ( not button.text ) then
		button.text = button:CreateFontString(nil, "OVERLAY");
		button.text:SetFontObject("GameFontHighlightSmall");
	end
    button.text:SetPoint("LEFT", 18, 0)
    button.text:SetPoint("RIGHT")
    button.text:SetHeight(16);
    button.text:SetJustifyH("LEFT")
    button.text:SetJustifyV("CENTER")
	--button.text = getglobal(button:GetName() .. "Text");
	button.text:SetText(text);
	button.value = (value or text);
	button.func = func;
	button.checked = false;
	
	if ( not button.icon ) then
		button.icon = button:CreateTexture();
	end
	button.icon:SetTexture(icon or "Interface\\Buttons\\UI-CheckBox-Check");
	button.icon:SetWidth(18);
	button.icon:SetHeight(18);
	button.icon:SetPoint("LEFT", button)
	button.icon:Hide();
	
	if ( not button.highlight ) then
		button.highlight = button:CreateTexture();
	end
	button.highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	button.highlight:SetBlendMode("ADD");
	button.highlight:SetAlpha("0.6");
	button.highlight:SetAllPoints(button);
	button.highlight:Hide();

	button:SetScript("OnEnter",
					function ()
						button.highlight:Show();
					end);
	
	button:SetScript("OnLeave",
					function ()
						button.highlight:Hide();
					end);
	
	button:SetScript("OnClick", 
					function ()
						if ( not button.checked ) then
							if ( self.selected ) then
								self.selected.checked = false;
								self.selected.icon:Hide();
							end
							self.selected = button;
							
							self.selected.checked = true;
							self.selected.icon:Show();
							self.text:SetText(self.selected.text:GetText());
							if ( self.selected.func ) then
								self.selected.func();
							end
							self.list:Hide();
						else
							if ( self.set_UseNoSelect ) then
								button.checked = false;
								button.icon:Hide();
								if ( button.func ) then
									button.func();
								end
								self.selected = nil;
								self.text:SetText(self.set_DefaultNoSelect);
							end
							self.list:Hide();
						end
						self.EVENT_VALCHANGED();
					end);
	
	local lastButton;
	if ( #self.buttons == 0 ) then
		button:SetPoint("TOPLEFT", self.list, "TOPLEFT", 4, -8);
		button:SetPoint("TOPRIGHT", self.list, "TOPRIGHT", -4, -8);
	else
		lastButton = self.buttons[#self.buttons];
		button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT");
		button:SetPoint("TOPRIGHT", lastButton, "BOTTOMRIGHT");
	end
	tinsert(self.buttons, button);

	self.list:SetHeight(#self.buttons * BQAE_DROPDOWN_BUTTONHEIGHT + 16);
end

function BQAE_DropDown:RemoveButton(index)
	if ( index > #self.buttons ) then return; end
	
	local priorButton, proceedingbutton;
	if ( index ~= #self.buttons ) then
		self.buttons[#self.buttons + 1]:SetPoint("TOP", self.buttons[#self.buttons - 1], "BOTTOM");
	end
	self.buttons[index]:Hide();
	tremove(self.buttons, index);
end

function BQAE_DropDown:ClearButtons()
	for i = #self.buttons, 1, -1 do
		self:RemoveButton(i);
	end
end

function BQAE_DropDown:SetDefaultNoSelect(text)
	self.set_DefaultNoSelect = text;
end

function BQAE_DropDown:SetSelectedIndex(index)
	assert(index, "BQAE_DropDown:SetSelectedIndex() called without an index.");

	if ( self.selected ) then
		self.selected.checked = false;
		self.selected.icon:Hide()
	end
	if ( self.buttons[index] ) then
		self.selected = self.buttons[index];
		self.selected.checked = true;
		self.selected.icon:Show();
		self.text:SetText(self.selected.text:GetText());
		return true;
	end
end

function BQAE_DropDown:SetSelectedValue(value)
	assert(value, "BQAE_DropDown:SetSelectedValue() called without a value.");
	
	for i, button in next, self.buttons do
		if ( button.value == value ) then
			if ( self.selected ) then
				self.selected.checked = false;
				self.selected.icon:Hide();
			end
			
			self.selected = self.buttons[i];
			self.selected.checked = true;
			self.selected.icon:Show();
			self.text:SetText(button.text:GetText());
			return true;
		end
	end
end

function BQAE_DropDown:GetSelected()
	return self.selected;
end

function BQAE_DropDown:GetSelectedValue()
	if ( self.selected ) then
		return self.selected.value;
	end
end

function BQAE_DropDown:GetSelectedText()
	if ( self.selected ) then
		return self.selected.text:GetText();
	end
end

function BQAE_DropDown:SetLabel(text)
	self.label:SetText(text);
end

function BQAE_DropDown:Enable()
	self.enabled = true;
end

function BQAE_DropDown:Disable()
	self.enabled = false;
end

function BQAE_DropDown:SetHandler(name, func)
	assert(type(name) == "string" and type(func) == "function", "Usage: BQAE_DropDown:SetHandler(name, func);");
	if (name == "OnValueChanged") then
		self.EVENT_VALCHANGED = func;
	else
		self:SetScript(name, func);
	end
end

end -- [[ End Versioning ]] 