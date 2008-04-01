NUM_CONTAINER_FRAMES = 9;
NUM_BAG_FRAMES = 4;
MAX_CONTAINER_ITEMS = 20;
NUM_CONTAINER_COLUMNS = 4;
CONTAINER_WIDTH = 192;
CONTAINER_SPACING = 0;
VISIBLE_CONTAINER_SPACING = 3;
CONTAINER_OFFSET = 70;
-- [n] = {textureName, textureWidth, textureHeight, frameHeight}
CONTAINER_FRAME_TABLE = {
	[0] = {"Interface\\ContainerFrame\\UI-BackpackBackground", 256, 256, 239},
	[1] = {"Interface\\ContainerFrame\\UI-Bag-1x4", 256, 128, 96},
	[2] = {"Interface\\ContainerFrame\\UI-Bag-1x4", 256, 128, 96},
	[3] = {"Interface\\ContainerFrame\\UI-Bag-1x4", 256, 128, 96},
	[4] = {"Interface\\ContainerFrame\\UI-Bag-1x4", 256, 128, 96},
	[5] = {"Interface\\ContainerFrame\\UI-Bag-1x4+2", 256, 128, 116},
	[6] = {"Interface\\ContainerFrame\\UI-Bag-1x4+2", 256, 128, 116},
	[7] = {"Interface\\ContainerFrame\\UI-Bag-1x4+2", 256, 128, 116},
	[8] = {"Interface\\ContainerFrame\\UI-Bag-2x4", 256, 256, 137},
	[9] = {"Interface\\ContainerFrame\\UI-Bag-2x4+2", 256, 256, 157},
	[10] = {"Interface\\ContainerFrame\\UI-Bag-2x4+2", 256, 256, 157},
	[11] = {"Interface\\ContainerFrame\\UI-Bag-2x4+2", 256, 256, 157},
	[12] = {"Interface\\ContainerFrame\\UI-Bag-3x4", 256, 256, 178},
	[13] = {"Interface\\ContainerFrame\\UI-Bag-3x4+2", 256, 256, 198},
	[14] = {"Interface\\ContainerFrame\\UI-Bag-3x4+2", 256, 256, 198},
	[15] = {"Interface\\ContainerFrame\\UI-Bag-3x4+2", 256, 256, 198},
	[16] = {"Interface\\ContainerFrame\\UI-Bag-4x4", 256, 256, 219},
	[18] = {"Interface\\ContainerFrame\\UI-Bag-4x4+2", 256, 256, 239},
	[20] = {"Interface\\ContainerFrame\\UI-Bag-5x4", 256, 256, 259},
};

function ContainerFrame_OnLoad()
	this:RegisterEvent("BAG_UPDATE");
	this:RegisterEvent("BAG_CLOSED");
	this:RegisterEvent("BAG_OPEN");
	this:RegisterEvent("BAG_UPDATE_COOLDOWN");
	this:RegisterEvent("ITEM_LOCK_CHANGED");
	this:RegisterEvent("UPDATE_INVENTORY_ALERTS");
	ContainerFrame1.bagsShown = 0;
	ContainerFrame1.bags = {};
end

function ContainerFrame_OnEvent()
	if ( event == "BAG_UPDATE" ) then
		if ( this:IsVisible() and this:GetID() == arg1 ) then
 			ContainerFrame_Update(this);
		end
	elseif ( event == "BAG_CLOSED" ) then
		if ( this:GetID() == arg1 ) then
			this:Hide();
		end
	elseif ( event == "BAG_OPEN" ) then
		if ( this:GetID() == arg1 ) then
			this:Show();
		end
	elseif ( event == "ITEM_LOCK_CHANGED" or event == "BAG_UPDATE_COOLDOWN" or event == "UPDATE_INVENTORY_ALERTS" ) then
		if ( this:IsVisible() ) then
			ContainerFrame_Update(this);
		end
	end
end

function ToggleBag(id)
	local size = GetContainerNumSlots(id);
	if ( size > 0 ) then
		local containerShowing;
		for i=1, NUM_CONTAINER_FRAMES, 1 do
			local frame = getglobal("ContainerFrame"..i);
			if ( frame:IsVisible() and frame:GetID() == id ) then
				containerShowing = i;
				frame:Hide();
			end
		end
		if ( not containerShowing ) then
			if ( CanOpenPanels() ) then
				ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(), size, id);
			else
				if ( UnitIsDead("player") ) then
					NotWhileDeadError();
				end
			end
		end
	end
end

function ToggleBackpack()
	if ( IsBagOpen(0) ) then
		for i=1, NUM_CONTAINER_FRAMES, 1 do
			local frame = getglobal("ContainerFrame"..i);
			if ( frame:IsVisible() ) then
				frame:Hide();
			end
		end
	else
		ToggleBag(0);
	end
