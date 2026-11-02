BagSlotItemFlyInMixin = {};

function BagSlotItemFlyInMixin:OnPlay()
	self:GetParent().AnimIcon:Show();
end

function BagSlotItemFlyInMixin:OnFinished()
	self:GetParent().AnimIcon:Hide();
end

BaseBagSlotButtonMixin = {};

function BaseBagSlotButtonMixin:BagSlotOnLoad()
	MainMenuBarBagManager:RegisterBagButton(self);

	self:RegisterEvent("ITEM_PUSH");

	EventRegistry:RegisterCallback("ContainerFrame.CloseBag", self.UpdateBagButtonHighlight, self);
	EventRegistry:RegisterCallback("ContainerFrame.OpenBag", self.UpdateBagButtonHighlight, self);

	self:OnLoadInternal();
end

function BaseBagSlotButtonMixin:OnLoadInternal()
	PaperDollItemSlotButton_OnLoad(self);

	self:RegisterForClicks("AnyUp");

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("BAG_UPDATE_DELAYED");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");

	self.isBag = 1;
	self.maxDisplayCount = 999;
	self.UpdateTooltip = self.BagSlotOnEnter;

	self.Count:ClearAllPoints();
	self.Count:SetPoint("BOTTOMRIGHT", -2, 2);

	self:RegisterBagButtonUpdateItemContextMatching();
end

function BaseBagSlotButtonMixin:BagSlotOnEvent(event, ...)
	if event == "ITEM_PUSH" then
		local bagSlot, iconFileID = ...;
		if self:GetID() == bagSlot then
			self.AnimIcon:SetTexture(iconFileID);
			self.FlyIn:Play(true);
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UpdateBagMatchesSearch();
	elseif event == "BAG_UPDATE_DELAYED" then
		PaperDollItemSlotButton_Update(self);
	elseif event == "INVENTORY_SEARCH_UPDATE" then
		self:UpdateBagMatchesSearch();
	else
		PaperDollItemSlotButton_OnEvent(self, event, ...);
	end
end

function BaseBagSlotButtonMixin:BagSlotOnShow()
	PaperDollItemSlotButton_OnShow(self, true);
end

function BaseBagSlotButtonMixin:BagSlotOnHide()
	PaperDollItemSlotButton_OnHide(self);
end

function BaseBagSlotButtonMixin:BagSlotOnClick(button, down)
	if not KeybindFrames_InQuickKeybindMode() then
		if IsModifiedClick() then
			if IsModifiedClick("OPENALLBAGS") then
				if self:HasBagEquipped() then
					ToggleAllBags();
				end
			end
		else
			if not self:PutItemInBag() then
				ToggleBag(self:GetBagID());
			end
		end
	end
end

function BaseBagSlotButtonMixin:PutItemInBag()
	return PutItemInBag(self:GetID());
end

function BaseBagSlotButtonMixin:BagSlotOnDragStart(button)
	PickupBagFromSlot(self:GetID());
end

function BaseBagSlotButtonMixin:BagSlotOnReceiveDrag()
	self:PutItemInBag();
end

function BaseBagSlotButtonMixin:BagSlotOnEnter()
	EventRegistry:TriggerEvent("BagSlot.OnEnter", self);
	self:OnEnterInternal();
end

function BaseBagSlotButtonMixin:OnEnterInternal()
	if not KeybindFrames_InQuickKeybindMode() then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		if GameTooltip:SetInventoryItem("player", self:GetID()) then
			local bindingKey = self.commandName and GetBindingKey(self.commandName);
			if bindingKey then
				bindingKey = GetBindingText(bindingKey);
				GameTooltip:AppendText(NORMAL_FONT_COLOR:WrapTextInColorCode(" ("..bindingKey..")"));
			end
			local bagID = self:GetBagID();
			if ContainerFrame_CanContainerUseFilterMenu(bagID) then
				local filterList = ContainerFrameSettingsManager:GenerateFilterList(bagID);
				if filterList then
					local wrapText = true;
					GameTooltip_AddNormalLine(GameTooltip, BAG_FILTER_ASSIGNED_TO:format(filterList), wrapText);
				end
			end
		else
			local title = ContainerFrame_IsReagentBag(self:GetBagID()) and EQUIP_CONTAINER_REAGENT or EQUIP_CONTAINER;
			GameTooltip:SetOwner(self, "ANCHOR_LEFT");
			GameTooltip_SetTitle(GameTooltip, title);
		end

		GameTooltip:Show();
	end
