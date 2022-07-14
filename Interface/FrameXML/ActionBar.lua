local NUM_ACTION_BUTTONS = 12;
local MIN_BUTTON_PADDING = 3;

ActionBarMixin = {}

function ActionBarMixin:ActionBar_OnLoad()
    self.numShowingButtons = NUM_ACTION_BUTTONS;
    self.buttonPadding = MIN_BUTTON_PADDING;
    self.buttonsAndSpacers = {}

    -- Create action buttons
    for i=1, NUM_ACTION_BUTTONS do
		local name = (self == MainMenuBar) and "ActionButton"..i or self:GetName().."Button"..i;
		local actionButton = CreateFrame("CheckButton", name, self, self.buttonTemplate, i);
        actionButton.commandName = self.commandNamePrefix.."BUTTON"..i;
        actionButton.isLastActionButton = i == NUM_ACTION_BUTTONS;
        self.buttonsAndSpacers[#self.buttonsAndSpacers + 1] = actionButton;

        -- Create button spacer
        -- Spacers are used to keep size of bar the same when we aren't showing the grid
        local spacer = CreateFrame("Frame", "ActionBarButtonSpacer"..i, self, "ActionBarButtonSpacerTemplate", i);
        self.buttonsAndSpacers[#self.buttonsAndSpacers + 1] = spacer;
    end

    self:UpdateGridLayout();

    self:RegisterEvent("ACTIONBAR_SHOWGRID");
    self:RegisterEvent("ACTIONBAR_HIDEGRID");
end

function ActionBarMixin:ActionBar_OnEvent(event, ...)
    if (event == "ACTIONBAR_SHOWGRID") then
        self:SetShowGrid(true, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	elseif (event == "ACTIONBAR_HIDEGRID") then
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

    for i, actionButton in pairs(self.ActionButtons) do
        actionButton:SetShowGrid(showGrid, reason);
    end

    self:UpdateShownButtons();
    self:UpdateVisibility();
    self:UpdateGridLayout();
end

function ActionBarMixin:UpdateShownButtons()
    for i, actionButton in pairs(self.ActionButtons) do
        local isWithinNumShowingButtons = i <= self.numShowingButtons;
        local showButton = isWithinNumShowingButtons  -- Show button if it is within the num shown buttons
                    and not actionButton:GetAttribute("statehidden") -- and it isn't being hidden by an attribute
                    and (actionButton:GetShowGrid() or HasAction(actionButton.action)); -- And either the grid is being shown or the button has an action

        actionButton:SetShown(showButton);

        if  (not showButton and isWithinNumShowingButtons) then
            self.ButtonSpacers[i]:Show();
        else
            self.ButtonSpacers[i]:Hide();
        end
    end
end

EditModeActionBarMixin = {}

function EditModeActionBarMixin:EditModeActionBar_OnLoad()
    self:ActionBar_OnLoad();
	self:OnSystemLoad();
    self:EditModeActionBarSystem_OnLoad();

    self.isShownExternal = self:IsShown();

    -- Need to override all the show/hide methods so that we can manage our visibility based on settings
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
    self:OnVisibilityUpdated();
end

function EditModeActionBarMixin:EditModeActionBar_OnHide()
    self:OnVisibilityUpdated();
end

function EditModeActionBarMixin:SetShownOverride(shown, isInternalCall)
    -- Need this since base version of SetShown doesn't call show/hide if it's already showing/hiding
    if (shown) then
        self:Show(isInternalCall);
    else
        self:Hide(isInternalCall);
    end
end

function EditModeActionBarMixin:ShowOverride(isInternalCall)
    if (not isInternalCall) then
        -- Track whether the show/hide calls are happening externally so we know what state the bar should be in were it to not have any visibility rules
        self.isShownExternal = true;

        -- When being shown externally, call our own update visibility method to check if we should actually be shown based on our visibility rules
        self:UpdateVisibility();
        return;
    end

    self:ShowBase();
end

function EditModeActionBarMixin:HideOverride(isInternalCall)
    if (not isInternalCall) then
        self.isShownExternal = false;
    end

    self:HideBase();
end

function EditModeActionBarMixin:UpdateVisibility()
    -- If we don't have visiblity settings, then just follow whatever we are told to do externally
    if (not self.visibility) then
        self:SetShown(self.isShownExternal, true);
        return;
    end

    -- If we are being hidden externally then don't change that
    if (not self.isShownExternal) then
        self:Hide(true);
        return;
    end

    -- If we are showing all buttons likely due to an icon being dragged then show the bar
    if (self.ShowAllButtons) then
        self:Show(true);
        return;
    end

    -- If edit mode manager is showing then show
    if (EditModeManagerFrame:IsEditModeActive()) then
        self:Show(true);
        return;
    end

    -- If we care about combat visibility, update visibility based on whether you're in combat
    if (self.visibility == "InCombat" or self.visibility == "OutOfCombat") then
        local isInCombat = UnitAffectingCombat("player");

        if (self.visibility == "InCombat") then
            self:SetShown(isInCombat, true);
        else -- Out of combat
            self:SetShown(not isInCombat, true);
        end
        return;
    end

    -- If no other rules, show the bar
    self:Show(true);
end

function EditModeActionBarMixin:OnVisibilityUpdated()
    -- When some action bars visibility changes we need to update our width/height with edit mode
    if (self == MultiBarRight or self == MultiBarLeft) then
        EditModeManagerFrame:UpdateRightAnchoredActionBarWidth();
    elseif (self == MultiBarBottomLeft or self == MultiBarBottomRight) then
        EditModeManagerFrame:UpdateBottomAnchoredActionBarHeight();
    end
end