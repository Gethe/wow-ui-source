
local HalfPi = math.pi / 2;


local function LinearTrajectory(source, target, elapsed, duration)
	local sourceX, sourceY = source:GetCenter();
	local targetX, targetY = target:GetCenter();
	local progress = elapsed / duration;
	local positionX = Lerp(sourceX, targetX, progress);
	local positionY = Lerp(sourceY, targetY, progress);
	return positionX, positionY;
end

local function InOutTrajectory(source, target, elapsed, duration)
	local sourceX, sourceY = source:GetCenter();
	local targetX, targetY = target:GetCenter();
	local progress = elapsed / duration;
	progress = (progress < 0.5 and progress or (1.0 - progress)) * 2.0;
	local positionX = Lerp(sourceX, targetX, progress);
	local positionY = Lerp(sourceY, targetY, progress);
	return positionX, positionY;
end

local function GenerateCurveTrajectory(rotation, curveMagnitude)
	local function CurveTrajectory(source, target, elapsed, duration)
		local sourceX, sourceY = source:GetCenter();
		local targetX, targetY = target:GetCenter();
		local direction = CreateVector2D(targetX - sourceX, targetY - sourceY);
		local curveDirection = direction:Clone();
		curveDirection:RotateDirection(rotation);
		local progress = elapsed / duration;
		direction:ScaleBy(progress);

		local perpendicularProgress = (progress < 0.5 and progress or (1.0 - progress));
		curveDirection:ScaleBy(math.sin(perpendicularProgress * math.pi) * curveMagnitude);

		direction:Add(curveDirection);
		local deltaX, deltaY = direction:GetXY();
		return sourceX + deltaX, sourceY + deltaY;
	end

	return CurveTrajectory;
end

local StandardCurveMagnitude = 0.2;
local StandardCurveTrajectory = GenerateCurveTrajectory(HalfPi, StandardCurveMagnitude);
local ReverseCurveTrajectory = GenerateCurveTrajectory(-HalfPi, StandardCurveMagnitude);

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

local function ShakeTargetLight(effectDescription, source, target)
	ScriptAnimationUtil.ShakeFrameRandom(target, 2, effectDescription.duration, .05);
end

local function GenerateRecoilCallback(magnitude, duration)
	local function RecoilFunction(effectDescription, source, target)
		local sourceX, sourceY = source:GetCenter();
		local targetX, targetY = target:GetCenter();
		local direction = CreateVector2D(sourceX - targetX, sourceY - targetY);
		direction:Normalize();
		direction:ScaleBy(magnitude);
		local distanceX, distanceY = direction:GetXY();

		local recoilDuration = duration / 2;

		local easingFunction = nil;
		local reverseVariationCallback = ScriptAnimationUtil.GenerateEasedVariationCallback(easingFunction, -distanceX, -distanceY);
		local reversePosition = GenerateClosure(ScriptAnimationUtil.StartScriptAnimation, source, reverseVariationCallback, recoilDuration);

		local variationCallback = ScriptAnimationUtil.GenerateEasedVariationCallback(easingFunction, distanceX, distanceY);
		ScriptAnimationUtil.StartScriptAnimation(source, variationCallback, recoilDuration, reversePosition);
	end

	return RecoilFunction;
end

local StandardRecoil = GenerateRecoilCallback(15, 0.2);

local function GenerateKnockbackCallback(knockbackMagnitude, duration)
	local function KnockbackFunction(effectDescription, source, target)
		-- Only one recoil can play at a time.
		if not ScriptAnimationUtil.GetScriptAnimationLock(target) then
			return;
		end

		local sourceX, sourceY = source:GetCenter();
		local targetX, targetY = target:GetCenter();
		local direction = CreateVector2D(targetX - sourceX, targetY - sourceY);
		direction:Normalize();

		local point, relativeFrame, relativePoint, x, y = target:GetPoint();
		local startTime = GetTime();
		local endTime = startTime + duration;
		direction:ScaleBy(knockbackMagnitude);

		local function KnockbackTickerFunction()
			local currentTime = GetTime();
			local elapsedTime = currentTime - startTime;
			local progress = elapsedTime / duration;
			local progressCurve = (progress < 0.5 and progress or (1.0 - progress)) * 2.0;
			local directionClone = direction:Clone();
			directionClone:ScaleBy(progressCurve);
			
			local xVariation, yVariation = directionClone:GetXY();
			target:SetPoint(point, relativeFrame, relativePoint, x + xVariation, y + yVariation);

			if currentTime >= endTime then
				target:SetPoint(point, relativeFrame, relativePoint, x, y);
				target.knockbackTicker:Cancel();
				target.knockbackTicker = nil;
				ScriptAnimationUtil.ReleaseScriptAnimationLock(target);
			end
		end

		local frequency = 0.01;
		target.knockbackTicker = C_Timer.NewTicker(frequency, KnockbackTickerFunction);
	end

	return KnockbackFunction;
