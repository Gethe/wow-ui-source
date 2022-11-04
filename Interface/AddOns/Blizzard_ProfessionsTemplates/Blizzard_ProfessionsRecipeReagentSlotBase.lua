ProfessionsReagentSlotButtonMixin = {};

function ProfessionsReagentSlotButtonMixin:SetItem(item)
	ItemButtonMixin.SetItem(self, item);
	self:UpdateOverlay();
end

function ProfessionsReagentSlotButtonMixin:SetCurrency(currencyID)
	self.currencyID = currencyID;
	local currencyInfo = currencyID and C_CurrencyInfo.GetCurrencyInfo(currencyID);
	if currencyInfo then
		local texture = currencyInfo.iconFileID;
		self.Icon:SetTexture(texture);
		self.Icon:Show();
		self:SetSlotQuality(currencyInfo.quality);
	end
	self:UpdateOverlay();
end

function ProfessionsReagentSlotButtonMixin:GetCurrencyID()
	return self.currencyID;
end

function ProfessionsReagentSlotButtonMixin:Reset()
	ItemButtonMixin.Reset(self);
	self.locked = nil;
	self.currencyID = nil;
	self:UpdateOverlay();
	self:UpdateCursor();
end

function ProfessionsReagentSlotButtonMixin:SetLocked(locked)
	self.locked = locked;
	self:UpdateOverlay();
end

function ProfessionsReagentSlotButtonMixin:UpdateOverlay()
	if self.locked then
		self.InputOverlay.LockedIcon:Show();
		self.InputOverlay.AddIcon:Hide();
	else
		self.InputOverlay.LockedIcon:Hide();
		self.InputOverlay.AddIcon:SetShown(self:GetItem() == nil and not self.currencyID);
	end
end

function ProfessionsReagentSlotButtonMixin:UpdateCursor()
	if GetMouseFocus() == self then
		local onEnterScript = self:GetScript("OnEnter");
		if onEnterScript ~= nil then
			onEnterScript(self);
		end
	end
end

function ProfessionsReagentSlotButtonMixin:SetSlotQuality(quality)
	if quality then
		if quality == Enum.ItemQuality.Common then
			self.IconBorder:SetAtlas("Professions-Slot-Frame", TextureKitConstants.IgnoreAtlasSize);
		elseif quality == Enum.ItemQuality.Uncommon then
			self.IconBorder:SetAtlas("Professions-Slot-Frame-Green", TextureKitConstants.IgnoreAtlasSize);
		elseif quality == Enum.ItemQuality.Rare then
			self.IconBorder:SetAtlas("Professions-Slot-Frame-Blue", TextureKitConstants.IgnoreAtlasSize);
		elseif quality == Enum.ItemQuality.Epic then
			self.IconBorder:SetAtlas("Professions-Slot-Frame-Epic", TextureKitConstants.IgnoreAtlasSize);
		elseif quality == Enum.ItemQuality.Legendary then
			self.IconBorder:SetAtlas("Professions-Slot-Frame-Legendary", TextureKitConstants.IgnoreAtlasSize);
		end
		self.IconBorder:Show();
	end
end

function ProfessionsReagentSlotButtonMixin:SetItemInternal(item)
	ItemButtonMixin.SetItemInternal(self, item);

	local _, itemQuality, _ = self:GetItemInfo();
	self:SetSlotQuality(itemQuality);
end