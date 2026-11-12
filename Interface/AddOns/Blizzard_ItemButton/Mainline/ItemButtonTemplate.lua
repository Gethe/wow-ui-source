function GetFormattedItemQuantity(quantity, maxQuantity)
	if quantity > (maxQuantity or 9999) then
		return "*";
	end;

	return quantity;
end

function SetItemButtonCount(button, count, abbreviate)
	if ( not button ) then
		return;
	end

	if ( not count ) then
		count = 0;
	end

	button.count = count;
	local countString = button.Count or _G[button:GetName().."Count"];
	local minDisplayCount = button.minDisplayCount or 1;
	if ( count > minDisplayCount or (button.isBag and count > 0)) then
		if ( abbreviate ) then
			count = AbbreviateNumbers(count);
		else
			count = GetFormattedItemQuantity(count, button.maxDisplayCount);
		end

		countString:SetText(count);
		countString:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		countString:Show();
	else
		countString:Hide();
	end
end

function GetItemButtonCount(button)
	return button.count;
end

function SetItemButtonStock(button, numInStock)
	if ( not button ) then
		return;
	end

	if ( not numInStock ) then
		numInStock = "";
	end

	button.numInStock = numInStock;
	if ( numInStock > 0 ) then
		_G[button:GetName().."Stock"]:SetFormattedText(MERCHANT_STOCK, numInStock);
		_G[button:GetName().."Stock"]:Show();
	else
		_G[button:GetName().."Stock"]:Hide();
	end
end

local backgroundTextureIsAtlas = true;
local function GetItemButtonBackgroundTexture_Base(button)
	if button.emptyBackgroundTexture then
		return button.emptyBackgroundTexture;
	elseif button.emptyBackgroundAtlas then
		return button.emptyBackgroundAtlas, backgroundTextureIsAtlas;
	end
end

function GetItemButtonBackgroundTexture(button)
	if button then
		if button.GetItemButtonBackgroundTexture then
			return button:GetItemButtonBackgroundTexture();
		else
			return GetItemButtonBackgroundTexture_Base(button);
		end
	end
end

local function SetItemButtonTexture_Base(button, texture)
	local icon = GetItemButtonIconTexture(button);
	if icon then
		local isAtlas;
		if not texture then
			texture, isAtlas = GetItemButtonBackgroundTexture(button);
		end

		icon:SetShown(texture ~= nil);

		-- Both SetAtlas and SetTexture carry the previous tex coords forward, so a texture that has
		-- ever held a degenerate atlas member stays corrupted until the coords are explicitly reset.
		if isAtlas then
			local useAtlasSize, filterMode, resetTexCoords = false, nil, true;
			icon:SetAtlas(texture, useAtlasSize, filterMode, resetTexCoords);
		else
			icon:SetTexture(texture);
			icon:SetTexCoord(0, 1, 0, 1);
		end
	end
end

function SetItemButtonTexture(button, texture)
	if button then
		if button.SetItemButtonTexture then
			button:SetItemButtonTexture(texture);
		else
			SetItemButtonTexture_Base(button, texture);
		end
	end
end

local function SetItemButtonTextureVertexColor_Base(button, r, g, b)
	local icon = GetItemButtonIconTexture(button);
	if icon then
		icon:SetVertexColor(r, g, b);
	end
end

function SetItemButtonTextureVertexColor(button, r, g, b)
	if button then
		if button.SetItemButtonTextureVertexColor then
			button:SetItemButtonTextureVertexColor(r, g, b);
		else
			SetItemButtonTextureVertexColor_Base(button, r, g, b);
		end
	end
end

local function SetItemButtonBorderVertexColor_Base(button, r, g, b)
	if button.IconBorder then
		button.IconBorder:SetVertexColor(r, g, b);
	end
end

function SetItemButtonBorderVertexColor(button, r, g, b)
	if button then
		if button.SetItemButtonBorderVertexColor then
			button:SetItemButtonBorderVertexColor(r, g, b);
		else
			SetItemButtonBorderVertexColor_Base(button, r, g, b);
		end
	end
