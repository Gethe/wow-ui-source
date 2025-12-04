local HouseEditorLayoutModeShownEvents =
{
	"HOUSING_LAYOUT_ROOM_RECEIVED",
	"HOUSING_LAYOUT_ROOM_REMOVED",
	"HOUSING_LAYOUT_ROOM_MOVED",
};

----------------- Base Pin Mixin -----------------
HousingLayoutBasePinMixin = {};

function HousingLayoutBasePinMixin:SetPin(pin)
	self.pin = pin;
	self:SetParent(pin);
	self:SetPoint("CENTER", pin, "CENTER", 0, 0);
	pin:SetUpdateCallback(function() self:Update(); end);
	-- Used for easier frame inspection for debugging
	pin.GetDebugName = GenerateClosure(self.GetPinDebugName, self);

	self:Init();
	self:Show();
end

function HousingLayoutBasePinMixin.Reset(framePool, self)
	Pool_HideAndClearAnchors(framePool, self);

	if self.pin then
		self.pin.GetDebugName = nil;
		self.pin = nil;
	end
end

function HousingLayoutBasePinMixin:GetPin()
	return self.pin;
end

function HousingLayoutBasePinMixin:HasActivePin()
	return self.pin and self.pin:IsValid();
end

function HousingLayoutBasePinMixin:Init()
	-- Required to be implemented by specialized mixins
	assert(false);
end

function HousingLayoutBasePinMixin:Update()
	-- Required to be implemented by specialized mixins
	assert(false);
end

function HousingLayoutBasePinMixin:GetPinDebugName()
	-- Required to be implemented by specialized mixins
	assert(false);
end


----------------- Door Pin Mixin -----------------
HousingLayoutDoorPinMixin = CreateFromMixins(HousingLayoutBasePinMixin);

function HousingLayoutDoorPinMixin:Init()
	self.connectionType = nil;

	local pin = self:GetPin();
	local doorInfo = pin and pin:IsValid() and self:GetPin():GetDoorConnectionInfo() or nil;
	self.connectionType = doorInfo and doorInfo.connectionType or nil;
	self.enabledTooltip = HOUSING_LAYOUT_UNOCCUPIED_DOOR_TOOLTIP;

	if self.connectionType == Enum.HousingRoomComponentType.Ceiling then
		self.ArrowIcon:SetRotation(0);
		self.ArrowIcon:Show();
		self:SetPoint("CENTER", pin, "CENTER", 0, 50);
		self.enabledTooltip = HOUSING_LAYOUT_UP_DOOR_TOOLTIP;
	elseif self.connectionType == Enum.HousingRoomComponentType.Floor then
		self.ArrowIcon:SetRotation(PI);
		self.ArrowIcon:Show();
		self:SetPoint("CENTER", pin, "CENTER", 0, -50);
		self.enabledTooltip = HOUSING_LAYOUT_DOWN_DOOR_TOOLTIP;
	else
		self.ArrowIcon:Hide();
	end

	self.Rays1.Anim:Play();
	self.Rays2.Anim:Play();
	self.Spinner.Anim:Play();

	local rot = doorInfo and doorInfo.doorFacing or 0;
	self.NodeAvailable.Base.NodeBase:SetRotation(rot);
	self.NodeAvailable.InteriorNodeAvailable.Glow:SetRotation(rot);

	self:Update();
end

function HousingLayoutDoorPinMixin:Update()
	if not self:HasActivePin() then
		return;
	end

	local pin = self:GetPin();
	local isOccupied = pin:IsOccupiedDoor();
	local isAtBudgetMax = C_HousingLayout.HasRoomPlacementBudget() and C_HousingLayout.GetSpentPlacementBudget() >= C_HousingLayout.GetRoomPlacementBudget();
	local isEnabled = not isOccupied and not isAtBudgetMax;
	self:SetEnabled(isEnabled);
	self.disabledTooltip = isOccupied and HOUSING_LAYOUT_OCCUPIED_DOOR_TOOLTIP or isAtBudgetMax and ERR_PLACED_ROOM_LIMIT_REACHED or nil;

	if (isOccupied) then
		self:Hide();
	elseif C_HousingLayout.HasSelectedRoom() then
		self.NodeAvailable:Hide();
		self:SetShown(pin:IsAnyPartOfRoomSelected());
	elseif C_HousingLayout.HasSelectedFloorplan() then
		local showWithAvailableAnim = pin:IsValidForSelectedFloorplan();
		self:SetShown(showWithAvailableAnim);
		self.NodeAvailable:SetShown(showWithAvailableAnim);
	else
		self:Show();
		self.NodeAvailable:Hide();
	end

	local selected = self:GetPin():IsSelected();
	if not selected and self.selectedLoopSound then
		StopSound(self.selectedLoopSound);
		self.selectedLoopSound = nil;
	end

	self:UpdateVisuals();
