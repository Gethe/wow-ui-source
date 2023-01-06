ActionBarMixin = {}

function ActionBarMixin:ActionBar_OnLoad()
    self.numShowingButtonsOrSpacers = 0;
    self.numButtonsShowable = self.numButtons;
    self.minButtonPadding = 2;
    self.buttonPadding = self.minButtonPadding;
    self.actionButtons = {};
    self.buttonsAndSpacers = {};

    -- Create action buttons
    for i=1, self.numButtons do

        -- Different naming for these bars is to avoid errors with legacy code
        -- Ideally this wouldn't be needed
        local name;
        if self == MainMenuBar then
            name = "ActionButton"..i;
        elseif self == StanceBar then
            name = "StanceButton"..i;
        elseif self == PetActionBar then
            name = "PetActionButton"..i;
        elseif self == PossessActionBar then
            name = "PossessButton"..i;
        else
            name = self:GetName().."Button"..i;
        end

		local actionButton = CreateFrame("CheckButton", name, self, self.buttonTemplate, i);
        actionButton.index = i;
        actionButton.isLastActionButton = i == self.numButtons;

        if self.commandNamePrefix then
            actionButton.commandName = self.commandNamePrefix.."BUTTON"..i;
        end

        table.insert(self.actionButtons, actionButton);
        table.insert(self.buttonsAndSpacers, actionButton);

        if not self.noSpacers then
            -- Create button spacer
            -- Spacers are used to keep size of bar the same when we aren't showing the grid
            local spacer = CreateFrame("Frame", "ActionBarButtonSpacer"..i, self, "ActionBarButtonSpacerTemplate", i);
            spacer:SetSize(actionButton:GetWidth(), actionButton:GetHeight()); -- Spacer size should match the size of the action buttons
            table.insert(self.buttonsAndSpacers, spacer);
        end
    end

    self:UpdateShownButtons();
    self:UpdateGridLayout();

    if self.showGridEventName then
        self:RegisterEvent(self.showGridEventName);
    end
    if self.hideGridEventName then
        self:RegisterEvent(self.hideGridEventName);
    end
end

