SocialContractFrameMixin = {};

function SocialContractFrameMixin:OnLoad()
	NineSliceUtil.ApplyLayoutByName(self.Border, "Dialog");

	ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, CreateScrollBoxLinearView());
end

function SocialContractFrameMixin:IsSocialContractFullyRead()
	return not self.ScrollBox:HasScrollableExtent() or (self.ScrollBox:GetScrollPercentage() >= .9);
end

function SocialContractFrameMixin:UpdateAcceptButton()
	-- We enable the button the first time we reach the bottom of the text and then it stays enabled permenantly
	if not self.AcceptButton:IsEnabled() and self:IsSocialContractFullyRead() then
		self.AcceptButton:Enable();
	end
end

function SocialContractFrameMixin:OnShow()
	self.ScrollBox:RegisterCallback(BaseScrollBoxEvents.OnLayout, self.UpdateAcceptButton, self);
	self.ScrollBox:RegisterCallback(BaseScrollBoxEvents.OnScroll, self.UpdateAcceptButton, self);

	self.AcceptButton:Disable();

	self.ScrollBox.Text:SetText(HTML_START .. SOCIAL_CONTRACT_TEXT1 .. SOCIAL_CONTRACT_TEXT2 .. SOCIAL_CONTRACT_TEXT3 .. HTML_END);

	GlueParent_AddModalFrame(self);
end

function SocialContractFrameMixin:OnHide()
	self.ScrollBox:UnregisterCallback(BaseScrollBoxEvents.OnLayout, self);
	self.ScrollBox:UnregisterCallback(BaseScrollBoxEvents.OnScroll, self);
	self.ScrollBox:SetScrollPercentage(0);
	self.ScrollBox.Text:SetText("");

	GlueParent_RemoveModalFrame(self);
end

SocialContractAcceptButtonMixin = {};

function SocialContractAcceptButtonMixin:OnClick()
	-- TODO: Try updating Social Contract here

	SocialContractFrame:Hide();
end

SocialContractDeclineButtonMixin = {};

function SocialContractDeclineButtonMixin:OnClick()
	QuitGame();
end