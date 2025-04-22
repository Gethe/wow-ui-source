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
	self.isModifyingRequired = false;
	if self.CropFrame then
		self.CropFrame:Hide();
	end
	self:Update();
end

function ProfessionsReagentSlotButtonMixin:Update()
	self:UpdateOverlay();
	self:UpdateCursor();
end

function ProfessionsReagentSlotButtonMixin:SetLocked(locked)
	self.locked = locked;
	self:UpdateOverlay();
end

function ProfessionsReagentSlotButtonMixin:SetCropOverlayShown(shown)
	self.CropFrame:SetShown(shown);
end

function ProfessionsReagentSlotButtonMixin:SetModifyingRequired(isModifyingRequired)
	self.isModifyingRequired = isModifyingRequired;
end

function ProfessionsReagentSlotButtonMixin:IsModifyingRequired()
	return self.isModifyingRequired;
end

function ProfessionsReagentSlotButtonMixin:UpdateOverlay()
	if self.InputOverlay then
		if self.locked then
			self.InputOverlay.LockedIcon:Show();
			self.InputOverlay.AddIcon:Hide();
		else
			self.InputOverlay.LockedIcon:Hide();
			self.InputOverlay.AddIcon:SetShown((self:GetItem() == nil) and not (self.currencyID or self.isModifyingRequired));
		end
	end
end

function ProfessionsReagentSlotButtonMixin:UpdateCursor()
	if self:IsMouseMotionFocus() then
		local onEnterScript = self:GetScript("OnEnter");
		if onEnterScript ~= nil then
			onEnterScript(self);
		end
	end
end

function ProfessionsReagentSlotButtonMixin:SetSlotQuality(quality)
	if quality then
		local atlasData = ColorManager.GetAtlasDataForProfessionsItemQuality(quality);
		if atlasData.atlas then
			self.IconBorder:SetAtlas(atlasData.atlas, TextureKitConstants.IgnoreAtlasSize);

			if atlasData.overrideColor then
				self.IconBorder:SetVertexColor(atlasData.overrideColor.r, atlasData.overrideColor.g, atlasData.overrideColor.b);
			else
				self.IconBorder:SetVertexColor(1, 1, 1);
			end
		end
		self.IconBorder:Show();
	end
end

function ProfessionsReagentSlotButtonMixin:SetItemInternal(item)
	ItemButtonMixin.SetItemInternal(self, item);

	local _, itemQuality, _ = self:GetItemInfo();
	self:SetSlotQuality(itemQuality);
end