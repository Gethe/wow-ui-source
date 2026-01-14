function ChatFrameEditBoxMixin:ShouldDeactivateChatOnEditFocusLost()
	return true;
end

function ChatFrameEditBoxMixin:UpdateNewcomerEditBoxHint(excludeChannel)
	self.prompt:SetShown(not self.header:IsShown());
end
