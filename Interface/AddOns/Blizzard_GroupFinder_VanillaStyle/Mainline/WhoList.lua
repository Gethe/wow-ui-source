-------------------------------------------------------
----------Constants
-------------------------------------------------------
MAX_WHOS_FROM_SERVER = 50;
LFG_TAB_WHO = 3;

local whoSortValue = 1;

local WHO_SORT_NAME = "name";
local WHO_SORT_CLASS = "class";
local WHO_SORT_LEVEL = "level";
local WHO_SORT_ASCENDING = 1;
local WHO_SORT_DESCENDING = 2;


-------------------------------------------------------
----------LFGWhoListButtonMixin
-------------------------------------------------------
LFGWhoListButtonMixin = {};

function LFGWhoListButtonMixin:OnClick(button)
	if button == "LeftButton" then
		LFGWhoListFrame.selectedWho = self.index or nil;
	else
		local name = self.OriginalName or self.Name:GetText();
		FriendsFrame_ShowDropdown(name, 1);
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function LFGWhoListButtonMixin:OnEnter()
	if self.tooltip1 and self.tooltip2 and self.tooltip3 then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetText(self.tooltip1);
		GameTooltip:AddLine(self.tooltip2, 1, 1, 1);
		GameTooltip:AddLine(self.tooltip3, 1, 1, 1);
		GameTooltip:Show();
	end
end

function LFGWhoListButtonMixin:SetSelected(selected)
	if selected then
		self.Selected:Show();
	else
		self.Selected:Hide();
	end
end

function LFGWhoListButtonMixin:InitButton(elementData, selected)
	local index = elementData.index;
	local info = elementData.info;
	self.index = index;

	self:SetSelected(selected);

	local classTextColor;
	if info.filename then
		classTextColor = RAID_CLASS_COLORS[info.filename];
	else
		classTextColor = HIGHLIGHT_FONT_COLOR;
	end

	local name = info.fullName;
	if info.timerunningSeasonID then
		name = TimerunningUtil.AddTinyIcon(name);
		self.OriginalName = info.fullName;
	end

	self.Name:SetText(name);

	local levelText = LFG_WHO_LEVEL:format(info.level);
	self.Level:SetText(levelText);
	self.Race:SetText(info.raceStr);
	self.Class:SetText(info.classStr);
	self.Class:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);

	local variableColumnTable = { info.area, info.fullGuildName, info.raceStr };
	local variableText = variableColumnTable[whoSortValue];
	self.Variable:SetText(variableText);

	local fullGuildName = info.fullGuildName
	self.GuildName:SetText(fullGuildName);

	if self.Variable:IsTruncated() or self.Level:IsTruncated() or self.Name:IsTruncated() then
		self.tooltip1 = info.fullName;
		self.tooltip2 = WHO_LIST_LEVEL_TOOLTIP:format(info.level);
		self.tooltip3 = variableText;
	else
		self.tooltip1 = nil;
		self.tooltip2 = nil;
		self.tooltip3 = nil;
	end

	self.InviteButton.info = info;
end

-------------------------------------------------------
----------WhoInviteButtonMixin
-------------------------------------------------------
WhoInviteButtonMixin = {};

function WhoInviteButtonMixin:OnClick(button)
		local contextData =
		{
			name = self.info.fullName,
		};

	UnitPopupSharedUtil.TryInvite(contextData, "INVITE", self.info.fullName)

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function WhoInviteButtonMixin:OnEnter()
	self:ShowTooltip();
end

function WhoInviteButtonMixin:ShowTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, WHO_PARTY_BUTTON_TOOLTIP);
	GameTooltip:Show();
end

function WhoInviteButtonMixin:OnLeave()
	GameTooltip:Hide();
end

-------------------------------------------------------
----------WhoFrameEditBoxMixin
-------------------------------------------------------
WhoFrameEditBoxMixin = {};

function WhoFrameEditBoxMixin:OnLoad()
	self.searchIcon:SetAtlas("glues-characterSelect-icon-search", TextureKitConstants.IgnoreAtlasSize);

	self.Instructions:SetFontObject(self.instructionsFontObject);
	-- This text can be scaled so we try to fit all (or least most) of the text and then truncate + tooltip where necessary
	self.Instructions:SetMaxLines(2);
end

function WhoFrameEditBoxMixin:OnShow()
	EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", function()
		self:AdjustHeightToFitInstructions();
	end, self);

	self:AdjustHeightToFitInstructions();
	EditBox_ClearFocus(self);
end

function WhoFrameEditBoxMixin:AdjustHeightToFitInstructions()
	local linesShown = math.min(self.Instructions:GetNumLines(), self.Instructions:GetMaxLines());
	local totalInstructionHeight = linesShown * self.Instructions:GetLineHeight();
	local padding = 20;
	self:SetHeight(totalInstructionHeight + padding);
