local REALM_BUTTON_HEIGHT = 16;
local MAX_REALMS_DISPLAYED = 18;
local MAX_REALM_CATEGORY_TABS = 8;

function RealmList_OnLoad(self)
	self:RegisterEvent("OPEN_REALM_LIST");
	self.currentRealm = nil;
	self.offset = 0;
end

function RealmList_OnEvent(self, event)
	if ( event == "OPEN_REALM_LIST" ) then
		if ( RealmListUI:IsShown() ) then
			RealmListUpdate();
		else
			SetGlueScreen("realmlist");
		end
	end
end

function RealmListUpdate()
	-- Just for the first time the frame is loaded
	if ( not RealmList.selectedCategory ) then
		RealmList.selectedCategory = 1;
	end
	
	-- Set the refresh timer
	RealmList.refreshTime = RealmListUpdateRate();

	-- Set up the category tabs
	RealmList_UpdateTabs(GetRealmCategories());

	local numRealms = GetNumRealms(RealmList.selectedCategory);
	local name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked;
	local realmIndex;
	local pvpText, loadText, isFull;
	local major, minor, revision, build, type;

	RealmListOkButton:Disable();
	RealmListHighlight:Hide();
	for i=1, MAX_REALMS_DISPLAYED, 1 do
		realmIndex = RealmList.offset + i;
		local button = _G["RealmListRealmButton"..i];
		if ( realmIndex > numRealms ) then
			button:Hide();
		else
			name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked, major, minor, revision, build, type = GetRealmInfo(RealmList.selectedCategory, realmIndex);

			if ( not name ) then
				button:Hide();
			else
				pvpText = _G["RealmListRealmButton"..i.."PVP"];
				if ( pvp and rp ) then
					pvpText:SetText(RPPVP_PARENTHESES);
					pvpText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				elseif ( rp ) then
					pvpText:SetText(RP_PARENTHESES);
					pvpText:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				elseif ( pvp ) then
					pvpText:SetText(PVP_PARENTHESES);
					pvpText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				else
					pvpText:SetText(GAMETYPE_NORMAL);
					pvpText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end

				isFull = nil;
				loadText = _G["RealmListRealmButton"..i.."Load"];
				
				if ( realmDown ) then
					loadText:SetText(REALM_DOWN);
					loadText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				elseif ( locked ) then
					loadText:SetText(REALM_LOCKED);
					loadText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				elseif ( load == -3.0 ) then
					loadText:SetText(LOAD_RECOMMENDED);
					loadText:SetTextColor(BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b);
				elseif ( load == -2.0 ) then
					loadText:SetText(LOAD_NEW);
					loadText:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				elseif ( load == 2.0 ) then
					loadText:SetText(LOAD_FULL);
					loadText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
					isFull = 1;
				elseif ( load > 0 ) then
					loadText:SetText(LOAD_HIGH);
					loadText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				elseif ( load < 0 ) then
					loadText:SetText(LOAD_LOW);
					loadText:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				else
					loadText:SetText(LOAD_MEDIUM);
					loadText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end

				if (major) then
					button.major = major;
					button.minor = minor;
					button.revision = revision;
					button.build = build;
					button.type = type;
					button:SetText(name.." ("..major.."."..minor.."."..revision..")");
				else
					button:SetText(name);
				end

				local players = _G["RealmListRealmButton"..i.."Players"];
				if ( numCharacters > 0 ) then
					players:SetText("("..numCharacters..")");
				else
					players:SetText("");
				end
				if ( realmDown ) then
					button:SetNormalFontObject(RealmDownNormal);
					button:SetHighlightFontObject(RealmDownHighlight);
				else
					if ( invalidRealm ) then
						button:SetNormalFontObject(RealmInvalidNormal);
						button:SetHighlightFontObject(RealmInvalidHighlight);
					else
						if ( numCharacters > 0 ) then
							button:SetNormalFontObject(RealmCharactersNormal);
							button:SetHighlightFontObject(GlueFontHighlightLeft);
						else
							button:SetNormalFontObject(RealmNoCharactersNormal);
							button:SetHighlightFontObject(GlueFontHighlightLeft);
						end
						
					end
				end
				
				button:Show();
				button:SetID(realmIndex);
				button.name = name;

				if ( realmDown ) then
					button:Disable();
				else
					button:Enable();
				end
				
				if ( RealmList.currentRealm ) then
					if ( RealmList.currentRealm == realmIndex ) then
						button:LockHighlight();
						RealmListOkButton:Enable();
						RealmListHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
						
						-- If realm is full and the player has no chars on that server show a dialog
						if ( isFull and numCharacters == 0 ) then
							RealmList.showRealmIsFullDialog = 1;
						else
							RealmList.showRealmIsFullDialog = nil;
						end
						
						if ( realmDown ) then
							RealmListHighlight:Hide();
							RealmListOkButton:Disable();
						else
							RealmListHighlight:Show();
							pvpText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
							loadText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
							RealmListOkButton:Enable();
							if ( invalidRealm ) then
								RealmListHighlightTexture:SetVertexColor(1.0, 0.1, 0.1);
							else
								if ( numCharacters > 0 ) then
									RealmListHighlightTexture:SetVertexColor(0.1, 1.0, 0.1);
								else
									RealmListHighlightTexture:SetVertexColor(1.0, 0.78, 0.0);
								end
							end
						end
					else
						button:UnlockHighlight();
					end
				else
					if ( currentRealm == 1 ) then
						RealmList.currentRealm = realmIndex;
						button:LockHighlight();
						RealmListHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
						if ( realmDown ) then
							RealmListHighlight:Hide();
							RealmListOkButton:Disable();
						else
							RealmListHighlight:Show();
							pvpText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
							loadText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
							RealmListOkButton:Enable();
							if ( invalidRealm ) then
								RealmListHighlightTexture:SetVertexColor(1.0, 0.1, 0.1);
							else
								if ( numCharacters > 0 ) then
									RealmListHighlightTexture:SetVertexColor(0.1, 1.0, 0.1);
								else
									RealmListHighlightTexture:SetVertexColor(1.0, 0.78, 0.0);
								end
							end
						end
					else
						button:UnlockHighlight();
					end
				end			
			end
		end
	end

	-- ScrollFrame stuff
	GlueScrollFrame_Update(RealmListScrollFrame, numRealms, MAX_REALMS_DISPLAYED, REALM_BUTTON_HEIGHT, RealmListHighlight, 557,  587);
