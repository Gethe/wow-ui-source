AuctionHouseBackgroundMixin = {};

function AuctionHouseBackgroundMixin:OnLoad()
	local xOffset = self.backgroundXOffset or 0;
	local yOffset = self.backgroundYOffset or 0;
	self.Background:SetAtlas(self.backgroundAtlas, true);
	self.Background:SetPoint("TOPLEFT", xOffset + 3, yOffset - 3);

	self.NineSlice:ClearAllPoints();
	self.NineSlice:SetPoint("TOPLEFT", xOffset, yOffset);
	self.NineSlice:SetPoint("BOTTOMRIGHT");
end

function AuctionHouseItemDisplayMixin:OnEnter()
	self:SetScript("OnUpdate", AuctionHouseItemDisplayMixin.OnUpdate);

	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	end

	if self:IsPet() then
		if self.itemKey then
			local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(self.itemKey);
			if itemKeyInfo and itemKeyInfo.battlePetLink then
				GameTooltip:SetOwner(self.ItemButton, "ANCHOR_RIGHT");
				BattlePetToolTip_ShowLink(itemKeyInfo.battlePetLink);
				AuctionHouseUtil.AppendBattlePetVariationLines(BattlePetTooltip);
			else
				BattlePetTooltip:Hide();
				GameTooltip:Hide();
			end
		else
			local itemLocation = self:GetItemLocation();
			if itemLocation then
				local bagID, slotIndex = itemLocation:GetBagAndSlot();
				if bagID and slotIndex then
					GameTooltip:SetOwner(self.ItemButton, "ANCHOR_RIGHT");
					GameTooltip:SetBagItem(bagID, slotIndex);
				end
			end
		end
	else
		BattlePetTooltip:Hide();

		local itemLocation = self:GetItemLocation();
		if itemLocation then
			GameTooltip:SetOwner(self.ItemButton, "ANCHOR_RIGHT");
			GameTooltip:SetHyperlink(C_Item.GetItemLink(itemLocation));
			GameTooltip:Show();
		else
			local itemKey = self:GetItemKey();
			if itemKey then
				GameTooltip:SetOwner(self.ItemButton, "ANCHOR_RIGHT");
				GameTooltip:SetItemKey(itemKey.itemID, itemKey.itemLevel, itemKey.itemSuffix, C_AuctionHouse.GetItemKeyRequiredLevel(itemKey));
				GameTooltip:Show();
			else
				local itemLink = self:GetItemLink();
				if itemLink then
					GameTooltip:SetOwner(self.ItemButton, "ANCHOR_RIGHT");
					GameTooltip:SetHyperlink(itemLink);
					GameTooltip:Show();
				end
			end
		end

		self.ItemButton.UpdateTooltip = self.ItemButton:GetScript("OnEnter");
	end
end