REQUIRED_REST_HOURS = 5;

function PlayerFrame_OnLoad(self)
	PlayerFrameHealthBar.LeftText = PlayerFrameHealthBarTextLeft;
	PlayerFrameHealthBar.RightText = PlayerFrameHealthBarTextRight;
	PlayerFrameManaBar.LeftText = PlayerFrameManaBarTextLeft;
	PlayerFrameManaBar.RightText = PlayerFrameManaBarTextRight;

	PlayerFrame.PlayerFrameContainer.FrameTexture:SetTexelSnappingBias(0);
	PlayerFrame.PlayerFrameContainer.FrameTexture:SetSnapToPixelGrid(false);

	PlayerFrame.PlayerFrameContainer.FrameFlash:SetTexelSnappingBias(0);
	PlayerFrame.PlayerFrameContainer.FrameFlash:SetSnapToPixelGrid(false);

	local playerFrameContent = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain;
	UnitFrame_Initialize(self, "player", PlayerName, self.PlayerFrameContainer.PlayerPortrait,
						 PlayerFrameHealthBar, PlayerFrameHealthBarText,
						 PlayerFrameManaBar, PlayerFrameManaBarText,
						 PlayerFrame.PlayerFrameContainer.FrameFlash, nil, nil,
						 playerFrameContent.MyHealPredictionBar,
						 playerFrameContent.OtherHealPredictionBar,
						 playerFrameContent.TotalAbsorbBar,
						 playerFrameContent.TotalAbsorbBarOverlay,
						 playerFrameContent.OverAbsorbGlow,
						 playerFrameContent.OverHealAbsorbGlow,
						 playerFrameContent.HealAbsorbBar,
						 playerFrameContent.HealAbsorbBarLeftShadow,
						 playerFrameContent.HealAbsorbBarRightShadow,
						 playerFrameContent.ManaCostPredictionBar);

	self.statusCounter = 0;
	self.statusSign = -1;
	CombatFeedback_Initialize(self, PlayerHitIndicator, 30);
	PlayerFrame_Update();
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");
	self:RegisterEvent("UNIT_FACTION");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_ENTER_COMBAT");
	self:RegisterEvent("PLAYER_LEAVE_COMBAT");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_UPDATE_RESTING");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_CONFIRM");
	self:RegisterEvent("READY_CHECK_FINISHED");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITING_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("PVP_TIMER_UPDATE");
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED");
	self:RegisterEvent("HONOR_LEVEL_UPDATE");
	self:RegisterUnitEvent("UNIT_COMBAT", "player", "vehicle");
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player", "vehicle");

	-- Chinese playtime stuff
	self:RegisterEvent("PLAYTIME_CHANGED");

	self:SetClampRectInsets(20, 0, 0, 0);

	local showmenu = function()
		ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "PlayerFrame", 106, 27);
	end

	UIParent_UpdateTopFramePositions();
	SecureUnitButton_OnLoad(self, "player", showmenu);
end

function PlayerFrame_OnEvent(self, event, ...)
	UnitFrame_OnEvent(self, event, ...);

	local arg1, arg2, arg3, arg4, arg5 = ...;
	if (event == "PLAYER_LEVEL_CHANGED") then
		PlayerFrame_Update();
	elseif (event == "UNIT_COMBAT") then
		if (arg1 == self.unit) then
			CombatFeedback_OnCombatEvent(self, arg2, arg3, arg4, arg5);
		end
	elseif (event == "UNIT_FACTION") then
		if (arg1 == "player") then
			PlayerFrame_UpdatePvPStatus();
		end
	elseif (event == "PLAYER_ENTERING_WORLD") then
		PlayerFrame_ToPlayerArt(self);
