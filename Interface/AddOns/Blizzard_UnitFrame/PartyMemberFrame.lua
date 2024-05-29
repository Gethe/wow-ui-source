MAX_PARTY_MEMBERS = 4;

-- Allow these to be overwritten.
MAX_PARTY_BUFFS = MAX_PARTY_BUFFS or 4;
MAX_PARTY_DEBUFFS = MAX_PARTY_DEBUFFS or 4;

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
	local buffsChanged = false;

	if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or self.debuffs == nil then
		self:ParseAllAuras(displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs);
		debuffsChanged = true;
		buffsChanged = true;
	else
		if unitAuraUpdateInfo.addedAuras ~= nil then
			for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
				local type = AuraUtil.ProcessAura(aura, displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs);

				if type == AuraUtil.AuraUpdateChangedType.Debuff or type == AuraUtil.AuraUpdateChangedType.Dispel then
					self.debuffs[aura.auraInstanceID] = aura;
					debuffsChanged = true;
				elseif type == AuraUtil.AuraUpdateChangedType.Buff then
					self.buffs[aura.auraInstanceID] = aura;
					buffsChanged = true;
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
					buffsChanged = true;
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
					buffsChanged = true;
				end
			end
		end
	end

	local showingBuffs = self.showBuffs;
	if (showingBuffs and buffsChanged) or (not showingBuffs and debuffsChanged) then
		local iterateList = showingBuffs and self.buffs or self.debuffs;
		local maxFrames = showingBuffs and MAX_PARTY_BUFFS or MAX_PARTY_DEBUFFS;
		local frameNum = 1;
		self.AuraFramePool:ReleaseAll();
		iterateList:Iterate(function(auraInstanceID, aura)
			if frameNum > maxFrames then
				return true;
			end

			local auraFrame = self.AuraFramePool:Acquire();
			auraFrame:SetPoint("TOPLEFT");
			auraFrame.layoutIndex = frameNum;
			auraFrame:Setup(self.unit, aura, showingBuffs);
			frameNum = frameNum + 1;
			return false;
		end);

		self.AuraFrameContainer:SetPoint("TOPLEFT", 48, -43);
		self.AuraFrameContainer:Layout();

		local unitStatus;
		if self.PartyMemberOverlay then
			unitStatus = self.PartyMemberOverlay.Status;
		end

		if not showingBuffs and unitStatus then
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

PartyMemberFrameMixin=CreateFromMixins(PartyMemberAuraMixin);

function PartyMemberFrameMixin:GetUnit()
	-- Override unit is set when we get in a vehicle
	-- Override unit will always be the original (most likely player/party member)
	return self.overrideUnit or self.unit;
end

function PartyMemberFrameMixin:UpdateArt()
	if UnitHasVehicleUI(self.unit) and UnitIsConnected(self:GetUnit()) then
		self:ToVehicleArt();
	else
		self:ToPlayerArt();
	end
end

function PartyMemberFrameMixin:ToPlayerArt()
	self.state = "player";
	self.overrideUnit = nil;

	self.VehicleTexture:Hide();
	self.Texture:Show();

	self.Flash:SetAtlas("ui-hud-unitframe-party-portraiton-incombat", TextureKitConstants.UseAtlasSize);
	self.Flash:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -2);

	self.PartyMemberOverlay.Status:SetAtlas("ui-hud-unitframe-party-portraiton-status", TextureKitConstants.UseAtlasSize);
	self.PartyMemberOverlay.Status:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -2);

	self.HealthBarContainer.HealthBar.HealthBarTexture:SetAtlas("UI-HUD-UnitFrame-Party-PortraitOn-Bar-Health", TextureKitConstants.UseAtlasSize);

	if (UNIT_FRAME_SHOW_HEALTH_ONLY) then
		self.HealthBarContainer:SetSize(74, 30);
		self.HealthBarContainer:SetPoint("TOPLEFT", self, "TOPLEFT", 43, -16);
		self:UpdateHealthBarTextAnchors();
		self.Texture:SetAtlas("plunderstorm-UI-HUD-UnitFrame-Party-PortraitOn");

		self.HealthBarContainer.HealthBarMask:SetAtlas("plunderstorm-ui-hud-unitframe-party-portraiton-bar-health-mask", TextureKitConstants.UseAtlasSize);
		self.HealthBarContainer.HealthBarMask:SetPoint("TOPLEFT", -27, 4);
	else
		self.HealthBarContainer:SetWidth(70);
		self.HealthBarContainer:SetPoint("TOPLEFT", self, "TOPLEFT", 45, -19);
		self:UpdateHealthBarTextAnchors();
		self.Texture:SetAtlas("UI-HUD-UnitFrame-Party-PortraitOn");

		self.HealthBarContainer.HealthBarMask:SetAtlas("UI-HUD-UnitFrame-Party-PortraitOn-Bar-Health-Mask", TextureKitConstants.UseAtlasSize);
		self.HealthBarContainer.HealthBarMask:SetPoint("TOPLEFT", -29, 3);
	end

	self.ManaBar:SetWidth(74);
	self.ManaBar:SetPoint("TOPLEFT", self, "TOPLEFT", 41, -30);
	self:UpdateManaBarTextAnchors();

	self.ManaBar.ManaBarMask:SetAtlas("UI-HUD-UnitFrame-Party-PortraitOn-Bar-Mana-Mask", TextureKitConstants.UseAtlasSize);
	self.ManaBar.ManaBarMask:SetPoint("TOPLEFT", self, "TOPLEFT", 14, -26);

	self.Name:SetWidth(57);
	self:UpdateNameTextAnchors();

	UnitFrame_SetUnit(self, self.unit, self.HealthBarContainer.HealthBar, self.ManaBar);
	UnitFrame_SetUnit(self.PetFrame, self.PetFrame.unit, self.PetFrame.HealthBar, nil);
	UnitFrame_Update(self, true);
