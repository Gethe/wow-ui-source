
local CURRENT_ACTION_BAR_STATE

function ActionBarController_GetCurrentActionBarState()
	return CURRENT_ACTION_BAR_STATE;
end

function ActionBarController_OnLoad(self)

	--ManyBars
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	
	-- This is used for shapeshifts/stances
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	
	--Vehicle Only
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	
	--MainBar Only

	--Alternate Only
	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");
	self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
	
	--Shapeshift/Stance Only
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");
	self:RegisterEvent("UPDATE_SHAPESHIFT_USABLE");
	self:RegisterEvent("UPDATE_INVENTORY_ALERTS");	-- Wha?? Still Wha...
	
	-- Possess Bar
	self:RegisterEvent("UPDATE_POSSESS_BAR");
	
	--Extra Actionbar Only
	self:RegisterEvent("UPDATE_EXTRA_ACTIONBAR");

	-- MultiBarBottomLeft
	self:RegisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT");
	
	-- Misc
	self:RegisterEvent("PET_BATTLE_CLOSE");
	
	self:RegisterEvent("SETTINGS_LOADED");

	CURRENT_ACTION_BAR_STATE = LE_ACTIONBAR_STATE_MAIN;
	
	-- hack to fix crasy animation on bars when action bar is also animating
	StatusTrackingBarManager:SetBarAnimation(ActionBarBusy);

	MainMenuMicroButton_Init();
end


function ActionBarController_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		ActionBarController_UpdateAll();
	end
	
	
	if (   event == "UPDATE_BONUS_ACTIONBAR" 
		or event == "UPDATE_VEHICLE_ACTIONBAR" 
		or event == "UPDATE_OVERRIDE_ACTIONBAR"
		or event == "ACTIONBAR_PAGE_CHANGED" ) then
		ActionBarController_UpdateAll();
	end
	
	if ( event == "UPDATE_BONUS_ACTIONBAR" ) then
		IconIntroTracker:ResetAll();
	end
	
	if ( event == "UNIT_DISPLAYPOWER" ) then
		UnitFrameManaBar_Update(OverrideActionBarPowerBar, "vehicle");
	end
	
	--shapeshift
	if (   event == "UPDATE_SHAPESHIFT_FORM" 
		or event == "UPDATE_SHAPESHIFT_FORMS" 
		or event == "UPDATE_SHAPESHIFT_USABLE" ) then
		StanceBar_Update();
	end
	
	--possess
	if ( event == "UPDATE_POSSESS_BAR" ) then
		PossessBar_Update();
		StanceBar_Update();
	end
	
	--Extra Action Bar
	if ( event == "UPDATE_EXTRA_ACTIONBAR" ) then
		ExtraActionBar_Update();
	end

	-- MultiBarBottomLeft
	if ( event == "ACTIONBAR_SHOW_BOTTOMLEFT") then
		Settings.SetValue("PROXY_SHOW_MULTI_ACTIONBAR_1", true);
	end
	
	if ( event == "PET_BATTLE_CLOSE" ) then
		ValidateActionBarTransition();
	end

	if event == "SETTINGS_LOADED" then
		local variables =
		{
			"PROXY_SHOW_MULTI_ACTIONBAR_1",
			"PROXY_SHOW_MULTI_ACTIONBAR_2",
			"PROXY_SHOW_MULTI_ACTIONBAR_3",
			"PROXY_SHOW_MULTI_ACTIONBAR_4",
		};

		local function UpdateActionBar()
			MultiActionBar_Update();
			StatusTrackingBarManager:UpdateBarTicks();
		end
		
		for index, variable in ipairs(variables) do
			Settings.SetOnValueChangedCallback(variable, UpdateActionBar);
		end

		UpdateActionBar();
	end
end