end

function SetItemButtonDesaturated(button, desaturated)
	if button then
		local icon = GetItemButtonIconTexture(button);
		if icon then
			icon:SetDesaturated(desaturated);
		end
	end
end

function SetItemButtonNormalTextureVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end

	button:GetNormalTexture():SetVertexColor(r, g, b);
end

function SetItemButtonNameFrameVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end

	local nameFrame = button.NameFrame or _G[button:GetName().."NameFrame"];
	nameFrame:SetVertexColor(r, g, b);
end

function SetItemButtonSlotVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end

	button.SlotTexture:SetVertexColor(r, g, b);
end

local function ClearOverlay(overlay)
	if overlay then
		overlay:SetVertexColor(1,1,1);
		overlay:SetAtlas(nil);
		overlay:SetTexture(nil);
		overlay:Hide();
	end
end

local OverlayKeys = {"IconOverlay", "IconOverlay2", "ProfessionQualityOverlay"};
function ClearItemButtonOverlay(button)
	for _, key in ipairs(OverlayKeys) do
		ClearOverlay(button[key]);
	end
	button.isProfessionItem = false;
	button.isCraftedItem = false;
end

function SetItemButtonBorder_Base(button, asset, isAtlas)
	button.IconBorder:SetShown(asset ~= nil);
	if asset then
		if isAtlas then
			button.IconBorder:SetAtlas(asset);
		else
			button.IconBorder:SetTexture(asset);
		end
	end
end

function SetItemButtonBorder(button, asset, isAtlas)
	if button then
		if button.SetItemButtonBorder then
			button:SetItemButtonBorder(asset, isAtlas);
		else
			SetItemButtonBorder_Base(button, asset, isAtlas);
		end
	end
end

local function SetItemButtonQuality_Base(button, quality, itemIDOrLink, suppressOverlays, isBound, ignoreColorOverrides)
	ClearItemButtonOverlay(button);

	local color = nil;
	if ignoreColorOverrides then
		color = ColorManager.GetDefaultColorDataForBagItemQuality(quality);
	else
		color = ColorManager.GetColorDataForBagItemQuality(quality);
	end

	if not suppressOverlays and itemIDOrLink then
		SetItemButtonOverlay(button, itemIDOrLink, quality, isBound);
	end

	if color then
		if itemIDOrLink then
			if C_ItemSocketInfo.IsArtifactRelicItem(itemIDOrLink) then
				SetItemButtonBorder(button, [[Interface\Artifacts\RelicIconFrame]]);
			else
				SetItemButtonBorder(button, [[Interface\Common\WhiteIconFrame]]);
			end
		else
			SetItemButtonBorder(button, [[Interface\Common\WhiteIconFrame]]);
		end

		SetItemButtonBorderVertexColor(button, color.r, color.g, color.b);
	else
		SetItemButtonBorder(button);
	end
end

function SetItemButtonQuality(button, quality, itemIDOrLink, suppressOverlays, isBound, ignoreColorOverrides)
	if button then
		if button.SetItemButtonQuality then
			button:SetItemButtonQuality(quality, itemIDOrLink, suppressOverlays, isBound, ignoreColorOverrides);
		else
			SetItemButtonQuality_Base(button, quality, itemIDOrLink, suppressOverlays, isBound, ignoreColorOverrides);
		end
	end
end

local function GetButtonOverlayQualityColor(quality)
	local color = ColorManager.GetColorDataForBagItemQuality(quality);
	if not color then
		quality = Enum.ItemQuality.Common;
	end
	return ColorManager.GetColorDataForBagItemQuality(quality);
end

