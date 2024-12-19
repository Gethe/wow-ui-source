local function IsInTrainingMode()
	local currGameMode = C_WoWLabsMatchmaking.GetPartyPlaylistEntry();
	return currGameMode == Enum.PartyPlaylistEntry.TrainingGameMode;
end

local function IsInPrematch()
	return IsInTrainingMode() or C_WowLabsDataManager.IsInPrematch();
end

-------------------------------------------------
---		Prematch Header Mixin

PrematchHeaderMixin = {};

local PrematchHeaderMixinEvents = {
	"WOW_LABS_MATCH_STATE_UPDATED",
};

function PrematchHeaderMixin:OnLoad()
	self:Show();
	FrameUtil.RegisterFrameForEvents(self, PrematchHeaderMixinEvents);
end

function PrematchHeaderMixin:OnShow()
	self:UpdateShown();

	EventRegistry:RegisterCallback("PlunderstormCountdown.TimerFinished", self.OnPlunderstormCountdownFinished, self);
end

function PrematchHeaderMixin:OnHide()
	self:UpdateShown();

	EventRegistry:UnregisterCallback("PlunderstormCountdown.TimerFinished", self);
end

function PrematchHeaderMixin:OnEvent(event, ...)
	if (event == "WOW_LABS_MATCH_STATE_UPDATED") then
		self:UpdateShown();
	end
end

function PrematchHeaderMixin:OnPlunderstormCountdownFinished()
	self:SetShown(IsInPrematch());
end

function PrematchHeaderMixin:UpdateShown()
	self:SetShown(IsInPrematch());
end

-------------------------------------------------
---		Shared Button Behavior Mixin

PrematchHeaderBaseButtonMixin = {};

function PrematchHeaderBaseButtonMixin:OnLoad()
	self:UpdateTextures();
end

function PrematchHeaderBaseButtonMixin:OnShow()
	if self.selectedStateEvent then
		EventRegistry:RegisterCallback(self.selectedStateEvent, self.UpdateTextures, self);
	end

	if self.alternateSelectedStateEvent then
		EventRegistry:RegisterCallback(self.alternateSelectedStateEvent, self.UpdateTextures, self);
	end

	if self.selectedStateFrameEvent then
		self:RegisterEvent(self.selectedStateFrameEvent);
	end
end

function PrematchHeaderBaseButtonMixin:OnHide()
	if self.selectedStateEvent then
		EventRegistry:UnregisterCallback(self.selectedStateEvent, self);
	end

	if self.alternateSelectedStateEvent then
		EventRegistry:UnregisterCallback(self.alternateSelectedStateEvent, self);
	end

	if self.selectedStateFrameEvent then
		self:UnregisterEvent(self.selectedStateFrameEvent);
	end
end

function PrematchHeaderBaseButtonMixin:OnEvent(event)
	if event == self.selectedStateFrameEvent then
		self:UpdateTextures();
	end
end

function PrematchHeaderBaseButtonMixin:ShouldShowSelectedState()
	-- Override in derived Mixins.
end

function PrematchHeaderBaseButtonMixin:UpdateTextures()
	local selected = self:ShouldShowSelectedState();
	local normalAtlasFormat = selected and "plunderstorm-menu-%s-selected" or "plunderstorm-menu-%s";
	local highlightAtlasFormat = selected and "plunderstorm-menu-%s-selected-hover" or "plunderstorm-menu-%s-hover";
	self:GetNormalTexture():SetAtlas(normalAtlasFormat:format(self.textureKit));
	self:GetHighlightTexture():SetAtlas(highlightAtlasFormat:format(self.textureKit));
end

-------------------------------------------------
---		Prematch Plunderstore Button Mixin

HeaderPlunderstoreButtonMixin = {};

function HeaderPlunderstoreButtonMixin:OnClick()
	AccountStoreUtil.ToggleAccountStore();
end

function HeaderPlunderstoreButtonMixin:OnEnter()
	self:SetEnabled(C_AccountStore.GetStoreFrontState(Constants.AccountStoreConsts.PlunderstormStoreFrontID) == Enum.AccountStoreState.Available);

	GameTooltip:SetOwner(self, "ANCHOR_LEFT");

	if self:IsEnabled() then
		GameTooltip:SetText(PLUNDERSTORM_PLUNDER_STORE_TITLE);
	else
		GameTooltip:SetText(ACCOUNT_STORE_UNAVAILABLE);
	end

	GameTooltip:Show();
end

function HeaderPlunderstoreButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function HeaderPlunderstoreButtonMixin:ShouldShowSelectedState()
	-- Overrides PrematchHeaderBaseButtonMixin.

	return AccountStoreFrame:IsShown();
end

-------------------------------------------------
---		Prematch Plunderstore Button Mixin

HeaderCustomizeButtonMixin = {};

