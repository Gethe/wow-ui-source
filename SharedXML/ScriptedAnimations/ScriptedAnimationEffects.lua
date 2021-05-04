
local UIParentShake = { { x = 0, y = -20}, { x = 0, y = 20}, { x = 0, y = -20}, { x = 0, y = 20}, { x = -9, y = -8}, { x = 8, y = 8}, { x = -3, y = -8}, { x = 9, y = 8}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, };
local UIParentShakeDuration = 0.20;
local UIParentShakeFrequency = 0.001;


local function GetDirectionVector(source, target)
	local sourceX, sourceY = source:GetCenter();
	local targetX, targetY = target:GetCenter();
	return CreateVector2D(targetX - sourceX, targetY - sourceY);
end

local function InOutProgress(progress)
	return (progress < 0.5 and progress or (1.0 - progress)) * 2.0;
end


local function GetProgress(elapsed, duration)
	-- A duration of 0 is used for effects that last until canceled.
	return (duration ~= 0) and (elapsed / duration) or 0;
end

local function LinearTrajectory(source, target, elapsed, duration)
	local sourceX, sourceY = source:GetCenter();
	local targetX, targetY = target:GetCenter();
	local progress = GetProgress(elapsed, duration);
	local positionX = Lerp(sourceX, targetX, progress);
	local positionY = Lerp(sourceY, targetY, progress);
	return positionX, positionY;
end

local function GenerateCurveTrajectory(curveMagnitude)
	local function CurveTrajectory(source, target, elapsed, duration)
		local progress = GetProgress(elapsed, duration);
		local direction = GetDirectionVector(source, target);

		-- Add movement perpendicular to direction to curve the effect.
		local curveDirection = CreateVector2D(-direction.y, direction.x);
		local inOutProgress = InOutProgress(progress);
		local curveProgress = math.sin(inOutProgress * math.pi);
		curveDirection:ScaleBy(curveProgress * curveMagnitude);

		direction:ScaleBy(progress);
		direction:Add(curveDirection);

		local sourceX, sourceY = source:GetCenter();
		local deltaX, deltaY = direction:GetXY();
		return sourceX + deltaX, sourceY + deltaY;
	end

	return CurveTrajectory;
end

local StandardCurveMagnitude = 0.1;
local StandardCurveTrajectory = GenerateCurveTrajectory(StandardCurveMagnitude);
local ReverseCurveTrajectory = GenerateCurveTrajectory(-StandardCurveMagnitude);

local function RandomCurveTrajectory(source, target, elapsed, duration)
	local curveTrajectory = (math.random(0, 1) == 0) and StandardCurveTrajectory or ReverseCurveTrajectory;
	local x, y = curveTrajectory(source, target, elapsed, duration);
	return x, y, curveTrajectory;
end

local function SourceStaticTrajectory(source, target, elapsed, duration)
	return source:GetCenter();
end

local function TargetStaticTrajectory(source, target, elapsed, duration)
	return target:GetCenter();
end

local function HalfwayStaticTrajectory(source, target, elapsed, duration)
	local sourceCenterX, sourceCenterY = source:GetCenter();
	local targetCenterX, targetCenterY = target:GetCenter();
	return sourceCenterX + ((targetCenterX - sourceCenterX) / 2.0), sourceCenterY + ((targetCenterY - sourceCenterY) / 2.0);
end

local function ShakeTargetLight(effectDescription, source, target, speed)
	local duration = effectDescription.duration / speed;
	local cancelFunction = ScriptAnimationUtil.ShakeFrameRandom(target, 2, duration, .05);
	return cancelFunction, duration;
end

local function ShakeUIParent(effectDescription, source, target, speed)
	local duration = effectDescription.duration / speed;
	local cancelFunction = ScriptAnimationUtil.ShakeFrame(UIParent, UIParentShake, UIParentShakeDuration, UIParentShakeFrequency);
	return cancelFunction, duration;
end