end

function WhoFrameEditBoxMixin:OnHide()
	EventRegistry:UnregisterCallback("TextSizeManager.OnTextScaleUpdated", self);
end

function WhoFrameEditBoxMixin:OnEnter()
	local isTruncated = self.Instructions:IsShown() and self.Instructions:IsTruncated();
	if not isTruncated then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, self.instructionText);
	GameTooltip:Show();
end

function WhoFrameEditBoxMixin:OnLeave()
	GameTooltip:Hide();
end

function WhoFrameEditBoxMixin:OnEnterPressed()
	C_FriendList.SendWho(self:GetText(), Enum.SocialWhoOrigin.Social, LFGWhoListFilterUtil.GetWhoFilters());
	self:ClearFocus();
end


-------------------------------------------------------
----------WhoSearchMixin
-------------------------------------------------------
WhoSearchMixin = {};
function WhoSearchMixin:OnClick()
	local searchText = LFGWhoListFrame.EditBox:GetText();
	C_FriendList.SendWho(searchText, Enum.SocialWhoOrigin.Social, LFGWhoListFilterUtil.GetWhoFilters());
	LFGWhoListFrame.EditBox:ClearFocus();
end

-------------------------------------------------------
----------LFGWhoListMixin
-------------------------------------------------------
LFGWhoListMixin = {};

function LFGWhoListMixin:OnLoad()
	self:RegisterEvent("WHO_LIST_UPDATE");

	if LFGVANILLA_SETTING_MODERN_STYLE then
		self.TitleContainer.TitleText:SetText(LFG_TITLE);
	end

	self:SetupScrollView();

	self:InitFilterMenu(self.FilterDropdown);
end

function LFGWhoListMixin:OnEvent(event, ...)
	if ( event == "WHO_LIST_UPDATE" ) then
		self:UpdateWhoList();
	end
end

function LFGWhoListMixin:SetupScrollView()
	local function InitializeWhoButton(frame, elementData)
		frame:SetScript("OnClick", function(button, buttonName)
			if buttonName == "LeftButton" then
				self.selectionBehavior:ToggleSelect(button);
			else
				local name = button.OriginalName or button.Name:GetText();
				FriendsFrame_ShowDropdown(name, 1);
			end
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		end);

		local selected = self.selectionBehavior:IsSelected(frame);
		frame:InitButton(elementData, selected);
	end

	-- Who list
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("LFGWhoListButtonTemplate", InitializeWhoButton);		

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local function OnSelectionChanged(o, elementData, selected)
		local button = self.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end
	end;

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);
end

function LFGWhoListMixin:OnShow()
	C_FriendList.SetWhoToUi(true);
end

function LFGWhoListMixin:OnHide()
	C_FriendList.SetWhoToUi(false);
end

function LFGWhoListMixin:UpdateWhoList()
	local numWhos, totalCount = C_FriendList.GetNumWhoResults();

	local displayedText = "";
	if ( totalCount > MAX_WHOS_FROM_SERVER ) then
		displayedText = format(WHO_FRAME_SHOWN_TEMPLATE, MAX_WHOS_FROM_SERVER);
	end
	self.WhoFrameTotals:SetText(format(WHO_FRAME_TOTAL_TEMPLATE, totalCount).."  "..displayedText);

	local dataProvider = CreateDataProvider();
	for index = 1, numWhos do
		local info = C_FriendList.GetWhoInfo(index);
		-- All scrollable text in the Who List uses font that can be resized by the player
		dataProvider:Insert({index=index, info=info, fontObject=UserScaledFontGameNormalSmall, });
	end
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	if not C_SocialUI.IsSystemEnabled() then
		PanelTemplates_SetTab(LFGParentFrame, 3);
		ShowUIPanel(LFGParentFrame);
	end
end

function LFGWhoListMixin:InitFilterMenu(dropdown, onUpdate, onDefault, ignoreSkillLine)
	LFGWhoListFilterUtil.ResetFilters();

	dropdown:SetupMenu(LFGWhoListFilterUtil.SetupFilterMenu);
end

LFGWhoListFilterUtil = {};

function LFGWhoListFilterUtil.ResetFilters()
	LFGWhoListFilterUtil.classesFiltered = {};
	LFGWhoListFilterUtil.racesFiltered = {};
	LFGWhoListFilterUtil.mapsIncluded = {};
	LFGWhoListFilterUtil.sortMode = WHO_SORT_NAME;
	LFGWhoListFilterUtil.sortOrder = WHO_SORT_ASCENDING;
	LFGWhoListFilterUtil.mapFiltersDefaulted = false;
end

