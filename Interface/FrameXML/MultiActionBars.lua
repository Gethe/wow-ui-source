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
		button:UpdateState();
	end
end

function MultiActionButtonUp (bar, id)
	local button = _G[bar.."Button"..id];
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		if(not GetCVarBool("ActionButtonUseKeyDown")) then
			SecureActionButton_OnClick(button, "LeftButton");
			button:UpdateState();
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

local function UpdateMainMenuBar(rightBarShowing)
	MainMenuBar:ChangeMenuBarSizeAndPosition(rightBarShowing);
	StatusTrackingBarManager:UpdateBarsShown();
end

function MultiActionBar_OnLoad(self)
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
end

function MultiActionBar_OnEvent(self, event, ...)
	if IsPlayerInWorld() then
		MultiActionBar_Update();
	end
end

function MultiActionBar_Update ()
	local showLeft = false;
	local showRight = false;
	
	UpdateMultiActionBar(MultiBarBottomLeft, SHOW_MULTI_ACTIONBAR_1, BOTTOMLEFT_ACTIONBAR_PAGE);
	UpdateMultiActionBar(MultiBarBottomRight, SHOW_MULTI_ACTIONBAR_2, BOTTOMRIGHT_ACTIONBAR_PAGE, UpdateMainMenuBar);
	UpdateMultiActionBar(MultiBarRight, SHOW_MULTI_ACTIONBAR_3, RIGHT_ACTIONBAR_PAGE, function(var) showRight = var; end);
	UpdateMultiActionBar(MultiBarLeft, SHOW_MULTI_ACTIONBAR_3 and SHOW_MULTI_ACTIONBAR_4, LEFT_ACTIONBAR_PAGE, function(var) showLeft = var; end);

	if ( showRight ) then
		local topLimit = MinimapCluster:GetBottom() - 10;	-- increasing by 14 here because we can overlap since the cluster is bigger than the elements it contains
		local bottomLimit = MicroButtonAndBagsBar:GetTop() + 24;

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
		VerticalMultiBarsContainer:SetSize(0, 0);
	end
	-- TODO: Evaluate how often we're doing multiple calls of UIParent_ManageFramePositions per frame
	UIParent_ManageFramePositions();
end

function MultiActionBar_ShowAllGrids (reason, force)
	MultiActionBar_UpdateGrid("MultiBarBottomLeft", true, reason, force);
	MultiActionBar_UpdateGrid("MultiBarBottomRight", true, reason, force);
	MultiActionBar_UpdateGrid("MultiBarRight", true, reason, force);
	MultiActionBar_UpdateGrid("MultiBarLeft", true, reason, force);
end

function MultiActionBar_HideAllGrids (reason)
	MultiActionBar_UpdateGrid("MultiBarBottomLeft", false, reason);
	MultiActionBar_UpdateGrid("MultiBarBottomRight", false, reason);
	MultiActionBar_UpdateGrid("MultiBarRight", false, reason);
	MultiActionBar_UpdateGrid("MultiBarLeft", false, reason);
end

function MultiActionBar_UpdateGrid (barName, show, reason, force)
	for i = 1, NUM_MULTIBAR_BUTTONS do
		local button = _G[barName.."Button"..i];
		if ( show and (force or not button.noGrid) ) then
			button:ShowGrid(reason);
		else
			button:HideGrid(reason);
		end
	end
end

function MultiActionBar_UpdateGridVisibility ()
	if ( ALWAYS_SHOW_MULTIBARS == "1" or ALWAYS_SHOW_MULTIBARS == 1 ) then
		MultiActionBar_ShowAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_CVAR);
	else
		MultiActionBar_HideAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_CVAR);
	end
end

function MultiActionBar_SetAllQuickKeybindModeEffectsShown(showEffects)
	MultiBarBottomLeft.QuickKeybindGlow:SetShown(showEffects);
	MultiBarBottomRight.QuickKeybindGlow:SetShown(showEffects);
	MultiBarLeft.QuickKeybindGlow:SetShown(showEffects);
	MultiBarRight.QuickKeybindGlow:SetShown(showEffects);
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
