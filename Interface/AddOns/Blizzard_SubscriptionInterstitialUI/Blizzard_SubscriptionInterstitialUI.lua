
local MaximumBulletPoints = 10;


UIPanelWindows["SubscriptionInterstitialFrame"] = { area = "center", pushable = 0, whileDead = 1 };


SubscriptionInterstitialSubscribeButtonBaseMixin = {};

function SubscriptionInterstitialSubscribeButtonBaseMixin:OnLoad()
	local useAtlasSize = true;
	self.Background:SetAtlas(self.backgroundAtlas, useAtlasSize);

	self.ButtonText:ScaleTextToFit();
end

function SubscriptionInterstitialSubscribeButtonBaseMixin:OnShow()
	self:ClearClickState();
end

function SubscriptionInterstitialSubscribeButtonBaseMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	self.wasClicked = true;

	if StoreInterfaceUtil.OpenToSubscriptionProduct() then
		SendSubscriptionInterstitialResponse(Enum.SubscriptionInterstitialResponseType.Clicked);
	else
		SendSubscriptionInterstitialResponse(Enum.SubscriptionInterstitialResponseType.WebRedirect)
	end

	HideUIPanel(self:GetParent());
end

function SubscriptionInterstitialSubscribeButtonBaseMixin:WasClicked()
	return self.wasClicked;
end

function SubscriptionInterstitialSubscribeButtonBaseMixin:ClearClickState()
	self.wasClicked = false;
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


SubscriptionInterstitialCloseButtonMixin = {};

function SubscriptionInterstitialCloseButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	HideUIPanel(self:GetParent());
end


SubscriptionInterstitialFrameMixin = {}

function SubscriptionInterstitialFrameMixin:OnLoad()
	self:RegisterEvent("SHOW_SUBSCRIPTION_INTERSTITIAL");

	self.Inset.Bg:Hide();
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
		self:SetInterstitialType(interstitialType);
		ShowUIPanel(self);
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

	ShowUIPanel(self);
end

function SubscriptionInterstitialFrameMixin:SetInterstitialType(interstitialType)
	local isMaxLevel = interstitialType == Enum.SubscriptionInterstitialType.MaxLevel;
	self.SubscribeButton:SetShown(not isMaxLevel);
	self.UpgradeButton:SetShown(isMaxLevel);
end
