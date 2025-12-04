
local ROOM_PIN_FRAME_LEVEL = 500;
local DOOR_PIN_FRAME_LEVEL = 1000;

local HouseEditorLayoutModeLifetimeEvents =
{
	"HOUSING_LAYOUT_PIN_FRAME_ADDED",
	"HOUSING_LAYOUT_PIN_FRAME_RELEASED",
	"HOUSING_LAYOUT_PIN_FRAMES_RELEASED",
};

local HouseEditorLayoutModeShownEvents =
{
	"HOUSING_LAYOUT_DOOR_SELECTION_CHANGED",
	"HOUSING_LAYOUT_ROOM_SELECTION_CHANGED",
	"HOUSING_LAYOUT_FLOORPLAN_SELECTION_CHANGED",
	"HOUSING_LAYOUT_DRAG_TARGET_CHANGED",
	"GLOBAL_MOUSE_UP",
	"GLOBAL_MOUSE_DOWN",
	"UPDATE_BINDINGS",
	"HOUSING_LAYOUT_ROOM_RECEIVED",
	"HOUSING_LAYOUT_ROOM_REMOVED",
	"HOUSING_LAYOUT_ROOM_MOVED",
	"HOUSING_LAYOUT_NUM_FLOORS_CHANGED",
	"HOUSING_LAYOUT_ROOM_SNAPPED",
	"HOUSING_LAYOUT_ROOM_MOVE_INVALID",
};

HouseEditorLayoutModeMixin = CreateFromMixins(BaseHouseEditorModeMixin);

function HouseEditorLayoutModeMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, HouseEditorLayoutModeLifetimeEvents);

	self.roomPinPool = CreateFramePool("BUTTON", self, "HousingLayoutRoomPinTemplate", HousingLayoutBasePinMixin.Reset);
	self.doorPinPool = CreateFramePool("BUTTON", self, "HousingLayoutDoorPinTemplate", HousingLayoutBasePinMixin.Reset);

	self.LayoutDragUnderlay:SetScript("OnMouseUp", function()
		C_HousingLayout.StopDrag()
	end);

	self.LayoutDragUnderlay:SetScript("OnMouseDown", function()
		C_HousingLayout.StartDrag()
	end);
end

function HouseEditorLayoutModeMixin:OnEvent(event, ...)
	if event == "HOUSING_LAYOUT_PIN_FRAME_ADDED" then
		local pinFrame = ...;
		self:AddPin(pinFrame);
	elseif event == "HOUSING_LAYOUT_PIN_FRAME_RELEASED" then
		local pinFrame = ...;
		self:ReleasePin(pinFrame);
	elseif event == "HOUSING_LAYOUT_PIN_FRAMES_RELEASED" then
		self:ReleasePins();
	elseif event == "HOUSING_LAYOUT_DOOR_SELECTION_CHANGED" then
		local hasSelection = ...;
		if hasSelection then
			self:GetParent():ExpandHouseStorage();
		end
		self:UpdateShownInstructions();
	elseif event == "GLOBAL_MOUSE_UP" or event == "GLOBAL_MOUSE_DOWN" then
		--should be able to drag rooms between floors
		if self.FloorSelect:IsMouseOver() then
			return;
		end

		local button = ...;
		local isDragging, isAccessible = C_HousingLayout.IsDraggingRoom();
		if not isDragging then
			return;
		end

		if event == "GLOBAL_MOUSE_UP" and not isAccessible and button == "LeftButton" then
			C_HousingLayout.StopDraggingRoom();
		elseif event == "GLOBAL_MOUSE_DOWN" and isAccessible and button == "LeftButton" then
			C_HousingLayout.StopDraggingRoom();
		end
	elseif event == "UPDATE_BINDINGS" then
		self:UpdateKeybinds();
	elseif event == "HOUSING_LAYOUT_FLOORPLAN_SELECTION_CHANGED" or event == "HOUSING_LAYOUT_ROOM_SELECTION_CHANGED" or event == "HOUSING_LAYOUT_DRAG_TARGET_CHANGED" then
		self:UpdateShownInstructions();
	elseif event == "HOUSING_LAYOUT_ROOM_RECEIVED" then
		local prevNumFloors, currNumFloors, isUpStairs = ...;
		if not isUpStairs and prevNumFloors >= currNumFloors then
			--upstairs rooms don't play a sound because downstairs is playing a sound
			--downstairs rooms that add a new floor play the floor added sound instead
			--revisit this code if we add basements
			PlaySound(SOUNDKIT.HOUSING_ROOM_ADDED);
		end
	elseif event == "HOUSING_LAYOUT_ROOM_REMOVED" then
		-- TODO: Guessing this should have a remove-specific sound played here?
	elseif event == "HOUSING_LAYOUT_ROOM_MOVED" then
		PlaySound(SOUNDKIT.HOUSING_ROOM_MOVED);
	elseif event == "HOUSING_LAYOUT_NUM_FLOORS_CHANGED" then
		local prevNumFloors, currNumFloors = ...;
		if prevNumFloors < currNumFloors then
			PlaySound(SOUNDKIT.HOUSING_FLOOR_ADDED);
		end
	elseif event == "HOUSING_LAYOUT_ROOM_SNAPPED" then
		PlaySound(SOUNDKIT.HOUSING_ROOM_MOVE_SNAP);
	elseif event == "HOUSING_LAYOUT_ROOM_MOVE_INVALID" then
		PlaySound(SOUNDKIT.HOUSING_INVALID_PLACEMENT);
	end
