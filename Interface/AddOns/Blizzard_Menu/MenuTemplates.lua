MenuTemplates = {};

local function CheckSecure()
	if MenuConstants.PrintSecure and (not IsPublicBuild()) then
		UIErrorsFrame:AddMessage("Secure: "..tostring(issecure()));
	end
end

local function CreateMenuElementDescription(template, initializer, data)
	local elementDescription = Menu.CreateMenuElementDescription();
	elementDescription:SetData(data);
	elementDescription:SetElementFactory(function(factory)
		factory(template, initializer);
	end);

	return elementDescription;
end

local function CallFunctionWithVarArgAsParam(func, ...)
	for index = 1, select("#", ...) do
		func(select(index, ...));
	end
end

local function GetCheckboxSoundKit(description)
	if description:IsSelected() then
		return MenuVariants.GetCheckboxCheckSoundKit();
	else
		return MenuVariants.GetCheckboxUncheckSoundKit();
	end
end

local function GetButtonSoundKit(description)
	return MenuVariants.GetButtonSoundKit();
end

--[[
Final initializer is called after all other initializers are called so that
the recursion functions here can find any of the regions that were attached.
]]--
local function ButtonFinalInitializer(button, description, menu)
	MenuTemplates.RecurseSetupFontString(button);

	local enabled = description:IsEnabled();
	button:SetEnabled(enabled);

	MenuTemplates.SetHierarchyEnabled(button, enabled);
end

local function OnButtonEnable(button)
	MenuTemplates.SetHierarchyEnabled(button, true);
end

local function OnButtonDisable(button)
	MenuTemplates.SetHierarchyEnabled(button, false);
end

local function OnButtonClick(button, buttonName)
	local description = button:GetElementDescription();
	if not description:CanOpenSubmenu() or description:ShouldPlaySoundOnSubmenuClick() then
		PlaySound(description:GetSoundKit());
	end

	description:Pick(MenuInputContext.MouseButton, buttonName);
	securecallfunction(CheckSecure);
end

local function ShowHighlight(button, description)
	button.highlight:Show();
	button.highlight:SetAlpha(description:IsEnabled() and 1 or MenuVariants.DisabledHighlightOpacity);
end

local function OnButtonEnter(button, description)
	ShowHighlight(button, description);
end

local function OnButtonLeave(button)
	button.highlight:Hide();
end

local function ButtonInitializer(button, description, menu)
	if description:CanOpenSubmenu() then
		MenuVariants.CreateSubmenuArrow(button);
	end

	local highlight = MenuVariants.CreateHighlight(button);

	--[[
	Visibility cannot be automatically toggled on the HIGHLIGHT layer
	because the highlight needs to be the bottom render layer.
	]]--
	button.OnEnter = OnButtonEnter;
	button.OnLeave = OnButtonLeave;
	
	--[[
	The button will not re-highlight if it is reinitialized while the cursor
	is already over the button.
	]]--
	for index, focus in ipairs(GetMouseFoci()) do
		if focus == button then
			ShowHighlight(button, description);
		end
	end

	if description:ShouldPollEnabled() then
		button:NewTicker(MenuConstants.ElementPollFrequencySeconds, function()
			button:SetEnabled(description:IsEnabled());
		end);
	end

	button:SetMotionScriptsWhileDisabled(true);
	button:SetScript("OnEnable", OnButtonEnable);
	button:SetScript("OnDisable", OnButtonDisable);
	button:SetScript("OnClick", OnButtonClick);
end

local function CreateButtonDescription(data)
	local elementDescription = CreateMenuElementDescription("Button", ButtonInitializer, data);
	elementDescription:SetFinalInitializer(ButtonFinalInitializer);
	return elementDescription;
end

