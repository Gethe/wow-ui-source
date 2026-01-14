ContributionCollectorDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function ContributionCollectorDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("ContributionCollectorPinTemplate");
end

function ContributionCollectorDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	local contributionCollectors = C_ContributionCollector.GetContributionCollectorsForMap(mapID);
	for i, contributionCollectorInfo in ipairs(contributionCollectors) do
		self:GetMap():AcquirePin("ContributionCollectorPinTemplate", contributionCollectorInfo);
	end
end

--[[ Pin ]]--
ContributionCollectorPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_CONTRIBUTION_COLLECTOR");

function ContributionCollectorPinMixin:OnAcquired(contributionCollectorInfo) -- override
	BaseMapPoiPinMixin.OnAcquired(self, contributionCollectorInfo);

	self.collectorCreatureID = contributionCollectorInfo.collectorCreatureID;
end

function ContributionCollectorPinMixin:OnMouseEnter() -- override
	self.UpdateTooltip = function() self:OnMouseEnter(); end;

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.name, HIGHLIGHT_FONT_COLOR:GetRGB());
	GameTooltip:AddLine(" ");

	self:AddContributionsToTooltip(GameTooltip, C_ContributionCollector.GetManagedContributionsForCreatureID(self.collectorCreatureID));

	GameTooltip:Show();
end

function ContributionCollectorPinMixin:OnMouseLeave() -- override
	GameTooltip:Hide();
end

function ContributionCollectorPinMixin:AddContributionsToTooltip(tooltip, ...)
	for i = 1, select("#", ...) do
		local contributionID = select(i, ...);
		local contributionName = C_ContributionCollector.GetName(contributionID);
		local state, stateAmount, timeOfNextStateChange = C_ContributionCollector.GetState(contributionID);
		local appearanceData = C_ContributionCollector.GetContributionAppearance(contributionID, state);

		if i ~= 1 then
			tooltip:AddLine(" ");
		end

		tooltip:AddLine(contributionName, HIGHLIGHT_FONT_COLOR:GetRGB());

		local tooltipLine = appearanceData.tooltipLine;
		if tooltipLine then
			if timeOfNextStateChange and appearanceData.tooltipUseTimeRemaining then
				local time = math.max(timeOfNextStateChange - GetServerTime(), 60); -- Never display times below one minute
				tooltipLine = tooltipLine:format(SecondsToTime(time, true, true, 1));
			else
				tooltipLine = tooltipLine:format(FormatPercentage(stateAmount));
			end

			tooltip:AddLine(tooltipLine, appearanceData.stateColor:GetRGB());
		end
	end
end