
local ROLE_COUNT_EVENTS = {
	"GROUP_ROSTER_UPDATE",
	"PLAYER_ROLES_ASSIGNED",
};

RoleCountMixin = {};

function RoleCountMixin:OnShow()
	self:Refresh();
	FrameUtil.RegisterFrameForEvents(self, ROLE_COUNT_EVENTS);
end

function RoleCountMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ROLE_COUNT_EVENTS);
end

function RoleCountMixin:OnEvent()
	self:Refresh();
end

function RoleCountMixin:Refresh()
	local counts = GetGroupMemberCountsForDisplay();
	self.DamagerCount:SetText(counts.DAMAGER);
	self.HealerCount:SetText(counts.HEALER);
	self.TankCount:SetText(counts.TANK);
end

TalentRankDisplayMixin = { };

function TalentRankDisplayMixin:SetValues(currentRank, maxRank, isDisabled, isAvailable)
	self.Text:SetFormattedText(GENERIC_FRACTION_STRING, currentRank, maxRank);
	local atlas, textColor;
	if isDisabled then
		atlas = "orderhalltalents-rankborder";
		textColor = DISABLED_FONT_COLOR;
	elseif isAvailable and currentRank < maxRank then
		atlas = "orderhalltalents-rankborder-green";
		textColor = GREEN_FONT_COLOR;
	else
		atlas = "orderhalltalents-rankborder-yellow";
		textColor = YELLOW_FONT_COLOR;
	end

	local useAtlasSize = true;
	self.Background:SetAtlas(atlas, true);
	self.Text:SetTextColor(textColor:GetRGB());
end

CurrencyDisplayMixin = CreateFromMixins(CurrencyTemplateMixin);

-- currencies: An array of currencyInfo
-- currencyInfo: either a currencyID, or an array with { currencyID, overrideAmount, colorCode }, or a table with { currencyID = 123, amount = 45, colorCode = RED_FONT_COLOR_CODE [, formatString = "5 / %s"] }
function CurrencyDisplayMixin:SetCurrencies(currencies, formatString)
	if #currencies == 1 then
		local currency = currencies[1];
		if type(currency) == "table" then
			if currency.currencyID and currency.amount then
				self:SetCurrencyFromID(currency.currencyID, currency.amount, currency.formatString or formatString, currency.colorCode);
			else
				local currencyID, overrideAmount, colorCode = unpack(currency);
				self:SetCurrencyFromID(currencyID, overrideAmount, formatString, colorCode);
			end
		else
			self:SetCurrencyFromID(currency);
		end

		return;
	end

	local text = GetCurrenciesString(currencies);
	if formatString then
		self:SetText(formatString:format(text));
	else
		self:SetText(text);
	end
end

function CurrencyDisplayMixin:SetText(text)
	self.Text:SetText(text);
	self:MarkDirty();
end

function CurrencyDisplayMixin:SetTextAnchorPoint(anchorPoint)
	self.Text:ClearAllPoints();
	self.Text:SetPoint(anchorPoint);
	self:MarkDirty();
end

function CurrencyDisplayMixin:SetCurrencyFont(fontObject)
	self.Text:SetFontObject(fontObject);
end

CurrencyDisplayGroupMixin = {};

function CurrencyDisplayGroupMixin:OnLoad()
	self.currencyFramePool = CreateFramePool("FRAME", self, "CurrencyDisplayTemplate");
end

