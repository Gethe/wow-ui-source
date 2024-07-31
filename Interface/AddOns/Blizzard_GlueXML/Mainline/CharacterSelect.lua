CHARACTER_FACING_INCREMENT = 2;

MOVING_TEXT_OFFSET = 12;
DEFAULT_TEXT_OFFSET = 0;
AUTO_DRAG_TIME = 0.5;				-- in seconds

CHARACTER_UNDELETE_COOLDOWN = 0;	-- in seconds
CHARACTER_UNDELETE_COOLDOWN_REMAINING = 0; -- in seconds

PAID_CHARACTER_CUSTOMIZATION = 1;
PAID_RACE_CHANGE = 2;
PAID_FACTION_CHANGE = 3;

local ADDON_LIST_RECEIVED = false;
local ACCOUNT_SAVE_IS_LOADED = false;
CAN_BUY_RESULT_FOUND = false;
TOKEN_COUNT_UPDATED = false;

local characterCopyRegions = {
	[1] = NORTH_AMERICA,
	[2] = KOREA,
	[3] = EUROPE,
	[4] = TAIWAN,
	[5] = CHINA,
};

CharacterSelectFrameMixin = { };
function CharacterSelectFrameMixin:OnLoad()
	self.LeftBlackBar:SetPoint("TOPLEFT", nil);
	self.RightBlackBar:SetPoint("TOPRIGHT", nil);
	self.TopBlackBar:SetPoint("TOPLEFT", nil);

    self.createIndex = 0;
    self.selectedIndex = 0;
	self.selectLast = false;
	self.backFromCharCreate = false;
	self.connectingToPlunderstorm = false;
    self.characterPadlockPool = CreateFramePool("BUTTON", self, "CharSelectLockedButtonTemplate");
	self.waitingforCharacterList = true;
	self.showSocialContract = false;
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
	self:RegisterEvent("SOCIAL_CONTRACT_STATUS_UPDATE");
	self:RegisterEvent("ACCOUNT_SAVE_ENABLED_UPDATE");
	self:RegisterEvent("ACCOUNT_LOCKED_POST_SAVE_UPDATE");
	self:RegisterEvent("REALM_HIDDEN_INFO_UPDATE");
	self:RegisterEvent("TIMERUNNING_SEASON_UPDATE");

	self:AddDynamicEventMethod(EventRegistry, "GameEnvironment.Selected", self.OnGameEnvironmentSelected);
	self:AddDynamicEventMethod(EventRegistry, "RealmList.Cancel", self.OnRealmListCancel);	
	CharacterSelectUI_ResetEnvironmentButton();

	CharacterSelectCharacterFrame:Init();

	local shouldHideGM = IsGMClient() and HideGMOnly();
	CharacterSelectUI.ToolTray:RegisterToolFrame(PlayersOnServer);
	CharacterSelectUI.ToolTray:RegisterToolFrame(CharacterTemplatesFrame);
	CharacterSelectUI.ToolTray:RegisterToolFrame(CopyCharacterButton);
	CopyCharacterButton:UpdateButtonState();
	CharacterSelectUI.ToolTray:SetShown(not shouldHideGM);

	-- If UI is reloaded while at character select, make sure timerunning addon gets loaded if necessary
	CharacterSelect_UpdateTimerunning();
end

function CharacterSelectFrameMixin:OnGameEnvironmentSelected(requestedEnvironment)
	assert(requestedEnvironment);
	if C_GameEnvironmentManager.GetCurrentGameEnvironment() ~= requestedEnvironment then
		self.CharacterSelectUI.GameEnvironmentToggleFrame:ChangeGameEnvironment(requestedEnvironment);
	end
end

function CharacterSelectFrameMixin:OnRealmListCancel()
	self.CharacterSelectUI.GameEnvironmentToggleFrame:SelectRadioButtonForEnvironment(Enum.GameEnvironment.WoW);
end

function CharacterSelectFrameMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);

    InitializeCharacterScreenData();
    SetInCharacterSelect(true);
    CharacterSelect_ResetVeteranStatus();

	CharacterSelectListUtil.BuildCharIndexToIDMapping();

    -- request account data times from the server (so we know if we should refresh keybindings, etc...)
    CheckCharacterUndeleteCooldown();

    UpdateAddonButton();

	CharacterSelectUtil.SetAutoSwitchRealm(false);

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
	AddonList_ClearCharacterDropdown();

    AccountUpgradePanel_Update(CharSelectAccountUpgradeButton.isExpanded);

    if( IsKioskGlueEnabled() ) then
        CharacterSelectUI:Hide();
    end

    -- character templates
    CharacterTemplatesFrame_Update();

    PlayersOnServer_Update();

	CharacterSelectUI:UpdateStoreEnabled();

    CharacterServicesMaster_UpdateServiceButton();

    C_StoreSecure.GetPurchaseList();
    C_StoreSecure.GetProductList();
    C_StoreGlue.UpdateVASPurchaseStates();

    CharacterSelect_ConditionallyLoadAccountSaveUI();

	CharacterSelectServerAlertFrame:UpdateEnabled();

    CharacterSelect_CheckVeteranStatus();

    if (C_StoreGlue.GetDisconnectOnLogout()) then
        C_StoreSecure.SetDisconnectOnLogout(false);
        GlueDialog_Hide();
        C_Login.DisconnectFromServer();
    end

	if not self.showSocialContract then
		C_SocialContractGlue.GetShouldShowSocialContract();
	end

	self.CharacterSelectUI.GameEnvironmentToggleFrame:SelectRadioButtonForEnvironment(Enum.GameEnvironment.WoW);

	CharacterSelectUI.ToolTray:SetExpanded(not g_characterSelectToolTrayCollapsed);
	GeneralDockManager:Hide();
	ChatFrame1:Hide();

	-- Show timerunning first time dialog if necessary
	CharacterSelect_UpdateTimerunning();
end

function CharacterSelectFrameMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);

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

	if not CharacterCreateFrame:HasService() then
   		EndCharacterServicesFlow(true);
	end

	SocialContractFrame:Hide();

	GlueTooltip:Hide();

    AccountReactivate_CloseDialogs();
    SetInCharacterSelect(false);
end

function CharacterSelect_UpdateState(fromLoginState)
	if not GetServerName() then
		CharacterSelect_SetSelectedCharacterName("");
    end

	if (fromLoginState == CharacterSelectUtil.GetAutoSwitchRealm()) then
        if ( IsConnectedToServer() ) then
            if (fromLoginState) then
                if (IsKioskGlueEnabled()) then
                    GlueParent_SetScreen("kioskmodesplash");
                else
                    CharacterSelectUI:Hide();
                    CharacterSelectUI:Show();
                end
            end
			CharacterSelectListUtil.GetCharacterListUpdate();
        else
            UpdateCharacterList();
        end
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

function CharacterSelect_IsVisible()
	return CharacterSelect:IsVisible();
end

function CharacterSelect_IsUndeleting()
	return CharacterSelect.undeleting;
end

function CharacterSelectFrameMixin:OnUpdate(elapsed)
    if ( self.undeleteFailed ) then
        if (not GlueDialog:IsShown()) then
			if (self.undeleteFailed == "name") then
				GlueDialog_Show("UNDELETE_NAME_TAKEN");
			elseif (self.undeleteFailed == "dracthyr") then
				GlueDialog_Show("UNDELETE_DRACTHYR_LEVEL_REQUIREMENT");
			else
				GlueDialog_Show("UNDELETE_FAILED");
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

    if ( C_CharacterServices.HasQueuedUpgrade() or C_StoreGlue.GetVASProductReady() ) then
        CharacterServicesMaster_OnCharacterListUpdate();
    end

    if (StoreFrame_WaitingForCharacterListUpdate()) then
        StoreFrame_OnCharacterListUpdate();
    end

	GlueDialog_CheckQueuedDialogs();
end

function CharacterSelectFrameMixin:OnKeyDown(key)
    if key == "ESCAPE" then
        if GlueParent_IsSecondaryScreenOpen("options") then
            GlueParent_CloseSecondaryScreen();
        elseif C_Login.IsLauncherLogin() then
			GlueMenuFrameUtil.ToggleMenu();
        elseif CharSelectServicesFlowFrame:IsShown() then
			if CharSelectServicesFlowFrame.MinimizedFrame then
				CharSelectServicesFlow_Minimize();
			else
				EndCharacterServicesFlow(false);
			end
        elseif CopyCharacterFrame:IsShown() then
            CopyCharacterFrame:Hide();
        elseif CharacterSelect.undeleting then
            CharacterSelect_EndCharacterUndelete();
		elseif GlobalGlueContextMenu_IsShown() then
			GlobalGlueContextMenu_Release();
        else
			GlueMenuFrameUtil.ToggleMenu();
        end
    elseif key == "ENTER" then
        if CharacterSelect_AllowedToEnterWorld() then
           CharacterSelect_EnterWorld();
        end
    elseif key == "PRINTSCREEN" then
        Screenshot();
    elseif key == "UP" or key == "LEFT" then
        if CharSelectServicesFlowFrame:IsShown() and CharSelectServicesFlowFrame.DisableButtons then
            return;
        end
        CharacterSelectScrollUp_OnClick();
    elseif ( key == "DOWN" or key == "RIGHT" ) then
        if CharSelectServicesFlowFrame:IsShown() and CharSelectServicesFlowFrame.DisableButtons then
            return;
        end
        CharacterSelectScrollDown_OnClick();
    end
end