--		if (UnitHasVehicleUI("player")) then
--			UnitFrame_SetUnit(self, "vehicle", PlayerFrameHealthBar, PlayerFrameManaBar);
--		else
--			UnitFrame_SetUnit(self, "player", PlayerFrameHealthBar, PlayerFrameManaBar);
--		end
		self.inCombat = nil;
		self.onHateList = nil;
		PlayerFrame_Update();
		PlayerFrame_UpdateStatus();
		PlayerFrame_UpdateRolesAssigned();

		if (IsPVPTimerRunning()) then
			PlayerPVPTimerText:Show();
			PlayerPVPTimerText.timeLeft = GetPVPTimer();
		else
			PlayerPVPTimerText:Hide();
			PlayerPVPTimerText.timeLeft = nil;
		end
	elseif (event == "PLAYER_ENTER_COMBAT") then
		self.inCombat = 1;
		PlayerFrame_UpdateStatus();
	elseif (event == "PLAYER_LEAVE_COMBAT") then
		self.inCombat = nil;
		PlayerFrame_UpdateStatus();
	elseif (event == "PLAYER_REGEN_DISABLED") then
		self.onHateList = 1;
		PlayerFrame_UpdateStatus();
	elseif (event == "PLAYER_REGEN_ENABLED") then
		self.onHateList = nil;
		PlayerFrame_UpdateStatus();
	elseif (event == "PLAYER_UPDATE_RESTING") then
		PlayerFrame_UpdateStatus();
	elseif (event == "PARTY_LEADER_CHANGED" or event == "GROUP_ROSTER_UPDATE") then
		PlayerFrame_UpdateGroupIndicator();
		PlayerFrame_UpdatePartyLeader();
		PlayerFrame_UpdateReadyCheck();
	elseif (event == "PLAYTIME_CHANGED") then
		PlayerFrame_UpdatePlaytime();
	elseif (event == "READY_CHECK" or event == "READY_CHECK_CONFIRM") then
		PlayerFrame_UpdateReadyCheck();
	elseif (event == "READY_CHECK_FINISHED") then
		ReadyCheck_Finish(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.ReadyCheck, DEFAULT_READY_CHECK_STAY_TIME);
	elseif (event == "UNIT_ENTERED_VEHICLE") then
		if (arg1 == "player") then
			self.inSeat = true;
			if (UnitInVehicleHidesPetFrame("player")) then
				self.vehicleHidesPet = true;
			end
			PlayerFrame_UpdateArt(self);
		end
	elseif (event == "UNIT_EXITING_VEHICLE") then
		if (arg1 == "player") then
			if (self.state == "vehicle") then
				self.inSeat = false;
				PlayerFrame_UpdateArt(self);
			else
				self.updatePetFrame = true;
			end
			self.vehicleHidesPet = false;
		end
	elseif (event == "UNIT_EXITED_VEHICLE") then
		if (arg1 == "player") then
			self.inSeat = true;
			PlayerFrame_UpdateArt(self);
		end
	elseif (event == "PVP_TIMER_UPDATE") then
		if (IsPVPTimerRunning()) then
			PlayerPVPTimerText:Show();
			PlayerPVPTimerText.timeLeft = GetPVPTimer();
		else
			PlayerPVPTimerText:Hide();
			PlayerPVPTimerText.timeLeft = nil;
		end
	elseif (event == "PLAYER_ROLES_ASSIGNED") then
		PlayerFrame_UpdateRolesAssigned();
	elseif (event == "HONOR_LEVEL_UPDATE") then
		PlayerFrame_UpdatePvPStatus();
	end
end

function PlayerFrame_OnUpdate(self, elapsed)
	if (PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:IsShown()) then
		local alpha = 255;
		local counter = self.statusCounter + elapsed;
		local sign    = self.statusSign;

		if (counter > 0.5) then
			sign = -sign;
			self.statusSign = sign;
		end
		counter = mod(counter, 0.5);
		self.statusCounter = counter;

		if (sign == 1) then
			alpha = (55 + (counter * 400)) / 255;
		else
			alpha = (255 - (counter * 400)) / 255;
		end
		PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetAlpha(alpha);
	end

	if (PlayerPVPTimerText.timeLeft) then
		PlayerPVPTimerText.timeLeft = PlayerPVPTimerText.timeLeft - elapsed*1000;
		local timeLeft = PlayerPVPTimerText.timeLeft;
		if (timeLeft < 0) then
			PlayerPVPTimerText:Hide()
		end
		PlayerPVPTimerText:SetFormattedText(SecondsToTimeAbbrev(floor(timeLeft/1000)));
	else
		PlayerPVPTimerText:Hide();
	end
	CombatFeedback_OnUpdate(self, elapsed);
end

