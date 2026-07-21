
PartyMemberFrameMixin = CreateFromMixins(PartyMemberAuraMixin);

function PartyMemberFrameMixin:GetUnit()
	-- Override unit is set when we get in a vehicle
	-- Override unit will always be the original (most likely player/party member)
	return self.overrideUnit or self.unit;
end

function PartyMemberFrameMixin:UpdateArt()
	self:ToPlayerArt();
end

function PartyMemberFrameMixin:ToPlayerArt()
	self.state = "player";
	self.overrideUnit = nil;

	self.PartyMemberOverlay.VehicleTexture:Hide();
	self.PartyMemberOverlay.Texture:Show();

	self.Portrait:SetPoint("TOPLEFT", 7, -6);
	self.PartyMemberOverlay.LeaderIcon:SetPoint("TOPLEFT", 0, 0);
	self.PartyMemberOverlay.PVPIcon:SetPoint("TOPLEFT", -9, -15);
	self.PartyMemberOverlay.Disconnect:SetPoint("LEFT", -7, -1);

	UnitFrame_SetUnit(self, self.unit, self.HealthBar, self.ManaBar);
	UnitFrame_SetUnit(self.PetFrame, self.PetFrame.unit, self.PetFrame.HealthBar, nil);
	UnitFrame_Update(self, true)
end

function PartyMemberFrameMixin:ToVehicleArt(vehicleType)
	self.state = "vehicle";
	self.overrideUnit = self.unit;

	self.PartyMemberOverlay.Texture:Hide();
	if ( vehicleType == "Natural" ) then
		self.PartyMemberOverlay.VehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicles-PartyFrame-Organic");
	else
		self.PartyMemberOverlay.VehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicles-PartyFrame");
	end
	self.PartyMemberOverlay.VehicleTexture:Show();

	self.Portrait:SetPoint("TOPLEFT", 4, -9);
	self.PartyMemberOverlay.LeaderIcon:SetPoint("TOPLEFT", -3, 0);
	self.PartyMemberOverlay.PVPIcon:SetPoint("TOPLEFT", -12, -15);
	self.PartyMemberOverlay.Disconnect:SetPoint("LEFT", -10, -1);

	UnitFrame_SetUnit(self, self.petUnitToken, self.HealthBar, self.ManaBar);
	UnitFrame_SetUnit(self.PetFrame, self.overrideUnit, self.PetFrame.HealthBar, nil);
	UnitFrame_Update(self, true)
end