-- Remember to update the OverlayKeys table if adding an overlay texture here.
function SetItemButtonOverlay(button, itemIDOrLink, quality, isBound)
	ClearItemButtonOverlay(button);

	if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemIDOrLink) then
		button.IconOverlay:SetAtlas("AzeriteIconFrame");
		button.IconOverlay:Show();
	elseif C_Item.IsCorruptedItem(itemIDOrLink) then
		button.IconOverlay:SetAtlas("Nzoth-inventory-icon");
		button.IconOverlay:Show();
	elseif C_Item.IsCosmeticItem(itemIDOrLink) then
		button.IconOverlay:SetAtlas("CosmeticIconFrame");
		button.IconOverlay:Show();
	elseif C_Soulbinds.IsItemConduitByItemInfo(itemIDOrLink) then
		local color = GetButtonOverlayQualityColor(quality);
		button.IconOverlay:SetVertexColor(color.r, color.g, color.b);
		button.IconOverlay:SetAtlas("ConduitIconFrame");
		button.IconOverlay:Show();

		-- If this is missing, the texture will make it apparant instead of error.
		if button.IconOverlay2 then
			button.IconOverlay2:SetAtlas("ConduitIconFrame-Corners");
			button.IconOverlay2:Show();
		end
	elseif C_Item.IsCurioItem(itemIDOrLink) or C_Item.IsRelicItem(itemIDOrLink) then
		local color = GetButtonOverlayQualityColor(quality);
		button.IconOverlay:SetVertexColor(color.r, color.g, color.b);
		button.IconOverlay:SetAtlas("delves-curios-icon-border");
		button.IconOverlay:Show();
	elseif C_Item.IsDecorItem(itemIDOrLink) then
		local color = HIGHLIGHT_FONT_COLOR;
		button.IconOverlay:SetVertexColor(color.r, color.g, color.b);
		button.IconOverlay:SetAtlas("housing-item-wood-frame_64");
		button.IconOverlay:Show();
	else
		-- The reagent slots contain this button/mixin, however there's a nuance in the button behavior that the overlay needs to be
		-- hidden if more than 1 quality of reagent is assigned to the slot. Those slots have a separate overlay that is
		-- managed independently of this, though it still uses the rest of this button's behaviors.
		SetItemCraftingQualityOverlay(button, itemIDOrLink);
	end
end

local function SetupCraftingQualityOverlay(button, qualityInfo)
	if not qualityInfo then
		return;
	end

	if not button.ProfessionQualityOverlay then
		button.ProfessionQualityOverlay = button:CreateTexture(nil, "OVERLAY");
		button.ProfessionQualityOverlay:SetPoint("TOPLEFT", -3, 2);
		button.ProfessionQualityOverlay:SetDrawLayer("OVERLAY", 7);
	end

	local atlas = qualityInfo.iconInventory;
	button.ProfessionQualityOverlay:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	ItemButtonMixin.UpdateCraftedProfessionsQualityShown(button);
	EventRegistry:RegisterCallback("ItemButton.UpdateCraftedProfessionQualityShown", ItemButtonMixin.UpdateCraftedProfessionsQualityShown, button);
end

function SetItemCraftingQualityOverlayOverride(button, qualityInfo)
	button.professionQualityOverlayOverride = qualityInfo;
	SetupCraftingQualityOverlay(button, qualityInfo);
end

function SetItemCraftingQualityOverlay(button, itemIDOrLink)
	if button.noProfessionQualityOverlay then
		return;
	end

	local qualityInfo = nil;
	if itemIDOrLink  then
		qualityInfo = C_TradeSkillUI.GetItemReagentQualityInfo(itemIDOrLink);
		if qualityInfo then
			button.isCraftedItem = false;
		else
			qualityInfo = C_TradeSkillUI.GetItemCraftedQualityInfo(itemIDOrLink);
			button.isCraftedItem = qualityInfo ~= nil;
		end

		button.isProfessionItem = qualityInfo ~= nil;
	else
		button.isProfessionItem = false;
	end

	if button.professionQualityOverlayOverride then
		qualityInfo = button.professionQualityOverlayOverride;
	end

	if qualityInfo then
		SetupCraftingQualityOverlay(button, qualityInfo);
	end
