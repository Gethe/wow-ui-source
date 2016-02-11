AdventureMap_ZoneLabelDataProviderMixin = CreateFromMixins(AdventureMapDataProviderMixin);

function AdventureMap_ZoneLabelDataProviderMixin:OnAdded(adventureMap)
	AdventureMapDataProviderMixin.OnAdded(self, adventureMap);

	if self.ZoneLabel then
		self.ZoneLabel:SetParent(adventureMap);
	else
		self.ZoneLabel = CreateFrame("FRAME", nil, adventureMap, "AdventureMap_ZoneLabelTemplate");
		self.ZoneLabel.dataProvider = self;
	end

	self.ZoneLabel:SetFrameStrata("HIGH");
end

function AdventureMap_ZoneLabelDataProviderMixin:RemoveAllData()
	self.bestAreaTrigger = nil;
	self:GetAdventureMap():ReleaseAreaTriggers("AdventureMap_ZoneLabel");

	self.ZoneLabel.FadeOutAnim:Stop();
	self.ZoneLabel.FadeInAnim:Stop();

	self.ZoneLabel:Hide();
	self.ZoneLabel:SetAlpha(0);

	self.numActiveAreas = 0;
	self.activeAreas = nil;
end

function AdventureMap_ZoneLabelDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	self.numActiveAreas = 0;
	self.activeAreas = {};

	for zoneIndex = 1, C_AdventureMap.GetNumZones() do
		local zoneMapID, zoneName, left, right, top, bottom = C_AdventureMap.GetZoneInfo(zoneIndex);
		self:AddZone(zoneMapID, zoneName, left, right, top, bottom);
	end

	self:AddContinent();

	self.ZoneLabel:Show();
end

function AdventureMap_ZoneLabelDataProviderMixin:OnCanvasPanChanged()
	-- There are multiple areas in the current camera view, we need to check if one of them is getting closer to the center of the map
	if self.numActiveAreas > 1 then
		self:MarkActiveAreasDirty();
	end
end

local EVALUATION_FREQUENCY_SEC = .1;
function AdventureMap_ZoneLabelDataProviderMixin:MarkActiveAreasDirty()
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

function AdventureMap_ZoneLabelDataProviderMixin:EvaluateBestAreaTrigger()
	self.labelDirty = false;

	local mapViewRect = self:GetAdventureMap():GetViewRect();
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

function AdventureMap_ZoneLabelDataProviderMixin:OnFadeOutFinished()
	if not self.labelDirty then
		self:EvaluateBestAreaTrigger();
	end
end

function AdventureMap_ZoneLabelDataProviderMixin:OnFadeInFinished()
	if self.labelDirty then
		self:EvaluateBestAreaTrigger();
	end
end

function AdventureMap_ZoneLabelDataProviderMixin:CalculateAnchorsForAreaTrigger(areaTrigger)
	local TOP_Y_OFFSET = -30;

	if areaTrigger.isContinent then
		return "TOPRIGHT", 0, TOP_Y_OFFSET;
	end

	local x, y = areaTrigger:GetCenter();
	if x < .5 then
		if x > .45 then
			if y > .5 then
				return "BOTTOM", 0, 0;
			else
				return "TOP", 0, TOP_Y_OFFSET;
			end
		end
		if y > .5 then
			return "BOTTOMLEFT", 0, 0;
		else
			return "TOPLEFT", 0, TOP_Y_OFFSET;
		end
	else
		if x < .55 then
			if y > .5 then
				return "BOTTOM", 0, 0;
			else
				return "TOP", 0, TOP_Y_OFFSET;
			end
		end
		if y > .5 then
			return "BOTTOMRIGHT", 0, 0;
		else
			return "TOPRIGHT", 0, TOP_Y_OFFSET;
		end
	end
end

local APPEAR_PERCENT = .85;
local function ZoneAreaTriggerPredicate(areaTrigger)
	local adventureMap = areaTrigger.owner.adventureMap;
	return not adventureMap:IsZoomingOut() and adventureMap:GetCanvasZoomPercent() > APPEAR_PERCENT;
end

local function ContinentAreaTriggerPredicate(areaTrigger)
	return not ZoneAreaTriggerPredicate(areaTrigger);
end

function AdventureMap_ZoneLabelDataProviderMixin:OnAreaEnclosedChanged(areaTrigger, areaEnclosed)
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

function AdventureMap_ZoneLabelDataProviderMixin:AddZone(zoneMapID, zoneName, left, right, top, bottom)
	local areaTrigger = self:GetAdventureMap():AcquireAreaTrigger("AdventureMap_ZoneLabel");
	areaTrigger.owner = self;
	areaTrigger.name = zoneName;
	areaTrigger.isContinent = false;

	self:GetAdventureMap():SetAreaTriggerEnclosedCallback(areaTrigger, OnAreaEnclosedChanged);
	self:GetAdventureMap():SetAreaTriggerPredicate(areaTrigger, ZoneAreaTriggerPredicate);

	local maxViewRect = self:GetAdventureMap():GetMaxZoomViewRect();

	local width = (right - left);
	local height = (bottom - top);
	areaTrigger:SetCenter(left + width * .5, top + height * .5);

	local MAX_VIEW_RECT_PERCENT = .5;
	local halfWidth = math.min(maxViewRect:GetWidth() * MAX_VIEW_RECT_PERCENT, width) * .5;
	local halfHeight = math.min(maxViewRect:GetHeight() * MAX_VIEW_RECT_PERCENT, height) * .5;
	areaTrigger:Stretch(halfWidth, halfHeight);
end

function AdventureMap_ZoneLabelDataProviderMixin:AddContinent()
	local areaTrigger = self:GetAdventureMap():AcquireAreaTrigger("AdventureMap_ZoneLabel");
	areaTrigger.owner = self;
	areaTrigger.name = select(2, C_AdventureMap.GetContinentInfo());
	areaTrigger.isContinent = true;

	self:GetAdventureMap():SetAreaTriggerEnclosedCallback(areaTrigger, OnAreaEnclosedChanged);
	self:GetAdventureMap():SetAreaTriggerPredicate(areaTrigger, ContinentAreaTriggerPredicate);

	areaTrigger:SetCenter(.5, .5);
	areaTrigger:Stretch(.01, .01);
end