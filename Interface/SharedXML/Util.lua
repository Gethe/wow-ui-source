function CanAccessObject(obj)
	return issecure() or not obj:IsForbidden();
end

CLASS_ICON_TCOORDS = {
	["WARRIOR"]		= {0, 0.25, 0, 0.25},
	["MAGE"]		= {0.25, 0.49609375, 0, 0.25},
	["ROGUE"]		= {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"]		= {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"]		= {0, 0.25, 0.25, 0.5},
	["SHAMAN"]	 	= {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"]		= {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"]		= {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"]		= {0, 0.25, 0.5, 0.75},
	["DEATHKNIGHT"]	= {0.25, .5, 0.5, .75},
	["MONK"]		= {0.5, 0.73828125, 0.5, .75},
	["DEMONHUNTER"]	= {0.7421875, 0.98828125, 0.5, 0.75},
};

function ConvertPixelsToUI(pixels, frameScale)
	local physicalScreenHeight = select(2, GetPhysicalScreenSize());
	return (pixels * 768.0)/(physicalScreenHeight * frameScale);
end

function ReloadUI()
	C_UI.Reload();
end

function ExtractHyperlinkString(linkString)
	local preString, hyperlinkString, postString = linkString:match("^(.*)|H(.+)|h(.*)$");
	return preString ~= nil, preString, hyperlinkString, postString;
end

function GetItemInfoFromHyperlink(link)
	local hyperlink = link:match("|Hitem:.-|h");
	if (hyperlink) then
		local itemID, creationContext = GetItemCreationContext(hyperlink);
		return tonumber(itemID), creationContext;
	else
		return nil;
	end
end

function GetAchievementInfoFromHyperlink(link)
	return tonumber(link:match("|Hachievement:(%d+)"));
end

function FormatLargeNumber(amount)
	amount = tostring(amount);
	local newDisplay = "";
	local strlen = amount:len();
	--Add each thing behind a comma
	for i=4, strlen, 3 do
		newDisplay = LARGE_NUMBER_SEPERATOR..amount:sub(-(i - 1), -(i - 3))..newDisplay;
	end
	--Add everything before the first comma
	newDisplay = amount:sub(1, (strlen % 3 == 0) and 3 or (strlen % 3))..newDisplay;
	return newDisplay;
end

-- where ... are the mixins to mixin
function Mixin(object, ...)
	for i = 1, select("#", ...) do
		local mixin = select(i, ...);
		for k, v in pairs(mixin) do
			object[k] = v;
		end
	end

	return object;
end

-- where ... are the mixins to mixin
function CreateFromMixins(...)
	return Mixin({}, ...)
end

function CreateAndInitFromMixin(mixin, ...)
	local object = CreateFromMixins(mixin);
	object:Init(...);
	return object;
end

COPPER_PER_SILVER = 100;
SILVER_PER_GOLD = 100;
COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD;

function GetMoneyString(money, separateThousands)
	local goldString, silverString, copperString;
	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);

	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		if (separateThousands) then
			goldString = FormatLargeNumber(gold)..GOLD_AMOUNT_SYMBOL;
		else
			goldString = gold..GOLD_AMOUNT_SYMBOL;
		end
		silverString = silver..SILVER_AMOUNT_SYMBOL;
		copperString = copper..COPPER_AMOUNT_SYMBOL;
	else
		if (separateThousands) then
			goldString = GOLD_AMOUNT_TEXTURE_STRING:format(FormatLargeNumber(gold), 0, 0);
		else
			goldString = GOLD_AMOUNT_TEXTURE:format(gold, 0, 0);
		end
		silverString = SILVER_AMOUNT_TEXTURE:format(silver, 0, 0);
		copperString = COPPER_AMOUNT_TEXTURE:format(copper, 0, 0);
	end

	local moneyString = "";
	local separator = "";
	if ( gold > 0 ) then
		moneyString = goldString;
		separator = " ";
	end
	if ( silver > 0 ) then
		moneyString = moneyString..separator..silverString;
		separator = " ";
	end
	if ( copper > 0 or moneyString == "" ) then
		moneyString = moneyString..separator..copperString;
	end

	return moneyString;
