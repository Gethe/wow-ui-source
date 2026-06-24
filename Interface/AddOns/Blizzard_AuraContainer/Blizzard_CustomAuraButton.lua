local _addonName, addonTbl = ...;

local function RequireObjectType(requiredType)
	return function(object)
		if not object:IsObjectType(requiredType) then
			error(string.format("bad object '%s' in function call (expected object type '%s', got '%s')", object:GetDebugName(), requiredType, object:GetObjectType()));
		end
	end
end

local function GetValidatedForbiddenObjectTable(owner, inboundObject, ...)
	inboundObject = GetForbiddenObjectTable(inboundObject);

	if inboundObject:IsForbidden() then
		error(string.format("bad object '%s' in function call (must not be a forbidden object)", inboundObject:GetDebugName()));
	end

	if not FlagsUtil.IsSet(inboundObject:GetForbiddenAspects(), owner:GetInheritableForbiddenAspects(Enum.ForbiddenAspectInheritance.Parent)) then
		-- This can error when attempting to attach a region that isn't parented to an aura button.
		error(string.format("bad object '%s' in function call (must inherit all forbidden parent aspects from owner)", inboundObject:GetDebugName()));
	end

	if not FlagsUtil.IsSet(inboundObject:GetForbiddenAspects(), owner:GetInheritableForbiddenAspects(Enum.ForbiddenAspectInheritance.Layout)) then
		-- This can error when attempting to attach a region that isn't anchored to an aura button.
		error(string.format("bad object '%s' in function call (must inherit all forbidden layout aspects from owner)", inboundObject:GetDebugName()));
	end

	local function ApplyToForbiddenObject(validationFunc)
		validationFunc(inboundObject);
	end

	mapvalues(ApplyToForbiddenObject, ...);
	return inboundObject;
end

local CustomAuraButtonPrivateMixin = CreateFromMixins(addonTbl.AuraButtonPrivateMixin);
addonTbl.CustomAuraButtonPrivateMixin = CustomAuraButtonPrivateMixin;

function CustomAuraButtonPrivateMixin:OnLoad_Intrinsic()
	addonTbl.AuraButtonPrivateMixin.OnLoad_Intrinsic(self);
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

local function ShouldShowDispelTypeForAura(auraBorder, auraData)
	if not auraData then
		return false;
	elseif auraData.isHarmful and not auraBorder.showWhenHarmful then
		return false;
	elseif auraData.isHelpful and not auraBorder.showWhenHelpful then
		return false;
	end

	return true;
end

function CustomAuraButtonPrivateMixin:ApplyAuraBorder(auraData)
	if self.AuraBorder then
		local dispelType = ShouldShowDispelTypeForAura(self.AuraBorder, auraData) and auraData.dispelName or nil;
		local style = self.AuraBorder.style;

		if style == AuraButtonBorderStyle.Atlas then
			AuraUtil.SetAuraBorderAtlas(self.AuraBorder, dispelType, self.AuraBorder.showIcon);
		elseif style == AuraButtonBorderStyle.Color then
			AuraUtil.SetAuraBorderColor(self.AuraBorder, dispelType);
		end

		self.AuraBorder:SetShown(dispelType ~= nil);
	end
end

function CustomAuraButtonPrivateMixin:ApplyAuraSymbol(auraData)
	if self.AuraSymbol then
		local dispelType = ShouldShowDispelTypeForAura(self.AuraBorder, auraData) and auraData.dispelName or nil;

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
		local auraDuration = auraData and C_UnitAuras.GetAuraDuration(unitToken, auraData.auraInstanceID) or nil;

		if not auraDuration then
			auraDuration = C_DurationUtil.CreateDuration();
			auraDuration:SetTimeSpan(secretwrap(0, 0));
		end

		self:ApplyDurationCooldown(auraDuration);
		self:ApplyDurationText(auraDuration);
		self:ApplyDurationBar(auraDuration);
	end
end

function CustomAuraButtonPrivateMixin:ApplyIcon(auraData)
	if self.Icon then
		local icon = auraData and auraData.icon or QUESTION_MARK_ICON;
		self.Icon:SetTexture(secretwrap(icon));
	end
end

function CustomAuraButtonPrivateMixin:ApplySpellName(auraData)
	if self.SpellName then
		local text = auraData and auraData.name or "";
		self.SpellName:SetText(secretwrap(text));
	end
end

function CustomAuraButtonPrivateMixin:ApplyVisibility(auraData)
	self:SetShown(secretwrap(auraData ~= nil));
end

function CustomAuraButtonPrivateMixin:ApplyAuraInstance(unitToken, auraData)
	self:ApplyApplicationCount(auraData);
	self:ApplyAuraBorder(auraData);
	self:ApplyAuraSymbol(auraData);
	self:ApplyDuration(unitToken, auraData);
	self:ApplyIcon(auraData);
	self:ApplySpellName(auraData);
	self:ApplyVisibility(auraData);
end

--[[override]] function CustomAuraButtonPrivateMixin:UpdateAuraDisplay()
	self:ApplyAuraInstance(self:GetAuraInstance());