end

function HousingLayoutDoorPinMixin:UpdateVisuals()
	if not self:HasActivePin() then
		return;
	end

	local isEnabled = self:IsEnabled();
	local isHovered = self:IsMouseMotionFocus();
	local isSelected = self:GetPin():IsSelected();
	
	local isFocused = isEnabled and (isHovered or isSelected);
	self:SetAlpha(isEnabled and 1 or 0.2);

	self.Icon:SetShown(not isFocused);
	self.ActiveIcon:SetShown(isFocused);
	self.SelectedGlow:SetShown(isSelected);
	self.Rays1:SetShown(isSelected);
	self.Spinner:SetShown(isSelected);
	self.Glow:SetShown(isSelected);
	self.Rays2:SetShown(isSelected);
end

function HousingLayoutDoorPinMixin:OnEnter()
	local isEnabled = self:IsEnabled();
	local hasTooltipContent = false;
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);

	if isEnabled then
		GameTooltip_AddHighlightLine(tooltip, self.enabledTooltip);
		hasTooltipContent = true;
	elseif self.disabledTooltip then
		GameTooltip_AddErrorLine(tooltip, self.disabledTooltip);
		hasTooltipContent = true;
	end

	self.ArrowIconHover:SetShown(isEnabled and self.ArrowIcon:IsShown());

	tooltip:SetShown(hasTooltipContent);

	self:UpdateVisuals();

	EventRegistry:TriggerEvent("HousingLayoutDoorPin.MouseOver", self, self:GetPin());

	if self:HasActivePin() and self:IsEnabled() then
		--only play for door nodes that can have rooms added to them
		PlaySound(SOUNDKIT.HOUSING_ADD_ROOM_HOVER)
	end
end

function HousingLayoutDoorPinMixin:OnLeave()
	GameTooltip_Hide();

	self.ArrowIconHover:Hide();

	self:UpdateVisuals();
end

function HousingLayoutDoorPinMixin:OnClick()
	local isDragging = C_HousingLayout.IsDraggingRoom();
	if not self:HasActivePin() or isDragging then
		return;
	end

	self:GetPin():Select();

	PlaySound(SOUNDKIT.HOUSING_LAYOUT_SELECT_ADD_ROOM_NODE);
	if self.selectedLoopSound then
		StopSound(self.selectedLoopSound);
		self.selectedLoopSound = nil;
	end
	self.selectedLoopSound = select(2, PlaySound(SOUNDKIT.HOUSING_LAYOUT_SELECT_ADD_ROOM_NODE_LOOP));
end

function HousingLayoutDoorPinMixin:GetDebugName()
	-- Used for easier frame inspection for debugging
	return "DoorPinUI";
end

function HousingLayoutDoorPinMixin:GetPinDebugName()
	local isEnabled = self:IsEnabled();
	local hasPin = self:HasActivePin();

	local pinName = "DoorPin";
	if not isEnabled then
		pinName = pinName.." - Disabled";
	elseif not hasPin then
		pinName = pinName.." - Inactive";
	end
	return pinName;
end

----------------- Room Pin Mixin -----------------
HousingLayoutRoomPinMixin = CreateFromMixins(HousingLayoutBasePinMixin);

