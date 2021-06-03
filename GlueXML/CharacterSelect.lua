CHARACTER_SELECT_ROTATION_START_X = nil;
CHARACTER_SELECT_INITIAL_FACING = nil;

CHARACTER_ROTATION_CONSTANT = 0.6;

MAX_CHARACTERS_DISPLAYED = 10;
MAX_CHARACTERS_DISPLAYED_BASE = MAX_CHARACTERS_DISPLAYED;

CHARACTER_LIST_OFFSET = 0;

CHARACTER_SELECT_BACK_FROM_CREATE = false;

MOVING_TEXT_OFFSET = 12;
DEFAULT_TEXT_OFFSET = 0;
CHARACTER_BUTTON_HEIGHT = 57;
CHARACTER_LIST_TOP = 688;
AUTO_DRAG_TIME = 0.5;				-- in seconds

CHARACTER_UNDELETE_COOLDOWN = 0;	-- in seconds
CHARACTER_UNDELETE_COOLDOWN_REMAINING = 0; -- in seconds

PAID_CHARACTER_CUSTOMIZATION = 1;
PAID_RACE_CHANGE = 2;
PAID_FACTION_CHANGE = 3;
PAID_CHARACTER_CLONE = 4;

FRAME_TYPE_TBC_INFO_PANE = "FrameType_InfoPane";

INFO_PANE_MAX_SCALE = 0.75;
CHOICE_PANE_MAX_SCALE = 0.75;

local translationTable = { };	-- for character reordering: key = button index, value = character ID

local STORE_IS_LOADED = false;
local ADDON_LIST_RECEIVED = false;
CAN_BUY_RESULT_FOUND = false;
TOKEN_COUNT_UPDATED = false;
REALM_CHANGE_IS_AUTO = false;

CharacterSelectLockedButtonMixin = {};

local characterCopyRegions = {
	[41] = NORTH_AMERICA,
	[42] = KOREA,
	[43] = EUROPE,
	[44] = TAIWAN,
	[45] = CHINA,
};

local localizedAtlasMembers = {};

function GenerateBuildString(buildNumber)
	if buildNumber == 0 then
		return "No Login";
	end

	-- Generate Build String from the Integer.
	local versionParse = {tostring(buildNumber):match("(%d+)(%d%d)(%d%d)$")};
	
	if #versionParse > 0 then
		for k, v in ipairs(versionParse) do
			versionParse[k] = tonumber(v);
		end

		return table.concat(versionParse, ".");
	else
		return "OLD";
	end
end

function CharacterSelectLockedButtonMixin:OnEnter()
	local requiresPurchase = IsExpansionTrialCharacter(self.guid) and CanUpgradeExpansion() or not C_CharacterServices.HasRequiredBoostForUnrevoke();

    local tooltipFooter;
    if requiresPurchase then
		tooltipFooter = CHARACTER_SELECT_REVOKED_BOOST_TOKEN_LOCKED_TOOLTIP_HELP_SHOP;
	else
        tooltipFooter = CHARACTER_SELECT_REVOKED_BOOST_TOKEN_LOCKED_TOOLTIP_HELP_USE_BOOST;
    end

    -- TODO: Add color constants to glue?
    GlueTooltip:SetText(self.tooltipTitle, 1, 1, 1, 1, false);
    GlueTooltip:AddLine(self.tooltipText, nil, nil, nil, nil, true);
    GlueTooltip:AddLine(tooltipFooter, .1, 1, .1, 1, true);
    GlueTooltip:Show();
    GlueTooltip:SetOwner(self, "ANCHOR_LEFT", -16, -5);
end

function CharacterSelectLockedButtonMixin:OnLeave()
    GlueTooltip:Hide();
end

function CharacterSelectLockedButtonMixin:OnClick()
	if IsExpansionTrialCharacter(self.guid) and CanUpgradeExpansion() then
		ToggleStoreUI();
		StoreFrame_SetGamesCategory();
		return;
	end

    CharacterSelectButton_OnClick(self.characterSelectButton);

	if GlobalGlueContextMenu_GetOwner() == self then
		GlobalGlueContextMenu_Release();
	else
		local availableBoostTypes = GetAvailableBoostTypesForCharacterByGUID(self.guid);
		if #availableBoostTypes > 1 then
			local glueContextMenu = GlobalGlueContextMenu_Acquire(self);
			glueContextMenu:SetPoint("TOPRIGHT", self, "TOPLEFT", 15, -12);

			for i, boostType in ipairs(availableBoostTypes) do
				local flowData = C_CharacterServices.GetCharacterServiceDisplayData(boostType);
				local function CharacterSelectLockedButtonContextMenuButton_OnClick() CharacterUpgradePopup_BeginCharacterUpgradeFlow(flowData, self.guid); end;
				glueContextMenu:AddButton(CHARACTER_SELECT_PADLOCK_DROP_DOWN_USE_BOOST:format(flowData.flowTitle), CharacterSelectLockedButtonContextMenuButton_OnClick);
			end

			local function CloseContextMenu()
				GlobalGlueContextMenu_Release();
			end

			glueContextMenu:AddButton(CANCEL, CloseContextMenu);

			glueContextMenu:Show();
		else
			CharacterSelect_ShowBoostUnlockDialog(self.guid);
		end
	end
end

function CharacterSelect_OnLoad(self)
    CharacterSelectModel:SetSequence(0);
    CharacterSelectModel:SetCamera(0);

    self.createIndex = 0;
    self.selectedIndex = 0;
    self.selectLast = false;
    self.characterPadlockPool = CreateFramePool("BUTTON", self, "CharSelectLockedButtonTemplate");
    self:RegisterEvent("CHARACTER_LIST_UPDATE");
    self:RegisterEvent("UPDATE_SELECTED_CHARACTER");
    self:RegisterEvent("FORCE_RENAME_CHARACTER");
    self:RegisterEvent("CHAR_RENAME_IN_PROGRESS");
    self:RegisterEvent("STORE_STATUS_CHANGED");
    self:RegisterEvent("CHARACTER_UNDELETE_STATUS_CHANGED");
    self:RegisterEvent("CLIENT_FEATURE_STATUS_CHANGED");
	self:RegisterEvent("CHARACTER_COPY_STATUS_CHANGED")
    self:RegisterEvent("CHARACTER_UNDELETE_FINISHED");
    self:RegisterEvent("TOKEN_CAN_VETERAN_BUY_UPDATE");
    self:RegisterEvent("TOKEN_DISTRIBUTIONS_UPDATED");
    self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
    self:RegisterEvent("VAS_CHARACTER_STATE_CHANGED");
    self:RegisterEvent("STORE_PRODUCTS_UPDATED");
    self:RegisterEvent("CHARACTER_DELETION_RESULT");
    self:RegisterEvent("CHARACTER_DUPLICATE_LOGON");
    self:RegisterEvent("CHARACTER_LIST_RETRIEVING");
    self:RegisterEvent("CHARACTER_LIST_RETRIEVAL_RESULT");
    self:RegisterEvent("DELETED_CHARACTER_LIST_RETRIEVING");
    self:RegisterEvent("DELETED_CHARACTER_LIST_RETRIEVAL_RESULT");
    self:RegisterEvent("VAS_CHARACTER_QUEUE_STATUS_UPDATE");
    self:RegisterEvent("LOGIN_STATE_CHANGED");
	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
    self:RegisterEvent("CHARACTER_UPGRADE_UNREVOKE_RESULT");
	self:RegisterEvent("MIN_EXPANSION_LEVEL_UPDATED");
	self:RegisterEvent("MAX_EXPANSION_LEVEL_UPDATED");
	self:RegisterEvent("INITIAL_HOTFIXES_APPLIED");
	self:RegisterEvent("UPDATE_NAME_RESERVATION");
	self:RegisterEvent("TBC_INFO_PANE_UPDATE");
	self:RegisterEvent("TBC_INFO_PANE_PRICE_UPDATE");
    SetCharSelectModelFrame("CharacterSelectModel");

    CHARACTER_SELECT_BACK_FROM_CREATE = false;

    CHARACTER_LIST_OFFSET = 0;
end

