
local function GetPlayerPartyMemberInfo()
	local members = C_WoWLabsMatchmaking.GetCurrentParty();
	for i, memberInfo in ipairs(members) do
		if memberInfo.isLocalPlayer then
			return memberInfo;
		end
	end

	return nil;
end

PlunderstormAccountStoreToggleMixin = {};

function PlunderstormAccountStoreToggleMixin:OnClick()
	-- TODO:: play a sound

	-- The Plunderstore should only show if we already have party member info since this
	-- will be required to check which things you own from the original Plunderstorm Renown track.
	if GetPlayerPartyMemberInfo() ~= nil then
		AccountStoreUtil.ToggleAccountStore();
	end
end

function PlunderstormAccountStoreToggleMixin:OnEnter()
	if not self:IsEnabled() then
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_LEFT");
		tooltip:SetText(ACCOUNT_STORE_UNAVAILABLE);
		tooltip:Show();
	end
end

function PlunderstormAccountStoreToggleMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

PlunderstormBasicsContainerFrameMixin = {};

local PlunderstormBasicsContainerFrameEvents = {
	"ACCOUNT_STORE_CURRENCY_AVAILABLE_UPDATED",
	"STORE_FRONT_STATE_UPDATED",
};

function PlunderstormBasicsContainerFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, PlunderstormBasicsContainerFrameEvents);

	if C_Glue.IsOnGlueScreen() and not self.PlunderstoreToggle then
		local plunderstoreToggle = CreateFrame("BUTTON", nil, self, "PlunderstormAccountStoreToggleTemplate");
		self.PlunderstoreToggle = plunderstoreToggle;
		plunderstoreToggle.layoutIndex = self.PlunderDisplay.layoutIndex + 1;
		plunderstoreToggle.topPadding = 20;
		plunderstoreToggle.align = "center";
		plunderstoreToggle.bottomPadding = 20;
		self.PlunderDisplay.bottomPadding = 20;
		plunderstoreToggle:SetEnabled(C_AccountStore.GetStoreFrontState(Constants.AccountStoreConsts.PlunderstormStoreFrontID) == Enum.AccountStoreState.Available);
		plunderstoreToggle:Show();
	end

	self.PlunderDisplay:SetScript("OnEnter", function ()
		local lifetimePlunder = self:GetLifetimePlunder();
		local hasLifetimePlunder = (lifetimePlunder ~= nil);
		if hasLifetimePlunder then
			local tooltip = GetAppropriateTooltip();
			tooltip:SetOwner(self.PlunderDisplay, "ANCHOR_LEFT");

			local accountStoreCurrencyID = C_AccountStore.GetCurrencyIDForStore(Constants.AccountStoreConsts.PlunderstormStoreFrontID);
			if accountStoreCurrencyID then
				AccountStoreUtil.AddCurrencyTotalTooltip(tooltip, accountStoreCurrencyID);
			end

			local lifetimePlunderText = LIFETIME_PLUNDER_TOOLTIP_FORMAT:format(BreakUpLargeNumbers(lifetimePlunder));
			GameTooltip_AddHighlightLine(tooltip, lifetimePlunderText);
			tooltip:Show();
		end
	end);

	self.PlunderDisplay:SetScript("OnLeave", function ()
		GetAppropriateTooltip():Hide();
	end);

	self:UpdatePlunderAmount();

	BaseLayoutMixin.OnShow(self);
end

function PlunderstormBasicsContainerFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, PlunderstormBasicsContainerFrameEvents);
end

function PlunderstormBasicsContainerFrameMixin:OnEvent(event)
	if event == "ACCOUNT_STORE_CURRENCY_AVAILABLE_UPDATED" then
		-- No need to check which currency was updated since there should be only one in Plunderstorm.
		self:UpdatePlunderAmount();
	elseif event == "STORE_FRONT_STATE_UPDATED" then
		self.PlunderstoreToggle:SetEnabled(C_AccountStore.GetStoreFrontState(Constants.AccountStoreConsts.PlunderstormStoreFrontID) == Enum.AccountStoreState.Available);
	end
end

function PlunderstormBasicsContainerFrameMixin:GetLifetimePlunder()
	-- In-game we can use the currency directly.
	if C_CurrencyInfo then
		-- Avoiding adding a proper constant for this so there's no leaking. Should really be something like Constants.CurrencyConsts.CURRENCY_ID_LIFETIME_PLUNDER
		local LifetimePlunderCurrencyType = 2922;
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(LifetimePlunderCurrencyType);
		if currencyInfo then
			return currencyInfo.quantity;
		end
	else
		local memberInfo = GetPlayerPartyMemberInfo();
		if memberInfo then
			return memberInfo.lifetimePlunder;
		end
	end

	return nil;
end

function PlunderstormBasicsContainerFrameMixin:UpdatePlunderAmount()
	local accountStoreCurrencyID = C_AccountStore.GetCurrencyIDForStore(Constants.AccountStoreConsts.PlunderstormStoreFrontID);
	if not accountStoreCurrencyID then
		self.PlunderDisplay.PlunderAmount:SetText("-");
		return;
	end

	if not AccountStoreUtil then
		C_AddOns.LoadAddOn("Blizzard_AccountStore");
	end

	local text = AccountStoreUtil.FormatCurrencyDisplayWithWarning(accountStoreCurrencyID);
	self.PlunderDisplay.PlunderAmount:SetText(text);
end

function PlunderstormBasicsContainerFrameMixin:SetBottomFrame(bottomFrame)
	self.bottomFrame = bottomFrame;
	self:UpdateScaleToFit();
end

function PlunderstormBasicsContainerFrameMixin:OnCleaned()
	self:UpdateScaleToFit();
end

function PlunderstormBasicsContainerFrameMixin:UpdateScaleToFit()
	self:SetScale(1.0);

	if not self.bottomFrame then
		return;
	end

	local totalSpace = self:GetHeight();
	local bottomSpace = self:GetBottom() - self.bottomFrame:GetTop();
	if bottomSpace >= 0 then
		return;
	end

	self:SetScale((totalSpace + bottomSpace) / totalSpace);
end
