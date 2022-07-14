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

	self:RegisterEvent("BAG_UPDATE_DELAYED");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");

	self.isBag = 1;
	self.maxDisplayCount = 999;
	self.UpdateTooltip = self.BagSlotOnEnter;

	self.NormalTexture:SetSize(50, 50);
	self.IconBorder:SetSize(30, 30);

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
	elseif event == "BAG_UPDATE_DELAYED" then
		PaperDollItemSlotButton_Update(self);
	elseif event == "INVENTORY_SEARCH_UPDATE" then
		self:SetMatchesSearch(not IsContainerFiltered(self:GetBagID()));
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
			local bindingKey = GetBindingKey(self.commandName);
			if bindingKey then
				bindingKey = GetBindingText(bindingKey);
				GameTooltip:AppendText(NORMAL_FONT_COLOR:WrapTextInColorCode(" ("..bindingKey..")"));
			end
			local bagID = self:GetBagID();
			if not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(bagID)) then
				for i, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
					if C_Container.GetBagSlotFlag(bagID, flag) then
						GameTooltip:AddLine(BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[flag]));
						break;
					end
				end
			end
		else
			GameTooltip_SetTitle(GameTooltip, EQUIP_CONTAINER);
		end

		GameTooltip:Show();
	end
end

function BaseBagSlotButtonMixin:BagSlotOnLeave()
	EventRegistry:TriggerEvent("BagSlot.OnLeave", self);
	GameTooltip:Hide();
	ResetCursor();
end

function BaseBagSlotButtonMixin:UpdateBagButtonHighlight(containerFrame)
	local isMatchingContainer = containerFrame:IsCombinedBagContainer() or (self:GetBagID() == containerFrame:GetBagID());
	if isMatchingContainer then
		self.SlotHighlightTexture:SetShown(containerFrame:IsShown());
	end
end

function BaseBagSlotButtonMixin:GetItemContextMatchResult()
	return ItemButtonUtil.GetItemContextMatchResultForContainer(self:GetBagID());
end

function BaseBagSlotButtonMixin:GetBagID()
	if ( self:GetID() == 0 ) then
		return 0;
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

MainMenuBarBackpackMixin = CreateFromMixins(BaseBagSlotButtonMixin);

function MainMenuBarBackpackMixin:BagSlotOnShow()
	-- Only here to prevent base object behavior
end

function MainMenuBarBackpackMixin:BagSlotOnHide()
	-- Only here to prevent base object behavior
end

function MainMenuBarBackpackMixin:OnLoadInternal()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("AZERITE_EMPOWERED_ITEM_LOOTED");

	self.icon:SetAtlas("hud-backpack");
	self.icon:Show();

	self.NormalTexture:SetSize(64, 64);
	self.Count:ClearAllPoints();
	self.Count:SetPoint("CENTER", 0, -10);
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
	elseif ( event == "CVAR_UPDATE" ) then
		local cvar, value = ...;
		self:OnCVarUpdate(cvar, value);
	elseif event == "AZERITE_EMPOWERED_ITEM_LOOTED" then
		self:OnAzeriteEmpoweredItemLooted();
	end
end

local BACKPACK_FREESLOTS_FORMAT = "(%s)";

function CalculateTotalNumberOfFreeBagSlots()
	local totalFree, freeSlots, bagFamily = 0;
	for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		freeSlots, bagFamily = GetContainerNumFreeSlots(i);
		if ( bagFamily == 0 ) then
			totalFree = totalFree + freeSlots;
		end
	end

	return totalFree;
end

function MainMenuBarBackpackMixin:UpdateFreeSlots()
	local totalFree = CalculateTotalNumberOfFreeBagSlots();
	if totalFree == 3 then
		TriggerTutorial(59);
	elseif totalFree == 0 then
		TriggerTutorial(58);
	end

	self.freeSlots = totalFree;
	self.Count:SetText(BACKPACK_FREESLOTS_FORMAT:format(totalFree));
end

function MainMenuBarBackpackMixin:SetCountShown(shown)
	self.Count:SetShown(shown);
end

function MainMenuBarBackpackMixin:OnBagUpdate(bagID)
	if bagID >= BACKPACK_CONTAINER and bagID <= NUM_TOTAL_EQUIPPED_BAG_SLOTS then
		self:UpdateFreeSlots()
	end
end

function MainMenuBarBackpackMixin:OnPlayerEnteringWorld()
	self:SetCountShown(GetCVarBool("displayFreeBagSlots"));
	self:UpdateFreeSlots();
end

function MainMenuBarBackpackMixin:OnCVarUpdate(cvar, value)
	-- [NB] TODO: Check if this is broken, it's probably been broken for a long time
	if cvar == "DISPLAY_FREE_BAG_SLOTS" then
		self:SetCountShown(value == "1");
	end
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

BagBarExpandToggleMixin = {};

function BagBarExpandToggleMixin:OnLoad()
	EventRegistry:RegisterCallback("MainMenuBarManager.OnExpandChanged", function(owner, manager)
		self:OnExpandChanged(manager:IsBarUserExpanded());
	end, self);

	EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", function()
		self:OnExpandChanged(GetCVarBool("expandBagBar"));
		EventRegistry:UnregisterFrameEventAndCallback("VARIABLES_LOADED", self);
	end, self);
end

function BagBarExpandToggleMixin:OnClick()
	MainMenuBarBagManager:ToggleExpandBar();
end

function BagBarExpandToggleMixin:OnExpandChanged(expanded)
	local rotation = expanded and math.pi or 0;
	self:GetNormalTexture():SetRotation(rotation);
	self:GetPushedTexture():SetRotation(rotation);
	self:GetHighlightTexture():SetRotation(rotation);
end