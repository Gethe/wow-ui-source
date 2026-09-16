
KeybindReminderMixin = {};

local WorldLootTypeOffensive = 31;
local WorldLootTypeUtility = 32;
local WorldLootTypeItem = 0;

local OffensiveSlotOffset = 61;
local UtilitySlotOffset = 49;

local OffensiveButtonMapping = "WOWLABS_MULTIACTIONBAR1BUTTON";
local UtilityButtonMapping = "WOWLABS_MULTIACTIONBAR2BUTTON";

function KeybindReminderMixin:OnLoad()
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("PLAYER_EQUIPED_SPELLS_CHANGED");
	self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED");
	self.UnboundText:SetText(("(%s)"):format(NOT_BOUND));
	self.BindingAction:SetText(self.overrideBindingActionText or _G["BINDING_NAME_"..self.keybind]);
	if(self.spellSlot ~= nil) then
			self:HideReminder();
	end
end

function KeybindReminderMixin:OnEvent(event, ...)
	if event == "UPDATE_BINDINGS" then
		self:UpdateReminder();
	end
	if(event == "PLAYER_SOFT_INTERACT_CHANGED") then 
		local previousTarget, currentTarget = ...;
		if(currentTarget ~= nil) then
			local isWorldLootObj = C_WorldLootObject.IsWorldLootObjectByGUID(currentTarget);
			if(isWorldLootObj) then
				self:ShowReminder(C_WorldLootObject.GetWorldLootObjectInfoByGUID(currentTarget).inventoryType);
			elseif(self.spellSlot ~= nil) then
				self:HideReminder();
			end
		elseif(self.spellSlot ~= nil) then
			self:HideReminder();
		end
	end
end

function KeybindReminderMixin:ShowReminder(itemType)
	self:Show();
	self:UpdateReminder(itemType);
end

function KeybindReminderMixin:HideReminder()
	self:Hide();
end

function KeybindReminderMixin:UpdateReminder(itemType)
	local key = GetBindingKey(self.keybind);
	local bindingText = GetBindingText(key, 1);
	local hasBindingText = bindingText ~= "";
	self.KeyIcon:SetShown(hasBindingText);
	self.KeyBind:SetShown(hasBindingText);
	self.UnboundText:SetShown(not hasBindingText);
	self.KeyBind:SetText(bindingText);

	if(self.spellSlot ~= nil) then
		if(itemType == WorldLootTypeOffensive) then
			--offensive
			self:UpdateOffensiveReminder();
		elseif(itemType == WorldLootTypeUtility) then
			--utility
			self:UpdateUtilityReminder();
		elseif(itemType == WorldLootTypeItem) then
			--item
			self:UpdateItemReminder();
		end
	end
end

function KeybindReminderMixin:UpdateOffensiveReminder()
	if(self:HandleEmptyAbilitySlots(OffensiveSlotOffset, OffensiveButtonMapping) == true) then
		return;
	end

	local hasAction = C_ActionBar.HasAction(OffensiveSlotOffset + self.spellSlot);
	if(hasAction) then
		--swap
		self.RightIndicator:Show();
		--Change the SlotSpell to be the icon of the spell in that slot.
		self.BindingAction:SetText(PLUNDERSTORM_INTERACT_SWAP_REMINDER_TEXT);
		local texture = C_ActionBar.GetActionTexture(OffensiveSlotOffset + self.spellSlot);
		self.SlotSpell:SetTexture(texture);
		self.SlotSpell:Show();
		self:Layout();
	else
		--assign
		self.RightIndicator:Hide();
		local bindingKey = GetBindingKeyForAction(OffensiveButtonMapping .. tostring(self.slotBindingOffset));
		if(bindingKey ~= nil) then
			self.BindingAction:SetText(PLUNDERSTORM_INTERACT_ASSIGN_REMINDER_TEXT:format(bindingKey));
		end
		self.SlotSpell:Hide();
		self:Layout();
	end
end

function KeybindReminderMixin:HandleEmptyAbilitySlots(baseIndex, buttonMapping)
	local firstSlotHasAction = C_ActionBar.HasAction(baseIndex);
	local secondSlotHasAction = C_ActionBar.HasAction(baseIndex + 1);
	local slotOffset = 0;

	if(firstSlotHasAction == false) then
		slotOffset = 1;
	elseif(secondSlotHasAction == false) then
		slotOffset = 2;
	else
		return false
	end

	self.RightIndicator:Hide();
	local bindingKey = GetBindingKeyForAction(buttonMapping .. tostring(slotOffset));
	if(bindingKey ~= nil) then
		self.BindingAction:SetText(PLUNDERSTORM_INTERACT_PICK_UP_REMINDER_TEXT:format(bindingKey));
	end

	self.SlotSpell:Hide();
	self:Layout();

	return true;
end

function KeybindReminderMixin:UpdateUtilityReminder()
	if(self:HandleEmptyAbilitySlots(UtilitySlotOffset, UtilityButtonMapping) == true) then
		return;
	end

	local hasAction = C_ActionBar.HasAction(UtilitySlotOffset + self.spellSlot);

	if(hasAction) then
		--swap
		self.RightIndicator:Show();
		--Change the SlotSpell to be the icon of the spell in that slot.
		self.BindingAction:SetText(PLUNDERSTORM_INTERACT_SWAP_REMINDER_TEXT);
		local texture = C_ActionBar.GetActionTexture(UtilitySlotOffset + self.spellSlot);
		self.SlotSpell:SetTexture(texture);
		self.SlotSpell:Show();
		self:Layout();
	else
		--assign
		self.RightIndicator:Hide();
		local bindingKey = GetBindingKeyForAction(UtilityButtonMapping .. tostring(self.slotBindingOffset));
		if(bindingKey ~= nil) then
			self.BindingAction:SetText(PLUNDERSTORM_INTERACT_ASSIGN_REMINDER_TEXT:format(bindingKey));
		end
		self.SlotSpell:Hide();
		self:Layout();
	end
end

function KeybindReminderMixin:UpdateItemReminder()
	if(self.spellSlot == 0) then
		self:HideReminder();
	else
		self.RightIndicator:Hide();
		local bindingKey = GetBindingKeyForAction(UtilityButtonMapping .. tostring(self.slotBindingOffset));
		if(bindingKey ~= nil) then
			self.BindingAction:SetText(PLUNDERSTORM_INTERACT_PICK_UP_REMINDER_TEXT:format(bindingKey));
		end
		self.SlotSpell:Hide();
		self:Layout();
	end
end