function CharacterSelect_OnShow(self)
    DebugLog("Select_OnShow");
    InitializeCharacterScreenData();
    SetInCharacterSelect(true);
    CHARACTER_LIST_OFFSET = 0;
    CharacterSelect_ResetVeteranStatus();

    if ( #translationTable == 0 ) then
        for i = 1, GetNumCharacters() do
            tinsert(translationTable, i);
        end
    end

    -- request account data times from the server (so we know if we should refresh keybindings, etc...)
    CheckCharacterUndeleteCooldown();

    UpdateAddonButton();

    CharacterSelect_SetAutoSwitchRealm(false);

    local FROM_LOGIN_STATE_CHANGE = false;
    CharacterSelect_UpdateState(FROM_LOGIN_STATE_CHANGE);

    -- Gameroom billing stuff (For Korea and China only)
    if ( SHOW_GAMEROOM_BILLING_FRAME ) then
        local paymentPlan, hasFallBackBillingMethod, isGameRoom = GetBillingPlan();
        if ( paymentPlan == 0 or ( ( paymentPlan == 1 or paymentPlan == 3 ) and ONLY_SHOW_GAMEROOM_BILLING_FRAME_ON_PERSONAL_TIME ) ) then
            -- No payment plan or should only show when using consumption time
            GameRoomBillingFrame:Hide();
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
                    billingText = format(BILLING_FREE_TIME_EXPIRE, format(MINUTES_ABBR, billingTimeLeft));
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
        end
    end

    -- fadein the character select ui
    CharacterSelectUI.FadeIn:Play();

    --Clear out the addons selected item
    GlueDropDownMenu_SetSelectedValue(AddonCharacterDropDown, true);

    AccountUpgradePanel_Update(CharSelectAccountUpgradeButton.isExpanded);

    if( IsKioskGlueEnabled() ) then
        CharacterSelectUI:Hide();
    end

    -- character templates
    CharacterTemplatesFrame_Update();

    PlayersOnServer_Update();

    CharacterSelect_UpdateStoreButton();

    CharacterServicesMaster_UpdateServiceButton();

	TBCInfoPane_Update();

    C_StoreSecure.GetPurchaseList();
    C_StoreSecure.GetProductList();
    C_StoreGlue.UpdateVASPurchaseStates();

    if (not STORE_IS_LOADED) then
        STORE_IS_LOADED = LoadAddOn("Blizzard_StoreUI")
        LoadAddOn("Blizzard_AuthChallengeUI");
    end

    CharacterSelect_CheckVeteranStatus();

    if (C_StoreGlue.GetDisconnectOnLogout()) then
        C_StoreSecure.SetDisconnectOnLogout(false);
        GlueDialog_Hide();
        C_Login.DisconnectFromServer();
    end

    if (not HasCheckedSystemRequirements()) then
        CheckSystemRequirements();
        SetCheckedSystemRequirements(true);
    end

	local includeSeenWarnings = true;
	CharacterSelectUI.ConfigurationWarnings:SetShown(#C_ConfigurationWarnings.GetConfigurationWarnings(includeSeenWarnings) > 0);
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

    PromotionFrame_Hide();
    C_AuthChallenge.Cancel();
    if ( StoreFrame ) then
        StoreFrame:Hide();
    end
    CopyCharacterFrame:Hide();
    if ( AddonDialog:IsShown() ) then
        AddonDialog:Hide();
        HasShownAddonOutOfDateDialog = false;
    end

    if ( self.undeleting ) then
        CharacterSelect_EndCharacterUndelete();
    end

    if ( CharSelectServicesFlowFrame:IsShown() ) then
        CharSelectServicesFlowFrame:Hide();
    end

    AccountReactivate_CloseDialogs();
    SetInCharacterSelect(false);
end

function CharacterSelect_SetAutoSwitchRealm(isAuto)
    REALM_CHANGE_IS_AUTO = isAuto;
end

function CharacterSelect_UpdateState(fromLoginState)
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

    if (fromLoginState == REALM_CHANGE_IS_AUTO) then
        if ( connected ) then
            if (fromLoginState) then
                if (IsKioskGlueEnabled()) then
                    GlueParent_SetScreen("kioskmodesplash");
                else
                    CharacterSelectUI:Hide();
                    CharacterSelectUI:Show();
                end
            end
			if (not IsCharacterListUpdateRequested()) then
	            GetCharacterListUpdate();
			end
        else
            UpdateCharacterList();
        end
    end
end

function CharacterSelect_SaveCharacterOrder()
    if ( CharacterSelect.orderChanged ) then
        SaveCharacterOrder(translationTable);
        CharacterSelect.orderChanged = nil;
    end
end

function CharacterSelect_SetRetrievingCharacters(retrieving, success)
    if ( retrieving ~= CharacterSelect.retrievingCharacters ) then
        CharacterSelect.retrievingCharacters = retrieving;

        if ( retrieving ) then
            GlueDialog_Show("RETRIEVING_CHARACTER_LIST");
        else
            if ( success ) then
                GlueDialog_Hide("RETRIEVING_CHARACTER_LIST");
            else
                GlueDialog_Show("OKAY", CHAR_LIST_FAILED);
            end
        end

        CharacterSelect_UpdateButtonState();
    end
end

function CharacterSelect_IsRetrievingCharacterList()
    return CharacterSelect.retrievingCharacters;
end

function CharacterSelect_OnUpdate(self, elapsed)
    if ( self.undeleteFailed ) then
        if (not GlueDialog:IsShown()) then
			if ( self.undeleteFailed == "pvp" ) then
				GlueDialog_Show("UNDELETE_FAILED_PVP");
			else
				GlueDialog_Show(self.undeleteFailed == "name" and "UNDELETE_NAME_TAKEN" or "UNDELETE_FAILED");
			end
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
	
	GlueDialog_CheckQueuedDialogs();
end

function CharacterSelect_OnKeyDown(self,key)
    if ( key == "ESCAPE" ) then
        if ( C_Login.IsLauncherLogin() ) then
            GlueMenuFrame:SetShown(not GlueMenuFrame:IsShown());
        elseif (CharSelectServicesFlowFrame:IsShown()) then
            CharSelectServicesFlowFrame:Hide();
        elseif ( CopyCharacterFrame:IsShown() ) then
            CopyCharacterFrame:Hide();
        elseif (CharacterSelect.undeleting) then
            CharacterSelect_EndCharacterUndelete();
		elseif ( GlobalGlueContextMenu_IsShown() ) then
			GlobalGlueContextMenu_Release();
        else
            CharacterSelect_Exit();
        end
    elseif ( key == "ENTER" ) then
        if (CharacterSelect_AllowedToEnterWorld()) then
            CharacterSelect_EnterWorld();
        end
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

VAS_QUEUE_TIMES = {};
function CharacterSelect_OnEvent(self, event, ...)
    if ( event == "CHARACTER_LIST_UPDATE" ) then
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
            if (IsKioskGlueEnabled()) then
                GlueParent_SetScreen("kioskmodesplash");
            else
                GlueParent_SetScreen("charcreate");
            end
            return;
        end

        CHARACTER_SELECT_BACK_FROM_CREATE = false;

        if (self.hasPendingTrialBoost) then
            KioskMode_SetWaitingOnTrial(true);
            C_CharacterServices.TrialBoostCharacter(self.trialBoostGuid, self.trialBoostFactionID, self.trialBoostSpecID);
            CharacterSelect_SetPendingTrialBoost(false);
        end

        if (self.undeleteNoCharacters) then
            GlueDialog_Show("UNDELETE_NO_CHARACTERS");
            self.undeleteNoCharacters = false;
        end

        UpdateCharacterList();
        UpdateAddonButton(true);
        CharSelectCharacterName:SetText(GetCharacterInfo(GetCharIDFromIndex(self.selectedIndex)));
        KioskMode_CheckAutoRealm();
        KioskMode_CheckEnterWorld();
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
	elseif ( event == "UPDATE_NAME_RESERVATION" ) then
		CharacterSelect_UpdateButtonState();
    elseif ( event == "FORCE_RENAME_CHARACTER" ) then
        GlueDialog_Hide();
        local message = ...;
        CharacterRenameDialog:Show();
        CharacterRenameText1:SetText(_G[message]);
    elseif ( event == "CHAR_RENAME_IN_PROGRESS" ) then
        GlueDialog_Show("OKAY", CHAR_RENAME_IN_PROGRESS);
    elseif ( event == "STORE_STATUS_CHANGED" ) then
        if (ADDON_LIST_RECEIVED) then
            CharacterSelect_UpdateStoreButton();
        end
    elseif ( event == "CHARACTER_UNDELETE_STATUS_CHANGED") then
        UpdateCharacterUndeleteStatus();
    elseif ( event == "CLIENT_FEATURE_STATUS_CHANGED" ) then
        AccountUpgradePanel_Update(CharSelectAccountUpgradeButton.isExpanded);
		CopyCharacterButton_UpdateButtonState();
		UpdateCharacterList();
	elseif ( event == "CHARACTER_COPY_STATUS_CHANGED" ) then
		CopyCharacterButton_UpdateButtonState();
    elseif ( event == "CHARACTER_UNDELETE_FINISHED" ) then
        GlueDialog_Hide("UNDELETING_CHARACTER");
        CharacterSelect_EndCharacterUndelete();
        local result, guid = ...;

        if ( result == LE_CHARACTER_UNDELETE_RESULT_OK ) then
            self.undeleteGuid = guid;
            self.undeleteFailed = nil;
        else
            self.undeleteGuid = nil;
			if ( result == LE_CHARACTER_UNDELETE_RESULT_ERROR_PVP_TEAMS_VIOLATION ) then
				self.undeleteFailed = "pvp";
			elseif ( result == LE_CHARACTER_UNDELETE_RESULT_ERROR_NAME_TAKEN_BY_THIS_ACCOUNT ) then
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
    elseif (event == "VAS_CHARACTER_STATE_CHANGED" or event == "STORE_PRODUCTS_UPDATED") then
        if ( not IsCharacterListUpdatePending() ) then
            UpdateCharacterList();
        end

		if (event == "STORE_PRODUCTS_UPDATED") then
			TBCInfoPane_RefreshPrice();
		end
    elseif ( event == "CHARACTER_DELETION_RESULT" ) then
        local success, errorToken = ...;
        if ( success ) then
            CHARACTER_LIST_OFFSET = 0;
            CharacterSelect_SelectCharacter(1, 1);
            GlueDialog_Hide();
        else
            GlueDialog_Show("OKAY", _G[errorToken]);
        end
    elseif ( event == "CHARACTER_DUPLICATE_LOGON" ) then
        local errorCode = ...;
        GlueDialog_Show("OKAY", _G[errorCode]);
    elseif ( event == "CHARACTER_LIST_RETRIEVING" ) then
        CharacterSelect_SetRetrievingCharacters(true);
    elseif ( event == "CHARACTER_LIST_RETRIEVAL_RESULT" ) then
        local success = ...;
        CharacterSelect_SetRetrievingCharacters(false, success);
    elseif ( event == "DELETED_CHARACTER_LIST_RETRIEVING" ) then
        CharacterSelect_SetRetrievingCharacters(true);
    elseif ( event == "DELETED_CHARACTER_LIST_RETRIEVAL_RESULT" ) then
        local success = ...;
        CharacterSelect_SetRetrievingCharacters(false, success);
    elseif ( event == "CHARACTER_UPGRADE_UNREVOKE_RESULT" ) then
        -- TODO: Add specific error messaging, but for now just show dialog that will open the help url
        local errorCode = ...
        if errorCode ~= 0 then
            local urlIndex = GetCurrentRegionName() == "CN" and 36 or 35;
            GlueDialog_Show("OKAY_WITH_URL_INDEX", ERROR_MANUAL_UNREVOKE_FAILURE, urlIndex);
        end
    elseif ( event == "VAS_CHARACTER_QUEUE_STATUS_UPDATE" ) then
        local guid, minutes = ...;
        VAS_QUEUE_TIMES[guid] = minutes;
        if (not IsCharacterListUpdatePending()) then
            UpdateCharacterList();
        end
    elseif ( event == "LOGIN_STATE_CHANGED" ) then
        local FROM_LOGIN_STATE_CHANGE = true;
        CharacterSelect_UpdateState(FROM_LOGIN_STATE_CHANGE);
	elseif ( event == "TRIAL_STATUS_UPDATE" ) then
		AccountUpgradePanel_Update(CharSelectAccountUpgradeButton.isExpanded);
		UpdateCharacterList();
	elseif ( event == "UPDATE_EXPANSION_LEVEL" or event == "MIN_EXPANSION_LEVEL_UPDATED" or event == "MAX_EXPANSION_LEVEL_UPDATED" or event == "INITIAL_HOTFIXES_APPLIED" ) then
		AccountUpgradePanel_Update(CharSelectAccountUpgradeButton.isExpanded);
	elseif ( event == "TBC_INFO_PANE_UPDATE") then
		TBCInfoPane_Update();
	elseif ( event == "TBC_INFO_PANE_PRICE_UPDATE") then
		TBCInfoPane_RefreshPrice();
	end
end

function CharacterSelect_SetPendingTrialBoost(hasPendingTrialBoost, factionID, specID, guid)
    CharacterSelect.hasPendingTrialBoost = hasPendingTrialBoost;
    CharacterSelect.trialBoostFactionID = factionID;
    CharacterSelect.trialBoostSpecID = specID;
    CharacterSelect.trialBoostGuid = guid;
end

function CharacterSelect_SetupPadlockForCharacterButton(button, guid)
    local padlock = CharacterSelect.characterPadlockPool:Acquire();
    button.padlock = padlock;
    padlock.characterSelectButton = button;

    padlock.guid = guid;

    local isTrialBoost, isTrialBoostLocked, revokedCharacterUpgrade, _, _, _, isExpansionTrialCharacter = select(22, GetCharacterInfoByGUID(guid));
	if isExpansionTrialCharacter then
		if IsExpansionTrial() or CanUpgradeExpansion() then
			-- Player has to upgrade to unlock this character
			padlock.tooltipTitle = CHARACTER_SELECT_INFO_EXPANSION_TRIAL_BOOST_LOCKED_TOOLTIP_TITLE;
			padlock.tooltipText = CHARACTER_SELECT_INFO_EXPANSION_TRIAL_BOOST_LOCKED_TOOLTIP_TEXT;
		else
			-- Player just needs to boost to get this character
			padlock.tooltipTitle = CHARACTER_SELECT_INFO_TRIAL_BOOST_LOCKED_TOOLTIP_TITLE;
			padlock.tooltipText = CHARACTER_SELECT_INFO_TRIAL_BOOST_LOCKED_TOOLTIP_TEXT;
		end
    elseif isTrialBoost and isTrialBoostLocked then
        padlock.tooltipTitle = CHARACTER_SELECT_INFO_TRIAL_BOOST_LOCKED_TOOLTIP_TITLE;
        padlock.tooltipText = CHARACTER_SELECT_INFO_TRIAL_BOOST_LOCKED_TOOLTIP_TEXT;
    elseif revokedCharacterUpgrade then
        padlock.tooltipTitle = CHARACTER_SELECT_REVOKED_BOOST_TOKEN_LOCKED_TOOLTIP_TITLE;
        padlock.tooltipText = CHARACTER_SELECT_REVOKED_BOOST_TOKEN_LOCKED_TOOLTIP_TEXT;
    else
        GMError("Invalid lock type");
    end
	
    padlock:SetParent(button);
    padlock:SetPoint("TOPRIGHT", button, "TOPLEFT", 5, 12);

    padlock:SetShown(not CharSelectServicesFlowFrame:IsShown());
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
        button:UnlockHighlight();
        button.upButton:Hide();
        button.downButton:Hide();
        if (self.undeleting or CharSelectServicesFlowFrame:IsShown()) then
            paidServiceButton:Hide();
            CharacterSelectButton_DisableDrag(button);

            if (button.padlock) then
                button.padlock:Hide();
            end
        else
            CharacterSelectButton_EnableDrag(button);
        end
    end

    local index = self.selectedIndex - CHARACTER_LIST_OFFSET;
    if ( (index > 0) and (index <= MAX_CHARACTERS_DISPLAYED) ) then
        button = _G["CharSelectCharacterButton"..index];
        paidServiceButton = _G["CharSelectPaidService"..index];

        if ( button ) then
            button:LockHighlight();
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
    local numChars = GetNumVisibleCharacters();
    local coords;

    if ( CharacterSelect.undeleteChanged ) then
        CHARACTER_LIST_OFFSET = 0;
        CharacterSelect.undeleteChanged = false;
    end

    if ( (CanCreateCharacter() or CharacterSelect.undeleting) and numChars >= MAX_CHARACTERS_DISPLAYED_BASE ) then
		MAX_CHARACTERS_DISPLAYED = MAX_CHARACTERS_DISPLAYED_BASE - 1;
    else
        MAX_CHARACTERS_DISPLAYED = MAX_CHARACTERS_DISPLAYED_BASE;
    end

	if CharacterSelect.selectLast then
        CHARACTER_LIST_OFFSET = max(numChars - MAX_CHARACTERS_DISPLAYED, 0);
        CharacterSelect.selectedIndex = GetNumCharactersActiveForEra();
        CharacterSelect.selectLast = false;
	elseif CharacterSelect.selectGuid or CharacterSelect.undeleteGuid then
		for i = 1, numChars do
			local guid, _, _, _, _, forceRename = select(15, GetCharacterInfo(i));
			if guid == CharacterSelect.selectGuid or guid == CharacterSelect.undeleteGuid then
				CHARACTER_LIST_OFFSET = max(i - MAX_CHARACTERS_DISPLAYED, 0);
				CharacterSelect.selectedIndex = i;
				if guid == CharacterSelect.undeleteGuid then
                    CharacterSelect.undeleteSucceeded = true;
                    CharacterSelect.undeletePendingRename = forceRename;
				end
                    break;
                end
            end
		CharacterSelect.selectGuid = nil;
        CharacterSelect.undeleteGuid = nil;
    end

    local debugText = numChars..": ";
    local characterLimit = min(numChars, MAX_CHARACTERS_DISPLAYED);
    local areCharServicesShown = CharSelectServicesFlowFrame:IsShown();

    for i=1, characterLimit, 1 do
        local name, race, _, class, classFileName, classID, level, zone, sex, ghost, PCC, PRC, PFC, PRCDisabled, guid, _, _, _, boostInProgress, _, locked, isTrialBoost, isTrialBoostLocked, revokedCharacterUpgrade, _, lastLoginBuild, _, isExpansionTrialCharacter, eraChoiceState = GetCharacterInfo(GetCharIDFromIndex(i+CHARACTER_LIST_OFFSET));
        local productID, vasServiceState, vasServiceErrors, productInfo;
        if (guid) then
            productID, vasServiceState, vasServiceErrors = C_StoreGlue.GetVASPurchaseStateInfo(guid);
        end
        if (productID) then
            productInfo = C_StoreSecure.GetProductInfo(productID);
        end

        local button = _G["CharSelectCharacterButton"..i];
        button.isVeteranLocked = false;

        if (button.padlock) then
            CharacterSelect.characterPadlockPool:Release(button.padlock);
            button.padlock = nil;
        end

		local showlastLoginBuild = (IsGMClient()) and (not HideGMOnly());
		button.buttonText.LastVersion:SetShown(showlastLoginBuild);

        if ( name ) then
            local nameText = button.buttonText.name;
            local infoText = button.buttonText.Info;
            local locationText = button.buttonText.Location;
			locationText:SetTextColor(GRAY_FONT_COLOR:GetRGB());

            if (not areCharServicesShown) then
                nameText:SetTextColor(1, .82, 0, 1);
            end

			if (IsEraChoiceStateLocked(eraChoiceState)) then
				nameText:SetTextColor(GRAY_FONT_COLOR:GetRGB());
				zone = BURNING_CRUSADE_TRANSITION_ACTIVATECHARACTER_CHARACTERLABEL
			elseif (DoesEraChoiceStateRequireDecision(eraChoiceState)) then
				locationText:SetTextColor(GREEN_FONT_COLOR:GetRGB());
				zone = BURNING_CRUSADE_TRANSITION_CHOOSEEXPANSION_CHARACTERLABEL;
			else
				zone = zone or "";
			end

            if ( CharacterSelect.undeleting ) then
                nameText:SetFormattedText(CHARACTER_SELECT_NAME_DELETED, name);
            elseif ( locked ) then
                nameText:SetText(name..CHARSELECT_CHAR_INACTIVE_CHAR);
            else
                nameText:SetText(name);
            end

			-- If we're not showing the build, don't bother doing nice formatting.
			if (showlastLoginBuild) then
				local currentVersion = select(6, GetBuildInfo());

				-- Set the Color based on the build being old / new
				if (lastLoginBuild < currentVersion) then
					button.buttonText.LastVersion:SetTextColor(YELLOW_FONT_COLOR:GetRGBA()) -- Earlier Build
				elseif (lastLoginBuild > currentVersion) then
					button.buttonText.LastVersion:SetTextColor(RED_FONT_COLOR:GetRGBA()) -- Later Build
				else
					button.buttonText.LastVersion:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGBA()) -- Current Build
				end

				button.buttonText.LastVersion:SetText(GenerateBuildString(lastLoginBuild));
			end

            if (vasServiceState == Enum.VasPurchaseProgress.ApplyingLicense and #vasServiceErrors > 0) then
                local productInfo = C_StoreSecure.GetProductInfo(productID);
                infoText:SetText("|cffff2020"..VAS_ERROR_ERROR_HAS_OCCURRED.."|r");
                if (productInfo and productInfo.sharedData.name) then
                    locationText:SetText("|cffff2020"..productInfo.sharedData.name.."|r");
                else
                    locationText:SetText("");
                end
			elseif (vasServiceState == Enum.VasPurchaseProgress.WaitingOnQueue and not VAS_QUEUE_TIMES[guid]) then
				C_StoreGlue.RequestCharacterQueueTime(guid);
            elseif (vasServiceState == Enum.VasPurchaseProgress.ProcessingFactionChange) then
                infoText:SetText(CHARACTER_UPGRADE_PROCESSING);
                locationText:SetFontObject("GlueFontHighlightSmall");
                locationText:SetText(FACTION_CHANGE_CHARACTER_LIST_LABEL);
            elseif (boostInProgress) then
                infoText:SetText(CHARACTER_UPGRADE_PROCESSING);
                locationText:SetFontObject("GlueFontHighlightSmall");
                locationText:SetText(CHARACTER_UPGRADE_CHARACTER_LIST_LABEL);
            else
                if ( locked ) then
                    button.isVeteranLocked = true;
                end

                locationText:SetFontObject("GlueFontDisableSmall");

                if isExpansionTrialCharacter then
					if IsExpansionTrial() then
						if isTrialBoostLocked then
							locationText:SetText(CHARACTER_SELECT_INFO_EXPANSION_TRIAL_BOOST_BUY_EXPANSION);
						else
							locationText:SetText(nil);
						end
					elseif CanUpgradeExpansion() then
						locationText:SetText(CHARACTER_SELECT_INFO_EXPANSION_TRIAL_BOOST_BUY_EXPANSION);
					else
						locationText:SetText(CHARACTER_SELECT_INFO_TRIAL_BOOST_APPLY_BOOST_TOKEN);
					end

                    if isTrialBoostLocked or not IsExpansionTrial() then
                        infoText:SetText(CHARACTER_SELECT_INFO_EXPANSION_TRIAL_BOOST_LOCKED);
                        CharacterSelect_SetupPadlockForCharacterButton(button, guid);

                        if (not areCharServicesShown) then
                            nameText:SetTextColor(.5, .5, .5, 1);
                        end
                    else
                        infoText:SetText(CHARACTER_SELECT_INFO_EXPANSION_TRIAL_PLAYABLE);
                    end
                elseif isTrialBoost then
                    locationText:SetText(CHARACTER_SELECT_INFO_TRIAL_BOOST_APPLY_BOOST_TOKEN);

                    if isTrialBoostLocked then
                        infoText:SetText(CHARACTER_SELECT_INFO_TRIAL_BOOST_LOCKED);
                        CharacterSelect_SetupPadlockForCharacterButton(button, guid);

                        if (not areCharServicesShown) then
                            nameText:SetTextColor(.5, .5, .5, 1);
                        end
                    else
                        infoText:SetText(CHARACTER_SELECT_INFO_TRIAL_BOOST_PLAYABLE);
                    end
                else
                    if( ghost ) then
                        infoText:SetFormattedText(CHARACTER_SELECT_INFO_GHOST, level, class);
                    else
                        infoText:SetFormattedText(CHARACTER_SELECT_INFO, level, class);
                    end

                    locationText:SetText(zone);

                    if revokedCharacterUpgrade then
                        CharacterSelect_SetupPadlockForCharacterButton(button, guid);
                    end
                end
            end
        end
        button:Show();
        button.index = i + CHARACTER_LIST_OFFSET;

        -- setup paid service button
        local paidServiceButton = _G["CharSelectPaidService"..i];
		paidServiceButton.VASIcon:SetSize(46, 46);
		paidServiceButton.tooltip = nil;
		paidServiceButton.tooltip2 = nil;
		paidServiceButton.tooltip3 = nil;
		paidServiceButton.disabledTooltip = nil;
		paidServiceButton.disabledTooltip2 = nil;
		paidServiceButton.disabledTooltip3 = nil;

        local upgradeIcon = _G["CharacterServicesProcessingIcon"..i];
        upgradeIcon:Hide();

        local serviceType, disableService;
        if (vasServiceState == Enum.VasPurchaseProgress.PaymentPending) then
            upgradeIcon:Show();
            upgradeIcon.tooltip = CHARACTER_UPGRADE_PROCESSING;
            upgradeIcon.tooltip2 = CHARACTER_STATE_ORDER_PROCESSING;
        elseif (vasServiceState == Enum.VasPurchaseProgress.ApplyingLicense and #vasServiceErrors > 0) then
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
        elseif (boostInProgress) then
            upgradeIcon:Show();
            upgradeIcon.tooltip = CHARACTER_UPGRADE_PROCESSING;
            upgradeIcon.tooltip2 = CHARACTER_SERVICES_PLEASE_WAIT;
		elseif ( vasServiceState == Enum.VasPurchaseProgress.WaitingOnQueue and productInfo ) then
			upgradeIcon:Show();
            upgradeIcon.tooltip = CHARACTER_UPGRADE_PROCESSING;
            upgradeIcon.tooltip2 = VAS_SERVICE_PROCESSING:format(productInfo.sharedData.name);
            if (VAS_QUEUE_TIMES[guid] and VAS_QUEUE_TIMES[guid] > 0) then
                upgradeIcon.tooltip2 = upgradeIcon.tooltip2 .. "|n" .. VAS_PROCESSING_ESTIMATED_TIME:format(SecondsToTime(VAS_QUEUE_TIMES[guid]*60, true, false, 2, true))
            end
		elseif ( vasServiceState == Enum.VasPurchaseProgress.ProcessingFactionChange ) then
            upgradeIcon:Show();
            upgradeIcon.tooltip = CHARACTER_UPGRADE_PROCESSING;
            upgradeIcon.tooltip2 = CHARACTER_SERVICES_PLEASE_WAIT;
        elseif ( CharacterSelect.undeleting ) then
            paidServiceButton:Hide();
            paidServiceButton.serviceType = nil;
		elseif ( IsEraChoiceStateLocked(eraChoiceState) and not CharSelectServicesFlowFrame:IsShown() ) then
            serviceType = PAID_CHARACTER_CLONE;
            paidServiceButton.GoldBorder:Hide();
			paidServiceButton.VASIcon:SetAtlas("ui-paidcharactercustomization-button-activatecharacter");
			paidServiceButton.VASIcon:SetSize(64, 64); -- This atlas includes the border, so we'll expand the icon to fill the frame.
            paidServiceButton.VASIcon:Show();
            paidServiceButton.texture:Hide();
			disableService = not C_StorePublic.DoesGroupHavePurchaseableProducts(WOW_CLASSIC_CHARACTER_CLONE_CATEGORY_ID);
			paidServiceButton.tooltip = BURNING_CRUSADE_TRANSITION_ACTIVATECHARACTER_TOOLTIP_TITLE;
			paidServiceButton.tooltip2 = BURNING_CRUSADE_TRANSITION_ACTIVATECHARACTER_TOOLTIP_DESCRIPTION;
			paidServiceButton.tooltip3 = "|cff20ff20" .. BURNING_CRUSADE_TRANSITION_ACTIVATECHARACTER_TOOLTIP_ACTION .. "|r";
			paidServiceButton.disabledTooltip = BURNING_CRUSADE_TRANSITION_ACTIVATECHARACTER_TOOLTIP_TITLE;
			paidServiceButton.disabledTooltip2 = BURNING_CRUSADE_TRANSITION_ACTIVATECHARACTER_TOOLTIP_DESCRIPTION;
            paidServiceButton.disabledTooltip3 = BLIZZARD_STORE_NOT_AVAILABLE_SUBTEXT;
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
    end

	if (GetTBCTransitionUIEnabled() and GetNumCharactersInactiveForEra() ~= 0) then
		CharSelectShowUnactivatedCharactersCheckButton:Show();
	else
		CharSelectShowUnactivatedCharactersCheckButton:Hide();
	end

    DebugLog(debugText);
    CharacterSelect_UpdateButtonState();

    CharacterSelect_UpdateStoreButton();

    CharacterSelect_ResetVeteranStatus();
    CharacterSelect_CheckVeteranStatus();

    CharacterSelect.createIndex = 0;

    CharSelectCreateCharacterButton:Hide();
    CharSelectUndeleteCharacterButton:Hide();
	CharSelectCreateCharacterButton.tooltip = nil;

    local connected = IsConnectedToServer();
    if (not CharacterSelect.undeleting) then
		if (CanCreateCharacter()) then
			CharacterSelect.createIndex = numChars + 1;
			if ( connected ) then
				--If can create characters position and show the create button
				CharSelectCreateCharacterButton:SetID(CharacterSelect.createIndex);
				CharSelectCreateCharacterButton:Show();
				UpdateCharacterUndeleteStatus();
				CharSelectUndeleteCharacterButton:Show();
			end
		elseif (numChars < GetNumCharacters()) then
			-- If our number of visible characters is less than our total number of characters,
			-- display the Create Character button with a helpful error message.
			CharSelectCreateCharacterButton.tooltip = CHAR_CREATE_UNACTIVATED_CHARACTER_LIMIT;
			CharSelectCreateCharacterButton:Show();
			CharSelectCreateCharacterButton:SetEnabled(false);
			UpdateCharacterUndeleteStatus();
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
        end
    end

    if ( numChars == 0 and not skipSelect ) then
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
    PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
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
    local numCharacters = GetNumVisibleCharacters();
    if ( numCharacters <= 1 ) then
        return;
    end

	-- Since active characters are always sorted before inactive characters, we can use the active character count as an index.
	local lastActiveCharacterIndex = GetNumCharactersActiveForEra();

    if ( not CharacterSelect.draggedIndex ) then
        button.upButton:Show();
        button.upButton.normalTexture:SetPoint("CENTER", 0, 0);
        button.upButton.highlightTexture:SetPoint("CENTER", 0, 0);
        button.downButton:Show();
        button.downButton.normalTexture:SetPoint("CENTER", 0, 0);
        button.downButton.highlightTexture:SetPoint("CENTER", 0, 0);
        if ( button.index == 1 or button.index == lastActiveCharacterIndex+1 ) then
            button.upButton:Disable();
            button.upButton:SetAlpha(0.35);
        else
            button.upButton:Enable();
            button.upButton:SetAlpha(1);
        end

        if ( button.index == numCharacters or button.index == lastActiveCharacterIndex ) then
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

function CharacterSelect_CreateNewCharacter(characterType, allowCharacterTypeFrameToShow)
    C_CharacterCreation.SetCharacterCreateType(characterType);
    CharacterSelect_SelectCharacter(CharacterSelect.createIndex);
end

function CharacterSelect_SelectCharacter(index, noCreate)
    if ( index == CharacterSelect.createIndex ) then
        if ( not noCreate ) then
            PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
            C_CharacterCreation.ClearCharacterTemplate();
            GlueParent_SetScreen("charcreate");
        end
    else
        local charID = GetCharIDFromIndex(index);
        SelectCharacter(charID);

        if (not C_WowTokenPublic.GetCurrentMarketPrice() or
            not CAN_BUY_RESULT_FOUND or (CAN_BUY_RESULT_FOUND ~= LE_TOKEN_RESULT_ERROR_SUCCESS and CAN_BUY_RESULT_FOUND ~= LE_TOKEN_RESULT_ERROR_SUCCESS_NO) ) then
            AccountReactivate_RecheckEligibility();
        end
        ReactivateAccountDialog_Open();
        SetBackgroundModel(CharacterSelectModel, GetSelectBackgroundModel(charID));

        -- Update the text of the EnterWorld button based on the type of character that's selected, default to "enter world"
        local text = ENTER_WORLD;
        local isTrialBoostLocked, revokedCharacterUpgrade = select(23,GetCharacterInfo(GetCharacterSelection()));
        if ( isTrialBoostLocked ) then
            text = ENTER_WORLD_UNLOCK_TRIAL_CHARACTER;
		elseif ( revokedCharacterUpgrade ) then
			text = ENTER_WORLD_UNLOCK_REVOKED_CHARACTER_UPGRADE;
        end
        CharSelectEnterWorldButton:SetText(text);
    end
end


function CharacterSelect_SelectCharacterByGUID(guid)
    local num = math.min(GetNumVisibleCharacters(), MAX_CHARACTERS_DISPLAYED);

    for i = 1, num do
        if (select(15, GetCharacterInfo(GetCharIDFromIndex(i + CHARACTER_LIST_OFFSET))) == guid) then
            local button = _G["CharSelectCharacterButton"..i];
            CharacterSelectButton_OnClick(button);
            button:LockHighlight();
			SetLastCharacterGuid(guid);
            UpdateCharacterSelection(CharacterSelect);
            GetCharacterListUpdate();
            return true;
        end
    end

    return false;
end

function CharacterDeleteDialog_OnShow()
    local name, race, _, class, classFileName, classID, level = GetCharacterInfo(GetCharIDFromIndex(CharacterSelect.selectedIndex));
    CharacterDeleteText1:SetFormattedText(CONFIRM_CHAR_DELETE, name, level, class);
    CharacterDeleteBackground:SetHeight(16 + CharacterDeleteText1:GetHeight() + CharacterDeleteText2:GetHeight() + 23 + CharacterDeleteEditBox:GetHeight() + 8 + CharacterDeleteButton1:GetHeight() + 16);
    CharacterDeleteButton1:Disable();
end

function CharacterSelect_EnterWorld()
    CharacterSelect_SaveCharacterOrder();
    local guid, _, _, _, _, _, locked, _, _, _, _, _, _, _, eraChoiceState = select(15,GetCharacterInfo(GetCharacterSelection()));

    if ( locked ) then
        SubscriptionRequestDialog_Open();
        return;
    end

	if ( GetTBCTransitionUIEnabled() and DoesEraChoiceStateRequireDecision(eraChoiceState)) then
			ChoicePane:Show();
		return;
	end

    PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ENTER_WORLD);
    StopGlueAmbience();
    EnterWorld();
end

function CharacterSelect_Exit()
    CharacterSelect_SaveCharacterOrder();
    PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_EXIT);
    C_Login.DisconnectFromServer();
end

function CharacterSelect_AccountOptions()
    PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS);