function CharacterSelectFrameMixin:OnEvent(event, ...)
    if ( event == "CHARACTER_LIST_UPDATE" ) then
		if C_GameEnvironmentManager.GetCurrentGameEnvironment() == Enum.GameEnvironment.WoWLabs then
			self.waitingforCharacterList = false;
			return;
		end

        PromotionFrame_AwaitingPromotion();

        local listSize = ...;
        if listSize then
			CharacterSelectListUtil.BuildCharIndexToIDMapping(listSize);
        end

        if GetNumCharacters() == 0 then
			if self.undeleting then
				CharacterSelect_EndCharacterUndelete();
				self.undeleteNoCharacters = true;
				return;
			elseif (not self.connectingToPlunderstorm and not self.backFromCharCreate) then
				if (IsKioskGlueEnabled()) then
					GlueParent_SetScreen("kioskmodesplash");
				else
					GlueParent_SetScreen("charcreate");
					CharacterSelect_ShowTimerunningChoiceWhenActive();
				end
				return;
			end
		end

        self.backFromCharCreate = false;

        if (self.hasPendingTrialBoost) then
            KioskMode_SetWaitingOnTrial(true);
            C_CharacterServices.TrialBoostCharacter(self.trialBoostGuid, self.trialBoostFactionID, self.trialBoostSpecID);
            CharacterSelect_SetPendingTrialBoost(false);
        end

        if (self.undeleteNoCharacters) then
            GlueDialog_Show("UNDELETE_NO_CHARACTERS");
            self.undeleteNoCharacters = false;
        end

		-- If we get here then any account conversion should have completed.
		-- Clear the dialog if showing as a fallback in case the usual close message gets lost to prevent confusion.
		GlueDialog_Hide("ACCOUNT_CONVERSION_DISPLAY");

		self.waitingforCharacterList = false;
        UpdateCharacterList();
        UpdateAddonButton();

		local characterGUID = GetCharacterGUID(CharacterSelectListUtil.GetCharIDFromIndex(self.selectedIndex));
		if characterGUID then
			local basicInfo = GetBasicCharacterInfo(characterGUID);
			local timerunningSeasonID = GetCharacterTimerunningSeasonID(characterGUID);
            CharacterSelect_SetSelectedCharacterName(basicInfo.name, timerunningSeasonID);
		else
			CharacterSelect_SetSelectedCharacterName("");
		end

        KioskMode_CheckAutoRealm();
        KioskMode_CheckEnterWorld();
        CharacterServicesMaster_OnCharacterListUpdate();
    elseif ( event == "UPDATE_SELECTED_CHARACTER" ) then
		local charID = ...;

		CharacterSelectListUtil.CheckBuildCharIndexToIDMapping();

		if ( charID == 0 ) then
		    CharacterSelect_SetSelectedCharacterName("");
		else
			local index = CharacterSelectListUtil.GetIndexFromCharID(charID);
		    self.selectedIndex = index;
			local guid = GetCharacterGUID(charID);
			if guid then
				local basicInfo = GetBasicCharacterInfo(guid);
				local timerunningSeasonID = guid and GetCharacterTimerunningSeasonID(guid);
				CharacterSelect_SetSelectedCharacterName(basicInfo.name, timerunningSeasonID);
			end
		end
		CharacterSelectCharacterFrame:UpdateCharacterSelection();

		-- Sets up the character rendering in the group scene or legacy BG style.
		CharacterSelect.CharacterSelectUI:SetCharacterDisplay(charID);

		local elementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
			local characterID = CharacterSelectListUtil.GetCharIDFromIndex(self.selectedIndex);
			return CharacterSelectListUtil.ContainsCharacterID(characterID, elementData);
		end);

		if elementData then
			CharacterSelectListUtil.ScrollToElement(elementData, ScrollBoxConstants.AlignNearest);
		end
    elseif ( event == "FORCE_RENAME_CHARACTER" ) then
        GlueDialog_Hide();
        local message = ...;
        CharacterRenameDialog:Show();
        CharacterRenameText1:SetText(_G[message]);
    elseif ( event == "CHAR_RENAME_IN_PROGRESS" ) then
        GlueDialog_Show("OKAY", CHAR_RENAME_IN_PROGRESS);
    elseif ( event == "STORE_STATUS_CHANGED" ) then
        if (ADDON_LIST_RECEIVED) then
			CharacterSelectUI:UpdateStoreEnabled();
        end
    elseif ( event == "CHARACTER_UNDELETE_STATUS_CHANGED") then
        local enabled, onCooldown, cooldown, remaining = GetCharacterUndeleteStatus();

        CHARACTER_UNDELETE_COOLDOWN = cooldown;
        CHARACTER_UNDELETE_COOLDOWN_REMAINING = remaining;

        CharSelectUndeleteCharacterButton:SetEnabled(enabled and not onCooldown);
        if (not enabled) then
            CharSelectUndeleteCharacterButton:SetDisabledTooltip(UNDELETE_TOOLTIP_DISABLED);
        elseif (onCooldown) then
            local timeStr = SecondsToTime(remaining, false, true, 1, false);
			CharSelectUndeleteCharacterButton:SetDisabledTooltip(UNDELETE_TOOLTIP_COOLDOWN:format(timeStr));
        end
	elseif ( event == "CLIENT_FEATURE_STATUS_CHANGED" ) then
        AccountUpgradePanel_Update(CharSelectAccountUpgradeButton.isExpanded);
		CopyCharacterButton:UpdateButtonState();
		UpdateCharacterList();
	elseif ( event == "CHARACTER_COPY_STATUS_CHANGED" ) then
		CopyCharacterButton:UpdateButtonState();
    elseif ( event == "CHARACTER_UNDELETE_FINISHED" ) then
        GlueDialog_Hide("UNDELETING_CHARACTER");
        CharacterSelect_EndCharacterUndelete();
        local result, guid = ...;

        if ( result == LE_CHARACTER_UNDELETE_RESULT_OK ) then
            self.undeleteGuid = guid;
            self.undeleteFailed = nil;
        else
            self.undeleteGuid = nil;
            if ( result == LE_CHARACTER_UNDELETE_RESULT_ERROR_NAME_TAKEN_BY_THIS_ACCOUNT ) then
                self.undeleteFailed = "name";
			elseif ( result == LE_CHARACTER_UNDELETE_RESULT_ERROR_DRACTHYR_LEVEL_REQUIREMENT ) then
				self.undeleteFailed = "dracthyr";
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
	elseif event == "VAS_CHARACTER_STATE_CHANGED" then
		CharacterSelect_UpdateIfUpdateIsNotPending();
	elseif event == "STORE_PRODUCTS_UPDATED" then
		CharacterSelect_UpdateIfUpdateIsNotPending();
    elseif ( event == "CHARACTER_DELETION_RESULT" ) then
        local success, errorToken = ...;
        if ( success ) then
			local last = false;
			local firstCharacterIndex = CharacterSelectListUtil.GetFirstOrLastCharacterIndex(last);
			if firstCharacterIndex then
				local noCreate = true;
				CharacterSelect_SelectCharacter(firstCharacterIndex, noCreate);
			end
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
		CharacterSelect_OnVASCharacterQueueStatusUpdate(guid, minutes);
    elseif ( event == "LOGIN_STATE_CHANGED" ) then
		if C_GameEnvironmentManager.GetCurrentGameEnvironment() == Enum.GameEnvironment.WoWLabs then
			return;
		end
        local FROM_LOGIN_STATE_CHANGE = true;
        CharacterSelect_UpdateState(FROM_LOGIN_STATE_CHANGE);
	elseif ( event == "TRIAL_STATUS_UPDATE" ) then
		AccountUpgradePanel_Update(CharSelectAccountUpgradeButton.isExpanded);
		UpdateCharacterList();
	elseif ( event == "UPDATE_EXPANSION_LEVEL" or event == "MIN_EXPANSION_LEVEL_UPDATED" or event == "MAX_EXPANSION_LEVEL_UPDATED" or event == "INITIAL_HOTFIXES_APPLIED" ) then
		AccountUpgradePanel_Update(CharSelectAccountUpgradeButton.isExpanded);
	elseif ( event == "SOCIAL_CONTRACT_STATUS_UPDATE") then
		self.showSocialContract = ...;
		if self.showSocialContract and GlueParent_GetCurrentScreen() == "charselect" then
			CharacterSelect_UpdateIfUpdateIsNotPending();
		end
    elseif ( event == "ACCOUNT_SAVE_ENABLED_UPDATE" ) then
        CharacterSelect_ConditionallyLoadAccountSaveUI();
    elseif (event == "ACCOUNT_LOCKED_POST_SAVE_UPDATE" ) then
        CharacterSelect_UpdateIfUpdateIsNotPending();
	elseif (event == "REALM_HIDDEN_INFO_UPDATE") then
		local text = ...;
		if(text) then
			REALM_HIDDEN_ALERT:SetText(text);
			REALM_HIDDEN_ALERT:Show();
		else
			REALM_HIDDEN_ALERT:Hide();
		end
	elseif (event == "TIMERUNNING_SEASON_UPDATE") then
		CharacterSelect_UpdateTimerunning();
	end
end

function CharacterSelect_SetSelectedCharacterName(name, timerunningSeasonID)
	local offsetX = nil;
	local offsetY = 2;
    CharSelectCharacterName:SetText(CharacterSelectUtil.FormatCharacterName(name, timerunningSeasonID, offsetX, offsetY));

	if timerunningSeasonID then
		CharSelectCharacterName:EnableMouse(true);
		CharSelectCharacterName:SetMouseMotionEnabled(true);
		CharSelectCharacterName:SetScript("OnEnter", function()
			GlueTooltip:SetOwner(CharSelectCharacterName, "ANCHOR_TOPLEFT", 0, 0);
			GlueTooltip:SetText(TIMERUNNING_CHARACTER_TOOLTIP_TITLE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1, true);
			if timerunningSeasonID == Constants.TimerunningConsts.TIMERUNNING_SEASON_PANDARIA then
				GlueTooltip:AddLine(TIMERUNNING_CHARACTER_TOOLTIP_PANDARIA_DESCRIPTION, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, true);
			end
			GlueTooltip:Show();
		end);
		CharSelectCharacterName:SetScript("OnLeave", function()
			GlueTooltip:Hide();
		end);
	else
		CharSelectCharacterName:SetMouseMotionEnabled(false);
		CharSelectCharacterName:SetScript("OnEnter", nil);
		CharSelectCharacterName:SetScript("OnLeave", nil);
	end
end

function CharacterSelect_UpdateTimerunning()
	local season = GetActiveTimerunningSeasonID();
	if season then
		C_AddOns.LoadAddOn("Blizzard_TimerunningCharacterCreate");
		TimerunningFirstTimeDialog:UpdateState();
	end
end

function CharacterSelect_UpdateIfUpdateIsNotPending()
	if ( not IsCharacterListUpdatePending() ) then
		UpdateCharacterList();
	end
end

function CharacterSelect_OnVASCharacterQueueStatusUpdate(guid, minutes)
	CharacterSelectUtil.UpdateVASQueueTime(guid, minutes);

	if not IsCharacterListUpdatePending() then
		CharacterSelectCharacterFrame:UpdateCharacterMatchingGUID(guid);
	end
end

function CharacterSelect_SetPendingTrialBoost(hasPendingTrialBoost, factionID, specID, guid)
    CharacterSelect.hasPendingTrialBoost = hasPendingTrialBoost;
    CharacterSelect.trialBoostFactionID = factionID;
    CharacterSelect.trialBoostSpecID = specID;
    CharacterSelect.trialBoostGuid = guid;
end

