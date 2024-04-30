Settings.Variables = {};

local function MatchesVariableType(arg1, arg2VariableType)
	return type(arg1) == arg2VariableType;
end

local function ErrorIfInvalidSettingArguments(name, variable, variableType, defaultValue)
	if type(name) ~= "string" then
		error(string.format("'name' for variable '%s' requires string type.", variable));
	end

	if type(variable) ~= "string" then
		error(string.format("'variable' for '%s' requires string type.", name));
	end
	
	if (defaultValue ~= nil) and not MatchesVariableType(defaultValue, variableType) then
		error(string.format("'defaultValue' argument for '%s', '%s' required '%s' type.", name, variable, variableType));
	end
end

local function ValuesEquivalent(v1, v2)
	if type(v1) == "number" and type(v2) == "number" then
		return ApproximatelyEqual(v1, v2);
	end
	return v1 == v2;
end

SettingMixin = {};

function SettingMixin:Init(name, variable, variableType)
	self.name = name;
	self.variable = variable;
	self.variableType = variableType;
	self.commitFlags = Settings.CommitFlag.None;
	self.ignoreApplyOverride = nil;
end

function SettingMixin:GetName()
	return self.name;
end

function SettingMixin:GetVariable()
	return self.variable;
end

function SettingMixin:GetVariableType()
	return self.variableType;
end

function SettingMixin:GetValue()
	local value = self:GetValueInternal();
	return value;
end

function SettingMixin:SetValue(value, force)
	if self.pendingValue ~= nil then
		return;
	end

	local currentValue = self:GetValue();
	local equivalentValue = ValuesEquivalent(currentValue, value);
	if not force and equivalentValue then
		return;
	end

	local originalValue = self.originalValue;
	local newValue = self:SetValueInternal(value);

	if (originalValue == nil) and not equivalentValue then
		originalValue = currentValue;
		self.originalValue = currentValue;
	elseif ValuesEquivalent(originalValue, newValue) then
		self.originalValue = nil;
	end

	SettingsCallbackRegistry:TriggerEvent(self:GetVariable(), self, newValue, currentValue, originalValue);
end

function SettingMixin:ReinitializeValue(value)
	self:Revert();

	local force = true;
	self:SetValue(value, force);
end

function SettingMixin:Revert()
	if self.originalValue ~= nil then
		self:SetValue(self.originalValue);
	end
end

function SettingMixin:GetOriginalValue()
	return self.originalValue;
end

function SettingMixin:GetCommitOrder()
	return self.commitOrder or 0;
end

function SettingMixin:SetCommitOrder(order)
	self.commitOrder = order;
end

function SettingMixin:SetCommitFlags(...)
	for index = 1, select("#", ...) do
		self:AddCommitFlag(select(index, ...));
	end
end

function SettingMixin:AddCommitFlag(flag)
	self.commitFlags = bit.bor(self.commitFlags, flag);
end

function SettingMixin:RemoveCommitFlag(flag)
	if self:HasCommitFlag(flag) then
		self.commitFlags = bit.bxor(self.commitFlags, flag);
	end
end

function SettingMixin:HasCommitFlag(flag)
	return bit.band(self.commitFlags, flag) > 0;
end

function SettingMixin:SetIgnoreApplyOverride(state)
	self.ignoreApplyOverride = state;
end

function SettingMixin:UpdateIgnoreApplyFlag()
	if self.ignoreApplyOverride == true then
		self:AddCommitFlag(Settings.CommitFlag.IgnoreApply);
	elseif self.ignoreApplyOverride == false then
		self:RemoveCommitFlag(Settings.CommitFlag.IgnoreApply);
	end
end

function SettingMixin:IsModified()
	return (self.originalValue ~= nil) and not ValuesEquivalent(self.originalValue, self:GetValue());
end

function SettingMixin:Commit()
	if self.originalValue ~= nil then
		self.originalValue = nil;
	end

	if self.commitValue then
		self.commitValue(self:GetValue());
	end
end

function SettingMixin:SetValueToDefault()
	local defaultValue = self:GetDefaultValueInternal();
	if (defaultValue ~= nil) and (defaultValue ~= self:GetValue()) then
		self:SetValue(defaultValue);
		self:Commit();
		return true;
	end
	return false;
end

function SettingMixin:GetDefaultValue()
	return self:GetDefaultValueInternal();
end

function SettingMixin:IsNewTagShown()
	return self.newTagShown;
end

function SettingMixin:SetNewTagShown(shown)
	self.newTagShown = shown;
end

CVarSettingMixin = CreateFromMixins(SettingMixin);

