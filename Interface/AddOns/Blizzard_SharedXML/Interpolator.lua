---------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;

if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
		Import("C_StoreGlue");
	end

	setfenv(1, tbl);

	Import("ApproximatelyEqual");
	Import("math");
	Import("GetTickTime");
	Import("Saturate");
end
----------------

InterpolatorUtil = {};

function InterpolatorUtil.InterpolateLinear(v1, v2, t)
	return (v1 * (1 - t)) + (v2 * t);
end

function InterpolatorUtil.InterpolateEaseOut(v1, v2, t)
	local y = math.sin(t * (math.pi * .5));
	return (v1 * (1 - y)) + (v2 * y);
end

InterpolatorMixin = {}

function InterpolatorMixin:Interpolate(v1, v2, time, setter, finished)
	if self.interpolateTo and ApproximatelyEqual(v1, v2) then
		return;
	end
	self.interpolateTo = v2;

	if self.timer then
		self.timer:Cancel();
		self.timer = nil;
	end

	time = math.max(0, time);
	local elapsed = 0;
	local interpolate = function()
		elapsed = elapsed + GetTickTime();
		local u = (time > 0) and Saturate(elapsed / time) or 1;
		setter(self.interpolateFunc(v1, v2, u));
		if u >= 1 then
			if finished then
				finished();
			end

			self:Cancel();
			return false;
		end

		return true;
	end;

	local continue = interpolate();
	if continue then
		self.timer = C_Timer.NewTicker(0, interpolate);
	end
end

function InterpolatorMixin:GetInterpolateTo()
	return self.interpolateTo;
end

function InterpolatorMixin:Cancel()
	self.interpolateTo = nil;
	if self.timer then
		self.timer:Cancel();
		self.timer = nil;
	end
end

function CreateInterpolator(interpolateFunc)
	local interpolator = CreateFromMixins(InterpolatorMixin);
	interpolator.interpolateFunc = interpolateFunc or InterpolatorUtil.InterpolateEaseOut;
	return interpolator;
end