function PlayerFrame_OnReceiveDrag()
	if (CursorHasItem()) then
		AutoEquipCursorItem();
	end
end

--
-- Functions related to localization anchoring, which can be overritten in LocalizationPost for different languages.
--

function PlayerFrame_UpdatePlayerNameTextAnchor()
	PlayerName:SetPoint("TOPLEFT", 88, -26);
end

function PlayerFrame_UpdateLevelTextAnchor()
	PlayerLevelText:SetPoint("TOPRIGHT", -24.5, -27);
end

function PlayerFrame_UpdateHealthBarTextAnchors()
	if (UnitHasVehiclePlayerFrameUI("player")) then
		PlayerFrameHealthBarText:SetPoint("CENTER", 0, 1);
		PlayerFrameHealthBarTextLeft:SetPoint("LEFT", 2, 1);
		PlayerFrameHealthBarTextRight:SetPoint("RIGHT", -2, 1);
	else
		PlayerFrameHealthBarText:SetPoint("CENTER", 0, 0);
		PlayerFrameHealthBarTextLeft:SetPoint("LEFT", 2, 0);
		PlayerFrameHealthBarTextRight:SetPoint("RIGHT", -2, 0);
	end
end

function PlayerFrame_UpdateManaBarTextAnchors()
	if (UnitHasVehiclePlayerFrameUI("player")) then
		PlayerFrameManaBarText:SetPoint("CENTER", 0, 1);
		PlayerFrameManaBarTextLeft:SetPoint("LEFT", 2, 1);
		PlayerFrameManaBarTextRight:SetPoint("RIGHT", -2, 1);
	else
		PlayerFrameManaBarText:SetPoint("CENTER", 0, 1);
		PlayerFrameManaBarTextLeft:SetPoint("LEFT", 2, 1);
		PlayerFrameManaBarTextRight:SetPoint("RIGHT", -2, 1);
	end
end

--
-- Functions related to various update calls.
--

function PlayerFrame_Update()
	if (UnitExists("player")) then
		PlayerFrame_UpdateLevel();
		PlayerFrame_UpdatePartyLeader();
		PlayerFrame_UpdatePvPStatus();
		PlayerFrame_UpdateStatus();
		PlayerFrame_UpdatePlaytime();
		PlayerFrame_UpdateLayout();
	end
end

function PlayerFrame_UpdateLevel()
	if (UnitExists("player")) then
		local level = UnitLevel(PlayerFrame.unit);
		local effectiveLevel = UnitEffectiveLevel(PlayerFrame.unit);
		if (effectiveLevel ~= level) then
			PlayerLevelText:SetVertexColor(0.1, 1.0, 0.1, 1.0);
		else
			PlayerLevelText:SetVertexColor(1.0, 0.82, 0.0, 1.0);
		end
		PlayerFrame_UpdateLevelTextAnchor();
		PlayerLevelText:SetText(effectiveLevel);
	end
end

function PlayerFrame_UpdatePartyLeader()
	if (UnitIsGroupLeader("player")) then
		PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.LeaderIcon:SetShown(not HasLFGRestrictions());
		PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.GuideIcon:SetShown(HasLFGRestrictions());
	else
		PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.LeaderIcon:Hide();
		PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.GuideIcon:Hide();
	end
end

function PlayerFrame_CanPlayPVPUpdateSound()
	return not PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PVPIcon:IsShown()
	and not PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigePortrait:IsShown();
end

