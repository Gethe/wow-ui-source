ProfessionsReagentSlotButtonMixin = {};

function ProfessionsReagentSlotButtonMixin:SetItem(item)
	ItemButtonMixin.SetItem(self, item);

	self.InputOverlay:Hide();
end

function ProfessionsReagentSlotButtonMixin:Reset()
	ItemButtonMixin.Reset(self);
		
	self.InputOverlay:Show();

	self:UpdateCursor();
end

function ProfessionsReagentSlotButtonMixin:SetLocked(locked)
	self.InputOverlay.LockedIcon:SetShown(locked);
	self.InputOverlay.AddIcon:SetShown(not locked);
end

function ProfessionsReagentSlotButtonMixin:UpdateCursor()
	local onEnterScript = self:GetScript("OnEnter");
	if onEnterScript ~= nil then
		onEnterScript(self);
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