-- *****************************************************************************************************
-- ***** ANIM LINE
-- *****************************************************************************************************

ObjectiveTrackerAnimLineState = EnumUtil.MakeEnum(
	"Adding",
	"Present",
	"Completing",
	"Completed", 
	"Fading",
	"Faded"
);

ObjectiveTrackerAnimLineMixin = CreateFromMixins(ObjectiveTrackerLineMixin);

function ObjectiveTrackerAnimLineMixin:OnGlowAnimFinished()
	if self.state == ObjectiveTrackerAnimLineState.Completing then
		self.state = ObjectiveTrackerAnimLineState.Completed;
		self:UpdateModule();
	elseif self.state == ObjectiveTrackerAnimLineState.Adding then
		self.state = ObjectiveTrackerAnimLineState.Present;
	end
end

function ObjectiveTrackerAnimLineMixin:OnFadeOutAnimFinished()
	self.state = ObjectiveTrackerAnimLineState.Faded;
	local needsUpdate = true;
	local block = self.parentBlock;
	block:ForEachUsedLine(function(line, objectiveKey)
		if line.state == ObjectiveTrackerAnimLineState.Fading then
			-- some other line is still fading
			needsUpdate = false;
			return true;
		end
	end);

	if needsUpdate then
		self:UpdateModule();
	end
end

function ObjectiveTrackerAnimLineMixin:SetState(desiredState)
	-- lines don't often use anims, don't set up OnFinished until needed
	if not self.animsInit then
		self.animsInit = true;
		self.FadeOutAnim:SetScript("OnFinished", GenerateClosure(self.OnFadeOutAnimFinished, self));
		self.GlowAnim:SetScript("OnFinished", GenerateClosure(self.OnGlowAnimFinished, self));
	end

	if desiredState == ObjectiveTrackerAnimLineState.Present then
		self.Icon:Hide();
	elseif desiredState == ObjectiveTrackerAnimLineState.Completed then
		if not self.noIcon then
			self.Icon:Show();
		end
	elseif desiredState == ObjectiveTrackerAnimLineState.Completing then
		if not self.noIcon then
			self.Icon:Show();
			self.CheckAnim:Play();
		end
		self.GlowAnim:Play();
	elseif desiredState == ObjectiveTrackerAnimLineState.Adding then
		self.GlowAnim:Play();
	elseif desiredState == ObjectiveTrackerAnimLineState.Fading then
		self.FadeOutAnim:Play();
	else
		self.Icon:Hide();
	end
	self.state = desiredState;
end

function ObjectiveTrackerAnimLineMixin:SetNoIcon(noIcon)
	self.noIcon = noIcon;
	self.Icon:Hide();
end

function ObjectiveTrackerAnimLineMixin:OnFree(block)
	if self.state then
		self.state = nil;
		self.noIcon = nil;
		self.Glow:SetAlpha(0);
		self.CheckGlow:SetAlpha(0);
		self.GlowAnim:Stop();
		self.CheckAnim:Stop();
		self.FadeOutAnim:Stop();
		self.FadeInAnim:Stop();
	end
	self.Icon:Hide();
end

-- *****************************************************************************************************
-- ***** ANIM BLOCK
-- *****************************************************************************************************

ObjectiveTrackerAnimBlockMixin = CreateFromMixins(ObjectiveTrackerBlockMixin);

function ObjectiveTrackerAnimBlockMixin:OnLayout()
	if self.parentModule:NeedsFanfare(self.id) then
		self:TryPlayAnim(self.AddAnim);
	end
end
		
function ObjectiveTrackerAnimBlockMixin:HasActiveAnim()
	return not not self.activeAnim;
end

function ObjectiveTrackerAnimBlockMixin:OnAnimFinished()
	if self.activeAnim ~= self.AddAnim then
		if not ObjectiveTrackerManager:HasRewardsToastForBlock(self) then
			self.parentModule:RemoveBlockFromCache(self);
			self.parentModule:MarkDirty();
		end
		self:SetAlpha(0);
	end
	self.activeAnim = nil;

	if self.pendingAnim then
		local anim = self.pendingAnim;
		self.pendingAnim = nil;
		self:TryPlayAnim(anim);
	end