function PlayerFrame_UpdatePvPStatus()
	local factionGroup, factionName = UnitFactionGroup("player");
	local pvpIcon = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PVPIcon;
	local prestigePortrait = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigePortrait;
	local prestigeBadge = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigeBadge;

	if (UnitIsPVPFreeForAll("player")) then
		if (PlayerFrame_CanPlayPVPUpdateSound()) then
			PlaySound(SOUNDKIT.IG_PVP_UPDATE);
		end
		local honorLevel = UnitHonorLevel("player");
		local honorRewardInfo = C_PvP.GetHonorRewardInfo(honorLevel);
		if (honorRewardInfo) then
			prestigePortrait:SetAtlas("honorsystem-portrait-neutral", TextureKitConstants.IgnoreAtlasSize);
			prestigeBadge:SetTexture(honorRewardInfo.badgeFileDataID);
			prestigePortrait:Show();
			prestigeBadge:Show();
			pvpIcon:Hide();
		else
			prestigePortrait:Hide();
			prestigeBadge:Hide();
			pvpIcon:SetAtlas("UI-HUD-UnitFrame-Player-PVP-FFAIcon", TextureKitConstants.UseAtlasSize);
			pvpIcon:Show();
		end

		PlayerPVPTimerText:Hide();
		PlayerPVPTimerText.timeLeft = nil;
	elseif (factionGroup and factionGroup ~= "Neutral" and UnitIsPVP("player")) then
		if (PlayerFrame_CanPlayPVPUpdateSound()) then
			PlaySound(SOUNDKIT.IG_PVP_UPDATE);
		end

		local honorLevel = UnitHonorLevel("player");
		local honorRewardInfo = C_PvP.GetHonorRewardInfo(honorLevel);
		if (honorRewardInfo) then
			-- ugly special case handling for mercenary mode
			if (UnitIsMercenary("player")) then
				if (factionGroup == "Horde") then
					factionGroup = "Alliance";
				elseif (factionGroup == "Alliance") then
					factionGroup = "Horde";
				end
			end

			prestigePortrait:SetAtlas("honorsystem-portrait-"..factionGroup, TextureKitConstants.IgnoreAtlasSize);
			prestigeBadge:SetTexture(honorRewardInfo.badgeFileDataID);
			prestigePortrait:Show();
			prestigeBadge:Show();
			pvpIcon:Hide();
		else
			prestigePortrait:Hide();
			prestigeBadge:Hide();
			if (factionGroup == "Horde") then
				pvpIcon:SetAtlas("UI-HUD-UnitFrame-Player-PVP-HordeIcon", TextureKitConstants.UseAtlasSize);
			elseif (factionGroup == "Alliance") then
				pvpIcon:SetAtlas("UI-HUD-UnitFrame-Player-PVP-AllianceIcon", TextureKitConstants.UseAtlasSize);
			end

			-- ugly special case handling for mercenary mode
			if (UnitIsMercenary("player")) then
				if (factionGroup == "Horde") then
					pvpIcon:SetAtlas("UI-HUD-UnitFrame-Player-PVP-AllianceIcon", TextureKitConstants.UseAtlasSize);
				elseif ( factionGroup == "Alliance" ) then
					pvpIcon:SetAtlas("UI-HUD-UnitFrame-Player-PVP-HordeIcon", TextureKitConstants.UseAtlasSize);
				end
			end

			pvpIcon:Show();
		end
	else
		prestigePortrait:Hide();
		prestigeBadge:Hide();
		pvpIcon:Hide();
		PlayerPVPTimerText:Hide();
		PlayerPVPTimerText.timeLeft = nil;
	end
end

function PlayerFrame_UpdateRolesAssigned()
	local roleIcon = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.RoleIcon;
	local role = UnitGroupRolesAssigned("player");
	local hasIcon = false;

	if (role == "TANK") then
		roleIcon:SetAtlas("roleicon-tiny-tank", TextureKitConstants.IgnoreAtlasSize);
		hasIcon = true;
	elseif (role == "HEALER") then
		roleIcon:SetAtlas("roleicon-tiny-healer", TextureKitConstants.IgnoreAtlasSize);
		hasIcon = true;
	elseif (role == "DAMAGER") then
		roleIcon:SetAtlas("roleicon-tiny-dps", TextureKitConstants.IgnoreAtlasSize);
		hasIcon = true;
	end

	-- If we show the role, hide the level text which is in the same location.
	roleIcon:SetShown(hasIcon);
	PlayerLevelText:SetShown(not hasIcon);
end

function PlayerFrame_UpdateArt(self)
	if (self.inSeat) then
		PetFrame:Update();
		if (UnitHasVehiclePlayerFrameUI("player")) then
			PlayerFrame_ToVehicleArt(self, UnitVehicleSkin("player"));
		else
			PlayerFrame_ToPlayerArt(self);
		end
	elseif (self.updatePetFrame) then
		-- leaving a vehicle that didn't change player art
		self.updatePetFrame = false;
		PetFrame:Update();
	end
end

