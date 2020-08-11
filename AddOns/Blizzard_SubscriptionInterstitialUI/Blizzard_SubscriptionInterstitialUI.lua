
UIPanelWindows["SubscriptionInterstitialFrame"] = { area = "center", pushable = 0, whileDead = 1 };


SubscriptionInterstitialSubscribeButtonMixin = {};

function SubscriptionInterstitialSubscribeButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	StoreFrame_SelectGameTimeProduct();
	ToggleStoreUI();
	HideUIPanel(self:GetParent());
end


SubscriptionInterstitialCloseButtonMixin = {};

function SubscriptionInterstitialCloseButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	HideUIPanel(self:GetParent());
end


SubscriptionInterstitialFrameMixin = {}

function SubscriptionInterstitialFrameMixin:OnLoad()
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");
end

function SubscriptionInterstitialFrameMixin:EvaluateShow()
	if UnitLevel("player") ~= 1 then
		ShowUIPanel(self);
	end
end

function SubscriptionInterstitialFrameMixin:OnEvent(event, ...)
	if event == "PLAYER_LEVEL_CHANGED" then
		local originalLevel, newLevel = ...;
		if newLevel == 20 then
			ShowUIPanel(self);
		end
	end
end