function CVarSettingMixin:Init(name, cvar, variableType)
	ErrorIfInvalidSettingArguments(name, cvar, variableType);
	SettingMixin.Init(self, name, cvar, variableType);
	
	local cvarAccessor = CreateCVarAccessor(cvar, variableType);
	
	self.GetValueInternal = function(self)
		return cvarAccessor:GetValue();
	end;

	self.SetValueInternal = function(self, value)
		assert(type(value) == variableType);
		self.pendingValue = value;
		cvarAccessor:SetValue(value);
		self.pendingValue = nil;
		return value;
	end
	
	self.GetDefaultValueInternal = function(self)
		return cvarAccessor:GetDefaultValue();
	end

	-- SetValue is deliberately type strict. ConvertValueInternal is exposed for the
	-- settings system to convert cvar values to the expected type.
	self.ConvertValueInternal = function(self, value)
		return cvarAccessor:ConvertValue(value);
	end
end

-- Lua setting creates a variable when initialized. This can be used to represent state 
-- for multiple variables. For example, a setting have two values, true and false, 
-- but changing its value may result in 4 different CVars being changed.
ProxySettingMixin = CreateFromMixins(SettingMixin);

function ProxySettingMixin:Init(name, variable, variableTbl, variableType, defaultValue, getValue, setValue, commitValue)
	ErrorIfInvalidSettingArguments(name, variable, variableType, defaultValue);
	SettingMixin.Init(self, name, variable, variableType);

	-- Default value is optional, and the setting will not be changed if the setting is "defaulted".
	-- However if it is omitted, getValue must be provided to set the initial value. 
	self.defaultValue = defaultValue;
	assert((defaultValue == nil) or MatchesVariableType(defaultValue, variableType));
	
	if variableTbl == nil then
		variableTbl = Settings.Variables;
	end

	self.GetValueInternal = function(self)
		local value = variableTbl[variable];
		assert(MatchesVariableType(value, variableType));
		return value;
	end;

	self.SetValueInternal = function(self, value)
		if not MatchesVariableType(value, variableType) then
			error(string.format("SetValue '%s' requires '%s' type, not '%s' type.", name, variableType, type(value)));
		end
		variableTbl[variable] = value;
		return value;
	end;

	self.GetDefaultValueInternal = function(self)
		return self.defaultValue;
	end;

	-- A valid value must be obtainable at the time the setting is initialized. In the case of saved variables,
	-- the setting is expected to be initialized after SETTINGS_LOADED (includes PEW and VARIABLES_LOADED). 
	-- If it is not, the default value will be assigned, and the value could be inaccurate if read before that event. 
	-- If this is not a saved variable, then the value is expected to be obtained from the getValue function.
	if variableTbl[variable] == nil then
		if getValue ~= nil then
			local v = getValue();
			--assert(v ~= nil, "getValue must return a value, but is returning nil.");
			self:SetValueInternal(v);
		elseif self.defaultValue ~= nil then
			self:SetValueInternal(self.defaultValue);
		else
			error("Setting cannot be created without an obtainable initial value.");
		end
	end
	
	-- Whenever the underlying variable is set, the setValue function is called to allow for
	-- additional changes. For internal settings, this typically results in changing multiple
	-- cvars. This wrapper occurs after the initial value is set so that we don't invoke the
	-- set callback as part of initialization above.
	if setValue then
		local oldSetValueInternal = self.SetValueInternal;
		self.SetValueInternal = function(self, value)
			setValue(oldSetValueInternal(self, value));
			return value;
		end
	end

	-- commitValue can be leveraged to treat the setting value as a temporary value. For example, a dropdown
	-- in the graphics list may have it's value changed from 1 to 2 without immediately making undesired cvar changes.
	self.commitValue = commitValue;
	
	-- initValue is the function that we used to set the original value (getValue). We save it so
	-- we can later reinitialize the setting from an external source if required.
	self.initValue = getValue;
end

function ProxySettingMixin:GetInitValue()
	if self.initValue then
		return self.initValue();
	end
	
	return self.defaultValue;
end

ModifiedClickSettingMixin = CreateFromMixins(SettingMixin);

function ModifiedClickSettingMixin:Init(name, modifier, defaultValue)
	SettingMixin.Init(self, name, modifier);

	self.defaultValue = defaultValue;
	assert((defaultValue == nil) or MatchesVariableType(defaultValue, Settings.VarType.String));

	self.GetValueInternal = function(self)
		return GetModifiedClick(modifier);
	end;

	self.SetValueInternal = function(self, value)
		assert(MatchesVariableType(value, Settings.VarType.String));
		SetModifiedClick(modifier, value);
		return value;
	end;

	self.GetDefaultValueInternal = function(self)
		return defaultValue;
	end;

	self:SetCommitFlags(Settings.CommitFlag.SaveBindings);
end

AddOnSettingMixin = CreateFromMixins(SettingMixin);

function AddOnSettingMixin:Init(name, variable, variableType, defaultValue)
	SettingMixin.Init(self, name, variable, variableType)

	self.defaultValue = defaultValue;
	self.internalValue = defaultValue;
end

function AddOnSettingMixin:SetValueInternal(value)
	self.internalValue = value;
	return value;
end

function AddOnSettingMixin:GetDefaultValueInternal()
	return self.defaultValue;
end

function AddOnSettingMixin:GetValueInternal()
	return self.internalValue;
end