function CharacterSelect_CheckDialogStates()
	if not TryShowAddonDialog() then
		if not HasCheckedSystemRequirements() then
			CheckSystemRequirements();
			SetCheckedSystemRequirements(true);
		end

		local includeSeenWarnings = true;
		CharacterSelectUI.ConfigurationWarnings:SetShown(#C_ConfigurationWarnings.GetConfigurationWarnings(includeSeenWarnings) > 0);
	end
end

function UpdateCharacterList(skipSelect)
	if CharacterSelect.waitingforCharacterList then
		CharacterSelectUI.CharacterList:SetCharacterCreateEnabled(false);
		CharSelectUndeleteCharacterButton:Hide();
		CharacterTemplatesFrame.CreateTemplateButton:Hide();
		CharacterSelect.selectedIndex = 0;
		local noCreate = true;
		CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, noCreate);
		return;
	end

	if ShouldShowLevelSquishDialog() then
		GlueAnnouncementDialog:Display(CHAR_LEVELS_SQUISHED_TITLE, CHAR_LEVELS_SQUISHED_DESCRIPTION, "seenLevelSquishPopup");
	else
		CharacterSelect_CheckDialogStates();
	end

	if CharacterSelect.showSocialContract then
		SocialContractFrame:Show();
		CharacterSelect.showSocialContract = false;
	end

    if CharacterSelect.undeleteChanged then
        CharacterSelect.undeleteChanged = false;
    end

	local includeEmptySlots = true;
	local numChars = GetNumCharacters(includeEmptySlots);
	if CharacterSelect.selectLast then
		local last = true;
		CharacterSelect.selectedIndex = CharacterSelectListUtil.GetFirstOrLastCharacterIndex(last);
		CharacterSelect.selectLast = false;
	elseif CharacterSelect.selectGuid or CharacterSelect.undeleteGuid then
		for i = 1, numChars do
			local characterGuid = GetCharacterGUID(i);

			-- Check each entry if it's an empty character.
			if characterGuid and (characterGuid == CharacterSelect.selectGuid or characterGuid == CharacterSelect.undeleteGuid) then
				CharacterSelect.selectedIndex = i;
				if characterGuid == CharacterSelect.undeleteGuid then
					local serviceInfo = GetServiceCharacterInfo(characterGuid);
					CharacterSelect.undeleteSucceeded = true;
					CharacterSelect.undeletePendingRename = serviceInfo.hasNameChange;
				end
				break;
			end
		end
		CharacterSelect.selectGuid = nil;
		CharacterSelect.undeleteGuid = nil;
	end

    CharacterSelect_UpdateButtonState();

	CharacterSelectUI:UpdateStoreEnabled();

    CharacterSelect_ResetVeteranStatus();
    CharacterSelect_CheckVeteranStatus();

    CharacterSelect.createIndex = 0;

    CharacterSelectUI.CharacterList:SetCharacterCreateEnabled(false);
    CharSelectUndeleteCharacterButton:Hide();
	CharacterTemplatesFrame.CreateTemplateButton:Hide();

    local connected = IsConnectedToServer();
    if (CanCreateCharacter() and not CharacterSelect.undeleting) then
        CharacterSelect.createIndex = numChars + 1;
        if ( connected ) then
			CharacterSelectUI.CharacterList:SetCharacterCreateEnabled(true);
            CharSelectUndeleteCharacterButton:Show();
			CharacterTemplatesFrame.CreateTemplateButton:Show();
        end
    end

    if ( numChars == 0 and not skipSelect ) then
        CharacterSelect.selectedIndex = 0;
		local noCreate = true;
        CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, noCreate);
        return;
    end

    if ( (CharacterSelect.selectedIndex == 0) or (CharacterSelect.selectedIndex > numChars) ) then
        CharacterSelect.selectedIndex = 1;
    end

    if ( not skipSelect ) then
		local noCreate = true;
        CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, noCreate);
    end
end

function CharacterSelect_ShowTimerunningChoiceWhenActive()
	if not IsBetaBuild() and GetActiveTimerunningSeasonID() then
		C_AddOns.LoadAddOn("Blizzard_TimerunningCharacterCreate");
		TimerunningChoicePopup:Show();
		return true;
	end

	return false;
end

function CharacterSelect_SelectCharacter(index, noCreate)
    if ( index == CharacterSelect.createIndex ) then
        if ( not noCreate and not CharacterSelectUtil.IsAccountLocked()) then
            PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
            C_CharacterCreation.ClearCharacterTemplate();
            GlueParent_SetScreen("charcreate");
        end
    else
		local selectedCharacterID = CharacterSelectListUtil.GetCharIDFromIndex(index);
		SelectCharacter(selectedCharacterID);

        if (not C_WowTokenPublic.GetCurrentMarketPrice() or
            not CAN_BUY_RESULT_FOUND or (CAN_BUY_RESULT_FOUND ~= LE_TOKEN_RESULT_ERROR_SUCCESS and CAN_BUY_RESULT_FOUND ~= LE_TOKEN_RESULT_ERROR_SUCCESS_NO) ) then
            AccountReactivate_RecheckEligibility();
        end
        ReactivateAccountDialog_Open();

        -- Update the text of the EnterWorld button based on the type of character that's selected, default to "enter world"
        local text = ENTER_WORLD;

		local characterInfo = CharacterSelectUtil.GetCharacterInfoTable(selectedCharacterID);
		if not characterInfo then
			return; --character selection is zero on startup.
		end

        if characterInfo.isTrialBoostCompleted then
            text = ENTER_WORLD_UNLOCK_TRIAL_CHARACTER;
		elseif characterInfo.revokedCharacterUpgrade then
			text = ENTER_WORLD_UNLOCK_REVOKED_CHARACTER_UPGRADE;
        end

        CharSelectEnterWorldButton:SetText(text);

		if characterInfo.boostInProgress == false and (not CharacterServicesFlow_IsShowing() or not CharacterServicesMaster.flow:UsesSelector()) then
			if IsRPEBoostEligible(selectedCharacterID) and CharacterSelectUtil.IsSameRealmAsCurrent(characterInfo.realmAddress) then
				BeginCharacterServicesFlow(RPEUpgradeFlow, {});
				if IsVeteranTrialAccount() then
					CharSelectServicesFlow_Minimize() --if they need to resubscribe, get the RPE flow out of the way.
				end
			else
				EndCharacterServicesFlow(false);
			end

			CharacterSelectListUtil.ForEachCharacterDo(function(frame)
				frame:SetSelectedState(frame:GetCharacterIndex() == index);
			end);
		end
    end
end

local function EnterWorldHelper()
	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ENTER_WORLD);
	StopGlueAmbience();
	EnterWorld();
end

StaticPopupDialogs["RPE_SKIP_UPGRADE_CONFIRM"] = {
    text = RPE_SKIP_UPGRADE_CONFIRMATION,
    button1 = CONTINUE,
    button2 = CANCEL,
    OnAccept = EnterWorldHelper,
    OnCancel = function () end,
}

function CharacterSelect_EnterWorld()
	if (CharacterSelectUtil.IsAccountLocked()) then
        return;
    end

	CharacterSelectListUtil.SaveCharacterOrder();
	local characterGuid = GetCharacterGUID(GetCharacterSelection());
	if not characterGuid then
		return;
	end

	local serviceInfo = GetServiceCharacterInfo(characterGuid);

    if ( serviceInfo.isLocked ) then
        SubscriptionRequestDialog_Open();
        return;
    end

	if IsRPEBoostEligible(GetCharacterSelection()) then
		GlueDialog_Show("RPE_SKIP_UPGRADE_CONFIRM");
	else
		EnterWorldHelper();
	end
end

function CharacterSelect_Exit()
	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_EXIT);

	CharacterSelectListUtil.SaveCharacterOrder();

	CharacterSelectCharacterFrame:ClearCharacterSelection();
	CharacterSelect.CharacterSelectUI:ReleaseCharacterOverlayFrames();
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
	if (CharacterSelectUtil.IsAccountLocked()) then
        return;
    end

    PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_DEL_CHARACTER);
    if ( CharacterSelect.selectedIndex > 0 ) then
		CharacterSelectListUtil.SaveCharacterOrder();
        CharacterDeleteDialog:Show();
    end
end

function CharacterSelect_AllowedToEnterWorld()
	local isAccountLocked = CharacterSelectUtil.IsAccountLocked();

    if (isAccountLocked) then
        return false;
    elseif (GetNumCharacters() == 0) then
        return false;
    elseif (CharacterSelect.undeleting) then
        return false;
    elseif (AccountReactivationInProgressDialog:IsShown()) then
        return false;
    elseif (GoldReactivateConfirmationDialog:IsShown()) then
        return false;
    elseif (TokenReactivateConfirmationDialog:IsShown()) then
        return false;
    elseif (CharSelectServicesFlowFrame:ShouldDisableButtons()) then
        return false;
	elseif (Kiosk.IsEnabled() and (CharacterSelect.hasPendingTrialBoost or KioskMode_IsWaitingOnTrial())) then
		return false;
    end

    local guid = GetCharacterGUID(GetCharacterSelection());
	if not guid then
		return false;
	end
	local serviceInfo = GetServiceCharacterInfo(guid);
	local trialBoostUnavailable = (serviceInfo.isExpansionTrialCharacter and (serviceInfo.isTrialBoostCompleted or not IsExpansionTrial())) or (serviceInfo.isTrialBoost and (serviceInfo.isTrialBoostCompleted or not C_CharacterServices.IsTrialBoostEnabled()));
    if (serviceInfo.boostInProgress or serviceInfo.isRevokedCharacterUpgrade or trialBoostUnavailable) then
        return false;
    end

    local timerunningSeasonID = GetCharacterTimerunningSeasonID(guid);
    if (timerunningSeasonID and not IsTimerunningEnabled()) then
        return false, TIMERUNNING_DISABLED_TOOLTIP;
    end

    return true;
end

function CharacterSelectUI_ResetEnvironmentButton()
	-- because of the CharacterSelect animations, we need to set the initial alpha of the WoW Toggle to 1
	CharacterSelect.CharacterSelectUI.GameEnvironmentToggleFrame.SelectWoWToggle:SetAlpha(1);
	CharacterSelect.CharacterSelectUI.GameEnvironmentToggleFrame.SelectWoWLabsToggle:SetAlpha(0.5);
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

function CharacterSelect_RotateSelection(direction)
	if GetNumCharacters() == 0 then
		return;
	end

	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
	local newIndex = CharacterSelectListUtil.GetNextCharacterIndex(direction);
	CharacterSelect_SelectCharacter(newIndex);

	local elementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
		local characterID = CharacterSelectListUtil.GetCharIDFromIndex(newIndex);
		return CharacterSelectListUtil.ContainsCharacterID(characterID, elementData);
	end);

	if elementData then
		CharacterSelectListUtil.ScrollToElement(elementData, ScrollBoxConstants.AlignNearest);
	end
end

function CharacterSelect_StartCustomizeForVAS(vasType, info)
	CharacterCreateFrame:SetVASInfo(vasType, info);
	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
	GlueParent_SetScreen("charcreate");
end

function CharacterSelectScrollDown_OnClick()
	CharacterSelect_RotateSelection(1);
end

function CharacterSelectScrollUp_OnClick()
	CharacterSelect_RotateSelection(-1);
end

local function GetLeftSideAlertBottomOffset()
	return RPEUpgradeMinimizedFrame:IsShown() and RPEUpgradeMinimizedFrame.Icon:GetTop() or CharacterSelectBackButton:GetTop();
end

CharacterSelectServerAlertFrameMixin = {};

function CharacterSelectServerAlertFrameMixin:OnLoad()
	CollapsibleServerAlertMixin.OnLoad(self);

	self:RegisterEvent("LAUNCHER_LOGIN_STATUS_CHANGED");
	self:UpdateEnabled();
end

function CharacterSelectServerAlertFrameMixin:OnShow()
	CollapsibleServerAlertMixin.OnShow(self);

	AccountUpgradePanel_UpdateExpandState();
end

function CharacterSelectServerAlertFrameMixin:OnHide()
	AccountUpgradePanel_UpdateExpandState();
end

function CharacterSelectServerAlertFrameMixin:OnEvent(event, ...)
	if event == "LAUNCHER_LOGIN_STATUS_CHANGED" then
		self:UpdateEnabled();
	else
		ServerAlertMixin.OnEvent(self, event, ...);
	end
end

function CharacterSelectServerAlertFrameMixin:UpdateEnabled()
	local shouldSuppressServerAlert = C_Login.IsLauncherLogin() and not (AccountSaveFrame and AccountSaveFrame:IsShown());
	self:SetSuppressed(shouldSuppressServerAlert);
