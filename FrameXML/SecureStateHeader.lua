-- SecureStateHeader - Button management state engine
--
---------------------------------------------------------------------------
-- Contributed with permission by Iriel, with some support code from Tem
-- (Anchoring code inspired by cueball)
-- (stateattribute code contributed by Alestane)
--
-- IMPORTANT: Version 2.1.0 updated the next state functions to require
--            the state header they're operating against. This could
--            not be made backward compatible. Only developers invoking
--            the new state calculations directly will be affected.
--
-- This template can be used for a huge variety of interactive user interface
-- elements such as paged action bars, pop-up menus, stance bars, etc. While it
-- may appear a little complicated, it's quite straightforward to use.
--
-- The template achieves its goal through four mechanisms:
--
-- 1) Child Visibility -- The template can hide or show its child frames
--                        based on the current state. Great for pop-up menus.
--
-- 2) Button Mapping -- The template can translate one type of click such as
--                      (LeftButton) into another based on its state. Great
--                      for paged action bars using the secure action
--                      templates.
--
-- 3) State Transitions -- The template can transition into a new state after
--                         any click, and optionally can schedule a second
--                         transition to occur some time later if no other
--                         transitions happen (Great for self-hiding menus)
--
-- 4) Key Rebinding -- The template can rebind keys to its child buttons
--                     when changing states.
--
-- 5) Attribute Changes -- The template can modify its own attributes
--                         according to its state, except for the attributes
--                         that control its own state behavior. It can use
--                         these attributes or its children can inherit them
--                         by using 'useparent-' attributes.
--
-- This engine cannot bypass the general principles of the new in combat
-- restrictions, once in combat it cannot be reconfigured, and it cannot
-- make any decisions for itself. The actions are controlled solely by the
-- user's clicks and (if enabled) changes in stance and unit existence.
--
--
-- USING THE HEADER
--
-- To use the header, create a Frame inheriting the template, then set up
-- the children's attributes as discussed below, and do the following for
-- each child you want it to control:
--
-- headerFrame:SetAttribute("addchild", childFrame);
--
-- The best way to learn how to use this is to use it for something simple
-- and work up.
--
--
-- STATES
--
-- The best way to imagine a state is as a complete configuration of
-- locations, bindings, visibility, etc, for all of the buttons controlled
-- by the header. The header manages any number of these states and thus
-- any number of different button layouts and reconfigurations (to some
-- rational extent, there are limits).
--
-- States can be almost any string value you want, I recommend you use
-- non-negative integer values because they're more convenient and better
-- supported.  The header starts with no state, which acts like the value
-- "0".
--
-- States change by way of 'transition rules, namely a specification of
-- how to get from a current state to a new state, a sampling of rules is:
--   "3" -- Change to state 3
--   "1,3,5" -- Cycle from 1 to 3 to 5 and back to 1
--   "1-5" -- Cycle from 1 through 5 ascending
--   "5-1" -- Cycle from 5 through 1 descending
--   "1-3:0;4:5;5:4" -- States 1-3 become state 0, state 4 and 5 toggle.
--   "4:;*:3" -- State 4 is to be left alone, all other states map to state 3
--   "1-4:=" -- States 1-4 map to themselves (useful for re-anchoring)
--
-- The header's current state is in its "state" attribute, and it will
-- call self:StateChanged(newState) whenever the state changes, if that
-- method has been defined.
--
--
-- VISIBILITY
--
-- Each child controls its own visibility through one of two attributes,
-- "showstates" and "hidestates". If "showstates" is defined then
-- "hidestates" will not be queried. Each of the attributes is parsed the
-- same way, the difference is whether entries in the list are shown or
-- hidden. The format of these is very simple - a comma separated list of
-- states or state ranges, though the "!" prefix can negate an entry.
--
-- Examples using "showstates" wording:
--
-- "7" -- Show in state 7, hide otherwise
-- "1-5" -- Show in states 1 through 5, hide otherwise
-- "1-3,11-13,20" -- Show in states 1-3, 11-13, and 20, hide otherwise
-- "*" -- Show in all states
-- "!7,1-10" -- Hide in state 7, show in states 1-10, hide otherwise
--
--
-- MOUSE BUTTON RE-MAPPING
--
-- Button re-mapping is the function of making one type of mouse button
-- press (LeftButton) look like another (say, RightButton, or possibly a
-- user defined virtual button). Since the secure action template uses the
-- button to look up attributes, this lets you change its behavior in
-- different states. Button mappings are incredibly flexible, first the
-- "statebutton" attribute of the child is queried using the SecureButton
-- modifier rules, so you can have different re-mappings for different
-- modifiers and buttons. If the attribute is found then it is parsed
-- as a series of state match conditions and new buttons.
--
-- Some examples:
--
-- "statebutton" -> "RightButton" -- Map any button to RightButton always
-- "statebutton" -> "2:RightButton" -- Map any button to RightButton in state 2
-- "*statebutton1" -> "2:RightButton;3:MiddleButton"
--                    -- Re-map the left button to the right button in state 2
--                    -- And the middle button in state 3
-- "shift-statebutton*" -> "1-10:LeftButton"
--                    -- Force any button to appear as the left button in
--                    -- states 1-10 for the shift modifier.
-- "*statebutton2" -> "1-10:heal;11-20:nuke"
--                    -- Re-map the right button to the virtual 'heal' button
--                    -- in states 1-10, and the nuke button in states 11-20
--
-- This re mapping happens at the start of the click, and the rest of the
-- processing uses the replacement button if there is one, or the original.
-- if not.
--
-- You set up the child action button however you want, expecting whatever
-- re-mappings you have configured.
--
--
-- STATE TRANSITIONS
--
-- After using the re-mapped button, the "newstate" attribute of that child
-- button is queried (with modifiers) to find the rules with which to select
-- a new state. If the attribute has a value then it is evaluated in the
-- same way as the button re mapping, but there are some different options
-- on the right hand side of the colon.
--
-- Example transitions:
--
-- "1-5" -- Cycle through 1,2,3,4,5, and back to 1...
-- "2,4,1,7" -- Cycle through 2,4,1,7, and back to 2...
-- "1-5:1;6-10:10-6;*:0" -- If in states 1-6, switch to state 1, if in
--                       -- states 6-10 then cycle through 10,9,8,7,6,
--                       -- if in any other state, switch to state 0
--
-- If a transition match is found then the state will change immediately
-- after the frame's original OnClick has been processed.
--
-- You can also provide "delaystate" and "delaytime" attributes (again,
-- queried with modifiers), "delaystate" is parsed exactly like "newstate",
-- using the ORIGINAL state (not the new one from "newstate"), and then
-- delaytime is parsed like "statebutton", and needs to result in a time
-- in seconds. If both of these are present and valid then a task is scheduled
-- to change the state to "delaystate" after "delaytime" seconds unless
-- another state change happens in the meantime.
--
-- There's one final optional attribute for delay, "delayhover", parsed
-- like "statebutton", if it results in nil or "false" then the timer
-- simply expires (unles cancelled). If it results in another value then
-- the timer will be reset whenever the mouse focus is the header frame
-- or any one of its children.
--
-- Hiding the header frame always causes the expiration to be zeroed and
-- hover cleared. Changing the state while there is a delaystate scheduled
-- cancels the scheduled change, configuring a new delayed change also
-- cancels any previous one.
--
-- KEY RE-BINDINGS
--
-- Key bindings are handled in groups, called 'binding sets'. The header
-- can change binding set when its state changes, and each child
-- button can provide a potentially different set of bindings for
-- each binding set. Bindings are maintained as overrides, when eys
-- are no longer in a set then their bindings are restored.
--
-- The header has an attribute "statebindings" that defines which binding
-- set to use for each state, it has a similar format to the button re-mapping
-- attributes, e.g:
--
-- "1:main;2:submenu;3-10:catmenu;11-20:bearmenu"
--
-- Then each button can provide one or more bindings to apply to itself
-- for a given binding set, via a "bindings-<setname>" attribute, whose
-- value is of the form "<Key>[:<Button>[,<Button>...]][;...]", where
-- the button will default to LeftButton if unspecified. e.g.:
--
-- "bindings-main" => "CTRL-F"
-- "bindings-alt" => "CTRL-F:LeftButton,RightButton;CTRL-G"
--
-- You can prefix a key with * to make the binding a priority binding,
-- priority binding overrides come before non-priority overrides, and should
-- only be used for short-lived purposes. e.g.:
--
-- "bindings-popup" => "*1;*2";
--
--
-- ADVANCED TOPICS
--
-- There are some more advanced features available, in the following
-- section the term 'state attribute' will be used to describe an attribute
-- that is fetched directly by name and then parsed as a state specification.
-- An empty string always acts as a NIL return
--
-- e.g.
--
-- "1:heal;2-5:harm" -- parsed to "heal" in state 1, "harm" in states
--                   -- 2 through 5, and nil in all other states.
-- "4:;*:trueval" -- Parsed to nil in state 4, "trueval" in all others.
--
--
-- ADVANCED TOPICS: STATE STACK FUNCTIONS
--
-- You store and restore states during transitions by using advanced
-- transition rules. In addition to the rules described above the
-- following functions are provided to interact with a state stack (the
-- stack is limited to at most 4 entries):
--
-- push([newState]) push the current state onto a 'state stack', and
--                  switch state to the newState (if provided)
-- pop([defaultState]) pop the top state off the stack and use it as the
--                     new state. If the stack is empty and defaultState
--                     is provided, then that's used as the new state.
-- set([newState]) replace the state stack with just the current state, and
--                  switch state to the newState (if provided)
-- swap([defaultState]) swap the current state and the top state off the
--                     stack. If the stack is empty and defaultState
--                     is provided, then that's used as the new state
--                     and the current state goes into the stack.
--
-- You can combine these and the other transition rules by separating
-- them with spaces. For example:
--
-- "1-5:push() 5-1;6-10:push(20)" -- If in states 1-5 then push the
--                                   current state and move to the previous
--                                   state in the range 1-5. If in states
--                                   6-10 then push the current state and
--                                   switch to state 20.
--
--
-- ADVANCED TOPICS: BUTTON LOCATION
--
-- Visible children can also have their location set relative to the
-- parent, the following state attributes on each child can control
-- child positioning:
--
-- "ofsx"        - The X offset, defaults to 0
-- "ofsy"        - The Y offset, defaults to 0
--
-- One of ofsx or ofsy must result in a value for anchoring to occur.
--
-- "ofspoint"    - The point on the button for the anchor, default "CENTER"
-- "ofsrelpoint" - The point on the header to anchor to, defaults to the
--                 ofspoint.
--
-- Whenever the state is updated the child positions will be re-applied,
-- those children with no offset values are left intact.
--
--
-- ADVANCED TOPICS: BUTTON SIZE
--
-- Visible children can also have their size set, the following state
-- attributes on each child can control child size:
--
-- "width"        - The desired width.
-- "height"       - The desired height.
-- "scale"        - The desired scale.
--
-- Only those that are set are changed.
--
--
-- ADVANCED TOPICS: HEADER PARENT
--
-- The header can change its parent with the use of the "headparent"
-- state attribute and matching "headparent-<parentName>" attributes.
--
-- Set "headparent-<parentName>" with the value of the desired parent frame,
-- and use the "headparent" state attribute to map state rules to parent names.
--
-- The "parentName" used does not need to match the frame's actual name or global
-- symbol. It is nothing more than "directions" to the header of where to find
-- the parentFrame
--
-- For example:
--
-- "headparent" -> "1:frame" -- Check "headparent-frame" for the frame object
-- when in state 1
--
-- "headparent" -> "1:parent1;2:parent2" -- Check "headparent-parent1" when
-- in state 1 and check "headparent-parent2" when in state 2
--
-- Any frame given to a "headparent-<parentName>" attribute must be an explicity
-- protected frame.
--
--
-- ADVANCED TOPICS: HEADER SIZE
--
-- The header can change its size and scale when the state is set. The following
-- state attributes on the header can control its size and scale:
--
-- "headwidth" - The desired width.
-- "headheight" - The desired height.
-- "headscale" - The desired scale.
--
-- Only those that are set are changed.
--
--
-- ADVANCED TOPICS: HEADER LOCATION
--
-- The header can also have its position changed when the state is set.  The
-- following state attributes on the header control this positioning:
--
-- "headofsx"    - The header X offset, defaults to 0
-- "headofsy"    - The header X offset, defaults to 0
--
-- One of headofsx or headofsy must result in a value for anchoring to occur.
--
-- "headofspoint" - The point on the header to anchor, default "CENTER"
-- "headofsrelpoint" - The point to anchor against, defaults to the
--                     headofspoint.
--
-- The headofsrelpoint attribute can use one of two special values in
-- addition to the usual parent-relative points:
--
-- "headofsrelpoint" -> "screen" -- Anchor relative to screen origin
-- "headofsrelpoint" -> "cursor" -- Anchor relative to cursor position
--
--
-- ADVANCED TOPICS: STATE-BASED ATTRIBUTES
--
-- A header can be set up to reconfigure its own attributes on a state change,
-- for inheritance by children, or for internal use if the header is also an
-- action button. This is accomlished through an "attribute set" system similar
-- to the mechanism for state bindings.
--
-- When the header changes state, it searches the state attribute
-- "stateattributes" (if present) for a set name that matches the new state.
-- If found, it then searches for a "attributes-<set name>" attribute and,
-- if found, parses it as a series of attribute assignments. These attributes
-- are specified as strings of the form "<attr>[=<value>](|<attr>[=<value>])*".
-- For example:
--
-- DemonButton:SetAttribute("stateattributes",
--                          "1:Imp;2:Voidwalker;3:Succubus;4:Felhunter")
-- DemonButton:SetAttribute("attributes-Succubus",
--                          "ctrl-spell*=Seduction|*unit2=focus")
-- DemonButton:SetAttribute("attributes-Felhunter",
--                          "shift-spell*=Devour Magic|shift-unit2=player"
--                          .. "|ctrl-spell*=Spell Lock|ctrl-unit2=focus")
--
--
-- ADVANCED TOPICS: HEADER UNIT CHANGE
-- (This feature is deprecated in favor of the stateattributes mechanism)
--
-- You can change the unit or unitsuffix property on the header using its
-- "headstateunit" state attribute. For each state it can have one of the
-- following values, that change its "unit" and "unitsuffix" attributes:
--
-- "<unit>"    -- A normal unit, e.g. "player" (unitsuffix is cleared)
-- "+<suffix>" -- A unit suffix e.g. "target" (unit is cleared)
-- "clear"      -- Clear unit and unitsuffix
--
--
-- ADVANCED TOPICS: EXTERNAL STATE CHANGES
--
-- The state header can be sent state changes from other code to sense
-- things such as unit existence changes, or stance changes. This is a
-- generalized mechanism that uses attributes on the header of the form
-- "state-<type>", such as "state-unitexists".
--
-- When one of these attributes is set to <newvalue>, the header is checked
-- for a "statemap-<type>-<newvalue>", and if that is not set, a
-- "statemap-<newvalue>" attribute.  If one is found then it will be processed
-- as a state transition specification and the header's state can be
-- changed as a result.
--
-- e.g.
--
-- -- Switch to state 0 on receipt of a false "state-unitexists" value, and
-- -- to state 1 on a true value.
--
-- "statemap-unitexists-false" => "0"
-- "statemap-unitexists-true" => "1"
--
-- If a non-empty statemap is provided for an external change, then the
-- following attributes can also be used to provide a delayed subsequent
-- change
--
-- "delaystatemap-<type>-<value>" then "delaystatemap-<type>"
-- "delaytimemap-<type>-<value>" then "delaytimemap-<type>"
-- "delayhovermap-<type>-<value>" then "delayhovermap-<type>"
--
-- External state sources should only set the value when it actually
-- changes, unless they're indication that an ACTION has occurred.
--
--
-- ADVANCED TOPICS: SLAVE HEADERS
--
-- It's possible to set a state header as the child of another state header.
-- Whenever the header's state changes, it sets the "state-parent" property
-- of each of its children to its new state.
--
-- You can also set a state header to propagate state change information
-- back to its parent. If you set the "exportstate" property of the
-- header to a value, then any state change on the header will set the
-- "state-<exportstate>" value on its parent to the header's new state.
--
--
-- ADVANCED TOPICS: ANCHOR CONTROL TEMPLATES
--
-- Sometimes you'll want to share a header amongst more than one set
-- of frames, for example a dropdown list against a unit frame. Other
-- times you might want to have the visibility of a header controlled
-- by a mouse over or something more complex like a OnMouseUp/Down. For
-- these actions you can use anchor templates.
--
-- When activated, the following attributes are used (all with modifiers)
-- to control one or more actions.
--
-- 1. The "anchorchild" attribute is used to find the frame that is to
--    be controlled. This must be either a Frame, or the string "$parent"
--    in which case the anchor's current parent is used. If no anchor
--    child is specified or it's not a Frame, then no further action
--    is taken. Otherwise;
--
-- 2. The "childofsx" and "childofsy" attributes are queried, and if either
--    exists then "childpoint" and "childrelpoint" are also queried. These
--    are then used (with appropriate defaults, consistent with the other
--    offset attributes described earlier) to re-anchor the anchorchild
--    relative to the anchor frame.
--
-- 3. The "childreparent" attribute is queried, if it's got a true value
--    then the anchor child's parent is set to the anchor frame. This is
--    especially useful combined with "useparent-unit" to create unit
--    context sensitive popups.
--
-- 4. The "childraise" attribute is queried, if it's got a true value then
--    the anchor child's Raise() method is called.
--
-- 5. The "childstate" attribute is queried, if this has a value then
--    it's used to change the anchor child's 'state-anchor' attribute.
--    If you prefix start the new state with a ^ then the attribute is
--    always set, otherwise it's only set if it's different than it was
--    before. You can also optionally provide a true "childverify" attribute
--    on the anchor to only change state if the anchorchild's parent is the
--    anchor frame.
--
-- 6. The anchor child is shown.
--
-- The following templates are provided:
--
-- * SecureAnchorButtonTemplate: Provides OnClick support, using the
--   button from the OnClick. You can specify alternate
--   buttons by providing the "onclickbutton" or attribute (queried
--   with modifiers).
--
-- * SecureAnchorEnterTemplate: Provides mouseover support using the
--   virtual buttons "OnEnter" and "OnLeave". You can specify alternate
--   buttons by providing the "onenterbutton" or "onleavebutton"
--   attributes (both queried with modifiers).
--
-- * SecureUpDownTemplate: Provides OnMouseUp/OnMouseDown support, using
--   the button pressed/released. You can specify alternate buttons
--   by providing the "onmouseupbutton" or "onmousedownbutton"
--   attributes (both queried with modifiers).
--
-- Example:
--
-- -- menuheader is the state header for a menu, with states 0 (hidden)
-- -- and 1 (shown). A sample 'mouseover to open' anchor could be set up
-- -- with:
--
-- local anchor = CreateFrame("Frame", nil, nil, "SecureAnchorEnterTemplate")
--
-- -- Send state changes to the menuheader on enter and leave
-- anchor:SetAttribute("anchorchild", menuheader);
-- anchor:SetAttribute("*childraise-OnEnter", true);
-- anchor:SetAttribute("*childstate-OnEnter", "enter");
-- anchor:SetAttribute("*childstate-OnLeave", "leave");
--
-- -- Switch from state 0 to state 1 on enter, and then schedule a
-- -- switch from state 1 to state 0 1 second after a leave (with hover
-- -- detection in case the mouse stays on the menu).
-- menuheader:SetAttribute("statemap-anchor-enter", "0:1");
-- menuheader:SetAttribute("statemap-anchor-leave",      ";"); -- Non-empty
-- menuheader:SetAttribute("delaystatemap-anchor-leave", "1:0");
-- menuheader:SetAttribute("delaytimemap-anchor-leave",  "1:1");
-- menuheader:SetAttribute("delayhovermap-anchor-leave", "1:true");
---------------------------------------------------------------------------

