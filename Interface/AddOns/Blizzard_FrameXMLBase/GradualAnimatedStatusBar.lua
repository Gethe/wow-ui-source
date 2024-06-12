GradualAnimatedStatusBarMixin = {};

function GradualAnimatedStatusBarMixin:OnLoad()
	if self:GetStatusBarTexture() then
		self:GetStatusBarTexture():SetDrawLayer("BORDER");
	end

	-- Gotta set this point OnLoad since self.BarTexture isn't fully setup until now
	self.GainFlareAnimationTexture:ClearAllPoints();
	self.GainFlareAnimationTexture:SetPoint("RIGHT", self.BarTexture, "RIGHT", 1, 0);

	-- Default values so bar is initialized
	-- Otherwise bar will return 0 from GetValue even though it isn't actually showing at 0
	self:SetMinMaxValues(0, 1);
	self:SetValue(0);

	self:Reset();
end

function GradualAnimatedStatusBarMixin:Reset()
	self.pendingReset = true;
end

function GradualAnimatedStatusBarMixin:SetDeferAnimationCallback(deferAnimationCallback)
	self.DeferAnimation = deferAnimationCallback;
end

function GradualAnimatedStatusBarMixin:SetOnAnimatedValueChangedCallback(animatedValueChangedCallback)
	self.animatedValueChangedCallback = animatedValueChangedCallback;
end

function GradualAnimatedStatusBarMixin:GetOnAnimatedValueChangedCallback()
	return self.animatedValueChangedCallback;
end

-- Give frames the opportunity to override the max level alpha animation so they can fade out their entire bar should they choose to
function GradualAnimatedStatusBarMixin:SetLevelUpMaxAlphaAnimation(animation)
	self.overrideLevelUpMaxAlphaAnimation = animation;
end

function GradualAnimatedStatusBarMixin:SetBarTexture(barTexture, deferUntilNextLevel)
	if deferUntilNextLevel then
		self.pendingBarTexture = barTexture;
	else
		self:SetStatusBarTexture(barTexture);
	end
end

function GradualAnimatedStatusBarMixin:SetAnimationTextures(gainFlareAtlas, levelUpAtlas, deferUntilNextLevel)
	if deferUntilNextLevel then
		self.pendingGainFlareAnimationTexture = gainFlareAtlas;
		self.pendingLevelUpTexture = levelUpAtlas;
	else
		self.GainFlareAnimationTexture:SetAtlas(gainFlareAtlas);
		self.LevelUpTexture:SetAtlas(levelUpAtlas);
	end
end

function GradualAnimatedStatusBarMixin:OnValueChanged()
	if self.animatedValueChangedCallback then
		self.animatedValueChangedCallback(self, self:GetAnimatedValue());
	end
end

-- Instead of using SetMinMaxValues or SetValue use this method instead
-- Optionally specify level for wrappable status bars like for XP or rep,
--	this will allow the animation to correctly reach the end of the bar and wrap back around
function GradualAnimatedStatusBarMixin:SetAnimatedValues(value, min, max, level, maxLevel)
	local areValuesCurrentlyChanging = self:IsDirty() or self:IsAnimating();

	-- Check if current value changed
	if (areValuesCurrentlyChanging or self:GetValue() ~= value) and self.pendingValue ~= value then
		self.pendingValue = value;
		self:MarkDirty();
	end

	-- Check if min or max changed
	local currentMin, currentMax = self:GetMinMaxValues();
	local shouldUpdateMin = (areValuesCurrentlyChanging or currentMin ~= min) and self.pendingMin ~= min;
	local shouldUpdateMax = (areValuesCurrentlyChanging or currentMax ~= max) and self.pendingMax ~= max;
	if shouldUpdateMin or shouldUpdateMax then
		self.pendingMin = min;
		self.pendingMax = max;
		self:MarkDirty();
	end

	-- Check if level changed
	if level and self.level ~= level then
		self.pendingLevel = level;
		self:MarkDirty();
	end
	self.maxLevel = maxLevel;

	if not self:IsVisible() then
		self:ProcessChangesInstantly();
	end
end

function GradualAnimatedStatusBarMixin:SubscribeToOnClean(subscribingFrame, onCleanCallback)
	if not self.onCleanCallbacks then
		self.onCleanCallbacks = {};
	end

	self.onCleanCallbacks[subscribingFrame] = onCleanCallback;
end

function GradualAnimatedStatusBarMixin:UnsubscribeFromOnClean(subscribingFrame)
	if not self.onCleanCallbacks then
		return;
	end

	self.onCleanCallbacks[subscribingFrame] = nil;
