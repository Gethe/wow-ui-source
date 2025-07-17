InstanceAbandonMixin = { };

StaticPopupDialogs["VOTE_ABANDON_INSTANCE_VOTE"] = {
	text = VOTE_TO_ABANDON_PROMPT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_PartyInfo.SetInstanceAbandonVoteResponse(true);
	end,
	OnCancel = function(dialog, data, reason)
		-- prevents reentry from OnAccept processing
		if reason == "clicked" then
			C_PartyInfo.SetInstanceAbandonVoteResponse(false);
		end
	end,
	whileDead = 1,
	progressBar = 1,
	GetReservedDialogFrame = function() return InstanceAbandonPopup; end
};

StaticPopupDialogs["VOTE_ABANDON_INSTANCE_WAIT"] = {
	text = VOTE_TO_ABANDON_PROMPT,
	whileDead = 1,
	progressBar = 1,
	GetReservedDialogFrame = function() return InstanceAbandonPopup; end
};

StaticPopupDialogs["VOTE_ABANDON_INSTANCE_SHUTDOWN"] = {
	text = VOTE_TO_ABANDON_PASSED,
	subText = VOTE_TO_ABANDON_LEAVING_INSTANCE,
	whileDead = 1,
	progressBar = 1,
};

StaticPopupDialogs["CONFIRM_LEAVE_RESTRICTED_CHALLENGE_MODE"] = {
	text = CONFIRM_LEAVE_RESTRICTED_CHALLENGE_MODE,
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		C_PartyInfo.ConfirmLeaveParty();
	end,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
};

StaticPopupDialogs["WARN_LEAVE_RESTRICTED_CHALLENGE_MODE"] = {
	text = "",
	GetExpirationText = function(dialog, data, timeleft)
		return string.format(WARN_LEAVE_RESTRICTED_CHALLENGE_MODE, timeleft)
	end,
	whileDead = 1,
	showAlert = 1,
};

StaticPopupDialogs["KEYSTONE_DESERTER_NOTIFICATION"] = {
	button1 = CLOSE,
	text = "%s",
	whileDead = 1,
	hideOnEscape = 1,
};

