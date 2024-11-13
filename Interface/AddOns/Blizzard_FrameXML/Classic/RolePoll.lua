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
	PlaySound(SOUNDKIT.READY_CHECK);
	FlashClientIcon();
	local recommendedTank, recommendedHealer, recommendedDPS = UnitGetAvailableRoles("player");
	if ( recommendedTank ) then
		RolePollPopupRoleButton_SetRecommended(RolePollPopupRoleButtonTank);
	else
		RolePollPopupRoleButton_SetNotRecommended(RolePollPopupRoleButtonTank);
	end
	if ( recommendedHealer ) then
		RolePollPopupRoleButton_SetRecommended(RolePollPopupRoleButtonHealer);
	else
		RolePollPopupRoleButton_SetNotRecommended(RolePollPopupRoleButtonHealer);
	end
	if ( recommendedDPS ) then
		RolePollPopupRoleButton_SetRecommended(RolePollPopupRoleButtonDPS);
	else
		RolePollPopupRoleButton_SetNotRecommended(RolePollPopupRoleButtonDPS);
	end
	
	self.role = UnitGroupRolesAssignedEnum("player");
	RolePollPopup_UpdateChecked(self);
	
	StaticPopupSpecial_Show(RolePollPopup);
end

function RolePollPopup_UpdateChecked(self)
	RolePollPopupRoleButtonTank.checkButton:SetChecked(self.role == Enum.LFGRole.Tank);
	RolePollPopupRoleButtonHealer.checkButton:SetChecked(self.role == Enum.LFGRole.Healer);
	RolePollPopupRoleButtonDPS.checkButton:SetChecked(self.role == Enum.LFGRole.Damage);
	
	if ( self.role == Enum.LFGRole.Tank or self.role == Enum.LFGRole.Healer or self.role == Enum.LFGRole.Damage ) then
		self.acceptButton:Enable();
	else
		self.acceptButton:Disable();
	end
end

function RolePollPopupRoleButton_SetRecommended(button)
	button.cover:Hide();
	button.cover:SetAlpha(1);
	
	button.notRecommended = false;
end

function RolePollPopupRoleButton_SetNotRecommended(button)
	button.cover:Show();
	button.cover:SetAlpha(0.5);
	
	button.notRecommended = true;
end

function RolePollPopupRoleButtonCheckButton_OnClick(self, button)
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		RolePollPopup.role = self:GetParent().role;
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		RolePollPopup.role = Constants.LFG_ROLEConstants.LFG_ROLE_NO_ROLE;
	end

	RolePollPopup_UpdateChecked(RolePollPopup);
end

function RolePollPopupAccept_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	UnitSetRoleEnum("player", self:GetParent().role);
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
