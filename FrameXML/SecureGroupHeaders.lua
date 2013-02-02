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
	local configCode = header:GetAttribute("initialConfigFunction") or defaultConfigFunction;

	if ( type(configCode) == "string" ) then
		local selfHandle = GetFrameHandle(newChild);
		if ( selfHandle ) then
			CallRestrictedClosure("self", GetManagedEnvironment(header, true),
			                      selfHandle, configCode, selfHandle);
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
				CallRestrictedClosure("self",
				                      GetManagedEnvironment(unitButton, true),
				                      selfHandle, configCode, selfHandle);
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
local tempTable = {};

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
					((not strictFiltering) and
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

-- SecureAuraHeader contributed by alestane@comcast.net

--[[
filter = [STRING] -- a pipe-separated list of aura filter options ("RAID" will be ignored)
separateOwn = [NUMBER] -- indicate whether buffs you cast yourself should be separated before (1) or after (-1) others. If 0 or nil, no separation is done.
sortMethod = ["INDEX", "NAME", "TIME"] -- defines how the group is sorted (Default: "INDEX")
sortDirection = ["+", "-"] -- defines the sort order (Default: "+")
groupBy = [nil, auraFilter] -- if present, a series of comma-separated filters, appended to the base filter to separate auras into groups within a single stream
includeWeapons = [nil, NUMBER] -- The aura sub-stream before which to include temporary weapon enchants. If nil or 0, they are ignored.
consolidateTo = [nil, NUMBER] -- The aura sub-stream before which to place a proxy for the consolidated header. If nil or 0, consolidation is ignored.
consolidateDuration = [nil, NUMBER] -- the minimum total duration an aura should have to be considered for consolidation (Default: 30)
consolidateThreshold = [nil, NUMBER] -- buffs with less remaining duration than this many seconds should not be consolidated (Default: 10)
consolidateFraction = [nil, NUMBER] -- The fraction of remaining duration a buff should still have to be eligible for consolidation (Default: .10)

template = [STRING] -- the XML template to use for the unit buttons. If the created widgets should be something other than Buttons, append the Widget name after a comma.
weaponTemplate = [STRING] -- the XML template to use for temporary enchant buttons. Can be nil if you preset the tempEnchant1 and tempEnchant2 attributes, or if you don't include temporary enchants.
consolidateProxy = [STRING|Frame] -- Either the button which represents consolidated buffs, or the name of the template used to construct one.
consolidateHeader = [STRING|Frame] -- Either the aura header which contains consolidated buffs, or the name of the template used to construct one.

point = [STRING] -- a valid XML anchoring point (Default: "TOPRIGHT")
minWidth = [nil, NUMBER] -- the minimum width of the container frame
minHeight = [nil, NUMBER] -- the minimum height of the container frame
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons. This should typically be set to at least the width of your buff template.
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons. This should typically be set to at least the height of your buff template.
wrapAfter = [NUMBER] -- begin a new row or column after this many auras. If 0 or nil, never wrap or limit the first row
wrapXOffset = [NUMBER] -- the x-offset from one row or column to the next
wrapYOffset = [NUMBER] -- the y-offset from one row or column to the next
maxWraps = [NUMBER] -- limit the number of rows or columns. If 0 or nil, the number of rows or columns will not be limited.
--]]

local function SetupAuraButtonConfiguration( header, newChild, defaultConfigFunction )
	local configCode = newChild:GetAttribute("initialConfigFunction") or header:GetAttribute("initialConfigFunction") or defaultConfigFunction;

	if ( type(configCode) == "string" ) then
		local selfHandle = GetFrameHandle(newChild);
		if ( selfHandle ) then
			CallRestrictedClosure("self", GetManagedEnvironment(header, true),
			                      selfHandle, configCode, selfHandle);
		end
	end
end

function SecureAuraHeader_OnLoad(self)
	self:RegisterEvent("UNIT_AURA");
end

function SecureAuraHeader_OnUpdate(self)
	local hasMainHandEnchant, hasOffHandEnchant, _;
	hasMainHandEnchant, _, _, hasOffHandEnchant, _, _ = GetWeaponEnchantInfo();
	if ( hasMainHandEnchant ~= self:GetAttribute("_mainEnchanted") ) then
		self:SetAttribute("_mainEnchanted", hasMainHandEnchant);
	end
	if ( hasOffHandEnchant ~= self:GetAttribute("_secondaryEnchanted") ) then
		self:SetAttribute("_secondaryEnchanted", hasOffHandEnchant);
	end
end

function SecureAuraHeader_OnEvent(self, event, ...)
	if ( self:IsVisible() ) then
		local unit = SecureButton_GetUnit(self);
		if ( event == "UNIT_AURA" and ... == unit ) then
			SecureAuraHeader_Update(self);
		end
	end
end

function SecureAuraHeader_OnAttributeChanged(self, name, value)
	if ( name == "_ignore" or self:GetAttribute("_ignore") ) then
		return;
	end
	if ( self:IsVisible() ) then
		SecureAuraHeader_Update(self);
	end
end

local buttons = {};

local function extractTemplateInfo(template, defaultWidget)
	local widgetType;

	if ( template ) then
		template, widgetType = strsplit(",", (tostring(template):trim():gsub("%s*,%s*", ",")) );
		if ( template ~= "" ) then
			if ( not widgetType or widgetType == "" ) then
				widgetType = defaultWidget;
			end
			return template, widgetType;
		end
	end
	return nil;
end

local function constructChild(kind, name, parent, template)
	local new = CreateFrame(kind, name, parent, template);
	SetupAuraButtonConfiguration(parent, new);
	return new;
end

local enchantableSlots = {
	[1] = "MainHandSlot", 
	[2] = "SecondaryHandSlot"
}

local function configureAuras(self, auraTable, consolidateTable, weaponPosition)
	local point = self:GetAttribute("point") or "TOPRIGHT";
	local xOffset = tonumber(self:GetAttribute("xOffset")) or 0;
	local yOffset = tonumber(self:GetAttribute("yOffset")) or 0;
	local wrapXOffset = tonumber(self:GetAttribute("wrapXOffset")) or 0;
	local wrapYOffset = tonumber(self:GetAttribute("wrapYOffset")) or 0;
	local wrapAfter = tonumber(self:GetAttribute("wrapAfter"));
	if ( wrapAfter == 0 ) then wrapAfter = nil; end
	local maxWraps = self:GetAttribute("maxWraps");
	if ( maxWraps == 0 ) then maxWraps = nil; end
	local minWidth = tonumber(self:GetAttribute("minWidth")) or 0;
	local minHeight = tonumber(self:GetAttribute("minHeight")) or 0;

	if ( consolidateTable and #consolidateTable == 0 ) then
		consolidateTable = nil;
	end
	local name = self:GetName();

	wipe(buttons);
	local buffTemplate, buffWidget = extractTemplateInfo(self:GetAttribute("template"), "Button");
	if ( buffTemplate ) then
		for i=1, #auraTable do
			local childAttr = "child"..i;
			local button = self:GetAttribute("child"..i);
			if ( button ) then
				button:ClearAllPoints();
			else
				button = constructChild(buffWidget, name and name.."AuraButton"..i, self, buffTemplate);
				setAttributesWithoutResponse(self, childAttr, button, "frameref-"..childAttr, GetFrameHandle(button)); 
			end
			local buffInfo = auraTable[i];
			button:SetID(buffInfo.index);
			button:SetAttribute("index", buffInfo.index);
			button:SetAttribute("filter", buffInfo.filter);
			buttons[i] = button;
		end
	end

	local consolidateProxy = self:GetAttribute("consolidateProxy");
	if ( consolidateTable ) then
		if ( type(consolidateProxy) == 'string' ) then
			local template, widgetType = extractTemplateInfo(consolidateProxy, "Button");
			if ( template ) then
				consolidateProxy = constructChild(widgetType, name and name.."ProxyButton", self, template);
				setAttributesWithoutResponse(self, "consolidateProxy", consolidateProxy, "frameref-proxy", GetFrameHandle(consolidateProxy));
			else
				consolidateProxy = nil;
			end
		end
		if ( consolidateProxy ) then
			if ( consolidateTable.position ) then
				tinsert(buttons, consolidateTable.position, consolidateProxy);
			else
				tinsert(buttons, consolidateProxy);
			end
			consolidateProxy:ClearAllPoints();
		end
	else
		if ( consolidateProxy and type(consolidateProxy.Hide) == 'function' ) then
			consolidateProxy:Hide();
		end
	end
	if ( weaponPosition ) then
		local hasMainHandEnchant, hasOffHandEnchant, hasRangedEnchant, _;
		hasMainHandEnchant, _, _, hasOffHandEnchant, _, _, hasRangedEnchant, _, _ = GetWeaponEnchantInfo();

		for weapon=3,1,-1 do
			local weaponAttr = "tempEnchant"..weapon
			local tempEnchant = self:GetAttribute(weaponAttr)
			if ( (select(weapon, hasMainHandEnchant, hasOffHandEnchant, hasRangedEnchant)) ) then
				if ( not tempEnchant ) then
					local template, widgetType = extractTemplateInfo(self:GetAttribute("weaponTemplate"), "Button");
					if ( template ) then
						tempEnchant = constructChild(widgetType, name and name.."TempEnchant"..weapon, self, template);
						setAttributesWithoutResponse(self, weaponAttr, tempEnchant);
					end
				end
				if ( tempEnchant ) then
					tempEnchant:ClearAllPoints();
					local slot = GetInventorySlotInfo(enchantableSlots[weapon]);
					tempEnchant:SetAttribute("target-slot", slot);
					tempEnchant:SetID(slot);
					if ( weaponPosition == 0 ) then
						tinsert(buttons, tempEnchant);
					else
						tinsert(buttons, weaponPosition, tempEnchant);
					end
				end
			else
				if ( tempEnchant and type(tempEnchant.Hide) == 'function' ) then
					tempEnchant:Hide();
				end
			end
		end
	end

	local display = #buttons
	if ( wrapAfter and maxWraps ) then
		display = min(display, wrapAfter * maxWraps);
	end

	local left, right, top, bottom = math.huge, -math.huge, -math.huge, math.huge;
	for index=1,display do
		local button = buttons[index];
		local wrapAfter = wrapAfter or index
		local tick, cycle = floor((index - 1) % wrapAfter), floor((index - 1) / wrapAfter);
		button:SetPoint(point, self, cycle * wrapXOffset + tick * xOffset, cycle * wrapYOffset + tick * yOffset);
		button:Show();
		left = min(left, button:GetLeft() or math.huge);
		right = max(right, button:GetRight() or -math.huge);
		top = max(top, button:GetTop() or -math.huge);
		bottom = min(bottom, button:GetBottom() or math.huge);
	end
	local deadIndex = #(auraTable) + 1;
	local button = self:GetAttribute("child"..deadIndex);
	while ( button ) do
		button:Hide();
		deadIndex = deadIndex + 1;
		button = self:GetAttribute("child"..deadIndex)
	end
	
	if ( display >= 1 ) then
		self:SetWidth(max(right - left, minWidth));
		self:SetHeight(max(top - bottom, minHeight));
	else
		self:SetWidth(minWidth);
		self:SetHeight(minHeight);
	end
	if ( consolidateTable ) then
		local header = self:GetAttribute("consolidateHeader");
		if ( type(header) == 'string' ) then
			local template, widgetType = extractTemplateInfo(header, "Frame");
			if ( template ) then
				header = constructChild(widgetType, name and name.."ProxyHeader", consolidateProxy, template);
				setAttributesWithoutResponse(self, "consolidateHeader", header);
				consolidateProxy:SetAttribute("header", header);
				consolidateProxy:SetAttribute("frameref-header", GetFrameHandle(header))
			end
		end
		if ( header ) then
			configureAuras(header, consolidateTable);
		end
	end
end

local tremove = table.remove;

local function stripRAID(filter)
	return filter and tostring(filter):upper():gsub("RAID", ""):gsub("|+", "|"):match("^|?(.+[^|])|?$");
end

local freshTable;
local releaseTable;
do
	local tableReserve = {};
	freshTable = function ()
		local t = next(tableReserve) or {};
		tableReserve[t] = nil;
		return t;
	end
	releaseTable = function (t)
		tableReserve[t] = wipe(t);
	end
end

local sorters = {};

local function sortFactory(key, separateOwn, reverse)
	if ( separateOwn ~= 0 ) then
		if ( reverse ) then
			return function (a, b)
				if ( groupingTable[a.filter] == groupingTable[b.filter] ) then
					local ownA, ownB = a.caster == "player", b.caster == "player";
					if ( ownA ~= ownB ) then
						return ownA == (separateOwn > 0)
					end
					return a[key] > b[key];
				else
					return groupingTable[a.filter] < groupingTable[b.filter];
				end
			end;
		else
			return function (a, b)
				if ( groupingTable[a.filter] == groupingTable[b.filter] ) then
					local ownA, ownB = a.caster == "player", b.caster == "player";
					if ( ownA ~= ownB ) then
						return ownA == (separateOwn > 0)
					end
					return a[key] < b[key];
				else
					return groupingTable[a.filter] < groupingTable[b.filter];
				end
			end;
		end
	else
		if ( reverse ) then
			return function (a, b)
				if ( groupingTable[a.filter] == groupingTable[b.filter] ) then
					return a[key] > b[key];
				else
					return groupingTable[a.filter] < groupingTable[b.filter];
				end
			end;
		else
			return function (a, b)
				if ( groupingTable[a.filter] == groupingTable[b.filter] ) then
					return a[key] < b[key];
				else
					return groupingTable[a.filter] < groupingTable[b.filter];
				end
			end;
		end
	end
end

for i, key in ipairs{"index", "name", "expires"} do
	local label = key:upper();
	sorters[label] = {};
	for bool in pairs{[true] = true, [false] = false} do
		sorters[label][bool] = {}
		for sep=-1,1 do
			sorters[label][bool][sep] = sortFactory(key, sep, bool);
		end
	end
end
sorters.TIME = sorters.EXPIRES;

function SecureAuraHeader_Update(self)
	local filter = self:GetAttribute("filter");
	local groupBy = self:GetAttribute("groupBy");
	local unit = SecureButton_GetUnit(self) or "player";
	local includeWeapons = tonumber(self:GetAttribute("includeWeapons"));
	if ( includeWeapons == 0 ) then
		includeWeapons = nil
	end
	local consolidateTo = tonumber(self:GetAttribute("consolidateTo"));
	local consolidateDuration, consolidateThreshold, consolidateFraction;
	if ( consolidateTo ) then
		consolidateDuration = tonumber(self:GetAttribute("consolidateDuration")) or 30;
		consolidateThreshold = tonumber(self:GetAttribute("consolidateThreshold")) or 10;
		consolidateFraction = tonumber(self:GetAttribute("consolidateFraction")) or 0.1;
	end
	local sortDirection = self:GetAttribute("sortDirection");
	local separateOwn = tonumber(self:GetAttribute("separateOwn")) or 0;
	if ( separateOwn > 0 ) then
		separateOwn = 1;
	elseif (separateOwn < 0 ) then
		separateOwn = -1;
	end
	local sortMethod = (sorters[tostring(self:GetAttribute("sortMethod")):upper()] or sorters["INDEX"])[sortDirection == "-"][separateOwn];

	local time = GetTime();

	local consolidateTable;
	if ( consolidateTo and consolidateTo ~= 0 ) then
		consolidateTable = wipe(tokenTable);
	end

	wipe(sortingTable);
	wipe(groupingTable);

	if ( groupBy ) then
		local i = 1;
		for subFilter in groupBy:gmatch("[^,]+") do
			if ( filter ) then
				subFilter = stripRAID(filter.."|"..subFilter);
			else
				subFilter = stripRAID(subFilter);
			end
			groupingTable[subFilter], groupingTable[i] = i, subFilter;
			i = i + 1;
		end
	else
		filter = stripRAID(filter);
		groupingTable[filter], groupingTable[1] = 1, filter;
	end
	if ( consolidateTable and consolidateTo < 0 ) then
		consolidateTo = #groupingTable + consolidateTo + 1;
	end
	if ( includeWeapons and includeWeapons < 0 ) then
		includeWeapons = #groupingTable + includeWeapons + 1;
	end
	local weaponPosition;
	for filterIndex, fullFilter in ipairs(groupingTable) do
		if ( consolidateTable and not consolidateTable.position and filterIndex >= consolidateTo ) then
			consolidateTable.position = #sortingTable + 1;
		end
		if ( includeWeapons and not weaponPosition and filterIndex >= includeWeapons ) then
			weaponPosition = #sortingTable + 1;
		end

		local i = 1;
		repeat
			local aura, _, duration = freshTable();
			aura.name, _, _, _, _, duration, aura.expires, aura.caster, _, aura.shouldConsolidate, _ = UnitAura(unit, i, fullFilter);
			if ( aura.name ) then
				aura.filter = fullFilter;
				aura.index = i;
				local targetList = sortingTable;
				if ( consolidateTable and aura.shouldConsolidate ) then
					if ( not aura.expires or duration > consolidateDuration or (aura.expires - time >= max(consolidateThreshold, duration * consolidateFraction)) ) then
						targetList = consolidateTable;
					end
				end
				tinsert(targetList, aura);
			else
				releaseTable(aura);
			end
			i = i + 1;
		until ( not aura.name );
	end
	if ( includeWeapons and not weaponPosition ) then
		weaponPosition = 0;
	end
	table.sort(sortingTable, sortMethod);
	if ( consolidateTable ) then
		table.sort(consolidateTable, sortMethod);
	end

	configureAuras(self, sortingTable, consolidateTable, weaponPosition);
	while ( sortingTable[1] ) do
		releaseTable(tremove(sortingTable));
	end
	while ( consolidateTable and consolidateTable[1] ) do
		releaseTable(tremove(consolidateTable));
	end
end
