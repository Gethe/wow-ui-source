MAX_ARENA_ENEMIES = 5;

function ArenaEnemyFrames_OnLoad(self)
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	ArenaEnemyFrames_CheckEffectiveEnableState(self);
	local showCastbars = GetCVarBool("showArenaEnemyCastbar");
	local castFrame;
	for i = 1, MAX_ARENA_ENEMIES do
		castFrame = _G["ArenaEnemyFrame"..i.."CastingBar"];
		castFrame:SetPoint("RIGHT", _G["ArenaEnemyFrame"..i], "LEFT", -32, -3);
		castFrame.showCastbar = showCastbars;
		CastingBarFrame_UpdateIsShown(castFrame);
	end
	
	UpdateArenaEnemyBackground(GetCVarBool("showPartyBackground"));
	ArenaEnemyBackground_SetOpacity(tonumber(GetCVar("partyBackgroundOpacity")));
	ArenaEnemyFrames_UpdateVisible();
	ArenaEnemyFrames_ResetCrowdControlCooldownData();
end

function ArenaEnemyFrames_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( (event == "CVAR_UPDATE") and (arg1 == "SHOW_ARENA_ENEMY_FRAMES_TEXT") ) then
		ArenaEnemyFrames_CheckEffectiveEnableState(self, arg2 == "1");
	elseif ( event == "VARIABLES_LOADED" ) then
		ArenaEnemyFrames_CheckEffectiveEnableState(self);
		local showCastbars = GetCVarBool("showArenaEnemyCastbar");
		local castFrame;
		for i = 1, MAX_ARENA_ENEMIES do
			castFrame = _G["ArenaEnemyFrame"..i.."CastingBar"];
			castFrame.showCastbar = showCastbars;
			CastingBarFrame_UpdateIsShown(castFrame);
		end
		for i=1, MAX_ARENA_ENEMIES do
			ArenaEnemyFrame_UpdatePet(_G["ArenaEnemyFrame"..i], i, true);
		end
		UpdateArenaEnemyBackground(GetCVarBool("showPartyBackground"));
		ArenaEnemyBackground_SetOpacity(tonumber(GetCVar("partyBackgroundOpacity")));
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		ArenaEnemyFrames_CheckEffectiveEnableState(self);
		ArenaEnemyFrames_UpdateVisible();
		ArenaEnemyFrames_ResetCrowdControlCooldownData();
	end
end

function ArenaEnemyFrames_ResetCrowdControlCooldownData()
	for i=1, MAX_ARENA_ENEMIES do
		local frame = _G["ArenaEnemyFrame"..i];
		frame.CC.spellID = nil;
		frame.CC.Icon:SetTexture(nil);
		frame.CC.Cooldown:Clear();
		ArenaEnemyFrame_UpdateCrowdControl(frame);
	end
end

function ArenaEnemyFrames_OnShow(self)
	DurabilityFrame:SetAlerts();
	UIParent_ManageFramePositions();
end

function ArenaEnemyFrames_OnHide(self)	
	DurabilityFrame:SetAlerts();
	UIParent_ManageFramePositions();
end

function ArenaEnemyFrames_CheckEffectiveEnableState(self, cvarUpdate)
	if (C_PvP.IsInBrawl()) then
		ArenaEnemyFrames_Disable(self);
	else
		if ( GetCVarBool("showArenaEnemyFrames") or cvarUpdate ) then
			ArenaEnemyFrames_Enable(self);
		else
			ArenaEnemyFrames_Disable(self);
		end
	end
end

function ArenaEnemyFrames_Enable(self)
	self.show = true;
	ArenaEnemyFrames_UpdateVisible();
end

function ArenaEnemyFrames_Disable(self)
	self.show = false;
	ArenaEnemyFrames_UpdateVisible();
end

function ArenaEnemyFrames_UpdateVisible()
	local _, instanceType = IsInInstance();
	if ( ArenaEnemyFrames.show and ((instanceType == "arena") or (GetNumArenaOpponents() > 0))) then
		ArenaEnemyFrames:Show();
	else
		ArenaEnemyFrames:Hide();
	end
end