end

function BaseBagSlotButtonMixin:BagSlotOnLeave()
	EventRegistry:TriggerEvent("BagSlot.OnLeave", self);
	GameTooltip:Hide();
	ResetCursor();
end

function BaseBagSlotButtonMixin:UpdateBagMatchesSearch()
	self:SetMatchesSearch(not C_Container.IsContainerFiltered(self:GetBagID()));
end

function BaseBagSlotButtonMixin:UpdateBagButtonHighlight(containerFrame)
	-- Gamepad bag buttons manage their own slot highlight.
	if self.UpdateBorderAtlases then
		return;
	end

	if containerFrame:MatchesBagID(self:GetBagID()) then
		self.SlotHighlightTexture:SetShown(containerFrame:IsShown());
	end
end

function BaseBagSlotButtonMixin:GetItemContextMatchResult()
	return ItemButtonUtil.GetItemContextMatchResultForContainer(self:GetBagID());
end

function BaseBagSlotButtonMixin:GetIsBarExpanded()
	return MainMenuBarBagManager:ShouldBarExpand();
end

function BaseBagSlotButtonMixin:GetBagID()
	if ( self:GetID() == Enum.BagIndex.Backpack ) then
		return Enum.BagIndex.Backpack;
	end

	return (self:GetID() - CharacterBag0Slot:GetID()) + 1;
end

function BaseBagSlotButtonMixin:HasBagEquipped()
	-- [NB] TODO: Faster way to look this up?
	return GetInventoryItemTexture("player", self:GetID()) ~= nil;
end

function BackpackButton_OnModifiedClick(self)
	if ( IsModifiedClick("OPENALLBAGS") ) then
		ToggleAllBags();
	end
end

function BaseBagSlotButtonMixin:IsBackpack()
	return false;
end

function BaseBagSlotButtonMixin:IsExtended()
	return false;
end

function BaseBagSlotButtonMixin:UpdateItemContextOverlayTextures(contextMode)
	if contextMode then
		self.ItemContextOverlay:SetColorTexture(0, 0, 0, 0.8);
		self.ItemContextOverlay:SetAllPoints();
	end
end

function BaseBagSlotButtonMixin:SetItemButtonTexture(texture)
	ItemButtonMixin.SetItemButtonTexture(self, texture);
	self:UpdateTextures();
end

function BaseBagSlotButtonMixin:SetItemButtonQuality()
	self:UpdateTextures();
end

function BaseBagSlotButtonMixin:SetBarExpanded(isExpanded)
	self:SetShown(isExpanded);
end

local FREE_SLOTS_FORMAT = "(%s)";

local GAMEPAD_BAG_SLOT_BORDER_ATLASES = {
	expanded = {
		normal = "BagSlotFrame_Expanded_Default",
		pushed = "BagSlotFrame_Expanded_Pushed_",
		disabled = "BagSlotFrame_Expanded_Disabled",
		highlight = "BagSlotFrame_Expanded_Hover",
	},
	collapsed = {
		normal = "BagSlotFrame_Collapsed_Default",
		pushed = "BagSlotFrame_Collapsed_Pushed",
		disabled = "BagSlotFrame_Collapsed_Disabled",
		highlight = "BagSlotFrame_Collapsed_Hover",
	},
};

GamepadBagSlotMixin = {};

function GamepadBagSlotMixin:HasBag()
	if self:IsBackpack() or self:GetBagID() == KEYRING_CONTAINER then
		return true;
	end

	return self:HasBagEquipped();
end