end

function GetNavigationButtonEnabledStates(count, index)
	-- Returns indicate whether navigation for "previous" and "next" should be enabled, respectively.
	if count > 1 then
		return index > 1, index < count;
	end

	return false, false;
end

----------------------------------
-- TRIAL/VETERAN FUNCTIONS
----------------------------------
function GameLimitedMode_IsActive()
	return IsTrialAccount() or IsVeteranTrialAccount();
end

function TriStateCheckbox_SetState(checked, checkButton)
	local checkedTexture = _G[checkButton:GetName().."CheckedTexture"];
	if ( not checkedTexture ) then
		message("Can't find checked texture");
	end
	if ( not checked or checked == 0 ) then
		-- nil or 0 means not checked
		checkButton:SetChecked(false);
		checkButton.state = 0;
	elseif ( checked == 2 ) then
		-- 2 is a normal
		checkButton:SetChecked(true);
		checkedTexture:SetVertexColor(1, 1, 1);
		checkedTexture:SetDesaturated(false);
		checkButton.state = 2;
	else
		-- 1 is a gray check
		checkButton:SetChecked(true);
		checkedTexture:SetDesaturated(true);
		checkButton.state = 1;
	end
end

RectangleMixin = {};

function CreateRectangle(left, right, top, bottom)
	local rectangle = CreateFromMixins(RectangleMixin);
	rectangle:OnLoad(left, right, top,  bottom);
	return rectangle;
end

function RectangleMixin:OnLoad(left, right, top, bottom)
	self:SetSides(left or 0.0, right or 0.0, top or 0.0, bottom or 0.0);
end

function RectangleMixin:SetSides(left, right, top, bottom)
	self.left = left;
	self.right = right;
	self.top = top;
	self.bottom = bottom;
end

function RectangleMixin:Reset()
	self.left = 0.0;
	self.right = 0.0;
	self.top = 0.0;
	self.bottom = 0.0;
end

function RectangleMixin:Stretch(x, y)
	self:Adjust(-x, x, -y, y);
end

function RectangleMixin:Move(x, y)
	self:Adjust(x, x, y, y);
end

function RectangleMixin:Adjust(left, right, top, bottom)
	self.left = self.left + left;
	self.right = self.right + right;
	self.top = self.top + top;
	self.bottom = self.bottom + bottom;
end

function RectangleMixin:IsEmpty()
	return self.left == self.right or self.top == self.bottom;
end

function RectangleMixin:IsInsideOut()
	return self.left > self.right or self.top > self.bottom;
end

function RectangleMixin:EnclosesPoint(x, y)
	return x >= self.left and x <= self.right and y >= self.top and y <= self.bottom;
end

function RectangleMixin:EnclosesRect(otherRect)
	return self:EnclosesPoint(otherRect:GetLeft(), otherRect:GetTop()) and self:EnclosesPoint(otherRect:GetRight(), otherRect:GetBottom());
end

function RectangleMixin:IntersectsRect(otherRect)
	return not (
		self.left > otherRect.right or
		self.right < otherRect.left or
		self.top > otherRect.bottom or
		self.bottom < otherRect.top
	);
end

function RectangleMixin:GetTop()
	return self.top;
end

function RectangleMixin:GetBottom()
	return self.bottom;
end

function RectangleMixin:GetLeft()
	return self.left;
end

function RectangleMixin:GetRight()
	return self.right;
end

function RectangleMixin:GetWidth()
	return self.right - self.left;
end

function RectangleMixin:GetHeight()
	return self.bottom - self.top;
end

function RectangleMixin:GetCenter()
	return Lerp(self.left, self.right, .5), Lerp(self.top, self.bottom, .5);
end

function RectangleMixin:SetTop(top)
	self.top = top;
end

function RectangleMixin:SetBottom(bottom)
	self.bottom = bottom;
end

function RectangleMixin:SetLeft(left)
	self.left = left;
end

