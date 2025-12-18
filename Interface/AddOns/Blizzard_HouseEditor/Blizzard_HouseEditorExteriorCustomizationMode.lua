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
	"HOUSING_FIXTURE_UNLOCKED",
	"HOUSE_EXTERIOR_TYPE_UNLOCKED",
	"HOUSE_LEVEL_CHANGED",
	"HOUSING_SET_FIXTURE_RESPONSE",
	"HOUSING_SET_EXTERIOR_HOUSE_TYPE_RESPONSE",
	"HOUSING_SET_EXTERIOR_HOUSE_SIZE_RESPONSE",
};

HouseEditorExteriorCustomizationModeMixin = {};

function HouseEditorExteriorCustomizationModeMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, ExteriorCustomizationModeLifetimeEvents);

	self.fixturePointPool = CreateFramePool("BUTTON", self, "HousingExteriorFixturePointTemplate", HousingExteriorFixturePointMixin.Reset);
end

function HouseEditorExteriorCustomizationModeMixin:OnEvent(event, ...)
	if event == "HOUSING_SET_FIXTURE_RESPONSE" then
		local result = ...;
		if result ~= Enum.HousingResult.Success then
			self:HandleErrorResult(result);
		end
	elseif event == "HOUSING_SET_EXTERIOR_HOUSE_TYPE_RESPONSE" then
		local result = ...;
		if result == Enum.HousingResult.Success then
			self:UpdateAllCoreOptions();
		else
			self:HandleErrorResult(result);
		end
	elseif event == "HOUSING_SET_EXTERIOR_HOUSE_SIZE_RESPONSE" then
		local result = ...;
		if result == Enum.HousingResult.Success then
			self:UpdateAllCoreOptions();
		else
			self:HandleErrorResult(result);
		end
	elseif event == "HOUSING_FIXTURE_POINT_FRAME_ADDED" then
		local pointFrame = ...;
		self:AddPoint(pointFrame);
	elseif event == "HOUSING_FIXTURE_POINT_FRAME_RELEASED" then
		local pointFrame = ...;
		self:ReleasePoint(pointFrame);
	elseif event == "HOUSING_FIXTURE_POINT_FRAMES_RELEASED" then
		self:ReleaseAllPoints();
	elseif event == "HOUSING_FIXTURE_POINT_SELECTION_CHANGED" then
		self:UpdateSelectedPoint();
	elseif event == "HOUSING_FIXTURE_HOVER_CHANGED" then
		local isHoveringFixture = ...;
		self:UpdateHoveredFixture(isHoveringFixture);
	elseif event == "HOUSING_CORE_FIXTURE_CHANGED" then
		self:UpdateCoreFixtureOptions();
	elseif event == "HOUSING_FIXTURE_UNLOCKED" then
		self:UpdateCoreFixtureOptions();
		if C_HouseExterior.HasSelectedFixturePoint() then
			self:UpdateSelectedPoint();
		end
	elseif event == "HOUSE_EXTERIOR_TYPE_UNLOCKED" then
		self:UpdateHouseTypeOptions();
	elseif event == "HOUSE_LEVEL_CHANGED" then
		self:UpdateHouseSizeOptions();
	end
end

function HouseEditorExteriorCustomizationModeMixin:HandleErrorResult(result)
	local errorText = HousingResultToErrorText[result];
	if errorText and errorText ~= "" then
		UIErrorsFrame:AddExternalErrorMessage(errorText);
	end
end

function HouseEditorExteriorCustomizationModeMixin:OnShow()
	EventRegistry:TriggerEvent("HouseEditor.HouseStorageSetShown", false);
	C_KeyBindings.ActivateBindingContext(Enum.BindingContext.HousingEditorExteriorCustomizationMode);
	FrameUtil.RegisterFrameForEvents(self, ExteriorCustomizationModeShownEvents);

	self:UpdateAllCoreOptions();

	if C_HouseExterior.HasSelectedFixturePoint() then
		self:UpdateSelectedPoint();
	end
	if C_HouseExterior.HasHoveredFixture() then
		self:UpdateHoveredFixture(true);
	end

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

function HouseEditorExteriorCustomizationModeMixin:UpdateAllCoreOptions()
	local skipLayout = true;
	self:UpdateHouseTypeOptions(skipLayout);
	self:UpdateHouseSizeOptions(skipLayout);
	self:UpdateCoreFixtureOptions(skipLayout);
	self.CoreOptionsPanel:Layout();
end

function HouseEditorExteriorCustomizationModeMixin:UpdateHouseTypeOptions(skipLayout)
	local optionsInfo = C_HouseExterior.GetHouseExteriorTypeOptions();
	if optionsInfo and optionsInfo.options and #optionsInfo.options > 1 then
		self.CoreOptionsPanel.HouseTypeOption:ShowHouseExteriorTypeOptions(optionsInfo.selectedExteriorType, optionsInfo.options);
	else
		self.CoreOptionsPanel.HouseTypeOption:ClearAndHide();
	end

	if not skipLayout then
		self.CoreOptionsPanel:Layout();
	end