end

function ClearItemCraftingQualityOverlay(button)
	ClearOverlay(button.ProfessionQualityOverlay);
end

function SetItemButtonReagentCount(button, reagentCount, playerReagentCount)
	local playerReagentCountAbbreviated = AbbreviateNumbers(playerReagentCount);
	button.Count:SetFormattedText(TRADESKILL_REAGENT_COUNT, playerReagentCountAbbreviated, reagentCount);
	--fix text overflow when the button count is too high
	if math.floor(button.Count:GetStringWidth()) > math.floor(button.Icon:GetWidth() + .5) then
		--round count width down because the leftmost number can overflow slightly without looking bad
		--round icon width because it should always be an int, but sometimes it's a slightly off float
		button.Count:SetFormattedText("%s\n/%s", playerReagentCountAbbreviated, reagentCount);
	end
end

function HandleModifiedItemClick(link, itemLocation)
	if ( not link ) then
		return false;
	end
	if ( IsModifiedClick("CHATLINK") ) then
		local linkType = string.match(link, "|H([^:]+)");
		if ( linkType == "instancelock" ) then	--People can't re-link instances that aren't their own.
			local guid = string.match(link, "|Hinstancelock:([^:]+)");
			if ( not string.find(UnitGUID("player"), guid) ) then
				return true;
			end
		end
		if ( ChatFrameUtil.InsertLink(link) ) then
			return true;
		end
	end
	if ( IsModifiedClick("DRESSUP") ) then
		return DressUpItemLocation(itemLocation) or DressUpLink(link);
	end
	if ( IsModifiedClick("EXPANDITEM") ) then
		if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(link) then
			OpenAzeriteEmpoweredItemUIFromLink(link);
			return true;
		end

		local skillLineID = C_TradeSkillUI.GetSkillLineForGear(link);
		if skillLineID then
			OpenProfessionUIToSkillLine(skillLineID);
			return true;
		end
	end
	return false;
end

function ItemButtonMixin:SetItemButtonTexture(texture)
	SetItemButtonTexture_Base(self, texture);
end

function ItemButtonMixin:SetItemButtonTextureVertexColor(r, g, b)
	SetItemButtonTextureVertexColor_Base(self, r, g, b);
end

function ItemButtonMixin:SetItemButtonQuality(quality, itemIDOrLink, suppressOverlays, isBound, ignoreColorOverrides)
	SetItemButtonQuality_Base(self, quality, itemIDOrLink, suppressOverlays, isBound, ignoreColorOverrides);
end

function ItemButtonMixin:SetItemButtonBorderVertexColor(r, g, b)
	SetItemButtonBorderVertexColor_Base(self, r, g, b);
end

function ItemButtonMixin:GetItemButtonBackgroundTexture()
	return GetItemButtonBackgroundTexture_Base(self);
end

CircularGiantItemButtonMixin = {}

function CircularGiantItemButtonMixin:SetItemButtonQuality(quality, itemIDOrLink, suppressOverlays, isBound, ignoreColorOverrides)
	ClearItemButtonOverlay(self);

	if quality then
		local isAtlas = true;
		local atlasData = ColorManager.GetAtlasDataForAuctionHouseItemQuality(quality);
		SetItemButtonBorder(self, atlasData.atlas, isAtlas);

		if atlasData.overrideColor then
			SetItemButtonBorderVertexColor(self, atlasData.overrideColor.r, atlasData.overrideColor.g, atlasData.overrideColor.b);
		else
			SetItemButtonBorderVertexColor(self, 1, 1, 1);
		end
	else
		SetItemButtonBorder(self);
	end
end

local EnchantingItemButtonEvents = {
	"ENCHANT_SPELL_COMPLETED",
};

EnchantingItemButtonAnimMixin = {};

