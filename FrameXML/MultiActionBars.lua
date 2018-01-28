NUM_MULTIBAR_BUTTONS = 12;
VERTICAL_MULTI_BAR_HEIGHT = 503;
VERTICAL_MULTI_BAR_WIDTH = 41;
VERTICAL_MULTI_BAR_VERTICAL_SPACING = 20;
VERTICAL_MULTI_BAR_HORIZONTAL_SPACING = 2;
VERTICAL_MULTI_BAR_MIN_SCALE = 0.6944;

function MultiActionButtonDown (bar, id)
	local button = _G[bar.."Button"..id];
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
	if (GetCVarBool("ActionButtonUseKeyDown")) then
		SecureActionButton_OnClick(button, "LeftButton");
		ActionButton_UpdateState(button);
	end
end

function MultiActionButtonUp (bar, id)
	local button = _G[bar.."Button"..id];
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		if(not GetCVarBool("ActionButtonUseKeyDown")) then
			SecureActionButton_OnClick(button, "LeftButton");
			ActionButton_UpdateState(button);
		end
	end
end

function IsNormalActionBarState()
	return MainMenuBar:IsShown();
end

function MultiActionBar_Update ()
	if ( SHOW_MULTI_ACTIONBAR_1 and IsNormalActionBarState()) then
		MultiBarBottomLeft:Show();
		MultiBarBottomLeft.isShowing = 1;
		VIEWABLE_ACTION_BAR_PAGES[BOTTOMLEFT_ACTIONBAR_PAGE] = nil;
	else
		MultiBarBottomLeft:Hide();
		MultiBarBottomLeft.isShowing = nil;
		VIEWABLE_ACTION_BAR_PAGES[BOTTOMLEFT_ACTIONBAR_PAGE] = 1;
	end
	if ( SHOW_MULTI_ACTIONBAR_2 and IsNormalActionBarState()) then
		MultiBarBottomRight:Show();
		VIEWABLE_ACTION_BAR_PAGES[BOTTOMRIGHT_ACTIONBAR_PAGE] = nil;
		MainMenuBar_ChangeMenuBarSizeAndPosition(true);
		StatusTrackingBarManager:UpdateBarsShown();
	else
		MultiBarBottomRight:Hide();
		MainMenuBar_ChangeMenuBarSizeAndPosition(false);
		StatusTrackingBarManager:UpdateBarsShown();
		VIEWABLE_ACTION_BAR_PAGES[BOTTOMRIGHT_ACTIONBAR_PAGE] = 1;
	end
	local showRight = false;
	local showLeft = false;
	if ( SHOW_MULTI_ACTIONBAR_3 and IsNormalActionBarState()) then
		MultiBarRight:Show();
		VIEWABLE_ACTION_BAR_PAGES[RIGHT_ACTIONBAR_PAGE] = nil;
		showRight = true;
	else
		MultiBarRight:Hide();
		VIEWABLE_ACTION_BAR_PAGES[RIGHT_ACTIONBAR_PAGE] = 1;
	end
	if ( SHOW_MULTI_ACTIONBAR_3 and SHOW_MULTI_ACTIONBAR_4 and IsNormalActionBarState()) then
		MultiBarLeft:Show();
		VIEWABLE_ACTION_BAR_PAGES[LEFT_ACTIONBAR_PAGE] = nil;
		showLeft = true;
	else
		MultiBarLeft:Hide();
		VIEWABLE_ACTION_BAR_PAGES[LEFT_ACTIONBAR_PAGE] = 1;
	end

	if ( showRight ) then
		local topLimit = MinimapCluster:GetBottom() + 14;	-- increasing by 14 here because we can overlap since the cluster is bigger than the elements it contains
		local availableSpace = topLimit - MicroButtonAndBagsBar:GetTop() - 14;	-- reducing by 14 here because we want some space beween the action buttons and the bags
		local contentWidth = VERTICAL_MULTI_BAR_WIDTH;
		local contentHeight = VERTICAL_MULTI_BAR_HEIGHT;
		if ( showLeft ) then
			contentHeight = contentHeight + VERTICAL_MULTI_BAR_HEIGHT + VERTICAL_MULTI_BAR_VERTICAL_SPACING;
			MultiBarLeft:ClearAllPoints();
			if ( contentHeight * VERTICAL_MULTI_BAR_MIN_SCALE > availableSpace ) then
				MultiBarLeft:SetPoint("TOPRIGHT", MultiBarRight, "TOPLEFT", -VERTICAL_MULTI_BAR_HORIZONTAL_SPACING, 0);
				contentHeight = VERTICAL_MULTI_BAR_HEIGHT;
				contentWidth = VERTICAL_MULTI_BAR_WIDTH * 2 + VERTICAL_MULTI_BAR_HORIZONTAL_SPACING;
			else
				MultiBarLeft:SetPoint("TOP", MultiBarRight, "BOTTOM", 0, -VERTICAL_MULTI_BAR_VERTICAL_SPACING);
			end
		end

		local scale = 1;
		if ( contentHeight > availableSpace ) then
			scale = availableSpace / contentHeight;
		end
		MultiBarRight:SetScale(scale);
		if ( showLeft ) then
			MultiBarLeft:SetScale(scale);
		end
		VerticalMultiBarsContainer:SetSize(contentWidth * scale, contentHeight * scale);

		-- center position, and if we run into the minimap cluster, move it down just enough
		local yOffset = (contentHeight - VERTICAL_MULTI_BAR_HEIGHT) / 2;
		VerticalMultiBarsContainer:SetPoint("RIGHT", 0, yOffset);
		local barTop = VerticalMultiBarsContainer:GetTop();
		if ( topLimit < barTop ) then
			yOffset = yOffset + topLimit - barTop;
			VerticalMultiBarsContainer:SetPoint("RIGHT", 0, yOffset);
		end
	else
		VerticalMultiBarsContainer:SetSize(0, 0);
	end
	-- TODO: Evaluate how often we're doing multiple calls of UIParent_ManageFramePositions per frame
	UIParent_ManageFramePositions();