function MenuTemplates.RecurseSetupFontString(frame)
	--[[
	Applying the enabled state is deferred until all initializers are called so that any
	construction or initialization of any regions is finished before we attempt to traverse
	the hierarchy and apply new states.
	]]--

	--[[
	Cache our current and disabled color so we can switch between them as the button
	enabled state is changed. When a use case for changing the disabled color appears,
	add an API to return the desired color(s).
	]]--

	local function TrySetupFontString(region)
		if region:IsObjectType("FontString") then
			local fontString = region;
			local autoEnableTextColors = 
			{
				[true] = CreateColor(fontString:GetTextColor()),
				[false] = DISABLED_FONT_COLOR,
			};
				
			-- Compositor replaces __index with a function. Also note that 
			-- you cannot acquire the original function again once SetTextColor
			-- is assigned because the mt will return the assigned function instead.
			local originalSetTextColor;
			local mt = getmetatable(fontString);
			if type(mt.__index) == "function" then
				originalSetTextColor = mt.__index(fontString, "SetTextColor");
			elseif not fontString.autoEnableTextColors then
				originalSetTextColor = fontString.SetTextColor;
			end
			
			if originalSetTextColor then
				fontString.SetTextColor = function(self, r, g, b, a)
					autoEnableTextColors[true] = CreateColor(r, g, b, a);
					originalSetTextColor(self, r, g, b, a);
				end;
				fontString.autoEnableTextColors = autoEnableTextColors;
			end
		end
	end
	CallFunctionWithVarArgAsParam(TrySetupFontString, frame:GetRegions());
	CallFunctionWithVarArgAsParam(MenuTemplates.RecurseSetupFontString, frame:GetChildren());
end

function MenuTemplates.SetHierarchyEnabled(frame, enabled)
	local function Recurse(frame)
		if frame.noRecurseHierarchy then
			return;
		end

		local function SetAutoEnabled(region)
			if region.noRecurseHierarchy then
				return;
			end

			local objType = region:GetObjectType();
			if objType == "FontString" and region.autoEnableTextColors then
				local fontString = region;
				local textColor = fontString.autoEnableTextColors[enabled];
				fontString:SetTextColor(textColor:GetRGBA());
			elseif objType == "Texture" then
				region:SetDesaturation(enabled and 0 or 1);
			end
		end
		CallFunctionWithVarArgAsParam(SetAutoEnabled, frame:GetRegions());
		CallFunctionWithVarArgAsParam(Recurse, frame:GetChildren());
	end

	Recurse(frame);
end

function MenuTemplates.CreateFrame(initializer, data)
	return CreateMenuElementDescription("Frame", initializer, data);
end

function MenuTemplates.CreateTemplate(template, initializer, data)
	return CreateMenuElementDescription(template, initializer, data);
end

function MenuTemplates.CreateTitle(text)
	local function Initializer(frame, description, menu)
		local fontString = MenuVariants.CreateFontString(frame);
		frame.fontString = fontString;
		fontString:SetTextToFit(text);
	end

	return MenuTemplates.CreateFrame(Initializer);
end

function MenuTemplates.CreateButton(text, callback, data)
	local function Initializer(button, description, menu)
		local fontString = MenuVariants.CreateFontString(button);
		button.fontString = fontString;
		fontString:SetTextToFit(text);
	end

	local elementDescription = CreateButtonDescription(data);
	elementDescription:SetSoundKit(GetButtonSoundKit);
	elementDescription:AddInitializer(Initializer);
	elementDescription:SetResponder(callback);
	return elementDescription;
end

--[[
Radio and checkbox textures both share a 2 texture setup where a second texture is created
only if the data is selected.
]]
function MenuTemplates.CreateSelectionTextures(frame, isSelected, data, unselectedAtlas, selectedAtlas)
	local leftTexture1 = frame:AttachTexture();
	frame.leftTexture1 = leftTexture1;
	leftTexture1:SetAtlas(unselectedAtlas, TextureKitConstants.UseAtlasSize);

	-- Avoiding creating the second texture unnecessarily.
	local leftTexture2 = nil;
	if isSelected(data) then
		leftTexture2 = frame:AttachTexture();
		local layer, drawLevel = leftTexture1:GetDrawLayer();
		leftTexture2:SetDrawLayer(layer, drawLevel + 1);
		leftTexture2:SetAtlas(selectedAtlas, TextureKitConstants.UseAtlasSize);
	end
	
	frame.leftTexture2 = leftTexture2;
	return leftTexture1, leftTexture2;
end

function MenuTemplates.CreateCheckbox(text, isSelected, onSelect, data)
	local function Initializer(button, description, menu)
		MenuVariants.CreateCheckbox(text, button, isSelected, data);
	end

	local elementDescription = CreateButtonDescription(data);
	elementDescription:SetSoundKit(GetCheckboxSoundKit);
	elementDescription:AddInitializer(Initializer);
	elementDescription:SetIsSelected(isSelected);
	elementDescription:SetResponder(onSelect);
	elementDescription:SetResponse(MenuResponse.Refresh);
	return elementDescription;
