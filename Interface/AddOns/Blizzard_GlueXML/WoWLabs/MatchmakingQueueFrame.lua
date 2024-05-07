---------------------------------------------------
-- GAME MODE BUTTON MIXIN
GameModeSelectionButtonMixin = {};
function GameModeSelectionButtonMixin:OnLoad()
	SelectableButtonMixin.OnLoad(self);

	self.ButtonName:SetText(self.gameModeString);
	self.Icon:SetAtlas(self.gameModeIcon);
end

function GameModeSelectionButtonMixin:OnClick()
	EventRegistry:TriggerEvent("GameMode.Selected", self, self.gameModeSelection);
end

function GameModeSelectionButtonMixin:SetSelected(selected)
	SelectableButtonMixin.SetSelectedState(self, selected);
	if selected then
		self.Icon:SetAtlas(self.gameModeIconSelected);
		self.ButtonName:SetTextColor(WHITE_FONT_COLOR:GetRGB());		
	else
		self.Icon:SetAtlas(self.gameModeIcon);
		self.ButtonName:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end
end

function GameModeSelectionButtonMixin:SetEnabled(enabled)
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
-- GAME MODE SETTINGS FRAME MIXIN
GameModeSettingsFrameMixin = { };
local GameModeSettingsFrameEvents =
{
	"CLIENT_FEATURE_STATUS_CHANGED",
};

function GameModeSettingsFrameMixin:OnLoad()
	self:AddDynamicEventMethod(EventRegistry, "GameMode.Selected", self.OnGameModeSelected);
end

function GameModeSettingsFrameMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, GameModeSettingsFrameEvents);

	self:UpdateButtons();
end

function GameModeSettingsFrameMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, GameModeSettingsFrameEvents);
end

function GameModeSettingsFrameMixin:OnEvent(event)
	if event == "CLIENT_FEATURE_STATUS_CHANGED" then
		self:UpdateButtons();
	end
end

function GameModeSettingsFrameMixin:OnGameModeSelected(button, gameModeSelected)
	local isPartyLeader = C_WoWLabsMatchmaking.IsPartyLeader();
	if isPartyLeader then
		button:SetSelected(true);
		local partyPlayIndex = gameModeSelected == "trio" and 2 or gameModeSelected == "duo" and 1 or 0;
		
		local result = C_WoWLabsMatchmaking.SetPartyPlaylistEntry(partyPlayIndex);
		if result then 
			EventRegistry:TriggerEvent("GameMode.PlayerUpdatedPartyList");
		end
	end
	self:UpdateButtons();
end

function GameModeSettingsFrameMixin:UpdateButtons()
	local isPartyLeader = C_WoWLabsMatchmaking.IsPartyLeader();
	local partySize = C_WoWLabsMatchmaking.GetPartySize();
	local isAlone = C_WoWLabsMatchmaking.IsAloneInWoWLabsParty();
	local currentEventRealmQueues = C_GameEnvironmentManager.GetCurrentEventRealmQueues();

	local trioActive = bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormTrio) == Enum.EventRealmQueues.PlunderstormTrio;
	local duoActive = bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormDuo) == Enum.EventRealmQueues.PlunderstormDuo;
	local soloActive = bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormSolo) == Enum.EventRealmQueues.PlunderstormSolo;
	local enableTrio = isPartyLeader and trioActive;
	local enableDuo = isPartyLeader and (partySize == 2 or partySize == 1) and duoActive;
	local enableSolo = isPartyLeader and (partySize == 1) and soloActive;

	if isAlone or isPartyLeader then
		self.QueueContainer.Trio:SetShown(trioActive);
		self.QueueContainer.Duo:Show();
		self.QueueContainer.Solo:Show();
		self.QueueContainer.Trio:SetEnabled(enableTrio);
		self.QueueContainer.Duo:SetEnabled(enableDuo);
		self.QueueContainer.Solo:SetEnabled(enableSolo);
	else
		self.QueueContainer.Duo:Hide();
		self.QueueContainer.Solo:Hide();
		self.QueueContainer.Trio:Hide();
	end

	self:UpdateGameModeSelection();

	local gameModeSelection = C_WoWLabsMatchmaking.GetPartyPlaylistEntry();
	self.QueueContainer.Trio:SetSelected(gameModeSelection == 2);
	self.QueueContainer.Duo:SetSelected(gameModeSelection == 1);
	self.QueueContainer.Solo:SetSelected(gameModeSelection == 0);
	self.QueueContainer:Layout();

	self.GameReadyButton:Update();
end

function GameModeSettingsFrameMixin:IsSelectionActive()
	local currentEventRealmQueues = C_GameEnvironmentManager.GetCurrentEventRealmQueues();
	if self.QueueContainer.Solo:IsSelected() then
		return bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormSolo) == Enum.EventRealmQueues.PlunderstormSolo;
	elseif self.QueueContainer.Duo:IsSelected() then
		return bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormDuo) == Enum.EventRealmQueues.PlunderstormDuo;
	elseif self.QueueContainer.Trio:IsSelected() then
		return bit.band(currentEventRealmQueues, Enum.EventRealmQueues.PlunderstormTrio) == Enum.EventRealmQueues.PlunderstormTrio;
	end

	return false;
