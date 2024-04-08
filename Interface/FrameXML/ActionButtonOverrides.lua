
-- TODO:: WoWLabs temp reintegration changes, let's figure out a better way to support this.
if C_GameModeManager.GetCurrentGameMode() == Enum.GameMode.Plunderstorm then
	local WOWLABS_ACTIONBUTTON_MAP = {
		[61] = { ["INVSLOT"] = INVSLOT_OFFENSIVE_1,	["FRAME"] = "MultiBarBottomLeftButton1"		},
		[62] = { ["INVSLOT"] = INVSLOT_OFFENSIVE_2,	["FRAME"] = "MultiBarBottomLeftButton2"		},
		[49] = { ["INVSLOT"] = INVSLOT_UTILITY_1,	["FRAME"] = "MultiBarBottomRightButton1"	},
		[50] = { ["INVSLOT"] = INVSLOT_UTILITY_2,	["FRAME"] = "MultiBarBottomRightButton2"	},
	};

	function IsOnPrimaryActionBar(action)
		return action >= 1 and action <= NUM_ACTIONBAR_BUTTONS;
	end

	ActionBarButtonEventsDerivedFrameMixin = CreateFromMixins(ActionBarButtonEventsFrameMixin);

	function ActionBarButtonEventsDerivedFrameMixin:OnLoad()
		ActionBarButtonEventsFrameMixin.OnLoad(self);
		self:RegisterEvent("ACTIONBAR_SHOWGRID");
		self:RegisterEvent("ACTIONBAR_HIDEGRID");
		self:RegisterEvent("PLAYER_EQUIPED_SPELLS_CHANGED");
		self:RegisterEvent("PLAYER_LOGIN");
		self:RegisterEvent("SPECTATE_BEGIN");
		self:RegisterEvent("SPECTATE_END");
		self:RegisterEvent("WORLD_LOOT_OBJECT_SWAP_INVENTORY_TYPE_UPDATED");
	end

	ActionBarActionButtonDerivedMixin = CreateFromMixins(ActionBarActionButtonMixin);
	function ActionBarActionButtonDerivedMixin:OnLoad()
		ActionBarActionButtonMixin.OnLoad(self);
		self:SetAttribute("showgrid", 1);
		self.initialFlyout = false;

		self.RarityPipBackground = self:CreateTexture(nil, "BACKGROUND");
		self.RarityPipBackground:ClearAllPoints();
		self.RarityPipBackground:SetPoint("CENTER");
		self.RarityPipBackground:SetScale(0.69);
		self.RarityPipBackground:SetAtlas("plunderstorm-actionbar-slot-pipbackground", TextureKitConstants.UseAtlasSize);
		self.RarityPipBackground:Hide();

		self.RarityPipContainer = CreateFrame("Frame", nil, self, "HorizontalLayoutFrame");
		self.RarityPipContainer:SetScale(0.69);
		self.RarityPipContainer.spacing = 2;
		self.RarityPipContainer:SetPoint("BOTTOM", self.RarityPipBackground, "BOTTOM", 0, 2);

		self:SetButtonArt();
	end

	function ActionBarActionButtonDerivedMixin:UpdateButtonArt()
		-- Intentionally override to nothing. We want to update from :SetButtonArt and :UpdateBorder.
	end

	function ActionBarActionButtonDerivedMixin:SetButtonArt()
		if not self.SlotArt then
			return;
		end

		self.SlotArt:Hide();
		self.SlotBackground:Show();
		self.SlotBackground:SetAtlas("plunderstorm-actionbar-slot-background");
		self.SlotBackground:SetPoint("TOPLEFT", -8, 8);
		self.SlotBackground:SetPoint("BOTTOMRIGHT", 8, -8);

		self:SetNormalAtlas("plunderstorm-actionbar-slot-border");
		self.NormalTexture:SetDrawLayer("OVERLAY");
		self.NormalTexture:SetSize(60, 60);
		self.NormalTexture:SetPoint("TOPLEFT", -8, 8);
	end

	function ActionBarActionButtonDerivedMixin:UpdatePressAndHoldAction()
		self.pressAndHoldAction = false;

		if self.action then
			local actionType, id = GetActionInfo(self.action);
			if actionType == "spell" then
				self.pressAndHoldAction = IsPressHoldReleaseSpell(id);
			elseif actionType == "macro" then
				local spellID = GetMacroSpell(id);
				if spellID then
					self.pressAndHoldAction = IsPressHoldReleaseSpell(spellID);
				end
			end
		end

		self:SetAttribute("pressAndHoldAction", self.pressAndHoldAction);
	end

	function ActionBarActionButtonDerivedMixin:Update()
		local action = self.action;
		local icon = self.icon;
		local buttonCooldown = self.cooldown;
		local texture = GetActionTexture(action);

		if (self.action == 1) or (self.action == 2) then
			if not self.ActionButtonCorners then
				self.ActionButtonCorners = self:CreateTexture(nil, "OVERLAY");
				self.ActionButtonCorners:SetPoint("CENTER");
				self.ActionButtonCorners:SetScale(0.65);
				self.ActionButtonCorners:SetAtlas("plunderstorm-actionbar-slot-corners", TextureKitConstants.UseAtlasSize);
			end

			self.ActionButtonCorners:Show();
		elseif self.ActionButtonCorners then
			self.ActionButtonCorners:Hide();
		end

		icon:SetDesaturated(false);
		local type, id = GetActionInfo(action);
		if ( HasAction(action) ) then
			if ( not self.eventsRegistered ) then
				ActionBarActionEventsFrame:RegisterFrame(self);
				self.eventsRegistered = true;
			end

			if ( not self:GetAttribute("statehidden") ) then
				self:Show();
			end
			self:UpdateState();
			self:UpdateProfessionQuality();
			ActionButton_UpdateCooldown(self);
			self:UpdateFlash();
			self:UpdateHighlightMark();
			self:UpdateSpellHighlightMark();
		else
			if ( self.eventsRegistered ) then
				ActionBarActionEventsFrame:UnregisterFrame(self);
				self.eventsRegistered = nil;
			end

			if ( not self:GetShowGrid() ) then
				self:Hide();
			else
				buttonCooldown:Hide();
			end

			ClearChargeCooldown(self);
			
			self:ClearFlash();
			self:SetChecked(false);
			self:ClearProfessionQuality();

			if self.LevelLinkLockIcon then
				self.LevelLinkLockIcon:SetShown(false);
			end
		end

		self:UpdateUsable();
		self:UpdatePressAndHoldAction();

		-- Update Action Text
		local actionName = self.Name;
		if actionName then
			if ( not IsConsumableAction(action) and not IsStackableAction(action) and (IsItemAction(action) or GetActionCount(action) == 0) ) then
				actionName:SetText(GetActionText(action));
			else
				actionName:SetText("");
			end
		end

		-- Update icon and hotkey text
		if ( texture ) then
			icon:SetTexture(texture);
			icon:Show();
			self.rangeTimer = -1;
			self:UpdateCount();
		else
			self.Count:SetText("");
			icon:Hide();
			buttonCooldown:Hide();
			self.rangeTimer = nil;
			local hotkey = self.HotKey;
			if ( hotkey:GetText() == RANGE_INDICATOR ) then
				hotkey:Hide();
			else
				hotkey:SetVertexColor(ACTIONBAR_HOTKEY_FONT_COLOR:GetRGB());
			end
		end

		-- Update flyout appearance
		self:UpdateFlyout();

		self:UpdateOverlayGlow();

		self:UpdateBorder();

		-- Update tooltip
		if ( GameTooltip:GetOwner() == self ) then
			self:SetTooltip();
		end

		self.feedback_action = action;
	end

	function ActionBarActionButtonDerivedMixin:UpdateSwappableState()
		if not WOWLABS_ACTIONBUTTON_MAP[self.action] then
			return;
		end

		local slot = WOWLABS_ACTIONBUTTON_MAP[self.action]["INVSLOT"];
		local itemLink = GetInventoryItemLink("player", slot);
		local isSpectating = C_SpectatingUI.IsSpectating(); 
		local swapInventoryType = C_WorldLootObject.GetCurrentWorldLootObjectSwapInventoryType();
		if not isSpectating and swapInventoryType and itemLink and (swapInventoryType == C_Item.GetItemInventoryTypeByID(itemLink)) then
			self:SetNormalAtlas("plunderstorm-actionbar-slot-border-swappable");
		else
			self:SetNormalAtlas("plunderstorm-actionbar-slot-border");
		end
	end

	function ActionBarActionButtonDerivedMixin:UpdateBorder()
		local id = self:GetID();

		if not WOWLABS_ACTIONBUTTON_MAP[self.action] then return end 

		local slot = WOWLABS_ACTIONBUTTON_MAP[self.action]["INVSLOT"]

		if self.Border then
			local itemQuality = C_SpectatingUI.IsSpectating() and C_SpectatingUI.GetSpectatingPlayerSpellItemQuality(slot or 0) or GetInventoryItemQuality("player", slot);

			local shouldShowQuality = itemQuality and itemQuality > 1;
			self.Border:SetShown(shouldShowQuality);
			if shouldShowQuality then
				local color = ITEM_QUALITY_COLORS[itemQuality] or ITEM_QUALITY_COLORS[1];
				self.Border:SetVertexColor(color.r, color.g, color.b, 1);
			end

			local numPipsToShow = itemQuality and itemQuality or 0;
			self.RarityPipBackground:SetShown(numPipsToShow > 0);

			self.rarityPips = self.rarityPips or {};
			for i = 1, math.max(numPipsToShow, #self.rarityPips) do
				local rarityPip = self.rarityPips[i];
				if not rarityPip then
					rarityPip = self.RarityPipContainer:CreateTexture(nil, "ARTWORK");
					rarityPip:SetAtlas("plunderstorm-actionbar-slot-pip", TextureKitConstants.UseAtlasSize);
					self.rarityPips[i] = rarityPip;
				end

				local shouldShow = i <= numPipsToShow;
				rarityPip.layoutIndex = shouldShow and i or nil;
				rarityPip:SetShown(shouldShow);
			end

			self.RarityPipContainer:MarkDirty();
		end
	end

	function ActionBarActionButtonDerivedMixin:GetShowGrid()
		local showGridAttribute = self:GetAttribute("showgrid");
		return showGridAttribute and showGridAttribute > 0 or false;
	end

	function ActionBarActionButtonDerivedMixin:ShowGrid(reason)
		assert(reason);

		if ( issecure() ) then
			self:SetAttribute("showgrid", bit.bor(self:GetAttribute("showgrid"), reason));
		end

		if ( self:GetShowGrid() ) then
			if ( not self:GetAttribute("statehidden") ) then
				self:Show();
			end
		end
	end

	function ActionBarActionButtonDerivedMixin:HideGrid(reason)
		assert(reason);

		if ( issecure() ) then
			local showgrid = self:GetAttribute("showgrid");
			if ( showgrid > 0 ) then
				self:SetAttribute("showgrid", bit.band(showgrid, bit.bnot(reason)));
			end
		end

		if ( not self:GetShowGrid() and not HasAction(self.action) ) then
			self:Hide();
		end
	end

	function ActionBarActionButtonDerivedMixin:EvaluateState() 
		local isSpectating = C_SpectatingUI.IsSpectating(); 
		self.HotKey:SetShown(not isSpectating);
		self:SetEnabled(not isSpectating);
		self:SetMotionScriptsWhileDisabled(isSpectating);
		if (isSpectating) then 
			self.icon:SetVertexColor(0.8, 0.8, 0.8);
		end
	end 

	function ActionBarActionButtonDerivedMixin:OnEvent(event, ...)
		if(event == "ACTIONBAR_SLOT_CHANGED" ) then
			if ( arg1 == 0 or arg1 == tonumber(self.action) ) then
				ClearNewActionHighlight(self.action, true);
				self:Update();
			end
		elseif ( event == "PLAYER_EQUIPED_SPELLS_CHANGED" or event == "PLAYER_LOGIN" ) then
			self:UpdateBorder();
		elseif ( event == "ACTIONBAR_SHOWGRID" ) then
			self:ShowGrid(ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
		elseif ( event == "ACTIONBAR_HIDEGRID" ) then
			if ( not KeybindFrames_InQuickKeybindMode() ) then
				self:HideGrid(ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
			end
		elseif ( event == "SPECTATE_BEGIN" or event == "SPECTATE_END" ) then
			self:Update();
			self:UpdateSwappableState();
		elseif ( event == "WORLD_LOOT_OBJECT_SWAP_INVENTORY_TYPE_UPDATED" ) then
			self:UpdateSwappableState();
		end

		ActionBarActionButtonMixin.OnEvent(self, event, ...)
	end

	function ActionBarActionButtonDerivedMixin:SetTooltip()
		local inQuickKeybind = KeybindFrames_InQuickKeybindMode();
		if ( GetCVar("UberTooltips") == "1" or inQuickKeybind ) then
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
		else
			local parent = self:GetParent();
			if ( parent == MultiBarBottomRight or parent == MultiBarRight or parent == MultiBarLeft ) then
				GameTooltip:SetOwner(self, "ANCHOR_LEFT");
			else
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			end
		end
		if ( GameTooltip:SetAction(self.action) ) then
			self.UpdateTooltip = self.SetTooltip;
		else
			self.UpdateTooltip = nil;
		end
	end

	-- Shared between action bar buttons and spell flyout buttons
	function ActionBarActionButtonDerivedMixin:UpdateFlyout(isButtonDownOverride)
		if (not self.FlyoutArrowContainer or
			not self.FlyoutBorderShadow) then
			return;
		end

		local actionType = GetActionInfo(self.action);
		if (actionType ~= "flyout") then
			self.FlyoutBorderShadow:Hide();
			self.FlyoutArrowContainer:Hide();
			return;
		end

		-- Update border
		local isMouseOverButton =  GetMouseFocus() == self;
		local isFlyoutShown = SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() == self;
		if (isFlyoutShown or isMouseOverButton) then
			self.FlyoutBorderShadow:Show();
		else
			self.FlyoutBorderShadow:Hide();
		end

		-- Update arrow
		local isButtonDown;
		if (isButtonDownOverride ~= nil) then
			isButtonDown = isButtonDownOverride;
		else
			isButtonDown = self:GetButtonState() == "PUSHED";
		end

		local flyoutArrowTexture = self.FlyoutArrowContainer.FlyoutArrowNormal;

		if (isButtonDown) then
			flyoutArrowTexture = self.FlyoutArrowContainer.FlyoutArrowPushed;

			self.FlyoutArrowContainer.FlyoutArrowNormal:Hide();
			self.FlyoutArrowContainer.FlyoutArrowHighlight:Hide();
		elseif (isMouseOverButton) then
			flyoutArrowTexture = self.FlyoutArrowContainer.FlyoutArrowHighlight;

			self.FlyoutArrowContainer.FlyoutArrowNormal:Hide();
			self.FlyoutArrowContainer.FlyoutArrowPushed:Hide();
		else
			self.FlyoutArrowContainer.FlyoutArrowHighlight:Hide();
			self.FlyoutArrowContainer.FlyoutArrowPushed:Hide();
		end

		self.FlyoutArrowContainer:Show();
		flyoutArrowTexture:Show();
		flyoutArrowTexture:ClearAllPoints();

		local arrowDirection = self:GetAttribute("flyoutDirection");
		local arrowDistance = isFlyoutShown and 1 or 4;

		-- If you are on an action bar then base your direction based on the action bar's orientation
		local actionBar = self:GetParent();
		if (actionBar.actionButtons) then
			arrowDirection = actionBar:GetSpellFlyoutDirection();
		end

		if (arrowDirection == "LEFT") then
			SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 90 or 270);
			flyoutArrowTexture:SetPoint("LEFT", self, "LEFT", -arrowDistance, 0);
		elseif (arrowDirection == "RIGHT") then
			SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 270 or 90);
			flyoutArrowTexture:SetPoint("RIGHT", self, "RIGHT", arrowDistance, 0);
		elseif (arrowDirection == "DOWN") then
			SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 0 or 180);
			flyoutArrowTexture:SetPoint("BOTTOM", self, "BOTTOM", 0, -arrowDistance);
		else
			SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 180 or 0);
			flyoutArrowTexture:SetPoint("TOP", self, "TOP", 0, arrowDistance);
		end
	end

	-- this is a hack to prevent the action from being cast when we're arranging spells on the loadout bar
	local onClickCooldown = 0

	function ActionBarActionButtonDerivedMixin:OnClick(button, down)
		local infoType = select(1, GetCursorInfo());

		if ( down and infoType == "merchant" ) then
			local merchantSlot = select(2, GetCursorInfo())
			local merchantItemString = GetMerchantItemLink(merchantSlot)
			local _, itemID = strsplit(":" , merchantItemString)
			local invSlot = WOWLABS_ACTIONBUTTON_MAP[self.action]["INVSLOT"]
			local checkItemID = GetInventoryItemID("player", invSlot);

			if ( itemID == tostring(checkItemID) ) then
				UIErrorsFrame:AddMessage(format(ERR_SPELL_ALREADY_KNOWN_S, select(1, C_Item.GetItemInfo(itemID))), 1.0, 0.1, 0.1, 1.0);
				ClearCursor();
				return
			end

			ClearCursor();
			PickupInventoryItem(invSlot);
			DeleteCursorItem();
			BuyMerchantItem(merchantSlot);
			return
		end

		if ( CursorHasItem() ) then
			local actionSlot = WOWLABS_ACTIONBUTTON_MAP[self.action];
			if actionSlot then
				PickupInventoryItem(actionSlot["INVSLOT"]);
			else
				DeleteCursorItem();
			end
			
			onClickCooldown = 1
		else
			if ( KeybindFrames_InQuickKeybindMode() ) then
				if ( cursorType ) then
					local slotID = self:CalculateAction(button);
					C_ActionBar.PutActionInSlot(slotID);
				end
			else
				if button == "RightButton" and C_ActionBar.IsAutoCastPetAction(self.action) then
					C_ActionBar.ToggleAutoCastPetAction(self.action);
				else
					local useKeyDownCvar = GetCVarBool("ActionButtonUseKeyDown");
					local actionBarLocked = Settings.GetValue("lockActionBars");

					local lockedBarDoNothing = actionBarLocked and down and IsModifiedClick("PICKUPACTION");
					
					if lockedBarDoNothing then
						return;
					end

					if not self.pressAndHoldAction and (useKeyDownCvar and down) then
						return;
					end

					local useDown = down or (useKeyDownCvar and not actionBarLocked);

					if ( onClickCooldown == 0 ) then
						SecureActionButton_OnClick(self, button, useDown);
					else
						onClickCooldown = onClickCooldown - 1;
					end
				end
			end
		end
	end

	function ActionBarActionButtonDerivedMixin:OnDragStart()
		--local useKeyDownCvar = GetCVarBool("ActionButtonUseKeyDown");
		local id = self.action;
		if (WOWLABS_ACTIONBUTTON_MAP[id]) then
			local actionBarLocked = Settings.GetValue("lockActionBars");
			local lockedBarDoNothing = actionBarLocked and IsModifiedClick("PICKUPACTION");
			local unlockedBarDoNothing = not actionBarLocked
			
			if ( lockedBarDoNothing or unlockedBarDoNothing ) then	
				PickupInventoryItem(WOWLABS_ACTIONBUTTON_MAP[id]["INVSLOT"]);
				self:UpdateState();
				self:UpdateFlash();
			end
		end
	end

	function ActionBarActionButtonDerivedMixin:OnReceiveDrag()
		self:UpdateState();
		self:UpdateFlash();
	end

	function ActionBarActionButtonDerivedMixin:OnDragStop()
		for slot, _ in pairs(WOWLABS_ACTIONBUTTON_MAP) do
			local actionButton = _G[WOWLABS_ACTIONBUTTON_MAP[slot]["FRAME"]]
			if actionButton:IsMouseOver() then
				PickupInventoryItem(WOWLABS_ACTIONBUTTON_MAP[slot]["INVSLOT"]);
				return
			end
		end

		DeleteCursorItem()
	end
else
	ActionBarButtonEventsDerivedFrameMixin = CreateFromMixins(ActionBarButtonEventsFrameMixin);
	ActionBarActionButtonDerivedMixin = CreateFromMixins(ActionBarActionButtonMixin);
	function ActionBarActionButtonDerivedMixin:OnDragStop() end 
end
