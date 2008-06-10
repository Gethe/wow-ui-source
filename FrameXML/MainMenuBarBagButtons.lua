KEYRING_CONTAINER = -2;

function BagSlotButton_OnClick()
	local id = this:GetID();
	local translatedID = id - CharacterBag0Slot:GetID() + 1;
	local hadItem = PutItemInBag(id);
	if ( not hadItem ) then
		ToggleBag(translatedID);
		PlaySound("BAGMENUBUTTONPRESS");
		
	end
	local isVisible = 0;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local frame = getglobal("ContainerFrame"..i);
		if ( (frame:GetID() == translatedID) and frame:IsVisible() ) then
			isVisible = 1;
			break;
		end
	end
	this:SetChecked(isVisible);
end

function BagSlotButton_OnDrag()
	local translatedID = this:GetID() - CharacterBag0Slot:GetID() + 1;
	PickupBagFromSlot(this:GetID());
	PlaySound("BAGMENUBUTTONPRESS");
	local isVisible = 0;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local frame = getglobal("ContainerFrame"..i);
		if ( (frame:GetID() == translatedID) and frame:IsVisible() ) then
			isVisible = 1;
			break;
		end
	end
	this:SetChecked(isVisible);
end

function BagSlotButton_OnShiftClick()
	if ( GetInventoryItemTexture("player", this:GetID()) ) then
		OpenAllBags();
	end
	local translatedID = this:GetID() - CharacterBag0Slot:GetID() + 1;
	local isVisible = 0;
	local frame;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		frame = getglobal("ContainerFrame"..i);
		if ( (frame:GetID() == translatedID) and frame:IsVisible() ) then
			isVisible = 1;
			break;
		end
	end
	this:SetChecked(isVisible);
end

function BackpackButton_OnClick()
	if ( not PutItemInBackpack() ) then
		ToggleBackpack();
	end
	local isVisible = 0;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local frame = getglobal("ContainerFrame"..i);
		if ( (frame:GetID() == 0) and frame:IsVisible() ) then
			isVisible = 1;
			break;
		end
	end
	this:SetChecked(isVisible);
end

function ItemAnim_OnLoad()
	this:RegisterEvent("ITEM_PUSH");
end

function ItemAnim_OnEvent(event)
	if ( event == "ITEM_PUSH" ) then
		local id = this:GetParent():GetID();
		if ( id == arg1 ) then
			this:ReplaceIconTexture(arg2);
			this:SetSequence(0);
			this:SetSequenceTime(0, 0);
			this:Show();
		end
	end
end

function BagSlotButton_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_LEFT");
	if ( GameTooltip:SetInventoryItem("player", this:GetID()) ) then
		local bindingKey = GetBindingKey("TOGGLEBAG"..(4 -  (this:GetID() - CharacterBag0Slot:GetID())));
		if ( bindingKey ) then
			GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..bindingKey..")"..FONT_COLOR_CODE_CLOSE);
		end
	else
		GameTooltip:SetText(TEXT(EQUIP_CONTAINER), 1.0, 1.0, 1.0);
	end
end

function ItemAnim_OnAnimFinished()
	this:Hide();
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
