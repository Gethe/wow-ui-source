--[[
Overview
	The idea behind this file is that we have certain frames in Classic that need special position management and updating based on what is visible.
	The obvious example here is how the MultiBarBottomLeft can push up the StanceBar, and in doing so also causes the StanceBar's background to be hidden.
	To perform that work, we add a config for these different frames that need to be "managed", then process them in UIParentManageFramePositions
	to adjust their anchors and states based on the overall state of the UI.
]]

local _, addonTable = ...; -- Used for passing functions between UIParentPanelManager.lua and other files in this addon.

BOTTOM_FRAME_CONTAINER_MARGIN = 5;

local function FrameShouldBePositionManaged(frame)
	return frame:IsShown() and frame:IsInDefaultPosition();
end

local function ActionBarShouldBePositionManaged(frame)
	return frame:IsShown()
		and frame:IsInDefaultPosition()
		and frame:IsSystemSettingDefault(Enum.EditModeActionBarSetting.Orientation)
		and frame:IsSystemSettingDefault(Enum.EditModeActionBarSetting.NumRows)
		and frame:IsSystemSettingDefault(Enum.EditModeActionBarSetting.IconSize);
end

local function FrameIsReadyForPositionManagement(frame)
	return not frame:IsEditModeDragging();
end

--[[
Config for Managed Frames
	* shouldBePositionedManagedFunc = Function to decide whether this frame should be considered by the management system.
	* rightSide = Bool indicating if this frame is part of the "right side managed frame stack". If not set, then it will be in the left side by default.
	* offsetYPadding = The amount of height to add to the "managed stack" after after this frame, in addition to this frame's height.
	* adjustSelfFunc = A function to call after this frame is managed, in case it needs any state adjustments.
	* adjustOffsetYFunc = Function to manipulate the offsetY value, before it gets applied to the current frame.
]]
local ManagedFrameConfig =
{
	["MultiBarBottomLeft"] =
	{
		shouldBePositionedManagedFunc = ActionBarShouldBePositionManaged,
		offsetYPadding = 8,
	},
	["MultiBarBottomRight"] =
	{
		shouldBePositionedManagedFunc = ActionBarShouldBePositionManaged,
		rightSide = true,
		offsetYPadding = 8,
	},
	["StanceBar"] =
	{
		shouldBePositionedManagedFunc = ActionBarShouldBePositionManaged,
		offsetYPadding = 10,
		adjustSelfFunc = function(cumulativeState, frame) frame:SetBackgroundArtShown( frame:ShouldShowBackgroundArt() and not cumulativeState.bottomLeftBarSlotIsOccupied); end,
	},
	["PetActionBar"] =
	{
		shouldBePositionedManagedFunc = ActionBarShouldBePositionManaged,
		offsetYPadding = 10,
		adjustSelfFunc = function(cumulativeState, frame) frame:SetBackgroundArtShown( frame:ShouldShowBackgroundArt() and not cumulativeState.bottomLeftBarSlotIsOccupied); end,
	},
	["PossessActionBar"] =
	{
		shouldBePositionedManagedFunc = ActionBarShouldBePositionManaged,
		offsetYPadding = 10,
		adjustSelfFunc = function(cumulativeState, frame) frame:SetBackgroundArtShown( frame:ShouldShowBackgroundArt() and not cumulativeState.bottomLeftBarSlotIsOccupied); end,
	},
	["MainMenuBarVehicleLeaveButton"] =
	{
		shouldBePositionedManagedFunc = FrameShouldBePositionManaged,
		offsetYPadding = 10,
	},
	["ChatFrame1"] =
	{
		shouldBePositionedManagedFunc = FrameShouldBePositionManaged,
		-- If our bottomLeftYOffset if sufficiently high (> 30), then offset the ChatFrame upwards. But don't let it go too high because it'll start to look silly (and also clip the PlayerFrame if the player is using the "Modern" layout).
		adjustOffsetYFunc = function(cumulativeState, offset) local chatFrameOffset = cumulativeState.bottomLeftYOffset - 30; return Clamp(chatFrameOffset, 0, 28); end,
	},
};