function GamepadBagSlotMixin:UpdateBorderAtlases()
	local hasBag = self:HasBag();
	local useCollapsed = hasBag and self.isCollapsed;
	local atlases = useCollapsed and GAMEPAD_BAG_SLOT_BORDER_ATLASES.collapsed or GAMEPAD_BAG_SLOT_BORDER_ATLASES.expanded;
	-- Empty slots keep the default normal atlas that UpdateTextures already applied.
	if hasBag then
		self:GetNormalTexture():SetAtlas(atlases.normal);
		self:GetPushedTexture():SetAtlas(atlases.pushed);
		self:GetDisabledTexture():SetAtlas(atlases.disabled);
		self:GetHighlightTexture():SetAtlas(atlases.highlight);
	end

	self.SlotHighlightTexture:SetShown(not hasBag);

	self:UpdateItemCount();
end

function GamepadBagSlotMixin:IsAmmunitionBag()
	if self:IsBackpack() then
		return false;
	end

	local itemID = GetInventoryItemID("player", self:GetID());
	if itemID ~= self.ammunitionBagItemID then
		self.ammunitionBagItemID = itemID;
		local classID = itemID and select(6, C_Item.GetItemInfoInstant(itemID));
		self.isAmmunitionBag = classID == Enum.ItemClass.Quiver;
	end

	return self.isAmmunitionBag or false;
end

function GamepadBagSlotMixin:UpdateItemCount()
	local isAmmunitionBag = self:IsAmmunitionBag();
	-- SetItemButtonCount hides counts at or below minDisplayCount, so lower it to show 0 ammo.
	self.minDisplayCount = isAmmunitionBag and -1 or nil;

	if isAmmunitionBag or self:GetBagID() == KEYRING_CONTAINER or not self:HasBag() then
		return;
	end

	self.Count:SetText(FREE_SLOTS_FORMAT:format(C_Container.GetContainerNumFreeSlots(self:GetBagID())));
	self.Count:Show();
end

function GamepadBagSlotMixin:TryOpenBagMenu(button)
	if button ~= "RightButton" then
		return false;
	end

	if self:HasBag() and not CursorHasItem() then
		self.BagDropdownButton:OpenMenu();
	end

	return true;
end

GamepadBagBarMixin = {};

function GamepadBagBarMixin:GetBagButton(bagID)
	if not InputUtil.IsGamepadUIEnabled() then
		return nil;
	end
	if bagID == KEYRING_CONTAINER and GetCVarBool("showKeyring") then
		return self.KeyRingButton;
	end
	return self.BagButtonArray[bagID + 1];
end

function GamepadBagBarMixin:OnLoad()
	for bagID = 0, NUM_TOTAL_BAG_FRAMES do
		local gamepadBagButton = self:GetBagButton(bagID);
		if gamepadBagButton then
			gamepadBagButton.BagDropdownButton:ClearAllPoints();
			gamepadBagButton.BagDropdownButton:SetPoint("TOPRIGHT", gamepadBagButton, "TOPRIGHT", 0, 0);
			gamepadBagButton.BagDropdownButton:SetMouseClickEnabled(false);
			gamepadBagButton.BagDropdownButton:SetMouseMotionEnabled(false);
			gamepadBagButton.BagDropdownButton:SetupMenu(function(dropdown, rootDescription)
				ContainerFrame_AddButtons_BagFilters(rootDescription, bagID);
				ContainerFrame_AddButtons_BagCleanup(rootDescription, bagID);

				if (bagID > 0) then
					rootDescription:CreateDivider();
					rootDescription:CreateButton(CONTEXT_ACTION_LABEL_UNEQUIP_BAG, function()
						local index = C_Container.ContainerIDToInventoryID(bagID);
						PickupBagFromSlot(index);
						for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
							if i ~= bagID then
								local freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(i);
								local gamepadBag = freeSlots and freeSlots > 0 and bagFamily == 0 and self:GetBagButton(i);
								if gamepadBag then
									if i == BACKPACK_CONTAINER then
										PutItemInBackpack();
									else
										PutItemInBag(gamepadBag:GetID(), false);
									end
									return;
								end
							end
						end
						PutItemInBackpack();
					end);
				end
			end);
			if not InputUtil.IsGamepadUIEnabled() then
				gamepadBagButton:Hide();
			end
		end
	end
	local gamepadkeyRingButton = GamepadBagBar and GamepadBagBar:GetBagButton(KEYRING_CONTAINER);
	if gamepadkeyRingButton then
		gamepadkeyRingButton.isCollapsed = true;
		gamepadkeyRingButton:UpdateBorderAtlases();
	end