function PlayerFrame_UpdateVoiceStatus(status)
	PlayerSpeakerFrame:Hide();
end

function PlayerFrame_UpdateReadyCheck()
	local readyFrame = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.ReadyCheck;
	local readyCheckStatus = GetReadyCheckStatus("player");
	if (readyCheckStatus) then
		if (readyCheckStatus == "ready") then
			ReadyCheck_Confirm(readyFrame, 1);
		elseif (readyCheckStatus == "notready") then
			ReadyCheck_Confirm(readyFrame, 0);
		else -- "waiting"
			ReadyCheck_Start(readyFrame);
		end
	else
		readyFrame:Hide();
	end
end

function PlayerFrame_UpdateStatus()
	local attackIcon = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.AttackIcon;
	local playerPortraitCornerIcon = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon;
	local statusTexture = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture;

	if (UnitHasVehiclePlayerFrameUI("player")) then
		statusTexture:Hide();
		attackIcon:Hide();
		playerPortraitCornerIcon:Hide();

		PlayerFrame_UpdatePlayerRestLoop(false);
	elseif (IsResting()) then
		statusTexture:SetVertexColor(1.0, 0.88, 0.25, 1.0);
		statusTexture:Show();
		attackIcon:Hide();
		playerPortraitCornerIcon:Show();

		PlayerFrame_UpdatePlayerRestLoop(true);
	elseif (PlayerFrame.inCombat) then
		statusTexture:SetVertexColor(1.0, 0.0, 0.0, 1.0);
		statusTexture:Show();
		attackIcon:Show();
		playerPortraitCornerIcon:Hide();

		PlayerFrame_UpdatePlayerRestLoop(false);
	elseif (PlayerFrame.onHateList) then
		attackIcon:Show();
		playerPortraitCornerIcon:Hide();

		PlayerFrame_UpdatePlayerRestLoop(false);
	else
		statusTexture:Hide();
		attackIcon:Hide();
		playerPortraitCornerIcon:Show();

		PlayerFrame_UpdatePlayerRestLoop(false);
	end
end

function PlayerFrame_UpdatePlayerRestLoop(state)
	local playerRestLoop = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop;

	if(state) then
		playerRestLoop:Show();
		playerRestLoop.PlayerRestLoopAnim:Play();
	else
		playerRestLoop:Hide();
		playerRestLoop.PlayerRestLoopAnim:Stop();
	end
end

function PlayerFrame_UpdateGroupIndicator()
	local groupIndicator = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.GroupIndicator;

	groupIndicator:Hide();
	local name, rank, subgroup;
	if (not IsInRaid()) then
		return;
	end

	local numGroupMembers = GetNumGroupMembers();
	for i=1, MAX_RAID_MEMBERS do
		if (i <= numGroupMembers) then
			name, rank, subgroup = GetRaidRosterInfo(i);
			-- Set the player's group number indicator
			if (name == UnitName("player")) then
				PlayerFrameGroupIndicatorText:SetText(GROUP.." "..subgroup);
				groupIndicator:SetWidth(PlayerFrameGroupIndicatorText:GetWidth()+40);
				groupIndicator:Show();
				break;
			end
		end
	end
end

function PlayerFrame_UpdatePlaytime()
	local playerPlayTime = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPlayTime;
	local playTimeIcon = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPlayTime.PlayTimeIcon;

	if (PartialPlayTime()) then
		playTimeIcon:SetAtlas("UI-HUD-UnitFrame-Player-PlayTimeTired", TextureKitConstants.UseAtlasSize);
		playerPlayTime.tooltip = format(PLAYTIME_TIRED, REQUIRED_REST_HOURS - floor(GetBillingTimeRested()/60));
		playerPlayTime:Show();
	elseif (NoPlayTime()) then
		playTimeIcon:SetAtlas("UI-HUD-UnitFrame-Player-PlayTimeUnhealthy", TextureKitConstants.UseAtlasSize);
		playerPlayTime.tooltip = format(PLAYTIME_UNHEALTHY, REQUIRED_REST_HOURS - floor(GetBillingTimeRested()/60));
		playerPlayTime:Show();
	else
		playerPlayTime:Hide();
	end
end

--
-- Functions related to swapping between player and vehicle art.
--