function LFGWhoListFilterUtil.GetWhoFilters()
	local whoFilters = {};
	whoFilters.classIDs = {};
	whoFilters.raceIDs = {};
	whoFilters.uiMapIDs = {};

	for classID in pairs(LFGWhoListFilterUtil.classesFiltered) do
		tinsert(whoFilters.classIDs, classID);
	end

	for raceID in pairs(LFGWhoListFilterUtil.racesFiltered) do
		tinsert(whoFilters.raceIDs, raceID);
	end

	for mapID in pairs(LFGWhoListFilterUtil.mapsIncluded) do
		tinsert(whoFilters.uiMapIDs, mapID);
	end

	return whoFilters;
end

function LFGWhoListFilterUtil.SetupFilterMenu(dropdown, rootDescription)
	LFGWhoListFilterUtil.InitClassFilters(rootDescription);
	LFGWhoListFilterUtil.InitRaceFilters(rootDescription);
	LFGWhoListFilterUtil.InitMapFilters(rootDescription);
	LFGWhoListFilterUtil.InitSortOptions(rootDescription);
end

function LFGWhoListFilterUtil.InitClassFilters(rootDescription)
	local function IsClassChecked(classID)
		return not LFGWhoListFilterUtil.classesFiltered[classID];
	end

	local function SetClassChecked(classID)
		if LFGWhoListFilterUtil.classesFiltered[classID] then
			LFGWhoListFilterUtil.classesFiltered[classID] = nil;
		else
			LFGWhoListFilterUtil.classesFiltered[classID] = true;
		end
	end

	local classSubmenu = rootDescription:CreateButton(CLASS);
	classSubmenu:CreateButton(CHECK_ALL, LFGWhoListFilterUtil.SetAllClassesFiltered, false);
	classSubmenu:CreateButton(UNCHECK_ALL, LFGWhoListFilterUtil.SetAllClassesFiltered, true);

	for index = 1, GetNumClasses() do
		local classDisplayName, _, classID = GetClassInfo(index);
		if classID then
			classSubmenu:CreateCheckbox(classDisplayName, IsClassChecked, SetClassChecked, classID);
		end
	end
end

function LFGWhoListFilterUtil.SetAllClassesFiltered(filtered)
	for index = 1, GetNumClasses() do
		local _, _, classID = GetClassInfo(index);
		if classID then
			if filtered then
				LFGWhoListFilterUtil.classesFiltered[classID] = true;
			else
				LFGWhoListFilterUtil.classesFiltered[classID] = nil;
			end
		end
	end

	return MenuResponse.Refresh;
end

function LFGWhoListFilterUtil.InitRaceFilters(rootDescription)
	local function IsRaceChecked(classID)
		return not LFGWhoListFilterUtil.racesFiltered[classID];
	end

	local function SetRaceChecked(classID)
		if LFGWhoListFilterUtil.racesFiltered[classID] then
			LFGWhoListFilterUtil.racesFiltered[classID] = nil;
		else
			LFGWhoListFilterUtil.racesFiltered[classID] = true;
		end
	end

	local raceSubmenu = rootDescription:CreateButton(RACE);
	raceSubmenu:CreateButton(CHECK_ALL, LFGWhoListFilterUtil.SetAllRacesFiltered, false);
	raceSubmenu:CreateButton(UNCHECK_ALL, LFGWhoListFilterUtil.SetAllRacesFiltered, true);

	for index, raceFilter in ipairs(C_FriendList.GetWhoRaceFilters()) do
		raceSubmenu:CreateCheckbox(raceFilter.name, IsRaceChecked, SetRaceChecked, raceFilter.ID);
	end
end

function LFGWhoListFilterUtil.SetAllRacesFiltered(filtered)
	for index, raceFilter in ipairs(C_FriendList.GetWhoRaceFilters()) do
		if raceFilter and raceFilter.ID then
			if filtered then
				LFGWhoListFilterUtil.racesFiltered[raceFilter.ID] = true;
			else
				LFGWhoListFilterUtil.racesFiltered[raceFilter.ID] = nil;
			end
		end
	end

	return MenuResponse.Refresh;
end

function LFGWhoListFilterUtil.GetTopMostUIMapType()
	return Enum.UIMapType.World;
end

function LFGWhoListFilterUtil.GetTopMostMapID()
	local currentMapID = C_Map.GetBestMapForUnit("player") or C_Map.GetFallbackWorldMapID();
	local topMostMapInfo = MapUtil.GetMapParentInfo(currentMapID, LFGWhoListFilterUtil.GetTopMostUIMapType(), true);
	return topMostMapInfo and topMostMapInfo.mapID;
end

function LFGWhoListFilterUtil.MapHasSelectableChildren(mapID)
	local children = C_Map.GetMapChildrenInfo(mapID);
	if not children then
		return false;
	end

	for index, childMapInfo in ipairs(children) do
		if C_Map.IsMapValidForNavBarDropdown(childMapInfo.mapID) then
			return true;
		end
	end

	return false;
