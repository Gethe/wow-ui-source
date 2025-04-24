local function EnsureVariableTypeIsValid(variableType, defaultValue)
	if variableType == nil then
		assert(defaultValue ~= nil);
		variableType = type(defaultValue);
	end
	return variableType;
end

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
	
	if type(variableType) ~= "string" then
		error(string.format("'variableType' for '%s', '%s' requires string type.", name, variable));
	end

	if (defaultValue ~= nil) and not MatchesVariableType(defaultValue, variableType) then
		error(string.format("'defaultValue' argument for '%s', '%s' required '%s' type.", name, variable, variableType));
	end
end

local function ErrorIfInvalidVariableType(name, value, variableType)
	if not MatchesVariableType(value, variableType) then
		error(string.format("SetValue '%s' requires '%s' type, not '%s' type.", name, variableType, type(value)));
	end
end

local function ValuesApproximatelyEqual(v1, v2)
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
	if self.pendingValue ~= nil then
		return self.pendingValue;
	end

	local currentValue = self:GetValueDerived();
	return currentValue;
end

-- 'immediate' is expected when committing applyable values or forcing
-- a value such as in cases like choosing defaults or reassigning a value
-- in the process of doing a revert.
function SettingMixin:SetValue(value, immediate)
	-- Stops reentrancy. For example, assigning a cvar setting triggers a CVAR_UPDATE 
	-- event that causes the settings system to try and update this setting.
	if self:IsLocked() then
		return;
	end

	if immediate or not (self:HasCommitFlag(Settings.CommitFlag.Apply)) then
		self:ApplyValue(value);
	else
		local currentValue = self:GetValueDerived();
		if ValuesApproximatelyEqual(currentValue, value) then
			-- Discard the pending value to return it to it's original state.
			self:ClearPendingValue();
		else
			-- The value is pending write by the commit step.
			self:SetPendingValue(value);
		end

		-- Notify so that controls can display this value.
		self:TriggerValueChanged(value);
	end
end

function SettingMixin:ApplyValue(value)
	self:ClearPendingValue();

	local currentValue = self:GetValueDerived();
	if currentValue ~= value then
		ErrorIfInvalidVariableType(self.name, value, self.variableType);

		self:SetLocked(true);
		self:SetValueDerived(value);
		self:SetLocked(false);
	end

	self:TriggerValueChanged(value);
end

function SettingMixin:SetValueToDefault()
	local defaultValue = self:GetDefaultValueDerived();
	if defaultValue == nil then
		return false;
	end
	
	self:ApplyValue(defaultValue);

	return true;
end

function SettingMixin:Commit()
	if self.pendingValue ~= nil then
		self:ApplyValue(self.pendingValue);
	else
		assertsafe(false, "Tried to commit setting '%s' without a pending value.", self.name);
	end

end

function SettingMixin:SetPendingValue(value)
	self.pendingValue = value;
end

function SettingMixin:ClearPendingValue()
	self.pendingValue = nil;
	self.lockPendingValue = false;
end

-- Revert discards the pending value and then notifies listeners to read
-- the current value again.
function SettingMixin:Revert()
	if self.lockPendingValue then
		return false;
	end

	self:ClearPendingValue();

	self:NotifyUpdate();
end

-- Informs any listeners the value changed and it's current value needs to be read again. 
-- This is only called externally in cases where the underlying value changed was a source other than the
-- setting object. A good example here is the Self Highlight option in unit popups, where the set of options
-- described on the setting is less granular than that displayed in the popup context menu. The context menu
-- changes the underlying cvars that then need to be reevaluated by the setting.
function SettingMixin:NotifyUpdate()
	local currentValue = self:GetValueDerived();
	self:TriggerValueChanged(currentValue);
end

-- If a dependent setting has its value changed, any value changed callbacks may
-- try to revert other settings with the intention of obtaining a new valid display value. 
-- It doesn't distinguish between reinitialization and a value being changed due to the commit step.
-- This is called at the beginning of the commit process to ensure all settings have their
-- pending values retained until the commit is done.
function SettingMixin:LockPendingValue()
	self.lockPendingValue = true;
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
	if self.pendingValue == nil then
		return false;
	end

	local currentValue = self:GetValueDerived();
	local equal = ValuesApproximatelyEqual(currentValue, self.pendingValue);
	return not equal;
end

function SettingMixin:GetDefaultValue()
	return self:GetDefaultValueDerived();
end

function SettingMixin:SetLocked(locked)
	self.locked = locked;
end

function SettingMixin:IsLocked()
	return self.locked;
end

function SettingMixin:TriggerValueChanged(value)
	SettingsCallbackRegistry:TriggerEvent(self.variable, self, value);
end

function SettingMixin:SetValueChangedCallback(callback)
	Settings.SetOnValueChangedCallback(self.variable, function(_, setting, value)
		callback(setting, value);
	end);
end

CVarSettingMixin = CreateFromMixins(SettingMixin);

