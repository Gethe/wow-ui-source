
local traitFramePredicatePairs = {};
local treeIDToCallback = {};

TraitUtil = {};

function TraitUtil.OpenTraitFrame(treeID)
	local treeIDCallback = treeIDToCallback[treeID];
	if treeIDCallback then
		treeIDCallback(treeID);
		return;
	end

	for _i, predicatePair in ipairs(traitFramePredicatePairs) do
		local predicate = predicatePair[1];
		if predicate(treeID) then
			local predicateCallback = predicatePair[2];
			predicateCallback(treeID);
			return;
		end
	end

	GenericTraitUI_LoadUI();
	GenericTraitFrame:SetTreeID(treeID);
	ShowUIPanel(GenericTraitFrame);
end

function TraitUtil.RegisterTraitFrameCallbackByPredicate(predicate, callback)
	table.insert(traitFramePredicatePairs, { predicate, callback });
end

function TraitUtil.RegisterTraitFrameCallbackByTreeID(treeID, callback)
	treeIDToCallback[treeID] = callback;
end

-- Add static registrations below here.

local function CheckForDelvesCompanionTraitFrame(treeID)
	return C_DelvesUI.IsTraitTreeForCompanion(treeID);
end

local function OpenDelvesCompanionTraitFrame()
	ShowUIPanel(DelvesCompanionConfigurationFrame);
end

TraitUtil.RegisterTraitFrameCallbackByPredicate(CheckForDelvesCompanionTraitFrame, OpenDelvesCompanionTraitFrame);
