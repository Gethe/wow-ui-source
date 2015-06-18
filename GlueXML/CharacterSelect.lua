CHARACTER_SELECT_ROTATION_START_X = nil;
CHARACTER_SELECT_INITIAL_FACING = nil;

CHARACTER_ROTATION_CONSTANT = 0.6;

MAX_CHARACTERS_DISPLAYED = 11;
MAX_CHARACTERS_DISPLAYED_BASE = MAX_CHARACTERS_DISPLAYED;

MAX_CHARACTERS_PER_REALM = 200; -- controled by the server now, so lets set it up high

CHARACTER_LIST_OFFSET = 0;

CHARACTER_SELECT_BACK_FROM_CREATE = false;

MOVING_TEXT_OFFSET = 12;
DEFAULT_TEXT_OFFSET = 0;
CHARACTER_BUTTON_HEIGHT = 57;
CHARACTER_LIST_TOP = 688;
AUTO_DRAG_TIME = 0.5;				-- in seconds

CHARACTER_UNDELETE_COOLDOWN = 0;	-- in days
CHARACTER_UNDELETE_COOLDOWN_REMAINING = 0; -- in days

local translationTable = { };	-- for character reordering: key = button index, value = character ID

BLIZZCON_IS_A_GO = false;

local STORE_IS_LOADED = false;
local ADDON_LIST_RECEIVED = false;
CAN_BUY_RESULT_FOUND = false;
TOKEN_COUNT_UPDATED = false;

function CharacterSelect_OnLoad(self)
	CharacterSelectModel:SetSequence(0);
	CharacterSelectModel:SetCamera(0);

	self.createIndex = 0;
	self.selectedIndex = 0;
	self.selectLast = false;
	self.currentBGTag = nil;
	self:RegisterEvent("ADDON_LIST_UPDATE");
	self:RegisterEvent("CHARACTER_LIST_UPDATE");
	self:RegisterEvent("UPDATE_SELECTED_CHARACTER");
	self:RegisterEvent("SELECT_LAST_CHARACTER");
	self:RegisterEvent("SELECT_FIRST_CHARACTER");
	self:RegisterEvent("SUGGEST_REALM");
	self:RegisterEvent("FORCE_RENAME_CHARACTER");
	self:RegisterEvent("STORE_STATUS_CHANGED");
	self:RegisterEvent("CHARACTER_UNDELETE_STATUS_CHANGED");
	self:RegisterEvent("CHARACTER_UNDELETE_FINISHED");
	self:RegisterEvent("TOKEN_CAN_VETERAN_BUY_UPDATE");
	self:RegisterEvent("TOKEN_DISTRIBUTIONS_UPDATED");
	self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
	self:RegisterEvent("VAS_CHARACTER_STATE_CHANGED");

	-- CharacterSelect:SetModel("Interface\\Glues\\Models\\UI_Orc\\UI_Orc.m2");

	-- local fogInfo = CharModelFogInfo["ORC"];
	-- CharacterSelect:SetFogColor(fogInfo.r, fogInfo.g, fogInfo.b);
	-- CharacterSelect:SetFogNear(0);
	-- CharacterSelect:SetFogFar(fogInfo.far);

	SetCharSelectModelFrame("CharacterSelectModel");

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
	DebugLog("Select_OnShow");
	CHARACTER_LIST_OFFSET = 0;
	CharacterSelect_ResetVeteranStatus();

	-- request account data times from the server (so we know if we should refresh keybindings, etc...)
	CheckCharacterUndeleteCooldown();
	
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

	--Clear out the addons selected item
	GlueDropDownMenu_SetSelectedValue(AddonCharacterDropDown, true);

	AccountUpgradePanel_Update(CharSelectAccountUpgradeButton.isExpanded);

	if( IsBlizzCon() ) then
		CharacterSelectUI:Hide();
	end
	
	-- character templates
	CharacterTemplatesFrame_Update();
	
	PlayersOnServer_Update();

	CharacterSelect_UpdateStoreButton();

	CharacterServicesMaster_UpdateServiceButton();

	C_PurchaseAPI.GetPurchaseList();
	C_PurchaseAPI.GetProductList();
	C_StoreGlue.UpdateVASPurchaseStates();

	if (not STORE_IS_LOADED) then
		STORE_IS_LOADED = LoadAddOn("Blizzard_StoreUI")
		LoadAddOn("Blizzard_AuthChallengeUI");		
	end
	
	CharacterSelect_CheckVeteranStatus();
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
	AccountReactivate_CloseDialogs();
	if ( DeclensionFrame ) then
		DeclensionFrame:Hide();
	end
	SERVER_SPLIT_STATE_PENDING = -1;
	
	PromotionFrame_Hide();
	C_AuthChallenge.Cancel();
	if ( StoreFrame ) then
		StoreFrame:Hide();
	end
	CopyCharacterFrame:Hide();
	if (AddonDialog:IsShown()) then
		AddonDialog:Hide();
		HasShownAddonOutOfDateDialog = false;
	end

	AccountReactivate_CloseDialogs();
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
	
	if ( self.undeleteFailed ) then
		if (not GlueDialog:IsShown()) then
			GlueDialog_Show(self.undeleteFailed == "name" and "UNDELETE_NAME_TAKEN" or "UNDELETE_FAILED");
			self.undeleteFailed = false;
		end
	end

	if ( self.undeleteSucceeded ) then
		if (not GlueDialog:IsShown()) then
			GlueDialog_Show(self.undeletePendingRename and "UNDELETE_SUCCEEDED_NAME_TAKEN" or "UNDELETE_SUCCEEDED");
			self.undeleteSucceeded = false;
			self.undeletePendingRename = false;
		end
	end

	if ( self.pressDownButton ) then
		self.pressDownTime = self.pressDownTime + elapsed;
		if ( self.pressDownTime >= AUTO_DRAG_TIME ) then
			CharacterSelectButton_OnDragStart(self.pressDownButton);
		end
	end

	if ( C_CharacterServices.HasQueuedUpgrade() or C_StoreGlue.GetVASProductReady() ) then
		CharacterServicesMaster_OnCharacterListUpdate();
	end

	if (STORE_IS_LOADED and StoreFrame_WaitingForCharacterListUpdate()) then
		StoreFrame_OnCharacterListUpdate();
	end
end

function CharacterSelect_OnKeyDown(self,key)
	if ( key == "ESCAPE" ) then
		if ( TOSFrame:IsShown() or ConnectionHelpFrame:IsShown() ) then
			return;
		elseif ( IsLauncherLogin() ) then
			GlueMenuFrame:SetShown(not GlueMenuFrame:IsShown());
		elseif (CharSelectServicesFlowFrame:IsShown()) then
			CharSelectServicesFlowFrame:Hide();
		elseif ( CopyCharacterFrame:IsShown() ) then
			CopyCharacterFrame:Hide();
		elseif (CharacterSelect.undeleting) then
			CharacterSelect_EndCharacterUndelete();
		else
			CharacterSelect_Exit();
		end
	elseif ( key == "ENTER" ) then
		if (not CharacterSelect_AllowedToEnterWorld()) then
			return;
		end
		CharacterSelect_EnterWorld();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	elseif ( key == "UP" or key == "LEFT" ) then
		if (CharSelectServicesFlowFrame:IsShown()) then
			return;
		end
		CharacterSelectScrollUp_OnClick();
	elseif ( key == "DOWN" or key == "RIGHT" ) then
		if (CharSelectServicesFlowFrame:IsShown()) then
			return;
		end
		CharacterSelectScrollDown_OnClick();
	end
end

