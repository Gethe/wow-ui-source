
local AccountStoreCardUpdateCadenceSeconds = 1.0;
local CreatureModelSceneID = 76;
local TransmogModelSceneID = 420;
local DefaultTransmogSetAppearances = {
	169000, -- Chest
	169001, -- Waist
	169002, -- Legs
	169003, -- Boots
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
	if not self.hoverSoundPlayed then
		self.hoverSoundPlayed = true;
		PlaySound(SOUNDKIT.ACCOUNT_STORE_ITEM_HOVER);
	end

	local itemInfo = self.itemInfo;
	local description = itemInfo.description;
	if not description then
		return;
	end

	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(tooltip, itemInfo.name);
	GameTooltip_AddNormalLine(tooltip, description);

	local isLocked = (itemInfo.mode == Enum.AccountStoreItemMode.Locked);
	local isOwned = (itemInfo.status == Enum.AccountStoreItemStatus.Owned) or (itemInfo.status == Enum.AccountStoreItemStatus.Refundable);
	if not isLocked and not isOwned and itemInfo.nonrefundable and (itemInfo.price > 0) then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddErrorLine(tooltip, ACCOUNT_STORE_NONREFUNDABLE_TOOLTIP);
	end

	tooltip:Show();
end

function AccountStoreBaseCardMixin:OnLeave()
	if not self:IsMouseOver() and not self.ModelScene:IsMouseOver() then
		self.hoverSoundPlayed = false;
	end

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

	local displayNew = not isOwned and FlagsUtil.IsSet(self.itemInfo.flags, Enum.AccountStoreItemFlag.DisplayAsNew);
	self.New:SetShown(displayNew);

	local showButton = (itemInfo.mode ~= Enum.AccountStoreItemMode.Locked);
	self.BuyButton:SetShown(showButton);
	
	-- Card text and the model scene are anchored to the buy button which we want to adjust when it's hidden.
	self.BuyButton:SetPoint("BOTTOM", 0, showButton and 25 or 0);

	if showButton then
		local isRefundable = itemInfo.status == Enum.AccountStoreItemStatus.Refundable;
		local canAfford = itemInfo.price <= C_AccountStore.GetCurrencyAvailable(itemInfo.currencyID);
		local enabled = isRefundable or (canAfford and not isOwned);
		self.BuyButton:SetEnabled(enabled);

		if isRefundable then
			self.BuyButton:SetText(PLUNDERSTORE_REFUND_BUTTON_TEXT);
		elseif isOwned then
			self.BuyButton:SetText(PLUNDERSTORE_ALREADY_OWNED_TOOLTIP);
		else
			self.BuyButton:SetText(AccountStoreUtil.FormatCurrencyDisplay(itemInfo.price, itemInfo.currencyID));
		end
	end

	if self:IsShown() then
		self:UpdateCardDisplay();
	end
end

function AccountStoreBaseCardMixin:SelectCard()
	PlaySound(SOUNDKIT.ACCOUNT_STORE_ITEM_SELECT);

	local itemInfo = self.itemInfo;
	local isRefundable = itemInfo.status == Enum.AccountStoreItemStatus.Refundable;
	local confirmationFormat = isRefundable and ACCOUNT_STORE_REFUND_CONFIRMATION_FORMAT or PLUNDERSTORE_PURCHASE_CONFIRMATION_FORMAT;
	local confirmation = confirmationFormat:format(itemInfo.name, AccountStoreUtil.FormatCurrencyDisplay(itemInfo.price, itemInfo.currencyID));

	if StaticPopup_Hide then
		StaticPopup_Hide("GENERIC_CONFIRMATION");

		StaticPopup_ShowGenericConfirmation(confirmation, function ()
			if isRefundable then
				PlaySound(SOUNDKIT.ACCOUNT_STORE_ITEM_REFUND);
				C_AccountStore.RefundItem(itemInfo.id);
			else
				PlaySound(SOUNDKIT.ACCOUNT_STORE_ITEM_PURCHASE);
				C_AccountStore.BeginPurchase(itemInfo.id);
			end
		end);
	else
		local text2 = nil;
		StaticPopup_Show("ACCOUNT_STORE_BEGIN_PURCHASE_OR_REFUND", confirmation, text2, itemInfo);
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

	local function GetPlayerActorName()
		local playerRaceName = nil;
		local playerGender = nil;
		if C_Glue.IsOnGlueScreen() then
			local members = C_WoWLabsMatchmaking.GetCurrentParty();
			if TableIsEmpty(members) then
				local characterGuid = GetCharacterGUID(GetCharacterSelection());
				if characterGuid then
					local basicCharacterInfo = GetBasicCharacterInfo(characterGuid);
					playerRaceName = basicCharacterInfo.raceFilename and basicCharacterInfo.raceFilename:lower();
					playerGender = basicCharacterInfo.genderEnum;
				end
			else
				for i, member in ipairs(members) do
					if member.isLocalPlayer then
						playerRaceName = member.raceFilename and member.raceFilename:lower();
						playerGender = member.gender;
						break;
					end
				end
			end
		else
			local raceFilename = select(2, UnitRace("player"));
			playerRaceName = raceFilename:lower();
			playerGender = UnitSex("player");
		end

		local useNativeForm = true;
		local overrideActorName;
		if playerRaceName == "dracthyr" then
			useNativeForm = false;
			overrideActorName = "dracthyr-alt";
		end

		return playerRaceName and playerRaceName:lower() or overrideActorName, playerGender, useNativeForm;
	end

	local function SetUpPlayerActor()
		if C_Glue.IsOnGlueScreen() then
			local playerRaceName, playerGender, useNativeForm = GetPlayerActorName();
			local overrideActorName = nil;
			local forceAlternateForm = nil;
			local playerActor = self.ModelScene:GetPlayerActor(overrideActorName, forceAlternateForm, playerRaceName, playerGender);
			if playerActor then
				playerActor:ReleaseFrontEndCharacterDisplays();
			end

			local members = C_WoWLabsMatchmaking.GetCurrentParty();
			if TableIsEmpty(members) then
				local flags = select(4, C_ModelInfo.GetModelSceneInfoByID(modelSceneID));
				local sheatheWeapons = bit.band(flags, Enum.UIModelSceneFlags.SheatheWeapon) == Enum.UIModelSceneFlags.SheatheWeapon;
				local hideWeapons = bit.band(flags, Enum.UIModelSceneFlags.HideWeapon) == Enum.UIModelSceneFlags.HideWeapon;
				local autoDress = bit.band(flags, Enum.UIModelSceneFlags.Autodress) == Enum.UIModelSceneFlags.Autodress;
				playerActor:SetPlayerModelFromGlues(GetCharacterSelection() - 1, sheatheWeapons, autoDress, hideWeapons, useNativeForm);
			else
				for i, member in ipairs(members) do
					if member.isLocalPlayer then
						playerActor:SetFrontEndLobbyModelFromDefaultCharacterDisplay(i - 1);
					end
				end
			end

			return playerActor;
		else
			local playerRaceName, playerGender, useNativeForm = GetPlayerActorName();
			local flags = select(4, C_ModelInfo.GetModelSceneInfoByID(modelSceneID));
			local sheatheWeapons = bit.band(flags, Enum.UIModelSceneFlags.SheatheWeapon) == Enum.UIModelSceneFlags.SheatheWeapon;
			local hideWeapons = bit.band(flags, Enum.UIModelSceneFlags.HideWeapon) == Enum.UIModelSceneFlags.HideWeapon;
			local autoDress = bit.band(flags, Enum.UIModelSceneFlags.Autodress) == Enum.UIModelSceneFlags.Autodress;
			local itemModifiedAppearanceIDs = nil; -- We set these below.
			local overrideActorName = nil;
			local forceAlternateForm = nil;
			SetupPlayerForModelScene(self.ModelScene, overrideActorName, itemModifiedAppearanceIDs, sheatheWeapons, autoDress, hideWeapons, useNativeForm, playerRaceName, playerGender);
			return self.ModelScene:GetPlayerActor(overrideActorName, forceAlternateForm, playerRaceName, playerGender);
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