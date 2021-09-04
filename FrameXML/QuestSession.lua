local unitTagOrdering = { "player", "party1", "party2", "party3", "party4", };

local function GetMemberUnit(guid)
	for index, unit in ipairs(unitTagOrdering) do
		if UnitGUID(unit) == guid then
			return unit;
		end
	end
end

local function GetMemberName(guid)
	return GetUnitName(GetMemberUnit(guid));
end

local function GetMemberClass(guid)
	return UnitClass(GetMemberUnit(guid));
end

QuestSessionDialogTitleMixin = {};

function QuestSessionDialogTitleMixin:SetText(atlas, text)
	self.Icon:SetAtlas(atlas, true);
	self.Text:SetText(text);
	self:MarkDirty();
end

QuestSessionDialogBodyMixin = {};

function QuestSessionDialogBodyMixin:AdjustTextWidthForAlignment()
	local body = self.Text;
	if body:GetNumLines() == 1 then
		body:SetWidth(0);
	else
		body:SetWidth(body:GetWrappedWidth());
	end
end

function QuestSessionDialogBodyMixin:SetText(text)
	-- If the text wraps at the default width, keep that size and let the height
	-- adjust.  If it doesn't wrap, then set the width to 0 so that the text
	-- stays centered.
	local defaultBodyWidth = 420;
	local body = self.Text;
	self.Icon:Hide();
	body:ClearAllPoints();
	body:SetPoint("TOPLEFT");
	body:SetWidth(defaultBodyWidth);
	body:SetText(text);
	body:SetTextColor(NORMAL_FONT_COLOR:GetRGBA());

	self:AdjustTextWidthForAlignment();
	self:MarkDirty();
end

function QuestSessionDialogBodyMixin:SetWarningText(text)
	local warningSize = 36;
	local padding = 10;
	local warningBodyWidth = 420 - (warningSize + padding);
	local body = self.Text;
	local icon = self.Icon;
	icon:Show();
	icon:SetTexture(STATICPOPUP_TEXTURE_ALERT);
	icon:SetSize(warningSize, warningSize);
	icon:ClearAllPoints();
	icon:SetPoint("TOPLEFT");
	body:ClearAllPoints();
	body:SetPoint("TOPLEFT", icon, "TOPRIGHT", padding, 0);
	body:SetWidth(warningBodyWidth);
	body:SetText(text);
	body:SetTextColor(NORMAL_FONT_COLOR:GetRGBA());

	self:AdjustTextWidthForAlignment();
	self:MarkDirty();
end

QuestSessionMemberMixin = {};

function QuestSessionMemberMixin:SetUnit(unit)
	SetPortraitTexture(self.Portrait, unit);
	self.Name:SetText(GetClassColoredTextForUnit(unit, UnitName(unit)))
	self.guid = UnitGUID(unit);
end

function QuestSessionMemberMixin:IsGUID(guid)
	return self.guid == guid;
end

function QuestSessionMemberMixin:SetState(state)
	self.StatusIcon:SetTexture(state);
end

QuestSessionDialogButtonMixin = {};

function QuestSessionDialogButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local dialog = self:GetParent():GetParent();
	if self.isConfirm then
		dialog:Confirm();
	else
		dialog:Cancel();
	end
end

QuestSessionDialogMinimizeButtonMixin = {};

function QuestSessionDialogMinimizeButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:GetParent():Minimize();
end

QuestSessionDialogMixin = {};

function QuestSessionDialogMixin:OnLoad()
	self.ButtonContainer.Confirm:SetText(self.confirmText);
	self.ButtonContainer.Decline:SetText(self.cancelText);
	self.Divider:SetShown(self.showDivider);
end

function QuestSessionDialogMixin:BaseOnEvent(event, ...)
	self:CheckValidateDialog();
end

function QuestSessionDialogMixin:BaseOnShow()
	if self:RequiresValidateDialog() then
		self:RegisterEvent("PLAYER_REGEN_DISABLED");
		self:RegisterEvent("PLAYER_REGEN_ENABLED");

		self:CheckValidateDialog();
	end
end

function QuestSessionDialogMixin:BaseOnHide()
	if self:RequiresValidateDialog() then
		self:UnregisterEvent("PLAYER_REGEN_DISABLED");
		self:UnregisterEvent("PLAYER_REGEN_ENABLED");
	end
end

function QuestSessionDialogMixin:CheckValidateDialog()
	if self:RequiresValidateDialog() and not self:IsDialogValid() then
		self:StartHideDialog(0.5, ERR_AFFECTING_COMBAT); -- TODO: Add new string
	end
end

function QuestSessionDialogMixin:RequiresValidateDialog()
	-- NOTE: This is set via key/value pairs and should be immutable.
	return self.requiresValidateDialog;
end

function QuestSessionDialogMixin:IsDialogValid()
	return not UnitAffectingCombat("player");
end

function QuestSessionDialogMixin:GetSessionCommand()
	-- Since there is no command for leaving a session, return whatever
	-- the current system command is; this is the most common case.
	-- Can override in derived mixin
	return QuestSessionManager:GetSystemSessionCommand();
end

function QuestSessionDialogMixin:Confirm()
	assert(false); -- implement this in derived mixin
end

