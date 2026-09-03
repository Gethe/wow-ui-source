MarchingAntsMixin = CreateFromMixins(DirtiableMixin);

function MarchingAntsMixin:OnLoad()
	self:SetDirtyMethod(self.Clean);
	self:SetupAssets();
end

function MarchingAntsMixin:OnShow()
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:CheckResumePlaying();
end

function MarchingAntsMixin:OnHide()
	self:UnregisterEvent("UI_SCALE_CHANGED");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:Stop();
end

function MarchingAntsMixin:OnEvent(event, ...)
	self:MarkDirty();
end

function MarchingAntsMixin:Clean()
	self:Stop();
	self:SetupAssets();
	self:CheckResumePlaying();
end

function MarchingAntsMixin:CheckResumePlaying()
	if self:IsVisible() and (self:GetSpeed() > 0) then
		self:Play();
	end
end

function MarchingAntsMixin:Play()
	self.MarchingAnim:Play();
end

function MarchingAntsMixin:Pause()
	self.MarchingAnim:Pause();
end

function MarchingAntsMixin:Stop()
	self.MarchingAnim:Stop();
end

function MarchingAntsMixin:GetHorizontalAsset()
	return self.horizontalAsset or [[UI-RaidFrames-SingleAnt-Horiz]];
end

function MarchingAntsMixin:SetHorizontalAsset(asset)
	self.horizontalAsset = asset;
	self:MarkDirty();
end

function MarchingAntsMixin:GetVerticalAsset()
	return self.verticalAsset or [[UI-RaidFrames-SingleAnt-Vertical]];
end

function MarchingAntsMixin:SetVerticalAsset(asset)
	self.verticalAsset = asset;
	self:MarkDirty();
end

function MarchingAntsMixin:GetCornersAsset()
	-- This is optional, the region will hide if not set.
	return self.cornersAsset;
end

function MarchingAntsMixin:SetCornersAsset(asset)
	self.cornersAsset = asset;
	self:MarkDirty();
end

function MarchingAntsMixin:GetSpeed()
	return self.animSpeed or 1;
end

function MarchingAntsMixin:SetSpeed(speed)
	-- Speeds of 0 will pause the animation, different speeds will resume the animation at the desired rate.
	-- FIXME: Adding checks to protect against
	self.animSpeed = math.max(speed or 1, 0);

	if self.animSpeed == 0 then
		self:Pause();
	elseif self.animSpeed > 0 then
		self.MarchingAnim:SetAnimationSpeedMultiplier(self.animSpeed);
		self:CheckResumePlaying();
	end
end

local elementSetupData =
{
	Left = { addressModeH = TextureKitConstants.AddressModeClamp, addressModeV = TextureKitConstants.AddressModeWrap, point1 = "TOPLEFT", point2 = "BOTTOMLEFT", keyOffsetP1X = "leftOffsetP1X", keyOffsetP1Y = "leftOffsetP1Y", keyOffsetP2X = "leftOffsetP2X", keyOffsetP2Y = "leftOffsetP2Y" },
	Right = { addressModeH = TextureKitConstants.AddressModeClamp, addressModeV = TextureKitConstants.AddressModeWrap, point1 = "TOPRIGHT", point2 = "BOTTOMRIGHT", keyOffsetP1X = "rightOffsetP1X", keyOffsetP1Y = "rightOffsetP1Y", keyOffsetP2X = "rightOffsetP2X", keyOffsetP2Y = "rightOffsetP2Y" },
	Top = { addressModeH = TextureKitConstants.AddressModeWrap, addressModeV = TextureKitConstants.AddressModeClamp, point1 = "TOPLEFT", point2 = "TOPRIGHT", keyOffsetP1X = "topOffsetP1X", keyOffsetP1Y = "topOffsetP1Y", keyOffsetP2X = "topOffsetP2X", keyOffsetP2Y = "topOffsetP2Y" },
	Bottom = { addressModeH = TextureKitConstants.AddressModeWrap, addressModeV = TextureKitConstants.AddressModeClamp, point1 = "BOTTOMLEFT", point2 = "BOTTOMRIGHT", keyOffsetP1X = "bottomOffsetP1X", keyOffsetP1Y = "bottomOffsetP1Y", keyOffsetP2X = "bottomOffsetP2X", keyOffsetP2Y = "bottomOffsetP2Y" },
	Corners = { point1 = "TOPLEFT", point2 = "BOTTOMRIGHT", keyOffsetP1X = "cornerOffsetP1X", keyOffsetP1Y = "cornerOffsetP1Y", keyOffsetP2X = "cornerOffsetP2X", keyOffsetP2Y = "cornerOffsetP2Y" },
}

local function AnchorElement(container, elementKey)
	local data = elementSetupData[elementKey];
	local element = container[elementKey];
	element:ClearAllPoints();
	element:SetPoint(data.point1, container, data.point1, container[data.keyOffsetP1X] or 0, container[data.keyOffsetP1Y] or 0);
	element:SetPoint(data.point2, container, data.point2, container[data.keyOffsetP2X] or 0, container[data.keyOffsetP2Y] or 0);
end

