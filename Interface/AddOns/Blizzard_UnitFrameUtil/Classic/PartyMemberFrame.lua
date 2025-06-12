MAX_PARTY_MEMBERS = 4;
MAX_PARTY_BUFFS = 4;
MAX_PARTY_DEBUFFS = 4;
MAX_PARTY_TOOLTIP_BUFFS = 16;
MAX_PARTY_TOOLTIP_DEBUFFS = 8;

CVarCallbackRegistry:SetCVarCachable("showPartyPets");
CVarCallbackRegistry:SetCVarCachable("showPartyBackground");

function HidePartyFrame()
	for i=1, MAX_PARTY_MEMBERS, 1 do
		_G["PartyMemberFrame"..i]:Hide();
	end
end

function ShowPartyFrame()
	for i=1, MAX_PARTY_MEMBERS, 1 do
		if ( UnitExists("party"..i) ) then
			_G["PartyMemberFrame"..i]:Show();
		end
	end
end

function PartyMemberFrame_UpdateArt(self)
	local unit = "party"..self:GetID();
	PartyMemberFrame_ToPlayerArt(self);
end

function PartyMemberFrame_ToPlayerArt(self)
	self.state = "player";
	local prefix = self:GetName();
	_G[prefix.."VehicleTexture"]:Hide();
	_G[prefix.."Texture"]:Show();
	_G[prefix.."Portrait"]:SetPoint("TOPLEFT", 7, -6);
	_G[prefix.."LeaderIcon"]:SetPoint("TOPLEFT", 0, 0);
	_G[prefix.."PVPIcon"]:SetPoint("TOPLEFT", -9, -15);
	_G[prefix.."Disconnect"]:SetPoint("LEFT", -7, -1);

	self.overrideName = nil;

	UnitFrame_SetUnit(self, "party"..self:GetID(), _G[prefix.."HealthBar"], _G[prefix.."ManaBar"]);
	UnitFrame_SetUnit(_G[prefix.."PetFrame"], "partypet"..self:GetID(), _G[prefix.."PetFrameHealthBar"], nil);
	PartyMemberFrame_UpdateMember(self);

	UnitFrame_Update(self, true)
end

function PartyMemberFrame_ToVehicleArt(self, vehicleType)
	self.state = "vehicle";
	local prefix = self:GetName();
	_G[prefix.."Texture"]:Hide();
	if ( vehicleType == "Natural" ) then
		_G[prefix.."VehicleTexture"]:SetTexture("Interface\\Vehicles\\UI-Vehicles-PartyFrame-Organic");
	else
		_G[prefix.."VehicleTexture"]:SetTexture("Interface\\Vehicles\\UI-Vehicles-PartyFrame");
	end
	_G[prefix.."VehicleTexture"]:Show();
	_G[prefix.."Portrait"]:SetPoint("TOPLEFT", 4, -9);
	_G[prefix.."LeaderIcon"]:SetPoint("TOPLEFT", -3, 0);
	_G[prefix.."PVPIcon"]:SetPoint("TOPLEFT", -12, -15);
	_G[prefix.."Disconnect"]:SetPoint("LEFT", -10, -1);

	self.overrideName = "party"..self:GetID();

	UnitFrame_SetUnit(self, "partypet"..self:GetID(), _G[prefix.."HealthBar"], _G[prefix.."ManaBar"]);
	UnitFrame_SetUnit(_G[prefix.."PetFrame"], "party"..self:GetID(), _G[prefix.."PetFrameHealthBar"], nil);
	PartyMemberFrame_UpdateMember(self);

	UnitFrame_Update(self, true)
end