function HousingLayoutRoomPinMixin:OnLoad()
	
	do --Rotate
		local function LoadRotateButton(button, isLeft)
			button.extraDisabledCheck = GenerateClosure(self.CheckRotateDisabled, self);

			button:SetScript("OnClick", function()
				if self:HasActivePin() then
					C_HousingLayout.RotateRoom(self:GetPin():GetRoomGUID(), isLeft);
					PlaySound(SOUNDKIT.HOUSING_ROOM_ROTATE);
				end
			end);
		end

		LoadRotateButton(self.OptionsContainer.RotateButtonLeft, true);
		LoadRotateButton(self.OptionsContainer.RotateButtonRight, false);
	end

	do --Move
		self.OptionsContainer.MoveButton.extraDisabledCheck = GenerateClosure(self.CheckMoveDisabled, self);

		self.OptionsContainer.MoveButton:SetScript("OnClick", function()
			if self:HasActivePin() then
				local accessible = true;
				self:GetPin():Drag(accessible);
			end
		end);
	end

	do --Remove
		self.OptionsContainer.RemoveButton.extraDisabledCheck = GenerateClosure(self.CheckRemoveDisabled, self);

		self.OptionsContainer.RemoveButton:SetScript("OnClick", function()
			if self:HasActivePin() then
				if StaticPopup_IsCustomGenericConfirmationShown(HouseEditorFrame.LayoutModeFrame) then
					return;
				end
				local roomGUID = self:GetPin():GetRoomGUID();
				StaticPopup_ShowCustomGenericConfirmation({
					text = HOUSING_LAYOUT_REMOVE_ROOM_CONFIRMATION,
					acceptText = YES,
					cancelText = CANCEL,
					callback = function()
						C_HousingLayout.RemoveRoom(roomGUID);
						PlaySound(SOUNDKIT.HOUSING_ROOM_DELETE);
					end,
					referenceKey = HouseEditorFrame.LayoutModeFrame, --will cause it to be closed on HouseEditorLayoutModeMixin:OnHide.
				});
			end
		end);
	end
end

function HousingLayoutRoomPinMixin:Init()
	self.RoomName:SetText(self:GetPin():GetRoomName());
	self:Update();
end

function HousingLayoutRoomPinMixin:Update()
	if not self:HasActivePin() then
		return;
	end

	local pin = self:GetPin();
	local isSelected = pin:IsSelected();
	local isBaseRoom = C_HousingLayout.IsBaseRoom(pin:GetRoomGUID())

	self.OptionsContainer:SetShown(isSelected);
	self:SetEnabled(not isBaseRoom);

	self:UpdateVisuals();
end

function HousingLayoutRoomPinMixin:OnDragStart()
	local accessible = false;
	self:GetPin():Drag(accessible);
end

function HousingLayoutRoomPinMixin:UpdateVisuals()
	if not self:HasActivePin() then
		return;
	end

	local isEnabled = self:IsEnabled();
	local isHovered = self:IsMouseMotionFocus();
	local isSelected = self:GetPin():IsSelected();

	local showBigger = isEnabled and isHovered and not isSelected;
	self:SetScale(showBigger and 1.25 or 1);

	local textColor;
	if not isEnabled then
		textColor = GRAY_FONT_COLOR;
	elseif isSelected or isHovered then
		textColor = WHITE_FONT_COLOR;
	else
		textColor = YELLOW_FONT_COLOR;
	end

	self.RoomName:SetTextColor(textColor:GetRGB());

	if self.iconAtlas then
		if isEnabled then
			self.Icon:SetAtlas(self.iconAtlas);
		else
			local disableAtlas = self.iconAtlas .. "-disable";
			if C_Texture.GetAtlasInfo(disableAtlas) then
				self.Icon:SetAtlas(disableAtlas);
			end
		end
	end
end

function HousingLayoutRoomPinMixin:OnClick()
	if not self:HasActivePin() then
		return;
	end

	PlaySound(SOUNDKIT.HOUSING_SELECT_ROOM);
	self:GetPin():Select();
	self:SetScale(1);
end

function HousingLayoutRoomPinMixin:OnShow()
	self:Layout();
	self.OptionsContainer:Layout();
	FrameUtil.RegisterFrameForEvents(self, HouseEditorLayoutModeShownEvents);
end

function HousingLayoutRoomPinMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, HouseEditorLayoutModeShownEvents);
end

function HousingLayoutRoomPinMixin:OnEnter()
	self:UpdateVisuals();
	EventRegistry:TriggerEvent("HousingLayoutRoomPin.MouseOver", self, self:GetPin());
end

function HousingLayoutRoomPinMixin:OnLeave()
	self:UpdateVisuals();