end

function CharacterSelectServerAlertFrameMixin:OnToggled(expanded, isUserInput)
	CollapsibleServerAlertMixin.OnToggled(self, expanded, isUserInput);

	if isUserInput then
		AccountUpgradePanel_SetLastUserExpandedFrame(expanded and self or nil);
	end

	AccountUpgradePanel_UpdateExpandState();
end

function CharacterSelectServerAlertFrameMixin:GetMaxFrameHeight()
	local bottom = GetLeftSideAlertBottomOffset();
	local top = CharSelectAccountUpgradeButton:IsShown() and CharSelectAccountUpgradeMiniPanel.banner:GetBottom() or CharacterSelectLogo:GetBottom();
	return math.min(top - bottom, CollapsibleServerAlertMixin.GetMaxFrameHeight(self));
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
	if IsTrialAccount() then
		local expansionDisplayInfo, features;
		if DoesCurrentLocaleSellExpansionLevels() then
			expansionDisplayInfo = GetExpansionDisplayInfo(LE_EXPANSION_CLASSIC);
			features = expansionDisplayInfo.features;
		else
			expansionDisplayInfo = GetExpansionDisplayInfo(LE_EXPANSION_LEVEL_CURRENT);
			features = expansionDisplayInfo.features;

			-- Replace the boost feature.
			features[3] = { icon = "Interface\\Icons\\Achievement_Quests_Completed_06", text = UPGRADE_FEATURE_2 }
		end

		if not expansionDisplayInfo then
			return nil, false;
		end

		local shouldShowBanner = true;
		return nil, shouldShowBanner, ACCOUNT_UPGRADE_BANNER_SUBSCRIBE, expansionDisplayInfo.logo, expansionDisplayInfo.banner, features;
	elseif IsVeteranTrialAccount() then
		local features = {
			{ icon = "Interface\\Icons\\achievement_bg_returnxflags_def_wsg", text = VETERAN_FEATURE_1 },
			{ icon = "Interface\\Icons\\achievement_reputation_01", text = VETERAN_FEATURE_2 },
			{ icon = "Interface\\Icons\\spell_holy_surgeoflight", text = VETERAN_FEATURE_3 },
		};

		local currentExpansionLevel = AccountUpgradePanel_GetDisplayExpansionLevel();
		local expansionDisplayInfo = GetExpansionDisplayInfo(currentExpansionLevel);
		if not expansionDisplayInfo then
			return currentExpansionLevel, false;
		end

		local shouldShowBanner = true;
		return currentExpansionLevel, shouldShowBanner, ACCOUNT_UPGRADE_BANNER_RESUBSCRIBE, expansionDisplayInfo.logo, expansionDisplayInfo.banner, features;
	else
		local currentExpansionLevel, upgradeLevel = AccountUpgradePanel_GetDisplayExpansionLevel();
		local shouldShowBanner = GameLimitedMode_IsActive() or CanUpgradeExpansion();
		if shouldShowBanner then
			local expansionDisplayInfo = GetExpansionDisplayInfo(upgradeLevel);
			if not expansionDisplayInfo then
				return currentExpansionLevel, false;
			end

			return currentExpansionLevel, shouldShowBanner, UPGRADE_ACCOUNT_SHORT, expansionDisplayInfo.logo, expansionDisplayInfo.banner, expansionDisplayInfo.features;
		else
			return currentExpansionLevel, shouldShowBanner;
		end
	end
end

function CharacterSelect_UpdateLogo()
	-- For now, Timerunning overrides the event realms (plunderstorm) if both are active at once. Revisit if we have Plunderstorm and Timerunning at the same time.
	local showEnvironmentToggle = C_GameEnvironmentManager.GetCurrentEventRealmQueues() ~= Enum.EventRealmQueues.None and GetActiveTimerunningSeasonID() == nil;
	CharacterSelectLogo:SetShown(not showEnvironmentToggle);
	CharacterSelect.CharacterSelectUI.GameEnvironmentToggleFrame:SetShown(showEnvironmentToggle);
	CharacterSelect.CharacterSelectUI.LimitedTimeEventFrame:SetShown(showEnvironmentToggle);
	local currentExpansionLevel = AccountUpgradePanel_GetBannerInfo();
	if ( showEnvironmentToggle ) then
		SetExpansionLogo(CharacterSelect.CharacterSelectUI.GameEnvironmentToggleFrame.SelectWoWToggle.NormalTexture, currentExpansionLevel);
	else
		SetExpansionLogo(CharacterSelectLogo, currentExpansionLevel);
	end
end

local UpgradePanelServerAlertSpacing = 35;
local function AccountUpgradePanel_GetTotalSpaceAvailable()
	local bottomEdge = GetLeftSideAlertBottomOffset();
	return CharacterSelectLogo:GetBottom() - bottomEdge;
end

local function AccountUpgradePanel_GetFullBannerSize()
	local SpacingRequired = 30;
	return SpacingRequired + (CharSelectAccountUpgradeButton:GetTop() - CharSelectAccountUpgradePanel:GetBottom());
end

local function AccountUpgradePanel_CheckFit()
	local totalSpace = AccountUpgradePanel_GetTotalSpaceAvailable();
	local totalSpaceUsed = (AccountUpgradePanel_GetFullBannerSize() + CharacterSelectServerAlertFrame:GetEffectiveHeight() + UpgradePanelServerAlertSpacing);
	return totalSpaceUsed <= totalSpace;
end

-- Generally, server alert takes precedence over the account upgrade panel if both won't fit expanded,
-- but if the player presses the expand button for the upgrade panel we want to force it open.
local s_lastUserExpandedFrame = nil;
function AccountUpgradePanel_SetLastUserExpandedFrame(frame)
	s_lastUserExpandedFrame = frame;
end

function AccountUpgradePanel_Update(isExpanded, isUserInput)
	if isUserInput then
		SetCVar("expandUpgradePanel", isExpanded and "1" or "0");
		AccountUpgradePanel_SetLastUserExpandedFrame(isExpanded and CharSelectAccountUpgradeButton or nil);
	end
	CharacterSelect_UpdateLogo();

	local currentExpansionLevel, shouldShowBanner, upgradeButtonText, upgradeLogo, upgradeBanner, features = AccountUpgradePanel_GetBannerInfo();
    if ( shouldShowBanner ) then
		CharSelectAccountUpgradeButton:SetText(upgradeButtonText);

		local gameEnvironmentToggleShown = CharacterSelect.CharacterSelectUI.GameEnvironmentToggleFrame:IsShown();
		local showChains = not gameEnvironmentToggleShown and (not currentExpansionLevel or currentExpansionLevel < LE_EXPANSION_WAR_WITHIN);

		CharSelectAccountUpgradeButton.TopChain1:SetShown(showChains);
		CharSelectAccountUpgradeButton.TopChain2:SetShown(showChains);

        CharSelectAccountUpgradeButton:Show();
        if ( isExpanded ) then
            CharSelectAccountUpgradePanel:Show();
            CharSelectAccountUpgradeMiniPanel:Hide();
			CharacterSelectServerAlertFrame:SetPoint("TOP", CharSelectAccountUpgradePanel, "BOTTOM", 0, -UpgradePanelServerAlertSpacing);

			if not AccountUpgradePanel_CheckFit() then
				CharacterSelectServerAlertFrame:SetExpanded(false);
			end

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
			CharacterSelectServerAlertFrame:SetPoint("TOP", CharSelectAccountUpgradeMiniPanel, "BOTTOM", 0, -UpgradePanelServerAlertSpacing);
			CharacterSelectServerAlertFrame:UpdateCollapsedState();

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
end

function AccountUpgradePanel_ToggleExpandState(isUserInput)
	AccountUpgradePanel_Update(not CharSelectAccountUpgradeButton.isExpanded, isUserInput);
end

function AccountUpgradePanel_UpdateExpandState()
	local expandDesired = GetCVarBool("expandUpgradePanel");
	local shouldBeExpanded = expandDesired or CharSelectAccountUpgradeButton.isExpanded;
    if ( CharacterSelectServerAlertFrame:IsShown() ) then
		local availableHeight = AccountUpgradePanel_GetTotalSpaceAvailable();
		local collapsedServerAlertHeight = CharacterSelectServerAlertFrame:GetCollapsedHeight();
		local fullServerAlertHeight = CharacterSelectServerAlertFrame:GetHeight();
		local serverAlertHeight = CharacterSelectServerAlertFrame:ShouldBeCollapsed() and collapsedServerAlertHeight or fullServerAlertHeight;
		local leftOverHeight = availableHeight - (serverAlertHeight + UpgradePanelServerAlertSpacing);
		local fullHeight = AccountUpgradePanel_GetFullBannerSize();
		local maxSpaceAvailable = availableHeight - collapsedServerAlertHeight;
		local canExpand = maxSpaceAvailable >= fullHeight;
		local maxHeight = fullServerAlertHeight + fullHeight + UpgradePanelServerAlertSpacing;
		local canCollapse = not GameLimitedMode_IsActive() or (maxHeight > availableHeight);
		CharSelectAccountUpgradeButton.expandCollapseButton:SetShown(canExpand and canCollapse);
		shouldBeExpanded = not canCollapse or (canExpand and shouldBeExpanded and ((leftOverHeight >= fullHeight) or (s_lastUserExpandedFrame == CharSelectAccountUpgradeButton)));
    elseif ( GameLimitedMode_IsActive() ) then
		shouldBeExpanded = true;
        CharSelectAccountUpgradeButton.expandCollapseButton:Hide();
    else
        CharSelectAccountUpgradeButton.expandCollapseButton:Show();
    end
	AccountUpgradePanel_Update(shouldBeExpanded);
	CharacterSelectServerAlertFrame:UpdateHeight();
end

function CharSelectAccountUpgradeButton_OnClick(self)
    PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
	if IsVeteranTrialAccount() then
		SubscriptionRequestDialog_Open();
	else
		UpgradeAccount();
	end
end

function CharacterTemplatesFrame_Update()
	if IsGMClient() and HideGMOnly() then
        return;
    end

    local numTemplates = C_CharacterCreation.GetNumCharacterTemplates();
	local isShown = (numTemplates > 0) and IsConnectedToServer();
	CharacterSelectUI.ToolTray:SetToolFrameShown(CharacterTemplatesFrame, isShown);
end

function CharacterTemplatesFrame_OnLoad(self)
	self.Dropdown:SetWidth(180);
	self.characterIndex = 1;

	self.CreateTemplateButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
		C_CharacterCreation.SetCharacterTemplate(self.characterIndex);
		GlueParent_SetScreen("charcreate");
	end);
end

function CharacterTemplatesFrame_OnShow(self)
	local function IsSelected(characterIndex)
		return self.characterIndex == characterIndex;
	end

	local function SetSelected(characterIndex)
		self.characterIndex = characterIndex;
	end

	self.Dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_CHARACTER_SELECT_TEMPLATE");

		for characterIndex = 1, C_CharacterCreation.GetNumCharacterTemplates() do
		    local name, description = C_CharacterCreation.GetCharacterTemplateInfo(characterIndex);
			local radio = rootDescription:CreateRadio(name, IsSelected, SetSelected, characterIndex);
			radio:SetTooltip(function(tooltip, elementDescription)
				GameTooltip_SetTitle(tooltip, name);
				GameTooltip_AddNormalLine(tooltip, description);
			end);
		end
	end);
