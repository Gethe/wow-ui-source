
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
		if ( HasExtraActionBar() ) then
			ExtraActionBarFrame:Show();
			ExtraActionBarFrame.outro:Stop();
			ExtraActionBarFrame.intro:Play();
		elseif( ExtraActionBarFrame:IsShown() ) then
			ExtraActionBarFrame.intro:Stop();
			ExtraActionBarFrame.outro:Play();
		end
	end
end


function ActionBarController_UpdateAll()
	PossessBar_Update();
	StanceBar_Update();
	CURRENT_ACTION_BAR_STATE = LE_ACTIONBAR_STATE_MAIN;
	
	-- If we have a skinned vehicle bar or skinned override bar, display the OverrideActionBar
	if ((HasVehicleActionBar() and UnitVehicleSkin("player") and UnitVehicleSkin("player") ~= "")
	or (HasOverrideActionBar() and GetOverrideBarSkin() and GetOverrideBarSkin() ~= "")) then
		-- For now, a vehicle has precedence over override bars (hopefully designers make it so these never conflict)
		if (HasVehicleActionBar()) then
			OverrideActionBar_Setup(UnitVehicleSkin("player"), GetVehicleBarIndex());
		else
			OverrideActionBar_Setup(GetOverrideBarSkin(), GetOverrideBarIndex());
		end
		
		CURRENT_ACTION_BAR_STATE = LE_ACTIONBAR_STATE_OVERRIDE;
	-- If we have a non-skinned override bar of some sort, use the MainMenuBarArtFrame
	elseif ( HasBonusActionBar() or HasOverrideActionBar() or HasVehicleActionBar() or HasTempShapeshiftActionBar() or C_PetBattles.IsInBattle() ) then
		if (HasVehicleActionBar()) then
			MainMenuBarArtFrame:SetAttribute("actionpage", GetVehicleBarIndex());
		elseif (HasOverrideActionBar()) then
			MainMenuBarArtFrame:SetAttribute("actionpage", GetOverrideBarIndex());
		elseif (HasTempShapeshiftActionBar()) then
			MainMenuBarArtFrame:SetAttribute("actionpage", GetTempShapeshiftBarIndex());
		elseif (HasBonusActionBar() and GetActionBarPage() == 1) then
			MainMenuBarArtFrame:SetAttribute("actionpage", GetBonusBarIndex());
		else
			MainMenuBarArtFrame:SetAttribute("actionpage", GetActionBarPage());
		end
		
		for i=1, NUM_ACTIONBAR_BUTTONS do
			local button = _G["ActionButton"..i];
			ActionButton_UpdateAction(button);
		end
	else
		-- Otherwise, display the normal action bar
		ActionBarController_ResetToDefault();
	end
	
	ValidateActionBarTransition();
end



function ActionBarController_ResetToDefault()
	MainMenuBarArtFrame:SetAttribute("actionpage", GetActionBarPage());
	for i=1, NUM_ACTIONBAR_BUTTONS do
		local button = _G["ActionButton"..i];
		ActionButton_UpdateAction(button);
	end
end


----------------------------------------------------
----------------- Animation Code -------------------
----------------------------------------------------




function BeginActionBarTransition(bar, animIn)
	bar:Show();
	bar.hideOnFinish = not animIn;
	bar.slideOut:Play(animIn);
end


function ValidateActionBarTransition()
	if MainMenuBar.slideOut:IsPlaying() or OverrideActionBar.slideOut:IsPlaying() or C_PetBattles.IsInBattle() then
		return; --Don't evluate and action bar state durring animations or while in Pet Battles
	end
	
	MultiActionBar_Update();
	UIParent_ManageFramePositions();
	
	if CURRENT_ACTION_BAR_STATE == LE_ACTIONBAR_STATE_MAIN then
		if OverrideActionBar:IsShown() then
			BeginActionBarTransition(OverrideActionBar, nil);
		elseif not MainMenuBar:IsShown() then
			BeginActionBarTransition(MainMenuBar, 1);
			BeginActionBarTransition(MultiBarRight, 1);
		end
	elseif CURRENT_ACTION_BAR_STATE == LE_ACTIONBAR_STATE_OVERRIDE then
		if MainMenuBar:IsShown() then
			BeginActionBarTransition(MainMenuBar, nil);
			BeginActionBarTransition(MultiBarRight, nil);
		elseif not OverrideActionBar:IsShown() then
			BeginActionBarTransition(OverrideActionBar, 1);
		end
	end
end



