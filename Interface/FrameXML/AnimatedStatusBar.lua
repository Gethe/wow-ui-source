AnimatedStatusBarMixin = {};

local DEFAULT_ACCUMULATION_TIMEOUT_SEC = .1;

function AnimatedStatusBarMixin:OnLoad()
	if self:GetStatusBarTexture() then
		self:GetStatusBarTexture():SetDrawLayer("BORDER");
	end
	self.OnFinishedCallback = function(...) self:OnAnimFinished(...); end;
	self.OnSetStatusBarAnimUpdateCallback = function(...) self:OnSetStatusBarAnimUpdate(...); end;
	self.accumulationTimeoutInterval = DEFAULT_ACCUMULATION_TIMEOUT_SEC;
	self.matchLevelOnFirstWrap = true;
	self.matchBarValueToAnimation = false;

	self:Reset();
end

function AnimatedStatusBarMixin:Reset()
	self.pendingReset = true;
end

function AnimatedStatusBarMixin:SetMatchLevelOnFirstWrap(matchLevelOnFirstWrap)
	self.matchLevelOnFirstWrap = matchLevelOnFirstWrap;
end

function AnimatedStatusBarMixin:GetMatchLevelOnFirstWrap()
	return self.matchLevelOnFirstWrap;
end

-- If set to false then the status bar's value will immediately pop to the end and the animation will cover it, otherwise the bar's value will smoothly animate under the leading edge
function AnimatedStatusBarMixin:SetMatchBarValueToAnimation(matchBarValueToAnimation)
	self.matchBarValueToAnimation = matchBarValueToAnimation;
end

function AnimatedStatusBarMixin:GetMatchBarValueToAnimation()
	return self.matchBarValueToAnimation;
end

function AnimatedStatusBarMixin:SetOnAnimatedValueChangedCallback(animatedValueChangedCallback)
	self.animatedValueChangedCallback = animatedValueChangedCallback;
end

function AnimatedStatusBarMixin:SetDeferAnimationCallback(deferAnimationCallback)
	self.DeferAnimation = deferAnimationCallback;
end

function AnimatedStatusBarMixin:GetOnAnimatedValueChangedCallback()
	return self.animatedValueChangedCallback;
end

local function SetAnimatedTextureColorsHelper(self, r, g, b)
	if self.ColorableTextures then
		for i, texture in ipairs(self.ColorableTextures) do
			texture:SetVertexColor(r, g, b);
		end
	end
end

function AnimatedStatusBarMixin:SetAnimatedTextureColors(r, g, b)
	self.animatedTextureColors = { r, g, b };
	SetAnimatedTextureColorsHelper(self, r, g, b);
end

-- Instead of using SetMinMaxValues or SetValue use this method instead
-- Optionally specify level for wrappable status bars like for XP or rep,
--	this will allow the animation to correctly reach the end of the bar and wrap back around
function AnimatedStatusBarMixin:SetAnimatedValues(value, min, max, level)
	if self.pendingValue ~= value then
		self.pendingValue = value;
		self:MarkDirty();
	end
	if self.pendingMin ~= min or self.pendingMax ~= max then
		self.pendingMin = min;
		self.pendingMax = max;
		self:MarkDirty();
	end
	if level and self.level ~= level then
		self.pendingLevel = level;
		self:MarkDirty();
	end
end

function AnimatedStatusBarMixin:MarkDirty(instant)
	self.accumulationTimeout = instant and 0 or self.accumulationTimeoutInterval;
end

function AnimatedStatusBarMixin:GetTargetValue()
	if self.pendingValue then
		return self.pendingValue;
	end
	return self.targetValue or self:GetValue();
end

-- Discrete value
function AnimatedStatusBarMixin:GetAnimatedValue()
	return self.animatedValue or self:GetValue();
end

function AnimatedStatusBarMixin:GetContinuousAnimatedValue()
	return self.continuousAnimatedValue or self:GetValue();
end

function AnimatedStatusBarMixin:OnUpdate(elapsed)
	if not self:IsAnimating() and self.accumulationTimeout and (not self.DeferAnimation or not self.DeferAnimation()) then
		if self.pendingReset then
			self:ProcessChangesInstantly();
			self.accumulationTimeout = nil;
		elseif self.accumulationTimeout <= elapsed then
			self:ProcessChanges();
			self.accumulationTimeout = nil;
		else
			self.accumulationTimeout = self.accumulationTimeout - elapsed;
		end
	end
end

function AnimatedStatusBarMixin:IsAnimating()
	return self.Anim:IsPlaying();
end