function ActionBarMixin:ActionBar_OnEvent(event, ...)
    if event == self.showGridEventName then
        self:SetShowGrid(true, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	elseif event == self.hideGridEventName then
		self:SetShowGrid(false, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
    end
end

function ActionBarMixin:ActionBar_OnShow()
    self:UpdateGridLayout();
end

function ActionBarMixin:CacheGridSettings(layoutChildren)
    self.oldGridSettings = {
        layoutChildren = layoutChildren,
        numShowingButtonsOrSpacers = self.numShowingButtonsOrSpacers,
        numRows = self.numRows,
        isHorizontal = self.isHorizontal,
        addButtonsToRight = self.addButtonsToRight,
        addButtonsToTop = self.addButtonsToTop,
        buttonPadding = self.buttonPadding,
    };
end

function ActionBarMixin:ShouldUpdateGrid(layoutChildren)
    if not self:IsShown() then
        return false;
    end

    if self.oldGridSettings == nil then
        return true;
    end

    if self.oldGridSettings.numShowingButtonsOrSpacers ~= self.numShowingButtonsOrSpacers
    or self.oldGridSettings.numRows ~= self.numRows
    or self.oldGridSettings.isHorizontal ~= self.isHorizontal
    or self.oldGridSettings.addButtonsToRight ~= self.addButtonsToRight
    or self.oldGridSettings.addButtonsToTop ~= self.addButtonsToTop
    or self.oldGridSettings.buttonPadding ~= self.buttonPadding
    or #self.oldGridSettings.layoutChildren ~= #layoutChildren then
        return true;
    end

    for index, layoutChild in ipairs(layoutChildren) do
        if self.oldGridSettings.layoutChildren[index] ~= layoutChild then
            return true;
        end
    end

    return false;
end

function ActionBarMixin:UpdateGridLayout()
    -- Determine which things will be laid out in the grid
    local shownButtonsAndSpacers = {};
    for i, buttonOrSpacer in pairs(self.buttonsAndSpacers) do
        if buttonOrSpacer:IsShown() then
            table.insert(shownButtonsAndSpacers, buttonOrSpacer);
        end
    end

    if not self:ShouldUpdateGrid(shownButtonsAndSpacers) then
        return;
    end

    -- Stride is the number of buttons per row (or column if we are vertical)
    -- Set stride so that if we can have the same number of icons per row we do
    local stride = math.ceil(self.numShowingButtonsOrSpacers / self.numRows);

    -- Set button padding. User can set padding through edit mode
    local buttonPadding = math.max(self.minButtonPadding, self.buttonPadding);

    -- Multipliers determine the direction the bar grows for grid layouts 
    -- Positive means right/up
    -- Negative means left/down
    local xMultiplier = self.addButtonsToRight and 1 or -1;
    local yMultiplier = self.addButtonsToTop and 1 or -1;

    -- Create the grid layout according to whether we are horizontal or vertical
    local layout;
    if self.isHorizontal then
        layout = GridLayoutUtil.CreateStandardGridLayout(stride, buttonPadding, buttonPadding, xMultiplier, yMultiplier);
    else
        layout = GridLayoutUtil.CreateVerticalGridLayout(stride, buttonPadding, buttonPadding, xMultiplier, yMultiplier);
    end

    -- Need to change where the buttons anchor based on how the bar grows
    local anchorPoint;
    if self.addButtonsToTop then
        if self.addButtonsToRight then
            anchorPoint = "BOTTOMLEFT";
        else
            anchorPoint = "BOTTOMRIGHT";
        end
    else
        if self.addButtonsToRight then
            anchorPoint = "TOPLEFT";
        else
            anchorPoint = "TOPRIGHT";
        end
    end

    -- Apply the layout and then update our size
	GridLayoutUtil.ApplyGridLayout(shownButtonsAndSpacers, AnchorUtil.CreateAnchor(anchorPoint, self, anchorPoint), layout);
    self:Layout();
    self:UpdateSpellFlyoutDirection();
    self:CacheGridSettings(shownButtonsAndSpacers);
end

function ActionBarMixin:SetShowGrid(showGrid, reason)
    if not showGrid and KeybindFrames_InQuickKeybindMode() then
        return; -- Don't hide grid if we are in QuickKeybindMode
    end

    -- SetShowGrid overrides "Always Show Buttons" being false, showAllButtons overrides "Bar Visible" setting
    -- When dragging spells or going through spell collection, we want to override both
    if reason == ACTION_BUTTON_SHOW_GRID_REASON_EVENT or reason == ACTION_BUTTON_SHOW_GRID_REASON_SPELLCOLLECTION then
        -- Use bit flags to ensure we don't re-hide the bar for one reason while another reason is still active
        -- IE dropping a dragged spell while the Spellbook is still open
        if showGrid then
            self.showAllButtons = bit.bor(self.showAllButtons or 0, reason);
        else
            self.showAllButtons = bit.band(self.showAllButtons or 0, bit.bnot(reason));
        end
    end

    for i, actionButton in pairs(self.actionButtons) do
        actionButton:SetShowGrid(showGrid, reason);
    end

    -- If you are dragging a spell then raise the bar's frame strata
    -- Do this so bars can appear above talents UI since it's pretty big and likely covers your bars
    -- Don't do for other cursor types (specifically items since we don't want bars to cover bag slots when dragging items)
    local cursorType = GetCursorInfo();
	local shouldBeRaised = showGrid and (reason == ACTION_BUTTON_SHOW_GRID_REASON_EVENT) and cursorType == "spell";
	self:UpdateFrameStrata(shouldBeRaised);

    self:UpdateShownButtons();
    self:UpdateVisibility();
    self:UpdateGridLayout();
end

function ActionBarMixin:GetShowAllButtons()
	return self.showAllButtons and self.showAllButtons > 0 or false;
end

function ActionBarMixin:UpdateFrameStrata(shouldBeRaised)
	self:SetFrameStrata(shouldBeRaised and "TOOLTIP" or "MEDIUM");
end

function ActionBarMixin:UpdateShownButtons()
    self.numShowingButtonsOrSpacers = 0;

    for i, actionButton in pairs(self.actionButtons) do
        local showButton = actionButton.index <= self.numButtonsShowable  -- Show button if it is within the num buttons which are showable
            and not actionButton:GetAttribute("statehidden") -- and it isn't being hidden by an attribute
            and (actionButton:GetShowGrid() or actionButton:HasAction(actionButton)); -- And either the grid is being shown or the button has an action

        actionButton:SetShown(showButton);

        if showButton then
            self.numShowingButtonsOrSpacers = self.numShowingButtonsOrSpacers + 1;
        end

        if not self.noSpacers then
            if not showButton and i <= self.numButtonsShowable then
                self.ButtonSpacers[i]:Show();
                self.numShowingButtonsOrSpacers = self.numShowingButtonsOrSpacers + 1;
            else
                self.ButtonSpacers[i]:Hide();
            end
        end
    end
end

function ActionBarMixin:UpdateSpellFlyoutDirection()
    local direction = self.isHorizontal and "UP" or "LEFT";

	local actionBarCenterX, actionBarCenterY = self:GetCenter();
	if actionBarCenterX and actionBarCenterY then
		if self.isHorizontal then
			local halfScreen = GetScreenHeight() / 2;
			direction = actionBarCenterY < halfScreen and "UP" or "DOWN";
		else
			local halfScreen = GetScreenWidth() / 2;
			direction = actionBarCenterX > halfScreen and "LEFT" or "RIGHT";
		end
	end

    if self.flyoutDirection ~= direction then
        self.flyoutDirection = direction;

        for i, actionButton in pairs(self.actionButtons) do
            if actionButton.UpdateFlyout then
                actionButton:UpdateFlyout();
            end
        end
    end
end

function ActionBarMixin:GetSpellFlyoutDirection()
    if not self.flyoutDirection then
        self:UpdateSpellFlyoutDirection();
    end

	return self.flyoutDirection;
end

EditModeActionBarMixin = {}

function EditModeActionBarMixin:EditModeActionBar_OnLoad()
    self:ActionBar_OnLoad();
	self:OnSystemLoad();

    self.isShownExternal = self:IsShown();

    -- Need to override all the show/hide methods so that we can manage our visibility based on settings
    self.IsShownBase = self.IsShown;
    self.IsShown = self.IsShownOverride;
    self.SetShownBase = self.SetShown;
    self.SetShown = self.SetShownOverride;
    self.ShowBase = self.Show;
    self.Show = self.ShowOverride;
    self.HideBase = self.Hide;
    self.Hide = self.HideOverride;

    self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
end

function EditModeActionBarMixin:EditModeActionBar_OnEvent(event, ...)
    if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        -- Update shown state when combat state changes to account for bar visibility setting
        -- Apparently regen being enabled/disabled is a good way to tell whether the player's combat state has changed
		self:UpdateVisibility();
    end
end

function EditModeActionBarMixin:ShouldUpdateGrid(layoutChildren)
	if self:IsInitialized() and not self.gridInitialized then
		self.gridInitialized = true;
		return true;
	end

	return ActionBarMixin.ShouldUpdateGrid(self, layoutChildren);
end

function EditModeActionBarMixin:IsShownOverride()
    -- This is needed since the bar may technically be hidden due to visibility settings but we don't actually want things to
    -- interpret it as truly hidden since a lot of things will use this info to know whether they need to show/hide the bar
    -- and that literal shown state doesn't accurately represent what the bar's state is
    if self.visibility and self.visibility ~= "Always" then
        return self.isShownExternal;
    end

    -- If the bar isn't using visibility settings then just return the base IsShown
    return self:IsShownBase();
end

function EditModeActionBarMixin:SetShownOverride(shown)
    if shown then
        self:ShowOverride();
    else
        self:HideOverride();
    end
end

function EditModeActionBarMixin:ShowOverride()
    self.isShownExternal = true;

    -- Action bars may have fancy visibility rules which we have to follow rather than just directly showing/hiding
    self:UpdateVisibility();
end

function EditModeActionBarMixin:HideOverride()
    self.isShownExternal = false;

    -- Action bars may have fancy visibility rules which we have to follow rather than just directly showing/hiding
    self:UpdateVisibility();
end

function EditModeActionBarMixin:UpdateVisibility()
    if not self.visibility then
        -- If we don't have visiblity settings, then just follow whatever we are told to do externally
        self:SetShownBase(self.isShownExternal or self.editModeForceShow);
    elseif not self.isShownExternal then
        -- If we are being hidden externally then don't change that
        self:HideBase();
    elseif self:GetShowAllButtons() then
        -- If we are showing all buttons likely due to an icon being dragged or viewing spell collection UI then show the bar
        self:ShowBase();
    elseif EditModeManagerFrame:IsEditModeActive() then
        -- If edit mode manager is showing then show
        self:ShowBase();
    elseif self.visibility == "InCombat" or self.visibility == "OutOfCombat" then
        -- If we care about combat visibility, update visibility based on whether you're in combat
        local isInCombat = UnitAffectingCombat("player");

        if self.visibility == "InCombat" then
            self:SetShownBase(isInCombat);
        else -- Out of combat
            self:SetShownBase(not isInCombat);
        end
    elseif self.visibility == "Hidden" then
        -- If we are set to be hidden then hide
        self:HideBase();
    else
        -- If no other rules, show the bar
        self:ShowBase();
    end

    self:UpdateGridLayout();
    EditModeManagerFrame:UpdateActionBarLayout(self);
end