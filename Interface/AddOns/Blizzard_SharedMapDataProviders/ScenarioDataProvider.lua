
ScenarioDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function ScenarioDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	self:GetMap():SetPinTemplateType("ScenarioBlobPinTemplate", "ScenarioPOIFrame");

	-- a single permanent pin for the blob
	local blobPin = self:GetMap():AcquirePin("ScenarioBlobPinTemplate");
	blobPin:SetPosition(0.5, 0.5);
	self.blobPin = blobPin;
end

function ScenarioDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("ScenarioPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("ScenarioBlobPinTemplate");
end

function ScenarioDataProviderMixin:RefreshAllData(fromOnShow)
	local mapID = self:GetMap():GetMapID();

	self:GetMap():RemoveAllPinsByTemplate("ScenarioPinTemplate");
	if C_Scenario.IsInScenario() then
		local scenarioIconInfo = C_Scenario.GetScenarioIconInfo(mapID);
		if scenarioIconInfo then
			for i, info in ipairs(scenarioIconInfo) do
				self:GetMap():AcquirePin("ScenarioPinTemplate", info);
			end
		end
	end

	self.blobPin:SetMapID(mapID);
	self.blobPin:Refresh();
end

function ScenarioDataProviderMixin:OnShow()
	self:RegisterEvent("SCENARIO_UPDATE");
end

function ScenarioDataProviderMixin:OnHide()
	self:UnregisterEvent("SCENARIO_UPDATE");
end

function ScenarioDataProviderMixin:OnEvent(event, ...)
	if event == "SCENARIO_UPDATE" then
		self:RefreshAllData();
	end
end

--[[ Scenario Blob Pin ]]--
ScenarioBlobPinMixin = CreateFromMixins(MapCanvasPinMixin);

function ScenarioBlobPinMixin:OnLoad()
	self:SetFillTexture("Interface\\WorldMap\\UI-QuestBlob-Inside");
	self:SetBorderTexture("Interface\\WorldMap\\UI-QuestBlob-Outside");
	self:SetFillAlpha(128);
	self:SetBorderAlpha(192);
	self:SetBorderScalar(1.0);
	self:SetIgnoreGlobalPinScale(true);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_SCENARIO_BLOB");
	self.questID = 0;
end

function ScenarioBlobPinMixin:OnCanvasSizeChanged()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
end

function ScenarioBlobPinMixin:OnCanvasScaleChanged()
	-- need to wait until end of the frame to update
	self:MarkDirty();
end

function ScenarioBlobPinMixin:MarkDirty()
	if not self.dirty then
		self.dirty = true;
		self:SetScript("OnUpdate", self.OnUpdate);
	end
end

function ScenarioBlobPinMixin:OnUpdate()
	self.dirty = nil;
	self:SetScript("OnUpdate", nil);
	self:Refresh();
end

function ScenarioBlobPinMixin:Refresh()
	self:DrawNone();
	if C_Scenario.IsInScenario() then
		self:DrawAll();
	end
end

--[[ Scenario POI Pins ]]--
ScenarioPinMixin = CreateFromMixins(MapCanvasPinMixin);

function ScenarioPinMixin:OnLoad()
	self:SetScalingLimits(1, 1, 1);

	self:UseFrameLevelType("PIN_FRAME_LEVEL_SCENARIO");
end

function ScenarioPinMixin:OnAcquired(info)
	local x1, x2, y1, y2 = GetObjectIconTextureCoords(info.index);
	self.Icon:SetTexCoord(x1, x2, y1, y2);
	self:SetPosition(info.x, info.y);
end