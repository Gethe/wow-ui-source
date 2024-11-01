
local AccountStoreCardUpdateCadenceSeconds = 1.0;
local CreatureModelSceneID = 76;
local TransmogModelSceneID = 420;
local DefaultTransmogSetAppearances = {
	195323, -- Chest
	198778, -- Gloves
	198782, -- Legs
	198784, -- Boots
};


AccountStoreBaseCardMixin = {};

local AccountStoreBaseCardEvents = {
	"UI_MODEL_SCENE_INFO_UPDATED",
	"ACCOUNT_STORE_ITEM_INFO_UPDATED",
};

function AccountStoreBaseCardMixin:OnLoad()
	self.BuyButton:SetScript("OnEnter", function()
		if not self.BuyButton:IsEnabled() then
			AccountStoreUtil.ShowDisabledItemInfoTooltip(self.BuyButton, self.itemInfo);
		end
	end);

	self.BuyButton:SetScript("OnLeave", function()
		GetAppropriateTooltip():Hide();
	end);

	self.BuyButton:SetScript("OnClick", function()
		self:SelectCard();
	end);

	self.ModelScene:SetScript("OnMouseWheel", function(modelSceneSelf, ...)
		self:OnMouseWheel(...);
	end);

	self.ModelScene:SetScript("OnEnter", function()
		self:OnEnter();
		self:LockHighlight();
	end);

	self.ModelScene:SetScript("OnLeave", function()
		self:OnLeave();
		self:UnlockHighlight();
	end);
end

function AccountStoreBaseCardMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, AccountStoreBaseCardEvents);

	self:UpdateCardDisplay();
end

function AccountStoreBaseCardMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, AccountStoreBaseCardEvents);
end

function AccountStoreBaseCardMixin:OnEnter()
	local itemInfo = self.itemInfo;
	local description = itemInfo.description;
	if not description then
		return;
	end

	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(tooltip, itemInfo.name);
	GameTooltip_AddNormalLine(tooltip, description);

	local isOwned = (itemInfo.status == Enum.AccountStoreItemStatus.Owned) or (itemInfo.status == Enum.AccountStoreItemStatus.Refundable);
	if not isOwned and itemInfo.nonrefundable then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddErrorLine(tooltip, ACCOUNT_STORE_NONREFUNDABLE_TOOLTIP);
	end

	tooltip:Show();
end

function AccountStoreBaseCardMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

-- Set dynamically.
function AccountStoreBaseCardMixin:OnUpdate(dt)
	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + dt;

	if self.timeSinceUpdate > AccountStoreCardUpdateCadenceSeconds then
		self.timeSinceUpdate = 0;
		self:CheckForItemStateUpdate();
	end
end

function AccountStoreBaseCardMixin:OnMouseWheel(delta)
	CallMethodOnNearestAncestor(self, "OnMouseWheel", delta);
end

function AccountStoreBaseCardMixin:OnEvent(event, ...)
	if event == "UI_MODEL_SCENE_INFO_UPDATED" then
		self:UpdateCardDisplay();
	elseif event == "ACCOUNT_STORE_ITEM_INFO_UPDATED" then
		local itemID = ...;
		if itemID == self.itemInfo.id then
			self:SetItemID(itemID);
		end
	end
end

local RefundTimeFormatter = CreateFromMixins(SecondsFormatterMixin);
RefundTimeFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, SecondsFormatter.Interval.Minutes, true, true);
RefundTimeFormatter:SetStripIntervalWhitespace(true);
RefundTimeFormatter:SetMinInterval(SecondsFormatter.Interval.Minutes);

function AccountStoreBaseCardMixin:SetItemID(itemID)
	self.itemID = itemID;

	local itemInfo = C_AccountStore.GetItemInfo(itemID);
	self.itemInfo = itemInfo;

	if not itemInfo then
		self:Hide();
		return;
	end

	self.Name:SetText(itemInfo.name);

	self:UpdateRefundTime();

	local isOwned = (itemInfo.status == Enum.AccountStoreItemStatus.Owned) or (itemInfo.status == Enum.AccountStoreItemStatus.Refundable);
	self.OwnedCheckmark:SetShown(isOwned);

	local isRefundable = itemInfo.status == Enum.AccountStoreItemStatus.Refundable;
	local canAfford = itemInfo.price <= C_AccountStore.GetCurrencyAvailable(itemInfo.currencyID);
	local enabled = isRefundable or (canAfford and not isOwned);
	self.BuyButton:SetEnabled(enabled);

	if isRefundable then
		self.BuyButton:SetText(PLUNDERSTORE_REFUND_BUTTON_TEXT);
	else
		self.BuyButton:SetText(AccountStoreUtil.FormatCurrencyDisplay(itemInfo.price, itemInfo.currencyID));
	end

	if self:IsShown() then
		self:UpdateCardDisplay();
	end
end

function AccountStoreBaseCardMixin:SelectCard()
	local itemInfo = self.itemInfo;
	local isRefundable = itemInfo.status == Enum.AccountStoreItemStatus.Refundable;
	local confirmationFormat = isRefundable and ACCOUNT_STORE_REFUND_CONFIRMATION_FORMAT or PLUNDERSTORE_PURCHASE_CONFIRMATION_FORMAT;
	local confirmation = confirmationFormat:format(itemInfo.name, AccountStoreUtil.FormatCurrencyDisplay(itemInfo.price, itemInfo.currencyID));

	if StaticPopup_Hide then
		StaticPopup_Hide("GENERIC_CONFIRMATION");

		StaticPopup_ShowGenericConfirmation(confirmation, function ()
			if isRefundable then
				C_AccountStore.RefundItem(itemInfo.id);
			else
				C_AccountStore.BeginPurchase(itemInfo.id);
			end
		end);
	else
		GlueDialog_Show("ACCOUNT_STORE_BEGIN_PURCHASE_OR_REFUND", confirmation, itemInfo);
	end