end

function PartyMemberFrameMixin:ToVehicleArt()
	self.state = "vehicle";
	self.overrideUnit = self.unit;

	self.Texture:Hide();
	self.VehicleTexture:Show();

	self.Flash:SetAtlas("UI-HUD-UnitFrame-Party-PortraitOn-Vehicle-InCombat", TextureKitConstants.UseAtlasSize);
	self.Flash:SetPoint("TOPLEFT", self, "TOPLEFT", -4, 4);

	self.PartyMemberOverlay.Status:SetAtlas("UI-HUD-UnitFrame-Party-PortraitOn-Vehicle-Status", TextureKitConstants.UseAtlasSize);
	self.PartyMemberOverlay.Status:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 3);

	self.HealthBar.HealthBarTexture:SetAtlas("UI-HUD-UnitFrame-Party-PortraitOn-Vehicle-Bar-Health", TextureKitConstants.UseAtlasSize);
	self.HealthBarContainer:SetWidth(67);
	self.HealthBarContainer:SetPoint("TOPLEFT", self, "TOPLEFT", 48, -18);
	self:UpdateHealthBarTextAnchors();

	-- Party frames when in a vehicle do not have a mask for the health bar, so remove any applied target mask that would not fit.
	self.HealthBarContainer.HealthBarMask:SetAtlas("UI-HUD-UnitFrame-Party-PortraitOn-Vehicle-Bar-Health-Mask", TextureKitConstants.UseAtlasSize);
	self.HealthBarContainer.HealthBarMask:SetPoint("TOPLEFT", -30, 3);

	self.ManaBar:SetWidth(70);
	self.ManaBar:SetPoint("TOPLEFT", self, "TOPLEFT", 45, -29);
	self:UpdateManaBarTextAnchors();

	self.ManaBar.ManaBarMask:SetAtlas("UI-HUD-UnitFrame-Party-PortraitOn-Vehicle-Bar-Mana-Mask", TextureKitConstants.UseAtlasSize);
	self.ManaBar.ManaBarMask:SetPoint("TOPLEFT", self, "TOPLEFT", 16, -25);

	self.Name:SetWidth(56);
	self:UpdateNameTextAnchors();

	UnitFrame_SetUnit(self, self.petUnitToken, self.HealthBarContainer.HealthBar, self.ManaBar);
	UnitFrame_SetUnit(self.PetFrame, self.overrideUnit, self.PetFrame.HealthBar, nil);
	UnitFrame_Update(self, true);
end

function PartyMemberFrameMixin:UpdateHealthBarTextAnchors()
	local healthBarTextOffsetX = 0;
	local healthBarTextOffsetY = 0;
	if (LOCALE_koKR) then
		healthBarTextOffsetY = 1;
	elseif (LOCALE_zhCN) then
		healthBarTextOffsetY = 2;
	end

	if (UNIT_FRAME_SHOW_HEALTH_ONLY) then
		healthBarTextOffsetX = 2;
		healthBarTextOffsetY = healthBarTextOffsetY + 3;
	end
	
	self.HealthBarContainer.CenterText:SetPoint("CENTER", self.HealthBarContainer, "CENTER", 0, healthBarTextOffsetY);
	self.HealthBarContainer.LeftText:SetPoint("LEFT", self.HealthBarContainer, "LEFT", healthBarTextOffsetX, healthBarTextOffsetY);
	self.HealthBarContainer.RightText:SetPoint("RIGHT", self.HealthBarContainer, "RIGHT", -healthBarTextOffsetX, healthBarTextOffsetY);
