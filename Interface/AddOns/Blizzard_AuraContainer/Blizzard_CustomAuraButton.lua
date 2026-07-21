local _addonName, addonTable = ...;

local function RequireObjectType(requiredType)
	return function(object)
		if not object:IsObjectType(requiredType) then
			error(string.format("bad object '%s' in function call (expected object type '%s', got '%s')", object:GetDebugName(), requiredType, object:GetObjectType()));
		end
	end
end

local function GetValidatedForbiddenObjectTable(owner, inboundObject, ...)
	inboundObject = GetForbiddenObjectTable(inboundObject);

	if inboundObject:HasAccessConstraints() then
		error(string.format("bad object '%s' in function call (must not be an access-constrained object)", inboundObject:GetDebugName()));
	end

	local _isProtected, isProtectedExplicitly = inboundObject:IsProtected();
	if isProtectedExplicitly then
		error(string.format("bad object '%s' in function call (must not be an explicitly protected object)", inboundObject:GetDebugName()));
	end

	if not FlagsUtil.IsSet(inboundObject:GetForbiddenAspects(), owner:GetInheritableForbiddenAspects(Enum.ScriptObjectPropagationPath.Hierarchy)) then
		-- This can error when attempting to attach a region that isn't parented to an aura button.
		error(string.format("bad object '%s' in function call (must inherit all forbidden parent aspects from owner)", inboundObject:GetDebugName()));
	end

	if not FlagsUtil.IsSet(inboundObject:GetForbiddenAspects(), owner:GetInheritableForbiddenAspects(Enum.ScriptObjectPropagationPath.Layout)) then
		-- This can error when attempting to attach a region that isn't anchored to an aura button.
		error(string.format("bad object '%s' in function call (must inherit all forbidden layout aspects from owner)", inboundObject:GetDebugName()));
	end

	local function ApplyToForbiddenObject(validationFunc)
		validationFunc(inboundObject);
	end

	mapvalues(ApplyToForbiddenObject, ...);
	return inboundObject;
end

CustomAuraButtonSharedMixin = {};

function CustomAuraButtonSharedMixin:GetApplicationBar()
	return self.ApplicationBar;
end


function CustomAuraButtonSharedMixin:SetApplicationBar(statusBar, options)
	options = securecopy(options or {});

	self.ApplicationBar = GetValidatedForbiddenObjectTable(self, statusBar, RequireObjectType("StatusBar"));
	self.ApplicationBar.maxApplications = options.maxApplications;

	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearApplicationBar()
	self.ApplicationBar = nil;
end

function CustomAuraButtonSharedMixin:GetApplicationCount()
	return self.ApplicationCount;
end

local function AssertValidFormatter(formatter)
	if formatter ~= nil then
		-- If it's good enough for the C API, it's good enough for me!
		C_DurationUtil.CreateDuration():FormatElapsedDuration(formatter);
	end

	return formatter;
end

function CustomAuraButtonSharedMixin:SetApplicationCount(fontString, options)
	options = securecopy(options or {});

	self.ApplicationCount = GetValidatedForbiddenObjectTable(self, fontString, RequireObjectType("FontString"));
	self.ApplicationCount.formatter = AssertValidFormatter(options.formatter);
	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearApplicationCount()
	self.ApplicationCount = nil;
end

function CustomAuraButtonSharedMixin:GetAuraBorder()
	return self.AuraBorder;
end

function CustomAuraButtonSharedMixin:SetAuraBorder(texture, options)
	options = C_AuraContainerUtil.ProcessCustomAuraButtonBorderOptions(securecopy(options));
	texture = GetValidatedForbiddenObjectTable(self, texture, RequireObjectType("Texture"));

	texture:AddSecretAspect(Enum.SecretAspect.Alpha);
	texture:AddSecretAspect(Enum.SecretAspect.VertexColor);
	texture:AddSecretAspect(Enum.SecretAspect.Shown);

	self.AuraBorder = texture;
	self.AuraBorderOptions = options;

	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearAuraBorder()
	self.AuraBorder = nil;
end

function CustomAuraButtonSharedMixin:GetAuraSymbol()
	return self.AuraSymbol;
end

local DefaultAuraSymbolOptions = {
	showWhenHarmful = true,
	showWhenHelpful = false,
};

function CustomAuraButtonSharedMixin:SetAuraSymbol(fontString, options)
	options = CreateFromMixins(DefaultAuraSymbolOptions, securecopy(options or {}));

	self.AuraSymbol = GetValidatedForbiddenObjectTable(self, fontString, RequireObjectType("FontString"));
	self.AuraSymbol.showWhenHarmful = options.showWhenHarmful;
	self.AuraSymbol.showWhenHelpful = options.showWhenHelpful;

	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearAuraSymbol()
	self.AuraSymbol = nil;
end

function CustomAuraButtonSharedMixin:GetDurationCooldown()
	return self.DurationCooldown;
end

function CustomAuraButtonSharedMixin:SetDurationCooldown(cooldownFrame)
	self.DurationCooldown = GetValidatedForbiddenObjectTable(self, cooldownFrame, RequireObjectType("Cooldown"));
	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearDurationCooldown()
	self.DurationCooldown = nil;
