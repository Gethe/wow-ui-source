local _addonName, addonTable = ...;

local function PackDisplayElement(element, options)
	return { element = element, options = options };
end

local function UnpackDisplayElement(displayElement)
	if displayElement then
		return displayElement.element, displayElement.options;
	end
end

local function ExportDisplayElement(displayElement)
	local element, options = UnpackDisplayElement(displayElement);
	return element, securecopy(options);
end

local function GetStatusBarInterpolationForUpdateMode(interpolation, updateMode)
	if updateMode == Enum.CustomAuraButtonUpdateMode.Update then
		return interpolation;
	else
		return Enum.StatusBarInterpolation.Immediate;
	end
end

local function RequireObjectType(requiredType)
	return function(object)
		if not object:IsObjectType(requiredType) then
			error(string.format("bad object '%s' in function call (expected object type '%s', got '%s')", object:GetDebugName(), requiredType, object:GetObjectType()));
		end
	end
end

CustomAuraButtonSharedMixin = {};

function CustomAuraButtonSharedMixin:GetApplicationBar()
	return ExportDisplayElement(self.applicationBar);
end

function CustomAuraButtonSharedMixin:SetApplicationBar(statusBar, options)
	AuraContainerUtil.ValidateInboundScriptObject(statusBar, self, RequireObjectType("StatusBar"));
	options = C_AuraContainerUtil.ProcessCustomAuraButtonApplicationBarOptions(securecopy(options) or {});

	statusBar = AuraContainerUtil.InitializeInboundScriptObject(statusBar);
	statusBar:AddSecretAspect(Enum.SecretAspect.BarValue);

	self.applicationBar = PackDisplayElement(statusBar, options);
	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearApplicationBar()
	self.applicationBar = nil;
end

function CustomAuraButtonSharedMixin:GetApplicationCount()
	return ExportDisplayElement(self.applicationCount);
end

function CustomAuraButtonSharedMixin:SetApplicationCount(fontString, options)
	AuraContainerUtil.ValidateInboundScriptObject(fontString, self, RequireObjectType("FontString"));
	options = C_AuraContainerUtil.ProcessCustomAuraButtonApplicationCountOptions(securecopy(options));

	fontString = AuraContainerUtil.InitializeInboundScriptObject(fontString);
	fontString:AddSecretAspect(Enum.SecretAspect.Text);
	fontString:AddSecretAspect(Enum.SecretAspect.Shown);

	self.applicationCount = PackDisplayElement(fontString, options);
	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearApplicationCount()
	self.applicationCount = nil;
end

function CustomAuraButtonSharedMixin:GetDispelTypeTextureCount()
	return #self.dispelTypeTextures;
end

function CustomAuraButtonSharedMixin:GetDispelTypeTexture(index)
	local dispelTypeTextures = self.dispelTypeTextures;
	return ExportDisplayElement(dispelTypeTextures[index]);
end

function CustomAuraButtonSharedMixin:AddDispelTypeTexture(texture, options)
	AuraContainerUtil.ValidateInboundScriptObject(texture, self, RequireObjectType("Texture"));
	options = C_AuraContainerUtil.ProcessCustomAuraButtonDispelTypeTextureOptions(securecopy(options));

	texture = AuraContainerUtil.InitializeInboundScriptObject(texture);
	texture:AddSecretAspect(Enum.SecretAspect.Alpha);
	texture:AddSecretAspect(Enum.SecretAspect.VertexColor);
	texture:AddSecretAspect(Enum.SecretAspect.TexCoords);
	texture:AddSecretAspect(Enum.SecretAspect.Shown);

	table.insert(self.dispelTypeTextures, PackDisplayElement(texture, options));

	self:UpdateAuraDisplay();

	local index = #self.dispelTypeTextures;
	return index;
end

function CustomAuraButtonSharedMixin:RemoveDispelTypeTexture(index)
	local dispelTypeTextures = self.dispelTypeTextures;

	if dispelTypeTextures[index] then
		table.remove(dispelTypeTextures, index);
		self:UpdateAuraDisplay();
	end
end

