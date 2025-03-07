RIGHT_ACTIONBAR_PAGE = 3;
LEFT_ACTIONBAR_PAGE = 4;
BOTTOMRIGHT_ACTIONBAR_PAGE = 5;
BOTTOMLEFT_ACTIONBAR_PAGE = 6;

MULTIBAR_5_ACTIONBAR_PAGE = 13;
MULTIBAR_6_ACTIONBAR_PAGE = 14;
MULTIBAR_7_ACTIONBAR_PAGE = 15;

NUM_MULTIBAR_BUTTONS = 12;
VERTICAL_MULTI_BAR_HEIGHT = 503;
VERTICAL_MULTI_BAR_WIDTH = 41;
VERTICAL_MULTI_BAR_VERTICAL_SPACING = 20;
VERTICAL_MULTI_BAR_HORIZONTAL_SPACING = 2;
VERTICAL_MULTI_BAR_MIN_SCALE = 0.8333;

function MultiActionButtonDown (barName, id)
	local bar = _G[barName];
	local button = bar.actionButtons[id];
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
	TryUseActionButton(button, true);
end

function MultiActionButtonUp (barName, id)
	local bar = _G[barName];
	local button = bar.actionButtons[id];
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		TryUseActionButton(button, false);
	end
end

function IsNormalActionBarState()
	return MainMenuBar:IsShown();
end

local multiActionBarTable;
local function GetMultiActionBars()
	if not multiActionBarTable then
		-- Double check on the off chance this gets called when the bars aren't yet loaded in
		if not MultiBarBottomLeft or not MultiBarBottomRight or not MultiBarRight or not MultiBarLeft or not MultiBar5 or not MultiBar6 or not MultiBar7 then
			return nil;
		end

		-- Lazy initialize & cache the table
		multiActionBarTable = {
			[BOTTOMLEFT_ACTIONBAR_PAGE] = 	{ bar = MultiBarBottomLeft, 	getIsVisible = MultiBar1_IsVisible },
			[BOTTOMRIGHT_ACTIONBAR_PAGE] = 	{ bar = MultiBarBottomRight, 	getIsVisible = MultiBar2_IsVisible },
			[RIGHT_ACTIONBAR_PAGE] = 		{ bar = MultiBarRight, 			getIsVisible = MultiBar3_IsVisible },
			[LEFT_ACTIONBAR_PAGE] = 		{ bar = MultiBarLeft, 			getIsVisible = MultiBar4_IsVisible },
			[MULTIBAR_5_ACTIONBAR_PAGE] = 	{ bar = MultiBar5, 				getIsVisible = MultiBar5_IsVisible },
			[MULTIBAR_6_ACTIONBAR_PAGE] = 	{ bar = MultiBar6, 				getIsVisible = MultiBar6_IsVisible },
			[MULTIBAR_7_ACTIONBAR_PAGE] = 	{ bar = MultiBar7, 				getIsVisible = MultiBar7_IsVisible },
		};
	end

	return multiActionBarTable;
end

local function UpdateMultiActionBar(frame, var, pageVar)
	if var == nil then
		-- if var is nil that means settings were not loaded when this was called, so do nothing
		return;
	end

	if var and IsNormalActionBarState() then
		frame:SetShown(true);
		VIEWABLE_ACTION_BAR_PAGES[pageVar] = nil;
	else
		frame:SetShown(false);
		VIEWABLE_ACTION_BAR_PAGES[pageVar] = 1;
	end
end

function MultiActionBar_Update ()
	local multiActionBarEntries = GetMultiActionBars();
	if multiActionBarEntries then
		for page, barEntry in pairs(multiActionBarEntries) do
			UpdateMultiActionBar(barEntry.bar, barEntry.getIsVisible(), page);
		end
	end
end

function MultiActionBar_ShowAllGrids (reason)
	local multiActionBarEntries = GetMultiActionBars();
	if multiActionBarEntries then
		for _, barEntry in pairs(multiActionBarEntries) do
			barEntry.bar:SetShowGrid(true, reason);
		end
	end
end

function MultiActionBar_HideAllGrids (reason)
	local multiActionBarEntries = GetMultiActionBars();
	if multiActionBarEntries then
		for _, barEntry in pairs(multiActionBarEntries) do
			barEntry.bar:SetShowGrid(false, reason);
		end
	end
end

function MultiActionBar_SetAllQuickKeybindModeEffectsShown(showEffects)
	local multiActionBarEntries = GetMultiActionBars();
	if multiActionBarEntries then
		for _, barEntry in pairs(multiActionBarEntries) do
			barEntry.bar.QuickKeybindGlow:SetShown(showEffects);
		end
	end
end

function MultiActionBar_GetBarForPage(page)
	local bars = GetMultiActionBars();
	return (bars and bars[page]) and bars[page].bar or nil;
end

function Multibar_EmptyFunc (show)

end

function MultiBar1_IsVisible()
	return IsMultibarVisible(1);
end

function MultiBar2_IsVisible()
	return IsMultibarVisible(2);
end

function MultiBar3_IsVisible()
	return IsMultibarVisible(3);
end

function MultiBar4_IsVisible()
	return IsMultibarVisible(4);
end

function MultiBar5_IsVisible()
	return IsMultibarVisible(5);
end

function MultiBar6_IsVisible()
	return IsMultibarVisible(6);
end

function MultiBar7_IsVisible()
	return IsMultibarVisible(7);
end