function CharacterSelect_OnEvent(self, event, ...)
	if ( event == "ADDON_LIST_UPDATE" ) then
		ADDON_LIST_RECEIVED = true;
		if (not STORE_IS_LOADED) then
			STORE_IS_LOADED = LoadAddOn("Blizzard_StoreUI");
			LoadAddOn("Blizzard_AuthChallengeUI");
			CharacterSelect_UpdateStoreButton();
		end
		UpdateAddonButton();
	elseif ( event == "CHARACTER_LIST_UPDATE" ) then
		PromotionFrame_AwaitingPromotion();
	
		local listSize = ...;
		if ( listSize ) then
			table.wipe(translationTable);
			for i = 1, listSize do
				tinsert(translationTable, i);
			end
			CharacterSelect.orderChanged = nil;
		end
		local numChars = GetNumCharacters();
		if (self.undeleting and numChars == 0) then
			CharacterSelect_EndCharacterUndelete();
			self.undeleteNoCharacters = true;
			return;
		elseif (not CHARACTER_SELECT_BACK_FROM_CREATE and numChars == 0) then
			SetGlueScreen("charcreate");
			return;
		end
		if (self.undeleteNoCharacters) then
			GlueDialog_Show("UNDELETE_NO_CHARACTERS");
			self.undeleteNoCharacters = false;
		end

		UpdateCharacterList();
		UpdateAddonButton(true);
		CharSelectCharacterName:SetText(GetCharacterInfo(GetCharIDFromIndex(self.selectedIndex)));
		if (IsBlizzCon()) then
			if (BLIZZCON_IS_A_GO) then
				EnterWorld();
			else
				SetGlueScreen("charcreate");
			end
		end
		CharacterServicesMaster_OnCharacterListUpdate();
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
		self.selectLast = true;
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
	elseif ( event == "STORE_STATUS_CHANGED" ) then
		if (ADDON_LIST_RECEIVED) then
			CharacterSelect_UpdateStoreButton();
		end
	elseif ( event == "CHARACTER_UNDELETE_STATUS_CHANGED") then
		local enabled, onCooldown, cooldown, remaining = GetCharacterUndeleteStatus();

		CHARACTER_UNDELETE_COOLDOWN = cooldown;
		CHARACTER_UNDELETE_COOLDOWN_REMAINING = remaining;

		CharSelectUndeleteCharacterButton:SetEnabled(enabled and not onCooldown);
		if (not enabled) then
			CharSelectUndeleteCharacterButton.tooltip = UNDELETE_TOOLTIP_DISABLED;
		elseif (onCooldown) then
			CharSelectUndeleteCharacterButton.tooltip = UNDELETE_TOOLTIP_COOLDOWN:format(CHARACTER_UNDELETE_COOLDOWN_REMAINING);
		else
			CharSelectUndeleteCharacterButton.tooltip = UNDELETE_TOOLTIP;
		end
	elseif ( event == "CHARACTER_UNDELETE_FINISHED" ) then
		local result, guid = ...;

		if ( result == LE_CHARACTER_UNDELETE_RESULT_OK ) then
			self.undeleteGuid = guid;
			self.undeleteFailed = nil;
		else
			self.undeleteGuid = nil;
			if ( result == LE_CHARACTER_UNDELETE_RESULT_ERROR_NAME_TAKEN_BY_THIS_ACCOUNT ) then
				self.undeleteFailed = "name";
			else
				self.undeleteFailed = "other";
			end
		end
	elseif ( event == "TOKEN_DISTRIBUTIONS_UPDATED" ) then
		local result = ...;
		-- TODO: Use lua enum
		if (result == 1) then
			TOKEN_COUNT_UPDATED = true;
			CharacterSelect_CheckVeteranStatus();
		end
	elseif ( event == "TOKEN_CAN_VETERAN_BUY_UPDATE" ) then
		local result = ...;
		CAN_BUY_RESULT_FOUND = result;
		CharacterSelect_CheckVeteranStatus();
	elseif ( event == "TOKEN_MARKET_PRICE_UPDATED" ) then
		local result = ...;
		CharacterSelect_CheckVeteranStatus();
	elseif (event == "VAS_CHARACTER_STATE_CHANGED") then
		if ( not IsCharacterListUpdatePending() ) then
			UpdateCharacterList();
		end
	end
end

function CharacterSelect_UpdateModel(self)
	UpdateSelectionCustomizationScene();
	self:AdvanceTime();
end

function UpdateCharacterSelection(self)
	local button, paidServiceButton;

	for i=1, MAX_CHARACTERS_DISPLAYED, 1 do
		button = _G["CharSelectCharacterButton"..i];
		paidServiceButton = _G["CharSelectPaidService"..i];
		button.selection:Hide();
		button.upButton:Hide();
		button.downButton:Hide();
		if (self.undeleting) then
			paidServiceButton:Hide();
			CharacterSelectButton_DisableDrag(button);
		else
			CharacterSelectButton_EnableDrag(button);
		end
	end

	local index = self.selectedIndex - CHARACTER_LIST_OFFSET;
	if ( (index > 0) and (index <= MAX_CHARACTERS_DISPLAYED) ) then
		button = _G["CharSelectCharacterButton"..index];
		paidServiceButton = _G["CharSelectPaidService"..index];

		if ( button ) then
			button.selection:Show();
			if ( button:IsMouseOver() ) then
				CharacterSelectButton_ShowMoveButtons(button);
			end
			if ( self.undeleting ) then
				paidServiceButton.GoldBorder:Hide();
				paidServiceButton.VASIcon:Hide();
				paidServiceButton.texture:SetTexCoord(.5, 1, .5, 1);
				paidServiceButton.texture:Show();
				paidServiceButton.tooltip = UNDELETE_SERVICE_TOOLTIP;
				paidServiceButton.disabledTooltip = nil;
				paidServiceButton:Show();
			end

			CharacterSelect_UpdateButtonState();
		end
	end
end

