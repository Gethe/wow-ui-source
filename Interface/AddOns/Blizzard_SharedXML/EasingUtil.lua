EasingUtil = {};

local function EaseIn(percent, power)
    return percent ^ power;
end

local function EaseOut(percent, power)
    return 1.0 - (1.0 - percent) ^ power;
end

local function EaseOutIn(percent, power)
    if percent < .5 then
        return (percent * 2.0) ^ power * .5;
    end
    return 1.0 - ((1.0 - percent) * 2.0) ^ power * .5;
end


function EasingUtil.InQuadratic(percent)
    return EaseIn(percent, 2);
end

function EasingUtil.OutQuadratic(percent)
    return EaseOut(percent, 2);
end

function EasingUtil.InOutQuadratic(percent)
    return EaseOutIn(percent, 2);
end


function EasingUtil.InCubic(percent)
    return EaseIn(percent, 3);
end

function EasingUtil.OutCubic(percent)
    return EaseOut(percent, 3);
end

function EasingUtil.InOutCubic(percent)
    return EaseOutIn(percent, 3);
end


function EasingUtil.InQuartic(percent)
    return EaseIn(percent, 4);
end

function EasingUtil.OutQuartic(percent)
    return EaseOut(percent, 4);
end

function EasingUtil.InOutQuartic(percent)
    return EaseOutIn(percent, 4);
end


function EasingUtil.InQuintic(percent)
    return EaseIn(percent, 5);
end

function EasingUtil.OutQuintic(percent)
    return EaseOut(percent, 5);
end

function EasingUtil.InOutQuintic(percent)
    return EaseOutIn(percent, 5);
end

function EasingUtil.InExponential(percent)
	if percent == 0 then
		return 0;
	end

	return 2 ^ (10 * (percent - 1));
end

function EasingUtil.OutExponential(percent)
	if percent == 1 then
		return 1;
	end

	return 1 - 2 ^ (-10 * percent);
end

function EasingUtil.InOutExponential(percent)
	if (percent == 0) or (percent == 1) then
		return percent;
	elseif percent < 0.5 then
		return 2 ^ (20 * percent - 11);
	end

	return 1 - 2 ^ (9 - 20 * percent);
end

function EasingUtil.OutBack(percent)
	local c1 = 1.70158;  -- Overshoot the target by 10% (supposedly).
	local c3 = c1 + 1;
	return 1 + c3 * ((percent - 1) ^ 3) + c1 * ((percent - 1) ^ 2);
end