end

function ObjectiveTrackerAnimBlockMixin:OnAnimStopped()
	if self.activeAnim == self.AddAnim then
		if self.extraAddAnim then
			self.extraAddAnim:Stop();
		end
	elseif self.activeAnim == self.TurnInAnim then
		self.parentModule:RemoveBlockFromCache(self);
	elseif self.activeAnim == self.RemoveAnim then
		self.parentModule:RemoveBlockFromCache(self);
	end
	self.activeAnim = nil;
end

function ObjectiveTrackerAnimBlockMixin:PlayAddAnimation()
	self.activeAnim = self.AddAnim;
	if not self.AddAnim:GetScript("OnFinished") then
		self.AddAnim:SetScript("OnFinished", GenerateClosure(self.OnAnimFinished, self));
		self.AddAnim:SetScript("OnStop", GenerateClosure(self.OnAnimStopped, self));
	end
	self:ForEachUsedLine(function(line, objectiveKey)
		line.FadeInAnim:Restart();
	end);
	self.AddAnim:Play();
	if self.extraAddAnim then
		self.extraAddAnim:Play();
	end
end

function ObjectiveTrackerAnimBlockMixin:PlayTurnInAnimation()
	self.activeAnim = self.TurnInAnim;
	if not self.TurnInAnim:GetScript("OnFinished") then
		self.TurnInAnim:SetScript("OnFinished", GenerateClosure(self.OnAnimFinished, self));
		self.TurnInAnim:SetScript("OnStop", GenerateClosure(self.OnAnimStopped, self));
	end	
	self.TurnInAnim:Play();
	self.parentModule:AddBlockToCache(self);
end

function ObjectiveTrackerAnimBlockMixin:PlayRemoveAnimation()
	self.activeAnim = self.RemoveAnim;
	if not self.RemoveAnim:GetScript("OnFinished") then
		self.RemoveAnim:SetScript("OnFinished", GenerateClosure(self.OnAnimFinished, self));
		self.RemoveAnim:SetScript("OnStop", GenerateClosure(self.OnAnimStopped, self));
	end	
	self.RemoveAnim:Play();
	self.parentModule:AddBlockToCache(self);
end

-- overrides base
function ObjectiveTrackerAnimBlockMixin:Free()
	ObjectiveTrackerBlockMixin.Free(self);
	if self.activeAnim then
		self.activeAnim:Stop();
	end
	self.pendingAnim = nil;
	self:SetAlpha(1);
end

function ObjectiveTrackerAnimBlockMixin:TryPlayAnim(anim, arg)
	if self.activeAnim == anim then
		return;
	end
	
	if anim == self.AddAnim then
		if self.activeAnim then
			self.activeAnim:Stop();
		else
			self:PlayAddAnimation();
		end
	elseif anim == self.TurnInAnim then
		if self.activeAnim == self.RemoveAnim then
			-- this shouldn't happen out of order, but just in case
			self.activeAnim:Stop();
			self:PlayTurnInAnimation();
		elseif self.activeAnim then
			self.pendingAnim = anim;
			self.parentModule:AddBlockToCache(self);
		else
			self:PlayTurnInAnimation();
		end
	elseif anim == self.RemoveAnim then
		local startDelay = arg or 3.5;
		self.RemoveAnim.Alpha:SetStartDelay(startDelay);
		if self.activeAnim == self.TurnInAnim or self.pendingAnim == self.TurnInAnim then
			-- no removing if quest has been turned in
			return;
		elseif self.activeAnim then
			self.pendingAnim = anim;
			self.parentModule:AddBlockToCache(self);
		else
			self:PlayRemoveAnimation();
		end
	end
end

function ObjectiveTrackerAnimBlockMixin:SetExtraAddAnimation(anim)
	self.extraAddAnim = anim;
end