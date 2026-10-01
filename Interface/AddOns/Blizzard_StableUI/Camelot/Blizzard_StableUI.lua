
local CURRENT_PET_SLOT = 1;
local GAMEPAD_ROTATION_SPEED = 300;
local GAMEPAD_ZOOM_SPEED = 10;

StableFrameMixin = {};

function StableFrameMixin:OnLoad()
	self:RegisterEvent("PET_STABLE_SHOW");
	self:RegisterEvent("PET_STABLE_UPDATE");
	self:RegisterEvent("PET_STABLE_CLOSED");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("PLAYER_MONEY");
	self:RegisterEvent("SPELLS_CHANGED");

	EventRegistry:RegisterCallback("StableFrameMixin.PetSelected", self.OnPetSelected, self);
	EventRegistry:RegisterCallback("StableFrameMixin.PetSwapRequested", self.OnPetSwapRequested, self);

	local panelAttributes = {
		area = "left",
		pushable = 1,
		allowOtherPanels = 1,
		width = 384,
		height = 512,
	};
	RegisterUIPanel(self, panelAttributes);

	self.expBar.GetLevelData = function()
		local petInfo = C_StableInfo.GetStablePetInfo(self.selectedPet or CURRENT_PET_SLOT);

		if petInfo then
			return petInfo.experience, petInfo.experienceNeeded, petInfo.level;
		end

		return 0, 0, 0;
	end
	self.expBar:SetTextLocked(true);

	self:RegisterForTransitions();
end

function StableFrameMixin:OnEvent(event, ...)
	local arg1 = ...;
	if ( event == "PET_STABLE_SHOW" ) then
		ShowUIPanel(self);
	elseif ( event == "PET_STABLE_UPDATE" or event == "SPELLS_CHANGED" or (event == "UNIT_PET" and arg1 == "player") or event == "PLAYER_MONEY" ) then
		self:Update();
	elseif ( event == "PET_STABLE_CLOSED" ) then
		HideUIPanel(self);
		StaticPopup_Hide("CONFIRM_BUY_STABLE_SLOT");
	end
end

function StableFrameMixin:OnShow()
	self:SetPortraitToUnit(UnitGUID("npc") and "npc" or "player");
	self.loyaltyLevel:Hide();
	self:SelectPet(CURRENT_PET_SLOT);
end

function StableFrameMixin:OnHide()
	C_StableInfo.ClosePetStables();
	StableUtils.ClearPetCursor();
	self.selectedPet = nil;
end

function StableFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function StableFrameMixin:SetupGamepad()
	local function CanPlacePet()
		return GetCursorInfo() == "pet";
	end

	local function PlacePet()
		local cursorType, petSlotID = GetCursorInfo();
		if cursorType == "pet" then
			local button = SmartNavigation:GetCurrentButton();
			EventRegistry:TriggerEvent("StableFrameMixin.PetSwapRequested", petSlotID, button:GetID(), true);
			ClearCursor();
		end
	end

	local function CanPickUpPet()
		local button = SmartNavigation:GetCurrentButton();
		return C_StableInfo.GetStablePetInfo(button:GetID());
	end

	local function PickUpPet()
		local button = SmartNavigation:GetCurrentButton();
		C_StableInfo.PickupStablePet(button:GetID());
	end

	local function CanPurchaseSlot()
		local button = SmartNavigation:GetCurrentButton();
		-- The first ID is for the current pet, so the stable slots start at 2
		return (button:GetID() - 1) > C_StableInfo.GetNumStableSlots();
	end

	local function PurchaseSlot()
		StaticPopup_Show("CONFIRM_BUY_STABLE_SLOT");
	end

	local placePetBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, PlacePet, ACTION_LABEL_SELECT);
	placePetBinding:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	placePetBinding:AddButtonContext("ButtonContext_StableFramePetButton");
	placePetBinding:AddCondition(CanPlacePet);

	local pickUpPetBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, PickUpPet, ACTION_LABEL_SELECT);
	pickUpPetBinding:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	pickUpPetBinding:AddButtonContext("ButtonContext_StableFramePetButton");
	pickUpPetBinding:AddCondition(CanPickUpPet);

	local purchaseSlotBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, PurchaseSlot, PURCHASE);
	purchaseSlotBinding:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	purchaseSlotBinding:AddButtonContext("ButtonContext_StableFramePetButton");
	purchaseSlotBinding:AddCondition(CanPurchaseSlot);

	local paperDollZoom = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT_VERTICAL, nil, FRAME_ACTION_ZOOM);
	local paperDollRotate = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT_HORIZONTAL, nil, ACTION_LABEL_ROTATE);
	local paperDollReset = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT_PRESS, GenerateClosure(self.modelScene.Reset, self.modelScene), RESET);
	self.footer = GamepadSharedUtility.CreatePromptedBindingFooter(self, "StableFrameFooter");
	self.footer:SetAnchorOffsets(0, -5);
	self.footer:AddPromptedBinding(placePetBinding);
	self.footer:AddPromptedBinding(pickUpPetBinding);
	self.footer:AddPromptedBinding(purchaseSlotBinding);
	self.footer:AddPromptedBinding(paperDollZoom);
	self.footer:AddPromptedBinding(paperDollRotate);
	self.footer:AddPromptedBinding(paperDollReset);
	self.footer:AddStandardBackPrompt();
	self.footer:Finalize();

	self.bindings = GamepadMode.CreateBindingGroup("StableFrameBindings");
	self.bindings:AddAxisBinding(GAMEPAD_STICK_RIGHT, GenerateClosure(self.SetZoomAndRotateSpeeds, self));

	SmartNavigation_MarkFrameFocusable(self.diet);
	SmartNavigation_MarkFrameIgnored(self.modelScene);
	SmartNavigation_AddJumpNavigationOverride(PetStableCurrentPet, SMART_NAV_INPUT_DIRECTION.UP, self.diet);

	SmartNavigation:SetSmartNavPanelInfoAddedCallback(self, function()
		SmartNavigation:SetTargetButtonForFrame(self, PetStableCurrentPet);
	end);
end

function StableFrameMixin:InitializeGamepad()
	PetStableCurrentPet.Text:SetFontObject(GameFontNormal);
	PetStableStabledPet1.Text:SetFontObject(GameFontNormal);

	PetStableCurrentPet:SetPointsOffset(-69, -40);
	PetStableCurrentPet.Text:SetPointsOffset(0, 12);
	PetStableStabledPet1.Text:SetPointsOffset(24, 12);

	PetStableCostMoneyFrame:ClearAllPoints();
	PetStableCostMoneyFrame:SetPoint("RIGHT", self.GamepadSlotCostText);

	self.CloseButton:Hide();
	self.purchaseButton:Hide();
	PetStableCostLabel:Hide();
	PetStableSlotText:Hide();
	self:Update();
end

function StableFrameMixin:UninitializeGamepad()
	PetStableCurrentPet.Text:SetFontObject(GameFontNormalSmall);
	PetStableStabledPet1.Text:SetFontObject(GameFontNormalSmall);

	PetStableCurrentPet.Text:SetPointsOffset(0, 6);
	PetStableStabledPet1.Text:SetPointsOffset(24, 6);

	PetStableCostMoneyFrame:ClearAllPoints();
	PetStableCostMoneyFrame:SetPoint("LEFT", PetStableCostLabel, "RIGHT");

	self.CloseButton:Show();
	self.GamepadSlotCostText:Hide();
	self:Update();
end

function StableFrameMixin:FocusGamepad()
	self.footer:ShowAndActivateBindings();
	GamepadMode.ActivateBindingGroup(self.bindings);
end

function StableFrameMixin:UnfocusGamepad()
	self:SetZoomAndRotateSpeeds(0, 0);
	self.footer:HideAndDeactivateBindings();
	GamepadMode.DeactivateBindingGroup(self.bindings);
end

function StableFrameMixin:SetZoomAndRotateSpeeds(rotation, zoom)
	self.rotationSpeed = rotation * GAMEPAD_ROTATION_SPEED;
	self.zoomSpeed = zoom * GAMEPAD_ZOOM_SPEED;

	if rotation ~= 0 or zoom ~= 0 then
		self:SetScript("OnUpdate", self.OnUpdate);
	else
		self:SetScript("OnUpdate", nil);
	end