function CustomAuraButtonSharedMixin:ClearDispelTypeTextures()
	self.dispelTypeTextures = {};
end

function CustomAuraButtonSharedMixin:GetDispelTypeText()
	return ExportDisplayElement(self.dispelTypeText);
end

function CustomAuraButtonSharedMixin:SetDispelTypeText(fontString, options)
	AuraContainerUtil.ValidateInboundScriptObject(fontString, self, RequireObjectType("FontString"));
	options = C_AuraContainerUtil.ProcessCustomAuraButtonDispelTypeTextOptions(securecopy(options));

	fontString = AuraContainerUtil.InitializeInboundScriptObject(fontString);
	fontString:AddSecretAspect(Enum.SecretAspect.Text);
	fontString:AddSecretAspect(Enum.SecretAspect.Shown);

	self.dispelTypeText = PackDisplayElement(fontString, options);
	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearDispelTypeText()
	self.dispelTypeText = nil;
end

function CustomAuraButtonSharedMixin:GetDurationCooldown()
	return ExportDisplayElement(self.durationCooldown);
end

function CustomAuraButtonSharedMixin:SetDurationCooldown(cooldown)
	AuraContainerUtil.ValidateInboundScriptObject(cooldown, self, RequireObjectType("Cooldown"));

	cooldown = AuraContainerUtil.InitializeInboundScriptObject(cooldown);
	cooldown:AddSecretAspect(Enum.SecretAspect.Cooldown);
	cooldown:AddSecretAspect(Enum.SecretAspect.Shown);

	self.durationCooldown = PackDisplayElement(cooldown);
	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearDurationCooldown()
	self.durationCooldown = nil;
end

function CustomAuraButtonSharedMixin:GetDurationText()
	return ExportDisplayElement(self.durationText);
end

function CustomAuraButtonSharedMixin:SetDurationText(fontString, options)
	AuraContainerUtil.ValidateInboundScriptObject(fontString, self, RequireObjectType("FontString"));
	options = C_AuraContainerUtil.ProcessCustomAuraButtonDurationTextOptions(securecopy(options));

	fontString = AuraContainerUtil.InitializeInboundScriptObject(fontString);
	fontString:AddSecretAspect(Enum.SecretAspect.Text);
	fontString:AddSecretAspect(Enum.SecretAspect.Alpha);
	fontString:AddSecretAspect(Enum.SecretAspect.VertexColor);

	local binding = self:GetDurationTextBinding();

	if options.binding then
		binding:Assign(options.binding);
	else
		binding:SetToDefaults();
		binding:SetFormatter(addonTable.DefaultAuraDurationFormatter);
	end

	binding:SetFontString(fontString);
	binding:SetDuration(self:GetAuraDuration());

	if options.textFormat then
		binding:SetTextFormat(options.textFormat.formatString, options.textFormat.components);
	elseif options.textFormatter then
		binding:SetFormatter(options.textFormatter);
	end

	if options.textColor then
		binding:SetTextColorCurve(options.textColor.curve, options.textColor.property);
	end

	-- Intentionally not preserving options for now; the options here are used
	-- as a convenience to build a binding. We could export them if this changes.
	self.durationText = PackDisplayElement(fontString);
	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearDurationText()
	self:GetDurationTextBinding():SetEnabled(false);
	self.durationText = nil;
end

function CustomAuraButtonSharedMixin:GetDurationBar()
	return ExportDisplayElement(self.durationBar);
end

function CustomAuraButtonSharedMixin:SetDurationBar(statusBar, options)
	AuraContainerUtil.ValidateInboundScriptObject(statusBar, self, RequireObjectType("StatusBar"));
	options = C_AuraContainerUtil.ProcessCustomAuraButtonDurationBarOptions(securecopy(options));

	statusBar = AuraContainerUtil.InitializeInboundScriptObject(statusBar);
	statusBar:AddSecretAspect(Enum.SecretAspect.BarValue);

	self.durationBar = PackDisplayElement(statusBar, options);
	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearDurationBar()
	self.durationBar = nil;
end

function CustomAuraButtonSharedMixin:GetIcon()
	return ExportDisplayElement(self.icon);
end

