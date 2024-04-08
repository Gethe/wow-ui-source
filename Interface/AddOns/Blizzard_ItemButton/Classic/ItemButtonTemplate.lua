
function SetItemButtonCount(button, count, abbreviate)
	if ( not button ) then
		return;
	end

	if ( not count ) then
		count = 0;
	end

	button.count = count;
	local countString = button.Count or _G[button:GetName().."Count"];
	if ( count > 1 or (button.isBag and count > 0) ) then
		if ( abbreviate ) then
			count = AbbreviateNumbers(count);
		elseif ( count > (button.maxDisplayCount or 9999) ) then
			count = "*";
		end
		countString:SetText(count);
		countString:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		countString:Show();
	else
		countString:Hide();
	end
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

function SetItemButtonTexture(button, texture)
	if ( not button ) then
		return;
	end
	local icon = button.Icon or button.icon or _G[button:GetName().."IconTexture"];
	if ( texture ) then
		icon:Show();
	else
		icon:Hide();
	end
	icon:SetTexture(texture);
end

function SetItemButtonSubTexture(button, texture)
	if ( not button ) then
		return;
	end
	local icon = button.subicon or _G[button:GetName().."SubIconTexture"];
	if ( texture ) then
		icon:Show();
	else
		icon:Hide();
	end
	icon:SetTexture(texture);
end

function SetItemButtonTextureVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end
	
	local icon = button.Icon or button.icon or _G[button:GetName().."IconTexture"];
	icon:SetVertexColor(r, g, b);
end

function SetItemButtonDesaturated(button, desaturated)
	if ( not button ) then
		return;
	end
	local icon = button.Icon or button.icon or _G[button:GetName().."IconTexture"];
	if ( not icon ) then
		return;
	end
	
	icon:SetDesaturated(desaturated);
end

function SetItemButtonNormalTextureVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end
	
	_G[button:GetName().."NormalTexture"]:SetVertexColor(r, g, b);
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
	
	_G[button:GetName().."SlotTexture"]:SetVertexColor(r, g, b);
end

function SetItemButtonQuality(button, quality, itemIDOrLink, suppressOverlays)
	if itemIDOrLink then
		button.IconBorder:SetTexture([[Interface\Common\WhiteIconFrame]]);
	else
		button.IconBorder:SetTexture([[Interface\Common\WhiteIconFrame]]);
	end
	button.IconOverlay:Hide();

	--[[if quality then
		if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
			button.IconBorder:Show();
			button.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
		else
			button.IconBorder:Hide();
		end
	else
		button.IconBorder:Hide();
	end]]
	button.IconBorder:Hide();
end

function HandleModifiedItemClick(link)
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
		if ( ChatEdit_InsertLink(link) ) then
			return true;
		elseif ( SocialPostFrame and Social_IsShown() and Social_InsertLink(link) ) then
			return true;
		end
	end
	if ( IsModifiedClick("DRESSUP") ) then
		return DressUpItemLink(link) or DressUpBattlePetLink(link) or DressUpMountLink(link)
	end
	return false;
end

ItemButtonMixin = {};

function ItemButtonMixin:OnItemContextChanged()
	self:UpdateItemContextMatching();
end

function ItemButtonMixin:PostOnShow()
	self:UpdateItemContextMatching();

	local hasFunctionSet = self.GetItemContextMatchResult ~= nil;
	if hasFunctionSet then
		ItemButtonUtil.RegisterCallback(ItemButtonUtil.Event.ItemContextChanged, self.OnItemContextChanged, self);
	end
end

function ItemButtonMixin:PostOnHide()
	ItemButtonUtil.UnregisterCallback(ItemButtonUtil.Event.ItemContextChanged, self);
end

function ItemButtonMixin:PostOnEvent(event, ...)
	if event == "GET_ITEM_INFO_RECEIVED" then
		if not self.pendingInfo then
			return;
		end

		if self.pendingInfo.itemLocation then
			self:SetItemLocation(self.pendingInfo.itemLocation);
		else
			self:SetItemInternal(self.pendingInfo.item);
		end
	end
end

