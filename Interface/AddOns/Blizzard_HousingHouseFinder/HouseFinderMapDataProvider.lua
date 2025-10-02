HouseFinderMapDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function HouseFinderMapDataProviderMixin:SetHouseMapData(houseMapData)
	self.houseMapData = houseMapData;
	self:RefreshAllData();
end

function HouseFinderMapDataProviderMixin:SetSelectedPin(pin)
	if self.selectedPin then
		self.selectedPin:Refresh();
	end
	self.selectedPin = pin;
end

function HouseFinderMapDataProviderMixin:OnEvent(event, ...)
	self:RefreshAllData();
end

function HouseFinderMapDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("HouseFinderPlotForSalePinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("HouseFinderFriendsPlotPinTemplate");
end

function HouseFinderMapDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	if self.houseMapData then
		for index, plotInfo in ipairs(self.houseMapData) do
			if plotInfo.ownerType == Enum.HousingPlotOwnerType.None then
				local pin = self:GetMap():AcquirePin("HouseFinderPlotForSalePinTemplate", plotInfo, self);
				pin:SetPosition(plotInfo.mapPosition.x, plotInfo.mapPosition.y);
			elseif plotInfo.ownerType == Enum.HousingPlotOwnerType.Friend then
				local pin = self:GetMap():AcquirePin("HouseFinderFriendsPlotPinTemplate", plotInfo, self);
				pin:SetPosition(plotInfo.mapPosition.x, plotInfo.mapPosition.y);
			end
		end
	end
end

--///////////////////For Sale Pin////////////////////////////
HouseFinderPlotForSalePinMixin = CreateFromMixins(MapCanvasPinMixin);

function HouseFinderPlotForSalePinMixin:OnLoad()
	self:SetScalingLimits(1, 0.7, 1.3);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_NEIGHBORHOOD_MAP_OBJECTS");
end

function HouseFinderPlotForSalePinMixin:OnAcquired(mapPlotInfo, dataProvider)
	self.plotInfo = mapPlotInfo;
	self.dataProvider = dataProvider;
	self:Refresh();
end

function HouseFinderPlotForSalePinMixin:Refresh()
	self.SelectedUnderlay:Hide();
end

function HouseFinderPlotForSalePinMixin:OnMouseEnter()
	self.isMouseOver = true;

	if not self.isGlowing then
		self.HighlightTexture:SetAlpha(1.0);
		self.HighlightTexture:Show();
	end

	PlaySound(SOUNDKIT.HOUSING_HOUSE_FINDER_PLOT_HOVER);
end

function HouseFinderPlotForSalePinMixin:OnMouseLeave()
	self.isMouseOver = false;

	if not self.isGlowing then
		self.HighlightTexture:Hide();
	end
end

function HouseFinderPlotForSalePinMixin:OnMouseDownAction(button)
	self:AdjustPointsOffset(1, -1);
end

function HouseFinderPlotForSalePinMixin:OnMouseUpAction(button, upInside)
	self:AdjustPointsOffset(-1, 1);
end

function HouseFinderPlotForSalePinMixin:OnMouseClickAction()
	self.SelectedUnderlay:Show();
	HouseFinderFrame:SelectPlot(self, self.plotInfo);
	self.dataProvider:SetSelectedPin(self);
end

function HouseFinderPlotForSalePinMixin:StartGlow(glowLoopCount)
	self.isGlowing = true;

	-- Still count this start as the first iteration
	self.currGlowLoopCount = glowLoopCount - 1;

	self.GlowAnim:SetScript("OnFinished", function()
		if self.currGlowLoopCount and self.currGlowLoopCount > 0 then
			self.currGlowLoopCount = self.currGlowLoopCount - 1;
			self.GlowAnim:Play();
		else
			self:StopGlow();
		end
	end);

	self.GlowAnim:Play();
	self.HighlightTexture:Show();
end

function HouseFinderPlotForSalePinMixin:StopGlow()
	self.isGlowing = false;
	self.currGlowLoopCount = 0;

	self.GlowAnim:Stop();
	self.HighlightTexture:SetAlpha(1.0);
	self.HighlightTexture:SetShown(self.isMouseOver);
end

--///////////////////Friend Plot Pin////////////////////////////
HouseFinderFriendsPlotPinMixin = CreateFromMixins(MapCanvasPinMixin);

function HouseFinderFriendsPlotPinMixin:OnLoad()
	self:SetScalingLimits(1, 0.7, 1.3);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_NEIGHBORHOOD_MAP_OBJECTS");
end

function HouseFinderFriendsPlotPinMixin:OnAcquired(mapPlotInfo, dataProvider)
	self.plotInfo = mapPlotInfo;
	self.dataProvider = dataProvider;
	self:Refresh();
end

function HouseFinderFriendsPlotPinMixin:Refresh()
	self.SelectedUnderlay:Hide();
end

function HouseFinderFriendsPlotPinMixin:OnMouseEnter()
	self.HighlightTexture:Show();
	PlaySound(SOUNDKIT.HOUSING_HOUSE_FINDER_PLOT_HOVER);
end

function HouseFinderFriendsPlotPinMixin:OnMouseLeave()
	self.HighlightTexture:Hide();
end

function HouseFinderFriendsPlotPinMixin:OnMouseDownAction(button)
	self:AdjustPointsOffset(1, -1);
end

function HouseFinderFriendsPlotPinMixin:OnMouseUpAction(button, upInside)
	self:AdjustPointsOffset(-1, 1);
end

function HouseFinderFriendsPlotPinMixin:OnMouseClickAction()
	self.SelectedUnderlay:Show();
	HouseFinderFrame:SelectPlot(self, self.plotInfo);
	self.dataProvider:SetSelectedPin(self);
end