function QuestSessionDialogMixin:Cancel()
	-- Can override in derived mixin, most of the time this just cancels
	self:HideImmediate();
end

local HAS_NOT_RESPONSED = "?";

function QuestSessionDialogMixin:AddUnit(unit, previousFrame)
	local guid = UnitGUID(unit);
	local player = self.playerPool:Acquire();
	self.memberFrames[guid] = player;

	if not previousFrame then
		player:SetPoint("LEFT");
	else
		player:SetPoint("LEFT", previousFrame, "RIGHT", 0, 0);
	end

	player:SetUnit(unit); -- TODO: Display something while this texture loads?
	player:Show();

	self:SetMemberResponse(guid, HAS_NOT_RESPONSED);
	return player;
end

function QuestSessionDialogMixin:GetMemberFrame(guid)
	return self.memberFrames and self.memberFrames[guid];
end

function QuestSessionDialogMixin:SetMemberResponse(guid, response)
	self:TrackResponse(guid, response);

	local memberFrame = self:GetMemberFrame(guid);
	if memberFrame then
		if response == HAS_NOT_RESPONSED then
			memberFrame:SetState(READY_CHECK_WAITING_TEXTURE);
		else
			memberFrame:SetState(response and READY_CHECK_READY_TEXTURE or READY_CHECK_NOT_READY_TEXTURE);
		end
	end

	-- Did everybody respond?
	local votesForCount, votesAgainstCount, votesRemainingCount = self:GetResponseCounts();
	if votesRemainingCount > 0 then
		return;
	end

	-- Yep, begin the dialog hide process...
	if votesAgainstCount > 0 then
		PlaySound(SOUNDKIT.QUEST_SESSION_DECLINE);
	end

	self:StartHideDialog();
end

function QuestSessionDialogMixin:GetResponseCounts()
	local votesForCount = 0;
	local votesAgainstCount = 0;
	local votesRemainingCount = 0;

	for trackedGuid, trackedResponse in pairs(self.trackedResponses) do
		if trackedResponse == HAS_NOT_RESPONSED then
			votesRemainingCount = votesRemainingCount + 1;
		elseif trackedResponse then
			votesForCount = votesForCount + 1;
		else
			votesAgainstCount = votesAgainstCount + 1;
		end
	end

	return votesForCount, votesAgainstCount, votesRemainingCount;
end

function QuestSessionDialogMixin:HasTrackedResponse(guid)
	if self.trackedResponses then
		local response = self.trackedResponses[guid];
		return response and response ~= HAS_NOT_RESPONSED;
	end

	return false;
end

function QuestSessionDialogMixin:TrackResponse(guid, response)
	if not self.trackedResponses then
		self.trackedResponses = {};
	end

	self.trackedResponses[guid] = response;
end

function QuestSessionDialogMixin:SetupPlayerContainer()
	self.playerPool = CreateFramePool("FRAME", self.PlayerContainer, "QuestSessionMemberTemplate");

	self.PlayerContainer:Show();
	self.Divider:SetPoint("TOP", self.PlayerContainer, "BOTTOM", 0, -15);
end

function QuestSessionDialogMixin:ResetPlayerContainer()
	if self.playerPool then
		self.playerPool:ReleaseAll();
		self.memberFrames = {};
		self.trackedResponses = {};
	end
end

function QuestSessionDialogMixin:CheckAddUnit(unit, previousFrame, excludeUnit)
	if unit ~= excludeUnit and UnitExists(unit) and UnitIsConnected(unit) and UnitInParty(unit, LE_PARTY_CATEGORY_HOME) then
		return self:AddUnit(unit, previousFrame);
	end

	return previousFrame;
end

function QuestSessionDialogMixin:AddParty(excludeUnit)
	self:ResetPlayerContainer();

	local previousFrame;
	for index, unit in ipairs(unitTagOrdering) do
		previousFrame = self:CheckAddUnit(unit, previousFrame, excludeUnit);
	end
end

function QuestSessionDialogMixin:StartHideDialog(delay, optError)
	QuestSessionManager:CheckClearMinimizedDialog(self);

	if self:IsShown() then
		C_Timer.After(delay or 2, function()
			if optError then
				UIErrorsFrame:AddMessage(optError, RED_FONT_COLOR:GetRGBA());
			end
			self:HideImmediate();
		end);
	end
end

local function PlayDialogSound(sound)
	if sound and sound ~= 0 then
		PlaySound(sound);
	end
end

function QuestSessionDialogMixin:HideImmediate()
	self:ResetPlayerContainer();
	self:PlayHideSound();
	StaticPopupSpecial_Hide(self);
	QuestSessionManager:NotifyDialogHide(self);
end

function QuestSessionDialogMixin:Minimize()
	StaticPopupSpecial_Hide(self);
	QuestSessionManager:NotifyDialogMinimize(self);
end

function QuestSessionDialogMixin:ShowDialog()
	self:PlayShowSound();
	StaticPopupSpecial_Show(self);
	QuestSessionManager:NotifyDialogShow(self);
end

function QuestSessionDialogMixin:SetShowSound(sound)
	self.showSound = sound;
end

function QuestSessionDialogMixin:GetShowSound()
	return self.showSound or SOUNDKIT.IG_MAINMENU_OPEN;