end

function MenuTemplates.CreateRadio(text, isSelected, onSelect, data)
	local function Initializer(button, description, menu)
		MenuVariants.CreateRadio(text, button, isSelected, data);
	end
	
	local elementDescription = CreateButtonDescription(data);
	elementDescription:SetSoundKit(GetButtonSoundKit);
	elementDescription:AddInitializer(Initializer);
	elementDescription:SetRadio(true);
	elementDescription:SetIsSelected(isSelected);
	elementDescription:SetResponder(onSelect);
	return elementDescription;
end

function MenuTemplates.CreateSpacer(extent)
	local function Initializer(frame, description, menu)
		frame:SetHeight(extent or 10);
	end

	return MenuTemplates.CreateFrame(Initializer);
end

function MenuTemplates.CreateDivider()
	local function Initializer(frame, description, menu)
		frame.divider = MenuVariants.CreateDivider(frame);
	end

	return MenuTemplates.CreateFrame(Initializer);
end

function MenuTemplates.CreateColorSwatch(text, callback, colorInfo)
	local function Initializer(frame, description, menu)
		local fontString = MenuVariants.CreateFontString(frame);
		frame.fontString = fontString;
		frame.fontString:SetTextToFit(text);

		local colorSwatch = frame:AttachTemplate("ColorSwatchTemplate");
		frame.colorSwatch = colorSwatch;
		colorSwatch:SetPoint("RIGHT");
		colorSwatch:SetSize(16, 16);
		colorSwatch:SetPropagateKeyboardInput(true);
		colorSwatch:SetColorRGB(colorInfo.r, colorInfo.g, colorInfo.b);

		-- Input is not propagating through the color swatch to the parent
		-- button. Resolve later.
		--colorSwatch:SetScript("OnEnter", function()
		--	colorSwatch:SetBorderColor(NORMAL_FONT_COLOR);
		--end);
		--
		--colorSwatch:SetScript("OnLeave", function()
		--	colorSwatch:SetBorderColor(HIGHLIGHT_FONT_COLOR);
		--end);
	end
	
	local elementDescription = CreateButtonDescription(colorInfo);
	elementDescription:SetSoundKit(GetButtonSoundKit);
	elementDescription:AddInitializer(Initializer);
	elementDescription:SetResponder(callback);
	return elementDescription;
end

do
	local function OnAutoHideButtonLeave(button)
		MenuUtil.HideTooltip(button);
	end

	function MenuTemplates.AttachAutoHideButton(parent, textureName)
		local button = parent:AttachFrame("Button");
		button:SetPropagateMouseMotion(true);
		button:Hide();
	
		button:SetScript("OnLeave", OnAutoHideButtonLeave);
	
		local texture = button:AttachTexture();
		texture:SetTexture(textureName);
		texture:SetAllPoints();
	
		local onEnter = parent.OnEnter or nop;
		parent.OnEnter = function(...)
			onEnter(parent, ...);
			button:Show();
		end
	
		local onLeave = parent.OnLeave or nop;
		parent.OnLeave = function(...)
			onLeave(parent, ...);
			button:Hide();
		end
		return button;
	end
end

function MenuTemplates.AttachAutoHideGearButton(parent)
	local button = MenuTemplates.AttachAutoHideButton(parent, MenuVariants.GearButtonTexture);
	button:SetSize(16, 16);
	return button;
end

function MenuTemplates.AttachAutoHideCancelButton(parent)
	local button = MenuTemplates.AttachAutoHideButton(parent, MenuVariants.CancelButtonTexture);
	button:SetSize(16, 16);
	return button;
end

function MenuTemplates.AttachNewFeatureFrame(parent)
	local newFeatureFrame = parent:AttachTemplate("NewFeatureLabelTemplate");
	
	newFeatureFrame.noRecurseHierarchy = true;
	return newFeatureFrame;
end

function MenuTemplates.AttachTexture(parent, textureOrAtlas, point, pointX, pointY)
	local iconTexture = parent:AttachTexture();
	iconTexture:SetPoint(point or "RIGHT", pointX or 0, pointY or 0);

	if C_Texture.GetAtlasInfo(textureOrAtlas) then
		local useAtlasSize = false;
		iconTexture:SetAtlas(textureOrAtlas, useAtlasSize);
	else
		iconTexture:SetTexture(textureOrAtlas);
	end

	return iconTexture;