local function SetupElement(container, elementKey, asset)
	local data = elementSetupData[elementKey];
	if data.addressModeH and data.addressModeV then
		SetTextureWithAddressModeOptions(container[elementKey], asset, TextureKitConstants.UseAtlasSize, data.addressModeH, data.addressModeV, true);
	else
		container[elementKey]:SetAtlas(asset);
	end

	AnchorElement(container, elementKey);
end

function MarchingAntsMixin:SetupAssets()
	SetupElement(self, "Top", self:GetHorizontalAsset());
	SetupElement(self, "Bottom", self:GetHorizontalAsset());
	SetupElement(self, "Left", self:GetVerticalAsset());
	SetupElement(self, "Right", self:GetVerticalAsset());

	local cornersAsset = self:GetCornersAsset();
	if cornersAsset then
		SetupElement(self, "Corners", cornersAsset);
		self.Corners:Show();
	else
		self.Corners:Hide();
	end
end

function MarchingAntsMixin:SetColor(color)
	local r, g, b, a = color:GetRGBA();
	self.Corners:SetVertexColor(r, g, b, a);
	self.Top:SetVertexColor(r, g, b, a);
	self.Left:SetVertexColor(r, g, b, a);
	self.Right:SetVertexColor(r, g, b, a);
	self.Bottom:SetVertexColor(r, g, b, a);
end

function MarchingAntsMixin:SetGradient(orientation, startColor, endColor)
	-- TODO: Add direction
	local startR, startG, startB, startA = startColor:GetRGBA();
	local endR, endG, endB, endA = endColor:GetRGBA();

	-- Gradients are apparently backwards, so reverse arguments as needed in the internal calls to make it work like this:
	-- horizontal: start = left side, end = right side
	-- vertical: start = top side, end = bottom side.

	self.Corners:SetGradient(orientation, endColor, startColor);

	if orientation == "HORIZONTAL" then
		self.Top:SetGradient(orientation, startColor, endColor);
		self.Bottom:SetGradient(orientation, startColor, endColor);

		-- TODO: Interpolate the sides that don't get the full gradient
		self.Left:SetVertexColor(startR, startG, startB, startA);
		self.Right:SetVertexColor(endR, endG, endB, endA);
	else
		self.Left:SetGradient(orientation, endColor, startColor);
		self.Right:SetGradient(orientation, endColor, startColor);

		-- TODO: Interpolate the sides that don't get the full gradient
		self.Top:SetVertexColor(startR, startG, startB, startA);
		self.Bottom:SetVertexColor(endR, endG, endB, endA);
	end
end

local function SetInsetsInternal(container, element, elementKey, p1x, p1y, p2x, p2y)
	local points = elementSetupData[elementKey];
	self[points.keyOffsetP1X] = p1x;
	self[points.keyOffsetP1Y] = p1y;
	self[points.keyOffsetP2X] = p2x;
	self[points.keyOffsetP2Y] = p2y;
	AnchorElement(container, element, elementKey);
end

function MarchingAntsMixin:SetInsetCorners(left, top, right, bottom)
	SetInsetsInternal(self, self.Corners, "Corners", left, top, right, bottom);
end

function MarchingAntsMixin:SetInsetLeft(left, top, right, bottom)
	SetInsetsInternal(self, self.Left, "Left", left, top, right, bottom);
end

function MarchingAntsMixin:SetInsetRight(left, top, right, bottom)
	SetInsetsInternal(self, self.Right, "Right", left, top, right, bottom);
end

function MarchingAntsMixin:SetInsetBottom(left, top, right, bottom)
	SetInsetsInternal(self, self.Bottom, "Bottom", left, top, right, bottom);
end

function MarchingAntsMixin:SetLineThickness(width, height)
	self.Left:SetWidth(width);
	self.Right:SetWidth(width);
	self.Top:SetHeight(height);
	self.Bottom:SetHeight(height);
end

function MarchingAntsMixin:AnchorAroundTarget(target, optPaddingHorizontal, optPaddingVertical)
	if target then
		local paddingH = optPaddingHorizontal or 0;
		local paddingV = optPaddingVertical or 0;
		self:ClearAllPoints();
		self:SetPoint("TOPLEFT", target, "TOPLEFT", -paddingH, paddingV);
		self:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", paddingH, -paddingV);
	end
end

function MarchingAnts_CreateAsChildOf(parent, optTemplate, optParentKey)
	-- First check if it already exists and use that element:
	local parentKey = optParentKey or "MarchingAnts";
	if parent and parent[parentKey] then
		return parent[parentKey];
	end

	local ants = CreateFrame("Frame", nil, parent, optTemplate or "MarchingAntsTemplate");
	if parent then
		ants:SetParentKey(parentKey);
	end

	return ants;
end

function MarchingAnts_Create(parent, width, height, optTemplate, optAnchor, optParentKey)
	local ants = MarchingAnts_CreateAsChildOf(parent, optTemplate, optParentKey);
	if width and height then
		ants:SetSize(width, height);
	end

	if optAnchor then
		local clearAllPoints = true;
		optAnchor:SetPoint(ants, clearAllPoints);
	end

	return ants;
end

function MarchingAnts_CreateForTarget(target, optTemplate, optPaddingHorizontal, optPaddingVertical, optParentKey)
	local ants = MarchingAnts_CreateAsChildOf(target, optTemplate, optParentKey);
	ants:AnchorAroundTarget(target, optPaddingHorizontal, optPaddingVertical);
	return ants;
end
