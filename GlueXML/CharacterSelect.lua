CHARACTER_SELECT_ROTATION_START_X = nil;
CHARACTER_SELECT_INITIAL_FACING = nil;

CHARACTER_ROTATION_CONSTANT = 0.6;

MAX_CHARACTERS_DISPLAYED = 11;
MAX_CHARACTERS_PER_REALM = 200; -- controled by the server now, so lets set it up high

CHARACTER_LIST_OFFSET = 0;

CHARACTER_SELECT_BACK_FROM_CREATE = false;

MOVING_TEXT_OFFSET = 12;
DEFAULT_TEXT_OFFSET = 0;
CHARACTER_BUTTON_HEIGHT = 57;
CHARACTER_LIST_TOP = 688;
AUTO_DRAG_TIME = 0.5;				-- in seconds

local translationTable = { };	-- for character reordering: key = button index, value = character ID

BLIZZCON_IS_A_GO = false;

function CharacterSelect_OnLoad(self)
	self:SetSequence(0);
	self:SetCamera(0);

	self.createIndex = 0;
	self.selectedIndex = 0;
	self.selectLast = 0;
	self.currentBGTag = nil;
	self:RegisterEvent("ADDON_LIST_UPDATE");
	self:RegisterEvent("CHARACTER_LIST_UPDATE");
	self:RegisterEvent("UPDATE_SELECTED_CHARACTER");
	self:RegisterEvent("SELECT_LAST_CHARACTER");
	self:RegisterEvent("SELECT_FIRST_CHARACTER");
	self:RegisterEvent("SUGGEST_REALM");
	self:RegisterEvent("FORCE_RENAME_CHARACTER");

	-- CharacterSelect:SetModel("Interface\\Glues\\Models\\UI_Orc\\UI_Orc.m2");

	-- local fogInfo = CharModelFogInfo["ORC"];
	-- CharacterSelect:SetFogColor(fogInfo.r, fogInfo.g, fogInfo.b);
	-- CharacterSelect:SetFogNear(0);
	-- CharacterSelect:SetFogFar(fogInfo.far);

	SetCharSelectModelFrame("CharacterSelect");

	-- Color edit box backdrops
	local backdropColor = DEFAULT_TOOLTIP_COLOR;
	CharacterSelectCharacterFrame:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
	CharacterSelectCharacterFrame:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6], 0.85);
	
	CHARACTER_SELECT_BACK_FROM_CREATE = false;

	CHARACTER_LIST_OFFSET = 0;
	if (not IsGMClient()) then
		MAX_CHARACTERS_PER_REALM = 11;
	end
end

function CharacterSelect_OnShow()
	CHARACTER_LIST_OFFSET = 0;
	-- request account data times from the server (so we know if we should refresh keybindings, etc...)
	ReadyForAccountDataTimes()
	
	local bgTag = CharacterSelect.currentBGTag;

	if ( bgTag ) then
		PlayGlueAmbience(GlueAmbienceTracks[bgTag], 4.0);
	end

	UpdateAddonButton();

	local serverName, isPVP, isRP = GetServerName();
	local connected = IsConnectedToServer();
	local serverType = "";
	if ( serverName ) then
		if( not connected ) then
			serverName = serverName.."\n("..SERVER_DOWN..")";
		end
		if ( isPVP ) then
			if ( isRP ) then
				serverType = RPPVP_PARENTHESES;
			else
				serverType = PVP_PARENTHESES;
			end
		elseif ( isRP ) then
			serverType = RP_PARENTHESES;
		end
		CharSelectRealmName:SetText(serverName.." "..serverType);
		CharSelectRealmName:Show();
	else
		CharSelectRealmName:Hide();
	end

	if ( connected ) then
		GetCharacterListUpdate();
	else
		UpdateCharacterList();
	end

	-- Gameroom billing stuff (For Korea and China only)
	if ( SHOW_GAMEROOM_BILLING_FRAME ) then
		local paymentPlan, hasFallBackBillingMethod, isGameRoom = GetBillingPlan();
		if ( paymentPlan == 0 ) then
			-- No payment plan
			GameRoomBillingFrame:Hide();
			CharacterSelectRealmSplitButton:ClearAllPoints();
			CharacterSelectRealmSplitButton:SetPoint("TOP", CharacterSelectLogo, "BOTTOM", 0, -5);
		else
			local billingTimeLeft = GetBillingTimeRemaining();
			-- Set default text for the payment plan
			local billingText = _G["BILLING_TEXT"..paymentPlan];
			if ( paymentPlan == 1 ) then
				-- Recurring account
				billingTimeLeft = ceil(billingTimeLeft/(60 * 24));
				if ( billingTimeLeft == 1 ) then
					billingText = BILLING_TIME_LEFT_LAST_DAY;
				end
			elseif ( paymentPlan == 2 ) then
				-- Free account
				if ( billingTimeLeft < (24 * 60) ) then
					billingText = format(BILLING_FREE_TIME_EXPIRE, billingTimeLeft.." "..MINUTES_ABBR);
				end				
			elseif ( paymentPlan == 3 ) then
				-- Fixed but not recurring
				if ( isGameRoom == 1 ) then
					if ( billingTimeLeft <= 30 ) then
						billingText = BILLING_GAMEROOM_EXPIRE;
					else
						billingText = format(BILLING_FIXED_IGR, MinutesToTime(billingTimeLeft, 1));
					end
				else
					-- personal fixed plan
					if ( billingTimeLeft < (24 * 60) ) then
						billingText = BILLING_FIXED_LASTDAY;
					else
						billingText = format(billingText, MinutesToTime(billingTimeLeft));
					end	
				end
			elseif ( paymentPlan == 4 ) then
				-- Usage plan
				if ( isGameRoom == 1 ) then
					-- game room usage plan
					if ( billingTimeLeft <= 600 ) then
						billingText = BILLING_GAMEROOM_EXPIRE;
					else
						billingText = BILLING_IGR_USAGE;
					end
				else
					-- personal usage plan
					if ( billingTimeLeft <= 30 ) then
						billingText = BILLING_TIME_LEFT_30_MINS;
					else
						billingText = format(billingText, billingTimeLeft);
					end
				end
			end
			-- If fallback payment method add a note that says so
			if ( hasFallBackBillingMethod == 1 ) then
				billingText = billingText.."\n\n"..BILLING_HAS_FALLBACK_PAYMENT;
			end
			GameRoomBillingFrameText:SetText(billingText);
			GameRoomBillingFrame:SetHeight(GameRoomBillingFrameText:GetHeight() + 26);
			GameRoomBillingFrame:Show();
			CharacterSelectRealmSplitButton:ClearAllPoints();
			CharacterSelectRealmSplitButton:SetPoint("TOP", GameRoomBillingFrame, "BOTTOM", 0, -10);
		end
	end
	
	-- fadein the character select ui
	GlueFrameFadeIn(CharacterSelectUI, CHARACTER_SELECT_FADE_IN)

	RealmSplitCurrentChoice:Hide();
	RequestRealmSplitInfo();

	--Clear out the addons selected item
	GlueDropDownMenu_SetSelectedValue(AddonCharacterDropDown, ALL);

	AccountUpgradePanel_Update(CharSelectAccountUpgradeButton.isExpanded);

	if( IsBlizzCon() ) then
		CharacterSelectUI:Hide();
	end
	
	-- character templates
	CharacterTemplatesFrame_Update();

	PromotionFrame_AwaitingPromotion();