end

function ToggleStoreUI(contextKey)
	local wasShown = StoreFrame_IsShown();
    if ( not wasShown ) then
        --We weren't showing, now we are. We should hide all other panels.
        -- not sure if anything is needed here at the gluescreen
    end
    StoreFrame_SetShown(not wasShown, contextKey);
end

function SetStoreUIShown(shown)
	local wasShown = StoreFrame_IsShown();
	if ( not wasShown and shown ) then
		--We weren't showing, now we are. We should hide all other panels.
		-- not sure if anything is needed here at the gluescreen
	end

	StoreFrame_SetShown(shown);
end

function PlayersOnServer_Update()
	if IsGMClient() and HideGMOnly() then
        return;
    end

    local self = PlayersOnServer;
    local connected = IsConnectedToServer();
	if not connected then
		CharacterSelectUI.ToolTray:SetToolFrameShown(self, false);
        return;
    end

    local showPlayers, numHorde, numAlliance = GetPlayersOnServer();
	CharacterSelectUI.ToolTray:SetToolFrameShown(self, showPlayers);
    if showPlayers then
        self.HordeCount:SetText(numHorde);
        self.AllianceCount:SetText(numAlliance);
        self.HordeStar:SetShown(numHorde < numAlliance);
        self.AllianceStar:SetShown(numAlliance < numHorde);
    end
end

function CharacterSelect_ActivateFactionChange()
    if IsConnectedToServer() then
        EnableChangeFaction();
		CharacterSelectListUtil.GetCharacterListUpdate();
    end
end

StaticPopupDialogs["TOKEN_GAME_TIME_OPTION_NOT_AVAILABLE"] = {
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

CharacterSelectBackButtonMixin = {};

function CharacterSelectBackButtonMixin:OnLoad()
	self.Arrow:SetSize(11, 16);
	self.Arrow:ClearAllPoints();
	self.Arrow:SetPoint("RIGHT", self:GetFontString(), "LEFT");
end

function CharacterSelectBackButtonMixin:OnEnable()
	ThreeSliceButtonMixin.UpdateButton(self);
	self.Arrow:SetDesaturation(0);
end

function CharacterSelectBackButtonMixin:OnDisable()
	ThreeSliceButtonMixin.UpdateButton(self);
	self.Arrow:SetDesaturation(1);
end

function CharacterSelectBackButtonMixin:OnClick()
	CharacterSelect_Exit();
end

function CharacterSelect_UpdateButtonState()
    local hasCharacters = GetNumCharacters() > 0;
    local servicesEnabled = not CharSelectServicesFlowFrame:ShouldDisableButtons();
    local undeleting = CharacterSelect.undeleting;
    local undeleteEnabled, undeleteOnCooldown = GetCharacterUndeleteStatus();
    local redemptionInProgress = AccountReactivationInProgressDialog:IsShown() or GoldReactivateConfirmationDialog:IsShown() or TokenReactivateConfirmationDialog:IsShown();
    local inCompetitiveMode = Kiosk.IsCompetitiveModeEnabled();
	local inKioskMode = Kiosk.IsEnabled();
	local guid = GetCharacterGUID(GetCharacterSelection());
	local boostInProgress = guid and GetServiceCharacterInfo(guid).boostInProgress == true;
	local isAccountLocked = CharacterSelectUtil.IsAccountLocked();

	-- Note: enterWorldError will be nil in most cases.
	local allowedToEnterWorld, enterWorldError = CharacterSelect_AllowedToEnterWorld();
	local disabledTooltip = isAccountLocked and CHARACTER_SELECT_ACCOUNT_LOCKED or enterWorldError;

	CharSelectEnterWorldButton:SetEnabled(allowedToEnterWorld);
	CharacterSelectBackButton:SetEnabled(servicesEnabled and not undeleting and not boostInProgress);
	CharacterSelectCharacterFrame:SetDeleteEnabled(hasCharacters and servicesEnabled and not undeleting and not redemptionInProgress and not CharacterSelect_IsRetrievingCharacterList() and not isAccountLocked, disabledTooltip);
	CharacterSelectUI.CharacterList:SetCharacterCreateEnabled(servicesEnabled and not undeleting and not redemptionInProgress and not isAccountLocked, disabledTooltip);
	CharSelectUndeleteCharacterButton:SetEnabled(servicesEnabled and undeleteEnabled and not undeleteOnCooldown and not redemptionInProgress and not isAccountLocked);
	CopyCharacterButton:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress and not isAccountLocked);
	ActivateFactionChange:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress and not isAccountLocked);
	ActivateFactionChange.texture:SetDesaturated(not (servicesEnabled and not undeleting and not redemptionInProgress and not isAccountLocked));
	CharacterTemplatesFrame.CreateTemplateButton:SetEnabled(servicesEnabled and not undeleting and not redemptionInProgress and not isAccountLocked);
	CharacterSelectUI:SetStoreEnabled(servicesEnabled and not undeleting and not redemptionInProgress and not isAccountLocked);
	CharacterSelectUI:SetMenuEnabled(servicesEnabled and not redemptionInProgress);
	CharacterSelectUI:SetChangeRealmEnabled(servicesEnabled and not undeleting and not redemptionInProgress);

	if CharacterSelect.VASPools then
		for frame in CharacterSelect.VASPools:EnumerateActive() do
			frame:SetEnabled(not redemptionInProgress and not isAccountLocked);
		end
	end

    CharSelectAccountUpgradeButton:SetEnabled(not redemptionInProgress and not undeleting and not inCompetitiveMode and not inKioskMode and not isAccountLocked);
	CharSelectEnterWorldButton:SetDisabledTooltip(disabledTooltip);
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
		CharacterSelectUtil.SetAutoSwitchRealm(true);
		C_Login.RequestAutoRealmJoin(realmAddr);
        -- We only want to do this on first load
        SetKioskAutoRealmAddress(nil);
    end
end

function CharacterSelect_ConditionallyLoadAccountSaveUI()
    if (C_AccountServices.IsAccountSaveEnabled()) then
        if (not ACCOUNT_SAVE_IS_LOADED) then
            ACCOUNT_SAVE_IS_LOADED = C_AddOns.LoadAddOn("Blizzard_AccountSaveUI");
        end
        if (AccountSaveFrame) then
            AccountSaveFrame:Show();

            if (GameRoomBillingFrame:IsShown()) then
				GameRoomBillingFrame:SetPoint("TOPLEFT", CharacterSelectBackButton, "TOPRIGHT");
            end
        end
    elseif AccountSaveFrame then
        AccountSaveFrame:Hide();

        if (GameRoomBillingFrame:IsShown()) then
            GameRoomBillingFrame:SetPoint("TOP", CharacterSelectServerAlertFrame, "BOTTOM");
        end
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

local function GetCharacterServiceDisplayOrder()
	local displayOrder = C_CharacterServices.GetCharacterServiceDisplayInfo();
	table.sort(displayOrder, function(left, right)
		return left.priority < right.priority;
	end)

	return displayOrder;
end

function IsRPEBoostEligible(charID)
	if CharacterSelect.undeleting then
		-- Deleted characters are not eligible for RPE Boost (until they are restored)
		return false;
	end
	local guid = GetCharacterGUID(charID)
	if not guid then
		return false;
	end
	return GetServiceCharacterInfo(guid).rpeResetAvailable;
end

-- CHARACTER BOOST (SERVICES)
function CharacterServicesMaster_UpdateServiceButton()
	if not CharacterSelect.VASPools then
		local vasResetter = function(framePool, frame)
            frame:Hide();
            frame.Glow:Hide();
            frame.GlowSpin:Hide();
            frame.GlowPulse:Hide();
            frame.GlowSpin.SpinAnim:Stop();
            frame.GlowPulse.PulseAnim:Stop();
			frame:ClearAllPoints();
			frame.layoutIndex = nil;
		end

		CharacterSelect.VASPools = CreateFramePoolCollection();
		CharacterSelect.VASPools:CreatePool("BUTTON", CharacterSelectUI.VASTokenContainer, "CharacterBoostTemplate", vasResetter);
		CharacterSelect.VASPools:CreatePool("BUTTON", CharacterSelectUI.VASTokenContainer, "CharacterVASTemplate", vasResetter);
	end

	CharacterSelect.VASPools:ReleaseAll();

    UpgradePopupFrame:Hide();
    CharacterSelectUI.WarningText:Hide();

    if CharacterSelect.undeleting or (CharSelectServicesFlowFrame:ShouldDisableButtons()) then
        return;
    end

	local displayOrder = GetCharacterServiceDisplayOrder();
    local upgradeInfo = C_SharedCharacterServices.GetUpgradeDistributions();
    local hasPurchasedBoost = false;
    for id, data in pairs(upgradeInfo) do
		hasPurchasedBoost = hasPurchasedBoost or data.hasPaid;
    end

	local isExpansionTrial, expansionTrialRemainingSeconds = GetExpansionTrialInfo();
	if isExpansionTrial then
		upgradeInfo[0] = {
			hasPaid = false,
			hasFree = true,
			amount = 1,
			isExpansionTrial = true,
			-- Possibly add to character service data
			remainingTime = expansionTrialRemainingSeconds,
			hideTimer = true,
			characterCreateType = Enum.CharacterCreateType.Normal,
		};
	end

	CharacterSelectUI:TriggerEvent(CharacterSelectUIMixin.Event.ExpansionTrialStateUpdated, isExpansionTrial);

    -- support refund notice for Korea
    if hasPurchasedBoost and C_StoreSecure.GetCurrencyID() == CURRENCY_KRW then
        CharacterSelectUI.WarningText:Show();
    end

	CharacterServicesMaster_UpdateVASButtons(displayOrder);
	CharacterServicesMaster_UpdateBoostButtons(displayOrder, upgradeInfo);
	CharacterSelectUI.VASTokenContainer:Layout();
end

function CharSelectServicesFlow_Minimize()
	local parent = CharSelectServicesFlowFrame;
	parent.IsMinimized = true;
	parent.MinimizedFrame:Show();
	parent:Hide();
end

function CharSelectServicesFlow_Maximize()
	local parent = CharSelectServicesFlowFrame;
	parent.IsMinimized = false;
	parent.MinimizedFrame:Hide();
	BeginCharacterServicesFlow(RPEUpgradeFlow, {});
end