end

function PartyMemberFrameMixin:UpdateManaBarTextAnchors()
	local manaBarTextOffsetY = 0;
	if (LOCALE_koKR) then
		manaBarTextOffsetY = 1;
	elseif (LOCALE_zhCN) then
		manaBarTextOffsetY = 2;
	end

	self.ManaBar.CenterText:SetPoint("CENTER", self.ManaBar, "CENTER", 2, manaBarTextOffsetY);
	self.ManaBar.RightText:SetPoint("RIGHT", self.ManaBar, "RIGHT", 0, manaBarTextOffsetY);

	if(self.state == "player") then
		self.ManaBar.LeftText:SetPoint("LEFT", self.ManaBar, "LEFT", 4, manaBarTextOffsetY);
	else
		self.ManaBar.LeftText:SetPoint("LEFT", self.ManaBar, "LEFT", 3, manaBarTextOffsetY);
	end
end

function PartyMemberFrameMixin:UpdateNameTextAnchors()
	local nameTextOffsetY = -6;
	if (LOCALE_zhCN or LOCALE_zhTW) then
		nameTextOffsetY = -4;
	end

	if(self.state == "player") then
		self.Name:SetPoint("TOPLEFT", self, "TOPLEFT", 46, nameTextOffsetY);
	else
		self.Name:SetPoint("TOPLEFT", self, "TOPLEFT", 49, nameTextOffsetY);
	end
end

function PartyMemberFrameMixin:Setup()
	self.unitToken = "party"..self.layoutIndex;
	self.petUnitToken = "partypet"..self.layoutIndex;

	self.debuffCountdown = 0;
	self.numDebuffs = 0;

	self.PetFrame:Setup();

	local myHealthbar = self.HealthBarContainer.HealthBar;

	UnitFrame_Initialize(self, self.unitToken, self.Name, self.frameType, self.Portrait,
		   myHealthbar,
		   self.HealthBarContainer.CenterText,
		   self.ManaBar,
		   self.ManaBar.CenterText,
		   self.Flash, nil, nil,
		   myHealthbar.MyHealPredictionBar,
		   myHealthbar.OtherHealPredictionBar,
		   myHealthbar.TotalAbsorbBar,
		   myHealthbar.OverAbsorbGlow,
		   myHealthbar.OverHealAbsorbGlow,
		   myHealthbar.HealAbsorbBar,
		   nil,
		   self.HealthBarContainer.TempMaxHealthLoss);

	myHealthbar:SetBarTextZeroText(DEAD);
	myHealthbar:SetBarText(self.HealthBarContainer.CenterText, self.HealthBarContainer.LeftText, self.HealthBarContainer.RightText);

	local tempMaxHealthLossBar = self.HealthBarContainer.TempMaxHealthLoss;
	tempMaxHealthLossBar:InitalizeMaxHealthLossBar( self.HealthBarContainer, myHealthbar);

	if PARTY_FRAME_SHOW_BUFFS then
		self.showBuffs = true;
	end

	self.AuraFramePool = CreateFramePool("BUTTON", self.AuraFrameContainer, "PartyAuraFrameTemplate");
	self.PetFrame.AuraFramePool = CreateFramePool("BUTTON", self.PetFrame.AuraFrameContainer, "PartyAuraFrameTemplate");

	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;

	-- Mask the various bar assets, to avoid any overflow with the frame shape.
	myHealthbar:GetStatusBarTexture():AddMaskTexture(self.HealthBarContainer.HealthBarMask);
	tempMaxHealthLossBar:GetStatusBarTexture():AddMaskTexture(self.HealthBarContainer.HealthBarMask);
	self.ManaBar:GetStatusBarTexture():AddMaskTexture(self.ManaBar.ManaBarMask);

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
	if not PartyFrame:ShouldShow() then
		self:Hide();
		PartyFrame:UpdatePartyMemberBackground();
		return;
	end

	local showFrame;
	if EditModeManagerFrame:ArePartyFramesForcedShown() and not UnitExists(self.unitToken) then
		UnitFrame_SetUnit(self, "player", self.HealthBarContainer.HealthBar, self.ManaBar);
		UnitFrame_SetUnit(self.PetFrame, "pet", self.PetFrame.HealthBar);
		showFrame = true;
	else
		UnitFrame_SetUnit(self, self.unitToken, self.HealthBarContainer.HealthBar, self.ManaBar);
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

	if UnitIsGroupLeader(self:GetUnit()) then
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
	local factionGroup = UnitFactionGroup(self:GetUnit());
	if UnitIsPVPFreeForAll(self:GetUnit()) then
		icon:SetAtlas("ui-hud-unitframe-player-pvp-ffaicon", true);
		icon:Show();
	elseif factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(self:GetUnit()) then
		local atlas = (factionGroup == "Horde") and "ui-hud-unitframe-player-pvp-hordeicon" or "ui-hud-unitframe-player-pvp-allianceicon";
		icon:SetAtlas(atlas, true);
		icon:Show();
	else
		icon:Hide();
	end
