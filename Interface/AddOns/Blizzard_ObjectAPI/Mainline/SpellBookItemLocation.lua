SpellBookItemLocation = {};
SpellBookItemLocationMixin = {};

--[[static]] function SpellBookItemLocation:CreateEmpty()
	local spelLBookItemLocation = CreateFromMixins(SpellBookItemLocationMixin);
	return spelLBookItemLocation;
end

-- slotIndex: int
-- spellBank: Enum.SpellBookSpellBank (see SpellBookConstantsDocumentation.lua)
--[[static]] function SpellBookItemLocation:CreateFromIndexAndBank(slotIndex, spellBank)
	local spellBookItemLocation = SpellBookItemLocation:CreateEmpty();
	spellBookItemLocation:SetIndexAndBank(slotIndex, spellBank);
	return spellBookItemLocation;
end

function SpellBookItemLocationMixin:Clear()
	self.slotIndex = nil;
	self.spellBank = nil;
end

function SpellBookItemLocationMixin:SetIndexAndBank(slotIndex, spellBank)
	self:Clear();
	self.slotIndex = slotIndex;
	self.spellBank = spellBank;
end

function SpellBookItemLocationMixin:GetIndexAndBank()
	return self.slotIndex, self.spellBank;
end

function SpellBookItemLocationMixin:IsEqualToIndexAndBank(otherSlotIndex, otherSpellBank)
	local slotIndex, spellBank = self:GetIndexAndBank();
	return slotIndex == otherSlotIndex and spellBank == otherSpellBank;
end

function SpellBookItemLocationMixin:IsEqualTo(otherSpellBookItemLocation)
	if not otherSpellBookItemLocation then
		return false;
	end

	local otherSlotIndex, otherSpellBank = otherSpellBookItemLocation:GetIndexAndBank();
	return self:IsEqualToIndexAndBank(otherSlotIndex, otherSpellBank);
end