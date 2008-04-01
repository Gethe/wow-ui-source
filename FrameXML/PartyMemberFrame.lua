MAX_PARTY_MEMBERS = 4;
PARTY_FRAME_SHOWN = 1;
MAX_PARTY_DEBUFFS = 4;
MAX_PARTY_TOOLTIP_BUFFS = 16;
MAX_PARTY_TOOLTIP_DEBUFFS = 8;

function HidePartyFrame()
	for i=1, MAX_PARTY_MEMBERS, 1 do
		getglobal("PartyMemberFrame"..i):Hide();
	end
	PARTY_FRAME_SHOWN = 0;
end

function ShowPartyFrame()
	for i=1, MAX_PARTY_MEMBERS, 1 do
		if ( GetPartyMember(i) ) then
			getglobal("PartyMemberFrame"..i):Show();
		end
	end
	PARTY_FRAME_SHOWN = 1;
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
	this:RegisterEvent("UNIT_PVP_UPDATE");
	this:RegisterEvent("UNIT_AURA");
end

function PartyMemberFrame_UpdateMember()
	local id = this:GetID();
	if ( GetPartyMember(id) ) then
		UnitFrame_UpdateManaType();
		UnitFrame_Update();
		if ( PARTY_FRAME_SHOWN == 1 ) then
			this:Show();
		end
		
		local lootMethod;
		local lootMaster;
		lootMethod, lootMaster = GetLootMethod();
		if ( id == lootMaster ) then
			getglobal(this:GetName().."MasterIcon"):Show();
		else
			getglobal(this:GetName().."MasterIcon"):Hide();
		end
	else
		this:Hide();
	end
	PartyMemberFrame_UpdatePvPStatus();
	PartyMemberFrame_RefreshBuffs();
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
	if( (GetPartyLeaderIndex() == id) and (PARTY_FRAME_SHOWN == 1) ) then
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

	if ( event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" ) then
		if ( arg1 == this:GetID() ) then
			UnitFrame_Update();
			PartyMemberFrame_RefreshBuffs();
		end
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

	if ( event == "UNIT_PVP_UPDATE" ) then
		local unit = "party"..this:GetID();
		if ( arg1 == unit ) then
			PartyMemberFrame_UpdatePvPStatus();
		end
		return;
	end

	if ( event =="UNIT_AURA" ) then
		local unit = "party"..this:GetID();
		if ( arg1 == unit ) then
			PartyMemberFrame_RefreshBuffs();
			if ( PartyMemberBuffTooltip:IsVisible() ) then
				PartyMemberBuffTooltip_Update();
			end
		end
		return;
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
		UnitPopup_ShowMenu(partyFrame, "PARTY", unit);
		UnitPopup:ClearAllPoints();
		UnitPopup:SetPoint("TOPLEFT", partyFrame:GetName(), "BOTTOMLEFT", 30, 24);
	end
end

function PartyMemberFrame_RefreshBuffs()
	local debuff, debuffButton;
	for i=1, MAX_PARTY_DEBUFFS do
		debuff = UnitDebuff("party"..this:GetID(), i);
		if ( debuff ) then
			getglobal(this:GetName().."Debuff"..i.."Icon"):SetTexture(debuff);
			getglobal(this:GetName().."Debuff"..i):Show();
		else
			getglobal(this:GetName().."Debuff"..i):Hide();
		end
	end
end

function PartyMemberBuffTooltip_Update(isPet)
	local buff, buffButton;
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
			getglobal("PartyMemberBuffTooltipBuff"..index.."Overlay"):Hide();
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
	for i=1, MAX_PARTY_TOOLTIP_DEBUFFS do
		if ( isPet ) then
			buff = UnitDebuff("pet", i);
		else
			buff = UnitDebuff("party"..this:GetID(), i);
		end
		
		if ( buff ) then
			getglobal("PartyMemberBuffTooltipDebuff"..index.."Icon"):SetTexture(buff);
			getglobal("PartyMemberBuffTooltipDebuff"..index.."Overlay"):Show();
			getglobal("PartyMemberBuffTooltipDebuff"..index):Show();
			index = index + 1;
			numDebuffs = numDebuffs + 1;
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