-- Called many times, grab a local copy
local match = string.match;
local tonumber = tonumber;
local strsplit = strsplit;

-- Utility functions -- closure-free iterators for splitting strings
local function splitNext(sep, body)
    if (body) then
        local pre, post = strsplit(sep, body, 2);
        if (post) then
            return post, pre;
        end
        return false, body;
    end
end
local function commaIterator(str) return splitNext, ",", str; end
local function semicolonIterator(str) return splitNext, ";", str; end
local function spaceIterator(str) return splitNext, " ", str; end
local function pipeIterator(str) return splitNext, "|", str; end

----------------------------------------------------------------------------
-- Get a state dependent attribute by applying the condition filtering
-- logic to the retrieved attribute
function SecureState_GetStateAttribute(self, state, attribute)
    local attrval = self:GetAttribute(attribute);
    return SecureState_SelectRule(state, attrval);
end

-- Get a state dependent modified attribute by applying the condition filtering
-- logic to the retrieved attribute
function SecureState_GetStateModifiedAttribute(self, state, attribute, button)
    local attrval = SecureButton_GetModifiedAttribute(self, attribute, button);
    return SecureState_SelectRule(state, attrval);
end

-- Test the visibility of the frames provided (typically children) and
-- show or hide them as necessary.
local function SecureStateHeader_TestChildVisibility(self, state, ...)
    state = tostring(state or "0");
    for i = 1, select('#', ...) do
        local child = (select(i, ...));
        local condition = child:GetAttribute("showstates");
        local show = true;
        local doShow = true;
        if (condition) then
            show = SecureState_TestCondition(state, tostring(condition));
        else
            condition = child:GetAttribute("hidestates");
            if (condition) then
                show = not SecureState_TestCondition(state,
                                                     tostring(condition));
            else
                doShow = false;
            end
        end
        if (show) then
            -- Set size and scale if requested
            local width = SecureState_GetStateAttribute(child, state, "width");
            local height =
                SecureState_GetStateAttribute(child, state, "height");
            local scale = SecureState_GetStateAttribute(child, state, "scale");
            width, height = tonumber(width), tonumber(height);
            scale = tonumber(scale);
            if (width)  then child:SetWidth(width); end
            if (height) then child:SetHeight(height); end
            if (scale)  then child:SetScale(scale); end

            -- Set location if requested
            local ofsx = SecureState_GetStateAttribute(child, state, "ofsx");
            local ofsy = SecureState_GetStateAttribute(child, state, "ofsy");
            if (ofsx or ofsy) then
                local ofspoint =
                    SecureState_GetStateAttribute(child, state, "ofspoint")
                    or "CENTER";
                local ofsrelpoint =
                    SecureState_GetStateAttribute(child, state, "ofsrelpoint")
                    or ofspoint;
                child:ClearAllPoints();
                child:SetPoint(ofspoint, self, ofsrelpoint,
                               ofsx or 0, ofsy or 0);
            end
            if (doShow) then
                child:SetAttribute("statehidden", nil);
                child:Show();
            end
        elseif (doShow) then
            child:SetAttribute("statehidden", true);
            child:Hide();
        end

        -- Send state change to child
        if (child:GetAttribute("state-parent") ~= state) then
            child:SetAttribute("state-parent", state);
        end
    end
