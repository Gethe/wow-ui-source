RegisterGameMenuEscHandler(GameMenuEscPriority.Menu, function()
	return Menu.GetManager():HandleESC();
end);


RegisterGameMenuEscHandler(GameMenuEscPriority.Casting, function()
	if SpellStopCasting() or SpellStopTargeting() then
		return true;
	end

	return false;
end);

-- Transitions ESC from world-style interaction into cursor/UI interaction.
local function TryHandleFrameworkPreEsc()
	if not CanAutoSetGamePadCursorControl(true) or IsModifierKeyDown() then
		return false;
	end

	if not (ClearTarget() and not UnitIsCharmed("player")) then
		SetGamePadCursorControl(true);
	end

	return true;
end

RegisterGameMenuEscHandler(GameMenuEscPriority.FrameworkPre, TryHandleFrameworkPreEsc);

RegisterGameMenuEscHandler(GameMenuEscPriority.Framework, function()
	if UIParent:IsShown() then
		return false;
	end

	UIParent:Show();
	SetUIVisibility(true);
	return true;
end);


-- Final fallback that returns ESC handling to world-style interaction.
local function TryHandleWorldEsc()
	if CanAutoSetGamePadCursorControl(false) and not IsModifierKeyDown() then
		SetGamePadCursorControl(false);
		return true;
	end

		return false;
end

RegisterGameMenuEscHandler(GameMenuEscPriority.World, TryHandleWorldEsc);

-- Legacy menus are retained for user addons, but should be avoided by everyone
-- in favor of the new menu system.
UIMenus = {
	"DropDownList1",
	"DropDownList2",
};

local function SecureCloseMenus()
	for index, value in pairs(UIMenus) do
		local menu = _G[value];
		if ( menu and menu:IsShown() ) then
			menu:Hide();
		end
	end
end

function CloseMenus()
	securecallfunction(SecureCloseMenus);
end

RegisterGameMenuEscHandler(GameMenuEscPriority.Menu, SecureCloseMenus);

function ToggleGroupFinderFrame(sidePanelName, selection)
	local style = C_LFGList.GetPremadeGroupFinderStyle();
	if style == Enum.PremadeGroupFinderStyle.Disabled then
		return;
	end

	if style == Enum.PremadeGroupFinderStyle.Vanilla then
		if not C_AddOns.IsAddOnLoaded("Blizzard_GroupFinder_VanillaStyle") then
			return;
		end

		LFGVanilla_ToggleFrame();
	else
		PVEFrame_ToggleFrame(sidePanelName, selection);
	end
end

EventRegistry:RegisterCallback("UI.TopLevelParentShown", function()
	CloseAllWindows();
end);
