UIThemeContainerMixin = {};

function UIThemeContainerMixin:UIThemeContainerFrame_OnPreLoad()
	self.cvar = "questTextContrast";
	self.fontStrings = {};
	self.frames = {};
end

function UIThemeContainerMixin:UIThemeContainerFrame_OnPreShow()
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
end

function UIThemeContainerMixin:UIThemeContainerFrame_OnPostHide()
	self:UnregisterEvent("CVAR_UPDATE");
	self:UnregisterEvent("VARIABLES_LOADED");
end

function UIThemeContainerMixin:UIThemeContainerFrame_OnPostEvent(event, ...)
	if event == "VARIABLES_LOADED" then
		self:UpdateTheme(self:GetCVarValue());
	elseif event == "CVAR_UPDATE" then
		local cvar, value = ...;
		self:CheckUpdateTheme(cvar, value);
	end
end

function UIThemeContainerMixin:UpdateTheme(cvarValue)
	cvarValue = tonumber(cvarValue or self:GetCVarValue());
	self:UpdateFontStrings(cvarValue);
	self:UpdateFrames(cvarValue);
	self:UpdateBackground(cvarValue);
end

function UIThemeContainerMixin:CheckUpdateTheme(cvar, value)
	if cvar == self.cvar then
		self:UpdateTheme(value);
	end
end

function UIThemeContainerMixin:GetCVarValue()
	return GetCVarNumberOrDefault(self.cvar);
end

function UIThemeContainerMixin:IsDarkMode(cvarValue)
	return QuestTextContrast.UseLightText(cvarValue);
end

local CONTRAST_LIGHT_MODE = false;
local CONTRAST_DARK_MODE = true;

local textColors = 
{
	-- key : fixedColor, color
	[CONTRAST_LIGHT_MODE] = { false, PARCHMENT_MATERIAL_TEXT_COLOR, },
	[CONTRAST_DARK_MODE] = { true, STONE_MATERIAL_TEXT_COLOR, },
};

function UIThemeContainerMixin:UpdateFontStrings(cvarValue)
	local colorEntry = textColors[self:IsDarkMode(cvarValue)];
	local fixedColor, color = unpack(colorEntry);

	for fontString in pairs(self.fontStrings) do
		fontString:SetFixedColor(fixedColor);
		fontString:SetTextColor(color:GetRGB());
	end
end

function UIThemeContainerMixin:UpdateFrames(cvarValue)
	local darkMode = self:IsDarkMode(cvarValue);

	for frame in pairs(self.frames) do
		frame:UpdateTheme(darkMode);
	end
end

function UIThemeContainerMixin:UpdateBackground(cvarValue)
	if self.backgroundTexture then
		self.backgroundTexture:SetAtlas(QuestTextContrast.GetTextureKitBackgroundAtlas(self.textureKit), TextureKitConstants.UseAtlasSize);
	end
end

function UIThemeContainerMixin:RegisterObject(container, object)
	container[object] = true;
end

function UIThemeContainerMixin:RegisterObjects(container, ...)
	for i = 1, select("#", ...) do
		local object  = select(i, ...);
		self:RegisterObject(container, object);
	end
end

function UIThemeContainerMixin:RegisterFontString(fontString)
	self:RegisterObject(self.fontStrings, fontString);
end

function UIThemeContainerMixin:RegisterFontStrings(...)
	self:RegisterObjects(self.fontStrings, ...);
end

function UIThemeContainerMixin:RegisterFrame(frame)
	self:RegisterObject(self.frames, frame);
end

function UIThemeContainerMixin:RegisterFrames(...)
	self:RegisterObjects(self.frames, ...);
end

function UIThemeContainerMixin:RegisterBackgroundTexture(texture, textureKit)
	self.backgroundTexture = texture;
	self.textureKit = textureKit;
end