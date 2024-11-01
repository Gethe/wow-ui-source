EndOfMatchFrameMixin = {};

local EndOfMatchFrameEvents = {
	"SHOW_END_OF_MATCH_UI",
};

function EndOfMatchFrameMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, EndOfMatchFrameEvents);
	self.hasMatchDetails = false;
	self.detailPool = CreateFramePool("Frame", self.DetailsContainer, "MatchDetailFrameTemplate");
	self.actionsButtonPool = CreateFramePool("Button", self, "EndOfMatchButtonBaseTemplate");

	EventRegistry:RegisterCallback("EndOfMatchUI.TryShow", self.TryShow, self)

	local checkSpectating = true;
	self:TryShow(checkSpectating);
end

function EndOfMatchFrameMixin:OnEvent(event, ...)
	if event == "SHOW_END_OF_MATCH_UI" then
		local checkSpectating = false;
		self:TryShow(checkSpectating);
	end
end

function EndOfMatchFrameMixin:TryShow(checkSpectating)
	self:TryUpdateMatchDetails();
	if not checkSpectating or not C_SpectatingUI.IsSpectating() then
		self:TryShowMatchDetails();
	end
end

local function UpdatePlacementTitle(endOfMatchFrame, matchEnded, placementDetail)
	local titleText = WOW_LABS_MATCH_COMPLETE;
	if placementDetail.value == 1 then
		titleText = WOW_LABS_MATCH_WON;
	elseif placementDetail.value == 2 or not matchEnded then
		titleText = string.format(WOW_LABS_MATCH_LOST, placementDetail.value);
	end

	endOfMatchFrame.Title:SetText(titleText);
end

local DetailInfos = {
	[Enum.MatchDetailType.Placement] = {
		description = WOW_LABS_MATCH_DETAILS_STANDING,
		iconAtlas = "plunderstorm-icon-trophy",
		onInitDetailCallback = UpdatePlacementTitle,
	},
	[Enum.MatchDetailType.Kills] = {
		description = WOW_LABS_MATCH_DETAILS_KILLS,
		iconAtlas = "plunderstorm-icon-kills",
	},
	[Enum.MatchDetailType.PlunderAcquired] = {
		description = WOW_LABS_MATCH_DETAILS_TOTAL_PLUNDER,
		iconAtlas = "plunderstorm-icon-plunderCoins",
	},
};

local function LeaveMatch()
	PlaySound(SOUNDKIT.IG_MAINMENU_LOGOUT);
	ForceLogout();
end

local function Requeue()
	C_WoWLabsMatchmaking.SetAutoQueueOnLogout(true);
	LeaveMatch();
end

local function OpenPlunderstore()
	EndOfMatchFrame:Hide();

	AccountStoreUtil.SetAccountStoreShown(true);
	AccountStoreFrame:SetFullscreenMode(true);
end

local function Spectate()
	EndOfMatchFrame:Hide();

	EventRegistry:TriggerEvent("EventToastManager.CloseActiveToasts");
	C_SpectatingUI.StartSpectating();
end

local ActionTemplates = {
	[Enum.EndOfMatchType.Plunderstorm] = {
		-- Requeue Button
		{
			showAtEndOfMatch = true,
			label = WOW_LABS_GO_AGAIN,
			isLarge = true,
			useCenterActionContainer = true,
			glowOnShow = true,

			OnClick = Requeue,
		},
		-- Leave Match Button
		{
			showAtEndOfMatch = true,
			label = WOW_LABS_REMATCH,
			OnClick = LeaveMatch,
		},
		-- Open Plunderstore
		{
			label = WOW_LABS_ACCOUNT_STORE,
			OnClick = OpenPlunderstore,
		},
		-- Spectate
		{
			label = SPECTATE,
			OnClick = Spectate,
		},
	},
};

