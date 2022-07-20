NUM_MULTIBAR_BUTTONS = 12;
VERTICAL_MULTI_BAR_HEIGHT = 503;
VERTICAL_MULTI_BAR_WIDTH = 41;
VERTICAL_MULTI_BAR_VERTICAL_SPACING = 20;
VERTICAL_MULTI_BAR_HORIZONTAL_SPACING = 2;
VERTICAL_MULTI_BAR_MIN_SCALE = 0.8333;

function MultiActionButtonDown (bar, id)
	local bar = _G[bar];
	local button = bar.ActionButtons[id];
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
	TryUseActionButton(button, true);
end

function MultiActionButtonUp (bar, id)
	local bar = _G[bar];
	local button = bar.ActionButtons[id];
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		TryUseActionButton(button, false);
	end
end

function IsNormalActionBarState()
	return MainMenuBar:IsShown();
end

local function UpdateMultiActionBar(frame, var, pageVar)
	if (var and IsNormalActionBarState()) then
		frame:SetShown(true);
		VIEWABLE_ACTION_BAR_PAGES[pageVar] = nil;
	else
		frame:SetShown(false);
		VIEWABLE_ACTION_BAR_PAGES[pageVar] = 1;
	end
end

function MultiActionBar_Update ()
	UpdateMultiActionBar(MultiBarBottomLeft, MultiBar1_IsVisible(), BOTTOMLEFT_ACTIONBAR_PAGE);
	UpdateMultiActionBar(MultiBarBottomRight, MultiBar1_IsVisible() and MultiBar2_IsVisible(), BOTTOMRIGHT_ACTIONBAR_PAGE);
	UpdateMultiActionBar(MultiBarRight, MultiBar3_IsVisible(), RIGHT_ACTIONBAR_PAGE);
	UpdateMultiActionBar(MultiBarLeft, MultiBar3_IsVisible() and MultiBar4_IsVisible(), LEFT_ACTIONBAR_PAGE);

	EditModeManagerFrame:UpdateRightAnchoredActionBarWidth();
	EditModeManagerFrame:UpdateBottomAnchoredActionBarHeight();
end

function MultiActionBar_ShowAllGrids (reason)
	MultiBarBottomLeft:SetShowGrid(true, reason);
	MultiBarBottomRight:SetShowGrid(true, reason);
	MultiBarRight:SetShowGrid(true, reason);
	MultiBarLeft:SetShowGrid(true, reason);
end

function MultiActionBar_HideAllGrids (reason)
	MultiBarBottomLeft:SetShowGrid(false, reason);
	MultiBarBottomRight:SetShowGrid(false, reason);
	MultiBarRight:SetShowGrid(false, reason);
	MultiBarLeft:SetShowGrid(false, reason);
end

function MultiActionBar_SetAllQuickKeybindModeEffectsShown(showEffects)
	MultiBarBottomLeft.QuickKeybindGlow:SetShown(showEffects);
	MultiBarBottomRight.QuickKeybindGlow:SetShown(showEffects);
	MultiBarLeft.QuickKeybindGlow:SetShown(showEffects);
	MultiBarRight.QuickKeybindGlow:SetShown(showEffects);
end

function Multibar_EmptyFunc (show)

end

function MultiBar1_IsVisible ()
	return Settings.GetValue("PROXY_SHOW_MULTI_ACTIONBAR_1");
end

function MultiBar2_IsVisible ()
	return Settings.GetValue("PROXY_SHOW_MULTI_ACTIONBAR_2");
end

function MultiBar3_IsVisible ()
	return Settings.GetValue("PROXY_SHOW_MULTI_ACTIONBAR_3");
end

function MultiBar4_IsVisible ()
	return Settings.GetValue("PROXY_SHOW_MULTI_ACTIONBAR_4");
end
