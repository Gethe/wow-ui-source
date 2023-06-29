HardcorePopUpFrameMixin = {};

HARDCORE_POPUP_SCREEN = {
    REALM_SELECT        = 1,
    CHARACTER_SELECT    = 2,
}

function HardcorePopUpFrameMixin:SetBodyText(text)
	self.TextBox:SetText(text);
end

function HardcorePopUpFrameMixin:Reset()
	self:SetBodyText("");
    self.screen = nil;
    self.realmInfo = nil;
end

function HardcorePopUpFrameMixin:OnLoad()
	NineSliceUtil.ApplyLayoutByName(self.Border, "Dialog");
    self.screen = nil;
    self.realmInfo = nil;
end

function HardcorePopUpFrameMixin:OnShow()
	GlueParent_AddModalFrame(self);
end

function HardcorePopUpFrameMixin:OnHide()
	GlueParent_RemoveModalFrame(self);
    self:Reset();
end

function HardcorePopUpFrameMixin:SetRealmInfo(realmInfo)
    self.selectedRealm = realmInfo;
end

function HardcorePopUpFrameMixin:ShowRealmSelectionWarning()
	self:SetBodyText(HTML_START .. HARDCORE_WARNING .. HTML_END);
    self:SetSize(510, 240);
    self.screen = HARDCORE_POPUP_SCREEN.REALM_SELECT;
    self:Show();
end

function HardcorePopUpFrameMixin:ShowCharacterCreationWarning()
    self:SetBodyText(HTML_START .. HARDCORE_CHARACTER_CREATE_WARNING .. HARDCORE_CHARACTER_CREATE_WARNING_TWO .. HTML_END);
    self:SetSize(510, 580);
    self.screen = HARDCORE_POPUP_SCREEN.CHARACTER_SELECT;
    self:Show();
end

HardcorePopUpAcceptButtonMixin = {};

function HardcorePopUpAcceptButtonMixin:OnClick()
    local screen = self:GetParent().screen;
    if (screen == HARDCORE_POPUP_SCREEN.REALM_SELECT) then
        C_RealmList.ConnectToRealm(self:GetParent().selectedRealm);
    elseif (screen == HARDCORE_POPUP_SCREEN.CHARACTER_SELECT) then
        C_CharacterCreation.CreateCharacter(CharacterCreateNameEdit:GetText());
    end
	self:GetParent():Hide();
end

HardcorePopUpDeclineButtonMixin = {};

function HardcorePopUpDeclineButtonMixin:OnClick()
	self:GetParent():Hide();
end