end

GamepadBagSlotButtonMixin = CreateFromMixins(BaseBagSlotButtonMixin);

function GamepadBagSlotButtonMixin:BagSlotOnLoad()
	-- We don't want to be registered to the MainMenuBarBagManager
	self:RegisterEvent("ITEM_PUSH");

	self:OnLoadInternal();
end

function GamepadBagSlotButtonMixin:BagSlotOnClick(button, down)
	if self:TryOpenBagMenu(button) then
		return;
	end

	if CursorHasItem() then
		self:PutItemInBag();
	else
		PickupBagFromSlot(self:GetID());
	end
end

MainMenuBarBackpackMixin = CreateFromMixins(BaseBagSlotButtonMixin);

function MainMenuBarBackpackMixin:BagSlotOnShow()
	-- Only here to prevent base object behavior
end

function MainMenuBarBackpackMixin:BagSlotOnHide()
	-- Only here to prevent base object behavior
end

function MainMenuBarBackpackMixin:OnLoadInternal()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("AZERITE_EMPOWERED_ITEM_LOOTED");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");
	self:RegisterEvent("CVAR_UPDATE");

	self:UpdateTextures();
	self.FreeSlots:ClearAllPoints();
	self.FreeSlots:SetPoint("CENTER", 0, -10);
end

function MainMenuBarBackpackMixin:OnEnterInternal()
	if not KeybindFrames_InQuickKeybindMode() then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip_SetTitle(GameTooltip, BACKPACK_TOOLTIP);

		local keyBinding = GetBindingKey("TOGGLEBACKPACK");
		if keyBinding then
			keyBinding = GetBindingText(keyBinding);
			GameTooltip:AppendText(NORMAL_FONT_COLOR:WrapTextInColorCode(" ("..keyBinding..")"));
		end

		GameTooltip:AddLine(NUM_FREE_SLOTS:format(self.freeSlots or 0));
		GameTooltip:Show();
	end
end

function MainMenuBarBackpackMixin:PutItemInBag()
	return PutItemInBackpack();
end

function MainMenuBarBackpackMixin:HasBagEquipped()
	return true;
end

function MainMenuBarBackpackMixin:BackpackOnEvent(event, ...)
	if event == "BAG_UPDATE" then
		local bag = ...;
		self:OnBagUpdate(bag);
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:OnPlayerEnteringWorld();
	elseif event == "AZERITE_EMPOWERED_ITEM_LOOTED" then
		self:OnAzeriteEmpoweredItemLooted();
	elseif event == "CVAR_UPDATE" then
		local cvar = ...;
		if cvar == "displayFreeBagSlots" then
			self:SetCountShown(GetCVar("displayFreeBagSlots") == "1");
		end
	end
end

function MainMenuBarBackpackMixin:UpdateFreeSlots()
	local totalFree = C_Container.CalculateTotalNumberOfFreeBagSlots();
	if totalFree == 3 then
		TriggerTutorial(59);
	elseif totalFree == 0 then
		TriggerTutorial(58);
	end

	self.freeSlots = totalFree;
	self.FreeSlots:SetText(FREE_SLOTS_FORMAT:format(totalFree));
end

function MainMenuBarBackpackMixin:SetCountShown(shown)
	self.FreeSlots:SetShown(shown);
end

function MainMenuBarBackpackMixin:OnBagUpdate(bagID)
	if bagID >= BACKPACK_CONTAINER and bagID <= NUM_TOTAL_EQUIPPED_BAG_SLOTS then
		C_Timer.After(0, function() self:UpdateFreeSlots(); end); -- Do it one frame later to avoid race conditions when moving bags around
	end
end

function MainMenuBarBackpackMixin:OnPlayerEnteringWorld()
	self:SetCountShown(GetCVar("displayFreeBagSlots") == "1");
	self:UpdateFreeSlots();
end

