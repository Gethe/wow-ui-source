---------------------------------------------------
----------Constants
-------------------------------------------------------
CVarCallbackRegistry:SetCVarCachable("disableSuggestedLevelActivityFilter");
LFGPARENT_LISTING_TAB_INDEX = 1;
LFGPARENT_BROWSING_TAB_INDEX = 2;

-------------------------------------------------------
----------LFG Parent
-------------------------------------------------------
LFGParentFrameMixin = {};

--[[
	Boolean flag that identifies this frame as having updated jump hints, no longer
	using legacy FrameControlsManager jump hints only displayed on targets.
	See FrameControlsManager:RefreshJumpHints
]]
LFGParentFrameMixin.useFooterJumpHints = true;

local LISTING_TAB_INDEX = 1;
local BROWSING_TAB_INDEX = 2;
local WHO_LIST_TAB_INDEX = 3;

local function LFGParentFrame_SetActiveTab(tabIndex)
	PanelTemplates_SetTab(LFGParentFrame, tabIndex);

	LFGListingFrame:SetShown(tabIndex == LISTING_TAB_INDEX);
	LFGBrowseFrame:SetShown(tabIndex == BROWSING_TAB_INDEX);
	LFGWhoListFrame:SetShown(tabIndex == WHO_LIST_TAB_INDEX);

	LFGParentFrame:UpdateTabs();
end

-- Text to display next to jump hints on other frames, if the jump takes them here
function LFGParentFrameMixin:GetJumpHintLabel()
	return LFG_TITLE;
end

function LFGParentFrameMixin:OnLoad()
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:UpdateEyePortrait();

	PanelTemplates_SetNumTabs(self, 2);
	LFGParentFrame.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
end

function LFGParentFrameMixin:OnShow()
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	self:UpdateTabs();

	local currentTabIndex = self.selectedTab or 1;
	LFGParentFrame_SetActiveTab(currentTabIndex)
end

function LFGParentFrameMixin:OnHide()
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
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
	if LFGVANILLA_SETTING_MODERN_STYLE then
		local currentTabIndex = self.selectedTab or 1;
		self.ListingTab:SetChecked(currentTabIndex == LISTING_TAB_INDEX);
		self.BrowsingTab:SetChecked(currentTabIndex == BROWSING_TAB_INDEX);
		self.WhoListingTab:SetChecked(currentTabIndex == WHO_LIST_TAB_INDEX);
		self.Tab1:Hide();
		self.Tab2:Hide();
		self.Tab3:Hide();		
	end

	if (C_LFGList.HasActiveEntryInfo()) then
		self.Tab1:SetText(LFG_LIST_EDIT);
	else
		self.Tab1:SetText(LFG_LIST_TAB_1);
	end
	PanelTemplates_TabResize(self.Tab1, 0);
end

function LFGParentFrameMixin:UpdateEyePortrait()
	if (C_LFGList.HasActiveEntryInfo()) then
		LFGParentFramePortrait:StartAnimating();
	else
		LFGParentFramePortrait:StopAnimating();
	end
end


LFGParentFrameRightTabMixin = CreateFromMixins(SidePanelTabButtonMixin);
function LFGParentFrameRightTabMixin:OnLoad()
	SidePanelTabButtonMixin.OnLoad(self);

	self.Icon:SetTexture(self.iconTexture);
	self.Icon:SetSize(30, 30);
	self.Icon:SetTexCoord(0.03125, 0.96875, 0.03125, 0.96875);

	self:SetCustomOnMouseUpHandler(function(tab, button, upInside)
		if button == "LeftButton" and upInside then
			LFGParentFrame_SetActiveTab(tab:GetID());
		end
	end);
end



function LFGVanilla_ShowFrame(tab)
	ShowUIPanel(LFGParentFrame);
	-- Decide which subframe to show
	local tabToShow = tab or LFGParentFrame.selectedTab;
	if (tabToShow == 3) then
		LFGParentFrameTab3_OnClick();
	elseif (tabToShow == 2) then
		LFGParentFrameTab2_OnClick();
	else -- Default to tab 1.
		LFGParentFrameTab1_OnClick();
	end

	UpdateMicroButtons();
end

