GamepadActionBarBindingUtil = {};

--[[
	Gamepad Action Bar Page units use the following slot IDs to represent
	a slot on any given page.

							  TopBar
						02				06
					01		03		05		07
						04				08

			  LeftBar						  RightBar
		10				14				18				22
	09		11		13		15		17		19		21		23
		12				16				20				24

							 BottomBar
						26				30
					25		27		29		31
						28				32
]]

local FIRST_RESERVED_PAGE_UNIT_SLOT_INDEX = 5;

--[[
	Returns true if the specified page number is a valid page number in the gamepad action bar system.
	This includes both standard pages and special pages (possess bar page).
]]
function GamepadActionBarBindingUtil.IsValidGamepadPageNumber(gamepadPageNum)
	return gamepadPageNum > 0 and gamepadPageNum <= Constants.GamepadActionBarConstants.NUM_PAGES_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT;
end

--[[
	Returns true if the specified page number represents a standard page or false otherwise. The standard pages are the first pages that
	appear in the page unit, while special pages like the possess bar page come after the standard pages. Standard pages are expected to
	contain only pageable action bars, unless they have been overridden by a non-pageable bar (like the possess bar).
]]
function GamepadActionBarBindingUtil.IsStandardGamepadPageNum(gamepadPageNum)
	return GamepadActionBarBindingUtil.IsValidGamepadPageNumber(gamepadPageNum) and gamepadPageNum <= Constants.GamepadActionBarConstants.NUM_STANDARD_PAGES_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT;
end

--[[
	Returns true if the page unit slot ID refers to a reserved slot. Reserved slots are skipped in
	slot storage allocation as they are used for UI actions.
]]
function GamepadActionBarBindingUtil.IsReservedPageUnitSlotID(gamepadPageUnitSlotID)
	return gamepadPageUnitSlotID >= FIRST_RESERVED_PAGE_UNIT_SLOT_INDEX
		and gamepadPageUnitSlotID <	FIRST_RESERVED_PAGE_UNIT_SLOT_INDEX + Constants.GamepadActionBarConstants.NUM_RESERVED_SLOTS_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT;
end

--[[
	Returns true if the specified id represents an action button residing in a pageable action bar on a standard page,
	or false otherwise.
]]
function GamepadActionBarBindingUtil.IsValidGamepadPageUnitSlotID(gamepadSlotID)
	--[[
		The pageUnitSlotID's are intended to represent a specific button position on a standard page. While
		the action the button holds depends on which page is active, the button's pageUnitSlotID remains the same across
		all pages.

		At the time of writing only buttons that exist on the pageable action bars found on the standard pages
		are assigned pageUnitSlotIDs.
	]]
	return gamepadSlotID > 0 and gamepadSlotID <= Constants.GamepadActionBarConstants.NUM_PAGEABLE_SLOTS_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT_STANDARD_PAGE;
end

--[[
	Returns true if the page unit slot ID refers to a bindable slot. If it returns false, user
	actions cannot be bound to that slot.
]]
function GamepadActionBarBindingUtil.IsBindablePageUnitSlotID(gamepadPageUnitSlotID)
	return GamepadActionBarBindingUtil.IsValidGamepadPageUnitSlotID(gamepadPageUnitSlotID)
		and not GamepadActionBarBindingUtil.IsReservedPageUnitSlotID(gamepadPageUnitSlotID);
end

--[[
	Returns the storage slot index for the action a pageable action button holds on the specified page number with the
	specified page unit slot id.

	gamepadPageNum - A page number that is associated with a standard page which has pageable action bars.

	gamepadPageUnitSlotID - The id of the button on the standard page which the associated storage slot index is being requested
							for.

	Returns the storage slot index which can be used with PickupAction, PlaceAction, or GetActionInfo to interact with the
	stored action.
]]
function GamepadActionBarBindingUtil.GetGamepadStorageSlotIndexFromPageAndPageUnitSlotID(gamepadPageNum, gamepadPageUnitSlotID)
	--[[
		Valid gamepad storage slots can't be calculated for non-standard pages because at the time
		of writing the standard pages are the only pages that support pageable action bars. We also
		only allocate storage for bindable slots.
	]]
	if not GamepadActionBarBindingUtil.IsStandardGamepadPageNum(gamepadPageNum)
		or not GamepadActionBarBindingUtil.IsBindablePageUnitSlotID(gamepadPageUnitSlotID)
	then
		return;
	end

	local firstGamepadStorageSlotIndex = C_GamepadUI.GetFirstGamepadActionStorageSlotIndex();
	local firstSlotOfSpecifiedPage = (Constants.GamepadActionBarConstants.NUM_PAGEABLE_SLOTS_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT_STANDARD_PAGE * (gamepadPageNum - 1)) + firstGamepadStorageSlotIndex;
	local storageSlotID = firstSlotOfSpecifiedPage + (gamepadPageUnitSlotID - 1);

	-- Skip reserved ranges for each page before this
	storageSlotID = storageSlotID - Constants.GamepadActionBarConstants.NUM_RESERVED_SLOTS_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT * (gamepadPageNum - 1);
	if gamepadPageUnitSlotID >= FIRST_RESERVED_PAGE_UNIT_SLOT_INDEX then
		storageSlotID = storageSlotID - Constants.GamepadActionBarConstants.NUM_RESERVED_SLOTS_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT;
	end

	return storageSlotID;