end

function HouseEditorLayoutModeMixin:OnShow()
	self:UpdateShownInstructions();
	self:UpdateKeybinds();
	FrameUtil.RegisterFrameForEvents(self, HouseEditorLayoutModeShownEvents);
	self:GetParent():ShowHouseStorage();
	C_KeyBindings.ActivateBindingContext(Enum.BindingContext.HousingEditorLayoutMode);
	PlaySound(SOUNDKIT.HOUSING_ENTER_LAYOUT_MODE);
end

function HouseEditorLayoutModeMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, HouseEditorLayoutModeShownEvents);

	local referenceKey = self;
	if StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
		StaticPopup_Hide("GENERIC_CONFIRMATION");
	end

	C_HousingLayout.CancelActiveLayoutEditing();
	C_KeyBindings.DeactivateBindingContext(Enum.BindingContext.HousingEditorLayoutMode);
	PlaySound(SOUNDKIT.HOUSING_EXIT_LAYOUT_MODE);
end

function HouseEditorLayoutModeMixin:TryHandleEscape()
	if C_HousingLayout.HasAnySelections() then
		C_HousingLayout.CancelActiveLayoutEditing();
		PlaySound(SOUNDKIT.HOUSING_CANCEL_ROOM_SELECTION);
		return true;
	end
	return false;
end

function HouseEditorLayoutModeMixin:UpdateShownInstructions()
	local isRoomSelected = C_HousingLayout.HasAnySelections();
	self:SetInstructionShown(self.Instructions.UnselectedInstructions, not isRoomSelected);
	self:SetInstructionShown(self.Instructions.SelectedInstructions, isRoomSelected);
	self.Instructions:UpdateLayout();
end

function HouseEditorLayoutModeMixin:SetInstructionShown(instructionSet, shouldShow)
	for _, instruction in ipairs(instructionSet) do
		instruction:SetShown(shouldShow);
	end
end

function HouseEditorLayoutModeMixin:UpdateKeybinds()
	self.Instructions:UpdateAllControls();
end

function HouseEditorLayoutModeMixin:AddPin(pinFrame)
	pinFrame:SetParent(self);

	local pinPool = nil;
	local pinType = pinFrame:GetPinType();

	if pinType == Enum.HousingLayoutPinType.Room then
		pinPool = self.roomPinPool;
		-- Must set FrameStratas here as they get reset on reparenting in & out of Pools
		pinFrame:SetFrameLevel(ROOM_PIN_FRAME_LEVEL);
	elseif pinType == Enum.HousingLayoutPinType.Door then
		pinPool = self.doorPinPool;
		-- Set Door pins higher than Rooms so they aren't potentially blocked by lengthy room names
		pinFrame:SetFrameLevel(DOOR_PIN_FRAME_LEVEL);
	end

	if pinPool then
		local newPin = pinPool:Acquire();
		newPin:SetPin(pinFrame);
		pinFrame.boundPin = newPin;
	end
end

function HouseEditorLayoutModeMixin:ReleasePin(pinFrame)
	local pinPool = nil;

	local pinType = pinFrame:GetPinType();
	if pinType == Enum.HousingLayoutPinType.Room then
		pinPool = self.roomPinPool;
	elseif pinType == Enum.HousingLayoutPinType.Door then
		pinPool = self.doorPinPool;
	end
		
	pinPool:Release(pinFrame.boundPin);
	pinFrame.boundPin = nil;
end

function HouseEditorLayoutModeMixin:ReleasePins()
	self.roomPinPool:ReleaseAll();
	self.doorPinPool:ReleaseAll();
end

local HouseEditorLayoutFloorSelectShownEvents =
{
	"HOUSING_LAYOUT_VIEWED_FLOOR_CHANGED",
	"HOUSING_LAYOUT_NUM_FLOORS_CHANGED",
};

HouseEditorLayoutFloorSelectMixin = {};

function HouseEditorLayoutFloorSelectMixin:OnLoad()
	self.UpButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.HOUSING_VIEW_FLOOR_UP);
		C_HousingLayout.SetViewedFloor(self.currentFloor + 1);
	end);
	self.DownButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.HOUSING_VIEW_FLOOR_DOWN);
		C_HousingLayout.SetViewedFloor(self.currentFloor - 1);
	end);
end

function HouseEditorLayoutFloorSelectMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, HouseEditorLayoutFloorSelectShownEvents);
	self:UpdateFloorInfo();
end

function HouseEditorLayoutFloorSelectMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, HouseEditorLayoutFloorSelectShownEvents);
end

function HouseEditorLayoutFloorSelectMixin:OnEvent(event, ...)
	if event == "HOUSING_LAYOUT_VIEWED_FLOOR_CHANGED" or event == "HOUSING_LAYOUT_NUM_FLOORS_CHANGED" then
		self:UpdateFloorInfo();
	end
end

function HouseEditorLayoutFloorSelectMixin:UpdateFloorInfo()
	self.currentFloor = C_HousingLayout.GetViewedFloor();
	self.FloorText:SetText(HOUSING_LAYOUT_FLOOR_DISPLAY:format(self.currentFloor + 1)); -- Floors start at 0, which is confusing for players so display starting at 1

	self.UpButton:SetEnabled(C_HousingLayout.AnyRoomsOnFloor(self.currentFloor + 1));
	self.DownButton:SetEnabled(C_HousingLayout.AnyRoomsOnFloor(self.currentFloor - 1));
end
