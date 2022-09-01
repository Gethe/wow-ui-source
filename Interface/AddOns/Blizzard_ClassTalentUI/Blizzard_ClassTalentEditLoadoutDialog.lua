StaticPopupDialogs["LOADOUT_CONFIRM_DELETE_DIALOG"] = {
	text = HUD_ClASS_TALENTS_EDIT_LOADOUT_CONFIRM_DELETE,
	button1 = DELETE,
	button2 = CANCEL,
	timeout = 0,
	OnAccept = function()
        ClassTalentEditLoadoutDialog:OnDeleteConfirmed();
	end,
	OnCancel = function()
	end,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["LOADOUT_CONFIRM_SHARED_ACTION_BARS"] = {
	text = HUD_ClASS_TALENTS_EDIT_LOADOUT_CONFIRM_SHARED_ACTION_BARS,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	OnAccept = function()
        ClassTalentEditLoadoutDialog:OnSharedActionBarsConfirmed();
	end,
	OnCancel = function()
	end,
	whileDead = 1,
	hideOnEscape = 1,
    showAlert = true,
};

ClassTalentEditLoadoutDialogMixin = {};

function ClassTalentEditLoadoutDialogMixin:OnLoad()
    self.exclusive = true;
	self.AcceptButton:SetOnClickHandler(GenerateClosure(self.OnAccept, self));
	self.DeleteButton:SetOnClickHandler(GenerateClosure(self.OnDelete, self));
	self.CancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self));
end

function ClassTalentEditLoadoutDialogMixin:OnCancel()
	StaticPopupSpecial_Hide(self);
end

function ClassTalentEditLoadoutDialogMixin:OnAccept()
    if self.AcceptButton:IsEnabled() then
        local loadoutName = self.LoadoutName:GetText();
        local usesShared = self.UsesSharedActionBars.CheckButton:GetChecked();

		StaticPopupSpecial_Hide(self);

        local configInfo = C_Traits.GetConfigInfo(self.configID);

        if(loadoutName ~= configInfo.name) then
            C_ClassTalents.RenameConfig(self.configID, loadoutName);
        end

        if(usesShared ~= configInfo.usesSharedActionBars) then
            if(usesShared) then
                StaticPopup_Show("LOADOUT_CONFIRM_SHARED_ACTION_BARS");
            else
                C_ClassTalents.SetUsesSharedActionBars(self.configID, false);
            end
        end
	end
end

function ClassTalentEditLoadoutDialogMixin:OnDelete()
    local configInfo = C_Traits.GetConfigInfo(self.configID);

    StaticPopupSpecial_Hide(self);
    StaticPopup_Show("LOADOUT_CONFIRM_DELETE_DIALOG", configInfo.name);
end

function ClassTalentEditLoadoutDialogMixin:OnDeleteConfirmed()
    C_ClassTalents.DeleteConfig(self.configID);
end

function ClassTalentEditLoadoutDialogMixin:OnSharedActionBarsConfirmed()
    C_ClassTalents.SetUsesSharedActionBars(self.configID, true);
end

function ClassTalentEditLoadoutDialogMixin:UpdateAcceptButtonEnabledState()
    local nameTextFilled = UserEditBoxNonEmpty(self.LoadoutName);
    self.AcceptButton:SetEnabled(nameTextFilled);
end

function ClassTalentEditLoadoutDialogMixin:OnTextChanged()
    self:UpdateAcceptButtonEnabledState();
end

function ClassTalentEditLoadoutDialogMixin:ShowDialog(configID)
    local configInfo = C_Traits.GetConfigInfo(configID);
    self.LoadoutName:SetText(configInfo.name);
	StaticPopupSpecial_Show(self);
	self.LoadoutName:SetFocus();

    self.UsesSharedActionBars.CheckButton:SetChecked(configInfo.usesSharedActionBars);

    self.configID = configID;
end


ClassTalentEditLoadoutDialogNameEditBoxMixin = {};

function ClassTalentEditLoadoutDialogNameEditBoxMixin:OnEnterPressed()
    self:GetParent():OnAccept();
end

function ClassTalentEditLoadoutDialogNameEditBoxMixin:OnEscapePressed()
    self:GetParent():OnCancel();
end

function ClassTalentEditLoadoutDialogNameEditBoxMixin:OnTextChanged()
    self:GetParent():OnTextChanged();
end

UseSharedActionBarsMixin = {};

function UseSharedActionBarsMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, -4);
    GameTooltip_AddNormalLine(GameTooltip, HUD_CLASS_TALENTS_EDIT_LOADOUT_USES_SHARED_ACTION_BARS_TOOLTIP);
	GameTooltip:Show();
end

function UseSharedActionBarsMixin:OnLeave()
    GameTooltip_Hide();
end
