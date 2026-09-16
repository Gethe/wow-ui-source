--
-- SecurePartyHeader and SecureRaidGroupHeader contributed with permission by: Esamynn, Cide, and Iriel
--

local strsplit = strsplit;
local select = select;
local tonumber = tonumber;
local type = type;
local floor = math.floor;
local ceil = math.ceil;
local min = math.min;
local max = math.max;
local abs = math.abs;
local pairs = pairs;
local ipairs = ipairs;
local strtrim = string.trim;
local unpack = unpack;
local wipe = table.wipe;
local tinsert = table.insert;
local CallRestrictedClosure = CallRestrictedClosure;
local GetManagedEnvironment = GetManagedEnvironment;
local GetFrameHandle = GetFrameHandle;

--[[
List of the various configuration attributes
======================================================
showRaid = [BOOLEAN] -- true if the header should be shown while in a raid
showParty = [BOOLEAN] -- true if the header should be shown while in a party and not in a raid
showPlayer = [BOOLEAN] -- true if the header should show the player when not in a raid
showSolo = [BOOLEAN] -- true if the header should be shown while not in a group (implies showPlayer)
nameList = [STRING] -- a comma separated list of player names (not used if 'groupFilter' is set)
groupFilter = [1-8, STRING] -- a comma seperated list of raid group numbers and/or uppercase class names and/or uppercase roles
roleFilter = [STRING] -- a comma seperated list of MT/MA/Tank/Healer/DPS role strings
strictFiltering = [BOOLEAN]
-- if true, then
---- if only groupFilter is specified then characters must match both a group and a class from the groupFilter list
---- if only roleFilter is specified then characters must match at least one of the specified roles
---- if both groupFilter and roleFilters are specified then characters must match a group and a class from the groupFilter list and a role from the roleFilter list
point = [STRING] -- a valid XML anchoring point (Default: "TOP")
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: 0)
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: 0)
sortMethod = ["INDEX", "NAME", "NAMELIST"] -- defines how the group is sorted (Default: "INDEX")
sortDir = ["ASC", "DESC"] -- defines the sort order (Default: "ASC")
template = [STRING] -- the XML template to use for the unit buttons
templateType = [STRING] - specifies the frame type of the managed subframes (Default: "Button")
groupBy = [nil, "GROUP", "CLASS", "ROLE", "ASSIGNEDROLE"] - specifies a "grouping" type to apply before regular sorting (Default: nil)
groupingOrder = [STRING] - specifies the order of the groupings (ie. "1,2,3,4,5,6,7,8")
maxColumns = [NUMBER] - maximum number of columns the header will create (Default: 1)
unitsPerColumn = [NUMBER or nil] - maximum units that will be displayed in a singe column, nil is infinite (Default: nil)
startingIndex = [NUMBER] - the index in the final sorted unit list at which to start displaying units (Default: 1)
columnSpacing = [NUMBER] - the amount of space between the rows/columns (Default: 0)
columnAnchorPoint = [STRING] - the anchor point of each new column (ie. use LEFT for the columns to grow to the right)
--]]

function SecureGroupHeader_OnLoad(self)
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
end

function SecureGroupHeader_OnEvent(self, event, ...)
	if ( (event == "GROUP_ROSTER_UPDATE" or event == "UNIT_NAME_UPDATE") and self:IsVisible() ) then
		SecureGroupHeader_Update(self);
	end
end

function SecureGroupHeader_OnAttributeChanged(self, name, value)
	if ( name == "_ignore" or self:GetAttribute("_ignore" ) ) then
		return
	end
	if ( self:IsVisible() ) then
		SecureGroupHeader_Update(self);
	end
end

