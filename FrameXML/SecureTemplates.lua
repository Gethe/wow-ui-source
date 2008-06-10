
-- The "modified attribute" takes the form of: modifier-name-button
-- The modifier is one of "shift-", "ctrl-", "alt-", and the button is a number from 1 through 5.
--
-- For example, you could set an action that is used for unmodified left click like this:
-- self:SetAttribute("action1", value);
-- You could set an action that is used for shift-right-click like this:
-- self:SetAttribute("shift-action2", value);
--
-- You can also use a wildcard in the place of the modifier or button to denote an attribute
-- that is used for any modifier or any button.
--
-- For example, you could set an action that is used for any left click like this:
-- self:SetAttribute("*action1", value);
-- You could set an action that is used for shift-click with any button like this:
-- self:SetAttribute("shift-action*", value);
--
ATTRIBUTE_NOOP = "";
-- You can exclude an action by explicitly setting its value to ATTRIBUTE_NOOP
--
-- For example, you could set an action that was used for all clicks except ctrl-left-click:
-- self:SetAttribute("*action*", value);
-- self:SetAttribute("shift-action1", ATTRIBUTE_NOOP);
--
-- Setting the attribute by itself is equivalent to *attribute*

function SecureButton_GetModifierPrefix()
    local prefix = "";
    if ( IsShiftKeyDown() ) then
        prefix = "shift-"..prefix;
    end
    if ( IsControlKeyDown() ) then
        prefix = "ctrl-"..prefix;
    end
    if ( IsAltKeyDown() ) then
        prefix = "alt-"..prefix;
    end
	return prefix;
end

function SecureButton_GetButtonSuffix(button)
	local suffix = "";
    if ( button == "LeftButton" ) then
        suffix = "1";
    elseif ( button == "RightButton" ) then
        suffix = "2";
    elseif ( button == "MiddleButton" ) then
        suffix = "3";
    elseif ( button == "Button4" ) then
        suffix = "4";
    elseif ( button == "Button5" ) then
        return "5";
    elseif ( button and button ~= "" ) then
        suffix = "-" .. tostring(button);
    end
    return suffix;
end

function SecureButton_GetModifiedAttribute(frame, name, button, prefix, suffix)
	if ( not prefix ) then
		prefix = SecureButton_GetModifierPrefix();
	end
	if ( not suffix ) then
		suffix = SecureButton_GetButtonSuffix(button);
	end
    local value = frame:GetAttribute(prefix..name..suffix) or
                  frame:GetAttribute("*"..name..suffix) or
                  frame:GetAttribute(prefix..name.."*") or
                  frame:GetAttribute("*"..name.."*") or
                  frame:GetAttribute(name);
    if ( not value and (frame:GetAttribute("useparent-"..name) or
                        frame:GetAttribute("useparent*")) ) then
        local parent = frame:GetParent();
        if ( parent ) then
            value = SecureButton_GetModifiedAttribute(parent, name, button, prefix, suffix);
        end
    end
    if ( value == ATTRIBUTE_NOOP ) then
        value = nil;
    end
    return value;
end
function SecureButton_GetAttribute(frame, name)
	return SecureButton_GetModifiedAttribute(frame, name, nil, "", "");
end

function SecureButton_GetModifiedUnit(self, button)
	local unit = SecureButton_GetModifiedAttribute(self, "unit", button);
	if ( unit ) then
		local unitsuffix = SecureButton_GetModifiedAttribute(self, "unitsuffix", button);
		if ( unitsuffix ) then
			unit = unit .. unitsuffix;
			-- map raid1pet to raidpet1
			unit = gsub(unit, "^([^%d]+)([%d]+)[pP][eE][tT]", "%1pet%2");
		end
		return unit;
	end
	if ( SecureButton_GetModifiedAttribute(self, "checkselfcast", button) and IsActionSelfCastKeyDown() ) then
		return "player";
	end
end
function SecureButton_GetUnit(self)
	local unit = SecureButton_GetAttribute(self, "unit");
	if ( unit ) then
		local unitsuffix = SecureButton_GetAttribute(self, "unitsuffix");
		if ( unitsuffix ) then
			unit = unit .. unitsuffix;
			-- map raid1pet to raidpet1
			unit = gsub(unit, "^([^%d]+)([%d]+)[pP][eE][tT]", "%1pet%2");
		end
		return unit;
	end