function RectangleMixin:SetRight(right)
	self.right = right;
end

function RectangleMixin:SetWidth(width)
	self.right = self.left + width;
end

function RectangleMixin:SetHeight(height)
	self.bottom = self.top + height;
end

function RectangleMixin:SetSize(width, height)
	self:SetWidth(width);
	self:SetHeight(height);
end

function RectangleMixin:SetCenter(x, y)
	local width = self:GetWidth();
	local height = self:GetHeight();

	self.left = x - width * .5;
	self.right = x + width * .5;

	self.top = y - height * .5;
	self.bottom = y + height * .5;
end

local g_updatingBars = {};

local function IsCloseEnough(bar, newValue, targetValue)
	local min, max = bar:GetMinMaxValues();
	local range = max - min;
	if range > 0.0 then
		return math.abs((newValue - targetValue) / range) < .00001;
	end

	return true;
end

local function ProcessSmoothStatusBars()
	for bar, targetValue in pairs(g_updatingBars) do
		local effectiveTargetValue = Clamp(targetValue, bar:GetMinMaxValues());
		local newValue = FrameDeltaLerp(bar:GetValue(), effectiveTargetValue, .25);

		if IsCloseEnough(bar, newValue, effectiveTargetValue) then
			g_updatingBars[bar] = nil;
			bar:SetValue(effectiveTargetValue);
		else
			bar:SetValue(newValue);
		end
	end
end

C_Timer.NewTicker(0, ProcessSmoothStatusBars);

SmoothStatusBarMixin = {};

function SmoothStatusBarMixin:ResetSmoothedValue(value) --If nil, tries to set to the last target value
	local targetValue = g_updatingBars[self];
	if targetValue then
		g_updatingBars[self] = nil;
		self:SetValue(value or targetValue);
	elseif value then
		self:SetValue(value);
	end
end

function SmoothStatusBarMixin:SetSmoothedValue(value)
	g_updatingBars[self] = value;
end

function SmoothStatusBarMixin:SetMinMaxSmoothedValue(min, max)
	self:SetMinMaxValues(min, max);

	local targetValue = g_updatingBars[self];
	if targetValue then
		local ratio = 1;
		if max ~= 0 and self.lastSmoothedMax and self.lastSmoothedMax ~= 0 then
			ratio = max / self.lastSmoothedMax;
		end

		g_updatingBars[self] = targetValue * ratio;
	end

	self.lastSmoothedMin = min;
	self.lastSmoothedMax = max;
end

function WrapTextInColorCode(text, colorHexString)
	return ("|c%s%s|r"):format(colorHexString, text);
end

ColorMixin = {};

function CreateColor(r, g, b, a)
	local color = CreateFromMixins(ColorMixin);
	color:OnLoad(r, g, b, a);
	return color;
end

function AreColorsEqual(left, right)
	if left and right then
		return left:IsEqualTo(right);
	end
	return left == right;
end

function ColorMixin:OnLoad(r, g, b, a)
	self:SetRGBA(r, g, b, a);
end

function ColorMixin:IsEqualTo(otherColor)
	return self.r == otherColor.r
		and self.g == otherColor.g
		and self.b == otherColor.b
		and self.a == otherColor.a;
end

function ColorMixin:GetRGB()
	return self.r, self.g, self.b;
end

function ColorMixin:GetRGBAsBytes()
	return self.r * 255, self.g * 255, self.b * 255;
end

function ColorMixin:GetRGBA()
	return self.r, self.g, self.b, self.a;
end

function ColorMixin:GetRGBAAsBytes()
	return self.r * 255, self.g * 255, self.b * 255, (self.a or 1) * 255;
end

function ColorMixin:SetRGBA(r, g, b, a)
	self.r = r;
	self.g = g;
	self.b = b;
	self.a = a;
end

function ColorMixin:SetRGB(r, g, b)
	self:SetRGBA(r, g, b, nil);
end

function ColorMixin:GenerateHexColor()
	return ("ff%.2x%.2x%.2x"):format(self:GetRGBAsBytes());
end