end

-- Apply bindings from the specified bindingset to all of the children.
local function SecureStateHeader_ApplyChildBindings(self, set, full, ...)
    set = tostring(set) or "";
    local setattr = "bindings-" .. set;

    local oldBindings = self:GetAttribute("_boundkeys");
    if (full) then
        -- Paranoia to prevent sync loss
        if (oldBindings == "*") then
            ClearOverrideBindings(self);
            oldBindings = nil;
        else
            self:SetAttribute("_boundkeys", "*");
        end
        self:SetAttribute("_bindingset", nil);
    else
        oldBindings = nil;
        self:SetAttribute("_boundkeys", "*");
    end

    local newBindings = {};

    for i = 1, select('#', ...) do
        local child = (select(i, ...));
        local bindings = child:GetAttribute(setattr);
        if (bindings) then
            local childname = child:GetName();
            if (not childname) then
                message("Cannot apply 'bindings-" .. set .. "'='" .. bindings
                        .. "' to unnamed button.");
            else
                for _, binding in semicolonIterator(tostring(bindings)) do
                    local prispec = match(binding, "^%*(.*)$");
                    if (prispec) then
                        binding = prispec;
                        prispec = true;
                    end
                    local key, button = strsplit(":", binding, 2);
                    if (not button) then
                        button = "LeftButton";
                    end
                    if (key ~= "") then
                        key = string.upper(key);
                        if (not newBindings[key]) then
                            newBindings[key] = true;
                            SetOverrideBindingClick(self, prispec,
                                                    key, childname, button);
                        end
                    end
                end
            end
        end
    end

    if (not full) then
        return;
    end

    -- Restore any keys that are no longer bound
    if (oldBindings) then
        for _,key in commaIterator(oldBindings) do
            if (not newBindings[key]) then
                SetOverrideBinding(self, false, key, nil)
            end
        end
    end
    -- Build the replacement list of bound keys
    if (next(newBindings)) then
        local bindArr = {};
        for key in pairs(newBindings) do
            table.insert(bindArr, key);
        end
        self:SetAttribute("_boundkeys", table.concat(bindArr, ","));
    else
        self:SetAttribute("_boundkeys", nil);
    end
    -- Specify the current binding set
    self:SetAttribute("_bindingset", set);