end

--
-- SecureActionButton
--
-- SecureActionButtons allow you to map different combinations of modifiers and buttons into
-- actions which are executed when the button is clicked.
--
-- For example, you could set up the button to respond to left clicks by targeting the focus:
-- self:SetAttribute("unit", "focus");
-- self:SetAttribute("type1", "target");
--
-- You could set up all other buttons to bring up a menu like this:
-- self:SetAttribute("type*", "menu");
-- self.showmenu = menufunc;
--
-- SecureActionButtons are also able to perform different actions depending on whether you can
-- attack the unit or assist the unit associated with the action button.  It does so by mapping
-- mouse buttons into "virtual buttons" based on the state of the unit. For example, you can use
-- the following to cast "Mind Blast" on a left click and "Shadow Word: Death" on a right click
-- if the unit can be attacked:
-- self:SetAttribute("harmbutton1", "nuke1");
-- self:SetAttribute("type-nuke1", "spell");
-- self:SetAttribute("spell-nuke1", "Mind Blast");
-- self:SetAttribute("harmbutton2", "nuke2");
-- self:SetAttribute("type-nuke2", "spell");
-- self:SetAttribute("spell-nuke2", "Shadow Word: Death");
--
-- In this example, we use the special attribute "harmbutton" which is used to map a virtual
-- button when the unit is attackable. We also have the attribute "helpbutton" which is used
-- when the unit can be assisted.
--
-- Although it may not be immediately obvious, we are able to use this new virtual button
-- to set up very complex click behaviors on buttons. For example, we can define a new "heal"
-- virtual button for all friendly left clicks, and then set the button to cast "Flash Heal"
-- on an unmodified left click and "Renew" on a ctrl left click:
-- self:SetAttribute("*helpbutton1", "heal");
-- self:SetAttribute("*type-heal", "spell");
-- self:SetAttribute("spell-heal", "Flash Heal");
-- self:SetAttribute("ctrl-spell-heal", "Renew");
--
-- This system is very powerful, and provides a good layer of abstraction for setting up
-- a button's click behaviors.