end

function CharacterSelect_OnHide(self)
	-- the user may have gotten d/c while dragging
	if ( CharacterSelect.draggedIndex ) then
		local button = _G["CharSelectCharacterButton"..(CharacterSelect.draggedIndex - CHARACTER_LIST_OFFSET)];
		CharacterSelectButton_OnDragStop(button);
	end
	CharacterSelect_SaveCharacterOrder();
	CharacterDeleteDialog:Hide();
	CharacterRenameDialog:Hide();
	if ( DeclensionFrame ) then
		DeclensionFrame:Hide();
	end
	SERVER_SPLIT_STATE_PENDING = -1;
	
	PromotionFrame_Hide();
end

function CharacterSelect_SaveCharacterOrder()
	if ( CharacterSelect.orderChanged ) then
		SaveCharacterOrder(translationTable);
		CharacterSelect.orderChanged = nil;
	end
end

function CharacterSelect_OnUpdate(self, elapsed)
	if ( SERVER_SPLIT_STATE_PENDING > 0 ) then
		CharacterSelectRealmSplitButton:Show();

		if ( SERVER_SPLIT_CLIENT_STATE > 0 ) then
			RealmSplit_SetChoiceText();
			RealmSplitPending:SetPoint("TOP", RealmSplitCurrentChoice, "BOTTOM", 0, -10);
		else
			RealmSplitPending:SetPoint("TOP", CharacterSelectRealmSplitButton, "BOTTOM", 0, 0);
			RealmSplitCurrentChoice:Hide();
		end

		if ( SERVER_SPLIT_STATE_PENDING > 1 ) then
			CharacterSelectRealmSplitButton:Disable();
			CharacterSelectRealmSplitButtonGlow:Hide();
			RealmSplitPending:SetText( SERVER_SPLIT_PENDING );
		else
			CharacterSelectRealmSplitButton:Enable();
			CharacterSelectRealmSplitButtonGlow:Show();
			local datetext = SERVER_SPLIT_CHOOSE_BY.."\n"..SERVER_SPLIT_DATE;
			RealmSplitPending:SetText( datetext );
		end

		if ( SERVER_SPLIT_SHOW_DIALOG and not GlueDialog:IsShown() ) then
			SERVER_SPLIT_SHOW_DIALOG = false;
			local dialogString = format(SERVER_SPLIT,SERVER_SPLIT_DATE);
			if ( SERVER_SPLIT_CLIENT_STATE > 0 ) then
				local serverChoice = RealmSplit_GetFormatedChoice(SERVER_SPLIT_REALM_CHOICE);
				local stringWithDate = format(SERVER_SPLIT,SERVER_SPLIT_DATE);
				dialogString = stringWithDate.."\n\n"..serverChoice;
				GlueDialog_Show("SERVER_SPLIT_WITH_CHOICE", dialogString);
			else
				GlueDialog_Show("SERVER_SPLIT", dialogString);
			end
		end
	else
		CharacterSelectRealmSplitButton:Hide();
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
	
	if ( self.pressDownButton ) then
		self.pressDownTime = self.pressDownTime + elapsed;
		if ( self.pressDownTime >= AUTO_DRAG_TIME ) then
			CharacterSelectButton_OnDragStart(self.pressDownButton);
		end
	end