function PlayerFrame_ToVehicleArt(self, vehicleType)
	--Swap frame

	PlayerFrame.state = "vehicle";

	UnitFrame_SetUnit(self, "vehicle", PlayerFrameHealthBar, PlayerFrameManaBar);
	UnitFrame_SetUnit(PetFrame, "player", PetFrameHealthBar, PetFrameManaBar);
	PetFrame:Update();
	PlayerFrame_Update();
	BuffFrame:Update();
	DebuffFrame:Update();
	ComboFrame_Update(ComboFrame);

	PlayerFrame.PlayerFrameContainer.FrameTexture:Hide();
	local vehicleFrameTexture = PlayerFrame.PlayerFrameContainer.VehicleFrameTexture;
	local frameFlash = PlayerFrame.PlayerFrameContainer.FrameFlash;
	if (vehicleType == "Natural") then
		vehicleFrameTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic");
		frameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic-Flash");
	else
		vehicleFrameTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame");
		frameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Flash");
	end

	frameFlash:SetWidth(240);
	frameFlash:SetHeight(120);
	frameFlash:SetPoint("CENTER", 0, -8);

	PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.RoleIcon:SetPoint("TOPLEFT", 185, -29);

	PlayerFrameHealthBar:SetHeight(8);
	PlayerFrameHealthBar:SetWidth(102);
	PlayerFrameHealthBar:SetPoint("TOPLEFT", 98, -52);

	PlayerFrame_UpdateHealthBarTextAnchors();

	PlayerFrameManaBar:SetHeight(8);
	PlayerFrameManaBar:SetWidth(102);
	PlayerFrameManaBar:SetPoint("TOPLEFT",98,-62);

	PlayerFrame_UpdateManaBarTextAnchors();

	PlayerFrame_ShowVehicleTexture();
	PlayerFrame_UpdatePlayerNameTextAnchor();
	PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon:Hide();
	PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.GroupIndicator:SetPoint("BOTTOMRIGHT", PlayerFrame, "TOPLEFT", 200, -20);
	PlayerLevelText:Hide();
end

function PlayerFrame_ToPlayerArt(self)
	--Unswap frame

	PlayerFrame.state = "player";

	UnitFrame_SetUnit(self, "player", PlayerFrameHealthBar, PlayerFrameManaBar);
	UnitFrame_SetUnit(PetFrame, "pet", PetFrameHealthBar, PetFrameManaBar);
	PetFrame:Update();
	PlayerFrame_Update();
	BuffFrame:Update();
	DebuffFrame:Update();
	ComboFrame_Update(ComboFrame);

	PlayerFrame.PlayerFrameContainer.FrameTexture:Show();
	local playerFrameFlash = PlayerFrame.PlayerFrameContainer.FrameFlash;
	playerFrameFlash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-InCombat");
	playerFrameFlash:SetWidth(192);
	playerFrameFlash:SetHeight(71);
	playerFrameFlash:SetPoint("CENTER", -1.5, 1);

	PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.RoleIcon:SetPoint("TOPLEFT", 196, -27);

	PlayerFrameHealthBar:SetHeight(20);
	PlayerFrameHealthBar:SetWidth(124);
	PlayerFrameHealthBar:SetPoint("TOPLEFT", 85, -40);

	PlayerFrame_UpdateHealthBarTextAnchors();

	PlayerFrameManaBar:SetHeight(10);
	PlayerFrameManaBar:SetWidth(124);
	PlayerFrameManaBar:SetPoint("TOPLEFT", 85, -62);

	PlayerFrame_UpdateManaBarTextAnchors();

	PlayerFrame_HideVehicleTexture();
	PlayerFrame_UpdatePlayerNameTextAnchor();
	PlayerFrame_UpdateRolesAssigned();
	PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.GroupIndicator:SetPoint("BOTTOMRIGHT", PlayerFrame, "TOPLEFT", 210, -27);
end

function PlayerFrame_ShowVehicleTexture()
	PlayerFrame.PlayerFrameContainer.VehicleFrameTexture:Show();

	local _, class = UnitClass("player");
	if (PlayerFrame.classPowerBar) then
		PlayerFrame.classPowerBar:Hide();
	elseif (class == "SHAMAN") then
		TotemFrame:Hide();
	elseif (class == "DEATHKNIGHT") then
		RuneFrame:Hide();
	elseif (class == "PRIEST") then
		PriestBarFrame:Hide();
	end

	ComboPointPlayerFrame:Setup();
	EssencePlayerFrame:Setup();
