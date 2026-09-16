AzeritePaperDollItemOverlayMixin = {};

function AzeritePaperDollItemOverlayMixin:UpdateCorruptedGlow(itemLocation, glow)
	self.CorruptedHighlightTexture:SetShown(glow and itemLocation:IsValid() and C_Item.IsItemCorruptionRelated(itemLocation));
end

function AzeritePaperDollItemOverlayMixin:SetAzeriteItem(itemLocation)
	if not itemLocation or not itemLocation:HasAnyLocation() then
		self:ResetAzeriteItem();
		return;
	end

	local isAzeriteItem = C_AzeriteItem.IsAzeriteItem(itemLocation);
	local isAzeriteEmpoweredItem = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation);

	self.AzeriteTexture:SetShown(isAzeriteItem or isAzeriteEmpoweredItem);
	self.RankFrame:SetShown(isAzeriteItem);
	self.AvailableTraitFrame:SetShown(isAzeriteEmpoweredItem);
	self:ResetAzeriteTextures();

	if isAzeriteItem then
		self:DisplayAsAzeriteItem(itemLocation);
	elseif isAzeriteEmpoweredItem then
		self:DisplayAsAzeriteEmpoweredItem(itemLocation);
	end
end

function AzeritePaperDollItemOverlayMixin:DisplayAsAzeriteItem(itemLocation)
	self.AzeriteTexture:SetAtlas("AzeriteArmor-CharacterInfo-Neck", true);
	self.AzeriteTexture:SetSize(50, 44);
	self.AzeriteTexture:SetDrawLayer("OVERLAY", 1);

	local ATLAS_NAME = "AzeriteArmor-CharacterInfo-NeckHighlight";
	self:SetHighlightAtlas(ATLAS_NAME, "ADD");
	local highlightTexture = self:GetHighlightTexture();
	highlightTexture:ClearAllPoints();
	highlightTexture:SetPoint("CENTER");

	local info = C_Texture.GetAtlasInfo(ATLAS_NAME);
	local SCALAR = .55;
	highlightTexture:SetSize((info and info.width or 0) * SCALAR, (info and info.height or 0) * SCALAR);

	self:UpdateAzeriteRank(itemLocation);
end

function AzeritePaperDollItemOverlayMixin:UpdateAzeriteRank(itemLocation)
	local powerLevel = C_AzeriteItem.GetPowerLevel(itemLocation);
	self.RankFrame.Label:SetText(powerLevel);
end

function AzeritePaperDollItemOverlayMixin:DisplayAsAzeriteEmpoweredItem(itemLocation)
	self.AzeriteTexture:SetAtlas("AzeriteArmor-CharacterInfo-Border", true);
	self.AzeriteTexture:SetSize(57, 46);
	self.AzeriteTexture:SetDrawLayer("BORDER", -1);

	if C_AzeriteEmpoweredItem.HasAnyUnselectedPowers(itemLocation) then
		self.AvailableTraitFrame:Show();
		self.AvailableTraitFrame.AvailableAnim:Play();
		self.AvailableTraitFrame.AvailableAnimGlow:Play();
	else
		self.AvailableTraitFrame:Hide();
		self.AvailableTraitFrame.AvailableAnim:Finish();
		self.AvailableTraitFrame.AvailableAnimGlow:Finish();
	end
end

function AzeritePaperDollItemOverlayMixin:ResetAzeriteItem()
	self.AzeriteTexture:Hide();
	self.RankFrame:Hide();
	self.AvailableTraitFrame:Hide();

	self:ResetAzeriteTextures();
end

function AzeritePaperDollItemOverlayMixin:ResetAzeriteTextures()
	self:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]], "ADD");
	local highlightTexture = self:GetHighlightTexture();
	highlightTexture:SetAllPoints(self);
end