end

function PartyMemberFrameMixin:UpdateAssignedRoles()
	local icon = self.PartyMemberOverlay.RoleIcon;
	local role = UnitGroupRolesAssignedEnum(self:GetUnit());

	if role == Enum.LFGRole.Tank then
		icon:SetAtlas("roleicon-tiny-tank");
		icon:Show();
	elseif role == Enum.LFGRole.Healer then
		icon:SetAtlas("roleicon-tiny-healer");
		icon:Show();
	elseif role == Enum.LFGRole.Damage then
		icon:SetAtlas("roleicon-tiny-dps");
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
		self.NotPresentIcon.texture:SetAtlas("groupfinder-eye-single", true);
		self.NotPresentIcon.texture:SetTexCoord(0, 1, 0, 1);
		self.NotPresentIcon.Border:Show();
		self.NotPresentIcon.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE;
		self.NotPresentIcon:Show();
	elseif C_IncomingSummon.HasIncomingSummon(self:GetUnit()) then
		local status = C_IncomingSummon.IncomingSummonStatus(self:GetUnit());
		if status == Enum.SummonStatus.Pending then
			self.NotPresentIcon.texture:SetAtlas("Raid-Icon-SummonPending");
			self.NotPresentIcon.texture:SetTexCoord(0, 1, 0, 1);
			self.NotPresentIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_PENDING;
			self.NotPresentIcon.Border:Hide();
			self.NotPresentIcon:Show();
		elseif status == Enum.SummonStatus.Accepted then
			self.NotPresentIcon.texture:SetAtlas("Raid-Icon-SummonAccepted");
			self.NotPresentIcon.texture:SetTexCoord(0, 1, 0, 1);
			self.NotPresentIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_ACCEPTED;
			self.NotPresentIcon.Border:Hide();
			self.NotPresentIcon:Show();
		elseif status == Enum.SummonStatus.Declined then
			self.NotPresentIcon.texture:SetAtlas("Raid-Icon-SummonDeclined");
			self.NotPresentIcon.texture:SetTexCoord(0, 1, 0, 1);
			self.NotPresentIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_DECLINED;
			self.NotPresentIcon.Border:Hide();
			self.NotPresentIcon:Show();
		end
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

	if event == "UNIT_NAME_UPDATE" then
		UnitFrame_Update(self,true);
	elseif event == "PLAYER_ENTERING_WORLD" then
		if UnitExists(self:GetUnit()) then
			self:UpdateMember();
			self:UpdateOnlineStatus();
			self:UpdateAssignedRoles();
		end
	elseif event == "GROUP_ROSTER_UPDATE" or event == "UPDATE_ACTIVE_BATTLEFIELD" then
		self:UpdateMember();
		self:UpdateArt();
		self:UpdateAssignedRoles();
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
	elseif event =="UNIT_PET" then
		if arg1 == self:GetUnit() then
			self:UpdatePet();
		end
		if UnitHasVehicleUI(self.unit) and UnitIsConnected(self:GetUnit()) then
			self:ToVehicleArt();
			self:UpdateMember();
		end
	elseif ( event == "READY_CHECK" or
		 event == "READY_CHECK_CONFIRM" ) then
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
				self:ToVehicleArt();
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
	elseif event == "UNIT_PHASE" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" or event == "UNIT_FLAGS" or event == "UNIT_CTR_OPTIONS" then
		if event ~= "UNIT_PHASE" or arg1 == self:GetUnit() then
			self:UpdateNotPresentIcon();
		end
	elseif event == "UNIT_OTHER_PARTY_CHANGED" and arg1 == self:GetUnit() then
		self:UpdateNotPresentIcon();
	elseif event == "INCOMING_SUMMON_CHANGED" then
		self:UpdateNotPresentIcon();
	end
end

function PartyMemberFrameMixin:OnUpdate(elapsed)
	if self.initialized then
		self:UpdateMemberHealth(elapsed);
	end
	if not self:IsMouseOver() and PartyMemberBuffTooltip:IsShown() and not PartyMemberBuffTooltip:IsMouseOver() then
		PartyMemberBuffTooltip:Hide()
	end 
