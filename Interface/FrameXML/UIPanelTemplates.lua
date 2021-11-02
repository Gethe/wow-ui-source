
ITEM_SEARCHBAR_LIST = {
	"BagItemSearchBox",
	"GuildItemSearchBox",
	"VoidItemSearchBox",
	"BankItemSearchBox",
};

function BagSearch_OnHide(self)
	local allClosed = true;
	for _,barName in pairs(ITEM_SEARCHBAR_LIST) do
		local bar = _G[barName];
		if bar and bar ~= self and bar:IsVisible() then
			allClosed = false;
		end
	end
	if ( allClosed ) then
		self.clearButton:Click();
		BagSearch_OnTextChanged(self);
	end
end

function BagSearch_OnTextChanged(self, userChanged)
	SearchBoxTemplate_OnTextChanged(self);

	for _, barName in pairs(ITEM_SEARCHBAR_LIST) do
		local bar = _G[barName];
		if ( bar and bar:GetText() ~= self:GetText() ) then
			bar:SetText(self:GetText());
		end
	end
	SetItemSearch(self:GetText());
end

function BagSearch_OnChar(self, text)
	-- clear focus if the player is repeating keys (ie - trying to move)
	-- TODO: move into base editbox code?
	local MIN_REPEAT_CHARACTERS = 4;
	local searchString = self:GetText();
	if (string.len(searchString) >= MIN_REPEAT_CHARACTERS) then
		local repeatChar = true;
		for i=1, MIN_REPEAT_CHARACTERS - 1, 1 do
			if ( string.sub(searchString,(0-i), (0-i)) ~= string.sub(searchString,(-1-i),(-1-i)) ) then
				repeatChar = false;
				break;
			end
		end
		if ( repeatChar ) then
			self:ClearFocus();
		end
	end
end

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

UIFrameCache = CreateFrame("FRAME");
local caches = {};
function UIFrameCache:New (frameType, baseName, parent, template)
	if ( self ~= UIFrameCache ) then
		error("Attempt to run factory method on class member");
	end

	local frameCache = {};

	setmetatable(frameCache, self);
	self.__index = self;

	frameCache.frameType = frameType;
	frameCache.baseName = baseName;
	frameCache.parent = parent;
	frameCache.template = template;
	frameCache.frames = {};
	frameCache.usedFrames = {};
	frameCache.numFrames = 0;

	tinsert(caches, frameCache);

	return frameCache;
end

function UIFrameCache:GetFrame ()
	local frame = self.frames[1];
	if ( frame ) then
		tremove(self.frames, 1);
		tinsert(self.usedFrames, frame);
		return frame;
	end

	frame = CreateFrame(self.frameType, self.baseName .. self.numFrames + 1, self.parent, self.template);
	frame.frameCache = self;
	self.numFrames = self.numFrames + 1;
	tinsert(self.usedFrames, frame);
	return frame;
end

function UIFrameCache:ReleaseFrame (frame)
	for k, v in next, self.frames do
		if ( v == frame ) then
			return;
		end
	end

	for k, v in next, self.usedFrames do
		if ( v == frame ) then
			tinsert(self.frames, frame);
			tremove(self.usedFrames, k);
			break;
		end
	end
end

-- SquareButton template code
SQUARE_BUTTON_TEXCOORDS = {
	["UP"] = {     0.45312500,    0.64062500,     0.01562500,     0.20312500};
	["DOWN"] = {   0.45312500,    0.64062500,     0.20312500,     0.01562500};
	["LEFT"] = {   0.23437500,    0.42187500,     0.01562500,     0.20312500};
	["RIGHT"] = {  0.42187500,    0.23437500,     0.01562500,     0.20312500};
	["DELETE"] = { 0.01562500,    0.20312500,     0.01562500,     0.20312500};
};

function SquareButton_SetIcon(self, name)
	local coords = SQUARE_BUTTON_TEXCOORDS[strupper(name)];
	if (coords) then
		self.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	end
end


-- Cap progress bar
function CapProgressBar_SetNotches(capBar, count)
	local barWidth = capBar:GetWidth();
	local barName = capBar:GetName();

	if ( capBar.notchCount and capBar.notchCount > count ) then
		for i = count + 1, capBar.notchCount do
			_G[barName.."Divider"..i]:Hide();
		end
	end

	local notchWidth = barWidth / count;

	for i=1, count - 1 do
		local notch = _G[barName.."Divider"..i];
		if ( not notch ) then
			notch = capBar:CreateTexture(barName.."Divider"..i, "BORDER", "CapProgressBarDividerTemplate", -1);
		end
		notch:ClearAllPoints();
		notch:SetPoint("LEFT", capBar, "LEFT", notchWidth * i - 2, 0);
	end
	capBar.notchCount = count;
end

