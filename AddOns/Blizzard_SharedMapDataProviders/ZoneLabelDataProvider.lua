ZoneLabelDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function ZoneLabelDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	if self.ZoneLabel then
		self.ZoneLabel:SetParent(mapCanvas);
	else
		self.ZoneLabel = CreateFrame("FRAME", nil, mapCanvas, "ZoneLabelDataProvider_ZoneLabelTemplate");
		self.ZoneLabel.dataProvider = self;
	end

	self.ZoneLabel:SetFrameStrata("HIGH");
end

function ZoneLabelDataProviderMixin:RemoveAllData()
	self.bestAreaTrigger = nil;
	self:GetMap():ReleaseAreaTriggers("ZoneLabelDataProvider_ZoneLabel");

	self.ZoneLabel.FadeOutAnim:Stop();
	self.ZoneLabel.FadeInAnim:Stop();

	self.ZoneLabel:Hide();
	self.ZoneLabel:SetAlpha(0);

	self.numActiveAreas = 0;
	self.activeAreas = nil;
end

function ZoneLabelDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	self.numActiveAreas = 0;
	self.activeAreas = {};

	local mapAreaID = self:GetMap():GetMapID();
	for zoneIndex = 1, C_MapCanvas.GetNumZones(mapAreaID) do
		local zoneMapID, zoneName, left, right, top, bottom = C_MapCanvas.GetZoneInfo(mapAreaID, zoneIndex);
		self:AddZone(zoneMapID, zoneName, left, right, top, bottom);
	end

	self:AddContinent();

	self.ZoneLabel:Show();
end

function ZoneLabelDataProviderMixin:OnCanvasPanChanged()
	-- There are multiple areas in the current camera view, we need to check if one of them is getting closer to the center of the map
	if self.numActiveAreas > 1 then
		self:MarkActiveAreasDirty();
	end
end

local EVALUATION_FREQUENCY_SEC = .1;
function ZoneLabelDataProviderMixin:MarkActiveAreasDirty()
	if not self.labelDirty and not self.ZoneLabel.FadeOutAnim:IsPlaying() then
		self.labelDirty = true;

		if not self.ZoneLabel.FadeInAnim:IsPlaying() then -- We'll re-evaluate after the fade in completes
			self.evaluateBestAreaTriggerCallback = self.evaluateBestAreaTriggerCallback or function() self:EvaluateBestAreaTrigger(); end;
			C_Timer.After(EVALUATION_FREQUENCY_SEC, self.evaluateBestAreaTriggerCallback);
		end
	end
end

local function GetDistSq(x1, y1, x2, y2)
	local deltaX = x1 - x2;
	local deltaY = y1 - y2;
	return deltaX * deltaX + deltaY * deltaY;
end

function ZoneLabelDataProviderMixin:EvaluateBestAreaTrigger()
	self.labelDirty = false;

	local mapViewRect = self:GetMap():GetViewRect();
	local mapViewRectCenterX, mapViewRectCenterY = mapViewRect:GetCenter();
	local newBestAreaTrigger;
	local bestDistSq = math.huge;
	for areaTrigger in pairs(self.activeAreas) do
		local distSq = GetDistSq(mapViewRectCenterX, mapViewRectCenterY, areaTrigger:GetCenter());
		if distSq < bestDistSq then
			newBestAreaTrigger = areaTrigger;
			bestDistSq = distSq;
		end
	end

	if newBestAreaTrigger and not self.bestAreaTrigger then
		self.bestAreaTrigger = newBestAreaTrigger;
		self.ZoneLabel.Text:SetText(newBestAreaTrigger.name);
		self.ZoneLabel.FadeInAnim:Play();

		self.ZoneLabel:ClearAllPoints();
		self.ZoneLabel:SetPoint(self:CalculateAnchorsForAreaTrigger(newBestAreaTrigger));

	elseif self.bestAreaTrigger and self.bestAreaTrigger ~= newBestAreaTrigger then
		self.bestAreaTrigger = nil;
		self.ZoneLabel.FadeOutAnim:Play();
	end
end

function ZoneLabelDataProviderMixin:OnFadeOutFinished()
	if not self.labelDirty then
		self:EvaluateBestAreaTrigger();
	end
end

function ZoneLabelDataProviderMixin:OnFadeInFinished()
	if self.labelDirty then
		self:EvaluateBestAreaTrigger();
	end
