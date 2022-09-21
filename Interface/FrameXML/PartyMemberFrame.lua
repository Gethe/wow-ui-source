MAX_PARTY_MEMBERS = 4;
MAX_PARTY_BUFFS = 4;
MAX_PARTY_DEBUFFS = 4;
MAX_PARTY_TOOLTIP_BUFFS = 16;
MAX_PARTY_TOOLTIP_BUFFS_PER_ROW = 8;
MAX_PARTY_TOOLTIP_DEBUFFS = 8;

CVarCallbackRegistry:SetCVarCachable("showPartyPets");
CVarCallbackRegistry:SetCVarCachable("showCastableBuffs");
CVarCallbackRegistry:SetCVarCachable("showDispelDebuffs");

PartyMemberAuraMixin={};

function PartyMemberAuraMixin:UpdateMemberAuras(unitAuraUpdateInfo)
	self:UpdateAurasInternal(unitAuraUpdateInfo);
end

function PartyMemberAuraMixin:UpdateAurasInternal(unitAuraUpdateInfo)
	local displayOnlyDispellableDebuffs = CVarCallbackRegistry:GetCVarValueBool("showDispelDebuffs") and UnitCanAssist("player", self.unit);
	-- Buffs are only displayed in the Party Buff Tooltip
	local ignoreBuffs = MAX_PARTY_TOOLTIP_BUFFS == 0;
	local ignoreDebuffs = MAX_PARTY_DEBUFFS == 0;
	local ignoreDispelDebuffs = MAX_PARTY_DEBUFFS == 0;

	local debuffsChanged = false;

	if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or self.debuffs == nil then
		self:ParseAllAuras(displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs);
		debuffsChanged = true;
	else
		if unitAuraUpdateInfo.addedAuras ~= nil then
			for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
				local type = AuraUtil.ProcessAura(aura, displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs);

				if type == AuraUtil.AuraUpdateChangedType.Debuff or type == AuraUtil.AuraUpdateChangedType.Dispel then
					self.debuffs[aura.auraInstanceID] = aura;
					debuffsChanged = true;
				elseif type == AuraUtil.AuraUpdateChangedType.Buff then
					self.buffs[aura.auraInstanceID] = aura;
				end
			end
		end

		if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
				if self.debuffs[auraInstanceID] ~= nil then
					local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID);
					local oldDebuffType = self.debuffs[auraInstanceID].debuffType;
					if newAura ~= nil then
						newAura.debuffType = oldDebuffType;
					end
					self.debuffs[auraInstanceID] = newAura;
					debuffsChanged = true;
				elseif self.buffs[auraInstanceID] ~= nil then
					local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID);
					if newAura ~= nil then
						newAura.isBuff = true;
					end
					self.buffs[auraInstanceID] = newAura;
				end
			end
		end

		if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
				if self.debuffs[auraInstanceID] ~= nil then
					self.debuffs[auraInstanceID] = nil;
					debuffsChanged = true;
				elseif self.buffs[auraInstanceID] ~= nil then
					self.buffs[auraInstanceID] = nil;
				end
			end
		end
	end

	if debuffsChanged then
		local frameNum = 1;
		self.DebuffFramePool:ReleaseAll();
		self.debuffs:Iterate(function(auraInstanceID, aura)
			if frameNum > MAX_PARTY_DEBUFFS then
				return true;
			end

			local debuffFrame = self.DebuffFramePool:Acquire();
			debuffFrame:Setup(self.unit, frameNum);
			debuffFrame:SetPoint("TOPLEFT");
			debuffFrame.layoutIndex = frameNum;			
			self:SetDebuff(debuffFrame, aura);
			frameNum = frameNum + 1;

			return false;
		end);

		self.DebuffFrameContainer:SetPoint("TOPLEFT", 48, -43);
		self.DebuffFrameContainer:Layout();

		local unitStatus;
		if self.PartyMemberOverlay then
			unitStatus = self.PartyMemberOverlay.Status;
		end

		if unitStatus then
			local highestPriorityDebuff = self.debuffs:GetTop();
			if highestPriorityDebuff then
				local statusColor = DebuffTypeColor[highestPriorityDebuff.dispelName] or DebuffTypeColor["none"];
				unitStatus:SetVertexColor(statusColor.r, statusColor.g, statusColor.b);
				unitStatus:Show();
			else
				unitStatus:Hide();
			end
		end
	end