------------------------------------------------------------------
-- API for VAS tokens:
------------------------------------------------------------------
local function GetVASDistributions()
	local distributions = C_CharacterServices.GetVASDistributions();
	local distributionsByVASType = {};

	for index, distribution in ipairs(distributions) do
		distribution.tokenStatus = distribution.inReview and "review" or "normal";
		distribution.isVAS = true;
		distributionsByVASType[distribution.serviceType] = distribution;
	end

	for vasType, distribution in pairs(distributionsByVASType) do
		if not IsVASEnabledOnRealm(vasType) then
			distribution.tokenStatus = "disabledOnRealm";
		else
			-- Are there any characters for which this token is valid?
			local usable = false;

			local includeEmptySlots = true;
			local numCharacters = GetNumCharacters(includeEmptySlots);
			for i=1, numCharacters do
				local charID = CharacterSelectListUtil.GetCharIDFromIndex(i);
				-- Do not run on empty character slots.
				if charID ~= 0 then
					if vasType == Enum.ValueAddedServiceType.PaidCharacterTransfer then
						usable = DoesClientThinkTheCharacterIsEligibleForPCT(charID);
					elseif vasType == Enum.ValueAddedServiceType.PaidFactionChange then
						usable = DoesClientThinkTheCharacterIsEligibleForPFC(charID);
					elseif vasType == Enum.ValueAddedServiceType.PaidRaceChange then
						usable = DoesClientThinkTheCharacterIsEligibleForPRC(charID);
					elseif vasType == Enum.ValueAddedServiceType.PaidNameChange then
						usable = DoesClientThinkTheCharacterIsEligibleForPNC(charID);
					end
					if usable then
						break;
					end
				end
			end
			if not usable then
				distribution.tokenStatus = "noCharacters";
			end
		end
	end

	return distributionsByVASType;
end

local function GetVASTokenStatus(vasTokenInfo)
	return vasTokenInfo.tokenStatus or "normal";
end

local function GetVASTokenAlpha(vasTokenInfo)
	return GetVASTokenStatus(vasTokenInfo) == "normal" and 1 or .7;
end

local statusToTooltipLookup = {
	review = VAS_TOKEN_TOOLTIP_STATUS_REVIEW,
	noCharacters = VAS_TOKEN_TOOLTIP_STATUS_NO_CHARACTERS,
	disabledOnRealm = VAS_TOKEN_TOOLTIP_STATUS_DISABLED_ON_REALM,
};

local function GetVASTokenStatusTooltip(vasTokenInfo)
	-- nil is fine, it means no tooltip.
	return statusToTooltipLookup[GetVASTokenStatus(vasTokenInfo)];
end

local function IsVASTokenUsable(vasTokenInfo)
	return GetVASTokenStatus(vasTokenInfo) == "normal";
end

local function AddExtraCharUpgradeDisplayData(charUpgradeDisplayData, upgradeInfo)
	charUpgradeDisplayData.remainingTime = upgradeInfo.remainingTime;
	charUpgradeDisplayData.hideTimer = upgradeInfo.hideTimer;
	charUpgradeDisplayData.characterCreateType = upgradeInfo.characterCreateType;
end

local function AddVASButton(charUpgradeDisplayData, upgradeInfo, template)
	AddExtraCharUpgradeDisplayData(charUpgradeDisplayData, upgradeInfo);

	local frame = CharacterSelect.VASPools:Acquire(template);
	frame.layoutIndex = CharacterSelect.VASPools:GetNumActive();

	frame.data = charUpgradeDisplayData;
	frame.upgradeInfo = upgradeInfo;
	frame.data.isExpansionTrial = upgradeInfo.isExpansionTrial;
	frame.data.isVAS = upgradeInfo.isVAS;
	frame.hasFreeBoost = upgradeInfo.hasFree;
	frame.remainingTime = upgradeInfo.remainingTime;

	-- Prefer texture kit if set.
	if charUpgradeDisplayData.iconTextureKit then
		local formattedVASIcon = ("%s-small"):format(charUpgradeDisplayData.iconTextureKit);
		frame.Icon:SetAtlas(formattedVASIcon, true);
		frame.Highlight.Icon:SetAtlas(formattedVASIcon, true);
	elseif charUpgradeDisplayData.icon then
		SetPortraitToTexture(frame.Icon, charUpgradeDisplayData.icon);
		SetPortraitToTexture(frame.Highlight.Icon, charUpgradeDisplayData.icon);
	end

	frame:SetAlpha(GetVASTokenAlpha(upgradeInfo));

	if upgradeInfo.remainingTime and not upgradeInfo.hideTimer then
		frame.Timer:StartTimer(upgradeInfo.remainingTime, 1, true);
	else
		frame.Timer:StopTimer();
	end

	if upgradeInfo.amount > 1 then
		frame.Ring:Show();
		frame.Number:Show();
		frame.Number:SetText(upgradeInfo.amount);
	else
		frame.Ring:Hide();
		frame.Number:Hide();
	end

	frame:Show();
end

function CharacterServicesMaster_UpdateBoostButtons(displayOrder, upgradeInfo)
	for _, characterService in pairs(displayOrder) do
		if not characterService.isVAS then
			local boostType = characterService.serviceID;
			local boostUpgradeInfo = upgradeInfo[boostType];
			if boostUpgradeInfo and boostUpgradeInfo.amount > 0 then
				local charUpgradeDisplayData = C_CharacterServices.GetCharacterServiceDisplayData(boostType);
				AddVASButton(charUpgradeDisplayData, boostUpgradeInfo, "CharacterBoostTemplate");
			end
		end
	end
end

function CharacterServicesMaster_UpdateVASButtons(displayOrder)
	local upgradeInfo = GetVASDistributions();
	for _, characterService in pairs(displayOrder) do
		if characterService.isVAS then
			local vasType = characterService.serviceID;
			local vasInfo = upgradeInfo[vasType];
			if vasInfo and vasInfo.amount > 0 then
				local vasDisplay = C_CharacterServices.GetCharacterServiceDisplayDataByVASType(vasType);
				if vasDisplay then
					AddVASButton(vasDisplay, vasInfo, "CharacterVASTemplate");
				end
			end
		end
	end
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
		if freeFrame.remainingTime and not freeFrame.upgradeInfo.hideTimer then
			popupFrame.Timer:StartTimer(freeFrame.remainingTime, 1, true, true, BOOST_POPUP_TIMER_FORMAT_STRING);
			popupFrame.Description:SetPoint("TOP", popupFrame.Timer, "BOTTOM", 0, -20);
			timerHeight = popupFrame.Timer:GetHeight() + 2;
		else
			popupFrame.Timer:StopTimer();
			popupFrame.Description:SetPoint("TOP", popupFrame.Title, "BOTTOM", 0, -20);
		end

		popupFrame.Description:SetText(popupData.description);
		popupFrame:SetupTextureKit(popupData.textureKit, textureKitRegionInfo);

		local baseHeight;
		if freeFrame.data.isExpansionTrial then
			popupFrame.GetStartedButton:SetText(EXPANSION_TRIAL_CREATE_TRIAL_CHARACTER); -- TODO: Update text to read "Create Dracthyr Evoker" (TODO: Add to Character display info data??)
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

function CharSelectServices_ShowFlowFrame()
	CharSelectServicesFlowFrame:Show();

	-- Moved out of the CharSelectServicesFlowFrame OnShow handler because a flow can be requested while another flow is
	-- already shown. See Gear Update as an example.
	CharacterServicesMaster_UpdateServiceButton();
end

function BeginCharacterServicesFlow(flow, data)
	if flow:CanInitialize() then
		CharSelectServicesFlowFrame:Initialize(flow);

		CharSelectServices_ShowFlowFrame();
		
		flow:SetTarget(data); -- NOTE: It seems like data can be changed in the middle of a flow, so keeping this here until that is determined.
		CharacterServicesMaster_SetFlow(CharacterServicesMaster, flow);

		-- RPE force expands the character list when player clicks the first 'next' button in the flow, since that is automatically started compared to other flows.
		if flow ~= RPEUpgradeFlow then
			-- In case the character select list was collapsed, ensure that it is now expanded.
			CharacterSelectUI:ExpandCharacterList();
			CharacterSelectUI:SetCharacterListToggleEnabled(false);
		end
	end
end

function EndCharacterServicesFlow(shouldMaximize)
	CharSelectServicesFlowFrame:Hide();
	if CharSelectServicesFlowFrame.MinimizedFrame then
		CharSelectServicesFlowFrame.MinimizedFrame:Hide();
		if shouldMaximize then
			CharSelectServicesFlowFrame.IsMinimized = false;
		end
	end
	CharacterSelectUI:SetCharacterListToggleEnabled(true);

	CharacterServicesMaster_ClearFlow(CharacterServicesMaster);
	CharacterSelectCharacterFrame.ScrollBox.dragBehavior:SetDragEnabled(CharacterSelectListUtil.CanReorder());
end

function CharacterUpgradePopup_BeginCharacterUpgradeFlow(data, guid)
	CharacterUpgradeFlow:SetTrialBoostGuid(nil);

	if guid then
		local serviceInfo = GetServiceCharacterInfo(guid);
		if serviceInfo.isTrialBoost then
			CharacterUpgradeFlow:SetTrialBoostGuid(guid);
		else
			CharacterUpgradeFlow:SetAutoSelectGuid(guid);
		end
	end

	CharacterUpgradePopup_CheckSetPopupSeen(data);
	BeginCharacterServicesFlow(CharacterUpgradeFlow, data);
end

function CharacterUpgradePopup_BeginVASFlow(data, guid)
	assert(data.vasType ~= nil);
	if data.vasType == Enum.ValueAddedServiceType.PaidCharacterTransfer then
		BeginCharacterServicesFlow(PaidCharacterTransferFlow, data);
	elseif data.vasType == Enum.ValueAddedServiceType.PaidFactionChange then
		BeginCharacterServicesFlow(PaidFactionChangeFlow, data);
	elseif data.vasType == Enum.ValueAddedServiceType.PaidRaceChange then
		BeginCharacterServicesFlow(PaidRaceChangeFlow, data);
	elseif data.vasType == Enum.ValueAddedServiceType.PaidNameChange then
		BeginCharacterServicesFlow(PaidNameChangeFlowMainline, data);
	else
		error("Unsupported VAS Type Flow");
	end
end

function CharacterUpgradePopup_OnStartClick(self)
    local data = HandleUpgradePopupButtonClick(self);
	if data.isExpansionTrial then
		CharacterSelectUtil.CreateNewCharacter(data.characterCreateType or Enum.CharacterCreateType.TrialBoost);
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

CharacterVASMixin = {};

function CharacterVASMixin:OnClick()
	if IsVASTokenUsable(self.upgradeInfo) then
		CharacterUpgradePopup_BeginVASFlow(self.data);
	end
end

function CharacterVASMixin:OnEnter()
	self.Highlight:Show();

	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_LEFT");

	if self.data.isExpansionTrial or self.data.isVAS then
		GameTooltip_SetTitle(tooltip, self.data.popupInfo.title);
		GameTooltip_AddNormalLine(tooltip, self.data.popupInfo.description);

		local statusLine = GetVASTokenStatusTooltip(self.upgradeInfo);
		if statusLine then
			GameTooltip_AddErrorLine(tooltip, statusLine);
		end
	else
		GameTooltip_SetTitle(tooltip, self.data.flowTitle);
		GameTooltip_AddNormalLine(tooltip, BOOST_TOKEN_TOOLTIP_DESCRIPTION:format(self.data.level));
	end

    tooltip:Show();
end

function CharacterVASMixin:OnLeave()
    self.Highlight:Hide();
	GetAppropriateTooltip():Hide();
end

CharacterBoostMixin = {};

