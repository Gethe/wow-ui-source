NUM_ALWAYS_UP_UI_FRAMES = 0;
NUM_EXTENDED_UI_FRAMES = 0;
MAX_WORLDSTATE_SCORE_BUTTONS = 20;
MAX_NUM_STAT_COLUMNS = 7;
WORLDSTATESCOREFRAME_BASE_COLUMNS = 6;
WORLDSTATESCOREFRAME_COLUMN_SPACING = 76;
WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET = -28;

WORLDSTATEALWAYSUPFRAME_TIMESINCELAST = -25;
WORLDSTATEALWAYSUPFRAME_TIMESINCESTART = 0;
WORLDSTATEALWAYSUPFRAME_TIMETORUN = 60;
WORLDSTATEALWAYSUPFRAME_DEFAULTINTERVAL = 5;

SCORE_BUTTON_HEIGHT = 16;

WORLDSTATEALWAYSUPFRAME_SUSPENDEDCHATFRAMES = {};

local inBattleground = false;

--
FILTERED_BG_CHAT_ADD_GLOBALS = { "ERR_RAID_MEMBER_ADDED_S", "ERR_BG_PLAYER_JOINED_SS" };
FILTERED_BG_CHAT_SUBTRACT_GLOBALS = { "ERR_RAID_MEMBER_REMOVED_S", "ERR_BG_PLAYER_LEFT_S" };

--Filtered at the end of BGs only
FILTERED_BG_CHAT_END_GLOBALS = { "LOOT_ITEM", "LOOT_ITEM_MULTIPLE", "CREATED_ITEM", "CREATED_ITEM_MULTIPLE", "ERR_RAID_MEMBER_REMOVED_S", "ERR_BG_PLAYER_LEFT_S" };

FILTERED_BG_CHAT_ADD = {};
FILTERED_BG_CHAT_SUBTRACT = {};
FILTERED_BG_CHAT_END = {};

ADDED_PLAYERS = {};
SUBTRACTED_PLAYERS = {};

CLASS_BUTTONS = {
	["WARRIOR"]	= {0, 0.25, 0, 0.25},
	["MAGE"]		= {0.25, 0.49609375, 0, 0.25},
	["ROGUE"]		= {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"]		= {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"]		= {0, 0.25, 0.25, 0.5},
	["SHAMAN"]	 	= {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"]		= {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"]	= {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"]		= {0, 0.25, 0.5, 0.75},
	["DEATHKNIGHT"]	= {0.25, 0.49609375, 0.5, 0.75},
	["MONK"]	= {0.49609375, 0.7421875, 0.5, 0.75},
};


ExtendedUI = {};

-- Always up stuff (i.e. capture the flag indicators)
function WorldStateAlwaysUpFrame_OnLoad(self)
	self:RegisterEvent("UPDATE_WORLD_STATES");
	self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");
	WorldStateAlwaysUpFrame_Update();
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_INDOORS");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND");

	self:RegisterEvent("WORLD_STATE_UI_TIMER_UPDATE");

	self:RegisterEvent("WORLD_STATE_TIMER_START");
	self:RegisterEvent("WORLD_STATE_TIMER_STOP");

	FILTERED_BG_CHAT_ADD = {};
	FILTERED_BG_CHAT_SUBTRACT = {};
	FILTERED_BG_CHAT_END = {};
	
	local chatString;
	for _, str in next, FILTERED_BG_CHAT_ADD_GLOBALS do	
		chatString = _G[str];
		if ( chatString ) then
			chatString = string.gsub(chatString, "%[", "%%[");
			chatString = string.gsub(chatString, "%]", "%%]");
			chatString = string.gsub(chatString, "%%s", "(.-)")
			tinsert(FILTERED_BG_CHAT_ADD, chatString);
		end
	end	
	
	local chatString;
	for _, str in next, FILTERED_BG_CHAT_SUBTRACT_GLOBALS do	
		chatString = _G[str];
		if ( chatString ) then
			chatString = string.gsub(chatString, "%[", "%%[");
			chatString = string.gsub(chatString, "%]", "%%]");
			chatString = string.gsub(chatString, "%%s", "(.-)")
			tinsert(FILTERED_BG_CHAT_SUBTRACT, chatString);
		end
	end
	
	for _, str in next, FILTERED_BG_CHAT_END_GLOBALS do
		chatString = _G[str];
		if ( chatString ) then
			chatString = string.gsub(chatString, "%[", "%%[");
			chatString = string.gsub(chatString, "%]", "%%]");
			chatString = string.gsub(chatString, "%%s", "(.-)");
			tinsert(FILTERED_BG_CHAT_END, chatString);
		end
	end

end

function WorldStateAlwaysUpFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		WorldStateFrame_ToggleBattlefieldMinimap();
		WorldStateAlwaysUpFrame_StopBGChatFilter(self);
		WorldStateChallengeMode_CheckTimers(GetWorldElapsedTimers());
	elseif ( event == "PLAYER_ENTERING_BATTLEGROUND" ) then
		WorldStateAlwaysUpFrame_StartBGChatFilter(self);
	elseif ( event == "WORLD_STATE_TIMER_START" ) then
		local timerID = ...;
		WorldStateChallengeMode_CheckTimers(timerID);
	elseif ( event == "WORLD_STATE_TIMER_STOP" ) then
		local timerID = ...;
		WorldStateChallengeMode_HideTimer(timerID);
	else
		WorldStateAlwaysUpFrame_Update();
	end
end