function UpdateCharacterList(skipSelect)
	local numChars = GetNumCharacters();
	local index = 1;
	local coords;

	if ( CharacterSelect.undeleteChanged ) then
		CHARACTER_LIST_OFFSET = 0;
		CharacterSelect.undeleteChanged = false;
	end

	if ( numChars < MAX_CHARACTERS_PER_REALM or
		( (CharacterSelect.undeleting and numChars >= MAX_CHARACTERS_DISPLAYED_BASE) or
		numChars > MAX_CHARACTERS_DISPLAYED_BASE) ) then
		if (MAX_CHARACTERS_DISPLAYED == MAX_CHARACTERS_DISPLAYED_BASE) then
			MAX_CHARACTERS_DISPLAYED = MAX_CHARACTERS_DISPLAYED_BASE - 1;
		end
	else
		MAX_CHARACTERS_DISPLAYED = MAX_CHARACTERS_DISPLAYED_BASE;
	end

	-- select the last("newest") character
	if ( CharacterSelect.selectLast ) then
		CHARACTER_LIST_OFFSET = max(numChars - MAX_CHARACTERS_DISPLAYED, 0);
		CharacterSelect.selectedIndex = numChars;
		CharacterSelect.selectLast = false;
	end

	if ( CharacterSelect.undeleteGuid ) then
		local found = false;
		repeat
			for i = 1, MAX_CHARACTERS_DISPLAYED, 1 do
				local guid, _, _, _, _, forceRename = select(14, GetCharacterInfo(GetCharIDFromIndex(i + CHARACTER_LIST_OFFSET)));
				if ( guid == CharacterSelect.undeleteGuid ) then
					CharacterSelect.selectedIndex = i + CHARACTER_LIST_OFFSET;
					CharacterSelect.undeleteSucceeded = true;
					CharacterSelect.undeletePendingRename = forceRename;
					found = true;
					break;
				end
			end
			if (not found) then
				CHARACTER_LIST_OFFSET = CHARACTER_LIST_OFFSET + 1;
			end
		until found;
		CharacterSelect.undeleteGuid = nil;
	end

	local debugText = numChars..": ";
	for i=1, numChars, 1 do
		local name, race, class, classFileName, classID, level, zone, sex, ghost, PCC, PRC, PFC, PRCDisabled, guid, _, _, _, boostInProgress, _, locked = GetCharacterInfo(GetCharIDFromIndex(i+CHARACTER_LIST_OFFSET));
		local productID, vasServiceState, vasServiceErrors = C_StoreGlue.GetVASPurchaseStateInfo(guid);
		local button = _G["CharSelectCharacterButton"..index];
		button.isVeteranLocked = false;
		if ( name ) then
			if ( not zone ) then
				zone = "";
			end
			if ( CharacterSelect.undeleting ) then
				_G["CharSelectCharacterButton"..index.."ButtonTextName"]:SetFormattedText(CHARACTER_SELECT_NAME_DELETED, name);
			elseif ( locked ) then
				_G["CharSelectCharacterButton"..index.."ButtonTextName"]:SetText(name..CHARSELECT_CHAR_INACTIVE_CHAR);
			else
				_G["CharSelectCharacterButton"..index.."ButtonTextName"]:SetText(name);
			end
			if (vasServiceState == LE_VAS_PURCHASE_STATE_APPLYING_LICENSE and vasServiceErrors) then
				local name = select(7, C_PurchaseAPI.GetProductInfo(productID));
				_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetText("|cffff2020"..VAS_ERROR_ERROR_HAS_OCCURRED.."|r");
				_G["CharSelectCharacterButton"..index.."ButtonTextLocation"]:SetText("|cffff2020"..name.."|r");
			elseif (vasServiceState == LE_VAS_PURCHASE_STATE_PROCESSING_FACTION_CHANGE) then
				_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetText(CHARACTER_UPGRADE_PROCESSING);
				_G["CharSelectCharacterButton"..index.."ButtonTextLocation"]:SetFontObject("GlueFontHighlightSmall");
				_G["CharSelectCharacterButton"..index.."ButtonTextLocation"]:SetText(FACTION_CHANGE_CHARACTER_LIST_LABEL);
			elseif (boostInProgress) then
				_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetText(CHARACTER_UPGRADE_PROCESSING);
				_G["CharSelectCharacterButton"..index.."ButtonTextLocation"]:SetFontObject("GlueFontHighlightSmall");
				_G["CharSelectCharacterButton"..index.."ButtonTextLocation"]:SetText(CHARACTER_UPGRADE_CHARACTER_LIST_LABEL);
			else
				if ( locked ) then
					button.isVeteranLocked = true;
				end
				if( ghost ) then
					_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetFormattedText(CHARACTER_SELECT_INFO_GHOST, level, class);
				else
					_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetFormattedText(CHARACTER_SELECT_INFO, level, class);
				end
				_G["CharSelectCharacterButton"..index.."ButtonTextLocation"]:SetFontObject("GlueFontDisableSmall");
				_G["CharSelectCharacterButton"..index.."ButtonTextLocation"]:SetText(zone);
			end
		end
		button:Show();
		button.index = i + CHARACTER_LIST_OFFSET;

		-- setup paid service button
		local paidServiceButton = _G["CharSelectPaidService"..index];
		local upgradeIcon = _G["CharacterServicesProcessingIcon"..index];
		upgradeIcon:Hide();
		local serviceType, disableService;
		if (vasServiceState == LE_VAS_PURCHASE_STATE_PAYMENT_PENDING) then
			upgradeIcon:Show();
			upgradeIcon.tooltip = CHARACTER_UPGRADE_PROCESSING;
			upgradeIcon.tooltip2 = CHARACTER_STATE_ORDER_PROCESSING;
		elseif (vasServiceState == LE_VAS_PURCHASE_STATE_APPLYING_LICENSE and vasServiceErrors) then
			upgradeIcon:Show();
			local tooltip, desc;
			if (STORE_IS_LOADED) then
				local info = StoreFrame_GetVASErrorMessage(guid, vasServiceErrors);
				if (info) then
					if (info.other) then
						tooltip = VAS_ERROR_ERROR_HAS_OCCURRED;
					else
						tooltip = VAS_ERROR_ADDRESS_THESE_ISSUES;
					end
					desc = info.desc;
				else
					tooltip = VAS_ERROR_ERROR_HAS_OCCURRED;
					desc = BLIZZARD_STORE_VAS_ERROR_OTHER;
				end
			else
				tooltip = VAS_ERROR_ERROR_HAS_OCCURRED;
				desc = BLIZZARD_STORE_VAS_ERROR_OTHER;
			end
			upgradeIcon.tooltip = "|cffffd200" .. tooltip .. "|r";
			upgradeIcon.tooltip2 = "|cffff2020" .. desc .. "|r";
		elseif (boostInProgress or vasServiceState == LE_VAS_PURCHASE_STATE_PROCESSING_FACTION_CHANGE) then
			upgradeIcon:Show();
			upgradeIcon.tooltip = CHARACTER_UPGRADE_PROCESSING;
			upgradeIcon.tooltip2 = CHARACTER_SERVICES_PLEASE_WAIT;
		elseif ( CharacterSelect.undeleting ) then
			paidServiceButton:Hide();
		elseif ( PFC ) then
			serviceType = PAID_FACTION_CHANGE;
			paidServiceButton.GoldBorder:Show();
			paidServiceButton.VASIcon:SetTexture("Interface\\Icons\\VAS_FactionChange");
			paidServiceButton.VASIcon:Show();
			paidServiceButton.texture:Hide();
			paidServiceButton.tooltip = PAID_FACTION_CHANGE_TOOLTIP;
			paidServiceButton.disabledTooltip = nil;
		elseif ( PRC ) then
			serviceType = PAID_RACE_CHANGE;
			paidServiceButton.GoldBorder:Show();
			paidServiceButton.VASIcon:SetTexture("Interface\\Icons\\VAS_RaceChange");
			paidServiceButton.VASIcon:Show();
			paidServiceButton.texture:Hide();
			disableService = PRCDisabled;
			paidServiceButton.tooltip = PAID_RACE_CHANGE_TOOLTIP;
			paidServiceButton.disabledTooltip = PAID_RACE_CHANGE_DISABLED_TOOLTIP;
		elseif ( PCC ) then
			serviceType = PAID_CHARACTER_CUSTOMIZATION;
			paidServiceButton.GoldBorder:Show();
			paidServiceButton.VASIcon:SetTexture("Interface\\Icons\\VAS_AppearanceChange");
			paidServiceButton.VASIcon:Show();
			paidServiceButton.texture:Hide();
			paidServiceButton.tooltip = PAID_CHARACTER_CUSTOMIZE_TOOLTIP;
			paidServiceButton.disabledTooltip = nil;
		end
		if ( serviceType ) then
			debugText = debugText.." "..(GetCharIDFromIndex(i+CHARACTER_LIST_OFFSET));
			paidServiceButton:Show();
			paidServiceButton.serviceType = serviceType;
			if ( disableService ) then
				paidServiceButton:Disable();
				paidServiceButton.texture:SetDesaturated(true);
				paidServiceButton.GoldBorder:SetDesaturated(true);
				paidServiceButton.VASIcon:SetDesaturated(true);
			elseif ( not paidServiceButton:IsEnabled() ) then
				paidServiceButton.texture:SetDesaturated(false);
				paidServiceButton.GoldBorder:SetDesaturated(false);
				paidServiceButton.VASIcon:SetDesaturated(false);
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
				paidServiceButton.GoldBorder:SetVertexColor(1, 1, 1);
				paidServiceButton.VASIcon:SetVertexColor(1, 1, 1);
			else
				button:SetAlpha(0.6);
				button.buttonText.name:SetPoint("TOPLEFT", DEFAULT_TEXT_OFFSET, -5);
				button:UnlockHighlight();
				paidServiceButton.texture:SetVertexColor(0.35, 0.35, 0.35);
				paidServiceButton.GoldBorder:SetVertexColor(0.35, 0.35, 0.35);
				paidServiceButton.VASIcon:SetVertexColor(0.35, 0.35, 0.35);
			end
		end
		
		index = index + 1;
		if ( index > MAX_CHARACTERS_DISPLAYED ) then
			break;
		end
	end
	DebugLog(debugText);
	if ( numChars == 0 ) then
		CharacterSelectDeleteButton:Disable();
		CharSelectEnterWorldButton:Disable();
	else
		CharacterSelect_UpdateButtonState();
	end

	CharacterSelect_UpdateStoreButton();

	CharacterSelect_ResetVeteranStatus();
	CharacterSelect_CheckVeteranStatus();

	CharacterSelect.createIndex = 0;

	CharSelectCreateCharacterButton:Hide();
	CharSelectUndeleteCharacterButton:Hide();
	
	local connected = IsConnectedToServer();
	if (numChars < MAX_CHARACTERS_PER_REALM and not CharacterSelect.undeleting) then
		CharacterSelect.createIndex = numChars + 1;
		if ( connected ) then
			--If can create characters position and show the create button
			CharSelectCreateCharacterButton:SetID(numChars + 1);
			CharSelectCreateCharacterButton:Show();
			CharSelectUndeleteCharacterButton:Show();
		end
	end

	if (MAX_CHARACTERS_DISPLAYED < MAX_CHARACTERS_DISPLAYED_BASE) then
		for i = MAX_CHARACTERS_DISPLAYED + 1, MAX_CHARACTERS_DISPLAYED_BASE, 1 do
			_G["CharSelectCharacterButton"..i]:Hide();
			_G["CharSelectPaidService"..i]:Hide();
			_G["CharacterServicesProcessingIcon"..i]:Hide();
		end
	end

	if (numChars < MAX_CHARACTERS_DISPLAYED) then
		for i = numChars + 1, MAX_CHARACTERS_DISPLAYED, 1 do
			_G["CharSelectCharacterButton"..i]:Hide();
			_G["CharSelectPaidService"..i]:Hide();
			_G["CharacterServicesProcessingIcon"..i]:Hide();
			index = index + 1;
		end
	end

	if ( numChars == 0 ) then
		CharacterSelect.selectedIndex = 0;
		CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
		return;
	end

	if ( numChars > MAX_CHARACTERS_DISPLAYED ) then
		CharSelectCreateCharacterButton:SetPoint("BOTTOM", -26, 15);
		CharSelectBackToActiveButton:SetPoint("BOTTOM", -8, 15);
		CharacterSelectCharacterFrame:SetWidth(280);
		CharacterSelectCharacterFrame.scrollBar:Show();
		CharacterSelectCharacterFrame.scrollBar:SetMinMaxValues(0, numChars - MAX_CHARACTERS_DISPLAYED);
		CharacterSelectCharacterFrame.scrollBar.blockUpdates = true;
		CharacterSelectCharacterFrame.scrollBar:SetValue(CHARACTER_LIST_OFFSET);
		CharacterSelectCharacterFrame.scrollBar.blockUpdates = nil;
	else
		CharSelectCreateCharacterButton:SetPoint("BOTTOM", -18, 15);
		CharSelectBackToActiveButton:SetPoint("BOTTOM", 0, 15);
		CharacterSelectCharacterFrame.scrollBar.blockUpdates = true;	-- keep mousewheel from doing anything
		CharacterSelectCharacterFrame:SetWidth(260);
		CharacterSelectCharacterFrame.scrollBar:Hide();
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
	if (CharacterSelect_AllowedToEnterWorld()) then
		CharacterSelect_EnterWorld();
	end