end

function CharacterSelect_TechSupport()
    PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS);
    LaunchURL(TECH_SUPPORT_URL);
end

function CharacterSelect_Delete()
    PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_DEL_CHARACTER);
    if ( CharacterSelect.selectedIndex > 0 ) then
        CharacterSelect_SaveCharacterOrder();
        CharacterDeleteDialog:Show();
    end
end

function CharacterSelect_ChangeRealm()
    PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_DEL_CHARACTER);
    CharacterSelect_SaveCharacterOrder();
    CharacterSelect_SetAutoSwitchRealm(false);
    C_RealmList.RequestChangeRealmList();
end

function CharacterSelect_AllowedToEnterWorld()
    if (GetNumVisibleCharacters() == 0) then
        return false;
    elseif (CharacterSelect.undeleting) then
        return false;
    elseif (AccountReactivationInProgressDialog:IsShown()) then
        return false;
    elseif (GoldReactivateConfirmationDialog:IsShown()) then
        return false;
    elseif (TokenReactivateConfirmationDialog:IsShown()) then
        return false;
    elseif (CharSelectServicesFlowFrame:IsShown()) then
        return false;
	elseif (Kiosk.IsEnabled() and (CharacterSelect.hasPendingTrialBoost or KioskMode_IsWaitingOnTrial())) then
		return false;
	elseif (IsNameReservationOnly()) then
		return false;
    end

    local isTrialBoost, isTrialBoostLocked, revokedCharacterUpgrade, vasServiceInProgress, _, _, isExpansionTrialCharacter = select(22, GetCharacterInfo(GetCharacterSelection()));
	local trialBoostUnavailable = (isExpansionTrialCharacter and (isTrialBoostLocked or not IsExpansionTrial())) or (isTrialBoost and (isTrialBoostLocked or not C_CharacterServices.IsTrialBoostEnabled()));
    if (revokedCharacterUpgrade or trialBoostUnavailable) then
        return false;
    end

	local eraChoiceState = select(29,GetCharacterInfo(GetCharIDFromIndex(GetCharacterSelection())));
	if (IsEraChoiceStateLocked(eraChoiceState)) then
		return false;
	end

    --[[if (vasServiceInProgress) then
        return false;
    end]]

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
    PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS);
    LaunchURL(AUTH_NO_TIME_URL);
