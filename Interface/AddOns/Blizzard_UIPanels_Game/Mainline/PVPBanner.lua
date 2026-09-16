
function PvPObjectiveBannerFrame_PlayBanner(self, data)
	local name = data.name or "";
	local description = data.description or "";

	self.Title:SetText(name);
	self.TitleFlash:SetText(name);
	self.BonusLabel:SetText(description);

	-- offsets for anims
	local xOffset = QueueStatusButton:GetLeft() - self:GetLeft();
	local yOffset = QueueStatusButton:GetTop() - self:GetTop() + 64;

	self.Anim.BG1Translation:SetOffset(xOffset, yOffset);
	self.Anim.TitleTranslation:SetOffset(xOffset, yOffset);
	self.Anim.BonusLabelTranslation:SetOffset(xOffset, yOffset);
	self.Anim.IconTranslation:SetOffset(xOffset, yOffset);
	-- hide zone text as it's very likely to be up
	ZoneText_Clear();
	-- show and play
	self:Show();
	self.Anim:Stop();
	self.Anim:Play();
end

function PvPObjectiveBannerFrame_StopBanner(self)
	self.Anim:Stop();
	self:Hide();
end

function PvPObjectiveBannerFrame_OnAnimFinished()
	TopBannerManager_BannerFinished();
	PvPObjectiveBannerFrame:Hide();
end
