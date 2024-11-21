RealmWarningPopUpFrameMixin = {};

REALM_WARNING_POPUP_SCREEN = {
    REALM_SELECT        = 1,
    CHARACTER_SELECT    = 2,
}

function RealmWarningPopUpFrameMixin:SetBodyText(text)
	self.ScrollBox.Text:SetText(text);
    self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
	self.ScrollBox:ScrollToBegin();
end

function RealmWarningPopUpFrameMixin:Reset()
	self:SetBodyText("");
    self.screen = nil;
    self.realmInfo = nil;
end

function RealmWarningPopUpFrameMixin:OnLoad()
	NineSliceUtil.ApplyLayoutByName(self.Border, "Dialog");
	ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, CreateScrollBoxLinearView());
    self.screen = nil;
    self.realmInfo = nil;
end

function RealmWarningPopUpFrameMixin:OnShow()
	GlueParent_AddModalFrame(self);
    if (self.ScrollBar:GetVisibleExtentPercentage() == 1) then
        -- Text is completely visible
        self.ScrollBar:Hide();
    else 
        self.ScrollBar:Show();
    end
end

function RealmWarningPopUpFrameMixin:OnHide()
	GlueParent_RemoveModalFrame(self);
    self:Reset();
end

function RealmWarningPopUpFrameMixin:SetRealmInfo(realmInfo)
    self.selectedRealm = realmInfo;
end

function RealmWarningPopUpFrameMixin:ShowRealmSelectionWarning()
	self:SetBodyText(HTML_START .. PVP_REALM_WARNING .. HTML_END);
    self:SetSize(510, 240);
    self.ScrollBox:SetSize(430,120);
    self.screen = REALM_WARNING_POPUP_SCREEN.REALM_SELECT;
    self:Show();
end

function RealmWarningPopUpFrameMixin:ShowCharacterCreationWarning()
    self:SetBodyText(HTML_START .. PVP_CHARACTER_CREATION_WARNING .. PVP_CHARACTER_CREATION_WARNING_TWO .. HTML_END);
    self:SetSize(510, 360);
    self.screen = REALM_WARNING_POPUP_SCREEN.CHARACTER_SELECT;
    self.ScrollBox:SetSize(430,240);
    self:Show();
end

RealmWarningPopUpAcceptButtonMixin = {};

function RealmWarningPopUpAcceptButtonMixin:OnClick()
    local screen = self:GetParent().screen;
    if (screen == REALM_WARNING_POPUP_SCREEN.REALM_SELECT) then
        C_RealmList.ConnectToRealm(self:GetParent().selectedRealm);
    elseif (screen == REALM_WARNING_POPUP_SCREEN.CHARACTER_SELECT) then
        C_CharacterCreation.CreateCharacter(CharacterCreateNameEdit:GetText());
    end
	self:GetParent():Hide();
end

RealmWarningPopUpDeclineButtonMixin = {};

function RealmWarningPopUpDeclineButtonMixin:OnClick()
	self:GetParent():Hide();
end