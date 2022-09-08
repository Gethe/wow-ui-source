MajorFactionUnlockToastMixin = {};

function MajorFactionUnlockToastMixin:OnLoad()
	self:RegisterEvent("MAJOR_FACTION_UNLOCKED");
end

function MajorFactionUnlockToastMixin:OnEvent(event, ...)
	if event == "MAJOR_FACTION_UNLOCKED" then
		if self:IsShown() then
			self:StopBanner();
		end

		local majorFactionID = ...;
		self:PlayMajorFactionUnlockToast(majorFactionID);
	end
end

function MajorFactionUnlockToastMixin:OnHide()
	MajorFactionCelebrationBannerMixin.OnHide(self);

	TopBannerManager_BannerFinished();
end

function MajorFactionUnlockToastMixin:PlayMajorFactionUnlockToast(majorFactionID)
	local majorFactionData = C_MajorFactions.GetMajorFactionData(majorFactionID);
	if majorFactionData then
		TopBannerManager_Show(self, { 
			name = majorFactionData.name, 
			covenantColor = COVENANT_COLORS[majorFactionData.textureKit],
			textureKit = majorFactionData.textureKit,
			celebrationSoundKit = majorFactionData.celebrationSoundKit,
		});
	end
end

function MajorFactionUnlockToastMixin:PlayBanner(data)
	self.MajorFactionName:SetText(data.name);
	self.MajorFactionName:SetTextColor(data.covenantColor:GetRGB());
	self:SetMajorFactionTextureKit(data.textureKit);
	PlaySound(data.celebrationSoundKit);

	self.ToastBG:SetAlpha(0);
	self.GlowLineTop:SetAlpha(0);
	self.GlowLineTopAdditive:SetAlpha(0);
	self.Stars1:SetAlpha(0);
	self.Stars2:SetAlpha(0);
	self.IconSwirlModelScene:SetAlpha(0);
	self.Icon:SetAlpha(0);
	self.MajorFactionName:SetAlpha(0);
	self.HeaderText:SetAlpha(0);

	self:SetAlpha(1);
	self:Show();
	self.ShowAnim:Stop();
	self.ShowAnim:Play();
end

function MajorFactionUnlockToastMixin:StopBanner()
	self.ShowAnim:Stop();
	self:Hide();
end

function MajorFactionUnlockToastMixin:OnAnimFinished()
	self:Hide();
end
