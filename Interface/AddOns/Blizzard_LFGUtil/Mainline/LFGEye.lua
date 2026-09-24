local LFG_EYE_NONE_ANIM			= "NONE";
local LFG_EYE_INIT_ANIM			= "INITIAL";
local LFG_EYE_SEARCHING_ANIM	= "SEARCHING_LOOP";
local LFG_EYE_HOVER_ANIM		= "HOVER_ANIM";
local LFG_EYE_FOUND_INIT_ANIM	= "FOUND_INIT";
local LFG_EYE_FOUND_LOOP_ANIM	= "FOUND_LOOP";
local LFG_EYE_POKE_INIT_ANIM	= "POKE_INIT";
local LFG_EYE_POKE_LOOP_ANIM	= "POKE_LOOP";
local LFG_EYE_POKE_END_ANIM		= "POKE_END";

local LFG_ANGER_INC_VAL = 30;
local LFG_ANGER_DEC_VAL = 1;
local LFG_ANGER_END_VAL = 75;
local LFG_ANGER_INIT_VAL = 60;
local LFG_ANGER_CAP_VAL = 90;

LFGEyeTemplateMixin = {};

function LFGEyeTemplateMixin:OnLoad()
	self.currActiveAnims = {};
	self.activeAnim = LFG_EYE_NONE_ANIM;
	self.isStatic = false;
	self.angerVal = 0;
end

function LFGEyeTemplateMixin:OnUpdate()
	if ( self:IsStaticMode() ) then
		self.texture:Show();
		return;
	end

	if self.hideTextureOnAnim then
		self.texture:Hide();
	end

	--Animation state machine
	if ( self:IsInitialEyeAnimFinished() or self:IsPokeEndAnimFinished()) then
		self:StartSearchingAnimation();
	elseif ( self:IsFoundInitialAnimFinished() ) then
		self:StartFoundAnimationLoop();
	elseif ( self:ShouldStartPokeInitAnim() ) then
		self:StartPokeAnimationInitial();
	elseif ( self:IsPokeInitAnimFinished() ) then
		self:StartPokeAnimationLoop();
	elseif ( self:ShouldStartPokeEndAnim() ) then
		self:StartPokeAnimationEnd();
	elseif ( self:ShouldStartHoverAnim() ) then
		self:StartHoverAnimation();
	end

	self.angerVal = self.angerVal - LFG_ANGER_DEC_VAL;
	self.angerVal = Clamp(self.angerVal, 0, LFG_ANGER_CAP_VAL);
end

function LFGEyeTemplateMixin:OnClick()
	--Angry Eye
	self.angerVal = self.angerVal + LFG_ANGER_INC_VAL;
end

function LFGEyeTemplateMixin:OnEnter()
	if ( self:IsStaticMode() ) then
		return;
	end

	if ( self.currAnim == LFG_EYE_SEARCHING_ANIM or self.currAnim == LFG_EYE_NONE_ANIM ) then
		self:StartHoverAnimation();
	end
end

function LFGEyeTemplateMixin:OnLeave()
	if ( self:IsStaticMode() ) then
		return;
	end

	if ( self.currAnim == LFG_EYE_HOVER_ANIM ) then
		self:StartSearchingAnimation();
	end
end

function LFGEyeTemplateMixin:StartInitialAnimation()
	self:StopAnimating();

	self:PlayAnim(self.EyeInitial, self.EyeInitial.EyeInitialAnim);

	self.currAnim = LFG_EYE_INIT_ANIM;
end

function LFGEyeTemplateMixin:StartSearchingAnimation()
	self:StopAnimating();

	self:PlayAnim(self.EyeSearchingLoop, self.EyeSearchingLoop.EyeSearchingLoopAnim);

	self.currAnim = LFG_EYE_SEARCHING_ANIM;
end

function LFGEyeTemplateMixin:StartHoverAnimation()
	self:StopAnimating();

	self:PlayAnim(self.EyeMouseOver, self.EyeMouseOver.EyeMouseOverAnim);

	self.currAnim = LFG_EYE_HOVER_ANIM;
end

function LFGEyeTemplateMixin:StartFoundAnimationInit()
	self:StopAnimating();

	self:PlayAnim(self.EyeFoundInitial, self.EyeFoundInitial.EyeFoundInitialAnim);

	self.currAnim = LFG_EYE_FOUND_INIT_ANIM;
end

