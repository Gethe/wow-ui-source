function CanStartQuestSession()
	return IsInGroup() and not C_QuestSession.Exists();
end

function CanJoinQuestSession()
	return C_QuestSession.Exists() and not C_QuestSession.HasJoined();
end

function CanDropQuestSession()
	return C_QuestSession.HasJoined();
end

QuestSessionMemberMixin = {};

function QuestSessionMemberMixin:SetPortrait(unit)
	SetPortraitTexture(self.Portrait, unit);
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
	local dialog = self:GetParent():GetParent();
	if self.isConfirm then
		dialog:Confirm();
	else
		dialog:Cancel();
	end
end

QuestSessionDialogMixin = {};

function QuestSessionDialogMixin:OnLoad()
	ResizeLayoutMixin.OnLoad(self); -- TODO: Convert layoutFrames to intrinsics?  this is painful

	self.ButtonContainer.Confirm:SetText(self.confirmText);
	self.ButtonContainer.Decline:SetText(self.cancelText);
	self.Divider:SetShown(self.showDivider);
end

function QuestSessionDialogMixin:OnHide()
	self:ResetPlayerContainer();
end

function QuestSessionDialogMixin:ShowDialog()
	StaticPopupSpecial_Show(self);
end

function QuestSessionDialogMixin:Confirm()
	assert(false); -- implement this in derived class
end

function QuestSessionDialogMixin:Cancel()
	assert(false); -- implement this in derived class
end

local HAS_NOT_RESPONSED = "?";

function QuestSessionDialogMixin:AddUnit(unit, previousFrame)
	local guid = UnitGUID(unit);
	local player = self.playerPool:Acquire();
	self.memberFrames[guid] = player;

	if not previousFrame then
		player:SetPoint("LEFT");
	else
		player:SetPoint("LEFT", previousFrame, "RIGHT", 7, 0);
	end

	player:SetPortrait(unit); -- TODO: Display something while this texture loads?
	player:Show();

	self:SetMemberResponse(guid, HAS_NOT_RESPONSED);
	return player;
end

function QuestSessionDialogMixin:GetMemberFrame(guid)
	return self.memberFrames[guid];
end

function QuestSessionDialogMixin:SetMemberResponse(guid, response)
	self.trackedResponses[guid] = response;

	local memberFrame = self:GetMemberFrame(guid);
	if memberFrame then
		if response == HAS_NOT_RESPONSED then
			memberFrame:SetState(READY_CHECK_WAITING_TEXTURE);
		else
			memberFrame:SetState(response and READY_CHECK_READY_TEXTURE or READY_CHECK_NOT_READY_TEXTURE);
		end
	end

	-- Did everybody respond?
	for k, v in pairs(self.trackedResponses) do
		if v == HAS_NOT_RESPONSED then
			-- Nope, bail.
			return;
		end
	end

	-- Yep, begin the dialog hide process...
	self:StartHideDialog();
end

function QuestSessionDialogMixin:HasTrackedResponse(guid)
	local response = self.trackedResponses[guid];
	return response and response ~= HAS_NOT_RESPONSED;
end

function QuestSessionDialogMixin:SetupPlayerContainer()
	self.playerPool = CreateFramePool("FRAME", self.PlayerContainer, "QuestSessionMemberTemplate");
end

function QuestSessionDialogMixin:ResetPlayerContainer()
	if self.playerPool then
		self.playerPool:ReleaseAll();
		self.memberFrames = {};

		-- This is temporary.  Just something to track player responses so that the dialog can be dismissed properly.
		-- Doesn't work if people leave/join the party at this time; will be replaced with dedicated events to handle dialog tracking
		self.trackedResponses = {};
	end
end

function QuestSessionDialogMixin:CheckAddUnit(unit, previousFrame, excludeGUID)
	if UnitExists(unit) and UnitGUID(unit) ~= excludeGUID then
		return self:AddUnit(unit, previousFrame);
	end

	return previousFrame;
end

