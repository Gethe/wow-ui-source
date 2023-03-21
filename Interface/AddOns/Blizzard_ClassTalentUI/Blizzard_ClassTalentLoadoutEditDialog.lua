StaticPopupDialogs["LOADOUT_CONFIRM_DELETE_DIALOG"] = {
	text = HUD_ClASS_TALENTS_EDIT_LOADOUT_CONFIRM_DELETE,
	button1 = DELETE,
	button2 = CANCEL,
	timeout = 0,
	OnAccept = function()
		ClassTalentLoadoutEditDialog:OnDeleteConfirmed();
	end,
	OnCancel = function()
	end,
	whileDead = 1,
	hideOnEscape = 1,
	wide = 1,
};

StaticPopupDialogs["LOADOUT_CONFIRM_SHARED_ACTION_BARS"] = {
	text = HUD_ClASS_TALENTS_EDIT_LOADOUT_CONFIRM_SHARED_ACTION_BARS,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	OnAccept = function()
		ClassTalentLoadoutEditDialog:OnSharedActionBarsConfirmed();
	end,
	OnCancel = function()
	end,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = true,
	wide = 1,
};

ClassTalentLoadoutEditDialogMixin = {};

function ClassTalentLoadoutEditDialogMixin:OnLoad()
	self.exclusive = true;
	self.AcceptButton:SetOnClickHandler(GenerateClosure(self.OnAccept, self));
	self.DeleteButton:SetOnClickHandler(GenerateClosure(self.OnDelete, self));
	self.CancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self));
	ClassTalentLoadoutDialogMixin.OnLoad(self);
end

function ClassTalentLoadoutEditDialogMixin:OnCancel()
	StaticPopupSpecial_Hide(self);
end

function ClassTalentLoadoutEditDialogMixin:OnAccept()
	if self.AcceptButton:IsEnabled() then
		local loadoutName = self.NameControl:GetText();
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

function ClassTalentLoadoutEditDialogMixin:OnDelete()
	local configInfo = C_Traits.GetConfigInfo(self.configID);

	StaticPopupSpecial_Hide(self);
	StaticPopup_Show("LOADOUT_CONFIRM_DELETE_DIALOG", configInfo.name);
end

function ClassTalentLoadoutEditDialogMixin:OnDeleteConfirmed()
	C_ClassTalents.DeleteConfig(self.configID);
end

function ClassTalentLoadoutEditDialogMixin:OnSharedActionBarsConfirmed()
	C_ClassTalents.SetUsesSharedActionBars(self.configID, true);
end

function ClassTalentLoadoutEditDialogMixin:UpdateAcceptButtonEnabledState()
	local nameTextFilled = self.NameControl:HasText();
	self.AcceptButton:SetEnabled(nameTextFilled);
end

function ClassTalentLoadoutEditDialogMixin:OnTextChanged()
	self:UpdateAcceptButtonEnabledState();
end

function ClassTalentLoadoutEditDialogMixin:ShowDialog(configID)
	local configInfo = C_Traits.GetConfigInfo(configID);
	StaticPopupSpecial_Show(self);
	self.NameControl:SetText(configInfo.name);

	self.UsesSharedActionBars.CheckButton:SetChecked(configInfo.usesSharedActionBars);

	self.configID = configID;
end

ClassTalentLoadoutEditDialogNameControlMixin = {}

function ClassTalentLoadoutEditDialogNameControlMixin:OnShow()
	ClassTalentLoadoutDialogNameControlMixin.OnShow(self);
	self:GetEditBox():SetFocus();
end

function ClassTalentLoadoutEditDialogNameControlMixin:OnEnterPressed()
	self:GetParent():OnAccept();
end

function ClassTalentLoadoutEditDialogNameControlMixin:OnEscapePressed()
	self:GetParent():OnCancel();
end

function ClassTalentLoadoutEditDialogNameControlMixin:OnTextChanged()
	self:GetParent():OnTextChanged();
end

UseSharedActionBarsMixin = {};

function UseSharedActionBarsMixin:OnEnter()
	GameTooltip:SetOwner(self.CheckButton, "ANCHOR_RIGHT", 0, 0);
	GameTooltip_AddNormalLine(GameTooltip, HUD_CLASS_TALENTS_EDIT_LOADOUT_USES_SHARED_ACTION_BARS_TOOLTIP);
	GameTooltip:Show();
end

function UseSharedActionBarsMixin:OnLeave()
	GameTooltip_Hide();
end

function UseSharedActionBarsMixin:OnClick()
	self.CheckButton:Click();
end
