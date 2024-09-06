CharacterSelectListGroupMixin = {};

function CharacterSelectListGroupMixin:OnLoad()
	self.characterButtonPool = CreateFramePool("BUTTON", self.Contents, "CharacterSelectListCharacterTemplate");
	self.emptyCharacterButtonPool = CreateFramePool("FRAME", self.Contents, "CharacterSelectListEmptyCharacterTemplate");
	self.groupButtons = {};
end

function CharacterSelectListGroupMixin:Init(elementData)
	self.Header.Text:SetText(elementData.name);
	self:OnExpandedChanged();

	self.characterButtonPool:ReleaseAll();
	self.emptyCharacterButtonPool:ReleaseAll();
	self.groupButtons = {};

	for _, data in ipairs(elementData.characterData) do
		if data.isEmpty then
			local emptyCharacterButton = self.emptyCharacterButtonPool:Acquire();

			emptyCharacterButton:ClearAllPoints();
			emptyCharacterButton.characterID = data.characterID;
			emptyCharacterButton:Show();

			table.insert(self.groupButtons, emptyCharacterButton);
		else
			local characterButton = self.characterButtonPool:Acquire();
			local inGroup = true;

			characterButton:ClearAllPoints();
			characterButton:SetData(data, inGroup);
			characterButton:Show();

			table.insert(self.groupButtons, characterButton);
		end
	end

	local spacing = -7;
	local initialAnchor = CreateAnchor("TOPLEFT", self.Contents, "TOPLEFT", 0, -9);
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopToBottom, #self.groupButtons, 0, 0, 0, spacing);
	AnchorUtil.ChainLayout(self.groupButtons, initialAnchor, layout);
end

function CharacterSelectListGroupMixin:OnExpandedChanged()
	local elementData = self:GetElementData();

	SetWarbandGroupCollapsedState(elementData.groupID, elementData.collapsed);

	self.Header:OnButtonStateChanged();
	self.Backdrop:SetShown(not elementData.collapsed);
	self.Contents:SetShown(not elementData.collapsed);

	self:SetHeight(elementData.collapsed and elementData.heightCollapsed or elementData.heightExpanded);
end

function CharacterSelectListGroupMixin:AnimatePulse()
    self:CleanupAnimations();
    self.PulseAnim:Restart();
end

function CharacterSelectListGroupMixin:CleanupAnimations()
    self.PulseAnim:Stop();
    self.PulseAnim:OnFinished();
end


CharacterSelectListGroupPulseAnimMixin = {};

function CharacterSelectListGroupPulseAnimMixin:OnPlay()
    self:GetParent().PulseGlow:Show();
end

function CharacterSelectListGroupPulseAnimMixin:OnFinished()
    self:GetParent().PulseGlow:Hide();
end


CharacterSelectListGroupHeaderMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function CharacterSelectListGroupHeaderMixin:OnLoad()
	local x, y = 1, -1;
	self:SetDisplacedRegions(x, y, self.Icon, self.Text);
end

function CharacterSelectListGroupHeaderMixin:OnEnter()
	ButtonStateBehaviorMixin.OnEnter(self);

	self.Highlight:Show();
end

function CharacterSelectListGroupHeaderMixin:OnLeave()
	ButtonStateBehaviorMixin.OnLeave(self);

	self.Highlight:Hide();
end

function CharacterSelectListGroupHeaderMixin:OnClick()
	local parentGroup = self:GetParent();
	local parentGroupElementData = parentGroup:GetElementData();
	parentGroupElementData.collapsed = not parentGroupElementData.collapsed;

	parentGroup:OnExpandedChanged();
end

function CharacterSelectListGroupHeaderMixin:OnButtonStateChanged()
	local parentGroupElementData = self:GetParent():GetElementData();
	local atlas;
	local textColor;

	if not self:IsEnabled() then
		if parentGroupElementData.collapsed then
			atlas = "glues-characterSelect-icon-plus-disabled";
		else
			atlas = "glues-characterSelect-icon-minus-disabled";
		end
		textColor = DISABLED_FONT_COLOR;
	elseif self:IsDown() then
		if parentGroupElementData.collapsed then
			atlas = "glues-characterSelect-icon-plus-pressed";
		else
			atlas = "glues-characterSelect-icon-minus-pressed";
		end
		textColor = HIGHLIGHT_FONT_COLOR;
	elseif self:IsOver() then
		if parentGroupElementData.collapsed then
			atlas = "glues-characterselect-icon-plus-hover";
		else
			atlas = "glues-characterselect-icon-minus-hover";
		end
		textColor = HIGHLIGHT_FONT_COLOR;
	else
		if parentGroupElementData.collapsed then
			atlas = "glues-characterSelect-icon-plus";
		else
			atlas = "glues-characterSelect-icon-minus";
		end
		textColor = HIGHLIGHT_FONT_COLOR;
	end

	self.Text:SetTextColor(textColor:GetRGBA());
	self.Icon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end


CharacterSelectListCharacterMixin = {};

function CharacterSelectListCharacterMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
end

-- We echo the various input down to our child frame, to prevent it from eating the input and stopping drag behavior.
-- Note this method is overwridden by CharacterServicesCharacterSelectorMixin at times.
function CharacterSelectListCharacterMixin:OnEnter()
	self.InnerContent:OnEnter(self:IsSelected());
	self:SetTooltipAndShow();
	CharSelectAccountUpgradeButtonPointerFrame:Show();
	CharSelectAccountUpgradeButtonGlow:Show();
end

-- Note this method is overwridden by CharacterServicesCharacterSelectorMixin at times.
function CharacterSelectListCharacterMixin:OnLeave()
	self.InnerContent:OnLeave(self:IsSelected());
	CharSelectAccountUpgradeButtonPointerFrame:Hide();
	CharSelectAccountUpgradeButtonGlow:Hide();
	GlueTooltip:Hide();
end

-- Note this method is overwridden by CharacterServicesCharacterSelectorMixin at times.
function CharacterSelectListCharacterMixin:OnClick()
	if self:CanSelect() and not self:IsSelected() then
		CharacterSelectUtil.SelectAtIndex(self:GetCharacterIndex());
	end
end