function LFGEyeTemplateMixin:StartFoundAnimationLoop()
	self:StopAnimating();

	self:PlayAnim(self.EyeFoundLoop, self.EyeFoundLoop.EyeFoundLoopAnim);
	self:PlayAnim(self.EyeFoundLoop, self.GlowBackLoop.GlowBackLoopAnim);

	self.currAnim = LFG_EYE_FOUND_LOOP_ANIM;
end

function LFGEyeTemplateMixin:StartPokeAnimationInitial()
	self:StopAnimating();

	self:PlayAnim(self.EyePokeInitial, self.EyePokeInitial.EyePokeInitialAnim);

	self.currAnim = LFG_EYE_POKE_INIT_ANIM;
end

function LFGEyeTemplateMixin:StartPokeAnimationLoop()
	self:StopAnimating();

	self:PlayAnim(self.EyePokeLoop, self.EyePokeLoop.EyePokeLoopAnim);

	self.currAnim = LFG_EYE_POKE_LOOP_ANIM;
end

function LFGEyeTemplateMixin:StartPokeAnimationEnd()
	self:StopAnimating();

	self:PlayAnim(self.EyePokeEnd, self.EyePokeEnd.EyePokeEndAnim);

	self.currAnim = LFG_EYE_POKE_END_ANIM;
end

function LFGEyeTemplateMixin:SetStaticMode(set)
	self.isStatic = set;

	for _, currAnim in ipairs(self.currActiveAnims) do
		if (self.isStatic) then
			currAnim[1]:Hide();
			currAnim[2]:Pause();
		else
			currAnim[1]:Show();
			currAnim[2]:Play();
		end
	end
end

function LFGEyeTemplateMixin:IsStaticMode()
	return self.isStatic;
end

function LFGEyeTemplateMixin:PlayAnim(parentFrame, anim)
	parentFrame:Show();
	anim:Play();

	tinsert(self.currActiveAnims, #(self.currActiveAnims) + 1, { parentFrame, anim });
end

function LFGEyeTemplateMixin:StopAnimating()
	if self.currAnim == LFG_EYE_NONE_ANIM then
		return;
	end
	self.currAnim = LFG_EYE_NONE_ANIM;

	for _, currAnim in ipairs(self.currActiveAnims) do
		currAnim[1]:Hide();
		currAnim[2]:Stop();
	end

	self.currActiveAnims = {};
end

function LFGEyeTemplateMixin:CheckStartSearchingAnimation()
	--Gates the animation from playing from anything that isn't a static eye -> queued eye
	if ( QueueStatusButton.Eye.currAnim
	and	QueueStatusButton.Eye.currAnim ~= LFG_EYE_SEARCHING_ANIM
	and QueueStatusButton.Eye.currAnim ~= LFG_EYE_INIT_ANIM
	and QueueStatusButton.Eye.currAnim ~= LFG_EYE_HOVER_ANIM
	and QueueStatusButton.Eye.currAnim ~= LFG_EYE_NONE_ANIM ) then
		QueueStatusButton.Eye:StartSearchingAnimation();
	end
end

function LFGEyeTemplateMixin:IsInitialEyeAnimFinished()
	return self.currAnim == LFG_EYE_INIT_ANIM and not self.EyeInitial.EyeInitialAnim:IsPlaying();
end

function LFGEyeTemplateMixin:IsFoundInitialAnimFinished()
	return self.currAnim == LFG_EYE_FOUND_INIT_ANIM and not self.EyeFoundInitial.EyeFoundInitialAnim:IsPlaying();
end

function LFGEyeTemplateMixin:ShouldStartHoverAnim()
	return self.cursorOnButton and self.currAnim == LFG_EYE_SEARCHING_ANIM;
end

function LFGEyeTemplateMixin:ShouldStartPokeInitAnim()
	return self.angerVal >= LFG_ANGER_INIT_VAL and (self.currAnim == LFG_EYE_HOVER_ANIM or self.currAnim == LFG_EYE_SEARCHING_ANIM);
end

function LFGEyeTemplateMixin:IsPokeInitAnimFinished()
	return self.currAnim == LFG_EYE_POKE_INIT_ANIM and not self.EyePokeInitial.EyePokeInitialAnim:IsPlaying();
end

function LFGEyeTemplateMixin:ShouldStartPokeEndAnim()
	return self.angerVal < LFG_ANGER_END_VAL and (self.currAnim == LFG_EYE_POKE_LOOP_ANIM or self:IsPokeInitAnimFinished());
end

function LFGEyeTemplateMixin:IsPokeEndAnimFinished()
	return self.currAnim == LFG_EYE_POKE_END_ANIM and not self.EyePokeEnd.EyePokeEndAnim:IsPlaying();
end