end

function CustomAuraButtonSharedMixin:GetDurationText()
	return self.DurationText;
end

function CustomAuraButtonSharedMixin:SetDurationText(fontString, options)
	options = securecopy(options or {});

	self.DurationText = GetValidatedForbiddenObjectTable(self, fontString, RequireObjectType("FontString"));

	if not self.DurationTextBinding then
		self.DurationTextBinding = C_DurationUtil.CreateDurationTextBinding();
	else
		self.DurationTextBinding:SetToDefaults();
	end

	if options.formatter then
		self.DurationTextBinding:SetFormatter(options.formatter);
	elseif options.textFormat then
		self.DurationTextBinding:SetTextFormat(options.textFormat);
	else
		self.DurationTextBinding:SetFormatter(addonTable.DefaultAuraDurationFormatter);
	end

	if options.textColorCurve then
		self.DurationTextBinding:SetTextColorCurve(options.textColorCurve);
	end

	if options.timeModifier then
		self.DurationTextBinding:SetTimeModifier(options.timeModifier);
	end

	if options.updateInterval then
		self.DurationTextBinding:SetUpdateInterval(options.updateInterval);
	end

	self.DurationTextBinding:SetExpiredText(options.expiredText);
	self.DurationTextBinding:SetZeroDurationText(options.zeroDurationText);
	self.DurationTextBinding:SetFontString(self.DurationText);

	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearDurationText()
	self.DurationText = nil;
end

function CustomAuraButtonSharedMixin:GetDurationBar()
	return self.DurationBar;
end

function CustomAuraButtonSharedMixin:SetDurationBar(statusBar, options)
	options = securecopy(options or {});
	assert(options.interpolation == nil or EnumUtil.IsValid(Enum.StatusBarInterpolation, options.interpolation));
	assert(options.direction == nil or EnumUtil.IsValid(Enum.StatusBarTimerDirection, options.direction));

	self.DurationBar = GetValidatedForbiddenObjectTable(self, statusBar, RequireObjectType("StatusBar"));

	if options.interpolation then
		self.DurationBar.interpolation = options.interpolation;
	end

	if options.direction then
		self.DurationBar.direction = options.direction;
	end

	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearDurationBar()
	self.DurationBar = nil;
end

function CustomAuraButtonSharedMixin:GetIcon()
	return self.Icon;
end

function CustomAuraButtonSharedMixin:SetIcon(texture)
	self.Icon = GetValidatedForbiddenObjectTable(self, texture, RequireObjectType("Texture"));
	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearIcon()
	self.Icon = nil;
end

function CustomAuraButtonSharedMixin:GetSpellName()
	return self.SpellName;
end

function CustomAuraButtonSharedMixin:SetSpellName(fontString)
	self.SpellName = GetValidatedForbiddenObjectTable(self, fontString, RequireObjectType("FontString"));
	self:UpdateAuraDisplay();
end

function CustomAuraButtonSharedMixin:ClearSpellName()
	self.SpellName = nil;
end

CustomAuraButtonInboundMixin = CreateFromMixins(CustomAuraButtonSharedMixin);
CustomAuraButtonPrivateMixin = CreateFromMixins(AuraButtonPrivateMixin, CustomAuraButtonSharedMixin);

function CustomAuraButtonPrivateMixin:OnLoad_Intrinsic()
	AuraButtonPrivateMixin.OnLoad_Intrinsic(self);
end

function CustomAuraButtonPrivateMixin:OnAuraInstanceAssigned(unitToken, auraData)
	self:ApplyAuraInstance(unitToken, auraData)
end

function CustomAuraButtonPrivateMixin:OnAuraInstanceUpdated(unitToken, auraData)
	self:ApplyAuraInstance(unitToken, auraData);
end

function CustomAuraButtonPrivateMixin:OnAuraInstanceCleared()
	local unitToken, auraData = nil, nil;
	self:ApplyAuraInstance(unitToken, auraData);
end

function CustomAuraButtonPrivateMixin:ApplyApplicationBar(auraData)
	if self.ApplicationBar then
		local applications = auraData and auraData.applications or 0;
		local maxApplications = self.ApplicationBar.maxApplications;

		self.ApplicationBar:SetMinMaxValues(secretwrap(0, math.max(maxApplications, 1)));
		self.ApplicationBar:SetValue(secretwrap(applications));
	end
end

function CustomAuraButtonPrivateMixin:ApplyApplicationCount(auraData)
	if self.ApplicationCount then
		local text = "";

		if auraData then
			local formatter = self.ApplicationCount.formatter;
			local applications = auraData.applications;

			if formatter then
				text = formatter:FormatNumber(applications);
			elseif applications > 1 then
				text = applications;
			end
		end

		self.ApplicationCount:SetText(secretwrap(text));
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

