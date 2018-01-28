
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

local MAX_PLAYERS_FOR_FULL_SIZE_UNIT_FRAMES = 3;

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

PvPCommentatorMixin = {};

function PvPCommentatorMixin:OnLoad()
	self.cameraMoveSpeed = 7;

	self.unitFrames = {};
	self.sortedUnitFrames = {};
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
	
	SetBinding("F1",		"COMMENTATORFOLLOW1");
	SetBinding("F2",		"COMMENTATORFOLLOW2");
	SetBinding("F3",		"COMMENTATORFOLLOW3");
	SetBinding("F4",		"COMMENTATORFOLLOW4");
	SetBinding("F5",		"COMMENTATORFOLLOW5");
	SetBinding("F6",		"COMMENTATORFOLLOW6");
	SetBinding("F7",		"COMMENTATORFOLLOW7");
	SetBinding("F8",		"COMMENTATORFOLLOW8");
	SetBinding("F9",		"COMMENTATORFOLLOW9");
	SetBinding("F10",		"COMMENTATORFOLLOW10");
	SetBinding("F11",		"COMMENTATORFOLLOW11");
	SetBinding("F12",		"COMMENTATORFOLLOW12");
	
	SetBinding("1",			"COMMENTATORFOLLOW1SNAP");
	SetBinding("2",			"COMMENTATORFOLLOW2SNAP");
	SetBinding("3",			"COMMENTATORFOLLOW3SNAP");
	SetBinding("4",			"COMMENTATORFOLLOW4SNAP");
	SetBinding("5",			"COMMENTATORFOLLOW5SNAP");
	SetBinding("6",			"COMMENTATORFOLLOW6SNAP");
	SetBinding("7",			"COMMENTATORFOLLOW7SNAP");
	SetBinding("8",			"COMMENTATORFOLLOW8SNAP");
	SetBinding("9",			"COMMENTATORFOLLOW9SNAP");
	SetBinding("0",			"COMMENTATORFOLLOW10SNAP");
	SetBinding("-",			"COMMENTATORFOLLOW11SNAP");
	SetBinding("=",			"COMMENTATORFOLLOW12SNAP");
	
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
	SaveBindings(GetCurrentBindingSet());
end

function PvPCommentatorMixin:SetNeedsFullRefresh(needed)
	self.needsFullRefresh = needed;
end

function PvPCommentatorMixin:NeedsFullRefresh()
	return self.needsFullRefresh;
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