end

function PartyMemberAuraMixin:ParseAllAuras(displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs) 
	if self.debuffs == nil then
		self.debuffs = TableUtil.CreatePriorityTable(AuraUtil.UnitFrameDebuffComparator, TableUtil.Constants.AssociativePriorityTable);
		self.buffs = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
	else
		self.debuffs:Clear();
		self.buffs:Clear();
	end

	local batchCount = nil;
	local usePackedAura = true;
	local function HandleAura(aura)
		local type = AuraUtil.ProcessAura(aura, displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs);

		if type == AuraUtil.AuraUpdateChangedType.Debuff or type == AuraUtil.AuraUpdateChangedType.Dispel then
			self.debuffs[aura.auraInstanceID] = aura;
		elseif type == AuraUtil.AuraUpdateChangedType.Buff then
			self.buffs[aura.auraInstanceID] = aura;
		end
	end
	AuraUtil.ForEachAura(self.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful), batchCount, HandleAura, usePackedAura);
	AuraUtil.ForEachAura(self.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful), batchCount, HandleAura, usePackedAura);
	AuraUtil.ForEachAura(self.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful, AuraUtil.AuraFilters.Raid), batchCount, HandleAura, usePackedAura);
end

function PartyMemberAuraMixin:SetDebuff(debuffFrame, aura)
	debuffFrame.auraInstanceID = aura.auraInstanceID;
	debuffFrame.isBossBuff = aura.isBossAura and aura.isHelpful;
	debuffFrame.filter = aura.isRaid and AuraUtil.AuraFilters.Raid;

	if aura.icon then
		debuffFrame.Icon:SetTexture(aura.icon);

		if ( aura.applications > 1 ) then
				local countText = aura.applications >= 100 and BUFF_STACKS_OVERFLOW or aura.applications;
				debuffFrame.Count:Show();
				debuffFrame.Count:SetText(countText);
		else
			debuffFrame.Count:Hide();
		end

		local color = DebuffTypeColor[aura.dispelName] or DebuffTypeColor["none"];
		debuffFrame.Border:SetVertexColor(color.r, color.g, color.b);

		local enabled = aura.expirationTime and aura.expirationTime ~= 0;
		if enabled then
			local startTime = aura.expirationTime - aura.duration;
			CooldownFrame_Set(debuffFrame.Cooldown, startTime, aura.duration, true);
		else
			CooldownFrame_Clear(debuffFrame.Cooldown);
		end

		debuffFrame:Show();
	end
end

PartyMemberFrameMixin=CreateFromMixins(PartyMemberAuraMixin);

function PartyMemberFrameMixin:UpdateArt()
	if ( UnitHasVehicleUI(self.unit) and UnitIsConnected(self.unit) ) then
		local vehicleType = UnitVehicleSkin(self.unit);
		self:ToVehicleArt(vehicleType);
	else
		self:ToPlayerArt();
	end
end

function PartyMemberFrameMixin:ToPlayerArt()
	self.state = "player";
	self.VehicleTexture:Hide();
	self.Texture:Show();
	self.Portrait:SetPoint("TOPLEFT", 7, -6);
	self.PartyMemberOverlay.PVPIcon:SetPoint("CENTER", self.PartyMemberOverlay, "TOPLEFT", 24, -68);
	self.PartyMemberOverlay.Disconnect:SetPoint("LEFT", -7, -1);

	self.overrideName = nil;

	UnitFrame_SetUnit(self, self.unit, self.HealthBar, self.ManaBar);
	UnitFrame_SetUnit(self.PetFrame, self.PetFrame.unit, self.PetFrame.HealthBar, nil);

	UnitFrame_Update(self, true)
end

