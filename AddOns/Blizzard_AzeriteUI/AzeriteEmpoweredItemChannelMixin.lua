AzeriteEmpoweredItemChannelMixin = {};

local REVEAL_SIZE_BY_TIER = {
	[3] = {
		278,
		368,
		591,
	},

	[4] = {
		188,
		278,
		368,
		591,
	},
	
	[5] = {
		96,
		188,
		278,
		368,
		591,
	},	
}

function AzeriteEmpoweredItemChannelMixin:Reset()
	self.tierIndex = nil;
	self.isTierAnimating = nil;
	self.targetHeight = nil;
	self.snapValue = true;
	self.RevealMask:SetHeight(-1);
end

function AzeriteEmpoweredItemChannelMixin:AdjustSizeForTiers(numTiers)
	self.revealSizes = REVEAL_SIZE_BY_TIER[numTiers];
	assert(self.revealSizes);
end

function AzeriteEmpoweredItemChannelMixin:SetUnlockedTier(tierIndex)
	if not tierIndex or self.tierIndex ~= tierIndex then
		self.tierIndex = tierIndex;
		if self.snapValue then
			self.snapValue = false;
			self.RevealMask:SetHeight(self:GetHeightForTierIndex(tierIndex));
		elseif not self.isTierAnimating then
			self.targetHeight = self:GetHeightForTierIndex(self.tierIndex);
		end
	end
end

function AzeriteEmpoweredItemChannelMixin:GetHeightForTierIndex(tierIndex)
	return self.revealSizes[tierIndex] or -1;
end

function AzeriteEmpoweredItemChannelMixin:UpdateTierAnimationProgress(tierIndex, progress)
	if not self.tierIndex or tierIndex ~= self.tierIndex then
		return;
	end

	if progress and progress < 1.0 then
		self.isTierAnimating = true;

		local fromHeight = self:GetHeightForTierIndex(self.tierIndex - 1);
		local toHeight = self:GetHeightForTierIndex(self.tierIndex);

		self.targetHeight = Lerp(fromHeight, toHeight, EasingUtil.InCubic(progress));
	else
		self.targetHeight = self:GetHeightForTierIndex(self.tierIndex);
		self.isTierAnimating = false;
	end
end

function AzeriteEmpoweredItemChannelMixin:UpdateTowardsTargetHeight(elapsed)
	if self.targetHeight then
		local newHeight = DeltaLerp(self.RevealMask:GetHeight(), self.targetHeight, .1, elapsed);
		
		if math.abs(newHeight - self.targetHeight) < .1 then
			self.RevealMask:SetHeight(self.targetHeight);
			self.targetHeight = nil;
		else
			self.RevealMask:SetHeight(newHeight);
		end
	end
end

function AzeriteEmpoweredItemChannelMixin:OnUpdate(elapsed)
	self:UpdateTowardsTargetHeight(elapsed);
	
	self.wispyOffsetY = (self.wispyOffsetY or 0) - elapsed * 0.15;
	self.Wispy1:SetTexCoord(0, 1, 0 + self.wispyOffsetY, 3 + self.wispyOffsetY);
	self.Wispy2:SetTexCoord(.5, 1.5, 0 - self.wispyOffsetY, 3 - self.wispyOffsetY);

	self.sparklesOffsetX = (self.sparklesOffsetX or 0) - elapsed * 0.05;
	self.sparklesOffsetY = (self.sparklesOffsetY or 0) - elapsed * 0.05;

	self.Sparkles1:SetTexCoord(0 + self.sparklesOffsetX, 1 + self.sparklesOffsetX, 0 + self.sparklesOffsetY, 1 + self.sparklesOffsetY);
	self.Sparkles2:SetTexCoord(0 - self.sparklesOffsetX, 1 - self.sparklesOffsetX, 0.5 - self.sparklesOffsetY, 1.5 - self.sparklesOffsetY);

	self.goldOffsetY = (self.goldOffsetY or 0) - elapsed * 0.025;

	self.Gold:SetTexCoord(0, 1, 0 + self.goldOffsetY, 1 + self.goldOffsetY);
end