end

function CharacterSelect_OnKeyDown(self,key)
	if ( key == "ESCAPE" ) then
		CharacterSelect_Exit();
	elseif ( key == "ENTER" ) then
		CharacterSelect_EnterWorld();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	elseif ( key == "UP" or key == "LEFT" ) then
		CharacterSelectScrollUp_OnClick();
	elseif ( key == "DOWN" or key == "RIGHT" ) then
		CharacterSelectScrollDown_OnClick();
	end
end

function CharacterSelect_OnEvent(self, event, ...)
	if ( event == "ADDON_LIST_UPDATE" ) then
		UpdateAddonButton();
	elseif ( event == "CHARACTER_LIST_UPDATE" ) then
		local listSize = ...;
		if ( listSize ) then
			table.wipe(translationTable);
			for i = 1, listSize do
				tinsert(translationTable, i);
			end
			CharacterSelect.orderChanged = nil;
		end
		if (not CHARACTER_SELECT_BACK_FROM_CREATE) then
			local numChars = GetNumCharacters();
			if (numChars == 0) then
				SetGlueScreen("charcreate");
				return;
			end
		end
		UpdateCharacterList();
		CharSelectCharacterName:SetText(GetCharacterInfo(GetCharIDFromIndex(self.selectedIndex)));
		if (IsBlizzCon()) then
			if (BLIZZCON_IS_A_GO) then
				EnterWorld();
			else
				SetGlueScreen("charcreate");
			end
		end
	elseif ( event == "UPDATE_SELECTED_CHARACTER" ) then
		local charID = ...;
		if ( charID == 0 ) then
			CharSelectCharacterName:SetText("");
		else
			local index = GetIndexFromCharID(charID);
			self.selectedIndex = index;
			CharSelectCharacterName:SetText(GetCharacterInfo(charID));
		end
		if ((CHARACTER_LIST_OFFSET == 0) and (self.selectedIndex > MAX_CHARACTERS_DISPLAYED)) then
			CHARACTER_LIST_OFFSET = self.selectedIndex - MAX_CHARACTERS_DISPLAYED;
		end
		UpdateCharacterSelection(self);
	elseif ( event == "SELECT_LAST_CHARACTER" ) then
		self.selectLast = 1;
	elseif ( event == "SELECT_FIRST_CHARACTER" ) then
		CHARACTER_LIST_OFFSET = 0;
		CharacterSelect_SelectCharacter(1, 1);
	elseif ( event == "SUGGEST_REALM" ) then
		local category, id = ...;
		local name = GetRealmInfo(category, id);
		if ( name ) then
			SetGlueScreen("charselect");
			ChangeRealm(category, id);
		else
			if ( RealmListUI:IsShown() ) then
				RealmListUpdate();
			else
				SetGlueScreen("realmlist");
			end
		end
	elseif ( event == "FORCE_RENAME_CHARACTER" ) then
		local message = ...;
		CharacterRenameDialog:Show();
		CharacterRenameText1:SetText(_G[message]);
	end
end

function CharacterSelect_UpdateModel(self)
	UpdateSelectionCustomizationScene();
	self:AdvanceTime();
end

function UpdateCharacterSelection(self)
	local button;
	for i=1, MAX_CHARACTERS_DISPLAYED, 1 do
		button = _G["CharSelectCharacterButton"..i];
		button.selection:Hide();
		button.upButton:Hide();
		button.downButton:Hide();
	end

	local index = self.selectedIndex - CHARACTER_LIST_OFFSET;
	if ( (index > 0) and (index <= MAX_CHARACTERS_DISPLAYED) ) then
		button = _G["CharSelectCharacterButton"..index];
		button.selection:Show();
		if ( button:IsMouseOver() ) then
			CharacterSelectButton_ShowMoveButtons(button);
		end
	end
end

