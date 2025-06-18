TextSizeManagerBase = {};

function TextSizeManagerBase:Init()
	self.registeredObjects = {};
	self.defaultScaleWeight = 0.5;

	self:SetCVarName("userFontScale");
	self:SetMinimumScale(0.8);
	self:BuildFonts();
	
	local function CVarChangedCB(cvar, value)
		self:UpdateFonts(value);
	end

	CVarCallbackRegistry:RegisterCallback(self:GetCVarName(), CVarChangedCB);
	EventUtil.ContinueAfterAllEvents(function() self:UpdateFonts() end, self:GetInitialUpdateEvents());
end

function TextSizeManagerBase:BuildFonts()
	self.fonts = {};

	local fontObjectNames = GetFonts();
	
	for index, fontObjectName in ipairs(fontObjectNames) do
		local info = GetFontInfo(fontObjectName);
		if info and info.canBeUserScaled then
			self.fonts[fontObjectName] = { info = info, baseHeight = info.height, object = info.fontObject };
		end
	end
end

function TextSizeManagerBase:GetFonts()
	return self.fonts;
end

function TextSizeManagerBase:GetFontBaseHeight(fontName)
	local fonts = self:GetFonts();
	if fonts then
		local font = fonts[fontName];
		if font then
			return font.baseHeight;
		end
	end

	return 0;
end

function TextSizeManagerBase:GetResizedFontHeight(fontName, value)
	return self:GetFontBaseHeight(fontName) * value;
end

function TextSizeManagerBase:SetTextScale(scale)
	scale = self:GetScale(scale);

	for fontName, fontData in pairs(self.fonts) do
		fontData.object:SetFontHeight(fontData.baseHeight * scale);
	end

	self:UpdateRegisteredObjects(scale);
	self:UpdateRegisteredSystems(scale);
end

function TextSizeManagerBase:UpdateFonts(value)
	-- trying scale for now
	self:SetTextScale(value);
end

function TextSizeManagerBase:GetMinimumScale()
	return self.minScale;
end

function TextSizeManagerBase:GetScale(scale)
	return math.max(scale or self:GetSettingValue(), self:GetMinimumScale());
end

function TextSizeManagerBase:GetDefaultScaleWeight()
	return self.defaultScaleWeight;
end

function TextSizeManagerBase:SetMinimumScale(scale)
	-- There's an absolute limit imposed on scaling, base height is like 14, definitely don't allow it to go below 7.
	self.minScale = math.max(scale or 0, 0.5);
end

function TextSizeManagerBase:SetCVarName(name)
	self.cvarName = name;
end

function TextSizeManagerBase:GetCVarName()
	return self.cvarName;
end

function TextSizeManagerBase:GetSettingValue()
	return GetCVarNumberOrDefault(self:GetCVarName());
end

function TextSizeManagerBase:SetSettingValue(value)
	SetCVar(self:GetCVarName(), value);
end

local function GetScaleWeight(manager, registrationInfo)
	if registrationInfo and registrationInfo.useScaleWeight then
		return registrationInfo.scaleWeight or manager:GetDefaultScaleWeight();
	end

	return 1;
end

function TextSizeManagerBase:GetWeightedScale(scale, registrationInfo)
	local delta = scale - 1;
	local weight = GetScaleWeight(self, registrationInfo);
	return 1 + (delta * weight);
end

function TextSizeManagerBase:GetScaledValue(value)
	return value * self:GetScale();
end

function TextSizeManagerBase:GetScaledValueWeighted(value, registrationInfo)
	return value * self:GetWeightedScale(self:GetScale(), registrationInfo);
end

function TextSizeManagerBase:UpdateRegisteredObjects(scale)
	for obj, registrationInfo in pairs(self.registeredObjects) do
		obj:OnTextScaleUpdated(scale, registrationInfo);
	end
end

function TextSizeManagerBase:UpdateRegisteredSystems(scale)
	EventRegistry:TriggerEvent("TextSizeManager.OnTextScaleUpdated", scale);
end

function TextSizeManagerBase:RegisterObject(object, registrationInfo)
	self.registeredObjects[object] = registrationInfo or object;
end

function TextSizeManagerBase:UpdateObject(object)
	object:OnTextScaleUpdated(self:GetScale(), self.registeredObjects[object]);
end
