---------------------------------------------------
----------Constants
-------------------------------------------------------


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
		self:UpdateTabs();
		self:UpdateEyePortrait();
	end
end

function LFGParentFrameMixin:UpdateTabs()
	if (C_LFGList.HasActiveEntryInfo()) then
		self.Tab1:SetText(LFG_LIST_EDIT);
	else
		self.Tab1:SetText(LFG_LIST_TAB_1);
	end
	PanelTemplates_TabResize(self.Tab1, 0);
end

function LFGParentFrameMixin:UpdateEyePortrait()
	if (C_LFGList.HasActiveEntryInfo()) then
		EyeTemplate_StartAnimating(LFGParentFramePortrait);
	else
		EyeTemplate_StopAnimating(LFGParentFramePortrait);
	end
end

function ShowLFGParentFrame(tab)
	ShowUIPanel(LFGParentFrame);
	-- Decide which subframe to show
	local tabToShow = tab or LFGParentFrame.selectedTab;
	if (tabToShow == 2) then
		LFGParentFrameTab2_OnClick();
	else -- Default to tab 1.
		LFGParentFrameTab1_OnClick();
	end

	UpdateMicroButtons();
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
		UpdateMicroButtons();
	else
		ShowLFGParentFrame(tab);
	end
end

function LFGParentFrameTab1_OnClick()
	PanelTemplates_SetTab(LFGParentFrame, 1);
	LFGListingFrame:Show();
	LFGBrowseFrame:Hide();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function LFGParentFrameTab2_OnClick()
	PanelTemplates_SetTab(LFGParentFrame, 2);
	LFGListingFrame:Hide();
	LFGBrowseFrame:Show();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function LFGParentFrame_SearchActiveEntry()
	LFGBrowseFrame:SearchActiveEntry();
	PanelTemplates_SetTab(LFGParentFrame, 2);
	LFGListingFrame:Hide();
	LFGBrowseFrame:Show();
end

-------------------------------------------------------
----------Util
-------------------------------------------------------
function LFGUtil_SortActivityIDs(activityIDList, useFullName)
	local function SortCB(activityID1, activityID2)
		local activityInfo1 = C_LFGList.GetActivityInfoTable(activityID1);
		local activityInfo2 = C_LFGList.GetActivityInfoTable(activityID2);

		if (activityInfo1.orderIndex ~= activityInfo2.orderIndex) then
			return activityInfo1.orderIndex < activityInfo2.orderIndex;
		end

		if (useFullName) then
			if (activityInfo1.fullName ~= activityInfo2.fullName) then
				return strcmputf8i(activityInfo1.fullName, activityInfo2.fullName) < 0;
			end
		else
			if (activityInfo1.shortName ~= activityInfo2.shortName) then
				return strcmputf8i(activityInfo1.shortName, activityInfo2.shortName) < 0;
			end
		end

		return activityID1 < activityID2;
	end

	table.sort(activityIDList, SortCB);
end

function LFGUtil_SortActivityGroupIDs(activityGroupIDList)
	local function SortCB(activityGroupID1, activityGroupID2)
		local name1, orderIndex1 = C_LFGList.GetActivityGroupInfo(activityGroupID1);
		local name2, orderIndex2 = C_LFGList.GetActivityGroupInfo(activityGroupID2);

		if (orderIndex1 and orderIndex2 and orderIndex1 ~= orderIndex2) then
			return orderIndex1 < orderIndex2;
		end

		if (name1 and name2 and name1 ~= name2) then
			return strcmputf8i(name1, name2) < 0;
		end

		return activityGroupID1 < activityGroupID2;
	end

	table.sort(activityGroupIDList, SortCB);
end

local ACTIVITY_ACTIVITYGROUP_CACHE = {};
function LFGUtil_GetActivityGroupForActivity(activityID)
	if (not ACTIVITY_ACTIVITYGROUP_CACHE[activityID]) then
		local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
		if (activityInfo) then
			ACTIVITY_ACTIVITYGROUP_CACHE[activityID] = activityInfo.groupFinderActivityGroupID;
		end
	end
		
	return ACTIVITY_ACTIVITYGROUP_CACHE[activityID];
end

function LFGUtil_OrganizeActivitiesByActivityGroup(activities)
	local organizedActivities = {};
	for i, activityID in ipairs(activities) do
		local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
		if (activityInfo) then
			if (not organizedActivities[activityInfo.groupFinderActivityGroupID]) then
				organizedActivities[activityInfo.groupFinderActivityGroupID] = {};
			end
			tinsert(organizedActivities[activityInfo.groupFinderActivityGroupID], activityID);
		end
	end

	for activityGroupID, activityIDs in pairs(organizedActivities) do
		LFGUtil_SortActivityIDs(activityIDs);
	end

	return organizedActivities;
end

-------------------------------------------------------
----------Drop-Down QoL
-------------------------------------------------------
function LFGDropDown_OnEnter(self)
	self.Button:LockHighlight();
end

function LFGDropDown_OnLeave(self)
	self.Button:UnlockHighlight();
end

function LFGDropDown_OnClick(self)
	ToggleDropDownMenu(nil, nil, self);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end