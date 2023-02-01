REQUIRED_REST_HOURS = 5;

function PlayerFrame_OnLoad(self)
	PlayerFrame.PlayerFrameContainer.FrameTexture:SetTexelSnappingBias(0);
	PlayerFrame.PlayerFrameContainer.FrameTexture:SetSnapToPixelGrid(false);

	PlayerFrame.PlayerFrameContainer.FrameFlash:SetTexelSnappingBias(0);
	PlayerFrame.PlayerFrameContainer.FrameFlash:SetSnapToPixelGrid(false);

	local healthBar = PlayerFrame_GetHealthBar();
	local manaBar = PlayerFrame_GetManaBar();
	UnitFrame_Initialize(self, "player", PlayerName, self.frameType, self.PlayerFrameContainer.PlayerPortrait,
						 healthBar,
						 healthBar.HealthBarText,
						 manaBar,
						 manaBar.ManaBarText,
						 PlayerFrame.PlayerFrameContainer.FrameFlash, nil, nil,
						 healthBar.MyHealPredictionBar,
						 healthBar.OtherHealPredictionBar,
						 healthBar.TotalAbsorbBar,
						 healthBar.TotalAbsorbBarOverlay,
						 healthBar.OverAbsorbGlow,
						 healthBar.OverHealAbsorbGlow,
						 healthBar.HealAbsorbBar,
						 healthBar.HealAbsorbBarLeftShadow,
						 healthBar.HealAbsorbBarRightShadow,
						 manaBar.ManaCostPredictionBar);

	self.statusCounter = 0;
	self.statusSign = -1;

	healthBar:GetStatusBarTexture():AddMaskTexture(healthBar.HealthBarMask);
	PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea.PlayerFrameHealthBarAnimatedLoss:GetStatusBarTexture():AddMaskTexture(healthBar.HealthBarMask);

	manaBar:GetStatusBarTexture():AddMaskTexture(manaBar.ManaBarMask);
	manaBar.FeedbackFrame:AddMaskTexture(manaBar.ManaBarMask);

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
		UnitFrame_Update(self);
		PlayerFrame_UpdateArt(self);
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
		if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HUD_REVAMP_UNIT_FRAME_CHANGES) then
			EventRegistry:RegisterCallback("Tutorials.ShowUnitFrameChanges", PlayerFrame_CheckTutorials, self);
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
			if (UnitInVehicleHidesPetFrame("player")) then
				self.vehicleHidesPet = true;
			end
			PlayerFrame_UpdateArt(self);
		end
	elseif (event == "UNIT_EXITING_VEHICLE") then
		if (arg1 == "player") then
			if (self.state == "vehicle") then
				PlayerFrame_UpdateArt(self);
			else
				self.updatePetFrame = true;
			end
			self.vehicleHidesPet = false;
		end
	elseif (event == "UNIT_EXITED_VEHICLE") then
		if (arg1 == "player") then
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

function PlayerFrame_CheckTutorials(self)
	if not self:IsShown() then
		return;
	end
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HUD_REVAMP_UNIT_FRAME_CHANGES) then
		EventRegistry:UnregisterCallback("Tutorials.ShowUnitFrameChanges", self);
	else
		local helpTipInfo = {
			text = TUTORIAL_HUD_REVAMP_UNIT_FRAME_CHANGES,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_HUD_REVAMP_UNIT_FRAME_CHANGES,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			offsetX = 0,
			alignment = HelpTip.Alignment.Center,
			onAcknowledgeCallback = GenerateClosure(PlayerFrame_CheckTutorials, self),
		};
		HelpTip:Show(UIParent, helpTipInfo, self);
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
-- Helper functions to access frequently needed UI.
--

function PlayerFrame_GetPlayerFrameContentContextual()
	return PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual;
end

function PlayerFrame_GetHealthBar()
	return PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea.HealthBar;
end

function PlayerFrame_GetManaBar()
	return PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar;
end

--
-- Functions related to localization anchoring, which can be overritten in LocalizationPost for different languages.
--

function PlayerFrame_UpdatePlayerNameTextAnchor()
	if PlayerFrame.unit == "vehicle" then
		PlayerName:SetPoint("TOPLEFT", 96, -27);
	else
		PlayerName:SetPoint("TOPLEFT", 88, -27);
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
		PlayerLevelText:SetText(effectiveLevel);
	end
end

function PlayerFrame_UpdatePartyLeader()
	local playerFrameTargetContextual = PlayerFrame_GetPlayerFrameContentContextual();
	if (UnitIsGroupLeader("player")) then
		playerFrameTargetContextual.LeaderIcon:SetShown(not HasLFGRestrictions());
		playerFrameTargetContextual.GuideIcon:SetShown(HasLFGRestrictions());
	else
		playerFrameTargetContextual.LeaderIcon:Hide();
		playerFrameTargetContextual.GuideIcon:Hide();
	end
