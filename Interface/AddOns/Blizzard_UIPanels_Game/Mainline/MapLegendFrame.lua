MapLegendMixin = { };

function MapLegendMixin:OnLoad()
	self:SetupCategories();
	self.ScrollFrame.ScrollChild:Layout();

	self.ScrollFrame:UpdateScrollChildRect();
end

function MapLegendMixin:SetupCategories()
	for index, data in ipairs(MapLegendData) do
		local category = CreateFrame("Frame", nil, self.ScrollFrame.ScrollChild, "MapLegendCategoryTemplate", index);
		category.TitleText:SetText(data.CategoryTitle);
		category.layoutIndex = index;
		category:Show();

		local buttons = {};
		for i, categoryID in ipairs(data.CategoryData) do
			local categoryData = MapLegendPinDefinitions[categoryID];
			if categoryData then
				local button = CreateFrame("Button", nil, category, "MapLegendButtonTemplate", i);
				button:InitializeButton(categoryData, i);
				table.insert(buttons, button);
			end
		end

		local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, 2, 0, 5);
		local anchor = CreateAnchor("TOPLEFT", category, "TOPLEFT", 0, -3);
		AnchorUtil.GridLayout(buttons, anchor, layout);

		category:Layout();
	end
end

MapLegendButtonMixin = { };

function MapLegendButtonMixin:OnEnter()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	GameTooltip_SetTitle(tooltip, self.nameText);
	GameTooltip_AddNormalLine(tooltip, self.tooltipText);
	tooltip:Show();
	self:HighlightMapPins();
end

function MapLegendButtonMixin:OnLeave()
	GetAppropriateTooltip():Hide();
	self:ClearHighlights();
end

function MapLegendButtonMixin:InitializeButton(buttonInfo, index)
	self.Icon:SetAtlas(buttonInfo.Atlas, TextureKitConstants.UseAtlasSize);
	if buttonInfo.fixedWidth and buttonInfo.fixedHeight then
		self.Icon:SetSize(buttonInfo.fixedWidth, buttonInfo.fixedHeight);
	end

	if (buttonInfo.BackgroundAtlas) then
		self.IconBack:SetAtlas(buttonInfo.BackgroundAtlas, TextureKitConstants.UseAtlasSize);
		self.IconBack:Show();
		-- Adjusting IconBack so the circle of the BackgroundAtlas ("UI-QuestPoi-QuestNumber") aligns with other circle atlases.
		self.IconBack:SetPoint("LEFT", -2, 0);
	else
		self.IconBack:SetPoint("LEFT", 0, 0);
	end
	self:SetText(buttonInfo.Name);
	self:Show();
	self.nameText = buttonInfo.Name;
	self.layoutIndex = index;
	self.tooltipText = buttonInfo.Tooltip;
	self.templates = buttonInfo.TemplateNames;
	--metadata
	self.metaData = buttonInfo.MetaData;

	EventRegistry:RegisterCallback("MapLegendPinOnEnter", self.HighlightSelfForPin, self);
	EventRegistry:RegisterCallback("MapLegendPinOnLeave", self.RemoveSelfHighlight, self);
end

function MapLegendButtonMixin:HighlightSelfForPin(pin)
	for i, templateName in ipairs(self.templates) do
		if pin.pinTemplate == templateName then
			if self:MetaDataMatches(pin) then
				self:SetHighlightLocked(true);
			end
		end
	end
end

function MapLegendButtonMixin:RemoveSelfHighlight()
	self:SetHighlightLocked(false);
end

function MapLegendButtonMixin:HighlightMapPins()
	self.highlightedPins = {};
	for i, templateName in ipairs(self.templates) do
		for pin in WorldMapFrame:EnumeratePinsByTemplate(templateName) do
			--check metadata comparisons. Returns true if data matches or no data exists
			if self:MetaDataMatches(pin) then
				pin:ShowMapLegendGlow();
				table.insert(self.highlightedPins, pin);
			end
		end
	end
end

function MapLegendButtonMixin:MetaDataMatches(pin)
	if self.metaData then
		if self.metaData.Style and pin.GetStyle and pin:GetStyle() == self.metaData.Style then
			return true;
		end
		if self.metaData.questClassification and pin.GetQuestClassification and pin:GetQuestClassification() == self.metaData.questClassification then
			return true;
		end
		if self.metaData.isRaid ~= nil and pin.isRaid ~= nil and self.metaData.isRaid == pin.isRaid then
			return true;
		end
		if self.metaData.worldQuestType and pin.worldQuestType and pin.worldQuestType == self.metaData.worldQuestType then
			return true;
		end
		if self.metaData.Atlas and pin.poiInfo and self.metaData.Atlas == pin.poiInfo.atlasName then
			return true;
		end
		if self.metaData.AtlasPrefix and pin.poiInfo and pin.poiInfo.atlasName then
			if string.find(pin.poiInfo.atlasName, self.metaData.AtlasPrefix, 1, true) == 1 then
				return true;
			end
		end
		return false;
	else --return true if button has no meta data
		return true;
	end
end

function MapLegendButtonMixin:ClearHighlights()
	if self.highlightedPins then
		for i, pin in ipairs(self.highlightedPins) do
			pin:HideMapLegendGlow();
		end
	end
end
