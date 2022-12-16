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
			factionColor = self:GetFactionColorByTextureKit(majorFactionData.textureKit),
			textureKit = majorFactionData.textureKit,
			celebrationSoundKit = majorFactionData.celebrationSoundKit,
		});
	end
end

function MajorFactionUnlockToastMixin:PlayBanner(data)
	self.FactionName:SetText(data.name);
	self.FactionName:SetTextColor(data.factionColor:GetRGB());
	self:SetMajorFactionTextureKit(data.textureKit);

	local textureKitRegions = {
		[self.GlowLineBottom] = "majorfaction-celebration-bottomglowline",
	};

	SetupTextureKitOnFrames(data.textureKit, textureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	PlaySound(data.celebrationSoundKit);

	self.ToastBG:SetAlpha(0);
	self.IconSwirlModelScene:SetAlpha(0);
	self.Icon:SetAlpha(0);
	self.FactionName:SetAlpha(0);
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