function CharacterSelectListCharacterMixin:OnDoubleClick()
	if self:CanSelect() then
		if not self:IsSelected() then
			CharacterSelectUtil.SelectAtIndex(self:GetCharacterIndex());
		end

		if CharacterSelect_AllowedToEnterWorld() then
			CharacterSelect_EnterWorld();
		end
	end
end

function CharacterSelectListCharacterMixin:SetData(elementData, inGroup)
	self.characterID = elementData.characterID;
	self.characterInfo = CharacterSelectUtil.GetCharacterInfoTable(self.characterID);

	-- This is a hack, something about the PCT tokenization changes are causing character selection to update before any characters are in the list.
	-- Adding this as a workaround and a point at which to help diagnose the failure.
	self.guid = nil;
	if not self.characterInfo then
		return;
	end
	self.guid = self.characterInfo.guid;

	self.isVeteranLocked = false;
	self.isLockedByExpansion = self.characterInfo.isLockedByExpansion;
	self.isAccountLocked = CharacterSelectUtil.IsAccountLocked();

	if inGroup then
		self.InnerContent.Backdrop:SetAtlas("glues-characterSelect-card-camp", TextureKitConstants.UseAtlasSize);
		self.InnerContent.Highlight:SetAtlas("glues-characterselect-card-camp-hover", TextureKitConstants.UseAtlasSize);
	end

	self.InnerContent:SetData(self.characterInfo);

	self:UpdateVASState();

	local filteringByBoostable = CharacterUpgradeCharacterSelectBlock_IsFilteringByBoostable();
	local arrowShown = self:CanSelect() and filteringByBoostable and CharacterUpgradeCharacterSelectBlock_IsCharacterBoostable(self.characterID);
	self:SetArrowButtonShown(arrowShown);

	self:UpdateSelectedState();

	-- Makes sure any overrides from VAS updates via CharacterServicesCharacterSelectorMixin are properly reset.
	self:SetScript("OnClick", CharacterSelectListCharacterMixin.OnClick);
	self:SetScript("OnDoubleClick", CharacterSelectListCharacterMixin.OnDoubleClick);
	self:SetScript("OnEnter", CharacterSelectListCharacterMixin.OnEnter);
	self:SetScript("OnLeave", CharacterSelectListCharacterMixin.OnLeave);
end

function CharacterSelectListCharacterMixin:GetCharacterID()
	return self.characterID;
end

function CharacterSelectListCharacterMixin:GetCharacterInfo()
	return self.characterInfo;
end

function CharacterSelectListCharacterMixin:UpdateVASState()
	local paidServiceButton = self.PaidService;
	local restoreCharacterServiceFrame = self.RestoreCharacterServiceFrame;
	local notificationButton = self.InnerContent.NotificationButton;

	local tooltip1 = nil;
	local tooltip2 = nil;
	notificationButton:SetHasInProgress(false, tooltip1, tooltip2);
	restoreCharacterServiceFrame:Hide();

	if CharacterServicesFlow_IsShowing() then
		paidServiceButton:Hide();
		return;
	end

	local guid = self.guid;
	local characterInfo = self:GetCharacterInfo();
	local vasServiceState, vasServiceErrors, vasProductInfo = CharacterSelectListUtil.GetVASInfoForGUID(guid);
	local modifyServiceType = true;
	local serviceType, disableService;
	if vasServiceState == Enum.VasPurchaseProgress.PaymentPending then
		tooltip1 = CHARACTER_UPGRADE_PROCESSING;
		tooltip2 = CHARACTER_STATE_ORDER_PROCESSING;
		notificationButton:SetHasInProgress(true, tooltip1, tooltip2);
	elseif vasServiceState == Enum.VasPurchaseProgress.ApplyingLicense and #vasServiceErrors > 0 then
        local tooltip, desc;
        local info = StoreFrame_GetVASErrorMessage(guid, vasServiceErrors);
        if info then
            if info.other then
                tooltip = VAS_ERROR_ERROR_HAS_OCCURRED;
            else
                tooltip = VAS_ERROR_ADDRESS_THESE_ISSUES;
            end
            desc = info.desc;
        else
            tooltip = VAS_ERROR_ERROR_HAS_OCCURRED;
            desc = BLIZZARD_STORE_VAS_ERROR_OTHER;
        end

		tooltip1 = "|cffffd200" .. tooltip .. "|r";
		tooltip2 = "|cffff2020" .. desc .. "|r";
		notificationButton:SetHasInProgress(true, tooltip1, tooltip2);
    elseif characterInfo and characterInfo.boostInProgress then
		tooltip1 = CHARACTER_UPGRADE_PROCESSING;
		tooltip2 = CHARACTER_SERVICES_PLEASE_WAIT;
		notificationButton:SetHasInProgress(true, tooltip1, tooltip2);
	elseif vasServiceState == Enum.VasPurchaseProgress.WaitingOnQueue then
		tooltip2 = CHARACTER_SERVICES_PLEASE_WAIT;
		if vasProductInfo then
			tooltip2 = VAS_SERVICE_PROCESSING:format(vasProductInfo.sharedData.name);
			local queueTime = CharacterSelectUtil.GetVASQueueTime(guid);
			if queueTime and queueTime > 0 then
				tooltip2 = tooltip2 .. "|n" .. VAS_PROCESSING_ESTIMATED_TIME:format(SecondsToTime(queueTime * 60, true, false, 2, true));
			end
		end

		tooltip1 = CHARACTER_UPGRADE_PROCESSING;
		notificationButton:SetHasInProgress(true, tooltip1, tooltip2);
	elseif vasServiceState == Enum.VasPurchaseProgress.ProcessingFactionChange then
		tooltip1 = CHARACTER_UPGRADE_PROCESSING;
		tooltip2 = CHARACTER_SERVICES_PLEASE_WAIT;
		notificationButton:SetHasInProgress(true, tooltip1, tooltip2);
	elseif guid and IsCharacterVASLocked(guid) then
		tooltip1 = CHARACTER_UPGRADE_PROCESSING;
		tooltip2 = CHARACTER_SERVICES_PLEASE_WAIT;
		notificationButton:SetHasInProgress(true, tooltip1, tooltip2);
	elseif CharacterSelect.undeleting then
		if self:IsSelected() then
			restoreCharacterServiceFrame:Show();
		end
	elseif characterInfo and characterInfo.hasFactionChange then
		serviceType = PAID_FACTION_CHANGE;
		paidServiceButton.GoldBorder:Show();
		paidServiceButton.VASIcon:SetTexture("Interface\\Icons\\VAS_FactionChange");
		paidServiceButton.VASIcon:Show();
		paidServiceButton.Texture:Hide();
		-- Paid faction change disabled has been deprecated.
		-- disableService = PFCDisabled;
		paidServiceButton.tooltip = PAID_FACTION_CHANGE_TOOLTIP;
		paidServiceButton.disabledTooltip = PAID_FACTION_CHANGE_DISABLED_TOOLTIP;
	elseif characterInfo and characterInfo.hasRaceChange then
		serviceType = PAID_RACE_CHANGE;
		paidServiceButton.GoldBorder:Show();
		paidServiceButton.VASIcon:SetTexture("Interface\\Icons\\VAS_RaceChange");
		paidServiceButton.VASIcon:Show();
		paidServiceButton.Texture:Hide();
		-- Paid race change disabled has been deprecated.
		-- disableService = PRCDisabled;
		paidServiceButton.tooltip = PAID_RACE_CHANGE_TOOLTIP;
		paidServiceButton.disabledTooltip = PAID_RACE_CHANGE_DISABLED_TOOLTIP;
	elseif characterInfo and characterInfo.hasCustomize then
		serviceType = PAID_CHARACTER_CUSTOMIZATION;
		paidServiceButton.GoldBorder:Show();
		paidServiceButton.VASIcon:SetTexture("Interface\\Icons\\VAS_AppearanceChange");
		paidServiceButton.VASIcon:Show();
		paidServiceButton.Texture:Hide();
		disableService = characterInfo.customizeDisabled;
		paidServiceButton.tooltip = PAID_CHARACTER_CUSTOMIZE_TOOLTIP;
		paidServiceButton.disabledTooltip = PAID_CHARACTER_CUSTOMIZE_DISABLED_TOOLTIP;
	end

	if modifyServiceType then
		if serviceType then
			paidServiceButton:Show();
			paidServiceButton.serviceType = serviceType;
			if disableService then
				paidServiceButton:Disable();
				paidServiceButton.Texture:SetDesaturated(true);
				paidServiceButton.GoldBorder:SetDesaturated(true);
				paidServiceButton.VASIcon:SetDesaturated(true);
			elseif not paidServiceButton:IsEnabled() then
				paidServiceButton.Texture:SetDesaturated(false);
				paidServiceButton.GoldBorder:SetDesaturated(false);
				paidServiceButton.VASIcon:SetDesaturated(false);
				paidServiceButton:Enable();
			end
		else
			paidServiceButton:Hide();
		end
	end