function ActionBarController_UpdateAll(force)
	PossessBar_Update();
	StanceBar_Update();
	CURRENT_ACTION_BAR_STATE = LE_ACTIONBAR_STATE_MAIN;
	
	-- If we have a skinned vehicle bar or skinned override bar, display the OverrideActionBar
	if ((HasVehicleActionBar() and UnitVehicleSkin("player") and UnitVehicleSkin("player") ~= "")
	or (HasOverrideActionBar() and GetOverrideBarSkin() and GetOverrideBarSkin() ~= 0)) then
		OverrideActionBar_UpdateSkin();
		CURRENT_ACTION_BAR_STATE = LE_ACTIONBAR_STATE_OVERRIDE;
	-- If we have a non-skinned override bar of some sort, use the MainMenuBar
	elseif ( HasBonusActionBar() or HasOverrideActionBar() or HasVehicleActionBar() or HasTempShapeshiftActionBar() or C_PetBattles.IsInBattle() ) then
		if (HasVehicleActionBar()) then
			MainMenuBar:SetAttribute("actionpage", GetVehicleBarIndex());
		elseif (HasOverrideActionBar()) then
			MainMenuBar:SetAttribute("actionpage", GetOverrideBarIndex());
		elseif (HasTempShapeshiftActionBar()) then
			MainMenuBar:SetAttribute("actionpage", GetTempShapeshiftBarIndex());
		elseif (HasBonusActionBar() and GetActionBarPage() == 1) then
			MainMenuBar:SetAttribute("actionpage", GetBonusBarIndex());
		else
			MainMenuBar:SetAttribute("actionpage", GetActionBarPage());
		end
		
		for k, frame in pairs(ActionBarButtonEventsFrame.frames) do
			frame:UpdateAction(force);
		end
	else
		-- Otherwise, display the normal action bar
		ActionBarController_ResetToDefault(force);
	end
	
	ValidateActionBarTransition();
end

function ActionBarController_ResetToDefault(force)
	MainMenuBar:SetAttribute("actionpage", GetActionBarPage());
	for k, frame in pairs(ActionBarButtonEventsFrame.frames) do
		frame:UpdateAction(force);
	end
end

----------------------------------------------------
----------------- Animation Code -------------------
----------------------------------------------------

function ActionBarBusy()
	return MainMenuBar.slideOut:IsPlaying() or OverrideActionBar.slideOut:IsPlaying() or C_PetBattles.IsInBattle();
end

function BeginActionBarTransition(bar, animIn)
	bar:Show();
	bar.hideOnFinish = not animIn;
	bar.slideOut:Play(animIn);
end

function ValidateActionBarTransition()
	if ActionBarBusy() then
		return; --Don't evluate and action bar state durring animations or while in Pet Battles
	end

	MultiActionBar_Update();
	UIParent_ManageFramePositions();

	if CURRENT_ACTION_BAR_STATE == LE_ACTIONBAR_STATE_MAIN then
		if OverrideActionBar:IsShown() then
			BeginActionBarTransition(OverrideActionBar, nil);
		elseif not MainMenuBar:IsShown() then
			BeginActionBarTransition(MainMenuBar, 1);
			if MultiBar3_IsVisible() and MultiBarRight:IsCurrentlyRightAnchored() then
				BeginActionBarTransition(MultiBarRight, 1);
			end
			if MultiBar4_IsVisible() and MultiBarLeft:IsCurrentlyRightAnchored() then
				BeginActionBarTransition(MultiBarLeft, 1);
			end
		end
	elseif CURRENT_ACTION_BAR_STATE == LE_ACTIONBAR_STATE_OVERRIDE then
		if MainMenuBar:IsShown() then
			BeginActionBarTransition(MainMenuBar, nil);
			if MultiBar3_IsVisible() and MultiBarRight:IsCurrentlyRightAnchored()  then
				BeginActionBarTransition(MultiBarRight, nil);
			end
			if MultiBar4_IsVisible() and MultiBarLeft:IsCurrentlyRightAnchored() then
				BeginActionBarTransition(MultiBarLeft, nil);
			end
		elseif not OverrideActionBar:IsShown() then
			BeginActionBarTransition(OverrideActionBar, 1);
		end
	end
end