local function GenerateRecoilCallback(magnitude, duration)
	local function RecoilFunction(effectDescription, source, target, speed)
		local totalDuration = duration / speed;

		local direction = GetDirectionVector(source, target);
		if direction:IsZero() then
			return nop, totalDuration;
		end

		direction:Normalize();
		direction:ScaleBy(magnitude);
		local distanceX, distanceY = direction:GetXY();

		-- Half the animation will be going out, and the other half coming in.
		local recoilDuration = totalDuration / 2;

		local easingFunction = nil;
		local reverseVariationCallback = ScriptAnimationUtil.GenerateEasedVariationCallback(easingFunction, -distanceX, -distanceY);
		local reversePosition = GenerateClosure(ScriptAnimationUtil.StartScriptAnimation, source, reverseVariationCallback, recoilDuration);

		local variationCallback = ScriptAnimationUtil.GenerateEasedVariationCallback(easingFunction, distanceX, distanceY);
		local cancelFunction = ScriptAnimationUtil.StartScriptAnimation(source, variationCallback, recoilDuration, reversePosition);

		return cancelFunction, totalDuration;
	end

	return RecoilFunction;
end

local StandardRecoil = GenerateRecoilCallback(15, 0.2);

local function GenerateKnockbackCallback(knockbackMagnitude, duration)
	-- To make recoil a knockback, reverse the source and target, and reverse the direction by negating magnitude.
	local recoilFunction = GenerateRecoilCallback(-knockbackMagnitude, duration);

	local function KnockbackFunction(effectDescription, source, target, speed)
		return recoilFunction(effectDescription, target, source, speed);
	end

	return KnockbackFunction;
end

local StandardKnockback = GenerateKnockbackCallback(25, 0.3);

local PullbackPercentage = 0.2;
local ForwardPercentage = 0.3;
local ForwardThreshold = PullbackPercentage + ForwardPercentage;
local BackwardPercentage = 1.0 - (PullbackPercentage + ForwardPercentage);
local function GenerateAttackCollisionFunction(pullbackMagnitude)
	local function AttackCollisionFunction(effectDescription, source, target, speed)
		local translation = GetDirectionVector(source, target);
		translation:ScaleBy(0.95); -- don't go the entire distance.
		
		local direction = translation:Clone();
		if direction:IsZero() then
			return nop, effectDescription.duration;
		end
		
		direction:Normalize();
		direction:ScaleBy(-pullbackMagnitude);

		-- This will be a three part animation: pull back, launch forward, then return to start.
		-- time:          1         5       4   2        3
		-- positions: pullback...source................target
		-- t1: source has pulled back
		-- t2: source is between the pullback point and target
		-- t3: source reaches target (the effect finish triggers, which can include a knockback)
		-- t4: source is returning to its original position
		-- t5: source has returned to its original position
		local distanceX, distanceY = translation:GetXY();
		local pullbackDistanceX, pullbackDistanceY = direction:GetXY();
		local forwardDistanceX, forwardDistanceY = distanceX - pullbackDistanceX, distanceY - pullbackDistanceY;

		local function AttackCollisionVariationCallback(elapsed, duration)
			local progress = elapsed / duration;
			if progress < PullbackPercentage then
				local progress = progress / PullbackPercentage;
				return pullbackDistanceX * progress, pullbackDistanceY * progress;
			elseif progress < ForwardThreshold then
				local progress = (progress - PullbackPercentage) / ForwardPercentage;
				return pullbackDistanceX + forwardDistanceX * progress, pullbackDistanceY + forwardDistanceY * progress;
			else
				local progress = (progress - ForwardThreshold) / BackwardPercentage;
				return distanceX * (1.0 - progress), distanceY * (1.0 - progress);
			end
		end

		-- The end of the effect should be triggered on collision, at the end of the "forward" part of the animation, so the
		-- full movement animation should last longer than the effect.
		local fullDuration = (effectDescription.duration * (1.0 / ForwardThreshold)) / speed;
		local cancelFunction = ScriptAnimationUtil.StartScriptAnimation(source, AttackCollisionVariationCallback, fullDuration);

		return cancelFunction, fullDuration;
	end

	return AttackCollisionFunction;
end

local StandardAttackCollision = GenerateAttackCollisionFunction(50);


