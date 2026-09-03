PixelUtil = {};

function PixelUtil.GetPixelToUIUnitFactor()
	local physicalWidth, physicalHeight = GetPhysicalScreenSize();
	return 768.0 / physicalHeight;
end

function PixelUtil.GetNearestPixelSize(uiUnitSize, layoutScale, minPixels)
	if uiUnitSize == 0 and (not minPixels or minPixels == 0) then
		return 0;
	end

	local uiUnitFactor = PixelUtil.GetPixelToUIUnitFactor();
	local numPixels = Round((uiUnitSize * layoutScale) / uiUnitFactor);
	if minPixels then
		if uiUnitSize < 0.0 then
			if numPixels > -minPixels then
				numPixels = -minPixels;
			end
		else
			if numPixels < minPixels then
				numPixels = minPixels;
			end
		end
	end

	return numPixels * uiUnitFactor / layoutScale;
end

function PixelUtil.ConvertPixelsToUI(desiredPixels, layoutScale)
	return PixelUtil.GetNearestPixelSize(desiredPixels, layoutScale);
end

function PixelUtil.ConvertPixelsToUIForRegion(desiredPixels, region)
	return PixelUtil.GetNearestPixelSize(desiredPixels, region:GetEffectiveScale());
end

-- DEPRECATED: Use SetRoundLayoutToNearestPixel instead for native code to automatically apply the same adjustment. This will be removed in the future.
function PixelUtil.SetWidth(region, width, minPixels)
	region:SetWidth(PixelUtil.GetNearestPixelSize(width, region:GetEffectiveScale(), minPixels));
end

-- DEPRECATED: Use SetRoundLayoutToNearestPixel instead for native code to automatically apply the same adjustment. This will be removed in the future.
function PixelUtil.SetHeight(region, height, minPixels)
	region:SetHeight(PixelUtil.GetNearestPixelSize(height, region:GetEffectiveScale(), minPixels));
end

-- DEPRECATED: Use SetRoundLayoutToNearestPixel instead for native code to automatically apply the same adjustment. This will be removed in the future.
function PixelUtil.SetSize(region, width, height, minWidthPixels, minHeightPixels)
	PixelUtil.SetWidth(region, width, minWidthPixels);
	PixelUtil.SetHeight(region, height, minHeightPixels);
end

-- DEPRECATED: Use SetRoundLayoutToNearestPixel instead for native code to automatically apply the same adjustment. This will be removed in the future.
function PixelUtil.SetPoint(region, point, relativeTo, relativePoint, offsetX, offsetY, minOffsetXPixels, minOffsetYPixels)
	region:SetPoint(point, relativeTo, relativePoint,
		PixelUtil.GetNearestPixelSize(offsetX, region:GetEffectiveScale(), minOffsetXPixels),
		PixelUtil.GetNearestPixelSize(offsetY, region:GetEffectiveScale(), minOffsetYPixels)
	);
end

function PixelUtil.SetRoundLayoutToNearestPixelRecursively(frame, enabled)
	frame:SetRoundLayoutToNearestPixel(enabled);

	for _, region in ipairs({frame:GetRegions()}) do
		region:SetRoundLayoutToNearestPixel(enabled);
	end

	for _, child in ipairs({frame:GetChildren()}) do
		PixelUtil.SetRoundLayoutToNearestPixelRecursively(child, enabled);
	end
end
