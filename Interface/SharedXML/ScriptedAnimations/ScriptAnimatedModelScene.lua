
local ScriptedAnimationModelSceneID = 343;

-- Experimentally determined.
local SceneUnitDivisor = 612.5;

-- These are (somewhat) arbitrary values. With these, many standard effects with look correct with a scale of 1.0.
-- To change these, we'd have to update all existing effects that play in scenes with useViewInsetNormalization.
local TargetViewWidth = 600;
local TargetViewHeight = 680;


ScriptAnimatedModelSceneMixin = {};

function ScriptAnimatedModelSceneMixin:OnLoad()
	ModelSceneMixin.OnLoad(self);

	self.centerX = 0;
	self.centerY = 0;
	self.effectControllers = {};
	self.pixelsPerSceneUnit = math.huge;
	self.delayedActions = {};
end

function ScriptAnimatedModelSceneMixin:OnShow()
	self:RefreshModelScene();
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:SetScript("OnSizeChanged", self.OnSizeChanged);
end

function ScriptAnimatedModelSceneMixin:OnHide()
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:UnregisterEvent("UI_SCALE_CHANGED");
	self:SetScript("OnSizeChanged", nil);
end

function ScriptAnimatedModelSceneMixin:OnSizeChanged()
	self:RefreshModelScene();
end

function ScriptAnimatedModelSceneMixin:OnEvent(event)
	if event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
		self:RefreshModelScene();
	end
end

function ScriptAnimatedModelSceneMixin:RefreshModelScene()
	if not self:GetRect() then
		return;
	end

	self.centerX, self.centerY = self:GetCenter();

	local sceneShouldBeSet = not self:IsModelSceneSet();
	if sceneShouldBeSet then
		self:SetFromModelSceneID(ScriptedAnimationModelSceneID);
		self.modelSceneSet = true;
	end

	if self.useViewInsetNormalization then
		local currentWidth, currentHeight = self:GetSize();
		local adjustmentX = (currentWidth - TargetViewWidth) / 2;
		local adjustmentY = (currentHeight - TargetViewHeight) / 2;
		self:SetViewInsets(adjustmentX, adjustmentX, adjustmentY, adjustmentY);
	end

	self:CalculatePixelsPerSceneUnit();

	-- Now that the scene is set, and we've calculated pixels per scene unit, we can execute the
	-- actions that were delayed until we had a proper scene set up.
	if sceneShouldBeSet then
		for i, action in ipairs(self.delayedActions) do
			action();
		end

		self.delayedActions = nil;
	end
end

function ScriptAnimatedModelSceneMixin:IsModelSceneSet()
	return self.modelSceneSet;
end

function ScriptAnimatedModelSceneMixin:ExecuteOrDelayUntilSceneSet(action)
	-- If we're still resolving sizing and anchoring and we don't have a proper model scene set up,
	-- we need to delay adding effects as they won't be initialized properly.
	if self:IsModelSceneSet() then
		action();
		return;
	end

	table.insert(self.delayedActions, action);
end

function ScriptAnimatedModelSceneMixin:OnUpdate(elapsed, ...)
	if #self.effectControllers == 0 then
		return;
	end

	ModelSceneMixin.OnUpdate(self, elapsed, ...);

	self.centerX, self.centerY = self:GetCenter();

	local modifiedElapsed = elapsed * self:GetEffectSpeed();
	for i, effectController in ipairs(self.effectControllers) do
		effectController:DeltaUpdate(modifiedElapsed, ...);
	end

	local i = 1;
	while i <= #self.effectControllers do
		local effectController = self.effectControllers[i];
		if effectController:IsActive() then
			i = i + 1;
		else
			tUnorderedRemove(self.effectControllers, i);
		end
	end
end

function ScriptAnimatedModelSceneMixin:SetActiveCamera(...)
	ModelSceneMixin.SetActiveCamera(self, ...);

	self:CalculatePixelsPerSceneUnit();
end

function ScriptAnimatedModelSceneMixin:GetSceneSize()
	local left, right, top, bottom = self:GetViewInsets();
	local width, height = self:GetSize();
	return (width - left) - right, (height - bottom) - top;
