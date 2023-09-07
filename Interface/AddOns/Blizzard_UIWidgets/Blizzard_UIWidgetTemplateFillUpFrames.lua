local function GetFillUpFramesVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.FillUpFrames, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateFillUpFrames"}, GetFillUpFramesVisInfoData);

UIWidgetTemplateFillUpFramesMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local decorFormatStringDefault = "%s_decor";
local decorFormatStringExtra = "%s_decor_%s";
local decorFlipbookLeftTextureKitFormatString = "%s_decor_flipbook_left";
local decorFlipbookRightTextureKitFormatString = "%s_decor_flipbook_right";

local decorTopPadding = {
	dragonriding_vigor = 8,
	dragonriding_sgvigor = -15,
};

local firstAndLastPadding = {
	dragonriding_vigor = -20,
	dragonriding_sgvigor = -17,
};

local decorFlipbookfixedSizeByTextureKit = {
	dragonriding_sgvigor = {width=77, height=106},
};

local decorFlipbookOffsetByTextureKit = {
	dragonriding_sgvigor = {x=7, y=12},
};


function UIWidgetTemplateFillUpFramesMixin:OnLoad()
	UIWidgetBaseTemplateMixin.OnLoad(self); 
	self.fillUpFramePool = CreateFramePool("FRAME", self, "UIWidgetFillUpFrameTemplate");
end

function UIWidgetTemplateFillUpFramesMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetTooltip(widgetInfo.tooltip);
	
	local atlasDecorName;

	if widgetInfo.frameTextureKit ~= nil and widgetInfo.frameTextureKit ~= "" then
		atlasDecorName = decorFormatStringExtra:format(widgetInfo.textureKit, widgetInfo.frameTextureKit);
	else
		atlasDecorName = decorFormatStringDefault:format(widgetInfo.textureKit);
	end

	self.DecorLeft:SetAtlas(atlasDecorName, TextureKitConstants.UseAtlasSize);
	self.DecorRight:SetAtlas(atlasDecorName, TextureKitConstants.UseAtlasSize);

	self.DecorLeft.topPadding = decorTopPadding[widgetInfo.textureKit];
	self.DecorRight.topPadding = decorTopPadding[widgetInfo.textureKit];

	local decorFlipbookAtlasLeft = decorFlipbookLeftTextureKitFormatString:format(widgetInfo.textureKit);
	local decorFlipbookAtlasRight = decorFlipbookRightTextureKitFormatString:format(widgetInfo.textureKit);
	local decorFlipbookAtlasInfoLeft = C_Texture.GetAtlasInfo(decorFlipbookAtlasLeft);
	local decorFlipbookAtlasInfoRight = C_Texture.GetAtlasInfo(decorFlipbookAtlasRight);
	if decorFlipbookAtlasInfoLeft and decorFlipbookAtlasInfoRight then
		self.DecorFlipbookLeft:SetAtlas(decorFlipbookAtlasLeft, TextureKitConstants.UseAtlasSize);
		self.DecorFlipbookRight:SetAtlas(decorFlipbookAtlasRight, TextureKitConstants.UseAtlasSize);

		local decorFlipbookFixedSize = decorFlipbookfixedSizeByTextureKit[widgetInfo.textureKit];
		if decorFlipbookFixedSize then
			self.DecorFlipbookLeft:SetSize(decorFlipbookFixedSize.width, decorFlipbookFixedSize.height);
			self.DecorFlipbookRight:SetSize(decorFlipbookFixedSize.width, decorFlipbookFixedSize.height);
		end

		local decorFlipbookOffset = decorFlipbookOffsetByTextureKit[widgetInfo.textureKit];
		if decorFlipbookOffset then
			self.DecorFlipbookLeft:SetPoint("CENTER", self.DecorLeft, -decorFlipbookOffset.x, decorFlipbookOffset.y);
			self.DecorFlipbookRight:SetPoint("CENTER", self.DecorRight, decorFlipbookOffset.x, decorFlipbookOffset.y);
		else
			self.DecorFlipbookLeft:SetPoint("CENTER", self.DecorLeft, 0, 0);
			self.DecorFlipbookRight:SetPoint("CENTER", self.DecorRight, 0, 0);
		end

	else
		self.DecorFlipbookLeft:Hide();
		self.DecorFlipbookRight:Hide();
	end

	self.fillUpFramePool:ReleaseAll();

	if not self.lastNumFullFrames then
		self.lastNumFullFrames = widgetInfo.numFullFrames;
	end

	local shouldPlayDecorAnimation = false;
	
	for index = 1, widgetInfo.numTotalFrames do
		local fillUpFrame = self.fillUpFramePool:Acquire();

		local isFull = (index <= widgetInfo.numFullFrames);
		local isFilling = (index == (widgetInfo.numFullFrames + 1));
		local flashFrame = isFull and (widgetInfo.numFullFrames > self.lastNumFullFrames) and (index > self.lastNumFullFrames);
		local pulseFrame = isFilling and widgetInfo.pulseFillingFrame and (widgetInfo.fillValue < widgetInfo.fillMax);
		local consumeFrame = not isFull and widgetInfo.numFullFrames < self.lastNumFullFrames and index == self.lastNumFullFrames;

		fillUpFrame:SetPoint("TOPLEFT", self, "TOPLEFT");
		fillUpFrame:Setup(widgetContainer, widgetInfo.textureKit, isFull, isFilling, flashFrame, pulseFrame, widgetInfo.fillMin, widgetInfo.fillMax, widgetInfo.fillValue, widgetInfo.frameTextureKit, consumeFrame)
		fillUpFrame.layoutIndex = index;

		if flashFrame then
			shouldPlayDecorAnimation = true;
		end

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

	if shouldPlayDecorAnimation and decorFlipbookAtlasInfoLeft and decorFlipbookAtlasInfoRight then
		self.DecorFlipbookLeft:Show();
		self.DecorFlipbookRight:Show();
		self.DecorFlipbookAnim:Restart();
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
	Spark = "%s_spark",
	SparkMask = "%s_mask",
	Flash = "%s_flash",
};

