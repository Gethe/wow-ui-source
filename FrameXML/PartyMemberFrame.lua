MAX_PARTY_MEMBERS = 4;
MAX_PARTY_BUFFS = 4;
MAX_PARTY_DEBUFFS = 4;
MAX_PARTY_TOOLTIP_BUFFS = 16;
MAX_PARTY_TOOLTIP_DEBUFFS = 8;

function HidePartyFrame()
	for i=1, MAX_PARTY_MEMBERS, 1 do
		_G["PartyMemberFrame"..i]:Hide();
	end
end

function ShowPartyFrame()
	for i=1, MAX_PARTY_MEMBERS, 1 do
		if ( GetPartyMember(i) ) then
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
	_G[prefix.."MasterIcon"]:SetPoint("TOPLEFT", 32, 0);
	_G[prefix.."PVPIcon"]:SetPoint("TOPLEFT", -9, -15);
	_G[prefix.."Disconnect"]:SetPoint("LEFT", -7, -1);
	
	self.overrideName = nil;
	
	UnitFrame_SetUnit(self, "party"..self:GetID(), _G[prefix.."HealthBar"], _G[prefix.."ManaBar"]);
	UnitFrame_SetUnit(_G[prefix.."PetFrame"], "partypet"..self:GetID(), _G[prefix.."PetFrameHealthBar"], nil);
	PartyMemberFrame_UpdateMember(self);
	
	UnitFrame_Update(self)
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
	_G[prefix.."MasterIcon"]:SetPoint("TOPLEFT", 29, 0);
	_G[prefix.."PVPIcon"]:SetPoint("TOPLEFT", -12, -15);
	_G[prefix.."Disconnect"]:SetPoint("LEFT", -10, -1);
	
	self.overrideName = "party"..self:GetID();
	
	UnitFrame_SetUnit(self, "partypet"..self:GetID(), _G[prefix.."HealthBar"], _G[prefix.."ManaBar"]);
	UnitFrame_SetUnit(_G[prefix.."PetFrame"], "party"..self:GetID(), _G[prefix.."PetFrameHealthBar"], nil);
	PartyMemberFrame_UpdateMember(self);
	
	UnitFrame_Update(self)
end

function PartyMemberFrame_OnLoad (self)
	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;
	PartyMemberFrame_UpdateMember(self);
	PartyMemberFrame_UpdateLeader(self);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	self:RegisterEvent("MUTELIST_UPDATE");
	self:RegisterEvent("IGNORELIST_UPDATE");
	self:RegisterEvent("UNIT_FACTION");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("VOICE_START");
	self:RegisterEvent("VOICE_STOP");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("VOICE_STATUS_UPDATE");
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_CONFIRM");
	self:RegisterEvent("READY_CHECK_FINISHED");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("UNIT_HEALTH");

	local showmenu = function()
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self:GetID().."DropDown"], self:GetName(), 47, 15);
	end
	SecureUnitButton_OnLoad(self, "party"..self:GetID(), showmenu);
	
	PartyMemberFrame_UpdateArt(self);
end

function PartyMemberFrame_UpdateMember (self)
	if ( HIDE_PARTY_INTERFACE == "1" and GetNumRaidMembers() > 0 ) then
		self:Hide();
		return;
	end
	local id = self:GetID();
	if ( GetPartyMember(id) ) then
		self:Show();

		UnitFrame_Update(self);

		local masterIcon = _G[self:GetName().."MasterIcon"];
		local lootMethod;
		local lootMaster;
		lootMethod, lootMaster = GetLootMethod();
		if ( id == lootMaster ) then
			masterIcon:Show();
		else
			masterIcon:Hide();
		end
	else
		self:Hide();
	end
	PartyMemberFrame_UpdatePet(self);
	PartyMemberFrame_UpdatePvPStatus(self);
	RefreshDebuffs(self, "party"..id);
	PartyMemberFrame_UpdateVoiceStatus(self);
	PartyMemberFrame_UpdateReadyCheck(self);
	PartyMemberFrame_UpdateOnlineStatus(self);
	UpdatePartyMemberBackground();
end

