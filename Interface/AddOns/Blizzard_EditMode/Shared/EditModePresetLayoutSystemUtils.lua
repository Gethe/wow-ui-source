
-- isInDefaultPosition should only be used when EditMode is disabled.
local function AddSystem(systems, system, systemIndex, anchorInfo, settings, isInDefaultPosition)
	table.insert(systems, {
		system = system,
		systemIndex = systemIndex,
		anchorInfo = anchorInfo,
		settings = {},
		isInDefaultPosition = isInDefaultPosition ~= false;
	});

	local settingsTable = systems[#systems].settings;
	for setting, value in pairs(settings) do
		table.insert(settingsTable, { setting = setting, value = value });
	end
end

EditModeSystemUtil = { }; 
function EditModeSystemUtil.GetSystems(systemsMap)
	local systems = {};
	for system, systemInfo in pairs(systemsMap) do
		if systemInfo.settings ~= nil then
			-- This system has no systemIndices, just add it
			AddSystem(systems, system, nil, systemInfo.anchorInfo, systemInfo.settings, systemInfo.isInDefaultPosition);
		else
			-- This system has systemIndices, so we need to loop through each one and add them one at a time
			for systemIndex, subSystemInfo in pairs(systemInfo) do
				AddSystem(systems, system, systemIndex, subSystemInfo.anchorInfo, subSystemInfo.settings, subSystemInfo.isInDefaultPosition);
			end
		end
	end
	return systems;
end