function PartyMemberFrame_OnLoad (self)
	local id = self:GetID();
	self.unitToken = "party"..id;
	self.petUnitToken = "partypet"..id;
	self.debuffCountdown = 0;
	self.numDebuffs = 0;
	self.noTextPrefix = true;
	local prefix = "PartyMemberFrame"..id;
	self.HealthBar.LeftText = _G[prefix.."HealthBarTextLeft"];
	self.HealthBar.RightText = _G[prefix.."HealthBarTextRight"];
	self.ManaBar.LeftText = _G[prefix.."ManaBarTextLeft"];
	self.ManaBar.RightText = _G[prefix.."ManaBarTextRight"];

	local healthBar = self.HealthBar;

	UnitFrame_Initialize(self, self.unitToken,  _G[prefix.."Name"], _G[prefix.."Portrait"],
			healthBar,
			_G[prefix.."HealthBarText"],
			self.ManaBar,
			_G[prefix.."ManaBarText"],
			_G[prefix.."Flash"], nil, nil,
			healthBar.MyHealPredictionBar,
			healthBar.OtherHealPredictionBar,
			healthBar.TotalAbsorbBar, healthBar.TotalAbsorbBarOverlay,
			self.textureFrame.childFrame.overAbsorbGlow, self.textureFrame.childFrame.overHealAbsorbGlow,
			healthBar.HealAbsorbBar, healthBar.HealAbsorbBarLeftShadow,
			healthBar.HealAbsorbBarRightShadow);

	SetTextStatusBarTextZeroText(_G[prefix.."HealthBar"], DEAD);

	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;
	PartyMemberFrame_UpdateMember(self);
	PartyMemberFrame_UpdateLeader(self);
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

	PartyMemberFrame_UpdateArt(self);

	local altPowerBar = _G["PartyMemberFrame"..self:GetID().."PowerBarAlt"];
	if altPowerBar then
		UnitPowerBarAlt_Initialize(altPowerBar, self.unitToken, 0.5, "GROUP_ROSTER_UPDATE");
	end
end

function PartyMemberFrame_UpdateVoiceActivityNotification(self)
	if self.voiceNotification then
		self.voiceNotification:ClearAllPoints();
		if self.notPresentIcon:IsShown() then
			self.voiceNotification:SetPoint("LEFT", self.notPresentIcon, "RIGHT", 0, 0);
		else
			self.voiceNotification:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -12);
		end
	end
end

function PartyMemberFrame_VoiceActivityNotificationCreatedCallback(self, notification)
	self.voiceNotification = notification;
	self.voiceNotification:SetParent(self);
	PartyMemberFrame_UpdateVoiceActivityNotification(self);
	notification:Show();
end

function PartyMemberFrame_UpdateMember (self)
	if ( GetDisplayedAllyFrames() ~= "party" ) then
		self:Hide();
		UpdatePartyMemberBackground();
		return;
	end
	local id = self:GetID();
	local unit = "party"..id;
	if ( UnitExists(unit) ) then
		self:Show();

		if VoiceActivityManager then
			local guid = UnitGUID(unit);
			VoiceActivityManager:RegisterFrameForVoiceActivityNotifications(self, guid, nil, "VoiceActivityNotificationPartyTemplate", "Button", PartyMemberFrame_VoiceActivityNotificationCreatedCallback);
		end

		UnitFrame_Update(self, true);
	else
		if VoiceActivityManager then
			VoiceActivityManager:UnregisterFrameForVoiceActivityNotifications(self);
			self.voiceNotification = nil;
		end
		self:Hide();
	end
	PartyMemberFrame_UpdatePet(self);
	PartyMemberFrame_UpdatePvPStatus(self);
	RefreshDebuffs(self, "party"..id, nil, nil, true);
	PartyMemberFrame_UpdateReadyCheck(self);
	PartyMemberFrame_UpdateOnlineStatus(self);
	PartyMemberFrame_UpdateNotPresentIcon(self);
	UpdatePartyMemberBackground();
end

function PartyMemberFrame_UpdatePet (self, id)
	if ( not id ) then
		id = self:GetID();
	end

	local frameName = "PartyMemberFrame"..id;
	local petFrame = _G["PartyMemberFrame"..id.."PetFrame"];

	if ( UnitIsConnected("party"..id) and UnitExists("partypet"..id) and CVarCallbackRegistry:GetCVarValueBool("showPartyPets") ) then
		petFrame:Show();
		petFrame:SetPoint("TOPLEFT", frameName, "TOPLEFT", 23, -43);
	else
		petFrame:Hide();
		petFrame:SetPoint("TOPLEFT", frameName, "TOPLEFT", 23, -27);
	end

	PartyMemberFrame_RefreshPetDebuffs(self, id);
	UpdatePartyMemberBackground();
end

function PartyMemberFrame_UpdateMemberHealth (self, elapsed)
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
		_G[self:GetName().."Portrait"]:SetAlpha(alpha);
	end
end

function PartyMemberFrame_UpdateLeader (self)
	local id = self:GetID();
	local leaderIcon = _G["PartyMemberFrame"..id.."LeaderIcon"];
	local guideIcon = _G["PartyMemberFrame"..id.."GuideIcon"];
	local masterIcon = _G["PartyMemberFrame"..id.."MasterIcon"];

	if( UnitIsGroupLeader("party"..id) ) then
		leaderIcon:Show();
		guideIcon:Hide();
	else
		guideIcon:Hide();
		leaderIcon:Hide();
	end

	local lootMethod, lootMaster = GetLootMethod();
	if ( lootMaster == id ) then
		masterIcon:Show();
	else
		masterIcon:Hide();
	end
