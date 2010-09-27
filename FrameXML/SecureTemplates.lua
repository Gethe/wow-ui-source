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

-- Internal helper function for modifier parsing
local strsplit = strsplit;
local function ParseSplitModifierString(...)
    for i=1, select('#', ...) do
        local mod, rep = strsplit(':', (select(i, ...)));
        if ( IsModifiedClick(mod) ) then
            return rep or mod:lower();
        end
    end
end

-- Given a modifier string which consists of one or more modifier
-- clauses separated by commas, return the id of the first matching
-- clause. If no modifiers match then nil is returned.
--
-- A modifier clause is of the form MODIFIER or the form MODIFIER:prefix
--
-- e.g.
--
-- "SELFCAST:self,CTRL"
--
-- will return 'self' if the self cast modifier is held down, or 'ctrl' if
-- the control key is held down
function SecureButton_ParseModifierString(msg)
    return ParseSplitModifierString(strsplit(',', msg));
end

-- Get the current modifier prefix for a frame (optional), if the frame has
-- a modifiers attribute defined, then it will be parsed using
-- SecureButton_ParseModifiersString and used as the prefix.
--
-- If no frame is specified, or the frame has no modifiers property, then
-- the old style prefix functionality is used.
function SecureButton_GetModifierPrefix(frame)
    -- Handle optional frame modifiers attribute
    if ( frame ) then
        local modlist = frame:GetAttribute("modifiers");
        if ( modlist ) then
            local prefix = SecureButton_ParseModifierString(modlist);
            if ( prefix ) then
                return prefix .. "-";
            end
        end
    end

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

-- Build lookup table for less common buttons
local BUTTON_LOOKUP_TABLE = {};
for n = 4, 31 do
    BUTTON_LOOKUP_TABLE["Button" .. n] = tostring(n);
end

function SecureButton_GetButtonSuffix(button)
    if ( button == "LeftButton" ) then
        return "1";
    elseif ( button == "RightButton" ) then
        return "2";
    elseif ( button == "MiddleButton" ) then
        return "3";
    elseif (button and button ~= "") then
        local lookup = BUTTON_LOOKUP_TABLE[button];
        if ( lookup ) then
            return lookup
        else
            return "-" .. tostring(button);
        end
    end
    return "";
end

function SecureButton_GetModifiedAttribute(frame, name, button, prefix, suffix)
    if ( not prefix ) then
        prefix = SecureButton_GetModifierPrefix(frame);
    end
    if ( not suffix ) then
        suffix = SecureButton_GetButtonSuffix(button);
    end
    local value = frame:GetAttribute(prefix, name, suffix);
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
                        unit = gsub(unit, "^[pP][lL][aA][yY][eE][rR][pP][eE][tT]", "pet");
                end

                local noPet, hadPet = unit:gsub("[pP][eE][tT](%d)", "%1");
                if ( hadPet == 0 ) then
                        noPet, hadPet = unit:gsub("^[pP][eE][tT]", "player");
                end
                local noPetNoTarget, hadTarget = noPet:gsub("[tT][aA][rR][gG][eE][tT]", "");
                if ( UnitHasVehicleUI(noPetNoTarget) and
                                SecureButton_GetModifiedAttribute(self, "toggleForVehicle", button) and
                                (noPetNoTarget == noPetNoTarget:gsub("^[mM][oO][uU][sS][eE][oO][vV][eE][rR]", "")
                                                               :gsub("^[fF][oO][cC][uU][sS]", "")
                                                               :gsub("^[aA][rR][eE][nN][aA]%d", ""))
                                -- NOTE: using these 3 gsubs is faster than a :lower() call and a table lookup
                                -- "target" is not included in the above check because it is already filtered out earlier on
                                ) then
                        if ( hadPet ~= 0 ) then
                                unit = noPet;
                        elseif ( (hadTarget == 0) or SecureButton_GetModifiedAttribute(self, "allowVehicleTarget", button) ) then
                                unit = unit:gsub("^[pP][lL][aA][yY][eE][rR]", "pet"):gsub("^([%a]+)([%d]+)", "%1pet%2");
                        end
                end

                return unit;
        end
        if ( SecureButton_GetModifiedAttribute(self, "checkselfcast", button) ) then
                if ( IsModifiedClick("SELFCAST") ) then
                        return "player";
                end
        end
        if ( SecureButton_GetModifiedAttribute(self, "checkfocuscast", button) ) then
                if ( IsModifiedClick("FOCUSCAST") ) then
                        return "focus";
                end
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

function SecureButton_GetEffectiveButton(self)
    -- We will be returning to implement this later
    return "LeftButton";
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

local forceinsecure = forceinsecure;