end

function ContainerFrame_OnHide()
	if ( this:GetID() == 0 ) then
		MainMenuBarBackpackButton:SetChecked(0);
	else
		local bagButton = getglobal("CharacterBag"..(this:GetID() - 1).."Slot");
		if ( bagButton ) then
			bagButton:SetChecked(0);
		else
			-- If its a bank bag then update its highlight
			
			UpdateBagButtonHighlight(this:GetID()); 
		end
	end
	PlaySound("igBackPackClose");
	ContainerFrame1.bagsShown = ContainerFrame1.bagsShown - 1;
	-- Remove the closed bag from the list and collapse the rest of the entries
	local index = 1;
	while ContainerFrame1.bags[index] do
		if ( ContainerFrame1.bags[index] == this:GetName() ) then
			local tempIndex = index;
			while ContainerFrame1.bags[tempIndex] do
				if ( ContainerFrame1.bags[tempIndex + 1] ) then
					ContainerFrame1.bags[tempIndex] = ContainerFrame1.bags[tempIndex + 1];
				else
					ContainerFrame1.bags[tempIndex] = nil;
				end
				tempIndex = tempIndex + 1;
			end
		end
		index = index + 1;
	end
	updateContainerFrameAnchors();
end

function ContainerFrame_OnShow()
	if ( this:GetID() == 0 ) then
		MainMenuBarBackpackButton:SetChecked(1);
	elseif ( this:GetID() <= NUM_BAG_SLOTS ) then 
		local button = getglobal("CharacterBag"..(this:GetID() - 1).."Slot");
		if ( button ) then
			button:SetChecked(1);
		end
	end
	ContainerFrame1.bagsShown = ContainerFrame1.bagsShown + 1;
end

function OpenBag(id)
	if ( not CanOpenPanels() ) then
		if ( UnitIsDead("player") ) then
			NotWhileDeadError();
		end
		return;
	end

	local size = GetContainerNumSlots(id);
	if ( size > 0 ) then
		local containerShowing;
		for i=1, NUM_CONTAINER_FRAMES, 1 do
			local frame = getglobal("ContainerFrame"..i);
			if ( frame:IsVisible() and frame:GetID() == id ) then
				containerShowing = i;
			end
		end
		if ( not containerShowing ) then
			ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(), size, id);
		end
	end
end

function CloseBag(id)
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = getglobal("ContainerFrame"..i);
		if ( containerFrame:IsVisible() and (containerFrame:GetID() == id) ) then
			containerFrame:Hide();
			return;
		end
	end
end

function IsBagOpen(id)
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = getglobal("ContainerFrame"..i);
		if ( containerFrame:IsVisible() and (containerFrame:GetID() == id) ) then
			return 1;
		end
	end
	return nil;
end

function OpenBackpack()
	if ( not CanOpenPanels() ) then
		if ( UnitIsDead("player") ) then
			NotWhileDeadError();
		end
		return;
	end

	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = getglobal("ContainerFrame"..i);
		if ( containerFrame:IsVisible() and (containerFrame:GetID() == 0) ) then
			ContainerFrame1.backpackWasOpen = 1;
			return;
		else
			ContainerFrame1.backpackWasOpen = nil;
		end
	end

	if ( not ContainerFrame1.backpackWasOpen ) then
		ToggleBackpack();
	end
end

function CloseBackpack()
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = getglobal("ContainerFrame"..i);
		if ( containerFrame:IsVisible() and (containerFrame:GetID() == 0) and (ContainerFrame1.backpackWasOpen == nil) ) then
			containerFrame:Hide();
			return;
		end
	end
end

function ContainerFrame_GetOpenFrame()
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local frame = getglobal("ContainerFrame"..i);
		if ( not frame:IsVisible() ) then
			return frame;
		end
		-- If all frames open return the last frame
		if ( i == NUM_CONTAINER_FRAMES ) then
			frame:Hide();
			return frame;
		end
	end
end