end

function CheckDisabledHelper(getButtons, getRestrictionFn, specializedRestrictionStrings)
	return function(self)
		local buttons = getButtons(self);
		if not self:HasActivePin() then
			for _, button in ipairs(buttons) do
				button.disabledTooltip = nil;
			end
			return true;
		end

		local restriction = getRestrictionFn(self);
		local hasRestrictions = restriction ~= Enum.HousingLayoutRestriction.None;

		local disabledTooltip = nil;
		if specializedRestrictionStrings[restriction] then
			disabledTooltip = specializedRestrictionStrings[restriction];
		else
			disabledTooltip = HousingLayoutGenericRestrictionStrings[restriction];
		end

		for _, button in ipairs(buttons) do
			button.disabledTooltip = disabledTooltip;
		end

		return hasRestrictions;
	end
end

HousingLayoutRoomPinMixin.CheckRotateDisabled = CheckDisabledHelper(
	function(self) return {self.OptionsContainer.RotateButtonLeft, self.OptionsContainer.RotateButtonRight}; end,
	function(self) return self:GetPin():CanRotate(); end,
	HousingLayoutRotateRestrictionStrings
);

HousingLayoutRoomPinMixin.CheckRemoveDisabled = CheckDisabledHelper(
	function(self) return {self.OptionsContainer.RemoveButton}; end,
	function(self) return self:GetPin():CanRemove(); end,
	HousingLayoutRemoveRestrictionStrings
);

HousingLayoutRoomPinMixin.CheckMoveDisabled = CheckDisabledHelper(
	function(self) return {self.OptionsContainer.MoveButton}; end,
	function(self) return self:GetPin():CanMove(); end,
	HousingLayoutMoveRestrictionStrings
);

function HousingLayoutRoomPinMixin:GetDebugName()
	-- Used for easier frame inspection for debugging
	local name = "RoomPinUI";
	return name;
end

function HousingLayoutRoomPinMixin:GetPinDebugName()
	local pinName = "RoomPin";
	local isActive = self:HasActivePin();
	if not isActive then
		pinName = pinName.." - Inactive";
	else
		local roomName = self:GetPin():GetRoomName();
		if roomName and roomName ~= "" then
			pinName = pinName.." - "..roomName;
		end
	end

	return pinName;
end

function HousingLayoutRoomPinMixin:OnEvent(event, ...)
	if event == "HOUSING_LAYOUT_ROOM_RECEIVED" or
	   event == "HOUSING_LAYOUT_ROOM_REMOVED" or
	   event == "HOUSING_LAYOUT_ROOM_MOVED"
	then
		for _, button in ipairs(self.OptionsContainer.Buttons) do
			button:Update();
		end
	end
end

----------------- Room Option Mixin -----------------
HousingLayoutRoomOptionMixin = {};

function HousingLayoutRoomOptionMixin:OnLoad()
	if self.iconAtlas and self.iconAtlas ~= "" then
		self.Icon:SetAtlas(self.iconAtlas, TextureKitConstants.IgnoreAtlasSize);
		self.HoverIcon:SetAtlas(self.iconAtlas, TextureKitConstants.IgnoreAtlasSize);
	end
end

function HousingLayoutRoomOptionMixin:OnShow()
	self:Update();
end

function HousingLayoutRoomOptionMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
	if self.disabledTooltip then
		GameTooltip_AddErrorLine(GameTooltip, self.disabledTooltip);
	else
		GameTooltip_AddNormalLine(GameTooltip, self.tooltipText);
	end
	GameTooltip:Show();

	if self:IsEnabled() then
		self.HoverIcon:Show();
		self.HoverBackground:Show();
	end
end

function HousingLayoutRoomOptionMixin:OnLeave()
	GameTooltip:Hide();

	if self:IsEnabled() then
		self.HoverIcon:Hide();
		self.HoverBackground:Hide();
	end
end

function HousingLayoutRoomOptionMixin:Update()
	local enabled = true;
	self.disabledTooltip = nil;
	if self.extraDisabledCheck and self:extraDisabledCheck() then
		enabled = false;
	end

	if enabled ~= self:IsEnabled() then
		self:SetEnabled(enabled);
		self.Icon:SetDesaturated(not enabled);
	end
end