-- relativePoint, xMultiplier, yMultiplier = getRelativePointAnchor( point )
-- Given a point return the opposite point and which axes the point
-- depends on.
local function getRelativePointAnchor( point )
	point = point:upper();
	if (point == "TOP") then
		return "BOTTOM", 0, -1;
	elseif (point == "BOTTOM") then
		return "TOP", 0, 1;
	elseif (point == "LEFT") then
		return "RIGHT", 1, 0;
	elseif (point == "RIGHT") then
		return "LEFT", -1, 0;
	elseif (point == "TOPLEFT") then
		return "BOTTOMRIGHT", 1, -1;
	elseif (point == "TOPRIGHT") then
		return "BOTTOMLEFT", -1, -1;
	elseif (point == "BOTTOMLEFT") then
		return "TOPRIGHT", 1, 1;
	elseif (point == "BOTTOMRIGHT") then
		return "TOPLEFT", -1, 1;
	else
		return "CENTER", 0, 0;
	end
end

local function setAttributesWithoutResponse(self, ...)
	local oldIgnore = self:GetAttribute("_ignore");
	self:SetAttribute("_ignore", "attributeChanges");
	for i = 1, select('#', ...), 2 do
		self:SetAttribute(select(i, ...));
	end
	self:SetAttribute("_ignore", oldIgnore);
end

local function SetupUnitButtonConfiguration( header, newChild, defaultConfigFunction )
	if ( header:GetAttribute("auraContainerTemplate") ) then
		newChild.AuraContainer = CreateFrame("AuraContainer", nil, newChild, header:GetAttribute("auraContainerTemplate"));
	end

	local configCode = header:GetAttribute("initialConfigFunction") or defaultConfigFunction;

	if ( type(configCode) == "string" ) then
		local selfHandle = GetFrameHandle(newChild);
		if ( selfHandle ) then
			CallRestrictedClosure(newChild, "self", GetManagedEnvironment(header, true), selfHandle, configCode, selfHandle);
		end
	end

	local copyAttributes = header:GetAttribute("_initialAttributeNames");
	if ( type(copyAttributes) == "string" ) then
		for name in copyAttributes:gmatch("[^,]+") do
			newChild:SetAttribute(name, scrub(header:GetAttribute("_initialAttribute-" .. name)));
		end
	end
end