function ContainerFrame_Update(frame)
	local id = frame:GetID();
	local name = frame:GetName();
	for j=1, frame.size, 1 do
		local itemButton = getglobal(name.."Item"..j);
		local texture, itemCount, locked, quality, readable = GetContainerItemInfo(id, itemButton:GetID());
		SetItemButtonTexture(itemButton, texture);
		SetItemButtonCount(itemButton, itemCount);

		SetItemButtonDesaturated(itemButton, locked, 0.5, 0.5, 0.5);
		
		if ( texture ) then
			ContainerFrame_UpdateCooldown(id, itemButton);
		else
			getglobal(name.."Item"..j.."Cooldown"):Hide();
		end

		itemButton.readable = readable;
		--local normalTexture = getglobal(name.."Item"..j.."NormalTexture");
		--if ( quality and quality ~= -1) then
		--	local color = getglobal("ITEM_QUALITY".. quality .."_COLOR");
		--	normalTexture:SetVertexColor(color.r, color.g, color.b);
		--else
		--	normalTexture:SetVertexColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
		--end
		local showSell = nil;
		if ( GameTooltip:IsOwned(itemButton) ) then
			if ( texture ) then
				local hasCooldown, repairCost = GameTooltip:SetBagItem(itemButton:GetParent():GetID(),itemButton:GetID());
				if ( hasCooldown ) then
					itemButton.updateTooltip = TOOLTIP_UPDATE_TIME;
				else
					itemButton.updateTooltip = nil;
				end
				if ( InRepairMode() and (repairCost > 0) ) then
					GameTooltip:AddLine(TEXT(REPAIR_COST), "", 1, 1, 1);
					SetTooltipMoney(GameTooltip, repairCost);
					GameTooltip:Show();
				elseif ( MerchantFrame:IsVisible() and not locked) then
					showSell = 1;
				end
			else
				GameTooltip:Hide();
			end
			if ( showSell ) then
				ShowContainerSellCursor(itemButton:GetParent():GetID(), itemButton:GetID());
			elseif ( readable ) then
				ShowInspectCursor();
			else
				ResetCursor();
			end
		end
	end
end

function ContainerFrame_UpdateCooldown(container, button)
	local cooldown = getglobal(button:GetName().."Cooldown");
	local start, duration, enable = GetContainerItemCooldown(container, button:GetID());
	CooldownFrame_SetTimer(cooldown, start, duration, enable);
	if ( duration > 0 and enable == 0 ) then
		SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4);
	end
end

function ContainerFrame_GenerateFrame(frame, size, id)
	frame.size = size;
	local frameSettings = CONTAINER_FRAME_TABLE[size];
	local name = frame:GetName();
	local bgTexture = getglobal(name.."BackgroundTexture");
	-- if size = 0 then its the backpack
	if ( id == 0 ) then
		frameSettings = CONTAINER_FRAME_TABLE[0];
		getglobal(name.."MoneyFrame"):Show();
	else
		getglobal(name.."MoneyFrame"):Hide();
	end
	getglobal(frame:GetName().."Name"):SetText(GetBagName(id));
	getglobal(frame:GetName().."PortraitButton"):SetID(id);
	local columns = NUM_CONTAINER_COLUMNS;
	local rows = ceil(size / columns);
	frame:SetWidth(CONTAINER_WIDTH);
	frame:SetHeight(frameSettings[4]);
	bgTexture:SetTexture(frameSettings[1]); 
	bgTexture:SetWidth(frameSettings[2]);
	bgTexture:SetHeight(frameSettings[3]);
	frame:SetID(id);
	for j=1, size, 1 do
		local index = size - j + 1;
		local itemButton =getglobal(name.."Item"..j);
		itemButton:SetID(index);
		-- Set first button
		if ( j == 1 ) then
			-- Anchor the first item differently if its the backpack frame
			if ( id == 0 ) then
				itemButton:SetPoint("BOTTOMRIGHT", name, "BOTTOMRIGHT", -11, 30);
			else
				itemButton:SetPoint("BOTTOMRIGHT", name, "BOTTOMRIGHT", -11, 9);
			end
			
		else
			if ( mod((j-1), columns) == 0 ) then
				itemButton:SetPoint("BOTTOMRIGHT", name.."Item"..(j - columns), "TOPRIGHT", 0, 4);	
			else
				itemButton:SetPoint("BOTTOMRIGHT", name.."Item"..(j - 1), "BOTTOMLEFT", -5, 0);	
			end
		end

		local texture, itemCount, locked, quality, readable = GetContainerItemInfo(id, index);
		SetItemButtonTexture(itemButton, texture);
		SetItemButtonCount(itemButton, itemCount);

		SetItemButtonDesaturated(itemButton, locked, 0.5, 0.5, 0.5);

		if ( texture ) then
			ContainerFrame_UpdateCooldown(id, itemButton);
		else
			getglobal(name.."Item"..j.."Cooldown"):Hide();
		end
		--if ( quality and quality ~= -1 ) then
		---	local color = getglobal("ITEM_QUALITY".. quality .."_COLOR");
		--	SetItemButtonNormalTextureVertexColor(itemButton, color.r, color.g, color.b);
		--else
		--	SetItemButtonNormalTextureVertexColor(itemButton, TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
		--end
		itemButton.readable = readable;
		itemButton:Show();
	end
	for j=size + 1, MAX_CONTAINER_ITEMS, 1 do
		getglobal(name.."Item"..j):Hide();
	end
	SetBagPortaitTexture(getglobal(frame:GetName().."Portrait"), id);
	-- Add the bag to the baglist
	ContainerFrame1.bags[ContainerFrame1.bagsShown + 1] = frame:GetName();
	updateContainerFrameAnchors();
	frame:Show();
	PlaySound("igBackPackOpen");
end

function updateContainerFrameAnchors()
	local uiScale = GetCVar("uiscale") + 0;
--	local screenHeight = GetScreenHeight();
	local screenHeight = 768;
	if ( GetCVar("useUiScale") == "1" ) then
		screenHeight = 768 / uiScale;
	end
	local freeScreenHeight = screenHeight - CONTAINER_OFFSET;
	local index = 1;
	local column = 0;
	while ContainerFrame1.bags[index] do
		local frame = getglobal(ContainerFrame1.bags[index]);
		-- freeScreenHeight determines when to start a new column of bags
		if ( index == 1 ) then
			-- First bag
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent():GetName(), "BOTTOMRIGHT", 0, CONTAINER_OFFSET);
		elseif ( freeScreenHeight < frame:GetHeight() ) then
			-- Start a new column
			column = column + 1;
			freeScreenHeight = UIParent:GetHeight() - CONTAINER_OFFSET;
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent():GetName(), "BOTTOMRIGHT", -(column * CONTAINER_WIDTH), CONTAINER_OFFSET);
		else
			-- Anchor to the previous bag
			frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING);	
		end
		freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING;
		index = index + 1;
	end