function PartyMemberFrame_UpdatePet (self, id)
	if ( not id ) then
		id = self:GetID();
	end
	
	local frameName = "PartyMemberFrame"..id;
	local petFrame = _G["PartyMemberFrame"..id.."PetFrame"];
	
	if ( UnitIsConnected("party"..id) and UnitExists("partypet"..id) and SHOW_PARTY_PETS == "1" ) then
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

	if( GetPartyLeaderIndex() == id ) then
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
	elseif ( factionGroup and UnitIsPVP(unit) ) then
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
	local isTank, isHealer, isDamage = UnitGroupRolesAssigned(unit);
	
	if ( isTank ) then
		icon:SetTexCoord(0, 19/64, 22/64, 41/64);
		icon:Show();
	elseif ( isHealer ) then
		icon:SetTexCoord(20/64, 39/64, 1/64, 20/64);
		icon:Show();
	elseif ( isDamage ) then
		icon:SetTexCoord(20/64, 39/64, 22/64, 41/64);
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
	elseif ( GetNumRaidMembers() > 0 ) then
		mode = "raid";
	else
		mode = "party";
	end
	local status = GetVoiceStatus("party"..id, mode);
	local statusIcon = _G["PartyMemberFrame"..id.."Speaker"];
	local muted = GetMuteStatus("party"..id, mode);
	local mutedIcon = _G["PartyMemberFrame"..id.."SpeakerMuted"];

	_G["PartyMemberFrame"..id.."SpeakerOn"]:SetVertexColor(0.7, 0.7, 0.7);
	if ( status ) then
		statusIcon:Show();
	else
		statusIcon:Hide();
	end
	if ( muted ) then
		mutedIcon:Show();
	else
		mutedIcon:Hide();
	end
	-- Update the talking speaker thingie if they are talking or not.
	local speaker = _G["PartyMemberFrame"..id.."SpeakerFrame"];
	local state = UnitIsTalking(UnitName("party"..id));
	if ( state ) then
		VoiceChat_Animate(speaker, 1);
		speaker:Show();
	else
		VoiceChat_Animate(speaker, nil);
		speaker:Hide();
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

