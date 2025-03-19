ArtifactLevelUpToastMixin = {};

function ArtifactLevelUpToastMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ARTIFACT_XP_UPDATE");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
end

function ArtifactLevelUpToastMixin:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:EvaluateTrigger();
	elseif event == "ARTIFACT_XP_UPDATE" then
		self:EvaluateTrigger();
	elseif event == "UNIT_INVENTORY_CHANGED" then
		local unitTag = ...;
		if unitTag == "player" then
			self:EvaluateTrigger();
		end
	end
end

function ArtifactLevelUpToastMixin:EvaluateTrigger()
	local itemID, altItemID, name, icon, xp, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop, artifactTier = C_ArtifactUI.GetEquippedArtifactInfo();
	local showArtifact = itemID ~= nil;
	if self.showArtifact ~= showArtifact or C_ArtifactUI.IsAtForge() then
		self.showArtifact = showArtifact;

		if self.showArtifact then
			self.currentArtifactPurchasableTraits = ArtifactBarGetNumArtifactTraitsPurchasableFromXP(pointsSpent, xp, artifactTier);
			self.currentItemID = itemID;
		else
			self.currentArtifactPurchasableTraits = nil;
			self.currentItemID = nil;
		end
	elseif self.showArtifact then
		local artifactPurchasableTraits = ArtifactBarGetNumArtifactTraitsPurchasableFromXP(pointsSpent, xp, artifactTier);
		if self.currentItemID == itemID then
			if self.currentArtifactPurchasableTraits < artifactPurchasableTraits then
				local artifactArtInfo = C_ArtifactUI.GetEquippedArtifactArtInfo();
				TopBannerManager_Show(self, { name = artifactArtInfo.titleName, icon = icon, });
			end
			self.currentArtifactPurchasableTraits = artifactPurchasableTraits;
		else
			self.currentItemID = itemID;
			self.currentArtifactPurchasableTraits = artifactPurchasableTraits;
		end
	end
end

function ArtifactLevelUpToastMixin:PlayBanner(data)
	self.ArtifactName:SetText(data.name);
	self.Icon:SetTexture(data.icon);

	self.BottomLineLeft:SetAlpha(0);
	self.BottomLineRight:SetAlpha(0);

	self.ArtifactName:SetAlpha(0);
	self.NewTrait:SetAlpha(0);
	self.UnlockTrait:SetAlpha(0);

	self:SetAlpha(1);
	self:Show();
	
	self.ArtifactLevelUpAnim:Play();
	PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_TOAST_TRAIT_AVAILABLE);
end

function ArtifactLevelUpToastMixin:StopBanner()
	self.ArtifactLevelUpAnim:Stop();
	self:Hide();
end

function ArtifactLevelUpToastMixin:OnAnimFinished()
	self:Hide();
	TopBannerManager_BannerFinished();
end