function SecureActionButton_OnClick(self, button)

	-- Allow remapping from a 'detached' state header
	local stateheader = self:GetAttribute("stateheader"); 
	if ( stateheader and (not InCombatLockdown() or stateheader:IsProtected()) ) then 
		local state = tostring(stateheader:GetAttribute("state") or "0");
		button = SecureState_GetStateModifiedAttribute(self, state, "statebutton", button) or button;
	end

	-- Lookup the unit, based on the modifiers and button
	local unit = SecureButton_GetModifiedUnit(self, button);

	-- Don't do anything if our unit doesn't exist
	if ( unit and unit ~= "none" and not UnitExists(unit) ) then
		return;
	end
 
	-- Remap button suffixes based on the disposition of the unit (contributed by Iriel and Cladhaire)
	if ( unit ) then
		local origButton = button;
		if ( UnitCanAttack("player", unit) )then
			button = SecureButton_GetModifiedAttribute(self, "harmbutton", button) or button;
		elseif ( UnitCanAssist("player", unit) )then
			button = SecureButton_GetModifiedAttribute(self, "helpbutton", button) or button;
		end

		-- The unit may have changed based on button remapping
		if ( button ~= origButton ) then
			unit = SecureButton_GetModifiedUnit(self, button);

			-- Don't do anything if our unit doesn't exist
			if ( unit and unit ~= "none" and not UnitExists(unit) ) then
				return;
			end
		end
	end

	-- Lookup the action type, based on the modifiers and button
	local type = SecureButton_GetModifiedAttribute(self, "type", button);

	-- Perform the requested action!
	if ( type == "actionbar" ) then
		local action = SecureButton_GetModifiedAttribute(self, "action", button);
		if ( action == "increment" ) then
			ActionBar_PageUp();
		elseif ( action == "decrement" ) then
			ActionBar_PageDown();
		elseif ( tonumber(action) ) then
			ChangeActionBarPage(action);
		else
			local a, b = strmatch(action, "^(%d+),%s*(%d+)$");
			if ( GetActionBarPage() == tonumber(a) ) then
				ChangeActionBarPage(b);
			else
				ChangeActionBarPage(a);
			end
		end
	elseif ( type == "action" ) then
		local action = SecureButton_GetModifiedAttribute(self, "action", button);
		if ( not action ) then
			action = ActionButton_GetPagedID(self);
		end
		if ( action ) then
			-- Save macros in case the one for this action is being edited
			securecall("MacroFrame_SaveMacro");

			UseAction(action, unit, button);
		end
	elseif ( type == "pet" ) then
		local action = SecureButton_GetModifiedAttribute(self, "action", button);
		if ( action ) then
			CastPetAction(action, unit);
		end
	elseif ( type == "spell" ) then
		local spell = SecureButton_GetModifiedAttribute(self, "spell", button);
		if ( spell ) then
			CastSpellByName(spell, unit);
		end
	elseif ( type == "item" ) then
		local bag = SecureButton_GetModifiedAttribute(self, "bag", button);
		local slot = SecureButton_GetModifiedAttribute(self, "slot", button);
		if ( slot ) then
			if ( bag ) then
				UseContainerItem(bag, slot, unit);
			else
				UseInventoryItem(slot, unit);
			end
		else
			local item = SecureButton_GetModifiedAttribute(self, "item", button);
			if ( item ) then
				UseItemByName(item, unit);
			end
		end
	elseif ( type == "macro" ) then
		local macro = SecureButton_GetModifiedAttribute(self, "macro", button);
		if ( macro ) then
			-- Save macros in case the one for this action is being edited
			securecall("MacroFrame_SaveMacro");

			RunMacro(macro, button);
		else
			local text = SecureButton_GetModifiedAttribute(self, "macrotext", button);
			if ( text ) then
				RunMacroText(text, button);
			end
		end
	elseif ( type == "stop" ) then
		if ( SpellIsTargeting() ) then
			SpellStopTargeting();
		end
	elseif ( type == "target" ) then
		if ( SpellIsTargeting() ) then
			SpellTargetUnit(unit);
		elseif ( CursorHasItem() ) then
			DropItemOnUnit(unit);
		else
			TargetUnit(unit);
		end
	elseif ( type == "focus" ) then
		FocusUnit(unit);
	elseif ( type == "assist" ) then
		AssistUnit(unit);
	elseif ( type == "click" ) then
		local delegate = SecureButton_GetModifiedAttribute(self, "clickbutton", button);
		if ( delegate ) then
			delegate:Click(button);
		end
	elseif ( type ) then
		-- Custom action support
		local func = rawget(self, type);
		if ( func ) then
			func(self, unit, button);
		end
	end

	-- Target predefined item, if we just cast a spell that targets an item
	if ( SpellCanTargetItem() ) then
		local bag = SecureButton_GetModifiedAttribute(self, "target-bag", button);
		local slot = SecureButton_GetModifiedAttribute(self, "target-slot", button);
		if ( slot ) then
			if ( bag ) then
				UseContainerItem(bag, slot);
			else
				UseInventoryItem(slot);
			end
		else
			local item = SecureButton_GetModifiedAttribute(self, "target-item", button);
			if ( item ) then
				SpellTargetItem(item);
			end
		end
	end
end

function SecureUnitButton_OnLoad(self, unit, menufunc)
	self:SetAttribute("type1", "target");
	self:SetAttribute("type*", "menu");
	self:SetAttribute("unit", unit);
	self.menu = menufunc;
end

function SecureUnitButton_OnClick(self, button)
    local type = SecureButton_GetModifiedAttribute(self, "type", button);
    if ( type == "menu" ) then
        if ( SpellIsTargeting() ) then
            SpellStopTargeting();
            return;
        end
    end
    SecureActionButton_OnClick(self, button);
end


--
-- SecureStateDriver contributed with permission by: Iriel
--

-- Prepare the frame to receive and process state changing events
function SecureStateDriver_OnLoad(self)
	self:SetAttribute("state-shift", 0);
	self:SetAttribute("state-ctrl", 0);
	self:SetAttribute("state-alt", 0);
	self:SetAttribute("state-actionbar", 0);
	self:SetAttribute("state-stance", GetShapeshiftForm(true));
	self:SetAttribute("state-stealth", IsStealthed() or 0);

    self:RegisterEvent("MODIFIER_STATE_CHANGED");
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("UPDATE_STEALTH");
end

