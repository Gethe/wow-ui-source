CreateChannelPopupMixin = {};

function CreateChannelPopupMixin:OnLoad()
	self.tabGroup = CreateTabGroup(self.Name, self.Password);
end

function CreateChannelPopupMixin:SetCallback(contextObject, callbackFunction)
	self.contextObject = contextObject;
	self.callbackFunction = callbackFunction;
end

function CreateChannelPopupMixin:DoCallback(...)
	self.callbackFunction(self.contextObject, ...)
end

function CreateChannelPopupMixin:OnOKClicked()
	self:DoCallback(self.Name:GetText(), self.Password:GetText());
	StaticPopupSpecial_Hide(self);
end

function CreateChannelPopupMixin:OnCancelClicked()
	StaticPopupSpecial_Hide(self);
end

function CreateChannelPopupMixin:OnTabPressed()
	self.tabGroup:OnTabPressed();
end

function CreateChannelPopupMixin:OnHide()
	self.Name:SetText("");
	self.Password:SetText("");
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end