function EnchantingItemButtonAnimMixin:OnLoad()
	local function AugmentBorderAnimOnFinished()
		self.AugmentBorderAnimTexture:Hide();
	end

	if self.AugmentBorderAnim then
		self.AugmentBorderAnim:SetScript("OnFinished", AugmentBorderAnimOnFinished);
	end
end

function EnchantingItemButtonAnimMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, EnchantingItemButtonEvents);
end

function EnchantingItemButtonAnimMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, EnchantingItemButtonEvents);
end

local ENCHANT_BURST_EFFECT = 175;

function EnchantingItemButtonAnimMixin:OnEvent(event, ...)
	if event == "ENCHANT_SPELL_COMPLETED" then
		local successful, enchantedItem = ...;
		if not successful or not enchantedItem or not enchantedItem:IsValid() then
			return;
		end

		local itemLocation = self:GetItemLocation();
		if itemLocation and itemLocation:IsValid() and itemLocation:IsEqualTo(enchantedItem) then
			local function OnEnchantItemEffectResolved()
				self.gainEnchantEffect = nil;
			end

			local source, target, onfinishedcallback, onresolutioncallback = self, self, nil, OnEnchantItemEffectResolved;
			self.gainEnchantEffect = GlobalFXDialogModelScene:AddEffect(ENCHANT_BURST_EFFECT, source, target, onfinishedcallback, onresolutioncallback);

			PlaySound(SOUNDKIT.ENCHANTMENT_ENCHANT_ANIMATION_START);
			self.AugmentBorderAnimTexture:Show();
			self.AugmentBorderAnim:Play();
		end
	end
end

function EnchantingItemButtonAnimMixin:SetItemLocationCallback(callback)
	self.GetItemLocationCallback = callback;
end

function EnchantingItemButtonAnimMixin:GetItemLocation()
	if self.GetItemLocationCallback then
		return self.GetItemLocationCallback();
	end

	return nil;
end

ItemSlotDropState = EnumUtil.MakeEnum("None", "Permitted", "Restricted");

-- Shows a gamepad-only overlay on an item slot for whether a cursor item can be dropped on it.
-- Inherit ItemSlotDropStateTemplate (needs a DropStateTexture child), call InitDropState on load,
-- then drive it with SetDropState (permitted/restricted) and SetDropFocused (hover or gamepad focus).
ItemSlotDropStateMixin = {};

function ItemSlotDropStateMixin:InitDropState()
	self.dropState = ItemSlotDropState.None;
	self.showDropStateWhenUnfocused = false;
	self.dropFocused = false;
end

function ItemSlotDropStateMixin:SetDropState(dropState, showWhenUnfocused)
	self.dropState = dropState;
	self.showDropStateWhenUnfocused = showWhenUnfocused;
	self:UpdateDropStateVisual();
end

function ItemSlotDropStateMixin:SetDropFocused(focused)
	self.dropFocused = focused;
	self:UpdateDropStateVisual();
end

function ItemSlotDropStateMixin:UpdateDropStateVisual()
	local atlas = nil;
	if self.dropState == ItemSlotDropState.Permitted then
		if self.dropFocused then
			atlas = "ItemSlotState_DropPermittedFocused";
		elseif self.showDropStateWhenUnfocused then
			atlas = "ItemSlotState_DropPermitted";
		end
	elseif self.dropState == ItemSlotDropState.Restricted and self.dropFocused then
		atlas = "ItemSlotState_DropRestrictedFocused";
	end

	local dropStateTexture = self.DropStateTexture;
	if atlas then
		dropStateTexture:SetAtlas(atlas);
	end
	dropStateTexture:SetShown(atlas ~= nil);

	-- The drop state replaces the gamepad focus highlight while shown.
	if self.Highlight then
		self.Highlight:SetShown(atlas == nil);
	end
end

ItemSlotDropStateBagRules = {};

local function GetEquippedBagIDForInventorySlot(inventorySlot)
	for bagID = Enum.BagIndex.Bag_1, Enum.BagIndex.ReagentBag do
		if C_Container.ContainerIDToInventoryID(bagID) == inventorySlot then
			return bagID;
		end
	end

	return nil;
