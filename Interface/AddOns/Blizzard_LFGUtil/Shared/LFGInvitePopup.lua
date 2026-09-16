--
-- Group invite stuff
--
LFG_INVITE_POPUP_DEFAULT_HEIGHT = 180;

function LFGInvitePopup_UpdateAcceptButton()
	if ( LFGRole_GetChecked(LFGInvitePopupRoleButtonTank) or LFGRole_GetChecked(LFGInvitePopupRoleButtonHealer) or LFGRole_GetChecked(LFGInvitePopupRoleButtonDPS) ) then
		LFGInvitePopupAcceptButton:Enable();
	else
		LFGInvitePopupAcceptButton:Disable();
	end
end

function LFGInvitePopupCheckButton_OnClick(checkButton)
	local popup = LFGInvitePopup;
	if ( not popup.allowMultipleRoles ) then
		for i=1, #popup.RoleButtons do
			local cb = popup.RoleButtons[i].checkButton;
			if ( cb ~= checkButton ) then
				cb:SetChecked(false);
			end
		end
	end

	LFGInvitePopup_UpdateAcceptButton();
end

function LFGInvitePopupAccept_OnClick()
	AcceptGroup(LFGRole_GetChecked(LFGInvitePopupRoleButtonTank), LFGRole_GetChecked(LFGInvitePopupRoleButtonHealer), LFGRole_GetChecked(LFGInvitePopupRoleButtonDPS));
	StaticPopupSpecial_Hide(LFGInvitePopup);
end

function LFGInvitePopupDecline_OnClick()
	DeclineGroup();
	StaticPopupSpecial_Hide(LFGInvitePopup);
end

local function GetWarningText(isQuestSessionActive)
	local warningText = {};

	if WillAcceptInviteRemoveQueues() then
		table.insert(warningText, ACCEPTING_INVITE_WILL_REMOVE_QUEUE);
	end

	if isQuestSessionActive then
		table.insert(warningText, QUEST_SESSION_LFG_WARNING_INVITED_TO_PARTY_WITH_ACTIVE_SYNC);
	end

	return #warningText and table.concat(warningText, "\n\n") or nil;
end

function LFGInvitePopup_Update(inviter, roleTankAvailable, roleHealerAvailable, roleDamagerAvailable, allowMultipleRoles, isQuestSessionActive)
	local self = LFGInvitePopup;
	local canBeTank, canBeHealer, canBeDamager = C_LFGList.GetAvailableRoles();
	local tankButton = LFGInvitePopupRoleButtonTank;
	local healerButton = LFGInvitePopupRoleButtonHealer;
	local damagerButton = LFGInvitePopupRoleButtonDPS;
	local availableRolesField = 0;	--Seems to be a ghetto bit-field
	self.timeOut = StaticPopupTimeoutSec;

	local titleMarkup = isQuestSessionActive and CreateAtlasMarkup("QuestSharing-QuestLog-Replay", 19, 16) or "";
	LFGInvitePopupText:SetFormattedText(titleMarkup .. INVITATION, inviter);

	-- tank
	if ( not canBeTank ) then
		LFG_PermanentlyDisableRoleButton(tankButton);
	elseif ( not roleTankAvailable ) then
		LFG_DisableRoleButton(tankButton);
		tankButton.disabledTooltip = LFG_ROLE_UNAVAILABLE;
	else
		LFG_EnableRoleButton(tankButton);
		tankButton.disabledTooltip = nil;
		availableRolesField = availableRolesField + 2;
	end
	-- healer
	if ( not canBeHealer ) then
		LFG_PermanentlyDisableRoleButton(healerButton);
	elseif ( not roleHealerAvailable ) then
		LFG_DisableRoleButton(healerButton);
		healerButton.disabledTooltip = LFG_ROLE_UNAVAILABLE;
	else
		LFG_EnableRoleButton(healerButton);
		healerButton.disabledTooltip = nil;
		availableRolesField = availableRolesField + 4;
	end
	-- damage
	if ( not canBeDamager ) then
		LFG_PermanentlyDisableRoleButton(damagerButton);
	elseif ( not roleDamagerAvailable ) then
		LFG_DisableRoleButton(damagerButton);
		damagerButton.disabledTooltip = LFG_ROLE_UNAVAILABLE;
	else
		LFG_EnableRoleButton(damagerButton);
		damagerButton.disabledTooltip = nil;
		availableRolesField = availableRolesField + 8;
	end

	-- update whether we can only have 1 role selected
	SetCheckButtonIsRadio(tankButton.checkButton, not allowMultipleRoles);
	SetCheckButtonIsRadio(healerButton.checkButton, not allowMultipleRoles);
	SetCheckButtonIsRadio(damagerButton.checkButton, not allowMultipleRoles);
	self.allowMultipleRoles = allowMultipleRoles;

	-- if only 1 role is available, check it otherwise check none
	tankButton.checkButton:SetChecked(availableRolesField == 2);
	healerButton.checkButton:SetChecked(availableRolesField == 4);
	damagerButton.checkButton:SetChecked(availableRolesField == 8);

	local warningText = GetWarningText(isQuestSessionActive);
	if warningText then
		self.QueueWarningText:SetText(warningText);
		self.QueueWarningText:Show();
		self:SetHeight(LFG_INVITE_POPUP_DEFAULT_HEIGHT + self.QueueWarningText:GetHeight() + 8);
	end

	LFGInvitePopup_UpdateAcceptButton();
end

function LFGInvitePopup_OnUpdate(self, elapsed)
	self.timeOut = self.timeOut - elapsed;
	if ( self.timeOut <= 0 ) then
		LFGInvitePopupDecline_OnClick();
	end
end