end

function ScriptAnimatedModelSceneMixin:CalculatePixelsPerSceneUnit()
	local width, height = self:GetSceneSize();
	local sceneSize = Vector2D_GetLength(width, height);
	local activeCamera = self:GetActiveCamera();
	if not activeCamera then
		return;
	end

	local zoomDistance = activeCamera:GetZoomDistance();
	self.pixelsPerSceneUnit = (sceneSize * zoomDistance) / SceneUnitDivisor;
end

function ScriptAnimatedModelSceneMixin:GetPixelsPerSceneUnit()
	return self.pixelsPerSceneUnit;
end

function ScriptAnimatedModelSceneMixin:AddEffect(effectID, source, target, onEffectFinish, onEffectResolution, scaleMultiplier)
	local effectController = CreateAndInitFromMixin(ScriptAnimatedEffectControllerMixin, self, effectID, source, target, onEffectFinish, onEffectResolution, scaleMultiplier);

	local function StartEffectController()
		effectController:StartEffect();
	end

	self:ExecuteOrDelayUntilSceneSet(StartEffectController);
	
	return effectController; 
end

function ScriptAnimatedModelSceneMixin:AddDynamicEffect(dynamicEffectDescription, source, target, onEffectFinish, onEffectResolution, scaleMultiplier)
	local effectController = CreateAndInitFromMixin(ScriptAnimatedEffectControllerMixin, self, dynamicEffectDescription.effectID, source, target, onEffectFinish, onEffectResolution, scaleMultiplier);

	local function StartEffectController()
		effectController:SetSoundEnabled(dynamicEffectDescription.soundEnabled);
		effectController:SetDynamicOffsets(dynamicEffectDescription.offsetX, dynamicEffectDescription.offsetY, dynamicEffectDescription.offsetZ);
		effectController:StartEffect();
	end

	self:ExecuteOrDelayUntilSceneSet(StartEffectController);
	
	return effectController; 
end

function ScriptAnimatedModelSceneMixin:InternalAddEffect(effectID, source, target, effectController, scaleMultiplier)
	local effect = ScriptedAnimationEffectsUtil.GetEffectByID(effectID);

	local actor = self:AcquireActor();
	
	if not actor.SetEffect then
		Mixin(actor, ScriptAnimatedModelSceneActorMixin);
	end

	actor:SetEffect(effect, source, target, scaleMultiplier);
	actor:Show();

	if not tContains(self.effectControllers, effectController) then
		table.insert(self.effectControllers, effectController);
	end

	return actor;
end

function ScriptAnimatedModelSceneMixin:SetEffectSpeed(speed)
	self.effectSpeed = speed;
end

function ScriptAnimatedModelSceneMixin:GetEffectSpeed()
	return self.effectSpeed or 1.0;
end

function ScriptAnimatedModelSceneMixin:ClearEffects()
	local skipRemovingController = true;
	for i, effectController in ipairs(self.effectControllers) do
		effectController:InternalCancelEffect(skipRemovingController);
	end

	self.effectControllers = {};
end

function ScriptAnimatedModelSceneMixin:HasActiveEffects()
	return #self.effectControllers > 0;
end

function ScriptAnimatedModelSceneMixin:RemoveEffectController(effectControllerToRemove)
	for i, effectController in ipairs(self.effectControllers) do
		if effectController == effectControllerToRemove then
			tUnorderedRemove(self.effectControllers, i);
			break;
		end
	end
end

function ScriptAnimatedModelSceneMixin:SetActorPositionFromPixels(actor, x, y, z)
	local pixelsPerSceneUnit = self.pixelsPerSceneUnit;
	local dx = (x - self.centerX) / pixelsPerSceneUnit;
	local dy = (y - self.centerY) / pixelsPerSceneUnit;
	local actorScaleDivisor = actor:GetScale();
	actor:SetEffectActorOffset(dx / actorScaleDivisor, dy / actorScaleDivisor, (z or 0) / actorScaleDivisor);
end
