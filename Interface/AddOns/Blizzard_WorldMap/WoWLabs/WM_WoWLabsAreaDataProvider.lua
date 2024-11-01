
local AreaTypeToTextureKit = {
	[Enum.WoWLabsAreaType.PlunderstormDropSparse] = "plunderstorm-map-zonegreen",
	[Enum.WoWLabsAreaType.PlunderstormDropMedium] = "plunderstorm-map-zoneyellow",
	[Enum.WoWLabsAreaType.PlunderstormDropDense] = "plunderstorm-map-zonered",
};

local AreaTypeToIconTextureKit = {
	[Enum.WoWLabsAreaType.PlunderstormDropSparse] = "plunderstorm-map-icongreen",
	[Enum.WoWLabsAreaType.PlunderstormDropMedium] = "plunderstorm-map-iconyellow",
	[Enum.WoWLabsAreaType.PlunderstormDropDense] = "plunderstorm-map-iconred",
};

local AreaTypeToSelectAtlas = {
	[Enum.WoWLabsAreaType.PlunderstormDropSparse] = "plunderstorm-map-zoneselected",
	[Enum.WoWLabsAreaType.PlunderstormDropMedium] = "plunderstorm-map-zoneselected",
	[Enum.WoWLabsAreaType.PlunderstormDropDense] = "plunderstorm-map-zoneselected",
};

local AreaTypeToSize = {
	[Enum.WoWLabsAreaType.PlunderstormDropSparse] = 200,
	[Enum.WoWLabsAreaType.PlunderstormDropMedium] = 180,
	[Enum.WoWLabsAreaType.PlunderstormDropDense] = 160,
};

local DropAreaAtlasFormats = {
	Hover = "%s-hover",
	Default = "%s",
	Pressed = "%s-pressed",
};

local DropIconAtlasFormats = {
	Hover = "%s-hover",
	Default = "%s",
	Pressed = "%s-pressed",
	Selected = "%s-selected",
	SelectedHover = "%s-selected",
};

-- TODO:: REPLACE DEBUG AREAS These should be replaced by a request/response flow with the server.
local DebugDropAreas = {
    { x = -1615, y = -1802, areaType = Enum.WoWLabsAreaType.PlunderstormDropDense, id = 155569, }, -- Stromgarde
	{ x = -1312, y = -2080, areaType = Enum.WoWLabsAreaType.PlunderstormDropMedium, id = 155570, }, -- Circle of Elements
	{ x = -866, y = -2080, areaType = Enum.WoWLabsAreaType.PlunderstormDropDense, id = 155571 }, -- Ar'gorok
	{ x = -1960, y = -2780, areaType = Enum.WoWLabsAreaType.PlunderstormDropMedium, id = 155572 }, -- Boulderfist Hall
	{ x = -1523, y = -2963, areaType = Enum.WoWLabsAreaType.PlunderstormDropDense, id = 155573 }, -- Go'Shek Farm
	{ x = -1792, y = -3331, areaType = Enum.WoWLabsAreaType.PlunderstormDropMedium, id = 155574 }, -- Witherbark Village
	{ x = -1113, y = -2908, areaType = Enum.WoWLabsAreaType.PlunderstormDropDense, id = 155575 }, -- Dabyrie's Farmstead
	{ x = -973, y = -3431, areaType = Enum.WoWLabsAreaType.PlunderstormDropMedium, id = 155576 }, -- Hammerfall
	{ x = -1138, y = -1691, areaType = Enum.WoWLabsAreaType.PlunderstormDropSparse, id = 155577 }, -- North of Stromgarde
	{ x = -1157, y = -2478, areaType = Enum.WoWLabsAreaType.PlunderstormDropSparse, id = 155578 }, -- Center North
	{ x = -1689, y = -2380, areaType = Enum.WoWLabsAreaType.PlunderstormDropSparse, id = 155579 }, -- Center South
	{ x = -1387, y = -3375, areaType = Enum.WoWLabsAreaType.PlunderstormDropSparse, id = 155580 }, -- East
};


WoWLabsAreaDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

local WoWLabsAreaDataProviderEvents = {
	"SELECT_WOW_LABS_AREA_FAILED",
	"LOBBY_MATCHMAKER_PARTY_UPDATE",
	"WOW_LABS_MATCH_STATE_UPDATED",
};

function WoWLabsAreaDataProviderMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, WoWLabsAreaDataProviderEvents);

	EventRegistry:RegisterCallback("PlunderstormCountdown.TimerFinished", self.OnPlunderstormCountdownFinished, self);
	EventRegistry:RegisterCallback("WoWLabsAreaPin.AreaSelected", self.OnAreaSelected, self);
	EventRegistry:RegisterCallback("WoWLabsAreaPin.AutoSelect", self.OnAutoSelect, self);
	EventRegistry:RegisterCallback("WoWLabsAreaPin.ConfirmSelection", self.OnConfirmSelection, self);
end

function WoWLabsAreaDataProviderMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, WoWLabsAreaDataProviderEvents);

	EventRegistry:UnregisterCallback("PlunderstormCountdown.TimerFinished", self);
	EventRegistry:UnregisterCallback("WoWLabsAreaPin.AreaSelected", self);
end

function AreaPOIDataProviderMixin:OnEvent(event, ...)
	if event == "AREA_POIS_UPDATED" then
		self:RefreshAllData();
	elseif event == "SELECT_WOW_LABS_AREA_FAILED" then
		self:RefreshAllData();
	elseif event == "WOW_LABS_MATCH_STATE_UPDATED" then
		self:RefreshAllData();
	elseif event == "LOBBY_MATCHMAKER_PARTY_UPDATE" then
		self.finalAreaID = C_WoWLabsMatchmaking.GetConfirmedWoWLabsArea();
		self:RefreshAllData();
	end
end

function WoWLabsAreaDataProviderMixin:OnPlunderstormCountdownFinished()
	self:RefreshAllData();
end

function WoWLabsAreaDataProviderMixin:OnAreaSelected(areaID)
	self.selectedAreaID = areaID;
	self:RefreshAllData();
end

