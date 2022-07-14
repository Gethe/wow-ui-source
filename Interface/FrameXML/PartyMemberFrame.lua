MAX_PARTY_MEMBERS = 4;
MAX_PARTY_BUFFS = 4;
MAX_PARTY_DEBUFFS = 4;
MAX_PARTY_TOOLTIP_BUFFS = 16;
MAX_PARTY_TOOLTIP_DEBUFFS = 8;

CVarCallbackRegistry:SetCVarCachable("showPartyPets");
CVarCallbackRegistry:SetCVarCachable("showCastableBuffs");
CVarCallbackRegistry:SetCVarCachable("showDispelDebuffs");
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
	if ( UnitHasVehicleUI(unit) and UnitIsConnected(unit) ) then
		local vehicleType = UnitVehicleSkin(unit);
		PartyMemberFrame_ToVehicleArt(self, vehicleType);
	else
		PartyMemberFrame_ToPlayerArt(self);
	end
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
	self.debuffCountdown = 0;
	self.numDebuffs = 0;
	self.noTextPrefix = true;
	local prefix = "PartyMemberFrame"..id;
	_G[prefix.."HealthBar"].LeftText = _G[prefix.."HealthBarTextLeft"];
	_G[prefix.."HealthBar"].RightText = _G[prefix.."HealthBarTextRight"];
	_G[prefix.."ManaBar"].LeftText = _G[prefix.."ManaBarTextLeft"];
	_G[prefix.."ManaBar"].RightText = _G[prefix.."ManaBarTextRight"];

	UnitFrame_Initialize(self, "party"..id,  _G[prefix.."Name"], _G[prefix.."Portrait"],
		   _G[prefix.."HealthBar"], _G[prefix.."HealthBarText"],
		   _G[prefix.."ManaBar"], _G[prefix.."ManaBarText"],
		   _G[prefix.."Flash"], nil, nil, _G[prefix.."MyHealPredictionBar"], _G[prefix.."OtherHealPredictionBar"],
		   _G[prefix.."TotalAbsorbBar"], _G[prefix.."TotalAbsorbBarOverlay"], _G[prefix.."OverAbsorbGlow"],
		   _G[prefix.."OverHealAbsorbGlow"], _G[prefix.."HealAbsorbBar"], _G[prefix.."HealAbsorbBarLeftShadow"],
		   _G[prefix.."HealAbsorbBarRightShadow"]);
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
	local id = self:GetID();
	self:RegisterUnitEvent("UNIT_AURA", "party"..id, "partypet"..id);
	self:RegisterUnitEvent("UNIT_PET",  "party"..id, "partypet"..id);
	local showmenu = function()
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self:GetID().."DropDown"], self:GetName(), 47, 15);
	end
	SecureUnitButton_OnLoad(self, "party"..id, showmenu);

	PartyMemberFrame_UpdateArt(self);
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
	PartyMemberFrame_UpdateAuras(self);
	PartyMemberFrame_UpdateVoiceStatus(self);
	PartyMemberFrame_UpdateReadyCheck(self);
	PartyMemberFrame_UpdateOnlineStatus(self);
	PartyMemberFrame_UpdateNotPresentIcon(self);
	UpdatePartyMemberBackground();
end

function PartyMemberFrame_UpdatePet (self)
	if ( UnitIsConnected(self.unit) and UnitExists(self.PetFrame.unit) and CVarCallbackRegistry:GetCVarValueBool("showPartyPets") ) then
		self.PetFrame:Show();
		self.PetFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 23, -43);
	else
		self.PetFrame:Hide();
		self.PetFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 23, -27);
	end

	PartyMemberFrame_UpdateAuras(self.PetFrame);
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

function PartyMemberFrame_UpdateAssignedRoles (self)
	local id = self:GetID();
	local unit = "party"..id;
	local icon = _G["PartyMemberFrame"..id.."RoleIcon"];
	local role = UnitGroupRolesAssigned(unit);

	if ( role == "TANK" or role == "HEALER" or role == "DAMAGER") then
		icon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role));
		icon:Show();
	else
		icon:Hide();
	end
end

