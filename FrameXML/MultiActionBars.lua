NUM_MULTIBAR_BUTTONS = 12;

-- Multi Actionbar Toggles and Temp State Variables
SHOW_MULTI_ACTIONBAR_1, SHOW_MULTI_ACTIONBAR_2, SHOW_MULTI_ACTIONBAR_3, SHOW_MULTI_ACTIONBAR_4 = nil;
STATE_MultiBar1, STATE_MultiBar2, STATE_MultiBar3, STATE_MultiBar4, STATE_AlwaysShowMultibars = nil;


function MultiActionBarFrame_OnLoad()
	-- Hack to get around load order dependencies
	UIOptionsFrameCheckButtons["SHOW_MULTIBAR1_TEXT"].setFunc = Multibar_EmptyFunc;
	UIOptionsFrameCheckButtons["SHOW_MULTIBAR2_TEXT"].setFunc = Multibar_EmptyFunc;
	UIOptionsFrameCheckButtons["SHOW_MULTIBAR3_TEXT"].setFunc = Multibar_EmptyFunc;
	UIOptionsFrameCheckButtons["SHOW_MULTIBAR4_TEXT"].setFunc = Multibar_EmptyFunc;
	UIOptionsFrameCheckButtons["ALWAYS_SHOW_MULTIBARS_TEXT"].setFunc = Multibar_EmptyFunc;
	UIOptionsFrameCheckButtons["SHOW_MULTIBAR1_TEXT"].func = MultiBar1_IsVisible;
	UIOptionsFrameCheckButtons["SHOW_MULTIBAR2_TEXT"].func = MultiBar2_IsVisible;
	UIOptionsFrameCheckButtons["SHOW_MULTIBAR3_TEXT"].func = MultiBar3_IsVisible;
	UIOptionsFrameCheckButtons["SHOW_MULTIBAR4_TEXT"].func = MultiBar4_IsVisible;
	UIOptionsFrameCheckButtons["ALWAYS_SHOW_MULTIBARS_TEXT"].func = MultibarGrid_IsVisible;
	-- This is where i will load the actionbar states
	--MultiActionBar_Update();
end

function MultiActionButtonDown(bar, id)
	local button = getglobal(bar.."Button"..id);
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
end

function MultiActionButtonUp(bar, id, onSelf)
	local button = getglobal(bar.."Button"..id);
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		if ( MacroFrame_SaveMacro ) then
			MacroFrame_SaveMacro();
		end
		UseAction(ActionButton_GetPagedID(button), 0, onSelf);
		if ( IsCurrentAction(ActionButton_GetPagedID(button)) ) then
			button:SetChecked(1);
		else
			button:SetChecked(0);
		end
	end
end



function MultiActionBar_Update()
	if ( SHOW_MULTI_ACTIONBAR_1 ) then
		MultiBarBottomLeft:Show();
		MultiBarBottomLeft.isShowing = 1;
		VIEWABLE_ACTION_BAR_PAGES[BOTTOMLEFT_ACTIONBAR_PAGE] = nil;
	else
		MultiBarBottomLeft:Hide();
		MultiBarBottomLeft.isShowing = nil;
		VIEWABLE_ACTION_BAR_PAGES[BOTTOMLEFT_ACTIONBAR_PAGE] = 1;
	end
	if ( SHOW_MULTI_ACTIONBAR_2 ) then
		MultiBarBottomRight:Show();
		VIEWABLE_ACTION_BAR_PAGES[BOTTOMRIGHT_ACTIONBAR_PAGE] = nil;
	else
		MultiBarBottomRight:Hide();
		VIEWABLE_ACTION_BAR_PAGES[BOTTOMRIGHT_ACTIONBAR_PAGE] = 1;
	end
	if ( SHOW_MULTI_ACTIONBAR_3 ) then
		MultiBarRight:Show();
		VIEWABLE_ACTION_BAR_PAGES[RIGHT_ACTIONBAR_PAGE] = nil;
	else
		MultiBarRight:Hide();
		VIEWABLE_ACTION_BAR_PAGES[RIGHT_ACTIONBAR_PAGE] = 1;
	end
	if ( SHOW_MULTI_ACTIONBAR_3 and SHOW_MULTI_ACTIONBAR_4 ) then
		MultiBarLeft:Show();
		VIEWABLE_ACTION_BAR_PAGES[LEFT_ACTIONBAR_PAGE] = nil;
	else
		MultiBarLeft:Hide();
		VIEWABLE_ACTION_BAR_PAGES[LEFT_ACTIONBAR_PAGE] = 1;
	end
end

function MultiActionBar_ShowAllGrids()
	MultiActionBar_UpdateGrid("MultiBarBottomLeft", 1);
	MultiActionBar_UpdateGrid("MultiBarBottomRight", 1);
	MultiActionBar_UpdateGrid("MultiBarRight", 1);
	MultiActionBar_UpdateGrid("MultiBarLeft", 1);
end

function MultiActionBar_HideAllGrids()
	MultiActionBar_UpdateGrid("MultiBarBottomLeft");
	MultiActionBar_UpdateGrid("MultiBarBottomRight");
	MultiActionBar_UpdateGrid("MultiBarRight");
	MultiActionBar_UpdateGrid("MultiBarLeft");
end

function MultiActionBar_UpdateGrid(barName, show)
	for i=1, NUM_MULTIBAR_BUTTONS do
		if ( show ) then
			ActionButton_ShowGrid(getglobal(barName.."Button"..i));
		else
			ActionButton_HideGrid(getglobal(barName.."Button"..i));
		end
		
	end
end

function MultiActionBar_UpdateGridVisibility()
	if ( ALWAYS_SHOW_MULTIBARS == "1" or ALWAYS_SHOW_MULTIBARS == 1 ) then
		MultiActionBar_ShowAllGrids();
	else
		MultiActionBar_HideAllGrids();
	end
end

function Multibar_EmptyFunc(show)
	
end

function MultibarGrid_IsVisible()
	STATE_AlwaysShowMultibars = ALWAYS_SHOW_MULTIBARS;
	return ALWAYS_SHOW_MULTIBARS;
end

function MultiBar1_IsVisible()
	STATE_MultiBar1 = SHOW_MULTI_ACTIONBAR_1;
	return SHOW_MULTI_ACTIONBAR_1;
end

function MultiBar2_IsVisible()
	STATE_MultiBar2 = SHOW_MULTI_ACTIONBAR_2;
	return SHOW_MULTI_ACTIONBAR_2;
end

function MultiBar3_IsVisible()
	STATE_MultiBar3 = SHOW_MULTI_ACTIONBAR_3;
	return SHOW_MULTI_ACTIONBAR_3;
end

function MultiBar4_IsVisible()
	STATE_MultiBar4 = SHOW_MULTI_ACTIONBAR_4;
	return SHOW_MULTI_ACTIONBAR_4;
end