function UpdateCharacterList(skipSelect)
	local numChars = GetNumCharacters();
	local index = 1;
	local coords;

	if ( CharacterSelect.selectLast == 1 ) then
		CHARACTER_LIST_OFFSET = max(numChars - MAX_CHARACTERS_DISPLAYED, 0);
		CharacterSelect.selectedIndex = numChars;
		CharacterSelect.selectLast = 0;
	end

	for i=1, numChars, 1 do
		local name, race, class, level, zone, sex, ghost, PCC, PRC, PFC, PRCDisabled = GetCharacterInfo(GetCharIDFromIndex(i+CHARACTER_LIST_OFFSET));
		local button = _G["CharSelectCharacterButton"..index];
		if ( not name ) then
			button:SetText("ERROR - too many characters");
		else
			if ( not zone ) then
				zone = "";
			end
			_G["CharSelectCharacterButton"..index.."ButtonTextName"]:SetText(name);
			if( ghost ) then
				_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetFormattedText(CHARACTER_SELECT_INFO_GHOST, level, class);
			else
				_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetFormattedText(CHARACTER_SELECT_INFO, level, class);
			end
			_G["CharSelectCharacterButton"..index.."ButtonTextLocation"]:SetText(zone);
		end
		button:Show();
		button.index = i + CHARACTER_LIST_OFFSET;

		-- setup paid service button
		local paidServiceButton = _G["CharSelectPaidService"..index];
		local serviceType, disableService;
		if ( PFC ) then
			serviceType = PAID_FACTION_CHANGE;
			paidServiceButton.texture:SetTexCoord(0, 0.5, 0.5, 1);
			paidServiceButton.tooltip = PAID_FACTION_CHANGE_TOOLTIP;
			paidServiceButton.disabledTooltip = nil;
		elseif ( PRC ) then
			serviceType = PAID_RACE_CHANGE;
			paidServiceButton.texture:SetTexCoord(0.5, 1, 0, 0.5);
			disableService = PRCDisabled;
			paidServiceButton.tooltip = PAID_RACE_CHANGE_TOOLTIP;
			paidServiceButton.disabledTooltip = PAID_RACE_CHANGE_DISABLED_TOOLTIP;
		elseif ( PCC ) then
			serviceType = PAID_CHARACTER_CUSTOMIZATION;
			paidServiceButton.texture:SetTexCoord(0, 0.5, 0, 0.5);
			paidServiceButton.tooltip = PAID_CHARACTER_CUSTOMIZE_TOOLTIP;
			paidServiceButton.disabledTooltip = nil;
		end
		if ( serviceType ) then
			paidServiceButton:Show();
			paidServiceButton.serviceType = serviceType;
			if ( disableService ) then
				paidServiceButton:Disable();
				paidServiceButton.texture:SetDesaturated(1);
			elseif ( not paidServiceButton:IsEnabled() ) then
				paidServiceButton.texture:SetDesaturated(0);
				paidServiceButton:Enable();
			end
		else
			paidServiceButton:Hide();
		end

		-- is a button being dragged?
		if ( CharacterSelect.draggedIndex ) then
			if ( CharacterSelect.draggedIndex == button.index ) then
				button:SetAlpha(1);
				button.buttonText.name:SetPoint("TOPLEFT", MOVING_TEXT_OFFSET, -5);
				button:LockHighlight();
				paidServiceButton.texture:SetVertexColor(1, 1, 1);
			else
				button:SetAlpha(0.6);
				button.buttonText.name:SetPoint("TOPLEFT", DEFAULT_TEXT_OFFSET, -5);
				button:UnlockHighlight();
				paidServiceButton.texture:SetVertexColor(0.35, 0.35, 0.35);
			end
		end
		
		index = index + 1;
		if ( index > MAX_CHARACTERS_DISPLAYED ) then
			break;
		end
	end

	if ( numChars == 0 ) then
		CharacterSelectDeleteButton:Disable();
		CharSelectEnterWorldButton:Disable();
	else
		CharacterSelectDeleteButton:Enable();
		CharSelectEnterWorldButton:Enable();
	end

	CharacterSelect.createIndex = 0;
	CharSelectCreateCharacterButton:Hide();	
	
	local connected = IsConnectedToServer();
	for i=index, MAX_CHARACTERS_DISPLAYED, 1 do
		local button = _G["CharSelectCharacterButton"..index];
		if ( (CharacterSelect.createIndex == 0) and (numChars < MAX_CHARACTERS_DISPLAYED) ) then
			CharacterSelect.createIndex = index;
			if ( connected ) then
				--If can create characters position and show the create button
				CharSelectCreateCharacterButton:SetID(index);
				--CharSelectCreateCharacterButton:SetPoint("TOP", button, "TOP", 0, -5);
				CharSelectCreateCharacterButton:Show();	
			end
		end
		_G["CharSelectPaidService"..index]:Hide();
		button:Hide();
		index = index + 1;
	end

	if ( numChars == 0 ) then
		CharacterSelect.selectedIndex = 0;
		CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
		return;
	end

	if ( numChars > MAX_CHARACTERS_DISPLAYED ) then
		CharacterSelectCharacterFrame:SetWidth(280);
		CharacterSelectCharacterFrame.scrollBar:Show();
		CharacterSelectCharacterFrame.scrollBar:SetMinMaxValues(0, numChars - MAX_CHARACTERS_DISPLAYED);
		CharacterSelectCharacterFrame.scrollBar.blockUpdates = true;
		CharacterSelectCharacterFrame.scrollBar:SetValue(CHARACTER_LIST_OFFSET);
		CharacterSelectCharacterFrame.scrollBar.blockUpdates = nil;
	else
		CharacterSelectCharacterFrame.scrollBar.blockUpdates = true;	-- keep mousewheel from doing anything
		CharacterSelectCharacterFrame:SetWidth(260);
		CharacterSelectCharacterFrame.scrollBar:Hide();
	end
	
	if (( numChars >= MAX_CHARACTERS_DISPLAYED ) and (numChars < MAX_CHARACTERS_PER_REALM)) then 
		CreateCharacterButtonSpecial:Show();
	else
		CreateCharacterButtonSpecial:Hide();
	end

	if ( (CharacterSelect.selectedIndex == 0) or (CharacterSelect.selectedIndex > numChars) ) then
		CharacterSelect.selectedIndex = 1;
	end
	
	if ( not skipSelect ) then
		CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
	end