end

function QuestSessionDialogMixin:ClearShowSound()
	self.showSound = 0;
end

function QuestSessionDialogMixin:PlayShowSound()
	PlayDialogSound(self:GetShowSound());
end

function QuestSessionDialogMixin:SetHideSound(sound)
	self.hideSound = sound;
end

function QuestSessionDialogMixin:GetHideSound()
	return self.hideSound or SOUNDKIT.IG_MAINMENU_CLOSE;
end

function QuestSessionDialogMixin:ClearHideSound()
	self.hideSound = 0;
end

function QuestSessionDialogMixin:PlayHideSound()
	PlayDialogSound(self:GetHideSound());
end

function QuestSessionDialogMixin:SetButtonsEnabled(enabled)
	-- TODO: Potentially hide buttons and display "waiting for others..."
	self.ButtonContainer.Confirm:SetEnabled(enabled);
	self.ButtonContainer.Decline:SetEnabled(enabled);

	self:OnButtonsEnabled(enabled);
end

function QuestSessionDialogMixin:OnButtonsEnabled(enabled)
	-- Override in derived mixin, nothing to do here
end

QuestSessionStartDialogMixin = {};

function QuestSessionStartDialogMixin:OnLoad()
	QuestSessionDialogMixin.OnLoad(self);
	self:SetShowSound(SOUNDKIT.QUEST_SESSION_READY_CHECK);
	self:ClearHideSound();

	self:RegisterEvent("QUEST_SESSION_MEMBER_START_RESPONSE");
	self:RegisterEvent("QUEST_SESSION_JOINED");
	self:RegisterEvent("QUEST_SESSION_LEFT");
	self:RegisterEvent("QUEST_SESSION_DESTROYED");

	self:SetupPlayerContainer();
end

function QuestSessionStartDialogMixin:OnEvent(event, ...)
	if event == "QUEST_SESSION_MEMBER_START_RESPONSE" then
		self:SetMemberResponse(...);
	elseif event == "QUEST_SESSION_JOINED" then
		self:StartHideDialog();
	elseif event == "QUEST_SESSION_LEFT" then
		self:StartHideDialog();
	elseif event == "QUEST_SESSION_DESTROYED" then
		self:StartHideDialog();
	end
end

function QuestSessionStartDialogMixin:CheckShow()
	local details = C_QuestSession.GetSessionBeginDetails();
	if details then
		self.Body:SetText(QuestSessionManager:GetStartSessionBodyText());

		self:ResetPlayerContainer();
		self:AddParty(GetMemberUnit(details.guid));
		self:CheckButtonEnabledState();
		self:ShowDialog();
	end
end

function QuestSessionStartDialogMixin:GetSessionCommand()
	return Enum.QuestSessionCommand.Start;
end

function QuestSessionStartDialogMixin:Confirm()
	self:SendSessionResponse(true);

	-- Check whether or not to play the individual confirm sound.  The last person to confirm will not play a sound because the fanfare will
	-- play instead.
	local _, _, votesRemainingCount = self:GetResponseCounts();
	if votesRemainingCount > 1 then
		PlaySound(SOUNDKIT.QUEST_SESSION_INDIVIDUAL_ACCEPT);
	end
end

function QuestSessionStartDialogMixin:Cancel()
	self:SendSessionResponse(false);
end

function QuestSessionStartDialogMixin:SendSessionResponse(accept)
	self:SetButtonsEnabled(false);
	C_QuestSession.SendSessionBeginResponse(accept);
end

function QuestSessionStartDialogMixin:CheckButtonEnabledState()
	local details = C_QuestSession.GetSessionBeginDetails();
	local enabled = not details or details.guid ~= UnitGUID("player");
	self:SetButtonsEnabled(enabled);
end

function QuestSessionStartDialogMixin:OnButtonsEnabled(enabled)
	-- If you still need to respond, you cannot minimize the dialog.
	self.MinimizeButton:SetEnabled(not enabled);

	if enabled then
		local details = C_QuestSession.GetSessionBeginDetails();
		local coloredClassName = GetClassColoredTextForUnit(GetMemberUnit(details.guid), GetMemberName(details.guid));
		self.Title:SetText("QuestSharing-DialogIcon", QUEST_SESSION_START_DIALOG_TITLE_INVITE:format(coloredClassName));
	else
		self.Title:SetText("QuestSharing-DialogIcon", QUEST_SESSION_START_DIALOG_TITLE_WAITING);
	end
end

function QuestSessionStartDialogMixin:OnTimeout()
	self:StartHideDialog();
end

QuestSessionCheckStartDialogMixin = {};

function QuestSessionCheckStartDialogMixin:Setup()
	FlashClientIcon(); -- This dialog will time out, let the user know about it.
	self.Title:SetText("QuestSharing-DialogIcon", QUEST_SESSION_CHECK_START_SESSION_TITLE);
	self.Body:SetText(QuestSessionManager:GetStartSessionBodyText());
	self.Divider:Show();
end

function QuestSessionCheckStartDialogMixin:GetSessionCommand()
	return Enum.QuestSessionCommand.Start;
end

function QuestSessionCheckStartDialogMixin:Confirm()
	C_QuestSession.RequestSessionStart();
	self:HideImmediate();
end