function PartyMemberFrameMixin:ToVehicleArt(vehicleType)
	self.state = "vehicle";
	self.Texture:Hide();
	if ( vehicleType == "Natural" ) then
		self.VehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicles-PartyFrame-Organic");
	else
		self.VehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicles-PartyFrame");
	end
	self.VehicleTexture:Show();
	self.Portrait:SetPoint("TOPLEFT", 4, -12);
	self.PartyMemberOverlay.PVPIcon:SetPoint("CENTER", self.PartyMemberOverlay, "TOPLEFT", 16, -83);
	self.PartyMemberOverlay.Disconnect:SetPoint("LEFT", -10, -9);

	self.overrideName = self.unit;

	UnitFrame_SetUnit(self, self.petUnitToken, self.HealthBar, self.ManaBar);
	UnitFrame_SetUnit(self.PetFrame, self.overrideName, self.PetFrame.HealthBar, nil);

	UnitFrame_Update(self, true)
end

function PartyMemberFrameMixin:Setup()
	self.unitToken = "party"..self.layoutIndex;
	self.petUnitToken = "partypet"..self.layoutIndex;

	self.debuffCountdown = 0;
	self.numDebuffs = 0;
	
	self.PetFrame:Setup();

	UnitFrame_Initialize(self, self.unitToken,  self.Name, self.Portrait,
		   self.HealthBar, self.HealthBar.CenterText,
		   self.ManaBar, self.ManaBar.CenterText,
		   self.Flash, nil, nil, self.HealthBar.MyHealPredictionBar, self.HealthBar.OtherHealPredictionBar,
		   self.TotalAbsorbBar, self.TotalAbsorbBarOverlay, self.HealthBar.OverAbsorbGlow,
		   self.HealthBar.OverHealAbsorbGlow, self.HealthBar.HealAbsorbBar, self.HealthBar.HealAbsorbBarLeftShadow,
		   self.HealthBar.HealAbsorbBarRightShadow);
	SetTextStatusBarTextZeroText(self.HealthBar, DEAD);

	self.DebuffFramePool = CreateFramePool("BUTTON", self.DebuffFrameContainer, "PartyDebuffFrameTemplate");
	self.PetFrame.DebuffFramePool = CreateFramePool("BUTTON", self.PetFrame.DebuffFrameContainer, "PartyDebuffFrameTemplate");

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
	self:RegisterEvent("MUTELIST_UPDATE");
	self:RegisterEvent("IGNORELIST_UPDATE");
	self:RegisterEvent("UNIT_FACTION");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_CONFIRM");
	self:RegisterEvent("READY_CHECK_FINISHED");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("UNIT_CONNECTION");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
	self:RegisterEvent("UNIT_PHASE");
	self:RegisterEvent("UNIT_CTR_OPTIONS");
	self:RegisterEvent("UNIT_FLAGS");
	self:RegisterEvent("UNIT_OTHER_PARTY_CHANGED");
	self:RegisterEvent("INCOMING_SUMMON_CHANGED");
	self:RegisterUnitEvent("UNIT_AURA", self.unitToken, self.petUnitToken);
	self:RegisterUnitEvent("UNIT_PET",  self.unitToken, self.petUnitToken);
	local showmenu = function()
		ToggleDropDownMenu(1, nil, self.DropDown, self, 47, 15);
	end
	SecureUnitButton_OnLoad(self, self.unitToken, showmenu);

	self:UpdateArt();
	self:SetFrameLevel(2);
	self:UpdateNotPresentIcon();
	
	UIDropDownMenu_SetInitializeFunction(self.DropDown, PartyMemberFrameMixin.InitializePartyFrameDropDown);
	UIDropDownMenu_SetDisplayMode(self.DropDown, "MENU");

	UnitPowerBarAlt_Initialize(self.PowerBarAlt, self.unitToken, 0.5, "GROUP_ROSTER_UPDATE");
	
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
	if not ShouldShowPartyFrames() then
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
			local guid = UnitGUID(self.unit);
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
	self:UpdateVoiceStatus();
	self:UpdateReadyCheck();
	self:UpdateOnlineStatus();
	self:UpdateNotPresentIcon();
	self:UpdateArt();
	PartyFrame:UpdatePartyMemberBackground();
