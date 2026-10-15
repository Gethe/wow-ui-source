local MAXIMUM_BULLET_POINTS = 10;
local TITLE_COLOR = CreateColor(1.0, 0.9294118, 0.8235294);
local SUBTEXT_COLOR = CreateColor(0.9215686, 0.8039216, 0.6352941);

local function GetUpgradeAtlas()
	local factionGroup = UnitFactionGroup("player");
	return string.format("interstitial-newplayerexperience-upgrade-%s", factionGroup);
end

local SubscriptionInterstitialFrameMixin_OnLoad = SubscriptionInterstitialFrameMixin.OnLoad;
function SubscriptionInterstitialFrameMixin:OnLoad()
	SubscriptionInterstitialFrameMixin_OnLoad(self);
	self:SetSize(812, 509);
	self.Inset:Hide();
	self.ShadowOverlay:Hide();
	SubscriptionInterstitialFrameBg:Hide();
	SubscriptionInterstitialFrameTopTileStreaks:Hide();
	self.ClosePanelButton:Hide();
end

local SubscriptionInterstitialUpgradeButtonMixin_OnLoad = SubscriptionInterstitialUpgradeButtonMixin.OnLoad;
function SubscriptionInterstitialUpgradeButtonMixin:OnLoad()
	SubscriptionInterstitialUpgradeButtonMixin_OnLoad(self);

	self.insideFrameContainer = CreateFrame("Frame", nil, self:GetParent());
	self.insideFrameContainer:SetFrameLevel(self:GetFrameLevel() + 1);
	self.insideFrameContainer:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", 8, -22);
	self.insideFrameContainer:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", -4, 3);
	self.insideFrame = self.insideFrameContainer:CreateTexture(nil, "ARTWORK");
	self.insideFrame:SetAtlas("common-insideframe");
	self.insideFrame:SetAllPoints(self.insideFrameContainer);

	local factionGroup = UnitFactionGroup("player");
	local hordeOffsetX = factionGroup == "Alliance" and 0 or 305;

	self.Background:SetAtlas(GetUpgradeAtlas(), TextureKitConstants.UseAtlasSize);
	self.Background:ClearAllPoints();
	self.Background:SetPoint("CENTER", -1, -9);
	self.TitleLine:SetTextColor(TITLE_COLOR:GetRGBA());
	self.TitleSubText:SetTextColor(SUBTEXT_COLOR:GetRGBA());
	self.ButtonText:SetFontObject(GameFontNormalHuge);
	self.ButtonText:SetTextColor(NORMAL_FONT_COLOR:GetRGBA());
	self.ButtonText:SetWidth(270);
	self.bulletPointPool:ReleaseAll();

	local point, relativeTo, relativePoint, offsetX = self.TitleLine:GetPoint(1);
	self.TitleLine:ClearAllPoints();
	self.TitleLine:SetPoint(point, relativeTo, relativePoint, offsetX + hordeOffsetX, -93);

	point, relativeTo, relativePoint, offsetX = self.TitleSubText:GetPoint(1);
	self.TitleSubText:ClearAllPoints();
	self.TitleSubText:SetPoint(point, relativeTo, relativePoint, offsetX + hordeOffsetX, -134);

	local function BulletPointFactoryFunction(index)
		local bulletPointText = _G["SUBSCRIPTION_INTERSTITIAL_UPGRADE_BULLET"..index];
		if not bulletPointText or (bulletPointText == "") then
			return nil;
		end

		local bulletPoint = self.bulletPointPool:Acquire();
		bulletPoint.Bullet:ClearAllPoints();
		bulletPoint.Bullet:SetPoint("TOPLEFT");
		bulletPoint.Text:ClearAllPoints();
		bulletPoint.Text:SetPoint("TOPLEFT", bulletPoint.Bullet, "RIGHT", 13, 8);
		bulletPoint.Text:SetTextColor(TITLE_COLOR:GetRGBA());
		bulletPoint.Text:SetText(bulletPointText);
		bulletPoint:Show();
		return bulletPoint;
	end

	local x, y = -141 + hordeOffsetX, -180;
	local spacing = 20;
	for index = 1, MAXIMUM_BULLET_POINTS do
		local bulletPoint = BulletPointFactoryFunction(index);
		if bulletPoint then
			bulletPoint:SetPoint("TOP", self, "TOP", x, y);
			y = y - spacing - bulletPoint.Text:GetHeight();
		end
	end

	self.ButtonText:ClearAllPoints();
	if factionGroup == "Alliance" then
		self.ButtonText:SetPoint("BOTTOM", -155, 80);
	else
		self.ButtonText:SetPoint("BOTTOM", 157, 80);
	end
end