QuestSessionCheckStopDialogMixin = {};

function QuestSessionCheckStopDialogMixin:Setup()
	self.Title:SetText("QuestSharing-Stop-DialogIcon", QUEST_SESSION_STOP_SESSION);
	self.Body:SetWarningText(QUEST_SESSION_CHECK_STOP_SESSION_BODY);
	self.Divider:Show();
end

function QuestSessionCheckStopDialogMixin:GetSessionCommand()
	return Enum.QuestSessionCommand.Stop;
end

function QuestSessionCheckStopDialogMixin:Confirm()
	C_QuestSession.RequestSessionStop();
	self:HideImmediate();
end

QuestSessionCheckLeavePartyDialogMixin = {};

function QuestSessionCheckLeavePartyDialogMixin:Setup()
	self.Title:SetText("QuestSharing-Stop-DialogIcon", QUEST_SESSION_CHECK_LEAVE_PARTY_TITLE);
	self.Body:SetWarningText(QUEST_SESSION_CHECK_LEAVE_PARTY_BODY);
	self.Divider:Show();
end

function QuestSessionCheckLeavePartyDialogMixin:Confirm()
	C_PartyInfo.ConfirmLeaveParty();
	self:HideImmediate();
end

QuestSessionCheckConvertToRaidDialogMixin = {};

function QuestSessionCheckConvertToRaidDialogMixin:Setup()
	self.Title:SetText("QuestSharing-Stop-DialogIcon", QUEST_SESSION_CHECK_CONVERT_TO_RAID_TITLE);
	self.Body:SetWarningText(QUEST_SESSION_CHECK_CONVERT_TO_RAID_BODY);
	self.Divider:Show();
end

function QuestSessionCheckConvertToRaidDialogMixin:Confirm()
	C_PartyInfo.ConfirmConvertToRaid();
	self:HideImmediate();
end

ConfirmJoinGroupRequestDialogMixin = {};

function ConfirmJoinGroupRequestDialogMixin:GetTitle(confirmationType, willConvertToRaid)
	local title = QUEST_SESSION_CHECK_INVITE_TITLE;
	if confirmationType == LE_INVITE_CONFIRMATION_REQUEST then
		title = QUEST_SESSION_CHECK_GROUP_INVITE_CONFIRMATION_TITLE_REQUEST;
	elseif confirmationType == LE_INVITE_CONFIRMATION_SUGGEST then
		title = QUEST_SESSION_CHECK_GROUP_INVITE_CONFIRMATION_TITLE_REFERRAL;
	end

	local atlas = "QuestSharing-DialogIcon";
	if willConvertToRaid then
		atlas = "QuestSharing-Stop-DialogIcon";
	end

	return atlas, title;
end

function ConfirmJoinGroupRequestDialogMixin:GetBody(confirmationBaseText, willConvertToRaid)
	local body = QUEST_SESSION_CHECK_GROUP_INVITE_CONFIRMATION_BODY;
	if willConvertToRaid then
		body = QUEST_SESSION_CHECK_GROUP_INVITE_CONFIRMATION_CONVERT_TO_RAID_BODY;
	end

	return confirmationBaseText .. "\n\n" .. body;
end

function ConfirmJoinGroupRequestDialogMixin:Setup(invite, confirmationBaseText)
	local confirmationType, name, guid, rolesInvalid, willConvertToRaid = GetInviteConfirmationInfo(invite);

	self.inviteConfirmation = invite;
	self.Title:SetText(self:GetTitle(confirmationType, willConvertToRaid));
	self.Body:SetWarningText(self:GetBody(confirmationBaseText, willConvertToRaid));
	self.Divider:Show();
	self:SetShowSound(SOUNDKIT.IG_PLAYER_INVITE);
end

function ConfirmJoinGroupRequestDialogMixin:Confirm()
	RespondToInviteConfirmation(self.inviteConfirmation, true);
	self:HideImmediate();
end

function ConfirmJoinGroupRequestDialogMixin:Cancel()
	RespondToInviteConfirmation(self.inviteConfirmation, false);
	self:HideImmediate();
end

ConfirmInviteToGroupDialogMixin = {};

function ConfirmInviteToGroupDialogMixin:GetTitle(willConvertToRaid)
	local atlas = "QuestSharing-DialogIcon";
	if willConvertToRaid then
		atlas = "QuestSharing-Stop-DialogIcon";
	end

	return atlas, QUEST_SESSION_CHECK_GROUP_INVITE_CONFIRMATION_TITLE;
end

function ConfirmInviteToGroupDialogMixin:GetBody(name, willConvertToRaid)
	if willConvertToRaid then
		return QUEST_SESSION_CHECK_DIRECT_RAID_INVITE_CONFIRMATION_BODY:format(name);
	else
		return QUEST_SESSION_CHECK_DIRECT_GROUP_INVITE_CONFIRMATION_BODY:format(name);
	end
end

function ConfirmInviteToGroupDialogMixin:Setup(name, willConvertToRaid)
	self.inviteName = name;
	self.Title:SetText(self:GetTitle(willConvertToRaid));
	self.Body:SetWarningText(self:GetBody(name, willConvertToRaid));
	self.Divider:Show();
	self:SetShowSound(SOUNDKIT.IG_PLAYER_INVITE);
