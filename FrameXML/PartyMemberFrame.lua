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
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("PARTY_LEADER_CHANGED");
	this:RegisterEvent("PARTY_MEMBER_ENABLE");
	this:RegisterEvent("PARTY_MEMBER_DISABLE");
	this:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	this:RegisterEvent("UNIT_FACTION");
	this:RegisterEvent("UNIT_AURA");
	this:RegisterEvent("UNIT_PET");
	this:RegisterEvent("VARIABLES_LOADED");
end

function PartyMemberFrame_UpdateMember()
	if ( HIDE_PARTY_INTERFACE == "1" and GetNumRaidMembers() > 0 ) then
		return;
	end
	local id = this:GetID();
	if ( GetPartyMember(id) ) then
		UnitFrame_UpdateManaType();
		UnitFrame_Update();
		this:Show();
		
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
	PartyMemberFrame_UpdatePet();
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

function PartyMemberFrame_OnEvent(event)
	UnitFrame_OnEvent(event);

	if ( event == "PARTY_MEMBERS_CHANGED" ) then
		PartyMemberFrame_UpdateMember();
		return;
	end
	
	if ( event == "PARTY_LEADER_CHANGED" ) then
		PartyMemberFrame_UpdateLeader();
		return;
	end

	--if ( event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" ) then
	--	if ( arg1 == this:GetID() ) then
	--		UnitFrame_Update();
	--		PartyMemberFrame_RefreshBuffs();
	--	end
	--	return;
	--end

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

	if ( event == "UNIT_FACTION" ) then
		local unit = "party"..this:GetID();
		if ( arg1 == unit ) then
			PartyMemberFrame_UpdatePvPStatus();
		end
		return;
	end

	if ( event =="UNIT_AURA" ) then
		local unit = "party"..this:GetID();
		if ( arg1 == unit ) then
			RefreshBuffs(this, 0, unit);
			if ( PartyMemberBuffTooltip:IsVisible() ) then
				PartyMemberBuffTooltip_Update();
			end
		else
			unit = "partypet"..this:GetID();
			if ( arg1 == unit ) then
				PartyMemberFrame_RefreshPetBuffs();
			end
		end
		return;
	end

	if ( event =="UNIT_PET" ) then
		local unit = "party"..this:GetID();
		if ( arg1 == unit ) then
			PartyMemberFrame_UpdatePet();
		end
		return;
	end

	if ( event == "VARIABLES_LOADED" ) then
		PartyMemberFrame_UpdatePet();
	end
end

function PartyMemberFrame_OnUpdate(elapsed)
	PartyMemberFrame_UpdateMemberHealth(arg1);
	local partyStatus = getglobal(this:GetName().."Status");
	if ( this.hasDispellable ) then
		partyStatus:Show();
		partyStatus:SetAlpha(BUFF_ALPHA_VALUE);
		if ( this.debuffCountdown and this.debuffCountdown > 0 ) then
			this.debuffCountdown = this.debuffCountdown - elapsed;
		else
			partyStatus:Hide();
		end
	else
		partyStatus:Hide();
	end
end

function PartyMemberFrame_OnClick(partyFrame)
	if ( SpellIsTargeting() and arg1 == "RightButton" ) then
		SpellStopTargeting();
		return;
	end
	if ( not partyFrame ) then
		partyFrame = this;
	end
	local unit = "party"..partyFrame:GetID();
	if ( arg1 == "LeftButton" ) then
		if ( SpellIsTargeting() ) then
			SpellTargetUnit(unit);
		elseif ( CursorHasItem() ) then
			DropItemOnUnit(unit);
		else
			TargetUnit(unit);
		end
	else
		ToggleDropDownMenu(1, nil, getglobal("PartyMemberFrame"..partyFrame:GetID().."DropDown"), partyFrame:GetName(), 47, 15);
	end
end

function PartyMemberPetFrame_OnClick()
	if ( SpellIsTargeting() and arg1 == "RightButton" ) then
		SpellStopTargeting();
		return;
	end
	if ( arg1 == "LeftButton" ) then
		local unit = "partypet"..this:GetParent():GetID();
		if ( SpellIsTargeting() ) then
			SpellTargetUnit(unit);
		else
			TargetUnit(unit);
		end
	end
end

function PartyMemberFrame_RefreshPetBuffs(id)
	if ( not id ) then
		id = this:GetID();
	end
	RefreshBuffs(getglobal("PartyMemberFrame"..id.."PetFrame"), 0, "partypet"..id)
end

function PartyMemberBuffTooltip_Update(isPet)
	local buff;
	local numBuffs = 0;
	local numDebuffs = 0;
	local index = 1;
	for i=1, MAX_PARTY_TOOLTIP_BUFFS do
		if ( isPet ) then
			buff = UnitBuff("pet", i);		
		else
			buff = UnitBuff("party"..this:GetID(), i);
		end
		if ( buff ) then
			getglobal("PartyMemberBuffTooltipBuff"..index.."Icon"):SetTexture(buff);
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
		buff, debuffStack, debuffType = UnitDebuff("party"..this:GetID(), i);
		if ( isPet ) then
			buff, debuffStack, debuffType = UnitDebuff("pet", i);
		else
			buff, debuffStack, debuffType = UnitDebuff("party"..this:GetID(), i);
		end
		
		if ( buff ) then
			partyDebuff:SetTexture(buff);
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
	local unitMinHP, unitMaxHP, unitCurrHP;
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
	if ( SHOW_PARTY_BACKGROUND == "1" and GetNumPartyMembers() > 0 and HIDE_PARTY_INTERFACE ~= "1" ) then
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
	if ( OpacityFrame:IsVisible() ) then
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
