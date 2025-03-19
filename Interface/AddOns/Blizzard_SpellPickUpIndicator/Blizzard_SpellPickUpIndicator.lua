SpellPickupIndicatorMixin = {};

local WorldLootTypeOffensive = 31;
local WorldLootTypeUtility = 32;
local WorldLootTypeItem = 0;

local OffensiveSlotOffset = 61;
local UtilitySlotOffset = 49;

local OffensiveButtonMapping = "WOWLABS_MULTIACTIONBAR1BUTTON";
local UtilityButtonMapping = "WOWLABS_MULTIACTIONBAR2BUTTON";

local leftClickPickupAtlas = "plunderstorm-pickup-mouseclick-left";
local rightClickPickupAtlas = "plunderstorm-pickup-mouseclick-right";

function SpellPickupIndicatorMixin:OnLoad()
	if(self.spellSlot == 0) then
		self.KeyIcon:SetAtlas(leftClickPickupAtlas);
	else
		self.KeyIcon:SetAtlas(rightClickPickupAtlas);
	end
end

function SpellPickupIndicatorMixin:SetInventoryType(inventoryType, id, itemGUID)
	if(inventoryType == WorldLootTypeOffensive) then
		--offensive
		self:UpdateOffensiveReminder(id, itemGUID);
	elseif(inventoryType == WorldLootTypeUtility) then
		--utility
		self:UpdateUtilityReminder(id, itemGUID);
	elseif(inventoryType == WorldLootTypeItem) then
		--item
		self:UpdateItemReminder();
	end

	self:Show();
	self:Layout();
end

function SpellPickupIndicatorMixin:UpdateOffensiveReminder(id, itemGUID)
	self.BindingAction:SetTextColor(NORMAL_FONT_COLOR:GetRGB());

	if(self:HandleEmptyAbilitySlots(OffensiveSlotOffset, OffensiveButtonMapping)) then
		return;
	end

	local hasAction = HasAction(OffensiveSlotOffset + self.spellSlot);

	local newActionType = GetActionInfo(id);
	local firstActionType, firstID = GetActionInfo(OffensiveSlotOffset + 0);
	local secondActionType, secondID = GetActionInfo(OffensiveSlotOffset + 1);

	local newSpellName = C_Spell.GetSpellName(id);
	local firstSpellName = C_Spell.GetSpellName(firstID);
	local secondSpellName = C_Spell.GetSpellName(secondID);
	
	if(self:HandleUpgradeNotification(newSpellName, firstActionType, firstSpellName, secondActionType, secondSpellName, OffensiveButtonMapping, itemGUID)) then
		return;
	end
	
	--swap
	self:Show();
	self.PickupArrow:Show();
	self.KeyIcon:Show();
	--Change the SlotSpell to be the icon of the spell in that slot.
	local texture = GetActionTexture(OffensiveSlotOffset + self.spellSlot);
	self.BindingAction:SetText(PLUNDERSTORM_INTERACT_SWAP_REMINDER_TEXT);
	self.SlotSpell:SetTexture(texture);
	self.SlotSpell:Show();
	self:Layout();
end

function SpellPickupIndicatorMixin:HandleUpgradeNotification(newID, firstName, firstID, secondName, secondID, buttonMapping, itemGUID)
	local isUpgrade = false;
	local firstSlotUpgrade = false;
	local secondSlotUpgrade = false;

	if(newID == firstID and firstName == "spell") then
		firstSlotUpgrade = true;
	elseif (newID == secondID and secondName == "spell") then
		secondSlotUpgrade = true;
	end

	if(firstSlotUpgrade or secondSlotUpgrade) then
		local itemInfo = C_WorldLootObject.GetWorldLootObjectInfoByGUID(itemGUID);
		if(itemInfo.atMaxQuality) then
			self.BindingAction:SetTextColor(GRAY_FONT_COLOR:GetRGB());
		else
			self.BindingAction:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		end

		self.KeyIcon:Hide();
		self.PickupArrow:Hide();
		if(self.spellSlot > 0) then
			self.BindingAction:Hide();
		end
		self.BindingAction:SetText(PLUNDERSTORM_INTERACT_UPGRADE_REMINDER_TEXT);
		self.SlotSpell:Hide();
		self:Layout();
		return true;
	end
	self.BindingAction:Show();
	self.KeyIcon:Show();
	return false;
end