-- creates child frames and finished configuring them
local function configureChildren(self, unitTable)
	local point = self:GetAttribute("point") or "TOP"; --default anchor point of "TOP"
	local relativePoint, xOffsetMult, yOffsetMult = getRelativePointAnchor(point);
	local xMultiplier, yMultiplier =  abs(xOffsetMult), abs(yOffsetMult);
	local xOffset = self:GetAttribute("xOffset") or 0; --default of 0
	local yOffset = self:GetAttribute("yOffset") or 0; --default of 0
	local sortDir = self:GetAttribute("sortDir") or "ASC"; --sort ascending by default
	local columnSpacing = self:GetAttribute("columnSpacing") or 0;
	local startingIndex = self:GetAttribute("startingIndex") or 1;

	local unitCount = #unitTable;
	local numDisplayed = unitCount - (startingIndex - 1);
	local unitsPerColumn = self:GetAttribute("unitsPerColumn");
	local numColumns;
	if ( unitsPerColumn and numDisplayed > unitsPerColumn ) then
		numColumns = min( ceil(numDisplayed / unitsPerColumn), (self:GetAttribute("maxColumns") or 1) );
	else
		unitsPerColumn = numDisplayed;
		numColumns = 1;
	end
	local loopStart = startingIndex;
	local loopFinish = min((startingIndex - 1) + unitsPerColumn * numColumns, unitCount)
	local step = 1;

	numDisplayed = loopFinish - (loopStart - 1);

	if ( sortDir == "DESC" ) then
		loopStart = unitCount - (startingIndex - 1);
		loopFinish = loopStart - (numDisplayed - 1);
		step = -1;
	end

	-- ensure there are enough buttons
	local needButtons = max(1, numDisplayed);
	if not ( self:GetAttribute("child"..needButtons) ) then
		local buttonTemplate = self:GetAttribute("template");
		local templateType = self:GetAttribute("templateType") or "Button";
		local name = self:GetName();
		for i = 1, needButtons, 1 do
			local childAttr = "child" .. i;
			if not ( self:GetAttribute(childAttr) ) then
				local newButton = CreateFrame(templateType, name and (name.."UnitButton"..i), self, buttonTemplate);
				self[i] = newButton;
				SetupUnitButtonConfiguration(self, newButton);
				setAttributesWithoutResponse(self, childAttr, newButton, "frameref-"..childAttr, GetFrameHandle(newButton));
			end
		end
	end

	local columnAnchorPoint, columnRelPoint, colxMulti, colyMulti;
	if ( numColumns > 1 ) then
		columnAnchorPoint = self:GetAttribute("columnAnchorPoint");
		columnRelPoint, colxMulti, colyMulti = getRelativePointAnchor(columnAnchorPoint);
	end

	local buttonNum = 0;
	local columnNum = 1;
	local columnUnitCount = 0;
	local currentAnchor = self;
	for i = loopStart, loopFinish, step do
		buttonNum = buttonNum + 1;
		columnUnitCount = columnUnitCount + 1;
		if ( columnUnitCount > unitsPerColumn ) then
			columnUnitCount = 1;
			columnNum = columnNum + 1;
		end

		local unitButton = self:GetAttribute("child"..buttonNum);
		if ( buttonNum == 1 ) then
			unitButton:SetPoint(point, currentAnchor, point, 0, 0);
			if ( columnAnchorPoint ) then
				unitButton:SetPoint(columnAnchorPoint, currentAnchor, columnAnchorPoint, 0, 0);
			end

		elseif ( columnUnitCount == 1 ) then
			local columnAnchor = self:GetAttribute("child"..(buttonNum - unitsPerColumn));
			unitButton:SetPoint(columnAnchorPoint, columnAnchor, columnRelPoint, colxMulti * columnSpacing, colyMulti * columnSpacing);
		else
			unitButton:SetPoint(point, currentAnchor, relativePoint, xMultiplier * xOffset, yMultiplier * yOffset);
		end
		unitButton:SetAttribute("unit", unitTable[i]);

		local configCode = unitButton:GetAttribute("refreshUnitChange");
		if ( type(configCode) == "string" ) then
			local selfHandle = GetFrameHandle(unitButton);
			if ( selfHandle ) then
				CallRestrictedClosure(unitButton, "self", GetManagedEnvironment(unitButton, true), selfHandle, configCode, selfHandle);
			end
		end

		if not unitButton:GetAttribute("statehidden") then
			unitButton:Show();
		end

		currentAnchor = unitButton;
	end
	repeat
		buttonNum = buttonNum + 1;
		local unitButton = self:GetAttribute("child"..buttonNum);
		if ( unitButton ) then
			unitButton:Hide();
			unitButton:ClearAllPoints();
			unitButton:SetAttribute("unit", nil);
		end
	until not ( unitButton )

	local unitButton = self:GetAttribute("child1");
	local unitButtonWidth = unitButton:GetWidth();
	local unitButtonHeight = unitButton:GetHeight();
	if ( numDisplayed > 0 ) then
		local width = xMultiplier * (unitsPerColumn - 1) * unitButtonWidth + ( (unitsPerColumn - 1) * (xOffset * xOffsetMult) ) + unitButtonWidth;
		local height = yMultiplier * (unitsPerColumn - 1) * unitButtonHeight + ( (unitsPerColumn - 1) * (yOffset * yOffsetMult) ) + unitButtonHeight;

		if ( numColumns > 1 ) then
			width = width + ( (numColumns -1) * abs(colxMulti) * (width + columnSpacing) );
			height = height + ( (numColumns -1) * abs(colyMulti) * (height + columnSpacing) );
		end

		self:SetWidth(width);
		self:SetHeight(height);
	else
		local minWidth = self:GetAttribute("minWidth") or (yMultiplier * unitButtonWidth);
		local minHeight = self:GetAttribute("minHeight") or (xMultiplier * unitButtonHeight);
		self:SetWidth( max(minWidth, 0.1) );
		self:SetHeight( max(minHeight, 0.1) );
	end
end

