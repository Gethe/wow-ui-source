
function InspectPaperDollFrame_OnLoad()
	this:RegisterEvent("UNIT_MODEL_CHANGED");
	this:RegisterEvent("UNIT_LEVEL");
end

function InspectModelFrame_OnUpdate(elapsedTime)
	if ( InspectModelRotateLeftButton:GetButtonState() == "PUSHED" ) then
		this.rotation = this.rotation + (elapsedTime * 2 * PI * ROTATIONS_PER_SECOND);
		if ( this.rotation < 0 ) then
			this.rotation = this.rotation + (2 * PI);
		end
		InspectModelFrame:SetRotation(this.rotation);
	end
	if ( InspectModelRotateRightButton:GetButtonState() == "PUSHED" ) then
		this.rotation = this.rotation - (elapsedTime * 2 * PI * ROTATIONS_PER_SECOND);
		if ( this.rotation > (2 * PI) ) then
			this.rotation = this.rotation - (2 * PI);
		end
		InspectModelFrame:SetRotation(this.rotation);
	end
end

function InspectModelFrame_OnLoad()
	this.rotation = 0.61;
	InspectModelFrame:SetRotation(this.rotation);
end

function InspectModelRotateLeftButton_OnClick()
	InspectModelFrame.rotation = InspectModelFrame.rotation - 0.03;
	InspectModelFrame:SetRotation(InspectModelFrame.rotation);
	PlaySound("igInventoryRotateCharacter");
end

function InspectModelRotateRightButton_OnClick()
	InspectModelFrame.rotation = InspectModelFrame.rotation + 0.03;
	InspectModelFrame:SetRotation(InspectModelFrame.rotation);
	PlaySound("igInventoryRotateCharacter");
end

function InspectPaperDollFrame_OnEvent(event, unit)
	if ( unit and unit == InspectFrame.unit ) then
		if ( event == "UNIT_MODEL_CHANGED" ) then
			InspectModelFrame:SetUnit(InspectFrame.unit);
		elseif ( event == "UNIT_LEVEL" ) then
			InspectPaperDollFrame_SetLevel();
		end
		return;
	end
end

function InspectPaperDollFrame_SetLevel()
	local unit = InspectFrame.unit;
	InspectLevelText:SetText(format(TEXT(PLAYER_LEVEL),UnitLevel(unit), UnitRace(unit), UnitClass(unit)));
end

function InspectPaperDollFrame_OnShow()
	InspectModelFrame:SetUnit(InspectFrame.unit);
	InspectPaperDollFrame_SetLevel();
	InspectPaperDollItemSlotButton_Update(InspectHeadSlot);
	InspectPaperDollItemSlotButton_Update(InspectNeckSlot);
	InspectPaperDollItemSlotButton_Update(InspectShoulderSlot);
	InspectPaperDollItemSlotButton_Update(InspectBackSlot);
	InspectPaperDollItemSlotButton_Update(InspectChestSlot);
	InspectPaperDollItemSlotButton_Update(InspectShirtSlot);
	InspectPaperDollItemSlotButton_Update(InspectTabardSlot);
	InspectPaperDollItemSlotButton_Update(InspectWristSlot);
	InspectPaperDollItemSlotButton_Update(InspectHandsSlot);
	InspectPaperDollItemSlotButton_Update(InspectWaistSlot);
	InspectPaperDollItemSlotButton_Update(InspectLegsSlot);
	InspectPaperDollItemSlotButton_Update(InspectFeetSlot);
	InspectPaperDollItemSlotButton_Update(InspectFinger0Slot);
	InspectPaperDollItemSlotButton_Update(InspectFinger1Slot);
	InspectPaperDollItemSlotButton_Update(InspectTrinket0Slot);
	InspectPaperDollItemSlotButton_Update(InspectTrinket1Slot);
	InspectPaperDollItemSlotButton_Update(InspectMainHandSlot);
	InspectPaperDollItemSlotButton_Update(InspectSecondaryHandSlot);
	InspectPaperDollItemSlotButton_Update(InspectRangedSlot);
end

function InspectPaperDollItemSlotButton_OnLoad()
	this:RegisterEvent("UNIT_INVENTORY_CHANGED");
	local slotName = this:GetName();
	local id;
	local textureName;
	id, textureName = GetInventorySlotInfo(strsub(slotName,8));
	this:SetID(id);
	local texture = getglobal(slotName.."IconTexture");
	texture:SetTexture(textureName);
	this.backgroundTextureName = textureName;
end

function InspectPaperDollItemSlotButton_OnEvent(event)
	if ( event == "UNIT_INVENTORY_CHANGED" ) then
		if ( arg1 == InspectFrame.unit ) then
			InspectPaperDollItemSlotButton_Update(this);
		end
		return;
	end
end

function InspectPaperDollItemSlotButton_OnClick(button)
	if ( button == "LeftButton" ) then
		if ( IsShiftKeyDown() ) then
			if ( ChatFrameEditBox:IsVisible() ) then
				ChatFrameEditBox:Insert(GetInventoryItemLink(InspectFrame.unit, this:GetID()));
			end
		end
	end
end

function InspectPaperDollItemSlotButton_Update(button)
	local unit = InspectFrame.unit;
	local textureName = GetInventoryItemTexture(unit, button:GetID());
	if ( textureName ) then
		SetItemButtonTexture(button, textureName);
		SetItemButtonCount(button, GetInventoryItemCount(unit, button:GetID()));
	else
		SetItemButtonTexture(button, button.backgroundTextureName);
		SetItemButtonCount(button, 0);
	end
	if ( GameTooltip:IsOwned(button) ) then
		if ( texture ) then
            if ( not GameTooltip:SetInventoryItem(InspectFrame.unit, button:GetID()) ) then
				GameTooltip:SetText(TEXT(getglobal(strupper(strsub(button:GetName(), 8)))));
			end
		else
			GameTooltip:Hide();
		end
	end
end
