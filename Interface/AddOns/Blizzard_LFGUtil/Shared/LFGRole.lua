
function LFG_PermanentlyDisableRoleButton(button)
	button.permDisabled = true;
	button:Disable();
	button.checkButton:Hide();
	button.checkButton:Disable();
	button.checkButton:SetChecked(false);
	button.alert:Hide();
	if ( button.background ) then
		button.background:Hide();
	end
	if ( button.shortageBorder ) then
		button.shortageBorder:SetVertexColor(0.5, 0.5, 0.5);
		button.incentiveIcon.texture:SetVertexColor(0.5, 0.5, 0.5);
		button.incentiveIcon.border:SetVertexColor(0.5, 0.5, 0.5);
	end
end

function LFG_DisableRoleButton(button)
	button:Disable();
	button.checkButton:Disable();
	if ( button.background ) then
		button.background:Hide();
	end
	if ( button.shortageBorder ) then
		button.shortageBorder:SetVertexColor(0.5, 0.5, 0.5);
		button.incentiveIcon.texture:SetVertexColor(0.5, 0.5, 0.5);
		button.incentiveIcon.border:SetVertexColor(0.5, 0.5, 0.5);
	end
end

function LFGRole_GetChecked(button)
	return button.checkButton:GetChecked();
end

function LFGRole_SetChecked(button, checked)
	button.checkButton:SetChecked(checked);
end

function LFGRoleButtonTemplate_OnLoad(self)
	if self.role then
		local showDisabled = false;
		self:SetNormalAtlas(GetIconForRole(self.role, showDisabled), TextureKitConstants.IgnoreAtlasSize);
		showDisabled = true;
		self:SetDisabledAtlas(GetIconForRole(self.role, showDisabled), TextureKitConstants.IgnoreAtlasSize);
	end
	
	local classTank, classHealer, classDPS = UnitGetAvailableRoles("player");
	local id = self.role;
	if(self.role == "TANK") then
		if( not classTank ) then
			self.permDisabledTip = YOUR_CLASS_MAY_NOT_PERFORM_ROLE;
		else
			self.permDisabledTip = YOU_ARE_NOT_SPECIALIZED_IN_ROLE;
		end
	elseif(self.role == "HEALER")then
		if( not classHealer ) then
			self.permDisabledTip = YOUR_CLASS_MAY_NOT_PERFORM_ROLE;
		else
			self.permDisabledTip = YOU_ARE_NOT_SPECIALIZED_IN_ROLE;
		end
	elseif(self.role == "DAMAGER")then
		if( not classDPS ) then
			self.permDisabledTip = YOUR_CLASS_MAY_NOT_PERFORM_ROLE;
		else
			self.permDisabledTip = YOU_ARE_NOT_SPECIALIZED_IN_ROLE;
		end
	end
end

function LFGRoleButtonTemplate_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(_G["ROLE_DESCRIPTION_"..self.role], nil, nil, nil, nil, true);
	if ( self.permDisabled ) then
		if(self.permDisabledTip)then
			GameTooltip:AddLine(self.permDisabledTip, 1, 0, 0, true);
		end
	elseif ( self.disabledTooltip and not self:IsEnabled() ) then
		GameTooltip:AddLine(self.disabledTooltip, 1, 0, 0, true);
	end
	GameTooltip:Show();
	LFGFrameRoleCheckButton_OnEnter(self);
end

function LFGRoleButton_LockReasonsTextTable(dungeonID, roleID, textTable)
	local reasons = GetLFDRoleLockInfo(dungeonID, roleID);
	textTable = textTable or {};
	for i = 1, #reasons do
		local text = reasons[i].reason_string or GetLFGInstanceErrorString("SELF", reasons[i].reason_id, reasons[i].sub_reason);
		textTable[text] = true;
	end

	return textTable;
end

function LFG_EnableRoleButton(button)
	button.permDisabled = false;
	button:Enable();
	if( button.lockedIndicator:IsShown() ) then
		button.checkButton:Hide();
		button.checkButton:Disable();
	else
		button.checkButton:Show();
		button.checkButton:Enable();
	end
	if ( button.background ) then
		button.background:Show();
	end
	if ( button.shortageBorder ) then
		button.shortageBorder:SetVertexColor(1, 1, 1);
		button.incentiveIcon.texture:SetVertexColor(1, 1, 1);
		button.incentiveIcon.border:SetVertexColor(1, 1, 1);
	end
end

function LFG_UpdateAvailableRoleButton(button, canBeRole)
	if (canBeRole) then
		LFG_EnableRoleButton(button);
	else
		LFG_PermanentlyDisableRoleButton(button);
	end
end

function LFG_UpdateAvailableRoles(tankButton, healButton, dpsButton, leaderButton)
	local canBeTank, canBeHealer, canBeDPS = C_LFGList.GetAvailableRoles();
	LFG_UpdateAvailableRoleButton(tankButton, canBeTank);
	LFG_UpdateAvailableRoleButton(healButton, canBeHealer);
	LFG_UpdateAvailableRoleButton(dpsButton, canBeDPS);

	if ( leaderButton ) then
		if (not IsInGroup() or UnitIsGroupLeader("player")) then
			LFG_EnableRoleButton(leaderButton);
		else
			LFG_PermanentlyDisableRoleButton(leaderButton);
		end
	end
end

function LFGFrameRoleCheckButton_OnEnter(self)
	if ( self.checkButton:IsEnabled() ) then
		self.checkButton:LockHighlight();
	end
end
