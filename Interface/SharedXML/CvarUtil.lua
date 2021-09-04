function RegisterCVar(name, value)
	C_CVar.RegisterCVar(name, value);
end

function ResetTestCvars()
	C_CVar.ResetTestCVars();
end

function SetCVar(name, value, eventName)
	if type(value) == "boolean" then
		return C_CVar.SetCVar(name, value and "1" or "0", eventName);
	else
		return C_CVar.SetCVar(name, value and tostring(value) or nil, eventName);
	end
end

function GetCVar(name)
	return C_CVar.GetCVar(name);
end

function SetCVarBitfield(name, index, value, scriptCVar)
	return C_CVar.SetCVarBitfield(name, index, value, scriptCVar);
end

function GetCVarBitfield(name, index)
	return C_CVar.GetCVarBitfield(name, index);
end

function GetCVarBool(name)
	return C_CVar.GetCVarBool(name);
end

function GetCVarDefault(name)
	return C_CVar.GetCVarDefault(name);
end
