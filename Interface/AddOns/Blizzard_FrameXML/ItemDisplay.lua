LootItemExtendedMixin = {};

function LootItemExtendedMixin:Init(itemLink, originalQuantity, specID, isCurrency, isUpgraded, isIconBorderShown, isIconBorderDropShadowShown, iconDrawLayer)
	local itemName, itemTexture, quantity, itemRarity, itemLink = ItemUtil.GetItemDetails(itemLink, originalQuantity, isCurrency);

	local atlas = LOOT_BORDER_BY_QUALITY[itemRarity];
	local desaturate = false;
	if (not atlas) then
		atlas = "loottoast-itemborder-gold";
		desaturate = true;
	end

	self.IconOverlay:SetVertexColor(1, 1, 1);
	self.IconOverlay:SetScale(1);
	self.IconOverlay2:SetScale(1);

	self:SetIconBorderAtlas(atlas);
	self:SetIconBorderDesaturated(desaturate);
	self:SetTexture(itemTexture);
	self:SetIconDrawLayer(iconDrawLayer or "BORDER");
	self:SetIconBorderShown(isIconBorderShown or false);
	self:SetIconBorderDropShadowShown(isIconBorderDropShadowShown or false);
	self:SetIconQuantity(quantity or 1);

	if C_Soulbinds.IsItemConduitByItemInfo(itemLink) then
		self:SetIconOverlayAtlas("ConduitIconFrame");
		self:SetIconOverlay2Atlas("ConduitIconFrame-Corners");
		local color = BAG_ITEM_QUALITY_COLORS[itemRarity];
		self.IconOverlay:SetVertexColor(color.r, color.g, color.b);
		local scale = .8;
		self.IconOverlay:SetScale(scale);
		self.IconOverlay2:SetScale(scale);
	else
		local showAzeriteBorder = isIconBorderShown and not isCurrency and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemLink);
		self:SetIconOverlayAtlas(showAzeriteBorder and "LootToast-Azerite-Border" or nil);
		self:SetIconOverlay2Atlas(nil);
	end

	local showSpecID = specID and specID > 0 and not isCurrency;
	local texture = showSpecID and select(4, GetSpecializationInfoByID(specID));
	self:SetSpecIconTexture(texture);

	self:StopAnimArrows();

	if isUpgraded then
		local upgradeTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[itemRarity or Enum.ItemQuality.Uncommon];
		self:SetArrowUpgradeTexture(upgradeTexture);
	else
		self:SetArrowUpgradeTexture(nil);
	end

	self.ItemBurst:SetAlpha(0);
	self.ItemBorderGlow:SetAlpha(0);
	self.GlowSmokeBurst:SetAlpha(0);
end

function LootItemExtendedMixin:SetIconQuantity(quantity)
	local canDisplayCount = quantity > 1;
	if canDisplayCount then
		local quantityString = GetFormattedItemQuantity(quantity);
		self.Count:SetText(quantityString);
	end
	self.Count:SetShown(canDisplayCount);
end
function LootItemExtendedMixin:SetIconDrawLayer(drawLayer)
	self.Icon:SetDrawLayer(drawLayer);
end
function LootItemExtendedMixin:SetTexture(texture)
	self.Icon:SetTexture(texture);
end
function LootItemExtendedMixin:SetIconBorderShown(shown)
	self.IconBorder:SetShown(shown);
end
function LootItemExtendedMixin:SetIconBorderAtlas(atlas)
	self.IconBorder:SetAtlas(atlas);
end
function LootItemExtendedMixin:SetIconBorderDropShadowShown(shown)
	self.IconBorderDropShadow:SetShown(shown);
end
function LootItemExtendedMixin:SetIconBorderDesaturated(desaturated)
	self.IconBorder:SetDesaturated(desaturated);
end
function LootItemExtendedMixin:SetIconOverlayShown(shown)
	self.IconOverlay:SetShown(shown);
end
function LootItemExtendedMixin:SetIconOverlay_Internal(overlay, atlas)
	local isValid = atlas ~= nil;
	if isValid then
		local useAtlasSize = true;
		overlay:SetAtlas(atlas, useAtlasSize);
	end
	overlay:SetShown(isValid);
end
function LootItemExtendedMixin:SetIconOverlayAtlas(atlas)
	self:SetIconOverlay_Internal(self.IconOverlay, atlas);
end
function LootItemExtendedMixin:SetIconOverlay2Atlas(atlas)
	self:SetIconOverlay_Internal(self.IconOverlay2, atlas);
end
function LootItemExtendedMixin:SetSpecIconShown(shown)
	self.SpecIcon:SetShown(shown);
	self.SpecRing:SetShown(shown);
end
function LootItemExtendedMixin:SetSpecIconTexture(texture)
	local isValid = atlas ~= nil;
	if isValid then
		self.SpecIcon:SetTexture(texture);
	end
	self:SetSpecIconShown(isValid);
end
function LootItemExtendedMixin:StopAnimArrows()
	self.animArrows:Stop();
end
function LootItemExtendedMixin:SetArrowUpgradeTexture(upgradeTexture)
	if ( upgradeTexture ) then
		local atlas = upgradeTexture.arrow;
		for k, arrow in pairs(self.arrows) do
			arrow:SetAtlas(atlas, true);
		end
		self.animArrows:Play();
	else
		for k, arrow in pairs(self.arrows) do
			arrow:SetAlpha(0);
		end
	end
end