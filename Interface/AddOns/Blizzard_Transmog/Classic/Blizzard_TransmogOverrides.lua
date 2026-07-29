function DressUpFrameLinkingSupported()
	return false;
end

function ShowEquippedGearSpellFrameMixin:ApplyOverrides()
	self.OverlayFX.OverlayLocked:SetSize(30, 30);
end
