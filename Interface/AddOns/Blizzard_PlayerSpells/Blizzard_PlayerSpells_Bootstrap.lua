local AddonName = ...;

function PlayerSpellsFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function OpenPlayerSpellsToGlyphTarget(event, ...)
	if PlayerSpellsFrame_LoadUI() then
		PlayerSpellsUtil.OpenToSpellBookTab();
		PlayerSpellsFrame.SpellBookFrame:OnEvent(event, ...);
	end
end