end

function CharacterSelect_PaidServiceOnClick(self, button, down, service)
    local translatedIndex =  GetCharIDFromIndex(self:GetID() + CHARACTER_LIST_OFFSET);
    if (translatedIndex <= 0 or translatedIndex > GetNumVisibleCharacters()) then
        -- Somehow our character order got borked, reset the offset and get an updated character list.
        CHARACTER_LIST_OFFSET = 0;
        PAID_SERVICE_CHARACTER_ID = nil;
        PAID_SERVICE_TYPE = nil;
        GetCharacterListUpdate();
        return;
    end

    PAID_SERVICE_CHARACTER_ID = translatedIndex;
    PAID_SERVICE_TYPE = service;
    PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
    if (CharacterSelect.undeleting) then
        local guid = select(15, GetCharacterInfo(PAID_SERVICE_CHARACTER_ID));
        CharacterSelect.pendingUndeleteGuid = guid;
        local timeStr = SecondsToTime(CHARACTER_UNDELETE_COOLDOWN, false, true, 1, false);
        GlueDialog_Show("UNDELETE_CONFIRM", UNDELETE_CONFIRMATION:format(timeStr));
	elseif (PAID_SERVICE_TYPE == PAID_CHARACTER_CLONE) then
		CloneConfirmation:Show();
    else
        GlueParent_SetScreen("charcreate");
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
    local currentGlueTag = GetCurrentGlueTag();

    if ( self.currentGlueTag ~= currentGlueTag or self.state ~= state ) then
        self.currentGlueTag = currentGlueTag;
        self.state = state;

        if ( currentGlueTag == deathKnightTag ) then
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
        else
            local textureBase = "Interface\\Buttons\\UI-DialogBox-goldbutton-" .. state;

            self.Left:SetTexture(textureBase.."-left");
            self.Middle:SetTexture(textureBase.."-middle");
            self.Right:SetTexture(textureBase.."-right");
            self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight");
        end
    end
end

function CharacterSelectScrollDown_OnClick()
    PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
    local numChars = GetNumVisibleCharacters();
    if ( numChars > 1 ) then
        if ( CharacterSelect.selectedIndex < GetNumVisibleCharacters() ) then
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
    PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
    local numChars = GetNumVisibleCharacters();
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
    if ( GetNumVisibleCharacters() > 1 ) then
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
        local paidBtn = _G["CharSelectPaidService"..index];
        paidBtn.texture:SetVertexColor(1, 1, 1);
        paidBtn.GoldBorder:SetVertexColor(1, 1, 1);
        paidBtn.VASIcon:SetVertexColor(1, 1, 1);
        if ( CharacterSelect.selectedIndex == index and button:IsMouseOver() ) then
			button:LockHighlight();
            CharacterSelectButton_ShowMoveButtons(button);
        end
    end
end

function MoveCharacter(originIndex, targetIndex, fromDrag)
	local originEraChoiceState = select(29,GetCharacterInfo(GetCharIDFromIndex(originIndex)));
	local targetEraChoiceState = select(29,GetCharacterInfo(GetCharIDFromIndex(targetIndex)));
	if (IsEraChoiceStateLocked(originEraChoiceState) ~= IsEraChoiceStateLocked(targetEraChoiceState)) then
		return;
	end

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

function IsEraChoiceStateLocked(eraChoiceState)
	if( not GetTBCTransitionUIEnabled() ) then 
		return false;
	end

	return eraChoiceState == Enum.CharacterEraChoiceState.CharacterEraChoiceLockedToOtherEra;
end

function DoesEraChoiceStateRequireDecision(eraChoiceState)
	return eraChoiceState == Enum.CharacterEraChoiceState.CharacterEraChoiceUndecided;
end

-- Account upgrade panel
function AccountUpgradePanel_GetDisplayExpansionLevel()
    if IsTrialAccount() then
		return nil, LE_EXPANSION_CLASSIC;
    end

	local currentExpansionLevel = GetClampedCurrentExpansionLevel();
	if IsExpansionTrial() then
		currentExpansionLevel = currentExpansionLevel - 1;
	end
	local upgradeExpansionLevel = math.min(currentExpansionLevel + 1, GetMaximumExpansionLevel());
	
	local minExpansionLevel = GetMinimumExpansionLevel();

	if currentExpansionLevel <= minExpansionLevel then
		currentExpansionLevel = LE_EXPANSION_CLASSIC;
	end
	
	if upgradeExpansionLevel <= minExpansionLevel then
		upgradeExpansionLevel = LE_EXPANSION_CLASSIC;
	end

	return currentExpansionLevel, upgradeExpansionLevel;
end

function AccountUpgradePanel_GetBannerInfo()
		local currentExpansionLevel = AccountUpgradePanel_GetDisplayExpansionLevel();
	local shouldShowBanner = false; -- We never want to show the banner for Classic.
			return currentExpansionLevel, shouldShowBanner;
end

function AccountUpgradePanel_Update(isExpanded)
	local currentExpansionLevel, shouldShowBanner, upgradeButtonText, upgradeLogo, upgradeBanner, features = AccountUpgradePanel_GetBannerInfo();
	SetGameLogo(CharacterSelectLogo);
    if ( shouldShowBanner ) then
		CharSelectAccountUpgradeButton:SetText(upgradeButtonText);
        CharacterSelectServerAlertFrame:SetPoint("TOP", CharSelectAccountUpgradeMiniPanel, "BOTTOM", 0, -35);
        CharSelectAccountUpgradeButton:Show();
        if ( isExpanded ) then
            CharSelectAccountUpgradePanel:Show();
            CharSelectAccountUpgradeMiniPanel:Hide();

			CharSelectAccountUpgradePanel.logo:SetTexture(upgradeLogo);
            CharSelectAccountUpgradePanel.banner:SetAtlas(upgradeBanner, true);

            local featureFrames = CharSelectAccountUpgradePanel.featureFrames;
            for i=1, #features do
                local frame = featureFrames[i];
                if ( not frame ) then
                    frame = CreateFrame("FRAME", "CharSelectAccountUpgradePanelFeature"..i, CharSelectAccountUpgradePanel, "UpgradeFrameFeatureTemplate");
                    frame:SetPoint("TOPLEFT", featureFrames[i - 1], "BOTTOMLEFT", 0, 0);
                end

                frame.icon:SetTexture(features[i].icon);
                frame.text:SetText(features[i].text);
            end
            for i=#features + 1, #featureFrames do
                featureFrames[i]:Hide();
            end

            CharSelectAccountUpgradeButtonExpandCollapseButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up");
            CharSelectAccountUpgradeButtonExpandCollapseButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down");
            CharSelectAccountUpgradeButtonExpandCollapseButton:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Disabled");
        else
            CharSelectAccountUpgradePanel:Hide();
            CharSelectAccountUpgradeMiniPanel:Show();

            CharSelectAccountUpgradeMiniPanel.logo:SetTexture(upgradeLogo);
            CharSelectAccountUpgradeMiniPanel.banner:SetAtlas(upgradeBanner, true);

            CharSelectAccountUpgradeButtonExpandCollapseButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up");
            CharSelectAccountUpgradeButtonExpandCollapseButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down");
            CharSelectAccountUpgradeButtonExpandCollapseButton:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled");
        end
	else
		CharSelectAccountUpgradePanel:Hide();
		CharSelectAccountUpgradeButton:Hide();
		CharSelectAccountUpgradeMiniPanel:Hide();
		CharacterSelectServerAlertFrame:SetPoint("TOP", CharacterSelectLogo, "BOTTOM", 0, -5);
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
        CharSelectAccountUpgradeButton.expandCollapseButton:Hide();
    else
        CharSelectAccountUpgradeButton.expandCollapseButton:Show();
        CharSelectAccountUpgradeButton.expandCollapseButton:Enable();
    end
    AccountUpgradePanel_Update(CharSelectAccountUpgradeButton.isExpanded);