end

-- Convenience function to refresh child visibility for the header
function SecureStateHeader_Refresh(self, state)
    state = state or self:GetAttribute("state");

     -- Reparent the header, if requested.
    local parentSuffix = SecureState_GetStateAttribute(self, state,
                                                       "headparent");
    if ( parentSuffix ) then
        local parent = self:GetAttribute("headparent-"..parentSuffix);
        if ( parent ) then
            local protected, explicit = parent:IsProtected();
            if ( protected and explicit ) then
                self:SetParent(parent);
            end
        end
    end

    -- Resize the header, if requested.
    local width = SecureState_GetStateAttribute(self, state, "headwidth");
    local height = SecureState_GetStateAttribute(self, state, "headheight");
    local scale = SecureState_GetStateAttribute(self, state, "headscale");
    if ( width ) then self:SetWidth(width); end
    if ( height ) then self:SetHeight(height); end
    if ( scale ) then self:SetScale(scale); end

    -- Move the header, if requested.
    local ofsx = SecureState_GetStateAttribute(self, state, "headofsx");
    local ofsy = SecureState_GetStateAttribute(self, state, "headofsy");
    local needraise;
    if (ofsx or ofsy) then
        local point = SecureState_GetStateAttribute(self, state,
                                                    "headofspoint")
            or "CENTER";
        local relpoint = SecureState_GetStateAttribute(self, state,
                                                       "headofsrelpoint")
            or point;
        local relframe;
        if (relpoint == "cursor") then
            local cx, cy = GetCursorPosition();
            local eff = self:GetEffectiveScale();
            ofsx = (ofsx or 0) + (cx / eff);
            ofsy = (ofsy or 0) + (cy / eff);
            relframe = nil;
            needraise = true;
            relpoint = "BOTTOMLEFT";
        elseif (relpoint == "screen") then
            relframe = nil;
            relpoint = "BOTTOMLEFT";
        else
            relframe = self:GetParent();
        end
        self:ClearAllPoints();
        self:SetPoint(point, relframe, relpoint, ofsx or 0, ofsy or 0);
    end

    local needraise = needraise or
        SecureState_GetStateAttribute(self, state, "raise");
    if (needraise) then self:Raise(); end

    -- Change the header's unit if necessary
    local newUnit = SecureState_GetStateAttribute(self, state,
                                                  "headstateunit");
    if (newUnit) then
        if (newUnit == "") then
            newUnit = nil;
        elseif (newUnit == "clear") then
            self:SetAttribute("unitsuffix", nil);
            self:SetAttribute("unit", nil);
        else
            local suffix = match(tostring(newUnit), "^%+(.*)$");
            if (suffix) then
                self:SetAttribute("unitsuffix", suffix);
                self:SetAttribute("unit", nil);
            else
                self:SetAttribute("unitsuffix", nil);
                self:SetAttribute("unit", newUnit);
            end
        end
    end

    -- Update the header's attributes - can overwrite "headstateunit"
    local attrSet =
        SecureState_GetStateAttribute(self, state, "stateattributes");
    if (attrSet and attrSet ~= self:GetAttribute("_attributes")) then
        self:SetAttribute("_attributes", attrSet);
        attrSet = self:GetAttribute("attributes-" .. attrSet);
        if (attrSet) then
            for _, clause in pipeIterator(attrSet) do
                local attr, value = strsplit("=", clause, 2);
                local attrFamily = attr:sub(1, 5);
                if (attrFamily ~= "state" and attrFamily ~= "delay") then
                    self:SetAttribute(attr, value);
                end
            end
        end
    end

    -- Apply visibility rules to children
    SecureStateHeader_TestChildVisibility(self, state, self:GetChildren());

    local bindingset =
        SecureState_GetStateAttribute(self, state, "statebindings");
    if (bindingset) then
        local oldset = self:GetAttribute("_bindingset");
        if (oldset ~= bindingset) then
            local forceset = match(bindingset, "^%^(.*)$");
            if (forceset) then
                if (forceset == "") then bindingset = oldset; end
                bindingset = forceset;
            end

            -- Apply bindings to children
            SecureStateHeader_ApplyChildBindings(self, bindingset, true,
                                                 self:GetChildren());
        end
    end