function CVarSettingMixin:Init(name, cvar, variableType)
	ErrorIfInvalidSettingArguments(name, cvar, variableType);
	SettingMixin.Init(self, name, cvar, variableType);
	
	local cvarAccessor = CreateCVarAccessor(cvar, variableType);
	
	self.GetValueDerived = function(self)
		local value = cvarAccessor:GetValue();
		return self:TransformValue(value);
	end;

	self.SetValueDerived = function(self, value)
		value = self:TransformValue(value);
		cvarAccessor:SetValue(value);
	end
	
	self.GetDefaultValueDerived = function(self)
		local value = cvarAccessor:GetDefaultValue();
		return self:TransformValue(value);
	end

	-- SetValue is deliberately type strict. ConvertValueInternal is exposed for the
	-- settings system to convert cvar values to the expected type.
	self.ConvertValueInternal = function(self, value)
		return cvarAccessor:ConvertValue(value);
	end
end

function CVarSettingMixin:TransformValue(value)
	if self.valueTransformer then
		return self.valueTransformer(value);
	end
	return value;
end

do
	-- Add additional transforms as necessary so it's not necessary to create ProxySettings just
	-- to remap inbound and outbound values. May be moved to SettingMixin if other setting types
	-- can take advantage of this. See VoiceVADSensitivity as an example for another transform.
	local function NegateBoolean(value)
		return not value;
	end
	
	function CVarSettingMixin:NegateBoolean()
		assert(self.variableType == Settings.VarType.Boolean);
		self.valueTransformer = NegateBoolean;
	end
end

ProxySettingMixin = CreateFromMixins(SettingMixin);

do
	local function SecureGetValueDerived(setting)
		return setting.getValue();
	end
	
	local function SecureSetValueDerived(setting, value)
		setting.setValue(value);
	end

	function ProxySettingMixin:Init(name, variable, variableType, defaultValue, getValue, setValue)
		variableType = EnsureVariableTypeIsValid(variableType, defaultValue);

		ErrorIfInvalidSettingArguments(name, variable, variableType, defaultValue);
		SettingMixin.Init(self, name, variable, variableType);
	
		self.getValue = getValue;
		self.setValue = setValue;
	
		self.GetValueDerived = function(self)
			return securecallfunction(SecureGetValueDerived, self);
		end;
		
		self.SetValueDerived = function(self, value)
			securecallfunction(SecureSetValueDerived, self, value);
		end;
	
		self.GetDefaultValueDerived = function(self)
			return defaultValue;
		end;
	end
end

ModifiedClickSettingMixin = CreateFromMixins(SettingMixin);

function ModifiedClickSettingMixin:Init(name, modifier, defaultValue)
	SettingMixin.Init(self, name, modifier, Settings.VarType.String);

	self.GetValueDerived = function(self)
		return GetModifiedClick(modifier);
	end;

	self.SetValueDerived = function(self, value)
		SetModifiedClick(modifier, value);
	end;

	self.GetDefaultValueDerived = function(self)
		return defaultValue;
	end;

	self:SetCommitFlags(Settings.CommitFlag.SaveBindings);
end

AddOnSettingMixin = CreateFromMixins(SettingMixin);

--[[
'variable' uniquely identifies your setting and must not conflict with any addons. Prefixing this identifier
with your addon name is highly recommended.
'variableKey' is your value's key in your saved variable table.
'variableTbl' is your saved variable table hopefully defined in your addon's .toc.
]]--

do
	local function SecureSetVariableTblDefaultValue(variableKey, variableTbl, defaultValue)
		if variableTbl[variableKey] == nil then
			variableTbl[variableKey] = defaultValue;
		end
	end
	
	local function SecureGetValueDerived(setting)
		return setting.variableTbl[setting.variableKey];
	end
	
	local function SecureSetValueDerived(setting, value)
		setting.variableTbl[setting.variableKey] = value;
		return value;
	end
	
	function AddOnSettingMixin:Init(name, variable, variableKey, variableTbl, variableType, defaultValue)
		variableType = EnsureVariableTypeIsValid(variableType, defaultValue);

		SettingMixin.Init(self, name, variable, variableType);
		assert(type(variableTbl) == "table", "'variableTbl' argument must be a table.");
	
		self.variableKey = variableKey;
		self.variableTbl = variableTbl;
		self.defaultValue = defaultValue;
	
		--[[ 
		The argument 'variableTbl' is passed in by the inbound attribute handler and is therefore secure. 
		However, any table access will taint execution and must be done through secure call wrappers.
		]]--
		securecallfunction(SecureSetVariableTblDefaultValue, variableKey, variableTbl, defaultValue);
	
		self.GetValueDerived = function(self)
			return securecallfunction(SecureGetValueDerived, self);
		end;
	
		self.SetValueDerived = function(self, value)
			securecallfunction(SecureSetValueDerived, self, value);
		end;
	
		self.GetDefaultValueDerived = function(self)
			return defaultValue;
		end;
	end
end