end

function RealmList_UpdateTabs(...)
	local numTabs = select("#", ...);
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
			tab:SetText(select(i, ...));
			GlueTemplates_TabResize(0, tab);
			tab:Show();
			if (IsInvalidTournamentRealmCategory(i)) then
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
	if ( not GlueTemplates_GetSelectedTab(RealmList) ) then
		GlueTemplates_SetTab(RealmList, 1);
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
	RealmListUI:Hide();
	-- If trying to join a Full realm then popup a dialog
	if ( RealmList.showRealmIsFullDialog ) then
		GlueDialog_Show("REALM_IS_FULL");
		return;
	end
	if ( RealmList.currentRealm ) then
		ChangeRealm(RealmList.selectedCategory , RealmList.currentRealm);
	end
end

function RealmList_OnCancel()
	RealmListDialogCancelled();
	local serverName, isPVP, isRP, isDown = GetServerName();

	if ( (GetNumRealms(RealmList.selectedCategory) == 0) or (isDown) or not(IsConnectedToServer())) then
		DisconnectFromServer();
		SetGlueScreen("login");
	else
		SetGlueScreen("charselect");
	end
end

function RealmSelectButton_OnClick(self, id)
	if ( IsInvalidLocale( RealmList.selectedCategory ) ) then
		--Display popup explaining locale specific realms
		GlueDialog_Show("REALM_LOCALE_WARNING");
	else
		RealmList.refreshTime = RealmListUpdateRate();
		RealmList.currentRealm = id;
		RealmListUpdate();
	end
end

function RealmSelectButton_OnDoubleClick(self, id)
	if ( IsInvalidLocale( RealmList.selectedCategory ) ) then
		--Display popup explaining locale specific realms
		GlueDialog_Show("REALM_LOCALE_WARNING");
	else
		RealmList.currentRealm = id;
		RealmList_OnOk();
	end
end

function RealmListScrollFrame_OnVerticalScroll(self, offset)
	RealmList.refreshTime = RealmListUpdateRate();
	local scrollbar = _G[self:GetName().."ScrollBar"];
	scrollbar:SetValue(offset);
	RealmList.offset = floor((offset / REALM_BUTTON_HEIGHT) + 0.5);
	RealmListUpdate();
end

function RealmList_OnShow(self)
	RealmList.currentRealm = nil;
	RealmListUpdate();
	self.refreshTime = RealmListUpdateRate();
	local selectedCategory = GetSelectedCategory();
	if ( selectedCategory == 0 ) then
		selectedCategory = 1;
	end
	local button = _G["RealmListTab"..selectedCategory];
	if ( button ) then
		RealmListTab_OnClick(button);
		GlueTemplates_SetTab(RealmList, selectedCategory);
	end
end

function RealmList_OnHide()
	CancelRealmListQuery();
end

function RealmList_OnUpdate(self, elapsed)
	if ( self.refreshTime ) then
		self.refreshTime = self.refreshTime - elapsed;
		if ( self.refreshTime <= 0 ) then
			self.refreshTime = nil;
			RequestRealmList();
		end
	end

	-- Account Msg stuff
	if ( (ACCOUNT_MSG_NUM_AVAILABLE > 0) and not GlueDialog:IsShown() ) then
		if ( ACCOUNT_MSG_HEADERS_LOADED ) then
			if ( ACCOUNT_MSG_BODY_LOADED ) then
				local dialogString = AccountMsg_GetHeaderSubject( ACCOUNT_MSG_CURRENT_INDEX ).."\n\n"..AccountMsg_GetBody();
				GlueDialog_Show("ACCOUNT_MSG", dialogString);
			end
		end
	end
end

function RealmListTab_OnClick(tab)
	if ( tab.disabled ) then
		if ( IsTournamentRealmCategory(tab:GetID()) ) then
			--Display popup explaining tournament realms
--			RealmHelpFrame:Show();
			GlueDialog_Show("REALM_TOURNAMENT_WARNING");
		end

		local button = _G["RealmListTab"..RealmList.selectedCategory];
		if ( button ) then
			button:Click();
		end
		return;
	end
	RealmList.selectedCategory = tab:GetID();
	RealmList.currentRealm = nil;
	RealmListUpdate();
end

function RealmHelpText_OnShow(self)
	self:SetText("<html><body><p>" .. string.format(REALM_HELP_FRAME_TEXT, REALM_HELP_FRAME_URL) .. "</p></body></html>");
end