end

-- Safety function to not taint the header while storing old OnClick
local function SecureStateHeader_SafeSaveOnClick(frame)
    if (not frame._stateOnClick) then
        frame._stateOnClick = frame:GetScript("OnClick");
    end
end

-- Safety function to invoke the old saved OnClick if it exists
local function SecureStateHeader_SafeCallOnClick(frame, ...)
    local oldOnClick = frame._stateOnClick;
    if ( type(oldOnClick) == "function" ) then
        return oldOnClick(frame, ...);
    end
end

-- Attribute handler to react to state changes and new child registrations
function SecureStateHeader_OnAttributeChanged(self, name, value)
    if (name == "state") then
        if (self:GetAttribute("_statedelay") ~= nil) then
            self:SetAttribute("_statedelay", nil)
        end
        value = tostring(value) or "0";
        SecureStateHeader_Refresh(self, value);

        -- Send state changes to parent
        local export = self:GetAttribute("exportstate");
        if (export and export ~= "") then
            local parent = self:GetParent();
            if (parent) then
                export = "state-" .. tostring(export);
                local oldval = parent:GetAttribute(export);
                if (oldval ~= value) then
                    parent:SetAttribute(export, value);
                end
            end
        end

        -- Finished with secure code - call user notification if present
        if (self.StateChanged) then
            self:StateChanged(value);
        end
        return;

    elseif (name == "delay-time") then
        self:SetAttribute("_statedelay", tonumber(value))
        self:SetScript("OnUpdate", SecureStateHeader_OnUpdate);
        return;

    elseif (name == "addchild") then
        if (type(value) ~= "table" or type(value[0]) ~= "userdata") then
            return;
        end
        value:SetParent(self);
        if (value:HasScript("OnClick")) then
            -- This can lead to tainting the current execution so we use a
            -- secure function for the dirty work.
            securecall(SecureStateHeader_SafeSaveOnClick, value);
            value:SetScript("OnClick", SecureStateChild_OnClick);
        end
        local state = self:GetAttribute("state");
        -- And update visibility of the child according to the rules
        SecureStateHeader_TestChildVisibility(self, state, value);
        -- And re-evaluate bindings if we have any
        local bindingset =
            SecureState_GetStateAttribute(self, state, "statebindings");
        if (bindingset) then
            SecureStateHeader_ApplyChildBindings(self, bindingset, false,
                                                 value);
        end
        return;
    end

    -- Handle generic state transition attributes
    local transtype = match(name, "^state%-(.*)$");
    if (transtype) then
        value = tostring(value);
        local mapname = "statemap-" .. transtype;
        local newState = self:GetAttribute(mapname .. "-" .. value)
            or self:GetAttribute(mapname);
        if (newState) then
            local state = tostring(self:GetAttribute("state") or "0");
            newState = SecureStateHeader_GetNextState(self, state,
                                                      newState, value);

            mapname = "delaystatemap-" .. transtype;
            local delayState = self:GetAttribute(mapname .. "-" .. value)
                or self:GetAttribute(mapname);
            delayState = SecureStateHeader_GetPendingState(self, state,
                                                           delayState, value);

            local delayTime, delayHover;
            if (delayState) then
                mapname = "delaytimemap-" .. transtype;
                delayTime = self:GetAttribute(mapname .. "-" .. value)
                    or self:GetAttribute(mapname);
                delayTime = SecureState_SelectRule(state, delayTime);

                mapname = "delayhovermap-" .. transtype;
                delayHover = self:GetAttribute(mapname .. "-" .. value)
                    or self:GetAttribute(mapname);
                delayHover = SecureState_SelectRule(state, delayHover);

                delayTime = tonumber(delayTime);

                if (delayHover == "false") then
                    delayHover = false;
                else
                    delayHover = (delayHover and true) or false;
                end
            end

            if (newState) then
                self:SetAttribute("state", newState);
            end

            if (delayState and delayTime) then
                self:SetAttribute("delay-state", delayState);
                self:SetAttribute("delay-hover", delayHover);
                self:SetAttribute("delay-time", delayTime);
            end
        end
        return;
    end
