BaseHouseEditorModeMixin = {};

function BaseHouseEditorModeMixin:BaseOnShow()
	if C_HousingDecor.IsHoveringDecor() then
		self:OnDecorHovered();
	elseif C_HousingDecor.IsHouseExteriorHovered() then
		self:OnHouseHovered();
	elseif C_HousingCustomizeMode.IsHoveringRoomComponent() then
		self:OnRoomComponentHovered();
	end
end

function BaseHouseEditorModeMixin:BaseOnHide()
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end

function BaseHouseEditorModeMixin:GetModeType()
	return self.modeType;
end

function BaseHouseEditorModeMixin:OnDecorHovered()
	local decorInstanceInfo = C_HousingDecor.GetHoveredDecorInfo();
	if not decorInstanceInfo then
		return;
	end

	local tooltip = self:ShowDecorInstanceTooltip(decorInstanceInfo);

	EventRegistry:TriggerEvent("HousingDecorInstance.MouseOver", self, tooltip);
end

function BaseHouseEditorModeMixin:OnHouseHovered()
	local tooltip = self:ShowHouseTooltip(decorInstanceInfo);
end

function BaseHouseEditorModeMixin:OnRoomComponentHovered()
	local roomComponentInfo = C_HousingCustomizeMode.GetHoveredRoomComponentInfo();
	if not roomComponentInfo then
		return;
	end

	local tooltip = self:ShowRoomComponentTooltip(roomComponentInfo);

	EventRegistry:TriggerEvent("HousingRoomComponentInstance.MouseOver", self, tooltip);
end

function BaseHouseEditorModeMixin:PlaySelectedSoundForDecorInfo(decorInfo)
	if decorInfo then -- We may not have an info in the case of newly placed decor
		self:PlaySelectedSoundForSize(decorInfo.size);
	end
end

function BaseHouseEditorModeMixin:PlaySelectedSoundForHouse()
	local houseExteriorSize = C_HouseExterior.GetCurrentHouseExteriorSize();
	self:PlaySelectedHouseSoundForSize(houseExteriorSize);
end

function BaseHouseEditorModeMixin:PlayPlacementSoundForHouse()
	local houseExteriorSize = C_HouseExterior.GetCurrentHouseExteriorSize();
	self:PlayPlacedHouseSoundForSize(houseExteriorSize);
end

function BaseHouseEditorModeMixin:PlaySoundForSize(size, small, medium, large)
	local sound;
	if size == Enum.HousingCatalogEntrySize.Tiny or size == Enum.HousingCatalogEntrySize.Small then
		sound = small;
	elseif size == Enum.HousingCatalogEntrySize.Medium or size == Enum.HousingCatalogEntrySize.None then
		sound = medium;
	else
		sound = large;
	end
	PlaySound(sound);
end

function BaseHouseEditorModeMixin:PlaySoundForHouseSize(size, small, medium, large)
	local sound;
	if size == Enum.HousingFixtureSize.Small or size == Enum.HousingFixtureSize.Any then
		sound = small;
	elseif size == Enum.HousingFixtureSize.Medium or size == Enum.HousingFixtureSize.None then
		sound = medium;
	else
		sound = large;
	end
	PlaySound(sound);
end

function BaseHouseEditorModeMixin:PlaySelectedSoundForSize(size)
	self:PlaySoundForSize(size,
		SOUNDKIT.HOUSING_SELECT_ITEM_SMALL,
		SOUNDKIT.HOUSING_SELECT_ITEM_MEDIUM,
		SOUNDKIT.HOUSING_SELECT_ITEM_LARGE
	);
end

function BaseHouseEditorModeMixin:PlayPlacedSoundForSize(size)
	self:PlaySoundForSize(size,
		SOUNDKIT.HOUSING_PLACE_ITEM_SMALL,
		SOUNDKIT.HOUSING_PLACE_ITEM_MEDIUM,
		SOUNDKIT.HOUSING_PLACE_ITEM_LARGE
	);
end

function BaseHouseEditorModeMixin:PlaySelectedHouseSoundForSize(size)
	self:PlaySoundForHouseSize(size,
		SOUNDKIT.HOUSING_SELECT_HOUSE_SMALL,
		SOUNDKIT.HOUSING_SELECT_HOUSE_MEDIUM,
		SOUNDKIT.HOUSING_SELECT_HOUSE_LARGE
	);
end

function BaseHouseEditorModeMixin:PlayPlacedHouseSoundForSize(size)
	self:PlaySoundForHouseSize(size,
		SOUNDKIT.HOUSING_PLACE_HOUSE_SMALL,
		SOUNDKIT.HOUSING_PLACE_HOUSE_MEDIUM,
		SOUNDKIT.HOUSING_PLACE_HOUSE_LARGE
	);
end

function BaseHouseEditorModeMixin:ShowDecorInstanceTooltip(decorInstanceInfo)
	-- Optional
	return nil;
end

function BaseHouseEditorModeMixin:ShowHouseTooltip()
	-- Optional
	return nil;
end

function BaseHouseEditorModeMixin:ShowInvalidPlacementDecorTooltip(invalidPlacementInfo)
	-- Optional
	return nil;
end

function BaseHouseEditorModeMixin:ShowInvalidPlacementHouseTooltip(invalidPlacementInfo)
	-- Optional
	return nil;
end

function BaseHouseEditorModeMixin:ShowRoomComponentTooltip(componentInfo)
	-- Optional
	return nil;
end

function BaseHouseEditorModeMixin:TryHandleEscape()
	-- Required
	assert(false);
end

HouseEditorInstructionsContainerMixin = {};

function HouseEditorInstructionsContainerMixin:OnLoad()
	self:UpdateAllVisuals();
end

