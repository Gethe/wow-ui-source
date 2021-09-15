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
		C_ItemInteraction.PerformItemInteraction();
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
		C_ItemInteraction.PerformItemInteraction();
	end,

	wide = true,
	wideText = true,
	compactItemFrame = true,
	hideOnEscape = 1,
	hasItemFrame = 1,
	acceptDelay = 5;
};

local FrameSpecificDefaults = {
	itemSlotOffsetY = 0,
	glowOverLayOffsetY = 0,
	descriptionOffset = 45,
	tutorialBitFlag = nil,
};

local FrameSpecificOverrides = {
	[Enum.UIItemInteractionType.CleanseCorruption] = {
		tutorialBitFlag = LE_FRAME_TUTORIAL_CORRUPTION_CLEANSER,
		glowOverLayOffsetY = 7,
	},

	[Enum.UIItemInteractionType.RunecarverScrapping] = {
		tutorialBitFlag = LE_FRAME_TUTORIAL_RUNECARVER_SCRAPPING,
		itemSlotOffsetY = 15,
		descriptionOffset = 72,
	},
};

------------- Frame and Unit Events -------------
local ITEM_INTERACTION_FRAME_EVENTS = {
	"PLAYER_MONEY",
	"ITEM_INTERACTION_CLOSE",
	"ITEM_INTERACTION_ITEM_SELECTION_UPDATED",
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

function ItemInteractionMixin:HasCost()
	return (self.cost ~= nil) and (self.cost > 0);
end

function ItemInteractionMixin:CostsGold() 
	return not self.currencyTypeId and self:HasCost();
end

function ItemInteractionMixin:CostsCurrency()
	return self.currencyTypeId and self:HasCost();
end

--------------- Base Frame Functions -----------------------
function ItemInteractionMixin:OnEvent(event, ...)
	if(event == "PLAYER_MONEY") or (event == "ITEM_INTERACTION_ITEM_SELECTION_UPDATED") then
		self:UpdateMoney();
		if (event == "ITEM_INTERACTION_ITEM_SELECTION_UPDATED") then
			local itemLocation = ...;
			if self:GetItemLocation() and self:GetItemLocation():IsEqualTo(itemLocation) then
				self:SetInteractionItem(nil);
			else
				self:SetInteractionItem(itemLocation);
			end
		end
	elseif event == "UNIT_SPELLCAST_START" then
		local unitTag, lineID, spellID = ...;
		local itemInteractionSpellId = C_ItemInteraction.GetItemInteractionSpellId(); 
		if itemInteractionSpellId and spellID == itemInteractionSpellId then
			self.castLineID = lineID;
		end
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
		local unitTag, spellName, rank, lineID, spellID = ...;
		if self.castLineID and self.castLineID == lineID then
			self.castLineID = nil;
		end
	elseif event == "UNIT_SPELLCAST_STOP" then
		local unitTag, lineID, spellID = ...;
		if self.castLineID and self.castLineID == lineID then
			C_ItemInteraction.ClearPendingItem();
		end
	elseif event == "ITEM_INTERACTION_CLOSE" then 
		HideUIPanel(self);
	end
end

function ItemInteractionMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ITEM_INTERACTION_FRAME_EVENTS);
	FrameUtil.RegisterFrameForUnitEvents(self, ITEM_INTERACTION_UNIT_EVENTS, "player");

	local frameInfo = C_ItemInteraction.GetItemInteractionInfo();
	self:LoadInteractionFrameData(frameInfo);

	PlaySound(self.openSoundKitID)
	if(self.tutorialBitFlag) then 
		if not GetCVarBitfield("closedInfoFrames", self.tutorialBitFlag) then
			local helpTipInfo = {
				text = self.tutorialText,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = self.tutorialBitFlag,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				offsetX = 80,
			};
			HelpTip:Show(self, helpTipInfo, self.ItemSlot);
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
	local frameTextureKitRegions = {
		[self.Background] = "%s-background",
		[self.ItemSlot.GlowOverlay] = "%s-glow",
	};

	local portraitFormat = "%s-portrait";
	if (C_Texture.GetAtlasInfo(portraitFormat:format(frameData.textureKit)) ~= nil) then
		frameTextureKitRegions[self.portrait] = portraitFormat;
	else
		SetPortraitTexture(self.portrait, "npc");
	end

	SetupTextureKitOnFrames(frameData.textureKit, frameTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	local hasDescription = (frameData.description ~= nil);
	self.Description:SetShown(hasDescription);
	if (hasDescription) then 
		self.Description:SetText(frameData.description);
	end

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

	self.ItemSlot:ClearAllPoints();
	self.ItemSlot:SetPoint("CENTER", self.Background, "CENTER", 0, GetItemInteractionFrameSpecificValueByKey("itemSlotOffsetY"));

	self.ItemSlot.GlowOverlay:ClearAllPoints();
	self.ItemSlot.GlowOverlay:SetPoint("CENTER", 0, GetItemInteractionFrameSpecificValueByKey("glowOverLayOffsetY"));

	self.Description:ClearAllPoints();
	self.Description:SetPoint("BOTTOM", 0, GetItemInteractionFrameSpecificValueByKey("descriptionOffset"));
end 

function ItemInteractionMixin:UpdateDescriptionColor()
	self.Description:SetTextColor(self:GetDescriptionColor():GetRGB());
end

function ItemInteractionMixin:GetDescriptionColor()
	if (self.interactionType == Enum.UIItemInteractionType.RunecarverScrapping) then
		return (self.itemLocation == nil) and DISABLED_FONT_COLOR or NORMAL_FONT_COLOR;
	end

	return NORMAL_FONT_COLOR;
end

function ItemInteractionMixin:UpdateCostFrame()
	local hasPrice = self:HasCost();
	local costsMoney = self:CostsGold();
	local costsCurrency = self:CostsCurrency();
	local buttonFrame = self.ButtonFrame;

	if(costsCurrency) then 
		self:UpdateCurrency(); 
	elseif(costsMoney) then 
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

	MoneyFrame_Update(self.ButtonFrame.MoneyFrame:GetName(),  self.cost, false);
	if GetMoney() < (self.cost) then
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
	if ( self.cost > amount ) then
		self.ButtonFrame.Currency.count:SetTextColor(RED_FONT_COLOR:GetRGB());
	else
		self.ButtonFrame.Currency.count:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end
	self:UpdateActionButtonState();
end

function ItemInteractionMixin:GetButtonTooltip()
	return self.buttonTooltip;
end

function ItemInteractionMixin:GetConfirmationInfo()
	if (self.confirmationDescription ~= nil) then
		return self.confirmationDescription, self.confirmationText;
	end

	return nil, nil;
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

		if FlagsUtil.IsSet(self.flags, Enum.UIItemInteractionFlags.ConfirmationHasDelay) then
			StaticPopup_Show("ITEM_INTERACTION_CONFIRMATION_DELAYED", textArg1, textArg2, data);
		else
			StaticPopup_Show("ITEM_INTERACTION_CONFIRMATION", textArg1, textArg2, data);
		end
	else
		C_ItemInteraction.PerformItemInteraction();
	end
end

-- Enables or disables the button to interact with the item based off of your currency amount and if you have an item in the slot.
function ItemInteractionMixin:UpdateActionButtonState()
	if(self:CostsCurrency()) then 
		local amount = C_CurrencyInfo.GetCurrencyInfo(self.currencyTypeId).quantity;
		self.ButtonFrame.ActionButton:SetEnabled(self.itemLocation ~= nil and amount >= self.cost);
	elseif (self:CostsGold()) then
		self.ButtonFrame.ActionButton:SetEnabled(self.itemLocation ~= nil and GetMoney() >= self.cost);
	else 
		self.ButtonFrame.ActionButton:SetEnabled(self.itemLocation ~= nil);
	end 
end

function ItemInteractionMixin:SetInteractionItem(itemLocation)
	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end

	self.DescriptionCurrencies:Hide();

	self.itemLocation = itemLocation;

	if (itemLocation) then
		if self.tutorialBitFlag and not GetCVarBitfield("closedInfoFrames", self.tutorialBitFlag) then
			HelpTip:Hide(self, self.tutorialText);
			SetCVarBitfield("closedInfoFrames", self.tutorialBitFlag, true);
		end

		if (self.interactionType == Enum.UIItemInteractionType.RunecarverScrapping) then
			local costs = C_LegendaryCrafting.GetRuneforgeLegendaryCost(itemLocation);
			RuneforgeUtil.SetCurrencyCosts(self.DescriptionCurrencies, costs);
			self.DescriptionCurrencies:Show();
		end
	end

	self:UpdateDescriptionColor();

	PlaySound(self.dropInSlotSoundKitId);
	self.ItemSlot:RefreshIcon();
	self.ItemSlot:RefreshTooltip();
	self:UpdateActionButtonState();

	StaticPopup_Hide("ITEM_INTERACTION_CONFIRMATION");
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
	if self:GetParent():GetItemLocation() then
		local item = Item:CreateFromItemLocation(self:GetParent():GetItemLocation());
		self.itemDataLoadedCancelFunc = item:ContinueWithCancelOnItemLoad(function()
			self.Icon:SetTexture(item:GetItemIcon());
			self.Icon:Show();
			self.GlowOverlay:Show();
		end);
	end
end

function ItemInteractionItemSlotMixin:RefreshTooltip()
	if GetMouseFocus() == self then
		self:OnMouseEnter();
	else
		self:OnMouseLeave();
	end
end

function ItemInteractionItemSlotMixin:OnClick(button)
	if button == "RightButton" then
		C_ItemInteraction.ClearPendingItem(); 
	else
		C_ItemInteraction.SetPendingItem(C_Cursor.GetCursorItem());
	end
end

function ItemInteractionItemSlotMixin:OnDragStart()
	C_ItemInteraction.ClearPendingItem();
end

function ItemInteractionItemSlotMixin:OnReceiveDrag()
	C_ItemInteraction.SetPendingItem(C_Cursor.GetCursorItem());
end

function ItemInteractionItemSlotMixin:OnMouseEnter()
	local itemLocation = self:GetParent():GetItemLocation(); 
	if itemLocation then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		if (self:GetParent():GetInteractionType() == Enum.UIItemInteractionType.CleanseCorruption) then
			C_ItemInteraction.SetCorruptionReforgerItemTooltip();
		else 
			ItemLocation:ApplyLocationToTooltip(itemLocation, GameTooltip);
		end
		GameTooltip:Show();
	else
		GameTooltip_Hide();
	end
end

function ItemInteractionItemSlotMixin:OnMouseLeave()
	GameTooltip_Hide();
end

------------------ Item Action Button Functions ----------------------------
ItemInteractionActionButtonMixin = {};

function ItemInteractionActionButtonMixin:OnMouseEnter()
	local interactFrame = self:GetParent():GetParent(); 
	if (interactFrame:CostsGold()) then
		if (not self:IsEnabled() and GetMoney() < interactFrame:GetCost()) then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
			GameTooltip_AddColoredLine(GameTooltip, NOT_ENOUGH_GOLD, RED_FONT_COLOR);
			GameTooltip:Show();
		else
			GameTooltip_Hide();
		end
	elseif(interactFrame:CostsCurrency()) then 
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(interactFrame.currencyTypeId);
		local name = currencyInfo.name;
		local amount = currencyInfo.quantity;
		if (not self:IsEnabled() and amount < interactFrame:GetCost()) then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
			GameTooltip_AddColoredLine(GameTooltip, NOT_ENOUGH_CURRENCY:format(name), RED_FONT_COLOR);
			GameTooltip:Show(); 
		else
			GameTooltip_Hide();
		end
	else
		local buttonTooltip = interactFrame:GetButtonTooltip();
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

function ItemInteractionActionButtonMixin:OnMouseLeave()
	GameTooltip_Hide();
end

function ItemInteractionActionButtonMixin:OnClick()
	self:GetParent():GetParent():InteractWithItem();
end 