function WoWLabsAreaDataProviderMixin:OnAutoSelect()
	-- TODO:: REPLACE DEBUG AREAS These should be replaced by a request/response flow with the server.
	local randomArea = DebugDropAreas[math.random(1, #DebugDropAreas)];
	self.selectedAreaID = randomArea.id;
	self:OnConfirmSelection();
end

function WoWLabsAreaDataProviderMixin:OnConfirmSelection()
	if not self.selectedAreaID then
		return;
	end

	C_WoWLabsMatchmaking.SelectWoWLabsArea(self.selectedAreaID);
	self.requestedAreaID = self.selectedAreaID;
	self:RefreshAllData();
end

function WoWLabsAreaDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("WoWLabsAreaSelectionControlsPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("WoWLabsAreaPinTemplate");
end

local function ShouldShowWoWLabsAreas()
	if not C_WowLabsDataManager.IsInPrematch() then
		return false;
	elseif C_WoWLabsMatchmaking.GetPartyPlaylistEntry() == Enum.PartyPlaylistEntry.TrainingGameMode then
		return false;
	end

	-- For now only the party leader can select an area.
	return UnitLeadsAnyGroup("player");
end

function WoWLabsAreaDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	if ShouldShowWoWLabsAreas() then
		self.confirmedAreaID = C_WoWLabsMatchmaking.GetConfirmedWoWLabsArea();

		local shouldBeEnabled = (self.requestedAreaID == nil) and (self.confirmedAreaID == nil);
		if shouldBeEnabled then
			local controlsPin = self:GetMap():AcquirePin("WoWLabsAreaSelectionControlsPinTemplate");
			controlsPin:SetPosition(0.5, 0.5);
			controlsPin.ConfirmSelectionButton:SetEnabled(self.selectedAreaID ~= nil);
		end

		-- TODO:: REPLACE DEBUG AREAS These should be replaced by a request/response flow with the server.
		for i, dropArea in ipairs(DebugDropAreas) do
			local areaInfo = {
				position = select(2, C_Map.GetMapPosFromWorldPos(2695, { x = dropArea.x, y = dropArea.y })),
				areaType = dropArea.areaType,
				id = dropArea.id,
				selected = (dropArea.id == self.selectedAreaID),
				confirmed = (dropArea.id == self.confirmedAreaID),
				enabled = shouldBeEnabled,
			};

			self:GetMap():AcquirePin("WoWLabsAreaPinTemplate", areaInfo);
		end
	end
end

--[[ Pin ]]--
WoWLabsAreaPinMixin = CreateFromMixins(MapCanvasPinMixin);

function WoWLabsAreaPinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_WOW_LABS_AREA");
end

function WoWLabsAreaPinMixin:OnClick()
	if not self:IsEnabled() then
		return;
	end

	EventRegistry:TriggerEvent("WoWLabsAreaPin.AreaSelected", self.areaInfo.id);
end

function WoWLabsAreaPinMixin:OnMouseDown()
	if not self:IsEnabled() then
		return;
	end

	self.isMouseDown = true;
	self:UpdateIconState();
end

function WoWLabsAreaPinMixin:OnMouseUp()
	self.isMouseDown = false;

	if not self:IsEnabled() then
		return;
	end

	self:UpdateIconState();
end

function WoWLabsAreaPinMixin:OnMouseEnter()
	self:UpdateIconState();
end

function WoWLabsAreaPinMixin:OnMouseLeave()
	self:UpdateIconState();
end

function WoWLabsAreaPinMixin:OnAcquired(areaInfo)
	self.isMouseDown = false;
	self.areaInfo = areaInfo;

	self:SetPosition(areaInfo.position:GetXY());

	local size = AreaTypeToSize[areaInfo.areaType];
	self:SetSize(size, size);

	local textureKit = AreaTypeToTextureKit[areaInfo.areaType];
	if textureKit then
		self.NormalTexture:SetAtlas(DropAreaAtlasFormats.Default:format(textureKit));
		self.PushedTexture:SetAtlas(DropAreaAtlasFormats.Pressed:format(textureKit));

		local showSelected = areaInfo.selected or areaInfo.confirmed;
		local selectedAtlas = AreaTypeToSelectAtlas[areaInfo.areaType];
		self.HighlightTexture:SetAtlas(showSelected and selectedAtlas or DropAreaAtlasFormats.Hover:format(textureKit));
		self.OverlayFrame.SelectedTexture:SetShown(showSelected);
		self.OverlayFrame.SelectedTexture:SetAtlas(selectedAtlas);
	end

	self:UpdateIconState();
	self:SetEnabled(areaInfo.enabled);
end

function WoWLabsAreaPinMixin:GetIconAtlasFormat(isSelected)
	if isSelected then
		return self:IsMouseOver() and DropIconAtlasFormats.SelectedHover or DropIconAtlasFormats.Selected;
	end

	if self.isMouseDown then
		return DropIconAtlasFormats.Pressed;
	elseif self:IsMouseOver() then
		return DropIconAtlasFormats.Hover;
	end

	return DropIconAtlasFormats.Default;
end

function WoWLabsAreaPinMixin:UpdateIconState()
	if self.areaInfo then
		local iconTextureKit = AreaTypeToIconTextureKit[self.areaInfo.areaType];
		if iconTextureKit then
			local atlasFormat = self:GetIconAtlasFormat(self.areaInfo.selected);
			self.OverlayFrame.Icon:SetAtlas(atlasFormat:format(iconTextureKit), TextureKitConstants.UseAtlasSize);
		end
	end
end

WoWLabsAreaSelectionControlsPinMixin = CreateFromMixins(MapCanvasPinMixin);

function WoWLabsAreaSelectionControlsPinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_TOPMOST");

	self.AutoSelectButton:SetScript("OnClick", function()
		EventRegistry:TriggerEvent("WoWLabsAreaPin.AutoSelect");
	end);

	self.ConfirmSelectionButton:SetScript("OnClick", function()
		EventRegistry:TriggerEvent("WoWLabsAreaPin.ConfirmSelection");
	end);
end

function WoWLabsAreaSelectionControlsPinMixin:OnShow()
	EventRegistry:RegisterCallback("WoWLabsAreaPin.AreaSelected", self.OnAreaSelected, self);
end

function WoWLabsAreaSelectionControlsPinMixin:OnHide()
	EventRegistry:UnregisterCallback("WoWLabsAreaPin.AreaSelected", self);
end

function WoWLabsAreaSelectionControlsPinMixin:OnCanvasSizeChanged()
	local map = self:GetMap();
	self:SetSize(map:DenormalizeHorizontalSize(1.0), map:DenormalizeVerticalSize(1.0));
end