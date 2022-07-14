UIPanelWindows["ItemInteractionFrame"] = {area = "left", pushable = 3, showFailedFunc = C_ItemInteraction.Reset, };

StaticPopupDialogs["ITEM_INTERACTION_CONFIRMATION"] = {
	text = "",
	button1 = "",
	button2 = CANCEL,

	OnShow = function(self, data)
		self.text:SetText(data.confirmationDescription);
		self.button1:SetText(data.confirmationText);
	end,

	OnAccept = function()
		ItemInteractionFrame:CompleteItemInteraction();
	end,

	wide = true,
	wideText = true,
	compactItemFrame = true,
	hideOnEscape = 1,
	hasItemFrame = 1,
};

StaticPopupDialogs["ITEM_INTERACTION_CONFIRMATION_DELAYED"] = {
	text = "",
	button1 = "",
	button2 = CANCEL,

	OnShow = function(self, data)
		self.text:SetText(data.confirmationDescription);
	end,

	OnAcceptDelayExpired = function(self, data)
		self.button1:SetText(data.confirmationText);
	end,

	OnAccept = function()
		ItemInteractionFrame:CompleteItemInteraction();
	end,

	wide = true,
	wideText = true,
	compactItemFrame = true,
	hideOnEscape = 1,
	hasItemFrame = 1,
	acceptDelay = 5,
};


StaticPopupDialogs["ITEM_INTERACTION_CONFIRMATION_DELAYED_WITH_CHARGE_INFO"] = {
	text = "",
	subText = "",
	button1 = "",
	button2 = CANCEL,

	OnShow = function(self, data)
		self.text:SetText(data.confirmationDescription);
		if (data.subText) then
			self.SubText:SetText(data.subText);
		end
	end,

	OnAcceptDelayExpired = function(self, data)
		self.button1:SetText(data.confirmationText);
	end,

	OnAccept = function()
		ItemInteractionFrame:CompleteItemInteraction();
	end,

	itemFrameAboveSubtext = true,
	normalSizedSubText = true,
	compactItemFrame = true,
	hideOnEscape = 1,
	hasItemFrame = 1,
	acceptDelay = 5,
};

local FrameSpecificDefaults = {
	itemSlotOffsetY = 0,
	glowOverLayOffsetY = 0,
	descriptionOffset = -65,
	tutorialBitFlag = nil,
};

local FrameSpecificOverrides = {
	[Enum.UIItemInteractionType.CleanseCorruption] = {
		tutorialBitFlag = LE_FRAME_TUTORIAL_CORRUPTION_CLEANSER,
		glowOverLayOffsetY = 7,
		descriptionOffset = -74,
	},

	[Enum.UIItemInteractionType.RunecarverScrapping] = {
		tutorialBitFlag = LE_FRAME_TUTORIAL_RUNECARVER_SCRAPPING,
		itemSlotOffsetY = 15,
		descriptionOffset = -67,
	},

	[Enum.UIItemInteractionType.ItemConversion] = {
		itemSlotOffsetY = 17,
		descriptionOffset = -74,
	},
};

------------- Frame and Unit Events -------------
local ITEM_INTERACTION_FRAME_EVENTS = {
	"PLAYER_MONEY",
	"ITEM_INTERACTION_CLOSE",
	"ITEM_INTERACTION_ITEM_SELECTION_UPDATED",
	"ITEM_INTERACTION_CHARGE_INFO_UPDATED",
	"GLOBAL_MOUSE_DOWN",
	"CURRENCY_DISPLAY_UPDATE",
};

local ITEM_INTERACTION_UNIT_EVENTS = {
	"UNIT_SPELLCAST_START", 
	"UNIT_SPELLCAST_INTERRUPTED",
	"UNIT_SPELLCAST_STOP",
}; 

ItemInteractionMixin = {};

----------------- Helper functions --------------------
function ItemInteractionMixin:GetItemLocation()
	return self.itemLocation;
end

function ItemInteractionMixin:GetInteractionType()
	return self.interactionType;
end 

function ItemInteractionMixin:GetCost()
	return self.cost;
end 

-- UiItemInteraction data only supports a single, flat currency cost.
-- We need to add support for extended currency costs or move Item Conversion out of the Item Interaction UI.
function ItemInteractionMixin:HasExtendedCurrencyCost()
	return self.interactionType == Enum.UIItemInteractionType.ItemConversion;
end

function ItemInteractionMixin:HasCost()
	return (self.cost ~= nil) and (self.cost > 0) or self:HasExtendedCurrencyCost();
end

function ItemInteractionMixin:CostsGold() 
	return not self.currencyTypeId and not self:HasExtendedCurrencyCost() and self:HasCost();
end

function ItemInteractionMixin:CostsCurrency()
	return self.currencyTypeId and self:HasCost();
end

function ItemInteractionMixin:UsesCharges()
	return self.chargeCurrencyTypeId and self.chargeCost > 0;
end