function CustomAuraButtonSharedMixin:SetIcon(texture)
	AuraContainerUtil.ValidateInboundScriptObject(texture, self, RequireObjectType("Texture"));

	texture = AuraContainerUtil.InitializeInboundScriptObject(texture);

	self.icon = PackDisplayElement(texture);
	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearIcon()
	self.icon = nil;
end

function CustomAuraButtonSharedMixin:GetSpellName()
	return ExportDisplayElement(self.spellName);
end

function CustomAuraButtonSharedMixin:SetSpellName(fontString)
	AuraContainerUtil.ValidateInboundScriptObject(fontString, self, RequireObjectType("FontString"));

	fontString = AuraContainerUtil.InitializeInboundScriptObject(fontString);
	fontString:AddSecretAspect(Enum.SecretAspect.Text);
	fontString:AddSecretAspect(Enum.SecretAspect.Shown);

	self.spellName = PackDisplayElement(fontString);
	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearSpellName()
	self.spellName = nil;
end

-- Deprecated aliases to match PTR naming; will be removed after 12.1.

function CustomAuraButtonSharedMixin:GetAuraBorder()
	return self:GetDispelTypeTexture(1);
end

function CustomAuraButtonSharedMixin:SetAuraBorder(texture, options)
	self:ClearDispelTypeTextures();
	self:AddDispelTypeTexture(texture, options);
end

function CustomAuraButtonSharedMixin:ClearAuraBorder()
	self:ClearDispelTypeTextures();
end

CustomAuraButtonSharedMixin.GetAuraSymbol = CustomAuraButtonSharedMixin.GetDispelTypeText;
CustomAuraButtonSharedMixin.SetAuraSymbol = CustomAuraButtonSharedMixin.SetDispelTypeText;
CustomAuraButtonSharedMixin.ClearAuraSymbol = CustomAuraButtonSharedMixin.ClearDispelTypeText;

CustomAuraButtonInboundMixin = CreateFromMixins(CustomAuraButtonSharedMixin);
CustomAuraButtonPrivateMixin = CreateFromMixins(AuraButtonPrivateMixin, CustomAuraButtonSharedMixin);

function CustomAuraButtonPrivateMixin:OnLoad_Intrinsic()
	AuraButtonPrivateMixin.OnLoad_Intrinsic(self);

	self.dispelTypeTextures = {};

	-- Retain the duration text binding across reconfiguration; replacing it
	-- would require explicitly disabling the previous active binding.
	self.durationTextBinding = C_DurationUtil.CreateDurationTextBinding();
end

function CustomAuraButtonPrivateMixin:OnAuraInstanceAssigned(unitToken, auraData)
	self:ApplyAuraInstance(unitToken, auraData, Enum.CustomAuraButtonUpdateMode.Assignment);
end

function CustomAuraButtonPrivateMixin:OnAuraInstanceUpdated(unitToken, auraData)
	self:ApplyAuraInstance(unitToken, auraData, Enum.CustomAuraButtonUpdateMode.Update);
end

function CustomAuraButtonPrivateMixin:OnAuraInstanceCleared()
	local unitToken, auraData = nil, nil;
	self:ApplyAuraInstance(unitToken, auraData, Enum.CustomAuraButtonUpdateMode.Assignment);
end

function CustomAuraButtonPrivateMixin:GetDurationTextBinding()
	return self.durationTextBinding;
end

function CustomAuraButtonPrivateMixin:ApplyApplicationBar(_unitToken, auraData, updateMode)
	local statusBar, options = UnpackDisplayElement(self.applicationBar);

	if statusBar then
		local applications = auraData and auraData.applications or 0;
		local maxApplications = options.maxApplications;
		local interpolation = GetStatusBarInterpolationForUpdateMode(options.interpolation, updateMode);

		statusBar:SetMinMaxValues(0, math.max(maxApplications, 1));
		statusBar:SetValue(applications, interpolation);
	end
end