end

-- If the frame is hidden and there's a pending state transition, zero its
-- time so it executes immediately later
function SecureStateHeader_OnHide(self)
    local delay = self:GetAttribute("_statedelay");
    if (delay) then
        self:SetAttribute("_statedelay", 0);
        if (self:GetAttribute("delay-hover")) then
            self:SetAttribute("delay-hover", nil);
        end
    end
end

-- Test whether the current mouse focus is the specified frame or one
-- of its chilren.
local function SecureStateHeader_MouseHovering(self)
    local mouseFocus = GetMouseFocus();
    while mouseFocus do
        if ( mouseFocus == self ) then
            return true;
        end
        mouseFocus = mouseFocus:GetParent();
    end
end

-- An OnUpdate function only used when necessary, which manages the
-- ability to perform a delayed state transition, possibly with a hover
-- sensing override
function SecureStateHeader_OnUpdate(self, elapsed)
    local delay = self:GetAttribute("_statedelay");
    if (not delay) then
        self:SetScript("OnUpdate", nil);
        return;
    end
    local ntime = delay - elapsed;
    if (self:GetAttribute("delay-hover")) then
        if (SecureStateHeader_MouseHovering(self)) then
            ntime = tonumber(self:GetAttribute("delay-time"));
            if (delay ~= ntime) then
                self:SetAttribute("_statedelay", ntime);
            end
            if (ntime > 0) then
                return;
            end
        end
    end
    if (ntime > 0) then
        self:SetAttribute("_statedelay", ntime);
        return;
    end
    self:SetAttribute("_statedelay", nil);
    local newState = self:GetAttribute("delay-state");
    self:SetAttribute("delay-state", nil);
    newState = SecureStateHeader_ResolvePendingState(self, newState);
    if (newState) then
        self:SetAttribute("state", newState);
    end
end

