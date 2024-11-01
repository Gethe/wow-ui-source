---------------------------------------------------
-- QUEUE TYPE BUTTON MIXIN
QueueTypeSelectionButtonMixin = {};
function QueueTypeSelectionButtonMixin:OnLoad()
	SelectableButtonMixin.OnLoad(self);

	self.ButtonName:SetText(self.queueTypeString);
	self.Icon:SetAtlas(self.queueTypeIcon);
end

function QueueTypeSelectionButtonMixin:OnClick()
	EventRegistry:TriggerEvent("MatchmakingQueueType.Selected", self, self.partyPlaylistEntry);
end

function QueueTypeSelectionButtonMixin:SetSelected(selected)
	SelectableButtonMixin.SetSelectedState(self, selected);
	if selected then
		self.Icon:SetAtlas(self.queueTypeIconSelected);
		self.ButtonName:SetTextColor(WHITE_FONT_COLOR:GetRGB());		
	else
		self.Icon:SetAtlas(self.queueTypeIcon);
		self.ButtonName:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end
end

function QueueTypeSelectionButtonMixin:SetEnabled(enabled)
	if enabled then
		self:SetAlpha(1);
		self.ButtonName:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		self:Enable();
	else
		self:SetAlpha(0.5);
		self.ButtonName:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self:Disable();
	end
end

---------------------------------------------------
-- QUEUE TYPE SETTINGS FRAME MIXIN
QueueTypeSettingsFrameMixin = { };
local QueueTypeSettingsFrameEvents =
{
	"CLIENT_FEATURE_STATUS_CHANGED",
};

function QueueTypeSettingsFrameMixin:OnLoad()
	self:AddDynamicEventMethod(EventRegistry, "MatchmakingQueueType.Selected", self.OnQueueTypeSelected);

	-- Registering this event differently since it occurs while the frame is hidden
	EventRegistry:RegisterCallback("MatchmakingQueue.LeaveQueue", self.OnLeaveQueue, self);
end

function QueueTypeSettingsFrameMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, QueueTypeSettingsFrameEvents);

	self:UpdateButtons();
end

function QueueTypeSettingsFrameMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, QueueTypeSettingsFrameEvents);
end

function QueueTypeSettingsFrameMixin:OnEvent(event)
	if event == "CLIENT_FEATURE_STATUS_CHANGED" then
		self:UpdateButtons();
	end
end

function QueueTypeSettingsFrameMixin:OnQueueTypeSelected(button, partyPlayIndex)
	local isPartyLeader = C_WoWLabsMatchmaking.IsPartyLeader();
	if isPartyLeader then
		button:SetSelected(true);
		if self.TEMPuseLocalPlayIndex then
			self.TEMPlocalPlayIndex = partyPlayIndex;
		else
			local result = C_WoWLabsMatchmaking.SetPartyPlaylistEntry(partyPlayIndex);
			if result then 
				EventRegistry:TriggerEvent("MatchmakingQueueType.PlayerUpdatedPartyList");
			end
		end
	end

	self:UpdateButtons();
end

function QueueTypeSettingsFrameMixin:OnLeaveQueue()
	self:SetPlayerReady(false);
	self.GameReadyButton:Update();
end