--------------- Base Frame Functions -----------------------
function ItemInteractionMixin:OnEvent(event, ...)
	if (event == "PLAYER_MONEY") or (event == "ITEM_INTERACTION_ITEM_SELECTION_UPDATED") then
		self:UpdateMoney();
		if (event == "ITEM_INTERACTION_ITEM_SELECTION_UPDATED") then
			local itemLocation = ...;
			if (self:GetItemLocation() and self:GetItemLocation():IsEqualTo(itemLocation)) then
				self:SetInteractionItem(nil);
			else
				self:SetInteractionItem(itemLocation);
			end
		end
	elseif (event == "ITEM_INTERACTION_CHARGE_INFO_UPDATED" or event == "CURRENCY_DISPLAY_UPDATE") then
		-- We need to display a recharge time right after we use our final charge.
		if (self:UsesCharges()) then
			self:UpdateCharges();
		end
	elseif (event == "UNIT_SPELLCAST_START") then
		local unitTag, lineID, spellID = ...;
		local itemInteractionSpellId = C_ItemInteraction.GetItemInteractionSpellId(); 
		if (itemInteractionSpellId and spellID == itemInteractionSpellId) then
			self.castLineID = lineID;
		end
	elseif (event == "UNIT_SPELLCAST_INTERRUPTED") then
		local unitTag, spellName, rank, lineID, spellID = ...;
		if (self.castLineID and self.castLineID == lineID) then
			self.castLineID = nil;
		end
	elseif (event == "UNIT_SPELLCAST_STOP") then
		local unitTag, lineID, spellID = ...;
		if (self.castLineID and self.castLineID == lineID) then
			C_ItemInteraction.ClearPendingItem();
		end
	elseif (event == "ITEM_INTERACTION_CLOSE") then 
		HideUIPanel(self);
	elseif (event == "GLOBAL_MOUSE_DOWN") then
		if (self.clickShowsFlyout) then
			local buttonName = ...;
			local isRightButton = buttonName == "RightButton";

			local mouseFocus = GetMouseFocus();
			local flyoutSelected = not isRightButton and DoesAncestryInclude(EquipmentFlyout_GetFrame(), mouseFocus);
			if not flyoutSelected then
				EquipmentFlyout_Hide();
			end
		end
	end	
end

function ItemInteractionMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ITEM_INTERACTION_FRAME_EVENTS);
	FrameUtil.RegisterFrameForUnitEvents(self, ITEM_INTERACTION_UNIT_EVENTS, "player");

	local frameInfo = C_ItemInteraction.GetItemInteractionInfo();
	self:LoadInteractionFrameData(frameInfo);

	PlaySound(self.openSoundKitID)
	if (self.tutorialBitFlag) then 
		if (not GetCVarBitfield("closedInfoFrames", self.tutorialBitFlag)) then
			local helpTipInfo = {
				text = self.tutorialText,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = self.tutorialBitFlag,
			};
			if (self.conversionMode) then
				helpTipInfo.alignment = HelpTip.Alignment.Left;
				helpTipInfo.targetPoint = HelpTip.Point.BottomEdgeCenter;
				helpTipInfo.offsetY = -10;
				HelpTip:Show(self, helpTipInfo, self.ItemConversionFrame.ItemConversionInputSlot);
			else
				helpTipInfo.targetPoint = HelpTip.Point.RightEdgeCenter;
				helpTipInfo.offsetX = 80;
				HelpTip:Show(self, helpTipInfo, self.ItemSlot);
			end
		end
	end

	self:UpdateCostFrame(); 
	OpenAllBags(self);

	C_ItemInteraction.InitializeFrame();
	C_ItemInteraction.ClearPendingItem();
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function ItemInteractionMixin:OnHide()
	PlaySound(self.closeSoundKitID)
	FrameUtil.UnregisterFrameForEvents(self, ITEM_INTERACTION_FRAME_EVENTS);
	FrameUtil.UnregisterFrameForEvents(self, ITEM_INTERACTION_UNIT_EVENTS);

	CloseAllBags(self);
	EquipmentFlyout_Hide();
	C_ItemInteraction.CloseUI();

	-- Greys out the items in your bag that don't match. If you need  to add a new item interaction frame
	-- Add a new type to ItemUtil.lua ItemButtonUtil.ItemContextEnum
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function ItemInteractionMixin:LoadInteractionFrameData(frameData) 
	self.openSoundKitID = frameData.openSoundKitID; 
	self.closeSoundKitID = frameData.closeSoundKitID; 
	self.TitleText:SetText(frameData.titleText); 
	self.ButtonFrame.ActionButton:SetText(frameData.buttonText);
	self.confirmationText = frameData.buttonText;
	self.confirmationDescription = frameData.confirmationDescription;
	self.tutorialText = frameData.tutorialText; 
	self.cost = frameData.cost; 
	self.interactionType = frameData.interactionType; 
	self.currencyTypeId = frameData.currencyTypeId; 
	self.dropInSlotSoundKitId = frameData.dropInSlotSoundKitId or SOUNDKIT.PUT_DOWN_SMALL_CHAIN;
	self.flags = frameData.flags;
	self.buttonTooltip = frameData.buttonTooltip;
	self.textureKit = frameData.textureKit;
	local frameTextureKitRegions = {
		[self.Background] = "%s-background",
		[self.ItemSlot.GlowOverlay] = "%s-glow",
	};

	self.conversionMode = (FlagsUtil.IsSet(self.flags, Enum.UIItemInteractionFlags.ConversionMode));
	self.clickShowsFlyout = (FlagsUtil.IsSet(self.flags, Enum.UIItemInteractionFlags.ClickShowsFlyout));

	self:SetupChargeCurrency();

	self:SetupEquipmentFlyout(self.clickShowsFlyout);
	
	local portraitFormat = "%s-portrait";
	if (C_Texture.GetAtlasInfo(portraitFormat:format(self.textureKit)) ~= nil) then
		frameTextureKitRegions[self.portrait] = portraitFormat;
	else
		SetPortraitTexture(self.portrait, "npc");
	end

	SetupTextureKitOnFrames(self.textureKit, frameTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	self.descriptionText = frameData.description;
	self:UpdateDescription(self.descriptionText); 

	local shouldShowInset = (FlagsUtil.IsSet(self.flags, Enum.UIItemInteractionFlags.DisplayWithInset));
	self.Inset:SetShown(shouldShowInset);
	self.Background:ClearAllPoints();
	if (shouldShowInset) then
		self.Background:SetPoint("BOTTOM", -1, 32);
		self:SetSize(339, 290);
	else
		self.Background:SetPoint("BOTTOM", 0, 30);
		self:SetSize(343, 261);
	end

	-- This is shown dynamically when an item is set for certain interactions.
	self.DescriptionCurrencies:Hide();
	
	self:SetupFrameSpecificData();
	self:UpdateDescriptionColor();
end 

-- For each specific frame, a new tutorial bit flag is required. So add to this when you add a new frame type.
function ItemInteractionMixin:SetupFrameSpecificData()
	local overrides = FrameSpecificOverrides[self.interactionType];
	local function GetItemInteractionFrameSpecificValueByKey(key)
		return overrides[key] or FrameSpecificDefaults[key];
	end
	
	self.tutorialBitFlag = GetItemInteractionFrameSpecificValueByKey("tutorialBitFlag");

	local itemSlotOffsetY = GetItemInteractionFrameSpecificValueByKey("itemSlotOffsetY");

	if (self.conversionMode) then
		self.ItemSlot:Hide();

		self.ItemConversionFrame.ItemConversionInputSlot:ClearAllPoints();
		self.ItemConversionFrame.ItemConversionInputSlot:SetPoint("CENTER", self.ItemConversionFrame, "CENTER", -75, itemSlotOffsetY);

		self.ItemConversionFrame.DimArrow:ClearAllPoints();
		self.ItemConversionFrame.DimArrow:SetPoint("CENTER", self.ItemConversionFrame, "CENTER", 0, itemSlotOffsetY);

		self.ItemConversionFrame.ItemConversionOutputSlot:ClearAllPoints();
		self.ItemConversionFrame.ItemConversionOutputSlot:SetPoint("CENTER", self.ItemConversionFrame, "CENTER", 75, itemSlotOffsetY);
		self.ItemConversionFrame.ItemConversionOutputSlot:SetNormalTexture(nil);

		self.ItemConversionFrame:SetupConversionCelebration();

		self.ItemConversionFrame:Show();
	else
		self.ItemConversionFrame:Hide();

		self.ItemSlot:ClearAllPoints();
		self.ItemSlot:SetPoint("CENTER", self.Background, "CENTER", 0, itemSlotOffsetY);

		self.ItemSlot.GlowOverlay:ClearAllPoints();
		self.ItemSlot.GlowOverlay:SetPoint("CENTER", 0, GetItemInteractionFrameSpecificValueByKey("glowOverLayOffsetY"));

		self.ItemSlot:Show();
	end

	self.Description:ClearAllPoints();
	self.Description:SetPoint("CENTER", 0, GetItemInteractionFrameSpecificValueByKey("descriptionOffset"));
end

-- The 9.2 "Item Conversion" interaction requires two currencies from the player: A flat cost of 1 "Charge" and an extended currency cost of X "Cosmic Flux" depending on the armor slot (gloves, legs, etc)	
-- UiItemInteraction data currently only supports a single, flat currency cost.
-- For now we're passing the "Charge" cost in through data and grabbing the extended currency cost of this interaction using C_ItemInteraction.GetItemConversionCurrencyCost().
-- We need to either add support for a flat charge cost + an extended currency cost or move Item Conversion out of the Item Interaction UI.
function ItemInteractionMixin:SetupChargeCurrency()
	if (self.interactionType == Enum.UIItemInteractionType.ItemConversion) then
		self.chargeCurrencyTypeId = self.currencyTypeId;
		self.currencyTypeId = nil;

		self.chargeCost = self.cost;
		self.cost = nil;
	else
		self.chargeCurrencyTypeId = nil;
		self.chargeCost = nil;
	end
end

function ItemInteractionMixin:UpdateDescription(description)
	local hasDescription = (description ~= nil);
	if (hasDescription) then
		self.Description:SetText(description);
	end

	self.Description:SetShown(hasDescription);
end

function ItemInteractionMixin:UpdateDescriptionColor()
	self.Description:SetTextColor(self:GetDescriptionColor():GetRGB());
end

function ItemInteractionMixin:GetDescriptionColor()
	local interactionItemSet = self.itemLocation;
	local usesCharges = self:UsesCharges();
	local chargeCurrencyInfo = usesCharges and C_CurrencyInfo.GetCurrencyInfo(self.chargeCurrencyTypeId);
	local charges = chargeCurrencyInfo and chargeCurrencyInfo.quantity;

	if (usesCharges and charges < self.chargeCost) then
		return RED_FONT_COLOR;
	elseif (not interactionItemSet and (self.interactionType ~= Enum.UIItemInteractionType.CleanseCorruption)) then
		return DISABLED_FONT_COLOR;
	end

	return NORMAL_FONT_COLOR;
end

function ItemInteractionMixin:UpdateCostFrame()
	local hasPrice = self:HasCost();
	local costsMoney = self:CostsGold();
	local costsCurrency = self:CostsCurrency();
	local buttonFrame = self.ButtonFrame;

	if (self:UsesCharges()) then
		self:UpdateCharges();
	end

	if (costsCurrency) then 
		self:UpdateCurrency(); 
	elseif (costsMoney) then 
		self:UpdateMoney();
	end
	buttonFrame.Currency:SetShown(costsCurrency);
	buttonFrame.MoneyFrame:SetShown(costsMoney);
	buttonFrame.BlackBorder:SetShown(hasPrice); 
	buttonFrame.MoneyFrameEdge:SetShown(hasPrice);
end

function ItemInteractionMixin:UpdateMoney()
	if (not self:CostsGold()) then
		return;
	end

	MoneyFrame_Update(self.ButtonFrame.MoneyFrame:GetName(), self.cost, false);
	if (GetMoney() < (self.cost)) then
		SetMoneyFrameColor(self.ButtonFrame.MoneyFrame:GetName(), "red");
	else
		SetMoneyFrameColor(self.ButtonFrame.MoneyFrame:GetName(), "white");
	end
	self:UpdateActionButtonState();
end

function ItemInteractionMixin:UpdateCurrency()
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(self.currencyTypeId);
	local amount = currencyInfo.quantity;
	local currencyTexture = currencyInfo.iconFileID;
	self.ButtonFrame.Currency.currencyID = self.currencyTypeId;
	self.ButtonFrame.Currency.icon:SetTexture(currencyTexture);
	self.ButtonFrame.Currency.count:SetText(self.cost);
	if (self.cost > amount) then
		self.ButtonFrame.Currency.count:SetTextColor(RED_FONT_COLOR:GetRGB());
	else
		self.ButtonFrame.Currency.count:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end
	self:UpdateActionButtonState();
end

function ItemInteractionMixin:UpdateCharges()
	local chargeCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(self.chargeCurrencyTypeId);
	local charges = chargeCurrencyInfo.quantity;
	local description = charges >= self.chargeCost and self.descriptionText or charges < self.chargeCost and self:GetRechargeMessage() or nil;
	self:UpdateDescription(description);
	self:UpdateDescriptionColor();
	self:UpdateActionButtonState();
end

function ItemInteractionMixin:GetRechargeMessage()
	local chargeInfo = C_ItemInteraction.GetChargeInfo();
	local timeToNextCharge = chargeInfo.timeToNextCharge;
	if (self.interactionType == Enum.UIItemInteractionType.ItemConversion) then
		return SL_SET_CONVERSION_RECHARGE_TIME:format(SecondsToTime(timeToNextCharge));
	end
end

function ItemInteractionMixin:GetButtonTooltip()
	return self.buttonTooltip;
end

function ItemInteractionMixin:GetConfirmationDescription()
	if (self:HasExtendedCurrencyCost()) then
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(self.currencyTypeId);
		local file, fileWidth, fileHeight, width, height = currencyInfo.iconFileID, 64, 64, 16, 16;
		local left, right, top, bottom = 0, 1, 0, 1;
		local xOffset, yOffset = 0, 0;
		local currencyTexture = CreateTextureMarkup(file, fileWidth, fileHeight, width, height, left, right, top, bottom, xOffset, yOffset);
		
		return self.confirmationDescription:format(self.cost, currencyTexture);
	end

	return self.confirmationDescription;
end

function ItemInteractionMixin:GetConfirmationInfo()
	if (self.confirmationDescription ~= nil) then
		return self:GetConfirmationDescription(), self.confirmationText;
	end

	return nil, nil;
end

function ItemInteractionMixin:GetChargeConfirmationText()
	local chargeInfo = C_ItemInteraction.GetChargeInfo();
	local chargeCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(self.chargeCurrencyTypeId);
	local timeToNextCharge = chargeInfo.timeToNextCharge;
	local charges = chargeCurrencyInfo.quantity;
	if (self.interactionType == Enum.UIItemInteractionType.ItemConversion) then
		if (charges == 1) then
			return SL_SET_CONVERSION_ONE_CHARGE_REMAINING:format(SecondsToTime(timeToNextCharge));
		elseif (charges > 1) then
			return SL_SET_CONVERSION_MULTIPLE_CHARGES_REMAINING:format(charges - 1);
		end
	end
end

function ItemInteractionMixin:InteractWithItem()
	local confirmationDescription, confirmationText = self:GetConfirmationInfo();
	if (confirmationDescription ~= nil) then
		local itemLocation = self:GetItemLocation();

		local function ItemInteractionStaticPopupItemFrameCallback(itemFrame)
			itemFrame:SetItemLocation(itemLocation);

			local quality = C_Item.GetItemQuality(itemLocation);
			SetItemButtonQuality(itemFrame, quality);
			itemFrame.Text:SetTextColor(ITEM_QUALITY_COLORS[quality].color:GetRGB());

			local itemName = C_Item.GetItemName(itemLocation);
			itemFrame.Text:SetText(itemName);
			itemFrame.Count:Hide();
		end

		local function ItemInteractionStaticPopupItemFrameOnEnterCallback(itemFrame)
			GameTooltip:SetOwner(itemFrame, "ANCHOR_RIGHT");
			ItemLocation:ApplyLocationToTooltip(itemLocation, GameTooltip);
			GameTooltip:Show();
		end

		local data = {
			confirmationDescription = confirmationDescription,
			confirmationText = confirmationText,
			itemFrameCallback = ItemInteractionStaticPopupItemFrameCallback,
			itemFrameOnEnter = ItemInteractionStaticPopupItemFrameOnEnterCallback,
		};

		local textArg1 = nil;
		local textArg2 = nil;

		if (FlagsUtil.IsSet(self.flags, Enum.UIItemInteractionFlags.ConfirmationHasDelay)) then
			if (self:UsesCharges()) then
				data.subText = self:GetChargeConfirmationText();
				StaticPopup_Show("ITEM_INTERACTION_CONFIRMATION_DELAYED_WITH_CHARGE_INFO", textArg1, textArg2, data);
			else
				StaticPopup_Show("ITEM_INTERACTION_CONFIRMATION_DELAYED", textArg1, textArg2, data);
			end
		else
			StaticPopup_Show("ITEM_INTERACTION_CONFIRMATION", textArg1, textArg2, data);
		end
	else
		self:CompleteItemInteraction();
	end
end

function ItemInteractionMixin:CompleteItemInteraction()
	if (self.conversionMode) then
		self.ItemConversionFrame:PlayConversionCelebration();
	end
	C_ItemInteraction.PerformItemInteraction();
end

-- Enables or disables the button to interact with the item based off of your currency amount and if you have an item in the slot.
function ItemInteractionMixin:UpdateActionButtonState()
	-- We check if we have enough charges before worrying about the gold or currency cost
	if (self:UsesCharges()) then
		local chargeCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(self.chargeCurrencyTypeId);
		local charges = chargeCurrencyInfo.quantity;
		if (charges < self.chargeCost) then
			self.ButtonFrame.ActionButton:SetEnabled(false);
			return;
		end
	end

	if (self:CostsCurrency()) then
		local amount = C_CurrencyInfo.GetCurrencyInfo(self.currencyTypeId).quantity;
		self.ButtonFrame.ActionButton:SetEnabled(self.itemLocation ~= nil and amount >= self.cost);
	elseif (self:CostsGold()) then
		self.ButtonFrame.ActionButton:SetEnabled(self.itemLocation ~= nil and GetMoney() >= self.cost);
	else 
		self.ButtonFrame.ActionButton:SetEnabled(self.itemLocation ~= nil);
	end 
end

function ItemInteractionMixin:SetItemConversionExtendedCurrencyCost(itemLocation)
	local conversionCurrencyInfo = itemLocation and C_ItemInteraction.GetItemConversionCurrencyCost(itemLocation) or nil;
	self.currencyTypeId = conversionCurrencyInfo and conversionCurrencyInfo.currencyID or nil;
	self.cost = conversionCurrencyInfo and conversionCurrencyInfo.amount or nil;

	if (self.currencyTypeId and self.cost) then
		self:UpdateCurrency();
		self.ButtonFrame.Currency:SetShown(true);
	else
		self.ButtonFrame.Currency:SetShown(false);
	end
end

function ItemInteractionMixin:SetInteractionItem(itemLocation)
	if (self.itemDataLoadedCancelFunc) then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end

	self.DescriptionCurrencies:Hide();

	self.itemLocation = itemLocation;

	if (itemLocation) then
		if (self.tutorialBitFlag and not GetCVarBitfield("closedInfoFrames", self.tutorialBitFlag)) then
			HelpTip:Hide(self, self.tutorialText);
			SetCVarBitfield("closedInfoFrames", self.tutorialBitFlag, true);
		end

		if (self.interactionType == Enum.UIItemInteractionType.RunecarverScrapping) then
			local costs = C_LegendaryCrafting.GetRuneforgeLegendaryCost(itemLocation);
			RuneforgeUtil.SetCurrencyCosts(self.DescriptionCurrencies, costs);
			self.DescriptionCurrencies:Show();
		end
	end
	
	if (self:HasExtendedCurrencyCost()) then
		self:SetItemConversionExtendedCurrencyCost(itemLocation);
	end

	self:UpdateDescriptionColor();

	PlaySound(self.dropInSlotSoundKitId);
	if (self.conversionMode) then
		self.ItemConversionFrame.ItemConversionInputSlot:RefreshIcon();
		self.ItemConversionFrame.ItemConversionInputSlot:RefreshTooltip();
		self.ItemConversionFrame:UpdateArrow(itemLocation and itemLocation:IsValid());
		self.ItemConversionFrame.ItemConversionOutputSlot:RefreshIcon();
	else
		self.ItemSlot:RefreshIcon();
		self.ItemSlot:RefreshTooltip();
	end
	self:UpdateActionButtonState();

	StaticPopup_Hide("ITEM_INTERACTION_CONFIRMATION");
end

function ItemInteractionMixin:SetupEquipmentFlyout(setup)
	local flyoutSettings = {
			customFlyoutOnUpdate = nop,
			hasPopouts = true,
			parent = self:GetParent(),
			anchorX = 20,
			anchorY = -8,
			useItemLocation = true,
			hideFlyoutHighlight = true,
			alwaysHideOnClick = true,
	};

	-- The equipment slot API requires the flyout settings to be on the item slot's parent.
	self.flyoutSettings = setup and not self.conversionMode and flyoutSettings or nil;
	self.ItemConversionFrame.flyoutSettings = setup and self.conversionMode and flyoutSettings or nil;
end

function ItemInteractionMixin:SetDynamicFlyoutSettings()
	-- Add a new filter function here if you want your interaction to use the equipment flyout.
	local filterFunction;
	if (self.interactionType == Enum.UIItemInteractionType.ItemConversion) then
		filterFunction = C_Item.IsItemConvertibleAndValidForPlayer;
	end

	-- itemSlot is required by the API, but unused in this context.
	local function GetItemInteractionItemsCallback(itemSlot, resultsTable)
		self:GetValidItemInteractionItemsCallback(filterFunction, resultsTable);
	end

	local function SetValidItemInteractionItemCallback(button)
		local location = button:GetItemLocation();
		C_ItemInteraction.SetPendingItem(location);
	end

	local flyoutSettings = self.conversionMode and self.ItemConversionFrame.flyoutSettings or self.flyoutSettings;
	flyoutSettings.getItemsFunc = GetItemInteractionItemsCallback;
	flyoutSettings.onClickFunc = SetValidItemInteractionItemCallback;
	flyoutSettings.filterFunction = filterFunction;
end

function ItemInteractionMixin:GetValidItemInteractionItemsCallback(filterFunction, resultsTable)
	if (not filterFunction) then
		return;
	end
	
	local function ItemLocationCallback(itemLocation)
		if (filterFunction(itemLocation)) then
			resultsTable[itemLocation] = C_Item.GetItemLink(itemLocation);
		end
	end

	ItemUtil.IteratePlayerInventoryAndEquipment(ItemLocationCallback);
end

function ItemInteractionMixin:ShowFlyout(itemSlot)
	self:SetDynamicFlyoutSettings();
	EquipmentFlyout_Show(itemSlot);
end

function ItemInteractionMixin:SetInputItemSlotTooltip(itemSlot, itemLocation)
	if (itemLocation) then
		GameTooltip:SetOwner(itemSlot, "ANCHOR_RIGHT");
		if (self.interactionType == Enum.UIItemInteractionType.CleanseCorruption) then
			C_ItemInteraction.SetCorruptionReforgerItemTooltip();
		else 
			ItemLocation:ApplyLocationToTooltip(itemLocation, GameTooltip);
		end
		GameTooltip:Show();
	elseif (self.interactionType == Enum.UIItemInteractionType.ItemConversion) then
			GameTooltip:SetOwner(itemSlot, "ANCHOR_RIGHT"); 			
			-- We don't allow wrapping on the first line of the tooltip, so hack around that restriction.
			GameTooltip_AddNormalLine(GameTooltip, "");
			GameTooltip_AddNormalLine(GameTooltip, SL_SET_CONVERSION_INPUT_DESCRIPTION:format(PVPUtil.GetCurrentSeasonNumber()));
			if (not ItemUtil.DoesAnyItemSlotMatchItemContext()) then
				GameTooltip_AddErrorLine(GameTooltip, ERR_ITEM_CONVERSION_NO_VALID_ITEMS);
			end
			GameTooltip:Show();
	else
		GameTooltip:Hide();
	end
end

------------------ Item Slot Functions ----------------------------
ItemInteractionItemSlotMixin = {};
function ItemInteractionItemSlotMixin:OnLoad()
	self:RegisterForClicks("RightButtonDown", "LeftButtonDown");
	self:RegisterForDrag("LeftButton");
end

function ItemInteractionItemSlotMixin:RefreshIcon()
	self.Icon:Hide();
	self.GlowOverlay:Hide();
	local itemInteractionFrame = self:GetParent()
	local itemLocation = itemInteractionFrame:GetItemLocation();
	if (itemLocation) then
		local item = Item:CreateFromItemLocation(itemLocation);
		self.itemDataLoadedCancelFunc = item:ContinueWithCancelOnItemLoad(function()
			self.Icon:SetTexture(item:GetItemIcon());
			self.Icon:Show();
			self.GlowOverlay:Show();
		end);
	end
end

function ItemInteractionItemSlotMixin:RefreshTooltip()
	if (GetMouseFocus() == self) then
		self:OnEnter();
	else
		self:OnLeave();
	end
end

function ItemInteractionItemSlotMixin:OnClick(button)
	if (button == "RightButton") then
		C_ItemInteraction.ClearPendingItem();
		return; 
	end

	local itemInteractionFrame = self:GetParent();
	local cursorItem = C_Cursor.GetCursorItem();
	if (cursorItem) then
		C_ItemInteraction.SetPendingItem(cursorItem);
		ClearCursor();
	elseif (itemInteractionFrame.clickShowsFlyout) then
		itemInteractionFrame:ShowFlyout(self);
	end
end

function ItemInteractionItemSlotMixin:OnDragStart()
	C_ItemInteraction.ClearPendingItem();
end

function ItemInteractionItemSlotMixin:OnReceiveDrag()
	C_ItemInteraction.SetPendingItem(C_Cursor.GetCursorItem());
end

function ItemInteractionItemSlotMixin:OnEnter()
	local itemInteractionFrame = self:GetParent();
	local itemLocation = itemInteractionFrame:GetItemLocation(); 
	itemInteractionFrame:SetInputItemSlotTooltip(self, itemLocation);
end

function ItemInteractionItemSlotMixin:OnLeave()
	GameTooltip_Hide();
end

------------------ Item Action Button Functions ----------------------------
ItemInteractionActionButtonMixin = {};

function ItemInteractionActionButtonMixin:OnEnter()
	local itemInteractionFrame = self:GetParent():GetParent();

	if (itemInteractionFrame:CostsGold()) then
		if (not self:IsEnabled() and GetMoney() < itemInteractionFrame:GetCost()) then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
			GameTooltip_AddColoredLine(GameTooltip, NOT_ENOUGH_GOLD, RED_FONT_COLOR);
			GameTooltip:Show();
		else
			GameTooltip_Hide();
		end
	elseif (itemInteractionFrame:CostsCurrency()) then 
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(itemInteractionFrame.currencyTypeId);
		local name = currencyInfo.name;
		local amount = currencyInfo.quantity;
		if (not self:IsEnabled() and amount < itemInteractionFrame:GetCost()) then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
			GameTooltip_AddColoredLine(GameTooltip, NOT_ENOUGH_CURRENCY:format(name), RED_FONT_COLOR);
			GameTooltip:Show(); 
		else
			GameTooltip_Hide();
		end
	else
		local buttonTooltip = itemInteractionFrame:GetButtonTooltip();
		if (self:IsEnabled() and (buttonTooltip ~= nil)) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			-- We don't allow wrapping on the first line of the tooltip, so hack around that restriction.
			GameTooltip_AddNormalLine(GameTooltip, "");
			GameTooltip_AddNormalLine(GameTooltip, buttonTooltip);
			GameTooltip:Show();
		else
			GameTooltip_Hide();
		end
	end
end

function ItemInteractionActionButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function ItemInteractionActionButtonMixin:OnClick()
	self:GetParent():GetParent():InteractWithItem();
end

------------------ Item Conversion Frame Functions ------------------

ItemInteractionItemConversionFrameMixin = {};
function ItemInteractionItemConversionFrameMixin:OnLoad()
	-- We have duplicates here to increase the brightness of the "Conversion Celebration Flash"
	self.flashingRegions = {
		[self.Background_Flash] =  "%s-background",
		[self.Background_Flash2] = "%s-background",
		[self.ItemConversionInputSlot.InputSlot_Flash]  = "%s-leftitem-border-empty",
		[self.ItemConversionInputSlot.InputSlot_Flash2] = "%s-leftitem-border-empty",
		[self.ItemConversionOutputSlot.OutputSlot_Flash] =  "%s-rightitem-border-empty",
		[self.ItemConversionOutputSlot.OutputSlot_Flash2] = "%s-rightitem-border-empty",
	}
end

function ItemInteractionItemConversionFrameMixin:OnHide()
	if (self.playingCelebration) then
		self:StopConversionCelebration();
	end
end

function ItemInteractionItemConversionFrameMixin:SetupConversionCelebration()
	local itemInteractionFrame = self:GetParent();
	local textureKit = itemInteractionFrame.textureKit;

	SetupTextureKitOnFrames(textureKit, self.flashingRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end

function ItemInteractionItemConversionFrameMixin:PlayConversionCelebration()
	self.AnimationHolder.ConversionFlash:Restart();
	self.playingCelebration = true;
end

function ItemInteractionItemConversionFrameMixin:StopConversionCelebration()
	for region, _ in pairs(self.flashingRegions) do
		region:SetAlpha(0);
	end
	self.AnimationHolder.ConversionFlash:Stop();
	self.playingCelebration = false;
end

function ItemInteractionItemConversionFrameMixin:UpdateArrow(validItem)
	if (validItem) then
		self.DimArrow:Hide();
		self.AnimatedArrow.Anim:Restart();
		self.AnimatedArrow:Show();
	else
		self.AnimatedArrow.Anim:Stop();
		self.AnimatedArrow:Hide();
		self.DimArrow:Show();
	end
end

------------------ Item Conversion Input Slot Functions ------------------
ItemInteractionItemConversionInputSlotMixin = {};

function ItemInteractionItemConversionInputSlotMixin:OnLoad()
	self:RegisterForClicks("RightButtonDown", "LeftButtonDown");
	self:RegisterForDrag("LeftButton");
end

function ItemInteractionItemConversionInputSlotMixin:RefreshIcon()
	local itemInteractionFrame = self:GetParent():GetParent();
	local itemLocation = itemInteractionFrame:GetItemLocation();
	if (itemLocation) then
		local item = Item:CreateFromItemLocation(itemLocation);
		self.itemDataLoadedCancelFunc = item:ContinueWithCancelOnItemLoad(function()
			SetupTextureKitOnFrame(itemInteractionFrame.textureKit, self.ButtonFrame, "%s-leftitem-border-full", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize)
			self:SetNormalTexture(nil);
			self:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
			self.Glow.EmptySlotGlow:Hide();
			self.Glow.PulseEmptySlotGlow:Stop();
			SetItemButtonTexture(self, item:GetItemIcon());
		end);
	else
		SetupTextureKitOnFrame(itemInteractionFrame.textureKit, self.ButtonFrame, "%s-leftitem-border-empty", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize)
		SetItemButtonTexture(self, nil);
		self:SetNormalAtlas("itemupgrade_greenplusicon");
		self:SetPushedAtlas("itemupgrade_greenplusicon_pressed");
		self.Glow.EmptySlotGlow:Show();
		self.Glow.PulseEmptySlotGlow:Restart();
	end
end

function ItemInteractionItemConversionInputSlotMixin:RefreshTooltip()
	if (GetMouseFocus() == self) then
		self:OnEnter();
	else
		self:OnLeave();
	end
end

function ItemInteractionItemConversionInputSlotMixin:OnClick(button)
	if (button == "RightButton") then
		C_ItemInteraction.ClearPendingItem();
		return; 
	end

	local itemConversionFrame = self:GetParent();
	local itemInteractionFrame = itemConversionFrame:GetParent();
	local cursorItem = C_Cursor.GetCursorItem();
	if (cursorItem) then
		C_ItemInteraction.SetPendingItem(cursorItem);
		ClearCursor();
	elseif (itemInteractionFrame.clickShowsFlyout) then
		itemInteractionFrame:ShowFlyout(self);
	end
end

function ItemInteractionItemConversionInputSlotMixin:OnDragStart()
	C_ItemInteraction.ClearPendingItem();
end

function ItemInteractionItemConversionInputSlotMixin:OnReceiveDrag()
	C_ItemInteraction.SetPendingItem(C_Cursor.GetCursorItem());
end

function ItemInteractionItemConversionInputSlotMixin:OnEnter()
	local itemInteractionFrame = self:GetParent():GetParent();
	local itemLocation = itemInteractionFrame:GetItemLocation();
	itemInteractionFrame:SetInputItemSlotTooltip(self, itemLocation);
end

function ItemInteractionItemConversionInputSlotMixin:OnLeave()
	GameTooltip_Hide();
end

------------------ Item Conversion Output Slot Functions ------------------
ItemInteractionItemConversionOutputSlotMixin = {};

function ItemInteractionItemConversionOutputSlotMixin:RefreshIcon()
	local itemInteractionFrame = self:GetParent():GetParent();
	local itemLocation = itemInteractionFrame:GetItemLocation();

	SetupTextureKitOnFrame(itemInteractionFrame.textureKit, self.ButtonFrame, "%s-rightitem-border-empty", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	SetItemButtonTexture(self, nil);

	if (itemLocation) then
		local icon = C_Item.GetItemConversionOutputIcon(itemLocation);
		if (not icon) then
			self:RegisterEvent("ITEM_CONVERSION_DATA_READY");
			return;
		end

		self:UnregisterEvent("ITEM_CONVERSION_DATA_READY");
		SetupTextureKitOnFrame(itemInteractionFrame.textureKit, self.ButtonFrame, "%s-rightitem-border-full", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
		SetItemButtonTexture(self, icon);
	end
end

function ItemInteractionItemConversionOutputSlotMixin:OnEvent(event, ...)
	if (event == "ITEM_CONVERSION_DATA_READY") then
		local itemGUID = ...;
		local itemInteractionFrame = self:GetParent():GetParent();
		local itemLocation = itemInteractionFrame:GetItemLocation();

		-- Let's make sure this data is for the current input item before refreshing the icon
		if (itemLocation and C_Item.GetItemGUID(itemLocation) == itemGUID) then
			self:RefreshIcon();
		end
	end
end

function ItemInteractionItemConversionOutputSlotMixin:OnEnter()
	local itemInteractionFrame = self:GetParent():GetParent();
	local itemLocation = itemInteractionFrame:GetItemLocation(); 
	if (itemLocation) then
		if (itemInteractionFrame:GetInteractionType() == Enum.UIItemInteractionType.ItemConversion) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			C_ItemInteraction.SetItemConversionOutputTooltip();
			GameTooltip:Show();
		else 
			GameTooltip_Hide();
		end
	else
		GameTooltip_Hide();
	end
end

function ItemInteractionItemConversionOutputSlotMixin:OnLeave()
	GameTooltip_Hide();
end