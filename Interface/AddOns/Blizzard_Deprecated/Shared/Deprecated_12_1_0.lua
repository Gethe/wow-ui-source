
-- These are functions are deprecated, and will be removed in a future patch.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

function getglobal(var)
	return _G[var];
end

local forceinsecure = forceinsecure;
function setglobal(var, val)
	if forceinsecure then
		forceinsecure();
	end

	_G[var] = val;
end

C_UnitAuras.AddPrivateAuraAppliedSound = function(sound)
	return C_UnitAuras.AddAuraSound(Enum.UnitAuraSoundTrigger.Added, sound);
end;

C_UnitAuras.RemovePrivateAuraAppliedSound = C_UnitAuras.RemoveAuraSound;

function CancelItemTempEnchantment(index)
	local slot;

	if index == 1 then
		slot = INVSLOT_MAINHAND;
	elseif index == 2 then
		slot = INVSLOT_OFFHAND;
	elseif index == 3 then
		slot = INVSLOT_RANGED;
	end

	if slot then
		C_PaperDollInfo.CancelTemporaryEnchantment(slot);
	end
end

function GetWeaponEnchantInfo()
	local values = {};
	local offset = 1;

	for _index, slot in ipairs({ INVSLOT_MAINHAND, INVSLOT_OFFHAND, INVSLOT_RANGED }) do
		local enchantmentInfo = C_PaperDollInfo.GetTemporaryEnchantmentInfo(slot);

		if enchantmentInfo then
			values[offset] = true;
			values[offset + 1] = enchantmentInfo.remainingTimeMs;
			values[offset + 2] = enchantmentInfo.chargesRemaining;
			values[offset + 3] = enchantmentInfo.enchantID;
		else
			values[offset] = false;
			-- Leave the subsequent entries as nil values.
		end

		offset = offset + 4;
	end

	-- Explicitly specifying range here to avoid nil gaps truncating results.
	return unpack(values, 1, offset - 1);
end

-- Aura container enums and global constants from PTR development.
AuraButtonBorderStyle = Enum.CustomAuraButtonBorderStyle;