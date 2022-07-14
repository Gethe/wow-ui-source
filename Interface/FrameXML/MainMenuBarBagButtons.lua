local allBagButtons = {};

BagSlotMixin = {};

function BagSlotMixin:GetItemContextMatchResult()
	return ItemButtonUtil.GetItemContextMatchResultForContainer(self:GetBagID());
end

function BagSlotMixin:GetBagID()
	if ( self:GetID() == 0 ) then
		return 0;
	end

	return (self:GetID() - CharacterBag0Slot:GetID()) + 1;
end

function BagSlotButton_OnClick(self)
	local id = self:GetID();
	local translatedID = self:GetBagID();
	local hadItem = PutItemInBag(id);
	if ( not hadItem ) then
		ToggleBag(translatedID);
	end
end

function BagSlotButton_OnModifiedClick(self)
	if ( IsModifiedClick("OPENALLBAGS") ) then
		if ( GetInventoryItemTexture("player", self:GetID()) ) then
			ToggleAllBags();
		end
	end
end

function BagSlotButton_OnDrag(self)
	PickupBagFromSlot(self:GetID());
end

function BackpackButton_OnClick(self)
	if ( not PutItemInBackpack() ) then
		ToggleBackpack();
	end
end

function BackpackButton_OnModifiedClick(self)
	if ( IsModifiedClick("OPENALLBAGS") ) then
		ToggleAllBags();
	end
end

function BagSlotButton_OnLoad(self)
	table.insert(allBagButtons, self);

	ItemAnim_OnLoad(self)
	PaperDollItemSlotButton_OnLoad(self);
	self:RegisterEvent("BAG_UPDATE_DELAYED");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");
	self.isBag = 1;
	self.UpdateTooltip = BagSlotButton_OnEnter;
	_G[self:GetName().."NormalTexture"]:SetWidth(50);
	_G[self:GetName().."NormalTexture"]:SetHeight(50);
	self.IconBorder:SetSize(30, 30);
	_G[self:GetName().."Count"]:SetPoint("BOTTOMRIGHT", -2, 2);
	self.maxDisplayCount = 999;
end

function BagSlotButton_OnEvent(self, event, ...)
	ItemAnim_OnEvent(self, event, ...);
	if ( event == "BAG_UPDATE_DELAYED" ) then
		PaperDollItemSlotButton_Update(self);
	elseif ( event == "INVENTORY_SEARCH_UPDATE" ) then
		self:SetMatchesSearch(not IsContainerFiltered(self:GetBagID()));
	else
		PaperDollItemSlotButton_OnEvent(self, event, ...);
	end
end

function BagSlotButton_OnEnter(self)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		if ( GameTooltip:SetInventoryItem("player", self:GetID()) ) then
			local bagID = self:GetBagID();
			local bindingID = 4 - bagID + 1;
			local bindingKey = GetBindingKey("TOGGLEBAG"..bindingID);
			if ( bindingKey ) then
				GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..bindingKey..")"..FONT_COLOR_CODE_CLOSE);
			end
			local bagID = self:GetBagID();
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
end

function BagSlotButton_OnLeave(self)
	GameTooltip:Hide();
	ResetCursor();
end

function ItemAnim_OnLoad(self)
	self:RegisterEvent("ITEM_PUSH");
end

function ItemAnim_OnEvent(self, event, ...)
	if ( event == "ITEM_PUSH" ) then
		local bagSlot, iconFileID = ...;
		local id = self:GetID();
		if ( id == bagSlot ) then
			self.animIcon:SetTexture(iconFileID);
			self.flyin:Play(true);
		end
	end
end

function ItemAnim_OnAnimFinished(self)
	self:Hide();
end

function Disable_BagButtons()
	for i, bagButton in ipairs(allBagButtons) do
		bagButton:Disable();
		SetDesaturation(bagButton.icon, true);
	end
end

function Enable_BagButtons()
	for i, bagButton in ipairs(allBagButtons) do
		bagButton:Enable();
		SetDesaturation(bagButton.icon, false);
	end
end

function MainMenuBarBackpackButton_OnLoad(self)
	table.insert(allBagButtons, self);

	ItemAnim_OnLoad(self)
	self:RegisterForClicks("AnyUp");
	MainMenuBarBackpackButtonIconTexture:SetAtlas("hud-backpack", false);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");
	self:RegisterEvent("AZERITE_EMPOWERED_ITEM_LOOTED");
	_G[self:GetName().."NormalTexture"]:SetWidth(64);
	_G[self:GetName().."NormalTexture"]:SetHeight(64);
	_G[self:GetName().."Count"]:ClearAllPoints();
	_G[self:GetName().."Count"]:SetPoint("CENTER", 0, -10);
end

function MainMenuBarBackpackButton_OnClick(self, button)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		if ( IsModifiedClick() ) then
			BackpackButton_OnModifiedClick(self, button);
		else
			BackpackButton_OnClick(self, button);
		end
	end
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
		self:SetMatchesSearch(not IsContainerFiltered(BACKPACK_CONTAINER));
	elseif ( event == "AZERITE_EMPOWERED_ITEM_LOOTED" ) then
		if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_AZERITE_ITEM_IN_BAG) then
			if AzeriteUtil.AreAnyAzeriteEmpoweredItemsEquipped() then
				SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_AZERITE_ITEM_IN_BAG, true);
				return;
			end

			if HelpTip:IsShowing(self, AZERITE_TUTORIAL_ITEM_IN_BAG) then
				return;
			end

			C_Timer.After(.5, function()
				if HelpTip:IsShowing(self, AZERITE_TUTORIAL_ITEM_IN_BAG) then
					return;
				end

				for i, bagButton in ipairs(allBagButtons) do
					local bagID = i - 1;
					if AzeriteUtil.DoesBagContainAnyAzeriteEmpoweredItems(bagID) then
						local helpTipInfo = {
							text = AZERITE_TUTORIAL_ITEM_IN_BAG,
							buttonStyle = HelpTip.ButtonStyle.Close,
							cvarBitfield = "closedInfoFrames",
							bitfieldFlag = LE_FRAME_TUTORIAL_AZERITE_ITEM_IN_BAG,
							targetPoint = HelpTip.Point.LeftEdgeCenter,
							offsetX = 8,
							onHideCallback = function() MainMenuMicroButton_SetAlertsEnabled(true, "backpack"); end,
						};
						MainMenuMicroButton_SetAlertsEnabled(false, "backpack");
						HelpTip:Show(self, helpTipInfo, bagButton);
						break;
					end
				end
			end);
		end
	end
end

function MainMenuBarBackpackButton_OnEnter(self)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetText(BACKPACK_TOOLTIP, 1.0, 1.0, 1.0);
		local keyBinding = GetBindingKey("TOGGLEBACKPACK");
		if ( keyBinding ) then
			GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..keyBinding..")"..FONT_COLOR_CODE_CLOSE);
		end
		GameTooltip:AddLine(string.format(NUM_FREE_SLOTS, (self.freeSlots or 0)));
		GameTooltip:Show();
	end
end

function MainMenuBarBackpackButton_OnLeave(self)
	GameTooltip:Hide();
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

	MainMenuBarBackpackButtonCount:SetText(string.format(BACKPACK_FREESLOTS_FORMAT, totalFree));
end