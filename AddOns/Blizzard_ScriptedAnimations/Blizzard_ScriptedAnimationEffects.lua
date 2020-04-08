
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

local function SourceStaticTrajectory(source, target, elapsed, duration)
	return source:GetCenter();
end

local function TargetStaticTrajectory(source, target, elapsed, duration)
	return target:GetCenter();
end

local function GenerateDelayedTrajectory(delay, trajectory)
	local function DelayedTrajectory(source, target, elapsed, duration)
		if elapsed < delay then
			return nil, nil;
		end

		return trajectory(source, target, elapsed - delay, duration - delay);
	end

	return DelayedTrajectory;
end

local function GenerateSourceAtAngle(target, distance, angleRadians)
	local targetX, targetY = target:GetCenter();
	local sourceX, sourceY = Vector2D_RotateDirection(angleRadians, 0, distance);
	sourceX = sourceX + targetX;
	sourceY = sourceY + targetY;

	local source = {};
	source.GetCenter = function()
		return sourceX, sourceY;
	end

	return source;
end

local function ShakeTargetLight(effectActor, effectDescription, source, target)
	ScriptAnimationUtil.ShakeFrameRandom(target, 2, effectDescription.duration, .05);
end

local function GenerateRecoilCallback(magnitude, duration)
	local function RecoilFunction(effectActor, effectDescription, source, target)
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
	local function KnockbackFunction(effectActor, effectDescription, source, target)
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
	local function CollisionFunction(effectActor, effectDescription, source, target)
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
	local function AttackCollisionFunction(effectActor, effectDescription, source, target)
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

local RingSize = 8;
local RingDistance = 75;
local function GenerateImpactRing(effectActor, effectDescription, source, target)
	local modelScene = effectActor:GetModelScene();
	local angleRadians = math.pi / 4;
	local angle = 0;
	for i = 1, RingSize do
		modelScene:AddEffect(effectDescription.ringImpact, target, GenerateSourceAtAngle(target, RingDistance, angle));
		angle = angle + angleRadians;
	end
end

local function GenerateCurvedMissileSequence(numMissiles, spacingSeconds)
	local function CurvedMissileSequence(effectActor, effectDescription, source, target)
		local modelScene = effectActor:GetModelScene();
		for i = 1, numMissiles do
			local missileDescription = CopyTable(effectDescription);
			local delay = i * spacingSeconds;
			missileDescription.duration = missileDescription.duration + delay;
			missileDescription.onStart = nil;
			local baseTrajectory = (i % 2 == 1) and ReverseCurveTrajectory or StandardCurveTrajectory;
			missileDescription.trajectory = GenerateDelayedTrajectory(delay, baseTrajectory);
			modelScene:AddEffect(missileDescription, source, target);
		end
	end

	return CurvedMissileSequence;
end

local ArcaneMissileSequence = GenerateCurvedMissileSequence(3, 0.1);


local StandardImpactDuration = 0.5;
local LongImpactDuration = 0.75;
local StandardEffectDuration = 1.0;
local QuickProjectileDuration = 0.5;
local MissileProjectileDuration = 0.3;
local StandardCollisionDuration = 0.3;

local ExplosionImpact = 1327007;
local LightningImpact = 1953988;
local ArcaneImpact = 1601380;
local StarsurgeImpact = 464345;
local FlamestrikeImpact = 1387771;
local NukeImpact = 1810660;
local ArgusImpact = 1715647;

local FireballEffect = 166128;
local LightningEffect = 1953986;
local ArcaneEffect = 1007493;
local StarsurgeEffect = 451173;
local RegrowthEffect = 166605;
local FireQuakeEffect = 1387771;
local FireMissileEffect = 1368707;
local ArgusEffect = 1711490;

local StandardImpact = {
	trajectory = TargetStaticTrajectory,
	duration = StandardImpactDuration,
};

local StandardImpactShake = Mixin({
	trajectory = TargetStaticTrajectory,
	duration = StandardImpactDuration,
	onStart = ShakeTargetLight,
}, StandardImpact);

local ScriptedAnimationImpacts = {
	Explosion = Mixin({
		effectFileID = ExplosionImpact,
	}, StandardImpactShake),

	ExplosionRecoil = Mixin({
		effectFileID = ExplosionImpact,
		onStart = StandardKnockback,
	}, StandardImpact),

	Arcane = Mixin({
		effectFileID = ArcaneImpact,
		actorScale = 0.35,
	}, StandardImpactShake),

	Shock = Mixin({
		effectFileID = LightningImpact,
	}, StandardImpactShake),

	Starsurge = Mixin({
		effectFileID = StarsurgeImpact,
	}, StandardImpactShake),

	Flamestrike = Mixin({
		effectFileID = FlamestrikeImpact,
		actorScale = 0.5,
	}, StandardImpact),

	Argus = Mixin({
		effectFileID = ArgusImpact,
		onStart = StandardKnockback,
	}, StandardImpact),

	FireMissileImpact = {
		trajectory = InOutTrajectory,
		duration = LongImpactDuration,
		effectFileID = FireMissileEffect,
	},
};

ScriptedAnimationEffects = {
	Fireball = {
		effectFileID = FireballEffect,
		trajectory = LinearTrajectory,
		duration = StandardEffectDuration,
		impact = ScriptedAnimationImpacts.ExplosionRecoil,
		onStart = StandardRecoil,
	},

	ArcaneMissile = {
		effectFileID = ArcaneEffect,
		actorScale = 0.5,
		trajectory = StandardCurveTrajectory,
		duration = MissileProjectileDuration,
		impact = ScriptedAnimationImpacts.Arcane,
		onStart = ArcaneMissileSequence,
	},

	LightningOrb = {
		effectFileID = LightningEffect,
		trajectory = LinearTrajectory,
		duration = StandardEffectDuration,
		impact = ScriptedAnimationImpacts.Shock,
	},

	Starsurge = {
		effectFileID = StarsurgeEffect,
		trajectory = LinearTrajectory,
		duration = StandardEffectDuration,
		impact = ScriptedAnimationImpacts.Starsurge,
	},

	Regrowth = {
		effectFileID = RegrowthEffect,
		actorScale = 5.0,
		trajectory = TargetStaticTrajectory,
		duration = StandardEffectDuration,
	},

	FireMissileRing = {
		effectFileID = FireQuakeEffect,
		actorScale = 0.75,
		trajectory = TargetStaticTrajectory,
		duration = QuickProjectileDuration,
		impact = ScriptedAnimationImpacts.Flamestrike,
		ringImpact = ScriptedAnimationImpacts.FireMissileImpact,
		onFinish = GenerateImpactRing,
	},

	ShockTarget = ScriptedAnimationImpacts.Shock,

	ArgusCollide = {
		effectFileID = ArgusEffect,
		trajectory = SourceStaticTrajectory,
		duration = StandardCollisionDuration,
		impact = ScriptedAnimationImpacts.Argus,
		onStart = StandardAttackCollision,
	},
};