function LFGVanilla_ToggleFrame(tab)
	local hideLFGParent = false;

	local LFGParentShown = LFGParentFrame:IsShown();
	local isCurrentTab = tab == LFGParentFrame.selectedTab;

	local tab1Shown = LFGListingFrame:IsShown();
	local tab2Shown = LFGBrowseFrame:IsShown();
	local tab3Shown = LFGWhoListFrame:IsShown();

	local hideTab1 = LFGParentShown and isCurrentTab and tab1Shown;
	local hideTab2 = LFGParentShown and isCurrentTab and tab2Shown;
	local hideTab3 = LFGParentShown and isCurrentTab and tab3Shown;

	if ((C_LFGList.GetPremadeGroupFinderStyle() ~= Enum.PremadeGroupFinderStyle.Vanilla) or
		(not C_LFGInfo.CanPlayerUsePremadeGroup()) or
		(hideTab1) or (hideTab2) or (hideTab3) or
		(LFGParentFrame:IsShown() and not tab)
	) then
		hideLFGParent = true;
	end

	if ( hideLFGParent ) then
		HideUIPanel(LFGParentFrame);
		UpdateMicroButtons();
	else
		LFGVanilla_ShowFrame(tab);
	end
end

function LFGParentFrameTab1_OnClick()
	LFGParentFrame_SetActiveTab(1);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function LFGParentFrameTab2_OnClick()
	LFGParentFrame_SetActiveTab(2);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function LFGParentFrameTab3_OnClick()
	LFGParentFrame_SetActiveTab(3);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function LFGParentFrame_SearchActiveEntry()
	LFGBrowseFrame:SearchActiveEntry();
	LFGParentFrame_SetActiveTab(2);
end

-------------------------------------------------------
----------Util
-------------------------------------------------------
function LFGUtil_SortActivityIDs(activityIDList)
	local function SortCB(activityID1, activityID2)
		local activityInfo1 = C_LFGList.GetActivityInfoTable(activityID1);
		local activityInfo2 = C_LFGList.GetActivityInfoTable(activityID2);

		if (activityInfo1.orderIndex ~= activityInfo2.orderIndex) then
			return activityInfo1.orderIndex < activityInfo2.orderIndex;
		end

		local name1 = LFGUtil_GetActivityInfoName(activityInfo1);
		local name2 = LFGUtil_GetActivityInfoName(activityInfo2);
		if (name1 ~= name2) then
			return strcmputf8i(name1, name2) < 0;
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

function LFGUtil_GetFilteredActivities(categoryID, activityGroupID)
	local activities = C_LFGList.GetAvailableActivities(categoryID, activityGroupID);

	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();

	local disableSuggestedLevelActivityFilter = CVarCallbackRegistry:GetCVarValueBool("disableSuggestedLevelActivityFilter");
	if (not disableSuggestedLevelActivityFilter) then
		local playerLevel = UnitLevel("player");
		for i=#activities, 1, -1 do
			local activityID = activities[i];
			-- Only filter out activities that are not part of the active entry.
			if (not (activeEntryInfo and tContains(activeEntryInfo.activityIDs, activityID))) then
				local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
				if ((activityInfo.minLevelSuggestion > 0 and activityInfo.minLevelSuggestion > playerLevel)
					or (activityInfo.maxLevelSuggestion > 0 and activityInfo.maxLevelSuggestion < playerLevel)) then
					tremove(activities, i);
				end
			end
		end
	end

	return activities;
end

function LFGUtil_GetActivityInfoName(activityInfo)
	-- For consistency, prefer the short name.
	return activityInfo.shortName ~= "" and activityInfo.shortName or activityInfo.fullName;
end

-------------------------------------------------------
----------Options Button Template
-------------------------------------------------------
LFGOptionsButton = { };

function LFGOptionsButton:OnEnter()
	self.Icon:SetAlpha(1.0);
end

function LFGOptionsButton:OnLeave()
	self.Icon:SetAlpha(0.8);
end

function LFGOptionsButton:OnMouseDown()
	self.Icon:AdjustPointsOffset(1, -1);
end

function LFGOptionsButton:OnMouseUp()
	self.Icon:AdjustPointsOffset(-1, 1);
end