end

function ConfirmInviteToGroupDialogMixin:Confirm()
	C_PartyInfo.ConfirmInviteUnit(self.inviteName);
	self:HideImmediate();
end

function ConfirmInviteToGroupDialogMixin:Cancel()
	self:HideImmediate();
end

ConfirmInviteToGroupReceivedDialogMixin = {};

function ConfirmInviteToGroupReceivedDialogMixin:OnUpdate()
	if self.timeout then
		if GetTime() >= self.timeout then
			self:HideImmediate();
			self.timeout = nil;
		end
	end
end

function ConfirmInviteToGroupReceivedDialogMixin:Setup(name, text)
	self.timeout = GetTime() + STATICPOPUP_TIMEOUT;
	self.Title:SetText("QuestSharing-DialogIcon", QUEST_SESSION_INVITE_RECEIVED_TITLE);
	self.Body:SetText(text);
	self.Divider:Show();
	self:SetShowSound(SOUNDKIT.IG_PLAYER_INVITE);
end

function ConfirmInviteToGroupReceivedDialogMixin:Confirm()
	AcceptGroup();
	self:HideImmediate();
end

function ConfirmInviteToGroupReceivedDialogMixin:Cancel()
	DeclineGroup();
	self:HideImmediate();
end

ConfirmBNJoinGroupRequestDialogMixin = {};

function ConfirmBNJoinGroupRequestDialogMixin:Setup(...)
	self.confirmationArgs = { ..., n = select("#", ...), };
	self.Title:SetText("QuestSharing-DialogIcon", QUEST_SESSION_CHECK_REQUEST_TO_JOIN_TITLE);
	self.Body:SetWarningText(QUEST_SESSION_CHECK_REQUEST_TO_JOIN_BODY_UNRESTRICTED);
	self.Divider:Show();
	self:SetShowSound(SOUNDKIT.IG_PLAYER_INVITE);
end

function ConfirmBNJoinGroupRequestDialogMixin:Confirm()
	ConfirmBNRequestInviteFriend(unpack(self.confirmationArgs));
	self:HideImmediate();
end

function ConfirmBNJoinGroupRequestDialogMixin:Cancel()
	self:HideImmediate();
end

ConfirmRequestToJoinGroupDialogMixin = {};

function ConfirmRequestToJoinGroupDialogMixin:Setup(target, targetLevelLink, tank, healer, dps)
	self.target = target;
	self.tank = tank;
	self.healer = healer;
	self.dps = dps;

	self.Title:SetText("QuestSharing-DialogIcon", QUEST_SESSION_CHECK_REQUEST_TO_JOIN_TITLE);

	if targetLevelLink == 0 or targetLevelLink >= UnitLevel("player") then
		self.Body:SetWarningText(QUEST_SESSION_CHECK_REQUEST_TO_JOIN_BODY_LEVEL_UNRESTRICTED);
	else
		self.Body:SetWarningText(QUEST_SESSION_CHECK_REQUEST_TO_JOIN_BODY_LEVEL_RESTRICTED:format(targetLevelLink));
	end

	self.Divider:Show();
	self:SetShowSound(SOUNDKIT.IG_PLAYER_INVITE);
end

function ConfirmRequestToJoinGroupDialogMixin:Confirm()
	C_PartyInfo.ConfirmRequestInviteFromUnit(self.target, self.tank, self.healer, self.dps);
	self:HideImmediate();
end

function ConfirmRequestToJoinGroupDialogMixin:Cancel()
	self:HideImmediate();
end

ConfirmInviteTravelPassConfirmationDialogMixin = {};

function ConfirmInviteTravelPassConfirmationDialogMixin:Setup(target, guid)
	self.target = target;
	self.guid = guid;
	self.Title:SetText("QuestSharing-DialogIcon", QUEST_SESSION_CHECK_GROUP_INVITE_CONFIRMATION_TITLE);
	self.Body:SetWarningText(QUEST_SESSION_CHECK_DIRECT_GROUP_INVITE_CONFIRMATION_BODY:format(target));
	self.Divider:Show();
	self:SetShowSound(SOUNDKIT.IG_PLAYER_INVITE);
end

function ConfirmInviteTravelPassConfirmationDialogMixin:Confirm()
	C_PartyInfo.ConfirmInviteTravelPass(self.target, self.guid);
	self:HideImmediate();
end

function ConfirmInviteTravelPassConfirmationDialogMixin:Cancel()
	self:HideImmediate();
end

local notifications = {};
local NOTIFICATION_USES_PLAYER_NAME = true;
local function AddNotification(notification, message, sound, usesName)
	notifications[notification] = { message = message, sound = sound, usesName = usesName };
end

local function FormatNotificationMessage(notification, guid)
	if notification.usesName then
		return notification.message:format(GetMemberName(guid));
	end

	return notification.message;
end

local function GetNotification(resultCode, guid)
	resultCode = resultCode or Enum.QuestSessionResult.Unknown;
	local notification = notifications[resultCode];

	if notification then
		return FormatNotificationMessage(notification, guid), notification.sound;
	end
end

local function CheckDisplayMessageForNotification(resultCode, guid)
	local message, sound = GetNotification(resultCode, guid);
	if message then
		ChatFrame_DisplaySystemMessageInPrimary(message);
	end

	if sound then
		PlaySound(sound);
	end