-- Defaults to a TOPRIGHT configuration.
function CurrencyDisplayGroupMixin:SetCurrencies(currencies, initFunction, initialAnchor, layout, tooltipAnchor, abbreviate, reverseOrder)
	initialAnchor = initialAnchor or AnchorUtil.CreateAnchor("TOPRIGHT", self, "TOPRIGHT");

	local stride = nil;
	local paddingX = 10;
	local paddingY = nil;
	local fixedWidth = 62;
	layout = layout or AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopRightToBottomLeft, stride, paddingX, paddingY, fixedWidth);

	self.currencyFramePool:ReleaseAll();

	local function FactoryFunction(index)
		local currencyFrame = self.currencyFramePool:Acquire();

		local customFontObject = self.customFontObject;
		if customFontObject ~= nil then
			currencyFrame:SetCurrencyFont(customFontObject);
		end

		local tIndex = index;
		if reverseOrder then
			tIndex = #currencies + 1 - index;
		end
		local currencyInfo = currencies[tIndex];

		currencyFrame:SetTooltipAnchor(tooltipAnchor or "ANCHOR_RIGHT");
		currencyFrame:SetAbbreviate(abbreviate);

		if type(currencyInfo) == "table" then
			if currencyInfo.currencyID and currencyInfo.amount then
				currencyFrame:SetCurrencyFromID(currencyInfo.currencyID, currencyInfo.amount, currencyInfo.formatString, currencyInfo.colorCode);
			else
				currencyFrame:SetCurrencyFromID(unpack(currencyInfo));
			end
		else
			currencyFrame:SetCurrencyFromID(currencyInfo);
		end

		if initFunction then
			initFunction(currencyFrame);
		end

		-- Force the frame to resize. This anchor will be replaced by the grid layout function.
		currencyFrame:SetPoint("CENTER");
		currencyFrame:Layout();

		currencyFrame:Show();

		return currencyFrame;
	end

	AnchorUtil.GridLayoutFactoryByCount(FactoryFunction, #currencies, initialAnchor, layout);

	self:MarkDirty();
end

function CurrencyDisplayGroupMixin:Refresh()
	for currencyFrame in self.currencyFramePool:EnumerateActive() do
		currencyFrame:Refresh();
	end
end

function CurrencyDisplayGroupMixin:SetCurrencyFont(fontObject)
	for currencyFrame in self.currencyFramePool:EnumerateActive() do
		currencyFrame:SetCurrencyFont(fontObject);
	end

	self.customFontObject = fontObject;
end

CurrencyLayoutFrameIconMixin = {};

function CurrencyLayoutFrameIconMixin:OnEnter()
	if self.currencyID then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetCurrencyByID(self.currencyID);
	elseif self.itemID then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetItemByID(self.itemID);
	end
end

function CurrencyLayoutFrameIconMixin:SetCurrencyID(currencyID)
	self.currencyID = currencyID;
	self.itemID = nil;
end

function CurrencyLayoutFrameIconMixin:SetItemID(itemID)
	self.currencyID = nil;
	self.itemID = itemID;
end

CurrencyHorizontalLayoutFrameMixin = {};

function CurrencyHorizontalLayoutFrameMixin:Clear()
	if self.quantityPool then
		self.quantityPool:ReleaseAll();
	end
	if self.iconPool then
		self.iconPool:ReleaseAll();
	end
	self.nextLayoutIndex = nil;
end

function CurrencyHorizontalLayoutFrameMixin:AddToLayout(region)
	if not self.nextLayoutIndex then
		self.nextLayoutIndex = 1;
	end
	region.layoutIndex = self.nextLayoutIndex;
	self.nextLayoutIndex = self.nextLayoutIndex + 1;
	region:Show();
	self:MarkDirty();
end

function CurrencyHorizontalLayoutFrameMixin:GetQuantityFontString()
	if not self.quantityPool then
		self.quantityPool = CreateFontStringPool(self, "ARTWORK", 0, (self.quantityFontObject or "GameFontHighlight"));
	end
	local fontString = self.quantityPool:Acquire();
	fontString.quantityInfo = nil;
	self:AddToLayout(fontString);
	return fontString;
end

function CurrencyHorizontalLayoutFrameMixin:GetIconFrame()
	if not self.iconPool then
		self.iconPool = CreateFramePool("FRAME", self, (self.iconFrameObject or "CurrencyLayoutFrameIconTemplate"));
	end
	local frame = self.iconPool:Acquire();
	self:AddToLayout(frame);
	return frame;
end

function CurrencyHorizontalLayoutFrameMixin:CreateLabel(text, color, fontObject, spacing)
	if self.Label then
		return;
	end

	local label = self:CreateFontString(nil, "ARTWORK", fontObject or "GameFontHighlight");
	self.Label = label;
	label.layoutIndex = 0;
	label.rightPadding = spacing;
	label:SetHeight(self.fixedHeight);
	label:SetText(text);
	color = color or HIGHLIGHT_FONT_COLOR;
	label:SetTextColor(color:GetRGB());
	self:MarkDirty();
end

function CurrencyHorizontalLayoutFrameMixin:AddCurrency(currencyID, overrideAmount, color)
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
	if currencyInfo then
		local height = self.fixedHeight;
		-- quantity
		local fontString = self:GetQuantityFontString();
		fontString:SetHeight(height);
		local amountString = BreakUpLargeNumbers(overrideAmount or currencyInfo.quantity);
		fontString:SetText(amountString);
		color = color or HIGHLIGHT_FONT_COLOR;
		fontString:SetTextColor(color:GetRGB());
		-- icon
		local frame = self:GetIconFrame();
		frame:SetSize(height, height);
		frame.Icon:SetTexture(currencyInfo.iconFileID);
		frame:SetCurrencyID(currencyID);
		-- spacing
		fontString.rightPadding = self.quantitySpacing;
		if fontString.layoutIndex > 1  then
			fontString.leftPadding = self.currencySpacing;
		end

		return fontString, frame;
	end

	return nil;
end

function CurrencyHorizontalLayoutFrameMixin:AddItem(itemID, overrideAmount, color)
	local height = self.fixedHeight;
	local includeBank = true;
	-- quantity
	local fontString = self:GetQuantityFontString();
	fontString:SetHeight(height);
	local amountString = BreakUpLargeNumbers(overrideAmount or C_Item.GetItemCount(itemID, includeBank));
	fontString:SetText(amountString);
	color = color or HIGHLIGHT_FONT_COLOR;
	fontString:SetTextColor(color:GetRGB());
	-- icon
	local frame = self:GetIconFrame();
	frame:SetSize(height, height);
	frame.Icon:SetTexture(C_Item.GetItemIconByID(itemID));
	frame:SetItemID(itemID);
	-- spacing
	fontString.rightPadding = self.quantitySpacing;
	if fontString.layoutIndex > 1  then
		fontString.leftPadding = self.currencySpacing;
	end

	return fontString, frame;
end