local unitTagOrdering = { "player", "party1", "party2", "party3", "party4", };

function QuestSessionDialogMixin:AddParty(excludeGUID)
	self:ResetPlayerContainer();

	local previousFrame;
	for index, unit in ipairs(unitTagOrdering) do
		previousFrame = self:CheckAddUnit(unit, previousFrame, excludeGUID);
	end
end

function QuestSessionDialogMixin:StartHideDialog(delay)
	C_Timer.After(delay or 2, function()
		StaticPopupSpecial_Hide(self);
	end);
end

function QuestSessionDialogMixin:HideImmediate()
	StaticPopupSpecial_Hide(self);
end

function QuestSessionDialogMixin:SetButtonsEnabled(enabled)
	-- TODO: Potentially hide buttons and display "waiting for others..."
	self.ButtonContainer.Confirm:SetEnabled(enabled);
	self.ButtonContainer.Decline:SetEnabled(enabled);
end

QuestSessionStartDialogMixin = {};

function QuestSessionStartDialogMixin:OnLoad()
	QuestSessionDialogMixin.OnLoad(self);
	QuestSessionManager:SetStartDialog(self);

	self:RegisterEvent("QUEST_SESSION_MEMBER_CONFIRM");
	self:RegisterEvent("QUEST_SESSION_MEMBER_START_RESPONSE");
	self:RegisterEvent("QUEST_SESSION_JOINED");
	self:RegisterEvent("QUEST_SESSION_LEFT");
	self:RegisterEvent("QUEST_SESSION_DESTROYED");

	self:SetupPlayerContainer();
	self:CheckShowSessionStartPrompt();
end

function QuestSessionStartDialogMixin:OnEvent(event, ...)
	if event == "QUEST_SESSION_MEMBER_CONFIRM" then
		self:CheckShowSessionStartPrompt();
	elseif event == "QUEST_SESSION_MEMBER_START_RESPONSE" then
		self:SetMemberResponse(...);
	elseif event == "QUEST_SESSION_JOINED" then
		self:StartHideDialog();
	elseif event == "QUEST_SESSION_LEFT" then
		self:StartHideDialog();
	elseif event == "QUEST_SESSION_DESTROYED" then
		self:StartHideDialog();
	end
end

function QuestSessionStartDialogMixin:CheckShowSessionStartPrompt()
	local details = C_QuestSession.GetSessionBeginDetails();
	if details then
		self.Title:SetText(QUEST_SESSION_START_SESSION);
		self.Body:SetText(QUEST_SESSION_UNIFIED_QUERY:format(details.name));

		self:ResetPlayerContainer();
		self:AddParty();
		self:CheckButtonEnabledState();
		self:ShowDialog();
	end
end

function QuestSessionStartDialogMixin:Confirm()
	PlaySound(SOUNDKIT.UI_WORLDQUEST_START);
	self:SendSessionResponse(true);
end

function QuestSessionStartDialogMixin:Cancel()
	PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST);
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

QuestSessionJoinVoteDialogMixin = {};

function QuestSessionJoinVoteDialogMixin:OnLoad()
	QuestSessionDialogMixin.OnLoad(self);

	self:RegisterEvent("QUEST_SESSION_MEMBER_JOIN_RESPONSE");
	self:RegisterEvent("QUEST_SESSION_LEFT");
	self:SetupPlayerContainer();
	QuestSessionManager:SetJoinDialog(self);
end

function QuestSessionJoinVoteDialogMixin:OnEvent(event, ...)
	if event == "QUEST_SESSION_MEMBER_JOIN_RESPONSE" then
		self:SetMemberResponse(...);
	elseif event == "QUEST_SESSION_LEFT" then
		self:StartHideDialog();
	end
end

