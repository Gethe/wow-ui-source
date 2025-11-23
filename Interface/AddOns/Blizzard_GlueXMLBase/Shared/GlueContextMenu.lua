
local function GlueContextMenu_ResetContextMenu(contextMenu)
	contextMenu:Reset();
	contextMenu:ClearAllPoints();
	contextMenu:Hide();
	
	if contextMenu == GlueContextMenu then
		GlueContextMenu.owner = nil;
	end
end

function GlobalGlueContextMenu_GetOwner()
	return GlueContextMenu.owner;
end

function GlobalGlueContextMenu_Acquire(owner, extraMenuHeight, extraMenuWidth)
	GlueContextMenu_ResetContextMenu(GlueContextMenu);
	GlueContextMenu:Initialize(extraMenuHeight, extraMenuWidth);
	GlueContextMenu.owner = owner;
	return GlueContextMenu;
end

function GlobalGlueContextMenu_IsShown()
	return GlueContextMenu:IsShown();
end

function GlobalGlueContextMenu_Release()
	GlueContextMenu_ResetContextMenu(GlueContextMenu);
end

GlueContextMenuMixin = {};

local DEFAULT_EXTRA_MENU_HEIGHT = 26;
local DEFAULT_EXTRA_MENU_WIDTH = 28;
local DEFAULT_TIMEOUT = 3;
function GlueContextMenuMixin:Initialize(extraMenuHeight, extraMenuWidth)
	self.extraMenuHeight = extraMenuHeight or DEFAULT_EXTRA_MENU_HEIGHT;
	self.extraMenuWidth = extraMenuWidth or DEFAULT_EXTRA_MENU_WIDTH;
	self.timeout = timeout or DEFAULT_TIMEOUT;
	self.timeLeft = self.timeout;
end

function GlueContextMenuMixin:OnUpdate(dt)
	if self.timeout then
		if self:IsMouseOver() then
			self.timeLeft = self.timeout;
		else
			self.timeLeft = self.timeLeft - dt;
			if self.timeLeft <= 0 then
				GlueContextMenu_ResetContextMenu(self);
			end
		end
	end
end

function GlueContextMenuMixin:AddButton(buttonText, buttonFunction)
	local buttonFrame = self.buttonFrames:Acquire();
	self.buttons[#self.buttons + 1] = buttonFrame;
	buttonFrame:SetText(buttonText);
	
	local function ContextMenuButton_OnClick()
		buttonFunction();
		GlueContextMenu_ResetContextMenu(self);
	end
	buttonFrame:SetScript("OnClick", ContextMenuButton_OnClick);
	
	buttonFrame:SetWidth(buttonFrame.Text:GetWidth());
	if self.newbuttonAnchor then
		buttonFrame:SetPoint("TOP", self.newbuttonAnchor, "BOTTOM");
	else
		buttonFrame:SetPoint("TOP", self, "TOP", 0, -(self.extraMenuHeight / 2));
	end
	
	self.newbuttonAnchor = buttonFrame;
	self:RefreshSize();
	buttonFrame:Show();
end

function GlueContextMenuMixin:GetMaximumButtonWidth()
	local maxWidth = 0;
	for i, button in ipairs(self.buttons) do
		maxWidth = math.max(button:GetWidth(), maxWidth);
	end
	
	return maxWidth;
end

function GlueContextMenuMixin:RefreshSize()
	local maxWidth = self:GetMaximumButtonWidth();
	self:SetWidth(maxWidth + self.extraMenuWidth);
	for i, button in ipairs(self.buttons) do
		button:SetWidth(maxWidth);
	end
	
	local buttonHeight = #self.buttons > 0 and self.buttons[1]:GetHeight() or 0;
	self:SetHeight(#self.buttons * buttonHeight + self.extraMenuHeight);
end

function GlueContextMenuMixin:Reset()
	if not self.buttonFrames then
		self.buttonFrames = CreateFramePool("BUTTON", self, "GlueContextMenuButtonTemplate");
	else
		self.buttonFrames:ReleaseAll();
	end
	
	self.buttons = self.buttons and wipe(self.buttons) or {};
	self.newbuttonAnchor = nil;
	self.timeLeft = timeout;
end
