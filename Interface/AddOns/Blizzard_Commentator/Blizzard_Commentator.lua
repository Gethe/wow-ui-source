CommentatorSave = {};

-- Also required by Bindings.xml
TOURNAMENT_OBSERVE_PLAYER_PRIMARY = 1;
TOURNAMENT_OBSERVE_PLAYER_SECONDARY = 2;
TOURNAMENT_OBSERVE_PLAYER_PRIMARY_SNAP = 3;

local TOURNAMENTARENA_ZONESTATE_SCANNING = "scanning"; -- Waiting to join a match
local TOURNAMENTARENA_ZONESTATE_TRANSFERRING_IN = "transferring_in"; -- Joining a match
local TOURNAMENTARENA_ZONESTATE_TRANSFERRING_OUT = "transferring_out"; -- Leaving a match
local TOURNAMENTARENA_ZONESTATE_PREMATCH = "prematch"; -- In a match that hasn't started
local TOURNAMENTARENA_ZONESTATE_OBSERVING = "observing"; -- In a match that has started
local TOURNAMENTARENA_ZONESTATE_SCOREBOARD = "scoreboard"; -- Match is over, at the scoreboard
local TOURNAMENTARENA_ZONESTATE_RESETTING = "resetting"; -- A reset was requested, determining the appropriate state to be in

local COMMENTATOR_NAMEPLATE_WIDTH = 190 * COMMENTATOR_INVERSE_SCALE;
local COMMENTATOR_NAMEPLATE_HEIGHT = 55;

local FOLLOW_CAM_TRANSITION_SPEEDS = {
	{ 0.05, 20.0 },
	{ 0.10, 30.0 },
	{ 0.03, 15.0 },
}

local CurrentCamTransitionIndex = 1;
function SetFollowCameraTransitionPreset(index)
	C_Commentator.SetFollowCameraSpeeds(unpack(FOLLOW_CAM_TRANSITION_SPEEDS[index]));
	CurrentCamTransitionIndex = index;
end

function CycleFollowCameraTransitionPreset(index)
	CurrentCamTransitionIndex = CurrentCamTransitionIndex + 1;
	if CurrentCamTransitionIndex > #FOLLOW_CAM_TRANSITION_SPEEDS then
		CurrentCamTransitionIndex = 1;
	end
	C_Commentator.SetFollowCameraSpeeds(unpack(FOLLOW_CAM_TRANSITION_SPEEDS[CurrentCamTransitionIndex]));
end

CommentatorMixin = {}