end

function PlayerFrame_HideVehicleTexture()
	PlayerFrame.PlayerFrameContainer.VehicleFrameTexture:Hide();

	local _, class = UnitClass("player");
	if (PlayerFrame.classPowerBar) then
		PlayerFrame.classPowerBar:Setup();
	elseif (class == "SHAMAN") then
		TotemFrame_Update();
	elseif (class == "DEATHKNIGHT") then
		RuneFrame:Show();
	elseif (class == "PRIEST") then
		PriestBarFrame_CheckAndShow();
	end

	ComboPointPlayerFrame:Setup();
	EssencePlayerFrame:Setup();
end

--
-- Functions related to the frame dropdown.
--

function PlayerFrameDropDown_OnLoad(self)
	UIDropDownMenu_SetInitializeFunction(self, PlayerFrameDropDown_Initialize);
	UIDropDownMenu_SetDisplayMode(self, "MENU");
end

function PlayerFrameDropDown_Initialize()
	if (PlayerFrame.unit == "vehicle") then
		UnitPopup_ShowMenu(PlayerFrameDropDown, "VEHICLE", "vehicle");
	else
		UnitPopup_ShowMenu(PlayerFrameDropDown, "SELF", "player");
	end
end

--
-- Functions related to class specific things.
--

function PlayerFrame_SetupDeathKnightLayout()
	PlayerFrame:SetHitRectInsets(0,0,0,33);
end

CustomClassLayouts = {
	["DEATHKNIGHT"] = PlayerFrame_SetupDeathKnightLayout,
}

local layoutUpdated = false;

function PlayerFrame_UpdateLayout()
	if (layoutUpdated) then
		return;
	end
	layoutUpdated = true;

	local _, class = UnitClass("player");

	if (CustomClassLayouts[class]) then
		CustomClassLayouts[class]();
	end
end

local RUNICPOWERBARHEIGHT = 63;
local RUNICGLOW_FADEALPHA = .050;
local RUNICGLOW_MINALPHA = .40;
local RUNICGLOW_MAXALPHA = .80;
local RUNICGLOW_PULSEINTERVAL = .8;
local RUNICGLOW_FINISHPULSEANDHIDE = false;
local RUNICGLOW_PULSESTART = 0;

function PlayerFrame_SetRunicPower(runicPower)
	PlayerFrameRunicPowerBar:SetHeight(RUNICPOWERBARHEIGHT * (runicPower / 100));
	PlayerFrameRunicPowerBar:SetTexCoord(0, 1, (1 - (runicPower / 100)), 1);

	if (runicPower >= 90) then
		RUNICGLOW_FINISHPULSEANDHIDE = false;
		if (not PlayerFrameRunicPowerGlow:IsShown()) then
			PlayerFrameRunicPowerGlow:Show();
		end
		PlayerFrameRunicPowerGlow:GetParent():SetScript("OnUpdate", DeathKnightPulseFunction);
	elseif (PlayerFrameRunicPowerGlow:GetParent():GetScript("OnUpdate")) then
		RUNICGLOW_FINISHPULSEANDHIDE = true;
	else
		PlayerFrameRunicPowerGlow:Hide();
	end
end