local COMMENTATOR_NAMEPLATE_HORIZONTAL_SCALE = 1.4;
local COMMENTATOR_NAMEPLATE_VERTICAL_SCALE = 2.7;
function PvPCommentatorMixin:ToggleNameplateSizeCVars()
	local namePlateHorizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"));
	if namePlateHorizontalScale > 1.0 then
		SetCVar("NamePlateHorizontalScale", 1.0);
		SetCVar("NamePlateVerticalScale", (COMMENTATOR_NAMEPLATE_VERTICAL_SCALE / COMMENTATOR_NAMEPLATE_HORIZONTAL_SCALE));
	else
		SetCVar("NamePlateHorizontalScale", COMMENTATOR_NAMEPLATE_HORIZONTAL_SCALE);
		SetCVar("NamePlateVerticalScale", COMMENTATOR_NAMEPLATE_VERTICAL_SCALE);
	end
	
	NamePlateDriverFrame:UpdateNamePlateOptions();
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
	
	SetCVar("NamePlateHorizontalScale", COMMENTATOR_NAMEPLATE_HORIZONTAL_SCALE);
	SetCVar("NamePlateVerticalScale", COMMENTATOR_NAMEPLATE_VERTICAL_SCALE);
	SetCVar("nameplateSelectedScale", 1.5);
	SetCVar("nameplateShowAll", 1);

	-- See InterfaceOptionsNPCNamesDropDown, we want these all off.
	SetCVar("UnitNameFriendlySpecialNPCName", 0);
	SetCVar("UnitNameHostleNPC", 0);
	SetCVar("UnitNameInteractiveNPC", 0);
	SetCVar("UnitNameNPC", 0);
	SetCVar("ShowQuestUnitCircles", 0);
	
	SetCVar("ShowClassColorInNameplate", 0);
	
	SetCVar("nameplateMotion", 0);
		
	SetCVar("showVKeyCastbar", 0);

	SetCVar("threatWarning", 0);
	
	SetCVar("deselectOnClick", 1);

	SetCVar("maxfpsbk", 0);

	SetCVar("showSpectatorTeamCircles", 1);
	
	SetCVar("ShowClassColorInNameplate", "1");
	
	SetCVar("nameplateMinAlpha", ".75");
	
	SetCVar("nameplateOccludedAlphaMult", "1.0");
	SetCVar("UnitNamePlayerGuild", "0");
	SetCVar("UnitNameEnemyMinionName", "0");
	SetCVar("UnitNameFriendlyMinionName", "0");
	
	SetCVar("chatStyle", "classic");
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

	local Y_START = self.isCompact and -50 or -25;
	local Y_PADDING = self.isCompact and -145 or -230;
	local X_OFFSET = 20;

	for teamIndex = 1, #self.unitFrames do
		local offsetY = Y_START;
		for sortedIndex, unitFrame in self:EnumerateSortedUnitFrames(teamIndex) do
			unitFrame:ClearAllPoints();

			if unitFrame:IsValid() then
				local newYOffset = offsetY + unitFrame:GetAdditionalYSpacing();
			
				if unitFrame.align == "right" then
					unitFrame:SetPoint("TOPRIGHT", WorldFrame, -X_OFFSET, newYOffset);
				else
					unitFrame:SetPoint("TOPLEFT", WorldFrame, X_OFFSET, newYOffset);
				end

				offsetY = offsetY + Y_PADDING;
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

	self.isCompact = maxPlayersPerTeam > MAX_PLAYERS_FOR_FULL_SIZE_UNIT_FRAMES;
	for teamIndex = 1, #self.unitFrames do
		for playerIndex = 1, #self.unitFrames[teamIndex] do
			self.unitFrames[teamIndex][playerIndex]:SetCompact(self.isCompact);
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

function PvPCommentatorMixin:UpdateAllUnitFrameCrowdControlRemovers(visible)
	for teamIndex = 1, #self.unitFrames do
		for playerIndex = 1, #self.unitFrames[teamIndex] do
			self.unitFrames[teamIndex][playerIndex]:UpdateCrowdControlRemover();
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

		ClearTarget();

		CommentatorTeamDisplay:Hide();
		CommentatorCooldownDisplayFrame:Hide();
		self:SetAllUnitFramesVisibilityState(false);
	elseif newState == TOURNAMENTARENA_ZONESTATE_OBSERVING or newState == TOURNAMENTARENA_ZONESTATE_PREMATCH then
		CommentatorTeamDisplay:Show();
		CommentatorTeamDisplay:RefreshPlayerNamesAndScores();

		if oldState ~= TOURNAMENTARENA_ZONESTATE_PREMATCH then
			CommentatorCooldownDisplayFrame:Hide();
		end

		ClearTarget();

		self:FullPlayerRefresh();
		self:SetAllUnitFramesVisibilityState(true);
		self:UpdateAllUnitFrameCrowdControlRemovers();

		self.currentSpeedFactor = nil;

		self:SetFrameLock(true);
	elseif newState == TOURNAMENTARENA_ZONESTATE_SCANNING then
		if C_Commentator.IsSpectating() then
			C_Commentator.ExitInstance();
		end
		
		self:SetFrameLock(false);
		CommentatorCooldownDisplayFrame:Hide();

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

function PvPCommentatorMixin:ToggleCommentatorCooldownDisplay()
	if self.state == TOURNAMENTARENA_ZONESTATE_OBSERVING or self.state == TOURNAMENTARENA_ZONESTATE_PREMATCH then
		CommentatorCooldownDisplayFrame:SetShown(not CommentatorCooldownDisplayFrame:IsShown());
	end
end