end

DropdownTextMixin = {};

function DropdownTextMixin:OnLoad()
	if self.text then
		self:SetText(self.text);
	end
end

function DropdownTextMixin:GetText()
	return self.text;
end

function DropdownTextMixin:SetText(text)
	self.text = text;
	self:UpdateText();
end

function DropdownTextMixin:GetUpdateText()
	return self.text;
end

function DropdownTextMixin:UpdateText()
	self.Text:SetText(self:GetUpdateText());

	if self.resizeToText then
		local newWidth = self.Text:GetUnboundedStringWidth();

		if self.resizeToTextPadding then
			newWidth = newWidth + self.resizeToTextPadding;
		end

		if self.resizeToTextMaxWidth then
			newWidth = math.min(self.resizeToTextMaxWidth, newWidth);
		end
		
		if self.resizeToTextMinWidth then
			newWidth = math.max(self.resizeToTextMinWidth, newWidth);
		end

		self:SetWidth(newWidth);
	end
end

function DropdownTextMixin:UpdateToMenuSelections(menuDescription, currentSelections)
	self:UpdateText();
end

--[[
An initializer wrapping DropdownButtonMixin.SetupMenu is not provided because in the vast majority of cases 
the displayed text will reflect at least 1 selected option. SetDefaultText() should be used to provide text 
in the cases where no selection is possible.
]]--
DropdownSelectionTextMixin = CreateFromMixins(DropdownTextMixin);

local function DefaultSelectionTranslator(selection)
	return MenuUtil.GetElementText(selection);
end

function DropdownSelectionTextMixin:OnLoad()
	DropdownTextMixin.OnLoad(self);

	self:SetSelectionTranslator(DefaultSelectionTranslator);
end

function DropdownSelectionTextMixin:GetUpdateText()
	return self.text or self.defaultText;
end

function DropdownSelectionTextMixin:GetDefaultText()
	return self.defaultText;
end

function DropdownSelectionTextMixin:SetDefaultText(text)
	self.defaultText = text;
	self:UpdateText();
end

function DropdownSelectionTextMixin:SetSelectionTranslator(translator)
	self.selectionTranslator = translator;
end

function DropdownSelectionTextMixin:SetSelectionText(selectionFunc)
	self.selectionFunc = selectionFunc;
end

function DropdownSelectionTextMixin:OverrideText(text)
	if not text then
		return;
	end

	self.disableSelectionText = true;
	self:SetText(text);
end

function DropdownSelectionTextMixin:UpdateToMenuSelections(menuDescription, currentSelections)
	if self.disableSelectionText then
		return;
	end

	if not currentSelections and menuDescription then
		currentSelections = MenuUtil.GetSelections(menuDescription);
	end

	local text = nil;
	
	if self.selectionFunc then
		text = self.selectionFunc(currentSelections);
	elseif currentSelections then
		local texts = {};
	
		for index, selection in ipairs(currentSelections) do
			if not selection:IsSelectionIgnored() then
				local translatedText = self.selectionTranslator(selection);
				table.insert(texts, translatedText);
			end
		end
		
		if #texts > 0 then
			text = table.concat(texts, LIST_DELIMITER);
		end
	end

	self:SetText(text or self.defaultText);
end

function DropdownSelectionTextMixin:OnShow()
	-- Will only cause a menu description to be generated if the generator was
	-- assigned prior to the OnShow() being called.
	self:GenerateMenu();
end

function DropdownSelectionTextMixin:OnEnter()
	ButtonStateBehaviorMixin.OnEnter(self);

	if self:ShouldShowTooltip() then
		self:ShowTooltip();
	end
end

function DropdownSelectionTextMixin:ShouldShowTooltip()
	return self.Text:IsTruncated() or self.tooltipFunc;
end

function DropdownSelectionTextMixin:SetTooltip(tooltipFunc)
	self.tooltipFunc = tooltipFunc;
end

function DropdownSelectionTextMixin:ShowTooltip()
	if self.tooltipFunc then
		MenuUtil.ShowTooltip(self, self.tooltipFunc);
	else
		MenuUtil.ShowTooltip(self, function(tooltip)
			GameTooltip_SetTitle(tooltip, self.Text:GetText());
		end);
	end