end

function GradualAnimatedStatusBarMixin:IsDirty()
	return self.isDirty;
end

function GradualAnimatedStatusBarMixin:MarkDirty(instant)
	self.isDirty = true;
	self.accumulationTimeout = instant and 0 or self.accumulationTimeoutInterval;
end

function GradualAnimatedStatusBarMixin:ClearDirty()
	self.isDirty = false;
	self.accumulationTimeout = nil;

	if self.onCleanCallbacks then
		for i, callback in pairs(self.onCleanCallbacks) do
			callback(self);
		end
	end
end

function GradualAnimatedStatusBarMixin:GetTargetValue()
	if self.pendingValue then
		return self.pendingValue;
	end
	return self.targetValue or self:GetValue();
end

function GradualAnimatedStatusBarMixin:GetAnimatedValue()
	return self.animatedValue or self:GetValue();
end

function GradualAnimatedStatusBarMixin:OnUpdate(elapsed)
	self:OnUpdateGainAnimation();

	if not self:IsAnimating() and self:IsDirty() and (not self.DeferAnimation or not self.DeferAnimation()) then
		if self.pendingReset then
			self:ProcessChangesInstantly();
		elseif self.accumulationTimeout <= elapsed then
			self:ProcessChanges();
		else
			self.accumulationTimeout = self.accumulationTimeout - elapsed;
		end
	end
end

function GradualAnimatedStatusBarMixin:SetIsMaxLevelFunctionOverride(overrideFunction)
	self.overrideIsAtMaxLevel = overrideFunction;
end

function GradualAnimatedStatusBarMixin:IsAtMaxLevel()
	if self.overrideIsAtMaxLevel then
		return self.overrideIsAtMaxLevel();
	end

	return self.maxLevel and self.level and self.level >= self.maxLevel;
end

function GradualAnimatedStatusBarMixin:IsAnimating()
	return self.targetValue and self:GetValue() < self.targetValue
		or self.gainFinishedAnimation and self.gainFinishedAnimation:IsPlaying()
		or self.LevelUpMaxAlphaAnimation:IsPlaying()
		or self.overrideLevelUpMaxAlphaAnimation and self.overrideLevelUpMaxAlphaAnimation:IsPlaying();
end

function GradualAnimatedStatusBarMixin:SubscribeToOnFinishedAnimating(subscribingFrame, onFinishedCallback)
	if not self.animationFinishedCallbacks then
		self.animationFinishedCallbacks = {};
	end

	self.animationFinishedCallbacks[subscribingFrame] = onFinishedCallback;
end

function GradualAnimatedStatusBarMixin:UnsubscribeFromOnFinishedAnimating(subscribingFrame)
	if not self.animationFinishedCallbacks then
		return;
	end

	self.animationFinishedCallbacks[subscribingFrame] = nil;
end

function GradualAnimatedStatusBarMixin:OnFinishedAnimating()
	if self.animationFinishedCallbacks then
		for i, callback in pairs(self.animationFinishedCallbacks) do
			callback(self);
		end
	end
end

function GradualAnimatedStatusBarMixin:ProcessChangesInstantly()
	self:ClearDirty();

	-- Stop all animations
	self:ClearGainAnimationValues();
	self:FinishAnimationInstantly(self.GainFlareAnimation);
	self:FinishAnimationInstantly(self.LevelUpRolloverAnimation);
	self:FinishAnimationInstantly(self.LevelUpMaxAnimation);
	self:FinishAnimationInstantly(self.overrideLevelUpMaxAlphaAnimation);

	-- Instantly assign all pending values
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

	self:ApplyPendingTextures();

	if self.pendingValue then
		self:SetValue(self.pendingValue);
		self.pendingValue = nil;
		self:OnValueChanged();
	end
end

function GradualAnimatedStatusBarMixin:ApplyPendingTextures()
	if self.pendingBarTexture then
		self:SetBarTexture(self.pendingBarTexture);
		self.pendingBarTexture = nil;
	end

	if self.pendingGainFlareAnimationTexture or self.pendingLevelUpTexture then
		self:SetAnimationTextures(self.pendingGainFlareAnimationTexture, self.pendingLevelUpTexture);
		self.pendingGainFlareAnimationTexture = nil;
		self.pendingLevelUpTexture = nil;
	end
end

local function GetPercentageBetween(min, max, value)
	if max == min then
		return 0;
	end
	return (value - min) / (max - min);
