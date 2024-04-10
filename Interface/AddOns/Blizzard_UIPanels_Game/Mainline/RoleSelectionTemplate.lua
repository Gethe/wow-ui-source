
RoleSelectionMixin = {};

function RoleSelectionMixin:OnLoad()
	self:UpdatePermanentlyDisabledRoles();
end

function RoleSelectionMixin:GetSelectedRoles()
	return self.RoleButtonTank:IsSelected(), self.RoleButtonHealer:IsSelected(), self.RoleButtonDPS:IsSelected();
end

function RoleSelectionMixin:UpdatePermanentlyDisabledRoles()
	local canBeTank, canBeHealer, canBeDPS = C_LFGList.GetAvailableRoles();
	self.RoleButtonTank:SetPermanentlyDisabled(not canBeTank);
	self.RoleButtonHealer:SetPermanentlyDisabled(not canBeHealer);
	self.RoleButtonDPS:SetPermanentlyDisabled(not canBeDPS);
end

--Disables any roles given an error string. Enables the others. Trumped by permanently disabled roles.
function RoleSelectionMixin:SetDisabledRoles(errorStringTank, errorStringHealer, errorStringDamage)
	self.RoleButtonTank:SetTemporarilyDisabled(not not errorStringTank, errorStringTank);
	self.RoleButtonHealer:SetTemporarilyDisabled(not not errorStringHealer, errorStringHealer);
	self.RoleButtonDPS:SetTemporarilyDisabled(not not errorStringDamage, errorStringDamage);
end

--Overwrite these functions
function RoleSelectionMixin:OnAccept()
end

function RoleSelectionMixin:OnCancel()
end


RoleSelectionRoleMixin = {};

function RoleSelectionRoleMixin:OnClick(button)
	if ( self.CheckButton:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end

	self:SetSelected(not self:IsSelected());
end

function RoleSelectionRoleMixin:IsSelected()
	return self.selected and not (self.permDisabled or self.tempDisabled);
end

function RoleSelectionRoleMixin:SetSelected(selected)
	self.selected = selected;
	self:UpdateDisplay();
end

function RoleSelectionRoleMixin:SetPermanentlyDisabled(permDisabled)
	self.permDisabled = permDisabled;
	self:UpdateDisplay();
end

function RoleSelectionRoleMixin:UpdateDisplay()
	if ( self.permDisabled ) then
		self:SetEnabled(false);
		local showDisabled = true;
		self:SetNormalAtlas(GetIconForRole(self.role, showDisabled), TextureKitConstants.IgnoreAtlasSize);
		self.CheckButton:SetEnabled(false);
		self.CheckButton:SetShown(false);
	elseif ( self.tempDisabled ) then
		self:SetEnabled(false);
		local showDisabled = true;
		self:SetNormalAtlas(GetIconForRole(self.role, showDisabled), TextureKitConstants.IgnoreAtlasSize);
		self.CheckButton:SetEnabled(false);
		self.CheckButton:SetShown(true);
		self.CheckButton:SetChecked(false);
	else
		self:SetEnabled(true);
		local showDisabled = false;
		self:SetNormalAtlas(GetIconForRole(self.role, showDisabled), TextureKitConstants.IgnoreAtlasSize);
		self.CheckButton:SetEnabled(true);
		self.CheckButton:SetShown(true);
		self.CheckButton:SetChecked(self.selected);
	end
end

function RoleSelectionRoleMixin:SetTemporarilyDisabled(disabled, errorString)
	self.tempDisabled = disabled;
	self.errorString = errorString;
	self:UpdateDisplay();
end
