-- THIS CODE IS DEPRECATED!
-- Try to avoid adding new features to this code.
-- The new Arena UI can be found in CompactArenaFrame.
-- This deprecated code is the old arena frames which are now only used by battlegrounds for representing flag carriers.

MAX_ARENA_ENEMIES = 5;

CVarCallbackRegistry:SetCVarCachable("showArenaEnemyPets");

local function LockUnitFrame(unitFrame)
	unitFrame.healthbar:SetStatusBarColor(0.5, 0.5, 0.5);
	unitFrame.healthbar.lockColor = true;
	unitFrame.manabar:SetStatusBarColor(0.5, 0.5, 0.5);
	unitFrame.manabar.lockColor = true;
	unitFrame.hideStatusOnTooltip = true;
end

local function UnlockUnitFrame(unitFrame)
	unitFrame.healthbar.lockColor = false;
	unitFrame.healthbar.forceHideText = false;
	unitFrame.manabar.lockColor = false;
	unitFrame.manabar.forceHideText = false;
	unitFrame.hideStatusOnTooltip = false;
end

ArenaEnemyFramesContainerMixin = {};

function ArenaEnemyFramesContainerMixin:Update()
	self:UpdateShownState();
	self:Layout();
	UIParent_ManageFramePositions();
end

function ArenaEnemyFramesContainerMixin:UpdateShownState()
	for index, unitFrame in ipairs(ArenaEnemyMatchFramesContainer.UnitFrames) do
		unitFrame:UpdateShownState();
	end

	local _, instanceType = IsInInstance();
	if instanceType and instanceType == "pvp"  then
		ArenaEnemyPrepFramesContainer:Hide();
		ArenaEnemyMatchFramesContainer:Show();
		self:Show();
		return;
	end

	ArenaEnemyPrepFramesContainer:Hide();
	ArenaEnemyMatchFramesContainer:Hide();
	self:Hide();
end

ArenaEnemyMatchFramesContainerMixin = {};

function ArenaEnemyMatchFramesContainerMixin:OnLoad()
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	self:CheckEffectiveEnableState();
	local showCastbars = GetCVarBool("showArenaEnemyCastbar");
	local castFrame;
	for i = 1, MAX_ARENA_ENEMIES do
		castFrame = _G["ArenaEnemyMatchFrame"..i.."CastingBar"];
		castFrame:SetPoint("RIGHT", _G["ArenaEnemyMatchFrame"..i], "LEFT", -32, -3);
		castFrame.showCastbar = showCastbars;
		castFrame:UpdateIsShown();
	end

	ArenaEnemyFramesContainer:Update();
	self:ResetCrowdControlCooldownData();
end

function ArenaEnemyMatchFramesContainerMixin:OnEvent(event, ...)
	local arg1, arg2 = ...;
	if ( (event == "CVAR_UPDATE") and (arg1 == "showArenaEnemyFrames") ) then
		self:CheckEffectiveEnableState(arg2 == "1");
	elseif ( event == "VARIABLES_LOADED" ) then
		self:CheckEffectiveEnableState();
		local showCastbars = GetCVarBool("showArenaEnemyCastbar");
		local castFrame;
		for i = 1, MAX_ARENA_ENEMIES do
			castFrame = _G["ArenaEnemyMatchFrame"..i.."CastingBar"];
			castFrame.showCastbar = showCastbars;
			castFrame:UpdateIsShown();
		end
		for i=1, MAX_ARENA_ENEMIES do
			_G["ArenaEnemyMatchFrame"..i]:UpdatePet();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		self:CheckEffectiveEnableState();
		ArenaEnemyFramesContainer:Update();
		self:ResetCrowdControlCooldownData();
	end
end

function ArenaEnemyMatchFramesContainerMixin:OnShow()
	DurabilityFrame:SetAlerts();
	ArenaEnemyFramesContainer:Update();
end

function ArenaEnemyMatchFramesContainerMixin:OnHide()
	DurabilityFrame:SetAlerts();
	ArenaEnemyFramesContainer:Update();
end

function ArenaEnemyMatchFramesContainerMixin:ResetCrowdControlCooldownData()
	for index, unitFrame in ipairs(self.UnitFrames) do
		unitFrame.CC.spellID = nil;
		unitFrame.CC.Icon:SetTexture(nil);
		unitFrame.CC.Cooldown:Clear();
		unitFrame:UpdateCrowdControl();
	end