end

function GameModeSettingsFrameMixin:UpdateGameModeSelection()
	local needsUpdate = false;
	local gameModeSelection = C_WoWLabsMatchmaking.GetPartyPlaylistEntry();
	if (gameModeSelection == 2) and not self.QueueContainer.Trio:IsEnabled() then
		needsUpdate = true;
	elseif (gameModeSelection == 1) and not self.QueueContainer.Duo:IsEnabled() then
		needsUpdate = true;
	elseif (gameModeSelection == 0) and not self.QueueContainer.Solo:IsEnabled() then
		needsUpdate = true;
	end

	if needsUpdate then
		local updated = false;
		if self.QueueContainer.Solo:IsEnabled() then
			updated = C_WoWLabsMatchmaking.SetPartyPlaylistEntry(0);
		elseif self.QueueContainer.Duo:IsEnabled() then
			updated = C_WoWLabsMatchmaking.SetPartyPlaylistEntry(1);
		elseif self.QueueContainer.Trio:IsEnabled() then
			updated = C_WoWLabsMatchmaking.SetPartyPlaylistEntry(2);
		end

		if updated then
			EventRegistry:TriggerEvent("GameMode.PlayerUpdatedPartyList");
		end
	end
end

function GameModeSettingsFrameMixin:SetPlayerReady(isReady)
	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ENTER_WORLD);
	C_WoWLabsMatchmaking.SetPlayerReady(isReady);
	self:GetParent():Update();
end


PlunderstormReadyButtonMixin = { };
local PlunderstormReadyButtonEvents =
{
	"LOBBY_MATCHMAKER_PARTY_UPDATE",
};

function PlunderstormReadyButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self,PlunderstormReadyButtonEvents);
	self:Update();
end

function PlunderstormReadyButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self,PlunderstormReadyButtonEvents);
end

function PlunderstormReadyButtonMixin:OnEvent(event)
	if event == "LOBBY_MATCHMAKER_PARTY_UPDATE" then
		self:Update();
	end
end

function PlunderstormReadyButtonMixin:OnClick()
	self:GetParent():SetPlayerReady(not C_WoWLabsMatchmaking.IsPlayerReady());
end

local function ShowReadyGlow(target, enabled)
	if enabled then
		GlowEmitterFactory:SetHeight(94);
		GlowEmitterFactory:SetOffset(24, 0);
		GlowEmitterFactory:Show(target, GlowEmitterMixin.Anims.GreenGlow);
	else
		GlowEmitterFactory:Hide(target);
	end
end

function PlunderstormReadyButtonMixin:HasValidQueue()
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

function PlunderstormReadyButtonMixin:Update()
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
	self.glueStartTime = GetTime();
	self:UpdateTimerText();
	self.timer:Cancel();
	self:StartTimer();
end

function MatchmakingQueueFrameMixin:OnTick()
	if self:IsShown() then
		local deltaTime = 0;
		local matchmakingStartTime = C_WoWLabsMatchmaking.GetInQueueTimeStart();
		
		if self.glueStartTime == nil then
			self.glueStartTime = GetTime();
		end

		if matchmakingStartTime > 0 then
			deltaTime = GetTime() - (matchmakingStartTime / 1000);
		else
			deltaTime = GetTime() - (self.glueStartTime); -- in case we dont get the start time from C_WoWLabsMatchmaking, we fake the timer on the frontend
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
	if squadSize == 0 then
		self.QueueSquadSize:SetText(WOWLABS_FIND_GAME_SOLO);
		self.QueueTimerSpinner.QueueSizeIcon:SetAtlas("plunderstorm-glues-queue-pending-spinner-front-solo");
	elseif squadSize == 1 then
		self.QueueSquadSize:SetText(WOWLABS_FIND_GAME_DUO);
		self.QueueTimerSpinner.QueueSizeIcon:SetAtlas("plunderstorm-glues-queue-pending-spinner-front-duo");
	elseif squadSize == 2 then
		self.QueueSquadSize:SetText(WOWLABS_FIND_GAME_TRIO);
		self.QueueTimerSpinner.QueueSizeIcon:SetAtlas("plunderstorm-glues-queue-pending-spinner-front-trio");
	else -- fallback case	
		self.QueueSquadSize:SetText(WOWLABS_FIND_GAME_SOLO);
		self.QueueTimerSpinner.QueueSizeIcon:SetAtlas("plunderstorm-glues-queue-pending-spinner-front-solo");
	end
end

LeaveQueueButtonMixin = {};
function LeaveQueueButtonMixin:OnClick()
	self:GetParent():GetParent():SetPlayerReady(false);
	self:GetParent():GetParent().GameModeSettingsFrame.GameReadyButton:Update();
end