end

function ZoneLabelDataProviderMixin:CalculateAnchorsForAreaTrigger(areaTrigger)
	local TOP_Y_OFFSET = -30;
	local BOTTOM_Y_OFFSET = 30;

	if areaTrigger.isContinent then
		return "TOPRIGHT", 0, TOP_Y_OFFSET;
	end

	local x, y = areaTrigger:GetCenter();
	if x < .5 then
		if x > .45 then
			if y > .5 then
				return "BOTTOM", 0, BOTTOM_Y_OFFSET;
			else
				return "TOP", 0, TOP_Y_OFFSET;
			end
		end
		if y > .5 then
			return "BOTTOMLEFT", 0, BOTTOM_Y_OFFSET;
		else
			return "TOPLEFT", 0, TOP_Y_OFFSET;
		end
	else
		if x < .55 then
			if y > .5 then
				return "BOTTOM", 0, BOTTOM_Y_OFFSET;
			else
				return "TOP", 0, TOP_Y_OFFSET;
			end
		end
		if y > .5 then
			return "BOTTOMRIGHT", 0, BOTTOM_Y_OFFSET;
		else
			return "TOPRIGHT", 0, TOP_Y_OFFSET;
		end
	end
end

local APPEAR_PERCENT = .85;
local function ZoneAreaTriggerPredicate(areaTrigger)
	local mapCanvas = areaTrigger.owner:GetMap();
	return not mapCanvas:IsZoomingOut() and mapCanvas:GetCanvasZoomPercent() > APPEAR_PERCENT;
end

local function ContinentAreaTriggerPredicate(areaTrigger)
	return not ZoneAreaTriggerPredicate(areaTrigger);
end

function ZoneLabelDataProviderMixin:OnAreaEnclosedChanged(areaTrigger, areaEnclosed)
	if areaEnclosed then
		self.activeAreas[areaTrigger] = true;
		self.numActiveAreas = self.numActiveAreas + 1;
	else
		self.activeAreas[areaTrigger] = nil;
		self.numActiveAreas = self.numActiveAreas - 1;
	end

	self:MarkActiveAreasDirty();
end

local function OnAreaEnclosedChanged(areaTrigger, areaEnclosed)
	areaTrigger.owner:OnAreaEnclosedChanged(areaTrigger, areaEnclosed);
end

function ZoneLabelDataProviderMixin:AddZone(zoneMapID, zoneName, left, right, top, bottom)
	local areaTrigger = self:GetMap():AcquireAreaTrigger("ZoneLabelDataProvider_ZoneLabel");
	areaTrigger.owner = self;
	areaTrigger.name = zoneName;
	areaTrigger.isContinent = false;

	self:GetMap():SetAreaTriggerEnclosedCallback(areaTrigger, OnAreaEnclosedChanged);
	self:GetMap():SetAreaTriggerPredicate(areaTrigger, ZoneAreaTriggerPredicate);

	local maxViewRect = self:GetMap():GetMaxZoomViewRect();

	local width = (right - left);
	local height = (bottom - top);
	areaTrigger:SetCenter(left + width * .5, top + height * .5);

	local MAX_VIEW_RECT_PERCENT = .5;
	local halfWidth = math.min(maxViewRect:GetWidth() * MAX_VIEW_RECT_PERCENT, width) * .5;
	local halfHeight = math.min(maxViewRect:GetHeight() * MAX_VIEW_RECT_PERCENT, height) * .5;
	areaTrigger:Stretch(halfWidth, halfHeight);
end

function ZoneLabelDataProviderMixin:AddContinent()
	local areaTrigger = self:GetMap():AcquireAreaTrigger("ZoneLabelDataProvider_ZoneLabel");
	areaTrigger.owner = self;
	areaTrigger.name = select(2, C_MapCanvas.GetContinentInfo(self:GetMap():GetMapID()));
	areaTrigger.isContinent = true;

	self:GetMap():SetAreaTriggerEnclosedCallback(areaTrigger, OnAreaEnclosedChanged);
	self:GetMap():SetAreaTriggerPredicate(areaTrigger, ContinentAreaTriggerPredicate);

	areaTrigger:SetCenter(.5, .5);
	areaTrigger:Stretch(.01, .01);
end