function PartyMemberFrameMixin:Setup()
	self.unitToken = "party"..self.layoutIndex;
	self.petUnitToken = "partypet"..self.layoutIndex;

	self.debuffCountdown = 0;
	self.numDebuffs = 0;

	self.PetFrame:Setup();

	self.noTextPrefix = true;
	self.HealthBar.LeftText = self.HealthBarTextLeft;
	self.HealthBar.RightText = self.HealthBarTextRight;
	self.ManaBar.LeftText = self.ManaBarTextLeft;
	self.ManaBar.RightText = self.ManaBarTextRight;

	local healthBar = self.HealthBar;

	UnitFrame_Initialize(self, self.unitToken, self.PartyMemberOverlay.Name, self.Portrait,
			healthBar,
			self.HealthBarText,
			self.ManaBar,
			self.ManaBarText,
			self.Flash, nil, nil,
			healthBar.MyHealPredictionBar,
			healthBar.OtherHealPredictionBar,
			healthBar.TotalAbsorbBar, healthBar.TotalAbsorbBarOverlay,
			self.PartyMemberOverlay.overAbsorbGlow, self.PartyMemberOverlay.overHealAbsorbGlow,
			healthBar.HealAbsorbBar, healthBar.HealAbsorbBarLeftShadow,
			healthBar.HealAbsorbBarRightShadow);

	self.HealthBar:SetBarTextZeroText(DEAD);

	self.AuraFramePool = CreateFramePool("BUTTON", self.AuraFrameContainer, "PartyAuraFrameTemplate");
	self.PetFrame.AuraFramePool = CreateFramePool("BUTTON", self.PetFrame.AuraFrameContainer, "PartyAuraFrameTemplate");

	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;
	self:UpdateMember();
	self:UpdateLeader();
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("UPDATE_ACTIVE_BATTLEFIELD");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	self:RegisterEvent("UNIT_FACTION");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_CONFIRM");
	self:RegisterEvent("READY_CHECK_FINISHED");
	self:RegisterEvent("UNIT_CONNECTION");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
	self:RegisterEvent("UNIT_PHASE");
	self:RegisterEvent("UNIT_FLAGS");
	self:RegisterEvent("UNIT_OTHER_PARTY_CHANGED");
	self:RegisterUnitEvent("UNIT_AURA", self.unitToken, self.petUnitToken);
	self:RegisterUnitEvent("UNIT_PET",  self.unitToken, self.petUnitToken);

	local function OpenContextMenu(frame, unit, button, isKeyPress)
		local contextData =
		{
			unit = unit,
		};
		UnitPopup_OpenMenu("PARTY", contextData);
	end

	SecureUnitButton_OnLoad(self, self.unitToken, OpenContextMenu);

	self:UpdateArt();
	self:SetFrameLevel(2);
	self:UpdateNotPresentIcon();

	local altPowerBar = self.PowerBarAlt;
	if altPowerBar then
		UnitPowerBarAlt_Initialize(altPowerBar, self.unitToken, 0.5, "GROUP_ROSTER_UPDATE");
	end

	CVarCallbackRegistry:RegisterCallback("showPartyPets", self.UpdatePet, self);

	self.initialized = true;
end

function PartyMemberFrameMixin:UpdateVoiceActivityNotification()
	if self.voiceNotification then
		self.voiceNotification:ClearAllPoints();
		if self.NotPresentIcon:IsShown() then
			self.voiceNotification:SetPoint("LEFT", self.NotPresentIcon, "RIGHT", 0, 0);
		else
			self.voiceNotification:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -12);
		end
	end
end

function PartyMemberFrameMixin:VoiceActivityNotificationCreatedCallback(notification)
	self.voiceNotification = notification;
	self.voiceNotification:SetParent(self);
	self:UpdateVoiceActivityNotification();
	notification:Show();
end

function PartyMemberFrameMixin:UpdateMember()
	if not PartyFrame:ShouldShow() then
		self:Hide();
		PartyFrame:UpdatePartyMemberBackground();
		return;
	end

	local showFrame;
	if EditModeManagerFrame:ArePartyFramesForcedShown() and not UnitExists(self.unitToken) then
		UnitFrame_SetUnit(self, "player", self.HealthBar, self.ManaBar);
		UnitFrame_SetUnit(self.PetFrame, "pet", self.PetFrame.HealthBar);
		showFrame = true;
	else
		UnitFrame_SetUnit(self, self.unitToken, self.HealthBar, self.ManaBar);
		UnitFrame_SetUnit(self.PetFrame, self.petUnitToken, self.PetFrame.HealthBar);
		showFrame = UnitExists(self.unitToken);
	end
	if showFrame then
		self:Show();

		if VoiceActivityManager then
			local guid = UnitGUID(self:GetUnit());
			VoiceActivityManager:RegisterFrameForVoiceActivityNotifications(self, guid, nil, "VoiceActivityNotificationPartyTemplate", "Button", PartyMemberFrameMixin.VoiceActivityNotificationCreatedCallback);
		end

		UnitFrame_Update(self, true);
	else
		if VoiceActivityManager then
			VoiceActivityManager:UnregisterFrameForVoiceActivityNotifications(self);
			self.voiceNotification = nil;
		end
		self:Hide();
	end
	self:UpdatePet();
	self:UpdatePvPStatus();
	self:UpdateAuras();
	self:UpdateReadyCheck();
	self:UpdateOnlineStatus();
	self:UpdateNotPresentIcon();
	self:UpdateArt();
	PartyFrame:UpdatePartyMemberBackground();