-- Determine what the next state (and delay state) should be for a
-- button.
function SecureStateHeader_GetNextButtonState(self, state, button)
    local nState = SecureButton_GetModifiedAttribute(self, "newstate", button);
    local header = self:GetParent();
    nState = SecureStateHeader_GetNextState(header, state, nState);

    local dState = SecureButton_GetModifiedAttribute(self, "delaystate",
                                                     button);
    dState = SecureStateHeader_GetPendingState(header, state, dState);
    local delay, hover;
    if (dState) then
        delay = SecureState_GetStateModifiedAttribute(self, state,
                                                      "delaytime", button);
        hover = SecureState_GetStateModifiedAttribute(self, state,
                                                      "delayhover", button);
        if (delay) then
            delay = tonumber(delay);
        end

        if (hover == "false") then
            hover = false;
        else
            hover = (hover and true) or false;
        end
    end

    return nState, dState, delay, hover;
end

-- Apply new button state configuration to the parent
function SecureStateHeader_ApplyNextButtonState(self,
                                                nState, dState, delay, hover)
    -- Abort now if the wrapped frame is not protected and we're in combat.
    -- This prevents a number of exploits that could otherwise occur if
    -- the wrapped frame isn't protected.
    if (not self:IsProtected() and InCombatLockdown()) then
        return;
    end

    local parent = self:GetParent();

    if (nState) then
        parent:SetAttribute("state", nState);
    end

    if (dState and delay) then
        parent:SetAttribute("delay-state", dState);
        parent:SetAttribute("delay-hover", hover);
        parent:SetAttribute("delay-time", delay);
    end
end

-- Wrapper function around existing OnClick to perform state-based button
-- remapping before calling the original, and to potentially update
-- state afterwards.
function SecureStateChild_OnClick(self, button, down)
    local parent = self:GetParent();
    local state = tostring(parent:GetAttribute("state") or "0");

    local downButton;
    if (down) then
        downButton = SecureState_GetStateModifiedAttribute(self, state,
                                                          "statedownbutton",
                                                          button);
    end
    button = downButton
        or SecureState_GetStateModifiedAttribute(self, state, "statebutton",
                                                 button)
        or button;

    local nState, dState, delay, hover =
        SecureStateHeader_GetNextButtonState(self, state, button);

    -- Invoke the old OnClick
    securecall(SecureStateHeader_SafeCallOnClick, self, button, down);

    SecureStateHeader_ApplyNextButtonState(self, nState, dState, delay, hover);
end

-- Given an old state and a transition spec, determine the new state
--
-- It is tolerant of nil or blank inputs, and a return of nil means
-- do not change state or trigger a state update.
--
-- UPDATED IN VERSION 2.1.0 TO REQUIRE HEADER PARAMETER
function SecureStateHeader_GetNextState(header, oldState,
                                        newStateSpec, suggested)
    local rule = SecureState_SelectRule(oldState, newStateSpec);
    return SecureStateHeader_ApplyRule(header, oldState, rule, suggested);
end

-- Determine what state and rules would be used to change states after a
-- delay.
function SecureStateHeader_GetPendingState(header, oldState,
                                           newStateSpec, suggested)
    local rule = SecureState_SelectRule(oldState, newStateSpec);
    if ((rule == nil) or (rule == "")) then
        return nil;
    end
    oldState = tostring(oldState or "0");
    if (suggested) then
        return oldState .. ";" .. rule .. ";" .. suggested;
    else
        return oldState .. ";" .. rule;
    end
end

-- Determine what state and rules would be used to change states after a
-- delay. Uses the input from a previous call to GetPendingState
function SecureStateHeader_ResolvePendingState(header, pended)
    return SecureStateHeader_ApplyRule(header, strsplit(';', pended));
end

-- Execute a test against a state, return true if the state matches
-- the test.
local function SecureState_DoTest(state, test)
    if (test == "*") then return true; end
    local lo,hi = match(test, "^(%d+)%-(%d+)$");
    if (lo) then
        lo, hi = tonumber(lo), tonumber(hi);
        local n = tonumber(state);
        if (n and (n >= lo) and (n <= hi)) then
            return true;
        end
    else
        if (state == test) then
            return true;
        end
    end
end

-- Test a condition (list of tests) against a state, returns true if there
-- there is a match.
function SecureState_TestCondition(state, condition)
    for _, test in commaIterator(condition) do
        local ntest = match(test, "^!(.*)$");
        if (ntest) then
            if (SecureState_DoTest(state, ntest)) then
                return;
            end
        else
            if (SecureState_DoTest(state, test)) then
                return true;
            end
        end
    end
end

-- Select the first rule from a spec whose condition matches the current
-- state. Returns nil for no match.
function SecureState_SelectRule(state, spec)
    if (spec and spec ~= "") then
        for _,clause in semicolonIterator(spec) do
            local condition, rule = strsplit(":", clause);
            if (not rule) then
                return clause;
            elseif ( SecureState_TestCondition(state, condition) ) then
                return rule;
            end
        end
    end
    return nil;
end

-- A table of state clause update commands
STATE_CLAUSE_COMMANDS = {};

-- Set the current state to be the whole stack,optionally setting the
-- state afterwards
--
-- set()
-- set(newState)
function STATE_CLAUSE_COMMANDS:set(state, newState)
    self:SetAttribute("statestack", state);
    return newState;
end

-- Push the current state onto the front of the state stack
--
-- push()
-- push(newState)
function STATE_CLAUSE_COMMANDS:push(state, newstate)
    local stack = self:GetAttribute("statestack");
    if (stack == nil) then
        self:SetAttribute("statestack", state);
        return newstate;
    end
    local trunc = match(tostring(stack), "^([^,]*,[^,]*,[^,]*),");
    if (trunc) then
        stack = trunc;
    end
    self:SetAttribute("statestack", state .. "," .. stack);
    return newstate;
end

-- Pop a state off the state stack, if it's empty and there are arguments
-- use the arguments as the new state, otherwise leave the state unchanged
--
-- pop
-- pop(defaultState)
function STATE_CLAUSE_COMMANDS:pop(state, defaultState)
    local stack = self:GetAttribute("statestack");
    if (stack == nil) then
        if (defaultState) then
            return defaultState;
        else
            return;
        end
    end
    stack = tostring(stack);
    local top, rest = match(stack, "([^,]*),(.*)$");
    if (top) then
        self:SetAttribute("statestack", rest);
        return top;
    end

    self:SetAttribute("statestack", nil)
    return stack;