end

function CharacterSelectButton_ShowMoveButtons(button)
	if (CharacterSelect.undeleting) then return end;
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

		if (not C_WowTokenPublic.GetCurrentMarketPrice() or 
			not CAN_BUY_RESULT_FOUND or (CAN_BUY_RESULT_FOUND ~= LE_TOKEN_RESULT_ERROR_SUCCESS and CAN_BUY_RESULT_FOUND ~= LE_TOKEN_RESULT_ERROR_SUCCESS_NO) ) then
			AccountReactivate_RecheckEligibility();
		end
		ReactivateAccountDialog_Open();
		local backgroundFileName = GetSelectBackgroundModel(charID);
		CharacterSelect.currentBGTag = SetBackgroundModel(CharacterSelectModel, backgroundFileName);
	end
end


function CharacterSelect_SelectCharacterByGUID(guid)
	local num = math.min(GetNumCharacters(), MAX_CHARACTERS_DISPLAYED);

	for i = 1, num do
		if (select(14, GetCharacterInfo(GetCharIDFromIndex(i + CHARACTER_LIST_OFFSET))) == guid) then
			local button = _G["CharSelectCharacterButton"..i];
			CharacterSelectButton_OnClick(button);
			button.selection:Show();
			UpdateCharacterSelection(CharacterSelect);
			GetCharacterListUpdate();
			return true;
		end
	end

	return false;
end

function CharacterDeleteDialog_OnShow()
	local name, race, class, classFileName, classID, level = GetCharacterInfo(GetCharIDFromIndex(CharacterSelect.selectedIndex));
	CharacterDeleteText1:SetFormattedText(CONFIRM_CHAR_DELETE, name, level, class);
	CharacterDeleteBackground:SetHeight(16 + CharacterDeleteText1:GetHeight() + CharacterDeleteText2:GetHeight() + 23 + CharacterDeleteEditBox:GetHeight() + 8 + CharacterDeleteButton1:GetHeight() + 16);
	CharacterDeleteButton1:Disable();
end

function CharacterSelect_EnterWorld()
	CharacterSelect_SaveCharacterOrder();
	PlaySound("gsCharacterSelectionEnterWorld");
	local locked = select(20,GetCharacterInfo(GetCharacterSelection()));
	if ( locked ) then
		SubscriptionRequestDialog_Open();
		return;
	end
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
	RequestRealmList(true);
end

function CharacterSelect_AllowedToEnterWorld()
	if (CharacterSelect.undeleting) then
		return false;
	elseif (AccountReactivationInProgressDialog:IsShown()) then
		return false;
	elseif (GoldReactivateConfirmationDialog:IsShown()) then
		return false;
	elseif (TokenReactivateConfirmationDialog:IsShown()) then
		return false;
	end

	return true;
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
	local translatedIndex =  GetCharIDFromIndex(self:GetID() + CHARACTER_LIST_OFFSET);
	if (translatedIndex <= 0 or translatedIndex > GetNumCharacters()) then
		-- Somehow our character order got borked, reset the offset and get an updated character list.
		CHARACTER_LIST_OFFSET = 0;
		PAID_SERVICE_CHARACTER_ID = nil;
		PAID_SERVICE_TYPE = nil;
		GetCharacterListUpdate();
		return;
	end

	PAID_SERVICE_CHARACTER_ID = translatedIndex;
	PAID_SERVICE_TYPE = service;
	PlaySound("gsCharacterSelectionCreateNew");
	if (CharacterSelect.undeleting) then
		local guid = select(14, GetCharacterInfo(PAID_SERVICE_CHARACTER_ID));
		CharacterSelect.pendingUndeleteGuid = guid;
		GlueDialog_Show("UNDELETE_CONFIRM", UNDELETE_CONFIRMATION:format(CHARACTER_UNDELETE_COOLDOWN));
	else
		SetGlueScreen("charcreate");
	end
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