end

local function AreTableContentsEqual(t1, t2)
	local t1Size = #t1;
	if (t1Size ~= #t2) then
		return false;
	end

	for i = 1, t1Size do
		if (t1[i] ~= t2[i]) then
			return false;
		end
	end

	return true;
end

--[[
	Attempts to place an action in a gamepad action bar slot.

	gamepadStorageSlotIndex - The index used by PlaceAction that corresponds to the gamepad action bar slot the
							  action should be bound to.

	actionTypePickupFunc - A function that can pickup the action being assigned to the gamepad action bar.
						   If not provided, the action will be assumed to be on the cursor already and that
						   we are binding using the mouse.

	... - Any pickup function arguments required for the pickup function.

	Returns true if the action was placed in the gamepad action bar slot or false otherwise.
]]
function GamepadActionBarBindingUtil.AssignActionToGamepadStandardSlot(gamepadStorageSlotIndex, actionTypePickupFunc, ...)
	-- Is the gamepadStorageSlotIndex a valid gamepad slot?
	if (not C_GamepadUI.IsValidGamepadActionStorageSlotIndex(gamepadStorageSlotIndex)) then
		UIErrorsFrame:AddMessage(GAMEPAD_BIND_FAILURE_INVALID_STANDARD_SLOT, RED_FONT_COLOR:GetRGB());
		return false;
	end

	-- Place the action on the cursor. Otherwise assume action is already on cursor.
	if (actionTypePickupFunc) then
		ClearCursor();
		actionTypePickupFunc(...);
	end

	local prePlacementCursorInfo = { GetCursorInfo() };
	if (#prePlacementCursorInfo == 0) then
		UIErrorsFrame:AddMessage(GAMEPAD_BIND_FAILURE_NO_ACTION_ON_CURSOR, RED_FONT_COLOR:GetRGB());
		return false;
	end

	-- Attempt to place the action
	PlaceAction(gamepadStorageSlotIndex);

	-- Grab the cursor information after the placement to check if the action was successfully bound.
	local postPlacementCursorInfo = { GetCursorInfo() };
	ClearCursor();

	--[[
		If the cursor info remains the same as it did before the bind then the binding has failed.
		Otherwise another action has been picked up or the cursor is clear and the binding was successful.

		Note if the action being bound was the same as the existing bound action in the slot, the action
		is cleared from the cursor.
	]]
	local bindingSucceeded = not AreTableContentsEqual(prePlacementCursorInfo, postPlacementCursorInfo);
	if (not bindingSucceeded) then
		UIErrorsFrame:AddMessage(GAMEPAD_BIND_FAILURE_GENERIC_FAIL, RED_FONT_COLOR:GetRGB());
	end
	return bindingSucceeded;
end

--[[
	Attempts to clear an action from a gamepad action bar slot.

	gamepadStorageSlotIndex - The index used by PickupAction for standard slots or PickupPetAction
							  for possess bar slots that corresponds to the slot to clear.

	isGamepadPossessBarSlot - Indicates that the gamepadStorageSlotIndex represents a gamepad possess bar slot
							  rather than a standard slot.
]]
function GamepadActionBarBindingUtil.ClearActionFromGamepadSlot(gamepadStorageSlotIndex, isGamepadPossessBarSlot)
	if (isGamepadPossessBarSlot) then
		if (not C_GamepadUI.IsValidGamepadPossessBarStorageSlotIndex(gamepadStorageSlotIndex)) then
			return;
		end

		if (UnitIsCharmed("pet")) then
			UIErrorsFrame:AddMessage(GAMEPAD_POSSESS_BAR_MODIFICATION_NOT_POSSIBLE, RED_FONT_COLOR:GetRGB());
			return;
		end

		PickupPetAction(gamepadStorageSlotIndex);
		ClearCursor();
		return;
	end

	if (not C_GamepadUI.IsValidGamepadActionStorageSlotIndex(gamepadStorageSlotIndex)) then
		return;
	end

	PickupAction(gamepadStorageSlotIndex);
	ClearCursor();
end

--[[
	Attempts to place an action in a gamepad possess bar slot.

	gamepadPossessBarStorageSlotIndex - The index used by PickupPetAction that corresponds to the gamepad possess bar slot the
										action should be bound to.

	actionTypePickupFunc - A function that can pickup the action being assigned to the gamepad action bar.
						   If not provided, the action will be assumed to be on the cursor already and that
						   we are binding using the mouse.

	... - Any pickup function arguments required for the pickup function.

	Returns true if the action was placed in the gamepad possess bar slot or false otherwise.
]]
function GamepadActionBarBindingUtil.AssignActionToGamepadPossessBarSlot(gamepadPossessBarStorageSlotIndex, actionTypePickupFunc, ...)
	if (not IsPetActive()) then
		UIErrorsFrame:AddMessage(GAMEPAD_BIND_FAILURE_NO_ACTIVE_PET, RED_FONT_COLOR:GetRGB());
		return false;
	end

	if (UnitIsCharmed("pet")) then
		UIErrorsFrame:AddMessage(GAMEPAD_POSSESS_BAR_MODIFICATION_NOT_POSSIBLE, RED_FONT_COLOR:GetRGB());
		return false;
	end

	if (not C_GamepadUI.IsValidGamepadPossessBarStorageSlotIndex(gamepadPossessBarStorageSlotIndex)) then
		UIErrorsFrame:AddMessage(GAMEPAD_BIND_FAILURE_INVALID_POSSESS_SLOT, RED_FONT_COLOR:GetRGB());
		return false;
	end

	-- Try to pickup the specified action with the cursor if a function is specified. Otherwise assume action is on cursor already.
	if (actionTypePickupFunc) then
		ClearCursor();
		actionTypePickupFunc(...);
	end

	local currentCursorInfo = { GetCursorInfo() };
	if (#currentCursorInfo == 0) then
		UIErrorsFrame:AddMessage(GAMEPAD_BIND_FAILURE_NO_ACTION_ON_CURSOR, RED_FONT_COLOR:GetRGB());
		return false;
	end

	if (currentCursorInfo[1] ~= "petaction") then
		UIErrorsFrame:AddMessage(GAMEPAD_BIND_FAILURE_NON_PET_ACTION, RED_FONT_COLOR:GetRGB());
		ClearCursor();
		return false;
	end

	-- Store any information about the currently bound pet action in the slot we are trying to bind to.
	local prePlacementSlotInfo = { GetPetActionInfo(gamepadPossessBarStorageSlotIndex) };

	-- Attempt to place the action in the slot.
	PickupPetAction(gamepadPossessBarStorageSlotIndex);

	-- Store information about the pet action that is stored in the slot we attempted to bind to.
	local postPlacementSlotInfo = { GetPetActionInfo(gamepadPossessBarStorageSlotIndex) };

	if (not AreTableContentsEqual(prePlacementSlotInfo, postPlacementSlotInfo)) then
		ClearCursor();	-- In case the existing bound action was placed on cursor.
		return true;
	end

	--[[
		If the cursor is empty after the placement but the slot info remained the same then the player has bound
		the action to a slot already containing that action. Otherwise the binding failed.
	]]
	currentCursorInfo = { GetCursorInfo() };
	ClearCursor();
	local bindingSucceeded = #currentCursorInfo == 0;
	if (not bindingSucceeded) then
		UIErrorsFrame:AddMessage(GAMEPAD_BIND_FAILURE_GENERIC_FAIL, RED_FONT_COLOR:GetRGB());
	end
	return bindingSucceeded;
end

--[[
	Returns error string if the selected action cannot be unbound from gamepad action bars.
]]
function GamepadActionBarBindingUtil.GetUnbindErrorMessage(selectedActionInfo)
	local actionType = selectedActionInfo[1];
	if actionType == "petaction" and PetHasActionBar() then
		return ERR_GAMEPAD_CANNOT_CLEAR_ACTION;
	end

	if actionType == "flyout" then
		local flyoutID = selectedActionInfo[2];
		local HUNTER_ASPECT_FLYOUT_ID = 253;
		if flyoutID == HUNTER_ASPECT_FLYOUT_ID then
			return ERR_GAMEPAD_CANNOT_CLEAR_ACTION;
		end
	end

	return nil;
end