function QueueTypeSettingsFrameMixin:UpdateButtons()
	local isPartyLeader = C_WoWLabsMatchmaking.IsPartyLeader();
	local partySize = C_WoWLabsMatchmaking.GetPartySize();
	local isAlone = C_WoWLabsMatchmaking.IsAloneInWoWLabsParty();
	local currentEventRealmQueues = C_GameEnvironmentManager.GetCurrentEventRealmQueues();

	local trainingActive = bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormTraining) == Enum.EventRealmQueues.PlunderstormTraining;
	local trioActive = bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormTrio) == Enum.EventRealmQueues.PlunderstormTrio;
	local duoActive = bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormDuo) == Enum.EventRealmQueues.PlunderstormDuo;
	local soloActive = bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormSolo) == Enum.EventRealmQueues.PlunderstormSolo;
	
	local enableTraining = isPartyLeader and trainingActive;
	local enableTrio = isPartyLeader and trioActive;
	local enableDuo = isPartyLeader and (partySize == 2 or partySize == 1) and duoActive;
	local enableSolo = isPartyLeader and (partySize == 1) and soloActive;

	if isAlone or isPartyLeader then
		self.QueueContainer.Training:Show();
		self.QueueContainer.Trio:SetShown(trioActive);
		self.QueueContainer.Duo:Show();
		self.QueueContainer.Solo:Show();
		self.QueueContainer.Training:SetEnabled(enableTraining);
		self.QueueContainer.Trio:SetEnabled(enableTrio);
		self.QueueContainer.Duo:SetEnabled(enableDuo);
		self.QueueContainer.Solo:SetEnabled(enableSolo);
	else
		self.QueueContainer.Training:Hide();
		self.QueueContainer.Duo:Hide();
		self.QueueContainer.Solo:Hide();
		self.QueueContainer.Trio:Hide();
	end

	self:UpdateQueueTypeSelection();

	local queueTypeSelection = self.TEMPuseLocalPlayIndex and self.TEMPlocalPlayIndex or C_WoWLabsMatchmaking.GetPartyPlaylistEntry();
	self.QueueContainer.Trio:SetSelected(queueTypeSelection == Enum.PartyPlaylistEntry.TrioGameMode);
	self.QueueContainer.Duo:SetSelected(queueTypeSelection == Enum.PartyPlaylistEntry.DuoGameMode);
	self.QueueContainer.Solo:SetSelected(queueTypeSelection == Enum.PartyPlaylistEntry.SoloGameMode);
	self.QueueContainer.Training:SetSelected(queueTypeSelection == Enum.PartyPlaylistEntry.TrainingGameMode);
	self.QueueContainer:Layout();

	if self.GameReadyButton then
		self.GameReadyButton:Update();
	end
end

function QueueTypeSettingsFrameMixin:IsSelectionActive()
	local currentEventRealmQueues = C_GameEnvironmentManager.GetCurrentEventRealmQueues();

	if self.QueueContainer.Training:IsSelected() then
		return bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormTraining) == Enum.EventRealmQueues.PlunderstormTraining;
	elseif self.QueueContainer.Solo:IsSelected() then
		return bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormSolo) == Enum.EventRealmQueues.PlunderstormSolo;
	elseif self.QueueContainer.Duo:IsSelected() then
		return bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormDuo) == Enum.EventRealmQueues.PlunderstormDuo;
	elseif self.QueueContainer.Trio:IsSelected() then
		return bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormTrio) == Enum.EventRealmQueues.PlunderstormTrio;
	end

	return false;
end

function QueueTypeSettingsFrameMixin:UpdateQueueTypeSelection()
	local needsUpdate = false;
	local queueTypeSelection = self.TEMPuseLocalPlayIndex and self.TEMPlocalPlayIndex or C_WoWLabsMatchmaking.GetPartyPlaylistEntry();

	if (queueTypeSelection == Enum.PartyPlaylistEntry.TrainingGameMode) and not self.QueueContainer.Training:IsEnabled() then
		needsUpdate = true;
	elseif (queueTypeSelection == Enum.PartyPlaylistEntry.TrioGameMode) and not self.QueueContainer.Trio:IsEnabled() then
		needsUpdate = true;
	elseif (queueTypeSelection == Enum.PartyPlaylistEntry.DuoGameMode) and not self.QueueContainer.Duo:IsEnabled() then
		needsUpdate = true;
	elseif (queueTypeSelection == Enum.PartyPlaylistEntry.SoloGameMode) and not self.QueueContainer.Solo:IsEnabled() then
		needsUpdate = true;
	end

	if needsUpdate then
		local updated = false;
		if self.QueueContainer.Training:IsEnabled() then
			updated = C_WoWLabsMatchmaking.SetPartyPlaylistEntry(3);
		elseif self.QueueContainer.Solo:IsEnabled() then
			updated = C_WoWLabsMatchmaking.SetPartyPlaylistEntry(0);
		elseif self.QueueContainer.Duo:IsEnabled() then
			updated = C_WoWLabsMatchmaking.SetPartyPlaylistEntry(1);
		elseif self.QueueContainer.Trio:IsEnabled() then
			updated = C_WoWLabsMatchmaking.SetPartyPlaylistEntry(2);
		end

		if updated then
			EventRegistry:TriggerEvent("MatchmakingQueueType.PlayerUpdatedPartyList");
		end
	end
