HardcorePopUpFrameMixin = {};

HARDCORE_POPUP_SCREEN = {
    REALM_SELECT        = 1,
    CHARACTER_SELECT    = 2,
}

function HardcorePopUpFrameMixin:SetBodyText(text)
	self.ScrollBox.Text:SetText(text);
    self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
	self.ScrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end

function HardcorePopUpFrameMixin:Reset()
	self:SetBodyText("");
    self.screen = nil;
    self.realmInfo = nil;
end

function HardcorePopUpFrameMixin:OnLoad()
	NineSliceUtil.ApplyLayoutByName(self.Border, "Dialog");
	ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, CreateScrollBoxLinearView());
    self.screen = nil;
    self.realmInfo = nil;
end

function HardcorePopUpFrameMixin:OnShow()
	GlueParent_AddModalFrame(self);
    if (self.ScrollBar:GetVisibleExtentPercentage() == 1) then
        -- Text is completely visible
        self.ScrollBar:Hide();
    else 
        self.ScrollBar:Show();
    end
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
    self.ScrollBox:SetSize(430,220);
    self.screen = HARDCORE_POPUP_SCREEN.REALM_SELECT;
    self:Show();
end

function HardcorePopUpFrameMixin:ShowCharacterCreationWarning()
    self:SetBodyText(HTML_START .. HARDCORE_CHARACTER_CREATE_WARNING .. HARDCORE_CHARACTER_CREATE_WARNING_TWO .. HTML_END);
    self:SetSize(510, 580);
    self.screen = HARDCORE_POPUP_SCREEN.CHARACTER_SELECT;
    self.ScrollBox:SetSize(430,470);
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

CharacterReincarnatePopUpDialogMixin = {};

function CharacterReincarnatePopUpDialogMixin:OnLoad()
    self:RegisterEvent("CHARACTER_LIST_UPDATE");
    self:RegisterEvent("CHARACTER_DELETION_RESULT");
end

function CharacterReincarnatePopUpDialogMixin:ShowWarning()
    local guid, name, className, level = C_Reincarnation.GetReincarnatingCharacter();
    CharacterReincarnatePopUpText1:SetFormattedText(REINCARNATE_CHARACTER_CONFIRMATION, name, level, className);
    CharacterReincarnatePopUpText1:SetHeight(16 + CharacterDeleteText1:GetHeight() + CharacterDeleteText2:GetHeight() + 23 + CharacterDeleteEditBox:GetHeight() + 8 + CharacterDeleteButton1:GetHeight() + 16);
    CharacterReincarnatePopUpButton1:Disable();
    self:Show()
end

function CharacterReincarnatePopUpDialogMixin:OnEvent(event, ...)
    if (event == "CHARACTER_LIST_UPDATE" or event == "CHARACTER_DELETION_RESULT") then
        self:Hide();
    end
end