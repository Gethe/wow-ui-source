
local ADDON_NAME = ...;

TOURNAMENT_OBSERVE_PLAYER_PRIMARY = 1;
TOURNAMENT_OBSERVE_PLAYER_SECONDARY = 2;
TOURNAMENT_OBSERVE_PLAYER_PRIMARY_SNAP = 3;

local TOURNAMENTARENA_ZONESTATE_SCANNING = "scanning";					-- [ Waiting to join a match ] --
local TOURNAMENTARENA_ZONESTATE_TRANSFERRING_IN = "transferring_in";		-- [ Joining a match ] --
local TOURNAMENTARENA_ZONESTATE_TRANSFERRING_OUT = "transferring_out";	-- [ Leaving a match ] --
local TOURNAMENTARENA_ZONESTATE_PREMATCH = "prematch";					-- [ In a match that hasn't started ] --
local TOURNAMENTARENA_ZONESTATE_OBSERVING = "observing";					-- [ In a match that has started] --
local TOURNAMENTARENA_ZONESTATE_SCOREBOARD = "scoreboard";				-- [ Match is over, at the scoreboard ] --
local TOURNAMENTARENA_ZONESTATE_RESETTING = "resetting";					-- [ A reset was requested, determining the appropriate state to be in ] --

local MAX_PLAYERS_FOR_STANDARD = 3;
local MAX_PLAYERS_FOR_COMPACT = 6;
local MAX_PLAYERS_FOR_VERY_COMPACT = 10;

local followCameraTransitionSpeedPresets = {
	{ 0.05, 20.0 },
	{ 0.10, 30.0 },
	{ 0.03, 15.0 },
}

local TournamentObserverCurrentFollowCameraPreset = 1;
function SetFollowCameraTransitionPreset(index)
	C_Commentator.SetFollowCameraSpeeds(unpack(followCameraTransitionSpeedPresets[index]));
	TournamentObserverCurrentFollowCameraPreset = index;
end

function CycleFollowCameraTransitionPreset(index)
	TournamentObserverCurrentFollowCameraPreset = TournamentObserverCurrentFollowCameraPreset + 1;
	if TournamentObserverCurrentFollowCameraPreset > #followCameraTransitionSpeedPresets then
		TournamentObserverCurrentFollowCameraPreset = 1;
	end
	
	C_Commentator.SetFollowCameraSpeeds(unpack(followCameraTransitionSpeedPresets[TournamentObserverCurrentFollowCameraPreset]));
end

function SetSpectatorModeForOtherFrames(spectatorMode)
	if (UIWidgetTopCenterContainerFrame) then
		UIWidgetTopCenterContainerFrame:SetSpectatorMode(spectatorMode, CommentatorTeamDisplay);
	end
	if (BattlefieldMapFrame) then
		BattlefieldMapFrame:SetSpectatorMode(spectatorMode);
	end
end

PvPCommentatorMixin = {};

function PvPCommentatorMixin:OnLoad()
	self.cameraMoveSpeed = 7;

	self.unitFrames = {};
	self.sortedUnitFrames = {};
	self.showUnitFrames = true;
	local TEAM_POSITIONS = { "left", "right", };

	for teamIndex = 1, C_Commentator.GetMaxNumTeams() do
		self.unitFrames[teamIndex] = {};
		
		for playerIndex = 1, C_Commentator.GetMaxNumPlayersPerTeam() do
			local newFrame = CreateFrame("FRAME", nil, WorldFrame, "CommentatorUnitFrameTemplate");
			newFrame:Initialize(TEAM_POSITIONS[teamIndex]);
			self.unitFrames[teamIndex][playerIndex] = newFrame;
		end
	end
	
	self:RegisterEvent("COMMENTATOR_ENTER_WORLD");
	self:RegisterEvent("COMMENTATOR_PLAYER_UPDATE");
	self:RegisterEvent("COMMENTATOR_PLAYER_NAME_OVERRIDE_UPDATE");

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LEAVING_WORLD");

	self:RefreshTeamFrameLayout();

	self.state = TOURNAMENTARENA_ZONESTATE_SCANNING;
	self:CheckObserverState();
	
	SetFollowCameraTransitionPreset(1);
end

function PvPCommentatorMixin:ObservePlayer(teamIndex, playerIndex, observationType)
	local unitFrame = self.sortedUnitFrames[teamIndex] and self.sortedUnitFrames[teamIndex][playerIndex];
	if unitFrame and unitFrame:IsValid() then
		teamIndex, playerIndex = unitFrame:GetTeamAndPlayer();

		if C_Commentator.IsUsingSmartCamera() then
			if observationType == TOURNAMENT_OBSERVE_PLAYER_PRIMARY then
				C_Commentator.LookAtPlayer(teamIndex, playerIndex, 1);
			
			-- There are three modes for the follow came and only two for smart cam so TOURNAMENT_OBSERVE_PLAYER_PRIMARY_SNAP is the same as TOURNAMENT_OBSERVE_PLAYER_SECONDARY.
			elseif observationType == TOURNAMENT_OBSERVE_PLAYER_PRIMARY_SNAP or observationType == TOURNAMENT_OBSERVE_PLAYER_SECONDARY then
				C_Commentator.LookAtPlayer(teamIndex, playerIndex, 2);
			end
		else
			if observationType == TOURNAMENT_OBSERVE_PLAYER_PRIMARY then
				C_Commentator.FollowPlayer(teamIndex, playerIndex);
			elseif observationType == TOURNAMENT_OBSERVE_PLAYER_SECONDARY then
				C_Commentator.LookAtPlayer(teamIndex, playerIndex);
			elseif observationType == TOURNAMENT_OBSERVE_PLAYER_PRIMARY_SNAP then
				C_Commentator.FollowPlayer(teamIndex, playerIndex, true);
			end
		end
	end
end

function PvPCommentatorMixin:ModifyCameraSpeed(speed)
	self.cameraMoveSpeed = math.max(math.min(40, self.cameraMoveSpeed + speed), 1);
	C_Commentator.SetMoveSpeed(self.cameraMoveSpeed);
end

function PvPCommentatorMixin:ResetCommentator()	
	if C_Commentator.IsSpectating() then
		self:SetObserverState(TOURNAMENTARENA_ZONESTATE_RESETTING);
	else
		CommentatorFadeToBlackFrame:Stop();
		CommentatorTeamDisplay:Hide();
		self:SetAllUnitFramesVisibilityState(false);
		self:SetFrameLock(false);
		SetSpectatorModeForOtherFrames(false);
		self.state = TOURNAMENTARENA_ZONESTATE_SCANNING;
	end
end

function PvPCommentatorMixin:SetFrameLock(enabled)
	if enabled then
		C_Commentator.SetMouseDisabled(true);
		AddFrameLock("COMMENTATOR_SPECTATING_MODE");
	else
		C_Commentator.SetMouseDisabled(false);
		RemoveFrameLock("COMMENTATOR_SPECTATING_MODE");
	end
end

function PvPCommentatorMixin:ToggleUnitFrames()
	self.showUnitFrames = not self.showUnitFrames;
	self:RefreshTeamFrameLayout();
end

function PvPCommentatorMixin:ToggleFrameLock()
	if IsFrameLockActive("COMMENTATOR_SPECTATING_MODE") then
		self:SetFrameLock(false);
	else
		self:SetFrameLock(true);
	end
end

function PvPCommentatorMixin:SetDefaultBindings()
	SetBinding("\\", "TOGGLEGAMEMENU");

	SetBinding("]", "COMMENTATORMOVESPEEDINCREASE");
	SetBinding("[", "COMMENTATORMOVESPEEDDECREASE");
	
	SetBinding("MOUSEWHEELUP", "COMMENTATORZOOMIN");
	SetBinding("MOUSEWHEELDOWN", "COMMENTATORZOOMOUT");

	SetBinding("ESCAPE", "COMMENTATORLOOKATNONE");
	
	SetBinding("F1",		"COMMENTATORFOLLOW_1_1");
	SetBinding("F2",		"COMMENTATORFOLLOW_1_2");
	SetBinding("F3",		"COMMENTATORFOLLOW_1_3");
	SetBinding("F4",		"COMMENTATORFOLLOW_1_4");
	SetBinding("F5",		"COMMENTATORFOLLOW_1_5");
	SetBinding("F6",		"COMMENTATORFOLLOW_1_6");
	SetBinding("F7",		"COMMENTATORFOLLOW_2_1");
	SetBinding("F8",		"COMMENTATORFOLLOW_2_2");
	SetBinding("F9",		"COMMENTATORFOLLOW_2_3");
	SetBinding("F10",		"COMMENTATORFOLLOW_2_4");
	SetBinding("F11",		"COMMENTATORFOLLOW_2_5");
	SetBinding("F12",		"COMMENTATORFOLLOW_2_6");
	
	SetBinding("1",			"COMMENTATORFOLLOW_1_1_SNAP");
	SetBinding("2",			"COMMENTATORFOLLOW_1_2_SNAP");
	SetBinding("3",			"COMMENTATORFOLLOW_1_3_SNAP");
	SetBinding("4",			"COMMENTATORFOLLOW_1_4_SNAP");
	SetBinding("5",			"COMMENTATORFOLLOW_1_5_SNAP");
	SetBinding("6",			"COMMENTATORFOLLOW_1_6_SNAP");
	SetBinding("7",			"COMMENTATORFOLLOW_2_1_SNAP");
	SetBinding("8",			"COMMENTATORFOLLOW_2_2_SNAP");
	SetBinding("9",			"COMMENTATORFOLLOW_2_3_SNAP");
	SetBinding("0",			"COMMENTATORFOLLOW_2_4_SNAP");
	SetBinding("-",			"COMMENTATORFOLLOW_2_5_SNAP");
	SetBinding("=",			"COMMENTATORFOLLOW_2_6_SNAP");
	
	SetBinding("CTRL-SHIFT-R", "COMMENTATORRESET");
	
	SetBinding(",", "TEAM_1_ADD_SCORE");
	SetBinding(".", "TEAM_2_ADD_SCORE");
	SetBinding("SHIFT-,", "TEAM_1_REMOVE_SCORE");
	SetBinding("SHIFT-.", "TEAM_2_REMOVE_SCORE");
	SetBinding("U", "RESET_SCORE_COUNT");
	SetBinding("/", "SWAPUNITFRAMES");
	
	SetBinding("TAB", "TOGGLE_SMART_CAMERA");
	
	SetBinding("N", "TOGGLE_CASTER_COOLDOWN_DISPLAY");
	SetBinding("CTRL-SHIFT-N", "CHECK_FOR_SCOREBOARD");
	SetBinding("SHIFT-N", "TOGGLE_NAMEPLATE_SIZE");
	
	SetBinding("CAPSLOCK", "TOGGLE_SMART_CAMERA_LOCK");

	SetBinding("SHIFT-SPACE", nil);
	
	SetBinding("F", "FORCEFOLLOWTRANSITON");
	SetBinding("T", "TOGGLESMOOTHFOLLOWTRANSITIONS");
	SetBinding("C", "TOGGLECAMERACOLLISION");
	SetBinding("V", "CYCLEFOLLOWTRANSITONSPEED");

	SetBinding("M", "TOGGLEBATTLEFIELDMINIMAP");
	SetBinding("B", "TOGGLEWORLDSTATESCORES");
	SetBinding("L", "TOGGLE_COMMENTATOR_UNIT_FRAMES");

	AttemptToSaveBindings(GetCurrentBindingSet());
end

function PvPCommentatorMixin:SetNeedsFullRefresh(needed)
	self.needsFullRefresh = needed;
end

function PvPCommentatorMixin:NeedsFullRefresh()
	return self.needsFullRefresh;
end

function PvPCommentatorMixin:IsCompact()
	return self.compactLevel >= COMMENTATOR_UNIT_FRAME_COMPACT;
end

function PvPCommentatorMixin:IsVeryCompact()
	return self.compactLevel >= COMMENTATOR_UNIT_FRAME_VERY_COMPACT;
end

function PvPCommentatorMixin:IsExtremelyCompact()
	return self.compactLevel >= COMMENTATOR_UNIT_FRAME_EXTREMELY_COMPACT;
end

function PvPCommentatorMixin:OnUpdate(elapsed)
	if not IsPlayerInWorld() then return end
	
	if self:NeedsFullRefresh() then
		self:FullPlayerRefresh();
	end
	
	self:CheckObserverState();
	self:LayoutTeamFrames();


	self.targetSpeedFactor = IsShiftKeyDown() and 2.0 or 1.0;
	self.currentSpeedFactor = DeltaLerp(self.currentSpeedFactor or 1.0, self.targetSpeedFactor, .05, elapsed);
	C_Commentator.SetSpeedFactor(self.currentSpeedFactor);

	-- We need to always keep UI visibility on as this controls whether nameplates are visible, however commands like TOGGLEUI (Alt+Z) 
	-- might turn this off if commentators need to briefly enable the default UI to adjust something and then hide it
		-- "SetInWorldUIVisibility" is a new function that enables nameplates, etc. but doesn't affect the actual UI frames
	SetInWorldUIVisibility(true);
end

function PvPCommentatorMixin:SetDefaultCommentatorSettings()
	self:SetDefaultBindings();
	self:SetDefaultCVars();
end

function PvPCommentatorMixin:SetDefaultCVars()
	SetCVar("UnitNameFriendlyPlayerName", 1);
	SetCVar("UnitNameFriendlyPetName", 1);
	SetCVar("UnitNameFriendlyGuardianName", 0);
	SetCVar("UnitNameFriendlyTotemName", 0);
	
	SetCVar("UnitNameEnemyPlayerName", 1);
	SetCVar("UnitNameEnemyPetName", 0);
	SetCVar("UnitNameEnemyGuardianName", 0);
	SetCVar("UnitNameEnemyTotemName", 0);

	SetCVar("Sound_ListenerAtCharacter", 0);

	SetCVar("nameplateShowEnemies", 1);
	SetCVar("nameplateShowEnemyPets", 1);
	SetCVar("nameplateShowEnemyGuardians", 0);
	SetCVar("nameplateShowEnemyTotems", 0);
	SetCVar("nameplateShowEnemyMinus", 0);
	SetCVar("nameplateShowFriends", 1);
	SetCVar("nameplateShowFriendlyPets", 0);
	SetCVar("nameplateShowFriendlyGuardians", 0);
	SetCVar("nameplateShowFriendlyTotems", 0);

	SetCVar("nameplateSelectedScale", 1.5);
	SetCVar("nameplateShowAll", 1);

	-- See InterfaceOptionsNPCNamesDropDown, we want these all off.
	-- SetCVar("UnitNameFriendlySpecialNPCName", 0);	-- CVar removed in Classic 7.3.5
	-- SetCVar("UnitNameHostleNPC", 0);					-- CVar removed in Classic 7.3.5
	-- SetCVar("UnitNameInteractiveNPC", 0);			-- CVar removed in Classic 7.3.5
	SetCVar("UnitNameNPC", 0);
	
	SetCVar("nameplateMotion", 0);
		
	SetCVar("showVKeyCastbar", 0);
	
	SetCVar("deselectOnClick", 1);

	SetCVar("maxfpsbk", 0);

	SetCVar("showSpectatorTeamCircles", 1);
	
	SetCVar("ShowClassColorInNameplate", "1");
	SetCVar("ShowClassColorInFriendlyNameplate", "1");
	
	SetCVar("nameplateMinAlpha", ".75");
	
	SetCVar("nameplateOccludedAlphaMult", "1.0");
	SetCVar("UnitNamePlayerGuild", "0");
	SetCVar("UnitNameEnemyMinionName", "0");
	SetCVar("UnitNameFriendlyMinionName", "0");
	
	SetCVar("chatStyle", "classic");

	SetCVar("colorNameplateNameBySelection", 1);
end

function PvPCommentatorMixin:OnEvent(event, ...)
	if event == "COMMENTATOR_ENTER_WORLD" then
		local mapID = select(8, GetInstanceInfo());
		local pos = C_Commentator.GetStartLocation(mapID);
		if pos then
			CommentatorFadeToBlackFrame:ReverseStart();
			local SNAP_TO_POSITION = true;
			C_Commentator.SetUseSmartCamera(true);
			C_Commentator.SetSmartCameraLocked(false);
			C_Commentator.SetCameraPosition(pos.x, pos.y, pos.z, SNAP_TO_POSITION);
			C_Commentator.SnapCameraLookAtPoint();
		end
	elseif event == "COMMENTATOR_PLAYER_UPDATE" then
		self:FullPlayerRefresh();
	elseif event == "COMMENTATOR_PLAYER_NAME_OVERRIDE_UPDATE" then
		self:FullPlayerRefresh();
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:ResetCommentator();
	elseif event == "PLAYER_LEAVING_WORLD" then
		self:SetNeedsFullRefresh(true);
	end
end

function PvPCommentatorMixin:ExitInstance()
	if C_Commentator.CanUseCommentatorCheats() then
		C_Commentator.ExitInstance();
	else
		ConfirmOrLeaveBattlefield();
	end
end

do
	local function UnitFrameComparator(left, right)
		if left:IsValid() and right:IsValid() then
			local leftRole = left:GetRole();
			local rightRole = right:GetRole();
			if leftRole ~= rightRole then
				if leftRole == "HEALER" then
					return true;
				elseif rightRole == "HEALER" then
					return false;
				end

				if leftRole == "TANK" then
					return true;
				elseif rightRole == "TANK" then
					return false;
				end
			end

			return strcmputf8i(left:GetPlayerName(), right:GetPlayerName()) < 0;
		end
		return left:IsValid();
	end

	function PvPCommentatorMixin:EnumerateSortedUnitFrames(teamIndex)
		if not self.sortedUnitFrames[teamIndex] then
			self.sortedUnitFrames[teamIndex] = {};

			for playerIndex = 1, #self.unitFrames[teamIndex] do
				self.sortedUnitFrames[teamIndex][playerIndex] = self.unitFrames[teamIndex][playerIndex];
			end

			table.sort(self.sortedUnitFrames[teamIndex], UnitFrameComparator);
		end
		
		return ipairs(self.sortedUnitFrames[teamIndex]);
	end
end

function PvPCommentatorMixin:LayoutTeamFrames()
	if not self.needsFullFrameLayout then return end
	self.needsFullFrameLayout = false;

	local Y_START = self:IsVeryCompact() and -2 or self:IsCompact() and -50 or -25;
	local Y_PADDING = self:IsExtremelyCompact() and -63 or self:IsVeryCompact() and -94 or self:IsCompact() and -145 or -230;
	local X_OFFSET = self:IsExtremelyCompact() and 5 or self:IsVeryCompact() and 10 or 20;

	for teamIndex = 1, #self.unitFrames do
		local offsetY = Y_START;
		local paddingY = Y_PADDING;
		local offsetX = X_OFFSET;
		local paddingX = 0;
		for sortedIndex, unitFrame in self:EnumerateSortedUnitFrames(teamIndex) do
			if (self.showUnitFrames) then
				unitFrame:ClearAllPoints();

				if unitFrame:IsValid() then
					-- If we get over 15 frames, show 2 columns.
					-- (There needs to be some cleanup to get this actually looking decent.)
					if (self:IsExtremelyCompact()) then
						if (sortedIndex == 16) then
							offsetY = Y_START;
							paddingY = Y_PADDING;
							offsetX = X_OFFSET + 170;
							paddingX = 0;
						end
					end

					local newYOffset = offsetY + unitFrame:GetAdditionalYSpacing();
			
					if unitFrame.align == "right" then
						unitFrame:SetPoint("TOPRIGHT", WorldFrame, -offsetX, newYOffset);
					else
						unitFrame:SetPoint("TOPLEFT", WorldFrame, offsetX, newYOffset);
					end

					offsetY = offsetY + paddingY;
					offsetX = offsetX + paddingX;

					unitFrame:Show();
				end
			else
				unitFrame:Hide();
			end
		end
	end
end

function PvPCommentatorMixin:RefreshTeamFrameLayout()
	self.needsFullFrameLayout = true;
end

function PvPCommentatorMixin:FullPlayerRefresh()
	self:SetNeedsFullRefresh(false);
	
	self.sortedUnitFrames = {};
	local maxPlayersPerTeam = 0;

	for teamIndex = 1, #self.unitFrames do
		local playersOnTeam = 0;
		for playerIndex = 1, #self.unitFrames[teamIndex] do
			C_Commentator.RequestPlayerCooldownInfo(teamIndex, playerIndex);
			local unitFrame = self.unitFrames[teamIndex][playerIndex];
			unitFrame:SetTeamAndPlayer(teamIndex, playerIndex);
			if unitFrame:IsValid() then
				playersOnTeam = playersOnTeam + 1;
			end
		end

		maxPlayersPerTeam = math.max(playersOnTeam, maxPlayersPerTeam);
	end

	if (maxPlayersPerTeam > MAX_PLAYERS_FOR_STANDARD) then
		if (maxPlayersPerTeam > MAX_PLAYERS_FOR_COMPACT) then
			if (maxPlayersPerTeam > MAX_PLAYERS_FOR_VERY_COMPACT) then
				self.compactLevel = COMMENTATOR_UNIT_FRAME_EXTREMELY_COMPACT;
			else
				self.compactLevel = COMMENTATOR_UNIT_FRAME_VERY_COMPACT;
			end
		else
			self.compactLevel = COMMENTATOR_UNIT_FRAME_COMPACT;
		end
	else
		self.compactLevel = COMMENTATOR_UNIT_FRAME_STANDARD;
	end
	
	for teamIndex = 1, #self.unitFrames do
		for playerIndex = 1, #self.unitFrames[teamIndex] do
			self.unitFrames[teamIndex][playerIndex]:SetCompact(self.compactLevel);
		end
	end
	
	self:RefreshTeamFrameLayout();
end

function PvPCommentatorMixin:InvalidateAllPlayers()
	self.sortedUnitFrames = {};

	for teamIndex = 1, #self.unitFrames do
		for playerIndex = 1, #self.unitFrames[teamIndex] do
			self.unitFrames[teamIndex][playerIndex]:Invalidate();
		end
	end
	
	self:RefreshTeamFrameLayout();
end

function PvPCommentatorMixin:SetAllUnitFramesVisibilityState(visible)
	for teamIndex = 1, #self.unitFrames do
		for playerIndex = 1, #self.unitFrames[teamIndex] do
			self.unitFrames[teamIndex][playerIndex]:SetVisibility(visible);
		end
	end
end

function PvPCommentatorMixin:CheckObserverState()
	local isSpectating = C_Commentator.IsSpectating();

	if self.state == TOURNAMENTARENA_ZONESTATE_TRANSFERRING_IN then
		if isSpectating then
			self:SetObserverState(TOURNAMENTARENA_ZONESTATE_PREMATCH);
		end
	elseif self.state == TOURNAMENTARENA_ZONESTATE_TRANSFERRING_OUT then
		if not isSpectating then
			self:SetObserverState(TOURNAMENTARENA_ZONESTATE_SCANNING);
		end
	elseif self.state == TOURNAMENTARENA_ZONESTATE_SCANNING then
		if isSpectating then
			if C_Commentator.GetTimeLeftInMatch() then
				self:SetObserverState(TOURNAMENTARENA_ZONESTATE_OBSERVING);
			else
				self:SetObserverState(TOURNAMENTARENA_ZONESTATE_PREMATCH);
			end
		end
	elseif self.state == TOURNAMENTARENA_ZONESTATE_PREMATCH then
		if isSpectating then
			if C_Commentator.GetTimeLeftInMatch() then
				self:SetObserverState(TOURNAMENTARENA_ZONESTATE_OBSERVING);
			end
		else
			self:SetObserverState(TOURNAMENTARENA_ZONESTATE_SCANNING);
		end
	elseif self.state == TOURNAMENTARENA_ZONESTATE_OBSERVING then
		if not isSpectating then
			self:SetObserverState(TOURNAMENTARENA_ZONESTATE_SCANNING);
		end
	elseif self.state == TOURNAMENTARENA_ZONESTATE_RESETTING then
		if isSpectating then
			C_Commentator.ResetFoVTarget();
			if C_Commentator.GetTimeLeftInMatch() then
				self:SetObserverState(TOURNAMENTARENA_ZONESTATE_OBSERVING);
			else
				self:SetObserverState(TOURNAMENTARENA_ZONESTATE_PREMATCH);
			end
		else
			self:SetObserverState(TOURNAMENTARENA_ZONESTATE_SCANNING);
		end
	end
end

function PvPCommentatorMixin:SetObserverState(state)
	if state ~= self.state then
		local oldState = self.state;
		self.state = state;
		self:OnObserverStateChanged(oldState, state);
	end
end

function PvPCommentatorMixin:OnObserverStateChanged(oldState, newState)
	if newState == TOURNAMENTARENA_ZONESTATE_TRANSFERRING_IN or newState == TOURNAMENTARENA_ZONESTATE_TRANSFERRING_OUT then
		self:InvalidateAllPlayers();

		self:SetFrameLock(true);
		SetSpectatorModeForOtherFrames(true);

		ClearTarget();

		CommentatorTeamDisplay:Hide();
		self:SetAllUnitFramesVisibilityState(false);
	elseif newState == TOURNAMENTARENA_ZONESTATE_OBSERVING or newState == TOURNAMENTARENA_ZONESTATE_PREMATCH then
		CommentatorTeamDisplay:Show();
		CommentatorTeamDisplay:RefreshPlayerNamesAndScores();

		ClearTarget();

		self:FullPlayerRefresh();
		self:SetAllUnitFramesVisibilityState(true);

		self.currentSpeedFactor = nil;

		self:SetFrameLock(true);
		SetSpectatorModeForOtherFrames(true);
	elseif newState == TOURNAMENTARENA_ZONESTATE_SCANNING then
		if C_Commentator.IsSpectating() then
			C_Commentator.ExitInstance();
		end
		
		self:SetFrameLock(false);
		SetSpectatorModeForOtherFrames(false);

		ClearTarget();

		CommentatorTeamDisplay:Hide();
		self:SetAllUnitFramesVisibilityState(false);
	end
end

function PvPCommentatorMixin:CheckScoreboard()
	local winningTeam = GetBattlefieldWinner();

	if winningTeam then
		self:SetObserverState(TOURNAMENTARENA_ZONESTATE_SCOREBOARD);
		
		local winningTeamIndex = winningTeam + 1;
		if C_Commentator.AreTeamsSwapped() then
			winningTeamIndex = winningTeamIndex == 1 and 2 or 1;
		end
		
		local teamName = CommentatorTeamDisplay:GetTeamName(winningTeamIndex);
		if teamName then
			CommentatorFadeToBlackFrame:Start(0.1);
			C_Timer.After(0.3, function()
				CommentatorVictoryFanfareFrame:Show();
				CommentatorVictoryFanfareFrame:PlayVictoryFanfare(COMMENTATOR_VICTORY_FANFARE_TEXT, teamName);
			end);
		end
	end 
end

function PvPCommentatorMixin:JoinInstance()
	self:SetObserverState(TOURNAMENTARENA_ZONESTATE_TRANSFERRING_IN);
end

function PvPCommentatorMixin:StopObserving()
	self:SetObserverState(TOURNAMENTARENA_ZONESTATE_TRANSFERRING_OUT);

	C_Commentator.ExitInstance();
end