end

function HouseEditorExteriorCustomizationModeMixin:UpdateHouseSizeOptions(skipLayout)
	local optionsInfo = C_HouseExterior.GetHouseExteriorSizeOptions();
	if optionsInfo and optionsInfo.options and #optionsInfo.options > 1 then
		self.CoreOptionsPanel.HouseSizeOption:ShowHouseExteriorSizeOptions(optionsInfo.selectedSize, optionsInfo.options);
	else
		self.CoreOptionsPanel.HouseSizeOption:ClearAndHide();
	end

	if not skipLayout then
		self.CoreOptionsPanel:Layout();
	end
end

function HouseEditorExteriorCustomizationModeMixin:UpdateCoreFixtureDropdown(dropdown, selectedOption, options, useColorNames)
	if options and #options > 1 then
		dropdown:ShowCoreFixtureInfo(selectedOption, options, useColorNames);
	else
		dropdown:ClearAndHide();
	end
end

function HouseEditorExteriorCustomizationModeMixin:UpdateCoreFixtureOptions(skipLayout)
	local stylesUseColorNames = false;
	local variantsUseColorNames = true;
	local baseFixtureInfo = C_HouseExterior.GetCoreFixtureOptionsInfo(Enum.HousingFixtureType.Base);
	self:UpdateCoreFixtureDropdown(self.CoreOptionsPanel.BaseStyleOption, baseFixtureInfo and baseFixtureInfo.selectedStyleFixtureID or nil, baseFixtureInfo and baseFixtureInfo.styleOptions or nil, stylesUseColorNames);
	self:UpdateCoreFixtureDropdown(self.CoreOptionsPanel.BaseVariantOption, baseFixtureInfo and baseFixtureInfo.selectedVariantFixtureID or nil, baseFixtureInfo and baseFixtureInfo.currentStyleVariantOptions or nil, variantsUseColorNames);

	local roofFixtureInfo = C_HouseExterior.GetCoreFixtureOptionsInfo(Enum.HousingFixtureType.Roof);
	self:UpdateCoreFixtureDropdown(self.CoreOptionsPanel.RoofStyleOption, roofFixtureInfo and roofFixtureInfo.selectedStyleFixtureID or nil, roofFixtureInfo and roofFixtureInfo.styleOptions or nil, stylesUseColorNames);
	self:UpdateCoreFixtureDropdown(self.CoreOptionsPanel.RoofVariantOption, roofFixtureInfo and roofFixtureInfo.selectedVariantFixtureID or nil, roofFixtureInfo and roofFixtureInfo.currentStyleVariantOptions or nil, variantsUseColorNames);

	if not skipLayout then
		self.CoreOptionsPanel:Layout();
	end
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
	
	if pointFrame.boundPoint then
		self.fixturePointPool:Release(pointFrame.boundPoint);
		pointFrame.boundPoint = nil;
	end
end

function HouseEditorExteriorCustomizationModeMixin:ReleaseAllPoints()
	self.selectedPointFrame = nil;
	self.fixturePointPool:ReleaseAll();
end

function HouseEditorExteriorCustomizationModeMixin:UpdateSelectedPoint()
	local selectedFixturePointInfo = C_HouseExterior.GetSelectedFixturePointInfo();

	local oldInfo = self.FixtureOptionList:GetFixturePointInfo();
	local hasOldInfo = not not oldInfo;
	local hasNewInfo = not not selectedFixturePointInfo;
	-- If old and new info are both nil or both the same, nothing to update
	if hasOldInfo == hasNewInfo and (not hasNewInfo or tCompare(oldInfo, selectedFixturePointInfo, 2)) then
		return;
	end

	if self.selectLoopSound then
		StopSound(self.selectLoopSound);
		self.selectLoopSound = nil;
	end

	if selectedFixturePointInfo then
		-- Set up new options
		self.FixtureOptionList:ShowFixturePointInfo(selectedFixturePointInfo);
		PlaySound(SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_NODE_SELECT);
		self.selectLoopSound = select(2, PlaySound(SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_NODE_SELECT_LOOP));
	elseif oldInfo then
		-- Clear old options
		self.FixtureOptionList:ClearAndHide();
	end

	self:UpdateAllPointVisuals();
end

function HouseEditorExteriorCustomizationModeMixin:UpdateHoveredFixture(isHoveringFixture)
	local tooltip = nil;
	if isHoveringFixture then
		tooltip = GameTooltip;
		tooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 0, 0);
		GameTooltip_AddHighlightLine(tooltip, HOUSING_EXTERIOR_CUSTOMIZATION_HOOKPOINT_OCCUPIED_TOOLTIP);
		tooltip:Show();
	elseif GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
	
	EventRegistry:TriggerEvent("HousingFixtureInstance.MouseOver", self, tooltip);
end