end

function DropdownSelectionTextMixin:OnLeave()
	ButtonStateBehaviorMixin.OnLeave(self);

	MenuUtil.HideTooltip(self);
end

WowDropdownFilterMixin = CreateFromMixins(DropdownButtonMixin);

function WowDropdownFilterMixin:OnLoad()
	assert(self.ResetButton);

	self.ResetButton:SetScript("OnClick", function(button, buttonName, down)
		if self.defaultCallback then
			 self.defaultCallback();
		end

		self.ResetButton:Hide();
	end);
end

function WowDropdownFilterMixin:OnShow()
	self:ValidateResetState();
end

-- Callback to set all filters to default state.
function WowDropdownFilterMixin:SetDefaultCallback(callback)
	self.defaultCallback = callback;
end

-- Callback to return if the filters are in their default state.
function WowDropdownFilterMixin:SetIsDefaultCallback(callback)
	self.isDefaultCallback = callback;
end

-- Called in response to any menu option change. 
function WowDropdownFilterMixin:SetUpdateCallback(callback)
	self.notifyUpdateCallback = callback;
end

function WowDropdownFilterMixin:NotifyUpdate(description)
	if self.notifyUpdateCallback then
		self.notifyUpdateCallback(description);
	end
end

function WowDropdownFilterMixin:OnMenuResponse(menu, description)
	DropdownButtonMixin.OnMenuResponse(self, menu, description);

	self:ValidateResetState();
	self:NotifyUpdate(description);
end

function WowDropdownFilterMixin:OnMenuAssigned()
	DropdownButtonMixin.OnMenuAssigned(self);

	self:ValidateResetState();
end

function WowDropdownFilterMixin:OnMenuResponse(menu, description)
	DropdownButtonMixin.OnMenuResponse(self, menu, description);

	self:ValidateResetState();
	self:NotifyUpdate(description);
end

function WowDropdownFilterMixin:Reset()
	self.ResetButton:Hide();
end

function WowDropdownFilterMixin:ValidateResetState()
	if self.isDefaultCallback then
		self.ResetButton:SetShown(not self.isDefaultCallback());
	end
end

WowStyle1DropdownMixin = CreateFromMixins(ButtonStateBehaviorMixin, DropdownSelectionTextMixin);

function WowStyle1DropdownMixin:SetupMenu(generator)
	DropdownButtonMixin.SetupMenu(self, generator);
end

function WowStyle1DropdownMixin:OnLoad()
	ValidateIsDropdownButtonIntrinsic(self);
	ButtonStateBehaviorMixin.OnLoad(self);
	DropdownSelectionTextMixin.OnLoad(self);
end

function WowStyle1DropdownMixin:OnButtonStateChanged()
	local enabled = self:IsEnabled();
	if enabled then
		self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	else
		self.Text:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	end

	self.Arrow:SetAtlas(self:GetArrowAtlas(), TextureKitConstants.UseAtlasSize);
end

--[[
The standard "filter" dropdown style. It's text does not reflect the selected option(s) and
instead is generally initialized to fixed text.
]]--
WowStyle1FilterDropdownMixin = CreateFromMixins(ButtonStateBehaviorMixin, DropdownTextMixin, WowDropdownFilterMixin);

function WowStyle1FilterDropdownMixin:OnLoad()
	ValidateIsDropdownButtonIntrinsic(self);
	ButtonStateBehaviorMixin.OnLoad(self);
	DropdownTextMixin.OnLoad(self);
	WowDropdownFilterMixin.OnLoad(self);

	local x, y = 2, -1;
	self:SetDisplacedRegions(x, y, self.Text);
end

function WowStyle1FilterDropdownMixin:OnButtonStateChanged()
	self.Background:SetAtlas(self:GetBackgroundAtlas(), TextureKitConstants.UseAtlasSize);
end

--[[
A special style used in Settings and Character Creation/Customization. Note that complex
contents (color swatches, icons, etc.) are not defined here but are instead added as a child
within this template. See "WowStyle2DropdownTemplate" in Blizzard_CharacterCustomize.xml.
]]--
WowStyle2DropdownMixin = CreateFromMixins(ButtonStateBehaviorMixin, DropdownSelectionTextMixin);