-- Table of supported action functions
local SECURE_ACTIONS = {};

SECURE_ACTIONS.actionbar =
    function (self, unit, button)
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
    end;

SECURE_ACTIONS.action =
    function (self, unit, button)
        local action = ActionButton_CalculateAction(self, button);
        if ( action ) then
            -- Save macros in case the one for this action is being edited
            securecall("MacroFrame_SaveMacro");

            local actionType, flyoutId = GetActionInfo(action);
            local cursorType = GetCursorInfo();

            if ( actionType == "flyout" and not cursorType ) then
                SpellFlyout:Toggle(flyoutId, self, nil, 3, true);
            else
                SpellFlyout:Hide();
                UseAction(action, unit, button);
            end
        end
    end;

SECURE_ACTIONS.pet =
    function (self, unit, button)
        local action =
            SecureButton_GetModifiedAttribute(self, "action", button);
        if ( action ) then
            CastPetAction(action, unit);
        end
    end;

SECURE_ACTIONS.flyout =
        function (self, unit, button)
                local flyoutId = SecureButton_GetModifiedAttribute(self, "spell", button);
                SpellFlyout:Toggle(flyoutId, self, nil, 3, true);
        end;

SECURE_ACTIONS.multispell =
    function (self, unit, button)
        local action = ActionButton_CalculateAction(self, button);
        local spell = SecureButton_GetModifiedAttribute(self, "spell", button);
        if ( action and spell ) then
            SetMultiCastSpell(action, tonumber(spell) or spell);
        end
    end;

SECURE_ACTIONS.spell =
    function (self, unit, button)
        local spell = SecureButton_GetModifiedAttribute(self, "spell", button);
        local spellID = tonumber(spell);
        if ( spellID ) then
            CastSpellByID(spellID, unit);
        elseif ( spell ) then
            CastSpellByName(spell, unit);
        end
    end;

-- Allow friendly names for glyph slots
local GLYPH_SLOTS = {
    minor1 = GLYPH_ID_MINOR_1;
    minor2 = GLYPH_ID_MINOR_2;
    minor3 = GLYPH_ID_MINOR_3;

    major1 = GLYPH_ID_MAJOR_1;
    major2 = GLYPH_ID_MAJOR_2;
    major3 = GLYPH_ID_MAJOR_3;

    prime1 = GLYPH_ID_PRIME_1;
    prime2 = GLYPH_ID_PRIME_2;
    prime3 = GLYPH_ID_PRIME_3;
};

SECURE_ACTIONS.glyph =
    function (self, unit, button)
        local spell = SecureButton_GetModifiedAttribute(self, "glyph", button);
        local slot = SecureButton_GetModifiedAttribute(self, "slot", button);
        local glyphID = tonumber(glyph);
        slot = (slot and GLYPH_SLOTS[slot]) or tonumber(slot);
        if ( glyphID and slot ) then
            CastGlyphByID(glyphID, slot);
        elseif ( glyph and slot ) then
            CastGlyphByName(glyph, slot);
        end
    end;

SECURE_ACTIONS.item =
    function (self, unit, button)
        local item = SecureButton_GetModifiedAttribute(self, "item", button);
        if ( not item ) then
            -- Backwards compatibility code, deprecated but still handled for now.
            local bag = SecureButton_GetModifiedAttribute(self, "bag", button);
            local slot = SecureButton_GetModifiedAttribute(self, "slot", button);
            if ( bag and slot ) then
                item = bag.." "..slot;
            else
                item = slot;
            end
        end
        if ( item ) then
            local name, bag, slot = SecureCmdItemParse(item);
            if ( IsEquippableItem(name) and not IsEquippedItem(name) ) then
                EquipItemByName(name);
            else
                SecureCmdUseItem(name, bag, slot, unit);
            end
        end
    end;

SECURE_ACTIONS.macro =
    function (self, unit, button)
        local macro = SecureButton_GetModifiedAttribute(self, "macro", button);
        if ( macro ) then
            -- Save macros in case the one for this action is being edited
            securecall("MacroFrame_SaveMacro");

            RunMacro(macro, button);
        else
            local text =
                SecureButton_GetModifiedAttribute(self, "macrotext", button);
            if ( text ) then
                RunMacroText(text, button);
            end
        end
    end;

local CANCELABLE_ITEMS = {
    [GetInventorySlotInfo("MainHandSlot")] = 1, -- main hand slot
    [GetInventorySlotInfo("SecondaryHandSlot")] = 2 -- off-hand slot
};

