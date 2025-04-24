NUM_MULTIBAR_BUTTONS = 12;
VERTICAL_MULTI_BAR_HEIGHT = 503;
VERTICAL_MULTI_BAR_WIDTH = 41;
VERTICAL_MULTI_BAR_VERTICAL_SPACING = 20;
VERTICAL_MULTI_BAR_HORIZONTAL_SPACING = 2;
VERTICAL_MULTI_BAR_MIN_SCALE = 0.8333;

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

local function UpdateMultiActionBar(frame, var, pageVar, cb)
	if (var and IsNormalActionBarState()) then 
		frame:SetShown(true); 
		VIEWABLE_ACTION_BAR_PAGES[pageVar] = nil; 
	else 
		frame:SetShown(false); 
		VIEWABLE_ACTION_BAR_PAGES[pageVar] = 1; 
	end
	
	if (cb) then
		cb(var);
	end
end

function MultiActionBar_Update ()
	local showLeft = false;
	local showRight = false;
	
	UpdateMultiActionBar(MultiBarBottomLeft, MultiBar1_IsVisible(), BOTTOMLEFT_ACTIONBAR_PAGE);
	UpdateMultiActionBar(MultiBarBottomRight, MultiBar2_IsVisible(), BOTTOMRIGHT_ACTIONBAR_PAGE);
	UpdateMultiActionBar(MultiBarRight, MultiBar3_IsVisible(), RIGHT_ACTIONBAR_PAGE, function(var) showRight = var; end);
	UpdateMultiActionBar(MultiBarLeft, MultiBar3_IsVisible() and MultiBar4_IsVisible(), LEFT_ACTIONBAR_PAGE, function(var) showLeft = var; end);

	if ( showRight ) then
		local maxWidth = VERTICAL_MULTI_BAR_WIDTH * 2 + VERTICAL_MULTI_BAR_HORIZONTAL_SPACING;

		local topLimit = MinimapCluster:GetBottom() + 20;
		local bottomLimit = UIParent:GetBottom() + 8;
			if (MultiBarBottomRight:IsShown() and MultiBarBottomRight:GetRight() >= UIParent:GetRight() - maxWidth - 16) then
				bottomLimit = MultiBarBottomRight:GetTop() + 8;
			else
				bottomLimit = MainMenuBarArtFrame:GetTop() + 24;
			end
		
		local availableSpace = topLimit - bottomLimit;
		local contentWidth = VERTICAL_MULTI_BAR_WIDTH;
		local contentHeight = VERTICAL_MULTI_BAR_HEIGHT;
		if ( showLeft ) then
			contentHeight = contentHeight + VERTICAL_MULTI_BAR_HEIGHT + VERTICAL_MULTI_BAR_VERTICAL_SPACING;
			MultiBarLeft:ClearAllPoints();
			if ( contentHeight * VERTICAL_MULTI_BAR_MIN_SCALE > availableSpace or not GetCVarBool("multiBarRightVerticalLayout")) then
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

		-- center position (of the available space), and if we run into the minimap cluster, move it down or up just enough
		local yOffset = ((contentHeight - VERTICAL_MULTI_BAR_HEIGHT) / 2) - ((GetScreenHeight() / 2) - ((availableSpace / 2) + bottomLimit));

		VerticalMultiBarsContainer:SetPoint("RIGHT", 0, yOffset);
		local barTop = VerticalMultiBarsContainer:GetTop();
		local barBottom = VerticalMultiBarsContainer:GetBottom();
		if ( topLimit < barTop or bottomLimit > barBottom) then
			yOffset = yOffset + math.min(topLimit - barTop, barBottom - bottomLimit);
			VerticalMultiBarsContainer:SetPoint("RIGHT", 0, yOffset);
		end
	else
		VerticalMultiBarsContainer:SetSize(1, 1);
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
	for i = 1, NUM_MULTIBAR_BUTTONS do
		local button = _G[barName.."Button"..i];
		if ( show and not button.noGrid) then
			ActionButton_ShowGrid(button);
		else
			ActionButton_HideGrid(button);
		end
	end
end

function MultiActionBar_UpdateGridVisibility ()
	if ( Settings.GetValue("alwaysShowActionBars") ) then
		MultiActionBar_ShowAllGrids();
	else
		MultiActionBar_HideAllGrids();
	end
end

function Multibar_EmptyFunc (show)
	
end

function MultibarGrid_IsVisible ()
	return Settings.GetValue("alwaysShowActionBars");
end

function MultiBar1_IsVisible()
	return Settings.GetValue("PROXY_SHOW_ACTIONBAR_2");
end

function MultiBar2_IsVisible()
	return Settings.GetValue("PROXY_SHOW_ACTIONBAR_3");
end

function MultiBar3_IsVisible()
	return Settings.GetValue("PROXY_SHOW_ACTIONBAR_4");
end

function MultiBar4_IsVisible()
	return Settings.GetValue("PROXY_SHOW_ACTIONBAR_5");
end