function ItemButtonMixin:SetMatchesSearch(matchesSearch)
	self.matchesSearch = matchesSearch;
	self:UpdateItemContextOverlay();
end

function ItemButtonMixin:GetMatchesSearch()
	return self.matchesSearch;
end

function ItemButtonMixin:UpdateItemContextMatching()
	local hasFunctionSet = self.GetItemContextMatchResult ~= nil;
	if hasFunctionSet then
		self.itemContextMatchResult = self:GetItemContextMatchResult();
	else
		self.itemContextMatchResult = ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
	end

	self:UpdateItemContextOverlay();
end

function ItemButtonMixin:UpdateCraftedProfessionsQualityShown()
	if not self.ProfessionQualityOverlay then
		return;
	end

	-- Stackable items with quality always show quality overlay
	local shouldShow = self.isProfessionItem and ((not self.isCraftedItem) or (ProfessionsFrame and ProfessionsFrame:IsShown() or self.alwaysShowProfessionsQuality));
	self.ProfessionQualityOverlay:SetShown(shouldShow);
end

function ItemButtonMixin:GetItemContextOverlayMode()
	local matchesSearch = self.matchesSearch == nil or self.matchesSearch;
	local contextApplies = self.itemContextMatchResult ~= ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
	local matchesContext = self.itemContextMatchResult == ItemButtonUtil.ItemContextMatchResult.Match;

	if not matchesSearch or (contextApplies and not matchesContext) then
		return ItemButtonConstants.ContextMatch.Standard;
	elseif matchesContext and self.showMatchHighlight then
		local itemContext = ItemButtonUtil.GetItemContext();
		if itemContext == ItemButtonUtil.ItemContextEnum.PickRuneforgeBaseItem or itemContext == ItemButtonUtil.ItemContextEnum.SelectRuneforgeItem or itemContext == ItemButtonUtil.ItemContextEnum.SelectRuneforgeUpgradeItem then
			return ItemButtonConstants.ContextMatch.RuneForging;
		end
	end

	return nil;
end

function ItemButtonMixin:UpdateItemContextOverlay()
	self:UpdateCraftedProfessionsQualityShown();

	local contextMode = self:GetItemContextOverlayMode();
	if contextMode then
		self:UpdateItemContextOverlayTextures(contextMode);
	end

	self.ItemContextOverlay:SetShown(contextMode ~= nil);
end

function ItemButtonMixin:UpdateItemContextOverlayTextures(contextMode)
	if contextMode == ItemButtonConstants.ContextMatch.Standard then
		self.ItemContextOverlay:SetColorTexture(0, 0, 0, 0.8);
		self.ItemContextOverlay:SetAllPoints();
	elseif contextMode == ItemButtonConstants.ContextMatch.RuneForging then
		self.ItemContextOverlay:SetAtlas("runecarving-icon-bag-item-glow", TextureKitConstants.UseAtlasSize);
		self.ItemContextOverlay:ClearAllPoints();
		self.ItemContextOverlay:SetPoint("CENTER");
	end
end

function ItemButtonMixin:Reset()
	self:SetItemButtonCount(nil);
	self:SetItemButtonTexture();
	self:SetItemButtonQuality();

	self.item = nil;
	self.itemLink = nil;
	self:SetItemSource(nil);

	self.noProfessionQualityOverlay = false;
	self.professionQualityOverlayOverride = nil;
	self.isProfessionItem = false;
	self.isCraftedItem = false;

	EventRegistry:UnregisterCallback("ItemButton.UpdateCraftedProfessionQualityShown", self.UpdateCraftedProfessionsQualityShown, self);
	ClearItemButtonOverlay(self);
end

function ItemButtonMixin:SetItemSource(itemLocation)
	self.itemLocation = itemLocation;
end

function ItemButtonMixin:SetItemLocation(itemLocation)
	self:SetItemSource(itemLocation);

	if itemLocation == nil or not C_Item.DoesItemExist(itemLocation) then
		self:SetItemInternal(nil);
		return itemLocation == nil;
	end

	return self:SetItemInternal(C_Item.GetItemLink(itemLocation));
end

-- item must be an itemID, item link or an item name.
function ItemButtonMixin:SetItem(item)
	self:SetItemSource(nil);
	return self:SetItemInternal(item);
