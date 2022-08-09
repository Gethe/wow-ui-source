MAX_PARTY_MEMBERS = 4;
MAX_PARTY_BUFFS = 4;
MAX_PARTY_DEBUFFS = 4;
MAX_PARTY_TOOLTIP_BUFFS = 16;
MAX_PARTY_TOOLTIP_DEBUFFS = 8;

CVarCallbackRegistry:SetCVarCachable("showPartyPets");
CVarCallbackRegistry:SetCVarCachable("showCastableBuffs");
CVarCallbackRegistry:SetCVarCachable("showDispelDebuffs");
CVarCallbackRegistry:SetCVarCachable("showPartyBackground");

PartyMemberAuraMixin={};

function PartyMemberAuraMixin:UpdateMemberAuras(unitAuraUpdateInfo)
	self:UpdateAurasInternal(unitAuraUpdateInfo);
end

function PartyMemberAuraMixin:UpdateAurasInternal(unitAuraUpdateInfo)
	local displayOnlyDispellableDebuffs = CVarCallbackRegistry:GetCVarValueBool("showDispelDebuffs") and UnitCanAssist("player", self.unit);
	-- Buffs are only displayed in the Party Buff Tooltip
	local ignoreBuffs = MAX_PARTY_TOOLTIP_BUFFS == 0;
	local ignoreDebuffs = not self.debuffFrames or MAX_PARTY_DEBUFFS == 0;
	local ignoreDispelDebuffs = not self.debuffFrames or MAX_PARTY_DEBUFFS == 0;

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
					self.buffs[aura.auraInstanceID..aura.auraInstanceID] = aura;
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
		self.debuffs:Iterate(function(auraInstanceID, aura)
			if frameNum > MAX_PARTY_DEBUFFS then
				return true;
			end

			local debuffFrame = self.debuffFrames[frameNum];
			self:SetDebuff(debuffFrame, aura, frameNum);
			frameNum = frameNum + 1;

			return false;
		end);

		local unitStatus;
		if self.PartyMemberOverlay and self.PartyMemberOverlay.Info then
			unitStatus = self.PartyMemberOverlay.Info.Status;
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

		self:HideAllDebuffs(frameNum);
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

function PartyMemberAuraMixin:SetDebuff(debuffFrame, aura, frameNum)
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

function PartyMemberAuraMixin:HideAllDebuffs(startingIndex)
	if self.debuffFrames then
		for i = startingIndex or 1, #self.debuffFrames do
			self.debuffFrames[i]:Hide();
		end
	end
end

PartyMemberFrameMixin=CreateFromMixins(PartyMemberAuraMixin);

function PartyMemberFrameMixin:UpdateArt()
	local unit = "party"..self.layoutIndex;
	if ( UnitHasVehicleUI(unit) and UnitIsConnected(unit) ) then
		local vehicleType = UnitVehicleSkin(unit);
		self:ToVehicleArt(vehicleType);
	else
		self:ToPlayerArt();
	end
end

function PartyMemberFrameMixin:ToPlayerArt()
	self.state = "player";
	local PartyMemberOverlayInfo = self.PartyMemberOverlay.Info;
	PartyMemberOverlayInfo.VehicleTexture:Hide();
	PartyMemberOverlayInfo.Texture:Show();
	self.Portrait:SetPoint("TOPLEFT", 7, -6);
	PartyMemberOverlayInfo.LeaderIcon:SetPoint("BOTTOM", self, "TOP", -5, -3);
	PartyMemberOverlayInfo.PVPIcon:SetPoint("TOPLEFT", -9, -15);
	PartyMemberOverlayInfo.Disconnect:SetPoint("LEFT", -7, -1);

	self.overrideName = nil;

	UnitFrame_SetUnit(self, "party"..self.layoutIndex, self.HealthBar, self.ManaBar);
	UnitFrame_SetUnit(self.PetFrame, "partypet"..self.layoutIndex, self.PetFrame.HealthBar, nil);
	self:UpdateMember();

	UnitFrame_Update(self, true)
end

