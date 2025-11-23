ChatAlertFrameMixin = {};

function ChatAlertFrameMixin:OnLoad()
	AlertContainerMixin.OnLoad(self);
	self:SetJustification("LEFT");
	self:SetWidth(DEFAULT_CHAT_FRAME.buttonFrame:GetWidth());
	self:SetPoint("BOTTOMLEFT", DEFAULT_CHAT_FRAME.buttonFrame, "TOPLEFT", 0, 27);
end

function ChatAlertFrameMixin:SetChatButtonSide(buttonSide)
	if buttonSide == "left" then
		self:SetJustification("LEFT");
	elseif buttonSide == "right" then
		self:SetJustification("RIGHT");
	end
end