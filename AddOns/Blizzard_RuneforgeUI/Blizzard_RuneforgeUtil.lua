
RuneforgeEffectOwnerMixin = {};

function RuneforgeEffectOwnerMixin:GetRuneforgeFrame()
	return self;
end

function RuneforgeEffectOwnerMixin:AddEffectData(effectKey, effectID, effectTarget, effectLevel)
	self[effectKey] = { effectID = effectID, effectTarget = effectTarget, effectLevel = effectLevel };
end

function RuneforgeEffectOwnerMixin:GetFrameFromEffectTarget(effectTarget)
	if effectTarget == RuneforgeUtil.EffectTarget.ItemSlot then
		return self, self:GetRuneforgeFrame().CraftingFrame.BaseItemSlot;
	elseif effectTarget == RuneforgeUtil.EffectTarget.ReverseItemSlot then
		return self:GetRuneforgeFrame().CraftingFrame.BaseItemSlot, self;
	elseif effectTarget == RuneforgeUtil.EffectTarget.None then
		return self, nil;
	else
		error("Unknown effect target: "..effectTarget);
	end
end

function RuneforgeEffectOwnerMixin:SetEffectShown(effectKey, shown)
	local effectData = self[effectKey];
	local controller = effectData.controller;
	if shown and not controller then
		local source, target = self:GetFrameFromEffectTarget(effectData.effectTarget);
		effectData.controller = self:GetRuneforgeFrame():AddEffect(effectData.effectLevel, effectData.effectID, source, target);
	elseif not shown and controller then
		controller:CancelEffect();
		effectData.controller = nil;
	end
end


RuneforgeSystemMixin = CreateFromMixins(RuneforgeEffectOwnerMixin);

local RefreshEventNames = {
	"BaseItemChanged",
	"PowerSelected",
	"ModifiersChanged",
};

function RuneforgeSystemMixin:GetRuneforgeFrame()
	return self:GetParent():GetParent();
end

function RuneforgeSystemMixin:IsRuneforgeCrafting()
	return self:GetRuneforgeFrame():IsRuneforgeCrafting();
end

function RuneforgeSystemMixin:IsRuneforgeUpgrading()
	return self:GetRuneforgeFrame():IsRuneforgeUpgrading();
end

function RuneforgeSystemMixin:RegisterRefreshMethod(refreshMethod)
	local runeforgeFrame = self:GetRuneforgeFrame();
	for i, eventName in ipairs(RefreshEventNames) do
		runeforgeFrame:RegisterCallback(RuneforgeFrameMixin.Event[eventName], GenerateClosure(refreshMethod, self, eventName), self);
	end
end

function RuneforgeSystemMixin:UnregisterRefreshMethod()
	local runeforgeFrame = self:GetRuneforgeFrame();
	for i, eventName in ipairs(RefreshEventNames) do
		runeforgeFrame:UnregisterCallback(RuneforgeFrameMixin.Event[eventName], self);
	end
end


RuneforgeUtil = {};

RuneforgeUtil.EffectTarget = {
	None = 1,
	ItemSlot = 2,
	ReverseItemSlot = 3,
};

RuneforgeUtil.Effect = {
	CenterPassive = 52,
	BottomPassive = 53,
	CenterRune = 56,
	PowerSlotted = 55,
	PowerInChainsEffect = 58,
	PowerOutChainsEffect = 59,
	ModifierSlotted = 61,
	FirstModifierChainsEffect = 54,
	SecondModifierChainsEffect = 57,
	UpgradeCenterRune = 69,
	UpgradeSubRune = 70,
};

RuneforgeUtil.Level = {
	Background = 1,
	Frame = 2,
	Overlay = 3,
};

RuneforgeUtil.RuneforgeState = {
	Craft = 1,
	Upgrade = 2,
};

RuneforgeUtil.FlyoutType = {
	BaseItem = 1,
	Legendary = 2,
	UpgradeItem = 3,
};

function RuneforgeUtil.GetCostsString(costs)
	local resultString = "";
	for i, cost in ipairs(costs) do
		local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(cost.currencyID);
		if currencyInfo then
			local currencyMarkup = CreateTextureMarkup(currencyInfo.icon, 64, 64, 14, 14, 0, 1, 0, 1);
			resultString = resultString.." "..cost.amount.." "..currencyMarkup;
		end
	end

	return resultString;
end

Enum.RuneforgePowerState =
{
	Available = 0,
	Unavailable = 1,
	Invalid = 2,
};