function HeaderCustomizeButtonMixin:OnHide()
	PrematchHeaderBaseButtonMixin.OnHide(self);

	C_Map.ClearUserWaypoint();
	C_SuperTrack.SetSuperTrackedUserWaypoint(false);
end

function HeaderCustomizeButtonMixin:OnClick()
	-- Hardcoded point for Da'kash's location in Brew Bay.
	local uiMapPoint = UiMapPoint.CreateFromCoordinates(2257, 0.8846, 0.7777, 10.64);
	C_Map.SetUserWaypoint(uiMapPoint);
	C_SuperTrack.SetSuperTrackedUserWaypoint(true);
end

function HeaderCustomizeButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, PLUNDERSTORM_CUSTOMIZE_BUTTON_TOOLTIP);
	GameTooltip:Show();
end

function HeaderCustomizeButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function HeaderCustomizeButtonMixin:ShouldShowSelectedState()
	-- Overrides PrematchHeaderBaseButtonMixin.

	return C_SuperTrack.IsSuperTrackingUserWaypoint();
end

-------------------------------------------------
---		Training Lobby QueueSelectButton Mixin

TrainingLobbyQueueSelectButtonMixin = {};

function TrainingLobbyQueueSelectButtonMixin:OnShow()
	PrematchHeaderBaseButtonMixin.OnShow(self);

	if (not IsInTrainingMode()) then
		self:Hide();
		return;
	end
end

function TrainingLobbyQueueSelectButtonMixin:OnClick()
	local parent = self:GetParent();
	parent.QueueFrame:SetShown(not parent.QueueFrame:IsShown());
end

function TrainingLobbyQueueSelectButtonMixin:ShouldShowSelectedState()
	-- Overrides PrematchHeaderBaseButtonMixin.

	return self:GetParent().QueueFrame:IsShown();
end

-------------------------------------------------
---		Plunderstorm DropMapButton Mixin

PlunderstormDropMapButtonMixin = {};

function PlunderstormDropMapButtonMixin:OnShow()
	PrematchHeaderBaseButtonMixin.OnShow(self);

	if (IsInTrainingMode() or not C_GameRules.IsGameRuleActive(Enum.GameRule.PlunderstormAreaSelection)) then
		self:Hide();
		return;
	end
end

function PlunderstormDropMapButtonMixin:OnClick()
	ToggleWorldMap();
end

function PlunderstormDropMapButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, PLUNDERSTORM_DROP_MAP_BUTTON_TOOLTIP);
	GameTooltip:Show();
end

function PlunderstormDropMapButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function PlunderstormDropMapButtonMixin:ShouldShowSelectedState()
	-- Overrides PrematchHeaderBaseButtonMixin.

	return WorldMapFrame and WorldMapFrame:IsShown();
end

-------------------------------------------------
---		Training Lobby Queue Mixin
TrainingLobbyQueueMixin = {};

function TrainingLobbyQueueMixin:OnLoad()
	self.useLocalPlayIndex = true;

	local numGroupMembers = GetNumGroupMembers();
	self.localPlayIndex = numGroupMembers <= 1 and Enum.PartyPlaylistEntry.SoloGameMode or Enum.PartyPlaylistEntry.DuoGameMode;
	self.isInTrainingMode = IsInTrainingMode();

	--Custom anchoring for centering the queue container in the portrait frame
	self.QueueContainer:ClearAllPoints();
	self.QueueContainer:SetPoint("CENTER", self, "CENTER", 0, 10);

	QueueTypeSettingsFrameMixin.OnLoad(self);

	self:SetTitle(TRAINING_LOBBY_QUEUE_TITLE);
	ButtonFrameTemplate_HidePortrait(self);
end

function TrainingLobbyQueueMixin:OnShow()
	if (not IsInTrainingMode()) then
		self:Hide();
		return;
	end

	local numGroupMembers = GetNumGroupMembers();
	if (numGroupMembers > 1) then
		self.localPlayIndex = Enum.PartyPlaylistEntry.DuoGameMode;
	end

	QueueTypeSettingsFrameMixin.OnShow(self);

	EventRegistry:TriggerEvent("TrainingLobbyQueue.ShownState", true);

	local padding = 50;
	self:SetWidth(self.QueueContainer:GetWidth() + padding);
end

function TrainingLobbyQueueMixin:OnHide()
	QueueTypeSettingsFrameMixin.OnHide(self);

	EventRegistry:TriggerEvent("TrainingLobbyQueue.ShownState", false);
end

StartQueueButtonMixin = {};

function StartQueueButtonMixin:OnShow()
	self:SetText(not C_WoWLabsMatchmaking.IsPartyLeader() and WOWLABS_READY_GAME or WOW_LABS_START_QUEUE);
end

function StartQueueButtonMixin:OnClick()
	local parent = self:GetParent();
	C_WoWLabsMatchmaking.SetAutoQueueOnLogout(true, parent:GetQueueType());
	PlaySound(SOUNDKIT.IG_MAINMENU_LOGOUT);
	ForceLogout();
end