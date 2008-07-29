MAX_PARTY_MEMBERS = 4;
MAX_PARTY_DEBUFFS = 4;
MAX_PARTY_TOOLTIP_BUFFS = 16;
MAX_PARTY_TOOLTIP_DEBUFFS = 8;

function HidePartyFrame()
	for i=1, MAX_PARTY_MEMBERS, 1 do
		getglobal("PartyMemberFrame"..i):Hide();
	end
end

function ShowPartyFrame()
	for i=1, MAX_PARTY_MEMBERS, 1 do
		if ( GetPartyMember(i) ) then
			getglobal("PartyMemberFrame"..i):Show();
		end
	end
end

function PartyMemberFrame_OnLoad()
	this.statusCounter = 0;
	this.statusSign = -1;
	this.unitHPPercent = 1;
	PartyMemberFrame_UpdateMember();
	PartyMemberFrame_UpdateLeader();
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("PARTY_LEADER_CHANGED");
	this:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	this:RegisterEvent("MUTELIST_UPDATE");
	this:RegisterEvent("IGNORELIST_UPDATE");
	this:RegisterEvent("UNIT_FACTION");
	this:RegisterEvent("UNIT_AURA");
	this:RegisterEvent("UNIT_PET");
	this:RegisterEvent("VOICE_START");
	this:RegisterEvent("VOICE_STOP");
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("VOICE_STATUS_UPDATE");
	this:RegisterEvent("READY_CHECK");
	this:RegisterEvent("READY_CHECK_CONFIRM");
	this:RegisterEvent("READY_CHECK_FINISHED");

	local showmenu = function()
		ToggleDropDownMenu(1, nil, getglobal("PartyMemberFrame"..this:GetID().."DropDown"), this:GetName(), 47, 15);
	end
	SecureUnitButton_OnLoad(this, "party"..this:GetID(), showmenu);
end

function PartyMemberFrame_UpdateMember()
	if ( HIDE_PARTY_INTERFACE == "1" and GetNumRaidMembers() > 0 ) then
		this:Hide();
		return;
	end
	local id = this:GetID();
	if ( GetPartyMember(id) ) then
		this:Show();

		UnitFrame_UpdateManaType();
		UnitFrame_Update();

		local masterIcon = getglobal(this:GetName().."MasterIcon");
		local lootMethod;
		local lootMaster;
		lootMethod, lootMaster = GetLootMethod();
		if ( id == lootMaster ) then
			masterIcon:Show();
		else
			masterIcon:Hide();
		end
	else
		this:Hide();
	end
	PartyMemberFrame_UpdatePvPStatus();
	RefreshBuffs(this, 0, "party"..id);
	PartyMemberFrame_UpdateVoiceStatus();
	PartyMemberFrame_UpdatePet();
	PartyMemberFrame_UpdateReadyCheck();
	UpdatePartyMemberBackground();
end

function PartyMemberFrame_UpdatePet(id)
	if ( not id ) then
		id = this:GetID();
	end
	
	local frameName = "PartyMemberFrame"..id;
	local petFrame = getglobal("PartyMemberFrame"..id.."PetFrame");
	
	if ( UnitIsConnected("party"..id) and UnitExists("partypet"..id) and SHOW_PARTY_PETS == "1" ) then
		petFrame:Show();
		petFrame:SetPoint("TOPLEFT", frameName, "TOPLEFT", 23, -43);
	else
		petFrame:Hide();
		petFrame:SetPoint("TOPLEFT", frameName, "TOPLEFT", 23, -27);
	end
	PartyMemberFrame_RefreshPetBuffs(id);
	UpdatePartyMemberBackground();
end

function PartyMemberFrame_UpdateMemberHealth(elapsed)
	if ( (this.unitHPPercent > 0) and (this.unitHPPercent <= 0.2) ) then
		local alpha = 255;
		local counter = this.statusCounter + elapsed;
		local sign    = this.statusSign;

		if ( counter > 0.5 ) then
			sign = -sign;
			this.statusSign = sign;
		end
		counter = mod(counter, 0.5);
		this.statusCounter = counter;

		if ( sign == 1 ) then
			alpha = (127  + (counter * 256)) / 255;
		else
			alpha = (255 - (counter * 256)) / 255;
		end
		getglobal(this:GetName().."Portrait"):SetAlpha(alpha);
	end