local function GetGroupHeaderType(self)
	local kind, start, stop;

	local nRaid = GetNumGroupMembers();
	local nParty = GetNumSubgroupMembers();
	if ( IsInRaid() and self:GetAttribute("showRaid") ) then
		kind = "RAID";
	elseif ( IsInGroup() and self:GetAttribute("showParty") ) then
		kind = "PARTY";
	elseif ( self:GetAttribute("showSolo") ) then
		kind = "SOLO";
	end
	if ( kind ) then
		if ( kind == "RAID" ) then
			start = 1;
			stop = nRaid;
		else
			if ( kind == "SOLO" or self:GetAttribute("showPlayer") ) then
				start = 0;
			else
				start = 1;
			end
			stop = nParty;
		end
	end
	return kind, start, stop;
end

local function GetGroupRosterInfo(kind, index)
	local _, unit, name, subgroup, className, role, server, assignedRole;
	if ( kind == "RAID" ) then
		unit = "raid"..index;
		name, _, subgroup, _, _, className, _, _, _, role, _, assignedRole = GetRaidRosterInfo(index);
	else
		if ( index > 0 ) then
			unit = "party"..index;
		else
			unit = "player";
		end
		if ( UnitExists(unit) ) then
			name, server = UnitName(unit);
			if (server and server ~= "") then
				name = name.."-"..server
			end
			_, className = UnitClass(unit);
			if ( GetPartyAssignment("MAINTANK", unit) ) then
				role = "MAINTANK";
			elseif ( GetPartyAssignment("MAINASSIST", unit) ) then
				role = "MAINASSIST";
			end
			assignedRole = UnitGroupRolesAssigned(unit)
		end
		subgroup = 1;
	end
	return unit, name, subgroup, className, role, assignedRole;
end

-- empties tbl and assigns the value true to each key passed as part of ...
local function fillTable( tbl, ... )
	for i = 1, select("#", ...), 1 do
		local key = select(i, ...);
		key = tonumber(key) or strtrim(key);
		tbl[key] = i;
	end
end

-- same as fillTable() except that each key is also stored in
-- the array portion of the table in order
local function doubleFillTable( tbl, ... )
	fillTable(tbl, ...);
	for i = 1, select("#", ...), 1 do
		local key = select(i, ...)
		tbl[i] = strtrim(key)
	end
end

--working tables
local tokenTable = {};
local sortingTable = {};
local groupingTable = {};

local function sortOnGroupWithNames(a, b)
	local order1 = tokenTable[ groupingTable[a] ];
	local order2 = tokenTable[ groupingTable[b] ];
	if ( order1 ) then
		if ( not order2 ) then
			return true;
		else
			if ( order1 == order2 ) then
				return sortingTable[a] < sortingTable[b];
			else
				return order1 < order2;
			end
		end
	else
		if ( order2 ) then
			return false;
		else
			return sortingTable[a] < sortingTable[b];
		end
	end
end

local function sortOnGroupWithIDs(a, b)
	local order1 = tokenTable[ groupingTable[a] ];
	local order2 = tokenTable[ groupingTable[b] ];
	if ( order1 ) then
		if ( not order2 ) then
			return true;
		else
			if ( order1 == order2 ) then
				return tonumber(a:match("%d+") or -1) < tonumber(b:match("%d+") or -1);
			else
				return order1 < order2;
			end
		end
	else
		if ( order2 ) then
			return false;
		else
			return tonumber(a:match("%d+") or -1) < tonumber(b:match("%d+") or -1);
		end
	end
end

local function sortOnNames(a, b)
	return sortingTable[a] < sortingTable[b];
end

local function sortOnNameList(a, b)
	return tokenTable[ sortingTable[a] ] < tokenTable[ sortingTable[b] ];
end