function CustomAuraButtonPrivateMixin:ApplyApplicationCount(_unitToken, auraData)
	local fontString, options = UnpackDisplayElement(self.applicationCount);

	if fontString then
		local text = "";

		if auraData then
			local formatter = options.formatter;
			local applications = auraData.applications;

			if formatter then
				text = formatter:FormatNumber(applications);
			elseif applications > 1 then
				text = applications;
			end
		end

		fontString:SetText(text);
	end
end

local function ShouldShowDispelTypeForAura(options, auraData)
	if not auraData then
		return false;
	elseif auraData.isHarmful and not options.showWhenHarmful then
		return false;
	elseif auraData.isHelpful and not options.showWhenHelpful then
		return false;
	elseif auraData.dispelName == nil and not options.showWithoutDispelType then
		return false;
	end

	return true;
end

local function GetDispelTypeMapKey(auraData)
	return auraData.dispelName or "None";
end

local function GetCustomDispelTypeTextureAsset(options, auraData)
	local assetMap = options.customDispelAssetMap;
	return assetMap and assetMap[GetDispelTypeMapKey(auraData)];
end

local function GetCustomDispelTypeTextureColor(options, unitToken, auraData)
	local colorMap = options.customDispelColorMap;
	local color = colorMap and colorMap[GetDispelTypeMapKey(auraData)];

	if options.customDispelColorCurve then
		color = C_UnitAuras.GetAuraDispelTypeColor(unitToken, auraData.auraInstanceID, options.customDispelColorCurve);
	end

	return color;
end

local function ApplyDispelTypeTextureAsset(texture, customAsset)
	texture:ResetTexCoord();

	if customAsset ~= nil then
		if not CheckSetAtlas(texture, customAsset.asset, customAsset.useAtlasSize) then
			texture:SetTexture(customAsset.asset);

			local texCoords = customAsset.texCoords;
			if texCoords then
				texture:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom);
			end
		end
	else
		-- Explicit wrapping here as we didn't add a method to force secret
		-- values on script objects (only aspects).
		texture:SetTexture(secretwrap(nil));
	end
end

local function ApplyDispelTypeTextureStyle(texture, options, auraData)
	local style = options.style;

	if style == Enum.CustomAuraButtonDispelTypeTextureStyle.Border then
		local showIcon = false;
		AuraUtil.SetAuraBorderAtlas(texture, auraData.dispelName, showIcon);
		texture:SetVertexColor(1, 1, 1, 1);
	elseif style == Enum.CustomAuraButtonDispelTypeTextureStyle.BorderWithIcon then
		local showIcon = true;
		AuraUtil.SetAuraBorderAtlas(texture, auraData.dispelName, showIcon);
		texture:SetVertexColor(1, 1, 1, 1);
	elseif style == Enum.CustomAuraButtonDispelTypeTextureStyle.Icon then
		AuraUtil.SetAuraDispelTypeIcon(texture, auraData.dispelName);
		texture:SetVertexColor(1, 1, 1, 1);
	elseif style == Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset then
		AuraUtil.SetAuraBorderColor(texture, auraData.dispelName);
	elseif style == Enum.CustomAuraButtonDispelTypeTextureStyle.CustomAsset then
		local customAsset = secretwrap(GetCustomDispelTypeTextureAsset(options, auraData));
		ApplyDispelTypeTextureAsset(texture, customAsset);
		texture:SetVertexColor(1, 1, 1, 1);
	end
end

local function ApplyCustomDispelTypeTextureColor(texture, options, unitToken, auraData)
	local color = GetCustomDispelTypeTextureColor(options, unitToken, auraData);

	if color then
		texture:SetVertexColor(color:GetRGBA());
	end
end

local function ApplyDispelTypeTexture(dispelTypeTexture, unitToken, auraData)
	local texture, options = UnpackDisplayElement(dispelTypeTexture);

	if ShouldShowDispelTypeForAura(options, auraData) then
		ApplyDispelTypeTextureStyle(texture, options, auraData);
		ApplyCustomDispelTypeTextureColor(texture, options, unitToken, auraData);
		texture:Show();
	else
		texture:Hide();
	end
end

function CustomAuraButtonPrivateMixin:ApplyDispelTypeTextures(unitToken, auraData)
	for _index, dispelTypeTexture in ipairs(self.dispelTypeTextures) do
		ApplyDispelTypeTexture(dispelTypeTexture, unitToken, auraData);
	end