end

function PartyMemberFrame_UpdatePvPStatus (self)
	local id = self:GetID();
	local unit = "party"..id;
	local icon = _G["PartyMemberFrame"..id.."PVPIcon"];
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

function PartyMemberFrame_UpdateReadyCheck (self)
	local id = self:GetID();
	local partyID = "party"..id;

	local readyCheckFrame = _G["PartyMemberFrame"..id.."ReadyCheck"];
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

function PartyMemberFrame_UpdateNotPresentIcon(self)
	local id = self:GetID();
	local partyID = "party"..id;

	local inPhase = UnitInPhase(partyID);

	if ( UnitInOtherParty(partyID) ) then
		self:SetAlpha(0.6);
		self.notPresentIcon.texture:SetTexture("Interface\\LFGFrame\\LFG-Eye");
		self.notPresentIcon.texture:SetTexCoord(0.125, 0.25, 0.25, 0.5);
		self.notPresentIcon.Border:Show();
		self.notPresentIcon.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE;
		self.notPresentIcon:Show();
	elseif ( (not inPhase) and UnitIsConnected(partyID) ) then
		self:SetAlpha(0.6);
		self.notPresentIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon");
		self.notPresentIcon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375);
		self.notPresentIcon.Border:Hide();
		self.notPresentIcon.tooltip = PARTY_PHASED_MESSAGE;
		self.notPresentIcon:Show();
	else
		self:SetAlpha(1);
		self.notPresentIcon:Hide();
	end

	PartyMemberFrame_UpdateVoiceActivityNotification(self);
end

