Soulbinds = {};

function Soulbinds.GetConduitDataAtCursor()
	local itemType, itemID = GetCursorInfo();
	if itemType == "conduit" then
		-- FIXME replace itemid
		local conduitType = C_Soulbinds.GetItemConduitTypeByItemID(itemID);
		local conduitID = C_Soulbinds.GetConduitID(itemID);
		return conduitType, conduitID;
	end
end

function Soulbinds.HasConduitAtCursor()
	return Soulbinds.GetConduitDataAtCursor() ~= nil;
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