end

local function BuildItemInfo(itemLocation)
	local itemID = C_Item.GetItemID(itemLocation);
	local classID, subclassID = select(6, C_Item.GetItemInfoInstant(itemID));
	local isBag = C_Item.GetItemInventoryType(itemLocation) == Enum.InventoryType.IndexBagType;
	local isCraftingReagent = select(17, C_Item.GetItemInfo(itemID));

	return {
		itemFamily = C_Item.GetItemFamily(itemID) or 0,
		isBag = isBag,
		isReagentBag = isBag and classID == Enum.ItemClass.Container and subclassID == Enum.ItemContainerSubclass.Reagent,
		isCraftingReagent = isCraftingReagent,
		isKey = classID == Enum.ItemClass.Key,
	};
end

function ItemSlotDropStateBagRules:Init()
	self.bagStates = {};
	self.cursorInfo = nil;

	EventRegistry:RegisterFrameEventAndCallback("CURSOR_CHANGED", self.Refresh, self);
	EventRegistry:RegisterFrameEventAndCallback("BAG_UPDATE_DELAYED", self.Refresh, self);
end

function ItemSlotDropStateBagRules:BuildCursorInfo()
	local cursorItemLocation = C_Cursor.GetCursorItem();
	if not cursorItemLocation or not cursorItemLocation:IsValid() then
		return nil;
	end

	local itemInfo = BuildItemInfo(cursorItemLocation);
	local cursorInfo = { itemInfo = itemInfo };

	if cursorItemLocation:IsBagAndSlot() then
		cursorInfo.sourceContainerBagID = cursorItemLocation:GetBagAndSlot();
	elseif itemInfo.isBag and cursorItemLocation:IsEquipmentSlot() then
		local sourceBagID = GetEquippedBagIDForInventorySlot(cursorItemLocation:GetEquipmentSlot());
		cursorInfo.sourceBagID = sourceBagID;
		itemInfo.bagHasContents = sourceBagID and C_Container.GetContainerNumFreeSlots(sourceBagID) < C_Container.GetContainerNumSlots(sourceBagID);
	end

	return cursorInfo;
end

-- Bags with no specialization return this family; it holds any item.
local BAG_FAMILY_GENERAL = 0;

function ItemSlotDropStateBagRules:GetDropStateForBag(bagID, itemInfo, sourceBagID)
	if bagID == sourceBagID then -- A bag can't be placed inside itself.
		return ItemSlotDropState.Restricted;
	elseif bagID == Enum.BagIndex.Keyring then -- The keyring returns the general family, so it can't go through the family check below.
		return itemInfo.isKey and ItemSlotDropState.Permitted or ItemSlotDropState.Restricted;
	elseif bagID == Enum.BagIndex.ReagentBag and not itemInfo.isCraftingReagent then -- The reagent bag returns the general family, so it can't go through the family check below.
		return ItemSlotDropState.Restricted;
	end

	if itemInfo.isBag and itemInfo.bagHasContents then
		return ItemSlotDropState.Restricted;
	end

	local _numFreeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(bagID);
	bagFamily = bagFamily or BAG_FAMILY_GENERAL;

	if itemInfo.isBag then
		-- A bag's item family describes what it holds, so bags only fit in general bags.
		return (bagFamily == BAG_FAMILY_GENERAL) and ItemSlotDropState.Permitted or ItemSlotDropState.Restricted;
	end

	if bagFamily ~= BAG_FAMILY_GENERAL and bit.band(itemInfo.itemFamily, bagFamily) == 0 then
		return ItemSlotDropState.Restricted;
	end

	return ItemSlotDropState.Permitted;
end