end

function QueueTypeSettingsFrameMixin:SetPlayerReady(isReady)
	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ENTER_WORLD);
	C_WoWLabsMatchmaking.SetPlayerReady(isReady);
	self:GetParent():Update();
end


QueueReadyButtonMixin = { };
local QueueReadyButtonEvents =
{
	"GLUES_RESUMED",
	"LOBBY_MATCHMAKER_PARTY_UPDATE",
};

function QueueReadyButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self,QueueReadyButtonEvents);
	self:Update();
end

function QueueReadyButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self,QueueReadyButtonEvents);
end

function QueueReadyButtonMixin:OnEvent(event)
	if event == "GLUES_RESUMED" then
		local autoQueue, queueType = C_WoWLabsMatchmaking.GetAutoQueueOnLogout();
		if autoQueue then
			C_WoWLabsMatchmaking.SetAutoQueueOnLogout(false);

			local queueContainer = self:GetParent().QueueContainer;
			local queueTypeButton = queueContainer.Training;
			if queueType == Enum.PartyPlaylistEntry.SoloGameMode then
				queueTypeButton = queueContainer.Solo;
			elseif queueType == Enum.PartyPlaylistEntry.DuoGameMode then
				queueTypeButton = queueContainer.Duo;
			elseif queueType == Enum.PartyPlaylistEntry.TrioGameMode then
				queueTypeButton = queueContainer.Trio;
			end
			
			queueTypeButton:OnClick();
			self:OnClick();
		end
	elseif event == "LOBBY_MATCHMAKER_PARTY_UPDATE" then
		self:Update();
	end
end

function QueueReadyButtonMixin:OnClick()
	self:GetParent():SetPlayerReady(not C_WoWLabsMatchmaking.IsPlayerReady());
end

local function ShowReadyGlow(target, enabled)
	if enabled then
		local offsetX, offsetY, width, height = 24, 0, nil, 94;
		GlowEmitterFactory:Show(target, GlowEmitterMixin.Anims.GreenGlow, offsetX, offsetY, width, height);
	else
		GlowEmitterFactory:Hide(target);
	end
end

function QueueReadyButtonMixin:HasValidQueue()
	if not C_WoWLabsMatchmaking.IsPartyLeader() then
		return true;
	end

	if not self:GetParent():IsSelectionActive() then
		return false;
	end

	if C_WoWLabsMatchmaking.IsAloneInWoWLabsParty() then
		return true;
	end

	local currentEventRealmQueues = C_GameEnvironmentManager.GetCurrentEventRealmQueues();
	local trioActive = bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormTrio) == Enum.EventRealmQueues.PlunderstormTrio;
	local duoActive = bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormDuo) == Enum.EventRealmQueues.PlunderstormDuo;
	local partySize = C_WoWLabsMatchmaking.GetPartySize();
	local trioReady = (partySize <= 3) and trioActive;
	local duoReady = (partySize <= 2) and duoActive;
	return trioReady or duoReady;
end