function PartyMemberFrame_OnEvent(self, event, ...)
	UnitFrame_OnEvent(self, event, ...);

	local arg1, arg2, arg3 = ...;
	local selfID = self:GetID();


	local unit = "party"..selfID;
	local unitPet = "partypet"..selfID;

	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( UnitExists("party"..self:GetID()) ) then
			PartyMemberFrame_UpdateMember(self);
			PartyMemberFrame_UpdateOnlineStatus(self);
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" or event == "UPDATE_ACTIVE_BATTLEFIELD" ) then
		PartyMemberFrame_UpdateMember(self);
		PartyMemberFrame_UpdateArt(self);
		PartyMemberFrame_UpdateLeader(self);
		return;
	elseif ( event == "PARTY_LEADER_CHANGED" ) then
		PartyMemberFrame_UpdateLeader(self);
	elseif ( event == "UNIT_FACTION" ) then
		if ( arg1 == unit ) then
			PartyMemberFrame_UpdatePvPStatus(self);
		end
	elseif ( event =="UNIT_AURA" ) then
		if ( arg1 == unit ) then
			RefreshDebuffs(self, unit, nil, nil, true);
			if ( PartyMemberBuffTooltip:IsShown() and
				selfID == PartyMemberBuffTooltip:GetID() ) then
				PartyMemberBuffTooltip_Update(self);
			end
		else
			if ( arg1 == unitPet ) then
				PartyMemberFrame_RefreshPetDebuffs(self);
			end
		end
	elseif ( event =="UNIT_PET" ) then
		if ( arg1 == unit ) then
			PartyMemberFrame_UpdatePet(self);
		end
	elseif ( event == "READY_CHECK" or
		 event == "READY_CHECK_CONFIRM" ) then
		PartyMemberFrame_UpdateReadyCheck(self);
	elseif ( event == "READY_CHECK_FINISHED" ) then
		if (UnitExists("party"..self:GetID())) then
			local finishTime = DEFAULT_READY_CHECK_STAY_TIME;
			if ( GetDisplayedAllyFrames() ~= "party" ) then
				finishTime = 0;
			end
			ReadyCheck_Finish(_G["PartyMemberFrame"..self:GetID().."ReadyCheck"], finishTime);
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		PartyMemberFrame_UpdatePet(self);
	elseif ( event == "UNIT_ENTERED_VEHICLE" ) then
		if ( arg1 == "party"..selfID ) then
			if ( arg2 and UnitIsConnected("party"..selfID) ) then
				PartyMemberFrame_ToVehicleArt(self, arg3);
			else
				PartyMemberFrame_ToPlayerArt(self);
			end
		end
	elseif ( event == "UNIT_EXITED_VEHICLE" ) then
		if ( arg1 == "party"..selfID ) then
			PartyMemberFrame_ToPlayerArt(self);
		end
	elseif ( event == "UNIT_CONNECTION" ) and ( arg1 == "party"..selfID ) then
		PartyMemberFrame_UpdateArt(self);
		PartyMemberFrame_UpdateOnlineStatus(self);
	elseif ( event == "UNIT_PHASE" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" or event == "UNIT_FLAGS") then
		if ( event ~= "UNIT_PHASE" or arg1 == unit ) then
			PartyMemberFrame_UpdateNotPresentIcon(self);
		end
	elseif ( event == "UNIT_OTHER_PARTY_CHANGED" and arg1 == unit ) then
		PartyMemberFrame_UpdateNotPresentIcon(self);
	end
end

function PartyMemberFrame_OnUpdate (self, elapsed)
	PartyMemberFrame_UpdateMemberHealth(self, elapsed);
	local partyStatus = _G[self:GetName().."Status"];
	if ( self.hasDispellable ) then
		partyStatus:Show();
		partyStatus:SetAlpha(BuffFrame.BuffAlphaValue);
		if ( self.debuffCountdown and self.debuffCountdown > 0 ) then
			self.debuffCountdown = self.debuffCountdown - elapsed;
		else
			partyStatus:Hide();
		end
	else
		partyStatus:Hide();
	end
end

function PartyMemberFrame_RefreshPetDebuffs (self, id)
	if ( not id ) then
		id = self:GetID();
	end
	RefreshDebuffs(_G["PartyMemberFrame"..id.."PetFrame"], "partypet"..id, nil, nil, true);
end

function PartyMemberBuffTooltip_Update (self)
	local name, icon;
	local numBuffs = 0;
	local numDebuffs = 0;
	local index = 1;
	local filter = nil;

	PartyMemberBuffTooltip:SetID(self:GetID());

	for i=1, MAX_PARTY_TOOLTIP_BUFFS do
		name, icon = UnitBuff(self.unit, i, filter);
		if ( icon ) then
			_G["PartyMemberBuffTooltipBuff"..index.."Icon"]:SetTexture(icon);
			_G["PartyMemberBuffTooltipBuff"..index]:Show();
			index = index + 1;
			numBuffs = numBuffs + 1;
		end
	end
	for i=index, MAX_PARTY_TOOLTIP_BUFFS do
		_G["PartyMemberBuffTooltipBuff"..i]:Hide();
	end

	if ( numBuffs == 0 ) then
		PartyMemberBuffTooltipDebuff1:SetPoint("TOP", "PartyMemberBuffTooltipBuff1", "TOP", 0, 0);
	elseif ( numBuffs <= 8 ) then
		PartyMemberBuffTooltipDebuff1:SetPoint("TOP", "PartyMemberBuffTooltipBuff1", "BOTTOM", 0, -2);
	else
		PartyMemberBuffTooltipDebuff1:SetPoint("TOP", "PartyMemberBuffTooltipBuff9", "BOTTOM", 0, -2);
	end

	index = 1;

	local debuffButton, debuffStack, debuffType, color, countdown;
	for i=1, MAX_PARTY_TOOLTIP_DEBUFFS do
		local debuffBorder = _G["PartyMemberBuffTooltipDebuff"..index.."Border"]
		local partyDebuff = _G["PartyMemberBuffTooltipDebuff"..index.."Icon"];
		name, icon, debuffStack, debuffType = UnitDebuff(self.unit, i, filter);
		if ( icon ) then
			partyDebuff:SetTexture(icon);
			if ( debuffType ) then
				color = DebuffTypeColor[debuffType];
			else
				color = DebuffTypeColor["none"];
			end
			debuffBorder:SetVertexColor(color.r, color.g, color.b);
			_G["PartyMemberBuffTooltipDebuff"..index]:Show();
			numDebuffs = numDebuffs + 1;
			index = index + 1;
		end
	end
	for i=index, MAX_PARTY_TOOLTIP_DEBUFFS do
		_G["PartyMemberBuffTooltipDebuff"..i]:Hide();
	end

	-- Size the tooltip
	local rows = ceil(numBuffs / 8) + ceil(numDebuffs / 8);
	local columns = min(8, max(numBuffs, numDebuffs));
	if ( (rows > 0) and (columns > 0) ) then
		PartyMemberBuffTooltip:SetWidth( (columns * 17) + 15 );
		PartyMemberBuffTooltip:SetHeight( (rows * 17) + 15 );
		PartyMemberBuffTooltip:Show();
	else
		PartyMemberBuffTooltip:Hide();
	end
end

function PartyMemberHealthCheck (self, value)
	local prefix = self:GetParent():GetName();
	local unitHPMin, unitHPMax, unitCurrHP;
	unitHPMin, unitHPMax = self:GetMinMaxValues();
	local parentName = self:GetParent():GetName();

	unitCurrHP = self:GetValue();
	if ( unitHPMax > 0 ) then
		self:GetParent().unitHPPercent = unitCurrHP / unitHPMax;
	else
		self:GetParent().unitHPPercent = 0;
	end
	if ( UnitIsDead("party"..self:GetParent():GetID()) ) then
		_G[prefix.."Portrait"]:SetVertexColor(0.35, 0.35, 0.35, 1.0);
	elseif ( UnitIsGhost("party"..self:GetParent():GetID()) ) then
		_G[prefix.."Portrait"]:SetVertexColor(0.2, 0.2, 0.75, 1.0);
	elseif ( (self:GetParent().unitHPPercent > 0) and (self:GetParent().unitHPPercent <= 0.2) ) then
		_G[prefix.."Portrait"]:SetVertexColor(1.0, 0.0, 0.0);
	else
		_G[prefix.."Portrait"]:SetVertexColor(1.0, 1.0, 1.0, 1.0);
	end
end

function UpdatePartyMemberBackground ()
	if ( not PartyMemberBackground ) then
		return;
	end
	local numMembers = GetNumSubgroupMembers();
	if ( numMembers > 0 and CVarCallbackRegistry:GetCVarValueBool("showPartyBackground") and GetDisplayedAllyFrames() == "party" ) then
		if ( _G["PartyMemberFrame"..numMembers.."PetFrame"]:IsShown() ) then
			PartyMemberBackground:SetPoint("BOTTOMLEFT", "PartyMemberFrame"..numMembers, "BOTTOMLEFT", -5, -21);
		else
			PartyMemberBackground:SetPoint("BOTTOMLEFT", "PartyMemberFrame"..numMembers, "BOTTOMLEFT", -5, -5);
		end
		PartyMemberBackground:Show();
	else
		PartyMemberBackground:Hide();
	end
end

function PartyMemberBackground_ToggleOpacity (self)
	if ( not self ) then
		self = PartyMemberBackground;
	end
	if ( OpacityFrame:IsShown() ) then
		OpacityFrame:Hide();
		return;
	end
	OpacityFrame:ClearAllPoints();
	if ( self == ArenaEnemyBackground ) then
		OpacityFrame:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, -7);
	else
		OpacityFrame:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 7);
	end
	OpacityFrame.opacityFunc = PartyMemberBackground_SetOpacity;
	OpacityFrame.saveOpacityFunc = PartyMemberBackground_SaveOpacity;
	OpacityFrame:Show();
