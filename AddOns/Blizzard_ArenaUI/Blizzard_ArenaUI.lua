MAX_ARENA_ENEMIES = 5;

function ArenaEnemyFrames_OnLoad(self)
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	if ( GetCVarBool("showArenaEnemyFrames") ) then
		ArenaEnemyFrames_Enable(self);
	else
		ArenaEnemyFrames_Disable(self);
	end
	local showCastbars = GetCVarBool("showArenaEnemyCastbar");
	local castFrame;
	for i = 1, MAX_ARENA_ENEMIES do
		castFrame = _G["ArenaEnemyFrame"..i.."CastingBar"];
		castFrame.showCastbar = showCastbars;
		CastingBarFrame_UpdateIsShown(castFrame);
	end
	
	UpdateArenaEnemyBackground(GetCVarBool("showPartyBackground"));
	ArenaEnemyBackground_SetOpacity(tonumber(GetCVar("partyBackgroundOpacity")));
end

function ArenaEnemyFrames_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( (event == "CVAR_UPDATE") and (arg1 == "SHOW_ARENA_ENEMY_FRAMES_TEXT") ) then
		if ( arg2 == "1" ) then
			ArenaEnemyFrames_Enable(self);
		else
			ArenaEnemyFrames_Disable(self);
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		if ( GetCVarBool("showArenaEnemyFrames") ) then
			ArenaEnemyFrames_Enable(self);
		else
			ArenaEnemyFrames_Disable(self);
		end
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
		ArenaEnemyFrames_UpdateVisible();
	end
end

function ArenaEnemyFrames_OnShow(self)
	--Set it up to hide stuff we don't want shown in an arena.
	ArenaEnemyFrames_UpdateWatchFrame();
	
	DurabilityFrame_SetAlerts();
	UIParent_ManageFramePositions();
end

function ArenaEnemyFrames_UpdateWatchFrame()
	local ArenaEnemyFrames = ArenaEnemyFrames;
	if ( not WatchFrame:IsUserPlaced() ) then
		if ( ArenaEnemyFrames:IsShown() ) then
			if ( WatchFrame_RemoveObjectiveHandler(WatchFrame_DisplayTrackedQuests) ) then
				ArenaEnemyFrames.hidWatchedQuests = true;
			end
		else
			if ( ArenaEnemyFrames.hidWatchedQuests ) then
				WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests);
				ArenaEnemyFrames.hidWatchedQuests = false;
			end
		end
		WatchFrame_ClearDisplay();
		WatchFrame_Update();
	elseif ( ArenaEnemyFrames.hidWatchedQuests ) then
		WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests);
		ArenaEnemyFrames.hidWatchedQuests = false;
		WatchFrame_ClearDisplay();
		WatchFrame_Update();
	end
end

function ArenaEnemyFrames_OnHide(self)
	--Make the stuff that needs to be shown shown again.
	ArenaEnemyFrames_UpdateWatchFrame();
	
	DurabilityFrame_SetAlerts();
	UIParent_ManageFramePositions();
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
	if ( ArenaEnemyFrames.show and (instanceType == "arena")) then
		ArenaEnemyFrames:Show();
	else
		ArenaEnemyFrames:Hide();
	end
end

function ArenaEnemyFrame_OnLoad(self)
	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;
	
	self.classPortrait = _G[self:GetName().."ClassPortrait"];
	ArenaEnemyFrame_UpdatePlayer(self, true);
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("ARENA_OPPONENT_UPDATE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	
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
		UnitFrame_Update(self);
	end
		
	local _, class = UnitClass(self.unit);
	
	if( class ) then
		self.classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
		self.classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
	end

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

function ArenaEnemyFrame_OnEvent(self, event, arg1, arg2)
	if ( event == "ARENA_OPPONENT_UPDATE" and arg1 == self.unit ) then
		if ( arg2 == "seen" or arg2 == "destroyed") then
			ArenaEnemyFrame_Unlock(self);
			ArenaEnemyFrame_UpdatePlayer(self);
			
			if ( self.healthbar.frequentUpdates and GetCVarBool("predictedHealth") ) then
				self.healthbar:SetScript("OnUpdate", UnitFrameHealthBar_OnUpdate);
				self.healthbar:UnregisterEvent("UNIT_HEALTH");
			end
			if ( self.manabar.frequentUpdates and GetCVarBool("predictedPower") ) then
				self.manabar:SetScript("OnUpdate", UnitFrameManaBar_OnUpdate);
				UnitFrameManaBar_UnregisterDefaultEvents(self.manabar);
			end
			UpdateArenaEnemyBackground();
			UIParent_ManageFramePositions();
		elseif ( arg2 == "unseen" ) then
			ArenaEnemyFrame_Lock(self);
			
			self.healthbar:RegisterEvent("UNIT_HEALTH");
			self.healthbar:SetScript("OnUpdate", nil);
			UnitFrameManaBar_RegisterDefaultEvents(self.manabar);
			self.manabar:SetScript("OnUpdate", nil);
		elseif ( arg2 == "cleared" ) then
			ArenaEnemyFrame_Unlock(self);
			self:Hide();
			ArenaEnemyFrames_UpdateVisible();
		end
	elseif ( event == "UNIT_PET" and arg1 == self.unit ) then
		ArenaEnemyFrame_UpdatePet(self);
	elseif ( event == "UNIT_NAME_UPDATE" and arg1 == self.unit ) then
		ArenaEnemyFrame_UpdatePlayer(self);
	end
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
			if ( self.manabar.frequentUpdates and GetCVarBool("predictedPower") ) then
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
		local numOpps = GetNumArenaOpponents();
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