end

function ArenaEnemyMatchFramesContainerMixin:CheckEffectiveEnableState(cvarUpdate)
	if (C_PvP.IsInBrawl() and not C_PvP.IsSoloShuffle()) then
		self:Disable();
	else
		if ( GetCVarBool("showArenaEnemyFrames") or cvarUpdate ) then
			self:Enable();
		else
			self:Disable();
		end
	end
end

function ArenaEnemyMatchFramesContainerMixin:Enable()
	self.show = true;
	ArenaEnemyFramesContainer:Update();
end

function ArenaEnemyMatchFramesContainerMixin:Disable()
	self.show = false;
	ArenaEnemyFramesContainer:Update();
end

function ArenaEnemyMatchFramesContainerMixin:GetBestAnchorUnitFrameForOppponent(opponentNumber)
	return self.UnitFrames[math.min(opponentNumber, MAX_ARENA_ENEMIES)];
end

ArenaEnemyMatchFrameMixin = {};

function ArenaEnemyMatchFrameMixin:OnLoad()
	local id = self:GetID();
	self.debuffCountdown = 0;
	self.numDebuffs = 0;
	local prefix = "ArenaEnemyMatchFrame"..id;

	local healthBar = _G[prefix.."HealthBar"];

	local myHealPredictionBar = _G[prefix.."MyHealPredictionBar"];
	myHealPredictionBar:SetStatusBar(healthBar);
	local otherHealPredictionBar = _G[prefix.."OtherHealPredictionBar"];
	otherHealPredictionBar:SetStatusBar(healthBar);
	local totalAbsorbBar = _G[prefix.."TotalAbsorbBar"];
	totalAbsorbBar:SetStatusBar(healthBar);
	local healAbsorbBar = _G[prefix.."HealAbsorbBar"];
	healAbsorbBar:SetStatusBar(healthBar);

	UnitFrame_Initialize(self, "arena"..id,  _G[prefix.."Name"], nil, nil,
			healthBar,
			_G[prefix.."HealthBarText"],
			_G[prefix.."ManaBar"],
			_G[prefix.."ManaBarText"],
			nil, nil, nil,
			myHealPredictionBar,
			otherHealPredictionBar,
			totalAbsorbBar,
			_G[prefix.."OverAbsorbGlow"],
			_G[prefix.."OverHealAbsorbGlow"],
			healAbsorbBar);
	SetTextStatusBarTextZeroText(healthBar, DEAD);

	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;

	self.classPortrait = _G[self:GetName().."ClassPortrait"];
	self.specPortrait = _G[self:GetName().."SpecPortrait"];
	self.specBorder = _G[self:GetName().."SpecBorder"];
	self.castBar = _G[self:GetName().."CastingBar"];

	self:UpdatePlayer();
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
		LockUnitFrame(self);
	elseif ( UnitExists("arenapet"..id) and ( not UnitClass("arena"..id) ) ) then	--We use UnitClass because even if the unit doesn't exist on the client, we may still have enough info to populate the frame.
		self:SetMysteryPlayer();
	end
end

function ArenaEnemyMatchFrameMixin:UpdatePlayer() --At some points, we need to use CVars instead of UVars even though UVars are faster.
	local id = self:GetID();
	if ( UnitGUID(self.unit) ) then	--Use UnitGUID instead of UnitExists in case the unit is a remote update.
		self:Show();
		_G["ArenaEnemyPrepFrame"..id]:Hide();
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

	self.castBar:SetUnit(self.unit, false, true);

	ArenaEnemyFramesContainer:Update();
end

function ArenaEnemyMatchFrameMixin:SetMysteryPlayer()
	self.healthbar:SetMinMaxValues(0,100);
	self.healthbar:SetValue(100);
	self.healthbar.forceHideText = true;
	self.manabar:SetMinMaxValues(0,100);
	self.manabar:SetValue(100);
	self.manabar.forceHideText = true;
	self.classPortrait:SetTexture("Interface\\CharacterFrame\\TempPortrait");
	self.classPortrait:SetTexCoord(0, 1, 0, 1);
	self.name:SetText("");
	LockUnitFrame(self);
	self:Show();
