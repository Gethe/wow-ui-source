local _, addonTable = ...; -- Used for passing functions between UIParentPanelManager.lua and other files in this addon.

local function FrameShouldBePositionManaged(frame)
	return frame:IsShown() and frame:IsInDefaultPosition();
end

local function FrameIsReadyForPositionManagement(frame)
	return not frame:IsEditModeDragging();
end

addonTable.UIParentManageFramePositions = function(self)
	--[[ State Variables ]]
	-- Tracks the state of frame position management as we run through this function.
	local frameState = {
		bottomLeftYOffset = 0,
		bottomRightYOffset = 0,
		-- For the Stance Bar, Pet Action Bar, and Possess Bar, we want to show a background if they're flush with the Main Menu Bar.
		-- If that spot is occupied, then we want to hide the background.
		-- This boolean keeps track of if something else has occupied the slot yet.
		bottomLeftBarSlotIsOccupied = false,
	};

	--[[ Helper function: Apply position management to a frame and update state appropriately.
			frame: frame to apply position management to.
			xOffset / yOffset: forced offsets to apply to frame's position.
			adjustSelfFunc: after applying position management, call this to adjust the frame.
			adjustStateFunc: after applying position management, call this to adjust the state of the position manager (e.g., updating subsequent offsets).
	]]
	local function ApplyPositionManagement(frame, frameState, xOffset, yOffset, adjustSelfFunc, adjustStateFunc)
		if (FrameShouldBePositionManaged(frame)) then
			if (FrameIsReadyForPositionManagement(frame)) then
				frame:ClearAllPoints();
				EditModeManagerFrame:SetToLayoutAnchor(frame, xOffset, yOffset);
				if (adjustSelfFunc) then
					adjustSelfFunc(frame, frameState);
				end
			end
			if (adjustStateFunc) then
				adjustStateFunc(frame, frameState);
			end
		end
	end

	--[[ Position Management ]]

	if (StatusTrackingBarManager) then -- Guard against early calls when we're loading the UI.
		-- Status Bars: add some amount of height to both left and right based on how many bars are showing.
		-- The height function is a little variable since if 0 bars are showing, then MainMenuBar shows the TopLevel bar which still takes some height.
		StatusTrackingBarManager:UpdateBarVisuals();
		if (SecondaryStatusTrackingBarContainer:IsShown() and SecondaryStatusTrackingBarContainer:IsInDefaultPosition()) then
			frameState.bottomLeftYOffset = frameState.bottomLeftYOffset + 15;
			frameState.bottomRightYOffset = frameState.bottomRightYOffset + 15;
		elseif (MainStatusTrackingBarContainer:IsShown() and MainStatusTrackingBarContainer:IsInDefaultPosition()) then
			frameState.bottomLeftYOffset = frameState.bottomLeftYOffset + 5;
			frameState.bottomRightYOffset = frameState.bottomRightYOffset + 5;
		end

		-- MultiBarBottomLeft
		ApplyPositionManagement(MultiBarBottomLeft, frameState, 0, frameState.bottomLeftYOffset,
			nil,
			function(frame, frameState) frameState.bottomLeftYOffset = frameState.bottomLeftYOffset + frame:GetHeight() + 8; frameState.bottomLeftBarSlotIsOccupied = true; end);

		-- MultiBarBottomRight
		ApplyPositionManagement(MultiBarBottomRight, frameState, 0, frameState.bottomRightYOffset,
			nil,
			function(frame, frameState) frameState.bottomRightYOffset = frameState.bottomRightYOffset + frame:GetHeight() + 8; end);

		-- StanceBar
		ApplyPositionManagement(StanceBar, frameState, 0, frameState.bottomLeftYOffset,
			function(frame, frameState) frame:SetBackgroundArtShown(MainMenuBar:IsShown() and not frameState.bottomLeftBarSlotIsOccupied); end,
			function(frame, frameState) frameState.bottomLeftYOffset = frameState.bottomLeftYOffset + frame:GetHeight() + 10; frameState.bottomLeftBarSlotIsOccupied = true; end);

		-- PetActionBar
		ApplyPositionManagement(PetActionBar, frameState, 0, frameState.bottomLeftYOffset,
			function(frame, frameState) frame:SetBackgroundArtShown(MainMenuBar:IsShown() and not frameState.bottomLeftBarSlotIsOccupied); end,
			function(frame, frameState) frameState.bottomLeftYOffset = frameState.bottomLeftYOffset + frame:GetHeight() + 10; frameState.bottomLeftBarSlotIsOccupied = true; end);

		-- PossessActionBar
		ApplyPositionManagement(PossessActionBar, frameState, 0, frameState.bottomLeftYOffset,
			function(frame, frameState) frame:SetBackgroundArtShown(MainMenuBar:IsShown() and not frameState.bottomLeftBarSlotIsOccupied); end,
			function(frame, frameState) frameState.bottomLeftYOffset = frameState.bottomLeftYOffset + frame:GetHeight() + 10; frameState.bottomLeftBarSlotIsOccupied = true; end);
	end

	-- Layout managed frame containers.
	self:UIParentManageBottomFrameContainer();
	self:UIParentManageRightFrameContainer();
end