end

function MultiActionBar_ShowAllGrids ()
	MultiActionBar_UpdateGrid("MultiBarBottomLeft", true);
	MultiActionBar_UpdateGrid("MultiBarBottomRight", true);
	MultiActionBar_UpdateGrid("MultiBarRight", true);
	MultiActionBar_UpdateGrid("MultiBarLeft", true);
end

function MultiActionBar_HideAllGrids ()
	MultiActionBar_UpdateGrid("MultiBarBottomLeft", false);
	MultiActionBar_UpdateGrid("MultiBarBottomRight", false);
	MultiActionBar_UpdateGrid("MultiBarRight", false);
	MultiActionBar_UpdateGrid("MultiBarLeft", false);
end

function MultiActionBar_UpdateGrid (barName, show)
	for i=1, NUM_MULTIBAR_BUTTONS do
		if ( show ) then
			ActionButton_ShowGrid(_G[barName.."Button"..i]);
		else
			ActionButton_HideGrid(_G[barName.."Button"..i]);
		end
	end
end

function MultiActionBar_UpdateGridVisibility ()
	if ( ALWAYS_SHOW_MULTIBARS == "1" or ALWAYS_SHOW_MULTIBARS == 1 ) then
		MultiActionBar_ShowAllGrids();
	else
		MultiActionBar_HideAllGrids();
	end
end

function Multibar_EmptyFunc (show)
	
end

function MultibarGrid_IsVisible ()
	STATE_AlwaysShowMultibars = ALWAYS_SHOW_MULTIBARS;
	return ALWAYS_SHOW_MULTIBARS;
end

function MultiBar1_IsVisible ()
	STATE_MultiBar1 = SHOW_MULTI_ACTIONBAR_1;
	return SHOW_MULTI_ACTIONBAR_1;
end

function MultiBar2_IsVisible ()
	STATE_MultiBar2 = SHOW_MULTI_ACTIONBAR_2;
	return SHOW_MULTI_ACTIONBAR_2;
end

function MultiBar3_IsVisible ()
	STATE_MultiBar3 = SHOW_MULTI_ACTIONBAR_3;
	return SHOW_MULTI_ACTIONBAR_3;
end

function MultiBar4_IsVisible ()
	STATE_MultiBar4 = SHOW_MULTI_ACTIONBAR_4;
	return SHOW_MULTI_ACTIONBAR_4;
end