function ColorMixin:GenerateHexColorMarkup()
	return "|c"..self:GenerateHexColor();
end

function ColorMixin:WrapTextInColorCode(text)
	return WrapTextInColorCode(text, self:GenerateHexColor());
end

RAID_CLASS_COLORS = {
	["HUNTER"] = CreateColor(0.67, 0.83, 0.45),
	["WARLOCK"] = CreateColor(0.53, 0.53, 0.93),
	["PRIEST"] = CreateColor(1.0, 1.0, 1.0),
	["PALADIN"] = CreateColor(0.96, 0.55, 0.73),
	["MAGE"] = CreateColor(0.25, 0.78, 0.92),
	["ROGUE"] = CreateColor(1.0, 0.96, 0.41),
	["DRUID"] = CreateColor(1.0, 0.49, 0.04),
	--["SHAMAN"] = CreateColor(0.0, 0.44, 0.87),
	["SHAMAN"] = CreateColor(0.96, 0.55, 0.73),
	["WARRIOR"] = CreateColor(0.78, 0.61, 0.43),
	["DEATHKNIGHT"] = CreateColor(0.77, 0.12 , 0.23),
	["MONK"] = CreateColor(0.0, 1.00 , 0.59),
	["DEMONHUNTER"] = CreateColor(0.64, 0.19, 0.79),
};

for k, v in pairs(RAID_CLASS_COLORS) do
	v.colorStr = v:GenerateHexColor();
end

function GetClassColor(classFilename)
	local color = RAID_CLASS_COLORS[classFilename];
	if color then
		return color.r, color.g, color.b, color.colorStr;
	end

	return 1, 1, 1, "ffffffff";
end

function GetClassColorObj(classFilename)
	-- TODO: Remove this, convert everything that's using GetClassColor to use the object instead, then begin using that again
	return RAID_CLASS_COLORS[classFilename];
end

function GetFactionColor(factionGroupTag)
	return PLAYER_FACTION_COLORS[PLAYER_FACTION_GROUP[factionGroupTag]];
end

-- Mix this into a FontString to have it resize until it stops truncating, or gets too small
ShrinkUntilTruncateFontStringMixin = {};

-- From largest to smallest
function ShrinkUntilTruncateFontStringMixin:SetFontObjectsToTry(...)
	self.fontObjectsToTry = { ... };
	if self:GetText() then
		self:ApplyFontObjects();
	end
end

function ShrinkUntilTruncateFontStringMixin:ApplyFontObjects()
	if not self.fontObjectsToTry then
		error("No fonts applied to ShrinkUntilTruncateFontStringMixin, call SetFontObjectsToTry first");
	end

	for i, fontObject in ipairs(self.fontObjectsToTry) do
		self:SetFontObject(fontObject);
		if not self:IsTruncated() then
			break;
		end
	end
end

function ShrinkUntilTruncateFontStringMixin:SetText(text)
	if not self:GetFont() then
		if not self.fontObjectsToTry then
			error("No fonts applied to ShrinkUntilTruncateFontStringMixin, call SetFontObjectsToTry first");
		end
		self:SetFontObject(self.fontObjectsToTry[1]);
	end

	getmetatable(self).__index.SetText(self, text);
	self:ApplyFontObjects();
end

function ShrinkUntilTruncateFontStringMixin:SetFormattedText(format, ...)
	if not self:GetFont() then
		if not self.fontObjectsToTry then
			error("No fonts applied to ShrinkUntilTruncateFontStringMixin, call SetFontObjectsToTry first");
		end
		self:SetFontObject(self.fontObjectsToTry[1]);
	end

	getmetatable(self).__index.SetFormattedText(self, format, ...);
	self:ApplyFontObjects();
end

function FormatPercentage(percentage, roundToNearestInteger)
	if roundToNearestInteger then
		percentage = Round(percentage * 100);
	else
		percentage = percentage * 100;
	end

	return PERCENTAGE_STRING:format(percentage);
end