end

local CustomAuraButtonInboundMixin = {};
addonTbl.CustomAuraButtonInboundMixin = CustomAuraButtonInboundMixin;

function CustomAuraButtonInboundMixin:GetApplicationCount()
	return self.ApplicationCount;
end

local function AssertValidFormatter(formatter)
	if formatter ~= nil then
		-- If it's good enough for the C API, it's good enough for me!
		C_DurationUtil.CreateDuration():FormatElapsedDuration(formatter);
	end

	return formatter;
end

function CustomAuraButtonInboundMixin:SetApplicationCount(fontString, options)
	self.ApplicationCount = GetValidatedForbiddenObjectTable(self, fontString, RequireObjectType("FontString"));
	self.ApplicationCount.formatter = AssertValidFormatter(options.formatter);
	self:UpdateAuraDisplay();
end

function CustomAuraButtonInboundMixin:ClearApplicationCount()
	self.ApplicationCount = nil;
end

function CustomAuraButtonInboundMixin:GetAuraBorder()
	return self.AuraBorder;
end

local DefaultAuraBorderOptions = {
	showIcon = true,
	showWhenHarmful = true,
	showWhenHelpful = false,
	style = AuraButtonBorderStyle.Atlas,
};

function CustomAuraButtonInboundMixin:SetAuraBorder(texture, options)
	options = CreateFromMixins(DefaultAuraBorderOptions, securecopy(options or {}));

	self.AuraBorder = GetValidatedForbiddenObjectTable(self, texture, RequireObjectType("Texture"));
	self.AuraBorder.showIcon = options.showIcon;
	self.AuraBorder.showWhenHarmful = options.showWhenHarmful;
	self.AuraBorder.showWhenHelpful = options.showWhenHelpful;
	self.AuraBorder.style = options.style;

	self:UpdateAuraDisplay();
end

function CustomAuraButtonInboundMixin:ClearAuraBorder()
	self.AuraBorder = nil;
end

function CustomAuraButtonInboundMixin:GetAuraSymbol()
	return self.AuraSymbol;
end

local DefaultAuraSymbolOptions = {
	showIcon = false,
	showWhenHarmful = true,
	showWhenHelpful = false,
	style = AuraButtonBorderStyle.Color,
};


function CustomAuraButtonInboundMixin:SetAuraSymbol(fontString, options)
	options = CreateFromMixins(DefaultAuraSymbolOptions, securecopy(options or {}));

	self.AuraSymbol = GetValidatedForbiddenObjectTable(self, fontString, RequireObjectType("FontString"));
	self.AuraSymbol.showWhenHarmful = options.showWhenHarmful;
	self.AuraSymbol.showWhenHelpful = options.showWhenHelpful;

	self:UpdateAuraDisplay();
end

function CustomAuraButtonInboundMixin:ClearAuraSymbol()
	self.AuraSymbol = nil;
end

function CustomAuraButtonInboundMixin:GetDurationCooldown()
	return self.DurationCooldown;
end

function CustomAuraButtonInboundMixin:SetDurationCooldown(cooldownFrame)
	self.DurationCooldown = GetValidatedForbiddenObjectTable(self, cooldownFrame, RequireObjectType("Cooldown"));
	self:UpdateAuraDisplay();
end

function CustomAuraButtonInboundMixin:ClearDurationCooldown()
	self.DurationCooldown = nil;
end

function CustomAuraButtonInboundMixin:GetDurationText()
	return self.DurationText;
end

function CustomAuraButtonInboundMixin:SetDurationText(fontString, options)
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
		self.DurationTextBinding:SetFormatter(addonTbl.DefaultAuraDurationFormatter);
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

function CustomAuraButtonInboundMixin:ClearDurationText()
	self.DurationText = nil;
end

function CustomAuraButtonInboundMixin:GetDurationBar()
	return self.DurationBar;
end

function CustomAuraButtonInboundMixin:SetDurationBar(statusBar, options)
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

function CustomAuraButtonInboundMixin:ClearDurationBar()
	self.DurationBar = nil;
end

function CustomAuraButtonInboundMixin:GetIcon()
	return self.Icon;
end

function CustomAuraButtonInboundMixin:SetIcon(texture)
	self.Icon = GetValidatedForbiddenObjectTable(self, texture, RequireObjectType("Texture"));
	self:UpdateAuraDisplay();
end

function CustomAuraButtonInboundMixin:ClearIcon()
	self.Icon = nil;
end

function CustomAuraButtonInboundMixin:GetSpellName()
	return self.SpellName;
end

function CustomAuraButtonInboundMixin:SetSpellName(fontString)
	self.SpellName = GetValidatedForbiddenObjectTable(self, fontString, RequireObjectType("FontString"));
	self:UpdateAuraDisplay();
end

function CustomAuraButtonInboundMixin:ClearSpellName()
	self.SpellName = nil;
end

ApplySecureDelegatesToTable(CustomAuraButtonInboundMixin);