end

function CharacterSelectListCharacterMixin:SetArrowButtonShown(shown)
	self.Arrow:SetShown(shown);
end

function CharacterSelectListCharacterMixin:UpdateSelectedState()
	self:SetSelectedState(self:IsSelected());
end

function CharacterSelectListCharacterMixin:SetTooltipAndShow()
	GlueTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -12, 95);
	if self:GetCharacterIsVeteranLocked() and CharSelectAccountUpgradeButton:IsEnabled() then
		GlueTooltip:SetText(CHARSELECT_CHAR_LIMITED_TOOLTIP, nil, nil, nil, nil, true);
	else
		CharacterSelectUtil.SetTooltipForCharacterInfo(self.characterInfo, self:GetCharacterID());
	end
	GlueTooltip:Show();
end

function CharacterSelectListCharacterMixin:IsSelected()
	local index = self:GetCharacterIndex();
	return index == CharacterSelect.selectedIndex;
end

function CharacterSelectListCharacterMixin:SetSelectedState(isSelected)
	self.InnerContent.Selected:SetShown(isSelected);

	if not self.characterInfo then
		return;
	end

	local isIconAssigned = self.characterInfo.faction ~= "Neutral";
	if isIconAssigned then
		self.InnerContent.FactionEmblemSelected:SetShown(isSelected);
		self.InnerContent.FactionEmblem:SetShown(not isSelected);
	end
end

function CharacterSelectListCharacterMixin:CanSelect()
	return self.InnerContent.isEnabled;
end

function CharacterSelectListCharacterMixin:MoveCharacter(offset)
	local index = self:GetCharacterIndex();
	CharacterSelectListUtil.ChangeCharacterOrder(index, index + offset);
end

function CharacterSelectListCharacterMixin:SetDropState(isShown)
	self.Drop:SetShown(isShown);
end

function CharacterSelectListCharacterMixin:GetCharacterIndex()
	return CharacterSelectListUtil.GetIndexFromCharID(self.characterID);
end

function CharacterSelectListCharacterMixin:GetCharacterGUID()
	return self.guid;
end

function CharacterSelectListCharacterMixin:GetCharacterIsVeteranLocked()
	return self.isVeteranLocked;
end

-- Called when character models or other UI are being hovered, to mirror that state on this UI.
function CharacterSelectListCharacterMixin:UpdateHighlightUI(isHighlight)
	self.InnerContent:UpdateHighlightUI(isHighlight, self:IsSelected());
end

function CharacterSelectListCharacterMixin:AnimateGlow()
    self:CleanupAnimations();
    self.GlowAnim:Restart();
end

function CharacterSelectListCharacterMixin:AnimateGlowMove()
    self:CleanupAnimations();
    self.GlowMoveAnim:Restart();
end

function CharacterSelectListCharacterMixin:AnimatePulse()
	self:CleanupAnimations();
    self.PulseAnim:Restart();
end

function CharacterSelectListCharacterMixin:CleanupAnimations()
    self.GlowAnim:Stop();
	self.GlowMoveAnim:Stop();
	self.PulseAnim:Stop();
    self.GlowAnim:OnFinished();
	self.GlowMoveAnim:OnFinished();
	self.PulseAnim:OnFinished();
end


CharacterSelectListCharacterGlowMoveAnimMixin = {};

function CharacterSelectListCharacterGlowMoveAnimMixin:OnPlay()
    self:GetParent().InnerContent.Glow:Show();
end

function CharacterSelectListCharacterGlowMoveAnimMixin:OnFinished()
    self:GetParent().InnerContent.Glow:Hide();
end


