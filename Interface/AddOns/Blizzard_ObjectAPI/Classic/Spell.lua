Spell = {};
SpellMixin = {};

local SpellEventListener;

--[[static]] function Spell:CreateFromSpellID(spellID)
	local spell = CreateFromMixins(SpellMixin);
	spell:SetSpellID(spellID);
	return spell;
end

function SpellMixin:SetSpellID(spellID)
	self:Clear();
	self.spellID = spellID;
end

function SpellMixin:GetSpellID()
	return self.spellID;
end

function SpellMixin:Clear()
	self.spellID = nil;
end

function SpellMixin:IsSpellEmpty()
	local spellID = self:GetSpellID();
	return not spellID or not C_Spell.DoesSpellExist(spellID);
end

-- Spell API
function SpellMixin:IsSpellDataCached()
	if not self:IsSpellEmpty() then
		return C_Spell.IsSpellDataCached(self:GetSpellID());
	end
	return true; 
end

function SpellMixin:GetSpellName()
	return (GetSpellInfo(self:GetSpellID()));
end

function SpellMixin:GetSpellSubtext()
	return GetSpellSubtext(self:GetSpellID());
end

function SpellMixin:GetSpellDescription()
	return GetSpellDescription(self:GetSpellID());
end

-- Add a callback to be executed when spell data is loaded, if the spell data is already loaded then execute it immediately
function SpellMixin:ContinueOnSpellLoad(callbackFunction)
	if type(callbackFunction) ~= "function" or self:IsSpellEmpty() then
		error("Usage: NonEmptySpell:ContinueOnLoad(callbackFunction)", 2);
	end

	SpellEventListener:AddCallback(self:GetSpellID(), callbackFunction);
end

-- Same as ContinueOnSpellLoad, except it returns a function that when called will cancel the continue
function SpellMixin:ContinueWithCancelOnSpellLoad(callbackFunction)
	if type(callbackFunction) ~= "function" or self:IsSpellEmpty() then
		error("Usage: NonEmptySpell:ContinueWithCancelOnSpellLoad(callbackFunction)", 2);
	end

	return SpellEventListener:AddCancelableCallback(self:GetSpellID(), callbackFunction);
end

--[ Spell Event Listener ]

SpellEventListener = CreateFrame("Frame");
SpellEventListener.callbacks = {};

SpellEventListener:SetScript("OnEvent", 
	function(self, event, ...)
		if event == "SPELL_DATA_LOAD_RESULT" then
			local spellID, success = ...;
			if success then
				self:FireCallbacks(spellID);
			else
				self:ClearCallbacks(spellID);
			end
		end
	end
);
SpellEventListener:RegisterEvent("SPELL_DATA_LOAD_RESULT");

local CANCELED_SENTINEL = -1;

function SpellEventListener:AddCallback(spellID, callbackFunction)
	local callbacks = self:GetOrCreateCallbacks(spellID);
	table.insert(callbacks, callbackFunction);
	C_Spell.RequestLoadSpellData(spellID);
end

function SpellEventListener:AddCancelableCallback(spellID, callbackFunction)
	local callbacks = self:GetOrCreateCallbacks(spellID);
	table.insert(callbacks, callbackFunction);
	C_Spell.RequestLoadSpellData(spellID);

	local index = #callbacks;
	return function()
		if #callbacks > 0 and callbacks[index] ~= CANCELED_SENTINEL then
			callbacks[index] = CANCELED_SENTINEL;
			return true;
		end
		return false;
	end;
end

do
	local function CallErrorHandler(...)
		return geterrorhandler()(...);
	end

	function SpellEventListener:FireCallbacks(spellID)
		local callbacks = self:GetCallbacks(spellID);
		if callbacks then
			self:ClearCallbacks(spellID);
			for i, callback in ipairs(callbacks) do
				if callback ~= CANCELED_SENTINEL then
					xpcall(callback, CallErrorHandler);
				end
			end

			for i = #callbacks, 1, -1 do
				callbacks[i] = nil;
			end
		end
	end
end

function SpellEventListener:ClearCallbacks(spellID)
	self.callbacks[spellID] = nil;
end

function SpellEventListener:GetCallbacks(spellID)
	return self.callbacks[spellID];
end

function SpellEventListener:GetOrCreateCallbacks(spellID)
	local callbacks = self.callbacks[spellID];
	if not callbacks then
		callbacks = {};
		self.callbacks[spellID] = callbacks;
	end
	return callbacks;
end