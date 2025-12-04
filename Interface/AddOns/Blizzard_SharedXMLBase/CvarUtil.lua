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

function SetCVarToDefault(name)
	SetCVar(name, GetCVarDefault(name))
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

function GetCVarNumberOrDefault(name)
	local number = tonumber(GetCVar(name));
	return number or tonumber(GetCVarDefault(name));
end

-- Returns a lua table from serialized CVar string
function GetCVarTable(name)
	return C_EncodingUtil.DeserializeCBOR(C_EncodingUtil.DecodeBase64(GetCVar(name))) or {};
end

-- Given the CVar name and a lua table, serialize the table into a string and store in the CVar
function SetCVarTable(name, tbl)
	local encodedTbl = C_EncodingUtil.EncodeBase64(C_EncodingUtil.SerializeCBOR(tbl));
	SetCVar(name, encodedTbl);
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
	local value = self.cvarValueCache[cvar];
	if value == nil then
		value = GetCVar(cvar);

		if self.cachable[cvar] then
			self.cvarValueCache[cvar] = value;
		end
	end
	return value;
end

function CVarCallbackRegistry:GetCVarValueBool(cvar)
	local value = self:GetCVarValue(cvar);
	return (value ~= nil) and value ~= "0";
end

function CVarCallbackRegistry:GetCVarBitfieldIndex(cvar, index)
	local value = self:GetCVarValue(cvar);

	-- Index is decremented going into C++.
	index = index - 1;

	-- Must match CVAR_ARRAY_BITS_STORED_PER_BYTE
	local bitsPerByte = 6;

	local totalBits = (#value - 1) * bitsPerByte;
	if index >= totalBits then
		return false;
	end

	-- byteIndex is offset by 1 in C++, and add another 1 to account for 1-based index in lua.
	local byteIndex = 2 + math.floor(index / bitsPerByte);

	local byte = string.byte(value, byteIndex);
	if not byte then
		return false
	end

	local bitIndex = index % bitsPerByte;
	local shiftedBitIndex = bit.lshift(1, bitIndex);
	return bit.band(byte, shiftedBitIndex) ~= 0;
end

function CVarCallbackRegistry:GetCVarNumberOrDefault(cvar)
	local number = tonumber(self:GetCVarValue(cvar));
	return number or tonumber(GetCVarDefault(cvar));
end

function CVarCallbackRegistry:SetCVarCachable(cvar)
	self.cachable[cvar] = true;
end

function CVarCallbackRegistry:ClearCache(cvar)
	self.cvarValueCache[cvar] = nil;
end

function CVarCallbackRegistry:GetCVarBitfieldDefault(cvar)
	local value = GetCVarDefault(cvar);

	local bitmask = 0;
	local bitsPerByte = 6; -- CVAR_ARRAY_BITS_STORED_PER_BYTE
	
	-- Process each data byte (skip version byte at index 1)
	for byteIndex = 2, #value do
		local byte = value:byte(byteIndex);
		if not byte then
			break;
		end
		
		-- Each byte stores 6 bits of data
		for bitIndex = 0, bitsPerByte - 1 do
			if bit.band(byte, bit.lshift(1, bitIndex)) ~= 0 then
				local overallBitIndex = (byteIndex - 2) * bitsPerByte + bitIndex;
				bitmask = bit.bor(bitmask, bit.lshift(1, overallBitIndex));
			end
		end
	end
	
	return bitmask;
end

function CVarCallbackRegistry:SetCVarBitfieldMask(cvar, mask)
	local value = self:GetCVarValue(cvar);

	local bitsPerByte = 6; -- CVAR_ARRAY_BITS_STORED_PER_BYTE
	local maxStringSize = 256;
	
	-- Extract the version from the existing value.
	local version = value:byte(1);
	
	-- Start with version byte from existing value
	local buffer = string.char(version);
	
	-- Convert mask to individual bits and pack them into bytes
	local currentMask = mask;
	local byteIndex = 2; -- Start after version byte
	
	while currentMask > 0 and byteIndex < maxStringSize do
		local dataByte = 0;
		
		-- Extract up to 6 bits for this byte
		for bitIndex = 0, bitsPerByte - 1 do
			if currentMask > 0 and bit.band(currentMask, 1) ~= 0 then
				dataByte = bit.bor(dataByte, bit.lshift(1, bitIndex));
			end
			currentMask = bit.rshift(currentMask, 1);
		end
		
		-- Set bit 6 to maintain the format 0b01xxxxxx (bit 6 = 1, bit 7 = 0)
		dataByte = bit.bor(dataByte, 0x40); -- 0x40 = 64 = 2^6
		
		-- Make sure bit 7 is not set (should never happen with our logic)
		dataByte = bit.band(dataByte, 0x7F); -- 0x7F = 127 = 2^7 - 1
		
		buffer = buffer .. string.char(dataByte);
		byteIndex = byteIndex + 1;
	end
	
	-- Remove trailing bytes that are just the padding value (0x40)
	-- This matches the C++ logic that shortens the string by removing trailing padding
	while #buffer > 1 do
		local lastByte = buffer:byte(-1);
		if lastByte == 0x40 then -- 64 = padding byte with no data bits set
			buffer = buffer:sub(1, -2);
		else
			break;
		end
	end
	
	SetCVar(cvar, buffer);
end

-- NOTE: This will invoke the supplied callback for **ALL** CVar changes, as
-- if listening directly for the CVAR_UPDATE event.
--
-- You probably don't want this! Instead, call RegisterCallback("cvarName", func[, owner])
-- instead to only receive updates for individual CVars.
function CVarCallbackRegistry:RegisterCallbackForAllCVarUpdates(func, owner, ...)
	return self:RegisterCallback(CVarCallbackRegistry.Event.OnCVarChanged, func, owner, ...);
end

CVarCallbackRegistry = Mixin(CreateFrame("Frame"), CVarCallbackRegistry);
CVarCallbackRegistry:OnLoad();
CVarCallbackRegistry:SetUndefinedEventsAllowed(true);