function WorldStateAlwaysUpFrame_Update()
	local numUI = GetNumWorldStateUI();
	local name, frame, frameText, frameDynamicIcon, frameIcon, frameFlash, flashTexture, frameDynamicButton;
	local extendedUI, extendedUIState1, extendedUIState2, extendedUIState3, uiInfo; 
	local uiType, text, icon, state, hidden, dynamicIcon, tooltip, dynamicTooltip, flash, relative;
	local inInstance, instanceType = IsInInstance();
	local alwaysUpShown = 1;
	local extendedUIShown = 1;
	local alwaysUpHeight = 10;
	for i=1, numUI do
		uiType, state, hidden, text, icon, dynamicIcon, tooltip, dynamicTooltip, extendedUI, extendedUIState1, extendedUIState2, extendedUIState3 = GetWorldStateUIInfo(i);
		if ( not hidden ) then
			if ( state > 0 ) then
				-- Handle always up frames and extended ui's completely differently
				if ( extendedUI ~= "" ) then
					-- extendedUI
					uiInfo = ExtendedUI[extendedUI]
					name = uiInfo.name..extendedUIShown;
					if ( extendedUIShown > NUM_EXTENDED_UI_FRAMES ) then
						frame = uiInfo.create(extendedUIShown);
						NUM_EXTENDED_UI_FRAMES = extendedUIShown;
					else
						frame = _G[name];
					end
					uiInfo.update(extendedUIShown, extendedUIState1, extendedUIState2, extendedUIState3);
					frame:Show();
					extendedUIShown = extendedUIShown + 1;
				else
					-- Always Up
					name = "AlwaysUpFrame"..alwaysUpShown;
					if ( alwaysUpShown > NUM_ALWAYS_UP_UI_FRAMES ) then
						frame = CreateFrame("Frame", name, WorldStateAlwaysUpFrame, "WorldStateAlwaysUpTemplate");
						NUM_ALWAYS_UP_UI_FRAMES = alwaysUpShown;
					else
						frame = _G[name];
					end
					if ( alwaysUpShown == 1 ) then
						frame:SetPoint("TOP", WorldStateAlwaysUpFrame, -23 , -20);
					else
						relative = _G["AlwaysUpFrame"..(alwaysUpShown - 1)];
						frame:SetPoint("TOP", relative, "BOTTOM");
					end
					frameText = _G[name.."Text"];
					frameIcon = _G[name.."Icon"];
					frameDynamicIcon = _G[name.."DynamicIconButtonIcon"];
					frameFlash = _G[name.."Flash"];
					flashTexture = _G[name.."FlashTexture"];
					frameDynamicButton = _G[name.."DynamicIconButton"];

					frameText:SetText(text);
					frameIcon:SetTexture(icon);
					frameDynamicIcon:SetTexture(dynamicIcon);
					flash = nil;
					if ( dynamicIcon ~= "" ) then
						flash = dynamicIcon.."Flash"
					end
					flashTexture:SetTexture(flash);
					frameDynamicButton.tooltip = dynamicTooltip;
					if ( state == 2 ) then
						UIFrameFlash(frameFlash, 0.5, 0.5, -1);
						frameDynamicButton:Show();
					elseif ( state == 3 ) then
						UIFrameFlashStop(frameFlash);
						frameDynamicButton:Show();
					else
						UIFrameFlashStop(frameFlash);
						frameDynamicButton:Hide();
					end
					alwaysUpShown = alwaysUpShown + 1;
					alwaysUpHeight = alwaysUpHeight + frame:GetHeight();
				end	
				if ( icon ~= "" ) then
					frame.tooltip = tooltip;
				else
					frame.tooltip = nil;
				end
				frame:Show();
			end
		end
	end
	for i=alwaysUpShown, NUM_ALWAYS_UP_UI_FRAMES do
		frame = _G["AlwaysUpFrame"..i];
		frame:Hide();
	end
	for i=extendedUIShown, NUM_EXTENDED_UI_FRAMES do
		frame = _G["WorldStateCaptureBar"..i];
		if ( frame ) then
			frame:Hide();
		end
	end
	WorldStateAlwaysUpFrame:SetHeight(alwaysUpHeight);
end

function WorldStateAlwaysUpFrame_OnUpdate(self, elapsed)
	WORLDSTATEALWAYSUPFRAME_TIMESINCELAST = WORLDSTATEALWAYSUPFRAME_TIMESINCELAST + elapsed;
	WORLDSTATEALWAYSUPFRAME_TIMESINCESTART = WORLDSTATEALWAYSUPFRAME_TIMESINCESTART + elapsed;
	if ( WORLDSTATEALWAYSUPFRAME_TIMESINCELAST >= WORLDSTATEALWAYSUPFRAME_DEFAULTINTERVAL ) then		
		local subtractedPlayers, playerString = 0;
		
		for i in next, SUBTRACTED_PLAYERS do 
			if ( not playerString ) then
				playerString = i;
			else
				playerString = playerString .. PLAYER_LIST_DELIMITER .. i;
			end
			
			subtractedPlayers = subtractedPlayers + 1;
		end

		local message, info;
		
		if ( subtractedPlayers > 0 ) then
			info = ChatTypeInfo["SYSTEM"];
			if ( subtractedPlayers > 1 and subtractedPlayers <= 3 ) then
				message = ERR_PLAYERLIST_LEFT_BATTLE;
				DEFAULT_CHAT_FRAME:AddMessage(string.format(message, subtractedPlayers, playerString), info.r, info.g, info.b, info.id);
			elseif ( subtractedPlayers > 3 ) then
				message = ERR_PLAYERS_LEFT_BATTLE_D;
				DEFAULT_CHAT_FRAME:AddMessage(string.format(message, subtractedPlayers), info.r, info.g, info.b, info.id);
			else
				message = ERR_PLAYER_LEFT_BATTLE_D;
				DEFAULT_CHAT_FRAME:AddMessage(string.format(message, playerString), info.r, info.g, info.b, info.id);
			end

			for i in next, SUBTRACTED_PLAYERS do
				SUBTRACTED_PLAYERS[i] = nil;
			end
		end
		
		local addedPlayers, playerString = 0;
		for i in next, ADDED_PLAYERS do
			if ( not playerString ) then
				playerString = i;
			else
				playerString = playerString .. PLAYER_LIST_DELIMITER .. i;
			end
			
			addedPlayers = addedPlayers + 1;
		end
		
		
		if ( addedPlayers > 0 ) then
			info = ChatTypeInfo["SYSTEM"];
			if ( addedPlayers > 1 and addedPlayers <= 3 ) then
				message = ERR_PLAYERLIST_JOINED_BATTLE;
				DEFAULT_CHAT_FRAME:AddMessage(string.format(message, addedPlayers, playerString), info.r, info.g, info.b, info.id);
			elseif ( addedPlayers > 3 ) then
				message = ERR_PLAYERS_JOINED_BATTLE_D;
				DEFAULT_CHAT_FRAME:AddMessage(string.format(message, addedPlayers), info.r, info.g, info.b, info.id);
			else
				message = ERR_PLAYER_JOINED_BATTLE_D;
				DEFAULT_CHAT_FRAME:AddMessage(string.format(message, playerString), info.r, info.g, info.b, info.id);
			end

			for i in next, ADDED_PLAYERS do
				ADDED_PLAYERS[i] = nil;
			end
		end
		
		WORLDSTATEALWAYSUPFRAME_TIMESINCELAST = 0;
	elseif ( WORLDSTATEALWAYSUPFRAME_TIMESINCESTART >= WORLDSTATEALWAYSUPFRAME_TIMETORUN ) then
		WORLDSTATEALWAYSUPFRAME_TIMESINCELAST = WORLDSTATEALWAYSUPFRAME_DEFAULTINTERVAL;
		WorldStateAlwaysUpFrame_OnUpdate(self, 0);
		self:SetScript("OnUpdate", nil);
	end
