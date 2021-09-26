local REALM_BUTTON_HEIGHT = 16;
local MAX_REALMS_DISPLAYED = 20;
local MAX_REALM_CATEGORY_TABS = 8;

function RealmList_OnLoad(self)
	self.selectedRealm = nil;
	self.selectedCategory = nil;
	
	local scrollFrame = RealmListScrollFrame;
	scrollFrame.update = function() RealmList_Update() end;
	HybridScrollFrame_CreateButtons(RealmListScrollFrame, "RealmListRealmButtonTemplate");
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
			local name, numChars, versionMismatch, isPvP, isRP, populationState, versionMajor, versionMinor, versionRev, versionBuild = C_RealmList.GetRealmInfo(realmAddr);

			button.realmAddr = realmAddr;
			local isSelectedRealm = realmAddr == RealmList.selectedRealm;

			--Update RealmType
			if ( isPvP and isRP ) then
				button.RealmType:SetText(RPPVP_PARENTHESES);
				button.RealmType:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			elseif ( isRP ) then
				button.RealmType:SetText(RP_PARENTHESES);
				button.RealmType:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
			elseif ( isPvP ) then
				button.RealmType:SetText(PVP_PARENTHESES);
				button.RealmType:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			else
				button.RealmType:SetText(GAMETYPE_NORMAL);
				button.RealmType:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			end

			--Update Load text

			if ( populationState == "OFFLINE" ) then
				button.Load:SetText(REALM_DOWN);
				button.Load:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			elseif ( versionMismatch ) then --not a population state
				button.Load:SetText(ADDON_INCOMPATIBLE);
				button.Load:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			elseif ( populationState == "LOCKED" ) then
				button.Load:SetText(REALM_LOCKED);
				button.Load:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			elseif ( populationState == "LOW" ) then
				button.Load:SetText(LOAD_LOW);
				button.Load:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
			elseif ( populationState == "HIGH" ) then
				button.Load:SetText(LOAD_HIGH);
				button.Load:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			elseif ( populationState == "NEW" ) then
				--button.Load:SetText(LOAD_NEW);
				-- CLASSIC TODO: Overriding the "NEW" state here to show a server as "Layered". This makes the hotfix a lot simpler, but ideally we should do this with a new population state.
				button.Load:SetText(REALM_LAYERED);
				button.Load:SetTextColor(BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b);
			elseif ( populationState == "RECOMMENDED" ) then
				--button.Load:SetText(LOAD_RECOMMENDED);
				button.Load:SetText(RECOMMENDED);
				button.Load:SetTextColor(BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b);
			elseif ( populationState == "FULL" ) then
				button.Load:SetText(LOAD_FULL);
				button.Load:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			elseif ( populationState == "MEDIUM" ) then
				button.Load:SetText(LOAD_MEDIUM);
				button.Load:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			else
				--Should never happen
				button.Load:SetText(LOAD_MEDIUM);
				button.Load:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			end

			--Update selected state
			if ( isSelectedRealm ) then
				button:LockHighlight();
				RealmListHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
				RealmListHighlight:SetShown(populationState ~= "OFFLINE");
				button.RealmType:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				button.Load:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

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
			if ( versionMajor ) then
				button:SetText(name.." ("..versionMajor.."."..versionMinor.."."..versionRev..")");
			else
				button:SetText(name);
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

	local name, numChars, versionMismatch, isPvP, isRP, populationState, versionMajor, versionMinor, versionRev, versionBuild = C_RealmList.GetRealmInfo(RealmList.selectedRealm);
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
			if (isTournament and not C_RealmList.CanJoinTournamentRealms()) then
				tab:SetDisabledFontObject("GlueFontDisableSmall");
				tab.disabled = true;
			else
				tab:SetDisabledFontObject("GlueFontHighlightSmall");
			end
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
		local name, numChars, versionMismatch, isPvP, isRP, populationState, versionMajor, versionMinor, versionRev, versionBuild = C_RealmList.GetRealmInfo(RealmList.selectedRealm);

		if ( populationState == "FULL" and numChars == 0 ) then
			GlueDialog_Show("REALM_IS_FULL");
		else
			C_RealmList.ConnectToRealm(RealmList.selectedRealm);
		end
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
			local realmName, numChars, versionMismatch, isPvP, isRP, populationState, versionMajor, versionMinor, versionRev, versionBuild = C_RealmList.GetRealmInfo(realmAddr);

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
			local versionMismatch1 = select(3, C_RealmList.GetRealmInfo(realm1));
			local versionMismatch2 = select(3, C_RealmList.GetRealmInfo(realm2));
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
			local name1 = select(1, C_RealmList.GetRealmInfo(realm1));
			local name2 = select(1, C_RealmList.GetRealmInfo(realm2));
			return strcmputf8i(name1, name2);
		end
	},
	realmType = {
		func = function(realm1, realm2)
			local pvp1, rp1 = select(4, C_RealmList.GetRealmInfo(realm1));
			local pvp2, rp2 = select(4, C_RealmList.GetRealmInfo(realm2));
			if ( rp1 ~= rp2 ) then
				return rp1 and 1 or -1;
			elseif ( pvp1 ~= pvp2 ) then
				return pvp1 and 1 or -1;
			else
				return 0;
			end
		end
	},
	numCharacters = {
		func = function(realm1, realm2)
			local numChars1 = select(2, C_RealmList.GetRealmInfo(realm1));
			local numChars2 = select(2, C_RealmList.GetRealmInfo(realm2));
			return numChars2 - numChars1;
		end
	},
	population = {
		func = function(realm1, realm2)
			local population1 = select(6, C_RealmList.GetRealmInfo(realm1));
			local population2 = select(6, C_RealmList.GetRealmInfo(realm2));
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
