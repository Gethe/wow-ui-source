CharacterSelectListMoveButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function CharacterSelectListMoveButtonMixin:OnLoad()
	ButtonStateBehaviorMixin.OnLoad(self);

	local x, y = 1, -1;
	self:SetDisplacedRegions(x, y, self.Arrow);
end

-- Make sure to reset the state of things when the buttons are hidden.  Fixes cases where you are pressed,
-- but move the mouse off the character, which hides the arrow buttons and could  persist the wrong state.
function CharacterSelectListMoveButtonMixin:OnHide()
	ButtonStateBehaviorMixin.OnDisable(self);
end

function CharacterSelectListMoveButtonMixin:OnEnter()
	ButtonStateBehaviorMixin.OnEnter(self);

	if self:IsEnabled() then
		self.Highlight:Show();
	end
end

function CharacterSelectListMoveButtonMixin:OnLeave()
	ButtonStateBehaviorMixin.OnLeave(self);

	if self:IsEnabled() then
		self.Highlight:Hide();
	end

	-- Ensure the parent state resets if needed (if mouse moved quickly off of this button AND the parent)
	local isSelected = true;
	self:GetParent():OnLeave(isSelected);
end

function CharacterSelectListMoveButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:GetParent():GetParent():MoveCharacter(self.moveOffset);
end

function CharacterSelectListMoveButtonMixin:OnButtonStateChanged()
	local atlas;
	if self:IsDown() then
		atlas = self.arrowPressed;
	elseif self:IsOver() then
		atlas = self.arrowHighlight;
	else
		atlas = self.arrowNormal;
	end

	self.Arrow:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

function CharacterSelectListMoveButtonMixin:SetEnabledState(enabled)
	self:SetEnabled(enabled);
	self.Arrow:SetShown(enabled);
end


CharacterSelectLockedButtonMixin = {};

function CharacterSelectLockedButtonMixin:OnEnter()
    GlueTooltip:SetOwner(self.TooltipAnchor, "ANCHOR_LEFT", 0, 0);
	GameTooltip_SetTitle(GlueTooltip, self.tooltipTitle, nil, false);
    GameTooltip_AddColoredLine(GlueTooltip, self.tooltipText, self.tooltipTextColor);

	if not self.characterSelectButton.isAccountLocked then
		local requiresPurchase = self:CanUnlockByExpansionPurchase() or not C_CharacterServices.HasRequiredBoostForUnrevoke();
		if requiresPurchase then
			GameTooltip_AddDisabledLine(GlueTooltip, CHARACTER_SELECT_REVOKED_BOOST_TOKEN_LOCKED_TOOLTIP_HELP_SHOP);
		else
			GameTooltip_AddDisabledLine(GlueTooltip, CHARACTER_SELECT_REVOKED_BOOST_TOKEN_LOCKED_TOOLTIP_HELP_USE_BOOST);
		end
	end

	GlueTooltip:Show();
end

function CharacterSelectLockedButtonMixin:OnLeave()
    GlueTooltip:Hide();
end

function CharacterSelectLockedButtonMixin:OnClick()
    local isAccountLocked = self.characterSelectButton.isAccountLocked;
	if not isAccountLocked and self:CanUnlockByExpansionPurchase() then
		ToggleStoreUI();
		StoreFrame_SetGamesCategory();
		return;
	end

	self.characterSelectButton:OnClick();

    if isAccountLocked then
        return;
    end

	if GlobalGlueContextMenu_GetOwner() == self then
		GlobalGlueContextMenu_Release();
	else
		local availableBoostTypes = GetAvailableBoostTypesForCharacterByGUID(self.guid);
		if #availableBoostTypes > 1 then
			local glueContextMenu = GlobalGlueContextMenu_Acquire(self);
			glueContextMenu:SetPoint("TOPRIGHT", self, "TOPLEFT", 15, -12);

			for i, boostType in ipairs(availableBoostTypes) do
				local flowData = C_CharacterServices.GetCharacterServiceDisplayData(boostType);
				local function CharacterSelectLockedButtonContextMenuButton_OnClick()
					CharacterUpgradePopup_BeginCharacterUpgradeFlow(flowData, self.guid);
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

function CharacterSelectLockedButtonMixin:CanUnlockByExpansionPurchase()
	return (self.characterSelectButton.isLockedByExpansion or IsExpansionTrialCharacter(self.guid)) and CanUpgradeExpansion();
end

function CharacterSelectLockedButtonMixin:ShowBoostUnlockDialog()
	local serviceInfo = GetServiceCharacterInfo(self.guid);
	if serviceInfo.isTrialBoost and serviceInfo.isTrialBoostCompleted then
		self:CheckApplyBoostToUnlockTrialCharacter(self.guid);
	elseif serviceInfo.isExpansionTrialCharacter then
		self:CheckApplyBoostToUnlockTrialCharacter(self.guid);
	elseif serviceInfo.isRevokedCharacterUpgrade then
		self:CheckApplyBoostToUnrevokeBoost(self.guid);
	end
end

function CharacterSelectLockedButtonMixin:ShowStoreFrameForBoostType(boostType, guid, reason)
	if not StoreFrame_IsShown or not StoreFrame_IsShown() then
		ToggleStoreUI();
	end

	StoreFrame_SelectBoost(boostType, reason, guid);
end

function CharacterSelectLockedButtonMixin:CheckApplyBoostToUnlockTrialCharacter(guid)
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

function CharacterSelectLockedButtonMixin:CheckApplyBoostToUnrevokeBoost(guid)
	local hasBoost, boostType = C_CharacterServices.HasRequiredBoostForUnrevoke();
	if hasBoost then
		local flowData = C_CharacterServices.GetCharacterServiceDisplayData(boostType);
		CharacterUpgradePopup_BeginCharacterUpgradeFlow(flowData, guid);
	else
		local purchasableBoostType = C_CharacterServices.GetActiveCharacterUpgradeBoostType();
		self:ShowStoreFrameForBoostType(purchasableBoostType, guid, "forUnrevokeBoost");
	end
end
