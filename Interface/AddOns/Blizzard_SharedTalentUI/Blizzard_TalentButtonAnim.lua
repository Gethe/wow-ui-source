
-- This mixin depends on the talentFrame member value being set on the TalentDisplayMixin, as we don't initialize it here
TalentDisplayAnimationStateControllerMixin = {};

local function NodeHasNoAnims(talentButton)
	local excludeNoneAnimations = true;
	return talentButton:HasActiveAnimations(excludeNoneAnimations);
end

local function NodeIsIncreased(talentButton)
	return talentButton:HasIncreasedRanks();
end

local function NodeIsInfiniteAndEnabled(talentButton)
	local entryInfo = talentButton:GetEntryInfo();
	if not entryInfo or entryInfo.type ~= Enum.TraitNodeEntryType.SpendInfinite then
		return false;
	end

	local isEnabledInTree = not talentButton:IsLocked() and not talentButton:IsGated() and talentButton:GetVisualState() ~= TalentButtonUtil.BaseVisualState.Disabled;
	return isEnabledInTree;
end

function TalentDisplayAnimationStateControllerMixin:InitAnimations(animations)
	self.currAnimStates = {};
	self.currAnimsForAnimStates = {};
	self.animStateActiveConditions = {};

	self:SetAnimationConditionCheck(TalentButtonAnimUtil.TalentButtonAnimState.None, NodeHasNoAnims);
	self:SetAnimationConditionCheck(TalentButtonAnimUtil.TalentButtonAnimState.Increased, NodeIsIncreased);
	self:SetAnimationConditionCheck(TalentButtonAnimUtil.TalentButtonAnimState.Infinite, NodeIsInfiniteAndEnabled);
end

function TalentDisplayAnimationStateControllerMixin:AddAnimations(animations)
	for _i, animPair in pairs(animations) do
		local animState = animPair[1];
		local animTemplate = animPair[2];

		local currAnimsForState = GetOrCreateTableEntry(self.currAnimsForAnimStates, animState);
		if not currAnimsForState[animTemplate] then
			local anim = self.talentFrame:AcquireAnimation(animState, animTemplate, self);
			self:AddAnimation(animState, anim);
		end
	end
end

function TalentDisplayAnimationStateControllerMixin:UpdateAnimations()
	local animsInitialized = false;
	for _i, animState in ipairs(self.currAnimStates) do
		local animStateActive = self:AnimStateActive(animState);

		if not animsInitialized and animStateActive then
			local animTemplatesByState = self.talentFrame:GetButtonAnimationStates();
			if animTemplatesByState then
				self:AddAnimations(animTemplatesByState);
			end

			animsInitialized = true;
		end

		local animsForAnimState = self.currAnimsForAnimStates[animState];
		if animsForAnimState then
			for animTemplate, anim in pairs(animsForAnimState) do
				if animStateActive then
					anim:Play();
					anim:UpdateFrameLevel();
				else
					anim:Stop();
					local fromRelease = false;
					self:RemoveAnimation(animState, anim, fromRelease);
				end
			end
		end
	end
end

function TalentDisplayAnimationStateControllerMixin:HasActiveAnimations(excludeNoneAnimations)
	for _i, animState in ipairs(self.currAnimStates) do
		if not excludeNoneAnimations or animState ~= TalentButtonAnimUtil.TalentButtonAnimState.None then
			local animsForAnimState = self.currAnimsForAnimStates[animState];
			if animsForAnimState then
				for _animTemplate, anim in pairs(animsForAnimState) do
					if anim:IsPlaying() then
						return true;
					end
				end
			end
		end
	end

	return false;
end

function TalentDisplayAnimationStateControllerMixin:AnimStateActive(animState)
	local animStateEvalFunc = self.animStateActiveConditions[animState];
	if animStateEvalFunc then
		return animStateEvalFunc(self);
	end

	return false;
end

function TalentDisplayAnimationStateControllerMixin:AddAnimation(animState, anim)
	local currAnimsForState = GetOrCreateTableEntry(self.currAnimsForAnimStates, animState);

	if currAnimsForState[anim.template] then
		return;
	end

	currAnimsForState[anim.template] = anim;
end

function TalentDisplayAnimationStateControllerMixin:RemoveAnimation(animState, anim, fromRelease)
	local currAnimsForAnimStates = self.currAnimsForAnimStates[animState];
	if not currAnimsForAnimStates then
		return;
	end

	for animTemplate, currAnim in pairs(currAnimsForAnimStates) do
		if currAnim == anim then
			if not fromRelease then
				self.talentFrame:ReleaseAnimation(animTemplate, currAnim);
			end

			currAnimsForAnimStates[animTemplate] = nil;
			break;
		end
	end

	if TableIsEmpty(currAnimsForAnimStates) then
		self.currAnimsForAnimStates[animState] = nil;
	end
end

function TalentDisplayAnimationStateControllerMixin:SetAnimationConditionCheck(animState, conditionFunc)
	table.insert(self.currAnimStates, animState);
	self.animStateActiveConditions[animState] = conditionFunc;
end

TalentDisplayAnimationMixin = {};

function TalentDisplayAnimationMixin:Init(parent, template, animState)
	self.template = template;
	self.animState = animState;
	self:SetParent(parent);
	self:SetPoint(self.anchorPoint, parent, self.relativePoint, self.xOffset, self.yOffset);
end

function TalentDisplayAnimationMixin:Play()
	self:Show();

	if self.Anim and not self.Anim:IsPlaying() then
		self.Anim:Play();
	end
end

function TalentDisplayAnimationMixin:IsPlaying()
	return self.Anim:IsPlaying();
end

function TalentDisplayAnimationMixin:Stop()
	self:Hide();

	if self.Anim and self.Anim:IsPlaying() then
		self.Anim:Stop();
	end
end

function TalentDisplayAnimationMixin:SetFrameLevelCallback(getFrameLevelCallback)
	self.getFrameLevelCallback = getFrameLevelCallback;
end

function TalentDisplayAnimationMixin:UpdateFrameLevel()
	self:SetFrameLevel(self:GetAnimFrameLevel());
end

function TalentDisplayAnimationMixin:GetAnimFrameLevel()
	if self.getFrameLevelCallback then
		return self.getFrameLevelCallback(self);
	end

	local parent = self:GetParent();
	if not parent then
		return 1;
	end

	-- By Default, make the animation appear below the parent
	return parent:GetFrameLevel() - 25;
end

function TalentDisplayAnimationMixin:ResetAnim()
	local parent = self:GetParent();
	local fromRelease = true;

	if parent then
		-- if this animation is released early, we want to make sure that the parent effectively removes the reference
		parent:RemoveAnimation(self.animState, self, fromRelease);
	end

	self:Hide();
	self:ClearAllPoints();
	self.template = nil;
end
