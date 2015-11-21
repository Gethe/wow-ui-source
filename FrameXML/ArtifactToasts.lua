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
	local hasArtifactEquipped = HasArtifactEquipped();

	if self.hasArtifactEquipped ~= hasArtifactEquipped or C_ArtifactUI.IsAtForge() then
		self.hasArtifactEquipped = hasArtifactEquipped;

		if self.hasArtifactEquipped then
			local itemID, altItemID, name, icon, xp, xpForNextPoint, quality, artifactAppearanceID, appearanceModID = C_ArtifactUI.GetEquippedArtifactInfo();
			self.currentArtifactXP = xp;
			self.currentItemID = itemID;
		else
			self.currentArtifactXP = nil;
			self.currentItemID = nil;
		end
	elseif self.hasArtifactEquipped then
		local itemID, altItemID, name, icon, xp, xpForNextPoint, quality, artifactAppearanceID, appearanceModID = C_ArtifactUI.GetEquippedArtifactInfo();
		if self.currentItemID == itemID then
			if self.currentArtifactXP < xpForNextPoint and xp >= xpForNextPoint then
				local _, titleName = C_ArtifactUI.GetEquippedArtifactArtInfo();
				TopBannerManager_Show(self, { name = titleName, icon = icon, });
			end
			self.currentArtifactXP = xp;
		else
			self.currentItemID = itemID;
			self.currentArtifactXP = xp;
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
	PlaySound("UI_70_Artifact_Forge_Toast_TraitAvailable");
end

function ArtifactLevelUpToastMixin:StopBanner()
	self.ArtifactLevelUpAnim:Stop();
	self:Hide();
end

function ArtifactLevelUpToastMixin:OnAnimFinished()
	self:Hide();
	TopBannerManager_BannerFinished();
end