--////////////////////////////Top Banner Toast//////////////////////////////////////////
HousingTopBannerMixin = {}

function HousingTopBannerMixin:OnLoad()
	self.PopinAnim:SetScript("OnFinished", GenerateClosure(self.OnPopinInAnimFinished, self));
	self.FadeOutAnim:SetScript("OnFinished", GenerateClosure(self.OnFadeOutAnimFinished, self));
	self:RegisterEvent("INITIATIVE_COMPLETED");
end

function HousingTopBannerMixin:OnEvent(event, ...)
	if ( event == "INITIATIVE_COMPLETED" ) then
		local initiativeTitle = ...;
		HousingTopBannerFrame:SetBannerText(ENDEAVOR_COMPLETED, initiativeTitle);
		TopBannerManager_Show(HousingTopBannerFrame);
	end
end

function HousingTopBannerMixin:OnPopinInAnimFinished()
	self.RaysAndGlow:Restart();
	self.LeavesFlutter:Restart();
	self.SheenShine:Play();
	self.FadeOutAnim:Play();
end

function HousingTopBannerMixin:OnFadeOutAnimFinished()
	self:Hide();
end

function HousingTopBannerMixin:OnHide()
    TopBannerManager_BannerFinished();
end

function HousingTopBannerMixin:SetBannerText(title, subtext)
    self.Title:SetText(title);
	self.Subtitle:SetText(subtext);
end

-- called by TopBannerManager
function HousingTopBannerMixin:PlayBanner()
	PlaySound(SOUNDKIT.HOUSING_BUY_BANNER);

	-- reset alphas for those with start delays
	self.Title:SetAlpha(0);
	self.Subtitle:SetAlpha(0);
	self.Glow:SetAlpha(0);
	self.Sheen:SetAlpha(1);
	-- show and play
	self:Show();
	self.PopinAnim:Play();

end

-- called by TopBannerManager
function HousingTopBannerMixin:StopBanner()
	self.RaysAndGlow:Stop();
	self.LeavesFlutter:Stop();
	self.SheenShine:Stop();
	self.PopinAnim:Stop();
	self:Hide();
end