function AnimatedStatusBarMixin:ProcessChangesInstantly()
	self.pendingReset = false;
	if self.pendingMin or self.pendingMax then
		self:SetMinMaxValues(self.pendingMin, self.pendingMax);
		self.pendingMin = nil;
		self.pendingMax = nil;
	end
	if self.pendingLevel then
		self.level = self.pendingLevel;
		self.pendingLevel = nil;
	end
	if self.pendingValue then
		self:SetValue(self.pendingValue);
		self.pendingValue = nil;
		self:OnValueChanged();
	end
end

local function GetPercentageBetween(min, max, value)
	if max == min then
		return 0;
	end
	return (value - min) / (max - min);
end

function AnimatedStatusBarMixin:ProcessChanges()
	local levelIsIncreasing = false;
	if self.pendingLevel then
		if not self.level then
			-- Assume that it was already on the pending level, do nothing special
			self.level = self.pendingLevel;
			self.pendingLevel = nil;
		elseif self.pendingLevel > self.level then
			-- Going up some levels
			levelIsIncreasing = true;
		elseif self.pendingLevel == self.level then
			-- Same level now, start from nothing
			self.pendingLevel = nil;
		else
			-- Unleveling, just instantly reset everything
			return self:ProcessChangesInstantly();
		end
	end
	if not levelIsIncreasing and (self.pendingMin or self.pendingMax) then
		local min, max = self:GetMinMaxValues();
		local oldRange = max - min;
		local newRange = self.pendingMax - self.pendingMin;
		if oldRange ~= 0 and newRange ~= 0 and oldRange ~= newRange then
			local ratio = oldRange / newRange;
			local currentValue = self:GetValue();
			self:SetMinMaxValues(self.pendingMin, self.pendingMax);
			self:SetValue(currentValue * ratio);
			self.animatedValue = nil;
			self.continuousAnimatedValue = nil;
			self:OnValueChanged();
		else
			self:SetMinMaxValues(self.pendingMin, self.pendingMax);
		end
		self.pendingMin = nil;
		self.pendingMax = nil;
	end

	local min, max = self:GetMinMaxValues();

	local newValue;
	if levelIsIncreasing then
		newValue = max;
	elseif self.pendingValue then
		newValue = self.pendingValue;
		self.pendingValue = nil;
	else
		return;
	end

	local oldValue = self:GetValue();
	if not levelIsIncreasing and oldValue == newValue then return; end
	
	if newValue > max then
		newValue = max;
	end

	local oldValueAsPercent = GetPercentageBetween(min, max, oldValue);
	local deltaAsPercent = GetPercentageBetween(min, max, newValue) - oldValueAsPercent;

	self.animatedValue = nil;
	self.continuousAnimatedValue = nil;

	-- No backward animations
	if deltaAsPercent < 0 then
		self:SetValue(newValue);
		self:OnValueChanged();
		return;
	end

	self.startValue = oldValue;
	self.targetValue = newValue;
	self.levelIsIncreasing = levelIsIncreasing;

	if deltaAsPercent == 0 then
		self:OnAnimFinished();
	else
		self:SetupAnimationGroupForValueChange(self.Anim, oldValueAsPercent, deltaAsPercent);
		self:StartTilingAnimation(oldValueAsPercent, deltaAsPercent);
	end
end

local function SetupAnimationGroupForValueChangeHelper(self, startingPercent, percentChange, ...)
	for i = 1, select("#", ...) do
		self:SetupAnimationForValueChange(select(i, ...), startingPercent, percentChange);
	end
end

function AnimatedStatusBarMixin:SetupAnimationGroupForValueChange(animationGroup, startingPercent, percentChange)
	SetupAnimationGroupForValueChangeHelper(self, startingPercent, percentChange, animationGroup:GetAnimations());

	animationGroup:SetScript("OnFinished", self.OnFinishedCallback);

	animationGroup:Play();
end

function AnimatedStatusBarMixin:SetupAnimationForValueChange(anim, startingPercent, percentChange)
	local objectType = anim:GetObjectType();

	if anim.adjustAnchors then
		for i = 1, anim:GetTarget():GetNumPoints() do
			local point, relativeTo, relativePoint, offsetX, offsetY = anim:GetTarget():GetPoint(i);
			anim:GetTarget():SetPoint(point, relativeTo, relativePoint, startingPercent * self:GetWidth(), offsetY);
		end
	end

	if anim.durationPerDistance then
		anim:SetDuration(self:GetWidth() * percentChange * anim.durationPerDistance);
	end

	if anim.delayPerDistance then
		anim:SetStartDelay(self:GetWidth() * percentChange * anim.delayPerDistance);
	end

	if objectType == "Translation" then
		if anim.adjustOffsetX then
			anim:SetOffset(percentChange * self:GetWidth(), 0);
		end
	elseif objectType == "Scale" then
		if anim.adjustScaleTo then
			anim:SetToScale(percentChange * self:GetWidth() * (anim.scaleFactor or 1), 1);
		end
	end

	if anim.setStatusBarOnUpdate then
		anim:SetScript("OnUpdate", self.OnSetStatusBarAnimUpdateCallback);
	end
