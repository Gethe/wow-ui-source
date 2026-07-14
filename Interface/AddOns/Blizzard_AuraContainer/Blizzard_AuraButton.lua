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

AuraButtonInboundMixin = CreateFromMixins(AuraButtonSharedMixin);
AuraButtonPrivateMixin = CreateFromMixins(AuraButtonSharedMixin);

function AuraButtonPrivateMixin:OnLoad_Intrinsic()
	self.auraData = nil;
	self.unitToken = nil;
	self.cancelAuraButtonsArray = nil;
end

function AuraButtonPrivateMixin:OnEnter_Intrinsic(_isFromMouseMotion)
	self:ShowTooltip();
end

function AuraButtonPrivateMixin:OnLeave_Intrinsic(_isFromMouseMotion)
	self:HideTooltip();
end

function AuraButtonPrivateMixin:OnUpdate_Intrinsic(_elapsedTime)
	self:UpdateTooltip();
end

function AuraButtonPrivateMixin:OnClick_Intrinsic(button, isDown)
	if not self:CanCancelAuraOnClick(button, isDown) then
		return;
	end

	local unitToken, auraData = self:GetAuraInstance();
	if unitToken and auraData and auraData.auraInstanceID then
		C_UnitAuras.CancelAuraByInstanceID(unitToken, auraData.auraInstanceID);
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

function AuraButtonPrivateMixin:GetAuraInstance()
	return self.unitToken, self.auraData;
end

function AuraButtonPrivateMixin:HasAuraInstance()
	return self.auraData ~= nil;
end

function AuraButtonPrivateMixin:SetAuraInstance(unitToken, auraData)
	self.unitToken = unitToken;
	self.auraData = auraData;
	self:OnAuraInstanceAssigned(unitToken, auraData);
end

function AuraButtonPrivateMixin:UpdateAuraInstance(unitToken, auraData)
	self.auraData = auraData;
	self:OnAuraInstanceUpdated(unitToken, auraData);
end

function AuraButtonPrivateMixin:ClearAuraInstance()
	if self.auraData ~= nil then
		self.unitToken = nil;
		self.auraData = nil;
		self:OnAuraInstanceCleared();
	end
end

function AuraButtonPrivateMixin:UpdateAuraDisplay()
	-- Override in a derived mixin to apply a full update to the aura.
end

function AuraButtonPrivateMixin:ShowTooltip()
	local unitToken, auraData = self:GetAuraInstance();

	if auraData then
		AuraButtonTooltip:AddForbiddenAspects(self:GetInheritableForbiddenAspects(Enum.ScriptObjectPropagationPath.Layout));
		AuraButtonTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
		RaiseFrameLevelByTwo(AuraButtonTooltip);
		self:PopulateTooltip(unitToken, auraData);
		self:SetOnUpdateMode(Enum.OnUpdateMode.RunWhenVisible);
	end
end

function AuraButtonPrivateMixin:PopulateTooltip(unitToken, auraData)
	if auraData.auraType == AuraContainerAuraDataType.Aura then
		AuraButtonTooltip:ShowAuraTooltip(unitToken, auraData);
	elseif auraData.auraType == AuraContainerAuraDataType.ItemEnchantment then
		AuraButtonTooltip:SetInventoryItem(unitToken, auraData.inventorySlot);
	end
end

function AuraButtonPrivateMixin:HideTooltip()
	AuraButtonTooltip:Hide();
	self:SetOnUpdateMode(Enum.OnUpdateMode.Disabled);
end

function AuraButtonPrivateMixin:UpdateTooltip()
	if AuraButtonTooltip:IsOwned(self) then
		self:PopulateTooltip(self:GetAuraInstance());
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
