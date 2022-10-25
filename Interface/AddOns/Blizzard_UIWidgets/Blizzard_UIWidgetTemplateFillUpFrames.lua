local function GetFillUpFramesVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.FillUpFrames, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateFillUpFrames"}, GetFillUpFramesVisInfoData);

UIWidgetTemplateFillUpFramesMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textureKitRegions = {
	DecorLeft = "%s_decor",
	DecorRight = "%s_decor",
}

local decorTopPadding = {
	dragonriding_vigor = 8;
};

local firstAndLastPadding = {
	dragonriding_vigor = -20;
};

function UIWidgetTemplateFillUpFramesMixin:OnLoad()
	UIWidgetBaseTemplateMixin.OnLoad(self); 
	self.fillUpFramePool = CreateFramePool("FRAME", self, "UIWidgetFillUpFrameTemplate");
end

function UIWidgetTemplateFillUpFramesMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetTooltip(widgetInfo.tooltip);

	SetupTextureKitOnRegions(widgetInfo.textureKit, self, textureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	self.DecorLeft.topPadding = decorTopPadding[widgetInfo.textureKit];
	self.DecorRight.topPadding = decorTopPadding[widgetInfo.textureKit];

	self.fillUpFramePool:ReleaseAll();

	if not self.lastNumFullFrames then
		self.lastNumFullFrames = widgetInfo.numFullFrames;
	end
	
	for index = 1, widgetInfo.numTotalFrames do
		local fillUpFrame = self.fillUpFramePool:Acquire();

		local isFull = (index <= widgetInfo.numFullFrames);
		local isFilling = (index == (widgetInfo.numFullFrames + 1));
		local flashFrame = isFull and (widgetInfo.numFullFrames > self.lastNumFullFrames) and (index > self.lastNumFullFrames);
		local pulseFrame = isFilling and widgetInfo.pulseFillingFrame and (widgetInfo.fillValue < widgetInfo.fillMax);

		fillUpFrame:SetPoint("TOPLEFT", self, "TOPLEFT");
		fillUpFrame:Setup(widgetContainer, widgetInfo.textureKit, isFull, isFilling, flashFrame, pulseFrame, widgetInfo.fillMin, widgetInfo.fillMax, widgetInfo.fillValue)
		fillUpFrame.layoutIndex = index;

		if isFull then
			self:ApplyEffectToFrame(widgetInfo, self.widgetContainer, fillUpFrame);
		else
			if fillUpFrame.effectController then
				fillUpFrame.effectController:CancelEffect();
				fillUpFrame.effectController = nil;
			end
		end

		if index == 1 then
			fillUpFrame.leftPadding = firstAndLastPadding[widgetInfo.textureKit];
		elseif index == widgetInfo.numTotalFrames then
			fillUpFrame.rightPadding = firstAndLastPadding[widgetInfo.textureKit];
		end
	end

	self.lastNumFullFrames = widgetInfo.numFullFrames;

	self:Layout();
end

function UIWidgetTemplateFillUpFramesMixin:ApplyEffects(widgetInfo)
	-- Intentionally empty, we apply the effect on the frames themselves when they are full
end

UIWidgetFillUpFrameTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

local frameTextureKitRegions = {
	BG = "%s_background",
	Frame = "%s_frame",
	Spark = "%s_spark",
	SparkMask = "%s_mask",
	Flash = "%s_flash",
};

local fillTextureKitFormatString = "%s_fill";

local fixedSizeByTextureKit = {
	dragonriding_vigor = {width=42, height=45};
};

local flashFameSound = {
	dragonriding_vigor = SOUNDKIT.UI_DRAGONRIDING_FULL_NODE;
};

function UIWidgetFillUpFrameTemplateMixin:Setup(widgetContainer, textureKit, isFull, isFilling, flashFrame, pulseFrame, min, max, value)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);

	SetupTextureKitOnRegions(textureKit, self, frameTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	local fillAtlas = fillTextureKitFormatString:format(textureKit);
	local fillAtlasInfo = C_Texture.GetAtlasInfo(fillAtlas);
	if fillAtlasInfo then
		self.Bar:SetStatusBarTexture(fillAtlas);
		self.Bar:SetSize(fillAtlasInfo.width, fillAtlasInfo.height);
		self.Spark:SetPoint("CENTER", self.Bar:GetStatusBarTexture(), "TOP", 0, 0);
	end

	self.Bar:SetMinMaxValues(min, max);

	if isFull then
		self.Bar:SetValue(max);
	elseif isFilling then
		self.Bar:SetValue(value);
	else
		self.Bar:SetValue(min);
	end

	if flashFrame then
		self.Flash.PulseAnim:Stop();
		self.Flash.FlashAnim:Restart();
		if flashFameSound[textureKit] then
			PlaySound(flashFameSound[textureKit]);
		end
	else
		if pulseFrame then
			self.Flash.PulseAnim:Play();
		else
			self.Flash.PulseAnim:Stop();
		end
	end

	self.Spark:SetShown(isFilling and value > min and value < max);

	local fixedSize = fixedSizeByTextureKit[textureKit];
	if fixedSize then
		self.fixedWidth = fixedSize.width;
		self.fixedHeight = fixedSize.height;
	else
		self.fixedWidth = nil;
		self.fixedHeight = nil;
	end

	self.leftPadding = nil;
	self.rightPadding = nil;

	self:Show();
	self:Layout();
end