end

-- Swap the current state with the top of the state stack, if it's empty and
-- there are arguments use the arguments as the new state, otherwise leave
-- the state unchanged and push nothing
--
-- swap
-- swap(defaultState)
function STATE_CLAUSE_COMMANDS:swap(state, defaultState)
    local stack = self:GetAttribute("statestack");
    if (stack == nil) then
        if (defaultState) then
            self:SetAttribute("statestack", state);
            return defaultState;
        else
            return;
        end
    end
    stack = tostring(stack);
    local top, rest = match(stack, "([^,]*),(.*)$");
    if (top) then
        -- No change if top state matches current
        if (top == state) then
            return state;
        end
        self:SetAttribute("statestack", state .. "," .. rest);
        return top;
    end

    self:SetAttribute("statestack", state)
    return stack;
end

-- Apply a single clause of a transition rule to the current state,
-- returning the new state (or nil to leave the state unchanged)
function SecureStateHeader_ApplyRuleClause(header, oldState, clause)
    if (clause == "") then
        return;
    end

    if (clause == "=") then
        return oldState;
    end

    local cmd, args = match(clause, "^([a-zA-z]+)%((.*)%)$");
    if (cmd) then
        local cmdFunc = STATE_CLAUSE_COMMANDS[cmd];
        if (cmdFunc) then
            if (args == "") then
                return cmdFunc(header, tostring(oldState or "0"));
            else
                return cmdFunc(header, tostring(oldState or "0"),
                               strsplit(",", args));
            end
        else
            -- Should this produce some kind of error? How? Where?
            message("Unknown transition function: " .. clause);
            return "0";
        end
    end

    local lo,hi = match(clause, "^(%d+)%-(%d+)$");
    if (lo) then
        local n = tonumber(oldState);
        if (not n) then return lo; end
        lo,hi = tonumber(lo), tonumber(hi);
        if (lo <= hi) then
            if ((n < lo) or (n >= hi)) then return lo; end
            return n + 1;
        else
            if ((n > lo) or (n <= hi)) then return lo; end
            return n - 1;
        end
    end

    local first, others = strsplit(",", clause, 2);
    if (others) then
        local useNext = (oldState == first);
        for _, cur in commaIterator(others) do
            if (useNext) then
                return cur;
            end
            useNext = (cur == oldState);
        end
        return first;
    end

    return clause;
end

-- Given an old state and a next state production rule, return the new
-- state.
function SecureStateHeader_ApplyRule(header, state, rule, suggested)
    if (rule == nil or rule == "") then
        return nil;
    end

    local anyChange = false;

    for _, clause in spaceIterator(tostring(rule)) do
        if (clause == "$input") then
            state = suggested or "0";
            anyChange = true;
        else
            local newState = SecureStateHeader_ApplyRuleClause(header,
                                                               state,
                                                               clause);
            if (newState) then
                state = newState;
                anyChange = true;
            end
        end
    end

    if (anyChange) then
        return state;
    else
        return nil;
    end
end

-- A convenience function for users of the header to map the button on
-- a child to the effective button that would be used for that child
-- with no modifiers held down
function SecureStateChild_GetEffectiveButton(self, button, down)
    local parent = self:GetParent();
    button = button or "LeftButton";
    local state = tostring((parent and parent:GetAttribute("state")) or "0");
    local downButton;
    if (down) then
        downButton = SecureState_GetStateModifiedAttribute(self, state,
                                                          "statedownbutton",
                                                          button);
    end
    return downButton
        or SecureState_GetStateModifiedAttribute(self, state, "statebutton",
                                                 button)
        or button;
end

-- Run the anchoring/popup rules for a given condition, this is shared by
-- the mouseover, mouseup/down, and on click anchor templates.
function SecureStateAnchor_RunChild(self, button, remapButton)
    -- Allow for button remapping for sanity's sake
    if (remapButton) then
        button = SecureButton_GetModifiedAttribute(self, remapButton, button)
            or button;
    end

    local child = SecureButton_GetModifiedAttribute(self, "anchorchild",
                                                    button);
    if (child == "$parent") then
        child = self:GetParent();
    end
    if (type(child) ~= "table" or type(child[0]) ~= "userdata") then
        return;
    end

    if (not self:IsProtected() and InCombatLockdown()) then
        return;
    end

    local x = SecureButton_GetModifiedAttribute(self, "childofsx", button);
    local y = SecureButton_GetModifiedAttribute(self, "childofsy", button);
    if (x or y) then
        x,y = tonumber(x) or 0, tonumber(y) or 0;
        local point =
            SecureButton_GetModifiedAttribute(self, "childpoint", button)
            or "CENTER";
        local relpoint =
            SecureButton_GetModifiedAttribute(self, "childrelpoint", button)
            or point;
        child:ClearAllPoints();
        child:SetPoint(point, self, relpoint, x, y);
    end

    -- This should always be safe since we're protected and this
    -- requires a trusted initiation to run in the first place. Required for
    -- shared raid header child dropdowns.
    if (SecureButton_GetModifiedAttribute(self, "childreparent", button)) then
        child:SetParent(self);
    end

    if (SecureButton_GetModifiedAttribute(self, "childraise", button)) then
        child:Raise();
    end

    local newstate =
        SecureButton_GetModifiedAttribute(self, "childstate", button);

    -- Allow for child verification
    if (newstate and
        SecureButton_GetModifiedAttribute(self, "childverify")) then
        if (child:GetParent() ~= self) then
            newstate = nil;
        end
    end

    if (newstate) then
        newstate = tostring(newstate);
        local forcestate = match(newstate, "^%^(.*)$");
        if (forcestate) then
            newstate = forcestate;
        end
        if (forcestate or child:GetAttribute("state-anchor") ~= newstate) then
            child:SetAttribute("state-anchor", newstate);
        end
    end

    child:Show();
end