end

function PartyMemberFrame_UpdateLeader()
	local id = this:GetID();
	local icon = getglobal("PartyMemberFrame"..id.."LeaderIcon");
	if( GetPartyLeaderIndex() == id ) then
		icon:Show();
	else
		icon:Hide();
	end
end

function PartyMemberFrame_UpdatePvPStatus()
	local id = this:GetID();
	local unit = "party"..id;
	local icon = getglobal("PartyMemberFrame"..id.."PVPIcon");
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

function PartyMemberFrame_UpdateVoiceStatus()
	local id = this:GetID();
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
	local statusIcon = getglobal("PartyMemberFrame"..id.."Speaker");
	local muted = GetMuteStatus("party"..id, mode);
	local mutedIcon = getglobal("PartyMemberFrame"..id.."SpeakerMuted");

	getglobal("PartyMemberFrame"..id.."SpeakerOn"):SetVertexColor(0.7, 0.7, 0.7);
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
	local speaker = getglobal("PartyMemberFrame"..id.."SpeakerFrame");
	local state = UnitIsTalking(UnitName("party"..id));
	if ( state ) then
		VoiceChat_Animate(speaker, 1);
		speaker:Show();
	else
		VoiceChat_Animate(speaker, nil);
		speaker:Hide();
	end
end

function PartyMemberFrame_UpdateReadyCheck()
	local id = this:GetID();
	local partyID = "party"..id;

	local readyCheckFrame = getglobal("PartyMemberFrame"..id.."ReadyCheck");
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

function PartyMemberFrame_OnEvent(event)
	UnitFrame_OnEvent(event);
 
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( GetPartyMember(this:GetID()) ) then
			PartyMemberFrame_UpdateMember();
			return;
		end
	end

	if ( event == "PARTY_MEMBERS_CHANGED" ) then
		PartyMemberFrame_UpdateMember();
		return;
	end
	
	if ( event == "PARTY_LEADER_CHANGED" ) then
		PartyMemberFrame_UpdateLeader();
		return;
	end

	if ( event == "PARTY_LOOT_METHOD_CHANGED" ) then
		local lootMethod;
		local lootMaster;
		lootMethod, lootMaster = GetLootMethod();
		if ( this:GetID() == lootMaster ) then
			getglobal(this:GetName().."MasterIcon"):Show();
		else
			getglobal(this:GetName().."MasterIcon"):Hide();
		end
		return;
	end

	if ( event == "MUTELIST_UPDATE" or event == "IGNORELIST_UPDATE" ) then
		PartyMemberFrame_UpdateVoiceStatus();
	end

	local unit = "party"..this:GetID();
	local unitPet = "partypet"..this:GetID();

	if ( event == "UNIT_FACTION" ) then
		if ( arg1 == unit ) then
			PartyMemberFrame_UpdatePvPStatus();
		end
		return;
	end

	if ( event =="UNIT_AURA" ) then
		if ( arg1 == unit ) then
			RefreshBuffs(this, 0, unit);
			if ( PartyMemberBuffTooltip:IsShown() and
			     this:GetID() == PartyMemberBuffTooltip:GetID() ) then
				PartyMemberBuffTooltip_Update(this:GetID());
			end
		else
			if ( arg1 == unitPet ) then
				PartyMemberFrame_RefreshPetBuffs();
			end
		end
		return;
	end

	if ( event =="UNIT_PET" ) then
		if ( arg1 == unit ) then
			PartyMemberFrame_UpdatePet();
		end
		return;
	end

	if ( event == "READY_CHECK" or
		 event == "READY_CHECK_CONFIRM" ) then
		PartyMemberFrame_UpdateReadyCheck();
		return;
	elseif ( event == "READY_CHECK_FINISHED" ) then
		if (GetPartyMember(this:GetID())) then
			ReadyCheck_Finish(getglobal("PartyMemberFrame"..this:GetID().."ReadyCheck"));
		end
		return;
	end

	local speaker = getglobal(this:GetName().."SpeakerFrame");
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
	end
	if ( event == "VARIABLES_LOADED" ) then
		PartyMemberFrame_UpdatePet();
		PartyMemberFrame_UpdateVoiceStatus();
	end
	if ( event == "VOICE_STATUS_UPDATE" ) then
		PartyMemberFrame_UpdateVoiceStatus();
	end
