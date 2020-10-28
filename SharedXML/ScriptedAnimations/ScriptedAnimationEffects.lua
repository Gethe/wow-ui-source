
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

local function GetTransformationProgress(elapsed, duration)
	return (elapsed > duration) and 1.0 or (elapsed / duration);
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

local function GenerateAlphaTransformation(effectActor, elapsed, duration, beginAlpha, targetAlpha)
	beginAlpha = beginAlpha or effectActor:GetAlpha();
	targetAlpha = targetAlpha or effectActor:GetAlpha();

	local function AlphaTransformation(effectActor, elapsed, duration)
		local progress = GetTransformationProgress(elapsed, duration);
		local alpha = Lerp(beginAlpha, targetAlpha, progress);
		effectActor:SetAlpha(alpha);

		return progress == 1.0;
	end

	return AlphaTransformation(effectActor, elapsed, duration), AlphaTransformation;
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
-- (1) The transformation system
-- Part of the goal of future FX is to allow more control over events in an effect such
-- as playing sounds or starting a new effect. This prototype is currently built to support
-- fading in and fading out.
-- Proposed transformation format:
-- {
-- timing: how the behavior starts (at a fixed time, at a fixed percentage, with the beginning,
-- 			so that the transformation ends with the effect, halfway through the effect, etc )
-- duration: how long the transformation lasts.
-- transformationCallback: an enum value corresponding to the function to do the actual transformation.
-- args: a list of arguments to control the callback.
-- }
-- These can be found in HardcodedTransformations below.
-- 
-- (2) Animation controls
-- Additional columns to support controlling animations
-- animation: an animation to play instead of Stand.
-- animationStartOffset: an offset (in seconds) to the animation.
--
-- (3) Looping sound effects
-- An additional columns to support controlling animations
-- loopingSoundKitID: a looping sound effect that plays while the effect is active.
--
-- (4) Particle scaling
-- An additional column to support an override for the particle scale, which will match the actor
-- scale by default.
-- particleOverrideScale: the override scale for particles.
--
-- (5) Starting alpha
-- An additional column to support an override for the effect actor's starting alpha.
-- startingAlpha: the effect actor's starting alpha.
--
-- (6) Playing Effect at Target without pitching from source 
-- A flag to allow an effect to play at a target without augmenting it's yaw by the source->target vector
-- useTargetAsSource: set to true for readability, anything nonfalse will evaluate to use the default angles. 

Enum.ScriptedAnimationTransformation = {};
Enum.ScriptedAnimationTransformation.Alpha = 1;

Enum.ScriptedAnimationTransformationTiming = {};
Enum.ScriptedAnimationTransformationTiming.BeginWithEffect = 1;
Enum.ScriptedAnimationTransformationTiming.FinishWithEffect = 2;
-- Enum.ScriptedAnimationTransformationTiming.Fixed = 3; -- Currently unsupported.

local TransformationToCallback = {
	[Enum.ScriptedAnimationTransformation.Alpha] = GenerateAlphaTransformation,
};

local HardcodedTransformations = {
	FadeIn = {
		timing = Enum.ScriptedAnimationTransformationTiming.BeginWithEffect,
		duration = 0.4,
		transformationCallback = TransformationToCallback[Enum.ScriptedAnimationTransformation.Alpha],
		args = { 0, 1, n = 2 },
	},

	FadeOut = {
		timing = Enum.ScriptedAnimationTransformationTiming.FinishWithEffect,
		duration = 0.4,
		transformationCallback = TransformationToCallback[Enum.ScriptedAnimationTransformation.Alpha],
		args = { nil, 0, n = 2 },
	},
};

local RunecarvingRuneFlashExtension = {
	animation = 127,
	animationStartOffset = 0.3,

	transformations = {
		HardcodedTransformations.FadeOut,
	},
};

local RunecarvingRuneBirthExtension = {
	transformations = {
		HardcodedTransformations.FadeIn,
	},
};

local AnimaDiversionHoldAnimation = {
	animation = 158,
};

