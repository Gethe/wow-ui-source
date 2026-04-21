HousingInspectModeManagerMixin = {};

local HousingInspectModeManagerEvents =
{
	"HOUSING_INSPECT_MODE_DECOR_HOVERED_CHANGED",
	"HOUSING_INSPECT_MODE_STATE_UPDATED",
};

function HousingInspectModeManagerMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, HousingInspectModeManagerEvents);
end

function HousingInspectModeManagerMixin:OnShow()
	EventRegistry:RegisterCallback("HouseEditor.StateUpdated", self.OnHouseEditorStateUpdated, self);
	EventRegistry:RegisterCallback("GameMenuFrame.Shown", self.ExitInspectMode, self);
	EventRegistry:RegisterCallback("CatalogShopFrame.VisibilityUpdated", self.OnShopVisibilityUpdated, self);
end

function HousingInspectModeManagerMixin:OnHide()
	EventRegistry:UnregisterCallback("HouseEditor.StateUpdated", self);
	EventRegistry:UnregisterCallback("GameMenuFrame.Shown", self);
	EventRegistry:UnregisterCallback("CatalogShopFrame.VisibilityUpdated", self);
end

function HousingInspectModeManagerMixin:OnEvent(event, ...)
	if event == "HOUSING_INSPECT_MODE_DECOR_HOVERED_CHANGED" then
		if self:IsInspectModeActive() then
			self:OnDecorHoveredChanged();
		end
	elseif event == "HOUSING_INSPECT_MODE_STATE_UPDATED" then
		self:OnUpdateInspectModeActive();
	end
end

function HousingInspectModeManagerMixin:IsInspectModeActive()
	-- Check if inspect mode is currently active
	return not not self.isInspectModeActive;
end

function HousingInspectModeManagerMixin:OnUpdateInspectModeActive()
	local currInspectModeState = C_HousingInspectMode.IsInInspectMode();
	if self.isInspectModeActive == currInspectModeState then
		return;
	end
	
	self.isInspectModeActive = currInspectModeState;
	
	if currInspectModeState then
		self:OnInspectModeActivated();
	else
		self:OnInspectModeDeactivated();
	end
end

function HousingInspectModeManagerMixin:OnInspectModeActivated()
	EventRegistry:TriggerEvent("HousingInspectMode.Activated");

	self:SetPoint("TOPLEFT");
	self:SetPoint("BOTTOMRIGHT");

	self:Show();
end

function HousingInspectModeManagerMixin:OnInspectModeDeactivated()	
	EventRegistry:TriggerEvent("HousingInspectMode.Deactivated");

	self:Hide();

	self:ClearAllPoints();
	self:OnDecorHoverEnded();
end

function HousingInspectModeManagerMixin:OnClick()
	if not self:IsInspectModeActive() then
		return;
	end

	if not self.hoveredInfo then
		-- If clicking anywhere that isn't a decor deactivate inspect mode
		self:ExitInspectMode();
		return;
	end

	-- Housing Dash is load on demand, and we need it to link into the catalog
	if not HousingDashboardFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingDashboard");
	end

	EventRegistry:TriggerEvent("HousingCatalogFrame.OpenToDecorID", self.hoveredInfo.decorID);
end

function HousingInspectModeManagerMixin:OnDecorHoveredChanged()
	-- Called when the hovered decor changes in inspect mode
	-- This is where we can update UI elements based on what's being hovered
	local isHoveringDecor = C_HousingInspectMode.IsHoveringDecor();
	
	if isHoveringDecor then
		local decorGUID = C_HousingInspectMode.GetHoveredDecorGUID();
		-- Handle decor hover started
		self:OnDecorHoverStarted(decorGUID);
	else
		-- Handle decor hover ended
		self:OnDecorHoverEnded();
		self:OnNonDecorHovered();
	end
end

function HousingInspectModeManagerMixin:OnNonDecorHovered()
	local tooltip = GameTooltip;
	if self:IsMouseMotionFocus() then
		tooltip:SetOwner(UIParent, "ANCHOR_CURSOR");
		GameTooltip_AddNormalLine(tooltip, HOUSING_INSPECT_MODE_NO_DECOR_TOOLTIP);
		tooltip:Show();
	else
		GameTooltip_Hide(tooltip);
	end
end

function HousingInspectModeManagerMixin:OnEnter()
	-- Called when inspect mode is on and we're hovering over the mode manager frame
	self:OnNonDecorHovered();
end

function HousingInspectModeManagerMixin:OnLeave()
	-- Called when inspect mode is on and we're leaving the mode manager frame
	GameTooltip_Hide(GameTooltip);
end

function HousingInspectModeManagerMixin:OnDecorHoverStarted(decorGUID)
	-- Called when hovering over a decor starts
	-- decorGUID is the GUID of the decor being hovered
	
	if not self:IsInspectModeActive() then
		return;
	end
	
	-- Get decor info to show in tooltip
	local decorInfo = C_HousingDecor.GetDecorInstanceInfoForGUID(decorGUID);
	if decorInfo then
		local tooltip = GameTooltip;
		tooltip:SetOwner(UIParent, "ANCHOR_CURSOR");
		GameTooltip_AddHighlightLine(tooltip, decorInfo.name);

		local hasAnyDyes = false;
		for i, dyeSlot in ipairs(decorInfo.dyeSlots) do
			if dyeSlot.dyeColorID ~= 0 then
				hasAnyDyes = true;
				break;
			end
		end

		if hasAnyDyes then
			GameTooltip_AddBlankLineToTooltip(tooltip);

			GameTooltip_AddNormalLine(tooltip, HOUSING_INSPECT_MODE_DYE_TOOLTIP_HEADER);

			for i, dyeSlot in ipairs(decorInfo.dyeSlots) do
				local dyeColorID = dyeSlot.dyeColorID;
				local dyeColorInfo = C_DyeColor.GetDyeColorInfo(dyeColorID);
				if dyeColorInfo and dyeColorInfo.name then
					GameTooltip_AddNormalLine(tooltip, string.format(HOUSING_INSPECT_MODE_DYE_TOOLTIP_ENTRY_FORMAT, dyeColorInfo.name));
				end
			end
		end

		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddColoredLine(tooltip, HOUSING_INSPECT_MODE_TOOLTIP_INSTRUCTION_TEXT, GREEN_FONT_COLOR);

		tooltip:Show();
	end

	self.hoveredInfo = decorInfo;
end

function HousingInspectModeManagerMixin:OnDecorHoverEnded()
	-- Called when hovering over a decor ends
	GameTooltip:Hide();

	self.hoveredInfo = nil;
end

function HousingInspectModeManagerMixin:OnHouseEditorStateUpdated(houseEditorActive)
	-- Upon activating the HouseEditor, Inspect mode will be deactivated
	if houseEditorActive and self:IsInspectModeActive() then
		self:ExitInspectMode();
	end
end

function HousingInspectModeManagerMixin:OnShopVisibilityUpdated(isShown)
	if isShown then
		self:ExitInspectMode();
	end
end

function HousingInspectModeManagerMixin:ExitInspectMode()
	C_HousingInspectMode.ExitInspectMode();
end