function CharacterSelectPanelButton_DeathKnightSwap(self)
	local textureBase;
	if ( not self:IsEnabled() ) then
		textureBase = "Interface\\Glues\\Common\\Glue-Panel-Button-Disabled";
	elseif ( self.down ) then
		textureBase = "Interface\\Glues\\Common\\Glue-Panel-Button-Down";
	else
		textureBase = "Interface\\Glues\\Common\\Glue-Panel-Button-Up";
	end

	local deathKnightTag = "DEATHKNIGHT";
	if ( CharacterSelect.currentBGTag == deathKnightTag ) then
		if (self.currentBGTag ~= deathKnightTag or self.texture ~= textureBase) then
			self.currentBGTag = deathKnightTag;
			self.texture = textureBase;
			local suffix;
			if ( self:IsEnabled() ) then
				suffix = "-Blue";
			else
				suffix = "";
			end

			self.Left:SetTexture(textureBase..suffix);
			self.Middle:SetTexture(textureBase..suffix);
			self.Right:SetTexture(textureBase..suffix);
			self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight-Blue");
		end
	else
		if (self.currentBGTag == deathKnightTag or self.texture ~= textureBase) then
			self.currentBGTag = nil;
			self.texture = textureBase;
			self.Left:SetTexture(textureBase);
			self.Middle:SetTexture(textureBase);
			self.Right:SetTexture(textureBase);
			self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight");
		end
	end
end

function CharacterSelectGoldPanelButton_DeathKnightSwap(self)
	local state;
	if ( not self:IsEnabled() ) then
		state = "disabled";
	elseif ( self.down ) then
		state = "down";
	else
		state = "up";
	end

	local deathKnightTag = "DEATHKNIGHT";
	if ( CharacterSelect.currentBGTag == deathKnightTag ) then
		if (self.currentBGTag ~= deathKnightTag or self.state ~= state) then
			self.currentBGTag = deathKnightTag;
			self.state = state;

			if (state == "disabled") then
				local textureBase = "Interface\\Buttons\\UI-DialogBox-goldbutton-disabled";

				self.Left:SetTexture(textureBase.."-left");
				self.Middle:SetTexture(textureBase.."-middle");
				self.Right:SetTexture(textureBase.."-right");
			else
				local textureBase = "UI-DialogBox-goldbutton-" .. state;

				self.Left:SetAtlas(textureBase.."-left-blue");
				self.Middle:SetAtlas(textureBase.."-middle-blue");
				self.Right:SetAtlas(textureBase.."-right-blue");
			end
			self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight-Blue");
		end
	else
		if (self.currentBGTag == deathKnightTag or self.state ~= state) then
			self.currentBGTag = nil;
			self.state = state;

			local textureBase = "Interface\\Buttons\\UI-DialogBox-goldbutton-" .. state;

			self.Left:SetTexture(textureBase.."-left");
			self.Middle:SetTexture(textureBase.."-middle");
			self.Right:SetTexture(textureBase.."-right");
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
		UpdateCharacterSelection(CharacterSelect);
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
		UpdateCharacterSelection(CharacterSelect);
	end
end

function CharacterSelectButton_OnDragUpdate(self)
	-- shouldn't be doing this without an index...
	if ( not CharacterSelect.draggedIndex) then
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

function CharacterSelectButton_DisableDrag(button)
	button:SetScript("OnMouseDown", nil);
	button:SetScript("OnMouseUp", nil);
	button:SetScript("OnDragStart", nil);
	button:SetScript("OnDragStop", nil);
end

function CharacterSelectButton_EnableDrag(button)
	button:SetScript("OnDragStart", CharacterSelectButton_OnDragStart);
	button:SetScript("OnDragStop", CharacterSelectButton_OnDragStop);
	-- Functions here copied from CharacterSelect.xml
	button:SetScript("OnMouseDown", function(self)
		CharacterSelect.pressDownButton = self;
		CharacterSelect.pressDownTime = 0;
	end);
	button:SetScript("OnMouseUp", CharacterSelectButton_OnDragStop);
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
	VETERAN = { [1] = { icon = "Interface\\Icons\\achievement_bg_returnxflags_def_wsg", text = VETERAN_FEATURE_1 },
		  [2] = { icon = "Interface\\Icons\\achievement_reputation_01", text = VETERAN_FEATURE_2 },
		  [3] = { icon = "Interface\\Icons\\spell_holy_surgeoflight", text = VETERAN_FEATURE_3 },
		  logo = "Interface\\Glues\\Common\\Glues-WoW-WODLOGO",
		  banner = "accountupgradebanner-wod"},
	[1] =	{ [1] = { icon = "Interface\\Icons\\achievement_level_85", text = UPGRADE_FEATURE_7 },
		  [2] = { icon = "Interface\\Icons\\achievement_firelands raid_ragnaros", text = UPGRADE_FEATURE_8 },
		  [3] = { icon = "Interface\\Icons\\Ability_Mount_CelestialHorse", text = UPGRADE_FEATURE_9 },
		  logo = "Interface\\Glues\\Common\\Glues-WoW-CCLogo",
		  banner = "accountupgradebanner-cataclysm"},
	[2] =	{ [1] = { icon = "Interface\\Icons\\achievement_level_85", text = UPGRADE_FEATURE_7 },
		  [2] = { icon = "Interface\\Icons\\achievement_firelands raid_ragnaros", text = UPGRADE_FEATURE_8 },
		  [3] = { icon = "Interface\\Icons\\Ability_Mount_CelestialHorse", text = UPGRADE_FEATURE_9 },
		  logo = "Interface\\Glues\\Common\\Glues-WoW-CCLogo",
		  banner = "accountupgradebanner-cataclysm"},
	[3] =	{ [1] = { icon = "Interface\\Icons\\achievement_level_90", text = UPGRADE_FEATURE_10 },
		  [2] = { icon = "Interface\\Glues\\AccountUpgrade\\upgrade-panda", text = UPGRADE_FEATURE_11 },
		  [3] = { icon = "Interface\\Icons\\achievement_zone_jadeforest", text = UPGRADE_FEATURE_12 },
		  logo = "Interface\\Glues\\Common\\Glues-WoW-MPLogo",
		  banner = "accountupgradebanner-mop"},
	[4] =	{ [1] = { icon = "Interface\\Icons\\UI_Promotion_CharacterBoost", text = UPGRADE_FEATURE_13 },
		  [2] = { icon = "Interface\\Icons\\Achievement_Level_100", text = UPGRADE_FEATURE_14 },
		  [3] = { icon = "Interface\\Icons\\UI_Promotion_Garrisons", text = UPGRADE_FEATURE_15 },
		  logo = "Interface\\Glues\\Common\\Glues-WoW-WODLOGO",
		  banner = "accountupgradebanner-wod"},
	[5] =	{ [1] = { icon = "Interface\\Icons\\UI_Promotion_CharacterBoost", text = UPGRADE_FEATURE_13 },
		  [2] = { icon = "Interface\\Icons\\Achievement_Level_100", text = UPGRADE_FEATURE_14 },
		  [3] = { icon = "Interface\\Icons\\UI_Promotion_Garrisons", text = UPGRADE_FEATURE_15 },
		  logo = "Interface\\Glues\\Common\\Glues-WoW-WODLOGO",
		  banner = "accountupgradebanner-wod"},
}

