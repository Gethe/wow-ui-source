local ExteriorCustomizationModeLifetimeEvents = 
{
	"HOUSING_FIXTURE_POINT_FRAME_ADDED",
	"HOUSING_FIXTURE_POINT_FRAME_RELEASED",
	"HOUSING_FIXTURE_POINT_FRAMES_RELEASED",
};

local ExteriorCustomizationModeShownEvents = 
{
	"HOUSING_FIXTURE_POINT_SELECTION_CHANGED",
	"HOUSING_FIXTURE_HOVER_CHANGED",
	"HOUSING_CORE_FIXTURE_CHANGED",
};

HouseEditorExteriorCustomizationModeMixin = {};

function HouseEditorExteriorCustomizationModeMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, ExteriorCustomizationModeLifetimeEvents);

	self.fixturePointPool = CreateFramePool("BUTTON", self, "HousingExteriorFixturePointTemplate", HousingExteriorFixturePointMixin.Reset);

	-- TODO: Implement house type and size swapping
	self.CoreOptionsPanel.HouseSizeOption:ShowStaticPlaceholderInfo(HOUSING_EXTERIOR_CUSTOMIZATION_HOUSE_SIZE_LABEL, HOUSING_EXTERIOR_CUSTOMIZATION_SIZE_SMALL);
end

function HouseEditorExteriorCustomizationModeMixin:OnEvent(event, ...)
	if event == "HOUSING_FIXTURE_POINT_FRAME_ADDED" then
		local pointFrame = ...;
		self:AddPoint(pointFrame);
	elseif event == "HOUSING_FIXTURE_POINT_FRAME_RELEASED" then
		local pointFrame = ...;
		self:ReleasePoint(pointFrame);
	elseif event == "HOUSING_FIXTURE_POINT_FRAMES_RELEASED" then
		self:ReleaseAllPoints();
	elseif event == "HOUSING_FIXTURE_POINT_SELECTION_CHANGED" then
		self:UpdatetSelectedPoint();
	elseif event == "HOUSING_FIXTURE_HOVER_CHANGED" then
		local isHoveringFixture = ...;
		self:UpdateHoveredFixture(isHoveringFixture);
	elseif event == "HOUSING_CORE_FIXTURE_CHANGED" then
		self:UpdateCoreFixtureOptions();
	end
end

function HouseEditorExteriorCustomizationModeMixin:OnShow()
	EventRegistry:TriggerEvent("HouseEditor.HouseStorageSetShown", false);
	C_KeyBindings.ActivateBindingContext(Enum.BindingContext.HousingEditorExteriorCustomizationMode);
	FrameUtil.RegisterFrameForEvents(self, ExteriorCustomizationModeShownEvents);

	local exteriorTypeName = C_HouseExterior.GetCurrentHouseExteriorTypeName();
	-- TODO: Implement house type and size swapping
	if exteriorTypeName then
		self.CoreOptionsPanel.HouseTypeOption:ShowStaticPlaceholderInfo(HOUSING_EXTERIOR_CUSTOMIZATION_HOUSE_TYPE_LABEL, exteriorTypeName);
	else
		self.CoreOptionsPanel.HouseTypeOption:ClearAndHide();
	end

	if C_HouseExterior.HasSelectedFixturePoint() then
		self:UpdatetSelectedPoint();
	end
	if C_HouseExterior.HasHoveredFixture() then
		self:UpdateHoveredFixture(true);
	end

	self:UpdateCoreFixtureOptions();

	PlaySound(SOUNDKIT.HOUSING_ENTER_EXTERIOR_EDIT_MODE);
end

function HouseEditorExteriorCustomizationModeMixin:OnHide()
	C_KeyBindings.DeactivateBindingContext(Enum.BindingContext.HousingEditorExteriorCustomizationMode);
	FrameUtil.UnregisterFrameForEvents(self, ExteriorCustomizationModeShownEvents);

	PlaySound(SOUNDKIT.HOUSING_EXIT_EXTERIOR_EDIT_MODE);
end

function HouseEditorExteriorCustomizationModeMixin:TryHandleEscape()
	if C_HouseExterior.HasSelectedFixturePoint() then
		C_HouseExterior.CancelActiveExteriorEditing();
		return true;
	end
	return false;
end