function PartyMemberFrame_UpdateVoiceStatus (self)
	local id = self:GetID();
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

	if ( UnitInOtherParty(partyID) ) then
		self:SetAlpha(0.6);
		self.notPresentIcon.texture:SetAtlas("groupfinder-eye-single", true);
		self.notPresentIcon.texture:SetTexCoord(0, 1, 0, 1);
		self.notPresentIcon.Border:Show();
		self.notPresentIcon.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE;
		self.notPresentIcon:Show();
	elseif ( C_IncomingSummon.HasIncomingSummon(self.unit) ) then
		local status = C_IncomingSummon.IncomingSummonStatus(self.unit);
		if(status == Enum.SummonStatus.Pending) then
			self.notPresentIcon.texture:SetAtlas("Raid-Icon-SummonPending");
			self.notPresentIcon.texture:SetTexCoord(0, 1, 0, 1);
			self.notPresentIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_PENDING;
			self.notPresentIcon.Border:Hide();
			self.notPresentIcon:Show();
		elseif( status == Enum.SummonStatus.Accepted ) then
			self.notPresentIcon.texture:SetAtlas("Raid-Icon-SummonAccepted");
			self.notPresentIcon.texture:SetTexCoord(0, 1, 0, 1);
			self.notPresentIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_ACCEPTED;
			self.notPresentIcon.Border:Hide();
			self.notPresentIcon:Show();
		elseif( status == Enum.SummonStatus.Declined ) then
			self.notPresentIcon.texture:SetAtlas("Raid-Icon-SummonDeclined");
			self.notPresentIcon.texture:SetTexCoord(0, 1, 0, 1);
			self.notPresentIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_DECLINED;
			self.notPresentIcon.Border:Hide();
			self.notPresentIcon:Show();
		end
	else
		local phaseReason = UnitIsConnected(partyID) and UnitPhaseReason(partyID) or nil;
		if phaseReason then
			self:SetAlpha(0.6);
			self.notPresentIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon");
			self.notPresentIcon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375);
			self.notPresentIcon.Border:Hide();
			self.notPresentIcon.tooltip = PartyUtil.GetPhasedReasonString(phaseReason, partyID);
			self.notPresentIcon:Show();
		else
			self:SetAlpha(1);
			self.notPresentIcon:Hide();
		end
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
			PartyMemberFrame_UpdateAssignedRoles(self);
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" or event == "UPDATE_ACTIVE_BATTLEFIELD" ) then
		PartyMemberFrame_UpdateMember(self);
		PartyMemberFrame_UpdateArt(self);
		PartyMemberFrame_UpdateAssignedRoles(self);
	elseif ( event == "PARTY_LEADER_CHANGED" ) then
		PartyMemberFrame_UpdateLeader(self);
	elseif ( event == "MUTELIST_UPDATE" or event == "IGNORELIST_UPDATE" ) then
		PartyMemberFrame_UpdateVoiceStatus(self);
	elseif ( event == "UNIT_FACTION" ) then
		if ( arg1 == unit ) then
			PartyMemberFrame_UpdatePvPStatus(self);
		end
	elseif ( event =="UNIT_AURA" ) then
		if ( arg1 == unit ) then
			local unitAuraUpdateInfo = arg2;
			PartyMemberFrame_UpdateAuras(self, unitAuraUpdateInfo);
			if ( PartyMemberBuffTooltip:IsShown() and
				selfID == PartyMemberBuffTooltip:GetID() ) then
				PartyMemberBuffTooltip_Update(self);
			end
		else
			if ( arg1 == unitPet ) then
				PartyMemberFrame_UpdateAuras(self.PetFrame, unitAuraUpdateInfo);
			end
		end
	elseif ( event =="UNIT_PET" ) then
		if ( arg1 == unit ) then
			PartyMemberFrame_UpdatePet(self);
		end
		if ( UnitHasVehicleUI("party"..selfID) and UnitIsConnected("party"..selfID)) then
			PartyMemberFrame_ToVehicleArt(self, UnitVehicleSkin("party"..selfID));
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
	elseif ( event == "UNIT_PHASE" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" or event == "UNIT_FLAGS" or event == "UNIT_CTR_OPTIONS") then
		if ( event ~= "UNIT_PHASE" or arg1 == unit ) then
			PartyMemberFrame_UpdateNotPresentIcon(self);
		end
	elseif ( event == "UNIT_OTHER_PARTY_CHANGED" and arg1 == unit ) then
		PartyMemberFrame_UpdateNotPresentIcon(self);
	elseif ( event == "INCOMING_SUMMON_CHANGED" ) then
		PartyMemberFrame_UpdateNotPresentIcon(self);
	end
end

function PartyMemberFrame_OnUpdate (self, elapsed)
	PartyMemberFrame_UpdateMemberHealth(self, elapsed);
end

function PartyMemberBuffTooltip_Update(self)
	PartyMemberBuffTooltip:SetID(self:GetID());

	local numBuffs = 0;
	local frameNum = 1;
	self.buffs:Iterate(function(auraInstanceID, aura)
		if frameNum > MAX_PARTY_TOOLTIP_BUFFS then
			return true;
		end

		if aura.icon then
			local buff = PartyMemberBuffTooltip.Buff[frameNum];
			buff.Icon:SetTexture(aura.icon);
			buff:Show();

			frameNum = frameNum + 1;
			numBuffs = numBuffs + 1;
		end

		return false;
	end);

	for i = frameNum, MAX_PARTY_TOOLTIP_BUFFS do
		PartyMemberBuffTooltip.Buff[i]:Hide();
	end

	if ( numBuffs == 0 ) then
		PartyMemberBuffTooltip.Debuff[1]:SetPoint("TOP", PartyMemberBuffTooltip.Buff[1], "TOP", 0, 0);
	elseif ( numBuffs <= 8 ) then
		PartyMemberBuffTooltip.Debuff[1]:SetPoint("TOP", PartyMemberBuffTooltip.Buff[1], "BOTTOM", 0, -2);
	else
		PartyMemberBuffTooltip.Debuff[1]:SetPoint("TOP", PartyMemberBuffTooltip.Buff[9], "BOTTOM", 0, -2);
	end

	local numDebuffs = 0;
	frameNum = 1;
	self.debuffs:Iterate(function(auraInstanceID, aura)
		if frameNum > MAX_PARTY_TOOLTIP_DEBUFFS then
			return true;
		end

		if aura.icon then
			local debuff = PartyMemberBuffTooltip.Debuff[frameNum]
			debuff.Icon:SetTexture(aura.icon);
			local color = aura.dispelName and DebuffTypeColor[aura.dispelName] or DebuffTypeColor["none"]
			debuff.Border:SetVertexColor(color.r, color.g, color.b);
			debuff:Show();

			frameNum = frameNum + 1;
			numDebuffs = numDebuffs + 1;
		end

		return false;
	end);

	for i = frameNum, MAX_PARTY_TOOLTIP_DEBUFFS do
		PartyMemberBuffTooltip.Debuff[i]:Hide();
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

function PartyFrameDropDown_OnLoad (self)
	UIDropDownMenu_SetInitializeFunction(self, PartyFrameDropDown_Initialize);
	UIDropDownMenu_SetDisplayMode(self, "MENU");
end

function PartyFrameDropDown_Initialize (self)
	local dropdown = UIDROPDOWNMENU_OPEN_MENU or self;
	UnitPopup_ShowMenu(dropdown, "PARTY", "party"..dropdown:GetParent():GetID());
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

function PartyMemberFrame_UpdateAuras(frame, unitAuraUpdateInfo)
	PartyMemberFrame_UpdateAurasInternal(frame, unitAuraUpdateInfo);
end


function PartyMemberFrame_UpdateAurasInternal(frame, unitAuraUpdateInfo)
	local displayOnlyDispellableDebuffs = CVarCallbackRegistry:GetCVarValueBool("showDispelDebuffs") and UnitCanAssist("player", frame.unit);
	-- Buffs are only displayed in the Party Buff Tooltip
	local ignoreBuffs = MAX_PARTY_TOOLTIP_BUFFS == 0;
	local ignoreDebuffs = not frame.debuffFrames or MAX_PARTY_DEBUFFS == 0;
	local ignoreDispelDebuffs = not frame.debuffFrames or MAX_PARTY_DEBUFFS == 0;

	local debuffsChanged = false;

	if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or frame.debuffs == nil then
		PartyMemberFrame_ParseAllAuras(frame, displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs);
		debuffsChanged = true;
	else
		if unitAuraUpdateInfo.addedAuras ~= nil then
			for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
				local type = AuraUtil.ProcessAura(aura, displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs);

				if type == AuraUtil.AuraUpdateChangedType.Debuff or type == AuraUtil.AuraUpdateChangedType.Dispel then
					frame.debuffs[aura.auraInstanceID] = aura;
					debuffsChanged = true;
				elseif type == AuraUtil.AuraUpdateChangedType.Buff then
					frame.buffs[aura.auraInstanceID] = aura;
				end
			end
		end

		if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
				if frame.debuffs[auraInstanceID] ~= nil then
					local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(frame.unit, auraInstanceID);
					local oldDebuffType = frame.debuffs[auraInstanceID].debuffType;
					if newAura ~= nil then
						newAura.debuffType = oldDebuffType;
					end
					frame.debuffs[auraInstanceID] = newAura;
					debuffsChanged = true;
				elseif frame.buffs[auraInstanceID] ~= nil then
					local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(frame.unit, auraInstanceID);
					if newAura ~= nil then
						newAura.isBuff = true;
					end
					frame.buffs[auraInstanceID] = newAura;
				end
			end
		end

		if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
				if frame.debuffs[auraInstanceID] ~= nil then
					frame.debuffs[auraInstanceID] = nil;
					debuffsChanged = true;
				elseif frame.buffs[auraInstanceID] ~= nil then
					frame.buffs[auraInstanceID] = nil;
				end
			end
		end
	end

	if debuffsChanged then
		local frameNum = 1;
		frame.debuffs:Iterate(function(auraInstanceID, aura)
			if frameNum > MAX_PARTY_DEBUFFS then
				return true;
			end

			local debuffFrame = frame.debuffFrames[frameNum];
			PartyMemberFrame_SetDebuff(frame, debuffFrame, aura, frameNum);
			frameNum = frameNum + 1;

			return false;
		end);


		local unitStatus;
		if frame.PartyMemberOverlay and frame.PartyMemberOverlay.Info then
			unitStatus = frame.PartyMemberOverlay.Info.Status;
		end

		if unitStatus then
			local highestPriorityDebuff = frame.debuffs:GetTop();
			if highestPriorityDebuff then
				local statusColor = DebuffTypeColor[highestPriorityDebuff.dispelName] or DebuffTypeColor["none"];
				unitStatus:SetVertexColor(statusColor.r, statusColor.g, statusColor.b);
				unitStatus:Show();
			else
				unitStatus:Hide();
			end
		end

		PartyMemberFrame_HideAllDebuffs(frame, frameNum);
	end
end

function PartyMemberFrame_ParseAllAuras(frame, displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs) 
	if frame.debuffs == nil then
		frame.debuffs = TableUtil.CreatePriorityTable(AuraUtil.UnitFrameDebuffComparator, TableUtil.Constants.AssociativePriorityTable);
		frame.buffs = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
	else
		frame.debuffs:Clear();
		frame.buffs:Clear();
	end

	local batchCount = nil;
	local usePackedAura = true;
	local function HandleAura(aura)
		local type = AuraUtil.ProcessAura(aura, displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs);

		if type == AuraUtil.AuraUpdateChangedType.Debuff or type == AuraUtil.AuraUpdateChangedType.Dispel then
			frame.debuffs[aura.auraInstanceID] = aura;
		elseif type == AuraUtil.AuraUpdateChangedType.Buff then
			frame.buffs[aura.auraInstanceID] = aura;
		end
	end
	AuraUtil.ForEachAura(frame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful), batchCount, HandleAura, usePackedAura);
	AuraUtil.ForEachAura(frame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful), batchCount, HandleAura, usePackedAura);
	AuraUtil.ForEachAura(frame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful, AuraUtil.AuraFilters.Raid), batchCount, HandleAura, usePackedAura);
end

function PartyMemberFrame_SetDebuff(partyMemberFrame, debuffFrame, aura, frameNum)
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

function PartyMemberFrame_HideAllDebuffs(frame, startingIndex)
	if frame.debuffFrames then
		for i = startingIndex or 1, #frame.debuffFrames do
			frame.debuffFrames[i]:Hide();
		end
	end
end