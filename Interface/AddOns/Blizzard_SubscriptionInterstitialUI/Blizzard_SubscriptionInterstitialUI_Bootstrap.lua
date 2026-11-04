function SubscriptionInterstitial_LoadUI()
	C_AddOns.LoadAddOn("Blizzard_SubscriptionInterstitialUI");
end

function SubscriptionInterstitial_ShowSubscriptionPeriod()
	SubscriptionInterstitial_LoadUI();
	SubscriptionInterstitialFrame:ShowInterstitial(Enum.SubscriptionInterstitialType.SubscriptionPeriod);
end