CharacterSelectListCharacterGlowAnimMixin = {};

function CharacterSelectListCharacterGlowAnimMixin:OnPlay()
    self:GetParent().InnerContent.Glow:Show();
end

function CharacterSelectListCharacterGlowAnimMixin:OnFinished()
    self:GetParent().InnerContent.Glow:Hide();
end


CharacterSelectListCharacterPulseAnimMixin = {};

function CharacterSelectListCharacterPulseAnimMixin:OnPlay()
	local innerContent = self:GetParent().InnerContent;
	innerContent.PulseGlow:Show();
    innerContent.PulseGlowIcon:Show();
    innerContent.PulseSpread1:Show();
    innerContent.PulseSpread2:Show();
    innerContent.BackdropEmpty:Show();
end

function CharacterSelectListCharacterPulseAnimMixin:OnFinished()
	local innerContent = self:GetParent().InnerContent;
	innerContent.PulseGlow:Hide();
    innerContent.PulseGlowIcon:Hide();
    innerContent.PulseSpread1:Hide();
    innerContent.PulseSpread2:Hide();
    innerContent.BackdropEmpty:Hide();
end


CharacterSelectListCharacterInnerContentMixin = {};

function CharacterSelectListCharacterInnerContentMixin:OnEnter(isSelected)
	local isHighlight = true;
	self:UpdateHighlightUI(isHighlight, isSelected);

	if isSelected then
		self.FactionEmblemSelected:Hide();
		self:ShowMoveButtons();
	end

	-- Update character model as needed.
	if self.characterInfo then
		MapSceneCharacterHighlightStart(self.characterInfo.guid);
	end
end

function CharacterSelectListCharacterInnerContentMixin:OnLeave(isSelected)
	-- Not calling UpdateHighlightUI as this specific case is more complex, needing to take move button states into account.
	local isMouseOverMoveButton = self.UpButton:IsMouseOver() or self.DownButton:IsMouseOver();
	if isSelected then
		if not isMouseOverMoveButton then
			self.SelectedHighlight:Hide();
			self.FactionEmblemSelected:Show();
		end
	else
		self.Highlight:Hide();
		self.FactionEmblemHighlight:Hide();
	end

	if not isMouseOverMoveButton then
		self.UpButton:Hide();
		self.DownButton:Hide();

		-- Update character model as needed.
		if self.characterInfo then
			MapSceneCharacterHighlightEnd(self.characterInfo.guid);
		end
	end
end

function CharacterSelectListCharacterInnerContentMixin:SetData(characterInfo)
	self.characterInfo = characterInfo;

	self.uncoloredClassName = nil;
	self.coloredClassName = nil;

	self.UpButton:Hide();
	self.DownButton:Hide();

	self.Highlight:Hide();
	self.SelectedHighlight:Hide();
	self.FactionEmblemHighlight:Hide();

	if not self.characterInfo then
		return;
	end

	local guid = nil;
	local characterSelectButton = nil;
	local tooltip1 = nil;
	local tooltip2 = nil;
	local tooltipTextColor = NORMAL_FONT_COLOR;
	self.NotificationButton:SetHasLock(false, guid, characterSelectButton, tooltip1, tooltip2, tooltipTextColor);

	self:UpdateLastLogin(self.characterInfo.lastLoginBuild);
	self:UpdateCharacterDisplayInfo();
	self:UpdateFactionEmblem();

	local filteringByBoostable = CharacterUpgradeCharacterSelectBlock_IsFilteringByBoostable();
	local enabledByFilter = not filteringByBoostable or CharacterUpgradeCharacterSelectBlock_IsCharacterBoostable(self:GetParent():GetCharacterID());
	self:SetEnabledState(enabledByFilter);
end

function CharacterSelectListCharacterInnerContentMixin:UpdateLastLogin(lastLoginBuild)
	local showlastLoginBuild = IsGMClient() and not HideGMOnly();

	local lastVersionText = self.Text.LastVersion;
	lastVersionText:SetShown(showlastLoginBuild);

	-- If we're not showing the build, don't bother doing nice formatting.
	if showlastLoginBuild then
		local currentVersion = select(4, GetBuildInfo());

		-- Set the Color based on the build being old / new
		if lastLoginBuild < currentVersion then
			lastVersionText:SetTextColor(YELLOW_FONT_COLOR:GetRGBA()) -- Earlier Build
		elseif lastLoginBuild > currentVersion then
			lastVersionText:SetTextColor(RED_FONT_COLOR:GetRGBA()) -- Later Build
		else
			lastVersionText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGBA()) -- Current Build
		end

		local function GenerateBuildString(buildNumber)
			if buildNumber == 0 then
				return "No Login";
			end

			-- Generate Build String from the Integer.
			local versionParse = { tostring(buildNumber):match("(%d+)(%d%d)(%d%d)$") };

			if #versionParse > 0 then
				for k, v in ipairs(versionParse) do
					versionParse[k] = tonumber(v);
				end

				return table.concat(versionParse, ".");
			else
				return "OLD";
			end
		end

		lastVersionText:SetText(GenerateBuildString(lastLoginBuild));
	end
end