function HouseEditorExteriorCustomizationModeMixin:UpdateCoreFixtureDropdown(dropdown, selectedOption, options)
	if options and #options > 1 then
		dropdown:ShowCoreFixtureInfo(selectedOption, options);
	else
		dropdown:ClearAndHide();
	end
end

function HouseEditorExteriorCustomizationModeMixin:UpdateCoreFixtureOptions()
	local baseFixtureInfo = C_HouseExterior.GetCoreFixtureOptionsInfo(Enum.HousingFixtureType.Base);
	self:UpdateCoreFixtureDropdown(self.CoreOptionsPanel.BaseStyleOption, baseFixtureInfo and baseFixtureInfo.selectedStyleFixtureID or nil, baseFixtureInfo and baseFixtureInfo.styleOptions or nil)
	self:UpdateCoreFixtureDropdown(self.CoreOptionsPanel.BaseVariantOption, baseFixtureInfo and baseFixtureInfo.selectedVariantFixtureID or nil, baseFixtureInfo and baseFixtureInfo.currentStyleVariantOptions or nil)

	local roofFixtureInfo = C_HouseExterior.GetCoreFixtureOptionsInfo(Enum.HousingFixtureType.Roof);
	self:UpdateCoreFixtureDropdown(self.CoreOptionsPanel.RoofStyleOption, roofFixtureInfo and roofFixtureInfo.selectedStyleFixtureID or nil, roofFixtureInfo and roofFixtureInfo.styleOptions or nil)
	self:UpdateCoreFixtureDropdown(self.CoreOptionsPanel.RoofVariantOption, roofFixtureInfo and roofFixtureInfo.selectedVariantFixtureID or nil, roofFixtureInfo and roofFixtureInfo.currentStyleVariantOptions or nil)

	self.CoreOptionsPanel:Layout();
end

function HouseEditorExteriorCustomizationModeMixin:UpdateAllPointVisuals()
	for pointFrame in self.fixturePointPool:EnumerateActive() do
		if pointFrame:IsShown() then
			pointFrame:UpdateVisuals();
		end
	end
end

function HouseEditorExteriorCustomizationModeMixin:AddPoint(pointFrame)
	pointFrame:SetParent(self);

	local newPoint = self.fixturePointPool:Acquire();
	newPoint:Initialize(pointFrame);
	pointFrame.boundPoint = newPoint;
end

function HouseEditorExteriorCustomizationModeMixin:ReleasePoint(pointFrame)
	if self.selectedPointFrame == pointFrame then
		self.selectedPointFrame = nil;
	end
	
	self.fixturePointPool:Release(pointFrame.boundPoint);
	pointFrame.boundPoint = nil;
end

function HouseEditorExteriorCustomizationModeMixin:ReleaseAllPoints()
	self.selectedPointFrame = nil;
	self.fixturePointPool:ReleaseAll();
end

function HouseEditorExteriorCustomizationModeMixin:UpdatetSelectedPoint()
	local selectedFixturePointInfo = C_HouseExterior.GetSelectedFixturePointInfo();

	local oldInfo = self.FixtureOptionList:GetFixturePointInfo();
	local hasOldInfo = not not oldInfo;
	local hasNewInfo = not not selectedFixturePointInfo;
	-- If old and new info are both nil or both the same, nothing to update
	if hasOldInfo == hasNewInfo and (not hasNewInfo or tCompare(oldInfo, selectedFixturePointInfo, 2)) then
		return;
	end

	-- Clear old options
	if oldInfo then
		self.FixtureOptionList:ClearAndHide();
	end

	if self.selectLoopSound then
		StopSound(self.selectLoopSound);
		self.selectLoopSound = nil;
	end

	-- Set up new options
	if selectedFixturePointInfo then
		self.FixtureOptionList:ShowFixturePointInfo(selectedFixturePointInfo);
		PlaySound(SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_NODE_SELECT);
		self.selectLoopSound = select(2, PlaySound(SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_NODE_SELECT_LOOP));
	end

	self:UpdateAllPointVisuals();
end

function HouseEditorExteriorCustomizationModeMixin:UpdateHoveredFixture(isHoveringFixture)
	if isHoveringFixture then
		local tooltip = GameTooltip;
		tooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 0, 0);
		GameTooltip_AddHighlightLine(tooltip, HOUSING_EXTERIOR_CUSTOMIZATION_HOOKPOINT_OCCUPIED_TOOLTIP);
		tooltip:Show();
	elseif GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end