-- Handle a state changing event and issue SetAttribute calls if the state changes.
function SecureStateDriver_OnEvent(self, event, ...)
	if ( event == "MODIFIER_STATE_CHANGED" ) then
		local key, state = select(1, ...);
		local name = "state-"..key;
		local oldState = self:GetAttribute(name);
		local curState = state;
		if ( oldState ~= curState ) then
			self:SetAttribute(name, curState);
		end
		return;
	end
	if ( event == "ACTIONBAR_PAGE_CHANGED" ) then
		local oldState = self:GetAttribute("state-actionbar");
		local curState = GetActionBarPage();
		if ( oldState ~= curState ) then
			self:SetAttribute("state-actionbar", curState);
		end
		return;
	end
	if ( event == "PLAYER_ENTERING_WORLD" or
	     event == "UPDATE_SHAPESHIFT_FORM" ) then
		local oldState = self:GetAttribute("state-stance");
		local curState = GetShapeshiftForm(true);
		if ( oldState ~= curState ) then
			self:SetAttribute("state-stance", curState);
		end
		if ( event ~= "PLAYER_ENTERING_WORLD" ) then
			return;
		end
	end
	if ( event == "PLAYER_ENTERING_WORLD" or
	     event == "UPDATE_STEALTH" ) then
		local oldState = self:GetAttribute("state-stealth");
		local curState = IsStealthed() or 0;
		if ( oldState ~= curState ) then
			self:SetAttribute("state-stealth", curState);
		end
		if ( event ~= "PLAYER_ENTERING_WORLD" ) then
			return;
		end
	end
end


--
-- SecurePieButton contributed with permission by: Iriel
--
-- The SecurePieButton provides support for pie menus which are radial
-- menus that generally appear under the cursor. These are expected to be
-- used in conjunction with a SecureStaetHeader. The menu is configured with
-- a number of attributes that follow the 'state attribute' specification
-- (described in SecureStateHeader.lua) to configure how each pie is to be
-- constructued based on the header state.
--
-- piecount   -- The number of segments in the pie (required)
-- piemindist -- Minimum radius to register an action (default: 1)
-- piegap     -- 'Dead space' angle between segments (degrees, default: 0)
-- pieoffset  -- Offset of first segment from top (degrees, default: 0)
--
-- pievariation -- The child/button variation for this pie.
--
-- The popup pie dispatches actions to one or more 'pie children' which
-- are defined via the modifier aware attributes. In order to allow for
-- different children in different states, if it's set the pievariation
-- attribute's applicable value is used as <var> in the following names,
-- and <var> is the empty string if the attribute is not specified.
--
-- pie<var>1child -- The first segment's child
-- pie<var>2child -- The second segment's child
-- ...
-- pie<var>nonechild -- The child for an 'dead space click' operation
--
-- Each of these piechild attributes also has a corresponding pie button
-- attribute (e.g. 'pie<var>1button') that can be used to override the button
-- that will be sent to the child.
--
-- If you'd prefer to dispatch all clicks through a single child, with
-- different button mappings for each operation, then you can set the
-- 'pie<var>*child' attribute to be the child to use, and then you can
-- specify an appropriate 'pie<var><op>button' setting. You can specify
-- the string "none" as a child or a button to disable the operation
-- in that location.
---------------------------------------------------------------------------

-- Read the properties from a pie button, validate the sanity of the pie
-- specification and return either the pie specification or nil
--
-- Returns:
--   varname -- The variation name (or the empty string)
--   count   -- Number of options in the pie
--   mindist -- Minimum move distance for a selection
--   gap     -- 'Dead' angle between active sectors (degrees)
--   offset  -- Offset of center of first sector from 'top' position (degrees)
function SecurePieButton_GetSettings(self, button)
    local parent  = self:GetParent();
    local state   = tostring((parent and parent:GetAttribute("state")) or 0);

    local GSA = SecureState_GetStateAttribute;
    local count   = GSA(self, state, "piecount");
    local mindist = GSA(self, state, "piemindist");
    local gap     = GSA(self, state, "piegap");
    local offset  = GSA(self, state, "pieoffset");
    local varname = GSA(self, state, "pievariation");

    varname = tostring(varname or "");

    count = math.floor(tonumber(count) or 0);
    mindist = tonumber(mindist) or 1;
    gap = tonumber(gap) or 0;
    offset = math.fmod(tonumber(offset) or 0, 360);
    while (offset < 0) do 
        offset = offset + 360;
    end
    -- Skip silly configurations
    if ((count <= 0) or (mindist <= 0) or ((gap * count) >= 360)) then
        return varname;
    end

    return varname, count, mindist, gap, offset;