function PartyMemberFrameMixin:ToVehicleArt(vehicleType)
	self.state = "vehicle";
	local PartyMemberOverlayInfo = self.PartyMemberOverlay.Info;
	PartyMemberOverlayInfo.Texture:Hide();
	if ( vehicleType == "Natural" ) then
		PartyMemberOverlayInfo.VehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicles-PartyFrame-Organic");
	else
		PartyMemberOverlayInfo.VehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicles-PartyFrame");
	end
	PartyMemberOverlayInfo.VehicleTexture:Show();
	self.Portrait:SetPoint("TOPLEFT", 4, -9);
	PartyMemberOverlayInfo.LeaderIcon:SetPoint("TOPLEFT", -3, 0);
	PartyMemberOverlayInfo.PVPIcon:SetPoint("TOPLEFT", -12, -15);
	PartyMemberOverlayInfo.Disconnect:SetPoint("LEFT", -10, -1);

	self.overrideName = "party"..self.layoutIndex;

	UnitFrame_SetUnit(self, "partypet"..self.layoutIndex, self.HealthBar, self.ManaBar);
	UnitFrame_SetUnit(self.PetFrame, self.overrideName, self.PetFrame.HealthBar, nil);
	self:UpdateMember();

	UnitFrame_Update(self, true)
end

function PartyMemberFrameMixin:Setup()
	local id = self.layoutIndex;
	self.debuffCountdown = 0;
	self.numDebuffs = 0;
	self.noTextPrefix = true;
	
	self.PetFrame:Setup();

	local PartyMemberOverlayInfo = self.PartyMemberOverlay.Info;
	self.HealthBar.LeftText = PartyMemberOverlayInfo.HealthBarTextLeft;
	self.HealthBar.RightText = PartyMemberOverlayInfo.HealthBarTextRight;
	self.ManaBar.LeftText = PartyMemberOverlayInfo.ManaBarTextLeft;
	self.ManaBar.RightText = PartyMemberOverlayInfo.ManaBarTextRight;

	UnitFrame_Initialize(self, "party"..id,  PartyMemberOverlayInfo.Name, self.Portrait,
		   self.HealthBar, PartyMemberOverlayInfo.HealthBarText,
		   self.ManaBar, PartyMemberOverlayInfo.ManaBarText,
		   self.Flash, nil, nil, PartyMemberOverlayInfo.MyHealPredictionBar, PartyMemberOverlayInfo.OtherHealPredictionBar,
		   self.TotalAbsorbBar, self.TotalAbsorbBarOverlay, PartyMemberOverlayInfo.OverAbsorbGlow,
		   PartyMemberOverlayInfo.OverHealAbsorbGlow, PartyMemberOverlayInfo.HealAbsorbBar, PartyMemberOverlayInfo.HealAbsorbBarLeftShadow,
		   PartyMemberOverlayInfo.HealAbsorbBarRightShadow);
	SetTextStatusBarTextZeroText(self.HealthBar, DEAD);

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
	self:RegisterUnitEvent("UNIT_AURA", "party"..id, "partypet"..id);
	self:RegisterUnitEvent("UNIT_PET",  "party"..id, "partypet"..id);
	local showmenu = function()
		ToggleDropDownMenu(1, nil, self.DropDown, self, 47, 15);
	end
	SecureUnitButton_OnLoad(self, "party"..id, showmenu);

	self:UpdateArt();
	self:SetFrameLevel(2);
	self:UpdateNotPresentIcon();
	
	UIDropDownMenu_SetInitializeFunction(self.DropDown, PartyMemberFrameMixin.InitializePartyFrameDropDown);
	UIDropDownMenu_SetDisplayMode(self.DropDown, "MENU");

	UnitPowerBarAlt_Initialize(self.PowerBarAlt, "party"..id, 0.5, "GROUP_ROSTER_UPDATE");
	
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
	if ( GetDisplayedAllyFrames() ~= "party" ) then
		self:Hide();
		PartyFrame:UpdatePartyMemberBackground();
		return;
	end
	local id = self.layoutIndex;
	local unit = "party"..id;
	if ( UnitExists(unit) ) then
		self:Show();

		if VoiceActivityManager then
			local guid = UnitGUID(unit);
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
	local id = self.layoutIndex;
	local leaderIcon = self.PartyMemberOverlay.Info.LeaderIcon;
	local guideIcon = self.PartyMemberOverlay.Info.GuideIcon;

	if( UnitIsGroupLeader("party"..id) ) then
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
	local id = self.layoutIndex;
	local unit = "party"..id;
	local icon = self.PartyMemberOverlay.Info.PVPIcon;
	local factionGroup = UnitFactionGroup(unit);
	if ( UnitIsPVPFreeForAll(unit) ) then
		icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		icon:Show();
	elseif ( factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(unit) ) then
		icon:SetTexture("Interface\\GroupFrame\\UI-Group-PVP-"..factionGroup);
		icon:Show();
	else
		icon:Hide();
	end