function EndOfMatchFrameMixin:TryUpdateMatchDetails()
	local matchDetails = C_EndOfMatchUI.GetEndOfMatchDetails();
	if not matchDetails then
		self:Hide();
		return;
	end

	self.hasMatchDetails = true;
	self.matchEnded = matchDetails.matchEnded;

	self.detailPool:ReleaseAll();
	for index, matchDetail in ipairs(matchDetails.detailsList) do
		local detailFrame = self.detailPool:Acquire();
		local detailFrameInfo = DetailInfos[matchDetail.type];
		detailFrame.layoutIndex = index;
		detailFrame:Init(matchDetail.type, detailFrameInfo.description, matchDetail.value, detailFrameInfo.iconAtlas);

		if detailFrameInfo.onInitDetailCallback then
			detailFrameInfo.onInitDetailCallback(self, matchDetails.matchEnded, matchDetail);
		end
	end
	self.DetailsContainer:Layout();

	local actionsTemplate = ActionTemplates[matchDetails.matchType];
	local centerLayoutIndex = 1;
	local regularLayoutIndex = 1;

	self.actionsButtonPool:ReleaseAll();
	for index, actionInfo in ipairs(actionsTemplate) do
		local currAction = self.actionsButtonPool:Acquire();

		if actionInfo.useCenterActionContainer then
			currAction:SetParent(self.CenterActionsContainer);
			currAction.layoutIndex = centerLayoutIndex;
			centerLayoutIndex = centerLayoutIndex + 1;
		else
			currAction:SetParent(self.ActionsContainer);
			currAction.layoutIndex = regularLayoutIndex;
			regularLayoutIndex = regularLayoutIndex + 1;
		end

		currAction:Init(actionInfo);
		currAction:SetShown(actionInfo.showAtEndOfMatch or not self.matchEnded);
	end

	self.CenterActionsContainer:Layout();
	self.ActionsContainer:Layout();
end

function EndOfMatchFrameMixin:TryShowMatchDetails()
	if self.hasMatchDetails then
		SpectateFrame:LeaveSpectatingMode();
		self:Show();
	end
end

function EndOfMatchFrameMixin:HasMatchDetails()
	return self.hasMatchDetails;
end

MatchDetailFrameMixin = {};

function MatchDetailFrameMixin:Init(type, description, value, iconAtlas)
	self:Show();

	if type == Enum.MatchDetailType.PlunderAcquired then
		local accountStoreCurrencyID = C_AccountStore.GetCurrencyIDForStore(Constants.AccountStoreConsts.PlunderstormStoreFrontID);
		if value and accountStoreCurrencyID and AccountStoreUtil.IsCurrencyAtWarningThreshold(accountStoreCurrencyID) then
			value = value .. " " .. CreateSimpleTextureMarkup([[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]], 16, 16);
		end

		self.Description:SetText(description);

		self:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

			local tooltipaccountStoreCurrencyID = C_AccountStore.GetCurrencyIDForStore(Constants.AccountStoreConsts.PlunderstormStoreFrontID);
			if tooltipaccountStoreCurrencyID then
				AccountStoreUtil.AddCurrencyTotalTooltip(GameTooltip, tooltipaccountStoreCurrencyID);
			end

			local LifetimePlunderCurrencyType = 2922;
			local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(LifetimePlunderCurrencyType);
			if currencyInfo then
				local lifetimePlunderText = LIFETIME_PLUNDER_TOOLTIP_FORMAT:format(BreakUpLargeNumbers(currencyInfo.quantity));
				GameTooltip_AddHighlightLine(GameTooltip, lifetimePlunderText);
			end

			GameTooltip:Show();
		end);

		self:SetScript("OnLeave", function() GameTooltip_Hide(); print("hide"); end);
	else
		self:SetScript("OnEnter", nil);
		self:SetScript("OnLeave", nil);
	end

	self.Description:SetText(description);
	self.Value:SetText(value or "");
	self.Icon:SetAtlas(iconAtlas);
end

EndOfMatchButtonBaseMixin = {};

local s_MaxButtonWidth = 0;
local s_MaxLargeButtonWidth = 0;

function EndOfMatchButtonBaseMixin:Init(actionInfo)
	self:SetText(actionInfo.label);
	self.isLarge = actionInfo.isLarge;
	self.glowOnShow = actionInfo.glowOnShow;
	self:SetScript("OnClick", actionInfo.OnClick);

	self:SetNormalFontObject(self.isLarge and "GameFontNormalHuge" or "GameFontNormalLarge" );
	self:SetHighlightFontObject(self.isLarge and "GameFontHighlightHuge" or "GameFontHighlightLarge");

	local widthPadding = self.isLarge and 120 or 80;
	local width = self:GetTextWidth() + widthPadding;
	self:SetWidth(width);

	local height = self.isLarge and 48 or 32;
	self:SetHeight(height);

	if self.isLarge then
		s_MaxLargeButtonWidth = math.max(s_MaxLargeButtonWidth, width);
	else
		s_MaxButtonWidth = math.max(s_MaxButtonWidth, width);
	end
end

function EndOfMatchButtonBaseMixin:OnShow()
	local standardWidth = self.isLarge and s_MaxLargeButtonWidth or s_MaxButtonWidth
	self:SetWidth(standardWidth);

	if self.glowOnShow then
		local offsetX, offsetY, width, height = 23.5, -0.5, nil, 95;
		GlowEmitterFactory:Show(self, GlowEmitterMixin.Anims.GreenGlow, offsetX, offsetY, width, height);
	else
		GlowEmitterFactory:Hide(self);
	end
end