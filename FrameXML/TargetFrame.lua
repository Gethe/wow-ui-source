MAX_COMBO_POINTS = 5;
MAX_TARGET_DEBUFFS = 5;

UnitReactionColor = {
	{ r = 1.0, g = 0.0, b = 0.0 },
	{ r = 1.0, g = 0.0, b = 0.0 },
	{ r = 1.0, g = 0.5, b = 0.0 },
	{ r = 1.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
};

function TargetFrame_OnLoad()
	this.statusCounter = 0;
	this.statusSign = -1;
	this.unitHPPercent = 1;
	TargetFrame_Update();
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("UNIT_LEVEL");
	this:RegisterEvent("UNIT_FACTION");
	this:RegisterEvent("UNIT_DYNAMIC_FLAGS");
	this:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	this:RegisterEvent("PLAYER_PVPLEVEL_CHANGED");
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("PARTY_LEADER_CHANGED");
	this:RegisterEvent("PARTY_MEMBER_ENABLE");
	this:RegisterEvent("PARTY_MEMBER_DISABLE");
	this:RegisterEvent("UNIT_AURA");
	this:RegisterEvent("PLAYER_FLAGS_CHANGED");
end

function TargetFrame_Update()
	if ( UnitExists("target") ) then
		this:Show();
		UnitFrame_Update();
		UnitFrame_UpdateManaType();
		TargetFrame_CheckLevel();
		TargetFrame_CheckFaction();
		TargetFrame_CheckClassification();
		TargetFrame_CheckDead();
		if ( UnitIsPartyLeader("target") ) then
			TargetLeaderIcon:Show();
		else
			TargetLeaderIcon:Hide();
		end
		TargetDebuffButton_Update();
	else
		this:Hide();
	end
end

function TargetFrame_OnEvent(event)
	UnitFrame_OnEvent(event);

	if ( event == "UNIT_HEALTH" ) then
		if ( arg1 == "target" ) then
			TargetFrame_CheckDead();
		end
		return;
	end
	if ( event == "UNIT_LEVEL" ) then
		if ( arg1 == "target" ) then
			TargetFrame_CheckLevel();
		end
		return;
	end
	if ( event == "UNIT_FACTION" ) then
		if ( arg1 == "target" or arg1 == "player" ) then
			TargetFrame_CheckFaction();
			TargetFrame_CheckLevel();
		end
		return;
	end
	if ( event == "UNIT_DYNAMIC_FLAGS" ) then
		if ( arg1 == "target" ) then
			TargetFrame_CheckFaction();
		end
		return;
	end
	if ( event == "UNIT_CLASSIFICATION_CHANGED" ) then
		if ( arg1 == "target" ) then
			TargetFrame_CheckClassification();
		end
		return;
	end
	if ( event == "PLAYER_TARGET_CHANGED" or event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE") then
		TargetFrame_Update();
		if ( event == "PARTY_MEMBERS_CHANGED" ) then
			TargetFrame_CheckFaction();
		end
		return;
	end
	if ( event == "UNIT_AURA" and arg1 == "target" ) then
		TargetDebuffButton_Update();
		return;
	end
	if ( event == "PLAYER_FLAGS_CHANGED" ) then
		if ( arg1 == "target" ) then
			if ( UnitIsPartyLeader("target") ) then
				TargetLeaderIcon:Show();
			else
				TargetLeaderIcon:Hide();
			end
		end
		return;
	end
end

function TargetFrame_OnShow()
	if ( UnitIsEnemy("target", "player") ) then
		PlaySound("igCreatureAggroSelect");
	elseif ( UnitIsFriend("player", "target") ) then
		PlaySound("igCharacterNPCSelect");
	else
		PlaySound("igCreatureNeutralSelect");
	end
end

function TargetFrame_OnHide()
	PlaySound("INTERFACESOUND_LOSTTARGETUNIT");
	if ( UnitPopup.unit == "target" ) then
		UnitPopup:Hide();
	end
end

function TargetFrame_CheckLevel()
	local playerLevel = UnitLevel("player");
	local targetLevel = UnitLevel("target");
	if ( UnitIsPlusMob("target") ) then
	--	TargetLevelText:SetText(targetLevel.."+");
		TargetLevelText:SetText(targetLevel);
	elseif ( targetLevel == 0 ) then
		TargetLevelText:SetText("");
	else
		TargetLevelText:SetText(targetLevel);
	end
	-- Color level number
	local color = GetDifficultyColor(targetLevel);
	TargetLevelText:SetVertexColor(color.r, color.g, color.b);
	
	if ( UnitClassification("target") == "worldboss" ) then
		-- If unit is a world boss show skull regardless of level
		TargetLevelText:Hide();
		TargetHighLevelTexture:Show();
	elseif ( UnitIsEnemy("target", "player") ) then
		if ( playerLevel > (targetLevel - 10) ) then
			-- Normal level target
			TargetLevelText:Show();
			TargetHighLevelTexture:Hide();
		else
			-- High level target
			TargetLevelText:Hide();
			TargetHighLevelTexture:Show();
		end
	elseif ( UnitIsCorpse("target") ) then
		TargetLevelText:Hide();
		TargetHighLevelTexture:Show();
	else
		-- Normal level target
		TargetLevelText:Show();
		TargetHighLevelTexture:Hide();
	end
end

function TargetFrame_CheckFaction()
	if ( UnitPlayerControlled("target") ) then
		local r, g, b;
		if ( UnitCanAttack("target", "player") ) then
			-- Hostile players are red
			if ( not UnitCanAttack("player", "target") ) then
				r = 0.0;
				g = 0.0;
				b = 1.0;
			else
				r = UnitReactionColor[2].r;
				g = UnitReactionColor[2].g;
				b = UnitReactionColor[2].b;
			end
		elseif ( UnitCanAttack("player", "target") ) then
			-- Players we can attack but which are not hostile are yellow
			r = UnitReactionColor[4].r;
			g = UnitReactionColor[4].g;
			b = UnitReactionColor[4].b;
		elseif ( UnitIsPVP("target") ) then
			-- Players we can assist but are PvP flagged are green
			r = UnitReactionColor[6].r;
			g = UnitReactionColor[6].g;
			b = UnitReactionColor[6].b;
		else
			-- All other players are blue (the usual state on the "blue" server)
			r = 0.0;
			g = 0.0;
			b = 1.0;
		end
		TargetFrameNameBackground:SetVertexColor(r, g, b);
		TargetPortrait:SetVertexColor(1.0, 1.0, 1.0);
	elseif ( UnitIsTapped("target") and not UnitIsTappedByPlayer("target") ) then
		TargetFrameNameBackground:SetVertexColor(0.5, 0.5, 0.5);
		TargetPortrait:SetVertexColor(0.5, 0.5, 0.5);
	else
		local reaction = UnitReaction("target", "player");
		if ( reaction ) then
			local r, g, b;
			r = UnitReactionColor[reaction].r;
			g = UnitReactionColor[reaction].g;
			b = UnitReactionColor[reaction].b;
			TargetFrameNameBackground:SetVertexColor(r, g, b);
		else
			TargetFrameNameBackground:SetVertexColor(0, 0, 1.0);
		end
		TargetPortrait:SetVertexColor(1.0, 1.0, 1.0);
	end

	local factionGroup = UnitFactionGroup("target");
	if ( UnitIsPVPFreeForAll("target") ) then
		TargetPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		TargetPVPIcon:Show();
	elseif ( factionGroup and UnitIsPVP("target") ) then
		TargetPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		TargetPVPIcon:Show();
	else
		TargetPVPIcon:Hide();
	end
end

function TargetFrame_CheckClassification()
	local classification = UnitClassification("target");
	if ( classification == "worldboss" ) then
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite");
	elseif ( classification == "rareelite"  ) then
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite");
	elseif ( classification == "elite"  ) then
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite");
	elseif ( classification == "rare"  ) then
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare");
	else
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame");
	end
end

function TargetFrame_CheckDead()
	if ( (UnitHealth("target") <= 0) and UnitIsConnected("target") ) then
		TargetDeadText:Show();
	else
		TargetDeadText:Hide();
	end
end

function TargetFrame_OnClick(button)
	if ( SpellIsTargeting() and button == "RightButton" ) then
		SpellStopTargeting();
		return;
	end
	if ( button == "LeftButton" ) then
		if ( SpellIsTargeting() ) then
			SpellTargetUnit("target");
		elseif ( CursorHasItem() ) then
			DropItemOnUnit("target");
		end
	else
		local menu = nil;
		if ( UnitIsEnemy("target", "player") ) then
			return;
		end
		if ( UnitIsUnit("target", "player") ) then
			menu = "SELF";
		elseif ( UnitIsUnit("target", "pet") ) then
			if(PetCanBeAbandoned()) then
				if(PetCanBeRenamed()) then
					menu = "PET_RENAME";
				else
					menu = "PET";
				end
			else
				menu = "PET_NOABANDON";
			end
		elseif ( UnitIsPlayer("target") ) then
			if ( UnitInParty("target") ) then
				menu = "PARTY";
			else
				menu = "PLAYER";
			end
		end
		if ( menu ) then
			UnitPopup_ShowMenu(this, menu, "target");
			UnitPopup:ClearAllPoints();
			UnitPopup:SetPoint("TOPLEFT", this:GetName(), "BOTTOMRIGHT", 6, 6);
		end
	end
end

function TargetDebuffButton_Update()
	-- Position buffs depending on whether the targeted unit is friendly orno
	if ( UnitIsFriend("player", "target") ) then
		TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, 32);
		TargetFrameDebuff1:SetPoint("TOPLEFT", "TargetFrameBuff1", "BOTTOMLEFT", 0, -2);
	else
		TargetFrameDebuff1:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, 32);
		TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff1", "BOTTOMLEFT", 0, -2);
	end
	
	local debuff, debuffButton, buff, buffButton;
	local button;
	for i=1, MAX_TARGET_DEBUFFS do
		buff = UnitBuff("target", i);
		button = getglobal("TargetFrameBuff"..i);
		if ( buff ) then
			getglobal("TargetFrameBuff"..i.."Icon"):SetTexture(buff);
			button:Show();
			button.id = i;
		else
			button:Hide();
		end
	end
	for i=1, MAX_TARGET_DEBUFFS do
		debuff = UnitDebuff("target", i);
		button = getglobal("TargetFrameDebuff"..i);
		if ( debuff ) then
			getglobal("TargetFrameDebuff"..i.."Icon"):SetTexture(debuff);
			button:Show();
		else
			button:Hide();
		end
		button.id = i;
	end
end

function TargetFrame_HealthUpdate(elapsed)
	if ( UnitIsPlayer("target") ) then
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
			TargetPortrait:SetAlpha(alpha);
		end
	end
end

function TargetHealthCheck()
	if ( UnitIsPlayer("target") ) then
		local unitMinHP, unitMaxHP, unitCurrHP;
		unitHPMin, unitHPMax = this:GetMinMaxValues();
		unitCurrHP = this:GetValue();
		this:GetParent().unitHPPercent = unitCurrHP / unitHPMax;
		if ( UnitIsDead("target") ) then
			TargetPortrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
		elseif ( UnitIsGhost("target") ) then
			TargetPortrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
		elseif ( (this:GetParent().unitHPPercent > 0) and (this:GetParent().unitHPPercent <= 0.2) ) then
			TargetPortrait:SetVertexColor(1.0, 0.0, 0.0);
		else
			TargetPortrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		end
	else
		TargetFrame_CheckFaction();
	end
end
