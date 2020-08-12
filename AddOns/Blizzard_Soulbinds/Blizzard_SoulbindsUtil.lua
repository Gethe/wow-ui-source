Soulbinds = {};

function Soulbinds.HasConduitAtCursor()
	return C_Soulbinds.GetConduitCollectionDataAtCursor() ~= nil;
end

local previewConduitType = nil;
function Soulbinds.SetPreviewConduitType(conduitType)
	previewConduitType = conduitType;
end

function Soulbinds.GetPreviewConduitType()
	return previewConduitType;
end

function Soulbinds.GetOpenSoulbind()
	return SoulbindViewer.Tree.soulbindID;
end

function Soulbinds.HasNewSoulbindTutorial(soulbindID)
	local noTutorialIDs = {1, 4, 7, 8};
	return not tContains(noTutorialIDs, soulbindID);
end

local isPathChangePending = false;
function Soulbinds.SetPathChangePending(pending)
	isPathChangePending = pending;
end

function Soulbinds.IsPathChangePending()
	return isPathChangePending;
end

function Soulbinds.GetConduitName(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return CONDUIT_POTENCY;
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return CONDUIT_ENDURANCE;
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return CONDUIT_FINESSE;
	end
end

function Soulbinds.GetConduitEmblemAtlas(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return "Soulbinds_Tree_Conduit_Icon_Attack";
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return "Soulbinds_Tree_Conduit_Icon_Protect";
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return "Soulbinds_Tree_Conduit_Icon_Utility";
	end
end