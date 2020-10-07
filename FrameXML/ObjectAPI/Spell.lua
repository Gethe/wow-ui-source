Spell = {};
SpellMixin = {};

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

function SpellMixin:GetSpellTexture()
	return (GetSpellTexture(self:GetSpellID()));
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