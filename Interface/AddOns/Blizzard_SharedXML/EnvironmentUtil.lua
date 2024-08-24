function InGlue()
	return IsOnGlueScreen and IsOnGlueScreen();
end

function nop()
end

function GetGlobalEnvironment()
	return getfenv(0);
end

function GetCurrentEnvironment()
	-- 2 because we want the environment of the caller, not this function
	return getfenv(2);
end

function IsInGlobalEnvironment()
	-- NOTE: This can't use GetCurrentEnvironment; it would neet to check getfenv(3)
	return getfenv(2) == GetGlobalEnvironment();
end

function SwapToGlobalEnvironment()
	-- 2 because we want to swap the environment of the caller, not this function
	setfenv(2, GetGlobalEnvironment());
end
	