function MainMenuBarBackpackMixin:OnAzeriteEmpoweredItemLooted()
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

			for i, bagButton in MainMenuBarBagManager:EnumerateBagButtons() do
				if AzeriteUtil.DoesBagContainAnyAzeriteEmpoweredItems(bagButton:GetBagID()) then
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

function MainMenuBarBackpackMixin:IsBackpack()
	return true;
end

function MainMenuBarBackpackMixin:UpdateItemContextOverlayTextures(contextMode)
	if contextMode then
		self.ItemContextOverlay:SetColorTexture(0, 0, 0, 0.8);

		local mask;
		if (self.buttonShape == "circle") then
			mask = self.CircleMask;
		elseif (self.buttonShape == "square") then
			mask = self.SquareMask;
		end

		mask:ClearAllPoints();
		mask:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4);
		mask:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -6, 6);
	end
end

function MainMenuBarBackpackMixin:SetBarExpanded(isExpanded)
	-- Remains shown regardless of expand state
end

function MainMenuBarBackpackMixin:BagSlotOnDragStart(button)
	-- prevent pick up
end

GamepadBackpackButtonMixin = CreateFromMixins(MainMenuBarBackpackMixin);

function GamepadBackpackButtonMixin:SetCountShown()
	-- Free slots will be handled by UpdateItemCount.
end

function GamepadBackpackButtonMixin:BagSlotOnLoad()
	-- We don't want to be registered to the MainMenuBarBagManager
	self:RegisterEvent("ITEM_PUSH");

	EventRegistry:RegisterCallback("ContainerFrame.CloseBag", self.UpdateBagButtonHighlight, self);
	EventRegistry:RegisterCallback("ContainerFrame.OpenBag", self.UpdateBagButtonHighlight, self);

	self:UpdateItemContextMatching();
	self:OnLoadInternal();
end

function GamepadBackpackButtonMixin:BagSlotOnClick(button, down)
	if self:TryOpenBagMenu(button) then
		return;
	end

	if CursorHasItem() then
		self:PutItemInBag();
	end
end

CharacterReagentBagMixin = {};

function CharacterReagentBagMixin:SetBarExpanded(isExpanded)
	-- Remains shown regardless of expand state
end

GamepadCharacterReagentBagMixin = CreateFromMixins(CharacterReagentBagMixin)

function GamepadCharacterReagentBagMixin:BagSlotOnLoad()
	-- We don't want to be registered to the MainMenuBarBagManager
	self:RegisterEvent("ITEM_PUSH");

	EventRegistry:RegisterCallback("ContainerFrame.CloseBag", self.UpdateBagButtonHighlight, self);
	EventRegistry:RegisterCallback("ContainerFrame.OpenBag", self.UpdateBagButtonHighlight, self);

	self:OnLoadInternal();
end

function GamepadCharacterReagentBagMixin:BagSlotOnClick(button, down)
	if self:TryOpenBagMenu(button) then
		return;
	end

	if CursorHasItem() then
		self:PutItemInBag();
	else
		PickupBagFromSlot(self:GetID());
	end
end

BagBarExpandToggleMixin = {};

function BagBarExpandToggleMixin:OnClick()
	MainMenuBarBagManager:ToggleExpandBar();
end

function BagBarExpandToggleMixin:GetRotation()
	local isExpanded = MainMenuBarBagManager:ShouldBarExpand();
	if BagsBar:IsHorizontal() then
		local leftRotation = 0;
		local rightRotation = math.pi;
		if BagsBar:IsDirectionLeft() then
			return isExpanded and rightRotation or leftRotation;
		else
			return isExpanded and leftRotation or rightRotation;
		end
	else -- vertical bags bar
		local upRotation = 3 * math.pi / 2;
		local downRotation = math.pi / 2;
		if BagsBar:IsDirectionUp() then
			return isExpanded and downRotation or upRotation;
		else
			return isExpanded and upRotation or downRotation;
		end
	end
end

function BagBarExpandToggleMixin:UpdateOrientation()
	local rotation = self:GetRotation();
	self:GetNormalTexture():SetRotation(rotation);
	self:GetPushedTexture():SetRotation(rotation);
	self:GetHighlightTexture():SetRotation(rotation);
end
