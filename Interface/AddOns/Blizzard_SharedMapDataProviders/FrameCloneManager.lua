FrameCloneManager = {};

function FrameCloneManager:Init()
	local reset = function(pool, region)
		region:Hide();
		region:ClearAllPoints();
		region:SetParent(nil);
	end

	self.framePool = CreateFramePool("Frame", GetAppropriateTopLevelParent(), nil, reset);
	self.texturePool = CreateTexturePool(GetAppropriateTopLevelParent(), nil, nil, nil, reset);
end

function FrameCloneManager:ReleaseAll()
	self.framePool:ReleaseAll();
	self.texturePool:ReleaseAll();
end

function FrameCloneManager:Release(...)
	for i = 1, select("#", ...) do
		local clone = select(i, ...);
		if clone:IsObjectType("Frame") then
			self:Release(clone:GetRegions());
			self:Release(clone:GetChildren());
			self.framePool:Release(clone);
		else
			self.texturePool:Release(clone);
		end
	end
end

function FrameCloneManager:Clone(originalFrame, parent)
	local lookup = {};
	local clone = self:CloneHierarchy(lookup, originalFrame, parent, originalFrame:GetChildren());
	self:CloneProperties(lookup);
	return clone;
end

function FrameCloneManager:CloneHierarchy(lookup, originalFrame, parent, ...)
	local clone = self:CloneSingleFrame(lookup, originalFrame, parent);

	for i = 1, select("#", ...) do
		local child = select(i, ...);
		self:CloneHierarchy(lookup, child, clone, child:GetChildren());
	end

	return clone;
end

function FrameCloneManager:CloneSingleFrame(lookup, originalFrame, parent)
	local clone = self.framePool:Acquire();
	lookup[originalFrame] = clone;

	if parent then
		clone:SetParent(parent);
	end

	self:CloneRegionHierarchy(lookup, clone, originalFrame:GetRegions());
	return clone;
end

function FrameCloneManager:CloneRegionHierarchy(lookup, cloneParent, ...)
	for i = 1, select("#", ...) do
		local originalRegion = select(i, ...);
		self:AcquireClonedRegion(lookup, originalRegion, cloneParent);
	end
end

function FrameCloneManager:AcquireClonedRegion(lookup, originalRegion, parent)
	if originalRegion and originalRegion:GetObjectType() == "Texture" then
		local clone = self.texturePool:Acquire();
		lookup[originalRegion] = clone;
		clone:SetParent(parent);
	end
end

function FrameCloneManager:CloneProperties(cloneLookup)
	for original, clone in pairs(cloneLookup) do
		if original:IsObjectType("Frame") then
			self:CloneFrameProperties(cloneLookup, original, clone);
		else
			self:CloneRegionProperties(cloneLookup, original, clone);
		end
	end
end

function FrameCloneManager:CloneCommonProperties(lookup, original, clone)
	clone:SetSize(original:GetSize());
	clone:SetScale(original:GetScale());
	clone:SetAlpha(original:GetAlpha());
	clone:SetShown(original:IsShown());
	
	-- The cloned regions must anchor to their cloned counterparts, not the originals...so map all the relative frames 
	-- to the clones
	clone:ClearAllPoints();
	for i = 1, original:GetNumPoints() do
		local point, relativeTo, relativePoint, offsetX, offsetY = original:GetPoint(i);
		clone:SetPoint(point, lookup[relativeTo] or relativeTo, relativePoint, offsetX, offsetY);
	end
end

function FrameCloneManager:CloneFrameProperties(lookup, original, clone)
	self:CloneCommonProperties(lookup, original, clone);

	clone:SetFrameLevel(original:GetFrameLevel());
	clone:SetFrameStrata(original:GetFrameStrata());
end

function FrameCloneManager:CloneRegionProperties(lookup, original, clone)
	self:CloneCommonProperties(lookup, original, clone);

	-- TODO: Support more things, this barely supports anything
	local atlas = original:GetAtlas();
	if atlas then
		clone:SetTexCoord(0, 1, 0, 1);
		clone:SetAtlas(atlas);
	else
		clone:SetTexture(original:GetTexture());
		clone:SetTexCoord(original:GetTexCoord());
	end

	-- TODO: This is a bit of a mystery... clone:SetDrawLayer(original:GetDrawLayer()); doesn't work
	local layer, sublevel = original:GetDrawLayer();
	clone:SetDrawLayer(layer, sublevel);
end

FrameCloneManager:Init();