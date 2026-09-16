local AddonName = ...;
local TutorialAddonName = "Blizzard_RemixArtifactTutorialUI";

function RemixArtifactUI_LoadUI()
	if not C_AddOns.IsAddOnLoaded(TutorialAddonName) and not LoadAddOnWithErrorHandling(TutorialAddonName) then
		return false;
	end

	if not C_AddOns.IsAddOnLoaded(AddonName) and not LoadAddOnWithErrorHandling(AddonName) then
		return false;
	end

	RemixArtifactTutorialControllerFrame:RegisterForRemixArtifactFrameEvents();
	return true;
end

function ShowRemixArtifactFrame()
	if RemixArtifactUI_LoadUI() then
		RemixArtifactFrame:UpdateTraitTree();
		if not RemixArtifactFrame:IsShown() then
			ShowUIPanel(RemixArtifactFrame);
		end
	end
end