end

function AnimatedStatusBarMixin:OnSetStatusBarAnimUpdate(anim, elapsed)
	self.continuousAnimatedValue = self.startValue + (self.targetValue - self.startValue) * anim:GetProgress();
	self.animatedValue = math.floor(self.continuousAnimatedValue);

	if self:GetMatchBarValueToAnimation() then
		self:SetValue(self.animatedValue);
	else
		self:SetValue(self.targetValue);
	end
	self:OnValueChanged();
end

function AnimatedStatusBarMixin:OnValueChanged()
	if self.animatedValueChangedCallback then
		self.animatedValueChangedCallback(self, self:GetAnimatedValue());
	end
end

function AnimatedStatusBarMixin:OnAnimFinished()
	if self.levelIsIncreasing then
		if self.matchLevelOnFirstWrap then
			self.level = self.pendingLevel;
		else
			self.level = self.level + 1;
		end
		self:SetValue(0);
		self:MarkDirty(true);
		self:OnValueChanged();
	else
		self:SetValue(self.targetValue);
		self:OnValueChanged();
	end	

	self.levelIsIncreasing = nil;
	self.targetValue = nil;
	self.animatedValue = nil;
	self.continuousAnimatedValue = nil;
	self.startValue = nil;
end

function AnimatedStatusBarMixin:AcquireTileTemplate()
	self.numUsedTileTemplates = (self.numUsedTileTemplates or 0) + 1;
	if not self.tileTemplates then
		self.tileTemplates = {};
	end
	if not self.tileTemplates[self.numUsedTileTemplates] then
		self.tileTemplates[self.numUsedTileTemplates] = CreateFrame("FRAME", nil, self:GetParent(), self.tileTemplate);
	end

	if self.animatedTextureColors then
		SetAnimatedTextureColorsHelper(self.tileTemplates[self.numUsedTileTemplates], unpack(self.animatedTextureColors));
	end
	return self.numUsedTileTemplates, self.tileTemplates[self.numUsedTileTemplates];
end

function AnimatedStatusBarMixin:ReleaseAllTileTemplate()
	if self.tileTemplates then
		for i, tileTemplate in ipairs(self.tileTemplates) do
			tileTemplate.Anim:Stop();
			tileTemplate:ClearAllPoints();
			tileTemplate:Hide();
		end
		self.numUsedTileTemplates = 0;
	end
end

local function ApplyDelayToAllAnims(delay, ...)
	for i = 1, select("#", ...) do
		local anim = select(i, ...);
		if anim:GetOrder() == 1 then
			anim:SetStartDelay(delay);
		end
	end
end

function AnimatedStatusBarMixin:StartTilingAnimation(startingPercent, percentChange)
	if self.tileTemplate and self.tileTemplateWidth and self.tileTemplateOverlap then
		self:ReleaseAllTileTemplate();

		assert(self.tileTemplateWidth > self.tileTemplateOverlap); -- Or we'd never stop tiling

		local width = self:GetWidth();
		local startingX = width * startingPercent;
		local barWidthLeft = width * percentChange;
		while barWidthLeft > self.tileTemplateOverlap do
			local tileTemplateIndex, tileTemplate = self:AcquireTileTemplate();
			tileTemplate:Show();
			tileTemplate:SetPoint("LEFT", self, "LEFT", startingX + (tileTemplateIndex - 1) * self.tileTemplateWidth + (tileTemplateIndex - 2) * -self.tileTemplateOverlap, 0);
			if self.tileTemplateDelay then
				ApplyDelayToAllAnims((tileTemplateIndex - 1) * self.tileTemplateDelay, tileTemplate.Anim:GetAnimations());
			end
			
			tileTemplate:SetWidth(math.min(self.tileTemplateWidth, math.max(barWidthLeft, self.tileTemplateWidth / 2)));
			tileTemplate.Anim:Play();

			barWidthLeft = barWidthLeft - (self.tileTemplateWidth - self.tileTemplateOverlap);
		end
	end
end