end

function AccountStoreBaseCardMixin:CheckForItemStateUpdate()
	local refreshedItemInfo = C_AccountStore.GetItemInfo(self.itemID);
	if not refreshedItemInfo then
		return;
	end

	refreshedItemInfo.status = Enum.AccountStoreItemStatus.Refundable;

	if refreshedItemInfo.status ~= self.itemInfo.status then
		self:SetItemID(self.itemID);
	elseif refreshedItemInfo.refundSecondsRemaining ~= self.itemInfo.refundSecondsRemaining then
		self.itemInfo.refundSecondsRemaining = refreshedItemInfo.refundSecondsRemaining;
		self:UpdateRefundTime();
	end
end

function AccountStoreBaseCardMixin:UpdateRefundTime()
	local itemInfo = self.itemInfo;
	local refundable = (itemInfo.status == Enum.AccountStoreItemStatus.Refundable) and itemInfo.refundSecondsRemaining;
	self.RefundText:SetShown(refundable);
	self:SetScript("OnUpdate", refundable and self.OnUpdate or nil);
	if refundable then
		local timeString = RefundTimeFormatter:Format(itemInfo.refundSecondsRemaining);
		self.RefundText:SetText(ACCOUNT_STORE_REFUND_TEXT_FORMAT:format(timeString));
	end
end

function AccountStoreBaseCardMixin:UpdateCardDisplay()
	-- Override in your derived Mixin.
end


AccountStoreCreatureCardMixin = {};

function AccountStoreCreatureCardMixin:UpdateCardDisplay()
	if not self.itemInfo then
		return;
	end

	local forceUpdate = true;
	self.ModelScene:SetFromModelSceneID(self.itemInfo.customUIModelSceneID or CreatureModelSceneID, forceUpdate);

	local creature = self.ModelScene:GetActorByTag("item");
	if creature then
		creature:Hide();
		creature:SetOnModelLoadedCallback(function()
			creature:Show();
		end);

		creature:SetModelByCreatureDisplayID(self.itemInfo.creatureDisplayID, forceUpdate);
	end
end


AccountStoreIconCardMixin = {};

function AccountStoreIconCardMixin:UpdateCardDisplay()
	if not self.itemInfo then
		return;
	end

	self.Icon:SetTexture(self.itemInfo.displayIcon);
end


AccountStoreTransmogSetCardMixin = {};

function AccountStoreTransmogSetCardMixin:UpdateCardDisplay()
	if not self.itemInfo then
		return;
	end

	local modelSceneID = self.itemInfo.customUIModelSceneID or TransmogModelSceneID;
	local forceUpdate = true;
	self.ModelScene:SetFromModelSceneID(modelSceneID, forceUpdate);

	local function SetUpPlayerActor()
		if C_Glue.IsOnGlueScreen() then
			local members = C_WoWLabsMatchmaking.GetCurrentParty();
			local playerActor = self.ModelScene:GetPlayerActor();
			if playerActor then
				playerActor:ReleaseFrontEndCharacterDisplays();
			end

			for i, member in ipairs(members) do
				if member.isLocalPlayer then
					playerActor:SetFrontEndLobbyModelFromDefaultCharacterDisplay(i - 1);
				end
			end

			return playerActor;
		else
			local overrideActorName = nil;
			local flags = select(4, C_ModelInfo.GetModelSceneInfoByID(modelSceneID));
			local sheatheWeapons = bit.band(flags, Enum.UIModelSceneFlags.SheatheWeapon) == Enum.UIModelSceneFlags.SheatheWeapon;
			local hideWeapons = bit.band(flags, Enum.UIModelSceneFlags.HideWeapon) == Enum.UIModelSceneFlags.HideWeapon;
			local autoDress = bit.band(flags, Enum.UIModelSceneFlags.Autodress) == Enum.UIModelSceneFlags.Autodress;
			local useNativeForm = true;
			local itemModifiedAppearanceIDs = nil; -- We set these below.
			SetupPlayerForModelScene(self.ModelScene, overrideActorName, itemModifiedAppearanceIDs, sheatheWeapons, autoDress, hideWeapons, useNativeForm);
			return self.ModelScene:GetPlayerActor(overrideActorName);
		end
	end

	local playerActor = SetUpPlayerActor();

	local displayDefaultArmor = bit.band(self.itemInfo.flags, Enum.AccountStoreItemFlag.DisplayDefaultArmor) == Enum.AccountStoreItemFlag.DisplayDefaultArmor;
	if displayDefaultArmor then
		for i, itemModifiedAppearanceID in ipairs(DefaultTransmogSetAppearances) do
			playerActor:TryOn(itemModifiedAppearanceID);
		end
	end

	for i, itemModifiedAppearanceID in ipairs(C_TransmogSets.GetAllSourceIDs(self.itemInfo.transmogSetID)) do
		playerActor:TryOn(itemModifiedAppearanceID);
	end
end


-- Duplicate behavior here.
AccountStoreMountCardMixin = AccountStoreCreatureCardMixin;