function SetupTextureKitOnFrameByID(textureKitID, frame, fmt, setVisibilityOfRegions, useAtlasSize)
	local textureKit = GetUITextureKitInfo(textureKitID);
	SetupTextureKitOnFrame(textureKit, frame, fmt, setVisibilityOfRegions, useAtlasSize);
end

function SetupTextureKitsOnFrames(textureKitID, frames, setVisibilityOfRegions, useAtlasSize)
	local textureKit = GetUITextureKitInfo(textureKitID);
	SetupTextureKitOnFrames(textureKit, frames, setVisibilityOfRegions, useAtlasSize);
end

-- Note this is deprecated in favor of CallbackRegistryMixin.
CallbackRegistryBaseMixin = {};

function CallbackRegistryBaseMixin:OnLoad()
	self.callbackRegistry = {};
end

function CallbackRegistryBaseMixin:RegisterCallback(event, callback)
	if not self.callbackRegistry[event] then
		self.callbackRegistry[event] = {};
	end

	self.callbackRegistry[event][callback] = true;
end

function CallbackRegistryBaseMixin:UnregisterCallback(event, callback)
	if self.callbackRegistry[event] then
		self.callbackRegistry[event][callback] = nil;
	end
end

function CallbackRegistryBaseMixin:TriggerEvent(event, ...)
	local registry = self.callbackRegistry[event];
	if registry then
		for callback in pairs(registry) do
			callback(event, ...);
		end
	end
end

--[[static]] function CallbackRegistryBaseMixin:GenerateCallbackEvents(events)
	self.Event = tInvert(events);
end

EventRegistrationHelper = {};

function EventRegistrationHelper:AddEvent(event)
	self.containedEvents = self.containedEvents or {};
	self.containedEvents[event] = true;
end

function EventRegistrationHelper:AddEvents(...)
	self.containedEvents = self.containedEvents or {};
	for i = 1, select("#", ...) do
		self.containedEvents[select(i, ...)] = true;
	end
end

function EventRegistrationHelper:RemoveEvent(event)
	if self.containedEvents then
		self.containedEvents[event] = nil;
	end
end

function EventRegistrationHelper:ClearEvents()
	self.containedEvents = nil;
end

function EventRegistrationHelper:SetEventsRegistered(registered)
	local events = self.containedEvents;
	if events then
		local func = registered and self.RegisterEvent or self.UnregisterEvent;
		for event in pairs(self.containedEvents) do
			func(self, event);
		end
	end
end

TabGroupMixin = {};

function TabGroupMixin:OnLoad(...)
	self.frames = { ... };
end

function TabGroupMixin:AddFrame(frame)
	table.insert(self.frames, frame);
end

function TabGroupMixin:OnTabPressed()
	for focusIndex, frame in ipairs(self.frames) do
		if frame:HasFocus() then
			local nextFocusIndex = IsShiftKeyDown() and (focusIndex - 1) or (focusIndex + 1);

			if nextFocusIndex == 0 then
				nextFocusIndex = #self.frames;
			elseif nextFocusIndex > #self.frames then
				nextFocusIndex = 1;
			end

			self.frames[nextFocusIndex]:SetFocus();
			return;
		end
	end
end

function CreateTabGroup(...)
	local tabGroup = CreateFromMixins(TabGroupMixin);
	tabGroup:OnLoad(...);
	return tabGroup;
end

function ExecuteFrameScript(frame, scriptName, ...)
	local script = frame:GetScript(scriptName);
	if script then
		securecall(script, frame, ...);
	end
end

function Flags_CreateMask(...)
	local mask = 0;
	for i = 1, select("#", ...) do
		mask = bit.bor(mask, select(i, ...));
	end

	return mask;
end

function Flags_CreateMaskFromTable(flagsTable)
	local mask = 0;
	for flagName, flagValue in pairs(flagsTable) do
		mask = bit.bor(mask, flagValue);
	end

	return mask;
end

FlagsMixin = {};

function FlagsMixin:OnLoad()
	self:ClearAll();
end

function FlagsMixin:AddNamedFlagsFromTable(flagsTable)
	assert(flagsTable.flags == nil);
	Mixin(self, flagsTable);
