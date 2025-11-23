ZoneLabelDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function ZoneLabelDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	if self.ZoneLabel then
		self.ZoneLabel:SetParent(self:GetMap());
	else
		self.ZoneLabel = CreateFrame("FRAME", nil, self:GetMap(), "ZoneLabelDataProvider_ZoneLabelTemplate");
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

	local mapID = self:GetMap():GetMapID();
	local mapChildren = C_Map.GetMapChildrenInfo(mapID, Enum.UIMapType.Zone);
	for i, childMapInfo in ipairs(mapChildren) do
		local left, right, top, bottom = C_Map.GetMapRectOnMap(childMapInfo.mapID, mapID);
		self:AddZone(childMapInfo.mapID, childMapInfo.name, left, right, top, bottom);
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

function ZoneLabelDataProviderMixin:EvaluateBestAreaTrigger()
	self.labelDirty = false;

	local mapViewRect = self:GetMap():GetViewRect();
	local mapViewRectCenterX, mapViewRectCenterY = mapViewRect:GetCenter();
	local newBestAreaTrigger;
	local bestDistSq = math.huge;
	for areaTrigger in pairs(self.activeAreas) do
		local distSq = Vector2D_GetLengthSquared(mapViewRectCenterX, mapViewRectCenterY, areaTrigger:GetCenter());
		if distSq < bestDistSq then
			newBestAreaTrigger = areaTrigger;
			bestDistSq = distSq;
		end
	end

	if newBestAreaTrigger and not self.bestAreaTrigger then
		self.bestAreaTrigger = newBestAreaTrigger;
		self.ZoneLabel.Text:SetText(newBestAreaTrigger.name);
		self.ZoneLabel.FadeInAnim:Play();
		self:GetMap():TriggerEvent("ZoneLabelFadeInStart", self.bestAreaTrigger.isContinent);

		self.ZoneLabel:ClearAllPoints();
		self.ZoneLabel:SetPoint(self:CalculateAnchorsForAreaTrigger(newBestAreaTrigger));

	elseif self.bestAreaTrigger and self.bestAreaTrigger ~= newBestAreaTrigger then
		self.ZoneLabel.FadeOutAnim:Play();
		self:GetMap():TriggerEvent("ZoneLabelFadeOutStart", self.bestAreaTrigger.isContinent);
		self.bestAreaTrigger = nil;
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
	local width = (right - left);
	local height = (bottom - top);
	if width <= 0 or height <= 0 then
		return;
	end

	local areaTrigger = self:GetMap():AcquireAreaTrigger("ZoneLabelDataProvider_ZoneLabel");
	areaTrigger.owner = self;
	areaTrigger.name = zoneName;
	areaTrigger.isContinent = false;

	self:GetMap():SetAreaTriggerEnclosedCallback(areaTrigger, OnAreaEnclosedChanged);
	self:GetMap():SetAreaTriggerPredicate(areaTrigger, ZoneAreaTriggerPredicate);

	local maxViewRect = self:GetMap():GetMaxZoomViewRect();

	areaTrigger:SetCenter(left + width * .5, top + height * .5);

	local MAX_VIEW_RECT_PERCENT = .5;
	local MIN_VIEW_RECT_PERCENT = .05;
	local halfWidth = Clamp(width, maxViewRect:GetWidth() * MIN_VIEW_RECT_PERCENT, maxViewRect:GetWidth() * MAX_VIEW_RECT_PERCENT) * .5;
	local halfHeight = Clamp(height, maxViewRect:GetWidth() * MIN_VIEW_RECT_PERCENT, maxViewRect:GetHeight() * MAX_VIEW_RECT_PERCENT) * .5;
	areaTrigger:Stretch(halfWidth, halfHeight);
end

function ZoneLabelDataProviderMixin:AddContinent()
	local mapInfo = MapUtil.GetMapParentInfo(self:GetMap():GetMapID(), Enum.UIMapType.Continent);
	if not mapInfo then
		return;
	end

	local areaTrigger = self:GetMap():AcquireAreaTrigger("ZoneLabelDataProvider_ZoneLabel");
	areaTrigger.owner = self;
	areaTrigger.name = mapInfo.name;
	areaTrigger.isContinent = true;

	self:GetMap():SetAreaTriggerEnclosedCallback(areaTrigger, OnAreaEnclosedChanged);
	self:GetMap():SetAreaTriggerPredicate(areaTrigger, ContinentAreaTriggerPredicate);

	areaTrigger:SetCenter(.5, .5);
	areaTrigger:Stretch(.01, .01);
end