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
	if ( count > 1 or (button.isBag and count > 0) ) then
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

function SetItemButtonQuality(button, quality, itemIDOrLink, suppressOverlays, isBound)
	if button.useCircularIconBorder then
		button.IconBorder:Show();

		if quality == Enum.ItemQuality.Poor then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-gray");
		elseif quality == Enum.ItemQuality.Common then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-white");
		elseif quality == Enum.ItemQuality.Uncommon then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-green");
		elseif quality == Enum.ItemQuality.Rare then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-blue");
		elseif quality == Enum.ItemQuality.Epic then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-purple");
		elseif quality == Enum.ItemQuality.Legendary then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-orange");
		elseif quality == Enum.ItemQuality.Artifact then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-artifact");
		elseif quality == Enum.ItemQuality.Heirloom then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-account");
		elseif quality == Enum.ItemQuality.WoWToken then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-account");
		else
			button.IconBorder:Hide();
		end
		
		return;
	end

	button.IconOverlay:Hide();
	if button.IconOverlay2 then
		button.IconOverlay2:Hide();
	end

	if itemIDOrLink then
		if IsArtifactRelicItem(itemIDOrLink) then
			button.IconBorder:SetTexture([[Interface\Artifacts\RelicIconFrame]]);
		else
			button.IconBorder:SetTexture([[Interface\Common\WhiteIconFrame]]);
		end
		
		if not suppressOverlays then
			SetItemButtonOverlay(button, itemIDOrLink, quality, isBound);
		end
	else
		button.IconBorder:SetTexture([[Interface\Common\WhiteIconFrame]]);
	end

	if quality then
		if quality >= Enum.ItemQuality.Common and BAG_ITEM_QUALITY_COLORS[quality] then
			button.IconBorder:Show();
			button.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
		else
			button.IconBorder:Hide();
		end
	else
		button.IconBorder:Hide();
	end
end

function SetItemButtonOverlay(button, itemIDOrLink, quality, isBound)
	button.IconOverlay:SetVertexColor(1,1,1);
	if button.IconOverlay2 then
		button.IconOverlay2:Hide();
	end

	if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemIDOrLink) then
		button.IconOverlay:SetAtlas("AzeriteIconFrame");
		button.IconOverlay:Show();
	elseif IsCorruptedItem(itemIDOrLink) then
		button.IconOverlay:SetAtlas("Nzoth-inventory-icon");
		button.IconOverlay:Show();
	elseif IsCosmeticItem(itemIDOrLink) and not isBound then
		button.IconOverlay:SetAtlas("CosmeticIconFrame");
		button.IconOverlay:Show();
	elseif C_Soulbinds.IsItemConduitByItemInfo(itemIDOrLink) then
		if not quality or not BAG_ITEM_QUALITY_COLORS[quality] then
			quality = Enum.ItemQuality.Common;
		end
		local color = BAG_ITEM_QUALITY_COLORS[quality];
		button.IconOverlay:SetVertexColor(color.r, color.g, color.b);
		button.IconOverlay:SetAtlas("ConduitIconFrame");
		button.IconOverlay:Show();

		-- If this is missing, the texture will make it apparant instead of error.
		if button.IconOverlay2 then
			button.IconOverlay2:SetAtlas("ConduitIconFrame-Corners");
			button.IconOverlay2:Show();
		end
	else
		button.IconOverlay:Hide();
	end
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
		elseif ( SocialPostFrame and Social_IsShown() ) then
			Social_InsertLink(link);
			return true;
		end
	end
	if ( IsModifiedClick("DRESSUP") ) then
		return DressUpItemLink(link) or DressUpBattlePetLink(link) or DressUpMountLink(link)
	end
	if ( IsModifiedClick("EXPANDITEM") ) then
		if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(link) then
			OpenAzeriteEmpoweredItemUIFromLink(link);
			return true;
		end
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
	self:UpdateItemContextOverlay(self);
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
	
	self:UpdateItemContextOverlay(self);
end

function ItemButtonMixin:UpdateItemContextOverlay()
	local matchesSearch = self.matchesSearch == nil or self.matchesSearch;
	local contextApplies = self.itemContextMatchResult ~= ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
	local matchesContext = self.itemContextMatchResult == ItemButtonUtil.ItemContextMatchResult.Match;

	self.ItemContextOverlay:Hide();

	if not matchesSearch or (contextApplies and not matchesContext) then
		self.ItemContextOverlay:SetColorTexture(0, 0, 0, 0.8);
		self.ItemContextOverlay:SetAllPoints(true);
		self.ItemContextOverlay:Show();
	elseif matchesContext and self.showMatchHighlight then
		local itemContext = ItemButtonUtil.GetItemContext();
		if itemContext == ItemButtonUtil.ItemContextEnum.PickRuneforgeBaseItem or itemContext == ItemButtonUtil.ItemContextEnum.SelectRuneforgeItem or itemContext == ItemButtonUtil.ItemContextEnum.SelectRuneforgeUpgradeItem then
			local useAtlasSize = true;
			self.ItemContextOverlay:SetAtlas("runecarving-icon-bag-item-glow", useAtlasSize);
			self.ItemContextOverlay:ClearAllPoints();
			self.ItemContextOverlay:SetPoint("CENTER");
			self.ItemContextOverlay:Show();
		end
	end
end

function ItemButtonMixin:Reset()
	self:SetItemButtonCount(nil);
	SetItemButtonTexture(self, nil);
	SetItemButtonQuality(self, nil, nil);

	self.itemLink = nil;
	self:SetItemSource(nil);
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

	SetItemButtonTexture(self, itemIcon);
	SetItemButtonQuality(self, itemQuality, itemLink);
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
		local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(self:GetItem());
		return itemLink, itemQuality, itemIcon;
	end
end

function ItemButtonMixin:GetItemID()
	local itemLink = self:GetItemLink();
	if not itemLink then
		return nil;
	end

	-- Storing in a local for clarity, and to avoid additional returns.
	local itemID = GetItemInfoInstant(itemLink);
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
