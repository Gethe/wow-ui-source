
function BagSlotButton_UpdateChecked(self)
	local translatedID = self:GetID() - CharacterBag0Slot:GetID() + 1;
	local isVisible = 0;
	local frame;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		frame = _G["ContainerFrame"..i];
		if ( (frame:GetID() == translatedID) and frame:IsShown() ) then
			isVisible = 1;
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
			OpenAllBags();
		end
	end
	BagSlotButton_UpdateChecked(self);
end

function BagSlotButton_OnDrag(self)
	PickupBagFromSlot(self:GetID());
	BagSlotButton_UpdateChecked(self);
end

function BackpackButton_UpdateChecked(self)
	local isVisible = 0;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local frame = _G["ContainerFrame"..i];
		if ( (frame:GetID() == 0) and frame:IsShown() ) then
			isVisible = 1;
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
		OpenAllBags();
	end
	BackpackButton_UpdateChecked(self);
end

function ItemAnim_OnLoad(self)
	self:RegisterEvent("ITEM_PUSH");
end

function ItemAnim_OnEvent(self, event, ...)
	if ( event == "ITEM_PUSH" ) then
		local arg1, arg2 = ...;
		local id = self:GetParent():GetID();
		if ( id == arg1 ) then
			self:ReplaceIconTexture(arg2);
			self:SetSequence(0);
			self:SetSequenceTime(0, 0);
			self:Show();
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
	else
		GameTooltip:SetText(EQUIP_CONTAINER, 1.0, 1.0, 1.0);
	end
end

function ItemAnim_OnAnimFinished(self)
	self:Hide();
end

function Disable_BagButtons()
	MainMenuBarBackpackButton:Disable();
	SetDesaturation(MainMenuBarBackpackButtonIconTexture, 1);
	CharacterBag0Slot:Disable();
	SetDesaturation(CharacterBag0SlotIconTexture, 1);
	CharacterBag1Slot:Disable();
	SetDesaturation(CharacterBag1SlotIconTexture, 1);
	CharacterBag2Slot:Disable();
	SetDesaturation(CharacterBag2SlotIconTexture, 1);
	CharacterBag3Slot:Disable();
	SetDesaturation(CharacterBag3SlotIconTexture, 1);
end

function Enable_BagButtons()
	MainMenuBarBackpackButton:Enable();
	SetDesaturation(MainMenuBarBackpackButtonIconTexture, nil);
	CharacterBag0Slot:Enable();
	SetDesaturation(CharacterBag0SlotIconTexture, nil);
	CharacterBag1Slot:Enable();
	SetDesaturation(CharacterBag1SlotIconTexture, nil);
	CharacterBag2Slot:Enable();
	SetDesaturation(CharacterBag2SlotIconTexture, nil);
	CharacterBag3Slot:Enable();
	SetDesaturation(CharacterBag3SlotIconTexture, nil);
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
	end
end

local BACKPACK_FREESLOTS_FORMAT = "(%s)";

function MainMenuBarBackpackButton_UpdateFreeSlots()
	local totalFree, freeSlots, bagFamily = 0;
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		freeSlots, bagFamily = GetContainerNumFreeSlots(i);
		if ( bagFamily == 0 ) then
			totalFree = totalFree + freeSlots;
		end
	end
	
	if ( totalFree == 3) then
		TriggerTutorial(59);
	end
	if ( totalFree == 0) then
		TriggerTutorial(58);
	end

	MainMenuBarBackpackButton.freeSlots = totalFree;
	
	MainMenuBarBackpackButtonCount:SetText(string.format(BACKPACK_FREESLOTS_FORMAT, totalFree));
end
