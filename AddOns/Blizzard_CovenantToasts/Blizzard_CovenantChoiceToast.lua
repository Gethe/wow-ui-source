CovenantChoiceToastMixin = {};

function CovenantChoiceToastMixin:OnLoad()
	self:RegisterEvent("COVENANT_CHOSEN");
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

function CovenantChoiceToastMixin:OnHide()
	CovenantCelebrationBannerMixin.OnHide(self);

	TopBannerManager_BannerFinished();
end

function CovenantChoiceToastMixin:PlayCovenantChoiceToast(covenantID)
	local covenantData = C_Covenants.GetCovenantData(covenantID);
	if covenantData then
		TopBannerManager_Show(self, { 
			name = covenantData.name, 
			covenantColor = COVENANT_COLORS[covenantData.textureKit],
			textureKit = covenantData.textureKit,
			celebrationSoundKit = covenantData.celebrationSoundKit,
		});
	end
end

function CovenantChoiceToastMixin:PlayBanner(data)
	self.CovenantName:SetText(data.name);
	self.CovenantName:SetTextColor(data.covenantColor:GetRGB());
	self:SetCovenantTextureKit(data.textureKit);
	PlaySound(data.celebrationSoundKit);

	self.ToastBG:SetAlpha(0);
	self.GlowLineTop:SetAlpha(0);
	self.GlowLineTopAdditive:SetAlpha(0);
	self.Stars1:SetAlpha(0);
	self.Stars2:SetAlpha(0);
	self.IconSwirlModelScene:SetAlpha(0);
	self.Icon:SetAlpha(0);
	self.CovenantName:SetAlpha(0);
	self.HeaderText:SetAlpha(0);

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
