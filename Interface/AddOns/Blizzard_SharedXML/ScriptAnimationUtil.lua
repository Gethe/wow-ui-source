
ScriptAnimationUtil = {};

function ScriptAnimationUtil.GetScriptAnimationLock(region)
	if region.scriptedAnimatedAnchorLock then
		return false;
	end

	region.scriptedAnimatedAnchorLock = true;
	return true;
end

function ScriptAnimationUtil.ReleaseScriptAnimationLock(region)
	region.scriptedAnimatedAnchorLock = nil;
end

function ScriptAnimationUtil.IsScriptAnimationLockActive(region)
	return region.scriptedAnimatedAnchorLock ~= nil;
end

function ScriptAnimationUtil.ShakeFrameRandom(region, magnitude, duration, frequency)
	if frequency <= 0 or ScriptAnimationUtil.IsScriptAnimationLockActive(region) then
		return nop;
	end

	local shake = {};
	for i = 1, math.ceil(duration / frequency) do
		local xVariation, yVariation = RandomFloatInRange(-magnitude, magnitude), RandomFloatInRange(-magnitude, magnitude);
		shake[i] = { x = xVariation, y = yVariation };
	end

	return ScriptAnimationUtil.ShakeFrame(region, shake, duration, frequency);
end

function ScriptAnimationUtil.ShakeFrame(region, shake, maximumDuration, frequency)
	local shakeStrength = tonumber(GetCVar("ShakeStrengthUI"));
	if shakeStrength <= 0 or not ScriptAnimationUtil.GetScriptAnimationLock(region) then
		return nop;
	end

	local point, relativeRegion, relativePoint, x, y = region:GetPoint(1);
	local shakeIndex = 1;
	local endTime = GetTime() + maximumDuration;

	local function CancelShake()
		region:SetPoint(point, relativeRegion, relativePoint, x, y);
		region.shakeTicker:Cancel();
		region.shakeTicker = nil;
		ScriptAnimationUtil.ReleaseScriptAnimationLock(region);
	end

	region.shakeTicker = C_Timer.NewTicker(frequency, function()
		local xVariation, yVariation = shake[shakeIndex].x * shakeStrength, shake[shakeIndex].y * shakeStrength;
		region:SetPoint(point, relativeRegion, relativePoint, x + xVariation, y + yVariation);
		shakeIndex = shakeIndex + 1;
		if shakeIndex > #shake or GetTime() >= endTime then
			CancelShake();
		end
	end);

	return CancelShake;
end

local function NoEasing(progress)
	return progress;
end

function ScriptAnimationUtil.GenerateEasedVariationCallback(easingFunction, distanceX, distanceY, alpha, scale)
	distanceX = distanceX or 0;
	distanceY = distanceY or 0;
	alpha = alpha or 0;
	scale = scale or 0;

	local function VariationCallback(elapsedTime, duration)
		local progress = (easingFunction and easingFunction(elapsedTime / duration)) or (elapsedTime / duration);
		return distanceX * progress, distanceY * progress, alpha * progress, scale * progress;
	end

	return VariationCallback;
end


function ScriptAnimationUtil.StartScriptAnimation(region, variationCallback, duration, onFinish)
	if not ScriptAnimationUtil.GetScriptAnimationLock(region) then
		if onFinish then
			onFinish();
		end
		return nop;
	end

	variationCallback = variationCallback;

	local point, relativeRegion, relativePoint, x, y = region:GetPoint(1);
	local alpha = region:GetAlpha();
	local scale = region:GetScale();

	local function ApplyVariation(variationX, variationY, variationAlpha, variationScale)
		region:SetPoint(point, relativeRegion, relativePoint, x + (variationX or 0), y + (variationY or 0));
		region:SetAlpha(alpha + (variationAlpha or 0));
		region:SetScale(scale + (variationScale or 0));
	end

	local startTime = GetTime();
	local endTime = startTime + duration;
	local elapsedTime = 0;
	ApplyVariation(variationCallback(elapsedTime, duration));

	local function CancelScriptAnimation()
		ApplyVariation(variationCallback(duration, duration));
		region.translationTicker:Cancel();
		region.translationTicker = nil;
		ScriptAnimationUtil.ReleaseScriptAnimationLock(region);
		if onFinish then
			onFinish();
		end
	end

	local function TranslationTickerFunction()
		local currentTime = GetTime();

		local finished = GetTime() >= endTime;
		if finished then
			CancelScriptAnimation();
		else
			elapsedTime = currentTime - startTime;
			ApplyVariation(variationCallback(elapsedTime, duration));
		end
	end

	region.translationTicker = C_Timer.NewTicker(0.01, TranslationTickerFunction);

	return CancelScriptAnimation;
end