function SecureGroupHeader_Update(self)
	local nameList = self:GetAttribute("nameList");
	local groupFilter = self:GetAttribute("groupFilter");
	local roleFilter = self:GetAttribute("roleFilter");
	local sortMethod = self:GetAttribute("sortMethod");
	local groupBy = self:GetAttribute("groupBy");

	wipe(sortingTable);

	-- See if this header should be shown
	local kind, start, stop = GetGroupHeaderType(self);
	if ( not kind ) then
		configureChildren(self, sortingTable);
		return;
	end

	if ( not groupFilter and not roleFilter and not nameList ) then
		groupFilter = "1,2,3,4,5,6,7,8";
	end

	if ( groupFilter or roleFilter ) then
		local strictFiltering = self:GetAttribute("strictFiltering"); -- non-strict by default
		wipe(tokenTable)
		if ( groupFilter and not roleFilter ) then
			-- filtering by a list of group numbers and/or classes
			fillTable(tokenTable, strsplit(",", groupFilter));
			if ( strictFiltering ) then
				fillTable(tokenTable, "MAINTANK", "MAINASSIST", "TANK", "HEALER", "DAMAGER", "NONE")
			end

		elseif ( roleFilter and not groupFilter ) then
			-- filtering by role (of either type)
			fillTable(tokenTable, strsplit(",", roleFilter));
			if ( strictFiltering ) then
				fillTable(tokenTable, 1, 2, 3, 4, 5, 6, 7, 8, unpack(CLASS_SORT_ORDER))
			end

		else
			-- filtering by group, class and/or role
			fillTable(tokenTable, strsplit(",", groupFilter));
			fillTable(tokenTable, strsplit(",", roleFilter));

		end

		for i = start, stop, 1 do
			local unit, name, subgroup, className, role, assignedRole = GetGroupRosterInfo(kind, i);

			if ( name and
				((not strictFiltering) and
					( tokenTable[subgroup] or tokenTable[className] or (role and tokenTable[role]) or tokenTable[assignedRole] ) -- non-strict filtering
				) or
					( tokenTable[subgroup] and tokenTable[className] and ((role and tokenTable[role]) or tokenTable[assignedRole]) ) -- strict filtering
			) then
				tinsert(sortingTable, unit);
				sortingTable[unit] = name;
				if ( groupBy == "GROUP" ) then
					groupingTable[unit] = subgroup;

				elseif ( groupBy == "CLASS" ) then
					groupingTable[unit] = className;

				elseif ( groupBy == "ROLE" ) then
					groupingTable[unit] = role;

				elseif ( groupBy == "ASSIGNEDROLE" ) then
					groupingTable[unit] = assignedRole;

				end
			end
		end

		if ( groupBy ) then
			local groupingOrder = self:GetAttribute("groupingOrder");
			doubleFillTable(wipe(tokenTable), strsplit(",", groupingOrder:gsub("%s+", "")));
			if ( sortMethod == "NAME" ) then
				table.sort(sortingTable, sortOnGroupWithNames);
			else
				table.sort(sortingTable, sortOnGroupWithIDs);
			end
		elseif ( sortMethod == "NAME" ) then -- sort by ID by default
			table.sort(sortingTable, sortOnNames);
		end

	else
		-- filtering via a list of names
		doubleFillTable(wipe(tokenTable), strsplit(",", nameList));
		for i = start, stop, 1 do
			local unit, name = GetGroupRosterInfo(kind, i);
			if ( tokenTable[name] ) then
				tinsert(sortingTable, unit);
				sortingTable[unit] = name;
			end
		end
		if ( sortMethod == "NAME" ) then
			table.sort(sortingTable, sortOnNames);
		elseif ( sortMethod == "NAMELIST" ) then
			table.sort(sortingTable, sortOnNameList)
		end

	end

	configureChildren(self, sortingTable);
end

--[[
The Pet Header accepts all of the various configuration attributes of the
regular raid header, as well as the following
======================================================
useOwnerUnit = [BOOLEAN] - if true, then the owner's unit string is set on managed frames "unit" attribute (instead of pet's)
filterOnPet = [BOOLEAN] - if true, then pet names are used when sorting/filtering the list
--]]

function SecureGroupPetHeader_OnLoad(self)
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_PET");
end