end

function PartyMemberFrameMixin:UpdateAssignedRoles()
	local id = self.layoutIndex;
	local unit = "party"..id;
	local icon = self.PartyMemberOverlay.Info.RoleIcon;
	local role = UnitGroupRolesAssigned(unit);

	if ( role == "TANK" or role == "HEALER" or role == "DAMAGER") then
		icon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role));
		icon:Show();
	else
		icon:Hide();
	end
end

function PartyMemberFrameMixin:UpdateVoiceStatus()
	local id = self.layoutIndex;
	if ( not UnitName("party"..id) ) then
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
	local id = self.layoutIndex;
	local partyID = "party"..id;

	local readyCheckFrame = self.ReadyCheck;
	local readyCheckStatus = GetReadyCheckStatus(partyID);
	if ( UnitName(partyID) and UnitIsConnected(partyID) and readyCheckStatus ) then
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
	local id = self.layoutIndex;
	local partyID = "party"..id;

	if ( UnitInOtherParty(partyID) ) then
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
		local phaseReason = UnitIsConnected(partyID) and UnitPhaseReason(partyID) or nil;
		if phaseReason then
			self:SetAlpha(0.6);
			self.NotPresentIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon");
			self.NotPresentIcon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375);
			self.NotPresentIcon.Border:Hide();
			self.NotPresentIcon.tooltip = PartyUtil.GetPhasedReasonString(phaseReason, partyID);
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


	local unit = "party"..selfID;
	local unitPet = "partypet"..selfID;

	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( UnitExists("party"..self.layoutIndex) ) then
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
		if ( arg1 == unit ) then
			self:UpdatePvPStatus();
		end
	elseif ( event =="UNIT_AURA" ) then
		if ( arg1 == unit ) then
			local unitAuraUpdateInfo = arg2;
			self:UpdateAuras(unitAuraUpdateInfo);
			if ( PartyMemberBuffTooltip:IsShown() and
				selfID == PartyMemberBuffTooltip:GetID() ) then
				PartyMemberBuffTooltip:UpdateTooltip(self);
			end
		else
			if ( arg1 == unitPet ) then
				self.PetFrame:UpdateAuras(unitAuraUpdateInfo);
			end
		end
	elseif ( event =="UNIT_PET" ) then
		if ( arg1 == unit ) then
			self:UpdatePet();
		end
		if ( UnitHasVehicleUI("party"..selfID) and UnitIsConnected("party"..selfID)) then
			self:ToVehicleArt(UnitVehicleSkin("party"..selfID));
		end
	elseif ( event == "READY_CHECK" or
		 event == "READY_CHECK_CONFIRM" ) then
		self:UpdateReadyCheck();
	elseif ( event == "READY_CHECK_FINISHED" ) then
		if (UnitExists("party"..self.layoutIndex)) then
			local finishTime = DEFAULT_READY_CHECK_STAY_TIME;
			if ( GetDisplayedAllyFrames() ~= "party" ) then
				finishTime = 0;
			end
			ReadyCheck_Finish(self.ReadyCheck, finishTime);
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		self:UpdatePet();
	elseif ( event == "UNIT_ENTERED_VEHICLE" ) then
		if ( arg1 == "party"..selfID ) then
			if ( arg2 and UnitIsConnected("party"..selfID) ) then
				self:ToVehicleArt(arg3);
			else
				self:ToPlayerArt();
			end
		end
	elseif ( event == "UNIT_EXITED_VEHICLE" ) then
		if ( arg1 == "party"..selfID ) then
			self:ToPlayerArt();
		end
	elseif ( event == "UNIT_CONNECTION" ) and ( arg1 == "party"..selfID ) then
		self:UpdateArt();
	elseif ( event == "UNIT_PHASE" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" or event == "UNIT_FLAGS" or event == "UNIT_CTR_OPTIONS") then
		if ( event ~= "UNIT_PHASE" or arg1 == unit ) then
			self:UpdateNotPresentIcon();
		end
	elseif ( event == "UNIT_OTHER_PARTY_CHANGED" and arg1 == unit ) then
		self:UpdateNotPresentIcon();
	elseif ( event == "INCOMING_SUMMON_CHANGED" ) then
		self:UpdateNotPresentIcon();
	end
end

function PartyMemberFrameMixin:OnUpdate(elapsed)
	if self.initialized then
		self:UpdateMemberHealth(elapsed);
	end
end

function PartyMemberFrameMixin:OnEnter()
	UnitFrame_OnEnter(self);
	PartyMemberBuffTooltip:SetPoint("TOPLEFT", self, "TOPLEFT", 47, -40);
	PartyMemberBuffTooltip:UpdateTooltip(self);
end

function PartyMemberFrameMixin:OnLeave()
	UnitFrame_OnLeave(self);
	PartyMemberBuffTooltip:Hide();
end

function PartyMemberFrameMixin:UpdateOnlineStatus()
	if ( not UnitIsConnected("party"..self.layoutIndex) ) then
		-- Handle disconnected state
		local healthBar = self.HealthBar;
		local unitHPMin, unitHPMax = healthBar:GetMinMaxValues();

		healthBar:SetValue(unitHPMax);
		healthBar:SetStatusBarColor(0.5, 0.5, 0.5);
		SetDesaturation(self.Portrait, true);
		self.PartyMemberOverlay.Info.Disconnect:Show();
		self.PetFrame:Hide();
		return;
	else
		SetDesaturation(self.Portrait, false);
		self.PartyMemberOverlay.Info.Disconnect:Hide();
	end
end

function PartyMemberFrameMixin:UpdateAuras(unitAuraUpdateInfo)
	self:UpdateMemberAuras(unitAuraUpdateInfo);
end

function PartyMemberFrameMixin:PartyMemberHealthCheck (value)
	local unitHPMin, unitHPMax, unitCurrHP;
	unitHPMin, unitHPMax = self.HealthBar:GetMinMaxValues();

	unitCurrHP = self.HealthBar:GetValue();
	if ( unitHPMax > 0 ) then
		self.unitHPPercent = unitCurrHP / unitHPMax;
	else
		self.unitHPPercent = 0;
	end
	if ( UnitIsDead("party"..self.layoutIndex) ) then
		self.Portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
	elseif ( UnitIsGhost("party"..self.layoutIndex) ) then
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
	local id = self:GetParent().layoutIndex;
	local unit = "partypet"..id;
	UnitFrame_Initialize(self, unit,  self.PartyMemberPetOverlay.Info.Name, self.Portrait,
	self.HealthBar, self.PartyMemberPetOverlay.Info.HealthBarText,
	nil, nil, self.Flash);
	SetTextStatusBarTextZeroText(self.HealthBar, DEAD);
	self.PartyMemberPetOverlay.Info.Name:Hide();
	SecureUnitButton_OnLoad(self, unit);
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

function PartyBuffFrameMixin:OnUpdate()
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetUnitBuff("party"..self:GetParent():GetID(), self:GetID());
	end
end

function PartyBuffFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetUnitBuff("party"..self:GetParent():GetID(), self:GetID());
end

function PartyBuffFrameMixin:OnLeave()
	GameTooltip:Hide();
end

PartyDebuffFrameMixin={};

function PartyDebuffFrameMixin:OnUpdate()
	if GameTooltip:IsOwned(self) then
		if self.isBossBuff then
			GameTooltip:SetUnitBuffByAuraInstanceID(self:GetParent().unit, self.auraInstanceID, self.filter);
		else
			GameTooltip:SetUnitDebuffByAuraInstanceID(self:GetParent().unit, self.auraInstanceID, self.filter);
		end
	end
end

function PartyDebuffFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.isBossBuff then
		GameTooltip:SetUnitBuffByAuraInstanceID(self:GetParent().unit, self.auraInstanceID, self.filter);
	else
		GameTooltip:SetUnitDebuffByAuraInstanceID(self:GetParent().unit, self.auraInstanceID, self.filter);
	end
end

function PartyDebuffFrameMixin:OnLeave()
	GameTooltip:Hide();
end