end

function ItemButtonMixin:SetItemInternal(item)
	self.item = item;

	if not item then
		self:Reset();
		return true;
	end

	local itemLink, itemQuality, itemIcon = self:GetItemInfo();

	self.itemLink = itemLink;
	if self.itemLink == nil then
		self.pendingInfo = { item = self.item, itemLocation = self.itemLocation };
		self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
		self:Reset();
		return true;
	end

	self.pendingItem = nil;
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");

	self:SetItemButtonTexture(itemIcon);
	self:SetItemButtonQuality(itemQuality, itemLink);
	return true;
end

function ItemButtonMixin:GetItemInfo()
	local itemLocation = self:GetItemLocation();
	if itemLocation then
		local itemLink = C_Item.GetItemLink(itemLocation);
		local itemQuality = C_Item.GetItemQuality(itemLocation);
		local itemIcon = C_Item.GetItemIcon(itemLocation);
		return itemLink, itemQuality, itemIcon;
	else
		local item = self:GetItem();
		if item then
			local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = C_Item.GetItemInfo(item);
			return itemLink, itemQuality, itemIcon;
		end
	end
end

function ItemButtonMixin:GetItemID()
	local itemLink = self:GetItemLink();
	if not itemLink then
		return nil;
	end

	-- Storing in a local for clarity, and to avoid additional returns.
	local itemID = C_Item.GetItemInfoInstant(itemLink);
	return itemID;
end

function ItemButtonMixin:GetItem()
	return self.item;
end

function ItemButtonMixin:GetItemLink()
	return self.itemLink;
end

function ItemButtonMixin:GetItemLocation()
	return self.itemLocation;
end

function ItemButtonMixin:SetItemButtonCount(count)
	SetItemButtonCount(self, count);
end

function ItemButtonMixin:SetItemButtonAnchorPoint(point, x, y)
	self.Count:ClearAllPoints();
	self.Count:SetPoint(point, x, y);
end

function ItemButtonMixin:SetItemButtonScale(scale)
	self.Count:SetScale(scale);
end

function ItemButtonMixin:GetItemButtonCount()
	return GetItemButtonCount(self);
end

function ItemButtonMixin:SetAlpha(alpha)
	self.icon:SetAlpha(alpha);
	self.IconBorder:SetAlpha(alpha);
	self.IconOverlay:SetAlpha(alpha);
	self.Stock:SetAlpha(alpha);
	self.Count:SetAlpha(alpha);
end

function ItemButtonMixin:SetBagID(bagID)
	self.bagID = bagID;
end

function ItemButtonMixin:GetBagID()
	return self.bagID;
end

function ItemButtonMixin:GetSlotAndBagID()
	return self:GetID(), self:GetBagID();
end

function ItemButtonMixin:OnUpdateItemContextMatching(bagID)
	if self:GetBagID() == bagID then
		self:UpdateItemContextMatching();
	end
end

function ItemButtonMixin:RegisterBagButtonUpdateItemContextMatching()
	assert(self:GetBagID() ~= nil);
	EventRegistry:RegisterCallback("ItemButton.UpdateItemContextMatching", self.OnUpdateItemContextMatching, self);
end

function ItemButtonMixin:SetItemButtonQuality(quality, itemIDOrLink, suppressOverlays, isBound)
	SetItemButtonQuality_Base(self, quality, itemIDOrLink, suppressOverlays, isBound);
end

function ItemButtonMixin:SetItemButtonBorderVertexColor(r, g, b)
	SetItemButtonBorderVertexColor_Base(self, r, g, b);
end

function ItemButtonMixin:SetItemButtonTextureVertexColor(r, g, b)
	SetItemButtonTextureVertexColor_Base(self, r, g, b);
end

function ItemButtonMixin:SetItemButtonTexture(texture)
	SetItemButtonTexture_Base(self, texture);
end

function ItemButtonMixin:GetItemButtonIconTexture()
	return GetItemButtonIconTexture(self);
end

function ItemButtonMixin:GetItemButtonBackgroundTexture()
	return GetItemButtonBackgroundTexture_Base(self);
end