function ArenaEnemyFrame_OnLoad(self)
	local id = self:GetID();
	self.debuffCountdown = 0; 
	self.numDebuffs = 0;
	self.noTextPrefix = 1;
	local prefix = "ArenaEnemyFrame"..id;
	UnitFrame_Initialize(self, "arena"..id,  _G[prefix.."Name"], nil,
			_G[prefix.."HealthBar"], _G[prefix.."HealthBarText"], 
			_G[prefix.."ManaBar"], _G[prefix.."ManaBarText"], nil, nil, nil,
			_G[prefix.."MyHealPredictionBar"], _G[prefix.."OtherHealPredictionBar"],
			_G[prefix.."TotalAbsorbBar"], _G[prefix.."TotalAbsorbBarOverlay"], _G[prefix.."OverAbsorbGlow"],
			_G[prefix.."OverHealAbsorbGlow"], _G[prefix.."HealAbsorbBar"], _G[prefix.."HealAbsorbBarLeftShadow"],
			_G[prefix.."HealAbsorbBarRightShadow"]);
	SetTextStatusBarTextZeroText(_G[prefix.."HealthBar"], DEAD);

	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;
	
	self.classPortrait = _G[self:GetName().."ClassPortrait"];
	self.specPortrait = _G[self:GetName().."SpecPortrait"];
	self.specBorder = _G[self:GetName().."SpecBorder"];
	self.castBar = _G[self:GetName().."CastingBar"];

	ArenaEnemyFrame_UpdatePlayer(self, true);
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("ARENA_OPPONENT_UPDATE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("ARENA_COOLDOWNS_UPDATE");
	self:RegisterEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE");
	
	UIDropDownMenu_Initialize(self.DropDown, ArenaEnemyDropDown_Initialize, "MENU");
	
	local setfocus = function()
		FocusUnit("arena"..self:GetID());
	end
	SecureUnitButton_OnLoad(self, "arena"..self:GetID(), setfocus);
	
	local id = self:GetID();
	if ( UnitClass("arena"..id) and (not UnitExists("arena"..id))) then	--It is possible for the unit itself to no longer exist on the client, but some of the information to remain (after reloading the UI)
		self:Show();
		ArenaEnemyFrame_Lock(self);
	elseif ( UnitExists("arenapet"..id) and ( not UnitClass("arena"..id) ) ) then	--We use UnitClass because even if the unit doesn't exist on the client, we may still have enough info to populate the frame.
		ArenaEnemyFrame_SetMysteryPlayer(self);
	end
end

function ArenaEnemyFrame_UpdatePlayer(self, useCVars)--At some points, we need to use CVars instead of UVars even though UVars are faster.
	local id = self:GetID();
	if ( UnitGUID(self.unit) ) then	--Use UnitGUID instead of UnitExists in case the unit is a remote update.
		self:Show();
		_G["ArenaPrepFrame"..id]:Hide();
		UnitFrame_Update(self);
	end
		
	local _, class = UnitClass(self.unit);
	if( class ) then
		self.classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
		self.classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
	end
	local specID = GetArenaOpponentSpec(id);
	if (specID and specID > 0) then 
		local _, _, _, specIcon = GetSpecializationInfoByID(specID);
		self.specBorder:Show();
		SetPortraitToTexture(self.specPortrait, specIcon);
	else
		self.specPortrait:SetTexture(nil);
		self.specBorder:Hide();
	end
	
	-- When not in an arena, show their faction icon (these are really flag carriers, not arena opponents)
	local _, instanceType = IsInInstance();
	local factionGroup, factionName = UnitFactionGroup(self.unit);
	local pvpIcon = _G[self:GetName() .. "PVPIcon"];
	if ( factionGroup and factionGroup ~= "Neutral" and instanceType ~= "arena" ) then
		pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		pvpIcon:Show();
		self:SetPoint("RIGHT", self:GetParent(), "RIGHT", -18, 0);
	else
		pvpIcon:Hide();
		self:SetPoint("RIGHT", self:GetParent(), "RIGHT", -2, 0);
	end

	CastingBarFrame_SetUnit(self.castBar, self.unit, false, true);
	
	ArenaEnemyFrames_UpdateVisible();
end

function ArenaEnemyFrame_Lock(self)
	self.healthbar:SetStatusBarColor(0.5, 0.5, 0.5);
	self.healthbar.lockColor = true;
	self.manabar:SetStatusBarColor(0.5, 0.5, 0.5);
	self.manabar.lockColor = true;
	self.hideStatusOnTooltip = true;
end

function ArenaEnemyFrame_Unlock(self)
	self.healthbar.lockColor = false;
	self.healthbar.forceHideText = false;
	self.manabar.lockColor = false;
	self.manabar.forceHideText = false;
	self.hideStatusOnTooltip = false;
end

function ArenaEnemyFrame_SetMysteryPlayer(self)
	self.healthbar:SetMinMaxValues(0,100);
	self.healthbar:SetValue(100);
	self.healthbar.forceHideText = true;
	self.manabar:SetMinMaxValues(0,100);
	self.manabar:SetValue(100);
	self.manabar.forceHideText = true;
	self.classPortrait:SetTexture("Interface\\CharacterFrame\\TempPortrait");
	self.classPortrait:SetTexCoord(0, 1, 0, 1);
	self.name:SetText("");
	ArenaEnemyFrame_Lock(self);
	self:Show();
end

function ArenaEnemyFrame_OnEvent(self, event, unit, ...)
	if ( unit == self.unit ) then
		if ( event == "ARENA_OPPONENT_UPDATE" ) then
			local unitEvent = ...;
			if ( unitEvent == "seen" or unitEvent == "destroyed") then
				ArenaEnemyFrame_Unlock(self);
				ArenaEnemyFrame_UpdatePlayer(self);
				
				if ( self.healthbar.frequentUpdates and GetCVarBool("predictedHealth") ) then
					self.healthbar:SetScript("OnUpdate", UnitFrameHealthBar_OnUpdate);
					self.healthbar:UnregisterEvent("UNIT_HEALTH");
				end
				if ( self.manabar.frequentUpdates ) then
					self.manabar:SetScript("OnUpdate", UnitFrameManaBar_OnUpdate);
					UnitFrameManaBar_UnregisterDefaultEvents(self.manabar);
				end
				ArenaEnemyFrame_UpdatePet(self);
				UpdateArenaEnemyBackground();
				UIParent_ManageFramePositions();
			elseif ( unitEvent == "unseen" ) then
				ArenaEnemyFrame_Lock(self);
				
				self.healthbar:RegisterEvent("UNIT_HEALTH");
				self.healthbar:SetScript("OnUpdate", nil);
				UnitFrameManaBar_RegisterDefaultEvents(self.manabar);
				self.manabar:SetScript("OnUpdate", nil);
			elseif ( unitEvent == "cleared" ) then
				ArenaEnemyFrame_Unlock(self);
				self:Hide();
				ArenaEnemyFrames_UpdateVisible();
				local _, instanceType = IsInInstance();
				if (instanceType ~= "arena") then
					ArenaPrepFrames:Hide()
				end
			end
		elseif ( event == "UNIT_PET" ) then
			ArenaEnemyFrame_UpdatePet(self);
		elseif ( event == "UNIT_NAME_UPDATE" ) then
			ArenaEnemyFrame_UpdatePlayer(self);
		elseif ( event == "UNIT_MAXHEALTH" or event == "UNIT_HEAL_PREDICTION" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" ) then
			UnitFrameHealPredictionBars_Update(self);
		elseif ( event == "ARENA_COOLDOWNS_UPDATE" ) then
			ArenaEnemyFrame_UpdateCrowdControl(self);
		elseif ( event == "ARENA_CROWD_CONTROL_SPELL_UPDATE" ) then
			local spellID = ...;
			if (spellID ~= self.CC.spellID) then
				local spellTexture, spellTextureNoOverride = GetSpellTexture(spellID);
				self.CC.spellID = spellID;
				self.CC.Icon:SetTexture(spellTextureNoOverride);
			end
		end
	end
end

function ArenaEnemyFrame_UpdateCrowdControl(self)
	local spellID, startTime, duration = C_PvP.GetArenaCrowdControlInfo(self.unit);
	if (spellID) then
		if (spellID ~= self.CC.spellID) then
			local spellTexture, spellTextureNoOverride = GetSpellTexture(spellID);
			self.CC.spellID = spellID;
			self.CC.Icon:SetTexture(spellTextureNoOverride);
		end
		if (startTime ~= 0 and duration ~= 0) then
			self.CC.Cooldown:SetCooldown(startTime/1000.0, duration/1000.0);
		else
			self.CC.Cooldown:Clear();
		end
	end
end

function ArenaEnemyFrame_OnShow(self)
	self:SetFrameLevel(2);

	C_PvP.RequestCrowdControlSpell(self.unit);
end

function ArenaEnemyFrames_GetBestAnchorUnitFrameForOppponent(opponentNumber)
	return _G["ArenaEnemyFrame" .. math.min(opponentNumber, MAX_ARENA_ENEMIES)];
end

function ArenaEnemyFrame_UpdatePet(self, id, useCVars)	--At some points, we need to use CVars instead of UVars even though UVars are faster.
	if ( not id ) then
		id = self:GetID();
	end
	
	local unitFrame = _G["ArenaEnemyFrame"..id];
	local petFrame = _G["ArenaEnemyFrame"..id.."PetFrame"];
	
	local showArenaEnemyPets = (SHOW_ARENA_ENEMY_PETS == "1");
	if ( useCVars ) then
		showArenaEnemyPets = GetCVarBool("showArenaEnemyPets");
	end
	
	if ( UnitGUID(petFrame.unit) and showArenaEnemyPets) then
		petFrame:Show();
	else
		petFrame:Hide();
	end
	
	UnitFrame_Update(petFrame);
end

function ArenaEnemyPetFrame_OnLoad(self)
	local id = self:GetParent():GetID();
	local prefix = "ArenaEnemyFrame"..id.."PetFrame";
	local unit = "arenapet"..id;
	UnitFrame_Initialize(self, unit,  _G[prefix.."Name"], _G[prefix.."Portrait"],
		   _G[prefix.."HealthBar"], _G[prefix.."HealthBarText"], _G[prefix.."ManaBar"], _G[prefix.."ManaBarText"]);
	SetTextStatusBarTextZeroText(_G[prefix.."HealthBar"], DEAD);
	_G[prefix.."Name"]:Hide();
	SecureUnitButton_OnLoad(self, unit);
	self:SetID(id);
	self:SetParent(ArenaEnemyFrames);
	ArenaEnemyFrame_UpdatePet(self, id, true);
	self:RegisterEvent("ARENA_OPPONENT_UPDATE");
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	
	UIDropDownMenu_Initialize(self.DropDown, ArenaEnemyPetDropDown_Initialize, "MENU");
	
	local setfocus = function()
		FocusUnit("arenapet"..self:GetID());
	end
	SecureUnitButton_OnLoad(self, "arenapet"..self:GetID(), setfocus);
end

function ArenaEnemyPetFrame_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "ARENA_OPPONENT_UPDATE" and arg1 == self.unit ) then
		if ( arg2 == "seen" or arg2 == "destroyed") then
			ArenaEnemyFrame_Unlock(self);
			ArenaEnemyFrame_UpdatePet(self);
			UpdateArenaEnemyBackground();
			local ownerFrame = _G["ArenaEnemyFrame"..self:GetID()];
			if ( not ownerFrame:IsShown() ) then
				ArenaEnemyFrame_SetMysteryPlayer(ownerFrame);
				ownerFrame:Show();
			end
			if ( self.healthbar.frequentUpdates and GetCVarBool("predictedHealth") ) then
				self.healthbar:SetScript("OnUpdate", UnitFrameHealthBar_OnUpdate);
				self.healthbar:UnregisterEvent("UNIT_HEALTH");
			end
			if ( self.manabar.frequentUpdates ) then
				self.manabar:SetScript("OnUpdate", UnitFrameManaBar_OnUpdate);
				UnitFrameManaBar_UnregisterDefaultEvents(self.manabar);
			end
		elseif ( arg2 == "unseen" ) then
			ArenaEnemyFrame_Lock(self);
			self.healthbar:RegisterEvent("UNIT_HEALTH");
			self.healthbar:SetScript("OnUpdate", nil);
			UnitFrameManaBar_RegisterDefaultEvents(self.manabar);
			self.manabar:SetScript("OnUpdate", nil);
		elseif ( arg2 == "cleared" ) then
			ArenaEnemyFrame_Unlock(self);
			self:Hide()
		end
	elseif ( event == "UNIT_CLASSIFICATION_CHANGED" and arg1 == self.unit ) then
		UnitFrame_Update(self);
	end
	UnitFrame_OnEvent(self, event, ...);
end

function ArenaEnemyDropDown_Initialize(self)
	UnitPopup_ShowMenu(self, "ARENAENEMY", "arena"..self:GetParent():GetID());
end

function ArenaEnemyPetDropDown_Initialize(self)
	UnitPopup_ShowMenu(self, "ARENAENEMY", "arenapet"..self:GetParent():GetID());
end

function UpdateArenaEnemyBackground(force)
	if ( (SHOW_PARTY_BACKGROUND == "1") or force ) then
		ArenaEnemyBackground:Show();
		local numOpps = min(GetNumArenaOpponents(), MAX_ARENA_ENEMIES);
		if ( numOpps > 0 ) then
			ArenaEnemyBackground:SetPoint("BOTTOMLEFT", "ArenaEnemyFrame"..numOpps.."PetFrame", "BOTTOMLEFT", -15, -10);
		else
			ArenaEnemyBackground:Hide();
		end
	else
		ArenaEnemyBackground:Hide();
	end
	
end

function ArenaEnemyBackground_SetOpacity(opacity)
	local alpha;
	if ( not opacity ) then
		alpha = 1.0 - OpacityFrameSlider:GetValue();
	else
		alpha = 1.0 - opacity;
	end
	ArenaEnemyBackground:SetAlpha(alpha);
end

-----------------------------------------------------------------------------
--Arena preparation stuff, shows class and spec of opponents during countdown
------------------------------------------------------------------------------


function ArenaPrepFrames_OnLoad(self)
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS");
	local numOpps = GetNumArenaOpponentSpecs();
	if (numOpps and numOpps > 0) then
		ArenaPrepFrames_OnEvent(self, "ARENA_PREP_OPPONENT_SPECIALIZATIONS");
	end
end

function ArenaPrepFrames_OnEvent(self, event, ...) --also called in OnLoad
	if (event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS") then
		ArenaPrepFrames_UpdateFrames();
		self:Show()
	end
end

function ArenaPrepFrames_OnShow(self)
	DurabilityFrame:SetAlerts();
	UIParent_ManageFramePositions()
end

function ArenaPrepFrames_OnHide(self)
	DurabilityFrame:SetAlerts();
	UIParent_ManageFramePositions();
end

function ArenaPrepFrames_GetBestAnchorUnitFrameForOppponent(opponentNumber)
	return _G["ArenaPrepFrame" .. math.min(opponentNumber, MAX_ARENA_ENEMIES)];
end

function ArenaPrepFrames_UpdateFrames()
	local numOpps = GetNumArenaOpponentSpecs();
	for i=1, MAX_ARENA_ENEMIES do
		local prepFrame = _G["ArenaPrepFrame"..i];
		if (i <= numOpps) then 
			prepFrame.specPortrait = _G["ArenaPrepFrame"..i.."SpecPortrait"];
			local specID, gender = GetArenaOpponentSpec(i);
			if (specID > 0) then 
				local _, _, _, specIcon, _, class = GetSpecializationInfoByID(specID, gender);
				if( class ) then
					prepFrame.classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
					prepFrame.classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[strupper(class)]));
				end
				SetPortraitToTexture(prepFrame.specPortrait, specIcon);
				prepFrame:Show();
			else
				prepFrame:Hide();
			end
		else
			prepFrame:Hide();
		end
	end
	
end

function ArenaPrepFrames_UpdateBackground(force)
	if ( (SHOW_PARTY_BACKGROUND == "1") or force ) then
		ArenaPrepBackground:Show();
		local numOpps = GetNumArenaOpponents();
		if ( numOpps > 0 ) then
			ArenaPrepBackground:SetPoint("BOTTOMLEFT", "ArenaEnemyFrame"..numOpps.."PetFrame", "BOTTOMLEFT", -15, -10);
		else
			ArenaPrepBackground:Hide();
		end
	else
		ArenaPrepBackground:Hide();
	end
	
end

function ArenaPrepBackground_SetOpacity(opacity)
	local alpha;
	if ( not opacity ) then
		alpha = 1.0 - OpacityFrameSlider:GetValue();
	else
		alpha = 1.0 - opacity;
	end
	ArenaPrepBackground:SetAlpha(alpha);
end
