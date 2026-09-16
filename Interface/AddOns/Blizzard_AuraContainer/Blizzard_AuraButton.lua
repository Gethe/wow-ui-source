AuraButtonSharedMixin = {};

local function ParseCancelAuraButtons(cancelAuraButtons)
	if cancelAuraButtons == nil then
		return nil;
	end

	cancelAuraButtons = securecopy(cancelAuraButtons);

	assert(type(cancelAuraButtons) == "string", "cancelAuraButtons must be a string or nil.");

	local parsedButtonArray = {};
	for clickToken in string.gmatch(cancelAuraButtons, "[^,%s]+") do
		table.insert(parsedButtonArray, clickToken);
	end

	assert(#parsedButtonArray > 0, "cancelAuraButtons must contain at least one click token when set.");

	return parsedButtonArray;
end

function AuraButtonSharedMixin:SetCancelAuraButtons(cancelAuraButtons)
	self.cancelAuraButtonsArray = ParseCancelAuraButtons(cancelAuraButtons);

	if self.cancelAuraButtonsArray ~= nil then
		self:RegisterForClicks(unpack(self.cancelAuraButtonsArray));
	else
		self:RegisterForClicks();
	end
end

function AuraButtonSharedMixin:GetTooltipAnchorPoint()
	return self.tooltipAnchorPoint, self.tooltipOffsetX, self.tooltipOffsetY;
end

function AuraButtonSharedMixin:SetTooltipAnchorPoint(point, offsetX, offsetY)
	local validAnchorPointNames =  {
		ANCHOR_LEFT = true,
		ANCHOR_RIGHT = true,
		ANCHOR_BOTTOMLEFT = true,
		ANCHOR_BOTTOM = true,
		ANCHOR_BOTTOMRIGHT = true,
		ANCHOR_TOPLEFT = true,
		ANCHOR_TOP = true,
		ANCHOR_TOPRIGHT = true,
		ANCHOR_CURSOR = true,
		ANCHOR_NONE = true,
		ANCHOR_PRESERVE = true,
		ANCHOR_CURSOR_LEFT = true,
		ANCHOR_CURSOR_RIGHT = true,
	};

	assert(validAnchorPointNames[point], "point must be a valid tooltip anchor point name");
	assert(offsetX == nil or type(offsetX) == "number", "offsetX must be a number or nil");
	assert(offsetY == nil or type(offsetY) == "number", "offsetY must be a number or nil");

	self.tooltipAnchorPoint = point;
	self.tooltipOffsetX = offsetX or 0;
	self.tooltipOffsetY = offsetY or 0;
end

function AuraButtonSharedMixin:ShouldHideTooltipInCombat()
	return self.tooltipHideInCombat;
end

function AuraButtonSharedMixin:SetHideTooltipInCombat(hideInCombat)
	self.tooltipHideInCombat = (hideInCombat == true);
end

AuraButtonInboundMixin = CreateFromMixins(AuraButtonSharedMixin);
AuraButtonPrivateMixin = CreateFromMixins(AuraButtonSharedMixin);

function AuraButtonPrivateMixin:OnLoad_Intrinsic()
	self.auraData = nil;
	self.auraDuration = C_DurationUtil.CreateDuration();
	self.unitToken = nil;
	self.cancelAuraButtonsArray = nil;
end

function AuraButtonPrivateMixin:OnEnter_Intrinsic(_isFromMouseMotion)
	if self:ShouldShowTooltip() then
		self:ShowTooltip();
	end
end

function AuraButtonPrivateMixin:OnLeave_Intrinsic(_isFromMouseMotion)
	self:HideTooltip();
end

function AuraButtonPrivateMixin:OnClick_Intrinsic(button, isDown)
	if not self:CanCancelAuraOnClick(button, isDown) then
		return;
	end

	local unitToken, auraData = self:GetAuraInstance();

	if auraData then
		if auraData.auraType == AuraContainerAuraDataType.Aura then
			C_UnitAuras.CancelAuraByInstanceID(unitToken, auraData.auraInstanceID);
		elseif auraData.auraType == AuraContainerAuraDataType.ItemEnchantment then
			C_PaperDollInfo.CancelTemporaryEnchantment(auraData.inventorySlot);
		end
	end
end

function AuraButtonPrivateMixin:OnAuraInstanceAssigned(_unitToken, _auraData)
	-- Override in a derived mixin to be notified when this button should set
	-- up display for a new or potentially fully-updated aura instance.
end

function AuraButtonPrivateMixin:OnAuraInstanceUpdated(_unitToken, _auraData)
	-- Override in a derived mixin to be notified when this button should
	-- update its display for a pre-existing aura instance.
end

function AuraButtonPrivateMixin:OnAuraInstanceCleared()
	-- Override in a derived mixin to be notified when this button should no
	-- longer display an aura instance.
end

function AuraButtonPrivateMixin:GetAuraDuration()
	return self.auraDuration;
end

function AuraButtonPrivateMixin:GetAuraInstance()
	return self.unitToken, self.auraData;
end

function AuraButtonPrivateMixin:HasAuraInstance()
	return self.auraData ~= nil;
end

function AuraButtonPrivateMixin:SetAuraInstance(unitToken, auraData)
	self.unitToken = unitToken;
	self.auraData = auraData;
	self:UpdateAuraDuration();
	self:OnAuraInstanceAssigned(unitToken, auraData);
end

function AuraButtonPrivateMixin:UpdateAuraInstance(unitToken, auraData)
	self.auraData = auraData;
	self:UpdateAuraDuration();
	self:OnAuraInstanceUpdated(unitToken, auraData);
end

function AuraButtonPrivateMixin:ClearAuraInstance()
	if self.auraData ~= nil then
		self.unitToken = nil;
		self.auraData = nil;
		self:UpdateAuraDuration();
		self:OnAuraInstanceCleared();
	end
end

function AuraButtonPrivateMixin:UpdateAuraDuration()
	-- Manually configuring duration objects here rather than using C_UnitAuras
	-- APIs because private auras don't support that API, and we need this to
	-- work with "fake" auras such as temporary item enchantments. We also
	-- want the identity of the duration object to be stable to prevent
	-- information leak on aura reassignment.

	local auraData = self.auraData;
	local auraDuration = self.auraDuration;

	-- Expiration time can be nil in some test cases.
	if auraData and auraData.expirationTime and auraData.expirationTime > 0 then
		auraDuration:SetTimeFromEnd(secretwrap(auraData.expirationTime, auraData.duration, auraData.timeMod));
	else
		auraDuration:SetTimeSpan(secretwrap(0, 0));
	end
end

function AuraButtonPrivateMixin:UpdateAuraDisplay()
	-- Override in a derived mixin to apply a full update to the aura.
end

function AuraButtonPrivateMixin:ShouldShowTooltip()
	if self:ShouldHideTooltipInCombat() and UnitAffectingCombat("player") then
		return false;
	end

	return true;
end

function AuraButtonPrivateMixin:ShowTooltip()
	local tooltip = AuraContainerUtil.GetDefaultTooltip();
	local unitToken, auraData = self:GetAuraInstance();

	if auraData then
		tooltip:AddForbiddenAspects(self:GetInheritableForbiddenAspects(Enum.ScriptObjectPropagationPath.Layout));
		tooltip:SetOwner(self, self:GetTooltipAnchorPoint());
		-- This is presently required because GetOwner returns nil for the
		-- case of aura buttons that are marked as hideFromGlobalEnv="true",
		-- such as target frame auras.
		tooltip.UpdateTooltip = GenerateFlatClosure(self.UpdateTooltip, self);
		RaiseFrameLevelByTwo(tooltip);

		self:PopulateTooltip(tooltip, unitToken, auraData);
	end
end

function AuraButtonPrivateMixin:PopulateTooltip(tooltip, unitToken, auraData)
	if auraData.auraType == AuraContainerAuraDataType.Aura then
		tooltip:ShowAuraTooltip(unitToken, auraData);
	elseif auraData.auraType == AuraContainerAuraDataType.ItemEnchantment then
		tooltip:SetInventoryItem(unitToken, auraData.inventorySlot);
	end
end

function AuraButtonPrivateMixin:HideTooltip()
	local tooltip = AuraContainerUtil.GetDefaultTooltip();
	tooltip.UpdateTooltip = nil;
	tooltip:Hide();
end

function AuraButtonPrivateMixin:UpdateTooltip()
	local tooltip = AuraContainerUtil.GetDefaultTooltip();

	if tooltip:IsOwned(self) then
		if self:ShouldShowTooltip() then
			self:PopulateTooltip(tooltip, self:GetAuraInstance());
		else
			self:HideTooltip();
		end
	end
end

function AuraButtonPrivateMixin:CanCancelAuraOnClick(button, isDown)
	if self.cancelAuraButtonsArray == nil then
		return false;
	end

	local clickToken = string.format("%s%s", button, isDown and "Down" or "Up");
	for index = 1, #self.cancelAuraButtonsArray do
		if self.cancelAuraButtonsArray[index] == clickToken then
			return true;
		end
	end

	return false;
end

AuraButtonTooltipMixin = CreateFromMixins(PrivateAurasTooltipMixin);

function AuraButtonTooltipMixin:OnUpdate(elapsedTime)
	if not GameTooltip_IsUpdateNeeded(self, elapsedTime) then
		return;
	end

	local owner = self:GetOwner();
	owner = owner and GetForbiddenObjectTable(owner) or nil;

	if owner and owner.UpdateTooltip then
		owner:UpdateTooltip();
	elseif self.UpdateTooltip then
		self:UpdateTooltip();
	elseif self.shouldRefreshData then
		self:RefreshData();
	end
end