end

function PartyMemberFrameMixin:UpdatePet()
	if ( UnitIsConnected(self.unit) and UnitExists(self.PetFrame.unit) and CVarCallbackRegistry:GetCVarValueBool("showPartyPets") ) then
		self.PetFrame:Show();
		self.PetFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 23, -43);
	else
		self.PetFrame:Hide();
		self.PetFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 23, -27);
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

	if( UnitIsGroupLeader(self.unit) ) then
		if ( HasLFGRestrictions() ) then
			guideIcon:Show();
			leaderIcon:Hide();
		else
			leaderIcon:Show();
			guideIcon:Hide();
		end
	else
		guideIcon:Hide();
		leaderIcon:Hide();
	end
end

function PartyMemberFrameMixin:UpdatePvPStatus()
	local icon = self.PartyMemberOverlay.PVPIcon;
	local factionGroup = UnitFactionGroup(self.unit);
	if UnitIsPVPFreeForAll(self.unit) then
		icon:SetAtlas("ui-hud-unitframe-player-pvp-ffaicon", true);
		icon:Show();
	elseif factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(self.unit) then
		local atlas = (factionGroup == "Horde") and "ui-hud-unitframe-player-pvp-hordeicon" or "ui-hud-unitframe-player-pvp-allianceicon";
		icon:SetAtlas(atlas, true);
		icon:Show();
	else
		icon:Hide();
	end
end

function PartyMemberFrameMixin:UpdateAssignedRoles()
	local icon = self.PartyMemberOverlay.RoleIcon;
	local role = UnitGroupRolesAssigned(self.unit);

	if role == "TANK" then
		icon:SetAtlas("roleicon-tiny-tank");
		icon:Show();
	elseif role == "HEALER" then
		icon:SetAtlas("roleicon-tiny-healer");
		icon:Show();
	elseif role == "DAMAGER" then
		icon:SetAtlas("roleicon-tiny-dps");
		icon:Show();
	else
		icon:Hide();
	end
end

function PartyMemberFrameMixin:UpdateVoiceStatus()
	if ( not UnitName(self.unit) ) then
		--No need to update if the frame doesn't have a unit.
		return;
	end

	local mode;
	local inInstance, instanceType = IsInInstance();

	if ( (instanceType == "pvp") or (instanceType == "arena") ) then
		mode = "Battleground";
	elseif ( IsInRaid() ) then
		mode = "raid";
	else
		mode = "party";
	end
end