end

function PartyMemberFrameMixin:UpdatePet()
	if UnitIsConnected(self:GetUnit()) and UnitExists(self.PetFrame.unit) and CVarCallbackRegistry:GetCVarValueBool("showPartyPets") then
		self.PetFrame:Show();
	else
		self.PetFrame:Hide();
	end

	self.PetFrame:UpdateAuras();
	PartyFrame:UpdatePartyMemberBackground();
end

function PartyMemberFrameMixin:UpdateMemberHealth(elapsed)
	if ( (self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2) ) then
		local alpha = 255;
		local counter = self.statusCounter + elapsed;
		local sign    = self.statusSign;

		if ( counter > 0.5 ) then
			sign = -sign;
			self.statusSign = sign;
		end
		counter = mod(counter, 0.5);
		self.statusCounter = counter;

		if ( sign == 1 ) then
			alpha = (127  + (counter * 256)) / 255;
		else
			alpha = (255 - (counter * 256)) / 255;
		end
		self.Portrait:SetAlpha(alpha);
	end
end

function PartyMemberFrameMixin:UpdateLeader()
	local leaderIcon = self.PartyMemberOverlay.LeaderIcon;
	local guideIcon = self.PartyMemberOverlay.GuideIcon;
	local masterIcon = self.PartyMemberOverlay.MasterIcon;

	if UnitIsGroupLeader(self:GetUnit()) then
		leaderIcon:Show();
		guideIcon:Hide();
	else
		guideIcon:Hide();
		leaderIcon:Hide();
	end

	local lootMethod, lootMaster = C_PartyInfo.GetLootMethod();
	local selfID = self.layoutIndex;
	if lootMaster == selfID then
		masterIcon:Show();
	else
		masterIcon:Hide();
	end
end

function PartyMemberFrameMixin:UpdatePvPStatus()
	local icon = self.PartyMemberOverlay.PVPIcon;
	local factionGroup = UnitFactionGroup(self:GetUnit());
	if UnitIsPVPFreeForAll(self:GetUnit()) then
		icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		icon:Show();
	elseif factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(self:GetUnit()) then
		icon:SetTexture("Interface\\GroupFrame\\UI-Group-PVP-"..factionGroup);
		icon:Show();
	else
		icon:Hide();
	end
end

function PartyMemberFrameMixin:UpdateReadyCheck()
	local readyCheckFrame = self.ReadyCheck;
	local readyCheckStatus = GetReadyCheckStatus(self:GetUnit());
	if UnitName(self:GetUnit()) and UnitIsConnected(self:GetUnit()) and readyCheckStatus then
		if ( readyCheckStatus == "ready" ) then
			ReadyCheck_Confirm(readyCheckFrame, 1);
		elseif ( readyCheckStatus == "notready" ) then
			ReadyCheck_Confirm(readyCheckFrame, 0);
		else -- "waiting"
			ReadyCheck_Start(readyCheckFrame);
		end
	else
		readyCheckFrame:Hide();
	end
end

function PartyMemberFrameMixin:UpdateNotPresentIcon()
	if UnitInOtherParty(self:GetUnit()) then
		self:SetAlpha(0.6);
		self.NotPresentIcon.texture:SetTexture("Interface\\LFGFrame\\LFG-Eye");
		self.NotPresentIcon.texture:SetTexCoord(0.125, 0.25, 0.25, 0.5);
		self.NotPresentIcon.Border:Show();
		self.NotPresentIcon.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE;
		self.NotPresentIcon:Show();
	else
		local phaseReason = UnitIsConnected(self:GetUnit()) and UnitPhaseReason(self:GetUnit()) or nil;
		if phaseReason then
			self:SetAlpha(0.6);
			self.NotPresentIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon");
			self.NotPresentIcon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375);
			self.NotPresentIcon.Border:Hide();
			self.NotPresentIcon.tooltip = PartyUtil.GetPhasedReasonString(phaseReason, self:GetUnit());
			self.NotPresentIcon:Show();
		else
			self:SetAlpha(1);
			self.NotPresentIcon:Hide();
		end
	end

	self:UpdateVoiceActivityNotification();
