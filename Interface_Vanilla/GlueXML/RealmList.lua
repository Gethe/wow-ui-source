local REALM_BUTTON_HEIGHT = 16;
local MAX_REALMS_DISPLAYED = 20;
local MAX_REALM_CATEGORY_TABS = 8;

function RealmList_OnLoad(self)
	self.selectedRealm = nil;
	self.selectedCategory = nil;
	
	self:RegisterEvent("QUEUE_IS_FULL");

	local scrollFrame = RealmListScrollFrame;
	scrollFrame.update = function() RealmList_Update() end;
	HybridScrollFrame_CreateButtons(RealmListScrollFrame, "RealmListRealmButtonTemplate");
end

function RealmList_OnEvent(self, event, ...)
	if ( event == "QUEUE_IS_FULL" ) then
		local realmName, characterCapReached = ...;
		if( self:IsVisible() ) then
			if( characterCapReached ) then
				RealmList_ShowCharacterCapReached();
			else
				RealmList_ShowQueueIsFull(realmName);
			end
		else
			-- Queue the popup for the next time we show ourselves
			self.showQueueIsFull = true;
			self.queueIsFullRealmName = realmName;
			self.characterCapReached = characterCapReached;
		end
	end
end

function RealmList_Update()
	-- If we don't have anything selected, select something
	if ( not RealmList_GetCategoryIndex(RealmList.selectedCategory) ) then
		RealmList.selectedCategory = C_RealmList.GetAvailableCategories()[1];
	end

	local kioskRealmAddr = GetKioskAutoRealmAddress();
	if (kioskRealmAddr) then
		RealmList.selectedRealm = kioskRealmAddr;
	end

	-- Update category tabs
	RealmList_UpdateTabs();

	-- Make sure the selected realm is on-screen
	
	-- Update the realm buttons
	local realms = RealmList.selectedCategory and C_RealmList.GetRealmsInCategory(RealmList.selectedCategory) or {};
	RealmListUtility_SortRealms(realms);
	local scrollFrame = RealmListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	local foundSelectedRealm;
	for i=1, #scrollFrame.buttons do
		local idx = i + offset;
		local button = scrollFrame.buttons[i];

		if ( idx <= #realms ) then
			local realmAddr = realms[idx];
			local realmInfo = C_RealmList.GetRealmInfo(realmAddr);

			button.realmAddr = realmAddr;
			local isSelectedRealm = realmAddr == RealmList.selectedRealm;

			local seasonID = realmInfo.seasonID;
			--Update RealmType
			local realmType = "";
			if (seasonID and SEASON_NAMES[seasonID] ~= nil) then
				realmType = SEASON_NAMES[seasonID] .. " ";
			end
			if ( realmInfo.isPvP and realmInfo.isRP ) then
				realmType = realmType .. RPPVP_PARENTHESES;
				button.RealmType:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
			elseif ( realmInfo.isRP ) then
				realmType = realmType .. RP_PARENTHESES;
				button.RealmType:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			elseif ( realmInfo.isPvP ) then
				realmType = realmType .. PVP_PARENTHESES;
				button.RealmType:SetTextColor(RED_FONT_COLOR:GetRGB());
			else
				realmType = realmType .. GAMETYPE_NORMAL;
				button.RealmType:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
			end
			if (seasonID) then
				if( realmInfo.isPvP ) then
					button.RealmType:SetTextColor(BLUE_FONT_COLOR:GetRGB());
			else
					button.RealmType:SetTextColor(GREEN_FONT_COLOR:GetRGB());
				end
			end
			button.RealmType:SetText(realmType);

			local populationState = realmInfo.populationState;
			local versionMismatch = realmInfo.versionMismatch;
			--Update Load text
			if ( populationState == "OFFLINE" ) then
				button.Load:SetText(REALM_DOWN);
				button.Load:SetTextColor(GRAY_FONT_COLOR:GetRGB());
			elseif ( versionMismatch ) then --not a population state
				button.Load:SetText(ADDON_INCOMPATIBLE);
				button.Load:SetTextColor(RED_FONT_COLOR:GetRGB());
			elseif ( populationState == "LOCKED" ) then
				button.Load:SetText(REALM_LOCKED);
				button.Load:SetTextColor(RED_FONT_COLOR:GetRGB());
			elseif ( populationState == "LOW" ) then
				button.Load:SetText(LOAD_LOW);
				button.Load:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			elseif ( populationState == "HIGH" ) then
				button.Load:SetText(LOAD_HIGH);
				button.Load:SetTextColor(RED_FONT_COLOR:GetRGB());
			elseif ( populationState == "NEW" ) then
				button.Load:SetText(LOAD_NEW);
				button.Load:SetTextColor(BLUE_FONT_COLOR:GetRGB());
			elseif ( populationState == "RECOMMENDED" ) then
				button.Load:SetText(LOAD_RECOMMENDED);
				button.Load:SetTextColor(BLUE_FONT_COLOR:GetRGB());
			elseif ( populationState == "FULL" ) then
				button.Load:SetText(LOAD_FULL);
				button.Load:SetTextColor(RED_FONT_COLOR:GetRGB());
			elseif ( populationState == "MEDIUM" ) then
				button.Load:SetText(LOAD_MEDIUM);
				button.Load:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
			else
				--Should never happen
				button.Load:SetText(LOAD_MEDIUM);
				button.Load:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
			end

			local numChars = realmInfo.numCharacters;
			--Update selected state
			if ( isSelectedRealm ) then
				button:LockHighlight();
				RealmListHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
				RealmListHighlight:SetShown(populationState ~= "OFFLINE");
				button.RealmType:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
				button.Load:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());

				--Update the highlight color
				if ( versionMismatch ) then
					RealmListHighlightTexture:SetVertexColor(1.0, 0.1, 0.1);
				elseif ( numChars > 0 ) then
					RealmListHighlightTexture:SetVertexColor(0.1, 1.0, 0.1);
				else
					RealmListHighlightTexture:SetVertexColor(1.0, 0.78, 0.0);
				end
				foundSelectedRealm = true;
			else
				button:UnlockHighlight();
			end

			--Update font colors
			if ( populationState == "OFFLINE" ) then
				button:SetNormalFontObject(RealmDownNormal);
				button:SetHighlightFontObject(RealmDownHighlight);
			elseif ( versionMismatch ) then
				button:SetNormalFontObject(RealmInvalidNormal);
				button:SetHighlightFontObject(RealmInvalidHighlight);
			elseif ( numChars > 0 ) then
				button:SetNormalFontObject(RealmCharactersNormal);
				button:SetHighlightFontObject(GlueFontHighlightLeft);
			else
				button:SetNormalFontObject(RealmNoCharactersNormal);
				button:SetHighlightFontObject(GlueFontHighlightLeft);
			end

			--Update enable state
			button:SetEnabled(populationState ~= "OFFLINE");

			--Update character count
			if ( numChars > 0 ) then
				button.PlayerCount:SetText("("..numChars..")");
			else
				button.PlayerCount:SetText("");
			end

			--Update name
			if ( realmInfo.version ) then
				button:SetText(realmInfo.name.." ("..realmInfo.version.major.."."..realmInfo.version.minor.."."..realmInfo.version.revision..")");
			else
				button:SetText(realmInfo.name);
			end


			button:Show();
		else
			button:Hide();
		end
	end

	if ( not foundSelectedRealm ) then
		RealmListHighlight:Hide();
	end

	if (kioskRealmAddr and foundSelectedRealm) then
		C_RealmList.ConnectToRealm(kioskRealmAddr);
		SetKioskAutoRealmAddress(nil);
	end

	RealmList_UpdateOKButton();

	HybridScrollFrame_Update(scrollFrame, (scrollFrame.buttons[1]:GetHeight()) * #realms, scrollFrame:GetHeight());
end

function RealmList_UpdateOKButton()
	if ( not RealmList.selectedRealm ) then
		RealmListOkButton:Disable();
		return;
	end

	local populationState = C_RealmList.GetRealmInfo(RealmList.selectedRealm).populationState;
	RealmListOkButton:SetEnabled(populationState and populationState ~= "OFFLINE");
end

function RealmList_UpdateTabs()
	local categories = C_RealmList.GetAvailableCategories();
	local numTabs = #categories;
	local tab;
	for i=1, MAX_REALM_CATEGORY_TABS do
		tab = _G["RealmListTab"..i];
		if ( not tab ) then
			tab = CreateFrame("Button", "RealmListTab"..i, RealmListBackground, "RealmListTabButtonTemplate");
			tab:SetID(i);
			tab:SetPoint("LEFT", "RealmListTab"..(i-1), "RIGHT", -15, 0);
		end
		tab.disabled = nil;
		if ( numTabs == 1 ) then
			tab:Hide();
		elseif ( i <= numTabs ) then
			local name, isTournament, isInvalidLocale = C_RealmList.GetCategoryInfo(categories[i]);
			tab:SetText(name);
			GlueTemplates_TabResize(0, tab);
			tab:Show();
			tab:SetDisabledFontObject("GlueFontHighlightSmall");
		else
			tab:Hide();
		end
	end
	GlueTemplates_SetNumTabs(RealmList, numTabs);

	--Select the tab for our current category
	local tabIdx = RealmList_GetCategoryIndex(RealmList.selectedCategory);
	if ( tabIdx ) then
		GlueTemplates_SetTab(RealmList, tabIdx);
	end
end

function RealmList_GetCategoryIndex(categoryID)
	local categories = C_RealmList.GetAvailableCategories();
	for i=1, #categories do
		if ( categories[i] == RealmList.selectedCategory ) then
			return i;
		end
	end
end

function RealmList_OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		RealmList_OnCancel();
	elseif ( key == "ENTER" ) then
		RealmList_OnOk();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function RealmList_OnOk()
	if (RealmList.selectedRealm) then
		-- If trying to join a Full realm then popup a dialog
		local realmInfo = C_RealmList.GetRealmInfo(RealmList.selectedRealm);

		if ( realmInfo.populationState == "FULL" and realmInfo.numCharacters == 0 ) then
			GlueDialog_Show("REALM_IS_FULL");
		elseif ( realmInfo.populationState == "LOCKED" and realmInfo.numCharacters == 0 ) then
			GlueDialog_Show("REALM_IS_LOCKED");
		else
			RealmList_OnConnectToRealm();
		end
	end
end

function RealmList_OnConnectToRealm()
	local realmInfo = C_RealmList.GetRealmInfo(RealmList.selectedRealm);

	if (realmInfo.seasonID == Enum.SeasonID.Hardcore and realmInfo.numCharacters == 0) then
		HardcorePopUpFrame:SetRealmInfo(RealmList.selectedRealm)
		HardcorePopUpFrame:ShowRealmSelectionWarning();
	else
		C_RealmList.ConnectToRealm(RealmList.selectedRealm);
	end
end

function RealmList_OnCancel()
	local auroraState, connectedToWoW, wowConnectionState, hasRealmList, waitingForRealmList = C_Login.GetState();
	if ( not connectedToWoW ) then
		C_Login.DisconnectFromServer();
	else 
		C_RealmList.ClearRealmList();
	end
end

function RealmList_ClickButton(self, doubleClick)
	local name, isTournament, isInvalidLocale = C_RealmList.GetCategoryInfo(RealmList.selectedCategory);
	if ( isInvalidLocale ) then
		--Display popup explaining locale specific realms
		GlueDialog_Show("REALM_LOCALE_WARNING");
		return;
	end

	RealmList.selectedRealm = self.realmAddr;
	RealmList_Update();
	if ( doubleClick ) then
		RealmList_OnOk();
	end
end

function RealmSelectButton_OnClick(self)
	RealmList_ClickButton(self, false);
end

function RealmSelectButton_OnDoubleClick(self)
	RealmList_ClickButton(self, true);
end

function RealmList_OnShow(self)
	if ( self.showQueueIsFull ) then
		if ( self.characterCapReached ) then
			RealmList_ShowCharacterCapReached();
		else
			RealmList_ShowQueueIsFull(self.queueIsFullRealmName);
		end
		self.showQueueIsFull = false;
		self.queueIsFullRealmName = nil;
		self.characterCapReached = false;
	end

	local name = GetServerName();

	-- If we already have a realm name, find the correct category
	if ( name ) then
		RealmList.selectedRealm, RealmList.selectedCategory = RealmList_GetInfoFromName(name);
	else
		RealmList.selectedRealm, RealmList.selectedCategory = nil, nil;
	end

	--Update the UI
	RealmList_Update();
	
	if ( not C_RealmList.IsRealmListComplete() ) then
		GlueDialog_Show("OKAY_MUST_ACCEPT", REALM_LIST_PARTIAL_RESULTS);
	end
end

function RealmList_GetInfoFromName(name)
	local categories = C_RealmList.GetAvailableCategories();
	for i=1, #categories do
		local realms = C_RealmList.GetRealmsInCategory(categories[i]);
		for j=1, #realms do
			local realmAddr = realms[j];
			local realmName = C_RealmList.GetRealmInfo(realmAddr).name;

			if ( realmName == name ) then
				return realmAddr, categories[i];
			end
		end
	end

	return nil, nil;
end

function RealmListTab_OnClick(tab)
	if ( tab.disabled ) then
		local name, isTournament = C_RealmList.GetCategoryInfo(C_RealmList.GetAvailableCategories()[tab:GetID()]);
		if ( isTournament ) then
			--Display popup explaining tournament realms
			GlueDialog_Show("REALM_TOURNAMENT_WARNING");
		end
		return;
	end
	RealmList.selectedCategory = C_RealmList.GetAvailableCategories()[tab:GetID()];
	RealmList.selectedRealm = nil;
	GlueTemplates_SetTab(RealmList, tab:GetID());
	RealmList_Update();
end

function RealmHelpText_OnShow(self)
	self:SetText(HTML_START .. string.format(REALM_HELP_FRAME_TEXT, REALM_HELP_FRAME_URL) .. HTML_END);
end

REALM_LIST_POPULATION_ORDERING = {
	RECOMMENDED = 1,
	NEW = 2,
	LOW = 3,
	MEDIUM = 4,
	HIGH = 5,
	FULL = 6,
	LOCKED = 7,
	OFFLINE = 8,
};

REALM_LIST_SORT_DEFINITIONS = {
	compatible = {
		func = function(realm1, realm2)
			local versionMismatch1 = C_RealmList.GetRealmInfo(realm1).versionMismatch;
			local versionMismatch2 = C_RealmList.GetRealmInfo(realm2).versionMismatch;
			if ( versionMismatch1 == versionMismatch2 ) then
				return 0;
			elseif ( versionMismatch1 ) then
				return 1;
			else
				return -1;
			end
		end
	},
	name = {
		func = function(realm1, realm2)
			local name1 = C_RealmList.GetRealmInfo(realm1).name;
			local name2 = C_RealmList.GetRealmInfo(realm2).name;
			return strcmputf8i(name1, name2);
		end
	},
	realmType = {
		func = function(realm1, realm2)
			local realmInfo1 = C_RealmList.GetRealmInfo(realm1);
			local realmInfo2 = C_RealmList.GetRealmInfo(realm2);
			if ( realmInfo1.isRP ~= realmInfo2.isRP ) then
				return realmInfo1.isRP and 1 or -1;
			elseif ( realmInfo1.isPvP ~= realmInfo2.isPvP ) then
				return realmInfo1.isPvP and 1 or -1;
			else
				return 0;
			end
		end
	},
	numCharacters = {
		func = function(realm1, realm2)
			local numChars1 = C_RealmList.GetRealmInfo(realm1).numCharacters;
			local numChars2 = C_RealmList.GetRealmInfo(realm2).numCharacters;
			return numChars2 - numChars1;
		end
	},
	population = {
		func = function(realm1, realm2)
			local population1 = C_RealmList.GetRealmInfo(realm1).populationState;
			local population2 = C_RealmList.GetRealmInfo(realm2).populationState;
			return REALM_LIST_POPULATION_ORDERING[population1] - REALM_LIST_POPULATION_ORDERING[population2];
		end
	}
};

REALM_LIST_SORT_ORDERING = {
	{
		sortBy = "compatible",
		reverse = false,
	},
	{
		sortBy = "numCharacters",
		reverse = false,
	},
	{
		sortBy = "population",
		reverse = false,
	},
	{
		sortBy = "name",
		reverse = false,
	},
	{
		sortBy = "realmType",
		reverse = false,
	},
};

function RealmList_PushSortOrdering(sortBy)
	if ( REALM_LIST_SORT_ORDERING[1].sortBy == sortBy ) then
		REALM_LIST_SORT_ORDERING[1].reverse = not REALM_LIST_SORT_ORDERING[1].reverse;
	else
		for i=1, #REALM_LIST_SORT_ORDERING do
			if ( REALM_LIST_SORT_ORDERING[i].sortBy == sortBy ) then
				--Move the item to the top
				table.insert(REALM_LIST_SORT_ORDERING, 1, table.remove(REALM_LIST_SORT_ORDERING, i));
				REALM_LIST_SORT_ORDERING[1].reverse = false;
			end
		end
	end

	RealmList_Update();
end

function RealmList_ShowQueueIsFull(realmName)
	local dialogString = QUEUE_IS_FULL;
	if( realmName ) then
		dialogString = string.format(_G["QUEUE_IS_FULL_REALM_NAME"], realmName);
	end
	GlueDialog_Show("OKAY_MUST_ACCEPT", dialogString);
end

function RealmList_ShowCharacterCapReached()
	GlueDialog_Show("OKAY_MUST_ACCEPT", NAME_RESERVATION_CHARACTER_CAP_REACHED);
end

function RealmListUtility_SortRealmsCB(realm1, realm2)
	for i=1, #REALM_LIST_SORT_ORDERING do
		local ordering = REALM_LIST_SORT_DEFINITIONS[REALM_LIST_SORT_ORDERING[i].sortBy].func(realm1, realm2);
		if ( ordering ~= 0 ) then
			if ( REALM_LIST_SORT_ORDERING[i].reverse ) then
				return ordering > 0;
			else
				return ordering < 0;
			end
		end
	end

	--Everything was exactly the same? Okaaaaay....
	return realm1 < realm2;
end

function RealmListUtility_SortRealms(realms)
	table.sort(realms, RealmListUtility_SortRealmsCB);
end

function RealmListUtility_GetTypeTooltip(realmAddr)
	local seasonID = C_RealmList.GetRealmInfo(realmAddr).seasonID;
	return seasonID == 0 and nil or SEASON_TOOLTIPS[seasonID];
end

function RealmTypeTooltipHitbox_OnEnter(self)
	local tooltipText = RealmListUtility_GetTypeTooltip(self:GetParent().realmAddr);
	if(tooltipText) then
		GlueTooltip:SetOwner(self, "ANCHOR_RIGHT", -50, 0);
		GlueTooltip:SetText(tooltipText);
	end
end

function RealmButton_RemoveTooltip(self)
	if (GlueTooltip_GetOwner(GlueTooltip) == self) then
		GlueTooltip:Hide();
	end
end

function RealmListUtility_ResizeRealmTypeColumn(offsetX, offsetY)
	local scrollFrame = RealmListScrollFrame;
	for i=1, #scrollFrame.buttons do
		local button = scrollFrame.buttons[i];
		button:SetWidth(button:GetWidth() + offsetX);
		button.RealmType:SetWidth(button.RealmType:GetWidth() + offsetX);
	end

	RealmListBackground:SetWidth(RealmListBackground:GetWidth() + offsetX);
	RealmTypeSort:SetWidth(RealmTypeSort:GetWidth() + offsetX);
	RealmListHighlight:SetWidth(RealmListHighlight:GetWidth() + offsetX);
	RealmListTopTexture:SetWidth(RealmListTopTexture:GetWidth() + offsetX);
	RealmListBottomTexture:SetWidth(RealmListBottomTexture:GetWidth() + offsetX);
	RealmListScrollFrame:SetPoint("BOTTOMRIGHT", RealmListBackground, "TOPLEFT", RealmListScrollFrame:GetWidth() + offsetX, -RealmListScrollFrame:GetHeight());
end