function ItemSlotDropStateBagRules:Refresh()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	local cursorInfo = self:BuildCursorInfo();
	if not cursorInfo and not self.cursorInfo then
		return;
	end

	self.cursorInfo = cursorInfo;
	wipe(self.bagStates);

	if cursorInfo then
		for bagID = Enum.BagIndex.Backpack, Enum.BagIndex.ReagentBag do
			self.bagStates[bagID] = self:GetDropStateForBag(bagID, cursorInfo.itemInfo, cursorInfo.sourceBagID);
		end
		self.bagStates[Enum.BagIndex.Keyring] = self:GetDropStateForBag(Enum.BagIndex.Keyring, cursorInfo.itemInfo, cursorInfo.sourceBagID);
	end

	EventRegistry:TriggerEvent("ItemSlotDropState.BagStatesUpdated");
end

function ItemSlotDropStateBagRules:IsItemOnCursor()
	return self.cursorInfo ~= nil;
end

function ItemSlotDropStateBagRules:IsBagOnCursor()
	return self.cursorInfo ~= nil and self.cursorInfo.itemInfo.isBag;
end

function ItemSlotDropStateBagRules:GetBagState(bagID)
	return self.bagStates[bagID] or ItemSlotDropState.None;
end

function ItemSlotDropStateBagRules:GetContainerSlotBagState(bagID, slotID)
	local bagState = self:GetBagState(bagID);
	local cursorInfo = self.cursorInfo;
	if bagState ~= ItemSlotDropState.Permitted or not cursorInfo then
		return bagState;
	end

	local itemLocation = ItemLocation:CreateFromBagAndSlot(bagID, slotID);
	if not C_Item.DoesItemExist(itemLocation) then
		return bagState;
	end

	-- The occupant takes the cursor item's old slot, so it has to fit there.
	local occupantInfo = BuildItemInfo(itemLocation);
	if cursorInfo.sourceBagID then
		local isReagentBagSlot = cursorInfo.sourceBagID == Enum.BagIndex.ReagentBag;
		if not occupantInfo.isBag or occupantInfo.isReagentBag ~= isReagentBagSlot then
			return ItemSlotDropState.Restricted;
		end
	elseif cursorInfo.sourceContainerBagID and cursorInfo.sourceContainerBagID ~= bagID then
		return self:GetDropStateForBag(cursorInfo.sourceContainerBagID, occupantInfo);
	end

	return bagState;
end

function ItemSlotDropStateBagRules:GetBagSlotState(bagID, hasBag)
	local cursorInfo = self.cursorInfo;
	if not cursorInfo then
		return ItemSlotDropState.None;
	end

	if cursorInfo.itemInfo.isBag then
		if bagID == Enum.BagIndex.Backpack then
			return self:GetBagState(bagID);
		end

		if bagID == Enum.BagIndex.Keyring then
			return ItemSlotDropState.Restricted;
		end

		local isReagentBagSlot = bagID == Enum.BagIndex.ReagentBag;
		if isReagentBagSlot ~= cursorInfo.itemInfo.isReagentBag then
			return ItemSlotDropState.Restricted;
		end

		-- The equipped bag moves into the container slot the cursor bag came from, transferring all items if possible.
		if hasBag and cursorInfo.sourceContainerBagID then
			local equippedLocation = ItemLocation:CreateFromEquipmentSlot(C_Container.ContainerIDToInventoryID(bagID));
			local equippedInfo = BuildItemInfo(equippedLocation);
			return self:GetDropStateForBag(cursorInfo.sourceContainerBagID, equippedInfo, bagID);
		end

		return ItemSlotDropState.Permitted;
	end

	if not hasBag then
		return ItemSlotDropState.Restricted;
	end

	local bagState = self:GetBagState(bagID);
	-- The keyring's free slot count is unreliable, so it is excluded from the full check.
	if bagState == ItemSlotDropState.Permitted and bagID ~= Enum.BagIndex.Keyring and C_Container.GetContainerNumFreeSlots(bagID) == 0 then
		return ItemSlotDropState.Restricted;
	end

	return bagState;
end

ItemSlotDropStateBagRules:Init();

