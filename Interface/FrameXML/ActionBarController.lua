
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
	
	--MainBar Only
	
	--Shapeshift/Stance Only
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");
	self:RegisterEvent("UPDATE_SHAPESHIFT_USABLE");
	self:RegisterEvent("UPDATE_INVENTORY_ALERTS");	-- Wha?? Still Wha...

	-- MultiBarBottomLeft
	self:RegisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT");
	
	-- Misc
	
	CURRENT_ACTION_BAR_STATE = LE_ACTIONBAR_STATE_MAIN;
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
		SHOW_MULTI_ACTIONBAR_1 = true;
		InterfaceOptionsActionBarsPanelBottomLeft.value = nil;
		MultiActionBar_Update();
		UIParent_ManageFramePositions();
	end
	
	if ( event == "PET_BATTLE_CLOSE" ) then
		ValidateActionBarTransition();
	end
end


function ActionBarController_UpdateAll(force)
	StanceBar_Update();
	CURRENT_ACTION_BAR_STATE = LE_ACTIONBAR_STATE_MAIN;

	-- If we have a non-skinned override bar of some sort, use the MainMenuBarArtFrame
	if ( HasBonusActionBar() or HasTempShapeshiftActionBar() ) then
		if (HasTempShapeshiftActionBar()) then
			MainMenuBarArtFrame:SetAttribute("actionpage", GetTempShapeshiftBarIndex());
		elseif (HasBonusActionBar() and GetActionBarPage() == 1) then
			MainMenuBarArtFrame:SetAttribute("actionpage", GetBonusBarIndex());
		else
			MainMenuBarArtFrame:SetAttribute("actionpage", GetActionBarPage());
		end
		
		for k, frame in pairs(ActionBarButtonEventsFrame.frames) do
			ActionButton_UpdateAction(frame, force);
		end
	else
		-- Otherwise, display the normal action bar
		ActionBarController_ResetToDefault(force);
	end
	
	ValidateActionBarTransition();
end



function ActionBarController_ResetToDefault(force)
	MainMenuBarArtFrame:SetAttribute("actionpage", GetActionBarPage());
	for k, frame in pairs(ActionBarButtonEventsFrame.frames) do
		ActionButton_UpdateAction(frame, force);
	end
end


----------------------------------------------------
----------------- Animation Code -------------------
----------------------------------------------------

function ActionBarBusy()
	return MainMenuBar.slideOut:IsPlaying();
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
		if not MainMenuBar:IsShown() then
			BeginActionBarTransition(MainMenuBar, 1);
			if ( SHOW_MULTI_ACTIONBAR_3 ) then
			BeginActionBarTransition(MultiBarRight, 1);
		end
			if ( SHOW_MULTI_ACTIONBAR_4 ) then
				BeginActionBarTransition(MultiBarLeft, 1);
			end
		end
	elseif CURRENT_ACTION_BAR_STATE == LE_ACTIONBAR_STATE_OVERRIDE then
		if MainMenuBar:IsShown() then
			BeginActionBarTransition(MainMenuBar, nil);
			if ( SHOW_MULTI_ACTIONBAR_3 ) then
			BeginActionBarTransition(MultiBarRight, nil);
			end
			if ( SHOW_MULTI_ACTIONBAR_4 ) then
				BeginActionBarTransition(MultiBarLeft, nil);
			end
		elseif not OverrideActionBar:IsShown() then
			BeginActionBarTransition(OverrideActionBar, 1);
		end
	end
end