end

function WorldStateAlwaysUpFrame_StartBGChatFilter (self)
	inBattleground = true;
	
	-- Reset the OnUpdate timer variables
	WORLDSTATEALWAYSUPFRAME_TIMESINCELAST = -25;
	WORLDSTATEALWAYSUPFRAME_TIMESINCESTART = 0;
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", WorldStateAlwaysUpFrame_FilterChatMsgSystem);
	
	self:SetScript("OnUpdate", WorldStateAlwaysUpFrame_OnUpdate);
end

function WorldStateAlwaysUpFrame_StopBGChatFilter (self)
	inBattleground = false;
	
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", WorldStateAlwaysUpFrame_FilterChatMsgSystem);
	
	for i in next, ADDED_PLAYERS do
		ADDED_PLAYERS[i] = nil;
	end
	
	for i in next, SUBTRACTED_PLAYERS do
		SUBTRACTED_PLAYERS[i] = nil;
	end
	
	self:SetScript("OnUpdate", nil);
end

function WorldStateAlwaysUpFrame_FilterChatMsgSystem (self, event, ...)
	local playerName;
	
	local message = ...;
	
	if ( GetBattlefieldWinner() ) then
		-- Filter out leaving messages when the battleground is over.
		for i, str in next, FILTERED_BG_CHAT_SUBTRACT do
			playerName = string.match(message, str);
			if ( playerName ) then
				return true;
			end
		end
	elseif ( WORLDSTATEALWAYSUPFRAME_TIMESINCESTART < WORLDSTATEALWAYSUPFRAME_TIMETORUN ) then
		-- Filter out leaving and joining messages when the battleground starts.
		for i, str in next, FILTERED_BG_CHAT_ADD do
			playerName = string.match(message, str);
			if ( playerName ) then
				-- Trim realm names
				playerName = string.match(playerName, "([^%-]+)%-?.*");
				ADDED_PLAYERS[playerName] = true;
				return true;
			end
		end
		
		for i, str in next, FILTERED_BG_CHAT_SUBTRACT do
			playerName = string.match(message, str);
			if ( playerName ) then
				playerName = string.match(playerName, "([^%-]+)%-?.*");
				SUBTRACTED_PLAYERS[playerName] = true;
				return true;
			end
		end
	end
	return false;
end


function WorldStateFrame_ToggleBattlefieldMinimap()
	local _, instanceType = IsInInstance();
	if ( instanceType ~= "pvp" and instanceType ~= "none" ) then
		if ( BattlefieldMinimap and BattlefieldMinimap:IsShown() ) then
			BattlefieldMinimap:Hide();
		end
		return;
	end

	if ( WorldStateFrame_CanShowBattlefieldMinimap() ) then
		if ( not BattlefieldMinimap ) then
			BattlefieldMinimap_LoadUI();
		end
		BattlefieldMinimap:Show();
	end
end

function WorldStateFrame_CanShowBattlefieldMinimap()
	local _, instanceType = IsInInstance();

	if ( instanceType == "pvp" ) then
		return GetCVar("showBattlefieldMinimap") == "1";
	end

	if ( instanceType == "none" ) then
		return GetCVar("showBattlefieldMinimap") == "2";
	end

	return false;
end

-- UI Specific functions
function CaptureBar_Create(id)
	local frame = CreateFrame("Frame", "WorldStateCaptureBar"..id, UIParent, "WorldStateCaptureBarTemplate");
	return frame;
end

function CaptureBar_Update(id, value, neutralPercent)
	local position = 25 + 124*(1 - value/100);
	local bar = _G["WorldStateCaptureBar"..id];
	local barSize = 121;
	if ( not bar.oldValue ) then
		bar.oldValue = position;
	end
	-- Show an arrow in the direction the bar is moving
	if ( position < bar.oldValue ) then
		_G["WorldStateCaptureBar"..id.."IndicatorLeft"]:Show();
		_G["WorldStateCaptureBar"..id.."IndicatorRight"]:Hide();
	elseif ( position > bar.oldValue ) then
		_G["WorldStateCaptureBar"..id.."IndicatorLeft"]:Hide();
		_G["WorldStateCaptureBar"..id.."IndicatorRight"]:Show();
	else
		_G["WorldStateCaptureBar"..id.."IndicatorLeft"]:Hide();
		_G["WorldStateCaptureBar"..id.."IndicatorRight"]:Hide();
	end
	-- Figure out if the ticker is in neutral territory or on a faction's side
	if ( value > (50 + neutralPercent/2) ) then
		_G["WorldStateCaptureBar"..id.."LeftIconHighlight"]:Show();
		_G["WorldStateCaptureBar"..id.."RightIconHighlight"]:Hide();
	elseif ( value < (50 - neutralPercent/2) ) then
		_G["WorldStateCaptureBar"..id.."LeftIconHighlight"]:Hide();
		_G["WorldStateCaptureBar"..id.."RightIconHighlight"]:Show();
	else
		_G["WorldStateCaptureBar"..id.."LeftIconHighlight"]:Hide();
		_G["WorldStateCaptureBar"..id.."RightIconHighlight"]:Hide();
	end
	-- Setup the size of the neutral bar
	local middleBar = _G["WorldStateCaptureBar"..id.."MiddleBar"];
	local leftLine = _G["WorldStateCaptureBar"..id.."LeftLine"];
	if ( neutralPercent == 0 ) then
		middleBar:SetWidth(1);
		leftLine:Hide();
	else
		middleBar:SetWidth(neutralPercent/100*barSize);
		leftLine:Show();
	end

	bar.oldValue = position;
	_G["WorldStateCaptureBar"..id.."Indicator"]:SetPoint("CENTER", "WorldStateCaptureBar"..id, "LEFT", position, 0);
end


-- This has to be after all the functions are loaded
ExtendedUI["CAPTUREPOINT"] = {
	name = "WorldStateCaptureBar",
	create = CaptureBar_Create,
	update = CaptureBar_Update,
	onHide = CaptureBar_Hide,
}

