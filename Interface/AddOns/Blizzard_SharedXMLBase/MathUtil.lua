
MathUtil = 
{
	Epsilon = .000001,
};

MathUtil.ApproxZero = MathUtil.Epsilon;
MathUtil.ApproxOne = 1.0 - MathUtil.Epsilon;

-- Global aliases for backwards compatibility.
Clamp = math.clamp;
Lerp = math.lerp;
PercentageBetween = math.normalize;
Round = math.round;
RoundToSignificantDigits = math.round;
Saturate = math.saturate;
Sign = math.sign;

local securecallfunction = securecallfunction;
function CreateCounter(initialCount, step)
	local count = initialCount or 0;
	step = step or 1;
	local counter = function()
		count = count + step;
		return count;
	end;
    return function()
        return securecallfunction(counter);
    end;
end

function Wrap(value, max)
	-- math.wrap uses a half-open [min, max) interval.
	return math.wrap(value, 1, max + 1);
end

function ClampDegrees(value)
	return math.wrap(value, 0, 360);
end

function ClampMod(value, mod)
	return math.wrap(value, 0, mod);
end

function NegateIf(value, condition)
	return condition and -value or value;
end

function PercentageBetween(value, startValue, endValue)
	if startValue == endValue then
		return 0.0;
	end
	return (value - startValue) / (endValue - startValue);
end

function ClampedPercentageBetween(value, startValue, endValue)
	return math.saturate(math.normalize(value, startValue, endValue));
end

local TARGET_FRAME_PER_SEC = 60.0;
function DeltaLerp(startValue, endValue, amount, timeSec)
	return math.lerp(startValue, endValue, math.saturate(amount * timeSec * TARGET_FRAME_PER_SEC));
end

function FrameDeltaLerp(startValue, endValue, amount)
	return DeltaLerp(startValue, endValue, amount, GetTickTime());
end

function RandomFloatInRange(minValue, maxValue)
	return math.lerp(minValue, maxValue, math.random());
end

-- Rounds the value to to the closest multiple of the passed multiplier
-- Ex: (55, 50) => 50, (85, 50) => 100
function RoundToNearestMultiple(value, multiplier)
	return math.round(value / multiplier) * multiplier;
end

function Square(value)
	return value * value;
end

function WithinRange(value, min, max)
	return value >= min and value <= max;
end

function WithinRangeExclusive(value, min, max)
	return value > min and value < max;
end

function ApproximatelyEqual(v1, v2, epsilon)
	return math.abs(v1 - v2) < (epsilon or MathUtil.Epsilon);
end

function CalculateDistanceSq(x1, y1, x2, y2)
	local dx = x2 - x1;
	local dy = y2 - y1;
	return (dx * dx) + (dy * dy);
end

function CalculateDistance(x1, y1, x2, y2)
	return math.sqrt(CalculateDistanceSq(x1, y1, x2, y2));
end

function CalculateAngleBetween(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1);
end

AccumulatorMixin = {};

function AccumulatorMixin:Init(initialCount)
	self.count = initialCount or 0;
end

function AccumulatorMixin:Add(count)
	self.count = self.count + count;
	return self.count;
end

function AccumulatorMixin:Subtract(count)
	self.count = self.count - count;
	return self.count;
end

function AccumulatorMixin:Count()
	return self.count;
end

function AccumulatorMixin:Reset(resetCount)
	self.count = resetCount or 0;
end

function CreateAccumulator(initialCount)
	return CreateAndInitFromMixin(AccumulatorMixin, initialCount);
end
