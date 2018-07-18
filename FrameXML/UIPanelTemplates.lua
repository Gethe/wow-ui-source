
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
			fixedLink = GetCurrencyLink(linkID);
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
	local _, _, currencyTexture = GetCurrencyInfo(currencyID);
	local markup = CreateTextureMarkup(currencyTexture, 64, 64, 16, 16, 0, 1, 0, 1);
	colorCode = colorCode or HIGHLIGHT_FONT_COLOR_CODE;

	local currencyString = ("%s%s %s|r"):format(colorCode, BreakUpLargeNumbers(amount), markup);

	if formatString then
		self:SetText(formatString:format(currencyString));
	else
		self:SetText(currencyString);
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