end

local function GetCustomDispelTypeText(options, auraData)
	if options.customDispelTextMap then
		return options.customDispelTextMap[GetDispelTypeMapKey(auraData)];
	end
end

function CustomAuraButtonPrivateMixin:ApplyDispelTypeText(_unitToken, auraData)
	local fontString, options = UnpackDisplayElement(self.dispelTypeText);

	if fontString then
		if ShouldShowDispelTypeForAura(options, auraData) then
			local customText = GetCustomDispelTypeText(options, auraData);

			if customText ~= nil then
				fontString:SetText(customText);
				fontString:Show();
			else
				AuraUtil.SetAuraSymbol(fontString, auraData.dispelName);
			end
		else
			fontString:SetText("");
			fontString:Hide();
		end
	end
end

function CustomAuraButtonPrivateMixin:HasAnyDurationDisplay()
	return (self.durationCooldown or self.durationText or self.durationBar) ~= nil;
end

function CustomAuraButtonPrivateMixin:ApplyDurationCooldown(_unitToken, _auraData, auraDuration)
	local cooldown = UnpackDisplayElement(self.durationCooldown);

	if cooldown then
		local clearIfZero = false;
		cooldown:SetCooldownFromDurationObject(auraDuration, clearIfZero);
	end
end

function CustomAuraButtonPrivateMixin:ApplyDurationText(_unitToken, _auraData, auraDuration)
	if self.durationText then
		local binding = self:GetDurationTextBinding();
		binding:SetDuration(auraDuration);
		binding:SetEnabled(not auraDuration:IsZero());
	end
end

function CustomAuraButtonPrivateMixin:ApplyDurationBar(_unitToken, _auraData, auraDuration, updateMode)
	local statusBar, options = UnpackDisplayElement(self.durationBar);

	if statusBar then
		local interpolation = GetStatusBarInterpolationForUpdateMode(options.interpolation, updateMode);

		statusBar:SetTimerDuration(auraDuration, interpolation, options.direction);
	end
end

function CustomAuraButtonPrivateMixin:ApplyDuration(unitToken, auraData, updateMode)
	if self:HasAnyDurationDisplay() then
		local auraDuration = self:GetAuraDuration();
		self:ApplyDurationCooldown(unitToken, auraData, auraDuration);
		self:ApplyDurationText(unitToken, auraData, auraDuration);
		self:ApplyDurationBar(unitToken, auraData, auraDuration, updateMode);
	end
end

function CustomAuraButtonPrivateMixin:ApplyIcon(_unitToken, auraData)
	local texture = UnpackDisplayElement(self.icon);

	if texture then
		AuraContainerUtil.SetIconTextureForAura(self, texture, auraData);
	end
end

function CustomAuraButtonPrivateMixin:ApplySpellName(_unitToken, auraData)
	local fontString = UnpackDisplayElement(self.spellName);

	if fontString then
		AuraContainerUtil.SetSpellNameForAura(self, fontString, auraData);
	end
end

function CustomAuraButtonPrivateMixin:ApplyVisibility(_unitToken, auraData)
	self:SetShown(secretwrap(auraData ~= nil));
end

function CustomAuraButtonPrivateMixin:ApplyAuraInstance(unitToken, auraData, updateMode)
	self:ApplyApplicationBar(unitToken, auraData, updateMode);
	self:ApplyApplicationCount(unitToken, auraData);
	self:ApplyDispelTypeTextures(unitToken, auraData);
	self:ApplyDispelTypeText(unitToken, auraData);
	self:ApplyDuration(unitToken, auraData, updateMode);
	self:ApplyIcon(unitToken, auraData);
	self:ApplySpellName(unitToken, auraData);
	self:ApplyVisibility(unitToken, auraData);
end

--[[override]] function CustomAuraButtonPrivateMixin:UpdateAuraDisplay()
	local unitToken, auraData = self:GetAuraInstance();
	self:ApplyAuraInstance(unitToken, auraData, Enum.CustomAuraButtonUpdateMode.Update);
end
