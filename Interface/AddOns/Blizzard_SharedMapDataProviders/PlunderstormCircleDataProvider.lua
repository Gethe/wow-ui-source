PlunderstormCircleDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

local validCircle = false;

local timeToLerp = 0;
local baseRadius = 0;
local OuterCircle = {};
local InnerCircle = {};
local PredictionCircle = {};
local startLerpTime = 0;
local initialBaseSize = 0;

-- Ratio of the image of the circle on the map versus the in-game circle
local CIRCLE_SIZE_RATIO = 0.58;
local LIGHTNING_SIZE_RATIO = 1.28;

local InnerCircleShrinkingColor = CreateColorFromRGBAHexString("FFFFFFFF");
local OuterCircleColor = CreateColorFromHexString("537B9BFF");
local InnerCircleIdleColor = OuterCircleColor; -- Same as outer for now.

function PlunderstormCircleDataProviderMixin:OnAdded(owningMap)
	self.owningMap = owningMap;
	self:RegisterEvent("WOW_LABS_DATA_BR_CIRCLE");
	C_WowLabsDataManager.PushCircleInfoToLua();
end

function PlunderstormCircleDataProviderMixin:OnEvent(event, ...)
	if event == "WOW_LABS_DATA_BR_CIRCLE" then
		startLerpTime, timeToLerp, OuterCircle.position, InnerCircle.position, baseRadius, OuterCircle.scale, InnerCircle.scale, PredictionCircle.position, PredictionCircle.scale, initialBaseSize = ...;
		validCircle = startLerpTime ~= -1 and timeToLerp ~= -1;
		if validCircle then
			startLerpTime = startLerpTime / 1000;
			timeToLerp = timeToLerp / 1000;
			self:RefreshAllData();
		else
			self:RemoveAllData();
		end
	end
end

function PlunderstormCircleDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("PlunderstormInnerCirclePinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("PlunderstormOuterCirclePinTemplate");
end

function PlunderstormCircleDataProviderMixin:RefreshAllData(fromOnShow)
	if not validCircle then
		return;
	end

	self:RemoveAllData();

	self:GetMap():AcquirePin("PlunderstormInnerCirclePinTemplate");
	self:GetMap():AcquirePin("PlunderstormOuterCirclePinTemplate", self:IsLightningShown());
end

function PlunderstormCircleDataProviderMixin:SetLightningShown(isLightningShown)
	self.shouldHideLightning = not isLightningShown;
end

function PlunderstormCircleDataProviderMixin:IsLightningShown()
	return not self.shouldHideLightning;
end


--[[ Pin ]]--
PlunderstormCircleBasePinMixin = CreateFromMixins(MapCanvasPinMixin);

function PlunderstormCircleBasePinMixin:SetData(circleData, r, g, b)
	self.circleData = circleData;
	self.Icon:SetVertexColor(r, g, b);
	self:SetScalingLimits(1, 1, 1);
end

function PlunderstormCircleBasePinMixin:OnAcquired()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_PLUNDERSTORM_CIRCLE");
	self:Refresh();
end

function PlunderstormCircleBasePinMixin:GetRelativeScale()
	if InnerCircle.scale and InnerCircle.scale ~= 0 and OuterCircle.scale and OuterCircle.scale ~= 0 then
		return InnerCircle.scale / OuterCircle.scale;
	end
	return 1;
end

function PlunderstormCircleBasePinMixin:UpdatePosition()
	self:SetPosition(self.circleData.position.x, self.circleData.position.y);
end

function PlunderstormCircleBasePinMixin:SetSizeAdjustedByScale(size)
	local canvasScale = self:GetMap():GetCanvasScale();
	size = size * canvasScale * CIRCLE_SIZE_RATIO;
	self:SetSize(size, size);
end

PlunderstormInnerCirclePinMixin = CreateFromMixins(PlunderstormCircleBasePinMixin);

function PlunderstormInnerCirclePinMixin:OnLoad()
	self.AntsRotate:Play();

	self.Icon:SetAtlas("wowlabs_minimapvoid-ring-prediction", TextureKitConstants.UseAtlasSize);

	local r, g, b = InnerCircleIdleColor:GetRGB();
	self:SetData(InnerCircle, r, g, b);
	local mapCanvas = self:GetMap();
	if(mapCanvas) then 
		mapCanvas:AddMaskableTexture(self.Icon);
	end 
end

function PlunderstormInnerCirclePinMixin:Refresh()
	if validCircle and self.circleData ~= nil and self.circleData.position ~= nil then
		self:UpdatePosition();
	end
end

function PlunderstormInnerCirclePinMixin:OnUpdate(elapsed)
	if not validCircle then
		return;
	end

	local relativeScale = self:GetRelativeScale();
	local radius = baseRadius;

	self:SetShown(true);
	local isCircleShrinking = GetTime() < startLerpTime + timeToLerp;

	if isCircleShrinking then
		local r, g, b = InnerCircleShrinkingColor:GetRGB();
		self.Icon:SetVertexColor(r, g, b);
	else
		local r, g, b = InnerCircleIdleColor:GetRGB();
		self.Icon:SetVertexColor(r, g, b);
		
		self:SetPosition(PredictionCircle.position.x, PredictionCircle.position.y);
		relativeScale = PredictionCircle.scale;	
		radius = initialBaseSize;
	end

	local newSize = radius * relativeScale;	
	self:SetSizeAdjustedByScale(newSize);
end

PlunderstormOuterCirclePinMixin = CreateFromMixins(PlunderstormCircleBasePinMixin);

function PlunderstormOuterCirclePinMixin:OnLoad()
	local r, g, b = OuterCircleColor:GetRGB();
	local a = .6;

	local mapCanvas = self:GetMap();
	self:SetData(OuterCircle, r, g, b);
	for index, strip in ipairs(self.Bounds) do
		strip:ClearAllPoints();
		strip:SetVertexColor(r, g, b, a);
		if(mapCanvas) then 
			mapCanvas:AddMaskableTexture(strip);
		end
	end
	self.Corners:SetVertexColor(r, g, b, a);
	if(mapCanvas) then 
		mapCanvas:AddMaskableTexture(self.Corners);
		mapCanvas:AddMaskableTexture(self.Icon);
		mapCanvas:AddMaskableTexture(self.Lightning1);
		mapCanvas:AddMaskableTexture(self.Lightning2);
		mapCanvas:AddMaskableTexture(self.Lightning3);
		mapCanvas:AddMaskableTexture(self.Lightning4);
	end
end

function PlunderstormOuterCirclePinMixin:OnAcquired(showLightning)
	PlunderstormCircleBasePinMixin.OnAcquired(self);

	if showLightning then
		self.LightningPulse:Play();
	else
		self.LightningPulse:Stop();
	end
end

function PlunderstormOuterCirclePinMixin:SetSizeAdjustedByScale(size)
	PlunderstormCircleBasePinMixin.SetSizeAdjustedByScale(self, size);

	local width, height = self:GetSize();
	self.Lightning1:SetSize(width * LIGHTNING_SIZE_RATIO, height * LIGHTNING_SIZE_RATIO);
	self.Lightning2:SetSize(width * LIGHTNING_SIZE_RATIO, height * LIGHTNING_SIZE_RATIO);
	self.Lightning3:SetSize(width * LIGHTNING_SIZE_RATIO, height * LIGHTNING_SIZE_RATIO);
	self.Lightning4:SetSize(width * LIGHTNING_SIZE_RATIO, height * LIGHTNING_SIZE_RATIO);
end

function PlunderstormOuterCirclePinMixin:Refresh()
	if validCircle and self.circleData ~= nil and self.circleData.position ~= nil and timeToLerp == 0 then
		self:UpdatePosition();
	end
end

function PlunderstormCircleBasePinMixin:OnReleased()
	MapCanvasPinMixin.OnReleased(self);
	for index, strip in ipairs(self.Bounds) do
		strip:ClearAllPoints();
	end
end

function PlunderstormOuterCirclePinMixin:OnUpdate(elapsed)
	if not validCircle then
		return;
	end

	local now = GetTime();
	local relativeScale = self:GetRelativeScale();
	if now < startLerpTime + timeToLerp then
		local lerpAmount = (now - startLerpTime) / timeToLerp;

		local newX = Lerp(OuterCircle.position.x, InnerCircle.position.x, lerpAmount);
		local newY = Lerp(OuterCircle.position.y, InnerCircle.position.y, lerpAmount);
		self:SetPosition(newX, newY);
		local newSize = Lerp(baseRadius, baseRadius * relativeScale, lerpAmount);

		self:SetSizeAdjustedByScale(newSize);
	elseif OuterCircle.position ~= nil and InnerCircle.position ~= nil then
		self:SetPosition( InnerCircle.position.x, InnerCircle.position.y);
		local newSize = baseRadius * relativeScale;

		self:SetSizeAdjustedByScale(newSize);
	end

	local parentScrollFrame = self:GetParent():GetParent();
	local anchorTo = parentScrollFrame;
	local anchorW, anchorH = anchorTo:GetSize();

	self.BoundsTL:SetPoint("TOPLEFT", anchorTo, "TOPLEFT");
	self.BoundsTL:SetPoint("BOTTOMRIGHT", self, "TOPLEFT");

	self.BoundsT:SetWidth(self:GetWidth());
	self.BoundsT:SetHeight(anchorH);
	self.BoundsT:SetPoint("BOTTOM", self, "TOP");

	self.BoundsTR:SetPoint("TOPRIGHT", anchorTo, "TOPRIGHT");
	self.BoundsTR:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");

	self.BoundsR:SetHeight(self:GetHeight());
	self.BoundsR:SetWidth(anchorW);
	self.BoundsR:SetPoint("LEFT", self, "RIGHT");

	self.BoundsBR:SetPoint("BOTTOMRIGHT", anchorTo, "BOTTOMRIGHT");
	self.BoundsBR:SetPoint("TOPLEFT", self, "BOTTOMRIGHT");

	self.BoundsB:SetWidth(self:GetWidth());
	self.BoundsB:SetHeight(anchorH);
	self.BoundsB:SetPoint("TOP", self, "BOTTOM");

	self.BoundsBL:SetPoint("BOTTOMLEFT", anchorTo, "BOTTOMLEFT");
	self.BoundsBL:SetPoint("TOPRIGHT", self, "BOTTOMLEFT");

	self.BoundsL:SetHeight(self:GetHeight());
	self.BoundsL:SetWidth(anchorW);
	self.BoundsL:SetPoint("RIGHT", self, "LEFT");
end
