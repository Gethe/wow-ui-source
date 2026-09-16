
local function AddSystem(systems, system, systemIndex, anchorInfo, settings)
	table.insert(systems, {
		system = system,
		systemIndex = systemIndex,
		anchorInfo = anchorInfo,
		settings = {},
		isInDefaultPosition = true;
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
			AddSystem(systems, system, nil, systemInfo.anchorInfo, systemInfo.settings);
		else
			-- This system has systemIndices, so we need to loop through each one and add them one at a time
			for systemIndex, subSystemInfo in pairs(systemInfo) do
				AddSystem(systems, system, systemIndex, subSystemInfo.anchorInfo, subSystemInfo.settings);
			end
		end
	end
	return systems;
end