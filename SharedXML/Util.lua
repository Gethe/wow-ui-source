RAID_CLASS_COLORS = {
	["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffabd473" },
	["WARLOCK"] = { r = 0.53, g = 0.53, b = 0.93, colorStr = "ff8788ee" },
	["PRIEST"] = { r = 1.0, g = 1.0, b = 1.0, colorStr = "ffffffff" },
	["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "fff58cba" },
	["MAGE"] = { r = 0.25, g = 0.78, b = 0.92, colorStr = "ff3fc7eb" },
	["ROGUE"] = { r = 1.0, g = 0.96, b = 0.41, colorStr = "fffff569" },
	["DRUID"] = { r = 1.0, g = 0.49, b = 0.04, colorStr = "ffff7d0a" },
	["SHAMAN"] = { r = 0.0, g = 0.44, b = 0.87, colorStr = "ff0070de" },
	["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffc79c6e" },
	["DEATHKNIGHT"] = { r = 0.77, g = 0.12 , b = 0.23, colorStr = "ffc41f3b" },
	["MONK"] = { r = 0.0, g = 1.00 , b = 0.59, colorStr = "ff00ff96" },
	["DEMONHUNTER"] = { r = 0.64, g = 0.19, b = 0.79, colorStr = "ffa330c9" },
};

function GetClassColor(classFilename)
	local color = RAID_CLASS_COLORS[classFilename];
	if color then
		return color.r, color.g, color.b, color.colorStr;
	end

	return 1, 1, 1, "ffffffff";
end

function WrapTextInColorCode(text, colorHexString)
	return ("|c%s%s|r"):format(colorHexString, text);
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

function SetClampedTextureRotation(texture, rotationDegrees)
	if (rotationDegrees ~= 0 and rotationDegrees ~= 90 and rotationDegrees ~= 180 and rotationDegrees ~= 270) then
		error("SetRotation: rotationDegrees must be 0, 90, 180, or 270");
		return;
	end

	if not (texture.rotationDegrees) then
		texture.origTexCoords = {texture:GetTexCoord()};
		texture.origWidth = texture:GetWidth();
		texture.origHeight = texture:GetHeight();
	end

	if (texture.rotationDegrees == rotationDegrees) then
		return;
	end

	texture.rotationDegrees = rotationDegrees;

	if (rotationDegrees == 0 or rotationDegrees == 180) then
		texture:SetWidth(texture.origWidth);
		texture:SetHeight(texture.origHeight);
	else
		texture:SetWidth(texture.origHeight);
		texture:SetHeight(texture.origWidth);
	end

	if (rotationDegrees == 0) then
		texture:SetTexCoord( texture.origTexCoords[1], texture.origTexCoords[2],
											texture.origTexCoords[3], texture.origTexCoords[4],
											texture.origTexCoords[5], texture.origTexCoords[6],
											texture.origTexCoords[7], texture.origTexCoords[8] );
	elseif (rotationDegrees == 90) then
		texture:SetTexCoord( texture.origTexCoords[3], texture.origTexCoords[4],
											texture.origTexCoords[7], texture.origTexCoords[8],
											texture.origTexCoords[1], texture.origTexCoords[2],
											texture.origTexCoords[5], texture.origTexCoords[6] );
	elseif (rotationDegrees == 180) then
		texture:SetTexCoord( texture.origTexCoords[7], texture.origTexCoords[8],
											texture.origTexCoords[5], texture.origTexCoords[6],
											texture.origTexCoords[3], texture.origTexCoords[4],
											texture.origTexCoords[1], texture.origTexCoords[2] );
	elseif (rotationDegrees == 270) then
		texture:SetTexCoord( texture.origTexCoords[5], texture.origTexCoords[6],
											texture.origTexCoords[1], texture.origTexCoords[2],
											texture.origTexCoords[7], texture.origTexCoords[8],
											texture.origTexCoords[3], texture.origTexCoords[4] );
	end
end

function ClearClampedTextureRotation(texture)
	if (texture.rotationDegrees) then
		SetClampedTextureRotation(0);
		texture.origTexCoords = nil;
		texture.origWidth = nil;
		texture.origHeight = nil;
	end
end


function GetTexCoordsByGrid(xOffset, yOffset, textureWidth, textureHeight, gridWidth, gridHeight)
	local widthPerGrid = gridWidth/textureWidth;
	local heightPerGrid = gridHeight/textureHeight;
	return (xOffset-1)*widthPerGrid, (xOffset)*widthPerGrid, (yOffset-1)*heightPerGrid, (yOffset)*heightPerGrid;
end

function GetTexCoordsForRole(role)
	local textureHeight, textureWidth = 256, 256;
	local roleHeight, roleWidth = 67, 67;

	if ( role == "GUIDE" ) then
		return GetTexCoordsByGrid(1, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "TANK" ) then
		return GetTexCoordsByGrid(1, 2, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "HEALER" ) then
		return GetTexCoordsByGrid(2, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "DAMAGER" ) then
		return GetTexCoordsByGrid(2, 2, textureWidth, textureHeight, roleWidth, roleHeight);
	else
		error("Unknown role: "..tostring(role));
	end
end

function tDeleteItem(table, item)
	local index = 1;
	while table[index] do
		if ( item == table[index] ) then
			tremove(table, index);
		else
			index = index + 1;
		end
	end
end

function tContains(table, item)
	local index = 1;
	while table[index] do
		if ( item == table[index] ) then
			return 1;
		end
		index = index + 1;
	end
	return nil;
end

function tInvert(tbl)
	local inverted = {};
	for k, v in pairs(tbl) do
		inverted[v] = k;
	end
	return inverted;
end

function CopyTable(settings)
	local copy = {};
	for k, v in pairs(settings) do
		if ( type(v) == "table" ) then
			copy[k] = CopyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
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

function Lerp(startValue, endValue, amount)
	return (1 - amount) * startValue + amount * endValue;
end

function Clamp(value, min, max)
	if value > max then
		return max;
	elseif value < min then
		return min;
	end
	return value;
end

function Saturate(value)
	return Clamp(value, 0.0, 1.0);
end

function PercentageBetween(value, startValue, endValue)
	if startValue == endValue then
		return 0.0;
	end
	return (startValue - value) / (startValue - endValue);
end

function ClampedPercentageBetween(value, startValue, endValue)
	return Saturate(PercentageBetween(value, startValue, endValue));
end

local TARGET_FRAME_PER_SEC = 60.0;
function DeltaLerp(startValue, endValue, amount, timeSec)
	return Lerp(startValue, endValue, Saturate(amount * timeSec * TARGET_FRAME_PER_SEC));
end

function FrameDeltaLerp(startValue, endValue, amount)
	return DeltaLerp(startValue, endValue, amount, GetTickTime());
end

----------------------------------
-- TRIAL/VETERAN FUCNCTIONS
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

local function ProcessSmoothStatusBars()
	for bar, targetValue in pairs(g_updatingBars) do
		local newValue = FrameDeltaLerp(bar:GetValue(), targetValue, .25);
		if math.abs(newValue - targetValue) < .005 then
			g_updatingBars[bar] = nil;
		end

		bar:SetValue(newValue);
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
			ratio = max / (self.lastSmoothedMax or max);
		end

		g_updatingBars[self] = targetValue * ratio;
	end

	self.lastSmoothedMin = min;
	self.lastSmoothedMax = max;
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
	return self.r * 255, self.g * 255, self.b * 255, self.a * 255;
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

function ColorMixin:WrapTextInColorCode(text)
	return WrapTextInColorCode(text, self:GenerateHexColor());
end

-- Time --
function SecondsToTime(seconds, noSeconds, notAbbreviated, maxCount, roundUp)
	local time = "";
	local count = 0;
	local tempTime;
	seconds = roundUp and ceil(seconds) or floor(seconds);
	maxCount = maxCount or 2;
	if ( seconds >= 86400  ) then
		count = count + 1;
		if ( count == maxCount and roundUp ) then
			tempTime = ceil(seconds / 86400);
		else
			tempTime = floor(seconds / 86400);
		end
		if ( notAbbreviated ) then
			time = D_DAYS:format(tempTime);
		else
			time = DAYS_ABBR:format(tempTime);
		end
		seconds = mod(seconds, 86400);
	end
	if ( count < maxCount and seconds >= 3600  ) then
		count = count + 1;
		if ( time ~= "" ) then
			time = time..TIME_UNIT_DELIMITER;
		end
		if ( count == maxCount and roundUp ) then
			tempTime = ceil(seconds / 3600);
		else
			tempTime = floor(seconds / 3600);
		end
		if ( notAbbreviated ) then
			time = time..D_HOURS:format(tempTime);
		else
			time = time..HOURS_ABBR:format(tempTime);
		end
		seconds = mod(seconds, 3600);
	end
	if ( count < maxCount and seconds >= 60  ) then
		count = count + 1;
		if ( time ~= "" ) then
			time = time..TIME_UNIT_DELIMITER;
		end
		if ( count == maxCount and roundUp ) then
			tempTime = ceil(seconds / 60);
		else
			tempTime = floor(seconds / 60);
		end
		if ( notAbbreviated ) then
			time = time..D_MINUTES:format(tempTime);
		else
			time = time..MINUTES_ABBR:format(tempTime);
		end
		seconds = mod(seconds, 60);
	end
	if ( count < maxCount and seconds > 0 and not noSeconds ) then
		if ( time ~= "" ) then
			time = time..TIME_UNIT_DELIMITER;
		end
		if ( notAbbreviated ) then
			time = time..D_SECONDS:format(seconds);
		else
			time = time..SECONDS_ABBR:format(seconds);
		end
	end
	return time;
end

function SecondsToTimeAbbrev(seconds)
	local tempTime;
	if ( seconds >= 86400  ) then
		tempTime = ceil(seconds / 86400);
		return DAY_ONELETTER_ABBR, tempTime;
	end
	if ( seconds >= 3600  ) then
		tempTime = ceil(seconds / 3600);
		return HOUR_ONELETTER_ABBR, tempTime;
	end
	if ( seconds >= 60  ) then
		tempTime = ceil(seconds / 60);
		return MINUTE_ONELETTER_ABBR, tempTime;
	end
	return SECOND_ONELETTER_ABBR, seconds;
end

function FormatShortDate(day, month, year)
	if (LOCALE_enGB) then
		return SHORTDATE_EU:format(day, month, year);
	else
		return SHORTDATE:format(day, month, year);
	end
end

function Round(value)
	if value < 0.0 then
		return math.ceil(value - .5);
	end
	return math.floor(value + .5);
end

function FormatPercentage(percentage)
	return ("%d%%"):format(Round(percentage * 100));
end

function CreateTextureMarkup(file, fileWidth, fileHeight, width, height, left, right, top, bottom)
	return ("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t"):format(
		  file
		, height
		, width
		, fileWidth
		, fileHeight
		, left * fileWidth
		, right * fileWidth
		, top * fileHeight
		, bottom * fileHeight
	);
end

function CreateAtlasMarkup(atlasName, height, width, offsetX, offsetY)
	return ("|A:%s:%d:%d:%d:%d|a"):format(
		  atlasName
		, height or 0
		, width or 0
		, offsetX or 0
		, offsetY or 0
	);
end

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