end

function FlagsMixin:AddNamedMask(flagName, mask)
	assert(self[flagName] == nil);
	self[flagName] = mask;
end

function FlagsMixin:Set(flag)
	self.flags = bit.bor(self.flags, flag);
end

function FlagsMixin:Clear(flag)
	self.flags = bit.band(self.flags, bit.bnot(flag));
end

function FlagsMixin:SetOrClear(flag, isSet)
	if isSet then
		self:Set(flag);
	else
		self:Clear(flag);
	end
end

function FlagsMixin:ClearAll()
	self.flags = 0;
end

function FlagsMixin:IsAnySet()
	return self.flags ~= 0;
end

function FlagsMixin:IsSet(flagOrMask)
	return bit.band(self.flags, flagOrMask) == flagOrMask;
end

function FlagsMixin:GetFlags()
	return self.flags;
end

DirtyFlagsMixin = CreateFromMixins(FlagsMixin);

function DirtyFlagsMixin:OnLoad()
	FlagsMixin.OnLoad(self);
	self.isDirty = false;
end

function DirtyFlagsMixin:MarkDirty(flag)
	if flag ~= nil then
		self:Set(flag);
	end

	self.isDirty = true;
end

function DirtyFlagsMixin:MarkClean()
	self:ClearAll();
	self.isDirty = false;
end

function DirtyFlagsMixin:IsDirty(flag)
	if flag ~= nil then
		return self:IsSet(flag);
	else
		return self.isDirty;
	end
end

function CallErrorHandler(...)
	return geterrorhandler()(...);
end

TabGroupMixin = {};

function TabGroupMixin:OnLoad(...)
	self.isTabGroup = true;
	self.frames = { ... };
end

function TabGroupMixin:AddFrame(frame)
	table.insert(self.frames, frame);
end

function TabGroupMixin:HasFocus()
	return self:GetFocusIndex() ~= nil;
end

function TabGroupMixin:SetFocus()
	-- focusing the first frame/subgroup for now...actually depends on whether or not we were going backwards or forwards through the groups
	local frame = self.frames[1];
	if frame then
		frame:SetFocus();
	end
end

function TabGroupMixin:GetFocusIndex()
	return self.focusIndex or self:DiscoverFocusIndex();
end

function TabGroupMixin:DiscoverFocusIndex()
	self.focusIndex = nil;

	for focusIndex, frame in ipairs(self.frames) do
		if frame:HasFocus() then
			self.focusIndex = focusIndex;
			return focusIndex;
		end
	end
end

function TabGroupMixin:IsValidFocusIndex(focusIndex)
	return focusIndex > 0 and focusIndex <= #self.frames;
end

function TabGroupMixin:WrapFocusIndex(focusIndex)
	if focusIndex == 0 then
		return #self.frames;
	elseif focusIndex > #self.frames then
		return 1;
	end

	return focusIndex;
end

