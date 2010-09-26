
function InspectPaperDollFrame_OnLoad(self)
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("INSPECT_READY");
end

function InspectPaperDollFrame_OnEvent(self, event, unit)
	if ( unit and unit == InspectFrame.unit ) then
		if ( event == "UNIT_MODEL_CHANGED" ) then
			InspectModelFrame:RefreshUnit();
		elseif ( event == "UNIT_LEVEL" ) then
			InspectPaperDollFrame_SetLevel();
		end
		return;
	end
	if (event == "INSPECT_READY") then
		InspectPaperDollFrame_SetLevel();
	end
end

function InspectPaperDollFrame_SetLevel()
	local unit, level = InspectFrame.unit, UnitLevel(InspectFrame.unit);
	local primaryTalentTree = GetPrimaryTalentTree(true);
	
	local classDisplayName, class = UnitClass(InspectFrame.unit); 
	local classColor = RAID_CLASS_COLORS[class];
	local classColorString = format("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255);
	local specName;
	
	if (primaryTalentTree) then
		_, specName = GetTalentTabInfo(primaryTalentTree, true);
	end
	
	if ( level == -1 ) then
		level = "??";
	end
	
	if (specName and specName ~= "") then
		InspectLevelText:SetFormattedText(PLAYER_LEVEL, level, classColorString, specName, classDisplayName);
	else
		InspectLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC, level, classColorString, classDisplayName);
	end
end

function InspectPaperDollFrame_OnShow()
	ButtonFrameTemplate_HideButtonBar(InspectFrame);
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
	
	SetPaperDollBackground(InspectModelFrame, InspectFrame.unit);
	InspectModelFrameBackgroundTopLeft:SetDesaturated(1);
	InspectModelFrameBackgroundTopRight:SetDesaturated(1);
	InspectModelFrameBackgroundBotLeft:SetDesaturated(1);
	InspectModelFrameBackgroundBotRight:SetDesaturated(1);
end

function InspectPaperDollItemSlotButton_OnLoad(self)
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	local slotName = self:GetName();
	local id;
	local textureName;
	local checkRelic;
	id, textureName, checkRelic = GetInventorySlotInfo(strsub(slotName,8));
	self:SetID(id);
	local texture = _G[slotName.."IconTexture"];
	texture:SetTexture(textureName);
	self.backgroundTextureName = textureName;
	self.checkRelic = checkRelic;
end

function InspectPaperDollItemSlotButton_OnEvent(self, event, ...)
	if ( event == "UNIT_INVENTORY_CHANGED" ) then
		local arg1 = ...;
		if ( arg1 == InspectFrame.unit ) then
			InspectPaperDollItemSlotButton_Update(self);
		end
		return;
	end
end

function InspectPaperDollItemSlotButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( not GameTooltip:SetInventoryItem(InspectFrame.unit, self:GetID()) ) then
		local text = _G[strupper(strsub(self:GetName(), 8))];
		if ( self.checkRelic and UnitHasRelicSlot(InspectFrame.unit) ) then
			text = _G["RELICSLOT"];
		end
		GameTooltip:SetText(text);
	end
	CursorUpdate(self);
end

function InspectPaperDollItemSlotButton_Update(button)
	local unit = InspectFrame.unit;
	local textureName = GetInventoryItemTexture(unit, button:GetID());
	if ( textureName ) then
		SetItemButtonTexture(button, textureName);
		SetItemButtonCount(button, GetInventoryItemCount(unit, button:GetID()));
		button.hasItem = 1;
	else
		local textureName = button.backgroundTextureName;
		if ( button.checkRelic and UnitHasRelicSlot(unit) ) then
			textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
		end
		SetItemButtonTexture(button, textureName);
		SetItemButtonCount(button, 0);
		button.hasItem = nil;
	end
	if ( GameTooltip:IsOwned(button) ) then
		if ( texture ) then
            if ( not GameTooltip:SetInventoryItem(InspectFrame.unit, button:GetID()) ) then
				GameTooltip:SetText(_G[strupper(strsub(button:GetName(), 8))]);
			end
		else
			GameTooltip:Hide();
		end
	end
end