function PartyMemberFrame_OnEvent(self, event, ...)
	UnitFrame_OnEvent(self, event, ...);
	
	local arg1, arg2, arg3 = ...;
	local selfID = self:GetID();
	
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( GetPartyMember(self:GetID()) ) then
			PartyMemberFrame_UpdateMember(self);
			PartyMemberFrame_UpdateOnlineStatus(self);
			return;
		end
	end

	if ( event == "PARTY_MEMBERS_CHANGED" ) then
		PartyMemberFrame_UpdateMember(self);
		PartyMemberFrame_UpdateArt(self);
		PartyMemberFrame_UpdateAssignedRoles(self);
		return;
	end
	
	if ( event == "PARTY_LEADER_CHANGED" ) then
		PartyMemberFrame_UpdateLeader(self);
		return;
	end

	if ( event == "PARTY_LOOT_METHOD_CHANGED" ) then
		local lootMethod;
		local lootMaster;
		lootMethod, lootMaster = GetLootMethod();
		if ( selfID == lootMaster ) then
			_G[self:GetName().."MasterIcon"]:Show();
		else
			_G[self:GetName().."MasterIcon"]:Hide();
		end
		return;
	end

	if ( event == "MUTELIST_UPDATE" or event == "IGNORELIST_UPDATE" ) then
		PartyMemberFrame_UpdateVoiceStatus(self);
	end

	local unit = "party"..self:GetID();
	local unitPet = "partypet"..self:GetID();

	if ( event == "UNIT_FACTION" ) then
		if ( arg1 == unit ) then
			PartyMemberFrame_UpdatePvPStatus(self);
		end
		return;
	end

	if ( event =="UNIT_AURA" ) then
		if ( arg1 == unit ) then
			RefreshDebuffs(self, unit);
			if ( PartyMemberBuffTooltip:IsShown() and
				selfID == PartyMemberBuffTooltip:GetID() ) then
				PartyMemberBuffTooltip_Update(self);
			end
		else
			if ( arg1 == unitPet ) then
				PartyMemberFrame_RefreshPetDebuffs(self);
			end
		end
		return;
	end

	if ( event =="UNIT_PET" ) then
		if ( arg1 == unit ) then
			PartyMemberFrame_UpdatePet(self);
		end
		if ( UnitHasVehicleUI("party"..selfID) and UnitIsConnected("party"..selfID)) then
			PartyMemberFrame_ToVehicleArt(self, UnitVehicleSkin("party"..selfID));
		end
		return;
	end

	if ( event == "READY_CHECK" or
		 event == "READY_CHECK_CONFIRM" ) then
		PartyMemberFrame_UpdateReadyCheck(self);
		return;
	elseif ( event == "READY_CHECK_FINISHED" ) then
		if (GetPartyMember(self:GetID())) then
			ReadyCheck_Finish(_G["PartyMemberFrame"..self:GetID().."ReadyCheck"]);
		end
		return;
	end

	local speaker = _G[self:GetName().."SpeakerFrame"];
	if ( event == "VOICE_START") then
		if ( arg1 == unit ) then
			speaker.timer = nil;
			UIFrameFadeIn(speaker, 0.2, speaker:GetAlpha(), 1);
			VoiceChat_Animate(speaker, 1);
		end
	elseif ( event == "VOICE_STOP" ) then
		if ( arg1 == unit ) then
			speaker.timer = VOICECHAT_DELAY;
			VoiceChat_Animate(speaker, nil);
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		PartyMemberFrame_UpdatePet(self);
		PartyMemberFrame_UpdateVoiceStatus(self);
	elseif ( event == "VOICE_STATUS_UPDATE" ) then
		PartyMemberFrame_UpdateVoiceStatus(self);
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
	elseif ( event == "UNIT_HEALTH" ) and ( arg1 == "party"..selfID ) then
		PartyMemberFrame_UpdateOnlineStatus(self);
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
	RefreshDebuffs(_G["PartyMemberFrame"..id.."PetFrame"], "partypet"..id)
end

function PartyMemberBuffTooltip_Update (self)
	local name, rank, icon;
	local numBuffs = 0;
	local numDebuffs = 0;
	local index = 1;
	
	PartyMemberBuffTooltip:SetID(self:GetID());
	
	for i=1, MAX_PARTY_TOOLTIP_BUFFS do
		name, rank, icon = UnitBuff(self.unit, i);
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
		name, rank, icon, debuffStack, debuffType = UnitDebuff(self.unit, i);		
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

function PartyFrameDropDown_OnLoad (self)
	UIDropDownMenu_Initialize(self, PartyFrameDropDown_Initialize, "MENU");
end

function PartyFrameDropDown_Initialize (self)
	local dropdown = UIDROPDOWNMENU_OPEN_MENU or self;
	UnitPopup_ShowMenu(dropdown, "PARTY", "party"..dropdown:GetParent():GetID());
end

function UpdatePartyMemberBackground ()
	if ( not PartyMemberBackground ) then
		return;
	end
	if ( SHOW_PARTY_BACKGROUND == "1" and GetNumPartyMembers() > 0 and not(HIDE_PARTY_INTERFACE == "1" and (GetNumRaidMembers() > 0)) ) then
		if ( _G["PartyMemberFrame"..GetNumPartyMembers().."PetFrame"]:IsShown() ) then
			PartyMemberBackground:SetPoint("BOTTOMLEFT", "PartyMemberFrame"..GetNumPartyMembers(), "BOTTOMLEFT", -5, -21);
		else
			PartyMemberBackground:SetPoint("BOTTOMLEFT", "PartyMemberFrame"..GetNumPartyMembers(), "BOTTOMLEFT", -5, -5);
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
		SetDesaturation(_G[selfName.."Portrait"], 1);
		_G[selfName.."Disconnect"]:Show();
		_G[selfName.."PetFrame"]:Hide();
		return;
	else
		local selfName = self:GetName();
		SetDesaturation(_G[selfName.."Portrait"], nil);
		_G[selfName.."Disconnect"]:Hide();
	end
end
