
local MaximumBulletPoints = 10;


if not C_Glue.IsOnGlueScreen() then
	UIPanelWindows["SubscriptionInterstitialFrame"] = { area = "center", pushable = 0, whileDead = 1 };
end


local SmartNavigationClickTrackingMixin = {};

function SmartNavigationClickTrackingMixin:OnShow()
	self:ClearClickState();
end

function SmartNavigationClickTrackingMixin:MarkClicked()
	self.wasClicked = true;
end

function SmartNavigationClickTrackingMixin:WasClicked()
	return self.wasClicked;
end

function SmartNavigationClickTrackingMixin:ClearClickState()
	self.wasClicked = false;
end


SubscriptionInterstitialSubscribeButtonBaseMixin = CreateFromMixins(SmartNavigationClickTrackingMixin);

function SubscriptionInterstitialSubscribeButtonBaseMixin:OnLoad()
	local useAtlasSize = true;
	self.Background:SetAtlas(self.backgroundAtlas, useAtlasSize);

	self.ButtonText:ScaleTextToFit();
end


SubscriptionInterstitialSubscribeButtonMixin = {};

function SubscriptionInterstitialSubscribeButtonMixin:OnLoad()
	SubscriptionInterstitialSubscribeButtonBaseMixin.OnLoad(self);

	self.FirstLine:ScaleTextToFit();
	self.SecondLine:ScaleTextToFit();
	self.ThirdLine:ScaleTextToFit();

	local maxSecondLineHeight = math.min(self.FirstLine:GetStringHeight(), self.ThirdLine:GetStringHeight());
	local currentSecondLineHeight = self.SecondLine:GetStringHeight();
	if currentSecondLineHeight > maxSecondLineHeight then
		local textScale = self.SecondLine:GetTextScale();
		self.SecondLine:SetTextScale(textScale * maxSecondLineHeight / currentSecondLineHeight);
	end
end


SubscriptionInterstitialUpgradeButtonMixin = {};

function SubscriptionInterstitialUpgradeButtonMixin:OnLoad()
	SubscriptionInterstitialSubscribeButtonBaseMixin.OnLoad(self);

	self.TitleLine:ScaleTextToFit();
	self.TitleSubText:ScaleTextToFit();

	self.bulletPointPool = CreateFramePool("FRAME", self, "SubscriptionInterstitialBulletPointTemplate");

	local function BulletPointFactoryFunction(index)
		local bulletPointText = _G["SUBSCRIPTION_INTERSTITIAL_UPGRADE_BULLET"..index];
		if not bulletPointText or (bulletPointText == "") then
			return nil;
		end

		local bulletPoint = self.bulletPointPool:Acquire();
		bulletPoint.Text:SetText(bulletPointText);
		bulletPoint:Show();
		return bulletPoint;
	end

	local stride = 1;
	local paddingX = 0;
	local paddingY = 22;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, paddingX, paddingY);
	local initialAnchor = AnchorUtil.CreateAnchor("TOP", self, "TOP", -141, -168);
	AnchorUtil.GridLayoutFactoryByCount(BulletPointFactoryFunction, MaximumBulletPoints, initialAnchor, layout);
end


SubscriptionInterstitialFrameMixin = {}

function SubscriptionInterstitialFrameMixin:OnLoad()
	self:RegisterEvent("SHOW_SUBSCRIPTION_INTERSTITIAL");

	self.Inset.Bg:Hide();

	self:CreateShadowOverlay();

	local function OnCloseClick()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
		self:HideInterstitial();
	end

	self.CloseButton:SetScript("OnClick", OnCloseClick);
	self.ClosePanelButton:SetScript("OnClick", OnCloseClick);

	local function OnSubscribeClick(button)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

		button:MarkClicked();

		if StoreInterfaceUtil.OpenToSubscriptionProduct() then
			SendSubscriptionInterstitialResponse(Enum.SubscriptionInterstitialResponseType.Clicked);
		else
			SendSubscriptionInterstitialResponse(Enum.SubscriptionInterstitialResponseType.WebRedirect);
		end

		self:HideInterstitial();
	end

	self.SubscribeButton:SetScript("OnClick", OnSubscribeClick);
	self.UpgradeButton:SetScript("OnClick", OnSubscribeClick);
end

function SubscriptionInterstitialFrameMixin:CreateShadowOverlay()
	self.ShadowOverlay = CreateFrame("Frame", nil, self, "ShadowOverlaySmallTemplate");
	self.ShadowOverlay:SetFrameLevel(500);
	self.ShadowOverlay:SetPoint("TOPLEFT", self.Inset, "TOPLEFT", 3, -3);
	self.ShadowOverlay:SetPoint("BOTTOMRIGHT", self.Inset, "BOTTOMRIGHT", -3, 2);
end

function SubscriptionInterstitialFrameMixin:OnShow()
	self.cinematicIsShowing = nil;
	EventRegistry:RegisterCallback("CinematicFrame.CinematicStarting", self.OnCinematicStarting, self);
end

function SubscriptionInterstitialFrameMixin:OnHide()
	if self.cinematicIsShowing then
		return;
	end

	EventRegistry:UnregisterCallback("CinematicFrame.CinematicStarting", self);
	EventRegistry:UnregisterCallback("CinematicFrame.CinematicStopped", self);

	if not self.SubscribeButton:WasClicked() and not self.UpgradeButton:WasClicked() then
		SendSubscriptionInterstitialResponse(Enum.SubscriptionInterstitialResponseType.Closed);

		self.SubscribeButton:ClearClickState();
		self.UpgradeButton:ClearClickState();
	end
end

function SubscriptionInterstitialFrameMixin:OnEvent(event, ...)
	if event == "SHOW_SUBSCRIPTION_INTERSTITIAL" then
		local interstitialType = ...;
		self:ShowInterstitial(interstitialType);
	end
end

function SubscriptionInterstitialFrameMixin:ShowInterstitial(interstitialType)
	self:SetInterstitialType(interstitialType);

	if C_Glue.IsOnGlueScreen() then
		-- Parented so it hides with character select; character select raises itself on click, so only a higher strata keeps this above it.
		self:SetParent(CharacterSelect);
		self:SetFrameStrata("DIALOG");
		self:Show();
	else
		ShowUIPanel(self);
	end
end

function SubscriptionInterstitialFrameMixin:HideInterstitial()
	if C_Glue.IsOnGlueScreen() then
		self:Hide();
	else
		HideUIPanel(self);
	end
end

function SubscriptionInterstitialFrameMixin:OnCinematicStarting()
	self.cinematicIsShowing = true;
	EventRegistry:UnregisterCallback("CinematicFrame.CinematicStarting", self);
	EventRegistry:RegisterCallback("CinematicFrame.CinematicStopped", self.OnCinematicStopped, self);
end

function SubscriptionInterstitialFrameMixin:OnCinematicStopped()
	self.cinematicIsShowing = nil;
	EventRegistry:UnregisterCallback("CinematicFrame.CinematicStopped", self);

	self:ShowInterstitial(self.interstitialType);
end

function SubscriptionInterstitialFrameMixin:SetInterstitialType(interstitialType)
	self.interstitialType = interstitialType;

	local isSubscriptionPeriod = interstitialType == Enum.SubscriptionInterstitialType.SubscriptionPeriod;
	local showUpgrade = isSubscriptionPeriod or (interstitialType == Enum.SubscriptionInterstitialType.MaxLevel);
	self.SubscribeButton:SetShown(not showUpgrade);
	self.UpgradeButton:SetShown(showUpgrade);
	self.UpgradeButton.TitleSubText:SetShown(not isSubscriptionPeriod);
end