-- Account upgrade panel
function AccountUpgradePanel_Update(isExpanded)
	local tag = nil;
	local logoTag = nil;
	if ( IsTrialAccount() ) then
		-- Trial users have the starter edition logo with an upgrade banner that brings you to the lowest expansion level available.
		tag = max(GetAccountExpansionLevel(), GetExpansionLevel()) - 1;
		logoTag = "TRIAL";
		CharSelectAccountUpgradeButton:SetText(UPGRADE);
	elseif ( IsVeteranTrialAccount() ) then
		-- Trial users have the starter edition logo with an upgrade banner that brings you to the lowest expansion level available.
		tag = "VETERAN";
		logoTag = "VETERAN";
		CharSelectAccountUpgradeButton:SetText(REACTIVATE_ACCOUNT_NOW);
	else
		tag = min(GetClientDisplayExpansionLevel(), max(GetAccountExpansionLevel(), GetExpansionLevel()));
		logoTag = tag;
		if ( IsExpansionTrial() ) then
			tag = tag - 1;
		end
		CharSelectAccountUpgradeButton:SetText(UPGRADE);
	end

	if ( EXPANSION_LOGOS[logoTag] ) then
		CharacterSelectLogo:SetTexture(EXPANSION_LOGOS[logoTag]);
		CharacterSelectLogo:Show();
	else
		CharacterSelectLogo:Hide();
	end

	if ( (not GameLimitedMode_IsActive() and not CanUpgradeExpansion()) or not ACCOUNT_UPGRADE_FEATURES[tag] ) then
		CharSelectAccountUpgradePanel:Hide();
		CharSelectAccountUpgradeButton:Hide();
		CharSelectAccountUpgradeMiniPanel:Hide();
		CharacterSelectServerAlertFrame:SetPoint("TOP", CharacterSelectLogo, "BOTTOM", 0, -5);
	else
		CharacterSelectServerAlertFrame:SetPoint("TOP", CharSelectAccountUpgradeMiniPanel, "BOTTOM", 0, -25);
		local featureTable = ACCOUNT_UPGRADE_FEATURES[tag];
		CharSelectAccountUpgradeButton:Show();
		if ( isExpanded ) then
			CharSelectAccountUpgradePanel:Show();
			CharSelectAccountUpgradeMiniPanel:Hide();

			CharSelectAccountUpgradePanel.logo:SetTexture(featureTable.logo);
			CharSelectAccountUpgradePanel.banner:SetAtlas(featureTable.banner, true);

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
			CharSelectAccountUpgradeMiniPanel.banner:SetAtlas(featureTable.banner, true);

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

function AccountUpgradePanel_UpdateExpandState()
	if ( CharacterSelectServerAlertFrame:IsShown() ) then
		CharSelectAccountUpgradeButton.isExpanded = false;
		CharSelectAccountUpgradeButton.expandCollapseButton:Hide();
	elseif ( GameLimitedMode_IsActive() ) then
		CharSelectAccountUpgradeButton.isExpanded = true;
		CharSelectAccountUpgradeButton.expandCollapseButton:Show();
		CharSelectAccountUpgradeButton.expandCollapseButton:Disable();
	else
		CharSelectAccountUpgradeButton.expandCollapseButton:Show();
		CharSelectAccountUpgradeButton.expandCollapseButton:Enable();
	end
	AccountUpgradePanel_Update(CharSelectAccountUpgradeButton.isExpanded);
end

function CharacterSelect_ScrollList(self, value)
	if ( not self.blockUpdates ) then
		CHARACTER_LIST_OFFSET = floor(value);
		UpdateCharacterList(true);	-- skip selecting
		UpdateCharacterSelection(CharacterSelect);	-- for button selection
		if (CharSelectServicesFlowFrame:IsShown()) then
			CharacterServicesMaster_Restart();
		end
	end
end

function CharacterTemplatesFrame_Update()
	if (IsGMClient() and HideGMOnly()) then
		return;
	end

	local self = CharacterTemplatesFrame;
	local numTemplates = GetNumCharacterTemplates();
	if ( numTemplates > 0 and IsConnectedToServer() ) then
		if ( not self:IsShown() ) then
			-- set it up
			self:Show();
			GlueDropDownMenu_SetAnchor(self.dropDown, -100, 54, "TOP", self, "TOP");
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

function ToggleStoreUI()
	if (STORE_IS_LOADED) then
		local wasShown = StoreFrame_IsShown();
		if ( not wasShown ) then
			--We weren't showing, now we are. We should hide all other panels.
			-- not sure if anything is needed here at the gluescreen
		end
		StoreFrame_SetShown(not wasShown);
	end
end

function CharacterTemplatesFrameDropDown_OnClick(button)
	GlueDropDownMenu_SetSelectedID(CharacterTemplatesFrameDropDown, button:GetID());
end

function PlayersOnServer_Update()
	if (IsGMClient() and HideGMOnly()) then
		return;
	end
	
	local self = PlayersOnServer;
	local connected = IsConnectedToServer();
	if (not connected) then
		self:Hide();
		return;
	end
	
	local showPlayers, numHorde, numAlliance = GetPlayersOnServer();
	if showPlayers then
		if not self:IsShown() then
			self:Show();
		end
		self.HordeCount:SetText(numHorde);
		self.AllianceCount:SetText(numAlliance);
		self.HordeStar:SetShown(numHorde < numAlliance);
		self.AllianceStar:SetShown(numAlliance < numHorde);
	else
		self:Hide();
	end
end

function CharacterSelect_ActivateFactionChange()
	if IsConnectedToServer() then
		EnableChangeFaction();
		GetCharacterListUpdate();
	end
end

function CharacterSelect_UpdateStoreButton()
	if ( C_StorePublic.IsEnabled() and not C_StorePublic.IsDisabledByParentalControls() and GetNumCharacters() > 0 and not GameLimitedMode_IsActive() ) then
		StoreButton:Show();
	else
		StoreButton:Hide();
	end
end

GlueDialogTypes["TOKEN_GAME_TIME_OPTION_NOT_AVAILABLE"] = {
	text = ACCOUNT_REACTIVATE_OPTION_UNAVAILABLE,
	button1 = OKAY,
	escapeHides = true,
}

function CharacterSelect_HasVeteranEligibilityInfo()
	return TOKEN_COUNT_UPDATED and ((C_WowTokenGlue.GetTokenCount() > 0 or CAN_BUY_RESULT_FOUND) and C_WowTokenPublic.GetCurrentMarketPrice());
end

function CharacterSelect_ResetVeteranStatus()
	CAN_BUY_RESULT_FOUND = false;
	TOKEN_COUNT_UPDATED = false;
end

function CharacterSelect_CheckVeteranStatus()
	if (IsVeteranTrialAccount() and CharacterSelect_HasVeteranEligibilityInfo()) then
		ReactivateAccountDialog_Open();
	elseif (IsVeteranTrialAccount()) then
		if (not TOKEN_COUNT_UPDATED) then
			C_WowTokenPublic.UpdateTokenCount();
		end
		if (not CAN_BUY_RESULT_FOUND and TOKEN_COUNT_UPDATED) then
			C_WowTokenGlue.CheckVeteranTokenEligibility();
		end
		if (not C_WowTokenPublic.GetCurrentMarketPrice() and CAN_BUY_RESULT_FOUND) then
			C_WowTokenPublic.UpdateMarketPrice();
		end
	end
end