function TabGroupMixin:OnTabPressed(preventFocusWrap)
	local focusIndex = self:GetFocusIndex();

	local frameAtIndex = self.frames[focusIndex];
	if frameAtIndex.isTabGroup then
		if frameAtIndex:OnTabPressed(true) then
			return true;
		end
	end

	local nextFocusIndex = IsShiftKeyDown() and (focusIndex - 1) or (focusIndex + 1);

	if preventFocusWrap and not self:IsValidFocusIndex(nextFocusIndex) then
		return false;
	end

	nextFocusIndex = Wrap(nextFocusIndex, #self.frames);
	self.focusIndex = nextFocusIndex;
	self.frames[nextFocusIndex]:SetFocus();
end

function CreateTabGroup(...)
	local tabGroup = CreateFromMixins(TabGroupMixin);
	tabGroup:OnLoad(...);
	return tabGroup;
end

function ExecuteFrameScript(frame, scriptName, ...)
	local script = frame:GetScript(scriptName);
	if script then
		xpcall(script, CallErrorHandler, frame, ...);
	end
end

PredictedSettingBaseMixin = {};

-- The wrapTable here should have functions to specific keys based on which type of setting you are wrapping.
-- All tables must have a getFunction key that returns the "real" value.
-- The PredictedSetting wrapTable should have a setFunction key with a function that takes a value and sets the real value to this value.
--   This function can return a true/false value noting if the set succeeded or not.
-- The PredictedToggle wrapTable should have a toggleFunction key that is the function to call to toggle the real value.
function PredictedSettingBaseMixin:SetUp(wrapTable)
	self.wrapTable = wrapTable;
end

function PredictedSettingBaseMixin:Clear()
	self.predictedValue = nil;
end

function PredictedSettingBaseMixin:Get()
	if (self.predictedValue ~= nil) then
		return self.predictedValue;
	end
	return self.wrapTable.getFunction();
end

PredictedSettingMixin = CreateFromMixins(PredictedSettingBaseMixin);

function PredictedSettingMixin:Set(value)
	local validated = self.wrapTable.setFunction(value);
	if (validated ~= false) then
		self.predictedValue = value;
	end
end

function CreatePredictedSetting(wrapTable)
	local predictedSetting = CreateFromMixins(PredictedSettingMixin);
	predictedSetting:SetUp(wrapTable);
	return predictedSetting;
end

PredictedToggleMixin = CreateFromMixins(PredictedSettingBaseMixin)

function PredictedToggleMixin:SetUp(wrapTable)
	PredictedSettingBaseMixin.SetUp(self, wrapTable);
	self.currentValue = self.wrapTable.getFunction();
end

function PredictedToggleMixin:Toggle()
	self.predictedValue = not self.currentValue;
	self.wrapTable.toggleFunction();
end

function PredictedToggleMixin:UpdateCurrentValue()
	self.currentValue = self.wrapTable.getFunction();
end

function CreatePredictedToggle(wrapTable)
	local predictedToggle = CreateFromMixins(PredictedToggleMixin);
	predictedToggle:SetUp(wrapTable);
	return predictedToggle;
end

LayoutIndexManagerMixin = {}

function LayoutIndexManagerMixin:AddManagedLayoutIndex(key, startingIndex)
	if (not self.managedLayoutIndexes) then
		self.managedLayoutIndexes = {};
		self.startingLayoutIndexes = {};
	end
	self.managedLayoutIndexes[key] = startingIndex;
	self.startingLayoutIndexes[key] = startingIndex;
end

function LayoutIndexManagerMixin:GetManagedLayoutIndex(key)
	if (not self.managedLayoutIndexes or not self.managedLayoutIndexes[key]) then
		return 0;
	end

	local layoutIndex = self.managedLayoutIndexes[key];
	self.managedLayoutIndexes[key] = self.managedLayoutIndexes[key] + 1;
	return layoutIndex;
end

function LayoutIndexManagerMixin:Reset()
	for k, _ in pairs(self.managedLayoutIndexes) do
		self.managedLayoutIndexes[k] = self.startingLayoutIndexes[k];
	end
end

function CreateLayoutIndexManager()
	return CreateFromMixins(LayoutIndexManagerMixin);
end

function CallMethodOnNearestAncestor(self, methodName, ...)
	local ancestor = self:GetParent();
	while ancestor and not ancestor[methodName] do
		ancestor = ancestor:GetParent();
	end

	if ancestor then
		ancestor[methodName](ancestor, ...);
		return true;
	end

	return false;
end

function FormateFullDateWithoutYear(messageDate)
	return FULLDATE_NO_YEAR:format(CALENDAR_WEEKDAY_NAMES[messageDate.weekDay], CALENDAR_FULLDATE_MONTH_NAMES[messageDate.month], messageDate.day);
end

function AreFullDatesEqual(firstDate, secondDate)
	return firstDate.month == secondDate.month and firstDate.day == secondDate.day and firstDate.year == secondDate.year;
end

function GetClampedCurrentExpansionLevel()
	return math.min(GetClientDisplayExpansionLevel(), math.max(GetAccountExpansionLevel(), GetExpansionLevel()));
end