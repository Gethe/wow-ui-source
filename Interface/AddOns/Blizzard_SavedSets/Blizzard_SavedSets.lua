
GlobalBlizzardSavedSets = GlobalBlizzardSavedSets or {};

local loaded = false;
local pendingCallbacks = {};

SavedSetsUtil = {};

SavedSetsUtil.RegisteredSavedSets = {
	SeenShopCatalogProductIDs = "SeenShopCatalogProductIDs",
	SeenHousingMarketDecorIDs = "SeenHousingMarketDecorIDs",
};

function SavedSetsUtil.IsLoaded()
	return loaded;
end

function SavedSetsUtil.ContinueOnLoad(callback)
	if loaded then
		callback();
		return true;
	else
		table.insert(pendingCallbacks, callback);
		return false;
	end
end

function SavedSetsUtil.HasAny(savedSetKey)
	if not loaded then
		-- Consider everything in the set until we know otherwise.
		return true;
	end

	local savedSet = GetOrCreateTableEntry(GlobalBlizzardSavedSets, savedSetKey);
	return not TableIsEmpty(savedSet);
end

function SavedSetsUtil.Set(savedSetKey, idOrTable)
	if not loaded then
		SavedSetsUtil.ContinueOnLoad(function() SavedSetsUtil.MarkSeen(savedSetKey, idOrTable); end);
		return;
	end

	local savedSet = GetOrCreateTableEntry(GlobalBlizzardSavedSets, savedSetKey);
	if type(idOrTable) == "table" then
		for _, id in ipairs(idOrTable) do
			savedSet[id] = true;
		end
	else
		savedSet[idOrTable] = true;
	end
end

function SavedSetsUtil.Check(savedSetKey, idOrTable)
	if not loaded then
		-- Consider everything in the set until we know otherwise.
		return true;
	end

	local savedSet = GetOrCreateTableEntry(GlobalBlizzardSavedSets, savedSetKey);
	if type(idOrTable) == "table" then
		for _, id in ipairs(idOrTable) do
			if not savedSet[id] then
				return false;
			end
		end
		return true;
	else
		return savedSet[idOrTable];
	end
end

local function TriggerPendingCallbacks()
	loaded = true;
	for _, callback in ipairs(pendingCallbacks) do
		callback();
	end
	pendingCallbacks = nil;
end

-- Note: this may be inconsistent at Glues so this may need to be adjusted in the future.
EventUtil.ContinueOnVariablesLoaded(TriggerPendingCallbacks);
