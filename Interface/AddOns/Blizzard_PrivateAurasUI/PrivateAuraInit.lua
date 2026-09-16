local _, PrivateAuras = ...;

assertsafe(PrivateAuras.unitWatchers ~= nil, "UnitWatchers not initialized");

local function AddPrivateAnchor(anchor)
	local unit = anchor.unitToken;
	local watcher = PrivateAuras.unitWatchers[unit];
	if not watcher then
		watcher = CreateAndInitFromMixin(PrivateAuras.PrivateAuraUnitWatcher, unit);
		PrivateAuras.unitWatchers[unit] = watcher;
	end
	watcher:AddAnchor(anchor);
end
C_UnitAurasPrivate.SetPrivateAuraAnchorAddedCallback(AddPrivateAnchor);

local function RemovePrivateAnchor(anchorID)
	for _, watcher in pairs(PrivateAuras.unitWatchers) do
		if watcher:RemoveAnchor(anchorID) then
			return;
		end
	end
end
C_UnitAurasPrivate.SetPrivateAuraAnchorRemovedCallback(RemovePrivateAnchor);

-- Anchors may have been added before this file was loaded
do
	local existingAnchors = C_UnitAurasPrivate.GetPrivateAuraAnchors();
	for _, anchor in ipairs(existingAnchors) do
		AddPrivateAnchor(anchor);
	end
end
