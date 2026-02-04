local timeRemainingFormatter = CreateFromMixins(SecondsFormatterMixin);
timeRemainingFormatter:Init(
	SecondsFormatterConstants.ZeroApproximationThreshold,
	SecondsFormatter.Abbreviation.OneLetter,
	SecondsFormatterConstants.DontRoundUpLastUnit,
	SecondsFormatterConstants.ConvertToLower,
	SecondsFormatterConstants.RoundUpIntervals);
timeRemainingFormatter:SetDesiredUnitCount(2);
timeRemainingFormatter:SetMinInterval(SecondsFormatter.Interval.Minutes);
timeRemainingFormatter:SetStripIntervalWhitespace(true);

local RED_TEXT_SECONDS_THRESHOLD = 1800;

----------------------------------------------------------------------------------
-- CatalogShopRefundButtonMixin
----------------------------------------------------------------------------------
CatalogShopRefundButtonMixin = {};

-- TODO (WOW12-45327): Cleaner and easier to use :SetScript("OnClick", function () ... end); in the parent's OnLoad (see https://wowhub.corp.blizzard.net/warcraft/wow/pull/40310)
function CatalogShopRefundButtonMixin:OnClick()
	PlaySound(SOUNDKIT.CATALOG_SHOP_SELECT_GENERIC_UI_BUTTON);
	if (self.catalogShopRefundOnClickMethod) then
		CatalogShopRefundFrame[self.catalogShopRefundOnClickMethod](CatalogShopRefundFrame);
	end
end

function CatalogShopRefundButtonMixin:OnEnter()
end

function CatalogShopRefundButtonMixin:OnLeave()
end

----------------------------------------------------------------------------------
-- RefundHeaderSortButtonMixin
----------------------------------------------------------------------------------
RefundHeaderSortButtonMixin = {};
function RefundHeaderSortButtonMixin:OnLoad()
	self.labelSet = false;
	if self.iconAtlas then
		self.Icon:Show();
		self.Icon:SetAtlas(self.iconAtlas, true);
	elseif self.labelText then
		self.Label:Show();
		self.Label:SetText(self.labelText);
		self.labelSet = true;
	end

	local color = self.normalColor or NORMAL_FONT_COLOR;
	self:UpdateColor(color);

	local arrowParent = self.labelSet and self.Label or self.Icon;
	self.Arrow:ClearAllPoints();
	self.Arrow:SetPoint("RIGHT", arrowParent, "LEFT", 0, 0);
end

function RefundHeaderSortButtonMixin:UpdateArrow()
	if self.sortField == CatalogShopRefundFrame:GetSortField() then
		if CatalogShopRefundFrame:GetSortAscending() then
			self.Arrow:SetTexCoord(0, 1, 0, 1);
		else
			self.Arrow:SetTexCoord(0, 1, 1, 0);
		end
		self.Arrow:Show();
	else
		self.Arrow:Hide();
	end

	self:Layout();
end

function RefundHeaderSortButtonMixin:OnShow()
	EventRegistry:RegisterCallback("CatalogShopRefund.SortFieldSet", self.SortFieldSet, self);

	self:UpdateArrow();
end

function RefundHeaderSortButtonMixin:OnHide()
	EventRegistry:UnregisterCallback("CatalogShopRefund.SortFieldSet", self);
end

function RefundHeaderSortButtonMixin:SortFieldSet()
	self:UpdateArrow();
end

function RefundHeaderSortButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	CatalogShopRefundFrame:SetSortField(self.sortField);
end

function RefundHeaderSortButtonMixin:UpdateColor(color)
	if self.labelSet then
		self.Label:SetTextColor(color:GetRGB());
	else
		self.Icon:SetVertexColor(color:GetRGB());
	end
end

function RefundHeaderSortButtonMixin:OnEnter()
	if (not self:IsEnabled()) then
		return;
	end

	local color = self.highlightColor or WHITE_FONT_COLOR;
	self:UpdateColor(color);
end

function RefundHeaderSortButtonMixin:OnLeave()
	local color = self.normalColor or NORMAL_FONT_COLOR;
	self:UpdateColor(color);
end

----------------------------------------------------------------------------------
-- RefundFlowDecorButtonMixin
----------------------------------------------------------------------------------
RefundFlowDecorButtonMixin = {};
function RefundFlowDecorButtonMixin:OnLoad()
	self.ContentsContainer.RefundCheckbox:SetScript("OnEnter", function() self:OnEnter(); end);
	self.ContentsContainer.RefundCheckbox:SetScript("OnLeave", function() self:OnLeave(); end);
	self.ContentsContainer.RefundCheckbox:SetScript("OnClick", function() self:OnValueChanged(); end);
end

function RefundFlowDecorButtonMixin:SetDecorInfo(decorInfo)
	if (not decorInfo) then
		return;
	end

	self.decorGUID = decorInfo.decorGUID;
	self.timeRemainingSeconds = decorInfo.timeRemainingSeconds;
	self.name = decorInfo.name;
	self.price = decorInfo.price;

	local container = self.ContentsContainer;
	container.RefundCheckbox:SetChecked(decorInfo.isSelected);
	container.NameText:SetText(self.name);
	container.RefundAmountText:SetText(self.price);
	container.TimeRemainingText:SetText(self:FormatTimeLeft(self.timeRemainingSeconds, timeRemainingFormatter));
end

function RefundFlowDecorButtonMixin:OnEnter()
	self.ContentsContainer.NameText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	self.ArtContainer.HighlightTexture:Show();
end

function RefundFlowDecorButtonMixin:OnLeave()
	self.ContentsContainer.NameText:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	self.ArtContainer.HighlightTexture:Hide();
end

function RefundFlowDecorButtonMixin:OnValueChanged()
	local decor = CatalogShopRefundFrame:GetDecor(self.decorGUID);
	if (not decor) then
		return;
	end

	local isChecked = self.ContentsContainer.RefundCheckbox:GetChecked();
	decor.isSelected = isChecked;

	if (isChecked) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end

	EventRegistry:TriggerEvent("CatalogShopRefund.SelectionsUpdated");
end

function RefundFlowDecorButtonMixin:ToggleSelected()
	local checkbox = self.ContentsContainer.RefundCheckbox;

	checkbox:SetChecked(not checkbox:GetChecked());
	self:OnValueChanged();
end

function RefundFlowDecorButtonMixin:SetSelectedNoClick(isSelected)
	self.ContentsContainer.RefundCheckbox:SetChecked(isSelected);
end

function RefundFlowDecorButtonMixin:GetDecorInfo()
	return self.decorInfo;
end

function RefundFlowDecorButtonMixin:IsSameDecor(decorInfo)
	return self.decorInfo and (self.decorInfo.decorGUID == decorInfo.decorGUID);
end

function RefundFlowDecorButtonMixin:FormatTimeLeft(secondsRemaining, formatter)
	local color = (secondsRemaining > RED_TEXT_SECONDS_THRESHOLD) and WHITE_FONT_COLOR or RED_FONT_COLOR;
	local text = formatter:Format(secondsRemaining);
	return color:WrapTextInColorCode(text);
end
