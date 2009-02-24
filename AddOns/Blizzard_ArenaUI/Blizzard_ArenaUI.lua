MAX_ARENA_ENEMIES = 5;

function ArenaEnemyFrames_OnLoad(self)
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	
	if ( GetCVarBool("showArenaEnemyFrames") ) then
		ArenaEnemyFrames_Enable(self);
	else
		ArenaEnemyFrames_Disable(self);
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
		UpdateArenaEnemyBackground(GetCVarBool("showPartyBackground"));
		ArenaEnemyBackground_SetOpacity(tonumber(GetCVar("partyBackgroundOpacity")));
	end
end

function ArenaEnemyFrames_OnShow(self)
	--Set it up to hide stuff we don't want shown in an arena.

	WatchFrame_RemoveObjectiveHandler(WatchFrame_HandleDisplayQuestTimers);
	WatchFrame_RemoveObjectiveHandler(WatchFrame_HandleDisplayTrackedAchievements);
	WatchFrame_RemoveObjectiveHandler(WatchFrame_DisplayTrackedQuests);
	
	WatchFrameLines:Hide();
	WatchFrame:Hide();
	
	ArenaEnemyFrames_MoveAchievements();
	
	DurabilityFrame_SetAlerts();
	UIParent_ManageFramePositions();
end

function ArenaEnemyFrames_MoveAchievements()
	return;	--Changeme. Need to set up a system to still allow PvP achivements to be shown in Arena with the new WatchFrame system.
	--[[if ( ArenaEnemyFrames:IsShown() ) then
		AchievementWatchFrame:ClearAllPoints();
		AchievementWatchFrame:SetPoint("TOPRIGHT", "ArenaEnemyFrame"..GetNumArenaOpponents(), "BOTTOMRIGHT", 0, -35);
	end]]
end

function ArenaEnemyFrames_OnHide(self)
	--Make the stuff that needs to be shown shown again.
	WatchFrame_AddObjectiveHandler(WatchFrame_HandleDisplayQuestTimers);
	WatchFrame_AddObjectiveHandler(WatchFrame_HandleDisplayTrackedAchievements);
	WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests);
	
	WatchFrameLines:Show();
	WatchFrame:Show();
	
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
	if ( GetNumArenaOpponents() > 0 and ArenaEnemyFrames.show ) then
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
	ArenaEnemyFrame_UpdatePlayer(self);
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("ARENA_OPPONENT_UPDATE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	
	local showmenu = function()
		ToggleDropDownMenu(1, nil, getglobal("ArenaEnemyFrame"..self:GetID().."DropDown"), self:GetName(), 47, 15);
	end
	SecureUnitButton_OnLoad(self, "arena"..self:GetID(), showmenu);
end

function ArenaEnemyFrame_UpdatePlayer(self)
	local id = self:GetID();
	if ( UnitExists(self.unit) ) then
		self:Show();
		UnitFrame_Update(self);
		
		local _, class = UnitClass(self.unit);
		self.classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
		
		ArenaEnemyFrame_UpdatePet(self);
	else
		self:Hide();
	end

	ArenaEnemyFrames_UpdateVisible();
end

function ArenaEnemyFrame_OnEvent(self, event, arg1)
	if ( event == "ARENA_OPPONENT_UPDATE" and arg1 == self.unit ) then
		ArenaEnemyFrame_UpdatePlayer(self);
		UpdateArenaEnemyBackground();
		ArenaEnemyFrames_MoveAchievements();
	elseif ( event == "UNIT_PET" and arg1 == self.unit ) then
		ArenaEnemyFrame_UpdatePet(self);
	elseif ( event == "UNIT_NAME_UPDATE" and arg1 == self.unit ) then
		ArenaEnemyFrame_UpdatePlayer(self);
	end
end

function ArenaEnemyFrame_UpdatePet(self, id)
	if ( not id ) then
		id = self:GetID();
	end
	
	local unitFrame = _G["ArenaEnemyFrame"..id];
	local petFrame = _G["ArenaEnemyFrame"..id.."PetFrame"];
	
	if ( UnitIsConnected(unitFrame.unit) and UnitExists(petFrame.unit) ) then
		petFrame:Show();
	else
		petFrame:Hide();
	end
	
	UnitFrame_Update(petFrame);
end

function ArenaEnemyDropDown_OnLoad (self)
	--UIDropDownMenu_Initialize(self, ArenaEnemyDropDown_Initialize, "MENU");
end

function ArenaEnemyDropDown_Initialize (self)
	local dropdown;
	if ( UIDROPDOWNMENU_OPEN_MENU ) then
		dropdown = UIDROPDOWNMENU_OPEN_MENU;
	else
		dropdown = self;
	end
	UnitPopup_ShowMenu(dropdown, "ARENAENEMY", "arena"..dropdown:GetParent():GetID());
end

function UpdateArenaEnemyBackground(force)
	if ( (SHOW_PARTY_BACKGROUND == "1") or force ) then
		ArenaEnemyBackground:Show();
		local numOpps = GetNumArenaOpponents();
		if ( numOpps > 0 ) then
			ArenaEnemyBackground:SetPoint("BOTTOMLEFT", "ArenaEnemyFrame"..numOpps.."PetFrame", "BOTTOMLEFT", -15, -10);
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