SECURE_ACTIONS.cancelaura =
    function (self, unit, button)
        local spell = SecureButton_GetModifiedAttribute(self, "spell", button);
        if ( spell ) then
            CancelUnitBuff(unit, spell, SecureButton_GetModifiedAttribute(self, "rank", button));
        else
            local slot = tonumber(SecureButton_GetModifiedAttribute(self, "target-slot", button));
            if ( slot and CANCELABLE_ITEMS[slot] ) then
                CancelItemTempEnchant(CANCELABLE_ITEMS[slot]);
            else
                local index = SecureButton_GetModifiedAttribute(self, "index", button) or self:GetID();
                if ( index ) then
                    CancelUnitBuff("player", index, SecureButton_GetModifiedAttribute(self, "filter", button));
                end
            end
        end
    end;

SECURE_ACTIONS.stop =
    function (self, unit, button)
        if ( SpellIsTargeting() ) then
            SpellStopTargeting();
        end
    end;

SECURE_ACTIONS.target =
    function (self, unit, button)
        if ( unit ) then
            if ( unit == "none" ) then
                ClearTarget();
            elseif ( SpellIsTargeting() ) then
                SpellTargetUnit(unit);
            elseif ( CursorHasItem() ) then
                DropItemOnUnit(unit);
            else
                TargetUnit(unit);
            end
        end
    end;

SECURE_ACTIONS.focus =
    function (self, unit, button)
        return FocusUnit(unit);
    end;

SECURE_ACTIONS.assist =
    function (self, unit, button)
        return AssistUnit(unit);
    end;

local function SecureAction_ManageAssignment(assignment, action, unit)
    if ( not action or action == "set" ) then
        SetPartyAssignment(assignment, unit);
    elseif ( action == "clear" ) then
        ClearPartyAssignment(assignment, unit);
    elseif ( action == "toggle" ) then
        if ( GetPartyAssignment(assignment, unit) ) then
            ClearPartyAssignment(assignment, unit);
        else
            SetPartyAssignment(assignment, unit);
        end
    end
end

SECURE_ACTIONS.maintank =
    function (self, unit, button)
        local action = SecureButton_GetModifiedAttribute(self, "action", button);
        SecureAction_ManageAssignment("maintank", action, unit);
    end;

SECURE_ACTIONS.mainassist =
    function (self, unit, button)
        local action = SecureButton_GetModifiedAttribute(self, "action", button);
        SecureAction_ManageAssignment("mainassist", action, unit);
    end;

SECURE_ACTIONS.click =
    function (self, unit, button)
        local delegate =
            SecureButton_GetModifiedAttribute(self, "clickbutton", button);
        if ( delegate ) then
            delegate:Click(button);
        end
    end;

SECURE_ACTIONS.attribute =
    function (self, unit, button)
        local frame =
            SecureButton_GetModifiedAttribute(self, "attribute-frame", button);
        if ( not frame ) then
            frame = self;
        end
        local name =
            SecureButton_GetModifiedAttribute(self, "attribute-name", button);
        local value =
            SecureButton_GetModifiedAttribute(self, "attribute-value", button);
        if ( name ) then
            frame:SetAttribute(name, value);
        end
    end;

function SecureActionButton_OnClick(self, button, down)
    -- TODO check with Tom etc if this is kosher
    if (down) then
        -- remap the button if desired for up-down behaviors. This behavior may not be safe and has been deferred.
        button = SecureButton_GetModifiedAttribute(self, "downbutton", button) or button
    end

    -- Lookup the unit, based on the modifiers and button
    local unit = SecureButton_GetModifiedUnit(self, button);

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
        end
    end

    -- Don't do anything if our unit doesn't exist
    if ( unit and unit ~= "none" and not UnitExists(unit) ) then
        return;
    end

    -- Lookup the action type, based on the modifiers and button
    local actionType = SecureButton_GetModifiedAttribute(self, "type", button);

    -- Perform the requested action!
    if ( actionType ) then
        local atRisk = false;
        local handler = SECURE_ACTIONS[actionType]
        if ( not handler ) then
            atRisk = true; -- user-provided function, be careful
            -- GMA call allows generic click handler snippets
            handler = SecureButton_GetModifiedAttribute(self, "_"..actionType, button);
        end
        if ( not handler ) then
            atRisk = false;
            -- functions retrieved from table keys carry their own taint
            handler = rawget(self, actionType);
        end
        if ( type(handler) == 'function' ) then
            if ( atRisk ) then
                forceinsecure();
            end
            -- actionType arg removed for 4,0
            handler(self, unit, button);
        elseif ( type(handler) == 'string' ) then
            SecureHandler_OnClick(self, "_"..actionType, button, down);
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
    self:SetAttribute("*type1", "target");
    self:SetAttribute("*type2", "menu");
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