function SecureGroupPetHeader_OnEvent(self, event, ...)
	if ( (event == "GROUP_ROSTER_UPDATE" or event == "UNIT_NAME_UPDATE" or event == "UNIT_PET") and self:IsVisible() ) then
		SecureGroupPetHeader_Update(self);
	end
end

function SecureGroupPetHeader_OnAttributeChanged(self, name, value)
	if ( name == "_ignore" or self:GetAttribute("_ignore" ) ) then
		return
	end
	if ( self:IsVisible() ) then
		SecureGroupPetHeader_Update(self);
	end
end

local function GetPetUnit(kind, index)
	if ( kind == "RAID" ) then
		return "raidpet"..index;
	elseif ( index > 0 ) then
		return "partypet"..index;
	else
		return "pet";
	end
end

function SecureGroupPetHeader_Update(self)
	local nameList = self:GetAttribute("nameList");
	local groupFilter = self:GetAttribute("groupFilter");
	local sortMethod = self:GetAttribute("sortMethod");
	local groupBy = self:GetAttribute("groupBy");
	local useOwnerUnit = self:GetAttribute("useOwnerUnit");
	local filterOnPet = self:GetAttribute("filterOnPet");

	wipe(sortingTable);

	-- See if this header should be shown
	local kind, start, stop = GetGroupHeaderType(self);
	if ( not kind ) then
		configureChildren(self, sortingTable);
		return;
	end

	if ( not groupFilter and not nameList ) then
		groupFilter = "1,2,3,4,5,6,7,8";
	end

	if ( groupFilter ) then
		-- filtering by a list of group numbers and/or classes
		fillTable(wipe(tokenTable), strsplit(",", groupFilter));
		local strictFiltering = self:GetAttribute("strictFiltering"); -- non-strict by default
		for i = start, stop, 1 do
			local unit, name, subgroup, className, role = GetGroupRosterInfo(kind, i);
			local petUnit = GetPetUnit(kind, i);
			if ( filterOnPet ) then
				name = UnitName(petUnit);
			end
			if not ( useOwnerUnit ) then
				unit = petUnit;
			end
			if ( UnitExists(petUnit) ) then
				if ( name and
					(
						(not strictFiltering) and
						(tokenTable[subgroup] or tokenTable[className] or (role and tokenTable[role])) -- non-strict filtering
					) or
					(tokenTable[subgroup] and tokenTable[className]) -- strict filtering
				) then
					tinsert(sortingTable, unit);
					sortingTable[unit] = name;
					if ( groupBy == "GROUP" ) then
						groupingTable[unit] = subgroup;

					elseif ( groupBy == "CLASS" ) then
						groupingTable[unit] = className;

					elseif ( groupBy == "ROLE" ) then
						groupingTable[unit] = role;

					end
				end
			end
		end

		if ( groupBy ) then
			local groupingOrder = self:GetAttribute("groupingOrder");
			doubleFillTable(wipe(tokenTable), strsplit(",", groupingOrder));
			if ( sortMethod == "NAME" ) then
				table.sort(sortingTable, sortOnGroupWithNames);
			else
				table.sort(sortingTable, sortOnGroupWithIDs);
			end
		elseif ( sortMethod == "NAME" ) then -- sort by ID by default
			table.sort(sortingTable, sortOnNames);

		end

	else
		-- filtering via a list of names
		doubleFillTable(tokenTable, strsplit(",", nameList));
		for i = start, stop, 1 do
			local unit, name = GetGroupRosterInfo(kind, i);
			local petUnit = GetPetUnit(kind, i);
			if ( filterOnPet ) then
				name = UnitName(petUnit);
			end
			if not ( useOwnerUnit ) then
				unit = petUnit;
			end
			if ( tokenTable[name] and UnitExists(petUnit) ) then
				tinsert(sortingTable, unit);
				sortingTable[unit] = name;
			end
		end
		if ( sortMethod == "NAME" ) then
			table.sort(sortingTable, sortOnNames);
		end

	end

	configureChildren(self, sortingTable);
end
