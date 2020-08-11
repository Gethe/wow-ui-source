UIPanelWindows["ItemInteractionFrame"] = {area = "left", pushable = 3, showFailedFunc = C_ItemInteraction.Reset, };

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

function ItemInteractionMixin:GetFrameType()
	return self.frameType;
end 

function ItemInteractionMixin:GetCost()
	return self.cost;
end 

function ItemInteractionMixin:CostsGold() 
	return not self.currencyTypeId and self.cost ~= nil; 
end 

function ItemInteractionMixin:CostsCurrency()
	return self.currencyTypeId and self.cost ~= nil; 
end 

--------------- Base Frame Functions -----------------------
function ItemInteractionMixin:OnEvent(event, ...)
	if(event == "PLAYER_MONEY") or (event == "ITEM_INTERACTION_ITEM_SELECTION_UPDATED") then
		self:UpdateMoney();
		if (event == "ITEM_INTERACTION_ITEM_SELECTION_UPDATED") then
			local itemLocation = ...;
			if self:GetItemLocation() and self:GetItemLocation():IsEqualTo(itemLocation) then
				self:SetInteractionItem(nil);
			elseif (itemLocation) then 
				self:SetInteractionItem(itemLocation)
			else 
				self:SetInteractionItem(nil);
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
				offsetX = -10,
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
	self.tutorialText = frameData.tutorialText; 
	self.cost = frameData.cost; 
	self.frameType = frameData.frameType; 
	self.currencyTypeId = frameData.currencyTypeId; 
	self.dropInSlotSoundKitId = frameData.dropInSlotSoundKitId or  SOUNDKIT.PUT_DOWN_SMALL_CHAIN;

	local frameTextureKitRegions = {
		[self.Background] = "%s-background",
		[self.portrait] = "%s-portrait",
		[self.ItemSlot.GlowOverlay] = "%s-glow",
	}

	SetupTextureKitOnFrames(frameData.textureKit, frameTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	if (frameData.description) then 
		self.Description:SetText(frameData.description); 
		self.Description:Show(); 
	end
	
	self:SetupFrameSpecificData();
end 

-- For each specific frame, a new tutorial bit flag is required. So add to this when you add a new frame type.
function ItemInteractionMixin:SetupFrameSpecificData()
	if (self.frameType == Enum.ItemInteractionFrameType.CleanseCorruption) then 
		self.tutorialBitFlag = LE_FRAME_TUTORIAL_CORRUPTION_CLEANSER;
	else 
		self.tutorialBitFlag = nil
	end 
end 

function ItemInteractionMixin:UpdateCostFrame()
	local costsMoney = self:CostsGold();
	local costsCurrency = self:CostsCurrency();
	local hasPrice = costsMoney or costsCurrency; 
	local buttonFrame = self.ButtonFrame;

	if(costsCurrency) then 
		self:UpdateCurrency(); 
	elseif(costsMoney) then 
		self:UpdateMoney();
	end
	buttonFrame.Currency:SetShown(hasPrice and costsCurrency);
	buttonFrame.MoneyFrame:SetShown(hasPrice and costsMoney);
	buttonFrame.BlackBorder:SetShown(hasPrice); 
	buttonFrame.MoneyFrameEdge:SetShown(hasPrice);

	buttonFrame.ActionButton:ClearAllPoints(); 

	if(not hasPrice) then 
		buttonFrame.ActionButton:SetPoint("BOTTOM", 0, 5);
	else 
		buttonFrame.ActionButton:SetPoint("BOTTOMRIGHT", -2, 5);
	end
end 

function ItemInteractionMixin:UpdateMoney()
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

function ItemInteractionMixin:InteractWithItem()
	local item = Item:CreateFromItemLocation(self.itemLocation);
	C_ItemInteraction.PerformItemInteraction();
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

	self.itemLocation = itemLocation;
	if (itemLocation and self.tutorialBitFlag) then
		if not GetCVarBitfield("closedInfoFrames", self.tutorialBitFlag) then
			HelpTip:Hide(self, self.tutorialText);
			SetCVarBitfield("closedInfoFrames", self.tutorialBitFlag, true);
		end
	end

	PlaySound(self.dropInSlotSoundKitId);
	self.ItemSlot:RefreshIcon();
	self.ItemSlot:RefreshTooltip();
	self:UpdateActionButtonState();
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
		if (self:GetParent():GetFrameType() == Enum.ItemInteractionFrameType.CleanseCorruption) then
			C_ItemInteraction.SetCorruptionReforgerItemTooltip();
		else 
			GameTooltip:SetInventoryItem("player", itemLocation:GetEquipmentSlot());
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
	end 
end

function ItemInteractionActionButtonMixin:OnMouseLeave()
	GameTooltip_Hide();
end

function ItemInteractionActionButtonMixin:OnClick()
	self:GetParent():GetParent():InteractWithItem();
end 