function QueueReadyButtonMixin:Update()
	self:SetEnabled(C_WoWLabsMatchmaking.CanEnterMatchmaking() and self:HasValidQueue());
	
	if C_WoWLabsMatchmaking.IsPlayerReady() then
		ShowReadyGlow(self, false);
		self:SetText(CANCEL);
	else
		local isPartyLeader = C_WoWLabsMatchmaking.IsPartyLeader();
		local isAlone = C_WoWLabsMatchmaking.IsAloneInWoWLabsParty();

		if isAlone or isPartyLeader then
			self:SetText(WOWLABS_JOIN_GAME);
			ShowReadyGlow(self, false);
		else
			self:SetText(WOWLABS_READY_GAME);
			ShowReadyGlow(self, true);
		end
	end
end


local QueueTimeFormatter = CreateFromMixins(SecondsFormatterMixin);
QueueTimeFormatter:Init(0, SecondsFormatter.Abbreviation.Truncate, true, true);

MatchmakingQueueFrameMixin = { };
function MatchmakingQueueFrameMixin:OnLoad()
	self.currentTimeInQueue = 0;
	self:StartTimer();
end

function MatchmakingQueueFrameMixin:ResetTimer()
	self.currentTimeInQueue = 0;
	self.clientStartTime = GetTime();
	self:UpdateTimerText();
	self.timer:Cancel();
	self:StartTimer();
end

function MatchmakingQueueFrameMixin:OnTick()
	if self:IsShown() then
		local deltaTime = 0;
		local matchmakingStartTime = C_WoWLabsMatchmaking.GetInQueueTimeStart();
		
		if self.clientStartTime == nil then
			self.clientStartTime = GetTime();
		end

		if matchmakingStartTime > 0 then
			deltaTime = GetTime() - (matchmakingStartTime / 1000);
		else
			deltaTime = GetTime() - (self.clientStartTime); -- in case we dont get the start time from C_WoWLabsMatchmaking, we fake the timer
		end

		self.currentTimeInQueue = math.floor(deltaTime);
		self:UpdateTimerText();	
		self:StartTimer();
	end
end

function MatchmakingQueueFrameMixin:UpdateTimerText()
	local time = QueueTimeFormatter:Format(self.currentTimeInQueue);
	self.TimerTimeText:SetText(time);		
end

function MatchmakingQueueFrameMixin:StartTimer()
	self.timer = C_Timer.NewTimer(1, GenerateClosure(self.OnTick, self));
end

function MatchmakingQueueFrameMixin:SetWaiting(waiting)
	self.QueueSquadSize:SetText(WOWLABS_WAITING_ON_OTHER_PLAYERS);
	self.TimerTimeText:SetShown(not waiting);
end

function MatchmakingQueueFrameMixin:SetSquadSize(squadSize)
	if squadSize == Enum.PartyPlaylistEntry.SoloGameMode then
		self.QueueSquadSize:SetText(WOWLABS_FIND_GAME_SOLO);
		self.QueueTimerSpinner.QueueSizeIcon:SetAtlas("plunderstorm-glues-queue-pending-spinner-front-solo");
	elseif squadSize == Enum.PartyPlaylistEntry.DuoGameMode then
		self.QueueSquadSize:SetText(WOWLABS_FIND_GAME_DUO);
		self.QueueTimerSpinner.QueueSizeIcon:SetAtlas("plunderstorm-glues-queue-pending-spinner-front-duo");
	elseif squadSize == Enum.PartyPlaylistEntry.TrioGameMode then
		self.QueueSquadSize:SetText(WOWLABS_FIND_GAME_TRIO);
		self.QueueTimerSpinner.QueueSizeIcon:SetAtlas("plunderstorm-glues-queue-pending-spinner-front-trio");
	else -- fallback case	
		self.QueueSquadSize:SetText(WOWLABS_FIND_GAME_SOLO);
		self.QueueTimerSpinner.QueueSizeIcon:SetAtlas("plunderstorm-glues-queue-pending-spinner-front-solo");
	end
end

LeaveQueueButtonMixin = {};
function LeaveQueueButtonMixin:OnClick()
	EventRegistry:TriggerEvent("MatchmakingQueue.LeaveQueue");
end