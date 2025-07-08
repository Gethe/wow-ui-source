-- These are functions that were deprecated in 11.2.0 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

-- NOTE FOR ADDON DEVELOPERS:
-- Starting this patch, region:ClearAllPoints() will immediately invalidate the rect.
-- This means you cannot rely on calling GetWidth, GetHeight, GetTop/Left/Bottom/Right, or GetRect after ClearAllPoints.
-- Any measurement calculations relying on the previous rect should occur before calling ClearAllPoints.

function IsSpellOverlayed(spellID)
	return C_SpellActivationOverlay.IsSpellOverlayed(spellID);
end