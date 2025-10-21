local function AreTextureCoordinatesValid(...)
	local coordCount = select("#", ...);
	for i = 1, coordCount do
		if type(select(i, ...)) ~= "number" then
			return false;
		end
	end

	return coordCount == 8;
end

local function AreTextureCoordinatesEntireImage(...)
	local ulX, ulY, blX, blY, urX, urY, brX, brY = ...;
	return	ulX == 0 and ulY == 0 and
			blX == 0 and blY == 1 and
			urX == 1 and urY == 0 and
			brX == 1 and brY == 1;
end

local function FormatTextureCoordinates(...)
	if AreTextureCoordinatesValid(...) then
		if not AreTextureCoordinatesEntireImage(...) then
			return WrapTextInColorCode(("UL:(%.2f, %.2f), BL:(%.2f, %.2f), UR:(%.2f, %.2f), BR:(%.2f, %.2f)"):format(...), "ff00ffff");
		end

		return "";
	end

	return "invalid coordinates";
end

local function ColorAssetType(assetType)
	if assetType == "Atlas" then
		return WrapTextInColorCode(assetType, "ff00ff00");
	end

	return WrapTextInColorCode(assetType, "ffff0000");
end

local function FormatTextureAssetName(assetName, assetType)
	return ("%s: %s"):format(ColorAssetType(assetType), tostring(assetName));
end

local function FormatTextureInfo(region, ...)
	if ... ~= nil then
		local assetInfo = { select(1, ...), select(2, ...) };
		return ("%s : %s %s"):format(region:GetDebugName(), FormatTextureAssetName(...), FormatTextureCoordinates(select(3, ...))), assetInfo;
	end
end

TextureInfoGeneratorMixin = {};

function TextureInfoGeneratorMixin:CheckGetRegionsTextureInfo(...)
	local info = {};
	local assets = {};
	for i = 1, select("#", ...) do
		local region = select(i, ...);
		if self:ShouldGenerateRegionInfo(region) then
			local textureInfo, assetInfo = FormatTextureInfo(region, GetTextureInfo(region))
			if textureInfo then
				table.insert(info, textureInfo);
				table.insert(assets, assetInfo);
			end
		end
	end

	if #info > 0 then
		return table.concat(info, "\n"), assets;
	end
end

function TextureInfoGeneratorMixin:CheckFormatTextureInfo(obj)
	if CanAccessObject(obj) then
		if obj:IsObjectType("Frame") then
			return self:CheckGetRegionsTextureInfo(obj:GetRegions());
		else
			return self:CheckGetRegionsTextureInfo(obj);
		end
	end
end

function TextureInfoGeneratorMixin:HandleTextureCommand(assets)
	if assets then
		for index, asset in ipairs(assets) do
			local assetName, assetType = asset[1], asset[2];

			if assetType == "Atlas" then
				HandleAtlasMemberCommand(assetName);
				PlaySound(SOUNDKIT.MAP_PING);
				break;
			elseif assetType == "File" then
				CopyToClipboard(assetName);
				PlaySound(SOUNDKIT.UI_BONUS_LOOT_ROLL_END); -- find sound
			end
		end
	end
end

function TextureInfoGeneratorMixin:SetCurrentTextureAssets(assets)
	self.textureAssets = assets;
end

function TextureInfoGeneratorMixin:GetCurrentTextureAssets(assets)
	return self.textureAssets;
end

function TextureInfoGeneratorMixin:SetCheckIsMouseOverRegion(check)
	self.checkIsMouseOverRegion = check;
end

function TextureInfoGeneratorMixin:ShouldCheckIsMouseOverRegion()
	if self.checkIsMouseOverRegion == nil then
		-- default this, legacy behavior for FrameStack
		return true;
	end

	-- If it's set then prefer the explicit value
	return self.checkIsMouseOverRegion;
end

function TextureInfoGeneratorMixin:ShouldGenerateRegionInfo(region)
	return CanAccessObject(region) and (not self:ShouldCheckIsMouseOverRegion() or region:IsMouseOver());
end
