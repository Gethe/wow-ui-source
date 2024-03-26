
local ZoomFrequencySeconds = 0.1;

local PreferSpectatePreviousKey = "A";
local PreferSpectateNextKey = "D";

SpectateFrameMixin = {};

function SpectateFrameMixin:OnLoad()
	self:RegisterEvent("PLAYER_DEAD");
	self:RegisterEvent("SPECTATE_BEGIN");
	self:RegisterEvent("SPECTATE_END");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_ALIVE");
	self:RegisterEvent("SPECTATE_TARGET_INFO_UPDATED");
	self:Hide();
end

function SpectateFrameMixin:OnShow()
	self:UpdateArrowText(self.ArrowLeft, "STRAFELEFT", "TURNLEFT", PreferSpectatePreviousKey);
	self:UpdateArrowText(self.ArrowRight, "STRAFERIGHT", "TURNRIGHT", PreferSpectateNextKey);
end

function SpectateFrameMixin:OnUpdate(dt)
	if not self:IsZoomingInFOV() and not self:IsZoomingOutFOV() then
		self:SetScript("OnUpdate", nil);
		self.timeSinceLastZoom = nil;
		return;
	end

	if not self.timeSinceLastZoom or (self.timeSinceLastZoom > ZoomFrequencySeconds) then
		self.timeSinceLastZoom = 0;

		if self:IsZoomingInFOV() then
			C_Commentator.ZoomIn();
		elseif self:IsZoomingOutFOV() then
			C_Commentator.ZoomOut();
		end
	else
		self.timeSinceLastZoom = (self.timeSinceLastZoom or 0) + dt;
	end
end

function SpectateFrameMixin:OnEvent(event, ...)
	if( event == "SPECTATE_BEGIN") then
		self:InitializeSpectateMode(); 
	elseif(event == "PLAYER_ENTERING_WORLD") then 
		if(C_SpectatingUI.IsSpectating()) then 
			self:InitializeSpectateMode();
		else 
			self:LeaveSpectatingMode(); 
		end
	elseif(event == "SPECTATE_END" or event == "PLAYER_ALIVE") then 
		self:InitializeSpectateMode();
	elseif event == "SPECTATE_TARGET_INFO_UPDATED" then
		self:UpdatePlayerName();
	end
end

function SpectateFrameMixin:UpdateArrowText(arrow, strafeCommand, turnCommand, preferredKey)
	local turnKey, turnKeyAlternate = GetBindingKey(turnCommand);
	if (turnKey == preferredKey) or (turnKeyAlternate == preferredKey) then
		arrow:SetArrowText(preferredKey);
		return;
	end

	local strafeKey, strafeKeyAlternate = GetBindingKey(strafeCommand);
	if strafeKeyAlternate == preferredKey then
		arrow:SetArrowText(preferredKey);
		return;
	end

	arrow:SetArrowText(strafeKey or turnKey or "");
end

function SpectateFrameMixin:ShouldBeInSpecateMode()
	if (not C_SpectatingUI.IsSpectating()) then 
		self:LeaveSpectatingMode(); 
		return false; 
	end 
	return true;
end

function SpectateFrameMixin:StartZoomingFOV()
	self:SetScript("OnUpdate", self.OnUpdate);
end

function SpectateFrameMixin:IsZoomingInFOV()
	return self:IsZoomingFOV("MOVEFORWARD");
end

function SpectateFrameMixin:IsZoomingOutFOV()
	return self:IsZoomingFOV("MOVEBACKWARD");
end

function SpectateFrameMixin:IsZoomingFOV(command)
	local primaryKey, alternateKey = GetBindingKey(command);
	return (primaryKey and IsKeyDown(primaryKey)) or (alternateKey and IsKeyDown(alternateKey));
end

function SpectateFrameMixin:InitializeSpectateMode()
	if(not self:ShouldBeInSpecateMode()) then 
		return; 
	end	

	SetFrameLock("SPECTATING", true);
	EditModeManagerFrame:SetOverrideLayout(1); 
	self:Show();
	self:UpdatePlayerName();
	C_ArrowCalloutManager.HideWorldLootObjectCallout();
end