end

-- Given cursor offset from a center point and a pie specification, return
-- the index of the segment the mouse is over (1..count), or nil if none.
function SecurePieButton_GetIndex(dx, dy, maxdist, count, mindist, gap, offset)
    local dist = math.sqrt(dx * dx + dy * dy);
    if ((not count) or (dist < mindist) or (dist > maxdist)) then
        return;
    end
    
    local segment = 360 / count;
    local angle = math.deg(math.atan2(dx, dy)) + 360 + segment/2 - offset;
    while (angle < 0) do angle = angle + 360; end
    angle = math.fmod(angle, 360);
    
    local index = (math.floor(angle / segment) % count) + 1;
    angle = math.fmod(angle, segment);

    if ((angle < (gap / 2)) or (angle > (segment - (gap / 2)))) then
        return;
    end
    
    return index;
end

-- Dispatch a click to the named pie child, optionally remapping the button.
function SecurePieButton_DispatchClick(self, suffix, varname, button)
    -- This gets called lots and is long
    local GMA = SecureButton_GetModifiedAttribute;
    local prefix = "pie" .. varname;

    local child = GMA(self, prefix .. suffix .. "child", button) or
	              GMA(self, prefix .. "*child", button);

    local button = GMA(self, prefix .. suffix .. "button", button) or
	               GMA(self, prefix.. "*button", button) or
	               button;

    if (child and child ~= "none" and button ~= "none") then
        child:Click(button);
    end
end

-- Handle button click for pie menu
function SecurePieButton_OnClick(self, button)
    -- Prevent abuse
    if (InCombatLockdown() and not self:IsProtected()) then
        return;
    end

    if (not self:IsVisible() or not self:GetRect()) then
		return;
    end

    local scale = self:GetEffectiveScale();
    local l, b, w, h = self:GetRect();
    local maxdist = math.max(w,h) / 2;
    local x, y = GetCursorPosition();
    local dx, dy = (x / scale) - (l + w / 2), (y / scale) - (b + h / 2);

    local varname, count, mindist, gap, offset = SecurePieButton_GetSettings(self, button);
    local index = SecurePieButton_GetIndex(dx, dy, maxdist, count, mindist, gap, offset);

    SecurePieButton_DispatchClick(self, index or "none", varname, button);
end


--
-- SecurePartyHeader and SecureRaidGroupHeader contributed with permission by: Esamynn, Cide, and Iriel
--

--[[
List of the various configuration attributes
======================================================
nameList = [STRING] -- a comma separated list of player names (not used if 'groupFilter' is set)
groupFilter = [1-8, STRING] -- a comma seperated list of raid group numbers and/or uppercase class names
strictFiltering = [BOOLEAN] - if true, then characters must match both a group and a class from the groupFilter list
point = [STRING] -- a valid XML anchoring point (Default: "TOP")
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: 0)
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: 0)
sortMethod = ["INDEX", "NAME"] -- defines how the group is sorted (Default: "INDEX")
sortDir = ["ASC", "DESC"] -- defines the sort order (Default: "ASC")
template = [STRING] -- the XML template to use for the unit buttons
templateType = [STRING] - specifies the frame type of the managed subframes (Default: "Button")
--]]

function SecurePartyHeader_OnLoad(self)
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("PARTY_MEMBER_ENABLE");
	this:RegisterEvent("PARTY_MEMBER_DISABLE");
end

function SecurePartyHeader_OnEvent(self, event)
	if ( (event == "PARTY_MEMBERS_CHANGED" or
	      event == "PARTY_MEMBER_ENABLE" or
	      event == "PARTY_MEMBER_DISABLE") and self:IsVisible() ) then
		SecurePartyHeader_Update(self);
	end
end

function SecurePartyHeader_OnAttributeChanged(self, name, value)
	if ( self:IsVisible() ) then
		SecurePartyHeader_Update(self);
	end
end

function SecureRaidGroupHeader_OnLoad(self)
	self:RegisterEvent("RAID_ROSTER_UPDATE");
end

function SecureRaidGroupHeader_OnEvent(self, event)
	if ( event == "RAID_ROSTER_UPDATE" and self:IsVisible() ) then
		SecureRaidGroupHeader_Update(self);
	end