end

function LFGWhoListFilterUtil.InitMapFilters(rootDescription)
	local function IsMapChecked(mapID)
		return LFGWhoListFilterUtil.mapsIncluded[mapID];
	end

	local function SetMapChecked(mapID)
		if LFGWhoListFilterUtil.mapsIncluded[mapID] then
			LFGWhoListFilterUtil.mapsIncluded[mapID] = nil;
		else
			LFGWhoListFilterUtil.mapsIncluded[mapID] = true;
		end
	end

	local function AddMapChildren(menuDescription, mapID)
		local children = C_Map.GetMapChildrenInfo(mapID);
		if not children then
			return;
		end

		table.sort(children, function(mapInfo1, mapInfo2) return mapInfo1.name < mapInfo2.name; end);

		for index, childMapInfo in ipairs(children) do
			if C_Map.IsMapValidForNavBarDropdown(childMapInfo.mapID) then
				if LFGWhoListFilterUtil.MapHasSelectableChildren(childMapInfo.mapID) then
					local childMenu = menuDescription:CreateButton(childMapInfo.name);
					AddMapChildren(childMenu, childMapInfo.mapID);
				else
					if not LFGWhoListFilterUtil.mapFiltersDefaulted then
						LFGWhoListFilterUtil.mapsIncluded[childMapInfo.mapID] = true;
					end
					menuDescription:CreateCheckbox(childMapInfo.name, IsMapChecked, SetMapChecked, childMapInfo.mapID);
				end
			end
		end
	end

	local mapSubmenu = rootDescription:CreateButton(ZONE);
	mapSubmenu:CreateButton(CHECK_ALL, LFGWhoListFilterUtil.SetAllMapsFiltered, true);
	mapSubmenu:CreateButton(UNCHECK_ALL, LFGWhoListFilterUtil.SetAllMapsFiltered, false);

	local topMostMapID = LFGWhoListFilterUtil.GetTopMostMapID();
	if topMostMapID then
		AddMapChildren(mapSubmenu, topMostMapID);
	end

	LFGWhoListFilterUtil.mapFiltersDefaulted = true;
end

function LFGWhoListFilterUtil.SetAllMapsFiltered(filtered)
	local function SetMapFilteredRecursive(mapID)
		if LFGWhoListFilterUtil.MapHasSelectableChildren(mapID) then
			for index, childMapInfo in ipairs(C_Map.GetMapChildrenInfo(mapID)) do
				if C_Map.IsMapValidForNavBarDropdown(childMapInfo.mapID) then
					SetMapFilteredRecursive(childMapInfo.mapID);
				end
			end
		else
			if filtered then
				LFGWhoListFilterUtil.mapsIncluded[mapID] = true;
			else
				LFGWhoListFilterUtil.mapsIncluded[mapID] = nil;
			end
		end
	end

	local topMostMapID = LFGWhoListFilterUtil.GetTopMostMapID();
	if topMostMapID then
		SetMapFilteredRecursive(topMostMapID);
	end

	return MenuResponse.Refresh;
end

function LFGWhoListFilterUtil.InitSortOptions(rootDescription)
	local function IsSortChecked(sortMode)
		return LFGWhoListFilterUtil.sortMode == sortMode;
	end

	local function SetSortChecked(sortMode)
		LFGWhoListFilterUtil.sortMode = sortMode;
		C_FriendList.SortWho(sortMode);

		return MenuResponse.Refresh;
	end

	local function IsOrderChecked(sortOrder)
		return LFGWhoListFilterUtil.sortOrder == sortOrder;
	end

	local function SetOrderChecked(sortOrder)
		LFGWhoListFilterUtil.sortOrder = sortOrder;
		C_FriendList.SortWho(LFGWhoListFilterUtil.sortMode, sortOrder == WHO_SORT_ASCENDING);

		return MenuResponse.Refresh;
	end

	local sortSubmenu = rootDescription:CreateButton(WHO_SORT_LABEL);
	sortSubmenu:CreateRadio(NAME, IsSortChecked, SetSortChecked, WHO_SORT_NAME);
	sortSubmenu:CreateRadio(CLASS, IsSortChecked, SetSortChecked, WHO_SORT_CLASS);
	sortSubmenu:CreateRadio(LEVEL, IsSortChecked, SetSortChecked, WHO_SORT_LEVEL);
	sortSubmenu:QueueDivider();
	sortSubmenu:CreateRadio(WHO_SORT_ASCENDING_LABEL, IsOrderChecked, SetOrderChecked, WHO_SORT_ASCENDING);
	sortSubmenu:CreateRadio(WHO_SORT_DESCENDING_LABEL, IsOrderChecked, SetOrderChecked, WHO_SORT_DESCENDING);
end