end

function PartyMemberFrame_OnUpdate(elapsed)
	PartyMemberFrame_UpdateMemberHealth(arg1);
	local partyStatus = getglobal(this:GetName().."Status");
	if ( this.hasDispellable ) then
		partyStatus:Show();
		partyStatus:SetAlpha(BuffFrame.BuffAlphaValue);
		if ( this.debuffCountdown and this.debuffCountdown > 0 ) then
			this.debuffCountdown = this.debuffCountdown - elapsed;
		else
			partyStatus:Hide();
		end
	else
		partyStatus:Hide();
	end
end

function PartyMemberFrame_RefreshPetBuffs(id)
	if ( not id ) then
		id = this:GetID();
	end
	RefreshBuffs(getglobal("PartyMemberFrame"..id.."PetFrame"), 0, "partypet"..id)
end

function PartyMemberBuffTooltip_Update(id, isPet)
	local name, rank, icon;
	local numBuffs = 0;
	local numDebuffs = 0;
	local index = 1;
	
	PartyMemberBuffTooltip:SetID(id);
	
	for i=1, MAX_PARTY_TOOLTIP_BUFFS do
		if ( isPet ) then
			name, rank, icon = UnitBuff("pet", i);		
		else
			name, rank, icon = UnitBuff("party"..this:GetID(), i);
		end
		if ( icon ) then
			getglobal("PartyMemberBuffTooltipBuff"..index.."Icon"):SetTexture(icon);
			getglobal("PartyMemberBuffTooltipBuff"..index.."Border"):Hide();
			getglobal("PartyMemberBuffTooltipBuff"..index):Show();
			index = index + 1;
			numBuffs = numBuffs + 1;
		end
	end
	for i=index, MAX_PARTY_TOOLTIP_BUFFS do
		getglobal("PartyMemberBuffTooltipBuff"..i):Hide();
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
		local debuffBorder = getglobal("PartyMemberBuffTooltipDebuff"..index.."Border")
		local partyDebuff = getglobal("PartyMemberBuffTooltipDebuff"..index.."Icon");
		if ( isPet ) then
			name, rank, icon, debuffStack, debuffType = UnitDebuff("pet", i);
		else
			name, rank, icon, debuffStack, debuffType = UnitDebuff("party"..this:GetID(), i);
		end
		
		if ( icon ) then
			partyDebuff:SetTexture(icon);
			if ( debuffType ) then
				color = DebuffTypeColor[debuffType];
			else
				color = DebuffTypeColor["none"];
			end
			debuffBorder:SetVertexColor(color.r, color.g, color.b);
			getglobal("PartyMemberBuffTooltipDebuff"..index):Show();
			numDebuffs = numDebuffs + 1;
			index = index + 1;
		end
	end
	for i=index, MAX_PARTY_TOOLTIP_DEBUFFS do
		getglobal("PartyMemberBuffTooltipDebuff"..i):Hide();
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

