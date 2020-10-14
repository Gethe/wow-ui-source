CommentatorModelSceneMixin = {}

local CommentatorModelSceneEvents =
{
	"COMBAT_LOG_EVENT_UNFILTERED",
};

local MODEL_SCENE_OFFENSIVE_EFFECT_AURA = 36;
local MODEL_SCENE_DEFENSIVE_EFFECT_AURA = 37;

function CommentatorModelSceneMixin:OnLoad()
	ScriptAnimatedModelSceneMixin.OnLoad(self);
	self.effectController = {};
end

function CommentatorModelSceneMixin:OnShow()
	ScriptAnimatedModelSceneMixin.OnShow(self);
	FrameUtil.RegisterFrameForEvents(self, CommentatorModelSceneEvents);
end

function CommentatorModelSceneMixin:OnHide()
	ScriptAnimatedModelSceneMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents(self, CommentatorModelSceneEvents);
	
end

function CommentatorModelSceneMixin:OnEvent(event, ...)
	ScriptAnimatedModelSceneMixin.OnEvent(self, event, ...);
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		self:OnUnfilteredCombatLogEvent(CombatLogGetCurrentEventInfo());
	end
end

function CommentatorModelSceneMixin:Reset()
	if self:IsInitialized() then
		for key, effectController in pairs(self.effectController) do
			effectController:FinishEffect();
		end
		self.effectController = {};
		self.unitToken = nil;
		self.effectTarget = nil;
	end
end

function CommentatorModelSceneMixin:IsInitialized()
	return self.unitToken and self.effectTarget;
end

function CommentatorModelSceneMixin:OnUnfilteredCombatLogEvent(...)
	local event = select(2, ...);
	if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED" then
		local destGuid = select(8, ...);
		if self.guid == destGuid then
			self:UpdateModelScene();
		end
	end
end

function CommentatorModelSceneMixin:Init(unitToken, guid, effectTarget)
	if unitToken and guid and effectTarget then
		self.unitToken = unitToken;
		self.guid = guid;
		self.effectTarget = effectTarget;
	else
		error("CommentatorModelSceneMixin:Init, invalid unitToken or effectTarget");
	end
	
end

function CommentatorModelSceneMixin:UpdateModelScene()
	if self:IsInitialized() then
		local offensive, defensive = C_Commentator.HasTrackedAuras(self.unitToken);
		if offensive then
			self:AddModelSceneEffect(MODEL_SCENE_OFFENSIVE_EFFECT_AURA);
		else
			self:FinishModelSceneEffect(MODEL_SCENE_OFFENSIVE_EFFECT_AURA);
		end

		if defensive then
			self:AddModelSceneEffect(MODEL_SCENE_DEFENSIVE_EFFECT_AURA);
		else
			self:FinishModelSceneEffect(MODEL_SCENE_DEFENSIVE_EFFECT_AURA);
		end
	end
end

function CommentatorModelSceneMixin:AddModelSceneEffect(effect)
	if not self.effectController[effect] then
		self.effectController[effect] = self:AddEffect(effect, self.effectTarget, self.effectTarget);
	end
end

function CommentatorModelSceneMixin:FinishModelSceneEffect(effect)
	local controller = self.effectController[effect];
	if controller then
		controller:FinishEffect();
		self.effectController[effect] = nil;
	end
end
