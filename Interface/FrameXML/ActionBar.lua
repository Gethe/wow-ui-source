local MIN_BUTTON_PADDING = 2;

ActionBarMixin = {}

function ActionBarMixin:ActionBar_OnLoad()
    self.numShowingButtons = self.numButtons;
    self.buttonPadding = MIN_BUTTON_PADDING;
    self.actionButtons = {};
    self.buttonsAndSpacers = {};

    -- Create action buttons
    for i=1, self.numButtons do

        -- Different naming for these bars is to avoid errors with legacy code
        -- Ideally this wouldn't be needed
        local name;
        if (self == MainMenuBar) then
            name = "ActionButton"..i;
        elseif (self == StanceBar) then
            name = "StanceButton"..i;
        elseif (self == PetActionBar) then
            name = "PetActionButton"..i;
        elseif (self == PossessActionBar) then
            name = "PossessButton"..i;
        else
            name = self:GetName().."Button"..i;
        end

		local actionButton = CreateFrame("CheckButton", name, self, self.buttonTemplate, i);
        actionButton.index = i;
        actionButton.isLastActionButton = i == self.numButtons;

        if (self.commandNamePrefix) then
            actionButton.commandName = self.commandNamePrefix.."BUTTON"..i;
        end

        self.actionButtons[#self.actionButtons + 1] = actionButton;
        self.buttonsAndSpacers[#self.buttonsAndSpacers + 1] = actionButton;

        if (not self.noSpacers) then
            -- Create button spacer
            -- Spacers are used to keep size of bar the same when we aren't showing the grid
            local spacer = CreateFrame("Frame", "ActionBarButtonSpacer"..i, self, "ActionBarButtonSpacerTemplate", i);
            spacer:SetSize(actionButton:GetWidth(), actionButton:GetHeight()); -- Spacer size should match the size of the action buttons
            self.buttonsAndSpacers[#self.buttonsAndSpacers + 1] = spacer;
        end
    end

    self:UpdateShownButtons();
    self:UpdateGridLayout();

    if (self.showGridEventName) then
        self:RegisterEvent(self.showGridEventName);
    end
    if (self.hideGridEventName) then
        self:RegisterEvent(self.hideGridEventName);
    end
end

function ActionBarMixin:ActionBar_OnEvent(event, ...)
    if (event == self.showGridEventName) then
        self:SetShowGrid(true, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	elseif (event == self.hideGridEventName) then
		self:SetShowGrid(false, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
    end
end

function ActionBarMixin:UpdateGridLayout()
    -- Stride is the number of buttons per row (or column if we are vertical)
    -- Set stride so that if we can have the same number of icons per row we do
    local stride = math.ceil(self.numShowingButtons / self.numRows);

    -- Set button padding. User can set padding through edit mode
    local buttonPadding = math.max(MIN_BUTTON_PADDING, self.buttonPadding);

    -- Multipliers determine the direction the bar grows for grid layouts 
    -- Positive means right/up
    -- Negative means left/down
    local xMultiplier = self.addButtonsToRight and 1 or -1;
    local yMultiplier = self.addButtonsToTop and 1 or -1;

    -- Create the grid layout according to whether we are horizontal or vertical
    local layout;
    if (self.isHorizontal) then
        layout = GridLayoutUtil.CreateStandardGridLayout(stride, buttonPadding, buttonPadding, xMultiplier, yMultiplier);
    else
        layout = GridLayoutUtil.CreateVerticalGridLayout(stride, buttonPadding, buttonPadding, xMultiplier, yMultiplier);
    end

    -- Need to change where the buttons anchor based on how the bar grows
    local anchorPoint;
    if (self.addButtonsToTop) then
        if (self.addButtonsToRight) then
            anchorPoint = "BOTTOMLEFT";
        else
            anchorPoint = "BOTTOMRIGHT";
        end
    else
        if (self.addButtonsToRight) then
            anchorPoint = "TOPLEFT";
        else
            anchorPoint = "TOPRIGHT";
        end
    end

    local shownButtonsAndSpacers = {};
    for i, buttonOrSpacer in pairs(self.buttonsAndSpacers) do
        if (buttonOrSpacer:IsShown()) then
            shownButtonsAndSpacers[#shownButtonsAndSpacers + 1] = buttonOrSpacer;
        end

        -- We will want to update our flyout if our orientation changes
        if (buttonOrSpacer.UpdateFlyout) then
            buttonOrSpacer:UpdateFlyout()
        end
    end

    -- Apply the layout and then update our size
	GridLayoutUtil.ApplyGridLayout(shownButtonsAndSpacers, AnchorUtil.CreateAnchor(anchorPoint, self, anchorPoint), layout);
    self:Layout();
end

function ActionBarMixin:SetShowGrid(showGrid, reason)
    if (not showGrid and KeybindFrames_InQuickKeybindMode()) then
        return; -- Don't hide grid if we are in QuickKeybindMode
    end

    if (reason == ACTION_BUTTON_SHOW_GRID_REASON_EVENT) then
        self.ShowAllButtons = showGrid;
    end

    for i, actionButton in pairs(self.actionButtons) do
        actionButton:SetShowGrid(showGrid, reason);
    end

	local shouldBeRaised = showGrid and (reason == ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	self:UpdateFrameStrata(shouldBeRaised);

    self:UpdateShownButtons();
    self:UpdateVisibility();
    self:UpdateGridLayout();
end

function ActionBarMixin:UpdateFrameStrata(shouldBeRaised)
	self:SetFrameStrata(shouldBeRaised and "TOOLTIP" or "MEDIUM");
end

function ActionBarMixin:UpdateShownButtons()
    for i, actionButton in pairs(self.actionButtons) do
        local showButton = actionButton.index <= self.numShowingButtons  -- Show button if it is within the num shown buttons
            and not actionButton:GetAttribute("statehidden") -- and it isn't being hidden by an attribute
            and (actionButton:GetShowGrid() or actionButton:HasAction(actionButton)); -- And either the grid is being shown or the button has an action

        actionButton:SetShown(showButton);

        if (not self.noSpacers) then
            if  (not showButton and i <= self.numShowingButtons) then
                self.ButtonSpacers[i]:Show();
            else
                self.ButtonSpacers[i]:Hide();
            end
        end
    end
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
    if (event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED") then
        -- Update shown state when combat state changes to account for bar visibility setting
        -- Apparently regen being enabled/disabled is a good way to tell whether the player's combat state has changed
		self:UpdateVisibility();
    end
end

function EditModeActionBarMixin:EditModeActionBar_OnShow()
    EditModeManagerFrame:UpdateActionBarLayout(self);
end

function EditModeActionBarMixin:EditModeActionBar_OnHide()
    EditModeManagerFrame:UpdateActionBarLayout(self);
end

function EditModeActionBarMixin:IsShownOverride()
    -- This is needed since the bar may technically be hidden due to visibility settings but we don't actually want things to
    -- interpret it as truly hidden since a lot of things will use this info to know whether they need to show/hide the bar
    -- and that literal shown state doesn't accurately represent what the bar's state is
    if (self.visibility) then
        if (self.visibility == "InCombat" or self.visibility == "OutOfCombat") then
            return self.isShownExternal;
        end
    end

    -- If the bar isn't using visibility settings then just return the base IsShown
    return self:IsShownBase();
end

function EditModeActionBarMixin:SetShownOverride(shown)
    if (shown) then
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
    -- If we don't have visiblity settings, then just follow whatever we are told to do externally
    if (not self.visibility) then
        self:SetShownBase(self.isShownExternal);
        return;
    end

    -- If we are being hidden externally then don't change that
    if (not self.isShownExternal) then
        self:HideBase();
        return;
    end

    -- If we are showing all buttons likely due to an icon being dragged then show the bar
    if (self.ShowAllButtons) then
        self:ShowBase();
        return;
    end

    -- If edit mode manager is showing then show
    if (EditModeManagerFrame:IsEditModeActive()) then
        self:ShowBase();
        return;
    end

    -- If we care about combat visibility, update visibility based on whether you're in combat
    if (self.visibility == "InCombat" or self.visibility == "OutOfCombat") then
        local isInCombat = UnitAffectingCombat("player");

        if (self.visibility == "InCombat") then
            self:SetShownBase(isInCombat);
        else -- Out of combat
            self:SetShownBase(not isInCombat);
        end
        return;
    end

    -- If we are set to be hidden then hide
    if (self.visibility == "Hidden") then
        self:HideBase();
        return;
    end

    -- If no other rules, show the bar
    self:ShowBase();
end