end

function GradualAnimatedStatusBarMixin:ProcessChanges()
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
			self:ProcessChangesInstantly();
			return;
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
		self:OnFinishedAnimating();
		self:ClearDirty();
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

	-- No backward animations
	if deltaAsPercent < 0 then
		self:SetValue(newValue);
		self:OnValueChanged();
		self:OnFinishedAnimating();
		self:ClearDirty();
		return;
	end

	self.startValue = oldValue;
	self.targetValue = newValue;
	self.levelIsIncreasing = levelIsIncreasing;
	self.gainAnimationStartTime = GetTime();
	self.gainAnimationDuration = self:GetWidth() * deltaAsPercent * self.gainAnimationDurationPerDistance;
	self:ClearDirty();
end

function GradualAnimatedStatusBarMixin:FinishAnimationInstantly(animation)
	if animation and animation:IsPlaying() then
		-- Set animation to be at it's end so it finishes instantly and calls it's OnFinished and such
		local isReverseNo = false;
		animation:Restart(isReverseNo, animation:GetDuration());
	end
end

function GradualAnimatedStatusBarMixin:ClearGainAnimationValues()
	self.gainAnimationStartTime = nil;
	self.gainAnimationDuration = nil;
	self.levelIsIncreasing = nil;
	self.targetValue = nil;
	self.animatedValue = nil;
	self.continuousAnimatedValue = nil;
	self.startValue = nil;
end

function GradualAnimatedStatusBarMixin:OnUpdateGainAnimation()
	if not self.targetValue then
		return;
	end

	if self:GetValue() >= self.targetValue then
		self:OnGainAnimationFinished();
		return;
	end

	local elapsedAnimationTime = GetTime() - self.gainAnimationStartTime;
	local animationProgress = math.min(elapsedAnimationTime / self.gainAnimationDuration, 1);
	self.animatedValue = self.startValue + (self.targetValue - self.startValue) * animationProgress;
	self.animatedValue = math.floor(self.animatedValue);
	self.animatedValue = math.min(self.targetValue, self.animatedValue);
	self:SetValue(self.animatedValue);
	self:OnValueChanged();
end

function GradualAnimatedStatusBarMixin:OnGainAnimationFinished()
	if self.levelIsIncreasing then
		self.level = self.pendingLevel;
		self:SetValue(self:IsAtMaxLevel() and self.targetValue or 0);
		self:MarkDirty(true);
		self:OnValueChanged();
	else
		self:SetValue(self.targetValue);
		self:OnValueChanged();
	end

	-- Play the gain complete animation
	if self.levelIsIncreasing then
		if self:IsAtMaxLevel() then
			self.gainFinishedAnimation = self.LevelUpMaxAnimation;
		else
			self.gainFinishedAnimation = self.LevelUpRolloverAnimation;
		end
	else
		local _, maxValue = self:GetMinMaxValues();
		if self:GetValue() >= maxValue then
			self.gainFinishedAnimation = self.LevelUpMaxAnimation;
		else
			self.gainFinishedAnimation = self.GainFlareAnimation;
		end
	end
	self.gainFinishedAnimation:Restart();

	-- Reset values
	self:ClearGainAnimationValues();
end

GainFlareAnimationMixin = {};

function GainFlareAnimationMixin:OnPlay()
	self:GetParent().GainFlareAnimationTexture:Show();
end

function GainFlareAnimationMixin:OnFinished()
	local parent = self:GetParent();
	parent.GainFlareAnimationTexture:Hide();
	parent:OnFinishedAnimating();
end

LevelUpRolloverAnimationMixin = {};

function LevelUpRolloverAnimationMixin:OnPlay()
	self:GetParent().LevelUpTexture:Show();
end

function LevelUpRolloverAnimationMixin:OnFinished()
	local parent = self:GetParent();
	parent.LevelUpTexture:Hide();
	parent:ApplyPendingTextures();
	parent:OnFinishedAnimating();
end

LevelUpMaxAnimationMixin = {};

function LevelUpMaxAnimationMixin:OnPlay()
	local parent = self:GetParent();
	parent.LevelUpTexture:Show();

	local alphaAnimation = parent.overrideLevelUpMaxAlphaAnimation or parent.LevelUpMaxAlphaAnimation;
	alphaAnimation:Restart();
end

function LevelUpMaxAnimationMixin:OnFinished()
	local parent = self:GetParent();
	parent.LevelUpTexture:Hide();
	parent:ApplyPendingTextures();
	parent:OnFinishedAnimating();
end