function CharacterBoostMixin:OnClick()
	EndCharacterServicesFlow(true);

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
    elseif not C_CharacterCreation.IsNewPlayerRestricted() then
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
	CharacterServicesMaster_UpdateServiceButton();

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
			CharacterSelectCharacterFrame:ScrollToCharacter(automaticBoostCharacterGUID);
			CharacterUpgradePopup_BeginCharacterUpgradeFlow(C_CharacterServices.GetCharacterServiceDisplayData(automaticBoostType), automaticBoostCharacterGUID);
			CharacterSelectListUtil.SelectCharacterByGUID(automaticBoostCharacterGUID);
        else
			if (CharacterUpgrade_IsCreatedCharacterUpgrade()) then
				CharacterUpgradeFlow:SetTarget(CHARACTER_UPGRADE_CREATE_CHARACTER_DATA);
			else
				CharacterUpgradeFlow:SetTarget(C_CharacterServices.GetCharacterServiceDisplayData(automaticBoostType), false);
			end

			if CharacterUpgradeFlow.data and CharacterUpgradeFlow:CanInitialize() then
				CharSelectServices_ShowFlowFrame();

				CharacterUpgradeFlow:SetTarget(CharacterUpgradeFlow.data);
				CharacterServicesMaster_SetFlow(CharacterServicesMaster, CharacterUpgradeFlow);
			end

			CharacterUpgrade_ResetBoostData();
		end

        C_CharacterServices.SetAutomaticBoost(nil);
		C_CharacterServices.SetAutomaticBoostCharacter(nil);
    elseif (C_CharacterServices.HasQueuedUpgrade()) then
        local guid = C_CharacterServices.GetQueuedUpgradeGUID();

        CharacterServicesMaster.waitingForLevelUp = CharacterSelectListUtil.SelectCharacterByGUID(guid);

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
	self.flows[flow] = true;
	CharacterServicesMaster_HideFlows(self);

    flow:Initialize(self);

	-- Prefer texture kit if set.
	if flow.data.iconTextureKit then
		local formattedVASIcon = ("%s-regular"):format(flow.data.iconTextureKit);
		self:GetParent().Icon:SetAtlas(formattedVASIcon, true);
	elseif flow.data.icon then
		SetPortraitToTexture(self:GetParent().Icon, flow.data.icon);
	end

	if flow.data.flowTitle then
		self:GetParent().TitleText:SetText(flow.data.flowTitle);
	end

    CharacterServicesMaster_UpdateFinishLabel(self);

    for i = 1, #flow.Steps do
        local block = flow.Steps[i];
        if (not block.HiddenStep) then
            block.frame:SetFrameLevel(CharacterServicesMaster:GetFrameLevel()+2);
            block.frame:SetParent(self);
        end
    end
end

function CharacterServicesMaster_ClearFlow(self)
	self.flow = nil;
end

function CharacterServicesMaster_AllowCharacterReordering(self)
	return not self.flow or self.flow:AllowCharacterReordering();
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

	self.flow:CheckRewind(self);
end

function CharacterServicesMaster_OnHide(self)
    for flow, state in pairs(self.flows) do
        if state then
			flow:OnHide();
			self.flows[flow] = false;
        end
    end
end

function CharacterServicesMaster_HideFlows(self)
	for flow in pairs(self.flows) do
		flow:HideBlocks();
	end
end

do
	local function callIfPresent(block)
		return function(key, fn, ...)
			local child = block.frame[key];
			if child then
				child[fn](child, ...);
			end
		end
	end

	function CharacterServicesMaster_SetBlockActiveState(block)
		local call = callIfPresent(block);
		call("StepLabel", "Show");
		call("StepNumber", "Show");
		call("StepActiveLabel", "Show");
		call("StepActiveLabel", "SetText", block.ActiveLabel);
		call("ControlsFrame", "Show");
		call("Checkmark", "Hide");
		call("StepFinishedLabel", "Hide");
		call("ResultsLabel", "Hide");
	end

	function CharacterServicesMaster_SetBlockFinishedState(block)
		local call = callIfPresent(block);
		call("Checkmark", "Show");
		call("StepFinishedLabel", "Show");
		call("StepFinishedLabel", "SetText", block.ResultsLabel);
		call("ResultsLabel", "Show");
		if (block.FormatResult) then
			call("ResultsLabel", "SetText", block:FormatResult());
		else
			call("ResultsLabel", "SetText", block:GetResult());
		end
		call("StepLabel", "Hide");
		call("StepNumber", "Hide");
		call("StepActiveLabel", "Hide");
		call("ControlsFrame", "Hide");
	end
end

function CharacterServicesMasterBackButton_OnClick()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    local master = CharacterServicesMaster;
    master.flow:Rewind(master);
end

function CharacterServicesMasterNextButton_OnClick()
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

function CharacterServicesMaster_Advance()
    local master = CharacterServicesMaster;
    master.blockComplete = true;
    CharacterServicesMaster_Update();
    master.flow:Advance(master);
end

function CharacterServicesMasterFinishButton_OnClick()
	if CharacterServicesMaster.flow:ShouldFinishBehaveLikeNext() then
		CharacterServicesMasterNextButton_OnClick();
		return;
	end

    -- wait a bit after button is shown so no one accidentally upgrades the wrong character
    if (CharacterServicesMaster.FinishTime and (GetTime() - CharacterServicesMaster.FinishTime < 0.5 )) then
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

function CharacterUpgradeSecondChanceWarningFrameConfirmButton_OnClick(self)
    CharacterUpgradeSecondChanceWarningFrame.warningAccepted = true;

    CharacterUpgradeSecondChanceWarningFrame:Hide();

    CharacterServicesMasterFinishButton_OnClick();
end

function CharacterUpgradeSecondChanceWarningFrameCancelButton_OnClick(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local master = CharacterServicesMaster;
	CharSelectServicesFlowFrame.FinishButton:Show(master.currentBlock.Finish);
	CharSelectServicesFlowFrame.BackButton:Show(master.currentBlock.Back);
	CharSelectServicesFlowFrame.CloseButton:Show();
    CharacterUpgradeSecondChanceWarningFrame:Hide();

    CharacterUpgradeSecondChanceWarningFrame.warningAccepted = false;
end

-- CHARACTER UNDELETE

StaticPopupDialogs["UNDELETE_FAILED"] = {
    text = UNDELETE_FAILED_ERROR,
    button1 = OKAY,
    escapeHides = true,
}

StaticPopupDialogs["UNDELETE_NAME_TAKEN"] = {
    text = UNDELETE_NAME_TAKEN,
    button1 = OKAY,
    escapeHides = true,
}

StaticPopupDialogs["UNDELETE_DRACTHYR_LEVEL_REQUIREMENT"] = {
	text = UNDELETE_DRACTHYR_LEVEL_REQUIREMENT,
	button1 = OKAY,
	escapeHides = true,
}

StaticPopupDialogs["UNDELETE_NO_CHARACTERS"] = {
    text = UNDELETE_NO_CHARACTERS;
    button1 = OKAY,
    button2 = nil,
}

StaticPopupDialogs["UNDELETE_SUCCEEDED"] = {
    text = UNDELETE_SUCCESS,
    button1 = OKAY,
    escapeHides = true,
}

StaticPopupDialogs["UNDELETE_SUCCEEDED_NAME_TAKEN"] = {
    text = UNDELETE_SUCCESS_NAME_CHANGE_REQUIRED,
    button1 = OKAY,
    escapeHides = true,
}

StaticPopupDialogs["UNDELETE_CONFIRM"] = {
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

    CharacterSelectCharacterFrame:UpdateUndeleteState();
	CharacterTemplatesFrame.CreateTemplateButton:Hide();

    AccountReactivate_CloseDialogs();

    CharacterServicesMaster_UpdateServiceButton();
    StartCharacterUndelete();
end

function CharacterSelect_EndCharacterUndelete()
    CharacterSelect.undeleting = false;
    CharacterSelect.undeleteChanged = true;

	CharacterSelectCharacterFrame:UpdateUndeleteState();
	CharacterTemplatesFrame.CreateTemplateButton:Show();

    CharacterServicesMaster_UpdateServiceButton();
    EndCharacterUndelete();
end

function CharacterSelect_FinishUndelete(guid)
    GlueDialog_Show("UNDELETING_CHARACTER");

    UndeleteCharacter(guid);
    CharacterSelect.createIndex = 0;
end

-- COPY CHARACTER
StaticPopupDialogs["COPY_CHARACTER"] = {
    text = "",
    button1 = OKAY,
    button2 = CANCEL,
    escapeHides = true,
    OnAccept = function ()
        CopyCharacterFromLive();
    end,
}

StaticPopupDialogs["COPY_ACCOUNT_DATA"] = {
    text = COPY_ACCOUNT_CONFIRM,
    button1 = OKAY,
    button2 = CANCEL,
    escapeHides = true,
    OnAccept = function ()
        CopyCharacter_AccountDataFromLive();
    end,
}

StaticPopupDialogs["COPY_KEY_BINDINGS"] = {
    text = COPY_KEY_BINDINGS_CONFIRM,
    button1 = OKAY,
    button2 = CANCEL,
    escapeHides = true,
    OnAccept = function ()
        CopyCharacter_KeyBindingsFromLive();
    end,
}

StaticPopupDialogs["COPY_IN_PROGRESS"] = {
    text = COPY_IN_PROGRESS,
    button1 = nil,
    button2 = nil,
    ignoreKeys = true,
    spinner = true,
}

StaticPopupDialogs["UNDELETING_CHARACTER"] = {
    text = RESTORING_CHARACTER_IN_PROGRESS,
    ignoreKeys = true,
    spinner = true,
}

function CopyCharacterFromLive()
    if ( not IsGMClient() ) then
		CopyAccountCharacterFromLive(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.SelectedIndex);
	else
		CopyAccountCharacterFromLive(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.SelectedIndex, CopyCharacterFrame.RealmName:GetText(), CopyCharacterFrame.CharacterName:GetText());
	end
    GlueDialog_Show("COPY_IN_PROGRESS");
end

function CopyCharacter_AccountDataFromLive()
    if ( not IsGMClient() ) then
        CopyAccountDataFromLive(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.SelectedIndex);
    else
        CopyAccountDataFromLive(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.SelectedIndex, CopyCharacterFrame.RealmName:GetText(), CopyCharacterFrame.CharacterName:GetText());
    end
    GlueDialog_Show("COPY_IN_PROGRESS");
end

function CopyCharacter_KeyBindingsFromLive()
    if ( not IsGMClient() ) then
        CopyKeyBindingsFromLive(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.SelectedIndex);
    else
        CopyKeyBindingsFromLive(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.SelectedIndex, CopyCharacterFrame.RealmName:GetText(), CopyCharacterFrame.CharacterName:GetText());
    end
    GlueDialog_Show("COPY_IN_PROGRESS");
end

CopyCharacterButtonMixin = {};

function CopyCharacterButtonMixin:OnClick()
	CopyCharacterFrame:SetShown(not CopyCharacterFrame:IsShown());
end

function CopyCharacterButtonMixin:UpdateButtonState()
	local isShown = C_CharacterServices.IsLiveRegionCharacterListEnabled() or C_CharacterServices.IsLiveRegionCharacterCopyEnabled() or C_CharacterServices.IsLiveRegionAccountCopyEnabled() or C_CharacterServices.IsLiveRegionKeyBindingsCopyEnabled();
	CharacterSelectUI.ToolTray:SetToolFrameShown(self, isShown);
end

function CopyCharacterSearch_OnClick(self)
    ClearAccountCharacters();
    CopyCharacterFrame_Update(CopyCharacterFrame.scrollFrame);
    RequestAccountCharacters(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.RealmName:GetText(), CopyCharacterFrame.CharacterName:GetText());
    self:Disable();
end

function CopyCharacterCopy_OnClick(self)
    if ( not GlueDialog:IsShown() ) then
		local selectedIndex = CopyCharacterFrame.SelectedIndex;
		if ( selectedIndex and (selectedIndex <= GetNumAccountCharacters()) ) then
			local name, realm = GetAccountCharacterInfo(selectedIndex);
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

function CopyKeyBindings_OnClick(self)
    if ( not GlueDialog:IsShown() ) then
        GlueDialog_Show("COPY_KEY_BINDINGS");
    end
end

function CopyCharacterEntry_Init(self, characterIndex)
	local name, realm, class, level = GetAccountCharacterInfo(characterIndex);
	self.Name:SetText(name);
	self.Server:SetText(realm);
	self.Class:SetText(class);
	self.Level:SetText(level);

	local selected = CopyCharacterFrame.SelectedIndex == characterIndex;
	CopyCharacterEntry_SetSelected(self, selected);
end

function CopyCharacterEntry_SetSelected(self, selected)
	self.SelectedTexture:SetShown(selected);
end

function CopyCharacterEntry_OnClick(self)
   CopyCharacterFrame_SetSelected(self:GetElementData());
end

function CopyCharacterFrame_SetSelected(characterIndex)
	if characterIndex then
		CopyCharacterFrame.CopyButton:SetEnabled(C_CharacterServices.IsLiveRegionCharacterCopyEnabled());
	end

	local function SetSelected(index, selected)
		if index then
			local frame = CopyCharacterFrame.ScrollBox:FindFrame(index);
			if frame then
				CopyCharacterEntry_SetSelected(frame, selected);
			end
		end
	end

	SetSelected(CopyCharacterFrame.SelectedIndex, false);
	CopyCharacterFrame.SelectedIndex = characterIndex;
	SetSelected(CopyCharacterFrame.SelectedIndex, true);
end

function CopyCharacterEntry_OnEnter(self)
	self.HighlightTexture:Show();
end

function CopyCharacterEntry_OnLeave(self)
	self.HighlightTexture:Hide();
end

function CopyCharacterFrame_OnLoad(self)
    ButtonFrameTemplate_HidePortrait(self);
    self:RegisterEvent("ACCOUNT_CHARACTER_LIST_RECIEVED");
    self:RegisterEvent("CHAR_RESTORE_COMPLETE");
    self:RegisterEvent("ACCOUNT_DATA_RESTORED");
    self:RegisterEvent("KEY_BINDINGS_COPY_COMPLETE");

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CopyCharacterEntryTemplate", function(button, elementData)
		CopyCharacterEntry_Init(button, elementData);
	end);
	view:SetPadding(0,0,0,0,4);

	ScrollUtil.InitScrollBoxListWithScrollBar(CopyCharacterFrame.ScrollBox, CopyCharacterFrame.ScrollBar, view);

	self.RegionID:SetWidth(100);
end

function CopyCharacterFrame_OnShow(self)
   GlueParent_AddModalFrame(self);

	self.CopyButton:SetEnabled(false);

	local regions = C_CharacterServices.GetLiveRegionCharacterCopySourceRegions();
	self.selectedRegion = regions[1];
	
	local function IsSelected(regionID)
		return self.selectedRegion == regionID;
	end

	local function SetSelected(regionID)
		self.selectedRegion = regionID;

		if not IsGMClient() then
			CopyCharacterFrame_SetSelected(nil);
			CopyCharacterFrame.ScrollBox:SetDataProvider(CreateIndexRangeDataProvider(0), ScrollBoxConstants.RetainScrollPosition);
			CopyCharacterFrame.CopyButton:Disable();
			RequestAccountCharacters(regionID);
		end
	end

	self.RegionID:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_CHARACTER_SELECT_REGION");

		for index, regionID in ipairs(regions) do
			local regionName = characterCopyRegions[regionID];
			if regionName then
				rootDescription:CreateRadio(regionName, IsSelected, SetSelected, regionID);
			end
		end
	end);

	ClearAccountCharacters();
	CopyCharacterFrame_Update(self.scrollFrame);

	if ( not IsGMClient() ) then
		self.RealmName:Hide();
		self.CharacterName:Hide();
		self.SearchButton:Hide();
		RequestAccountCharacters(CopyCharacterFrame_GetSelectedRegionID());
	else
		self.RealmName:Show();
		self.RealmName:SetFocus();
		self.CharacterName:Show();
		self.SearchButton:Show();
		self.SearchButton:SetEnabled(C_CharacterServices.IsLiveRegionCharacterListEnabled());
		self.CopyButton:SetEnabled(C_CharacterServices.IsLiveRegionCharacterCopyEnabled());
	end

	self.CopyAccountData:SetEnabled(C_CharacterServices.IsLiveRegionAccountCopyEnabled());
	self.CopyKeyBindings:SetEnabled(C_CharacterServices.IsLiveRegionKeyBindingsCopyEnabled());
