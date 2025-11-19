
local function ShouldUseMainMenuBarAsEndCaps(actionBar)
	return actionBar:IsInDefaultPosition()
		and actionBar:IsSystemSettingDefault(Enum.EditModeActionBarSetting.Orientation)
		and actionBar:IsSystemSettingDefault(Enum.EditModeActionBarSetting.NumRows)
		and actionBar:IsSystemSettingDefault(Enum.EditModeActionBarSetting.NumIcons)
		and actionBar:IsSystemSettingDefault(Enum.EditModeActionBarSetting.IconSize)
		and actionBar:IsSystemSettingDefault(Enum.EditModeActionBarSetting.IconPadding)
		and actionBar:IsSystemSettingDefault(Enum.EditModeActionBarSetting.HideBarScrolling);
end

local function ShouldUseDistantEndCapAnchors(actionBar)
	return actionBar:GetSettingValue(Enum.EditModeActionBarSetting.Orientation) == Enum.ActionBarOrientation.Vertical
		or actionBar:GetSettingValue(Enum.EditModeActionBarSetting.NumRows) > 1;
end

function MainActionBarMixin:UpdateEndCaps(overrideHideEndCaps)
	local useMainMenuBarAsEndCaps = ShouldUseMainMenuBarAsEndCaps(self);

	-- Visibility
	if (overrideHideEndCaps) then
		MainMenuBar:SetShown(false);
		self.EndCaps:SetShown(false);
	else
		-- In Classic, if the MainActionBar is in the default position, size, etc.
		--   then we use the MainMenuBar (the large bar at the bottom) as our "end caps".
		-- If our MainActionBar has been adjusted in a significant way (e.g., moved, resized, etc.)
		--   then we do use more "compact" end caps, which are just the Gryphons.

		MainMenuBar:SetShown(useMainMenuBarAsEndCaps);
		self.EndCaps:SetShown(not useMainMenuBarAsEndCaps);
	end

	-- Positioning
	if (ShouldUseDistantEndCapAnchors(self)) then
		self.EndCaps.LeftEndCap:SetPoint("BOTTOMRIGHT", self.EndCaps, "BOTTOMLEFT", 0, -3);
		self.EndCaps.RightEndCap:SetPoint("BOTTOMLEFT", self.EndCaps, "BOTTOMRIGHT", -1, -3);
	else
		self.EndCaps.LeftEndCap:SetPoint("BOTTOMRIGHT", self.EndCaps, "BOTTOMLEFT", 28, -3);
		self.EndCaps.RightEndCap:SetPoint("BOTTOMLEFT", self.EndCaps, "BOTTOMRIGHT", -29, -3);
	end

	-- Action Bar Page Number and Buttons
	if (useMainMenuBarAsEndCaps) then
		-- For the Main Menu Bar, use the blocky "Classic" style.
		self.ActionBarPageNumber.Text:SetPoint("CENTER", 15, 0);
		self.ActionBarPageNumber.UpButton:SwapToDefaultAtlas();
		self.ActionBarPageNumber.DownButton:SwapToDefaultAtlas();
	else
		-- When we're not using the Main Menu Bar, use the sleek "Modern" style.
		self.ActionBarPageNumber.Text:SetPoint("CENTER", -7, 0);
		self.ActionBarPageNumber.UpButton:SwapToAlternateAtlas();
		self.ActionBarPageNumber.DownButton:SwapToAlternateAtlas();
	end
end