function CharacterSelectListCharacterInnerContentMixin:UpdateCharacterDisplayInfo()
	local mailSenders = nil;
	self.NotificationButton:SetHasMail(false, mailSenders);

	if not self.characterInfo then
		return;
	end

	local characterInfo = self.characterInfo;

	local name = characterInfo.name;
	local class = characterInfo.className;
	local level = characterInfo.experienceLevel;
	local guid = characterInfo.guid;
	local zone = characterInfo.areaName or "";
	local areCharServicesShown = CharSelectServicesFlowFrame:IsShown();

	local nameText = self.Text.Name;
	local infoText = self.Text.Info;
	local statusText = self.Text.Status;

	if not areCharServicesShown then
		nameText:SetTextColor(1, .82, 0, 1);
	end

	local timerunningSeasonID = guid and GetCharacterTimerunningSeasonID(guid);
	local formattedName = CharacterSelectUtil.FormatCharacterName(name, timerunningSeasonID);
    if ( CharacterSelect.undeleting ) then
        nameText:SetFormattedText(CHARACTER_SELECT_NAME_DELETED, formattedName);
    elseif ( characterInfo.isLocked ) then
        nameText:SetText(formattedName..CHARSELECT_CHAR_INACTIVE_CHAR);
	else
        nameText:SetText(formattedName);
    end

	local vasServiceState, vasServiceErrors, vasProductInfo = CharacterSelectListUtil.GetVASInfoForGUID(guid);
	if self.isAccountLocked then
		self:SetupPadlock();
		statusText:SetFontObject("GlueFontDisableLarge");
		statusText:SetText(zone);
		infoText:SetText(CHARACTER_SELECT_INFO:format(level, class));
	elseif (vasServiceState == Enum.VasPurchaseProgress.ApplyingLicense) and (#vasServiceErrors > 0) then
		infoText:SetText("|cffff2020" .. VAS_ERROR_ERROR_HAS_OCCURRED .. "|r");
		if vasProductInfo and vasProductInfo.sharedData.name then
			statusText:SetText("|cffff2020" .. vasProductInfo.sharedData.name .. "|r");
		else
			statusText:SetText("");
		end
	elseif (vasServiceState == Enum.VasPurchaseProgress.WaitingOnQueue) and not CharacterSelectUtil.GetVASQueueTime(guid) then
		C_StoreGlue.RequestCharacterQueueTime(guid);
	elseif vasServiceState == Enum.VasPurchaseProgress.ProcessingFactionChange then
		infoText:SetText(CHARACTER_UPGRADE_PROCESSING);
		statusText:SetFontObject("GlueFontHighlightLarge");
		statusText:SetText(FACTION_CHANGE_CHARACTER_LIST_LABEL);
	elseif characterInfo.boostInProgress then
		infoText:SetText(CHARACTER_UPGRADE_PROCESSING);
		statusText:SetFontObject("GlueFontHighlightLarge");
		statusText:SetText(CHARACTER_UPGRADE_CHARACTER_LIST_LABEL);
	else
		if characterInfo.isLocked then
			self.isVeteranLocked = true;
		end

		statusText:SetFontObject("GlueFontDisableLarge");

		if characterInfo.isExpansionTrialCharacter then
			if IsExpansionTrial() then
				if characterInfo.isTrialBoostCompleted then
					statusText:SetText(CHARACTER_SELECT_INFO_EXPANSION_TRIAL_BOOST_BUY_EXPANSION);
				else
					statusText:SetText(nil);
				end
			elseif CanUpgradeExpansion() then
				statusText:SetText(CHARACTER_SELECT_INFO_EXPANSION_TRIAL_BOOST_BUY_EXPANSION);
			else
				statusText:SetText(CHARACTER_SELECT_INFO_TRIAL_BOOST_APPLY_BOOST_TOKEN);
			end

			if characterInfo.isTrialBoostCompleted or not IsExpansionTrial() then
				infoText:SetText(CHARACTER_SELECT_INFO_EXPANSION_TRIAL_BOOST_LOCKED);
				self:SetupPadlock();

				if not areCharServicesShown then
					nameText:SetTextColor(.5, .5, .5, 1);
				end
			else
				infoText:SetText(CHARACTER_SELECT_INFO_EXPANSION_TRIAL_PLAYABLE);
			end
		elseif characterInfo.isTrialBoost then
			statusText:SetText(CHARACTER_SELECT_INFO_TRIAL_BOOST_APPLY_BOOST_TOKEN);

			if characterInfo.isTrialBoostCompleted then
				infoText:SetText(CHARACTER_SELECT_INFO_TRIAL_BOOST_LOCKED);
				self:SetupPadlock();

				if not areCharServicesShown then
					nameText:SetTextColor(.5, .5, .5, 1);
				end
			else
				infoText:SetText(CHARACTER_SELECT_INFO_TRIAL_BOOST_PLAYABLE);
			end
		else
			local color = CreateColor(GetClassColor(characterInfo.classFilename));
			local coloredClassName = color:WrapTextInColorCode(class);
			if characterInfo.isGhost then
				self.coloredClassName = CHARACTER_SELECT_INFO_GHOST:format(level, coloredClassName);
				self.uncoloredClassName = CHARACTER_SELECT_INFO_GHOST:format(level, class);
			else
				self.coloredClassName = CHARACTER_SELECT_INFO:format(level, coloredClassName);
				self.uncoloredClassName = CHARACTER_SELECT_INFO:format(level, class);
			end
			infoText:SetText(self.coloredClassName);

			if characterInfo.isLockedByExpansion then
				statusText:SetText(CHARACTER_SELECT_INFO_EXPANSION_TRIAL_BOOST_BUY_EXPANSION);
			else
				if areCharServicesShown and CharacterServicesMaster.flow ~= RPEUpgradeFlow then
					statusText:SetFontObject("GlueFontHighlightLarge");
					statusText:SetText(characterInfo.realmName);
				elseif IsRPEBoostEligible(self:GetParent():GetCharacterID()) then
					statusText:SetFontObject("GlueFontHighlightLarge");
					statusText:SetText(RPE_GEAR_UPDATE);
				else
					statusText:SetFontObject("GlueFontDisableLarge");
					statusText:SetText(zone);
				end
			end

			if characterInfo.isLockedByExpansion or characterInfo.isRevokedCharacterUpgrade then
				self:SetupPadlock();
			end

			mailSenders = characterInfo.mailSenders;
			local showMailNotification = mailSenders and #mailSenders >= 1;
			self.NotificationButton:SetHasMail(showMailNotification, mailSenders);
		end
	end
end

function CharacterSelectListCharacterInnerContentMixin:SetupPadlock()
	if not self.characterInfo then
		return;
	end

	local characterInfo = self.characterInfo;
	local tooltipTextColor = NORMAL_FONT_COLOR;
	local tooltip1 = nil;
	local tooltip2 = nil;

	if CharacterSelectUtil.IsAccountLocked() then
		tooltip2 = CHARACTER_SELECT_ACCOUNT_LOCKED;
		tooltipTextColor = RED_FONT_COLOR;
	elseif characterInfo.isExpansionTrialCharacter then
		if IsExpansionTrial() or CanUpgradeExpansion() then
			-- Player has to upgrade to unlock this character
			tooltip1 = CHARACTER_SELECT_INFO_EXPANSION_TRIAL_BOOST_LOCKED_TOOLTIP_TITLE;
			tooltip2 = CHARACTER_SELECT_INFO_EXPANSION_TRIAL_BOOST_LOCKED_TOOLTIP_TEXT;
		else
			-- Player just needs to boost to get this character
			tooltip1 = CHARACTER_SELECT_INFO_TRIAL_BOOST_LOCKED_TOOLTIP_TITLE;
			tooltip2 = CHARACTER_SELECT_INFO_TRIAL_BOOST_LOCKED_TOOLTIP_TEXT;
		end
	elseif characterInfo.isTrialBoost and characterInfo.isTrialBoostCompleted then
		tooltip1 = CHARACTER_SELECT_INFO_TRIAL_BOOST_LOCKED_TOOLTIP_TITLE;
		tooltip2 = CHARACTER_SELECT_INFO_TRIAL_BOOST_LOCKED_TOOLTIP_TEXT;
	elseif characterInfo.isRevokedCharacterUpgrade then
		tooltip1 = CHARACTER_SELECT_REVOKED_BOOST_TOKEN_LOCKED_TOOLTIP_TITLE;
		tooltip2 = CHARACTER_SELECT_REVOKED_BOOST_TOKEN_LOCKED_TOOLTIP_TEXT;
	elseif characterInfo.isLockedByExpansion then
		tooltip1 = CHARACTER_SELECT_INFO_EXPANSION_TRIAL_BOOST_LOCKED_TOOLTIP_TITLE;
		tooltip2 = CHARACTER_SELECT_INFO_EXPANSION_TRIAL_BOOST_BUY_EXPANSION;
	else
		GMError("Invalid lock type");
	end

	local guid = characterInfo.guid;
	local characterSelectButton = self:GetParent();
	self.NotificationButton:SetHasLock(true, guid, characterSelectButton, tooltip1, tooltip2, tooltipTextColor);
end

function CharacterSelectListCharacterInnerContentMixin:UpdateFactionEmblem()
	local factionEmblem = self.FactionEmblem;
	local factionEmblemHighlight = self.FactionEmblemHighlight;
	local factionEmblemSelected = self.FactionEmblemSelected;

	if not self.characterInfo then
		factionEmblem:Hide();
		factionEmblemSelected:Hide();
		return;
	end

	local faction = self.characterInfo.faction;
	local isIconAssigned = faction ~= "Neutral";
	if isIconAssigned then
		if faction == "Alliance" then
			factionEmblem:SetAtlas("glues-characterSelect-icon-faction-alliance", TextureKitConstants.UseAtlasSize);
			factionEmblemHighlight:SetAtlas("glues-characterSelect-icon-faction-alliance-hover", TextureKitConstants.UseAtlasSize);
			factionEmblemSelected:SetAtlas("glues-characterSelect-icon-faction-alliance-selected", TextureKitConstants.UseAtlasSize);
		else
			factionEmblem:SetAtlas("glues-characterselect-icon-faction-horde", TextureKitConstants.UseAtlasSize);
			factionEmblemHighlight:SetAtlas("glues-characterselect-icon-faction-horde-hover", TextureKitConstants.UseAtlasSize);
			factionEmblemSelected:SetAtlas("glues-characterSelect-icon-faction-horde-selected", TextureKitConstants.UseAtlasSize);
		end
	end
	factionEmblem:SetShown(isIconAssigned);
	factionEmblemSelected:SetShown(isIconAssigned);
end

function CharacterSelectListCharacterInnerContentMixin:SetEnabledState(isEnabled)
	local nameText = self.Text.Name;
	local infoText = self.Text.Info;
	local statusText = self.Text.Status;

	if isEnabled then
		nameText:SetTextColor(1, 0.82, 0);
		infoText:SetTextColor(1, 1, 1);
		if self.coloredClassName then
			infoText:SetText(self.coloredClassName);
		end

		if statusText:GetText() == RPE_GEAR_UPDATE then
			statusText:SetTextColor(RPE_FONT_COLOR:GetRGBA());
		else
			statusText:SetTextColor(0.5, 0.5, 0.5);
		end
	else
		nameText:SetTextColor(0.25, 0.25, 0.25);
		if self.uncoloredClassName then
			infoText:SetText(self.uncoloredClassName);
		end
		infoText:SetTextColor(0.25, 0.25, 0.25);
		statusText:SetTextColor(0.25, 0.25, 0.25);
	end

	self.FactionEmblem:SetDesaturated(not isEnabled);
	infoText:SetFixedColor(not isEnabled);

	self.isEnabled = isEnabled;
end

function CharacterSelectListCharacterInnerContentMixin:ShowMoveButtons()
	if CharacterSelect.undeleting or CharacterSelectUtil.IsAccountLocked() then
		return;
	end

	if GetNumCharacters() <= 1 then
		return;
	end

	if not CharacterSelectListUtil.CanReorder() then
		return;
	end

	local upButton = self.UpButton;
	local downButton = self.DownButton;

	upButton:Show();
	downButton:Show();

	local index = self:GetParent():GetCharacterIndex();
	local isFirstButton = index == 1;
	upButton:SetEnabledState(not isFirstButton);

	local last = true;
	local lastCharacterIndex = CharacterSelectListUtil.GetFirstOrLastCharacterIndex(last);
	local lastIndex = math.max(CharacterSelectListUtil.CharacterGroupSlotCount + 1, lastCharacterIndex);
	local isLastButton = index == lastIndex;
	downButton:SetEnabledState(not isLastButton);
end

function CharacterSelectListCharacterInnerContentMixin:SetDragState(isDragging)
	self.Drag:SetShown(isDragging);
	self.Backdrop:SetShown(not isDragging);
	self.Highlight:Hide();
end

-- Called when character models or other UI are being hovered, to mirror that state on this UI.
function CharacterSelectListCharacterInnerContentMixin:UpdateHighlightUI(isHighlight, isSelected)
	self.SelectedHighlight:SetShown(isHighlight and isSelected);
	self.Highlight:SetShown(isHighlight and not isSelected);
	self.FactionEmblemHighlight:SetShown(isHighlight and not isSelected);
end


CharacterSelectListEmptyCharacterMixin = {};

function CharacterSelectListEmptyCharacterMixin:OnEnter()
	self.InnerContent.Highlight:Show();
end

function CharacterSelectListEmptyCharacterMixin:OnLeave()
	self.InnerContent.Highlight:Hide();
end

function CharacterSelectListEmptyCharacterMixin:GetCharacterID()
	return self.characterID;
end

function CharacterSelectListEmptyCharacterMixin:GetCharacterIndex()
	return CharacterSelectListUtil.GetIndexFromCharID(self.characterID);
end

function CharacterSelectListEmptyCharacterMixin:GetCharacterGUID()
	return nil;
end

function CharacterSelectListEmptyCharacterMixin:SetDropState(isShown)
	self.Drop:SetShown(isShown);
end

function CharacterSelectListEmptyCharacterMixin:SetDragState(dragging)
	self.InnerContent.DragGlow:SetShown(dragging);
end

function CharacterSelectListEmptyCharacterMixin:AnimateGlowFade()
	self:CleanupAnimations();
    self.GlowFadeAnim:Restart();
end

function CharacterSelectListEmptyCharacterMixin:CleanupAnimations()
    self.GlowFadeAnim:Stop();
    self.GlowFadeAnim:OnFinished();
end


CharacterSelectListEmptyCharacterGlowFadeAnimMixin = {};

function CharacterSelectListEmptyCharacterGlowFadeAnimMixin:OnPlay()
    self:GetParent().InnerContent.DragGlow:Show();
end

function CharacterSelectListEmptyCharacterGlowFadeAnimMixin:OnFinished()
    self:GetParent().InnerContent.DragGlow:Hide();
end


CharacterSelectListPaidServiceMixin = {};

function CharacterSelectListPaidServiceMixin:OnClick()
	if CharacterSelectUtil.IsAccountLocked() then
		return;
	end

	local characterID = self:GetParent():GetCharacterID();
	local includeEmptySlots = true;
	local numCharacters = GetNumCharacters(includeEmptySlots);
	if characterID <= 0 or (characterID > numCharacters) then
		-- Somehow our character order got borked, scroll to top and get an updated character list.
		CharacterSelectCharacterFrame.ScrollBox:ScrollToBegin();
		CharacterCreateFrame:ClearPaidServiceInfo();

		CharacterSelectListUtil.GetCharacterListUpdate();
		return;
	end

	CharacterCreateFrame:SetPaidServiceInfo(self.serviceType, characterID);

	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
	GlueParent_SetScreen("charcreate");
end

function CharacterSelectListPaidServiceMixin:OnEnter()
	GlueTooltip:SetOwner(self, "ANCHOR_LEFT", 4, -8);
	local text = self:IsEnabled() and self.tooltip or self.disabledTooltip;
	GlueTooltip:SetText(text, 1.0, 1.0, 1.0);
end

function CharacterSelectListPaidServiceMixin:OnLeave()
	GlueTooltip:Hide();
end


CharacterSelectListNotificationButtonMixin = {};

function CharacterSelectListNotificationButtonMixin:OnLoad()
	self.hasNotificationMail = false;
	self.hasNotificationLock = false;
	self.hasNotificationInProgress = false;
end

function CharacterSelectListNotificationButtonMixin:OnEnter()
	self.IconFrame.Icon:SetAtlas(self.formattedIconHover, TextureKitConstants.UseAtlasSize);

	if self.hasNotificationInProgress then
		GlueTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip_AddHighlightLine(GlueTooltip, self.inProgressTooltip1);

		local wrap = true;
		local leftOffset = 1;
		GameTooltip_AddNormalLine(GlueTooltip, self.inProgressTooltip2, wrap, leftOffset);
		GlueTooltip:Show();
	elseif self.hasNotificationLock then
		GlueTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip_SetTitle(GlueTooltip, self.lockTooltip1, nil, false);
		GameTooltip_AddColoredLine(GlueTooltip, self.lockTooltip2, self.lockTooltipTextColor);

		if not self.lockCharacterSelectButton.isAccountLocked then
			local requiresPurchase = self:CanUnlockByExpansionPurchase() or not C_CharacterServices.HasRequiredBoostForUnrevoke();
			if requiresPurchase then
				GameTooltip_AddDisabledLine(GlueTooltip, CHARACTER_SELECT_REVOKED_BOOST_TOKEN_LOCKED_TOOLTIP_HELP_SHOP);
			else
				GameTooltip_AddDisabledLine(GlueTooltip, CHARACTER_SELECT_REVOKED_BOOST_TOKEN_LOCKED_TOOLTIP_HELP_USE_BOOST);
			end
		end

		GlueTooltip:Show();
	elseif self.hasNotificationMail then
		if self.mailSenders and #self.mailSenders >= 1 then
			GlueTooltip:SetOwner(self, "ANCHOR_LEFT");
			FormatUnreadMailTooltip(GlueTooltip, HAVE_MAIL_FROM, self.mailSenders);
			GlueTooltip:Show();
		end
	end
end

function CharacterSelectListNotificationButtonMixin:OnLeave()
	self.IconFrame.Icon:SetAtlas(self.formattedIcon, TextureKitConstants.UseAtlasSize);
	GlueTooltip:Hide();
end

function CharacterSelectListNotificationButtonMixin:OnClick()
	if self.hasNotificationLock and not self.hasNotificationInProgress then
		self:OnClickLock();
	end
end

function CharacterSelectListNotificationButtonMixin:SetHasMail(state, mailSenders)
	self.hasNotificationMail = state;
	self.mailSenders = mailSenders;
	self:UpdateNotificationType();
end

function CharacterSelectListNotificationButtonMixin:SetHasLock(state, guid, characterSelectButton, tooltip1, tooltip2, tooltipTextColor)
	self.hasNotificationLock = state;
	self.lockGuid = guid;
	self.lockCharacterSelectButton = characterSelectButton;
	self.lockTooltip1 = tooltip1;
	self.lockTooltip2 = tooltip2;
	self.lockTooltipTextColor = tooltipTextColor;
	self:UpdateNotificationType();
end

function CharacterSelectListNotificationButtonMixin:SetHasInProgress(state, tooltip1, tooltip2)
	self.hasNotificationInProgress = state;
	self.inProgressTooltip1 = tooltip1;
	self.inProgressTooltip2 = tooltip2;
	self:UpdateNotificationType();
end

function CharacterSelectListNotificationButtonMixin:UpdateNotificationType()
	local currentNotificationType = nil;
	if self.hasNotificationInProgress then
		currentNotificationType = "inProgress";
	elseif self.hasNotificationLock then
		currentNotificationType = "lock";
	elseif self.hasNotificationMail then
		currentNotificationType = "mail";
	end

	self:SetShown(currentNotificationType);
	if currentNotificationType then
		self:UpdateIcon(currentNotificationType);
	end
end

function CharacterSelectListNotificationButtonMixin:UpdateIcon(icon)
	self.formattedIcon = ("glues-characterSelect-icon-notify-%s"):format(icon);
	self.formattedIconHover = ("glues-characterSelect-icon-notify-%s-hover"):format(icon);

	self.IconFrame.Icon:SetAtlas(self.formattedIcon, TextureKitConstants.UseAtlasSize);
end

-- Lock specific logic.
function CharacterSelectListNotificationButtonMixin:OnClickLock()
	local isAccountLocked = self.lockCharacterSelectButton.isAccountLocked;
	if not isAccountLocked and self:CanUnlockByExpansionPurchase() then
		ToggleStoreUI();
		StoreFrame_SetGamesCategory();
		return;
	end

	self.lockCharacterSelectButton:OnClick();

    if isAccountLocked then
        return;
    end

	if GlobalGlueContextMenu_GetOwner() == self then
		GlobalGlueContextMenu_Release();
	else
		local availableBoostTypes = GetAvailableBoostTypesForCharacterByGUID(self.lockGuid);
		if #availableBoostTypes > 1 then
			local glueContextMenu = GlobalGlueContextMenu_Acquire(self);
			glueContextMenu:SetPoint("TOPRIGHT", self, "TOPLEFT", 15, -12);

			for i, boostType in ipairs(availableBoostTypes) do
				local flowData = C_CharacterServices.GetCharacterServiceDisplayData(boostType);
				local function CharacterSelectLockedButtonContextMenuButton_OnClick()
					CharacterUpgradePopup_BeginCharacterUpgradeFlow(flowData, self.lockGuid);
				end

				glueContextMenu:AddButton(CHARACTER_SELECT_PADLOCK_DROP_DOWN_USE_BOOST:format(flowData.flowTitle), CharacterSelectLockedButtonContextMenuButton_OnClick);
			end

			local function CloseContextMenu()
				GlobalGlueContextMenu_Release();
			end

			glueContextMenu:AddButton(CANCEL, CloseContextMenu);

			glueContextMenu:Show();
		else
			self:ShowBoostUnlockDialog();
		end
	end
end

function CharacterSelectListNotificationButtonMixin:CanUnlockByExpansionPurchase()
	return (self.lockCharacterSelectButton.isLockedByExpansion or IsExpansionTrialCharacter(self.lockGuid)) and CanUpgradeExpansion();
end

function CharacterSelectListNotificationButtonMixin:ShowBoostUnlockDialog()
	local serviceInfo = GetServiceCharacterInfo(self.lockGuid);
	if serviceInfo.isTrialBoost and serviceInfo.isTrialBoostCompleted then
		self:CheckApplyBoostToUnlockTrialCharacter(self.lockGuid);
	elseif serviceInfo.isExpansionTrialCharacter then
		self:CheckApplyBoostToUnlockTrialCharacter(self.lockGuid);
	elseif serviceInfo.isRevokedCharacterUpgrade then
		self:CheckApplyBoostToUnrevokeBoost(self.lockGuid);
	end
end

function CharacterSelectListNotificationButtonMixin:CheckApplyBoostToUnlockTrialCharacter(guid)
	local availableBoostTypes = GetAvailableBoostTypesForCharacterByGUID(guid);
	if #availableBoostTypes >= 1 then
		-- We should only ever get in this case if #availableBoostTypes == 1. If there is more than 1 available
		-- boost type then users use a dropdown to choose a boost.
		local flowData = C_CharacterServices.GetCharacterServiceDisplayData(availableBoostTypes[1]);
		CharacterUpgradePopup_BeginCharacterUpgradeFlow(flowData, guid);
	else
		local purchasableBoostType = C_CharacterServices.GetActiveCharacterUpgradeBoostType();
		self:ShowStoreFrameForBoostType(purchasableBoostType, guid, "forClassTrialUnlock");
	end
end

function CharacterSelectListNotificationButtonMixin:CheckApplyBoostToUnrevokeBoost(guid)
	local hasBoost, boostType = C_CharacterServices.HasRequiredBoostForUnrevoke();
	if hasBoost then
		local flowData = C_CharacterServices.GetCharacterServiceDisplayData(boostType);
		CharacterUpgradePopup_BeginCharacterUpgradeFlow(flowData, guid);
	else
		local purchasableBoostType = C_CharacterServices.GetActiveCharacterUpgradeBoostType();
		self:ShowStoreFrameForBoostType(purchasableBoostType, guid, "forUnrevokeBoost");
	end
end

function CharacterSelectListNotificationButtonMixin:ShowStoreFrameForBoostType(boostType, guid, reason)
	if not StoreFrame_IsShown or not StoreFrame_IsShown() then
		ToggleStoreUI();
	end

	StoreFrame_SelectBoost(boostType, reason, guid);
end


RestoreCharacterServiceButtonMixin = {};

function RestoreCharacterServiceButtonMixin:OnClick()
	if CharacterSelectUtil.IsAccountLocked() then
		return;
	end

	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);

	local characterID = self:GetParent():GetParent():GetCharacterID();
	local guid = GetCharacterGUID(characterID);
	CharacterSelect.pendingUndeleteGuid = guid;
	local timeStr = SecondsToTime(CHARACTER_UNDELETE_COOLDOWN, false, true, 1, false);
	GlueDialog_Show("UNDELETE_CONFIRM", UNDELETE_CONFIRMATION:format(timeStr));
end

function RestoreCharacterServiceButtonMixin:OnEnter()
	GlueTooltip:SetOwner(self, "ANCHOR_LEFT", 4, -8);
	GlueTooltip:SetText(UNDELETE_SERVICE_TOOLTIP, 1.0, 1.0, 1.0);
end

function RestoreCharacterServiceButtonMixin:OnLeave()
	GlueTooltip:Hide();
end