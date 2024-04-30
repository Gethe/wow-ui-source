--Overrides the shared CvarUtil.lua SetCvar function. 10.0 refactor removed 'eventName' and other associated code on Mainline. Until Classic
--brings over those changes, we want the 'eventName' passed along in this function.
function SetCVar(name, value, eventName)
	if type(value) == "boolean" then
		return C_CVar.SetCVar(name, value and "1" or "0", eventName);
	else
		return C_CVar.SetCVar(name, value and tostring(value) or nil, eventName);
	end
end