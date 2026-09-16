
local CURRENT_PET_SLOT = 1;

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

function StableFrameMixin:Update()
	local nextCost = C_StableInfo.GetNextStableSlotCost();
	MoneyFrame_Update("PetStableCostMoneyFrame", nextCost);
	
	local numSlots = C_StableInfo.GetNumStableSlots();
	local numPets = C_StableInfo.GetNumStablePets();

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

	self.purchaseButton:Update();

	if not self.purchaseButton:IsShown() then
		PetStableCurrentPet:SetPoint("TOP", self.modelScene, "BOTTOM", -69, -43);
	else
		PetStableCurrentPet:SetPoint("TOP", self.modelScene, "BOTTOM", -69, -23);
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
		self.modelScene.diet.stabledPetID = index;
		self.modelScene.diet:UpdateHappiness();

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