end

local StandardKnockback = GenerateKnockbackCallback(25, 0.3);

local function GenerateCollisionFunction()
	local function CollisionFunction(effectDescription, source, target)
		local sourceX, sourceY = source:GetCenter();
		local targetX, targetY = target:GetCenter();
		local translation = CreateVector2D(targetX - sourceX, targetY - sourceY);
		translation:ScaleBy(0.95); -- don't go the entire distance.
		
		local distanceX, distanceY = translation:GetXY();

		local easingFunction = nil; 
		local reverseVariationCallback = ScriptAnimationUtil.GenerateEasedVariationCallback(easingFunction, -distanceX, -distanceY);
		local reversePosition = GenerateClosure(ScriptAnimationUtil.StartScriptAnimation, source, reverseVariationCallback, effectDescription.duration * 2.0);

		local variationCallback = ScriptAnimationUtil.GenerateEasedVariationCallback(easingFunction, distanceX, distanceY);
		ScriptAnimationUtil.StartScriptAnimation(source, variationCallback, effectDescription.duration, reversePosition);
	end

	return CollisionFunction;
end

local StandardCollision = GenerateCollisionFunction();

local PullbackPercentage = 0.2;
local ForwardPercentage = 0.3;
local ForwardThreshold = PullbackPercentage + ForwardPercentage;
local BackwardPercentage = 1.0 - (PullbackPercentage + ForwardPercentage);
local function GenerateAttackCollisionFunction(pullbackMagnitude)
	local function AttackCollisionFunction(effectDescription, source, target)
		local sourceX, sourceY = source:GetCenter();
		local targetX, targetY = target:GetCenter();
		local translation = CreateVector2D(targetX - sourceX, targetY - sourceY);
		translation:ScaleBy(0.95); -- don't go the entire distance.
		
		local direction = translation:Clone();
		direction:Normalize();
		direction:ScaleBy(-pullbackMagnitude);

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

		-- The end of the effect should be triggered on collision, at the end of the "forward" part of the animation.
		local fullDuration = effectDescription.duration * (1.0 / ForwardThreshold);
		ScriptAnimationUtil.StartScriptAnimation(source, AttackCollisionVariationCallback, fullDuration);
	end

	return AttackCollisionFunction;
end

local StandardAttackCollision = GenerateAttackCollisionFunction(50);


local BehaviorToCallback = {
	-- [Enum.ScriptedAnimationBehavior.None] = nil,
	[Enum.ScriptedAnimationBehavior.SourceRecoil] = StandardRecoil,
	[Enum.ScriptedAnimationBehavior.SourceCollideWithTarget] = StandardAttackCollision,
	[Enum.ScriptedAnimationBehavior.TargetShake] = ShakeTargetLight,
	[Enum.ScriptedAnimationBehavior.TargetKnockBack] = StandardKnockback,
};

local TrajectoryToCallback = {
	[Enum.ScriptedAnimationTrajectory.AtSource] = SourceStaticTrajectory,
	[Enum.ScriptedAnimationTrajectory.Straight] = LinearTrajectory,
	[Enum.ScriptedAnimationTrajectory.CurveLeft] = StandardCurveTrajectory,
	[Enum.ScriptedAnimationTrajectory.CurveRight] = ReverseCurveTrajectory,
	[Enum.ScriptedAnimationTrajectory.CurveRandom] = RandomCurveTrajectory,
	[Enum.ScriptedAnimationTrajectory.AtTarget] = TargetStaticTrajectory,
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
		effects[effectDescription.id] = effectDescription;
	end

	return effects;
end

local ScriptedAnimationEffects = LoadScriptedAnimationEffects();


ScriptedAnimationEffectsUtil = {};

ScriptedAnimationEffectsUtil.NamedEffectIDs = {
	Fireball = 1,
	Regrowth = 3,
	MeleeAttack = 4,
	ShockTarget = 6,
};

function ScriptedAnimationEffectsUtil.GetEffectByID(effectID)
	return ScriptedAnimationEffects[effectID];
end

function ScriptedAnimationEffectsUtil.GetAllEffectIDs()
	local allEffectIDs = {};
	for effectID, effect in pairs(ScriptedAnimationEffects) do
		table.insert(allEffectIDs, effectID);
	end

	return allEffectIDs;
end