end

function PartyMemberFrameMixin:OnEvent(event, ...)
	UnitFrame_OnEvent(self, event, ...);

	local arg1, arg2, arg3 = ...;
	local selfID = self.layoutIndex;

	if event == "PLAYER_ENTERING_WORLD" then
		if UnitExists(self:GetUnit()) then
			self:UpdateMember();
			self:UpdateOnlineStatus();
		end
	elseif event == "GROUP_ROSTER_UPDATE" or event == "UPDATE_ACTIVE_BATTLEFIELD" then
		self:UpdateMember();
		self:UpdateArt();
		self:UpdateLeader();
	elseif event == "PARTY_LEADER_CHANGED" then
		self:UpdateLeader();
	elseif event == "UNIT_FACTION" then
		if arg1 == self:GetUnit() then
			self:UpdatePvPStatus();
		end
	elseif event =="UNIT_AURA" then
		if arg1 == self:GetUnit() then
			local unitAuraUpdateInfo = arg2;
			self:UpdateAuras(unitAuraUpdateInfo);
			if ( PartyMemberBuffTooltip:IsShown() and
				selfID == PartyMemberBuffTooltip:GetID() ) then
				PartyMemberBuffTooltip:UpdateTooltip(self);
			end
		else
			if arg1 == self.petUnitToken then
				self.PetFrame:UpdateAuras(unitAuraUpdateInfo);
			end
		end
	elseif event == "UNIT_PET" then
		if arg1 == self:GetUnit() then
			self:UpdatePet();
		end
	elseif event == "READY_CHECK" or event == "READY_CHECK_CONFIRM" then
		self:UpdateReadyCheck();
	elseif event == "READY_CHECK_FINISHED" then
		if UnitExists(self:GetUnit()) then
			local finishTime = DEFAULT_READY_CHECK_STAY_TIME;
			if not PartyFrame:ShouldShow() then
				finishTime = 0;
			end
			ReadyCheck_Finish(self.ReadyCheck, finishTime);
		end
	elseif event == "VARIABLES_LOADED" then
		self:UpdatePet();
	elseif event == "UNIT_ENTERED_VEHICLE" then
		if arg1 == self:GetUnit() then
			if arg2 and UnitIsConnected(self:GetUnit()) then
				self:ToVehicleArt(arg3);
			else
				self:ToPlayerArt();
			end
			self:UpdateMember();
		end
	elseif event == "UNIT_EXITED_VEHICLE" then
		if arg1 == self:GetUnit() then
			self:ToPlayerArt();
			self:UpdateMember();
		end
	elseif event == "UNIT_CONNECTION" and arg1 == self:GetUnit() then
		self:UpdateArt();
		self:UpdateOnlineStatus();
	elseif event == "UNIT_PHASE" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" or event == "UNIT_FLAGS" then
		if event ~= "UNIT_PHASE" or arg1 == self:GetUnit() then
			self:UpdateNotPresentIcon();
		end
	elseif event == "UNIT_OTHER_PARTY_CHANGED" and arg1 == self:GetUnit() then
		self:UpdateNotPresentIcon();
	end
end