local function GetCustomAuraBorderColor(options, unitToken, auraData)
	local dispelType = auraData.dispelName or "";
	local color;

	if options.customDispelColorMap then
		color = options.customDispelColorMap[dispelType];

		if color == nil then
			-- Supporting "" as a fallback for auras with no dispel type.
			color = options.customDispelColorMap[""];
		end
	end

	if options.customDispelColorCurve then
		color = C_UnitAuras.GetAuraDispelTypeColor(unitToken, auraData.auraInstanceID, options.customDispelColorCurve);
	end

	return color;
end

local function SetAuraBorderColor(auraBorder, options, unitToken, auraData)
	local color = GetCustomAuraBorderColor(options, unitToken, auraData);

	if color then
		auraBorder:SetVertexColor(color:GetRGBA());
	else
		AuraUtil.SetAuraBorderColor(auraBorder, auraData.dispelName);
	end
end

function CustomAuraButtonPrivateMixin:ApplyAuraBorder(unitToken, auraData)
	if self.AuraBorder then
		if ShouldShowDispelTypeForAura(self.AuraBorderOptions, auraData) then
			local style = self.AuraBorderOptions.style;

			if style == Enum.CustomAuraButtonBorderStyle.Atlas then
				AuraUtil.SetAuraBorderAtlas(self.AuraBorder, auraData.dispelName, self.AuraBorderOptions.showIcon);
			elseif style == Enum.CustomAuraButtonBorderStyle.Color then
				SetAuraBorderColor(self.AuraBorder, self.AuraBorderOptions, unitToken, auraData);
			end

			self.AuraBorder:Show();
		else
			self.AuraBorder:Hide();
		end
	end
end

function CustomAuraButtonPrivateMixin:ApplyAuraSymbol(auraData)
	if self.AuraSymbol then
		local dispelType = ShouldShowDispelTypeForAura(self.AuraSymbol, auraData) and auraData.dispelName or nil;

		-- SetAuraSymbol only conditionally sets secret text; we need this
		-- to be unconditional as it could be observed externally. Also make
		-- sure visibility is secret as a precaution.

		self.AuraSymbol:SetShown(secretwrap(false));
		self.AuraSymbol:SetText(secretwrap(""));

		AuraUtil.SetAuraSymbol(self.AuraSymbol, dispelType);
	end
end

function CustomAuraButtonPrivateMixin:HasAnyDurationDisplay()
	return (self.DurationCooldown or self.DurationText or self.DurationBar) ~= nil;
end

function CustomAuraButtonPrivateMixin:ApplyDurationCooldown(auraDuration)
	if self.DurationCooldown then
		local clearIfZero = false;
		self.DurationCooldown:SetCooldownFromDurationObject(auraDuration, clearIfZero);
	end
end

function CustomAuraButtonPrivateMixin:ApplyDurationText(auraDuration)
	if self.DurationTextBinding then
		self.DurationTextBinding:SetDuration(auraDuration);
		self.DurationTextBinding:SetEnabled(not auraDuration:IsZero());
	end
end

function CustomAuraButtonPrivateMixin:ApplyDurationBar(auraDuration)
	if self.DurationBar then
		self.DurationBar:SetTimerDuration(auraDuration, self.DurationBar.interpolation, self.DurationBar.direction);
	end
end

function CustomAuraButtonPrivateMixin:ApplyDuration(unitToken, auraData)
	if self:HasAnyDurationDisplay() then
		local auraDuration = C_DurationUtil.CreateDuration();

		if auraData and auraData.expirationTime > 0 then
			-- Avoiding the use of C_UnitAuras.GetAuraDuration as that API
			-- isn't equipped to handle private auras. Build it manually.
			auraDuration:SetTimeFromEnd(secretwrap(auraData.expirationTime, auraData.duration, auraData.timeMod));
		else
			auraDuration:SetTimeSpan(secretwrap(0, 0));
		end

		self:ApplyDurationCooldown(auraDuration);
		self:ApplyDurationText(auraDuration);
		self:ApplyDurationBar(auraDuration);
	end
end

function CustomAuraButtonPrivateMixin:ApplyIcon(auraData)
	if self.Icon then
		AuraContainerUtil.SetIconTextureForAura(self, self.Icon, auraData);
	end
end

function CustomAuraButtonPrivateMixin:ApplySpellName(auraData)
	if self.SpellName then
		AuraContainerUtil.SetSpellNameForAura(self, self.SpellName, auraData);
	end
end

function CustomAuraButtonPrivateMixin:ApplyVisibility(auraData)
	self:SetShown(secretwrap(auraData ~= nil));
end

function CustomAuraButtonPrivateMixin:ApplyAuraInstance(unitToken, auraData)
	self:ApplyApplicationBar(auraData);
	self:ApplyApplicationCount(auraData);
	self:ApplyAuraBorder(unitToken, auraData);
	self:ApplyAuraSymbol(auraData);
	self:ApplyDuration(unitToken, auraData);
	self:ApplyIcon(auraData);
	self:ApplySpellName(auraData);
	self:ApplyVisibility(auraData);
end

--[[override]] function CustomAuraButtonPrivateMixin:UpdateAuraDisplay()
	self:ApplyAuraInstance(self:GetAuraInstance());
end
