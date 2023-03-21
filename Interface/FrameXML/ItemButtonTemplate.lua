ItemButtonConstants =
{
	ContextMatch =
	{
		Standard = 1,
		RuneForging = 2,
	},
};

local function GetItemButtonIconTexture(button)
	return button.Icon or button.icon or _G[button:GetName().."IconTexture"];
end

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

local function GetItemButtonBackgroundTexture_Base(button)
	if button.emptyBackgroundTexture then
		return button.emptyBackgroundTexture;
	elseif button.emptyBackgroundAtlas then
		return button.emptyBackgroundAtlas, true;
	end
end

function GetItemButtonBackgroundTexture(button)
	if button then
		if button.GetItemButtonBackgroundTexture then
			return button:GetItemButtonBackgroundTexture();
		else
			GetItemButtonBackgroundTexture_Base(button);
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

		if isAtlas then
			icon:SetAtlas(texture);
		else
			icon:SetTexture(texture);
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

local qualityToIconBorderAtlas =
{
	[Enum.ItemQuality.Poor] = "auctionhouse-itemicon-border-gray",
	[Enum.ItemQuality.Common] = "auctionhouse-itemicon-border-white",
	[Enum.ItemQuality.Uncommon] = "auctionhouse-itemicon-border-green",
	[Enum.ItemQuality.Rare] = "auctionhouse-itemicon-border-blue",
	[Enum.ItemQuality.Epic] = "auctionhouse-itemicon-border-purple",
	[Enum.ItemQuality.Legendary] = "auctionhouse-itemicon-border-orange",
	[Enum.ItemQuality.Artifact] = "auctionhouse-itemicon-border-artifact",
	[Enum.ItemQuality.Heirloom] = "auctionhouse-itemicon-border-account",
	[Enum.ItemQuality.WoWToken] = "auctionhouse-itemicon-border-account",
};

local function SetItemButtonQuality_Base(button, quality, itemIDOrLink, suppressOverlays, isBound)
	ClearItemButtonOverlay(button);

	local hasQuality = quality and BAG_ITEM_QUALITY_COLORS[quality];
	if hasQuality then
		if itemIDOrLink then
			if IsArtifactRelicItem(itemIDOrLink) then
				SetItemButtonBorder(button, [[Interface\Artifacts\RelicIconFrame]]);
			else
				SetItemButtonBorder(button, [[Interface\Common\WhiteIconFrame]]);
			end

			if not suppressOverlays then
				SetItemButtonOverlay(button, itemIDOrLink, quality, isBound);
			end
		else
			SetItemButtonBorder(button, [[Interface\Common\WhiteIconFrame]]);
		end

		local color = BAG_ITEM_QUALITY_COLORS[quality];
		SetItemButtonBorderVertexColor(button, color.r, color.g, color.b);
	else
		SetItemButtonBorder(button);
	end
end

function SetItemButtonQuality(button, quality, itemIDOrLink, suppressOverlays, isBound)
	if button then
		if button.SetItemButtonQuality then
			button:SetItemButtonQuality(quality, itemIDOrLink, suppressOverlays, isBound);
		else
			SetItemButtonQuality_Base(button, quality, itemIDOrLink, suppressOverlays, isBound);
		end
	end
end

-- Remember to update the OverlayKeys table if adding an overlay texture here.
function SetItemButtonOverlay(button, itemIDOrLink, quality, isBound)
	ClearItemButtonOverlay(button);

	if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemIDOrLink) then
		button.IconOverlay:SetAtlas("AzeriteIconFrame");
		button.IconOverlay:Show();
	elseif IsCorruptedItem(itemIDOrLink) then
		button.IconOverlay:SetAtlas("Nzoth-inventory-icon");
		button.IconOverlay:Show();
	elseif IsCosmeticItem(itemIDOrLink) then
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
		-- The reagent slots contain this button/mixin, however there's a nuance in the button behavior that the overlay needs to be
		-- hidden if more than 1 quality of reagent is assigned to the slot. Those slots have a separate overlay that is
		-- managed independently of this, though it still uses the rest of this button's behaviors.
		SetItemCraftingQualityOverlay(button, itemIDOrLink);
	end
end

local function SetupCraftingQualityOverlay(button, quality)
	if quality then
		if not button.ProfessionQualityOverlay then
			button.ProfessionQualityOverlay = button:CreateTexture(nil, "OVERLAY");
			button.ProfessionQualityOverlay:SetPoint("TOPLEFT", -3, 2);
			button.ProfessionQualityOverlay:SetDrawLayer("OVERLAY", 7);
		end

		local atlas = ("Professions-Icon-Quality-Tier%d-Inv"):format(quality);
		button.ProfessionQualityOverlay:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
		ItemButtonMixin.UpdateCraftedProfessionsQualityShown(button);
		EventRegistry:RegisterCallback("ItemButton.UpdateCraftedProfessionQualityShown", ItemButtonMixin.UpdateCraftedProfessionsQualityShown, button);
	end
end

function SetItemCraftingQualityOverlayOverride(button, quality)
	button.professionQualityOverlayOverride = quality;
	SetupCraftingQualityOverlay(button, quality);
end

function SetItemCraftingQualityOverlay(button, itemIDOrLink)
	if button.noProfessionQualityOverlay then
		return;
	end

	local quality = nil;
	if itemIDOrLink  then
		quality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemIDOrLink);
		if quality then
			button.isCraftedItem = false;
		else
			quality = C_TradeSkillUI.GetItemCraftedQualityByItemInfo(itemIDOrLink);
			button.isCraftedItem = quality ~= nil;
		end

		button.isProfessionItem = quality ~= nil;
	else
		button.isProfessionItem = false;
	end

	if button.professionQualityOverlayOverride then
		quality = button.professionQualityOverlayOverride;
	end

	if quality then
		SetupCraftingQualityOverlay(button, quality);
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
		if ( ChatEdit_InsertLink(link) ) then
			return true;
		elseif ( SocialPostFrame and Social_IsShown() ) then
			Social_InsertLink(link);
			return true;
		end
	end
	if ( IsModifiedClick("DRESSUP") ) then
		return DressUpItemLocation(itemLocation) or DressUpItemLink(link) or DressUpBattlePetLink(link) or DressUpMountLink(link)
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
			local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(item);
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

CircularGiantItemButtonMixin = {}

function CircularGiantItemButtonMixin:SetItemButtonQuality(quality, itemIDOrLink, suppressOverlays, isBound)
	ClearItemButtonOverlay(self);

	if quality then
		local isAtlas = true;
		SetItemButtonBorder(self, qualityToIconBorderAtlas[quality], isAtlas);
	else
		SetItemButtonBorder(self);
	end
end