end

-- NOTE: If the enum isn't here, then we don't want to display a message for it.
AddNotification(Enum.QuestSessionResult.NotInParty, ERR_QUEST_SESSION_RESULT_NOT_IN_PARTY);
AddNotification(Enum.QuestSessionResult.InvalidOwner, ERR_QUEST_SESSION_RESULT_INVALID_OWNER_S, nil, NOTIFICATION_USES_PLAYER_NAME);
AddNotification(Enum.QuestSessionResult.AlreadyActive, ERR_QUEST_SESSION_RESULT_ALREADY_ACTIVE);
AddNotification(Enum.QuestSessionResult.InRaid, ERR_QUEST_SESSION_RESULT_IN_RAID);
AddNotification(Enum.QuestSessionResult.OwnerRefused, ERR_QUEST_SESSION_RESULT_OWNER_REFUSED_S, nil, NOTIFICATION_USES_PLAYER_NAME);
AddNotification(Enum.QuestSessionResult.Timeout, ERR_QUEST_SESSION_RESULT_TIMEOUT, SOUNDKIT.QUEST_SESSION_DECLINE);
AddNotification(Enum.QuestSessionResult.Disabled, ERR_QUEST_SESSION_RESULT_DISABLED);
AddNotification(Enum.QuestSessionResult.Started, ERR_QUEST_SESSION_RESULT_STARTED, SOUNDKIT.QUEST_SESSION_ACTIVATE);
AddNotification(Enum.QuestSessionResult.Stopped, ERR_QUEST_SESSION_RESULT_STOPPED, SOUNDKIT.QUEST_SESSION_DEACTIVATE);
AddNotification(Enum.QuestSessionResult.Left, ERR_QUEST_SESSION_RESULT_LEFT, SOUNDKIT.QUEST_SESSION_DEACTIVATE);
AddNotification(Enum.QuestSessionResult.OwnerLeft, ERR_QUEST_SESSION_RESULT_STOPPED);
AddNotification(Enum.QuestSessionResult.PartyDestroyed, ERR_QUEST_SESSION_RESULT_STOPPED, SOUNDKIT.QUEST_SESSION_DEACTIVATE);
AddNotification(Enum.QuestSessionResult.ReadyCheckFailed, ERR_QUEST_SESSION_RESULT_READY_CHECK_FAILED);
AddNotification(Enum.QuestSessionResult.AlreadyMember, ERR_QUEST_SESSION_RESULT_ALREADY_MEMBER);
AddNotification(Enum.QuestSessionResult.NotOwner, ERR_QUEST_SESSION_RESULT_NOT_OWNER);
AddNotification(Enum.QuestSessionResult.AlreadyOwner, ERR_QUEST_SESSION_RESULT_ALREADY_OWNER);
AddNotification(Enum.QuestSessionResult.AlreadyJoined, ERR_QUEST_SESSION_RESULT_ALREADY_JOINED);
AddNotification(Enum.QuestSessionResult.NotMember, ERR_QUEST_SESSION_RESULT_NOT_MEMBER);
AddNotification(Enum.QuestSessionResult.Busy, ERR_QUEST_SESSION_RESULT_BUSY);
AddNotification(Enum.QuestSessionResult.JoinRejected, ERR_QUEST_SESSION_RESULT_JOIN_REJECTED);
AddNotification(Enum.QuestSessionResult.Resync, CreateAtlasMarkup("QuestSharing-QuestLog-Replay") .. ERR_QUEST_SESSION_RESULT_RESYNC, SOUNDKIT.QUEST_SESSION_RESYNC);
AddNotification(Enum.QuestSessionResult.QuestNotCompleted, ERR_QUEST_SESSION_RESULT_QUEST_NOT_COMPLETED);
AddNotification(Enum.QuestSessionResult.Restricted, ERR_QUEST_SESSION_RESULT_RESTRICTED);
AddNotification(Enum.QuestSessionResult.InPetBattle, ERR_QUEST_SESSION_RESULT_IN_PET_BATTLE);
AddNotification(Enum.QuestSessionResult.InvalidPublicParty, ERR_QUEST_SESSION_RESULT_UNKNOWN);
AddNotification(Enum.QuestSessionResult.Unknown, ERR_QUEST_SESSION_RESULT_UNKNOWN);
AddNotification(Enum.QuestSessionResult.InCombat, ERR_QUEST_SESSION_RESULT_IN_COMBAT);
AddNotification(Enum.QuestSessionResult.MemberInCombat, ERR_QUEST_SESSION_RESULT_MEMBER_IN_COMBAT);

QuestSessionManagerMixin = {};

local questSessionUpdateEvents =
{
	"GROUP_FORMED",
	"GROUP_LEFT",
	"GROUP_ROSTER_UPDATE",
	"QUEST_SESSION_JOINED",
	"QUEST_SESSION_LEFT",
	"QUEST_SESSION_CREATED",
	"QUEST_SESSION_DESTROYED",
};

function QuestSessionManagerMixin:RegisterUpdateEvents()
	for eventName in pairs(questSessionUpdateEvents) do
		self:RegisterEvent(eventName);
	end
end