end

function StableFrameMixin:OnUpdate(elapsed)
	local camera = self.modelScene:GetActiveCamera();
	if camera then
		camera:AdjustYaw(self.rotationSpeed * elapsed, 0);
		camera:ZoomBy(self.zoomSpeed * elapsed);
	end
end

function StableFrameMixin:Update()
	local nextCost = C_StableInfo.GetNextStableSlotCost();
	MoneyFrame_Update("PetStableCostMoneyFrame", nextCost);

	if self.lastSwappedDestinationSlot and C_StableInfo.GetStablePetInfo(self.lastSwappedDestinationSlot) then
		self:SelectPet(self.lastSwappedDestinationSlot);
		self.lastSwappedDestinationSlot = nil;
	end

	for i=1,Constants.PetConsts.NUM_PET_SLOTS_HUNTER,1 do
		local slot = self:GetSlotFrame(i);
		if slot then
			slot:Update();
		end
	end

	local selectedPetInfo = C_StableInfo.GetStablePetInfo(self.selectedPet or CURRENT_PET_SLOT);

	if selectedPetInfo then
		self.modelScene:SetPet(selectedPetInfo);
	end

	if InputUtil.IsGamepadUIEnabled() then
		local canPurchase = C_StableInfo.GetNumStableSlots() < Constants.PetConsts.MAX_STABLE_SLOTS;
		self.GamepadSlotCostText:SetShown(canPurchase);
		PetStableCostMoneyFrame:SetShown(canPurchase);
		self.footer:Refresh();
	else
		self.purchaseButton:Update();

		if not self.purchaseButton:IsShown() then
			PetStableCurrentPet:SetPoint("TOP", self.modelScene, "BOTTOM", -69, -43);
		else
			PetStableCurrentPet:SetPoint("TOP", self.modelScene, "BOTTOM", -69, -23);
		end
	end
end

function StableFrameMixin:GetSlotFrame(index)
	if index == 1 then
		return PetStableCurrentPet;
	elseif index == 2 then
		return PetStableStabledPet1;
	elseif index == 3 then
		return PetStableStabledPet2;
	end

	error("No pet frame for slot " .. index);
end

function StableFrameMixin:OnPetSelected(index)
	self:SelectPet(index);
end

function StableFrameMixin:SelectPet(index)

	local before = self.selectedPet;

	local petInfo = C_StableInfo.GetStablePetInfo(index);

	if petInfo then
		self.selectedPet = index;
		self.diet.stabledPetID = index;
		self.diet:UpdateHappiness();

		if petInfo.name == petInfo.familyName then
			PetStableLevelText:SetText(format(UNIT_LEVEL_TEMPLATE, petInfo.level) .. " ".. petInfo.familyName);
		else
			PetStableLevelText:SetText(petInfo.name .. " " .. format(UNIT_LEVEL_TEMPLATE, petInfo.level) .. " ".. petInfo.familyName);
		end

		PetStableLoyaltyText:SetText(petInfo.loyaltyName);

		self.loyaltyLevel:Show();
		self.loyaltyLevel.levelText:SetText(petInfo.loyaltyLevel);
		local xOffset = (petInfo.loyaltyLevel == 1) and self.loyaltyLevel.levelTextOffsetXLevelOne or self.loyaltyLevel.levelTextOffsetX;
		self.loyaltyLevel.levelText:ClearAllPoints();
		self.loyaltyLevel.levelText:SetPoint("CENTER", xOffset, 0);
		self.loyaltyLevel.tooltip = format(LOYALTY_LEVEL, petInfo.loyaltyLevel);

		if petInfo.experienceNeeded > 0 then
			if self.expBar:IsShown() then
				self.expBar:Update();
			else
				self.expBar:Show();
			end
		else
			self.expBar:Hide();
		end
	end

	for i=1,Constants.PetConsts.NUM_PET_SLOTS_HUNTER,1 do
		local slot = self:GetSlotFrame(i);
		if slot then
			slot:SetChecked(i == self.selectedPet);
		end
	end

	if before ~= self.selectedPet then
		self:Update();
		EventRegistry:TriggerEvent("StableFrameMixin.OnSelectedPetChanged", petSlotID);
	end