end


function ContainerFrameItemButton_OnLoad()
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	this:RegisterForDrag("LeftButton");

	this.SplitStack = function(button, split)
		SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
	end
end

function ContainerFrameItemButton_OnClick(button, ignoreShift)
	if ( button == "LeftButton" ) then
		if ( IsShiftKeyDown() and not ignoreShift ) then
			if ( ChatFrameEditBox:IsVisible() ) then
				ChatFrameEditBox:Insert(GetContainerItemLink(this:GetParent():GetID(), this:GetID()));
			else
				local texture, itemCount, locked = GetContainerItemInfo(this:GetParent():GetID(), this:GetID());
				if ( not locked ) then
					this.SplitStack = function(button, split)
						SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
					end
					OpenStackSplitFrame(this.count, this, "BOTTOMRIGHT", "TOPRIGHT");
				end
			end
		else
			PickupContainerItem(this:GetParent():GetID(), this:GetID());
		end
	elseif ( button == "RightButton" ) then
		if ( IsShiftKeyDown() and MerchantFrame:IsVisible() and not ignoreShift ) then
			this.SplitStack = function(button, split)
				SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
				MerchantItemButton_OnClick("LeftButton");
			end
			OpenStackSplitFrame(this.count, this, "BOTTOMRIGHT", "TOPRIGHT");
		else
			UseContainerItem(this:GetParent():GetID(), this:GetID());
		end
	end
end

function ContainerFrameItemButton_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_LEFT");
	local hasCooldown, repairCost = GameTooltip:SetBagItem(this:GetParent():GetID(),this:GetID());
	if ( hasCooldown ) then
		this.updateTooltip = TOOLTIP_UPDATE_TIME;
	else
		this.updateTooltip = nil;
	end
	if ( InRepairMode() and (repairCost and repairCost > 0) ) then
		GameTooltip:AddLine(TEXT(REPAIR_COST), "", 1, 1, 1);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	elseif ( MerchantFrame:IsVisible() ) then
		ShowContainerSellCursor(this:GetParent():GetID(),this:GetID());
	elseif ( this.readable ) then
		ShowInspectCursor();
	end
end

function ContainerFrameItemButton_OnUpdate(elapsed)
	if ( not this.updateTooltip ) then
		return;
	end

	this.updateTooltip = this.updateTooltip - elapsed;
	if ( this.updateTooltip > 0 ) then
		return;
	end

	if ( GameTooltip:IsOwned(this) ) then
		ContainerFrameItemButton_OnEnter();
	else
		this.updateTooltip = nil;
	end
end

function OpenAllBags(forceOpen)
	local bagsOpen = 0;
	local totalBags = 1;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = getglobal("ContainerFrame"..i);
		local bagButton = getglobal("CharacterBag"..(i -1).."Slot");
		if ( (i <= NUM_BAG_FRAMES) and GetContainerNumSlots(bagButton:GetID() - CharacterBag0Slot:GetID() + 1) > 0) then
			totalBags = totalBags + 1;
		end
		if ( containerFrame:IsVisible() ) then
			containerFrame:Hide();
			bagsOpen = bagsOpen + 1;
		end
	end
	
	if ( bagsOpen == totalBags and not forceOpen ) then
		return;
	end
	
	ToggleBackpack();
	ToggleBag(1);
	ToggleBag(2);
	ToggleBag(3);
	ToggleBag(4);
end

function CloseAllBags()
	CloseBackpack();
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		CloseBag(i);
	end
end