function CommentatorMixin:OnLoad()
	self.cameraMoveSpeed = 7;
	
	local resetterCb = function(pool, frame)
		frame:Reset();
		FramePool_HideAndClearAnchors(pool, frame);
	end;

	self.unitFramePool = CreateFramePool("BUTTON", self, "CommentatorUnitFrameTemplate", resetterCb);
	self.unitFrames = {{}, {}};

	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("COMMENTATOR_RESET_SETTINGS");
	self:RegisterEvent("COMMENTATOR_ENTER_WORLD");
	self:RegisterEvent("COMMENTATOR_PLAYER_UPDATE");
	self:RegisterEvent("COMMENTATOR_PLAYER_NAME_OVERRIDE_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	self.state = TOURNAMENTARENA_ZONESTATE_SCANNING;
	self:CheckObserverState();
	
	SetFollowCameraTransitionPreset(1);
end

function CommentatorMixin:OnEvent(event, ...)
	if event == "COMMENTATOR_RESET_SETTINGS" then
		self:SetDefaultSettings();
	elseif event == "COMMENTATOR_ENTER_WORLD" then
		if C_Commentator.IsSpectating() then
			self:OnCommentatorEnterWorld();
		end
	elseif event == "COMMENTATOR_PLAYER_UPDATE" or event == "COMMENTATOR_PLAYER_NAME_OVERRIDE_UPDATE" then
		if C_Commentator.IsSpectating() then
			self:ReinitializeUnitFrames();
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:ResetInternal();
	elseif event == "ADDON_LOADED" then
		local addOnName = ...;
		if "Blizzard_Commentator" == addOnName then
			self:UnregisterEvent("ADDON_LOADED");
			self:ResetInternal();
		end
	end
end

function CommentatorMixin:OnUpdate(elapsed)
	self:CheckObserverState();
	
	self.Scoreboard:SetMatchDuration(C_Commentator.GetMatchDuration());

	if self.state ~= TOURNAMENTARENA_ZONESTATE_OBSERVING or self.state ~= TOURNAMENTARENA_ZONESTATE_PREMATCH then
		return;
	end

	self.targetSpeedFactor = IsShiftKeyDown() and 2.0 or 1.0;
	self.currentSpeedFactor = DeltaLerp(self.currentSpeedFactor or 1.0, self.targetSpeedFactor, .05, elapsed);
	C_Commentator.SetSpeedFactor(self.currentSpeedFactor);

	-- We need to always keep UI visibility on as this controls whether nameplates are visible, however commands like TOGGLEUI (Alt+Z) 
	-- might turn this off if commentators need to briefly enable the default UI to adjust something and then hide it
	-- "SetInWorldUIVisibility" is a new function that enables nameplates, etc. but doesn't affect the actual UI frames
	SetInWorldUIVisibility(true);
end

function CommentatorMixin:ResetInternal()
	if C_Commentator.IsSpectating() then
		-- We need to overwrite the cvars because they are a prerequisite for the nameplates, 
		-- and we have no guarantee that these shared cvars won't be modified by another system.
		self:SetDefaultCVars();
		
		-- Ensure cvars and nameplate sizes are assigned before nameplates appear.
		NamePlateDriverFrame:SetBaseNamePlateSize(COMMENTATOR_NAMEPLATE_WIDTH, COMMENTATOR_NAMEPLATE_HEIGHT);
	end
	
	self:Reset();
end

function CommentatorMixin:SwapTeams()
	C_Commentator.SwapTeamSides();
	self:ReinitializeUnitFrames();
	self.Scoreboard:Reinitialize();
end

function CommentatorMixin:ObservePlayer(teamIndex, playerIndex, observationType)
	if self.sortedPlayerIndices and self.sortedPlayerIndices[teamIndex] then
		local changedIndex = self.sortedPlayerIndices[teamIndex][playerIndex];
		if changedIndex then
			playerIndex = changedIndex;
		end
	end

	if C_Commentator.IsUsingSmartCamera() then
		if observationType == TOURNAMENT_OBSERVE_PLAYER_PRIMARY then
			C_Commentator.LookAtPlayer(teamIndex, playerIndex, 1);
		-- TOURNAMENT_OBSERVE_PLAYER_PRIMARY_SNAP is equivalent to TOURNAMENT_OBSERVE_PLAYER_SECONDARY using the smart camera.
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

function CommentatorMixin:SetDefaultSettings()
	self:SetDefaultBindings();
	self:SetDefaultCVars();
end

function CommentatorMixin:SetDefaultBindings()
	SetBinding("\\", "TOGGLEGAMEMENU");
	SetBinding("]", "COMMENTATORMOVESPEEDINCREASE");
	SetBinding("[", "COMMENTATORMOVESPEEDDECREASE");
	SetBinding("MOUSEWHEELUP", "COMMENTATORZOOMIN");
	SetBinding("MOUSEWHEELDOWN", "COMMENTATORZOOMOUT");
	SetBinding("ESCAPE", "COMMENTATORLOOKATNONE");
	SetBinding("F1", "COMMENTATORFOLLOW1");
	SetBinding("F2", "COMMENTATORFOLLOW2");
	SetBinding("F3", "COMMENTATORFOLLOW3");
	SetBinding("F4", "COMMENTATORFOLLOW4");
	SetBinding("F5", "COMMENTATORFOLLOW5");
	SetBinding("F6", "COMMENTATORFOLLOW6");
	SetBinding("F7", "COMMENTATORFOLLOW7");
	SetBinding("F8", "COMMENTATORFOLLOW8");
	SetBinding("F9", "COMMENTATORFOLLOW9");
	SetBinding("F10", "COMMENTATORFOLLOW10");
	SetBinding("F11", "COMMENTATORFOLLOW11");
	SetBinding("F12", "COMMENTATORFOLLOW12");
	SetBinding("1", "COMMENTATORFOLLOW1SNAP");
	SetBinding("2",	"COMMENTATORFOLLOW2SNAP");
	SetBinding("3",	"COMMENTATORFOLLOW3SNAP");
	SetBinding("4",	"COMMENTATORFOLLOW4SNAP");
	SetBinding("5",	"COMMENTATORFOLLOW5SNAP");
	SetBinding("6",	"COMMENTATORFOLLOW6SNAP");
	SetBinding("7",	"COMMENTATORFOLLOW7SNAP");
	SetBinding("8",	"COMMENTATORFOLLOW8SNAP");
	SetBinding("9",	"COMMENTATORFOLLOW9SNAP");
	SetBinding("0",	"COMMENTATORFOLLOW10SNAP");
	SetBinding("-",	"COMMENTATORFOLLOW11SNAP");
	SetBinding("=",	"COMMENTATORFOLLOW12SNAP");
	SetBinding("CTRL-SHIFT-R", "COMMENTATORRESET");
	SetBinding(",", "TEAM_1_ADD_SCORE");
	SetBinding(".", "TEAM_2_ADD_SCORE");
	SetBinding("SHIFT-,", "TEAM_1_REMOVE_SCORE");
	SetBinding("SHIFT-.", "TEAM_2_REMOVE_SCORE");
	SetBinding("U", "RESET_SCORE_COUNT");
	SetBinding("/", "SWAPUNITFRAMES");
	SetBinding("TAB", "TOGGLE_SMART_CAMERA");
	SetBinding("CTRL-SHIFT-N", "CHECK_FOR_SCOREBOARD");
	SetBinding("CAPSLOCK", "TOGGLE_SMART_CAMERA_LOCK");
	SetBinding("SHIFT-SPACE", nil);
	SetBinding("F", "FORCEFOLLOWTRANSITON");
	SetBinding("T", "TOGGLESMOOTHFOLLOWTRANSITIONS");
	SetBinding("C", "TOGGLECAMERACOLLISION");
	SetBinding("V", "CYCLEFOLLOWTRANSITONSPEED");

	SaveBindings(GetCurrentBindingSet());
end

function CommentatorMixin:SetDefaultCVars()
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

	local nativeScale = 1;
	SetCVar("NamePlateHorizontalScale", nativeScale);
	SetCVar("NamePlateVerticalScale", nativeScale);
	SetCVar("nameplateGlobalScale", nativeScale);
	SetCVar("nameplateMinScale", nativeScale);
	SetCVar("nameplateMaxScale", nativeScale);
	SetCVar("nameplateSelectedScale", nativeScale);

	SetCVar("nameplateShowAll", 1);
	SetCVar("UnitNameNPC", 0);
	SetCVar("ShowClassColorInNameplate", 0);
	SetCVar("nameplateMotion", 0);
	SetCVar("showVKeyCastbar", 0);
	SetCVar("deselectOnClick", 1);
	SetCVar("maxfpsbk", 0);
	SetCVar("showSpectatorTeamCircles", 1);
	SetCVar("ShowClassColorInNameplate", "1");
	SetCVar("nameplateMinAlpha", "1");
	SetCVar("nameplateOccludedAlphaMult", "1.0");
	SetCVar("UnitNamePlayerGuild", "0");
	SetCVar("UnitNameEnemyMinionName", "0");
	SetCVar("UnitNameFriendlyMinionName", "0");
	SetCVar("chatStyle", "classic");
	SetCVar("countdownForCooldowns", 1)
end

function CommentatorMixin:ModifyCameraSpeed(speed)
	self.cameraMoveSpeed = Clamp(self.cameraMoveSpeed + speed, 1, 40);
	C_Commentator.SetMoveSpeed(self.cameraMoveSpeed);
end

function CommentatorMixin:SetFrameLock(enabled)
	SetFrameLock("COMMENTATOR_SPECTATING_MODE", enabled);
	C_Commentator.SetMouseDisabled(enabled);
end

function CommentatorMixin:ToggleFrameLock()
	self:SetFrameLock(not IsFrameLockActive("COMMENTATOR_SPECTATING_MODE"));
end

function CommentatorMixin:Start()
	self:SetScript("OnUpdate", self.OnUpdate);
	self:SetObserverState(TOURNAMENTARENA_ZONESTATE_RESETTING);
end

function CommentatorMixin:Shutdown()
	self:SetScript("OnUpdate", nil);
	self:SetObserverState(TOURNAMENTARENA_ZONESTATE_SCANNING);
	
	CommentatorFadeToBlackFrame:Stop();
	self.Scoreboard:Hide();
	self:ClearUnitFrames();
	self:SetFrameLock(false);
end

function CommentatorMixin:Reset()
	if C_Commentator.IsSpectating() then
		self:Start();
	else
		self:Shutdown();
	end
end

function CommentatorMixin:OnCommentatorEnterWorld()
	local mapID = select(8, GetInstanceInfo());
	local pos = C_Commentator.GetStartLocation(mapID);
	if pos then
		CommentatorFadeToBlackFrame:ReverseStart();

		C_Commentator.SetUseSmartCamera(true);
		C_Commentator.SetSmartCameraLocked(false);
		local SNAP_TO_POSITION = true;
		C_Commentator.SetCameraPosition(pos.x, pos.y, pos.z, SNAP_TO_POSITION);
		C_Commentator.SnapCameraLookAtPoint();
	end
end

local function UnitFrameComparator(left, right)
	local leftRole = left.tempRole;
	local rightRole = right.tempRole;
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

	return strcmputf8i(left.tempName, right.tempName) < 0;
end

function CommentatorMixin:InitUnitFrames()
	self.sortedPlayerIndices = {{},{}};

	local highestPlayerCount = 0;
	for teamIndex = 1, 2 do
		local playerCount = C_Commentator.GetNumPlayers(teamIndex);
		highestPlayerCount = math.max(highestPlayerCount, playerCount);
		if playerCount then
			local isAlignedLeft = teamIndex == 1;
			local unitFrames = self.unitFrames[teamIndex];
			for playerIndex = 1, playerCount do
				local unitFrame = self.unitFramePool:Acquire();
				unitFrame:SetFrameLevel(playerIndex);

				local playerData = C_Commentator.GetPlayerData(teamIndex, playerIndex);
				unitFrame:Init(isAlignedLeft, playerData, teamIndex);
				unitFrame.tempRole = unitFrame:GetRole();
				unitFrame.playerIndex = playerIndex;
				unitFrame.tempName = unitFrame:GetPlayerName();
				unitFrame:Show();
				table.insert(unitFrames, unitFrame);
			end

			table.sort(unitFrames, UnitFrameComparator);

			for index, unitFrame in ipairs(unitFrames) do
				unitFrame.tempRole = nil;
				unitFrame.tempName = nil;
				self.sortedPlayerIndices[teamIndex][index] = unitFrame.playerIndex;
			end
		end
	end

	local minified = highestPlayerCount > 5;
	local originY = minified and 30 or -25;
	local offsetX = minified and -100 or 20;
	local padding;
	if minified then
		padding = -56;
	elseif highestPlayerCount > 3 then
		padding = -160;
	else
		padding = -230;
	end

	do
		local offsetY = originY;
		for index, unitFrame in ipairs(self.unitFrames[1]) do
			unitFrame:ClearAllPoints();
			unitFrame:SetPoint("TOPLEFT", self, offsetX, offsetY);
			unitFrame:SetMinified(minified);
			offsetY = offsetY + padding;
		end
	end

	do
		local offsetY = originY;
		for index, unitFrame in ipairs(self.unitFrames[2]) do
			unitFrame:ClearAllPoints();
			unitFrame:SetPoint("TOPRIGHT", self, -offsetX, offsetY);
			unitFrame:SetMinified(minified);
			offsetY = offsetY + padding;
		end
	end
end

function CommentatorMixin:ClearUnitFrames()
	self.unitFramePool:ReleaseAll();
	self.unitFrames = {{}, {}};
end

function CommentatorMixin:ReinitializeUnitFrames()
	self:ClearUnitFrames();
	self:InitUnitFrames();
end

function CommentatorMixin:CheckObserverState()
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

function CommentatorMixin:SetObserverState(state)
	if state ~= self.state then
		local oldState = self.state;
		self.state = state;
		self:OnObserverStateChanged(oldState, state);
	end
end

function CommentatorMixin:OnObserverStateChanged(oldState, newState)
	if newState == TOURNAMENTARENA_ZONESTATE_TRANSFERRING_IN or newState == TOURNAMENTARENA_ZONESTATE_TRANSFERRING_OUT then
		ClearTarget();

		self.Scoreboard:Hide();
		self:ClearUnitFrames();

		self:SetFrameLock(true);
	elseif newState == TOURNAMENTARENA_ZONESTATE_OBSERVING or newState == TOURNAMENTARENA_ZONESTATE_PREMATCH then
		ClearTarget();

		self.Scoreboard:Show();
		self:ReinitializeUnitFrames();

		self.currentSpeedFactor = nil;

		self:SetFrameLock(true);
	elseif newState == TOURNAMENTARENA_ZONESTATE_SCANNING then
		ClearTarget();

		if C_Commentator.IsSpectating() then
			C_Commentator.ExitInstance();
		end
		
		self.Scoreboard:Hide();
		self:ClearUnitFrames();

		self:SetFrameLock(false);
	end
end

function CommentatorMixin:CheckScoreboard()
	local winningTeam = GetBattlefieldWinner();
	if winningTeam then
		self:SetObserverState(TOURNAMENTARENA_ZONESTATE_SCOREBOARD);
		
		local winningTeamIndex = winningTeam + 1;
		if C_Commentator.AreTeamsSwapped() then
			winningTeamIndex = winningTeamIndex == 1 and 2 or 1;
		end
				
		local teamName = self.Scoreboard:GetTeamName(winningTeamIndex);
		if teamName then
			CommentatorFadeToBlackFrame:Start(0.1);
			C_Timer.After(0.3, function()
				CommentatorVictoryFanfareFrame:Show();
				CommentatorVictoryFanfareFrame:PlayVictoryFanfare(COMMENTATOR_VICTORY_FANFARE_TEXT, teamName);
			end);
		end
	end 
end

function CommentatorMixin:GetNameplateTemplate()
	return "CommentatorNamePlateTemplate";
end

function CommentatorMixin:ExitInstance()
	if C_Commentator.CanUseCommentatorCheats() then
		C_Commentator.ExitInstance();
	else
		ConfirmOrLeaveBattlefield();
	end
end

function CommentatorMixin:JoinInstance()
	self:SetObserverState(TOURNAMENTARENA_ZONESTATE_TRANSFERRING_IN);
end

function CommentatorMixin:StopObserving()
	self:SetObserverState(TOURNAMENTARENA_ZONESTATE_TRANSFERRING_OUT);

	C_Commentator.ExitInstance();
end