addonTable.UIParentManageFramePositions = function(self)
	if (not StatusTrackingBarManager) then -- Guard against early calls when we're loading the UI.
		return;
	end

	--[[ State Variables ]]
	-- Tracks the state of frame position management as we run through this function.
	local cumulativeState = {
		bottomLeftYOffset = 0,
		bottomRightYOffset = 0,
		-- For the Stance Bar, Pet Action Bar, and Possess Bar, we want to show a background if they're flush with the Main Menu Bar.
		-- If that spot is occupied, then we want to hide the background.
		-- This boolean keeps track of if something else has occupied the slot yet.
		bottomLeftBarSlotIsOccupied = false,
	};

	--[[ Helper function: Apply position management to a frame and update overall state appropriately. ]]
	local function ApplyPositionManagement(cumulativeState, frameName)
		local config = ManagedFrameConfig[frameName];
		local frame = _G[frameName];

		-- Verify whether our frame should be managed.
		if (config.shouldBePositionedManagedFunc(frame)) then
			if (FrameIsReadyForPositionManagement(frame)) then
				frame:ClearAllPoints();

				-- Calculate offsets.
				local xOffset = 0;
				local yOffset = config.rightSide and cumulativeState.bottomRightYOffset or cumulativeState.bottomLeftYOffset;
				if (config.adjustOffsetYFunc) then
					yOffset = config.adjustOffsetYFunc(cumulativeState, yOffset);
				end

				-- Apply offsets.
				EditModeManagerFrame:SetToLayoutAnchor(frame, xOffset, yOffset);

				-- Post-anchoring cleanup.
				if (config.adjustSelfFunc) then
					config.adjustSelfFunc(cumulativeState, frame);
				end
			end

			-- Adjust the managed state for the next frame.
			-- (Note: We do this if our frame "should" be position managed, even if it wasn't "ready" to actually have that management applied to itself.)
			if (config.offsetYPadding) then
				if (config.rightSide) then
					cumulativeState.bottomRightYOffset = cumulativeState.bottomRightYOffset + frame:GetHeight() + config.offsetYPadding;
				else
					cumulativeState.bottomLeftYOffset = cumulativeState.bottomLeftYOffset + frame:GetHeight() + config.offsetYPadding;
					cumulativeState.bottomLeftBarSlotIsOccupied = true;
				end
			end
		end
	end

	--[[ Position Management ]]

		-- Status Bars: add some amount of height to both left and right based on how many bars are showing.
		-- The height function is a little variable since if 0 bars are showing, then MainMenuBar shows the TopLevel bar which still takes some height.
		StatusTrackingBarManager:UpdateBarVisuals();
		if (SecondaryStatusTrackingBarContainer:IsShown() and SecondaryStatusTrackingBarContainer:IsInDefaultPosition()) then
			cumulativeState.bottomLeftYOffset = cumulativeState.bottomLeftYOffset + 15;
			cumulativeState.bottomRightYOffset = cumulativeState.bottomRightYOffset + 15;
		elseif (MainStatusTrackingBarContainer:IsShown() and MainStatusTrackingBarContainer:IsInDefaultPosition()) then
			cumulativeState.bottomLeftYOffset = cumulativeState.bottomLeftYOffset + 5;
			cumulativeState.bottomRightYOffset = cumulativeState.bottomRightYOffset + 5;
		end

		-- MultiBarBottomLeft
		ApplyPositionManagement(cumulativeState, "MultiBarBottomLeft");

		-- MultiBarBottomRight
		ApplyPositionManagement(cumulativeState, "MultiBarBottomRight");

		-- StanceBar
		ApplyPositionManagement(cumulativeState, "StanceBar");

		-- PetActionBar
		ApplyPositionManagement(cumulativeState, "PetActionBar");

		-- PossessActionBar
		ApplyPositionManagement(cumulativeState, "PossessActionBar");

		-- MainMenuBarVehicleLeaveButton
		ApplyPositionManagement(cumulativeState, "MainMenuBarVehicleLeaveButton");

		-- ChatFrame1
		ApplyPositionManagement(cumulativeState, "ChatFrame1");

	-- Layout managed frame containers.
	self:UIParentManageBottomFrameContainer();
	self:UIParentManageRightFrameContainer();
end