function QuestSessionManagerMixin:OnLoad()
	self:RegisterEvent("QUEST_SESSION_MEMBER_CONFIRM");
	self:RegisterEvent("QUEST_SESSION_NOTIFICATION");
	self:RegisterEvent("QUEST_SESSION_ENABLED_STATE_CHANGED");
	self:RegisterEvent("LEAVE_PARTY_CONFIRMATION");
	self:RegisterEvent("CONVERT_TO_RAID_CONFIRMATION");
	self:RegisterEvent("QUEST_REMOVED");
	self:RegisterEvent("BNET_REQUEST_INVITE_CONFIRMATION");
	self:RegisterEvent("REQUEST_INVITE_CONFIRMATION");
	self:RegisterEvent("INVITE_TRAVEL_PASS_CONFIRMATION");

	FrameUtil.RegisterFrameForEvents(self, questSessionUpdateEvents);
	questSessionUpdateEvents = tInvert(questSessionUpdateEvents);

	self:RegisterUpdateEvents();

	self:CheckShowSessionStartPrompt();
end

function QuestSessionManagerMixin:OnEvent(event, ...)
	if event == "QUEST_SESSION_MEMBER_CONFIRM" then
		self:CheckShowSessionStartPrompt();
	elseif event == "QUEST_SESSION_NOTIFICATION" then
		self:OnQuestSessionNotification(...);
	elseif event == "QUEST_SESSION_ENABLED_STATE_CHANGED" then
		self:OnEnabledStateChanged(...);
	elseif event == "LEAVE_PARTY_CONFIRMATION" then
		self:ShowCheckDialog(self.CheckLeavePartyDialog);
	elseif event == "CONVERT_TO_RAID_CONFIRMATION" then
		self:ShowCheckDialog(self.CheckConvertToRaidDialog);
	elseif event == "QUEST_REMOVED" then
		self:OnQuestRemoved(...);
	elseif event == "BNET_REQUEST_INVITE_CONFIRMATION" then
		self:CheckShowBNetRequestInviteConfirmation(...);
	elseif event == "REQUEST_INVITE_CONFIRMATION" then
		self:CheckShowRequestInviteConfirmation(...);
	elseif event == "INVITE_TRAVEL_PASS_CONFIRMATION" then
		self:CheckShowInviteTravelPassConfirmation(...);
	end

	if questSessionUpdateEvents[event] then
		self:NotifyUpdate();
	end
end

function QuestSessionManagerMixin:OnQuestRemoved(questID, wasReplayQuest)
	if wasReplayQuest then
		QuestEventListener:AddCallback(questID, function()
			ChatFrame_DisplaySystemMessageInPrimary(QUEST_SESSION_REPLAY_QUEST_REMOVED:format(QuestUtils_GetQuestName(questID)));
		end);
	end
end

function QuestSessionManagerMixin:CheckShowSessionStartPrompt()
	self.StartDialog:CheckShow();
end

function QuestSessionManagerMixin:CheckShowBNetRequestInviteConfirmation(gameAccountID, questSessionActive, tank, healer, dps)
	if questSessionActive then
		self:ShowCheckDialog(self.ConfirmBNJoinGroupRequestDialog, gameAccountID, tank, healer, dps);
	else
		ConfirmBNRequestInviteFriend(gameAccountID, tank, healer, dps);
	end
end

function QuestSessionManagerMixin:CheckShowRequestInviteConfirmation(target, targetLevelLink, questSessionActive, tank, healer, dps)
	if questSessionActive then
		self:ShowCheckDialog(self.ConfirmRequestToJoinGroupDialog, target, targetLevelLink, tank, healer, dps);
	else
		C_PartyInfo.ConfirmRequestInviteFromUnit(target, tank, healer, dps);
	end
end

function QuestSessionManagerMixin:CheckShowInviteTravelPassConfirmation(target, guid, willConvertToRaid, questSessionActive)
	if questSessionActive then
		self:ShowCheckDialog(self.ConfirmInviteTravelPassConfirmationDialog, target, guid);
	else
		C_PartyInfo.ConfirmInviteTravelPass(target, guid);
	end
end

function QuestSessionManagerMixin:ShowGroupInviteConfirmation(invite, text)
	self:ShowCheckDialog(self.ConfirmJoinGroupRequestDialog, invite, text);
end

function QuestSessionManagerMixin:ShowGroupInviteReceivedConfirmation(name, text)
	self:ShowCheckDialog(self.ConfirmInviteToGroupReceivedDialog, name, text);
end

function QuestSessionManagerMixin:OnInviteToPartyConfirmation(name, willConvertToRaid)
	self:ShowCheckDialog(self.ConfirmInviteToGroupDialog, name, willConvertToRaid);
end

function QuestSessionManagerMixin:IsTimeout(resultCode)
	return resultCode == Enum.QuestSessionResult.MemberTimeout or resultCode == Enum.QuestSessionResult.Timeout;
end

function QuestSessionManagerMixin:ShouldNotificationDismissDialogs(resultCode)
	return resultCode == Enum.QuestSessionResult.InRaid or self:IsTimeout(resultCode);
end