end

function SecureRaidGroupHeader_OnAttributeChanged(self, name, value)
	if ( self:IsVisible() ) then
		SecureRaidGroupHeader_Update(self);
	end
end

-- relativePoint, xMultiplier, yMultiplier = getRelativePointAnchor( point )
-- Given a point return the opposite point and which axes the point
-- depends on.
local function getRelativePointAnchor( point )
	point = strupper(point);
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

function ApplyUnitButtonConfiguration( ... )
	for i = 1, select("#", ...), 1 do
		local frame = select(i, ...);
		local anchor = frame:GetAttribute("initial-anchor");
		local width = tonumber(frame:GetAttribute("initial-width") or nil);
		local height = tonumber(frame:GetAttribute("initial-height")or nil);
		local scale = tonumber(frame:GetAttribute("initial-scale")or nil);
		local unitWatch = frame:GetAttribute("initial-unitWatch");
		if ( anchor ) then
			local point, relPoint, xOffset, yOffset = strsplit(",", anchor);
			relpoint = relpoint or point;
			xOffset = tonumber(xOffset) or 0;
			yOffset = tonumber(yOffset) or 0;
			frame:SetPoint(point, frame:GetParent(), relPoint, xOffset, yOffset);
		end
		if ( width ) then
			frame:SetWidth(width);
		end
		if ( height ) then
			frame:SetHeight(height);
		end
		if ( scale ) then
			frame:SetScale(scale);
		end
		if ( unitWatch ) then
			if ( unitWatch == "state" ) then
				RegisterUnitWatch(frame, true);
			else
				RegisterUnitWatch(frame);
			end
		end
		
		-- call this function recursively for the current frame's children
		ApplyUnitButtonConfiguration(frame:GetChildren());
	end
end

local function ApplyConfig( header, newChild, defaultConfigFunction )
	local configFunction = header.initialConfigFunction or defaultConfigFunction;
	if ( type(configFunction) == "function" ) then
		configFunction(newChild);
		return true;
	end
end

function SetupUnitButtonConfiguration( header, newChild, defaultConfigFunction )
	newChild:AllowAttributeChanges();
	if ( securecall(ApplyConfig, header, newChild, defaultConfigFunction) ) then
		ApplyUnitButtonConfiguration(newChild);
	end
end

-- empties tbl and assigns the value true to each key passed as part of ...
local function fillTable( tbl, ... )
	for key in pairs(tbl) do
		tbl[key] = nil;
	end
	for i = 1, select("#", ...), 1 do
		local key = select(i, ...);
		key = tonumber(key) or key;
		tbl[key] = true;
	end
end

-- same as fillTable() except that each key is also stored in 
-- the array portion of the table in order
local function doubleFillTable( tbl, ... )
	fillTable(tbl, ...);
	for i = 1, select("#", ...), 1 do
		tbl[i] = select(i, ...);
	end
end

--working tables
local tokenTable = {};
local sortingTable = {};