function PartyMemberFrameMixin:UpdateReadyCheck()
	local readyCheckFrame = self.ReadyCheck;
	local readyCheckStatus = GetReadyCheckStatus(self.unit);
	if ( UnitName(self.unit) and UnitIsConnected(self.unit) and readyCheckStatus ) then
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
	if ( UnitInOtherParty(self.unit) ) then
		self:SetAlpha(0.6);
		self.NotPresentIcon.texture:SetAtlas("groupfinder-eye-single", true);
		self.NotPresentIcon.texture:SetTexCoord(0, 1, 0, 1);
		self.NotPresentIcon.Border:Show();
		self.NotPresentIcon.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE;
		self.NotPresentIcon:Show();
	elseif ( C_IncomingSummon.HasIncomingSummon(self.unit) ) then
		local status = C_IncomingSummon.IncomingSummonStatus(self.unit);
		if(status == Enum.SummonStatus.Pending) then
			self.NotPresentIcon.texture:SetAtlas("Raid-Icon-SummonPending");
			self.NotPresentIcon.texture:SetTexCoord(0, 1, 0, 1);
			self.NotPresentIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_PENDING;
			self.NotPresentIcon.Border:Hide();
			self.NotPresentIcon:Show();
		elseif( status == Enum.SummonStatus.Accepted ) then
			self.NotPresentIcon.texture:SetAtlas("Raid-Icon-SummonAccepted");
			self.NotPresentIcon.texture:SetTexCoord(0, 1, 0, 1);
			self.NotPresentIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_ACCEPTED;
			self.NotPresentIcon.Border:Hide();
			self.NotPresentIcon:Show();
		elseif( status == Enum.SummonStatus.Declined ) then
			self.NotPresentIcon.texture:SetAtlas("Raid-Icon-SummonDeclined");
			self.NotPresentIcon.texture:SetTexCoord(0, 1, 0, 1);
			self.NotPresentIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_DECLINED;
			self.NotPresentIcon.Border:Hide();
			self.NotPresentIcon:Show();
		end
	else
		local phaseReason = UnitIsConnected(self.unit) and UnitPhaseReason(self.unit) or nil;
		if phaseReason then
			self:SetAlpha(0.6);
			self.NotPresentIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon");
			self.NotPresentIcon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375);
			self.NotPresentIcon.Border:Hide();
			self.NotPresentIcon.tooltip = PartyUtil.GetPhasedReasonString(phaseReason, self.unit);
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

	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( UnitExists(self.unit) ) then
			self:UpdateMember();
			self:UpdateOnlineStatus();
			self:UpdateAssignedRoles();
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" or event == "UPDATE_ACTIVE_BATTLEFIELD" ) then
		self:UpdateMember();
		self:UpdateArt();
		self:UpdateAssignedRoles();
		self:UpdateLeader();
	elseif ( event == "PARTY_LEADER_CHANGED" ) then
		self:UpdateLeader();
	elseif ( event == "MUTELIST_UPDATE" or event == "IGNORELIST_UPDATE" ) then
		self:UpdateVoiceStatus();
	elseif ( event == "UNIT_FACTION" ) then
		if ( arg1 == self.unit ) then
			self:UpdatePvPStatus();
		end
	elseif ( event =="UNIT_AURA" ) then
		if ( arg1 == self.unit ) then
			local unitAuraUpdateInfo = arg2;
			self:UpdateAuras(unitAuraUpdateInfo);
			if ( PartyMemberBuffTooltip:IsShown() and
				selfID == PartyMemberBuffTooltip:GetID() ) then
				PartyMemberBuffTooltip:UpdateTooltip(self);
			end
		else
			if ( arg1 == self.petUnitToken ) then
				self.PetFrame:UpdateAuras(unitAuraUpdateInfo);
			end
		end
	elseif ( event =="UNIT_PET" ) then
		if ( arg1 == self.unit ) then
			self:UpdatePet();
		end
		if ( UnitHasVehicleUI(self.unit) and UnitIsConnected(self.unit)) then
			self:ToVehicleArt(UnitVehicleSkin(self.unit));
			self:UpdateMember();
		end
	elseif ( event == "READY_CHECK" or
		 event == "READY_CHECK_CONFIRM" ) then
		self:UpdateReadyCheck();
	elseif ( event == "READY_CHECK_FINISHED" ) then
		if (UnitExists(self.unit)) then
			local finishTime = DEFAULT_READY_CHECK_STAY_TIME;
			if not ShouldShowPartyFrames() then
				finishTime = 0;
			end
			ReadyCheck_Finish(self.ReadyCheck, finishTime);
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		self:UpdatePet();
	elseif ( event == "UNIT_ENTERED_VEHICLE" ) then
		if ( arg1 == self.unit ) then
			if ( arg2 and UnitIsConnected(self.unit) ) then
				self:ToVehicleArt(arg3);
			else
				self:ToPlayerArt();
			end
			self:UpdateMember();
		end
	elseif ( event == "UNIT_EXITED_VEHICLE" ) then
		if ( arg1 == self.unit ) then
			self:ToPlayerArt();
			self:UpdateMember();
		end
	elseif ( event == "UNIT_CONNECTION" ) and ( arg1 == self.unit) then
		self:UpdateArt();
	elseif ( event == "UNIT_PHASE" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" or event == "UNIT_FLAGS" or event == "UNIT_CTR_OPTIONS") then
		if ( event ~= "UNIT_PHASE" or arg1 == self.unit ) then
			self:UpdateNotPresentIcon();
		end
	elseif ( event == "UNIT_OTHER_PARTY_CHANGED" and arg1 == self.unit ) then
		self:UpdateNotPresentIcon();
	elseif ( event == "INCOMING_SUMMON_CHANGED" ) then
		self:UpdateNotPresentIcon();
	end
end

function PartyMemberFrameMixin:OnUpdate(elapsed)
	if self.initialized then
		self:UpdateMemberHealth(elapsed);
	end
	if(not self:IsMouseOver() and PartyMemberBuffTooltip:IsShown() and not PartyMemberBuffTooltip:IsMouseOver()) then
		PartyMemberBuffTooltip:Hide()
	end 
end

function PartyMemberFrameMixin:OnEnter()
	UnitFrame_OnEnter(self);
	PartyMemberBuffTooltip:SetPoint("TOPLEFT", self, "TOPLEFT", 47, -25);
	PartyMemberBuffTooltip:UpdateTooltip(self);
end

function PartyMemberFrameMixin:OnLeave()
	UnitFrame_OnLeave(self);
end

function PartyMemberFrameMixin:UpdateOnlineStatus()
	local healthBar = self.HealthBar;

	if not UnitIsConnected(self.unit) then
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
	if ( unitHPMax > 0 ) then
		self.unitHPPercent = unitCurrHP / unitHPMax;
	else
		self.unitHPPercent = 0;
	end
	if ( UnitIsDead(self.unit) ) then
		self.Portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
	elseif ( UnitIsGhost(self.unit) ) then
		self.Portrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
	elseif ( (self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2) ) then
		self.Portrait:SetVertexColor(1.0, 0.0, 0.0);
	else
		self.Portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
	end
end

function PartyMemberFrameMixin:InitializePartyFrameDropDown()
	local dropdown = UIDROPDOWNMENU_OPEN_MENU or self.DropDown;
	UnitPopup_ShowMenu(dropdown, "PARTY", "party"..dropdown:GetParent().layoutIndex);
end

PartyMemberPetFrameMixin=CreateFromMixins(PartyMemberAuraMixin);

function PartyMemberPetFrameMixin:UpdateAuras(unitAuraUpdateInfo)
	self:UpdateMemberAuras(unitAuraUpdateInfo);
end

function PartyMemberPetFrameMixin:Setup()
	self.unitToken = "partypet"..self:GetParent().layoutIndex;
	UnitFrame_Initialize(self, self.unitToken,  self.Name, self.Portrait, self.HealthBar, nil, nil, nil, self.Flash);
	SetTextStatusBarTextZeroText(self.HealthBar, DEAD);
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

PartyBuffFrameMixin={};

function PartyBuffFrameMixin:Setup(unit, index)
	self.unit = unit;
	self.index = index;
end

function PartyBuffFrameMixin:OnUpdate()
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetUnitBuff(self.unit, self.index);
	end
end

function PartyBuffFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetUnitBuff(self.unit, self.index);
end

function PartyBuffFrameMixin:OnLeave()
	GameTooltip:Hide();
end

PartyDebuffFrameMixin = {};
function PartyDebuffFrameMixin:Setup(unit, index)
	self.unit = unit;
	self.index = index;
end

function PartyDebuffFrameMixin:OnUpdate()
	if GameTooltip:IsOwned(self) then
		if self.isBossBuff then
			GameTooltip:SetUnitBuffByAuraInstanceID(self.unit, self.auraInstanceID, self.filter);
		else
			GameTooltip:SetUnitDebuffByAuraInstanceID(self.unit, self.auraInstanceID, self.filter);
		end
	end
end

function PartyDebuffFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.isBossBuff then
		GameTooltip:SetUnitBuffByAuraInstanceID(self.unit, self.auraInstanceID, self.filter);
	else
		GameTooltip:SetUnitDebuffByAuraInstanceID(self.unit, self.auraInstanceID, self.filter);
	end
end

function PartyDebuffFrameMixin:OnLeave()
	GameTooltip:Hide();
end
