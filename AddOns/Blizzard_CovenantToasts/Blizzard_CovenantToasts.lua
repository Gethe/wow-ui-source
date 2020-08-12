CovenantChoiceToastMixin = {};

function CovenantChoiceToastMixin:OnLoad()
	self:RegisterEvent("COVENANT_CHOSEN");
	self.iconSwirlEffects = {};
end

function CovenantChoiceToastMixin:OnEvent(event, ...)
	if event == "COVENANT_CHOSEN" then
		if self:IsShown() then
			self:StopBanner();
		end

		local covenantID = ...;
		self:PlayCovenantChoiceToast(covenantID);
	end
end

function CovenantChoiceToastMixin:CancelIconSwirlEffects()
	for _, effect in ipairs(self.iconSwirlEffects) do
		effect:CancelEffect();
	end

	self.iconSwirlEffects = {};
end

function CovenantChoiceToastMixin:OnHide()
	self:CancelIconSwirlEffects();
	TopBannerManager_BannerFinished();
end

local covenantSwirlEffects = 
{
	Kyrian = {91},
	Venthyr = {92},
	NightFae = {93, 96},
	Necrolord = {94},
}

function CovenantChoiceToastMixin:PlayCovenantChoiceToast(covenantID)
	local covenantData = C_Covenants.GetCovenantData(covenantID);
	if covenantData then
		TopBannerManager_Show(self, { 
			name = covenantData.name, 
			covenantColor = COVENANT_COLORS[covenantData.textureKit],
			swirlEffects = covenantSwirlEffects[covenantData.textureKit],
			textureKit = covenantData.textureKit,
		});
	end
end

function CovenantChoiceToastMixin:PlayBanner(data)
	self.CovenantName:SetText(data.name);
	self.CovenantName:SetTextColor(data.covenantColor:GetRGB());

	local textureKitRegions = {
		[self.GlowLineTop] = "CovenantChoice-Celebration-%sCloudyLine",
		[self.GlowLineTopAdditive] = "CovenantChoice-Celebration-%sCloudyLine",
		[self.Icon.Tex] = "CovenantChoice-Celebration-%sSigil",
	}

	SetupTextureKitOnFrames(data.textureKit, textureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	self.ToastBG:SetAlpha(0);
	self.GlowLineTop:SetAlpha(0);
	self.GlowLineTopAdditive:SetAlpha(0);
	self.Stars1:SetAlpha(0);
	self.Stars2:SetAlpha(0);
	self.IconSwirlModelScene:SetAlpha(0);
	self.Icon:SetAlpha(0);
	self.CovenantName:SetAlpha(0);
	self.HeaderText:SetAlpha(0);

	self:CancelIconSwirlEffects()

	for i, effect in ipairs(data.swirlEffects) do
		self.iconSwirlEffects[i] = self.IconSwirlModelScene:AddEffect(effect, self);
	end

	self:SetAlpha(1);
	self:Show();
	self.ShowAnim:Stop();
	self.ShowAnim:Play();
end

function CovenantChoiceToastMixin:StopBanner()
	self.ShowAnim:Stop();
	self:Hide();
end

function CovenantChoiceToastMixin:OnAnimFinished()
	self:Hide();
end