-- creates child frames and finished configuring them
local function configureChildren(self)
	local point = self:GetAttribute("point") or "TOP"; --default anchor point of "TOP"
	local relativePoint, xOffsetMult, yOffsetMult = getRelativePointAnchor(point);
	local xMultiplier, yMultiplier =  abs(xOffsetMult), abs(yOffsetMult);
	local xOffset = self:GetAttribute("xOffset") or 0; --default of 0
	local yOffset = self:GetAttribute("yOffset") or 0; --default of 0
	local sortMethod = self:GetAttribute("sortMethod") or "INDEX"; --sort by ID by default
	local sortDir = self:GetAttribute("sortDir") or "ASC"; --sort ascending by default

	if ( sortMethod == "NAME" ) then
		table.sort(sortingTable);
	end
	
	local unitCount = #sortingTable;
	
	-- ensure there are enough buttons
	local needButtons = max(1, unitCount);
	if not ( self:GetAttribute("child"..needButtons) ) then
		local buttonTemplate = self:GetAttribute("template");
		local templateType = self:GetAttribute("templateType") or "Button";
		local name = self:GetName();
		if not ( buttonTemplate and name ) then
			self:Hide();
			return;
		end
		for i = 1, needButtons, 1 do
			if not ( self:GetAttribute("child"..i) ) then
				local newButton = CreateFrame(templateType, name.."UnitButton"..i, self, buttonTemplate);
				SetupUnitButtonConfiguration(self, newButton);
				self:SetAttribute("child"..i, newButton);
			end
		end
	end
	
	local loopStart, loopFinish, step = 1, unitCount, 1;
	if ( sortDir == "DESC" ) then
		loopStart, loopFinish, step = unitCount, 1, -1;
	end
	
	local buttonNum = 0;
	local currentAnchor = self;
	for i = loopStart, loopFinish, step do
		buttonNum = buttonNum + 1;
		
		local unitButton = self:GetAttribute("child"..buttonNum);
		unitButton:Hide();
		unitButton:ClearAllPoints();
		if ( buttonNum == 1 ) then
			unitButton:SetPoint(point, currentAnchor, point, 0, 0);
		else
			unitButton:SetPoint(point, currentAnchor, relativePoint, xMultiplier * xOffset, yMultiplier * yOffset);
		end
		unitButton:SetAttribute("unit", sortingTable[sortingTable[i]]);
		unitButton:Show();
		
		currentAnchor = unitButton;
	end
	repeat
		buttonNum = buttonNum + 1;
		local unitButton = self:GetAttribute("child"..buttonNum);
		if ( unitButton ) then
			unitButton:Hide();
			unitButton:SetAttribute("unit", nil);
		end
	until not ( unitButton )
	
	local unitButton = self:GetAttribute("child1");
	local unitButtonWidth = unitButton:GetWidth();
	local unitButtonHeight = unitButton:GetHeight();
	if ( unitCount > 0 ) then
		self:SetWidth( xMultiplier * (unitCount - 1) * unitButtonWidth + ( (unitCount - 1) * (xOffset * xOffsetMult) ) + unitButtonWidth );
		self:SetHeight( yMultiplier * (unitCount - 1) * unitButtonHeight + ( (unitCount - 1) * (yOffset * yOffsetMult) ) + unitButtonHeight );
	else
		local minWidth = self:GetAttribute("minWidth") or (yMultiplier * unitButtonWidth);
		local minHeight = self:GetAttribute("minHeight") or (xMultiplier * unitButtonHeight);
		self:SetWidth( max(minWidth, 0.1) );
		self:SetHeight( max(minHeight, 0.1) );
	end
end

function SecurePartyHeader_Update(self)
	for key in pairs(sortingTable) do
		sortingTable[key] = nil;
	end

	for i = 1, GetNumPartyMembers(), 1 do
		local unit = "party"..i;
		local name = UnitName(unit);
		tinsert(sortingTable, name);
		sortingTable[name] = unit;
	end

	configureChildren(self);
end

function SecureRaidGroupHeader_Update(self)
	local nameList = self:GetAttribute("nameList");
	local groupFilter = self:GetAttribute("groupFilter");
	
	if not ( groupFilter or nameList ) then
		self:Hide();
		return;
	end
	
	for key in pairs(sortingTable) do
		sortingTable[key] = nil;
	end
	
	if ( groupFilter ) then
		-- filtering by a list of group numbers and/or classes
		fillTable(tokenTable, strsplit(",", groupFilter));
		local strictFiltering = self:GetAttribute("strictFiltering"); -- non-strict by default
		for i = 1, GetNumRaidMembers(), 1 do
			local name, _, subgroup, _, _, className = GetRaidRosterInfo(i);
			if ( ((not strictFiltering) and 
			      (tokenTable[subgroup] or tokenTable[className]) -- non-strict filtering
			     ) or 
			      (tokenTable[subgroup] and tokenTable[className]) -- strict filtering
			) then
				tinsert(sortingTable, name);
				sortingTable[name] = "raid"..i;
			end
		end
	
	elseif ( nameList ) then
		-- filtering via a list of names
		doubleFillTable(sortingTable, strsplit(",", nameList));
		for i = 1, GetNumRaidMembers(), 1 do
			local name = GetRaidRosterInfo(i);
			if ( sortingTable[name] ) then
				sortingTable[name] = "raid"..i;
			end
		end
		for i = #sortingTable, 1, -1 do
			local name = sortingTable[i];
			if ( sortingTable[name] == true ) then
				tremove(sortingTable, i);
			end
		end
	
	else
		self:Hide();
		return;
	end

	configureChildren(self);
end