-------------- FINAL SCORE FUNCTIONS ---------------

function WorldStateScoreFrame_OnLoad(self)
	self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");
	self:RegisterEvent("UPDATE_WORLD_STATES");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, 3);

	UIDropDownMenu_Initialize( ScorePlayerDropDown, ScorePlayerDropDown_Initialize, "MENU");
	
	ButtonFrameTemplate_HidePortrait(self);
	self.Inset:SetPoint("BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, 40);
	_G[self:GetName() .. "BtnCornerLeft"]:Hide();
	_G[self:GetName() .. "BtnCornerRight"]:Hide();
	_G[self:GetName() .. "ButtonBottomBorder"]:Hide();
	
	local rowFrame, prevRowFrame = _, WorldStateScoreButton1;
	for i=2,MAX_WORLDSTATE_SCORE_BUTTONS do
		rowFrame = CreateFrame("FRAME", "WorldStateScoreButton"..i, WorldStateScoreFrame, "WorldStateScoreTemplate");
		rowFrame:SetPoint("TOPLEFT",  prevRowFrame, "BOTTOMLEFT", 0, 0);
		rowFrame:SetPoint("TOPRIGHT",  prevRowFrame, "BOTTOMRIGHT", 0, 0);
		prevRowFrame = rowFrame;
	end
end

function WorldStateScoreFrame_Update()
	local isArena, isRegistered = IsActiveBattlefieldArena();
	local isRatedBG = IsRatedBattleground();
	local battlefieldWinner = GetBattlefieldWinner(); 
	
	local firstFrameAfterCustomStats = WorldStateScoreFrameHonorGained;

	if ( isArena ) then
		-- Hide unused tabs
		WorldStateScoreFrameTab1:Hide();
		WorldStateScoreFrameTab2:Hide();
		WorldStateScoreFrameTab3:Hide();
	
		-- Hide unused columns
		WorldStateScoreFrameDeaths:Hide();
		WorldStateScoreFrameHK:Hide();
		WorldStateScoreFrameHonorGained:Hide();
		WorldStateScoreFrameBgRating:Hide();

		-- Reanchor some columns.
		WorldStateScoreFrameDamageDone:SetPoint("LEFT", WorldStateScoreFrameKB, "RIGHT", -5, 0);
		if ( isRegistered ) then
			WorldStateScoreFrameTeam:Show();
			WorldStateScoreFrameKB:SetPoint("LEFT", WorldStateScoreFrameTeam, "RIGHT", -10, 0);
			WorldStateScoreFrameMatchmakingRating:Hide();
			WorldStateScoreFrameRatingChange:Show();
			WorldStateScoreFrameRatingChange:SetPoint("LEFT", WorldStateScoreFrameHealingDone, "RIGHT", 0, 0);
			WorldStateScoreFrameRatingChange.sortType = "bgratingChange";
		else
			WorldStateScoreFrameMatchmakingRating:Hide();
			WorldStateScoreFrameRatingChange:Hide();
			WorldStateScoreFrameTeam:Hide();
			WorldStateScoreFrameKB:SetPoint("LEFT", WorldStateScoreFrameName, "RIGHT", 4, 0);
		end
	else
		-- Show Tabs
		WorldStateScoreFrameTab1:Show();
		WorldStateScoreFrameTab2:Show();
		WorldStateScoreFrameTab3:Show();
		
		WorldStateScoreFrameTeam:Hide();
		WorldStateScoreFrameDeaths:Show();

		-- Reanchor some columns.
		WorldStateScoreFrameKB:SetPoint("LEFT", WorldStateScoreFrameName, "RIGHT", 4, 0);
		
		if isRatedBG then
			WorldStateScoreFrameHonorGained:Hide();
			WorldStateScoreFrameHK:Hide();
			WorldStateScoreFrameDamageDone:SetPoint("LEFT", WorldStateScoreFrameDeaths, "RIGHT", -5, 0);	
			
			WorldStateScoreFrameBgRating:Show();
			firstFrameAfterCustomStats = WorldStateScoreFrameBgRating;

			if battlefieldWinner then
				WorldStateScoreFrameRatingChange.sortType = "bgratingChange";
				WorldStateScoreFrameRatingChange:SetPoint("LEFT", WorldStateScoreFrameBgRating, "RIGHT", -5, 0);
				WorldStateScoreFrameRatingChange:Show();
			else
				WorldStateScoreFrameRatingChange:Hide();
			end
		else 
			WorldStateScoreFrameHK:Show();
			WorldStateScoreFrameHK:SetPoint("LEFT", WorldStateScoreFrameDeaths, "RIGHT", -5, 0);
			WorldStateScoreFrameDamageDone:SetPoint("LEFT", WorldStateScoreFrameHK, "RIGHT", -5, 0);
			
			WorldStateScoreFrameHonorGained:Show();

			WorldStateScoreFrameRatingChange:Hide();
			WorldStateScoreFrameBgRating:Hide();
		end
		WorldStateScoreFrameMatchmakingRating:Hide();
	end

	--Show the frame if its hidden and there is a victor
	if ( battlefieldWinner ) then
		-- Show the final score frame, set textures etc.
		
		if  not WorldStateScoreFrame.firstOpen then
			ShowUIPanel(WorldStateScoreFrame);
			WorldStateScoreFrame.firstOpen = true;
		end
		
		if ( isArena ) then
			WorldStateScoreFrameLeaveButton:SetText(LEAVE_ARENA);
			WorldStateScoreFrameTimerLabel:SetText(TIME_TO_PORT_ARENA);
		else
			WorldStateScoreFrameLeaveButton:SetText(LEAVE_BATTLEGROUND);				
			WorldStateScoreFrameTimerLabel:SetText(TIME_TO_PORT);
		end
		
		WorldStateScoreFrameLeaveButton:Show();
		WorldStateScoreFrameTimerLabel:Show();
		WorldStateScoreFrameTimer:Show();

		-- Show winner
		if ( isArena ) then
			if ( isRegistered ) then
				local teamName = GetBattlefieldTeamInfo(battlefieldWinner);
				if ( teamName ) then
					WorldStateScoreWinnerFrameText:SetFormattedText(VICTORY_TEXT_ARENA_WINS, teamName);			
				else
					WorldStateScoreWinnerFrameText:SetText(VICTORY_TEXT_ARENA_DRAW);							
				end
			else
				WorldStateScoreWinnerFrameText:SetText(_G["VICTORY_TEXT_ARENA"..battlefieldWinner]);
			end
			if ( battlefieldWinner == 0 ) then
				-- Green Team won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.19, 0.57, 0.11);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.19, 0.57, 0.11);
				WorldStateScoreWinnerFrameText:SetVertexColor(0.1, 1.0, 0.1);	
			else		
				-- Gold Team won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.85, 0.71, 0.26);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.85, 0.71, 0.26);
				WorldStateScoreWinnerFrameText:SetVertexColor(1, 0.82, 0);	
			end
		else
			WorldStateScoreWinnerFrameText:SetText(_G["VICTORY_TEXT"..battlefieldWinner]);
			if ( battlefieldWinner == 0 ) then
				-- Horde won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.52, 0.075, 0.18);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.5, 0.075, 0.18);
				WorldStateScoreWinnerFrameText:SetVertexColor(1.0, 0.1, 0.1);
			else
				-- Alliance won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.11, 0.26, 0.51);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.11, 0.26, 0.51);
				WorldStateScoreWinnerFrameText:SetVertexColor(0, 0.68, 0.94);	
			end
		end
		WorldStateScoreWinnerFrame:Show();
	else
		WorldStateScoreWinnerFrame:Hide();
		WorldStateScoreFrameLeaveButton:Hide();
		WorldStateScoreFrameTimerLabel:Hide();
		WorldStateScoreFrameTimer:Hide();
	end
	
	-- Update buttons
	local numScores = GetNumBattlefieldScores();

	local scoreButton, columnButtonIcon;
	local name, kills, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec;
	local teamName, teamRating, newTeamRating, teamMMR;
	local index;
	local columnData;

        -- ScrollFrame update
	local hasScrollBar;
	if ( numScores > MAX_WORLDSTATE_SCORE_BUTTONS ) then
		hasScrollBar = 1;
		WorldStateScoreScrollFrame:Show();
	else
		WorldStateScoreScrollFrame:Hide();
        end
	FauxScrollFrame_Update(WorldStateScoreScrollFrame, numScores, MAX_WORLDSTATE_SCORE_BUTTONS, SCORE_BUTTON_HEIGHT );

	-- Setup Columns
	local text, icon, tooltip, columnButton;
	local numStatColumns = GetNumBattlefieldStats();
	local columnButton, columnButtonText, columnTextButton, columnIcon;
	local lastStatsFrame = "WorldStateScoreFrameHealingDone";
	for i=1, MAX_NUM_STAT_COLUMNS do
		if ( i <= numStatColumns ) then
			text, icon, tooltip = GetBattlefieldStatInfo(i);
			columnButton = _G["WorldStateScoreColumn"..i];
			columnButtonText = _G["WorldStateScoreColumn"..i.."Text"];
			columnButtonText:SetText(text);
			columnButton.icon = icon;
			columnButton.tooltip = tooltip;
			
			columnTextButton = _G["WorldStateScoreButton1Column"..i.."Text"];

			if ( icon ~= "" ) then
				columnTextButton:SetPoint("CENTER", "WorldStateScoreColumn"..i, "CENTER", 6, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			else
				columnTextButton:SetPoint("CENTER", "WorldStateScoreColumn"..i, "CENTER", -1, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			end

			
			if ( i == numStatColumns ) then
				lastStatsFrame = "WorldStateScoreColumn"..i;
			end
		
			_G["WorldStateScoreColumn"..i]:Show();
		else
			_G["WorldStateScoreColumn"..i]:Hide();
		end
	end
	
	-- Anchor the next frame to the last column shown
	firstFrameAfterCustomStats:SetPoint("LEFT", lastStatsFrame, "RIGHT", 5, 0);
	
	-- Last button shown is what the player count anchors to
	local lastButtonShown = "WorldStateScoreButton1";
	local teamDataFailed, coords;
	local scrollOffset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame);

	for i=1, MAX_WORLDSTATE_SCORE_BUTTONS do
		-- Need to create an index adjusted by the scrollframe offset
		index = scrollOffset + i;
		scoreButton = _G["WorldStateScoreButton"..i];
		if ( hasScrollBar ) then
			scoreButton:SetWidth(WorldStateScoreFrame.scrollBarButtonWidth);
		else
			scoreButton:SetWidth(WorldStateScoreFrame.buttonWidth);
		end
		if ( index <= numScores ) then
			
			name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec = GetBattlefieldScore(index);
			
			if ( classToken ) then
				coords = CLASS_BUTTONS[classToken];
				scoreButton.class.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes");
				scoreButton.class.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
				scoreButton.class:Show();
			else
				scoreButton.class:Hide();
			end
			
			scoreButton.name.text:SetText(name);
			if ( not race ) then
				race = "";
			end
			if ( not class ) then
				class = "";
			end
			scoreButton.name.name = name;
			scoreButton.name.tooltip = race.." "..class;
			if ( talentSpec ) then
				_G["WorldStateScoreButton"..i.."ClassButton"].tooltip = format(TALENT_SPEC_AND_CLASS, talentSpec, class);
			else
				_G["WorldStateScoreButton"..i.."ClassButton"].tooltip = class;
			end
			scoreButton.killingBlows:SetText(killingBlows);
			scoreButton.damage:SetText(damageDone);
			scoreButton.healing:SetText(healingDone);
			teamDataFailed = 0;
			teamName, teamRating, newTeamRating, teamMMR = GetBattlefieldTeamInfo(faction);

			if ( not teamRating ) then
				teamDataFailed = 1;
			end
			
			if ( not newTeamRating ) then
				teamDataFailed = 1;
			end

			if ( isArena ) then
				scoreButton.name.text:SetWidth(150);
				if ( isRegistered ) then
					scoreButton.team:SetText(teamName);
					scoreButton.team:Show();
					if ( teamDataFailed == 1 ) then
						scoreButton.ratingChange:SetText("-------");
					else
						if ratingChange > 0 then 
							scoreButton.ratingChange:SetText(GREEN_FONT_COLOR_CODE..ratingChange);
						else
							scoreButton.ratingChange:SetText(RED_FONT_COLOR_CODE..ratingChange);
						end
					end
					scoreButton.ratingChange:Show();
				else
					scoreButton.team:Hide();
					scoreButton.ratingChange:Hide();
				end
				scoreButton.honorableKills:Hide();
				scoreButton.honorGained:Hide();
				scoreButton.deaths:Hide();
			else
				scoreButton.name.text:SetWidth(175);
				scoreButton.deaths:SetText(deaths);
				scoreButton.team:Hide();
				scoreButton.deaths:Show();
				if isRatedBG then
					if battlefieldWinner then
						if ratingChange > 0 then 
							scoreButton.ratingChange:SetText(GREEN_FONT_COLOR_CODE..ratingChange);
						else
							scoreButton.ratingChange:SetText(RED_FONT_COLOR_CODE..ratingChange);
						end
						scoreButton.ratingChange:Show();
					else
						scoreButton.ratingChange:Hide();
					end
					scoreButton.bgRating:SetText(bgRating);
					scoreButton.bgRating:Show();
					scoreButton.honorGained:Hide();
					scoreButton.honorableKills:Hide();
				else 
					scoreButton.honorGained:SetText(floor(honorGained));
					scoreButton.honorGained:Show();
					scoreButton.honorableKills:SetText(honorableKills);
					scoreButton.honorableKills:Show();
					scoreButton.ratingChange:Hide();
					scoreButton.bgRating:Hide();
				end
				scoreButton.matchmakingRating:Hide();
			end
			
			for j=1, MAX_NUM_STAT_COLUMNS do
				columnButtonText = _G["WorldStateScoreButton"..i.."Column"..j.."Text"];
				columnButtonIcon = _G["WorldStateScoreButton"..i.."Column"..j.."Icon"];
				if ( j <= numStatColumns ) then
					-- If there's an icon then move the icon left and format the text with an "x" in front
					columnData = GetBattlefieldStatData(index, j);
					if ( _G["WorldStateScoreColumn"..j].icon ~= "" ) then
						if ( columnData > 0 ) then
							columnButtonText:SetFormattedText(FLAG_COUNT_TEMPLATE, columnData);
							columnButtonIcon:SetTexture(_G["WorldStateScoreColumn"..j].icon..faction);
							columnButtonIcon:Show();
						else
							columnButtonText:SetText("");
							columnButtonIcon:Hide();
						end
						
					else
						columnButtonText:SetText(columnData);
						columnButtonIcon:Hide();
					end
					columnButtonText:Show();
				else
					columnButtonText:Hide();
					columnButtonIcon:Hide();
				end
			end
			if ( faction ) then
				if ( faction == 0 ) then
					if ( isArena ) then
						-- Green Team 
						scoreButton.factionLeft:SetVertexColor(0.19, 0.57, 0.11);
						scoreButton.factionRight:SetVertexColor(0.19, 0.57, 0.11);
						scoreButton.name.text:SetVertexColor(0.1, 1.0, 0.1);
					else
						-- Horde
						scoreButton.factionLeft:SetVertexColor(0.52, 0.075, 0.18);
						scoreButton.factionRight:SetVertexColor(0.5, 0.075, 0.18);
						scoreButton.name.text:SetVertexColor(1.0, 0.1, 0.1);
					end
				else
					if ( isArena ) then
						-- Gold Team 
						scoreButton.factionLeft:SetVertexColor(0.85, 0.71, 0.26);
						scoreButton.factionRight:SetVertexColor(0.85, 0.71, 0.26);
						scoreButton.name.text:SetVertexColor(1, 0.82, 0);
					else
						-- Alliance 
						scoreButton.factionLeft:SetVertexColor(0.11, 0.26, 0.51);
						scoreButton.factionRight:SetVertexColor(0.11, 0.26, 0.51);
						scoreButton.name.text:SetVertexColor(0, 0.68, 0.94);
					end
				end
				if ( ( not isArena ) and ( name == UnitName("player") ) ) then
					scoreButton.name.text:SetVertexColor(1.0, 0.82, 0);
				end
				scoreButton.factionLeft:Show();
				scoreButton.factionRight:Show();
			else
				scoreButton.factionLeft:Hide();
				scoreButton.factionRight:Hide();
			end
			lastButtonShown = scoreButton:GetName();
			scoreButton:Show();
		else
			scoreButton:Hide();
		end
	end
	
	-- Show average matchmaking rating at the bottom	
	if isRatedBG or (isArena and isRegistered) then
		local _, ourAverageMMR, theirAverageMMR;
		local myFaction = GetBattlefieldArenaFaction();
		_, _, _, ourAverageMMR = GetBattlefieldTeamInfo(myFaction);
		_, _, _, theirAverageMMR = GetBattlefieldTeamInfo((myFaction+1)%2);
		WorldStateScoreFrame.teamAverageRating:Show();
		WorldStateScoreFrame.enemyTeamAverageRating:Show();
		WorldStateScoreFrame.teamAverageRating:SetFormattedText(BATTLEGROUND_YOUR_AVERAGE_RATING, ourAverageMMR);
		WorldStateScoreFrame.enemyTeamAverageRating:SetFormattedText(BATTLEGROUND_ENEMY_AVERAGE_RATING, theirAverageMMR);
	else
		WorldStateScoreFrame.teamAverageRating:Hide();
		WorldStateScoreFrame.enemyTeamAverageRating:Hide();
	end
	
	-- Count number of players on each side
	local _, _, _, _, numHorde = GetBattlefieldTeamInfo(0);
	local _, _, _, _, numAlliance = GetBattlefieldTeamInfo(1);
	
	-- Set count text and anchor team count to last button shown
	WorldStateScorePlayerCount:Show();
	if ( numHorde > 0 and numAlliance > 0 ) then
		WorldStateScorePlayerCount:SetText(format(PLAYER_COUNT_ALLIANCE, numAlliance).." / "..format(PLAYER_COUNT_HORDE, numHorde));
	elseif ( numAlliance > 0 ) then
		WorldStateScorePlayerCount:SetFormattedText(PLAYER_COUNT_ALLIANCE, numAlliance);
	elseif ( numHorde > 0 ) then
		WorldStateScorePlayerCount:SetFormattedText(PLAYER_COUNT_HORDE, numHorde);
	else
		WorldStateScorePlayerCount:Hide();
	end
	if ( isArena ) then
		WorldStateScorePlayerCount:Hide();
	end


	if GetBattlefieldInstanceRunTime() > 60000 then
		WorldStateScoreBattlegroundRunTime:Show();
		WorldStateScoreBattlegroundRunTime:SetText(TIME_ELAPSED.." "..SecondsToTime(GetBattlefieldInstanceRunTime()/1000, true));
	else
		WorldStateScoreBattlegroundRunTime:Hide();
	end
end

function WorldStateScoreFrame_Resize()
	local isArena, isRegistered = IsActiveBattlefieldArena();
	local isRatedBG = IsRatedBattleground();
	
	local columns = WORLDSTATESCOREFRAME_BASE_COLUMNS;
	local scrollBar = 37;
	local name;
	
	local width = WorldStateScoreFrameName:GetWidth() + WorldStateScoreFrameClass:GetWidth();

	if ( isArena ) then
		columns = 3;
		if ( isRegistered ) then
			columns = 4;
			width = width + WorldStateScoreFrameTeam:GetWidth();
		else
			width = width + 43;
		end
	elseif ( isRatedBG ) then
		if not GetBattlefieldWinner() then
			columns = columns - 1;
		end
	end

	columns = columns + GetNumBattlefieldStats();

	width = width + (columns*WORLDSTATESCOREFRAME_COLUMN_SPACING);

	if ( WorldStateScoreScrollFrame:IsShown() ) then
		width = width + scrollBar;
	end
	
	WorldStateScoreFrame:SetWidth(width);
	
	WorldStateScoreFrame.scrollBarButtonWidth = WorldStateScoreFrame:GetWidth() - 165;
	WorldStateScoreFrame.buttonWidth = WorldStateScoreFrame:GetWidth() - 137;
	WorldStateScoreScrollFrame:SetWidth(WorldStateScoreFrame.scrollBarButtonWidth);

	-- Position Column data horizontally
	for i=1, MAX_WORLDSTATE_SCORE_BUTTONS do
		local scoreButton = _G["WorldStateScoreButton"..i];
		
		if ( i == 1 ) then
			scoreButton.team:SetPoint("LEFT", "WorldStateScoreFrameTeam", "LEFT", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.matchmakingRating:SetPoint("CENTER", "WorldStateScoreFrameMatchmakingRating", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.bgRating:SetPoint("CENTER", "WorldStateScoreFrameBgRating", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.ratingChange:SetPoint("CENTER", "WorldStateScoreFrameRatingChange", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.honorableKills:SetPoint("CENTER", "WorldStateScoreFrameHK", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.killingBlows:SetPoint("CENTER", "WorldStateScoreFrameKB", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.deaths:SetPoint("CENTER", "WorldStateScoreFrameDeaths", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.damage:SetPoint("CENTER", "WorldStateScoreFrameDamageDone", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.healing:SetPoint("CENTER", "WorldStateScoreFrameHealingDone", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.honorGained:SetPoint("CENTER", "WorldStateScoreFrameHonorGained", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			for j=1, MAX_NUM_STAT_COLUMNS do
				_G["WorldStateScoreButton"..i.."Column"..j.."Text"]:SetPoint("CENTER", _G["WorldStateScoreColumn"..j], "CENTER", 0,  WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			end
		else
			scoreButton.team:SetPoint("LEFT", "WorldStateScoreButton"..(i-1).."Team", "LEFT", 0,  -SCORE_BUTTON_HEIGHT);
			scoreButton.matchmakingRating:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."MatchmakingRating", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.bgRating:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."BgRating", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.ratingChange:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."RatingChange", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.honorableKills:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."HonorableKills", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.killingBlows:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."KillingBlows", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.deaths:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."Deaths", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.damage:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."Damage", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.healing:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."Healing", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.honorGained:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."HonorGained", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			for j=1, MAX_NUM_STAT_COLUMNS do
				_G["WorldStateScoreButton"..i.."Column"..j.."Text"]:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."Column"..j.."Text", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			end
		end
	end
	return width;
end

function WorldStateScoreFrameTab_OnClick(tab)
	local faction = tab:GetID();
	PanelTemplates_SetTab(WorldStateScoreFrame, faction);
	if ( faction == 2 ) then
		faction = 1;
	elseif ( faction == 3 ) then
		faction = 0;
	else
		faction = nil;
	end
	WorldStateScoreFrameLabel:SetFormattedText(STAT_TEMPLATE, tab:GetText());
	SetBattlefieldScoreFaction(faction);
	PlaySound("igCharacterInfoTab");
end

function ToggleWorldStateScoreFrame()
	if ( WorldStateScoreFrame:IsShown() ) then
		HideUIPanel(WorldStateScoreFrame);
	else
		--Make sure we're in an active BG
		local inBattlefield = false;
		for i=1, GetMaxBattlefieldID() do
			local status = GetBattlefieldStatus(i);
			if ( status == "active" ) then
				inBattlefield = true;
				break;
			end
		end

		if ( ( not IsActiveBattlefieldArena() or GetBattlefieldWinner() ) and inBattlefield ) then
			ShowUIPanel(WorldStateScoreFrame);
		end
	end
end

-- Report AFK feature
local AFK_PLAYER_CLICKED = nil;

function ScorePlayer_OnClick(self, mouseButton)
	if ( mouseButton == "RightButton" ) then
		if ( not UnitIsUnit(self.name,"player") and UnitInRaid(self.name)) then
			AFK_PLAYER_CLICKED = self.name;
			ToggleDropDownMenu(1, nil, ScorePlayerDropDown, self:GetName(), 0, -5);
		end
	elseif ( mouseButton == "LeftButton" and IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		ChatEdit_InsertLink(self.text:GetText());
	end
end

function ScorePlayerDropDown_OnClick()
	ReportPlayerIsPVPAFK(AFK_PLAYER_CLICKED);
	PlaySound("UChatScrollButton");
	AFK_PLAYER_CLICKED = nil;
end

function ScorePlayerDropDown_Cancel()
	AFK_PLAYER_CLICKED = nil;
	PlaySound("UChatScrollButton");
end

function ScorePlayerDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.text = PVP_REPORT_AFK;
	info.func = ScorePlayerDropDown_OnClick;
	UIDropDownMenu_AddButton(info);

	info = UIDropDownMenu_CreateInfo();
	info.text = CANCEL;
	info.func = ScorePlayerDropDown_Cancel;
	UIDropDownMenu_AddButton(info);
end

--
-- Challenge Mode - only 1 timer for now, needs some work for multiple timers
--

-- WatchFrame handler function
function WorldStateChallengeMode_DisplayTimers(lineFrame, nextAnchor, maxHeight, frameWidth)
	local self = WorldStateChallengeModeFrame;
	if ( self.timerID ) then
		self:SetParent(lineFrame);
		if (nextAnchor) then
			self:SetPoint("TOPLEFT", nextAnchor, "BOTTOMLEFT", 0, -WATCHFRAME_TYPE_OFFSET);
		else
			self:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", 0, -WATCHFRAME_INITIAL_OFFSET)
		end
		local _, elapsedTime = GetWorldElapsedTime(self.timerID);
		WorldStateChallengeModeTimer.baseTime = elapsedTime;
		WorldStateChallengeModeTimer.timeSinceBase = 0;
		WorldStateChallengeModeTimer.frame = self;
		self:Show();
		return self, 198, 0, 1;
	else
		-- handler should have been removed before this...
		self:Hide();
		return nextAnchor, 0, 0, 0;
	end
end

function WorldStateChallengeMode_CheckTimers(...)
	for i = 1, select("#", ...) do
		local timerID = select(i, ...);
		local _, elapsedTime, isChallengeModeTimer = GetWorldElapsedTime(timerID);
		if ( isChallengeModeTimer ) then
			local _, _, _, _, _, _, _, mapID = GetInstanceInfo();
			if ( mapID ) then
				WorldStateChallengeMode_ShowTimer(timerID, elapsedTime, GetChallengeModeMapTimes(mapID));
				return;
			end
		end	
	end
	WorldStateChallengeMode_HideTimer();
end

function WorldStateChallengeMode_ShowTimer(timerID, elapsedTime, ...)
	local self = WorldStateChallengeModeFrame;
	if not ( self.medalTimes ) then
		self.medalTimes = { };
	end
	for i = 1, select("#", ...) do
		self.medalTimes[i] = select(i, ...);
	end
	-- not currently being displayed, set up handler
	if ( not self.timerID ) then
		WatchFrame_AddObjectiveHandler(WorldStateChallengeMode_DisplayTimers, 1);
		if ( WatchFrame_RemoveObjectiveHandler(WatchFrame_DisplayTrackedQuests) ) then
			self.hidWatchedQuests = true;
		end
	end
	self.timerID = timerID;
	WorldStateChallengeModeFrame_UpdateMedal(self, elapsedTime);
	WorldStateChallengeModeFrame_UpdateValues(self, elapsedTime);
	WatchFrame_ClearDisplay();
	WatchFrame_Expand(WatchFrame);	-- will automatically do a watchframe update
	WorldStateChallengeModeTimer:Show();
end

function WorldStateChallengeMode_HideTimer(timerID)
	local self = WorldStateChallengeModeFrame;
	if ( not timerID or self.timerID == timerID ) then
		self.timerID = nil;
		if ( self.hidWatchedQuests ) then
			WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests);
		end
		self:Hide();
		WorldStateChallengeModeTimer:Hide();
		self.lastMedalShown = nil;
		WatchFrame_RemoveObjectiveHandler(WorldStateChallengeMode_DisplayTimers);
		WatchFrame_ClearDisplay();
		WatchFrame_Update(WatchFrame);
	end
end

function WorldStateChallengeModeFrame_UpdateMedal(self, elapsedTime)
	-- find best medal for current time
	local prevMedalTime = 0;
	for i = #self.medalTimes, 1, -1 do
		local currentMedalTime = self.medalTimes[i];
		if ( elapsedTime < currentMedalTime ) then
			self.statusBar:SetMinMaxValues(0, currentMedalTime - prevMedalTime);
			self.statusBar.medalTime = currentMedalTime;
			if ( CHALLENGE_MEDAL_TEXTURES[i] ) then
				self.medalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES[i]);
				self.medalIcon:Show();
				self.GlowFrame.MedalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES[i]);
				self.GlowFrame.MedalGlowAnim:Play();
			end
			self.noMedal:Hide();
			-- play sound if medal changed
			if ( self.lastMedalShown and self.lastMedalShown ~= i ) then
				if ( self.lastMedalShown == CHALLENGE_MEDAL_GOLD ) then
					PlaySound("UI_Challenges_MedalExpires_GoldtoSilver");
				elseif ( self.lastMedalShown == CHALLENGE_MEDAL_SILVER ) then
					PlaySound("UI_Challenges_MedalExpires_SilvertoBronze");
				else
					PlaySound("UI_Challenges_MedalExpires");
				end
			end
			self.lastMedalShown = i;
			return;
		else
			prevMedalTime = currentMedalTime;
		end
	end
	-- no medal
	self.statusBar.timeLeft:SetText(CHALLENGES_TIMER_NO_MEDAL);
	self.statusBar:SetValue(0);
	self.statusBar.medalTime = nil;
	self.noMedal:Show();
	self.medalIcon:Hide();
	-- play sound if medal changed
	if ( self.lastMedalShown and self.lastMedalShown ~= 0 ) then
		PlaySound("UI_Challenges_MedalExpires");
	end
	self.lastMedalShown = 0;
end

function WorldStateChallengeModeFrame_UpdateValues(self, elapsedTime)
	local statusBar = self.statusBar;
	if ( statusBar.medalTime ) then
		local timeLeft = statusBar.medalTime - elapsedTime;
		local anim = self.GlowFrame.MedalPulseAnim;
		if (timeLeft <= 5) then
			if (anim:IsPlaying()) then 
				anim.timeLeft = timeLeft;
			else
				self.GlowFrame.MedalPulseAnim:Play();
			end
		end
		if (timeLeft == 10) then
			if (not self.playedSound) then
				PlaySoundKitID(34154);
				self.playedSound = true;
			end
		else
			self.playedSound = false;
		end
		if ( timeLeft < 0 ) then
			WorldStateChallengeModeFrame_UpdateMedal(self, elapsedTime);
		else
			statusBar:SetValue(statusBar.medalTime - elapsedTime);
			statusBar.timeLeft:SetText(GetTimeStringFromSeconds(statusBar.medalTime - elapsedTime));
		end
	end
end

function WorldStateChallengeModeAnim_OnFinished(self)
	if (self.timeLeft and self.timeLeft > 0 and self.timeLeft < 5) then
		self:Play();
	else
		self.timeLeft = nil;
	end
end

local floor = floor;
function WorldStateChallengeModeTimer_OnUpdate(self, elapsed)
	self.timeSinceBase = self.timeSinceBase + elapsed;
	WorldStateChallengeModeFrame_UpdateValues(self.frame, floor(self.baseTime + self.timeSinceBase));
end