end

function PartyMemberFrameMixin:OnEnter()
	UnitFrame_OnEnter(self);

	if not HIDE_PARTY_MEMBER_BUFF_TOOLTIP then
		PartyMemberBuffTooltip:SetPoint("TOPLEFT", self, "TOPLEFT", 47, -25);
		PartyMemberBuffTooltip:UpdateTooltip(self);
	end
end

function PartyMemberFrameMixin:OnLeave()
	UnitFrame_OnLeave(self);
end

function PartyMemberFrameMixin:UpdateOnlineStatus()
	local healthBar = self.HealthBarContainer.HealthBar;

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
	unitHPMin, unitHPMax = self.HealthBarContainer.HealthBar:GetMinMaxValues();

	unitCurrHP = self.HealthBarContainer.HealthBar:GetValue();
	if unitHPMax > 0 then
		self.unitHPPercent = unitCurrHP / unitHPMax;
	else
		self.unitHPPercent = 0;
	end

	local unit = self:GetUnit();
	local unitIsDead = UnitIsDead(unit);
	local unitIsGhost = UnitIsGhost(unit);
	if PARTY_FRAME_RESURRECTABLE_TOOLTIP then
		local playerIsDeadOrGhost = UnitIsDeadOrGhost("player");
		local unitIsDeadOrGhost = unitIsDead or unitIsGhost;
		self.ResurrectableIndicator:SetShown(not playerIsDeadOrGhost and unitIsDeadOrGhost);
	end

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

PartyMemberPetFrameMixin=CreateFromMixins(PartyMemberAuraMixin);

function PartyMemberPetFrameMixin:UpdateAuras(unitAuraUpdateInfo)
	self:UpdateMemberAuras(unitAuraUpdateInfo);
end

function PartyMemberPetFrameMixin:Setup()
	self.unitToken = "partypet"..self:GetParent().layoutIndex;
	UnitFrame_Initialize(self, self.unitToken, self.Name, nil, self.Portrait, self.HealthBar, nil, nil, nil, self.Flash);
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

PartyAuraFrameMixin = {};
function PartyAuraFrameMixin:Setup(unit, aura, isBuff)
	self.unit = unit;
	self.auraInstanceID = aura.auraInstanceID;

	local isBossBuff = aura.isBossAura and aura.isHelpful;
	local filter = aura.isRaid and AuraUtil.AuraFilters.Raid or nil;
	self.isBuff = isBuff;
	self.isBossBuff = isBossBuff;
	self.filter = filter;

	if aura.icon then
		self.Icon:SetTexture(aura.icon);

		if aura.applications > 1 then
			local countText = aura.applications >= 100 and BUFF_STACKS_OVERFLOW or aura.applications;
			self.Count:Show();
			self.Count:SetText(countText);
		else
			self.Count:Hide();
		end

		self.DebuffBorder:SetShown(not isBuff);
		if not isBuff then
			local color = DebuffTypeColor[aura.dispelName] or DebuffTypeColor["none"];
			self.DebuffBorder:SetVertexColor(color.r, color.g, color.b);
		end

		local enabled = aura.expirationTime and aura.expirationTime ~= 0;
		if enabled then
			local startTime = aura.expirationTime - aura.duration;
			CooldownFrame_Set(self.Cooldown, startTime, aura.duration, true);
		else
			CooldownFrame_Clear(self.Cooldown);
		end

		self:Show();
	end
end

function PartyAuraFrameMixin:OnUpdate()
	if GameTooltip:IsOwned(self) then
		self:UpdateTooltip();
	end
end

function PartyAuraFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:UpdateTooltip();
end

function PartyAuraFrameMixin:OnLeave()
	GameTooltip:Hide();
end

function PartyAuraFrameMixin:UpdateTooltip()
	if self.isBossBuff then
		GameTooltip:SetUnitBuffByAuraInstanceID(self.unit, self.auraInstanceID, self.filter);
	elseif self.isBuff then
		GameTooltip:SetUnitBuffByAuraInstanceID(self.unit, self.auraInstanceID, self.filter);
	else
		GameTooltip:SetUnitDebuffByAuraInstanceID(self.unit, self.auraInstanceID, self.filter);
	end
end

ResurrectableIndicatorMixin = {};
function ResurrectableIndicatorMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, PARTY_FRAME_RESURRECTABLE_TOOLTIP);
	GameTooltip:Show();
end

function ResurrectableIndicatorMixin:OnLeave()
	GameTooltip_Hide();
end