function CapProgressBar_Update(capBar, cap1Quantity, cap1Limit, cap2Quantity, cap2Limit, totalQuantity, totalLimit, hasNoSharedStats)
	if ( totalLimit == 0) then
		return;
	end

	local barWidth = capBar:GetWidth() - 4;
	local sizePerPoint = barWidth / totalLimit;
	local progressWidth = totalQuantity * sizePerPoint;

	local cap1Width, cap2Width;
	if ( cap2Quantity and cap2Limit ) then
		cap1Width = min(cap1Limit - cap1Quantity, cap2Limit - cap2Quantity) * sizePerPoint;	--cap1 can't go past the cap2 LFG limit either.
		cap2Width = (cap2Limit - cap2Quantity) * sizePerPoint - cap1Width;
	else
		cap1Width = (cap1Limit - cap1Quantity) * sizePerPoint;
		cap2Width = 0;
	end

	--Don't let it go past the end.
	progressWidth = min(progressWidth, barWidth);
	cap1Width = min(cap1Width, barWidth - progressWidth);
	cap2Width = min(cap2Width, barWidth - progressWidth - cap1Width);
	capBar.progress:SetWidth(progressWidth);

	capBar.cap1:SetWidth(cap1Width);
	capBar.cap2:SetWidth(cap2Width);

	local lastFrame, lastRelativePoint = capBar, "LEFT";

	if ( progressWidth > 0 ) then
		capBar.progress:Show();
		capBar.progress:SetPoint("LEFT", lastFrame, lastRelativePoint, 2, 0);
		lastFrame, lastRelativePoint = capBar.progress, "RIGHT";
	else
		capBar.progress:Hide();
	end

	if ( cap1Width > 0 and not hasNoSharedStats) then
		capBar.cap1:Show();
		capBar.cap1Marker:Show();
		capBar.cap1:SetPoint("LEFT", lastFrame, lastRelativePoint, 0, 0);
		lastFrame, lastRelativePoint = capBar.cap1, "RIGHT";
	else
		capBar.cap1:Hide();
		capBar.cap1Marker:Hide();
	end

	if ( cap2Width > 0 and not hasNoSharedStats) then
		capBar.cap2:Show();
		capBar.cap2Marker:Show();
		capBar.cap2:SetPoint("LEFT", lastFrame, lastRelativePoint, 0, 0);
		lastFrame, lastRelativePoint = capBar.cap2, "RIGHT";
	else
		capBar.cap2:Hide();
		capBar.cap2Marker:Hide();
	end
end

--Radio button functions
function SetCheckButtonIsRadio(button, isRadio)
	if ( isRadio ) then
		button:SetNormalTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetNormalTexture():SetTexCoord(0, 0.25, 0, 1);

		button:SetHighlightTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetHighlightTexture():SetTexCoord(0.5, 0.75, 0, 1);

		button:SetCheckedTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetCheckedTexture():SetTexCoord(0.25, 0.5, 0, 1);

		button:SetPushedTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetPushedTexture():SetTexCoord(0, 0.25, 0, 1);

		button:SetDisabledCheckedTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetDisabledCheckedTexture():SetTexCoord(0.75, 1, 0, 1);
	else
		button:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up");
		button:GetNormalTexture():SetTexCoord(0, 1, 0, 1);

		button:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight");
		button:GetHighlightTexture():SetTexCoord(0, 1, 0, 1);

		button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
		button:GetCheckedTexture():SetTexCoord(0, 1, 0, 1);

		button:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down");
		button:GetPushedTexture():SetTexCoord(0, 1, 0, 1);

		button:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
		button:GetDisabledCheckedTexture():SetTexCoord(0, 1, 0, 1);
	end
end

--Inline hyperlinks
function InlineHyperlinkFrame_OnEnter(self, link, text, fontString, left, bottom, width, height)
	self.tooltipFrame:SetOwner(self, "ANCHOR_PRESERVE");
	self.tooltipFrame:ClearAllPoints();
	self.tooltipFrame:SetPoint("BOTTOMLEFT", fontString, "TOPLEFT", left + width, bottom);
	self.tooltipFrame:SetHyperlink(link);
end

function InlineHyperlinkFrame_OnLeave(self)
	self.tooltipFrame:Hide();
end

function InlineHyperlinkFrame_OnClick(self, link, text, button)
	if ( self.hasIconHyperlinks ) then
		local fixedLink;
		local _, _, linkType, linkID = string.find(link, "([%a]+):([%d]+)");
		if ( linkType == "currency" ) then
			fixedLink = C_CurrencyInfo.GetCurrencyLink(linkID);
		end

		if ( fixedLink ) then
			HandleModifiedItemClick(fixedLink);
			return;
		end
	end
	SetItemRef(link, text, button);
end

CurrencyTemplateMixin = {};

function CurrencyTemplateMixin:SetCurrencyFromID(currencyID, amount, formatString, colorCode)
	local currencyString = GetCurrencyString(currencyID, amount, colorCode, self.abbreviate);
	if formatString then
		self:SetText(formatString:format(currencyString));
	else
		self:SetText(currencyString);
	end
	
	self.currencyID = currencyID;
	self.amount = amount;
	self.formatString = formatString;
	self.colorCode = colorCode;
end

