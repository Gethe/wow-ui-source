Soulbinds = {};

SOULBINDS_RENOWN_CURRENCY_ID = 1822;

local SOULBINDS_COVENANT_KYRIAN = 1;
local SOULBINDS_COVENANT_VENTHYR = 2;
local SOULBINDS_COVENANT_NIGHT_FAE = 3;
local SOULBINDS_COVENANT_NECROLORD = 4;
local soulbindDefaultIDs = {
	[SOULBINDS_COVENANT_KYRIAN] = 7,
	[SOULBINDS_COVENANT_VENTHYR] = 8,
	[SOULBINDS_COVENANT_NIGHT_FAE] = 1,
	[SOULBINDS_COVENANT_NECROLORD] = 4,
};

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

function Soulbinds.GetOpenSoulbindID()
	return SoulbindViewer:GetOpenSoulbindID();
end

function Soulbinds.HasNewSoulbindTutorial(soulbindID)
	for k, v in pairs(soulbindDefaultIDs) do
		if v == soulbindID then
			return false;
		end
	end
	return true;
end

function Soulbinds.GetDefaultSoulbindID(covenantID)
	return soulbindDefaultIDs[covenantID];
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