end

function StableFrameMixin:OnPetSwapRequested(originSlot, destinationSlot)
	if not originSlot or not destinationSlot then
		return;
	end

	C_StableInfo.SetPetSlot(originSlot, destinationSlot);
	self.lastSwappedDestinationSlot = destinationSlot;
end

PetStableSlotMixin = {};

function PetStableSlotMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
end

function PetStableSlotMixin:OnEnter()
	if (self.tooltip) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip);
		GameTooltip:AddLine(self.tooltipSubtext, 1.0, 1.0, 1.0);
		GameTooltip:Show();
	end
end

function PetStableSlotMixin:OnLeave()
	GameTooltip:Hide();
end

function PetStableSlotMixin:OnClick()
	local cursorType, petSlotID = GetCursorInfo();
	if cursorType ~= "pet" then
		EventRegistry:TriggerEvent("StableFrameMixin.PetSelected", self:GetID());
	else
		EventRegistry:TriggerEvent("StableFrameMixin.PetSwapRequested", petSlotID, self:GetID(), true);
		ClearCursor();
	end
end

function PetStableSlotMixin:OnDragStart()
	C_StableInfo.PickupStablePet(self:GetID());
end

function PetStableSlotMixin:OnReceiveDrag()
	local cursorType, petSlotID = GetCursorInfo();
	if cursorType ~= "pet" then
		return;
	end
	EventRegistry:TriggerEvent("StableFrameMixin.PetSwapRequested", petSlotID, self:GetID(), true);
	ClearCursor();
end

function PetStableSlotMixin:Update()
	local id = self:GetID();

	local petInfo = C_StableInfo.GetStablePetInfo(id);

	local unlocked = id == CURRENT_PET_SLOT or id - 2 < C_StableInfo.GetNumStableSlots();

	if petInfo then
		SetItemButtonTexture(self, petInfo.icon);
		self.tooltip = petInfo.name;
		self.tooltipSubtext = format(UNIT_LEVEL_TEMPLATE,petInfo.level) .. " " .. petInfo.familyName;
	else
		SetItemButtonTexture(self, 0);
		self.tooltip = unlocked and EMPTY_STABLE_SLOT or "";
		self.tooltipSubtext = "";
	end

	if unlocked then
		self.background:SetVertexColor(1.0, 1.0, 1.0);
	else
		self.background:SetVertexColor(1.0, 0.1, 0.1);
	end

end

function PetStableSlotMixin:OnSmartNavSelect()
	EventRegistry:TriggerEvent("StableFrameMixin.PetSelected", self:GetID());
end

PetStablePurchaseButtonMixin = {};

function PetStablePurchaseButtonMixin:Update()

	local numSlots = C_StableInfo.GetNumStableSlots();

	local nextCost = C_StableInfo.GetNextStableSlotCost();

	-- Enable, disable, or hide purchase button
	self:Show();
	if ( numSlots == Constants.PetConsts.MAX_STABLE_SLOTS) then
		self:Hide();
		PetStableCostLabel:Hide();
		PetStableCostMoneyFrame:Hide();
		PetStableSlotText:Hide();
	elseif ( GetMoney() >= nextCost ) then
		self:Enable();
		PetStableCostLabel:Show();
		PetStableCostMoneyFrame:Show();
		PetStableSlotText:Show();
		SetMoneyFrameColor("PetStableCostMoneyFrame", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		self:Disable();
		PetStableCostLabel:Show();
		PetStableCostMoneyFrame:Show();
		PetStableSlotText:Show();
		SetMoneyFrameColor("PetStableCostMoneyFrame", RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	end
end

function PetStablePurchaseButtonMixin:OnClick()
	StaticPopup_Show("CONFIRM_BUY_STABLE_SLOT");
end

PetStableLoyaltyLevelMixin = {};

function PetStableLoyaltyLevelMixin:OnEnter()
	if self.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip);
		GameTooltip:Show();
	end
end
