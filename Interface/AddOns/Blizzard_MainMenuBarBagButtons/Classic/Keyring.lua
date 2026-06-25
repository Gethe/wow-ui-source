
KeyringMixin = {};

function KeyringMixin:OnLoad()
	if(not IsKeyRingEnabled()) then
		return; -- in versions that dont support the keyring, dont register for anything, early out
	end

	MainMenuBarBagManager:RegisterBagButton(self);
	ItemAnim_OnLoad(self)
	self:SetID(KEYRING_CONTAINER);
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");

	self.initialWidth = self:GetWidth();
	self.initialHeight = self:GetHeight();
end

function KeyringMixin:OnEvent(event, ...)
	ItemAnim_OnEvent(self, event, ...);
end

function KeyringMixin:OnShow()
	self:GetParent():Layout();
end

function KeyringMixin:OnClick()
	if (CursorHasItem()) then
		PutKeyInKeyRing();
	else
		ToggleBag(KEYRING_CONTAINER);
	end
end

function KeyringMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(KEYRING, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddLine();
end

function KeyringMixin:OnLeave()
	GameTooltip:Hide();
end

function KeyringMixin:OnReceiveDrag()
	if (CursorHasItem()) then
		PutKeyInKeyRing();
	end
end

function KeyringMixin:UpdateOrientation(isHorizontal)
	if isHorizontal then
		self:SetSize(self.initialWidth, self.initialHeight);
		self:GetNormalTexture():SetRotation(0);
		self:GetHighlightTexture():SetRotation(0);
		self:GetPushedTexture():SetRotation(0);
	else
		-- Swap width/height for vertical bags bar since the bar is horizontal by default
		self:SetSize(self.initialHeight, self.initialWidth);
		self:GetNormalTexture():SetRotation(math.pi/2);
		self:GetHighlightTexture():SetRotation(math.pi/2);
		self:GetPushedTexture():SetRotation(math.pi/2);
	end
end
