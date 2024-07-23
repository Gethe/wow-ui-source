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
			local bindingKey = GetBindingKey(self.commandName);
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

function BaseBagSlotButtonMixin:GetSlotAtlases()
	return "bag-border", "bag-border-empty", "bag-border-highlight";
end

function BaseBagSlotButtonMixin:UpdateItemContextOverlayTextures(contextMode)
	if contextMode then
		self.ItemContextOverlay:SetColorTexture(0, 0, 0, 0.8);
		self.ItemContextOverlay:SetAllPoints();
	end
end

function BaseBagSlotButtonMixin:UpdateTextures()
	local size = ContainerFrame_GetContainerNumSlots(self:GetBagID());
	local bagSlotAtlas, bagSlotEmptyAtlas, bagSlotHighlight = self:GetSlotAtlases();
	local atlas = (size and size > 0) and bagSlotAtlas or bagSlotEmptyAtlas;

	local normalTexture = self:GetNormalTexture();
	normalTexture:SetAllPoints(self);
	normalTexture:SetAtlas(atlas);

	local pushedTexture = self:GetPushedTexture();
	pushedTexture:SetAllPoints(self);
	pushedTexture:SetAtlas(atlas);

	local highlight = self:GetHighlightTexture();
	highlight:SetAllPoints(self);
	highlight:SetBlendMode("ADD");
	highlight:SetAlpha(.4);
	highlight:SetAtlas(bagSlotHighlight);

	self.SlotHighlightTexture:SetAtlas(bagSlotHighlight);
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

	self:UpdateTextures();
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
	elseif event == "AZERITE_EMPOWERED_ITEM_LOOTED" then
		self:OnAzeriteEmpoweredItemLooted();
	end
end

local BACKPACK_FREESLOTS_FORMAT = "(%s)";

function CalculateTotalNumberOfFreeBagSlots()
	local totalFree, freeSlots, bagFamily = 0;
	for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(i);
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
	self:SetCountShown(true);
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

function MainMenuBarBackpackMixin:GetSlotAtlases()
	return "bag-main", "bag-main", "bag-main-highlight";
end

function MainMenuBarBackpackMixin:UpdateItemContextOverlayTextures(contextMode)
	if contextMode then
		self.ItemContextOverlay:SetColorTexture(0, 0, 0, 0.8);

		local mask = self.CircleMask;
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

CharacterReagentBagMixin = {};

function CharacterReagentBagMixin:GetSlotAtlases()
	return "bag-reagent-border", "bag-reagent-border-empty", "bag-border-highlight";
end

function CharacterReagentBagMixin:SetBarExpanded(isExpanded)
	-- Remains shown regardless of expand state
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

BagsBarMixin = {};

function BagsBarMixin:OnLoad()
	self.initialWidth = self:GetWidth();
	self.initialHeight = self:GetHeight();

	self.bagBarExpandToggleInitialWidth = BagBarExpandToggle:GetWidth();
	self.bagBarExpandToggleInitialHeight = BagBarExpandToggle:GetHeight();

	if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.Bags) then
		self:Hide();
		return;
	end

	EventUtil.ContinueOnVariablesLoaded(GenerateClosure(self.Layout, self));
	EventRegistry:RegisterCallback("MainMenuBarManager.OnExpandChanged", self.Layout, self);
end

function BagsBarMixin:GetBagButtonAnchorPoints()
	-- Returns Point, RelativePoint
	if self:IsHorizontal() then
		if self:IsDirectionLeft() then
			return "RIGHT", "LEFT";
		else
			return "LEFT", "RIGHT";
		end
	else
		if self:IsDirectionUp() then
			return "BOTTOM", "TOP";
		else
			return "TOP", "BOTTOM";
		end
	end
end

function BagsBarMixin:Layout()
	-- Set bar and toggle button size based on orientation
	if self:IsHorizontal() then
		self:SetSize(self.initialWidth, self.initialHeight);
		BagBarExpandToggle:SetSize(self.bagBarExpandToggleInitialWidth, self.bagBarExpandToggleInitialHeight);
	else
		-- Swap width/height for vertical bags bar since the bar is horizontal by default
		self:SetSize(self.initialHeight, self.initialWidth);
		BagBarExpandToggle:SetSize(self.bagBarExpandToggleInitialHeight, self.bagBarExpandToggleInitialWidth);
	end

	-- Get new bag anchor points
	local point, relativePoint = self:GetBagButtonAnchorPoints();

	-- Setup backpack button anchor
	MainMenuBarBackpackButton:ClearAllPoints();
	MainMenuBarBackpackButton:SetPoint(point, self, point);

	-- Update expand button
	BagBarExpandToggle:UpdateOrientation();
	BagBarExpandToggle:ClearAllPoints();
	BagBarExpandToggle:SetPoint(point, MainMenuBarBackpackButton, relativePoint);

	-- Update other bag button anchors
	local anchorRelativeTo = BagBarExpandToggle;
	for i, bagButton in MainMenuBarBagManager:EnumerateBagButtons() do
		if bagButton:IsShown() and bagButton ~= MainMenuBarBackpackButton then
			bagButton:ClearAllPoints();
			bagButton:SetPoint(point, anchorRelativeTo, relativePoint);
			anchorRelativeTo = bagButton;
		end
	end
end

function BagsBarMixin:IsHorizontal()
	return self.isHorizontal;
end

function BagsBarMixin:IsDirectionLeft()
	return self:IsHorizontal() and self.direction == Enum.BagsDirection.Left;
end

function BagsBarMixin:IsDirectionUp()
	return not self:IsHorizontal() and self.direction == Enum.BagsDirection.Up;
end