end

function CopyCharacterFrame_OnHide(self)
	GlueParent_RemoveModalFrame(self);
end

function CopyCharacterFrame_OnEvent(self, event, ...)
    if ( event == "ACCOUNT_CHARACTER_LIST_RECIEVED" ) then
        CopyCharacterFrame_Update(self.scrollFrame);
        self.SearchButton:Enable();
    elseif ( event == "CHAR_RESTORE_COMPLETE" or event == "ACCOUNT_DATA_RESTORED" or event == "KEY_BINDINGS_COPY_COMPLETE") then
        local success, token = ...;
        GlueDialog_Hide();
        self:Hide();
        if (not success) then
            GlueDialog_Show("OKAY", COPY_FAILED);
        end
    end
end

function CopyCharacterFrame_GetSelectedRegionID()
	return CopyCharacterFrame.selectedRegion;
end

function CopyCharacterFrame_Update(self)
	local dataProvider = CreateIndexRangeDataProvider(GetNumAccountCharacters());
	CopyCharacterFrame.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
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


function CharacterServicesFlow_IsShowing()
	return CharSelectServicesFlowFrame:IsShown() or (CharSelectServicesFlowFrame.MinimizedFrame and CharSelectServicesFlowFrame.MinimizedFrame:IsShown())
end

CharSelectServicesFlowFrameMixin = {};

function CharSelectServicesFlowFrameMixin:OnLoad()
	self.CloseButton:SetScript("OnClick", function()
		EndCharacterServicesFlow(false);
		CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex); --reopens RPE upgrade if eligigble
		CharacterServicesMaster_UpdateServiceButton();
	end);

	self.MinimizeButton:SetScript("OnClick", function()
		CharSelectServicesFlow_Minimize();
	end);
end

function CharSelectServicesFlowFrameMixin:OnShow()
	if self.IsMinimized then
		CharSelectServicesFlow_Minimize();
	else
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
		CharacterSelect_UpdateButtonState();
		CharSelectServicesCover:Show();
	end
end

function CharSelectServicesFlowFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	CharacterSelect_UpdateButtonState();
	CharSelectServicesCover:Hide();
	CharacterServicesMaster_UpdateServiceButton();
end

function CharSelectServicesFlowFrameMixin:SetErrorMessage(msg)
	self.ErrorMessageContainer.Text:SetText(msg);
	self.ErrorMessageContainer.Text:SetJustifyH("CENTER");
	self.ErrorMessageContainer.fullText = msg;

	local isTruncated = self.ErrorMessageContainer.Text:IsTruncated();
	self.ErrorMessageContainer.isTruncated = isTruncated;
	if isTruncated then
		-- HACK, avoid global string hotfix:
		local errorLink = string.gsub('[' .. BLIZZARD_STORE_VAS_ERROR_LABEL .. ']', ':', '');
		self.ErrorMessageContainer.Text:SetText(errorLink);
	end
end

function CharSelectServicesFlowFrameMixin:ClearErrorMessage()
	self.ErrorMessageContainer.Text:SetText("");
	self.ErrorMessageContainer.fullText = nil;
	self.ErrorMessageContainer.isTruncated = nil;
end

function CharSelectServicesFlowFrameMixin:Initialize(flow)
	if not flow.MinimizedFrame then
		self.IsMinimized = false; --flows that cant minimize should no longer be tracking that they are minimized.
		if self.MinimizedFrame then
			self.MinimizedFrame:Hide(); --any previously minimized frames should be hidden (will be cleared in CharSelectServicesFlowFrame:Initialize)
		end
	end

	self.MinimizedFrame = flow.MinimizedFrame and _G[flow.MinimizedFrame];
	self.DisableButtons = flow:ShouldDisableButtons();

	local theme = flow:GetTheme();
	if theme == "default" then
		self.BackgroundDefault:Show();
		self.BackgroundHeader:Show();
		self.BackgroundDivider:Show();
		self.Icon:Show();
		self.IconBorder:Show();
		self.TitleText:Show();
		self.CloseButton:Show();

		self.BackgroundRPE:Hide();
		self.MinimizeButton:Hide();

		local backNextX, backNextY = 25, 26;
		self.NextButton:SetPoint("BOTTOMRIGHT", -backNextX, backNextY);
		self.BackButton:SetPoint("BOTTOMLEFT", backNextX, backNextY);

		self.FinishButton:SetPoint("BOTTOMRIGHT", -9, 23);

		self:SetSize(362, 668);
		self:SetPoint("LEFT", 3, -7);
	elseif theme == "RPE" then
		self.BackgroundDefault:Hide();
		self.BackgroundHeader:Hide();
		self.BackgroundDivider:Hide();
		self.Icon:Hide();
		self.IconBorder:Hide();
		self.TitleText:Hide();
		self.CloseButton:Hide();

		self.BackgroundRPE:Show();
		self.MinimizeButton:Show();

		local backNextX, backNextY = 27, 31;
		self.NextButton:SetPoint("BOTTOMRIGHT", -backNextX, backNextY);
		self.BackButton:SetPoint("BOTTOMLEFT", backNextX, backNextY);

		self.FinishButton:SetPoint("BOTTOMRIGHT", -11, 28);

		self:SetSize(362, 598);
		self:SetPoint("LEFT", 3, 85);
	end
end

function CharSelectServicesFlowFrameMixin:ShouldDisableButtons()
	return self:IsShown() and self.DisableButtons;
end

FlowErrorContainerMixin = {};

function FlowErrorContainerMixin:OnEnter()
	if self.isTruncated then
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip_SetTitle(tooltip, BLIZZARD_STORE_VAS_ERROR_LABEL);
		GameTooltip_AddErrorLine(tooltip, self.fullText);
		tooltip:Show();
	end
end

function FlowErrorContainerMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

LimitedTimeEventFrameMixin = {};

function LimitedTimeEventFrameMixin:OnLoad()
	self.Text.BGLabel:SetMaxLines(3);
	self.Text.Label:SetMaxLines(3);
end