end

function ArenaEnemyMatchFrameMixin:OnEvent(event, unit, ...)
	if ( unit == self.unit ) then
		if ( event == "ARENA_OPPONENT_UPDATE" ) then
			local unitEvent = ...;
			if ( unitEvent == "seen" or unitEvent == "destroyed") then
				UnlockUnitFrame(self);
				self:UpdatePlayer();

				if ( self.healthbar.frequentUpdates and GetCVarBool("predictedHealth") ) then
					self.healthbar:SetScript("OnUpdate", UnitFrameHealthBar_OnUpdate);
					self.healthbar:UnregisterEvent("UNIT_HEALTH");
				end
				if ( self.manabar.frequentUpdates ) then
					self.manabar:SetScript("OnUpdate", UnitFrameManaBar_OnUpdate);
					UnitFrameManaBar_UnregisterDefaultEvents(self.manabar);
				end
				self:UpdatePet();

				ArenaEnemyFramesContainer:Update();
			elseif ( unitEvent == "unseen" ) then
				LockUnitFrame(self);
				self.healthbar:RegisterEvent("UNIT_HEALTH");
				self.healthbar:SetScript("OnUpdate", nil);
				UnitFrameManaBar_RegisterDefaultEvents(self.manabar);
				self.manabar:SetScript("OnUpdate", nil);
			elseif ( unitEvent == "cleared" ) then
				UnlockUnitFrame(self);
				self:Hide();
				ArenaEnemyFramesContainer:Update();
				local _, instanceType = IsInInstance();
				if (instanceType ~= "arena") then
					ArenaEnemyPrepFramesContainer:Hide()
				end
			end
		elseif ( event == "UNIT_PET" ) then
			self:UpdatePet();
		elseif ( event == "UNIT_NAME_UPDATE" ) then
			self:UpdatePlayer();
		elseif ( event == "UNIT_MAXHEALTH" or event == "UNIT_HEAL_PREDICTION" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" ) then
			UnitFrameHealPredictionBars_Update(self);
		elseif ( event == "ARENA_COOLDOWNS_UPDATE" ) then
			self:UpdateCrowdControl();
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

function ArenaEnemyMatchFrameMixin:UpdateCrowdControl()
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

function ArenaEnemyMatchFrameMixin:OnShow()
	C_PvP.RequestCrowdControlSpell(self.unit);
	ArenaEnemyFramesContainer:Update();
end

function ArenaEnemyMatchFrameMixin:OnHide()
	ArenaEnemyFramesContainer:Update();
end

function ArenaEnemyMatchFrameMixin:GetPetFrame()
	return _G["ArenaEnemyMatchFrame"..self:GetID().."PetFrame"];
end

function ArenaEnemyMatchFrameMixin:UpdatePet()
	self:GetPetFrame():Update();
end

function ArenaEnemyMatchFrameMixin:UpdateShownState()
	local unitGuid = UnitGUID(self.unit);
	self:SetShown(unitGuid);
	self.CastingBar:SetShown(self.CastingBar.casting);
	self:UpdatePet();
end

ArenaEnemyPrepFrameMixin = {};

function ArenaEnemyPrepFrameMixin:OnShow()
	ArenaEnemyFramesContainer:Update();
end

function ArenaEnemyPrepFrameMixin:OnHide()
	ArenaEnemyFramesContainer:Update();
end

ArenaEnemyPetFrameMixin = {};

function ArenaEnemyPetFrameMixin:Update() --At some points, we need to use CVars instead of UVars even though UVars are faster.
	if UnitGUID(self.unit) and CVarCallbackRegistry:GetCVarValue("showArenaEnemyPets") then
		self:Show();
	else
		self:Hide();
	end

	UnitFrame_Update(self);
end

function ArenaEnemyPetFrameMixin:OnLoad()
	local id = self:GetParent():GetID();
	local prefix = "ArenaEnemyMatchFrame"..id.."PetFrame";
	local unit = "arenapet"..id;
	self.layoutIndex = self:GetParent().layoutIndex + 1;
	UnitFrame_Initialize(self, unit,  _G[prefix.."Name"], nil, _G[prefix.."Portrait"],
		   _G[prefix.."HealthBar"], _G[prefix.."HealthBarText"], _G[prefix.."ManaBar"], _G[prefix.."ManaBarText"]);
	SetTextStatusBarTextZeroText(_G[prefix.."HealthBar"], DEAD);
	_G[prefix.."Name"]:Hide();
	SecureUnitButton_OnLoad(self, unit);
	self:SetID(id);
	self:SetParent(ArenaEnemyMatchFramesContainer);
	self:Update();
	self:RegisterEvent("ARENA_OPPONENT_UPDATE");
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");

	UIDropDownMenu_Initialize(self.DropDown, ArenaEnemyPetDropDown_Initialize, "MENU");

	local setfocus = function()
		FocusUnit("arenapet"..self:GetID());
	end
	SecureUnitButton_OnLoad(self, "arenapet"..self:GetID(), setfocus);
end

function ArenaEnemyPetFrameMixin:OnEvent(event, ...)
	local arg1, arg2 = ...;
	if ( event == "ARENA_OPPONENT_UPDATE" and arg1 == self.unit ) then
		if ( arg2 == "seen" or arg2 == "destroyed") then
			UnlockUnitFrame(self);
			self:Update();
			local ownerFrame = _G["ArenaEnemyMatchFrame"..self:GetID()];
			if ( not ownerFrame:IsShown() ) then
				ownerFrame:SetMysteryPlayer();
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
			LockUnitFrame(self);
			self.healthbar:RegisterEvent("UNIT_HEALTH");
			self.healthbar:SetScript("OnUpdate", nil);
			UnitFrameManaBar_RegisterDefaultEvents(self.manabar);
			self.manabar:SetScript("OnUpdate", nil);
		elseif ( arg2 == "cleared" ) then
			UnlockUnitFrame(self);
			self:Hide()
		end
	elseif ( event == "UNIT_CLASSIFICATION_CHANGED" and arg1 == self.unit ) then
		UnitFrame_Update(self);
	end
	UnitFrame_OnEvent(self, event, ...);
end

function ArenaEnemyPetFrameMixin:OnShow()
	UnitFrame_Update(self);
	ArenaEnemyFramesContainer:Update();
end

function ArenaEnemyPetFrameMixin:OnHide()
	ArenaEnemyFramesContainer:Update();
end

function ArenaEnemyDropDown_Initialize(self)
	UnitPopup_ShowMenu(self, "ARENAENEMY", "arena"..self:GetParent():GetID());
end

function ArenaEnemyPetDropDown_Initialize(self)
	UnitPopup_ShowMenu(self, "ARENAENEMY", "arenapet"..self:GetParent():GetID());
end

-----------------------------------------------------------------------------
--Arena preparation stuff, shows class and spec of opponents during countdown
------------------------------------------------------------------------------

ArenaEnemyPrepFramesContainerMixin = {};

function ArenaEnemyPrepFramesContainerMixin:OnLoad()
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS");
	local numOpps = GetNumArenaOpponentSpecs();
	if (numOpps and numOpps > 0) then
		self:OnEvent(self, "ARENA_PREP_OPPONENT_SPECIALIZATIONS");
	end
end

function ArenaEnemyPrepFramesContainerMixin:OnEvent(event, ...) --also called in OnLoad
	if (event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS") then
		self:UpdateFrames();
		self:Show();
	end
end

function ArenaEnemyPrepFramesContainerMixin:OnShow()
	DurabilityFrame:SetAlerts();
	ArenaEnemyFramesContainer:Update();
end

function ArenaEnemyPrepFramesContainerMixin:OnHide()
	DurabilityFrame:SetAlerts();
	ArenaEnemyFramesContainer:Update();
end

function ArenaEnemyPrepFramesContainerMixin:GetBestAnchorUnitFrameForOppponent(opponentNumber)
	return self.UnitFrames[math.min(opponentNumber, MAX_ARENA_ENEMIES)];
end

function ArenaEnemyPrepFramesContainerMixin:UpdateFrames()
	local numOpps = GetNumArenaOpponentSpecs();
	for i=1, MAX_ARENA_ENEMIES do
		local prepFrame = self.UnitFrames[i];
		if (i <= numOpps) then 
			prepFrame.specPortrait = _G["ArenaEnemyPrepFrame"..i.."SpecPortrait"];
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