function PartyMemberHealthCheck()
	local prefix = this:GetParent():GetName();
	local unitHPMin, unitHPMax, unitCurrHP;
	unitHPMin, unitHPMax = this:GetMinMaxValues();
	-- Handle disconnected state
	if ( not UnitIsConnected("party"..this:GetParent():GetID()) ) then
		this:SetValue(unitHPMax);
		this:SetStatusBarColor(0.5, 0.5, 0.5);
		SetDesaturation(getglobal(this:GetParent():GetName().."Portrait"), 1);
		getglobal(this:GetParent():GetName().."Disconnect"):Show();
		getglobal(this:GetParent():GetName().."PetFrame"):Hide();
		return;
	else
		SetDesaturation(getglobal(this:GetParent():GetName().."Portrait"), nil);
		getglobal(this:GetParent():GetName().."Disconnect"):Hide();
	end
	
	unitCurrHP = this:GetValue();
	if ( unitHPMax > 0 ) then
		this:GetParent().unitHPPercent = unitCurrHP / unitHPMax;
	else
		this:GetParent().unitHPPercent = 0;
	end
	if ( UnitIsDead("party"..this:GetParent():GetID()) ) then
		getglobal(prefix.."Portrait"):SetVertexColor(0.35, 0.35, 0.35, 1.0);
	elseif ( UnitIsGhost("party"..this:GetParent():GetID()) ) then
		getglobal(prefix.."Portrait"):SetVertexColor(0.2, 0.2, 0.75, 1.0);
	elseif ( (this:GetParent().unitHPPercent > 0) and (this:GetParent().unitHPPercent <= 0.2) ) then
		getglobal(prefix.."Portrait"):SetVertexColor(1.0, 0.0, 0.0);
	else
		getglobal(prefix.."Portrait"):SetVertexColor(1.0, 1.0, 1.0, 1.0);
	end
end

function PartyFrameDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, PartyFrameDropDown_Initialize, "MENU");
end

function PartyFrameDropDown_Initialize()
	local dropdown;
	if ( UIDROPDOWNMENU_OPEN_MENU ) then
		dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU);
	else
		dropdown = this;
	end
	UnitPopup_ShowMenu(dropdown, "PARTY", "party"..dropdown:GetParent():GetID());
end

function UpdatePartyMemberBackground()
	if ( not PartyMemberBackground ) then
		return;
	end
	if ( SHOW_PARTY_BACKGROUND == "1" and GetNumPartyMembers() > 0 and not(HIDE_PARTY_INTERFACE == "1" and (GetNumRaidMembers() > 0)) ) then
		if ( getglobal("PartyMemberFrame"..GetNumPartyMembers().."PetFrame"):IsShown() ) then
			PartyMemberBackground:SetPoint("BOTTOMLEFT", "PartyMemberFrame"..GetNumPartyMembers(), "BOTTOMLEFT", -5, -21);
		else
			PartyMemberBackground:SetPoint("BOTTOMLEFT", "PartyMemberFrame"..GetNumPartyMembers(), "BOTTOMLEFT", -5, -5);
		end
		PartyMemberBackground:Show();
	else
		PartyMemberBackground:Hide();
	end
end

function PartyMemberBackground_ToggleOpacity()
	if ( OpacityFrame:IsShown() ) then
		OpacityFrame:Hide();
		return;
	end
	OpacityFrame:ClearAllPoints();
	OpacityFrame:SetPoint("TOPLEFT", "PartyMemberBackground", "TOPRIGHT", 0, 7);
	OpacityFrame.opacityFunc = PartyMemberBackground_SetOpacity;
	OpacityFrame.saveOpacityFunc = PartyMemberBackground_SaveOpacity;
	OpacityFrame:Show();
end

function PartyMemberBackground_SetOpacity()
	local alpha = 1.0 - OpacityFrameSlider:GetValue();
	PartyMemberBackground:SetAlpha(alpha);
end

function PartyMemberBackground_SaveOpacity()
	PARTYBACKGROUND_OPACITY = OpacityFrameSlider:GetValue();
end

function PartyMemberFrame_UpdateStatusBarText()
	local lockText = nil;
	if ( SHOW_PARTY_TEXT == "1" ) then
		lockText = 1;	
	end
	for i=1, MAX_PARTY_MEMBERS do
		getglobal("PartyMemberFrame"..i.."HealthBar").forceShow = lockText;
		getglobal("PartyMemberFrame"..i.."ManaBar").forceShow = lockText;
		if ( lockText ) then
			getglobal("PartyMemberFrame"..i.."HealthBarText"):Show();
			getglobal("PartyMemberFrame"..i.."ManaBarText"):Show();
		end
	end
end
