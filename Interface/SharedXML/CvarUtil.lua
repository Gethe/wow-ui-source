function RegisterCVar(name, value)
	C_CVar.RegisterCVar(name, value);
end

function ResetTestCvars()
	C_CVar.ResetTestCVars();
end

function SetCVar(name, value)
	if type(value) == "boolean" then
		return C_CVar.SetCVar(name, value and "1" or "0");
	else
		return C_CVar.SetCVar(name, value and tostring(value) or nil);
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

-- Assumes every value stored in the cvar is of the same type. The purpose
-- of using this accessor is to add type strictness to avoid scenarios where
-- nil is implicitly converted to "0" or false and to relieve the callsites of
-- casting concerns.
CVarAccessorMixin = {};

function CVarAccessorMixin:Init(cvar, variableType)
	if variableType == "boolean" then
		self.ConvertValue = function(self, value)
			return value and value ~= "0";
		end;
	elseif variableType == "number" then
		self.ConvertValue = function(self, value)
			return tonumber(value);
		end;
	elseif variableType == "string" then
		self.ConvertValue = function(self, value)
			return (value ~= nil) and tostring(value) or "";
		end;
	end

	self.GetValue = function(self)
		local rawValue = GetCVar(cvar);
		return self:ConvertValue(rawValue);	
	end;

	self.SetValue = function(self, value)
		if type(value) ~= variableType then
			error(string.format("SetValue requires '%s' type", variableType));
		end
		SetCVar(cvar, value);
	end;

	self.GetDefaultValue = function(self)
		local rawValue = GetCVarDefault(cvar);
		return self:ConvertValue(rawValue);
	end;
end

function CreateCVarAccessor(cvar, variableType)
	if variableType ~= "number" and variableType ~= "boolean" and variableType ~= "string" then
		error(string.format("CreateCVarAccessor requires 'number', 'boolean' or 'string' type. Provided '%s' type.", variableType));
	end
	return CreateAndInitFromMixin(CVarAccessorMixin, cvar, variableType);
end

CVarCallbackRegistry = CreateFromMixins(CallbackRegistryMixin);
CVarCallbackRegistry:GenerateCallbackEvents(
	{
		"OnCVarChanged",
	}
);

function CVarCallbackRegistry:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.cachable = {};
	self.cvarValueCache = {};

	self:SetScript("OnEvent", self.OnEvent);

	self:RegisterEvent("CVAR_UPDATE");
end

function CVarCallbackRegistry:OnEvent(event, ...)
	if event == "CVAR_UPDATE" then
		local cvar, value = ...;

		if self.cachable[cvar] then
			self.cvarValueCache[cvar] = value;
		end

		self:TriggerEvent(CVarCallbackRegistry.Event.OnCVarChanged, cvar, value);
		self:TriggerEvent(cvar, value);
	end
end

function CVarCallbackRegistry:GetCVarValue(cvar)
	if self.cachable[cvar] and not self.cvarValueCache[cvar] then
		self.cvarValueCache[cvar] = GetCVar(cvar);
	end

	if self.cvarValueCache[cvar] then
		return self.cvarValueCache[cvar];
	end
	return GetCVar(cvar);
end

function CVarCallbackRegistry:GetCVarValueBool(cvar)
	local value = self:GetCVarValue(cvar);
	return value and value ~= "0";
end

function CVarCallbackRegistry:SetCVarCachable(cvar)
	self.cachable[cvar] = true;
end

function CVarCallbackRegistry:RegisterCVarChangedCallback(func, owner, ...)
	return self:RegisterCallback(CVarCallbackRegistry.Event.OnCVarChanged, func, owner, ...);
end

CVarCallbackRegistry = Mixin(CreateFrame("Frame"), CVarCallbackRegistry);
CVarCallbackRegistry:OnLoad();
CVarCallbackRegistry:SetUndefinedEventsAllowed(true);