local firstFadeIn = true;
function DeathKnightPulseFunction(self, elapsed)
	if (RUNICGLOW_PULSESTART == 0) then
		RUNICGLOW_PULSESTART = GetTime();
	elseif (not RUNICGLOW_FINISHPULSEANDHIDE) then
		local interval = RUNICGLOW_PULSEINTERVAL - math.abs(.9 - (UnitPower("player") / 100));
		local animTime = GetTime() - RUNICGLOW_PULSESTART;
		if (animTime >= interval) then
			-- Fading out
			PlayerFrameRunicPowerGlow:SetAlpha(math.max(RUNICGLOW_MINALPHA, math.min(RUNICGLOW_MAXALPHA, RUNICGLOW_MAXALPHA * interval/animTime)));
			if (animTime >= interval * 2) then
				self.timeSincePulse = 0;
				RUNICGLOW_PULSESTART = GetTime();
			end
			firstFadeIn = false;
		else
			-- Fading in
			if (firstFadeIn) then
				PlayerFrameRunicPowerGlow:SetAlpha(math.max(RUNICGLOW_FADEALPHA, math.min(RUNICGLOW_MAXALPHA, RUNICGLOW_MAXALPHA * animTime/interval)));
			else
				PlayerFrameRunicPowerGlow:SetAlpha(math.max(RUNICGLOW_MINALPHA, math.min(RUNICGLOW_MAXALPHA, RUNICGLOW_MAXALPHA * animTime/interval)));
			end
		end
	elseif (RUNICGLOW_FINISHPULSEANDHIDE) then
		local currentAlpha = PlayerFrameRunicPowerGlow:GetAlpha();
		local animTime = GetTime() - RUNICGLOW_PULSESTART;
		local interval = RUNICGLOW_PULSEINTERVAL;
		firstFadeIn = true;

		if (animTime >= interval) then
			-- Already fading out, just keep fading out.
			local alpha = math.min(PlayerFrameRunicPowerGlow:GetAlpha(), RUNICGLOW_MAXALPHA * (interval/(animTime*(animTime/2))));

			PlayerFrameRunicPowerGlow:SetAlpha(alpha);
			if (alpha <= RUNICGLOW_FADEALPHA) then
				self.timeSincePulse = 0;
				RUNICGLOW_PULSESTART = 0;
				PlayerFrameRunicPowerGlow:Hide();
				self:SetScript("OnUpdate", nil);
				RUNICGLOW_FINISHPULSEANDHIDE = false;
				return;
			end
		else
			-- Was fading in, start fading out
			animTime = interval;
		end
	end
end

--
-- Functions for having the cast bar underneath the player frame.
--

function PlayerFrame_AttachCastBar()
	-- pet
	PetCastingBarFrame:SetLook("UNITFRAME");
	PetCastingBarFrame:SetWidth(150);
	PetCastingBarFrame:SetHeight(10);

	-- player
	PlayerCastingBarFrame.ignoreFramePositionManager = true;
	UIParentBottomManagedFrameContainer:RemoveManagedFrame(PlayerCastingBarFrame);
	PlayerCastingBarFrame.attachedToPlayerFrame = true;
	PlayerCastingBarFrame:SetLook("UNITFRAME");
	PlayerCastingBarFrame:SetParent(PlayerFrame);
	PlayerFrame_AdjustAttachments();
end

function PlayerFrame_DetachCastBar()
	-- pet
	PetCastingBarFrame:SetLook("CLASSIC");
	PetCastingBarFrame:SetWidth(195);
	PetCastingBarFrame:SetHeight(13);

	-- player
	PlayerCastingBarFrame.ignoreFramePositionManager = nil;
	PlayerCastingBarFrame.attachedToPlayerFrame = false;
	PlayerCastingBarFrame:SetLook("CLASSIC");
	-- Will be re-anchored via edit mode
end

function PlayerFrame_AdjustAttachments()
	if (not PlayerCastingBarFrame.attachedToPlayerFrame) then
		return;
	end

	local yOffset;
	if (PetFrame and PetFrame:IsShown()) then
		yOffset = PetFrame:GetBottom() - PlayerFrame:GetBottom();

		if (PetCastingBarFrame.showCastbar) then
			yOffset = yOffset - 30;
		end
	elseif (TotemFrame and TotemFrame:IsShown()) then
		yOffset = TotemFrame:GetBottom() - PlayerFrame:GetBottom();
	else
		local _, class = UnitClass("player");
		if (class == "PALADIN") then
			yOffset = -6;
		elseif (class == "PRIEST" and PriestBarFrame:IsShown()) then
			yOffset = -2;
		elseif (class == "DEATHKNIGHT" or class == "WARLOCK") then
			yOffset = 4;
		else
			yOffset = 10;
		end
	end

	PlayerCastingBarFrame:ClearAllPoints();
	PlayerCastingBarFrame:SetPoint("TOPRIGHT", PlayerFrame, "BOTTOMRIGHT", 0, yOffset);
end
