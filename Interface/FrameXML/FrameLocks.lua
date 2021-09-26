----------------------------------------------------------------------------------------
--	Notes - The way this works should be temporary. It's easy to implement in Lua using
-- hooks, but we should probably implement this in C (or at least not hook Hide and Show
-- in this way).
----------------------------------------------------------------------------------------

local HIDE_MOST = {
	MinimapCluster		= "hidden",
	PlayerFrame			= "hidden",
	TargetFrame			= "hidden",
	ObjectiveTrackerFrame = "hidden",
	RuneFrame			= "hidden",
	MainMenuBar			= "hidden",
	DurabilityFrame 	= "hidden",
	CompactRaidFrameManager = "hidden",
	PartyMemberFrame1	= "hidden",
	PartyMemberFrame2	= "hidden",
	PartyMemberFrame3	= "hidden",
	PartyMemberFrame4	= "hidden",
	ConsolidatedBuffs	= "hidden",
	BuffFrame			= "hidden",
	MultiBarLeft		= "hidden",
	MultiBarRight		= "hidden",
	FocusFrame			= "hidden",
	TemporaryEnchantFrame = "hidden",
	ZoneAbilityFrame	= "hidden",
	OrderHallCommandBar	= "hidden",
	WorldStateScoreFrame = "hidden",
	UIWidgetTopCenterContainerFrame = "hidden",
}

--------Data on what locks exist and what frames are ruled by them--------
FRAMELOCK_STATES = {
	COMMENTATOR_SPECTATING_MODE = Mixin(
	HIDE_MOST,
	{
		GeneralDockManager	= "hidden",
		QuickJoinToastButton	= "hidden",
		ChatFrameMenuButton	= "hidden",
		CombatLogQuickButtonFrame = "hidden",
		ArenaEnemyFrames = "hidden",
		ChatFrame1			= "hidden",
		ChatFrameChannelButton = "hidden",
		UIWidgetTopCenterContainerFrame = "shown",
		WorldStateScoreFrame = "",
		--Additional chat frames are added to this list as they are created.
	}),
	PETBATTLES = HIDE_MOST,
};

FRAMELOCK_STATE_PRIORITIES = {
	"COMMENTATOR_SPECTATING_MODE",
	"PETBATTLES",
};

----------Curent states--------------------------
local ACTIVE_FRAMELOCKS = {};
local BASE_STATES = {};

----------Local helper functions---------------
local function initiateFrame(frame)
	local frameName = frame:GetName();
	if ( not frameName or frameName == "" ) then
		GMError("Frames controlled by FrameLocks must have names.");
	end

	if ( BASE_STATES[frameName] ) then
		return;
	end

	BASE_STATES[frameName] = frame:IsShown() and "shown" or "hidden";
	assert(frame.originalShow ~= frame.Show); --Make sure we didn't already set up this frame.
	frame.originalShow = frame.Show;
	frame.originalHide = frame.Hide;
	frame.Show = SmartShow;
	frame.Hide = SmartHide;
end

local function updateFrameByState(frame)
	initiateFrame(frame);
	local frameName = frame:GetName();
	if ( not frameName or frameName == "" ) then
		GMError("Frames controlled by FrameLocks must have names.");
	end
	for i=1, #FRAMELOCK_STATE_PRIORITIES do
		local lock = FRAMELOCK_STATE_PRIORITIES[i];
		if ( ACTIVE_FRAMELOCKS[lock] ) then
			local desiredState = FRAMELOCK_STATES[lock][frameName];
			if ( desiredState == "hidden" ) then
				frame:originalHide();
				return;
			elseif ( desiredState == "shown" ) then
				frame:originalShow();
				return;
			end
		end
	end

	--If we got to here, no lock is in place, so use the base state.
	if ( BASE_STATES[frameName] == "shown" ) then
		frame:originalShow();
	else
		frame:originalHide();
	end
end

local function setBaseState(frame, state)
	local frameName = frame:GetName();
	if ( not frameName or frameName == "" ) then
		GMError("Frames controlled by FrameLocks must have names.");
	end
	initiateFrame(frame);
	BASE_STATES[frameName] = state;
	updateFrameByState(frame);
end

local function setFrameLock(lock, isLocked)
	ACTIVE_FRAMELOCKS[lock] = isLocked;
	for frameName, _ in pairs(FRAMELOCK_STATES[lock]) do
		local frame = _G[frameName];
		if ( frame ) then
			updateFrameByState(frame);
		end
	end
	
	-- Recalculate positions of elements like the Backpack and tooltips!
	UIParent_ManageFramePositions();
end

----------Publicly accessed functions------------
function SmartHide(frame)
	setBaseState(frame, "hidden");
end

function SmartShow(frame)
	setBaseState(frame, "shown");
end

function IsFrameSmartShown(frame)
	local frameName = frame:GetName();
	if ( not frameName or frameName == "" ) then
		GMError("Frames controlled by FrameLocks must have names.");
	end

	local state = BASE_STATES[frameName];
	if ( state == "shown" ) then
		return true;
	elseif (state == "hidden" ) then
		return false;
	else
		return frame:IsShown();
	end
end

function IsFrameLockActive(lock)
	return ACTIVE_FRAMELOCKS[lock];
end

function AddFrameLock(lock)
	setFrameLock(lock, true);
end

function RemoveFrameLock(lock)
	setFrameLock(lock, false);
end

function SetFrameLock(lock, enabled)
	setFrameLock(lock, enabled);
end

function UpdateFrameLock(frame)
	updateFrameByState(frame);
end