function CurrencyTemplateMixin:SetTooltipAnchor(tooltipAnchor)
	self.tooltipAnchor = tooltipAnchor;
end

function CurrencyTemplateMixin:SetAbbreviate(abbreviate)
	self.abbreviate = abbreviate;
end

function CurrencyTemplateMixin:Refresh()
	-- without an override amount this currency is eligible for a refresh
	if not self.amount then
		local overrideAmount = nil;
		self:SetCurrencyFromID(self.currencyID, overrideAmount, self.formatString, self.colorCode);
	end
end

function CurrencyTemplateMixin:OnEnter()
	if self.tooltipAnchor and self.currencyID then
		self:SetScript("OnUpdate", self.OnUpdate);
	end
end

function CurrencyTemplateMixin:OnLeave()
	self:SetScript("OnUpdate", nil);
	GameTooltip:Hide();
end

function CurrencyTemplateMixin:OnUpdate()
	if self.Text:IsMouseOver() then
		GameTooltip:SetOwner(self, self.tooltipAnchor);
		GameTooltip:SetCurrencyByID(self.currencyID);
	elseif GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end

UIExpandingButtonMixin = {};

function UIExpandingButtonMixin:SetUp(expanded, expansionDirection)
	self.expansionDirection = expansionDirection;
	self.currentlyExpanded = expanded;
	self:Update();
end

function UIExpandingButtonMixin:SetLabel(label)
	self.Label:SetText(label);
end

local function GetOppositeDirection(direction)
	if (direction == "RIGHT") then
		return "LEFT";
	else
		return "RIGHT";
	end
end

function UIExpandingButtonMixin:SetExpanded(expanded)
	self.currentlyExpanded = expanded;
	self:Update();
end

function UIExpandingButtonMixin:IsCurrentlyExpanded()
	return self.currentlyExpanded;
end

function UIExpandingButtonMixin:Update(override)
	if (self.currentlyExpanded == nil or not self.expansionDirection) then
		error("The button must be set up before update.");
		return;
	end

	if (override ~= nil) then
		self.currentlyExpanded = override;
	end

	local direction = self.currentlyExpanded and GetOppositeDirection(self.expansionDirection) or self.expansionDirection;

	SquareButton_SetIcon(self, direction);

	if (self.callback) then
		self.callback(self, self.currentlyExpanded);
	end
end

function UIExpandingButtonMixin:RegisterCallback(callback)
	self.callback = callback;
end

function UIExpandingButtonMixin:OnClick(button, down)
	self.currentlyExpanded = not self.currentlyExpanded;
	self:Update();
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

ButtonWithDisableMixin = {};

function ButtonWithDisableMixin:SetDisableTooltip(tooltipTitle, tooltipText)
	self.disableTooltipTitle = tooltipTitle;
	self.disableTooltipText = tooltipText;
	self:SetEnabled(tooltipTitle == nil);
end

function ButtonWithDisableMixin:OnEnter()
	if self.disableTooltipTitle and not self:IsEnabled() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

		local wrap = true;
		GameTooltip_SetTitle(GameTooltip, self.disableTooltipTitle, RED_FONT_COLOR, wrap);

		if self.disableTooltipText then
			GameTooltip_AddNormalLine(GameTooltip, self.disableTooltipText, wrap);
		end

		GameTooltip:Show();
	end
end

CurrencyDisplayMixin = CreateFromMixins(CurrencyTemplateMixin);

-- currencies: An array of currencyInfo
-- currencyInfo: either a currencyID, or an array with { currencyID, overrideAmount, colorCode }, or a table with { currencyID = 123, amount = 45, colorCode = RED_FONT_COLOR_CODE }
function CurrencyDisplayMixin:SetCurrencies(currencies, formatString)
	if #currencies == 1 then
		local currency = currencies[1];
		if type(currency) == "table" then
			if currency.currencyID and currency.amount then
				self:SetCurrencyFromID(currency.currencyID, currency.amount, formatString, currency.colorCode);
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
		local tIndex = index;
		if reverseOrder then
			tIndex = #currencies + 1 - index;
		end
		local currencyInfo = currencies[tIndex];

		currencyFrame:SetTooltipAnchor(tooltipAnchor);
		currencyFrame:SetAbbreviate(abbreviate);

		if type(currencyInfo) == "table" then
			if currencyInfo.currencyID and currencyInfo.amount then
				local formatString = nil;
				currencyFrame:SetCurrencyFromID(currencyInfo.currencyID, currencyInfo.amount, formatString, currencyInfo.colorCode);
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

CurrencyHorizontalLayoutFrameMixin = { };

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
	self:AddToLayout(fontString);
	return fontString;
end

function CurrencyHorizontalLayoutFrameMixin:GetIconFrame()
	if not self.iconPool then
		self.iconPool = CreateFramePool("FRAME", self, "CurrencyLayoutFrameIconTemplate");
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
		frame.id = currencyID;
		-- spacing
		fontString.rightPadding = self.quantitySpacing;
		if fontString.layoutIndex > 1  then
			fontString.leftPadding = self.currencySpacing;
		end
	end
end