local AddonName = ...;

function ArtifactFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowArtifactFrame()
	if ArtifactFrame_LoadUI() then
		ShowUIPanel(ArtifactFrame);
	end
end

function ShowArtifactRelicForgeFrame()
	if ArtifactFrame_LoadUI() then
		ShowUIPanel(ArtifactRelicForgeFrame);
	end
end

function ArtifactFrame_OnTraitsRefunded(numRefunded, refundedTier)
	if ArtifactFrame_LoadUI() then
		ArtifactFrame:OnTraitsRefunded(numRefunded, refundedTier);
	end
end