local ScriptAnimationTableExtension = {
	[22] = AnimaDiversionHoldAnimation,
	[24] = AnimaDiversionHoldAnimation,
	[27] = AnimaDiversionHoldAnimation,
	[28] = AnimaDiversionHoldAnimation,
	[31] = AnimaDiversionHoldAnimation,
	[33] = AnimaDiversionHoldAnimation,

	[41] = {
		animation = 158,
	},

	[52] = {
		loopingSoundKitID = SOUNDKIT.UI_RUNECARVING_MAIN_WINDOW_OPEN_LOOP,
	},

	[55] = {
		loopingSoundKitID = SOUNDKIT.UI_RUNECARVING_POWER_SELECTED_LOOP,
	},

	[54] = {
		loopingSoundKitID = SOUNDKIT.UI_RUNECARVING_LOWER_RUNE_SELECTED_LOOP,
	},

	[57] = {
		loopingSoundKitID = SOUNDKIT.UI_RUNECARVING_UPPER_RUNE_SELECTED_LOOP,
	},

	[73] = Mixin({ loopingSoundKitID = SOUNDKIT.UI_RUNECARVING_ITEM_SELECTED_LOOP, }, RunecarvingRuneBirthExtension),
	[74] = RunecarvingRuneBirthExtension,
	[75] = RunecarvingRuneBirthExtension,
	[76] = RunecarvingRuneBirthExtension,
	[77] = RunecarvingRuneBirthExtension,
	[78] = RunecarvingRuneBirthExtension,
	[79] = RunecarvingRuneBirthExtension,
	[80] = RunecarvingRuneBirthExtension,

	[81] = RunecarvingRuneFlashExtension,
	[82] = RunecarvingRuneFlashExtension,
	[83] = RunecarvingRuneFlashExtension,
	[84] = RunecarvingRuneFlashExtension,
	[85] = RunecarvingRuneFlashExtension,
	[86] = RunecarvingRuneFlashExtension,
	[87] = RunecarvingRuneFlashExtension,
	[88] = RunecarvingRuneFlashExtension,
	[89] = {
		animation = 215, 
	},

	-- Covenant Toast Looping Sounds. 
	[91] = { 
		loopingSoundKitID = SOUNDKIT.UI_COVENANT_CHOICE_CELEBRATION_ANIMATION_BASTION,
	},
	[92] = { 
		loopingSoundKitID = SOUNDKIT.UI_COVENANT_CHOICE_CELEBRATION_ANIMATION_REVENDRETH,
	},
	[93] = { 
		loopingSoundKitID = SOUNDKIT.UI_COVENANT_CHOICE_CELEBRATION_ANIMATION_ARDENWEALD,
	},
	[94] = { 
		loopingSoundKitID = SOUNDKIT.UI_COVENANT_CHOICE_CELEBRATION_ANIMATION_MALDRAXXUS,
	},

	[98] = {
		animation = 158,
	},

	[99] = {
		useTargetAsSource = true,
	},

	[119] = {
		startingAlpha = 0.2,
	},
	[120] = {
		startingAlpha = 0.3,
	},
	[121] = {
		startingAlpha = 0.2,
	},
	[122] = {
		startingAlpha = 0.3,
	},
	[123] = {
		startingAlpha = 0.4,
	},


};

-- Split into chunks of 10. These effects were created with old-style particle scaling,
-- so to preserve their current behavior they all have a particleOverrideScale of 1.0.
local LegacyParticleScaleEffects = {
	2, 3, 4, 5, 6, 8, 9, 10, 11, 12,
	15, 16, 17, 18, 19, 20, 21, 22, 25, 30,
	36, 37, 43, 44, 45, 46, 48, 49, 50, 53,
	54, 55, 57, 58, 59, 60, 61, 62, 63, 64,
	65, 77, 67, 68, 70, 72, 73, 74, 75, 76,
	77, 78, 79, 80, 81, 82, 83, 84, 85, 86,
	87, 88, 89, 90, 91, 92, 93, 94, 95, 96,
	97, 101, 119, 120, 121, 122, 123
};

for i, effectID in ipairs(LegacyParticleScaleEffects) do
	local effectExtension = ScriptAnimationTableExtension[effectID];
	if not effectExtension then
		effectExtension = {};
		ScriptAnimationTableExtension[effectID] = effectExtension;
	end

	effectExtension.particleOverrideScale = 1.0;
end


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