function QuestSessionManagerMixin:OnQuestSessionNotification(resultCode, guid)
	CheckDisplayMessageForNotification(resultCode, guid);

	if self:IsTimeout(resultCode) then
		self.StartDialog:OnTimeout();
	end

	if self:ShouldNotificationDismissDialogs(resultCode) then
		-- TODO: Play error sound?
		self:DismissDialogs();
	end

	self:NotifyUpdate();
end

function QuestSessionManagerMixin:OnEnabledStateChanged(enabled)
	if not enabled then
		self:DismissDialogs();
	end

	self:NotifyUpdate();
end

function QuestSessionManagerMixin:SetMinimizedDialog(dialog)
	assert(self.minimizedDialog == nil);
	self.minimizedDialog = dialog;
end

function QuestSessionManagerMixin:GetMinimizedDialog()
	return self.minimizedDialog;
end

function QuestSessionManagerMixin:GetActiveDialog()
	for index, frame in ipairs(self.SessionManagementDialogs) do
		if frame:IsVisible() then
			return frame;
		end
	end
end

function QuestSessionManagerMixin:CheckClearMinimizedDialog(dialog)
	if self.minimizedDialog == dialog then
		self.minimizedDialog = nil;
	end
end

function QuestSessionManagerMixin:ClearMinimizedDialog()
	self.minimizedDialog = nil;
end

function QuestSessionManagerMixin:DismissDialogs()
	for index, frame in ipairs(self.SessionManagementDialogs) do
		frame:HideImmediate();
	end

	self:ClearMinimizedDialog();
end

function QuestSessionManagerMixin:NotifyDialogShow(dialog)
	self:NotifyUpdate();
	self:CheckMutuallyExclusiveDialogs(dialog);
end

function QuestSessionManagerMixin:NotifyDialogHide(dialog)
	self:CheckClearMinimizedDialog(dialog);
	self:NotifyUpdate();

end

function QuestSessionManagerMixin:NotifyDialogMinimize(dialog)
	self:SetMinimizedDialog(dialog);
	self:NotifyUpdate();
end

function QuestSessionManagerMixin:NotifyUpdate()
	EventRegistry:TriggerEvent("QuestSessionManager.Update");
end

function QuestSessionManagerMixin:CheckMutuallyExclusiveDialogs(shownDialog)
	if shownDialog == self.StartDialog and self.CheckStartDialog:IsShown() then
		self.CheckStartDialog:HideImmediate();
	end
end

function QuestSessionManagerMixin:GetSessionManagementFailureReason()
	if self:GetActiveDialog() then
		return "activeDialog";
	end

	local command = self:GetSessionCommand();
	if command == Enum.QuestSessionCommand.None then
		return "noCommand";
	end

	if command == Enum.QuestSessionCommand.Start and UnitAffectingCombat("player") then
		return "inCombat";
	end

	return nil;
end

function QuestSessionManagerMixin:IsSessionManagementEnabled()
	return self:GetSessionManagementFailureReason() == nil;
end

function QuestSessionManagerMixin:StartSession()
	self:ShowCheckDialog(self.CheckStartDialog);
end

function QuestSessionManagerMixin:StopSession()
	self:ShowCheckDialog(self.CheckStopDialog);
end

function QuestSessionManagerMixin:ShowCheckDialog(dialog, ...)
	dialog:Setup(...);
	dialog:ShowDialog();
end

function QuestSessionManagerMixin:GetSessionCommand()
	local dialog = self:GetMinimizedDialog() or self:GetActiveDialog();
	if dialog then
		return dialog:GetSessionCommand();
	end

	return self:GetSystemSessionCommand();
end

function QuestSessionManagerMixin:GetSystemSessionCommand()
	-- Prefer pending over available
	local command = C_QuestSession.GetPendingCommand();
	if command == Enum.QuestSessionCommand.None then
		return C_QuestSession.GetAvailableSessionCommand();
	end

	return command;
end

function QuestSessionManagerMixin:ExecuteSessionCommand()
	local dialog = self:GetMinimizedDialog();
	if dialog then
		StaticPopupSpecial_Show(dialog);
		self:ClearMinimizedDialog();
		self:NotifyDialogShow(dialog);
	else
		local command = C_QuestSession.GetAvailableSessionCommand();
		if command == Enum.QuestSessionCommand.Start then
			self:StartSession();
		elseif command == Enum.QuestSessionCommand.Stop then
			self:StopSession();
		end
	end
end

function QuestSessionManagerMixin:ShouldSessionManagementUIBeVisible()
	return C_QuestSession.Exists() or QuestSessionManager:GetSessionCommand() ~= Enum.QuestSessionCommand.None;
end

function QuestSessionManagerMixin:GetProposedPlayerLevel()
	local proposedSessionLevel = C_QuestSession.GetProposedMaxLevelForSession();
	return math.min(UnitLevel("player"), proposedSessionLevel);
end

function QuestSessionManagerMixin:GetStartSessionBodyText()
	local proposedLevel = QuestSessionManager:GetProposedPlayerLevel();
	local bodyText = proposedLevel < UnitLevel("player") and QUEST_SESSION_CHECK_START_SESSION_BODY or QUEST_SESSION_CHECK_START_SESSION_BODY_UNRESTRICTED;
	return bodyText:format(proposedLevel); -- NOTE: Always passing the level into the string, just in case.
end