end

function CharSelectAccountUpgradeButton_OnClick(self)
    PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
	if IsVeteranTrialAccount() then
		SubscriptionRequestDialog_Open();
	else
		UpgradeAccount();
	end
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

function CharacterSelect_ScrollToCharacter(self, characterGUID)
	local numCharacters = GetNumVisibleCharacters();
	if numCharacters <= MAX_CHARACTERS_DISPLAYED then
		return;
	end

	local maxScroll = max(numCharacters - MAX_CHARACTERS_DISPLAYED, 0);
	for i = 1, maxScroll do
		local guid = select(15, GetCharacterInfo(i));
		if guid == characterGUID then
			CharacterSelect_ScrollList(self, i);
			return;
		end
	end
	
	CharacterSelect_ScrollList(self, maxScroll);
end

function CharacterTemplatesFrame_Update()
    if (IsGMClient() and HideGMOnly()) then
        return;
    end

    local self = CharacterTemplatesFrame;
    local numTemplates = C_CharacterCreation.GetNumCharacterTemplates();
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
    for i = 1, C_CharacterCreation.GetNumCharacterTemplates() do
        local name, description = C_CharacterCreation.GetCharacterTemplateInfo(i);
        info.text = name;
        info.checked = nil;
        info.func = CharacterTemplatesFrameDropDown_OnClick;
        info.tooltipTitle = name;
        info.tooltipText = description;
        GlueDropDownMenu_AddButton(info);
    end
end

function ToggleStoreUI()
	if (not STORE_IS_LOADED) then
		STORE_IS_LOADED = LoadAddOn("Blizzard_StoreUI")
		LoadAddOn("Blizzard_AuthChallengeUI");
	end

    if (STORE_IS_LOADED) then
        local wasShown = StoreFrame_IsShown();
        if ( not wasShown ) then
            --We weren't showing, now we are. We should hide all other panels.
            -- not sure if anything is needed here at the gluescreen
        end
        StoreFrame_SetShown(not wasShown);
    end
end

function SetStoreUIShown(shown)
	if (not STORE_IS_LOADED) then
		STORE_IS_LOADED = LoadAddOn("Blizzard_StoreUI")
		LoadAddOn("Blizzard_AuthChallengeUI");
	end

	if (STORE_IS_LOADED) then
		local wasShown = StoreFrame_IsShown();
		if ( not wasShown and shown ) then
			--We weren't showing, now we are. We should hide all other panels.
			-- not sure if anything is needed here at the gluescreen
		end
		
		StoreFrame_SetShown(shown);
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

function CharacterSelect_IsStoreAvailable()
    return C_StorePublic.IsEnabled() and not C_StorePublic.IsDisabledByParentalControls() and GetNumCharacters() > 0 and not GameLimitedMode_IsActive();
end

function CharacterSelect_UpdateStoreButton()
    if ( CharacterSelect_IsStoreAvailable() and not Kiosk.IsEnabled()) then
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
    local hasCharacters = GetNumVisibleCharacters() > 0;
    local servicesEnabled = not CharSelectServicesFlowFrame:IsShown();
    local undeleting = CharacterSelect.undeleting;
    local undeleteEnabled, undeleteOnCooldown = GetCharacterUndeleteStatus();
    local redemptionInProgress = AccountReactivationInProgressDialog:IsShown() or GoldReactivateConfirmationDialog:IsShown() or TokenReactivateConfirmationDialog:IsShown();
    local inCompetitiveMode = IsCompetitiveModeEnabled();
	local inKioskMode = Kiosk.IsEnabled();
	local canCreateCharacter = CanCreateCharacter();

    local boostInProgress = select(19,GetCharacterInfo(GetCharacterSelection()));
    CharSelectEnterWorldButton:SetEnabled(CharacterSelect_AllowedToEnterWorld());
    CharacterSelectBackButton:SetEnabled(servicesEnabled and not undeleting and not boostInProgress);
    CharacterSelectDeleteButton:SetEnabled(hasCharacters and servicesEnabled and not undeleting and not redemptionInProgress and not CharacterSelect_IsRetrievingCharacterList());
    CharSelectChangeRealmButton:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress);
    CharSelectUndeleteCharacterButton:SetEnabled(canCreateCharacter and servicesEnabled and undeleteEnabled and not undeleteOnCooldown and not redemptionInProgress);
    CharacterSelectAddonsButton:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress and not inKioskMode);
    CopyCharacterButton:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress);
    ActivateFactionChange:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress);
    ActivateFactionChange.texture:SetDesaturated(not (servicesEnabled and not undeleting and not redemptionInProgress));
    CharacterTemplatesFrame.CreateTemplateButton:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress);
    CharacterSelectMenuButton:SetEnabled(servicesEnabled and not redemptionInProgress);
    CharSelectCreateCharacterButton:SetEnabled(canCreateCharacter and servicesEnabled and not redemptionInProgress);
    StoreButton:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress);

    if( CharacterSelect.CharacterBoosts ) then
        for _, frame in pairs(CharacterSelect.CharacterBoosts) do
            frame:SetEnabled(not redemptionInProgress);
        end
    end

    CharSelectAccountUpgradeButton:SetEnabled(not redemptionInProgress and not undeleting and not inCompetitiveMode and not inKioskMode);
end

function CharacterSelect_DeleteCharacter(charID)
    if CharacterSelect_IsRetrievingCharacterList() then
        return;
    end

    DeleteCharacter(GetCharIDFromIndex(CharacterSelect.selectedIndex));
    CharacterDeleteDialog:Hide();
    PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
    GlueDialog_Show("CHAR_DELETE_IN_PROGRESS");
end

local KIOSK_AUTO_REALM_ADDRESS = nil
function SetKioskAutoRealmAddress(realmAddr)
	KIOSK_AUTO_REALM_ADDRESS = realmAddr;
end

function GetKioskAutoRealmAddress()
	return KIOSK_AUTO_REALM_ADDRESS;
end

function KioskMode_CheckAutoRealm()
    local realmAddr = GetKioskAutoRealmAddress();
    if (realmAddr) then
        CharacterSelect_SetAutoSwitchRealm(true);
		C_Login.RequestAutoRealmJoin(realmAddr);
        -- We only want to do this on first load
        SetKioskAutoRealmAddress(nil);
    end
end
    
local KIOSK_MODE_WAITING_ON_TRIAL = false;
function KioskMode_SetWaitingOnTrial(waiting)
    KIOSK_MODE_WAITING_ON_TRIAL = waiting;
end

function KioskMode_IsWaitingOnTrial()
    return KIOSK_MODE_WAITING_ON_TRIAL;
end

function KioskMode_CheckEnterWorld()
    if (not Kiosk.IsEnabled()) then
        return;
    end

	if (not KioskMode_IsWaitingOnTrial()) then
        if (KioskModeSplash:GetAutoEnterWorld()) then
            EnterWorld();
        else
			if (not IsGMClient()) then
            KioskDeleteAllCharacters();
			end
            if (IsKioskGlueEnabled()) then
                GlueParent_SetScreen("kioskmodesplash");
            end
        end
    end
end

-- CHARACTER BOOST (SERVICES)
function CharacterServicesMaster_UpdateServiceButton()
    if not CharacterSelect.CharacterBoosts  then
        CharacterSelect.CharacterBoosts = {}
    else
        for _, frame in pairs(CharacterSelect.CharacterBoosts) do
            frame:Hide();
            frame.Glow:Hide();
            frame.GlowSpin:Hide();
            frame.GlowPulse:Hide();
            frame.GlowSpin.SpinAnim:Stop();
            frame.GlowPulse.PulseAnim:Stop();
        end
    end
	
	CharacterSelect.numActiveCharacterBoosts = 0;
	
    UpgradePopupFrame:Hide();
    CharacterSelectUI.WarningText:Hide();

    if CharacterSelect.undeleting or CharSelectServicesFlowFrame:IsShown() then
        return;
    end

    local upgradeInfo = C_SharedCharacterServices.GetUpgradeDistributions();	
    local hasPurchasedBoost = false;
    for id, data in pairs(upgradeInfo) do
		hasPurchasedBoost = hasPurchasedBoost or data.hasPaid;
    end

	local isExpansionTrial, expansionTrialRemainingSeconds = GetExpansionTrialInfo();
	if isExpansionTrial then
		upgradeInfo[0] = {hasPaid = false, hasFree = true, amount = 1, isExpansionTrial = true, remainingTime = expansionTrialRemainingSeconds};
	end

    -- support refund notice for Korea
    if hasPurchasedBoost and C_StoreSecure.GetCurrencyID() == CURRENCY_KRW then
        CharacterSelectUI.WarningText:Show();
    end

	local characterServiceDisplayInfo = C_CharacterServices.GetCharacterServiceDisplayOrder();
    for _, boostType in pairs(characterServiceDisplayInfo) do
		DisplayBattlepayTokens(upgradeInfo[boostType], boostType);
	end

	local accountExpansion = GetAccountExpansionLevel();
	local MINIMUM_BOOST_POPUP_SHOWN = 7;

	-- We don't show the free boost popup if your region doesn't sell boxes.
	if DoesCurrentLocaleSellExpansionLevels() then
	local freeFrame = nil;
	for i = 1, CharacterSelect.numActiveCharacterBoosts do
		local boostFrame = CharacterSelect.CharacterBoosts[i];
			local boostFrameIsBetterCandidate = false;

			if boostFrame.data.expansion >= MINIMUM_BOOST_POPUP_SHOWN then
				if not freeFrame then
					boostFrameIsBetterCandidate = true;
				elseif boostFrame.data.isExpansionTrial then
					boostFrameIsBetterCandidate = not freeFrame.data.isExpansionTrial or boostFrame.data.expansion > freeFrame.data.expansion;
				else
					boostFrameIsBetterCandidate = not freeFrame.data.isExpansionTrial and boostFrame.data.expansion > freeFrame.data.expansion;
				end
			end

		if boostFrameIsBetterCandidate then
				if boostFrame.data.isExpansionTrial then
					if isExpansionTrial and boostFrame.data.expansion <= accountExpansion and boostFrame.data.expansion > C_SharedCharacterServices.GetLastSeenExpansionTrialPopup() then
						freeFrame = boostFrame;
					end
				else
					if boostFrame.data.expansion <= accountExpansion and boostFrame.data.expansion > C_SharedCharacterServices.GetLastSeenCharacterUpgradePopup() then
				freeFrame = boostFrame;
			end
		end
	end
		end
		
		if freeFrame then
		DisplayBattlepayTokenFreeFrame(freeFrame);
	end
	end
end

function DisplayBattlepayTokens(upgradeInfo, boostType)
	if upgradeInfo and upgradeInfo.amount > 0 then
	local charUpgradeDisplayData = C_CharacterServices.GetCharacterServiceDisplayData(boostType);
		DisplayBattlepayTokenType(charUpgradeDisplayData, upgradeInfo);
	end
end

function DisplayBattlepayTokenType(charUpgradeDisplayData, upgradeInfo)
	if upgradeInfo.amount > 0 then
		CharacterSelect.numActiveCharacterBoosts = CharacterSelect.numActiveCharacterBoosts + 1;
		
		local boostFrameIndex = CharacterSelect.numActiveCharacterBoosts;
		local frame = CharacterSelect.CharacterBoosts[boostFrameIndex];
		if not frame then
			frame = CreateFrame("Button", "CharacterSelectCharacterBoost"..boostFrameIndex, CharacterSelect, "CharacterBoostTemplate");
		end

		frame.data = charUpgradeDisplayData;
		frame.data.isExpansionTrial = upgradeInfo.isExpansionTrial;
		frame.data.frameType = FRAME_TYPE_CHARACTER_BOOST;
		frame.hasFreeBoost = upgradeInfo.hasFree;
		frame.remainingTime = upgradeInfo.remainingTime;

		SetPortraitToTexture(frame.Icon, charUpgradeDisplayData.icon);
		SetPortraitToTexture(frame.Highlight.Icon, charUpgradeDisplayData.icon);
		frame.Highlight.IconBorder:SetAtlas(charUpgradeDisplayData.iconBorderAtlas);

		if boostFrameIndex > 1 then
			frame:SetPoint("TOPRIGHT", CharacterSelect.CharacterBoosts[boostFrameIndex - 1], "TOPLEFT", -3, 0);
		else
			frame:SetPoint("TOPRIGHT", CharacterSelectCharacterFrame, "TOPLEFT", -18, -4);
		end

		if upgradeInfo.remainingTime then
			frame.Timer:StartTimer(upgradeInfo.remainingTime, 1, true);
		else
			frame.Timer:StopTimer();
		end

		if upgradeInfo.amount > 1 then
			frame.Ring:Show();
			frame.NumberBackground:Show();
			frame.Number:Show();
			frame.Number:SetText(upgradeInfo.amount);
		else
			frame.Ring:Hide();
			frame.NumberBackground:Hide();
			frame.Number:Hide();
		end
		frame:Show();
	end
end