function HouseEditorInstructionsContainerMixin:UpdateAllVisuals()
	self:CallOnChildrenThenUpdateLayout("UpdateVisuals");
end

function HouseEditorInstructionsContainerMixin:UpdateAllControls()
	self:CallOnChildrenThenUpdateLayout("UpdateControl");
end

function HouseEditorInstructionsContainerMixin:CallOnChildrenThenUpdateLayout(functionName)
	local widestControlWidth;
	local childFrames = {self:GetChildren()};
	for _, child in ipairs(childFrames) do
		child[functionName](child);
	end

	self:UpdateLayout();
end

function HouseEditorInstructionsContainerMixin:UpdateLayout()
	local widestControlWidth = 0;
	local layoutChildren = self:GetLayoutChildren();
	for _, child in ipairs(layoutChildren) do
		local controlWidth = child:GetControlWidth();
		if controlWidth > widestControlWidth then
			widestControlWidth = controlWidth;
		end
	end

	for _, child in ipairs(layoutChildren) do
		child:SetControlWidth(widestControlWidth);
	end

	self:Layout();
end

HouseEditorInstructionMixin = {};

function HouseEditorInstructionMixin:OnLoad()
	self:UpdateVisuals();
end

function HouseEditorInstructionMixin:UpdateVisuals()
	self:UpdateControl();
	self:UpdateInstruction();
end

function HouseEditorInstructionMixin:GetControlWidth()
	return self.InstructionText:GetUnboundedStringWidth();
end

function HouseEditorInstructionMixin:SetControlWidth(width)
	self.InstructionText:SetWidth(width);
end

function HouseEditorInstructionMixin:UpdateControl()
	local bindingText = nil;
	if self.keybindName then
		bindingText = GetBindingKeyForAction(self.keybindName);
	elseif self.controlText then
		bindingText = self.controlText;
	end

	if not self.iconAtlas and (not bindingText or bindingText == "") then
		bindingText = HOUSE_EDITOR_INSTRUCTION_UNBOUND;
	end
		
	if bindingText and bindingText ~= "" then
		self.Control.Text:SetText(bindingText);
		self.Control.Text:Show();
		self.Control.Background:Show();
		self.Control.Icon:Hide();

		local textWidth = (self.Control.Text:GetStringWidth()) + 26;
		self.Control.Background:SetWidth(textWidth);
		self.Control:SetWidth(textWidth);
	else
		if self.iconAtlas then
			self.Control.Icon:SetAtlas(self.iconAtlas);
			self.Control.Icon:Show();
		else
			self.Control.Icon:Hide();
		end
		self.Control.Text:Hide();
		self.Control.Background:Hide();
	end

	self:MarkDirty();
end

function HouseEditorInstructionMixin:UpdateInstruction()
	if self.instructionText then
		self.InstructionText:SetText(self.instructionText);
		self.InstructionText:Show();
	elseif self.IsActive and self.instructionTextActive and self.instructionTextInactive then
		local isActive = self:IsActive();
		self.InstructionText:SetText(isActive and self.instructionTextActive or self.instructionTextInactive);
		self.InstructionText:Show();
	else
		self.InstructionText:Hide();
	end
	self:MarkDirty();
end

HouseEditorBudgetCountMixin = {};

function HouseEditorBudgetCountMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, self.updateEvents);
	self:UpdateCount();
	self:Layout();
end

function HouseEditorBudgetCountMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, self.updateEvents);
end

function HouseEditorBudgetCountMixin:OnEvent(event, ...)
	-- If other non-update events get added, this will need to check that events is in updateEvents
	self:UpdateCount();
	self:Layout();
end

function HouseEditorBudgetCountMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
	GameTooltip_AddHighlightLine(GameTooltip, self.tooltipText);
	GameTooltip:Show();
end

function HouseEditorBudgetCountMixin:OnLeave()
	GameTooltip:Hide();
end

HouseEditorDecorCountMixin = {};

function HouseEditorDecorCountMixin:OnLoad()
	self.updateEvents = {"HOUSING_NUM_DECOR_PLACED_CHANGED", "HOUSE_LEVEL_CHANGED"};
	-- Start with the safe, neutral, fallback tooltip
	self.tooltipText =  HOUSING_DECOR_BUDGET_TOOLTIP;
end

function HouseEditorDecorCountMixin:UpdateCount()
	local decorPlaced = C_HousingDecor.GetSpentPlacementBudget();
	local maxDecor = C_HousingDecor.GetMaxPlacementBudget();
	self.Text:SetText(HOUSING_DECOR_PLACED_COUNT_FMT:format(decorPlaced, maxDecor));
	-- Update tooltip text with context-appropriate base and populate with updated count info
	local baseTooltip = C_Housing.IsInsideHouse() and HOUSING_DECOR_BUDGET_TOOLTIP_INDOOR or HOUSING_DECOR_BUDGET_TOOLTIP_OUTDOOR;
	self.tooltipText =  baseTooltip:format(decorPlaced, maxDecor);
end

HouseEditorRoomCountMixin = {};

function HouseEditorRoomCountMixin:OnLoad()
	self.updateEvents = {"HOUSING_LAYOUT_ROOM_RECEIVED", "HOUSING_LAYOUT_ROOM_REMOVED", "HOUSE_LEVEL_CHANGED"};
	self.tooltipText = HOUSING_LAYOUT_NUM_ROOMS_TOOLTIP;
end

function HouseEditorRoomCountMixin:UpdateCount()
	local currentSpentBudget = C_HousingLayout.GetSpentPlacementBudget();
	local roomPlacementBudget = C_HousingLayout.GetRoomPlacementBudget();
	self.Text:SetText(HOUSING_LAYOUT_NUM_ROOMS:format(currentSpentBudget, roomPlacementBudget));
end