function CharacterSelect_UpdateButtonState()
	local servicesEnabled = not CharSelectServicesFlowFrame:IsShown();
	local undeleting = CharacterSelect.undeleting;
	local undeleteEnabled, undeleteOnCooldown = GetCharacterUndeleteStatus();
	local redemptionInProgress = AccountReactivationInProgressDialog:IsShown() or GoldReactivateConfirmationDialog:IsShown() or TokenReactivateConfirmationDialog:IsShown();

	local boostInProgress = select(18,GetCharacterInfo(GetCharacterSelection()));
	CharSelectEnterWorldButton:SetEnabled(servicesEnabled and not undeleting and not boostInProgress and not redemptionInProgress);
	CharacterSelectBackButton:SetEnabled(servicesEnabled and not undeleting and not boostInProgress);
	CharacterSelectDeleteButton:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress);
	CharSelectChangeRealmButton:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress);
	CharSelectUndeleteCharacterButton:SetEnabled(servicesEnabled and undeleteEnabled and not undeleteOnCooldown and not redemptionInProgress);
	CharacterSelectAddonsButton:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress);
	CopyCharacterButton:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress);
	ActivateFactionChange:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress);
	ActivateFactionChange.texture:SetDesaturated(not (servicesEnabled and not undeleting and not redemptionInProgress));
	CharacterTemplatesFrame.CreateTemplateButton:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress);
	CharacterSelectMenuButton:SetEnabled(servicesEnabled and not redemptionInProgress);
	CharSelectCreateCharacterButton:SetEnabled(servicesEnabled and not redemptionInProgress);
	StoreButton:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress);
	CharacterServicesTokenNormal:SetEnabled(not redemptionInProgress);
	CharacterServicesTokenWoDFree:SetEnabled(not redemptionInProgress);
	CharSelectAccountUpgradeButton:SetEnabled(not redemptionInProgress and not undeleting);
end

-- CHARACTER UNDELETE

GlueDialogTypes["UNDELETE_FAILED"] = {
	text = UNDELETE_FAILED_ERROR,
	button1 = OKAY,
	escapeHides = true,
}

GlueDialogTypes["UNDELETE_NAME_TAKEN"] = {
	text = UNDELETE_NAME_TAKEN,
	button1 = OKAY,
	escapeHides = true,
}

GlueDialogTypes["UNDELETE_NO_CHARACTERS"] = {
	text = UNDELETE_NO_CHARACTERS;
	button1 = OKAY,
	button2 = nil,
}

GlueDialogTypes["UNDELETE_SUCCEEDED"] = {
	text = UNDELETE_SUCCESS,
	button1 = OKAY,
	escapeHides = true,
}

GlueDialogTypes["UNDELETE_SUCCEEDED_NAME_TAKEN"] = {
	text = UNDELETE_SUCCESS_NAME_CHANGE_REQUIRED,
	button1 = OKAY,
	escapeHides = true,
}

GlueDialogTypes["UNDELETE_CONFIRM"] = {
	text = UNDELETE_CONFIRMATION,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function ()
		CharacterSelect_FinishUndelete(CharacterSelect.pendingUndeleteGuid);
		CharacterSelect.pendingUndeleteGuid = nil;
	end,
	OnCancel = function ()
		CharacterSelect.pendingUndeleteGuid = nil;
	end,
}

function CharacterSelect_StartCharacterUndelete()
	CharacterSelect.undeleting = true;
	CharacterSelect.undeleteChanged = true;

	CharSelectCreateCharacterButton:Hide();
	CharSelectUndeleteCharacterButton:Hide();
	CharSelectBackToActiveButton:Show();
	CharSelectChangeRealmButton:Hide();
	CharSelectUndeleteLabel:Show();

	AccountReactivate_CloseDialogs();

	CharacterServicesMaster_UpdateServiceButton();
	StartCharacterUndelete();
end

function CharacterSelect_EndCharacterUndelete()
	CharacterSelect.undeleting = false;
	CharacterSelect.undeleteChanged = true;

	CharSelectBackToActiveButton:Hide();
	CharSelectCreateCharacterButton:Show();
	CharSelectUndeleteCharacterButton:Show();
	CharSelectChangeRealmButton:Show();
	CharSelectUndeleteLabel:Hide();

	CharacterServicesMaster_UpdateServiceButton();
	EndCharacterUndelete();
end

function CharacterSelect_FinishUndelete(guid)
	UndeleteCharacter(guid);
	CharacterSelect.createIndex = 0;
	CharacterSelect_EndCharacterUndelete();
end

-- COPY CHARACTER

MAX_COPY_CHARACTER_BUTTONS = 19;
COPY_CHARACTER_BUTTON_HEIGHT = 16;

GlueDialogTypes["COPY_CHARACTER"] = {
	text = "",
	button1 = OKAY,
	button2 = CANCEL,
	escapeHides = true,
	OnAccept = function ()
		CopyCharacterFromLive();
	end,
}

GlueDialogTypes["COPY_ACCOUNT_DATA"] = {
	text = COPY_ACCOUNT_CONFIRM,
	button1 = OKAY,
	button2 = CANCEL,
	escapeHides = true,
	OnAccept = function ()
		CopyCharacter_AccountDataFromLive();
	end,
}

GlueDialogTypes["COPY_IN_PROGRESS"] = {
	text = COPY_IN_PROGRESS,
	button1 = nil,
	button2 = nil,
}

function CopyCharacterFromLive()
	CopyAccountCharacterFromLive(CopyCharacterFrame.SelectedIndex);
	GlueDialog_Show("COPY_IN_PROGRESS");
end

function CopyCharacter_AccountDataFromLive()
	local allowed = CopyAccountCharactersAllowed();
	if ( allowed >= 2 ) then
		CopyAccountDataFromLive(GlueDropDownMenu_GetSelectedValue(CopyCharacterFrame.RegionID));
	elseif ( allowed == 1 ) then
		CopyAccountDataFromLive(GlueDropDownMenu_GetSelectedValue(CopyCharacterFrame.RegionID), CopyCharacterFrame.RealmName:GetText(), CopyCharacterFrame.CharacterName:GetText());
	end
	GlueDialog_Show("COPY_IN_PROGRESS");
end

function CopyCharacterButton_OnLoad(self)
	if (IsGMClient() and HideGMOnly()) then
		return;
	end
	self:SetShown( CopyAccountCharactersAllowed() > 0 );
end
	
function CopyCharacterButton_OnClick(self)
	CopyCharacterFrame:SetShown( not CopyCharacterFrame:IsShown() );
end

function CopyCharacterSearch_OnClick(self)
	ClearAccountCharacters();
	CopyCharacterFrame_Update(CopyCharacterFrame.scrollFrame);
	RequestAccountCharacters(GlueDropDownMenu_GetSelectedValue(CopyCharacterFrame.RegionID), CopyCharacterFrame.RealmName:GetText(), CopyCharacterFrame.CharacterName:GetText());
	self:Disable();
end

function CopyCharacterCopy_OnClick(self)
	if ( CopyCharacterFrame.SelectedIndex and not GlueDialog:IsShown() ) then
		local name, realm = GetAccountCharacterInfo(CopyCharacterFrame.SelectedIndex);
		GlueDialog_Show("COPY_CHARACTER", format(COPY_CHARACTER_CONFIRM, name, realm));
	end
end

function CopyAccountData_OnClick(self)
	if ( not GlueDialog:IsShown() ) then
		GlueDialog_Show("COPY_ACCOUNT_DATA");
	end
end

function CopyCharacterEntry_OnClick(self)
	if ( CopyCharacterFrame.SelectedButton ) then
		CopyCharacterFrame.SelectedButton:UnlockHighlight();
		if ( not CopyCharacterFrame.SelectedButton.mouseOver ) then
			CopyCharacterEntry_Unhighlight( CopyCharacterFrame.SelectedButton );
		end
	end
	
	self:LockHighlight();
	CopyCharacterFrame.SelectedButton = self;
	CopyCharacterFrame.SelectedIndex = self:GetID() + FauxScrollFrame_GetOffset(CopyCharacterFrame.scrollFrame);
	CopyCharacterFrame.CopyButton:SetEnabled(true);