function QuestSessionJoinVoteDialogMixin:CheckShow()
	self.details = C_QuestSession.GetSessionJoinRequestDetails();
	if self.details then
		self.Title:SetText(QUEST_SESSION_JOIN_SESSION_TITLE:format(self.details.name));
		self.Body:SetText(QUEST_SESSION_JOIN_SESSION_BODY:format(self.details.name));
		self.Body:SetVertexColor(NORMAL_FONT_COLOR:GetRGB());

		self:ResetPlayerContainer();
		self:AddParty(self.details.guid);
		self:CheckButtonEnabledState();
		self:ShowDialog();
	end
end

function QuestSessionJoinVoteDialogMixin:Confirm()
	PlaySound(SOUNDKIT.UI_WORLDQUEST_START);
	self:SendSessionResponse(true);
end

function QuestSessionJoinVoteDialogMixin:Cancel()
	PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST);
	self:SendSessionResponse(false);
end

function QuestSessionJoinVoteDialogMixin:SendSessionResponse(accept)
	assert(self.details);
	self:SetButtonsEnabled(false);
	C_QuestSession.SendSessionJoinRequestResponse(self.details.guid, accept);
end

function QuestSessionJoinVoteDialogMixin:CheckButtonEnabledState()
	self:SetButtonsEnabled(not self:HasTrackedResponse());
end

QuestSessionCheckStartDialogMixin = {};

function QuestSessionCheckStartDialogMixin:Setup()
	self.Title:SetText(QUEST_SESSION_CHECK_START_SESSION_TITLE);
	self.Body:SetText(QUEST_SESSION_CHECK_START_SESSION_BODY);
	self.Body:SetVertexColor(NORMAL_FONT_COLOR:GetRGB());
end

function QuestSessionCheckStartDialogMixin:Confirm()
	self:HideImmediate();
	C_QuestSession.RequestSessionStart();
end

function QuestSessionCheckStartDialogMixin:Cancel()
	self:HideImmediate();
end

QuestSessionCheckJoinDialogMixin = {};

function QuestSessionCheckJoinDialogMixin:Setup()
	self.Title:SetText(QUEST_SESSION_CHECK_JOIN_SESSION_TITLE);
	self.Body:SetText(QUEST_SESSION_CHECK_JOIN_SESSION_BODY);
	self.Body:SetVertexColor(NORMAL_FONT_COLOR:GetRGB());
end

function QuestSessionCheckJoinDialogMixin:Confirm()
	self:HideImmediate();
	C_QuestSession.RequestSessionJoin();
end

function QuestSessionCheckJoinDialogMixin:Cancel()
	self:HideImmediate();
end


-- NOTE: If the enum isn't here, then we don't want to display a message for it.
local resultToErrorStr =
{
	[Enum.QuestSessionResult.NotInParty] = ERR_QUEST_SESSION_RESULT_NOT_IN_PARTY,
	[Enum.QuestSessionResult.InvalidOwner] = ERR_QUEST_SESSION_RESULT_INVALID_OWNER_S,
	[Enum.QuestSessionResult.AlreadyActive] = ERR_QUEST_SESSION_RESULT_ALREADY_ACTIVE,
	[Enum.QuestSessionResult.InRaid] = ERR_QUEST_SESSION_RESULT_IN_RAID,
	[Enum.QuestSessionResult.OwnerRefused] = ERR_QUEST_SESSION_RESULT_OWNER_REFUSED_S,
	[Enum.QuestSessionResult.Timeout] = ERR_QUEST_SESSION_RESULT_TIMEOUT,
	[Enum.QuestSessionResult.Disabled] = ERR_QUEST_SESSION_RESULT_DISABLED,
	[Enum.QuestSessionResult.Started] = ERR_QUEST_SESSION_RESULT_STARTED,
	[Enum.QuestSessionResult.Stopped] = ERR_QUEST_SESSION_RESULT_STOPPED,
	[Enum.QuestSessionResult.Left] = ERR_QUEST_SESSION_RESULT_LEFT,
	[Enum.QuestSessionResult.OwnerLeft] = ERR_QUEST_SESSION_RESULT_STOPPED,
	[Enum.QuestSessionResult.PartyDestroyed] = ERR_QUEST_SESSION_RESULT_STOPPED,
	[Enum.QuestSessionResult.ReadyCheckFailed] = ERR_QUEST_SESSION_RESULT_READY_CHECK_FAILED,
	[Enum.QuestSessionResult.AlreadyMember] = ERR_QUEST_SESSION_RESULT_ALREADY_MEMBER,
	[Enum.QuestSessionResult.NotOwner] = ERR_QUEST_SESSION_RESULT_NOT_OWNER,
	[Enum.QuestSessionResult.AlreadyOwner] = ERR_QUEST_SESSION_RESULT_ALREADY_OWNER,
	[Enum.QuestSessionResult.AlreadyJoined] = ERR_QUEST_SESSION_RESULT_ALREADY_JOINED,
	[Enum.QuestSessionResult.NotMember] = ERR_QUEST_SESSION_RESULT_NOT_MEMBER,
	[Enum.QuestSessionResult.Busy] = ERR_QUEST_SESSION_RESULT_BUSY,
	[Enum.QuestSessionResult.JoinRejected] = ERR_QUEST_SESSION_RESULT_JOIN_REJECTED,
	[Enum.QuestSessionResult.Unknown] = ERR_QUEST_SESSION_RESULT_UNKNOWN,
}