end

function CharacterSelectButton_OnClick(self)
	PlaySound("gsCharacterCreationClass");
	local id = self:GetID() + CHARACTER_LIST_OFFSET;
	if ( id ~= CharacterSelect.selectedIndex ) then
		CharacterSelect_SelectCharacter(id);
	end
end

function CharacterSelectButton_OnDoubleClick(self)
	local id = self:GetID() + CHARACTER_LIST_OFFSET;
	if ( id ~= CharacterSelect.selectedIndex ) then
		CharacterSelect_SelectCharacter(id);
	end
	CharacterSelect_EnterWorld();
end

function CharacterSelectButton_ShowMoveButtons(button)
	local numCharacters = GetNumCharacters();
	if ( numCharacters <= 1 ) then
		return;
	end
	if ( not CharacterSelect.draggedIndex ) then
		button.upButton:Show();
		button.upButton.normalTexture:SetPoint("CENTER", 0, 0);
		button.upButton.highlightTexture:SetPoint("CENTER", 0, 0);
		button.downButton:Show();
		button.downButton.normalTexture:SetPoint("CENTER", 0, 0);
		button.downButton.highlightTexture:SetPoint("CENTER", 0, 0);
		if ( button.index == 1 ) then
			button.upButton:Disable();
			button.upButton:SetAlpha(0.35);
		else
			button.upButton:Enable();
			button.upButton:SetAlpha(1);
		end
		if ( button.index == numCharacters ) then
			button.downButton:Disable();
			button.downButton:SetAlpha(0.35);
		else
			button.downButton:Enable();
			button.downButton:SetAlpha(1);
		end
	end
end

function CharacterSelect_TabResize(self)
	local buttonMiddle = _G[self:GetName().."Middle"];
	local buttonMiddleDisabled = _G[self:GetName().."MiddleDisabled"];
	local width = self:GetTextWidth() - 8;
	local leftWidth = _G[self:GetName().."Left"]:GetWidth();
	buttonMiddle:SetWidth(width);
	buttonMiddleDisabled:SetWidth(width);
	self:SetWidth(width + (2 * leftWidth));
end

function CharacterSelect_SelectCharacter(index, noCreate)
	if ( index == CharacterSelect.createIndex ) then
		if ( not noCreate ) then
			PlaySound("gsCharacterSelectionCreateNew");
			ClearCharacterTemplate();
			SetGlueScreen("charcreate");
		end
	else
		local charID = GetCharIDFromIndex(index);
		SelectCharacter(charID);

		local backgroundFileName = GetSelectBackgroundModel(charID);
		CharacterSelect.currentBGTag = SetBackgroundModel(CharacterSelect, backgroundFileName);
	end
end

function CharacterDeleteDialog_OnShow()
	local name, race, class, level = GetCharacterInfo(GetCharIDFromIndex(CharacterSelect.selectedIndex));
	CharacterDeleteText1:SetFormattedText(CONFIRM_CHAR_DELETE, name, level, class);
	CharacterDeleteBackground:SetHeight(16 + CharacterDeleteText1:GetHeight() + CharacterDeleteText2:GetHeight() + 23 + CharacterDeleteEditBox:GetHeight() + 8 + CharacterDeleteButton1:GetHeight() + 16);
	CharacterDeleteButton1:Disable();
end

function CharacterSelect_EnterWorld()
	CharacterSelect_SaveCharacterOrder();
	PlaySound("gsCharacterSelectionEnterWorld");
	StopGlueAmbience();
	EnterWorld();
end

function CharacterSelect_Exit()
	CharacterSelect_SaveCharacterOrder();
	PlaySound("gsCharacterSelectionExit");
	DisconnectFromServer();
	SetGlueScreen("login");
end

function CharacterSelect_AccountOptions()
	PlaySound("gsCharacterSelectionAcctOptions");
end

function CharacterSelect_TechSupport()
	PlaySound("gsCharacterSelectionAcctOptions");
	LaunchURL(TECH_SUPPORT_URL);
end

function CharacterSelect_Delete()
	PlaySound("gsCharacterSelectionDelCharacter");
	if ( CharacterSelect.selectedIndex > 0 ) then
		CharacterSelect_SaveCharacterOrder();
		CharacterDeleteDialog:Show();
	end
end

function CharacterSelect_ChangeRealm()
	PlaySound("gsCharacterSelectionDelCharacter");
	CharacterSelect_SaveCharacterOrder();
	RequestRealmList(1);
end

function CharacterSelectFrame_OnMouseDown(button)
	if ( button == "LeftButton" ) then
		CHARACTER_SELECT_ROTATION_START_X = GetCursorPosition();
		CHARACTER_SELECT_INITIAL_FACING = GetCharacterSelectFacing();
	end
end

function CharacterSelectFrame_OnMouseUp(button)
	if ( button == "LeftButton" ) then
		CHARACTER_SELECT_ROTATION_START_X = nil
	end
end