end

function CopyCharacterEntry_Highlight(self)
	self.Name:SetFontObject("GameFontHighlight");
	self.Server:SetFontObject("GameFontHighlight");
	self.Class:SetFontObject("GameFontHighlight");
	self.Level:SetFontObject("GameFontHighlight");
end

function CopyCharacterEntry_OnEnter(self)
	CopyCharacterEntry_Highlight(self);
	self.mouseOver = true;
end

function CopyCharacterEntry_Unhighlight(self)
	self.Name:SetFontObject("GameFontNormalSmall");
	self.Server:SetFontObject("GameFontNormalSmall");
	self.Class:SetFontObject("GameFontNormalSmall");
	self.Level:SetFontObject("GameFontNormalSmall");
end

function CopyCharacterEntry_OnLeave(self)
	if ( CopyCharacterFrame.SelectedButton ~= self) then
		CopyCharacterEntry_Unhighlight(self);
	end
	self.mouseOver = false;
end

function CopyCharacterFrame_OnLoad(self)
	FauxScrollFrame_SetOffset(self.scrollFrame, 0);
	self.scrollFrame.ScrollBar.scrollStep = COPY_CHARACTER_BUTTON_HEIGHT;
	ButtonFrameTemplate_HidePortrait(self);
	self:RegisterEvent("ACCOUNT_CHARACTER_LIST_RECIEVED");
	self:RegisterEvent("CHAR_RESTORE_COMPLETE");
	self:RegisterEvent("ACCOUNT_DATA_RESTORED");
	for i=2, MAX_COPY_CHARACTER_BUTTONS do
		local newButton = CreateFrame("BUTTON", nil, CopyCharacterFrame, "CopyCharacterEntryTemplate");
		newButton:SetPoint("TOP", self.CharacterEntries[i-1], "BOTTOM", 0, -4);
		newButton:SetID(i);
		self.CharacterEntries[i] = newButton;
	end
end

function CopyCharacterFrame_OnShow(self)
	if ( self.SelectedButton ) then
		self.SelectedButton:UnlockHighlight();
		CopyCharacterEntry_Unhighlight(self.SelectedButton);
	end
	self.SelectedButton = nil;
	self.SelectedIndex = nil;
	self.CopyButton:SetEnabled(false);

	GlueDropDownMenu_SetWidth(self.RegionID, 80);
	GlueDropDownMenu_SetSelectedValue(self.RegionID, 1);
	GlueDropDownMenu_Initialize(self.RegionID, CopyCharacterFrameRegionIDDropdown_Initialize);
	GlueDropDownMenu_SetAnchor(self.RegionID, 0, 0, "TOPLEFT", self.RegionID, "BOTTOMLEFT");
	GlueDropDownMenu_Refresh(self.RegionID);
	
	ClearAccountCharacters();
	CopyCharacterFrame_Update(self.scrollFrame);

	if ( CopyAccountCharactersAllowed() >= 2 ) then
		self.RealmName:Hide();
		self.CharacterName:Hide();
		self.SearchButton:Hide();
		RequestAccountCharacters(GlueDropDownMenu_GetSelectedValue(CopyCharacterFrame.RegionID));
	elseif ( CopyAccountCharactersAllowed() == 1) then
		self.RealmName:Show();
		self.RealmName:SetFocus();
		self.CharacterName:Show();
		self.SearchButton:Show();
	end
end

function CopyCharacterFrameRegionIDDropdown_Initialize()
	local info = GlueDropDownMenu_CreateInfo();
	local selectedValue = GlueDropDownMenu_GetSelectedValue(CopyCharacterFrame.RegionID);
	info.func = CopyCharacterFrameRegionIDDropdown_OnClick;

	info.text = NORTH_AMERICA;
	info.value = 1;
	info.checked = (info.value == selectedValue);
	GlueDropDownMenu_AddButton(info);

	info.text = KOREA;
	info.value = 2;
	info.checked = (info.value == selectedValue);
	GlueDropDownMenu_AddButton(info);
	
	info.text = EUROPE;
	info.value = 3;
	info.checked = (info.value == selectedValue);
	GlueDropDownMenu_AddButton(info);

	info.text = TAIWAN;
	info.value = 4;
	info.checked = (info.value == selectedValue);
	GlueDropDownMenu_AddButton(info);
	
--	info.text = "China";
--	info.value = 5;
--	info.checked = (info.value == selectedValue);
--	GlueDropDownMenu_AddButton(info);
end

function CopyCharacterFrameRegionIDDropdown_OnClick(button)
	GlueDropDownMenu_SetSelectedValue(CopyCharacterFrame.RegionID, button.value);
	if ( CopyAccountCharactersAllowed() >= 2 ) then
		RequestAccountCharacters(button.value);
	end
end

function CopyCharacterFrame_OnEvent(self, event, ...)
	if ( event == "ACCOUNT_CHARACTER_LIST_RECIEVED" ) then
		CopyCharacterFrame_Update(self.scrollFrame);
		self.SearchButton:Enable();
	elseif ( event == "CHAR_RESTORE_COMPLETE" or event == "ACCOUNT_DATA_RESTORED") then
		local success, token = ...;
		GlueDialog:Hide();
		self:Hide();
		if (not success) then
			GlueDialog_Show("OKAY", COPY_FAILED);
		end
	end
end

function CopyCharacterFrame_Update(self)
	local offset = FauxScrollFrame_GetOffset(self) or 0;
	local count = GetNumAccountCharacters();
	-- turn off the selected button, we'll see if it moved
	if (CopyCharacterFrame.SelectedButton) then
		CopyCharacterFrame.SelectedButton:UnlockHighlight();
		if (not CopyCharacterFrame.SelectedButton.mouseOver) then
			CopyCharacterEntry_Unhighlight(CopyCharacterFrame.SelectedButton);
		end
	end
	
	for i=1, MAX_COPY_CHARACTER_BUTTONS do
		local characterIndex = offset + i;
		local button = CopyCharacterFrame.CharacterEntries[i];
		if ( characterIndex <= count ) then
			local name, realm, class, level = GetAccountCharacterInfo(characterIndex);
			button.Name:SetText(name);
			button.Server:SetText(realm);
			button.Class:SetText(class);
			button.Level:SetText(level);
			-- The list moved, so we need to shuffle the selected button
			if ( CopyCharacterFrame.SelectedIndex == characterIndex ) then
				button:LockHighlight();
				CopyCharacterEntry_Highlight(button);
				CopyCharacterFrame.SelectedButton = button;
			end
			button:Enable();
			button:Show();
		else
			button:Disable();
			button:Hide();
		end
	end
	FauxScrollFrame_Update(CopyCharacterFrameScrollFrame, count, MAX_COPY_CHARACTER_BUTTONS, COPY_CHARACTER_BUTTON_HEIGHT );
end

function CopyCharacterScrollFrame_OnVerticalScroll(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, COPY_CHARACTER_BUTTON_HEIGHT, CopyCharacterFrame_Update)
end

function CopyCharacterEditBox_OnLoad(self)
	self.parent = self:GetParent();
end

function CopyCharacterEditBox_OnShow(self)
	self:SetText("");
end

function CopyCharacterEditBox_OnEnterPressed(self)
	self:GetParent().SearchButton:Click();
end

function CopyCharacterRealmNameEditBox_OnTabPressed(self)
	self:GetParent().CharacterName:SetFocus();
end

function CopyCharacterCharacterNameEditBox_OnTabPressed(self)
	self:GetParent().RealmName:SetFocus();
end