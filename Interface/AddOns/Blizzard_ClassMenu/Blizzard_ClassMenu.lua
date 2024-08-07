UNSPECIFIED_CLASS_FILTER = 0;
UNSPECIFIED_SPEC_FILTER = 0;

ClassMenu = {};

local function GetPlayerClassData(filterClassID)
	local name, tag, classID = UnitClass("player");
	local classInfo = C_CreatureInfo.GetClassInfo(classID);
	local color = GetClassColorObj(classInfo.classFile);
	return name, classID, color.colorStr; 
end

function ClassMenu.InitClassSpecDropdown(dropdown, getClassFilter, getSpecFilter, setClassAndSpecFilter, excludeSpecs, excludeAllSpecOption)
	-- Changing a child radio option requires the root menu to be rebuilt before selections
	-- are parsed to determine the selection text. This is not enabled by default because it is
	-- so infrequently necessary.
	dropdown:EnableRegenerateOnResponse();

	dropdown:SetSelectionText(function(selections)
		local datas = {};
		
		-- There will be up to two selections in the menu: one for the specialization and another for the
		-- class. Prioritize the specialized option if it is selected by inserting it in the front of the table.
		for index, selection in ipairs(selections) do
			local data = selection.data;
			if (data.classID == UNSPECIFIED_CLASS_FILTER) and (data.classID == UNSPECIFIED_CLASS_FILTER) then
				return ALL_CLASSES;
			end

			if data.specID == UNSPECIFIED_CLASS_FILTER then
				table.insert(datas, data);
			else
				table.insert(datas, 1, data);
			end
		end

		local data = datas[1];
		if not data then
			return nil;
		end

		local classInfo = C_CreatureInfo.GetClassInfo(data.classID);
		local classColorStr = RAID_CLASS_COLORS[classInfo.classFile].colorStr;
		if data.specID == UNSPECIFIED_SPEC_FILTER then
			return HEIRLOOMS_CLASS_FILTER_FORMAT:format(classColorStr, classInfo.className);
		end
		
		local _, specName = GetSpecializationInfoForSpecID(data.specID);
		return HEIRLOOMS_CLASS_SPEC_FILTER_FORMAT:format(classColorStr, classInfo.className, specName);
	end);

	local function CreateData(classID, specID)
		return {classID = classID, specID = specID};
	end
	
	local function GetFilterOrPlayerClassData()
		local filterClassID = getClassFilter();
		if filterClassID == UNSPECIFIED_CLASS_FILTER then
			return GetPlayerClassData();
		end

		local classInfo = C_CreatureInfo.GetClassInfo(filterClassID);
		if not classInfo then
			return GetPlayerClassData();
		end

		local color = GetClassColorObj(classInfo.classFile);
		return classInfo.className, filterClassID, color.colorStr;
	end

	local function IsClassSelected(data)
		return getClassFilter() == data.classID;
	end

	local function IsSpecSelected(data)
		return getSpecFilter() == data.specID;
	end

	local function IsAllSpecSelected(data)
		return (getClassFilter() == data.classID) and (getSpecFilter() == UNSPECIFIED_SPEC_FILTER);
	end
	
	local function SetSelected(data)
		setClassAndSpecFilter(data.classID, data.specID);
	end
	
	dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_CLASS_FILTER");

		local classMenu = nil;
		if excludeSpecs then
			classMenu = rootDescription;
		else
			classMenu = rootDescription:CreateButton(CLASS);
		end

		classMenu:CreateRadio(ALL_CLASSES, IsClassSelected, SetSelected, CreateData(UNSPECIFIED_CLASS_FILTER, UNSPECIFIED_SPEC_FILTER));

		for index = 1, GetNumClasses() do
			if (index == 10) and (GetClassicExpansionLevel() <= LE_EXPANSION_CATACLYSM) then
				-- We have an annoying gap between warlock and druid
				index = 11;
			end

			local classDisplayName, classTag, classID = GetClassInfo(index);
			classMenu:CreateRadio(classDisplayName, IsClassSelected, SetSelected, CreateData(classID, UNSPECIFIED_SPEC_FILTER));
		end

		if not excludeSpecs then
			local name, classID, colorStr = GetFilterOrPlayerClassData();
			rootDescription:CreateTitle(HEIRLOOMS_CLASS_FILTER_FORMAT:format(colorStr, name));

			local sex = UnitSex("player");
			for index = 1, GetNumSpecializationsForClassID(classID) do
				local specID, specName = GetSpecializationInfoForClassID(classID, index, sex);
				rootDescription:CreateRadio(specName, IsSpecSelected, SetSelected, CreateData(classID, specID));
			end

			if not excludeAllSpecOption then
				-- Selecting "All specializations" is equivalent to selecting the class from the class submenu.
				rootDescription:CreateRadio(ALL_SPECS, IsAllSpecSelected, SetSelected, CreateData(classID, UNSPECIFIED_SPEC_FILTER));
			end
		end
	end);
end