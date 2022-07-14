SocialContractFrameMixin = {};

function SocialContractFrameMixin:SetBodyText(text)
	self.ScrollBox.Text:SetText(text);
	self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
	self.ScrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
	self.isRead = false;
end

function SocialContractFrameMixin:IsTextFullyScrolled()
	local textUsesScrollBar = self.ScrollBox:HasScrollableExtent();
	return not textUsesScrollBar or (self.ScrollBox:GetScrollPercentage() >= .9);
end

function SocialContractFrameMixin:UpdateReadStatus()
	-- We consider the Social Contract "read" once we reach the bottom of the text for the first time
	self.isRead = self.isRead or self:IsTextFullyScrolled();
end

function SocialContractFrameMixin:UpdateAcceptButton()
	self.AcceptButton:SetEnabled(self.isRead);
end

function SocialContractFrameMixin:Update()
	self:UpdateReadStatus();
	self:UpdateAcceptButton();
end

function SocialContractFrameMixin:Reset()
	self:SetBodyText("");
	self:Update();
end

function SocialContractFrameMixin:OnLoad()
	NineSliceUtil.ApplyLayoutByName(self.Border, "Dialog");

	ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, CreateScrollBoxLinearView());
end

function SocialContractFrameMixin:OnShow()
	self.ScrollBox:RegisterCallback(BaseScrollBoxEvents.OnScroll, self.Update, self);

	self:SetBodyText(HTML_START .. SOCIAL_CONTRACT_TEXT1 .. SOCIAL_CONTRACT_TEXT2 .. SOCIAL_CONTRACT_TEXT3 .. HTML_END);

	GlueParent_AddModalFrame(self);
end

function SocialContractFrameMixin:OnHide()
	self.ScrollBox:UnregisterCallback(BaseScrollBoxEvents.OnScroll, self);

	self:Reset();

	GlueParent_RemoveModalFrame(self);
end

SocialContractAcceptButtonMixin = {};

function SocialContractAcceptButtonMixin:OnClick()
	C_SocialContractGlue.TryUpdateSocialContract();

	SocialContractFrame:Hide();
end

SocialContractDeclineButtonMixin = {};

function SocialContractDeclineButtonMixin:OnClick()
	QuitGame();
end