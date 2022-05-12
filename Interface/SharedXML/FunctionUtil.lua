function ExecuteFrameScript(frame, scriptName, ...)
	local script = frame:GetScript(scriptName);
	if script then
		xpcall(script, CallErrorHandler, frame, ...);
	end
end

function CallMethodOnNearestAncestor(self, methodName, ...)
	local ancestor = self:GetParent();
	while ancestor and not ancestor[methodName] do
		ancestor = ancestor:GetParent();
	end

	if ancestor then
		return true, ancestor[methodName](ancestor, ...);
	end

	return false;
end

function GetValueOrCallFunction(tbl, key, ...)
	if not tbl then
		return;
	end

	local value = tbl[key];
	if type(value) == "function" then
		return value(...);
	else
		return value;
	end
end

-- [[ Closure generation ]]

local closureGeneration = {
	function(f) return function(...) return f(...); end end,
	function(f, a) return function(...) return f(a, ...); end end,
	function(f, a, b) return function(...) return f(a, b, ...); end end,
	function(f, a, b, c) return function(...) return f(a, b, c, ...); end end,
	function(f, a, b, c, d) return function(...) return f(a, b, c, d, ...); end end,
};

function GenerateClosure(f, ...)
    local count = select("#", ...);
    local generator = closureGeneration[count + 1];
    if generator then
    	return generator(f, ...);
    end
    error("Closure generation does not support more than "..(#closureGeneration - 1).." parameters");
 end
