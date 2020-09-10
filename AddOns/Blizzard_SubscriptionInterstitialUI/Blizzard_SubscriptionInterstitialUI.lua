
local MaximumBulletPoints = 10;


UIPanelWindows["SubscriptionInterstitialFrame"] = { area = "center", pushable = 0, whileDead = 1 };


SubscriptionInterstitialSubscribeButtonMixin = {};

function SubscriptionInterstitialSubscribeButtonMixin:OnLoad()
	local useAtlasSize = true;
	self.Background:SetAtlas(self.backgroundAtlas, useAtlasSize);
end

function SubscriptionInterstitialSubscribeButtonMixin:OnShow()
	self:ClearClickState();
end

function SubscriptionInterstitialSubscribeButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	SendSubscriptionInterstitialResponse(Enum.SubscriptionInterstitialResponseType.Clicked);

	if C_StorePublic.DoesGroupHavePurchaseableProducts(WOW_GAME_TIME_CATEGORY_ID) then
		StoreFrame_SelectGameTimeProduct();
		ToggleStoreUI();
	else
		LoadURLIndex(22);
	end

	self.wasClicked = true;

	HideUIPanel(self:GetParent());
end

function SubscriptionInterstitialSubscribeButtonMixin:WasClicked()
	return self.wasClicked;
end

function SubscriptionInterstitialSubscribeButtonMixin:ClearClickState()
	self.wasClicked = false;
end


SubscriptionInterstitialUpgradeButtonMixin = {};

function SubscriptionInterstitialUpgradeButtonMixin:OnLoad()
	SubscriptionInterstitialSubscribeButtonMixin.OnLoad(self);

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

function SubscriptionInterstitialFrameMixin:OnHide()
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

function SubscriptionInterstitialFrameMixin:SetInterstitialType(interstitialType)
	local isMaxLevel = interstitialType == Enum.SubscriptionInterstitialType.MaxLevel;
	self.SubscribeButton:SetShown(not isMaxLevel);
	self.UpgradeButton:SetShown(isMaxLevel);
end