end

function PlayerFrame_CanPlayPVPUpdateSound()
	local playerFrameTargetContextual = PlayerFrame_GetPlayerFrameContentContextual();

	return not playerFrameTargetContextual.PVPIcon:IsShown() and not playerFrameTargetContextual.PrestigePortrait:IsShown();
end

function PlayerFrame_UpdatePvPStatus()
	local factionGroup, factionName = UnitFactionGroup("player");

	local playerFrameTargetContextual = PlayerFrame_GetPlayerFrameContentContextual();
	local pvpIcon = playerFrameTargetContextual.PVPIcon;
	local prestigePortrait = playerFrameTargetContextual.PrestigePortrait;
	local prestigeBadge = playerFrameTargetContextual.PrestigeBadge;

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
	local hasIcon = false;

	-- Only show role icons when in instanced content areas (raids, dungeons, battleground, etc.)
	local _, instanceType = GetInstanceInfo();
	if instanceType ~= "none" then
		local role = UnitGroupRolesAssigned("player");

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
	end

	-- If we show the role, hide the level text which is in the same location.
	roleIcon:SetShown(hasIcon);
	PlayerLevelText:SetShown(not hasIcon);
end

function PlayerFrame_UpdateArt(self)
	if (UnitHasVehiclePlayerFrameUI("player")) then
		PlayerFrame_ToVehicleArt(self);
	else
		PlayerFrame_ToPlayerArt(self);
	end

	if (self.updatePetFrame) then
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
	local playerFrameTargetContextual = PlayerFrame_GetPlayerFrameContentContextual();
	local attackIcon = playerFrameTargetContextual.AttackIcon;
	local playerPortraitCornerIcon = playerFrameTargetContextual.PlayerPortraitCornerIcon;
	local statusTexture = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture;

	if (IsResting()) then
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
	local playerFrameTargetContextual = PlayerFrame_GetPlayerFrameContentContextual();
	local playerPlayTime = playerFrameTargetContextual.PlayerPlayTime;
	local playTimeIcon = playerFrameTargetContextual.PlayerPlayTime.PlayTimeIcon;

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
	PlayerFrame.state = "vehicle";

	local healthBar = PlayerFrame_GetHealthBar();
	local manaBar = PlayerFrame_GetManaBar();

	--Swap pet and player frames
	UnitFrame_SetUnit(self, "vehicle", healthBar, manaBar);
	UnitFrame_SetUnit(PetFrame, "player", PetFrameHealthBar, PetFrameManaBar);

	-- Swap frame textures
	PlayerFrame.PlayerFrameContainer.FrameTexture:Hide();
	PlayerFrame.PlayerFrameContainer.VehicleFrameTexture:Show();

	-- Update Flash and Status Textures
	local frameFlash = PlayerFrame.PlayerFrameContainer.FrameFlash;
	frameFlash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Vehicle-InCombat", TextureKitConstants.UseAtlasSize);
	frameFlash:SetPoint("CENTER", frameFlash:GetParent(), "CENTER", -3.5, 1);

	local statusTexture = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture;
	statusTexture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Vehicle-Status", TextureKitConstants.UseAtlasSize);
	statusTexture:SetPoint("TOPLEFT", frameFlash:GetParent(), "TOPLEFT", 11, -8);

	-- Update health bar
	healthBar:SetWidth(118);
	healthBar:SetHeight(20);
	healthBar:SetPoint("TOPLEFT", 91, -40);

	healthBar.HealthBarMask:SetPoint("TOPLEFT", healthBar.HealthBarMask:GetParent(), "TOPLEFT", -8, 6);

	-- Update mana bar
	manaBar:SetWidth(118);
	manaBar:SetHeight(10);
	manaBar:SetPoint("TOPLEFT",91,-61);

	manaBar.ManaBarMask:SetWidth(121);

	-- Update power bar
	local _, class = UnitClass("player");
	if PlayerFrame.classPowerBar then
		PlayerFrame.classPowerBar:Hide();
	elseif class == "SHAMAN" then
		TotemFrame:Hide();
	elseif class == "DEATHKNIGHT" then
		RuneFrame:Hide();
	elseif class == "PRIEST" then
		PriestBarFrame:Hide();
	end
	ComboPointPlayerFrame:Setup();
	EssencePlayerFrame:Setup();

	-- Update other stuff
	PlayerFrame_Update();
	PetFrame:Update();
	BuffFrame:Update();
	DebuffFrame:Update();
	ComboFrame_Update(ComboFrame);

	PlayerFrame_UpdateRolesAssigned();
	PlayerFrame_UpdatePlayerNameTextAnchor();
	local playerFrameTargetContextual = PlayerFrame_GetPlayerFrameContentContextual();
	playerFrameTargetContextual.GroupIndicator:SetPoint("BOTTOMRIGHT", PlayerFrame, "TOPLEFT", 210, -26);
	playerFrameTargetContextual.RoleIcon:SetPoint("TOPLEFT", 194, -27);
	playerFrameTargetContextual.PvpTimerText:SetPoint("TOPLEFT", 45, -87);
	PlayerLevelText:Hide();