function CharacterSelectFrame_OnUpdate()
	if ( CHARACTER_SELECT_ROTATION_START_X ) then
		local x = GetCursorPosition();
		local diff = (x - CHARACTER_SELECT_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
		CHARACTER_SELECT_ROTATION_START_X = GetCursorPosition();
		SetCharacterSelectFacing(GetCharacterSelectFacing() + diff);
	end
end

function CharacterSelectRotateRight_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterSelectFacing(GetCharacterSelectFacing() + CHARACTER_FACING_INCREMENT);
	end
end

function CharacterSelectRotateLeft_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterSelectFacing(GetCharacterSelectFacing() - CHARACTER_FACING_INCREMENT);
	end
end

function CharacterSelect_ManageAccount()
	PlaySound("gsCharacterSelectionAcctOptions");
	LaunchURL(AUTH_NO_TIME_URL);
end

function RealmSplit_GetFormatedChoice(formatText)
	local realmChoice;
	if ( SERVER_SPLIT_CLIENT_STATE == 1 ) then
		realmChoice = SERVER_SPLIT_SERVER_ONE;
	else
		realmChoice = SERVER_SPLIT_SERVER_TWO;
	end
	return format(formatText, realmChoice);
end

function RealmSplit_SetChoiceText()
	RealmSplitCurrentChoice:SetText( RealmSplit_GetFormatedChoice(SERVER_SPLIT_CURRENT_CHOICE) );
	RealmSplitCurrentChoice:Show();
end

function CharacterSelect_PaidServiceOnClick(self, button, down, service)
	PAID_SERVICE_CHARACTER_ID = GetCharIDFromIndex(self:GetID() + CHARACTER_LIST_OFFSET);
	PAID_SERVICE_TYPE = service;
	PlaySound("gsCharacterSelectionCreateNew");
	SetGlueScreen("charcreate");
end

function CharacterSelect_DeathKnightSwap(self)
	local deathKnightTag = "DEATHKNIGHT";
	if ( CharacterSelect.currentBGTag == deathKnightTag ) then
		if (self.currentBGTag ~= deathKnightTag) then
			self.currentBGTag = deathKnightTag;
			self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up-Blue");
			self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down-Blue");
			self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight-Blue");
		end
	else
		if (self.currentBGTag == deathKnightTag) then
			self.currentBGTag = nil;
			self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up");
			self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down");
			self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight");
		end
	end
end

function CharacterSelectScrollDown_OnClick()
	PlaySound("igInventoryRotateCharacter");
	local numChars = GetNumCharacters();
	if ( numChars > 1 ) then
		if ( CharacterSelect.selectedIndex < GetNumCharacters() ) then
			local newIndex = CharacterSelect.selectedIndex + 1;
			if (newIndex > MAX_CHARACTERS_DISPLAYED) then
				CHARACTER_LIST_OFFSET = newIndex - MAX_CHARACTERS_DISPLAYED;
			end
			CharacterSelect_SelectCharacter(newIndex);
		else
			CHARACTER_LIST_OFFSET = 0;
			CharacterSelect_SelectCharacter(1);
		end
		UpdateCharacterList();
	end
end

function CharacterSelectScrollUp_OnClick()
	PlaySound("igInventoryRotateCharacter");
	local numChars = GetNumCharacters();
	if ( numChars > 1 ) then
		if ( CharacterSelect.selectedIndex > 1 ) then
			local newIndex = CharacterSelect.selectedIndex - 1;
			if (newIndex >= MAX_CHARACTERS_DISPLAYED) then
				CHARACTER_LIST_OFFSET = max(newIndex - MAX_CHARACTERS_DISPLAYED, 0);
			end
			CharacterSelect_SelectCharacter(newIndex);
		else
			CHARACTER_LIST_OFFSET = max(numChars - MAX_CHARACTERS_DISPLAYED, 0);
			CharacterSelect_SelectCharacter(numChars);
		end
		UpdateCharacterList();
	end
end

function CharacterSelectButton_OnDragUpdate(self)
	-- shouldn't be doing this without an index...
	if ( not CharacterSelect.draggedIndex ) then
		CharacterSelectButton_OnDragStop(self);
		return;
	end
	-- only check Y-axis, user dragging horizontally should not change anything	
	local _, cursorY = GetCursorPosition();
	if ( cursorY <= CHARACTER_LIST_TOP ) then
		-- check if the mouse is on a different button
		local buttonIndex = floor((CHARACTER_LIST_TOP - cursorY) / CHARACTER_BUTTON_HEIGHT) + 1;
		local button = _G["CharSelectCharacterButton"..buttonIndex];
		if ( button and button.index ~= CharacterSelect.draggedIndex and button:IsShown() ) then
			-- perform move
			if ( button.index > CharacterSelect.draggedIndex ) then
				-- move down
				MoveCharacter(CharacterSelect.draggedIndex, CharacterSelect.draggedIndex + 1, true);
			else
				-- move up
				MoveCharacter(CharacterSelect.draggedIndex, CharacterSelect.draggedIndex - 1, true);
			end
		end
	end
end

function CharacterSelectButton_OnDragStart(self)
	if ( GetNumCharacters() > 1 ) then
		CharacterSelect.pressDownButton = nil;
		CharacterSelect.draggedIndex = self:GetID() + CHARACTER_LIST_OFFSET;
		self:SetScript("OnUpdate", CharacterSelectButton_OnDragUpdate);	
		for index = 1, MAX_CHARACTERS_DISPLAYED do
			local button = _G["CharSelectCharacterButton"..index];
			if ( button ~= self ) then
				button:SetAlpha(0.6);
				_G["CharSelectPaidService"..index].texture:SetVertexColor(0.35, 0.35, 0.35);
			end
		end
		self.buttonText.name:SetPoint("TOPLEFT", MOVING_TEXT_OFFSET, -5);
		self:LockHighlight();
		self.upButton:Hide();
		self.downButton:Hide();
	end
end

function CharacterSelectButton_OnDragStop(self)
	CharacterSelect.pressDownButton = nil;
	CharacterSelect.draggedIndex = nil;
	self:SetScript("OnUpdate", nil);
	for index = 1, MAX_CHARACTERS_DISPLAYED do
		local button = _G["CharSelectCharacterButton"..index];
		button:SetAlpha(1);
		button:UnlockHighlight();
		button.buttonText.name:SetPoint("TOPLEFT", DEFAULT_TEXT_OFFSET, -5);
		_G["CharSelectPaidService"..index].texture:SetVertexColor(1, 1, 1);
		if ( button.selection:IsShown() and button:IsMouseOver() ) then
			CharacterSelectButton_ShowMoveButtons(button);
		end
	end
end

function MoveCharacter(originIndex, targetIndex, fromDrag)
	CharacterSelect.orderChanged = true;
	if ( targetIndex < 1 ) then
		targetIndex = #translationTable;
	elseif ( targetIndex > #translationTable ) then
		targetIndex = 1;
	end
	if ( originIndex == CharacterSelect.selectedIndex ) then
		CharacterSelect.selectedIndex = targetIndex;
	elseif ( targetIndex == CharacterSelect.selectedIndex ) then
		CharacterSelect.selectedIndex = originIndex;
	end
	translationTable[originIndex], translationTable[targetIndex] = translationTable[targetIndex], translationTable[originIndex];
	-- update character list
	if ( fromDrag ) then
		CharacterSelect.draggedIndex = targetIndex;
	end
	UpdateCharacterSelection(CharacterSelect);
	UpdateCharacterList();
end

-- translation functions
function GetCharIDFromIndex(index)
	return translationTable[index] or 0;
end

function GetIndexFromCharID(charID)
	-- no need for lookup if the order hasn't changed
	if ( not CharacterSelect.orderChanged ) then
		return charID;
	end
	for index = 1, #translationTable do
		if ( translationTable[index] == charID ) then
			return index;
		end
	end
	return 0;
end


ACCOUNT_UPGRADE_FEATURES = {
	TRIAL =	{ [1] = { icon = "Interface\\Icons\\achievement_level_80", text = UPGRADE_FEATURE_4 },
		  [2] = { icon = "Interface\\Icons\\achievement_boss_lichking", text = UPGRADE_FEATURE_5 },
		  [3] = { icon = "Interface\\Icons\\achievement_zone_icecrown_01", text = UPGRADE_FEATURE_6 },
		  logo = "Interface\\Glues\\Common\\Glues-WoW-WotLKLogo",
		  banner = { 0.0, 0.777, 0.411, 0.546 }},
	[1] =	{ [1] = { icon = "Interface\\Icons\\achievement_level_80", text = UPGRADE_FEATURE_4 },
		  [2] = { icon = "Interface\\Icons\\achievement_boss_lichking", text = UPGRADE_FEATURE_5 },
		  [3] = { icon = "Interface\\Icons\\achievement_zone_icecrown_01", text = UPGRADE_FEATURE_6 },
		  logo = "Interface\\Glues\\Common\\Glues-WoW-WotLKLogo",
		  banner = { 0.0, 0.777, 0.411, 0.546 }},
	[2] =	{ [1] = { icon = "Interface\\Icons\\achievement_level_85", text = UPGRADE_FEATURE_7 },
		  [2] = { icon = "Interface\\Icons\\achievement_firelands raid_ragnaros", text = UPGRADE_FEATURE_8 },
		  [3] = { icon = "Interface\\Icons\\Ability_Mount_CelestialHorse", text = UPGRADE_FEATURE_9 },
		  logo = "Interface\\Glues\\Common\\Glues-WoW-CCLogo",
		  banner = { 0.0, 0.777, 0.138, 0.272 }},
	[3] =	{ [1] = { icon = "Interface\\Icons\\achievement_level_90", text = UPGRADE_FEATURE_10 },
		  [2] = { icon = "Interface\\Glues\\AccountUpgrade\\upgrade-panda", text = UPGRADE_FEATURE_11 },
		  [3] = { icon = "Interface\\Icons\\achievement_zone_jadeforest", text = UPGRADE_FEATURE_12 },
		  logo = "Interface\\Glues\\Common\\Glues-WoW-MPLogo",
		  banner = { 0.0, 0.777, 0.5468, 0.6826 }},
}

-- Account upgrade panel
function AccountUpgradePanel_Update(isExpanded)
	local tag = nil;
	if ( IsTrialAccount() ) then
		tag = "TRIAL";
	else
		tag = max(GetAccountExpansionLevel(), GetExpansionLevel());
		if ( IsExpansionTrial() ) then
			tag = tag - 1;
		end
	end

	if ( EXPANSION_LOGOS[tag] ) then
		CharacterSelectLogo:SetTexture(EXPANSION_LOGOS[tag]);
		CharacterSelectLogo:Show();
	else
		CharacterSelectLogo:Hide();
	end

	--We don't want to show the upgrade panel in Asian countries for now.
	if ( NEVER_SHOW_UPGRADE ) then
		CharSelectAccountUpgradePanel:Hide();
		CharSelectAccountUpgradeButton:Hide();
		CharSelectAccountUpgradeMiniPanel:Hide();
		return;
	end

	if ( (not IsTrialAccount() and not CanUpgradeExpansion()) or not ACCOUNT_UPGRADE_FEATURES[tag] ) then
		CharSelectAccountUpgradePanel:Hide();
		CharSelectAccountUpgradeButton:Hide();
		CharSelectAccountUpgradeMiniPanel:Hide();
		GameRoomBillingFrame:SetPoint("TOP", CharacterSelectLogo, "BOTTOM", 0, -50);
	else
		GameRoomBillingFrame:SetPoint("TOP", CharSelectAccountUpgradePanel, "BOTTOM", 0, -10);
		local featureTable = ACCOUNT_UPGRADE_FEATURES[tag];
		CharSelectAccountUpgradeButton:Show();
		if ( isExpanded ) then
			CharSelectAccountUpgradePanel:Show();
			CharSelectAccountUpgradeMiniPanel:Hide();

			CharSelectAccountUpgradePanel.logo:SetTexture(featureTable.logo);
			CharSelectAccountUpgradePanel.banner:SetTexCoord(unpack(featureTable.banner));

			local featureFrames = CharSelectAccountUpgradePanel.featureFrames;
			for i=1, #featureTable do
				local frame = featureFrames[i];
				if ( not frame ) then
					frame = CreateFrame("FRAME", "CharSelectAccountUpgradePanelFeature"..i, CharSelectAccountUpgradePanel, "UpgradeFrameFeatureTemplate");
					frame:SetPoint("TOPLEFT", featureFrames[i - 1], "BOTTOMLEFT", 0, 0);
				end

				frame.icon:SetTexture(featureTable[i].icon);
				frame.text:SetText(featureTable[i].text);
			end
			for i=#featureTable + 1, #featureFrames do
				featureFrames[i]:Hide();
			end

			CharSelectAccountUpgradeButtonExpandCollapseButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up");
			CharSelectAccountUpgradeButtonExpandCollapseButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down");
			CharSelectAccountUpgradeButtonExpandCollapseButton:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Disabled");
		else
			CharSelectAccountUpgradePanel:Hide();
			CharSelectAccountUpgradeMiniPanel:Show();

			CharSelectAccountUpgradeMiniPanel.logo:SetTexture(featureTable.logo);
			CharSelectAccountUpgradeMiniPanel.banner:SetTexCoord(unpack(featureTable.banner));

			CharSelectAccountUpgradeButtonExpandCollapseButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up");
			CharSelectAccountUpgradeButtonExpandCollapseButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down");
			CharSelectAccountUpgradeButtonExpandCollapseButton:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled");
		end
	end
	CharSelectAccountUpgradeButton.isExpanded = isExpanded;
	SetCVar("expandUpgradePanel", isExpanded and "1" or "0");
end

function AccountUpgradePanel_ToggleExpandState()
	AccountUpgradePanel_Update(not CharSelectAccountUpgradeButton.isExpanded);
end

function CharacterSelect_ScrollList(self, value)
	if ( not self.blockUpdates ) then
		CHARACTER_LIST_OFFSET = value;
		UpdateCharacterList(true);	-- skip selecting
		UpdateCharacterSelection(CharacterSelect);	-- for button selection
	end
end

function CharacterTemplatesFrame_Update()
	local self = CharacterTemplatesFrame;
	local numTemplates = GetNumCharacterTemplates();
	if ( numTemplates > 0 ) then
		if ( not self:IsShown() ) then
			-- set it up
			self:Show();
			GlueDropDownMenu_SetWidth(self.dropDown, 160);
			GlueDropDownMenu_Initialize(self.dropDown, CharacterTemplatesFrameDropDown_Initialize);
			GlueDropDownMenu_SetSelectedID(self.dropDown, 1);
		end
	else
		self:Hide();
	end
end

function CharacterTemplatesFrameDropDown_Initialize()
	local info = GlueDropDownMenu_CreateInfo();
	for i = 1, GetNumCharacterTemplates() do
		local name, description = GetCharacterTemplateInfo(i);
		info.text = name;
		info.checked = nil;
		info.func = CharacterTemplatesFrameDropDown_OnClick;
		info.tooltipTitle = name;
		info.tooltipText = description;
		GlueDropDownMenu_AddButton(info);
	end
end

function CharacterTemplatesFrameDropDown_OnClick(button)
	GlueDropDownMenu_SetSelectedID(CharacterTemplatesFrameDropDown, button:GetID());
end