local fillTextureKitFormatString = "%s_fill";
local fillFullTextureKitFormatString = "%s_fillfull";
local fillFlipbookTextureKitFormatString = "%s_fill_flipbook";

local frameFormatStringDefault = "%s_frame";
local frameFormatStringExtra = "%s_frame_%s";

local burstFlipbookTextureKitFormatString = "%s_burst_flipbook";
local filledFlipbookTextureKitFormatString = "%s_filled_flipbook";

local fixedSizeByTextureKit = {
	dragonriding_vigor = {width=42, height=45},
	dragonriding_sgvigor = {width=48, height=62},
};

local filledFlipbookfixedSizeByTextureKit = {
	dragonriding_sgvigor = {width=34, height=50},
};

local burstFlipbookfixedSizeByTextureKit = {
	dragonriding_sgvigor = {width=100, height=100},
};

local flashFameSound = {
	dragonriding_vigor = SOUNDKIT.UI_DRAGONRIDING_FULL_NODE,
	dragonriding_sgvigor = SOUNDKIT.UI_DRAGONRIDING_FULL_NODE,
};

function UIWidgetFillUpFrameTemplateMixin:Setup(widgetContainer, textureKit, isFull, isFilling, flashFrame, pulseFrame, min, max, value, frameTextureKit, consumeFrame)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);

	SetupTextureKitOnRegions(textureKit, self, frameTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	local atlasFrameName;
	if frameTextureKit ~= nil and frameTextureKit ~= "" then
		atlasFrameName = frameFormatStringExtra:format(textureKit, frameTextureKit);
	else
		atlasFrameName = frameFormatStringDefault:format(textureKit);
	end

	self.Frame:SetAtlas(atlasFrameName, TextureKitConstants.UseAtlasSize);

	local fillAtlas;
	if isFull then
		fillAtlas = fillFullTextureKitFormatString:format(textureKit);
	else
		fillAtlas = fillTextureKitFormatString:format(textureKit);
	end

	local fillAtlasInfo = C_Texture.GetAtlasInfo(fillAtlas);
	if fillAtlasInfo and fillAtlas ~= self.lastFillAtlas then
		self.Bar:SetStatusBarTexture(fillAtlas);
		self.Bar:SetSize(fillAtlasInfo.width, fillAtlasInfo.height);
		self.Spark:SetPoint("CENTER", self.Bar:GetStatusBarTexture(), "TOP", 0, 0);
		self.Bar.FlipbookMask:SetPoint("TOP", self.Bar:GetStatusBarTexture(), "TOP", 0, 0);
		self.lastFillAtlas = fillAtlas;
	end

	local flipbookAtlas = fillFlipbookTextureKitFormatString:format(textureKit);
	local flipbookAtlasInfo = C_Texture.GetAtlasInfo(flipbookAtlas);
	if flipbookAtlasInfo then
		self.Bar.Flipbook:SetAtlas(flipbookAtlas, TextureKitConstants.UseAtlasSize);
	end

	local burstFlipbookAtlas = burstFlipbookTextureKitFormatString:format(textureKit);
	local burstFlipbookAtlasInfo = C_Texture.GetAtlasInfo(burstFlipbookAtlas);
	if burstFlipbookAtlasInfo then
		self.Bar.BurstFlipbook:SetAtlas(burstFlipbookAtlas, TextureKitConstants.UseAtlasSize);

		local burstFlipbookFixedSize = burstFlipbookfixedSizeByTextureKit[textureKit];
		if burstFlipbookFixedSize then
			self.Bar.BurstFlipbook:SetSize(burstFlipbookFixedSize.width, burstFlipbookFixedSize.height);
		end
	else
		self.Bar.BurstFlipbook:Hide();
	end

	local filledFlipbookAtlas = filledFlipbookTextureKitFormatString:format(textureKit);
	local filledFlipbookAtlasInfo = C_Texture.GetAtlasInfo(filledFlipbookAtlas);
	if filledFlipbookAtlasInfo then
		self.Bar.FilledFlipbook:SetAtlas(filledFlipbookAtlas, TextureKitConstants.UseAtlasSize);
		
		local filledFlipbookFixedSize = filledFlipbookfixedSizeByTextureKit[textureKit];
		if filledFlipbookFixedSize then
			self.Bar.FilledFlipbook:SetSize(filledFlipbookFixedSize.width, filledFlipbookFixedSize.height);
		end
	else
		self.Bar.FilledFlipbook:Hide();
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
		self.Bar.Flipbook:Hide();
		self.Flash.PulseAnim:Stop();
		self.Flash.FlashAnim:Restart();
		if flashFameSound[textureKit] then
			PlaySound(flashFameSound[textureKit]);
		end

		if filledFlipbookAtlasInfo then
			self.Bar.FilledFlipbook:Show();
			self.Bar.FilledFlipbookAnim:Restart();	
		else
			self.Bar.FilledFlipbook:Hide();
			self.Bar.FilledFlipbookAnim:Stop();
		end
	else
		if pulseFrame then
			self.Flash.PulseAnim:Play();
			if flipbookAtlasInfo then
				self.Bar.Flipbook:Show();
				self.Bar.FillupFlipbookAnim:Play();
			end
		else
			self.Flash.PulseAnim:Stop();
			self.Bar.Flipbook:Hide();
			self.Bar.FillupFlipbookAnim:Stop();
		end
	end

	if consumeFrame then
		if burstFlipbookAtlasInfo then
			self.Bar.BurstFlipbook:Show();
			self.Bar.BurstFlipbookAnim:Restart();
		else
			self.Bar.BurstFlipbook:Hide();
			self.Bar.BurstFlipbookAnim:Stop();
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

DecorFlipbookAnimMixin = {}

function DecorFlipbookAnimMixin:OnAnimFinished()
	self:GetParent().DecorFlipbookLeft:Hide();
	self:GetParent().DecorFlipbookRight:Hide();
end

FilledFlipbookAnimMixin = {}

function FilledFlipbookAnimMixin:OnAnimFinished()
	self:GetParent().FilledFlipbook:Hide();
end

BurstFlipbookAnimMixin = {}

function BurstFlipbookAnimMixin:OnAnimFinished()
	self:GetParent().BurstFlipbook:Hide();
end