local namedResults =
{
	[Enum.QuestSessionResult.InvalidOwner] = true,
	[Enum.QuestSessionResult.OwnerRefused] = true,
}

local function GetMemberName(guid)
	if UnitGUID("player") == guid then
		return GetUnitName("player");
	end

	for i = 1, MAX_PARTY_MEMBERS do
		if UnitGUID("party"..i) == guid then
			return GetUnitName("party"..i);
		end
	end
end

local function GetQuestSessionResultMessage(result, guid)
	result = result or Enum.QuestSessionResult.Unknown;
	local message = resultToErrorStr[result];

	if message then
		if namedResults[result] then
			return message:format(GetMemberName(guid));
		end


		return message;
	end
end

local function CheckDisplayMessageForNotification(result, guid)
	local message = GetQuestSessionResultMessage(result, guid);
	if message then
		ChatFrame_DisplaySystemMessageInPrimary(message);
	end
end

QuestSessionManagerMixin = {};

function QuestSessionManagerMixin:OnLoad()
	self:RegisterEvent("QUEST_SESSION_JOIN_REQUEST");
	self:RegisterEvent("QUEST_SESSION_NOTIFICATION");
end

function QuestSessionManagerMixin:OnEvent(event, ...)
	if event == "QUEST_SESSION_JOIN_REQUEST" then
		self:CheckShowSessionJoinRequestPrompt();
	elseif event == "QUEST_SESSION_NOTIFICATION" then
		self:OnQuestSessionNotification(...);
	end
end

function QuestSessionManagerMixin:SetStartDialog(frame)
	self.StartDialog = frame;
end

function QuestSessionManagerMixin:SetJoinDialog(frame)
	self.JoinDialog = frame;
	self:CheckShowSessionJoinRequestPrompt();
end

function QuestSessionManagerMixin:CheckShowSessionJoinRequestPrompt()
	self.JoinDialog:CheckShow();
end

function QuestSessionManagerMixin:OnQuestSessionNotification(result, guid)
	CheckDisplayMessageForNotification(result, guid);

	if result == Enum.QuestSessionResult.MemberTimeout then
		-- TODO: Figure out if this always implicitly applies to active player
		self.StartDialog:SetMemberResponse(UnitGUID("player"), false);
	end
end

function QuestSessionManagerMixin:StartSession()
	QuestSessionCheckStartDialog:Setup();
	QuestSessionCheckStartDialog:ShowDialog();
end

function QuestSessionManagerMixin:JoinSession()
	QuestSessionCheckJoinDialog:Setup();
	QuestSessionCheckJoinDialog:ShowDialog();
end

function QuestSessionManagerMixin:DropSession()
	C_QuestSession.RequestSessionDrop();
end