function GetTBCInfoIconFrame()
	if CharacterSelect.notificationIconFrames and #CharacterSelect.notificationIconFrames > 0 then
		for i=1, #CharacterSelect.notificationIconFrames do
			local frame = CharacterSelect.notificationIconFrames[i];
			if frame and frame.frameType == FRAME_TYPE_TBC_INFO_PANE then
				return frame;
			end
		end
	end

	return nil;
end

function DisplayTBCInfoPaneIcon()
	if not GetTBCInfoPaneEnabled() then
		local frame = GetTBCInfoIconFrame();
		if frame then
			frame:Hide();
		end
		return;
	end

	-- Check if the icon has already been shown
	if GetTBCInfoIconFrame() then
		return;
	end

	local newFrame = CreateFrame("Button", "TBCInfoPaneIcon", CharacterSelect, "TBCInfoPaneTemplate");
	newFrame.frameType = FRAME_TYPE_TBC_INFO_PANE;

	DisplayNotificationIcon(newFrame);
end

-- Show an arbitrary button frame in the top right next to the character list.  Will extend to the left with each button added.
-- For now we do not have a case when we show both the Info Pane and the Level Up token, but when we do they can both be shown via this function.
function DisplayNotificationIcon(buttonFrame)
	if not CharacterSelect.notificationIconFrames then
        CharacterSelect.notificationIconFrames = {};
	end

	local iconFrameIndex = #CharacterSelect.notificationIconFrames;
	CharacterSelect.notificationIconFrames[iconFrameIndex] = buttonFrame;

	if iconFrameIndex > 1 then
		buttonFrame:SetPoint("TOPRIGHT", CharacterSelect.notificationIconFrames[iconFrameIndex - 1], "TOPLEFT", 0, 0);
	else
		buttonFrame:SetPoint("TOPRIGHT", CharacterSelectCharacterFrame, "TOPLEFT", -16, 7);
	end

	buttonFrame:Show();
end

function TBCInfoPane_Update()
	DisplayTBCInfoPaneIcon();
	TBCInfoPane_CheckVisible();
end

function TBCInfoPane_Toggle()
	if ( TBCInfoPane:IsShown() ) then
		SetCVar("seenTBCInfoPane", 1);
		TBCInfoPane:Hide();
	else
		TBCInfoPane:Show();
	end
end

function TBCInfoPane_CheckVisible()
	TBCInfoPane:SetShown(GetTBCInfoPaneEnabled() and GetCVar("seenTBCInfoPane") == "0");
end

-- Global because of localization
tbcInfoIconAtlas = "classic-burningcrusade-infoicon";
function TBCInfoPaneTemplate_OnLoad(self)
	DefaultScaleFrameMixin.OnDefaultScaleFrameLoad(self);
	self.TBCIcon:SetAtlas(tbcInfoIconAtlas, true);
	self.TBCIconHighlight:SetAtlas(tbcInfoIconAtlas, true);
end

function TBCInfoPaneTemplate_OnEnter(self)
	GlueTooltip:SetOwner(self);
	if ( self:IsEnabled() ) then
		GlueTooltip:SetText(BURNING_CRUSADE_INFORMATION, 1.0, 1.0, 1.0);
	else
		GlueTooltip:SetText(nil, 1.0, 1.0, 1.0);
	end
end

function TBCInfoPaneTemplate_OnLeave(self)
	GlueTooltip:Hide();
end

-- Global because of localization
tbcInfoPaneInfographicAtlas = "classic-announcementpopup-bcinfographic";
function TBCInfoPane_OnShow(self)
	self.TBCInfoPaneDiagram:SetAtlas(tbcInfoPaneInfographicAtlas, true);
end

function TBCInfoPane_RefreshPrice()
	if( BURNING_CRUSADE_PREVIEW_DESCRIPTION2 ) then
		local formattedPrice = BURNING_CRUSADE_TRANSITION_DEFAULT_PRICE;
		if ( GetTBCInfoPanePriceEnabled() ) then
			formattedPrice = GetFormattedClonePrice();
		end

		TBCInfoPane.TBCInfoPaneHTMLDesc:SetText(string.format(BURNING_CRUSADE_PREVIEW_DESCRIPTION2, formattedPrice));
	end
end

function TBCInfoPaneHTMLDesc_OnLoad(self)
	TBCInfoPane_RefreshPrice();
end

local cloneServiceProductId = 679
function GetFormattedClonePrice()
	local formattedPrice = SecureCurrencyUtil.GetFormattedPrice(cloneServiceProductId);

	if not formattedPrice then
		formattedPrice = BURNING_CRUSADE_TRANSITION_DEFAULT_PRICE;
	end

	return formattedPrice;
end

function ChoicePane_OnPlay()
	if (GetCVar("heardChoiceSFX") == "0") then
		PlaySound(SOUNDKIT.YOU_ARE_NOT_PREPARED);
	else
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
	end
	ChoiceConfirmation:Show();
	ChoicePane:Hide();
end

function ChoicePane_OnExitGame()
	CharacterSelect_SaveCharacterOrder();
	QuitGame();
end

function ChoicePane_Toggle()
	ChoicePane:SetShown(not ChoicePane:IsShown());
end

-- Global because of localization
choicePaneCurrentLogoAtlas = "classic-burningcrusadetransition-choice-logo-current";
choicePaneOtherLogoAtlas = "classic-burningcrusadetransition-choice-logo-other";
function ChoicePane_OnShow(self)
	PlaySound(SOUNDKIT.JEWEL_CRAFTING_FINALIZE);
	
	local selectedCharName = GetCharacterInfo(GetCharacterSelection());
	ChoicePaneCurrentDesc:SetText(string.format(BURNING_CRUSADE_TRANSITION_CHOICE_CURRENT_DESCRIPTION, selectedCharName, selectedCharName, GetFormattedClonePrice()));

	self.CurrentLogo:SetAtlas(choicePaneCurrentLogoAtlas);
	self.OtherLogo:SetAtlas(choicePaneOtherLogoAtlas);

	FitToParent(GlueParent, self);
end

function ChoicePane_OnClose(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	ChoicePane:Hide();
end

-- ChoiceConfirmationTemplate

-- This name has a different source depending on whether the ChoiceConfirmation or CloneConfirmation is showing.  But it is used in the same manner in the confirmation edit box.
local selectedCharName;
function ChoiceConfirmationEditBox_OnTextChanged(self)
	if ( strupper(self:GetText()) == strupper(selectedCharName) ) then
		self:GetParent().ChoiceConfirmationConfirmButton:Enable();
	else
		self:GetParent().ChoiceConfirmationConfirmButton:Disable();
	end
end

function ChoiceConfirmationEditBox_OnEnterPressed(self)
	if ( self:GetParent().ChoiceConfirmationConfirmButton:IsEnabled() ) then
		self:GetParent().ChoiceConfirmationConfirmButton:Click();
	end
end

function ChoiceConfirmationEditBox_OnEscapePressed(self)
	self:GetParent().ChoiceConfirmationCancelButton:Click();
end

-- ChoiceConfirmation

function ChoiceConfirmation_OnLoad(self)
	DefaultScaleFrameMixin.OnDefaultScaleFrameLoad(self);
	self.ChoiceConfirmationConfirmButton:SetScript("OnClick", ChoiceConfirmation_OnConfirm);
	self.ChoiceConfirmationCancelButton:SetScript("OnClick", ChoiceConfirmation_OnCancel);
end

function ChoiceConfirmation_OnShow(self)
	selectedCharName = GetCharacterInfo(GetCharacterSelection());
	self.ConfirmationLogo:SetAtlas(choicePaneCurrentLogoAtlas);
	self.ChoiceConfirmationTitle:SetText(string.format(BURNING_CRUSADE_TRANSITION_CHOICE_CONFIRM, selectedCharName));
end

function ChoiceConfirmation_OnConfirm(self)
	if (GetCVar("heardChoiceSFX") == "0") then
		PlaySound(SOUNDKIT.FELREAVER);
		SetCVar("heardChoiceSFX", 1);
	else
		PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ENTER_WORLD);
	end
    StopGlueAmbience();
	ChoiceConfirmation:Hide();
    EnterWorldWithTransitionChoice();
end

function ChoiceConfirmation_OnCancel(self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT);
	ChoiceConfirmation:Hide();
end

-- CloneConfirmation

function CloneConfirmation_OnLoad(self)
	DefaultScaleFrameMixin.OnDefaultScaleFrameLoad(self);
	self.ChoiceConfirmationConfirmButton:SetScript("OnClick", CloneConfirmation_OnConfirm);
	self.ChoiceConfirmationCancelButton:SetScript("OnClick", CloneConfirmation_OnCancel);
	self.ChoiceConfirmationConfirmButton:SetText(CONTINUE);
end

function CloneConfirmation_OnShow(self)
	local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, lastActiveDay, lastActiveMonth, lastActiveYear = GetCharacterInfo(PAID_SERVICE_CHARACTER_ID);
	selectedCharName = name;
	self.ConfirmationLogo:SetAtlas(choicePaneCurrentLogoAtlas);
	local formattedDate = string.format(FULLDATE_NO_WEEKDAY, CALENDAR_FULLDATE_MONTH_NAMES[lastActiveMonth], lastActiveDay, lastActiveYear);
	if (not formattedDate) then
		formattedDate = BURNING_CRUSADE_TRANSITION_DEFAULT_CLONE_DATE;
	end
	self.CloneConfirmationTitle:SetText(string.format(BURNING_CRUSADE_TRANSITION_ACTIVATECHARACTER_CONFIRM, selectedCharName, formattedDate));
	self.ChoiceConfirmationInstruction:SetPoint("TOP", self.CloneConfirmationTitle, "BOTTOM", 0, -37);
end

function CloneConfirmation_OnConfirm(self)
    if (C_StorePublic.DoesGroupHavePurchaseableProducts(WOW_CLASSIC_CHARACTER_CLONE_CATEGORY_ID)) then
		CloneConfirmation:Hide();
		StoreFrame_SetShown(true);
		local guid = select(15, GetCharacterInfo(PAID_SERVICE_CHARACTER_ID));
		StoreFrame_SelectActivateProduct(guid);
    end
end

function CloneConfirmation_OnCancel(self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT);
	CloneConfirmation:Hide();
end

local textureKitRegionInfo = {
	["Top"] = {formatString= "%s-boostpopup-top", useAtlasSize=true},
	["Middle"] = {formatString="%s-boostpopup-middle", useAtlasSize = false},
	["Bottom"] = {formatString="%s-boostpopup-bottom", useAtlasSize = true},
	["CloseButtonBG"] = {formatString="%s-boostpopup-exit-frame", useAtlasSize = true}
}

function DisplayBattlepayTokenFreeFrame(freeFrame)
	local freeFrameData = freeFrame.data;
	if not freeFrame.data.isExpansionTrial then
	freeFrame.Glow:SetPoint("CENTER", freeFrame.IconBorder, "CENTER");
	freeFrame.Glow:Show();
	freeFrame.GlowSpin.SpinAnim:Play();
	freeFrame.GlowPulse.PulseAnim:Play();
	freeFrame.GlowSpin:Show();
	freeFrame.GlowPulse:Show();
	end

	local popupData = freeFrameData.popupInfo;
	if popupData then
		local popupFrame = UpgradePopupFrame;
		
		popupFrame.data = freeFrameData;
		popupFrame.Title:SetText(popupData.title);

		local timerHeight = 0;
		if freeFrame.remainingTime then
			popupFrame.Timer:StartTimer(freeFrame.remainingTime, 1, true, true, BOOST_POPUP_TIMER_FORMAT_STRING);
			popupFrame.Description:SetPoint("TOP", popupFrame.Timer, "BOTTOM", 0, -20);
			timerHeight = popupFrame.Timer:GetHeight() + 2;
		else
			popupFrame.Timer:StopTimer();
			popupFrame.Description:SetPoint("TOP", popupFrame.Title, "BOTTOM", 0, -20);
		end

		popupFrame.Description:SetText(popupData.description);
		popupFrame:SetupTextureKit(popupData.textureKitPrefix, textureKitRegionInfo);
		
		local baseHeight;
		if freeFrame.data.isExpansionTrial then
			popupFrame.GetStartedButton:SetText(EXPANSION_TRIAL_CREATE_TRIAL_CHARACTER);
			popupFrame.LaterButton:Hide();
			baseHeight = 160;
		else
			popupFrame.GetStartedButton:SetText(CHARACTER_UPGRADE_POPUP_BOOST_EXISTING_CHARACTER);
			popupFrame.LaterButton:Show();
			baseHeight = 180;
		end

		popupFrame:SetHeight(baseHeight + timerHeight + popupFrame.Description:GetHeight() + popupFrame.Title:GetHeight());
		popupFrame:Show();
	end
end

local function CharacterUpgradePopup_CheckSetPopupSeen(data)
    if UpgradePopupFrame and UpgradePopupFrame.data and UpgradePopupFrame:IsVisible() then
        if data.expansion == UpgradePopupFrame.data.expansion then
			if UpgradePopupFrame.data.isExpansionTrial and C_SharedCharacterServices.GetLastSeenExpansionTrialPopup() < data.expansion then
				C_SharedCharacterServices.SetExpansionTrialPopupSeen(data.expansion);
			elseif C_SharedCharacterServices.GetLastSeenCharacterUpgradePopup() < data.expansion then
				C_SharedCharacterServices.SetCharacterUpgradePopupSeen(data.expansion);
			end
        end
    end
end