function InstanceAbandonMixin:OnLoad()
	self:RegisterEvent("INSTANCE_ABANDON_VOTE_STARTED");
	self:RegisterEvent("INSTANCE_ABANDON_VOTE_UPDATED");
	self:RegisterEvent("INSTANCE_ABANDON_VOTE_FINISHED");
	self:RegisterEvent("LEAVE_PARTY_CONFIRMATION");
	self:RegisterEvent("CHALLENGE_MODE_LEAVER_TIMER_STARTED");
	self:RegisterEvent("CHALLENGE_MODE_LEAVER_TIMER_ENDED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("INSTANCE_LEAVER_STATUS_CHANGED");
end

function InstanceAbandonMixin:OnShow()
	if not self.textures then
		-- init
		local numIcons = 5;
		local iconSize = 48;
		local iconSpacing = 6;
		local sidePadding = 60;
		local topPadding = 10;

		self.StatusFrame.textures = { };
		local lastTexture;
		for i = 1, numIcons do
			local texture = self.StatusFrame:CreateTexture(nil, "ARTWORK");
			texture:SetSize(iconSize, iconSize);
			if lastTexture then
				texture:SetPoint("LEFT", lastTexture, "RIGHT", iconSpacing, 0);
			else
				texture:SetPoint("TOPLEFT", sidePadding, -topPadding);
			end
			tinsert(self.StatusFrame.textures, texture);
			lastTexture = texture;
		end
		local width = sidePadding * 2 + numIcons * iconSize + (numIcons - 1) * iconSpacing;
		local height = topPadding + iconSize;
		self.StatusFrame:SetSize(width, height);

		self.VoteText:SetFontObject("UserScaledFontGameNormal");
	end

	local votesRequired, keystoneOwnerVoteWeight = C_PartyInfo.GetInstanceAbandonVoteRequirements();

	if C_PartyInfo.IsChallengeModeKeystoneOwner() then
		self.VoteText:SetFormattedText(VOTE_TO_ABANDON_VOTES_NEEDED_KEYHOLDER, votesRequired, keystoneOwnerVoteWeight);
	else
		self.VoteText:SetFormattedText(VOTE_TO_ABANDON_VOTES_NEEDED, votesRequired);
	end

	self:Refresh();
end

function InstanceAbandonMixin:OnEvent(event, ...)
	if event == "INSTANCE_ABANDON_VOTE_STARTED" then
		local playSound = true;
		self:CheckShowVoteDialog(playSound);
	elseif event == "INSTANCE_ABANDON_VOTE_UPDATED" then
		self:Refresh();
	elseif event == "INSTANCE_ABANDON_VOTE_FINISHED" then
		StaticPopup_Hide("VOTE_ABANDON_INSTANCE_VOTE");
		StaticPopup_Hide("VOTE_ABANDON_INSTANCE_WAIT");
		local votePassed = ...;
		if votePassed then
			self:CheckShowShutdownDialog();
		end
	elseif event == "LEAVE_PARTY_CONFIRMATION" then
		local reason = ...;
		if reason == Enum.LeavePartyConfirmReason.RestrictedChallengeMode then
			StaticPopup_Show("CONFIRM_LEAVE_RESTRICTED_CHALLENGE_MODE");
		end
	elseif event == "CHALLENGE_MODE_LEAVER_TIMER_STARTED" then
		self:CheckShowLeaverWarningDialog();
	elseif event == "CHALLENGE_MODE_LEAVER_TIMER_ENDED" then
		StaticPopup_Hide("WARN_LEAVE_RESTRICTED_CHALLENGE_MODE");
	elseif event == "INSTANCE_LEAVER_STATUS_CHANGED" then
		local isLeaver = ...;
		if isLeaver then
			local text = RED_FONT_COLOR:WrapTextInColorCode(MYTHIC_PLUS_DESERTER_FLAGGED).."|n|n"..MYTHIC_PLUS_DESERTER_CONSEQUENCE;
			StaticPopup_Show("KEYSTONE_DESERTER_NOTIFICATION", text);
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:CheckShowVoteDialog();
		self:CheckShowLeaverWarningDialog();
	end
end

function InstanceAbandonMixin:Refresh()
	local numVoted = C_PartyInfo.GetNumInstanceAbandonGroupVoteResponses();
	for i, texture in ipairs(self.StatusFrame.textures) do
		if i <= numVoted then
			texture:SetAtlas("ui-lfg-roleicon-generic");
		else
			texture:SetAtlas("UI-LFG-RoleIcon-Generic-Disabled");
		end
	end

	local response = C_PartyInfo.GetInstanceAbandonVoteResponse();
	if response == nil then
		self.ResponseText:Hide();
	else
		self.ResponseText:Show();
		local text = response and VOTE_TO_ABANDON_VOTED_YES or VOTE_TO_ABANDON_VOTED_NO;
		self.ResponseText:SetText(text);
	end

	self:Layout();
end

function InstanceAbandonMixin:CheckShowVoteDialog(playSound)
	local duration, timeLeft = C_PartyInfo.GetInstanceAbandonVoteTime();
	if timeLeft > 0 then
		InstanceAbandonFrame:Show();
		local dialog;
		local response = C_PartyInfo.GetInstanceAbandonVoteResponse();
		if response == nil then
			dialog = StaticPopup_Show("VOTE_ABANDON_INSTANCE_VOTE", nil, nil, nil, InstanceAbandonFrame);
		else
			dialog = StaticPopup_Show("VOTE_ABANDON_INSTANCE_WAIT", nil, nil, nil, InstanceAbandonFrame);
		end
		StaticPopup_SetProgressBarTime(dialog, duration, timeLeft);
		if playSound then
			PlaySound(SOUNDKIT.UI_INSTANCE_ABANDON_VOTE);
		end
	end
end

function InstanceAbandonMixin:CheckShowShutdownDialog()
	local duration, timeLeft = C_PartyInfo.GetInstanceAbandonShutdownTime();
	if timeLeft > 0 then
		local dialog = StaticPopup_Show("VOTE_ABANDON_INSTANCE_SHUTDOWN");
		StaticPopup_SetProgressBarTime(dialog, duration, timeLeft);
	end
end

function InstanceAbandonMixin:CheckShowLeaverWarningDialog()
	local secondsLeft = C_ChallengeMode.GetLeaverPenaltyWarningTimeLeft();
	if secondsLeft > 0 then
		local dialog = StaticPopup_Show("WARN_LEAVE_RESTRICTED_CHALLENGE_MODE");
		StaticPopup_SetTimeLeft(dialog, secondsLeft);
	end
end