function SpellPickupIndicatorMixin:UpdateUtilityReminder(id, itemGUID)
	self.BindingAction:SetTextColor(NORMAL_FONT_COLOR:GetRGB());

	if(self:HandleEmptyAbilitySlots(UtilitySlotOffset, UtilityButtonMapping)) then
		return;
	end

	local hasAction = HasAction(UtilitySlotOffset + self.spellSlot);
	local firstActionType, firstID = GetActionInfo(UtilitySlotOffset + 0);
	local secondActionType, secondID = GetActionInfo(UtilitySlotOffset + 1);

	local newSpellName = C_Spell.GetSpellName(id);
	local firstSpellName = C_Spell.GetSpellName(firstID);
	local secondSpellName = C_Spell.GetSpellName(secondID);
	
	if(self:HandleUpgradeNotification(newSpellName, firstActionType, firstSpellName, secondActionType, secondSpellName, UtilityButtonMapping, itemGUID)) then
		return;
	end

	--swap
	self.PickupArrow:Show();
	self.KeyIcon:Show();
	--Change the SlotSpell to be the icon of the spell in that slot.
	local texture = GetActionTexture(UtilitySlotOffset + self.spellSlot);
	self.SlotSpell:SetTexture(texture);
	self.SlotSpell:Show();
	self:Layout();
end

function SpellPickupIndicatorMixin:UpdateItemReminder()
	self.PickupArrow:Hide();
	self.BindingAction:SetText(PLUNDERSTORM_INTERACT_PICK_UP_REMINDER_TEXT);
	self.BindingAction:Show();
	self.SlotSpell:Hide();
	self:Layout();
end

function SpellPickupIndicatorMixin:HandleEmptyAbilitySlots(baseIndex, buttonMapping)
	local firstSlotHasAction = HasAction(baseIndex);
	local secondSlotHasAction = HasAction(baseIndex + 1);

	if(firstSlotHasAction == false) then
		self.PickupArrow:Hide();
		self.BindingAction:Hide();
		self.SlotSpell:Hide();
		self.KeyIcon:Hide();
		return true;
	elseif(secondSlotHasAction == false) then
		self.PickupArrow:Hide();
		self.BindingAction:Hide();
		self.SlotSpell:Hide();
		self.KeyIcon:Hide();
		return true;
	else
		return false
	end
end

SpellPickupDisplayMixin = {};

function SpellPickupDisplayMixin:OnLoad()
	self:AddStaticEventMethod(EventRegistry, "WorldLootObjectTooltip.Shown", self.OnWorldLootObjectTooltipShown);
	self:AddDynamicEventMethod(EventRegistry, "WorldLootObjectTooltip.Hidden", self.OnWorldLootObjectTooltipHidden);
end

function SpellPickupDisplayMixin:OnUpdate()
	self:UpdatePosition();
end

function SpellPickupDisplayMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);
	BaseLayoutMixin.OnShow(self);
end

function SpellPickupDisplayMixin:OnWorldLootObjectTooltipShown(inventoryType, tooltip, id, itemGUID)
	if(inventoryType == WorldLootTypeItem) then
		--we no longer want to show items on this prompt, so early exit.
		return;
	end

	self.anchorTooltip = tooltip;
	self.LeftSpellPickupIndicator:SetInventoryType(inventoryType, id, itemGUID);
	self.RightSpellPickupIndicator:SetInventoryType(inventoryType, id, itemGUID);

	local objectInfo = C_WorldLootObject.GetWorldLootObjectInfoByGUID(itemGUID);

	self:UpdatePosition();
	self:Show();
	self:Layout();
end

function SpellPickupDisplayMixin:OnWorldLootObjectTooltipHidden(_inventoryType, tooltip)
	if self.anchorTooltip == tooltip then
		self.anchorTooltip = nil;
		self:Hide();
	end
end

function SpellPickupDisplayMixin:UpdatePosition()
    if self.anchorTooltip ~= nil then 
	    local spaceBelow = self.anchorTooltip:GetBottom() or 0;
		local selfHeight = self:GetHeight() or 0;
		self:ClearAllPoints();
	    if spaceBelow >= selfHeight + 10 then
	    	self:SetPoint("TOP", self.anchorTooltip, "BOTTOM", 0, -6);
	    else
	    	self:SetPoint("BOTTOM", self.anchorTooltip, "TOP", 0, 6);
	    end
	end
end