end

function PartyMemberBackground_SetOpacity ()
	local alpha = 1.0 - OpacityFrameSlider:GetValue();
	PartyMemberBackground:SetAlpha(alpha);
	if ( ArenaEnemyBackground_SetOpacity ) then
		ArenaEnemyBackground_SetOpacity();
	end
end

function PartyMemberBackground_SaveOpacity ()
	PARTYBACKGROUND_OPACITY = OpacityFrameSlider:GetValue();
	SetCVar("partyBackgroundOpacity", PARTYBACKGROUND_OPACITY);
end

function PartyMemberFrame_UpdateStatusBarText ()
	local lockText = nil;
	if ( SHOW_PARTY_TEXT == "1" ) then
		lockText = 1;
	end
	for i=1, MAX_PARTY_MEMBERS do
		_G["PartyMemberFrame"..i.."HealthBar"].forceShow = lockText;
		_G["PartyMemberFrame"..i.."ManaBar"].forceShow = lockText;
		if ( lockText ) then
			_G["PartyMemberFrame"..i.."HealthBarText"]:Show();
			_G["PartyMemberFrame"..i.."ManaBarText"]:Show();
		end
	end
end

function PartyMemberFrame_UpdateOnlineStatus(self)
	if ( not UnitIsConnected("party"..self:GetID()) ) then
		-- Handle disconnected state
		local selfName = self:GetName();
		local healthBar = _G[selfName.."HealthBar"];
		local unitHPMin, unitHPMax = healthBar:GetMinMaxValues();

		healthBar:SetValue(unitHPMax);
		healthBar:SetStatusBarColor(0.5, 0.5, 0.5);
		SetDesaturation(_G[selfName.."Portrait"], true);
		_G[selfName.."Disconnect"]:Show();
		_G[selfName.."PetFrame"]:Hide();
		return;
	else
		local selfName = self:GetName();
		SetDesaturation(_G[selfName.."Portrait"], false);
		_G[selfName.."Disconnect"]:Hide();
	end
end
