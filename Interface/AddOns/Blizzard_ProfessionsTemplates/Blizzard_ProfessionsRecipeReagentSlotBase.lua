ProfessionsReagentSlotButtonMixin = {};

function ProfessionsReagentSlotButtonMixin:SetItem(item)
	ItemButtonMixin.SetItem(self, item);
	self:UpdateOverlay();
end

function ProfessionsReagentSlotButtonMixin:Reset()
	ItemButtonMixin.Reset(self);
	self.locked = nil;
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
		self.InputOverlay.AddIcon:SetShown(self:GetItem() == nil);
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

function ProfessionsReagentSlotButtonMixin:SetItemInternal(item)
	ItemButtonMixin.SetItemInternal(self, item);

	local _, itemQuality, _ = self:GetItemInfo();
	if itemQuality then
		if itemQuality == Enum.ItemQuality.Common then
			self.IconBorder:SetAtlas("Professions-Slot-Frame", TextureKitConstants.IgnoreAtlasSize);
		elseif itemQuality == Enum.ItemQuality.Uncommon then
			self.IconBorder:SetAtlas("Professions-Slot-Frame-Green", TextureKitConstants.IgnoreAtlasSize);
		elseif itemQuality == Enum.ItemQuality.Rare then
			self.IconBorder:SetAtlas("Professions-Slot-Frame-Blue", TextureKitConstants.IgnoreAtlasSize);
		elseif itemQuality == Enum.ItemQuality.Epic then
			self.IconBorder:SetAtlas("Professions-Slot-Frame-Epic", TextureKitConstants.IgnoreAtlasSize);
		elseif itemQuality == Enum.ItemQuality.Legendary then
			self.IconBorder:SetAtlas("Professions-Slot-Frame-Legendary", TextureKitConstants.IgnoreAtlasSize);
		end
	end
end