function SpectateFrameMixin:UpdatePlayerName()
	local spectateTargetInfo = C_SpectatingUI.GetSpectateTargetInfo();
	local targetName = spectateTargetInfo and spectateTargetInfo.targetName or "";
	self.PlayerName:SetText(targetName);
end

local EDITMODE_MODERN_PRESET_LAYOUT_INDEX = 1;
function SpectateFrameMixin:LeaveSpectatingMode()
	StaticPopup_Hide("CONFIRM_LEAVE_MATCH_WHILE_RESSURECTABLE");
	SetFrameLock("SPECTATING", false);
	EditModeManagerFrame:ClearOverrideLayout();
	C_EditMode.SetActiveLayout(EDITMODE_MODERN_PRESET_LAYOUT_INDEX); --Default layout
	self:Hide();
end

local function LeaveMatch()
	PlaySound(SOUNDKIT.IG_MAINMENU_LOGOUT);
	if C_SpectatingUI.IsSpectating() then
		C_SpectatingUI.LeaveSpectateMode();
	end

	ForceLogout();
end

local PLUNDER_CURRENCY_ID = 3011;
function LeaveMatchUtil_LeaveMatchPopup() 
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(PLUNDER_CURRENCY_ID);
	local playerIsDead = UnitIsDeadOrGhost("player");
	if not playerIsDead and currencyInfo.quantity > 0 then
		StaticPopup_Show(GetNumGroupMembers() > 1 and "CONFIRM_LEAVE_MATCH_WITH_PLUNDER" or "CONFIRM_LEAVE_MATCH_WITH_PLUNDER_SOLO");

		return;
	end

	if playerIsDead then
		for i=1, GetNumGroupMembers()-1 do
			if not UnitIsDeadOrGhost("party"..i) then
				StaticPopup_Show("CONFIRM_LEAVE_MATCH_WHILE_RESSURECTABLE");

				return;
			end
		end
	end

	LeaveMatch();
end

StaticPopupDialogs["CONFIRM_LEAVE_MATCH_WHILE_RESSURECTABLE"] = {	text = WOW_LABS_CONFIRM_LEAVE_MATCH,
	button1 = WOW_LABS_REMATCH,
	button2 = WOW_LABS_STAY,
	OnAccept = function()
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(PLUNDER_CURRENCY_ID);
		if currencyInfo.quantity <= 0 then
			LeaveMatch();	
		else
			StaticPopup_Show(GetNumGroupMembers() > 1 and "CONFIRM_LEAVE_MATCH_WITH_PLUNDER" or "CONFIRM_LEAVE_MATCH_WITH_PLUNDER_SOLO");
		end
	end,
	OnCancel = function() end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	customAlertIcon = [[Interface\RaidFrame\Raid-Icon-Rez]],
}

StaticPopupDialogs["CONFIRM_LEAVE_MATCH_WITH_PLUNDER"] = {
	text = WOW_LABS_CONFIRM_LEAVE_MATCH_PLUNDER,
	button1 = WOW_LABS_REMATCH,
	button2 = WOW_LABS_STAY,
	OnAccept = LeaveMatch,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = true,
}

StaticPopupDialogs["CONFIRM_LEAVE_MATCH_WITH_PLUNDER_SOLO"] = {
	text = WOW_LABS_CONFIRM_LEAVE_MATCH_PLUNDER_SOLO,
	button1 = WOW_LABS_REMATCH,
	button2 = WOW_LABS_STAY,
	OnAccept = LeaveMatch,
	OnCancel = function() end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = true,
}

SpectateViewRewardsButtonMixin = {};
function SpectateViewRewardsButtonMixin:OnClick()
	ToggleMajorFactionRenown(Constants.MajorFactionsConsts.PLUNDERSTORM_MAJOR_FACTION_ID);
end

SpectateLeaveMatchButtonMixin = {};
function SpectateLeaveMatchButtonMixin:OnClick()
	LeaveMatchUtil_LeaveMatchPopup();
end

SpectateCycleModeMixin = { };
function SpectateCycleModeMixin:OnClick()
	C_SpectatingUI.SpectateChange(self.spectateNext);
end

function SpectateCycleModeMixin:SetArrowText(text)
	self.Text:SetText(text);
	self.HighlightText:SetText(text);
end
