
function BagSlotButton_UpdateChecked(self)
	local translatedID = self:GetID() - CharacterBag0Slot:GetID() + 1;
	local isVisible = false;
	local frame;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		frame = _G["ContainerFrame"..i];
		if ( (frame:GetID() == translatedID) and frame:IsShown() ) then
			isVisible = true;
			break;
		end
	end
	self:SetChecked(isVisible);
end

function BagSlotButton_OnClick(self)
	local id = self:GetID();
	local translatedID = id - CharacterBag0Slot:GetID() + 1;
	local hadItem = PutItemInBag(id);
	if ( not hadItem ) then
		ToggleBag(translatedID);
	end
	BagSlotButton_UpdateChecked(self);
end

function BagSlotButton_OnModifiedClick(self)
	if ( IsModifiedClick("OPENALLBAGS") ) then
		if ( GetInventoryItemTexture("player", self:GetID()) ) then
			ToggleAllBags();
		end
	end
	BagSlotButton_UpdateChecked(self);
end

function BagSlotButton_OnDrag(self)
	PickupBagFromSlot(self:GetID());
	BagSlotButton_UpdateChecked(self);
end

function BackpackButton_UpdateChecked(self)
	local isVisible = false;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local frame = _G["ContainerFrame"..i];
		if ( (frame:GetID() == 0) and frame:IsShown() ) then
			isVisible = true;
			break;
		end
	end
	self:SetChecked(isVisible);
end

function BackpackButton_OnClick(self)
	if ( not PutItemInBackpack() ) then
		ToggleBackpack();
	end
	BackpackButton_UpdateChecked(self);
end

function BackpackButton_OnModifiedClick(self)
	if ( IsModifiedClick("OPENALLBAGS") ) then
		ToggleAllBags();
	end
	BackpackButton_UpdateChecked(self);
end

function PutKeyInKeyRing()
	local texture;
	local emptyKeyRingSlot;
	for i=1, GetKeyRingSize() do
		texture = GetContainerItemInfo(KEYRING_CONTAINER, i);
		if ( not texture ) then
			emptyKeyRingSlot = i;
			break;
		end
	end
	if ( emptyKeyRingSlot ) then
		PickupContainerItem(KEYRING_CONTAINER, emptyKeyRingSlot);
	else
		UIErrorsFrame:AddMessage(NO_EMPTY_KEYRING_SLOTS, 1.0, 0.1, 0.1, 1.0);
	end
end

function GetKeyRingSize()
	local numKeyringSlots = GetContainerNumSlots(KEYRING_CONTAINER);
	local maxSlotNumberFilled = 0;
	local numItems = 0;
	for i=1, numKeyringSlots do
		local texture = GetContainerItemInfo(KEYRING_CONTAINER, i);
		-- Update max slot
		if ( texture and i > maxSlotNumberFilled) then
			maxSlotNumberFilled = i;
		end
		-- Count how many items you have
		if ( texture ) then
			numItems = numItems + 1;
		end
	end

	-- Round to the nearest 4 rows that will hold the keys
	local modulo = maxSlotNumberFilled % 4;
	local size;
	if ( (modulo == 0) and (numItems < maxSlotNumberFilled) ) then
		size = maxSlotNumberFilled;
	else
		-- Only expand if the number of keys in the keyring exceed or equal the max slot filled
		size = maxSlotNumberFilled + (4 - modulo);
	end	
	size = min(size, numKeyringSlots);

	return size;
end

function ItemAnim_OnLoad(self)
	self:RegisterEvent("ITEM_PUSH");
end

function ItemAnim_OnEvent(self, event, ...)
	if ( event == "ITEM_PUSH" ) then
		local arg1, arg2 = ...;
		local id = self:GetID();
		if ( id == arg1 ) then
			self.animIcon:SetTexture(arg2);
			self.flyin:Play(true);
		end
	end
end

function BagSlotButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if ( GameTooltip:SetInventoryItem("player", self:GetID()) ) then
		local bindingKey = GetBindingKey("TOGGLEBAG"..(4 -  (self:GetID() - CharacterBag0Slot:GetID())));
		if ( bindingKey ) then
			GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..bindingKey..")"..FONT_COLOR_CODE_CLOSE);
		end
		local bagID = (self:GetID() - CharacterBag0Slot:GetID()) + 1;
		if (not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(bagID))) then
			for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
				if ( GetBagSlotFlag(bagID, i) ) then
					GameTooltip:AddLine(BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[i]));
					break;
				end
			end
		end
		GameTooltip:Show();
	else
		GameTooltip:SetText(EQUIP_CONTAINER, 1.0, 1.0, 1.0);
	end
end

function ItemAnim_OnAnimFinished(self)
	self:Hide();
end

function Disable_BagButtons()
	MainMenuBarBackpackButton:Disable();
	SetDesaturation(MainMenuBarBackpackButtonIconTexture, true);
	CharacterBag0Slot:Disable();
	SetDesaturation(CharacterBag0SlotIconTexture, true);
	CharacterBag1Slot:Disable();
	SetDesaturation(CharacterBag1SlotIconTexture, true);
	CharacterBag2Slot:Disable();
	SetDesaturation(CharacterBag2SlotIconTexture, true);
	CharacterBag3Slot:Disable();
	SetDesaturation(CharacterBag3SlotIconTexture, true);
end

function Enable_BagButtons()
	MainMenuBarBackpackButton:Enable();
	SetDesaturation(MainMenuBarBackpackButtonIconTexture, false);
	CharacterBag0Slot:Enable();
	SetDesaturation(CharacterBag0SlotIconTexture, false);
	CharacterBag1Slot:Enable();
	SetDesaturation(CharacterBag1SlotIconTexture, false);
	CharacterBag2Slot:Enable();
	SetDesaturation(CharacterBag2SlotIconTexture, false);
	CharacterBag3Slot:Enable();
	SetDesaturation(CharacterBag3SlotIconTexture, false);
end

function MainMenuBarBackpackButton_OnEvent(self, event, ...)
	if ( event == "BAG_UPDATE" ) then
		local bag = ...;
		if ( bag >= BACKPACK_CONTAINER and bag <= NUM_BAG_SLOTS ) then
			MainMenuBarBackpackButton_UpdateFreeSlots();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( GetCVar("displayFreeBagSlots") == "1" ) then
			MainMenuBarBackpackButtonCount:Show();
		else
			MainMenuBarBackpackButtonCount:Hide();
		end
		MainMenuBarBackpackButton_UpdateFreeSlots();
	elseif ( event == "CVAR_UPDATE" ) then
		local cvar, value = ...
		if ( cvar == "DISPLAY_FREE_BAG_SLOTS" ) then
			if ( value == "1" ) then
				MainMenuBarBackpackButtonCount:Show();
			else
				MainMenuBarBackpackButtonCount:Hide();
			end
		end
	elseif ( event == "INVENTORY_SEARCH_UPDATE" ) then
		if ( IsContainerFiltered(BACKPACK_CONTAINER) ) then
			self.searchOverlay:Show();
		else
			self.searchOverlay:Hide();
		end
	end
end

local BACKPACK_FREESLOTS_FORMAT = "(%s)";

function CalculateTotalNumberOfFreeBagSlots()
	local totalFree, freeSlots, bagFamily = 0;
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		freeSlots, bagFamily = GetContainerNumFreeSlots(i);
		if ( bagFamily == 0 ) then
			totalFree = totalFree + freeSlots;
		end
	end
	
	return totalFree;
end

function MainMenuBarBackpackButton_UpdateFreeSlots()
	local totalFree = CalculateTotalNumberOfFreeBagSlots();
	if ( totalFree == 3) then
		TriggerTutorial(59);
	end
	if ( totalFree == 0) then
		TriggerTutorial(58);
	end

	MainMenuBarBackpackButton.freeSlots = totalFree;
end
