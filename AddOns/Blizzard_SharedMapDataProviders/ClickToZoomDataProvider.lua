ClickToZoomDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function ClickToZoomDataProviderMixin:FadeIn()
	self.MapLabel.FadeInAnim:Play();
end

function ClickToZoomDataProviderMixin:FadeOut()
	self.MapLabel.FadeOutAnim:Play();
end

function ClickToZoomDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	
	local fadeInCallback = function (event, isContinent)
		if isContinent then
			self:FadeIn();
		end
	end
	
	local fadeOutCallback = function (event, isContinent)
		if isContinent then
			self:FadeOut();
		end
	end
	
	self:GetMap():RegisterCallback("ZoneLabelFadeInStart", fadeInCallback);
	self:GetMap():RegisterCallback("ZoneLabelFadeOutStart", fadeOutCallback);

	if self.MapLabel then
		self.MapLabel:SetParent(self:GetMap());
		self:ClearAllPoints();
	else
		self.MapLabel = CreateFrame("FRAME", nil, self:GetMap(), "ClickToZoomDataProvider_LabelTemplate");
	end

	self.MapLabel:SetPoint("BOTTOMRIGHT", -75, 65);
	self.MapLabel:SetFrameStrata("HIGH");
	self.MapLabel:SetAlpha(1);
end

function ClickToZoomDataProviderMixin:RemoveAllData()
	self.MapLabel.FadeInAnim:Stop()
	self.MapLabel.FadeOutAnim:Stop()
	self.MapLabel:SetAlpha(0);
end

function ClickToZoomDataProviderMixin:RefreshAllData(fromOnShow)
	if self:GetMap():IsZoomedOut() then
		if not self.MapLabel.FadeInAnim:IsPlaying() then
			self.MapLabel:SetAlpha(1);
		end
	else
		if not self.MapLabel.FadeOutAnim:IsPlaying() then
			self.MapLabel:SetAlpha(0);
		end
	end
end