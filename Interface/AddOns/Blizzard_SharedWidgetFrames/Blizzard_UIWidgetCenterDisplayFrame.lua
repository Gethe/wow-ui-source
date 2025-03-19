
local textureKitBackgroundFormat = "%s-Background";
local widgetContainerYOffsetsByTextureKit = {
	["completiondialog-dragonflightcampaign"] = 43,
	["completiondialog-warwithincampaign"] = 43,
};

WidgetCenterDisplayFrameMixin = { };

function WidgetCenterDisplayFrameMixin:OnLoad()
	self:RegisterEvent("GENERIC_WIDGET_DISPLAY_SHOW");
end

function WidgetCenterDisplayFrameMixin:OnEvent(event, ...)
	if(event == "GENERIC_WIDGET_DISPLAY_SHOW") then
		self:Setup(...);
	end
end

function WidgetCenterDisplayFrameMixin:OnHide()
	self.WidgetContainer:UnregisterForWidgetSet();
end

function WidgetCenterDisplayFrameMixin:Setup(displayInfo)
	if(not displayInfo) then 
		return;
	end

	self:Show();
	self.TitleContainer.Title:SetText(displayInfo.title);
	local hasTitleText = displayInfo.title and displayInfo.title ~= "";
	self.TitleContainer:SetShown(hasTitleText);

	if(not self.TitleContainer:IsShown()) then
		self.WidgetContainer:ClearAllPoints();
		self.WidgetContainer:SetPoint("TOPLEFT", self);
	end

	self.WidgetContainer:UnregisterForWidgetSet();

	if(displayInfo.uiWidgetSetID) then
		self.WidgetContainer:RegisterForWidgetSet(displayInfo.uiWidgetSetID, DefaultWidgetLayout);
		local widgetContainerOffsetY = widgetContainerYOffsetsByTextureKit[displayInfo.uiTextureKit];
		if (widgetContainerOffsetY) then
			self.WidgetContainer:ClearAllPoints();
			self.WidgetContainer:SetPoint("TOP", self.TitleContainer, "BOTTOM", 0, widgetContainerOffsetY);
		end
	end

	if(displayInfo.uiTextureKit) then
		local atlas = GetFinalNameFromTextureKit(textureKitBackgroundFormat, displayInfo.uiTextureKit);
		if(atlas) then
			self.Background:SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
		else
			self.Background:SetAtlas(nil);
		end
	end
	self.fixedWidth = displayInfo.frameWidth > 0 and displayInfo.frameWidth or nil;
	self.fixedHeight = displayInfo.frameHeight > 0 and displayInfo.frameHeight or nil;

	if(self.TitleContainer:IsShown()) then
		self.TitleContainer.fixedWidth = self.fixedWidth or self:GetWidth();
		self.TitleContainer.Title:SetWidth(self.TitleContainer.fixedWidth);
		self.TitleContainer:Layout();
	end

	self:SetupButtons(displayInfo);
	self:Layout();
end

function WidgetCenterDisplayFrameMixin:SetupButtons(displayInfo)
	local hasExtraButtonText = displayInfo.extraButtonText and displayInfo.extraButtonText ~= "";
	local hasCloseButtonText = displayInfo.closeButtonText and displayInfo.closeButtonText ~= "";

	if(hasExtraButtonText) then
		self.ExtraButton:SetText(displayInfo.extraButtonText);
	end

	if(hasCloseButtonText) then
		self.CloseButton:SetText(displayInfo.closeButtonText);
	else 
		self.CloseButton:SetText(CLOSE);
	end

	self.ExtraButton:SetShown(hasExtraButtonText);
	self.ExtraButton:ClearAllPoints();
	self.CloseButton:ClearAllPoints();

	if (self.ExtraButton:IsShown() and self.CloseButton:IsShown()) then
		self.ExtraButton:SetPoint("BOTTOM", -100, 15);
		self.CloseButton:SetPoint("LEFT", self.ExtraButton, "RIGHT", 80, 0);
	else
		self.CloseButton:SetPoint("BOTTOM", 0, 15);
	end 
end

UIWidgetCenterDisplayFrameButtonMixin = { };

function UIWidgetCenterDisplayFrameButtonMixin:OnClick()
	self:GetParent():Hide();
	C_GenericWidgetDisplay.Close();
end

UIWidgetCenterDisplayFrameExtraButtonMixin = { };

function UIWidgetCenterDisplayFrameExtraButtonMixin:OnClick()
	C_GenericWidgetDisplay.Acknowledge();
end