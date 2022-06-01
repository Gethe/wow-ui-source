-------------------------------------------------------
----------LFG Parent
-------------------------------------------------------
LFGParentFrameMixin = {};

function LFGParentFrameMixin:OnLoad()
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:UpdateEyePortrait();

	PanelTemplates_SetNumTabs(self, 2);
	LFGParentFrame.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
end

function LFGParentFrameMixin:OnEvent(event, ...)
	if (event == "PLAYER_LEVEL_UP") then
		C_LFGList.RequestAvailableActivities();
	elseif (event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then
		self:UpdateEyePortrait();
	end
end

function LFGParentFrameMixin:UpdateEyePortrait()
	if (C_LFGList.HasActiveEntryInfo()) then
		EyeTemplate_StartAnimating(LFGParentFramePortrait);
	else
		EyeTemplate_StopAnimating(LFGParentFramePortrait);
	end
end

function ToggleLFGParentFrame(tab)
	local hideLFGParent = false;
	if ((not C_LFGList.IsLookingForGroupEnabled()) or
		(LFGParentFrame:IsShown() and tab == LFGParentFrame.selectedTab and LFGParentFrameTab1:IsShown()) or
		(LFGParentFrame:IsShown() and not tab)
	) then
		hideLFGParent = true;
	end

	if ( hideLFGParent ) then
		HideUIPanel(LFGParentFrame);
	else
		ShowUIPanel(LFGParentFrame);
		-- Decide which subframe to show
		local tabToShow = tab or LFGParentFrame.selectedTab;
		if (tabToShow == 2) then
			LFGParentFrameTab2_OnClick();
		else -- Default to tab 1.
			LFGParentFrameTab1_OnClick();
		end
	end
	UpdateMicroButtons();
end

function LFGParentFrameTab1_OnClick()
	PanelTemplates_SetTab(LFGParentFrame, 1);
	LFGFrame:Show();
	LFMFrame:Hide();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function LFGParentFrameTab2_OnClick()
	PanelTemplates_SetTab(LFGParentFrame, 2);
	LFGFrame:Hide();
	LFMFrame:Show();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function LFGParentFrame_LFMSearchActiveEntry()
	PanelTemplates_SetTab(LFGParentFrame, 2);
	LFGFrame:Hide();
	LFMFrame:Show();
	LFMFrame:SearchActiveEntry();
end