end

function PlayerFrame_ToPlayerArt(self)
	PlayerFrame.state = "player";

	local healthBar = PlayerFrame_GetHealthBar();
	local manaBar = PlayerFrame_GetManaBar();

	-- Unswap pet and player frames
	UnitFrame_SetUnit(self, "player", healthBar, manaBar);
	UnitFrame_SetUnit(PetFrame, "pet", PetFrameHealthBar, PetFrameManaBar);

	-- Swap frame textures
	PlayerFrame.PlayerFrameContainer.FrameTexture:Show();
	PlayerFrame.PlayerFrameContainer.VehicleFrameTexture:Hide();

	-- Update Flash and Status Textures
	local frameFlash = PlayerFrame.PlayerFrameContainer.FrameFlash;
	frameFlash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize);
	frameFlash:SetPoint("CENTER", frameFlash:GetParent(), "CENTER", -1.5, 1);

	local statusTexture = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture;
	statusTexture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Status", TextureKitConstants.UseAtlasSize);
	statusTexture:SetPoint("TOPLEFT", frameFlash:GetParent(), "TOPLEFT", 18, -14);

	-- Update health bar
	healthBar:SetHeight(20);
	healthBar:SetWidth(124);
	healthBar:SetPoint("TOPLEFT", 85, -40);

	healthBar.HealthBarMask:SetPoint("TOPLEFT", healthBar.HealthBarMask:GetParent(), "TOPLEFT", -2, 6);

	-- Update mana bar
	manaBar:SetHeight(10);
	manaBar:SetWidth(124);
	manaBar:SetPoint("TOPLEFT", 85, -61);

	manaBar.ManaBarMask:SetWidth(128);

	-- Update power bar
	local _, class = UnitClass("player");
	if (PlayerFrame.classPowerBar) then
		PlayerFrame.classPowerBar:Setup();
	elseif (class == "SHAMAN") then
		TotemFrame:Update(); 
	elseif (class == "DEATHKNIGHT") then
		RuneFrame:Show();
	elseif (class == "PRIEST") then
		PriestBarFrame_CheckAndShow();
	end
	ComboPointPlayerFrame:Setup();
	EssencePlayerFrame:Setup();

	-- Update other stuff
	PlayerFrame_Update();
	PetFrame:Update();
	BuffFrame:Update();
	DebuffFrame:Update();
	ComboFrame_Update(ComboFrame);

	PlayerFrame_UpdateRolesAssigned();
	PlayerFrame_UpdatePlayerNameTextAnchor();
	local playerFrameTargetContextual = PlayerFrame_GetPlayerFrameContentContextual();
	playerFrameTargetContextual.GroupIndicator:SetPoint("BOTTOMRIGHT", PlayerFrame, "TOPLEFT", 210, -27);
	playerFrameTargetContextual.RoleIcon:SetPoint("TOPLEFT", 196, -27);
	playerFrameTargetContextual.PvpTimerText:SetPoint("TOPLEFT", 45, -82);
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

local function AnchorCastBarToPlayerFrame()
	PlayerCastingBarFrame:ClearAllPoints()
	if(PlayerFrameBottomManagedFramesContainer:IsShown() and PlayerFrameBottomManagedFramesContainer:GetHeight() > 0) then
		PlayerCastingBarFrame:SetPoint("TOP", PlayerFrameBottomManagedFramesContainer, "BOTTOM", -10, -5);
	else
		PlayerCastingBarFrame:SetPoint("TOP", PlayerFrame, "BOTTOM", 20, 10);
	end
end

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
	PlayerCastingBarFrame:SetFixedFrameStrata(false); -- Inherit parent strata while locked
	PlayerCastingBarFrame:SetParent(PlayerFrame);
	AnchorCastBarToPlayerFrame();
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
	PlayerCastingBarFrame:SetFrameStrata("HIGH"); -- Maintain HIGH strata while unlocked
	PlayerCastingBarFrame:SetFixedFrameStrata(true);
	-- Will be re-anchored via edit mode
end

function PlayerFrame_AdjustAttachments()
	if (PlayerCastingBarFrame.attachedToPlayerFrame) then
		AnchorCastBarToPlayerFrame();
	end
end

PlayerFrameBottomManagedFramesContainerMixin = {};

function PlayerFrameBottomManagedFramesContainerMixin:Layout()
	LayoutMixin.Layout(self);
	PlayerFrame_AdjustAttachments();
end