function WowStyle2DropdownMixin:OnLoad()
	ButtonStateBehaviorMixin.OnLoad(self);
	DropdownSelectionTextMixin.OnLoad(self);

	local x, y = 2, -1;
	self:SetDisplacedRegions(x, y, self.Text);
end

function WowStyle2DropdownMixin:GetBackgroundAtlas()
	if self:IsEnabled() then
		if self:IsDownOver() then
			return "common-dropdown-c-button-pressedhover-1";
		elseif self:IsOver() then
			return "common-dropdown-c-button-hover-1";
		elseif self:IsDown() then
			return "common-dropdown-c-button-pressed-1";
		elseif self:IsMenuOpen() then
			return "common-dropdown-c-button-open";
		else
			return "common-dropdown-c-button";
		end
	end

	return "common-dropdown-c-button-disabled";
end

function WowStyle2DropdownMixin:OnButtonStateChanged()
	local enabled = self:IsEnabled();
	if enabled then
		self.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	else
		self.Text:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	end

	self.Arrow:SetShown(self:IsOver());
	self.Arrow:SetDesaturated(not enabled);

	self.Background:SetAtlas(self:GetBackgroundAtlas(), TextureKitConstants.UseAtlasSize);
end

function WowStyle2DropdownMixin:OnMenuOpened(menu)
	DropdownButtonMixin.OnMenuOpened(self, menu);

	self:OnButtonStateChanged();
end

function WowStyle2DropdownMixin:OnMenuClosed(menu)
	DropdownButtonMixin.OnMenuClosed(self, menu);

	self:OnButtonStateChanged();
end

MenuStyleMixin = {};

function MenuStyleMixin:Generate()
	local texture = self:AttachTexture();
	texture:SetAllPoints();

	local r, g, b = GREEN_FONT_COLOR:GetRGB();
	texture:SetColorTexture(r, g, b, .5);
end

function MenuStyleMixin:GetInset()
	return 0,0,0,0; -- L, T, R, B
end

-- Increases the effective width of every child.
function MenuStyleMixin:GetChildExtentPadding()
	return 0, 0;
end

-- Test purposes only.
RandomColorStyleMenuMixin = CreateFromMixins(MenuStyleMixin);

function RandomColorStyleMenuMixin:Generate()
	local texture = self:AttachTexture();
	texture:SetAllPoints();

	local c = .5;
	local r, g, b = math.random() * c, math.random() * c, math.random() * c;
	texture:SetColorTexture(r, g, b, 1);
end

BlackColorStyleMenuMixin = CreateFromMixins(MenuStyleMixin);

function BlackColorStyleMenuMixin:Generate()
	local texture = self:AttachTexture();
	texture:SetAllPoints();

	texture:SetColorTexture(0, 0, 0, 1);
end

MenuStyle2Mixin = CreateFromMixins(MenuStyleMixin);

function MenuStyle2Mixin:Generate()
	local background = self:AttachTexture();
	background:SetAtlas("common-dropdown-c-bg");
	background:SetPoint("TOPLEFT", -17, 12);
	background:SetPoint("BOTTOMRIGHT", 17, -22);
end

function MenuStyle2Mixin:GetInset()
	return 3, 6, 3, 7; -- L, T, R, B
end

-- Accompanies the style of WowStyle2Dropdown
WowStyle2IconButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function WowStyle2IconButtonMixin:OnLoad()
	self:OnButtonStateChanged();

	local x, y = 2, -1;
	self:SetDisplacedRegions(x, y, self.Icon);
end

function WowStyle2IconButtonMixin:GetBackgroundAtlas()
	if self:IsEnabled() then
		if self:IsDownOver() then
			return "common-dropdown-c-button-pressedhover-2";
		elseif self:IsOver() then
			return "common-dropdown-c-button-hover-2";
		elseif self:IsDown() then
			return "common-dropdown-c-button-pressed-2";
		else
			return "common-dropdown-c-button";
		end
	end

	return "common-dropdown-c-button-disabled";
end

function WowStyle2IconButtonMixin:OnButtonStateChanged()
	self.Background:SetAtlas(self:GetBackgroundAtlas(), TextureKitConstants.UseAtlasSize);

	local icon = self:IsEnabled() and self.normalAtlas or self.disabledAtlas;
	self.Icon:SetAtlas(icon, TextureKitConstants.UseAtlasSize);
end