function PartyMemberFrameMixin:OnUpdate(elapsed)
	if self.initialized then
		self:UpdateMemberHealth(elapsed);
		local partyStatus = self.PartyMemberOverlay.Status;
		if ( self.hasDispellable ) then
			partyStatus:Show();
			-- Yes, the Classic Party Member Frame does pull the pulsing alpha for its debuff warning from the Buff Frame.
			-- Should be refactored if/when this causes trouble.
			partyStatus:SetAlpha(BuffFrame.AuraContainer:GetAuraWarningAlphaForDuration(0));

			if ( self.debuffCountdown and self.debuffCountdown > 0 ) then
				self.debuffCountdown = self.debuffCountdown - elapsed;
			else
				partyStatus:Hide();
			end
		else
			partyStatus:Hide();
		end
	end
end

function PartyMemberFrameMixin:OnEnter()
	UnitFrame_OnEnter(self);
	PartyMemberBuffTooltip:SetPoint("TOPLEFT", self, "TOPLEFT", 47, -30);
	PartyMemberBuffTooltip:UpdateTooltip(self);
end

function PartyMemberFrameMixin:OnLeave()
	UnitFrame_OnLeave(self);
	PartyMemberBuffTooltip:Hide();
end

function PartyMemberFrameMixin:UpdateOnlineStatus()
	local healthBar = self.HealthBar;

	if not UnitIsConnected(self:GetUnit()) then
		-- Handle disconnected state
		local unitHPMin, unitHPMax = healthBar:GetMinMaxValues();

		healthBar:SetValue(unitHPMax);
		healthBar:SetStatusBarDesaturated(true);
		SetDesaturation(self.Portrait, true);
		self.PartyMemberOverlay.Disconnect:Show();
		self.PetFrame:Hide();
	else
		healthBar:SetStatusBarDesaturated(false);
		SetDesaturation(self.Portrait, false);
		self.PartyMemberOverlay.Disconnect:Hide();
	end
end

function PartyMemberFrameMixin:UpdateAuras(unitAuraUpdateInfo)
	self:UpdateMemberAuras(unitAuraUpdateInfo);
end

function PartyMemberFrameMixin:PartyMemberHealthCheck(value)
	local unitHPMin, unitHPMax, unitCurrHP;
	unitHPMin, unitHPMax = self.HealthBar:GetMinMaxValues();

	unitCurrHP = self.HealthBar:GetValue();
	if unitHPMax > 0 then
		self.unitHPPercent = unitCurrHP / unitHPMax;
	else
		self.unitHPPercent = 0;
	end

	local unit = self:GetUnit();
	local unitIsDead = UnitIsDead(unit);
	local unitIsGhost = UnitIsGhost(unit);

	if unitIsDead then
		self.Portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
	elseif unitIsGhost then
		self.Portrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
	elseif (self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2) then
		self.Portrait:SetVertexColor(1.0, 0.0, 0.0);
	else
		self.Portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
	end
end

PartyMemberPetFrameMixin = CreateFromMixins(PartyMemberAuraMixin);

function PartyMemberPetFrameMixin:UpdateAuras(unitAuraUpdateInfo)
	self:UpdateMemberAuras(unitAuraUpdateInfo);
end

function PartyMemberPetFrameMixin:Setup()
	self.unitToken = "partypet"..self:GetParent().layoutIndex;
	UnitFrame_Initialize(self, self.unitToken, self.Name, self.Portrait,
				self.HealthBar, self.HealthBarText,
				nil, nil, self.Flash,
				nil, nil, self.MyHealPredictionBar, self.OtherHealPredictionBar);
	self.HealthBar:SetBarTextZeroText(DEAD);
	self.Name:Hide();
	SecureUnitButton_OnLoad(self, self.unitToken);
end

function PartyMemberPetFrameMixin:OnShow()
	UnitFrame_Update(self);
end

function PartyMemberPetFrameMixin:OnEvent(event, ...)
	UnitFrame_OnEvent(self, event, ...);
end

function PartyMemberPetFrameMixin:OnEnter()
	UnitFrame_OnEnter(self, motion);
end

function PartyMemberPetFrameMixin:OnLeave()
	UnitFrame_OnLeave(self, motion);
end