local function HandleUpgradePopupButtonClick(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    local data = self:GetParent().data;
    CharacterUpgradePopup_CheckSetPopupSeen(data);
    return data;
end

UpgradePopupFrameMixin = CreateFromMixins(BaseExpandableDialogMixin);

function UpgradePopupFrameMixin:OnCloseClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	CharacterUpgradePopup_CheckSetPopupSeen(self.data);
	CharacterServicesMaster_UpdateServiceButton();
end

function CharacterUpgradePopup_OnCharacterBoostDelivered(boostType, guid, reason)
    if reason == "forUnrevokeBoost" then
		local flowData = C_CharacterServices.GetCharacterServiceDisplayData(boostType);
		CharacterUpgradePopup_BeginCharacterUpgradeFlow(flowData, guid);
    else
        local flowData = C_CharacterServices.GetCharacterServiceDisplayData(boostType);

        if reason == "forClassTrialUnlock" then
            CharacterUpgradePopup_BeginCharacterUpgradeFlow(flowData, guid);
        else
            CharacterUpgradePopup_BeginCharacterUpgradeFlow(flowData);
        end
    end
end

function CharacterUpgradePopup_BeginCharacterUpgradeFlow(data, guid)
	CharacterUpgradeFlow:SetTrialBoostGuid(nil);
	
	if guid then
		local isTrialBoost, isTrialBoostLocked, revokedCharacterUpgrade = select(22, GetCharacterInfoByGUID(guid)); 
		if isTrialBoost then
			CharacterUpgradeFlow:SetTrialBoostGuid(guid);
		else
			CharacterUpgradeFlow:SetAutoSelectGuid(guid);
		end
	end

	CharacterUpgradePopup_CheckSetPopupSeen(data);
    CharacterUpgradeFlow:SetTarget(data);
    CharSelectServicesFlowFrame:Show();
	CharacterServicesMaster_SetFlow(CharacterServicesMaster, CharacterUpgradeFlow);
end

function CharacterUpgradePopup_OnStartClick(self)
    local data = HandleUpgradePopupButtonClick(self);
	if data.isExpansionTrial then
		CharacterSelect_CreateNewCharacter(Enum.CharacterCreateType.TrialBoost, true);
	else
    CharacterUpgradePopup_BeginCharacterUpgradeFlow(data);
	end
end

function CharacterUpgradePopup_OnStartEnter(self)
	local data = self:GetParent().data;
	if not data.isExpansionTrial then
		GlueTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local tooltip = CHARACTER_UPGRADE_POPUP_BOOST_EXISTING_CHARACTER_TOOLTIP:format(data.flowTitle);
		GlueTooltip:SetText(tooltip, nil, nil, nil, nil, true);
	end
end

function CharacterUpgradePopup_OnStartLeave(self)
	GlueTooltip:Hide();
end

function CharacterUpgradePopup_OnTryNewClick(self)
    HandleUpgradePopupButtonClick(self);

    if (C_CharacterServices.IsTrialBoostEnabled()) then
        CharacterUpgrade_BeginNewCharacterCreation(Enum.CharacterCreateType.TrialBoost);
    end
end

function CharacterServicesTokenBoost_OnClick(self)
	if self.data.isExpansionTrial then
		if UpgradePopupFrame:IsShown() then
			UpgradePopupFrame:Hide();
		else
			DisplayBattlepayTokenFreeFrame(self);
		end
    elseif IsVeteranTrialAccount() then
        GlueDialog_Show("CHARACTER_BOOST_FEATURE_RESTRICTED", CHARACTER_BOOST_YOU_MUST_REACTIVATE);
    elseif IsTrialAccount() then
        GlueDialog_Show("CHARACTER_BOOST_FEATURE_RESTRICTED", CHARACTER_BOOST_YOU_MUST_UPGRADE);
    elseif C_CharacterCreation.HasSufficientExperienceForAdvancedCreation() then
        CharacterUpgradePopup_BeginCharacterUpgradeFlow(self.data);
    else
        GlueDialog_Show("CHARACTER_BOOST_NO_CHARACTERS_WARNING", nil, self.data);
    end
end

function CharacterServicesMaster_OnLoad(self)
    self.flows = {};

    self:RegisterEvent("PRODUCT_DISTRIBUTIONS_UPDATED");
    self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
    self:RegisterEvent("PRODUCT_ASSIGN_TO_TARGET_FAILED");
end

local completedGuid;

function CharacterServicesMaster_OnEvent(self, event, ...)
    if (event == "PRODUCT_DISTRIBUTIONS_UPDATED" or event == "UPDATE_EXPANSION_LEVEL") then
        CharacterServicesMaster_UpdateServiceButton();
    elseif (event == "PRODUCT_ASSIGN_TO_TARGET_FAILED") then
        if (CharacterServicesMaster.pendingGuid and C_CharacterServices.DoesGUIDHavePendingFactionChange(CharacterServicesMaster.pendingGuid)) then
            CharacterServicesMaster.pendingGuid = nil;
            GlueDialog_Show("BOOST_FACTION_CHANGE_IN_PROGRESS");
            return;
        end
        GlueDialog_Show("PRODUCT_ASSIGN_TO_TARGET_FAILED");
    end
end

function CharacterServicesMaster_OnCharacterListUpdate()
    CharacterServicesMaster.pendingGuid = nil;
    local automaticBoostType = C_CharacterServices.GetAutomaticBoost();
	local startAutomatically = automaticBoostType ~= nil;
    if (CharacterServicesMaster.waitingForLevelUp) then
        C_CharacterServices.ApplyLevelUp();
        CharacterServicesMaster.waitingForLevelUp = false;
        KioskMode_SetWaitingOnTrial(false);
        KioskMode_CheckEnterWorld();
    elseif (CharacterUpgrade_IsCreatedCharacterUpgrade() or startAutomatically) then
		if (C_CharacterServices.GetAutomaticBoostCharacter()) then
			local automaticBoostCharacterGUID = C_CharacterServices.GetAutomaticBoostCharacter();
			CharacterSelect_ScrollToCharacter(CharacterSelect, automaticBoostCharacterGUID);
			CharacterUpgradePopup_BeginCharacterUpgradeFlow(C_CharacterServices.GetCharacterServiceDisplayData(automaticBoostType), automaticBoostCharacterGUID);
			CharacterSelect_SelectCharacterByGUID(automaticBoostCharacterGUID);
        else
			if (CharacterUpgrade_IsCreatedCharacterUpgrade()) then
				CharacterUpgradeFlow:SetTarget(CHARACTER_UPGRADE_CREATE_CHARACTER_DATA);
			else
				CharacterUpgradeFlow:SetTarget(C_CharacterServices.GetCharacterServiceDisplayData(automaticBoostType), false);
			end
			
			if CharacterUpgradeFlow.data then
				CharSelectServicesFlowFrame:Show();
				CharacterServicesMaster_SetFlow(CharacterServicesMaster, CharacterUpgradeFlow);
			end

			CharacterUpgrade_ResetBoostData();
		end
        
        C_CharacterServices.SetAutomaticBoost(nil);
		C_CharacterServices.SetAutomaticBoostCharacter(nil);
    elseif (C_CharacterServices.HasQueuedUpgrade()) then
        local guid = C_CharacterServices.GetQueuedUpgradeGUID();

          CharacterServicesMaster.waitingForLevelUp = CharacterSelect_SelectCharacterByGUID(guid);

        C_CharacterServices.ClearQueuedUpgrade();
    end
end

function CharacterServicesMaster_UpdateFinishLabel(self)
    local finishButton = self:GetParent().FinishButton;
    local displayText = self.flow:GetFinishLabel();
    finishButton:SetText(displayText);
end

function CharacterServicesMaster_SetFlow(self, flow)
    self.flow = flow;
    if (not self.flows[flow]) then
        setmetatable(flow, { __index = CharacterServicesFlowPrototype });
    end
    self.flows[flow] = true;
    flow:Initialize(self);
    SetPortraitToTexture(self:GetParent().Icon, flow.data.icon);
    self:GetParent().TitleText:SetText(flow.data.flowTitle);

    CharacterServicesMaster_UpdateFinishLabel(self);

    for i = 1, #flow.Steps do
        local block = flow.Steps[i];
        if (not block.HiddenStep) then
            block.frame:SetFrameLevel(CharacterServicesMaster:GetFrameLevel()+2);
            block.frame:SetParent(self);
        end
    end
end

function CharacterServicesMaster_SetCurrentBlock(self, block, wasFromRewind)
    local parent = self:GetParent();
    if (not block.HiddenStep) then
        CharacterServicesMaster_SetBlockActiveState(block);
    end
    self.currentBlock = block;
    self.blockComplete = false;
    parent.BackButton:SetShown(block.Back);
    parent.NextButton:SetShown(block.Next);
    parent.FinishButton:SetShown(block.Finish);
    if (block.Finish) then
        self.FinishTime = GetTime();
    end

    -- Some blocks may remember user choices when the user returns to
    -- them.  As such, even though the block isn't finished for purposes
    -- of advancing to the next step, the next button should still be
    -- enabled.  This addresses an issue where the "alert, next is ready!"
    -- animation was playing even though from the user's point of view
    -- the next button never really appeared disabled.

    local isFinished = block:IsFinished(wasFromRewind);

    if wasFromRewind then
        local forwardStateWouldBeFinished = block:IsFinished();
        parent.NextButton:SetEnabled(forwardStateWouldBeFinished);
    else
        parent.NextButton:SetEnabled(isFinished);
    end

    -- Since there's no way to finish the entire flow and then go back,
    -- the finishButton is always enabled based on the block actually
    -- being finished.
    parent.FinishButton:SetEnabled(isFinished);
end

function CharacterServicesMaster_Restart()
    local self = CharacterServicesMaster;

    if (self.flow) then
        self.flow:Restart(self);
    end
end

function CharacterServicesMaster_Update()
    local self = CharacterServicesMaster;
    local parent = self:GetParent();
    local block = self.currentBlock;

    CharacterServicesMaster_UpdateFinishLabel(self);

	if (block and block:IsFinished()) then
		
        if (not block.HiddenStep and (block.AutoAdvance or self.blockComplete)) then
            CharacterServicesMaster_SetBlockFinishedState(block);
        end

		if (block.AutoAdvance) then
			if ( block.Popup and ( not block.ShouldShowPopup or block:ShouldShowPopup() )) then
		 		local text;
				if ( block.GetPopupText ) then
					text = block:GetPopupText();
				end
				GlueDialog_Show(block.Popup, text);
				return;
			end
            self.flow:Advance(self);
        else
            if (block.Next) then
                if (not parent.NextButton:IsEnabled()) then
                    parent.NextButton:SetEnabled(true);
                    if ( parent.NextButton:IsVisible() ) then
                        parent.NextButton.Flash:Show();
                        parent.NextButton.PulseAnim:Play();
                    end
                end
            elseif (block.Finish) then
                parent.FinishButton:SetEnabled(true);
            end
        end
    elseif (block) then
        if (block.Next) then
            parent.NextButton:SetEnabled(false);

            if ( parent.NextButton:IsVisible() ) then
                parent.NextButton.PulseAnim:Stop();
                parent.NextButton.Flash:Hide();
            end
        elseif (block.Finish) then
            parent.FinishButton:SetEnabled(false);
        end
    end
    self.currentTime = 0;
end

function CharacterServicesMaster_OnHide(self)
    for flow, _ in pairs(self.flows) do
        flow:OnHide();
    end
end

function CharacterServicesMaster_SetBlockActiveState(block)
    block.frame.StepLabel:Show();
    block.frame.StepNumber:Show();
    block.frame.StepActiveLabel:Show();
    block.frame.StepActiveLabel:SetText(block.ActiveLabel);
    block.frame.ControlsFrame:Show();
    block.frame.Checkmark:Hide();
    block.frame.StepFinishedLabel:Hide();
    block.frame.ResultsLabel:Hide();
end

function CharacterServicesMaster_SetBlockFinishedState(block)
    block.frame.Checkmark:Show();
    block.frame.StepFinishedLabel:Show();
    block.frame.StepFinishedLabel:SetText(block.ResultsLabel);
    block.frame.ResultsLabel:Show();
    if (block.FormatResult) then
        block.frame.ResultsLabel:SetText(block:FormatResult());
    else
        block.frame.ResultsLabel:SetText(block:GetResult());
    end
    block.frame.StepLabel:Hide();
    block.frame.StepNumber:Hide();
    block.frame.StepActiveLabel:Hide();
    block.frame.ControlsFrame:Hide();
end

function CharacterServicesMasterBackButton_OnClick(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    local master = CharacterServicesMaster;
    master.flow:Rewind(master);
end

function CharacterServicesMasterNextButton_OnClick(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    local master = CharacterServicesMaster;
    if ( master.currentBlock.Popup and
        ( not master.currentBlock.ShouldShowPopup or master.currentBlock:ShouldShowPopup() )) then
        local text;
        if ( master.currentBlock.GetPopupText ) then
            text = master.currentBlock:GetPopupText();
        end
        GlueDialog_Show(master.currentBlock.Popup, text);
        return;
    end

    CharacterServicesMaster_Advance();
end

function CharacterServicesProcessingIcon_OnEnter(self)
    GlueTooltip:SetOwner(self, "ANCHOR_LEFT", -20, 0);
    GlueTooltip:AddLine(self.tooltip, 1.0, 1.0, 1.0);
    GlueTooltip:AddLine(self.tooltip2, nil, nil, nil, 1, 1);
    GlueTooltip:Show();
end

function CharacterServicesMaster_Advance()
    local master = CharacterServicesMaster;
    master.blockComplete = true;
    CharacterServicesMaster_Update();
    master.flow:Advance(master);
end

function CharacterServicesMasterFinishButton_OnClick(self)
    -- wait a bit after button is shown so no one accidentally upgrades the wrong character
    if ( GetTime() - CharacterServicesMaster.FinishTime < 0.5 ) then
        return;
    end
    local master = CharacterServicesMaster;
    local parent = master:GetParent();
    local success = master.flow:Finish(master);
    if (success) then
        PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
        parent:Hide();
    else
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    end
end

function CharacterServicesTokenBoost_OnEnter(self)
    self.Highlight:Show();
    GlueTooltip:SetOwner(self, "ANCHOR_LEFT");
	if self.data.isExpansionTrial then
		GlueTooltip:AddLine(self.data.popupInfo.title, 1.0, 1.0, 1.0);
		GlueTooltip:AddLine(self.data.popupInfo.description, nil, nil, nil, true);
	else
    GlueTooltip:AddLine(BOOST_TOKEN_TOOLTIP_TITLE:format(self.data.level), 1.0, 1.0, 1.0);
		GlueTooltip:AddLine(BOOST_TOKEN_TOOLTIP_DESCRIPTION:format(self.data.level), nil, nil, nil, true);
	end
    GlueTooltip:Show();
end

function CharacterServicesTokenBoost_OnLeave(self)
    self.Highlight:Hide();
    GlueTooltip:Hide();
end

function CharacterUpgradeSecondChanceWarningFrameConfirmButton_OnClick(self)
    CharacterUpgradeSecondChanceWarningFrame.warningAccepted = true;

    CharacterUpgradeSecondChanceWarningFrame:Hide();

    CharacterServicesMasterFinishButton_OnClick(CharacterServicesMasterFinishButton);
end

function CharacterUpgradeSecondChanceWarningFrameCancelButton_OnClick(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

    CharacterUpgradeSecondChanceWarningFrame:Hide();

    CharacterUpgradeSecondChanceWarningFrame.warningAccepted = false;
end

function CharacterUpgradeSecondChanceWarningFrameConfirmButton_OnShow(self)
	self.hideTimer = 0;
end

BOOST_BUTTON_DELAY = 2;
function CharacterUpgradeSecondChanceWarningFrameConfirmButton_Update(self, elapsed)
	if(self.hideTimer == nil) then self.hideTimer = 0 end;
	self.hideTimer = math.min(self.hideTimer + elapsed, BOOST_BUTTON_DELAY);
	if(self.hideTimer >= BOOST_BUTTON_DELAY and not CharacterUpgradeSecondChanceWarningBackground.ConfirmButton:IsEnabled()) then
		CharacterUpgradeSecondChanceWarningBackground.ConfirmButton:Enable();
	end
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

GlueDialogTypes["UNDELETE_FAILED_PVP"] = {
	text = CHAR_CREATE_PVP_TEAMS_VIOLATION,
	button1 = OKAY,
	escapeHides = true,
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
    GlueDialog_Show("UNDELETING_CHARACTER");

    UndeleteCharacter(guid);
    CharacterSelect.createIndex = 0;
end

function UpdateCharacterUndeleteStatus()
	local enabled, onCooldown, cooldown, remaining = GetCharacterUndeleteStatus();
	local canCreateCharacter = CanCreateCharacter();
	local charactersAreHidden = GetNumVisibleCharacters() < GetNumCharacters();

	CHARACTER_UNDELETE_COOLDOWN = cooldown;
	CHARACTER_UNDELETE_COOLDOWN_REMAINING = remaining;

	CharSelectUndeleteCharacterButton:SetEnabled(enabled and not onCooldown and canCreateCharacter);
	if (not enabled) then
		CharSelectUndeleteCharacterButton.tooltip = UNDELETE_TOOLTIP_DISABLED;
	elseif (onCooldown) then
		local timeStr = SecondsToTime(remaining, false, true, 1, false);
		CharSelectUndeleteCharacterButton.tooltip = UNDELETE_TOOLTIP_COOLDOWN:format(timeStr);
	elseif (not canCreateCharacter and charactersAreHidden) then
		CharSelectUndeleteCharacterButton.tooltip = CHAR_CREATE_UNACTIVATED_CHARACTER_LIMIT;
	else
		CharSelectUndeleteCharacterButton.tooltip = UNDELETE_TOOLTIP;
	end
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
    ignoreKeys = true,
    spinner = true,
}

GlueDialogTypes["UNDELETING_CHARACTER"] = {
    text = RESTORING_CHARACTER_IN_PROGRESS,
    ignoreKeys = true,
    spinner = true,
}

function CopyCharacterFromLive()
    if ( not IsGMClient() ) then
		CopyAccountCharacterFromLive(GlueDropDownMenu_GetSelectedValue(CopyCharacterFrame.RegionID), CopyCharacterFrame.SelectedIndex);
	else
		CopyAccountCharacterFromLive(GlueDropDownMenu_GetSelectedValue(CopyCharacterFrame.RegionID), CopyCharacterFrame.SelectedIndex, CopyCharacterFrame.RealmName:GetText(), CopyCharacterFrame.CharacterName:GetText());
	end
    GlueDialog_Show("COPY_IN_PROGRESS");
end

function CopyCharacter_AccountDataFromLive()
    if ( not IsGMClient() ) then
        CopyAccountDataFromLive(GlueDropDownMenu_GetSelectedValue(CopyCharacterFrame.RegionID));
    else
        CopyAccountDataFromLive(GlueDropDownMenu_GetSelectedValue(CopyCharacterFrame.RegionID), CopyCharacterFrame.RealmName:GetText(), CopyCharacterFrame.CharacterName:GetText());
    end
    GlueDialog_Show("COPY_IN_PROGRESS");
end

function CopyCharacterButton_OnLoad(self)
	CopyCharacterButton_UpdateButtonState();
end

function CopyCharacterButton_OnClick(self)
    CopyCharacterFrame:SetShown( not CopyCharacterFrame:IsShown() );
end

function CopyCharacterButton_UpdateButtonState()
	CopyCharacterButton:SetShown(C_CharacterServices.IsLiveRegionCharacterListEnabled() or C_CharacterServices.IsLiveRegionCharacterCopyEnabled() or C_CharacterServices.IsLiveRegionAccountCopyEnabled());
end

function CopyCharacterSearch_OnClick(self)
    ClearAccountCharacters();
    CopyCharacterFrame_Update(CopyCharacterFrame.scrollFrame);
    RequestAccountCharacters(GlueDropDownMenu_GetSelectedValue(CopyCharacterFrame.RegionID), CopyCharacterFrame.RealmName:GetText(), CopyCharacterFrame.CharacterName:GetText());
    self:Disable();
end

function CopyCharacterCopy_OnClick(self)
    if ( not GlueDialog:IsShown() ) then
		if ( CopyCharacterFrame.SelectedIndex ) then
			local name, realm = GetAccountCharacterInfo(CopyCharacterFrame.SelectedIndex);
			GlueDialog_Show("COPY_CHARACTER", format(COPY_CHARACTER_CONFIRM, name, realm));
		elseif ( IsGMClient() ) then
			GlueDialog_Show("COPY_CHARACTER", format(COPY_CHARACTER_CONFIRM, CopyCharacterFrame.CharacterName:GetText(), CopyCharacterFrame.RealmName:GetText()));
		end
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
    CopyCharacterFrame.CopyButton:SetEnabled(C_CharacterServices.IsLiveRegionCharacterCopyEnabled());
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
    GlueDropDownMenu_Initialize(self.RegionID, CopyCharacterFrameRegionIDDropdown_Initialize);
    GlueDropDownMenu_SetAnchor(self.RegionID, 0, 0, "TOPLEFT", self.RegionID, "BOTTOMLEFT");

    ClearAccountCharacters();
    CopyCharacterFrame_Update(self.scrollFrame);

    if ( not IsGMClient() ) then
        self.RealmName:Hide();
        self.CharacterName:Hide();
        self.SearchButton:Hide();
        RequestAccountCharacters(GlueDropDownMenu_GetSelectedValue(CopyCharacterFrame.RegionID));
    else
        self.RealmName:Show();
        self.RealmName:SetFocus();
        self.CharacterName:Show();
        self.SearchButton:Show();
		self.SearchButton:SetEnabled(C_CharacterServices.IsLiveRegionCharacterListEnabled());
	    self.CopyButton:SetEnabled(C_CharacterServices.IsLiveRegionCharacterCopyEnabled());
    end
	self.CopyAccountData:SetEnabled(C_CharacterServices.IsLiveRegionAccountCopyEnabled());
end

function CopyCharacterFrameRegionIDDropdown_Initialize()
    local info = GlueDropDownMenu_CreateInfo();
    local selectedValue = GlueDropDownMenu_GetSelectedValue(CopyCharacterFrame.RegionID);
	local newSelectedValue = nil;
    info.func = CopyCharacterFrameRegionIDDropdown_OnClick;


	local regions = C_CharacterServices.GetLiveRegionCharacterCopySourceRegions();
	for i=1, #regions do
		local regionID = regions[i];
		local regionName = characterCopyRegions[regionID];

		if (regionName) then
			info.text = regionName;
			info.value = regionID;
			info.checked = (info.value == selectedValue) or (selectedValue == nil and i == 1);
			if (not newSelectedValue) then
				newSelectedValue = info.value;
			end
			GlueDropDownMenu_AddButton(info);
		end
	end

	if (selectedValue == nil and newSelectedValue ~= nil) then
		GlueDropDownMenu_SetSelectedValue(CopyCharacterFrame.RegionID, newSelectedValue);
		GlueDropDownMenu_Refresh(CopyCharacterFrame.RegionID);
	end
end

function CopyCharacterFrameRegionIDDropdown_OnClick(button)
    GlueDropDownMenu_SetSelectedValue(CopyCharacterFrame.RegionID, button.value);
    if ( not IsGMClient() ) then
        RequestAccountCharacters(button.value);
    end
end

function CopyCharacterFrame_OnEvent(self, event, ...)
    if ( event == "ACCOUNT_CHARACTER_LIST_RECIEVED" ) then
        CopyCharacterFrame_Update(self.scrollFrame);
        self.SearchButton:Enable();
    elseif ( event == "CHAR_RESTORE_COMPLETE" or event == "ACCOUNT_DATA_RESTORED") then
        local success, token = ...;
        GlueDialog_Hide();
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

function CharacterSelect_ShowStoreFrameForBoostType(boostType, guid, reason)
	if not StoreFrame_IsShown or not StoreFrame_IsShown() then
		ToggleStoreUI();
	end

	StoreFrame_SelectBoost(boostType, reason, guid);
end

function CharacterSelect_CheckApplyBoostToUnlockTrialCharacter(guid)
    local availableBoostTypes = GetAvailableBoostTypesForCharacterByGUID(guid);
    if #availableBoostTypes >= 1 then
		-- We should only ever get in this case if #availableBoostTypes == 1. If there is more than 1 available
		-- boost type then users use a dropdown to choose a boost.
        local flowData = C_CharacterServices.GetCharacterServiceDisplayData(availableBoostTypes[1]);
        CharacterUpgradePopup_BeginCharacterUpgradeFlow(flowData, guid);
    else
	    local purchasableBoostType = C_CharacterServices.GetActiveCharacterUpgradeBoostType();
        CharacterSelect_ShowStoreFrameForBoostType(purchasableBoostType, guid, "forClassTrialUnlock");
    end
end

function CharacterSelect_CheckApplyBoostToUnrevokeBoost(guid)
    local hasBoost, boostType = C_CharacterServices.HasRequiredBoostForUnrevoke();
    if hasBoost then
		local flowData = C_CharacterServices.GetCharacterServiceDisplayData(boostType);
		CharacterUpgradePopup_BeginCharacterUpgradeFlow(flowData, guid);
    else
		local purchasableBoostType = C_CharacterServices.GetActiveCharacterUpgradeBoostType();
        CharacterSelect_ShowStoreFrameForBoostType(purchasableBoostType, guid, "forUnrevokeBoost");
    end
end

function CharacterSelect_ShowBoostUnlockDialog(guid)
    local isTrialBoost, isTrialBoostLocked, revokedCharacterUpgrade, _, _, _, isExpansionTrialCharacter = select(22, GetCharacterInfoByGUID(guid));

    if isTrialBoost and isTrialBoostLocked then
        CharacterSelect_CheckApplyBoostToUnlockTrialCharacter(guid);
        return true;
	elseif isExpansionTrialCharacter then
        CharacterSelect_CheckApplyBoostToUnlockTrialCharacter(guid);
        return true;
    elseif revokedCharacterUpgrade then
        CharacterSelect_CheckApplyBoostToUnrevokeBoost(guid);
        return true;
    end

    return false;
end

function CharSelectEnterWorldButton_OnEnter(button)
	GlueTooltip:SetOwner(button, "ANCHOR_LEFT", 4, -8);
	if ( not button:IsEnabled() and IsNameReservationOnly() ) then
		local hours = GetLaunchETA();
		if (hours > 0) then
			text = LAUNCH_ETA:format(hours);
		else
			text = LAUNCH_ETA_SOON;
		end
		
		GlueTooltip:SetText(text);
	else
		GlueTooltip:Hide();
	end
end

function CharSelectEnterWorldButton_OnLeave(button)
	GlueTooltip:Hide();
end
