function RolePollPopup_OnLoad(self)
	self:RegisterEvent("ROLE_POLL_BEGIN");
end

function RolePollPopup_OnEvent(self, event, ...)
	if ( event == "ROLE_POLL_BEGIN" ) then
		if ( not self:IsShown() ) then
			RolePollPopup_Show(self);
		end
	end
end

function RolePollPopup_Show(self)
	--First, update what roles are usable
	local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles("player");
	if ( canBeTank ) then
		RolePollPopupRoleButton_Enable(RolePollPopupRoleButtonTank);
	else
		RolePollPopupRoleButton_Disable(RolePollPopupRoleButtonTank);
	end
	if ( canBeHealer ) then
		RolePollPopupRoleButton_Enable(RolePollPopupRoleButtonHealer);
	else
		RolePollPopupRoleButton_Disable(RolePollPopupRoleButtonHealer);
	end
	if ( canBeDamager ) then
		RolePollPopupRoleButton_Enable(RolePollPopupRoleButtonDPS);
	else
		RolePollPopupRoleButton_Disable(RolePollPopupRoleButtonDPS);
	end
	
	self.role = UnitGroupRolesAssigned("player");
	RolePollPopup_UpdateChecked(self);
	
	StaticPopupSpecial_Show(RolePollPopup);
end

function RolePollPopup_UpdateChecked(self)
	RolePollPopupRoleButtonTank.checkButton:SetChecked(self.role == "TANK");
	RolePollPopupRoleButtonHealer.checkButton:SetChecked(self.role == "HEALER");
	RolePollPopupRoleButtonDPS.checkButton:SetChecked(self.role == "DAMAGER");
	
	if ( self.role == "TANK" or self.role == "HEALER" or self.role == "DAMAGER" ) then
		self.acceptButton:Enable();
	else
		self.acceptButton:Disable();
	end
end

function RolePollPopupRoleButton_Enable(button)
	button:Enable();
	SetDesaturation(button:GetNormalTexture(), false);
	button.cover:Hide();
	button.cover:SetAlpha(1);
	button.checkButton:Enable();
	button.checkButton:Show();
	
	button.permDisabled = false;
end

function RolePollPopupRoleButton_Disable(button)
	button:Disable();
	SetDesaturation(button:GetNormalTexture(), true);
	button.cover:Show();
	button.cover:SetAlpha(0.5);
	button.checkButton:Disable();
	button.checkButton:Hide();
	
	button.permDisabled = true;
end

function RolePollPopupRoleButtonCheckButton_OnClick(self, button)
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		RolePollPopup.role = self:GetParent().role;
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
		RolePollPopup.role = "NONE";
	end

	RolePollPopup_UpdateChecked(RolePollPopup);
end

function RolePollPopupAccept_OnClick(self, button)
	UnitSetRole("player", self:GetParent().role);
	StaticPopupSpecial_Hide(self:GetParent());
end

function RoleChangedFrame_OnLoad(self)
	self:RegisterEvent("ROLE_CHANGED_INFORM");
end

function RoleChangedFrame_OnEvent(self, event, ...)
	if ( event == "ROLE_CHANGED_INFORM" ) then
		local changed, from, oldRole, newRole = ...;
		
		if ( newRole == "NONE" ) then
			if ( changed == from ) then
				ChatFrame_DisplaySystemMessageInPrimary(format(ROLE_REMOVED_INFORM, changed));
			else
				ChatFrame_DisplaySystemMessageInPrimary(format(ROLE_REMOVED_INFORM_WITH_SOURCE, changed, from));
			end
		else
			local displayedRole = _G["INLINE_"..newRole.."_ICON"].." ".._G[newRole];	--Uses INLINE_TANK_ICON, etc.
			if ( changed == from ) then
				ChatFrame_DisplaySystemMessageInPrimary(format(ROLE_CHANGED_INFORM, changed, displayedRole));
			else
				ChatFrame_DisplaySystemMessageInPrimary(format(ROLE_CHANGED_INFORM_WITH_SOURCE, changed, displayedRole, from));
			end
		end
	end
end