-- Behavior functions should have the signature: (effectDescription, source, target, speed) -> cancelFunction, behaviorDuration
local BehaviorToCallback = {
	-- [Enum.ScriptedAnimationBehavior.None] = nil,
	[Enum.ScriptedAnimationBehavior.SourceRecoil] = StandardRecoil,
	[Enum.ScriptedAnimationBehavior.SourceCollideWithTarget] = StandardAttackCollision,
	[Enum.ScriptedAnimationBehavior.TargetShake] = ShakeTargetLight,
	[Enum.ScriptedAnimationBehavior.TargetKnockBack] = StandardKnockback,
	[Enum.ScriptedAnimationBehavior.UIParentShake] = ShakeUIParent,
};

local TrajectoryToCallback = {
	[Enum.ScriptedAnimationTrajectory.AtSource] = SourceStaticTrajectory,
	[Enum.ScriptedAnimationTrajectory.Straight] = LinearTrajectory,
	[Enum.ScriptedAnimationTrajectory.CurveLeft] = StandardCurveTrajectory,
	[Enum.ScriptedAnimationTrajectory.CurveRight] = ReverseCurveTrajectory,
	[Enum.ScriptedAnimationTrajectory.CurveRandom] = RandomCurveTrajectory,
	[Enum.ScriptedAnimationTrajectory.AtTarget] = TargetStaticTrajectory,
	[Enum.ScriptedAnimationTrajectory.HalfwayBetween] = HalfwayStaticTrajectory,
};

-- Support feature prototypes without extending the databse table. Current Extensions:
--
-- README: Please replace the comments below if you add a new extension.
-- (1) Feature
-- Feature description
-- featureKey1: feature key 1 description

local ScriptAnimationTableExtension = {
	-- [1] = {
	-- 	featureKey1 = 12345,
	-- }
};


local function LoadScriptedAnimationEffects()
	local effects = {};
	local effectDescriptions = C_ScriptedAnimations.GetAllScriptedAnimationEffects();
	local count = #effectDescriptions;
	for i = 1, count do
		local effectDescription = effectDescriptions[i];
		effectDescription.trajectory = TrajectoryToCallback[effectDescription.trajectory];
		effectDescription.startBehavior = effectDescription.startBehavior and BehaviorToCallback[effectDescription.startBehavior] or nil;
		effectDescription.finishBehavior = effectDescription.finishBehavior and BehaviorToCallback[effectDescription.finishBehavior] or nil;

		local effectID = effectDescription.id;
		local extension = ScriptAnimationTableExtension[effectID];
		if extension then
			effectDescription = Mixin(effectDescription, extension);
		end
		
		effects[effectID] = effectDescription;
	end

	return effects;
end

local ScriptedAnimationEffects = LoadScriptedAnimationEffects();


ScriptedAnimationEffectsUtil = {};

function ScriptedAnimationEffectsUtil.GetEffectByID(effectID)
	return ScriptedAnimationEffects[effectID];
end

function ScriptedAnimationEffectsUtil.ReloadDB()
	ScriptedAnimationEffects = LoadScriptedAnimationEffects();
end


ScriptedAnimationEffectsDebug = {};

function ScriptedAnimationEffectsDebug.GetDB()
	return ScriptedAnimationEffects;
end

function ScriptedAnimationEffectsDebug.GetAllEffectIDs()
	local allEffectIDs = {};
	for effectID, effect in pairs(ScriptedAnimationEffects) do
		table.insert(allEffectIDs, effectID);
	end

	return allEffectIDs;
end

function ScriptedAnimationEffectsDebug.GetBehavior(behavior)
	return BehaviorToCallback[behavior];
end

function ScriptedAnimationEffectsDebug.GetTrajectory(trajectory)
	return TrajectoryToCallback[trajectory];
end

function ScriptedAnimationEffectsDebug.GetEnumFromBehavior(behaviorFunction)
	for enum, callback in pairs(BehaviorToCallback) do
		if callback == behaviorFunction then
			return enum;
		end
	end

	return nil;
end

function ScriptedAnimationEffectsDebug.GetEnumFromTrajectory(trajectoryFunction)
	for enum, callback in pairs(TrajectoryToCallback) do
		if callback == trajectoryFunction then
			return enum;
		end
	end

	return nil;
end

function ScriptedAnimationEffectsDebug.LoadEffectsDBCopy()
	return LoadScriptedAnimationEffects();
end

function ScriptedAnimationEffectsDebug.RestoreDBCopy(dbCopy)
	ScriptedAnimationEffects = dbCopy;
end
