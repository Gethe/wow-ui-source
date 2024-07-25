

ProfessionsCustomerListingsElementMixin = CreateFromMixins(TableBuilderRowMixin);

function ProfessionsCustomerListingsElementMixin:OnLineEnter()
	self.HighlightTexture:Show();
end

function ProfessionsCustomerListingsElementMixin:OnLineLeave()
	self.HighlightTexture:Hide();
end

function ProfessionsCustomerListingsElementMixin:Init(elementData)
	self.order = elementData.option;
end

local function AnyRecraftablePredicate(itemGUID)
	local craftRecipeID, craftSkillLineAbility = C_TradeSkillUI.GetOriginalCraftRecipeID(itemGUID);
	return craftSkillLineAbility ~= nil and C_CraftingOrders.CanOrderSkillAbility(craftSkillLineAbility);
end

local ProfessionsCustomerOrderFormEvents =
{
    "UNIT_INVENTORY_CHANGED",
	"BAG_UPDATE",
	"CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE",
	"CRAFTINGORDERS_ORDER_CANCEL_RESPONSE",
	"PLAYER_MONEY",
	"TRACKED_RECIPE_UPDATE",
	"CAN_LOCAL_WHISPER_TARGET_RESPONSE",
};

ProfessionsCustomerOrderFormMixin = {};

function ProfessionsCustomerOrderFormMixin:InitPaymentContainer()
	self.PaymentContainer.TipMoneyInputFrame:SetOnValueChangedCallback(GenerateClosure(self.UpdateTotalPrice, self));
	self.PaymentContainer.TipMoneyInputFrame.CopperBox:Hide();

	self.PaymentContainer.ListOrderButton:SetScript("OnClick", function()
		local recraftAllocation = self.transaction:GetRecraftAllocation();
		local warning = nil;
		local hasRemovalWarning = nil;

		if recraftAllocation then 
			local itemIDs = TableUtil.Transform(self.transaction:CreateCraftingReagentInfoTbl(), function(craftingReagentInfo)
				return craftingReagentInfo.itemID;
			end);
		
			local removalWarnings = C_TradeSkillUI.GetRecraftRemovalWarnings(self.transaction:GetRecraftAllocation(), itemIDs);
			hasRemovalWarning = #removalWarnings > 0;
			if hasRemovalWarning then
				warning = removalWarnings[1];
			end
		end
		
		if not warning then
			if self:OrderCouldReduceQuality() then
				warning = CRAFTING_ORDER_RECRAFT_WARNING2;
			elseif self.order.unusableBOP then
				warning = PROFESSIONS_ORDER_UNUSABLE_WARNING;
			end
		end
	
		if warning then
			local referenceKey = self;
			if not StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
				local customData = 
				{
					text = warning,
					acceptText = YES,
					cancelText = NO,
					callback = function() self:ListOrder(); end,
					referenceKey = referenceKey,
				};

				if hasRemovalWarning then
					customData.showAlert = true;
				end

				StaticPopup_ShowCustomGenericConfirmation(customData);
			end
		else
			self:ListOrder();
		end
	end);

	self.PaymentContainer.CancelOrderButton:SetScript("OnClick", function()
		C_CraftingOrders.CancelOrder(self.order.orderID);
	end);
end

function ProfessionsCustomerOrderFormMixin:SetRecraftItemGUID(itemGUID)
	local craftRecipeID, skillLineAbilityID = C_TradeSkillUI.GetOriginalCraftRecipeID(itemGUID);
	self.order.spellID = craftRecipeID;
	self.order.skillLineAbilityID = skillLineAbilityID;
	self.recraftGUID = itemGUID;
	self:InitSchematic();
	self:SetupQualityDropdown();
	self:UpdateMinimumQuality();
end

function ProfessionsCustomerOrderFormMixin:InitButtons()
	self.RecraftSlot.InputSlot:SetScript("OnMouseDown", function(button, buttonName, down)
		if buttonName == "LeftButton" and not self.committed then
			HelpTip:Hide(self, CRAFTING_ORDER_TUTORIAL_RECRAFT);

			local flyout = ToggleProfessionsItemFlyout(self.RecraftSlot.InputSlot, self);
			if flyout then
				local function OnFlyoutItemSelected(o, flyout, elementData)
					local itemLocation = C_Item.GetItemLocation(elementData.itemGUID);
					C_Sound.PlayItemSound(Enum.ItemSoundType.Drop, itemLocation);
					self:SetRecraftItemGUID(elementData.itemGUID);
				end
	
				flyout.GetElementsImplementation = function(self)
					local isIndexTable = true;
					local itemGUIDs = tFilter(C_TradeSkillUI.GetRecraftItems(), AnyRecraftablePredicate, isIndexTable);
					local items = ItemUtil.TransformItemGUIDsToItems(itemGUIDs);
					local elementData = {items = items, itemGUIDs = itemGUIDs};
					return elementData;
				end

				flyout.OnElementEnterImplementation = function(elementData, tooltip)
					tooltip:SetItemByGUID(elementData.itemGUID);
				end
				
				flyout.OnElementEnabledImplementation = function(button, elementData)
					return true;
				end

				local canModifyFilter = false;
				flyout:Init(self.RecraftSlot.InputSlot, self.transaction, canModifyFilter);
				flyout:RegisterCallback(ProfessionsItemFlyoutMixin.Event.ItemSelected, OnFlyoutItemSelected, self);
			end
		elseif self.order.recraftItemHyperlink then
			HandleModifiedItemClick(self.order.recraftItemHyperlink);
		end
	end);

	self.RecraftSlot.InputSlot:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.RecraftSlot.InputSlot, "ANCHOR_RIGHT");

		local itemGUID = self.transaction and self.transaction:GetRecraftAllocation();
		if itemGUID then
			GameTooltip:SetItemByGUID(itemGUID);
			if not self.committed then
				GameTooltip_AddBlankLineToTooltip(GameTooltip);
				GameTooltip_AddInstructionLine(GameTooltip, RECRAFT_REAGENT_TOOLTIP_CLICK_TO_REPLACE);
			end
		elseif self.order.recraftItemHyperlink then
			GameTooltip:SetHyperlink(self.order.recraftItemHyperlink);
		else
			GameTooltip_AddInstructionLine(GameTooltip, RECRAFT_REAGENT_TOOLTIP_CLICK_TO_ADD);
		end
		GameTooltip:Show();
	end);

	self.RecraftSlot.OutputSlot:SetScript("OnEnter", function()
		local itemGUID = self.transaction and self.transaction:GetRecraftAllocation();
		if itemGUID or self.committed then
			GameTooltip:SetOwner(self.RecraftSlot.OutputSlot, "ANCHOR_RIGHT");

			local optionalReagents = self.transaction:CreateOptionalCraftingReagentInfoTbl();
			local minimumQuality = self.minQualityIDs and self.minQualityIDs[self.order.minQuality];
			if itemGUID then
				GameTooltip:SetRecipeResultItem(self.order.spellID, optionalReagents, itemGUID, nilRecipeLevel, minimumQuality);
			else
				GameTooltip:SetRecipeResultItemForOrder(self.order.spellID, optionalReagents, self.order.orderID, nilRecipeLevel, minimumQuality);
			end
		end
	end);

	self.RecraftSlot.OutputSlot:SetScript("OnClick", function()
		local itemGUID = self.transaction and self.transaction:GetRecraftAllocation();
		local optionalReagents = self.transaction:CreateOptionalCraftingReagentInfoTbl();
		local minimumQuality = self.minQualityIDs and self.minQualityIDs[self.order.minQuality];
		local outputItemInfo = C_TradeSkillUI.GetRecipeOutputItemData(self.order.spellID, optionalReagents, itemGUID, minimumQuality, self.committed and self.order.orderID or nil);
		if outputItemInfo and outputItemInfo.hyperlink then
			HandleModifiedItemClick(outputItemInfo.hyperlink);
		end
	end);

	self.PaymentContainer.ViewListingsButton:SetScript("OnClick", function(frame, button, down)
		if down then
			frame:SetHighlightAtlas("UI-CraftingOrderIcon-Down");
		else
			frame:SetHighlightAtlas("UI-CraftingOrderIcon-Up");
			self:ShowCurrentListings();
		end
	 end);

	 self.PaymentContainer.ViewListingsButton:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip_AddHighlightLine(GameTooltip, CRAFTING_ORDER_VIEW_ORDERS);
		GameTooltip:Show();
	 end);

	 self.TrackRecipeCheckbox.Text:SetText(LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(PROFESSIONS_TRACK_RECIPE));
	 self.TrackRecipeCheckbox.Checkbox:SetScript("OnClick", function(button, buttonName, down)
		local checked = button:GetChecked();
		C_TradeSkillUI.SetRecipeTracked(self.order.spellID, checked, self.order.isRecraft);
		PlaySound(SOUNDKIT.UI_PROFESSION_TRACK_RECIPE_CHECKBOX);
	 end);

	 local function SetFavoriteTooltip(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		local isFavorite = button:GetChecked();
		if not isFavorite and C_CraftingOrders.GetNumFavoriteCustomerOptions() >= Constants.CraftingOrderConsts.MAX_CRAFTING_ORDER_FAVORITE_RECIPES then
			GameTooltip_AddErrorLine(GameTooltip, PROFESSIONS_CRAFTING_ORDERS_FAVORITES_FULL);
		else
			GameTooltip_AddHighlightLine(GameTooltip, isFavorite and BATTLE_PET_UNFAVORITE or BATTLE_PET_FAVORITE);
		end
		GameTooltip:Show();
	end
	 self.FavoriteButton:SetScript("OnClick", function(button, buttonName, down)
		local checked = button:GetChecked();
		if checked and C_CraftingOrders.GetNumFavoriteCustomerOptions() >= Constants.CraftingOrderConsts.MAX_CRAFTING_ORDER_FAVORITE_RECIPES then
			button:SetChecked(false);
			return;
		end

		C_CraftingOrders.SetCustomerOptionFavorited(self.order.spellID, checked);

		button:SetIsFavorite(checked);
		PlaySound(SOUNDKIT.UI_PROFESSION_TRACK_RECIPE_CHECKBOX);

		SetFavoriteTooltip(button);
	end);
	self.FavoriteButton:SetScript("OnEnter", function(button)
		SetFavoriteTooltip(button);
	end);
	self.FavoriteButton:SetScript("OnLeave", GameTooltip_Hide);

	self.AllocateBestQualityCheckbox.text:SetText(LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(PROFESSIONS_USE_BEST_QUALITY_REAGENTS));
	self.AllocateBestQualityCheckbox:SetScript("OnClick", function(button, buttonName, down)
		local checked = button:GetChecked();
		local forCustomer = true;
		Professions.SetShouldAllocateBestQualityReagents(checked, forCustomer);

		Professions.AllocateAllBasicReagents(self.transaction, checked);
		self:UpdateReagentSlots();

		-- Trick to re-fire the OnEnter script to update the tooltip.
		self.AllocateBestQualityCheckbox:Hide();
		self.AllocateBestQualityCheckbox:Show();
		PlaySound(SOUNDKIT.UI_PROFESSION_USE_BEST_REAGENTS_CHECKBOX);
	end);
	self.AllocateBestQualityCheckbox:SetScript("OnEnter", function(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		local checked = button:GetChecked();
		if checked then
			GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_USE_LOWEST_QUALITY_REAGENTS);
		else
			GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_USE_HIGHEST_QUALITY_REAGENTS);
		end
		GameTooltip:Show();
	end);
	self.AllocateBestQualityCheckbox:SetScript("OnLeave", GameTooltip_Hide);

	SquareButton_SetIcon(self.OrderRecipientDisplay.SocialDropdown, "DOWN");

	self.OrderRecipientDisplay.SocialDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_PROFESSIONS_CUSTOMER_ORDER_FORM");

		if not self.order then
			return;
		end

		local whisperStatus = self:GetWhisperCrafterStatus();

		-- Add whisper option
		local canWhisper = whisperStatus == Enum.ChatWhisperTargetStatus.CanWhisper or whisperStatus == Enum.ChatWhisperTargetStatus.CanWhisperGuild;
		if canWhisper then
			rootDescription:CreateButton(WHISPER_MESSAGE, function()
				ChatFrame_SendTell(self.order.crafterName);
			end);
		else
			local button = rootDescription:CreateButton(WHISPER_MESSAGE, nop);
			button:SetEnabled(false);
			button:SetTooltip(function(tooltip, elementDescription)
				if whisperStatus == Enum.ChatWhisperTargetStatus.Offline then
					GameTooltip_AddNormalLine(tooltip, PROF_ORDER_CANT_WHISPER_OFFLINE);
				elseif whisperStatus == Enum.ChatWhisperTargetStatus.WrongFaction then
					GameTooltip_AddNormalLine(tooltip, PROF_ORDER_CANT_WHISPER_WRONG_FACTION);
				end
			end);
		end
		
		-- Add "Add Friend" option
		local alreadyIsFriend = C_FriendList.IsFriend(self.order.crafterGuid);
		local canAddFriend = whisperStatus == Enum.ChatWhisperTargetStatus.CanWhisper and not alreadyIsFriend;
		if canAddFriend then
			rootDescription:CreateButton(ADD_CHARACTER_FRIEND, function()
				local professionName = C_TradeSkillUI.GetProfessionNameForSkillLineAbility(self.order.skillLineAbilityID);
				local friendNote = CRAFTER_ORDER_FRIEND_NOTE_FMT:format(professionName, self.transaction:GetRecipeSchematic().name);
				C_FriendList.AddFriend(self.order.crafterName, friendNote);
			end);
		else
			local button = rootDescription:CreateButton(ADD_CHARACTER_FRIEND, nop);
			button:SetEnabled(false);
			button:SetTooltip(function(tooltip, elementDescription)
				if alreadyIsFriend then
					GameTooltip_AddNormalLine(tooltip, ALREADY_FRIEND_FMT:format(self.order.crafterName));
				elseif whisperStatus == Enum.ChatWhisperTargetStatus.Offline then
					GameTooltip_AddNormalLine(tooltip, PROF_ORDER_CANT_ADD_FRIEND_OFFLINE);
				elseif whisperStatus == Enum.ChatWhisperTargetStatus.WrongFaction or whisperStatus == Enum.ChatWhisperTargetStatus.CanWhisperGuild then
					-- CanWhisperGuild means we can whisper the player despite them being cross-faction because they are in our guild
					GameTooltip_AddNormalLine(tooltip, PROF_ORDER_CANT_ADD_FRIEND_WRONG_FACTION);
				end
			end);
		end
		
		-- Add ignore option
		local canIgnore = self.order.crafterGuid and not C_FriendList.IsIgnoredByGuid(self.order.crafterGuid);
		if canIgnore then
			rootDescription:CreateButton(IGNORE, function()
				local referenceKey = self;
				if not StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
					local customData = 
					{
						text = CRAFTING_ORDERS_IGNORE_CONFIRMATION,
						text_arg1 = self.order.crafterName,
						callback = function()
							C_FriendList.AddIgnore(self.order.crafterName);
						end,
						acceptText = YES,
						cancelText = NO,
						referenceKey = referenceKey,
					};

					StaticPopup_ShowCustomGenericConfirmation(customData);
				end
			end);
		else
			local button = rootDescription:CreateButton(ADD_CHARACTER_FRIEND, nop);
			button:SetEnabled(false);
			if self.order.crafterGuid then
				button:SetTooltip(function(tooltip, elementDescription)
					GameTooltip_AddNormalLine(tooltip, PROF_ORDER_CANT_IGNORE_ALREADY_IGNORED);
				end);
			end
		end
	end);
end

function ProfessionsCustomerOrderFormMixin:InitCurrentListings()
	self.CurrentListings:SetTitle(PROFESSIONS_CURRENT_LISTINGS);
	self.CurrentListings.CloseButton:SetScript("OnClick", function() self:HideCurrentListings(); end);

	self.CurrentListings.SetSortOrder = function(currentListings, sortOrder)
		if currentListings.primarySort.order == sortOrder then
			currentListings.primarySort.ascending = not currentListings.primarySort.ascending;
		else
			currentListings.secondarySort = CopyTable(currentListings.primarySort);
			currentListings.primarySort =
			{
				order = sortOrder;
				ascending = true;
			};
		end
	
		if currentListings.tableBuilder then
			for frame in currentListings.tableBuilder:EnumerateHeaders() do
				frame:UpdateArrow();
			end
		end
	
		self:RequestCurrentListings();
	end

	self.CurrentListings.primarySort =
	{
		order = ProfessionsSortOrder.Tip;
		ascending = false;
	};

	self.CurrentListings.secondarySort =
	{
		order = ProfessionsSortOrder.Reagents;
		ascending = true;
	};

	self.CurrentListings.GetSortOrder = function(currentListings)
		return currentListings.primarySort.order, currentListings.primarySort.ascending;
	end

	local pad = 5;
	local spacing = 1;
	local view = CreateScrollBoxListLinearView(pad, pad, pad, pad, spacing);
	view:SetElementInitializer("ProfessionsCustomerListingsElementTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.CurrentListings.OrderList.ScrollBox, self.CurrentListings.OrderList.ScrollBar, view);

	self.CurrentListings.tableBuilder = CreateTableBuilder(nil, ProfessionsTableBuilderMixin);
	local function ElementDataTranslator(elementData)
		return elementData;
	end;
	ScrollUtil.RegisterTableBuilder(self.CurrentListings.OrderList.ScrollBox, self.CurrentListings.tableBuilder, ElementDataTranslator);

	local function ElementDataProvider(elementData)
		return elementData;
	end;
	self.CurrentListings.tableBuilder:SetDataProvider(ElementDataProvider);

	local PTC = ProfessionsTableConstants;
	self.CurrentListings.tableBuilder:Reset();
	self.CurrentListings.tableBuilder:SetColumnHeaderOverlap(2);
	self.CurrentListings.tableBuilder:SetHeaderContainer(self.CurrentListings.OrderList.HeaderContainer);
	self.CurrentListings.tableBuilder:SetTableMargins(5, 5);
	self.CurrentListings.tableBuilder:SetTableWidth(230);

	self.CurrentListings.tableBuilder:AddFillColumn(self.CurrentListings, PTC.NoPadding, 1.0, PTC.Tip.LeftCellPadding,
										  	PTC.Tip.RightCellPadding, ProfessionsSortOrder.Tip, "ProfessionsCrafterTableCellActualCommissionTemplate");

	self.CurrentListings.tableBuilder:AddFixedWidthColumn(self.CurrentListings, PTC.NoPadding, PTC.Reagents.Width, PTC.Reagents.LeftCellPadding,
										  	 PTC.Reagents.RightCellPadding, ProfessionsSortOrder.Reagents, "ProfessionsCrafterTableCellReagentsTemplate");

	self.CurrentListings.tableBuilder:Arrange();

	local function OnDataRangeChanged(sortPending, indexBegin, indexEnd)
		if (not self.expectMoreRows) or (self.requestCallback ~= nil) or (not self.numOrders) then
			return;
		end

		local ordersFromBottom = self.numOrders - indexEnd;
		local requestMoreOrdersThreshold = 30;
		if ordersFromBottom < requestMoreOrdersThreshold then
			self:RequestMoreOrders();
		end
	end
	self.CurrentListings.OrderList.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, OnDataRangeChanged, self);
end

function ProfessionsCustomerOrderFormMixin:OnLoad()
	local function PoolReset(pool, slot)
		slot:Reset();
		slot.Button:SetScript("OnEnter", nil);
		slot.Button:SetScript("OnClick", nil);
		slot.Button:SetScript("OnMouseDown", nil);
		Pool_HideAndClearAnchors(pool, slot);
	end
	self.reagentSlotPool = CreateFramePool("FRAME", self, "ProfessionsReagentSlotTemplate", PoolReset);

	self:InitPaymentContainer();
	self:InitButtons();
	self:InitCurrentListings();
end

function ProfessionsCustomerOrderFormMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, ProfessionsCustomerOrderFormEvents);
end

function ProfessionsCustomerOrderFormMixin:OnHide()
    FrameUtil.UnregisterFrameForEvents(self, ProfessionsCustomerOrderFormEvents);
	if self.requestCallback then
		self.requestCallback:Cancel();
		self.requestCallback = nil;
	end

	self.QualityDialog:Close();

	self:HideCurrentListings();
	StaticPopup_Hide("GENERIC_CONFIRMATION");
end

function ProfessionsCustomerOrderFormMixin:OnEvent(event, ...)
	if event == "UNIT_INVENTORY_CHANGED" or event == "BAG_UPDATE" then
		self:UpdateReagentSlots();
	elseif event == "CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE" or event == "CRAFTINGORDERS_ORDER_CANCEL_RESPONSE" then
		if event == "CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE" then
			self.pendingOrderPlacement = false;
			self:UpdateListOrderButton();
		end
		local result = ...;
		local success = (result == Enum.CraftingOrderResult.Ok);
		if success then
			self:Hide();
			CallMethodOnNearestAncestor(self, "SelectMode", ProfessionsCustomerOrdersMode.Orders);
		else
			local errorText;
			if event == "CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE" then
				if result == Enum.CraftingOrderResult.InvalidTarget then
					errorText = CRAFTING_ORDER_FAILED_INVALID_TARGET;
				elseif result == Enum.CraftingOrderResult.TargetCannotCraft then
					errorText = CRAFTING_ORDER_FAILED_TARGET_CANT_CRAFT;
				elseif result == Enum.CraftingOrderResult.MaxOrdersReached then
					errorText = PROFESSIONS_MAX_ORDERS_REACHED;
				elseif result == Enum.CraftingOrderResult.NoAccountItems then
					errorText = CRAFTING_ORDER_FAILED_ACCOUNT_ITEMS;
				else
					errorText = PROFESSIONS_ORDER_PLACEMENT_FAILED;
				end
			elseif event == "CRAFTINGORDERS_ORDER_CANCEL_RESPONSE" then
				errorText = (result == Enum.CraftingOrderResult.AlreadyClaimed) and PROFESSIONS_ORDER_CANCEL_FAILED_CLAIMED or PROFESSIONS_ORDER_CANCEL_FAILED;
			end
			UIErrorsFrame:AddExternalErrorMessage(errorText);
		end
	elseif event == "PLAYER_MONEY" then
		self:UpdateListOrderButton();
	elseif event == "TRACKED_RECIPE_UPDATE" then
		local recipeID, tracked = ...;
		if recipeID == self.order.spellID then
			self.TrackRecipeCheckbox.Checkbox:SetChecked(tracked);
		end
	elseif event == "CAN_LOCAL_WHISPER_TARGET_RESPONSE" then
		local whisperTarget, status = ...;
		
		if whisperTarget == self.order.crafterGuid then
			self:SetWhisperCrafterStatus(status);
		end
	end
end

function ProfessionsCustomerOrderFormMixin:SetupQualityDropdown()
	if not self.minQualityIDs then
		return;
	end

	local function IsSelected(qualityIndex)
		return self.order.minQuality == qualityIndex;
	end

	local function SetSelected(qualityIndex)
		self:SetMinimumQualityIndex(qualityIndex);
	end

	local function CreateRadio(rootDescription, text, index)
		local radio = rootDescription:CreateRadio(text, IsSelected, SetSelected, index);
		radio:AddInitializer(function(button, description, menu)
			button.fontString:SetFontObject("Number12Font");
			
			if index > 1 then
				button.fontString:SetPoint("LEFT", button.leftTexture1, "RIGHT", 1, 7);
			end
		end);
	end

	self.MinimumQuality.Dropdown:SetWidth(80);
	self.MinimumQuality.Dropdown.Text:SetJustifyH("CENTER");
	self.MinimumQuality.Dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_PROFESSIONS_CUSTOMER_ORDER_QUALITY");

		local smallIcon = true;
		local overrideOffsetY = 0;
		for index in ipairs(self.minQualityIDs) do
			local text = index == 1 and NONE or Professions.GetChatIconMarkupForQuality(index, smallIcon, overrideOffsetY);
			CreateRadio(rootDescription, text, index);
		end
	end);
end

function ProfessionsCustomerOrderFormMixin:SetupOrderRecipientDropdown()
	self.OrderRecipientDropdown:SetWidth(136);

	local function IsSelected(orderType)
		return self.order.orderType == orderType;
	end

	local function SetSelected(orderType)
		self:SetOrderRecipient(orderType);
	end

	local function GetOrderTypes()
		local orderTbls = {};
		if not self.order.isRecraft then
			table.insert(orderTbls, { text = PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_PUBLIC, orderType = Enum.CraftingOrderType.Public, });
		else
			if self.order.orderType == Enum.CraftingOrderType.Public then
				self.order.orderType = Enum.CraftingOrderType.Personal;
			end
		end
		if IsInGuild() then
			table.insert(orderTbls, { text = PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_GUILD, orderType = Enum.CraftingOrderType.Guild, });
		end
		table.insert(orderTbls, { text = PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_PRIVATE, orderType = Enum.CraftingOrderType.Personal, });
		return orderTbls;
	end

	self.OrderRecipientDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_PROFESSIONS_CUSTOMER_ORDER_RECIPIENT");

		for index, tbl in ipairs(GetOrderTypes()) do
			rootDescription:CreateRadio(tbl.text, IsSelected, SetSelected, tbl.orderType);
		end
	end);

	self:UpdateMinimumQuality();
end

function ProfessionsCustomerOrderFormMixin:SetupDurationDropdown()
	if not self.duration or self.duration < Enum.CraftingOrderDuration.Short or self.duration > Enum.CraftingOrderDuration.Long then
		self.duration = Enum.CraftingOrderDuration.Long;
	end

	local function IsSelected(duration)
		return self.duration == duration;
	end

	local function SetSelected(duration)
		self:SetDuration(duration);
	end

	local function CreateRadio(rootDescription, text, duration)
		local radio = rootDescription:CreateRadio(text, IsSelected, SetSelected, duration);
		radio:AddInitializer(function(button, description, menu)
			button.fontString:SetFontObject("Number12Font");
		end);
	end

	self.PaymentContainer.Duration:SetText(PROFESSIONS_CRAFTING_FORM_CUSTOMER_DURATION);
	self.PaymentContainer.DurationDropdown:SetWidth(143);
	self.PaymentContainer.DurationDropdown.Text:SetFontObject("Number12Font");
	self.PaymentContainer.DurationDropdown.Text:SetJustifyH("RIGHT");
	self.PaymentContainer.DurationDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_PROFESSIONS_CUSTOMER_ORDER_DURATION");

		CreateRadio(rootDescription, PROFESSIONS_LISTING_DURATION_ONE, Enum.CraftingOrderDuration.Short);
		CreateRadio(rootDescription, PROFESSIONS_LISTING_DURATION_TWO, Enum.CraftingOrderDuration.Medium);
		CreateRadio(rootDescription, PROFESSIONS_LISTING_DURATION_THREE, Enum.CraftingOrderDuration.Long);
	end);
end

function ProfessionsCustomerOrderFormMixin:UpdateMinimumQuality()
	local showMinQuality = (not self.committed) and self.minQualityIDs and self.order.orderType ~= Enum.CraftingOrderType.Public;
	self.MinimumQuality:SetShown(showMinQuality);
end

function ProfessionsCustomerOrderFormMixin:UpdateDepositCost()
	if not self.order or not self.order.skillLineAbilityID or not self.order.orderType or not self.duration then
		return;
	end

	self.PaymentContainer.PostingFee:Show();
	self.PaymentContainer.PostingFeeMoneyDisplayFrame:Show();

	self.depositCost = C_CraftingOrders.CalculateCraftingOrderPostingFee(self.order.skillLineAbilityID, self.order.orderType, self.duration);
	self.PaymentContainer.PostingFeeMoneyDisplayFrame:SetAmount(self.depositCost);
	self:UpdateTotalPrice();
end

function ProfessionsCustomerOrderFormMixin:SetDuration(index)
	self.duration = index;

	Professions.SetDefaultOrderDuration(index);
	
	self:UpdateDepositCost();
end

function ProfessionsCustomerOrderFormMixin:SetOrderRecipient(index)
	self.order.orderType = index;

	Professions.SetDefaultOrderRecipient(index);

	self:UpdateReagentSlots();
	self:UpdateMinimumQuality();
	self:UpdateDepositCost();

	self.OrderRecipientTarget:SetShown(index == Enum.CraftingOrderType.Personal);
	self:UpdateMinimumQualityAnchor();

	self:UpdateListOrderButton();
end

function ProfessionsCustomerOrderFormMixin:SetMinimumQualityIndex(index)
	self.order.minQuality = index;

	SetItemCraftingQualityOverlayOverride(self.RecraftSlot.OutputSlot, index);
end

local helptipSystemName = "Professions Customer Orders";

local function SetupSlotOverride(slot, orderSource, canAllocate, committed)
	if orderSource == Enum.CraftingOrderReagentSource.Crafter then
		slot:SetOverrideNameColor(DISABLED_REAGENT_COLOR);
		slot:SetShowOnlyRequired(true);
	elseif orderSource == Enum.CraftingOrderReagentSource.Customer then
		if not canAllocate and not committed then
			slot:SetOverrideNameColor(ERROR_COLOR);
		end
	end
end

function ProfessionsCustomerOrderFormMixin:UpdateReagentSlots()
	if not self.transaction then
		return;
	end

	local transaction = self.transaction;
	local recipeID = transaction:GetRecipeID();
	local recipeSchematic = transaction:GetRecipeSchematic();
	local committed = self.order.orderID ~= nil;

	self.reagentSlotPool:ReleaseAll();
	local reagentTypes = {};

	local slotParents =
	{
		[Enum.CraftingReagentType.Basic] = self.ReagentContainer.Reagents,
		[Enum.CraftingReagentType.Modifying] = self.ReagentContainer.OptionalReagents,
	};

	local qualityReagentsHelpTipInfo =
	{
		text = CRAFTING_ORDER_TUTORIAL_REAGENTS,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.BottomEdgeCenter,
		alignment = HelpTip.Alignment.Left,
		offsetX = -60,
		system = helptipSystemName,
		acknowledgeOnHide = true,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_PROFESSIONS_CO_QUALITY_REAGENTS,
	};

	local optionalReagentsHelpTipInfo =
	{
		text = CRAFTING_ORDER_TUTORIAL_OPTIONAL_REAGENTS,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.BottomEdgeCenter,
		alignment = HelpTip.Alignment.Left,
		offsetX = -60,
		system = helptipSystemName,
		acknowledgeOnHide = true,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_PROFESSIONS_CO_OPTIONAL_REAGENTS,
	};

	local qualityReagentHelptipShown = GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PROFESSIONS_CO_QUALITY_REAGENTS);
	local optionalReagentHelptipShown = GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PROFESSIONS_CO_OPTIONAL_REAGENTS);
	for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		local orderSource = reagentSlotSchematic.orderSource;
		if orderSource == Enum.CraftingOrderReagentSource.Any and self.order.orderType == Enum.CraftingOrderType.Public then
			-- For public orders, only the customer can provide "Any" sourced reagents
			orderSource = Enum.CraftingOrderReagentSource.Customer;
		end

		local reagentType = reagentSlotSchematic.reagentType;
		if reagentType ~= Enum.CraftingReagentType.Finishing then
			-- modifying-required slots cannot be correctly ordered by their logical slot indices, but design wants them at the top.
			local isModifyingRequiredSlot = ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic);
			local sectionType = (isModifyingRequiredSlot and Enum.CraftingReagentType.Basic) or reagentType;

			local slots = reagentTypes[sectionType];
			if not slots then
				slots = {};
				reagentTypes[sectionType] = slots;
			end
			local hasAnyAllocation = transaction:HasAnyAllocations(slotIndex);

			local slot = self.reagentSlotPool:Acquire();
			if isModifyingRequiredSlot then
				table.insert(slots, 1, slot);
			else
				table.insert(slots, slot);
			end

			slot:SetParent(slotParents[sectionType]);

			slot:Init(transaction, reagentSlotSchematic);
			slot:Show();

			if committed then
				if not hasAnyAllocation then
					slot:SetOverrideNameColor(DISABLED_REAGENT_COLOR);
				end
			end

			if reagentType == Enum.CraftingReagentType.Basic then
				local canProvide = orderSource ~= Enum.CraftingOrderReagentSource.Crafter and not committed;
				local canAllocate = canProvide and Professions.CanAllocateReagents(transaction, slotIndex);
				slot:SetHighlightShown(canAllocate or (orderSource == Enum.CraftingOrderReagentSource.Customer and not committed));

				local isQualityReagent = (Professions.GetReagentInputMode(reagentSlotSchematic) == Professions.ReagentInputMode.Quality);
				if self.minQualityIDs and canProvide and isQualityReagent and not qualityReagentHelptipShown then
					HelpTip:Show(self, qualityReagentsHelpTipInfo, slot);
					qualityReagentHelptipShown = true;
				end

				if canAllocate then
					local forCustomer = true;
					local useBestQuality = Professions.ShouldAllocateBestQualityReagents(forCustomer);
					Professions.AllocateBasicReagents(transaction, slotIndex, useBestQuality);
					slot:Update();
				end

				local canToggle = orderSource == Enum.CraftingOrderReagentSource.Any and not committed;
				slot:SetCheckboxShown(canToggle);
				if canToggle then
					slot:SetCheckboxChecked(canAllocate);
					slot:SetCheckboxEnabled(canAllocate);
					slot:SetCheckboxCallback(function(provided)
						slot:SetHighlightShown(provided);
						if not provided then
							transaction:ClearAllocations(slotIndex);

							slot.Button:UpdateCursor();
							slot:Update();
						else
							local forCustomer = true;
							local useBestQuality = Professions.ShouldAllocateBestQualityReagents(forCustomer);
							Professions.AllocateBasicReagents(transaction, slotIndex, useBestQuality);
							slot:Update();
						end

						slot:SetUnallocatable(not provided);
					end);
					if not canAllocate then
						slot:SetCheckboxTooltipText(ERROR_COLOR:WrapTextInColorCode(PROFESSIONS_ORDERS_NOT_ENOUGH_REAGENTS));
					end
				else
					SetupSlotOverride(slot, orderSource, canAllocate, committed);
				end

				if isQualityReagent then
					slot.Button:SetScript("OnClick", function(button, buttonName, down)
						if IsShiftKeyDown() then
							local qualityIndex = Professions.FindFirstQualityAllocated(transaction, reagentSlotSchematic) or 1;
							local handled, link = Professions.HandleQualityReagentItemLink(recipeID, reagentSlotSchematic, qualityIndex);
							if not handled then
								Professions.TriggerReagentClickedEvent(link);
							end
							return;
						end

						if not slot:IsUnallocatable() then
							if buttonName == "LeftButton" then
								HelpTip:Hide(self, CRAFTING_ORDER_TUTORIAL_REAGENTS);
								local function OnAllocationsAccepted(dialog, allocations, reagentSlotSchematic)
									transaction:OverwriteAllocations(reagentSlotSchematic.slotIndex, allocations);

									slot:Update();

									self:UpdateListOrderButton();
								end

								self.QualityDialog:RegisterCallback(ProfessionsQualityDialogMixin.Event.Accepted, OnAllocationsAccepted, slot);
								
								local allocationsCopy = transaction:GetAllocationsCopy(slotIndex);
								local disallowZeroAllocations = false;
								local characterInventoryOnly = true;
								self.QualityDialog:Open(recipeID, reagentSlotSchematic, allocationsCopy, slotIndex, disallowZeroAllocations, characterInventoryOnly);
							end
						end
					end);

					slot.Button:SetScript("OnEnter", function()
						GameTooltip:SetOwner(slot.Button, "ANCHOR_RIGHT");
						Professions.SetupQualityReagentTooltip(slot, transaction);
						if orderSource ~= Enum.CraftingOrderReagentSource.Any then
							GameTooltip_AddBlankLineToTooltip(GameTooltip);
							local sourceMsg = (orderSource == Enum.CraftingOrderReagentSource.Crafter) and PROFESSIONS_ORDER_CRAFTER_REQUIRED_REAGENT or PROFESSIONS_ORDER_CUSTOMER_REQUIRED_REAGENT;
							GameTooltip_AddHighlightLine(GameTooltip, sourceMsg);
						end
						GameTooltip:Show();
					end);
				else
					slot.Button:SetScript("OnClick", function(button, buttonName, down)
						if IsShiftKeyDown() then
							local handled, link = Professions.HandleFixedReagentItemLink(recipeID, reagentSlotSchematic);
							if not handled then
								Professions.TriggerReagentClickedEvent(link);
							end
							return;
						end
					end);

					slot.Button:SetScript("OnEnter", function()
						GameTooltip:SetOwner(slot.Button, "ANCHOR_RIGHT");
						local tooltipInfo = CreateBaseTooltipInfo("GetRecipeReagentItem", recipeID, reagentSlotSchematic.dataSlotIndex);
						tooltipInfo.tooltipPostCall = function(tooltip)
							if orderSource ~= Enum.CraftingOrderReagentSource.Any then
								GameTooltip_AddBlankLineToTooltip(tooltip);
								local sourceMsg = (orderSource == Enum.CraftingOrderReagentSource.Crafter) and PROFESSIONS_ORDER_CRAFTER_REQUIRED_REAGENT or PROFESSIONS_ORDER_CUSTOMER_REQUIRED_REAGENT;
								GameTooltip_AddHighlightLine(tooltip, sourceMsg);
							end
						end
						GameTooltip:ProcessInfo(tooltipInfo);
					end);
				end

				if committed and reagentSlotSchematic.required then
					slot:SetCheckmarkShown(hasAnyAllocation);
					slot:SetCheckmarkAtlas("Professions-Icon-Customer");
					slot:SetCheckmarkTooltipText(hasAnyAllocation and PROFESSIONS_CUSTOMER_ORDER_REAGENT_PROVIDED);
					slot:SetOverrideQuantity(hasAnyAllocation and reagentSlotSchematic.quantityRequired or 0);
				end
			else
				slot.Button:SetLocked(false);

				if reagentSlotSchematic.required then
					local canProvide = orderSource ~= Enum.CraftingOrderReagentSource.Crafter and not committed;
					local canAllocate = canProvide and Professions.CanAllocateReagents(transaction, slotIndex);
					slot:SetHighlightShown(canAllocate or (orderSource == Enum.CraftingOrderReagentSource.Customer and not committed));

					local canToggle = orderSource == Enum.CraftingOrderReagentSource.Any and not committed;
					if not canToggle then
						local alreadyModified = self.order.isRecraft and transaction:HasModification(reagentSlotSchematic.dataSlotIndex);
						SetupSlotOverride(slot, orderSource, canAllocate or alreadyModified, committed);
					end
				end
				
				if not optionalReagentHelptipShown and not committed then
					HelpTip:Show(self, optionalReagentsHelpTipInfo, slot);
					optionalReagentHelptipShown = true;
				end

				local function OverwriteAllocationWithQuantityInPossession(slotIndex, reagent, reagentSlotSchematic)
					local quantityOwned = ProfessionsUtil.GetReagentQuantityInPossession(reagent, self.transaction:ShouldUseCharacterInventoryOnly());
					local quantity = math.min(quantityOwned, reagentSlotSchematic.quantityRequired);
					self.transaction:OverwriteAllocation(slotIndex, reagent, quantity);
				end

				local function AllocateModificationWithQuantityInPossession(slotIndex, reagentSlotSchematic)
					local modification = self.transaction:GetModification(reagentSlotSchematic.dataSlotIndex);
					if modification and modification.itemID > 0 then
						local reagent = Professions.CreateCraftingReagentByItemID(modification.itemID);
						OverwriteAllocationWithQuantityInPossession(slotIndex, reagent, reagentSlotSchematic);
					end
				end

				slot.Button:SetScript("OnEnter", function()
					GameTooltip:SetOwner(slot.Button, "ANCHOR_RIGHT");

					local areRequirementsAllocated = not slot.originalItem or transaction:AreAllRequirementsAllocatedByItemID(slot.originalItem:GetItemID());
					local suppressInstruction = committed or (slot.originalItem and areRequirementsAllocated);
					Professions.SetupOptionalReagentTooltip(slot, recipeID, reagentSlotSchematic, nil, nil, suppressInstruction, self.transaction);
					GameTooltip:Show();
				end);
				
				slot.Button:SetScript("OnMouseDown", function(button, buttonName, down)
					if not slot:IsUnallocatable() then
						if buttonName == "LeftButton" then
							HelpTip:Hide(self, CRAFTING_ORDER_TUTORIAL_OPTIONAL_REAGENTS);

							local flyout = ToggleProfessionsItemFlyout(slot.Button, self);
							if flyout then
								local function OnUndoClicked(o, flyout)
									AllocateModificationWithQuantityInPossession(slotIndex, reagentSlotSchematic);
									
									slot:RestoreOriginalItem();
									slot:SetHighlightShown(false);
									
									self:UpdateListOrderButton();
									
									EventRegistry:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
								end

								local function OnFlyoutItemSelected(o, flyout, elementData)
									local item = elementData.item;
									local reagent = Professions.CreateCraftingReagentByItemID(item:GetItemID());
									OverwriteAllocationWithQuantityInPossession(slotIndex, reagent, reagentSlotSchematic);

									slot:SetItem(item);
									slot:SetHighlightShown(not slot:IsOriginalItemSet());
									 
									self:UpdateListOrderButton();
								end

								flyout.GetElementsImplementation = function(self, filterAvailable)
									local itemIDs = Professions.ExtractItemIDsFromCraftingReagents(reagentSlotSchematic.reagents);
									if filterAvailable then
										itemIDs = ItemUtil.FilterOwnedItems(itemIDs);
									end
									local items = ItemUtil.TransformItemIDsToItems(itemIDs);
									local elementData = {items = items, useCharacterInventoryOnly = self.transaction:ShouldUseCharacterInventoryOnly()};
									return elementData;
								end
								
								flyout.OnElementEnterImplementation = function(elementData, tooltip)
									Professions.FlyoutOnElementEnterImplementation(elementData, tooltip, recipeID, nil, self.transaction, reagentSlotSchematic, self.transaction:ShouldUseCharacterInventoryOnly());
								end
	
								flyout.OnElementEnabledImplementation = function(button, elementData, displayCount)
									if displayCount <= 0 then
										return false;
									end

									local item = elementData.item;
									local reagent = Professions.CreateCraftingReagentByItemID(item:GetItemID());
									if self.transaction:HasAllocatedReagent(reagent) then
										return false;
									end

									if not self.transaction:AreAllRequirementsAllocated(item) then
										return false;
									end

									local quantityOwned = ProfessionsUtil.GetReagentQuantityInPossession(reagent, self.transaction:ShouldUseCharacterInventoryOnly());
									if quantityOwned < reagentSlotSchematic.quantityRequired then
										return false;
									end

									local recraftAllocation = transaction:GetRecraftAllocation();
									if recraftAllocation and not C_TradeSkillUI.IsRecraftReagentValid(recraftAllocation, item:GetItemID()) then
										return false;
									end

									return true;
								end

								flyout.GetElementValidImplementation = function(button, elementData)
									return self.transaction:AreAllRequirementsAllocated(elementData.item);
								end

								flyout.GetUndoElementImplementation = function(self)
									if not slot:IsOriginalItemSet() then
										return slot:GetOriginalItem();
									end
								end

								flyout:Init(slot.Button, self.transaction);
								flyout:RegisterCallback(ProfessionsItemFlyoutMixin.Event.ItemSelected, OnFlyoutItemSelected, slot);
								flyout:RegisterCallback(ProfessionsItemFlyoutMixin.Event.UndoClicked, OnUndoClicked, slot);
							end
						elseif buttonName == "RightButton" then
							-- Normally you cannot remove the reagent if it is the original item unless you are replacing it with another
							-- reagent, however, in the case of infusions with dependent reagents, if a dependent reagent is changed to something
							-- the infusion cannot be supported on, we need to be able to explicly remove it from the order.
							if not slot.originalItem or not transaction:AreAllRequirementsAllocatedByItemID(slot.originalItem:GetItemID()) then
								transaction:ClearAllocations(slotIndex);

								slot:ClearItem();

								if not reagentSlotSchematic.required then
									-- Add icon not shown for modified + required reagents. This already
									-- displays a single large add icon.
									slot.Button.InputOverlay.AddIcon:Show();
								end

								slot:SetHighlightShown(false);

								self:UpdateListOrderButton();
							end
						end
					end
				end);
			end
		end
	end
	
	if committed then
		for slot in self.reagentSlotPool:EnumerateActive() do
			slot:SetUnallocatable(true);
			slot.Button.InputOverlay.AddIcon:Hide();
		end
	end
	
	do
		local spacingX, spacingY = 35, -5;
		local stride = 4;
		local direction = GridLayoutMixin.Direction.TopLeftToBottomRightVertical;
		Professions.LayoutReagentSlots(reagentTypes[Enum.CraftingReagentType.Basic], self.ReagentContainer.Reagents, spacingX, spacingY, stride, direction);
	end
	Professions.LayoutAndShowReagentSlotContainer(reagentTypes[Enum.CraftingReagentType.Modifying], self.ReagentContainer.OptionalReagents);

	self:UpdateListOrderButton();
end

function ProfessionsCustomerOrderFormMixin:GetPendingRecraftItemQuality()
	local item = Item:CreateFromItemGUID(self.recraftGUID);
	return C_TradeSkillUI.GetItemCraftedQualityByItemInfo(item:GetItemLink());
end

function ProfessionsCustomerOrderFormMixin:OrderCouldReduceQuality()
	if self.committed or not self.order.isRecraft or not self.recraftGUID or not self.minQualityIDs then
		return false;
	end

	local currentQuality = self:GetPendingRecraftItemQuality();
	if currentQuality == 1 then
		return false;
	end

	if self.order.orderType ~= Enum.CraftingOrderType.Public then
		return self.order.minQuality < currentQuality;
	end

	return true;
end

function ProfessionsCustomerOrderFormMixin:InitSchematic()
	self.ReagentContainer.Reagents:Show();
	self.ReagentContainer.OptionalReagents:Show();
	self.ReagentContainer.RecraftInfoText:Hide();
	self.TrackRecipeCheckbox:Hide();

	local recipeID = self.order.spellID;

	if recipeID and not self.committed then
		self.TrackRecipeCheckbox:Show();
		self.TrackRecipeCheckbox.Checkbox:SetChecked(C_TradeSkillUI.IsRecipeTracked(recipeID, self.order.isRecraft));
	end

	local recipeSchematic = self.order.spellID and C_TradeSkillUI.GetRecipeSchematic(self.order.spellID, self.order.isRecraft);
	self.transaction = recipeSchematic and CreateProfessionsRecipeTransaction(recipeSchematic);
	self.transaction:SetUseCharacterInventoryOnly(true);

	if self.order.isRecraft then
		if self.recraftGUID then
			self.transaction:SetRecraftAllocation(self.recraftGUID);
		else
			self.transaction:SetRecraftAllocationOrderID(self.order.orderID);
		end
		local function AllocateModification(slotIndex, reagentSlotSchematic)
			local modification = self.transaction:GetModification(reagentSlotSchematic.dataSlotIndex);
			if modification and modification.itemID > 0 then
				local reagent = Professions.CreateCraftingReagentByItemID(modification.itemID);
				self.transaction:OverwriteAllocation(slotIndex, reagent, reagentSlotSchematic.quantityRequired);
			end
		end
		for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
			if reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent then
				AllocateModification(slotIndex, reagentSlotSchematic);
			end
		end
	end

	self.RecraftSlot:Init(self.transaction, AnyRecraftablePredicate, function(itemGUID) self:SetRecraftItemGUID(itemGUID); end, self.order.recraftItemHyperlink);
	SetItemCraftingQualityOverlayOverride(self.RecraftSlot.OutputSlot, self.order.minQuality or 1);

	self.minQualityIDs = recipeID and C_TradeSkillUI.GetQualitiesForRecipe(recipeID);

	if self.committed then
		for _, reagentInfo in ipairs(self.order.reagents) do
			self.transaction:OverwriteAllocation(reagentInfo.slotIndex, reagentInfo.reagent, reagentInfo.reagent.quantity);
		end
	else
		Professions.AllocateAllBasicReagents(self.transaction, true);
	end

	if self.order.isRecraft then
		if self.committed then
			-- After the allocations above, strip any reagents that fail to meet prerequisites. This is a workaround for
			-- incompatible reagents being part of the original order data because it is not removed until the item is
			-- actually recreated. Since the crafter cannot modify this slot anyways, it's empty state will be the only
			-- correct state.
			for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
				if reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent then
					-- Skip any slots where the existing modification was replaced by another customer provided slot.
					local allocs = self.transaction:GetAllocations(slotIndex);
					local alloc = allocs:SelectFirst();
					if alloc then
						local reagent = alloc:GetReagent();
						local itemID = reagent.itemID;
						if itemID and itemID > 0 and not self.transaction:AreAllRequirementsAllocatedByItemID(itemID) then
							self.transaction:ClearAllocations(slotIndex);
							self.transaction:ClearModification(reagentSlotSchematic.dataSlotIndex);
						end
					end
				end
			end
		end

		self.RecraftRecipeName:Show();
		self.loader = CreateProfessionsRecipeLoader(recipeSchematic, function()
			local reagents = nil;
			local outputItemInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, reagents);
			if outputItemInfo.hyperlink then
				local item = Item:CreateFromItemLink(outputItemInfo.hyperlink);
				local itemName = item:GetItemName();
				local hasMinQuality = (self.order.minQuality ~= nil and self.order.minQuality > 1) and self.committed;
				if hasMinQuality then
					itemName = itemName.." "..CreateAtlasMarkup(string.format("Professions-Icon-Quality-Tier%d-Small", self.order.minQuality));
				end
				self.RecraftRecipeName:SetText(PROFESSIONS_ORDER_RECRAFT_TITLE_FMT:format(item:GetItemQualityColor().color:WrapTextInColorCode(itemName)));
			else
				self.RecraftRecipeName:SetText(PROFESSIONS_ORDER_RECRAFT_TITLE_FMT:format(recipeSchematic.name));
			end
		end);
	else
		self.loader = CreateProfessionsRecipeLoader(recipeSchematic, function()
			local reagents = nil;
			local outputItemInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, reagents);
			if outputItemInfo.hyperlink then
				local item = Item:CreateFromItemLink(outputItemInfo.hyperlink);
				local itemName = item:GetItemName();
				local hasMinQuality = (self.order.minQuality ~= nil and self.order.minQuality > 1) and self.committed;
				if hasMinQuality then
					itemName = itemName.." "..CreateAtlasMarkup(string.format("Professions-Icon-Quality-Tier%d-Small", self.order.minQuality));
				end
				self.RecipeName:SetText(itemName);
				self.RecipeName:SetTextColor(item:GetItemQualityColorRGB());
			else
				self.RecipeName:SetText(recipeSchematic.name);
				self.RecipeName:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
			end

			self.RecipeName:SetHeight(self.RecipeName:GetStringHeight());

			Professions.SetupOutputIcon(self.OutputIcon, self.transaction, outputItemInfo);
		end);

		self.OutputIcon:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.OutputIcon, "ANCHOR_RIGHT");
			local optionalReagents = self.transaction:CreateOptionalCraftingReagentInfoTbl();
			local minimumQuality = self.minQualityIDs and self.minQualityIDs[self.order.minQuality];
			self.OutputIcon:SetScript("OnUpdate", function()
				GameTooltip:SetRecipeResultItem(recipeSchematic.recipeID, optionalReagents, nilRecraftAllocation, nilRecipeLevel, minimumQuality);
			end);
		end);
		self.OutputIcon:SetScript("OnLeave", function()
			GameTooltip_Hide();
			self.OutputIcon:SetScript("OnUpdate", nil);
		end);
		self.OutputIcon:SetScript("OnClick", function()
			local optionalReagents = self.transaction:CreateOptionalCraftingReagentInfoTbl();
			local minimumQuality = self.minQualityIDs and self.minQualityIDs[self.order.minQuality];
			local outputItemInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, optionalReagents, nilRecraftAllocation, minimumQuality);
			if outputItemInfo.hyperlink then
				HandleModifiedItemClick(outputItemInfo.hyperlink);
			end
		end);
	end

	local professionName = C_TradeSkillUI.GetProfessionNameForSkillLineAbility(self.order.skillLineAbilityID);
	self.ProfessionText:SetText(CRAFTING_ORDER_RECIPE_PROFESSION_FMT:format(professionName));
	self.ProfessionText:ClearAllPoints();
	if self.order.isRecraft then
		self.ProfessionText:SetPoint("TOPLEFT", self.RecraftRecipeName, "BOTTOMLEFT", 0, -5);
	else
		self.ProfessionText:SetPoint("TOPLEFT", self.RecipeName, "BOTTOMLEFT", 0, -5);
	end
	self.ProfessionText:Show();

	self:UpdateReagentSlots();
	self:UpdateMinimumQuality();
	self:UpdateDepositCost();
	self:UpdateListOrderButton();

	if not self.committed and Professions.DoesSchematicIncludeReagentQualities(self.transaction:GetRecipeSchematic()) then
		self.AllocateBestQualityCheckbox:Show();
		local forCustomer = true;
		self.AllocateBestQualityCheckbox:SetChecked(Professions.ShouldAllocateBestQualityReagents(forCustomer));
	else
		self.AllocateBestQualityCheckbox:Hide();
	end
end

function ProfessionsCustomerOrderFormMixin:UpdateMinimumQualityAnchor()
	self.MinimumQuality:ClearAllPoints();
	local targetVisible = self.OrderRecipientTarget:IsShown();
	local minimumQualityAnchorTo = targetVisible and self.OrderRecipientTarget or self.OrderRecipientDropdown;
	local yOfs = targetVisible and -3 or -6;
	self.MinimumQuality:SetPoint("TOPRIGHT", minimumQualityAnchorTo, "BOTTOMRIGHT", 0, yOfs);
end

function ProfessionsCustomerOrderFormMixin:Init(order)
	self.order = order;
	if order.minQuality < 1 then
		order.minQuality = 1;
	end

	self.duration = Professions.GetDefaultOrderDuration();
	self.depositCost = 0;
	self.committed = order.orderID ~= nil;
	self.transaction = nil;
	self.RecraftSlot:Init(self.transaction, AnyRecraftablePredicate, function(itemGUID) self:SetRecraftItemGUID(itemGUID); end, self.order.recraftItemHyperlink);
	self.minQualityIDs = nil;
	self.recraftGUID = nil;
	if self.loader then
		self.loader:Cancel();
		self.loader = nil;
	end
	self:HideCurrentListings();
	self.pendingOrderPlacement = false;

	self.OutputIcon:SetShown(not order.isRecraft);
	self.RecipeName:SetShown(not order.isRecraft);
	self.RecraftRecipeName:Hide();
	self.RecraftSlot:SetShown(order.isRecraft);
	self.ReagentContainer.RecraftInfoText:SetShown(order.isRecraft);
	self.AllocateBestQualityCheckbox:Hide();

	local editBox = self.PaymentContainer.NoteEditBox.ScrollingEditBox;
	editBox:SetDefaultTextEnabled(not self.committed);
	editBox:SetText(order.customerNotes or "");
	editBox:SetEnabled(not self.committed);
	self.PaymentContainer.NoteEditBox:SetShown(not C_CraftingOrders.AreOrderNotesDisabled());

	local completed = (order.orderState == Enum.CraftingOrderState.Expired or order.orderState == Enum.CraftingOrderState.Rejected or order.orderState == Enum.CraftingOrderState.Canceled or order.orderState == Enum.CraftingOrderState.Fulfilled);

	local function ShouldShowRegionCompleted(region)
		if region.hideWhenCompleted then
			return not completed;
		end

		if region.hideWhenNotCompleted then
			return completed;
		end

		return true;
	end

	for _, region in ipairs(self.uncommittedRegions) do
		region:SetShown(not self.committed and ShouldShowRegionCompleted(region));
	end
	for _, region in ipairs(self.PaymentContainer.uncommittedRegions) do
		region:SetShown(not self.committed and ShouldShowRegionCompleted(region));
	end

	for _, region in ipairs(self.committedRegions) do
		region:SetShown(self.committed and ShouldShowRegionCompleted(region));
	end
	for _, region in ipairs(self.PaymentContainer.committedRegions) do
		region:SetShown(self.committed and ShouldShowRegionCompleted(region));
	end

	self.TrackRecipeCheckbox:Hide();

	local showFavoriteButton = not order.isRecraft;
	self.FavoriteButton:SetShown(showFavoriteButton);
	if showFavoriteButton then
		local isFavorite = C_CraftingOrders.IsCustomerOptionFavorited(order.spellID);
		self.FavoriteButton:SetChecked(isFavorite);
		self.FavoriteButton:SetIsFavorite(isFavorite);
	end

	self.PaymentContainer.PostingFee:ClearAllPoints();
	local xOfs = 0;
	local yOfs = completed and 40 or 0;
	self.PaymentContainer.PostingFee:SetPoint("TOPLEFT", self.PaymentContainer.Duration, "BOTTOMLEFT", xOfs, yOfs);

	if self.order.spellID then
		self:InitSchematic();
	else
		self.ReagentContainer.Reagents:Hide();
		self.ReagentContainer.OptionalReagents:Hide();
		self.MinimumQuality:Hide();
		self.PaymentContainer.PostingFee:Hide();
		self.PaymentContainer.PostingFeeMoneyDisplayFrame:Hide();
		self.ProfessionText:Hide();
		self.MinimumQualityIcon:Hide();

		if not self.committed and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PROFESSIONS_RECRAFT) then
			local recraftSlotHelpTipInfo =
			{
				text = CRAFTING_ORDER_TUTORIAL_RECRAFT,
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				system = helptipSystemName,
				acknowledgeOnHide = true,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_PROFESSIONS_RECRAFT,
			};
			HelpTip:Show(self, recraftSlotHelpTipInfo, self.RecraftSlot.InputSlot);
		end
	end

	if not self.committed then
		self:SetupQualityDropdown();
		self:SetupOrderRecipientDropdown();
		self:SetupDurationDropdown();
		self:UpdateTotalPrice();

		self.OrderRecipientTarget:SetShown(self.order.orderType == Enum.CraftingOrderType.Personal);
		self.PaymentContainer.TipMoneyInputFrame:SetAmount(order.tipAmount);
		self:UpdateMinimumQualityAnchor();

		self.ReagentContainer.Reagents.Label:SetText(PROFESSIONS_CUSTOMER_REAGENT_CONTAINER_LABEL);
		self.ReagentContainer.OptionalReagents.Label:SetText(PROFESSIONS_CUSTOMER_OPTIONAL_REAGENT_CONTAINER_LABEL);

		self.PaymentContainer.ViewListingsButton:SetShown(not self.order.isRecraft);

		if not order.isRecraft then
			self:RequestCurrentListingsForCommission();
		end
	else
		self.PaymentContainer.TipMoneyDisplayFrame:SetAmount(order.tipAmount);

		local remainingTime = Professions.GetCraftingOrderRemainingTime(order.expirationTime);
		local seconds = remainingTime >= 60 and remainingTime or 60; -- Never show < 1min
		local timeRemainingText = Professions.OrderTimeLeftFormatter:Format(seconds);
		if self.order.orderState ~= Enum.CraftingOrderState.Created then
			timeRemainingText = CRAFTING_ORDER_TIME_PENDING_FMT:format(timeRemainingText);
		end
		self.PaymentContainer.TimeRemainingDisplay.Text:SetText(timeRemainingText);

		self.OrderRecipientDisplay.SocialDropdown:SetShown(order.crafterName ~= nil);
		local crafterText;
		if order.crafterName then
			crafterText = order.crafterName;
			self:SetWhisperCrafterStatus(Enum.ChatWhisperTargetStatus.Offline);
			C_ChatInfo.RequestCanLocalWhisperTarget(order.crafterGuid);
		elseif self.order.orderState == Enum.CraftingOrderState.Created then
			crafterText = CRAFTING_ORDER_NOT_YET_CLAIMED;
		else
			crafterText = CRAFTING_ORDER_NOT_CLAIMED;
		end
		self.OrderRecipientDisplay.CrafterValue:SetText(crafterText);

		local orderTypeText;
		if self.order.orderType == Enum.CraftingOrderType.Public then
			orderTypeText = PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_PUBLIC;
		elseif self.order.orderType == Enum.CraftingOrderType.Guild then
			orderTypeText = PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_GUILD;
		elseif self.order.orderType == Enum.CraftingOrderType.Personal then
			orderTypeText = PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_PRIVATE;
		end
		self.OrderRecipientDisplay.PostedTo:SetText(orderTypeText);

		local orderStateText;
		if self.order.orderState == Enum.CraftingOrderState.Created then
			orderStateText = CRAFTING_ORDER_NOT_CLAIMED;
		elseif self.order.orderState == Enum.CraftingOrderState.Expired then
			orderStateText = PROFESSIONS_ORDER_EXPIRED;
		elseif self.order.orderState == Enum.CraftingOrderState.Canceled then
			orderStateText = PROFESSIONS_ORDER_CANCELLED;
		elseif self.order.orderState == Enum.CraftingOrderState.Rejected then
			orderStateText = PROFESSIONS_ORDER_REJECTED;
		elseif self.order.orderState == Enum.CraftingOrderState.Claimed then
			orderStateText = PROFESSIONS_CRAFTING_ORDER_IN_PROGRESS;
		else
			orderStateText = PROFESSIONS_ORDER_COMPLETE;
		end
		self.OrderStateText:SetText(orderStateText);

		self:UpdateCancelOrderButton();

		self.ReagentContainer.Reagents.Label:SetText(PROFESSIONS_PROVIDED_REAGENT_CONTAINER_LABEL);
		self.ReagentContainer.OptionalReagents.Label:SetText(PROFESSIONS_PROVIDED_OPTIONAL_REAGENT_CONTAINER_LABEL);

		self:UpdateMinimumQuality();
	end
end

function ProfessionsCustomerOrderFormMixin:UpdateTotalPrice()
	local tip = self.committed and self.order.tipAmount or self.PaymentContainer.TipMoneyInputFrame:GetAmount();
	local total = self.depositCost + tip;
	self.PaymentContainer.TotalPriceMoneyDisplayFrame:SetAmount(total);

	if not self.committed then
		self:UpdateListOrderButton();
	end
end

function ProfessionsCustomerOrderFormMixin:AreRequiredReagentsProvided()
	local transaction = self.transaction;
	local recipeSchematic = transaction:GetRecipeSchematic();
	for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		local mustProvide = (reagentSlotSchematic.required and ((reagentSlotSchematic.orderSource == Enum.CraftingOrderReagentSource.Customer) or ((reagentSlotSchematic.orderSource == Enum.CraftingOrderReagentSource.Any) and (self.order.orderType == Enum.CraftingOrderType.Public))));
		if mustProvide and not transaction:HasAllAllocations(slotIndex) then
			return false;
		end
	end

	return true;
end

function ProfessionsCustomerOrderFormMixin:AnyModifyingReagentsChanged()
	local transaction = self.transaction;
	local recipeSchematic = transaction:GetRecipeSchematic();
	for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Modifying then
			local originalModification = transaction:GetOriginalModification(reagentSlotSchematic.dataSlotIndex);
			local originalModItemID = originalModification and originalModification.itemID;
			local currentAllocation = transaction:GetAllocations(slotIndex);
			local allocs = currentAllocation:SelectFirst();
			local currentAllocationItemID = 0;
			if allocs then
				local reagent = allocs:GetReagent();
				currentAllocationItemID = reagent.itemID;
			end
			if originalModItemID ~= currentAllocationItemID then
				return true;
			end
		end
	end
	return false;
end

function ProfessionsCustomerOrderFormMixin:UpdateListOrderButton()
	if self.committed then
		return;
	end
	
	local listOrderButton = self.PaymentContainer.ListOrderButton;

	local enabled = true;
	local errorText;

	if self.pendingOrderPlacement then
		enabled = false;
	elseif self.order.isRecraft and not self.order.skillLineAbilityID then
		enabled = false;
		errorText = PROFESSIONS_MUST_SELECT_RECRAFT_TARGET;
	elseif self.order.isRecraft and self:GetPendingRecraftItemQuality() == #self.minQualityIDs and not self:AnyModifyingReagentsChanged() then
		enabled = false;
		errorText = CRAFTING_ORDER_RECRAFT_CANT_CRAFT;
	elseif not self:AreRequiredReagentsProvided() then
		enabled = false;
		errorText = PROFESSIONS_INSUFFICIENT_REAGENTS_CUSTOMER;
	elseif not self.transaction:HasMetPrerequisiteRequirements() then
		enabled = false;
		errorText = PROFESSIONS_PREREQUISITE_REAGENTS_CUSTOMER;
	elseif self.order.orderType == Enum.CraftingOrderType.Personal and self.OrderRecipientTarget:GetText() == "" then
		enabled = false;
		errorText = PRFOESSIONS_MISSING_ORDER_TARGET;
	elseif self.PaymentContainer.TipMoneyInputFrame:GetAmount() <= 0 then
		enabled = false;
		errorText = PROFESSIONS_ORDER_MUST_TIP;
	elseif self.PaymentContainer.TotalPriceMoneyDisplayFrame:GetAmount() > GetMoney() then
		enabled = false;
		errorText = NOT_ENOUGH_GOLD;
	end

	listOrderButton:SetEnabled(enabled);

	if errorText then
		listOrderButton:SetScript("OnEnter", function()
			GameTooltip:SetOwner(listOrderButton, "ANCHOR_RIGHT");
			GameTooltip_AddErrorLine(GameTooltip, errorText);
			GameTooltip:Show();
		end);
	else
		listOrderButton:SetScript("OnEnter", nil);
	end
end

function ProfessionsCustomerOrderFormMixin:UpdateCancelOrderButton()
	local enabled = true;
	local errorText;

	if self.order.orderState ~= Enum.CraftingOrderState.Created then
		enabled = false;
		errorText = PROFESSIONS_ORDER_CANT_CANCEL_CLAIMED;
	end

	self.PaymentContainer.CancelOrderButton:SetEnabled(enabled);

	if errorText then
		self.PaymentContainer.CancelOrderButton:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.PaymentContainer.CancelOrderButton, "ANCHOR_RIGHT");
			GameTooltip_AddErrorLine(GameTooltip, errorText);
			GameTooltip:Show();
		end);
	else
		self.PaymentContainer.CancelOrderButton:SetScript("OnEnter", nil);
	end
end

function ProfessionsCustomerOrderFormMixin:ListOrder()
    local craftingReagentTbl = self.transaction:CreateCraftingReagentInfoTbl();
    local itemMods = self.transaction:GetRecraftItemMods();
    if itemMods then
        for dataSlotIndex, modification in ipairs(itemMods) do
            if modification.itemID > 0 then
                for _, craftingReagentInfo in ipairs(craftingReagentTbl) do
                    if (craftingReagentInfo.itemID == modification.itemID) and (craftingReagentInfo.dataSlotIndex == modification.dataSlotIndex) then
                        -- If the modification still exists in the same position, set it's quantity to 0 to inform the server
                        -- not to modify this reagent.
                        craftingReagentInfo.quantity = 0;
                        break;
                    end
                end
            end
        end
    end
	local newOrderInfo =
	{
		skillLineAbilityID = self.order.skillLineAbilityID,
		orderType = self.order.orderType,
		orderDuration = self.duration,
		tipAmount = self.PaymentContainer.TipMoneyInputFrame:GetAmount(),
		customerNotes = self.PaymentContainer.NoteEditBox.ScrollingEditBox:GetInputText(),
		reagentItems = self.transaction:CreateRegularReagentInfoTbl(),
		craftingReagentItems = craftingReagentTbl,
		recraftItem = self.recraftGUID,
	};
	newOrderInfo.customerNotes = string.gsub(newOrderInfo.customerNotes, "\n", "");

	if self.order.orderType ~= Enum.CraftingOrderType.Public and self.minQualityIDs then
		newOrderInfo.minCraftingQualityID = self.order.minQuality > 1 and self.minQualityIDs[self.order.minQuality] or 0;
	end

	if self.order.orderType == Enum.CraftingOrderType.Personal then
		newOrderInfo.orderTarget = self.OrderRecipientTarget:GetText();
	end

	C_CraftingOrders.PlaceNewOrder(newOrderInfo);
	self.pendingOrderPlacement = true;
	self:UpdateListOrderButton();
end

local baseFrameWidth = 800;
local currentListingsPopoutFrameWidth = 330;

function ProfessionsCustomerOrderFormMixin:HideCurrentListings()
	self.CurrentListings:Hide();

	local ordersPanel = self:GetParent();
	SetUIPanelAttribute(ordersPanel, "width", baseFrameWidth);
	UpdateUIPanelPositions(ordersPanel);
end

function ProfessionsCustomerOrderFormMixin:ShowCurrentListings()
	self.CurrentListings:Show();

	local ordersPanel = self:GetParent();
	SetUIPanelAttribute(ordersPanel, "width", baseFrameWidth + currentListingsPopoutFrameWidth);
	UpdateUIPanelPositions(ordersPanel);

	self:RequestCurrentListings();
end

function ProfessionsCustomerOrderFormMixin:SendOrderRequest(request, requestCallback)
	self.lastRequest = request;

	if self.requestCallback then
		self.requestCallback:Cancel();
	end
	self.requestCallback = requestCallback;
	request.callback = self.requestCallback;
	C_CraftingOrders.RequestCustomerOrders(request);
end

function ProfessionsCustomerOrderFormMixin:RequestCurrentListings()
	self.CurrentListings.OrderList.ResultsText:Hide();
	self.CurrentListings.OrderList.LoadingSpinner:Show();
	self.CurrentListings.OrderList.ScrollBox:Hide();

	local selectedSkillLineAbility = self.order.skillLineAbilityID;
	local request =
	{
		orderType = Enum.CraftingOrderType.Public,
		selectedSkillLineAbility = selectedSkillLineAbility,
		searchFavorites = false,
		initialNonPublicSearch = false,
		offset = 0,
		forCrafter = false,
		primarySort = Professions.TranslateSearchSort(self.CurrentListings.primarySort),
		secondarySort = Professions.TranslateSearchSort(self.CurrentListings.secondarySort),
	};
	local requestCallback = C_FunctionContainers.CreateCallback(function(...) self:OrderRequestCallback(...); end);
	self:SendOrderRequest(request, requestCallback);
end

function ProfessionsCustomerOrderFormMixin:RequestCurrentListingsForCommission()
    local selectedSkillLineAbility = self.order.skillLineAbilityID;
	local request =
	{
		orderType = Enum.CraftingOrderType.Public,
		selectedSkillLineAbility = selectedSkillLineAbility,
		searchFavorites = false,
		initialNonPublicSearch = false,
		offset = 0,
		forCrafter = false,
		primarySort = { sortType = Enum.CraftingOrderSortType.Tip, reversed = true, },
		secondarySort = { sortType = Enum.CraftingOrderSortType.Reagents, reversed = true, },
	};
	local requestCallback = C_FunctionContainers.CreateCallback(function(result)
		if result == Enum.CraftingOrderResult.Ok then
			local orders = C_CraftingOrders.GetCustomerOrders();
			if #orders > 0 and self.PaymentContainer.TipMoneyInputFrame:GetAmount() == 0 then
				local topPayingOrder = orders[1];
				local maxGold = 99999999999;
				-- Default commission is 1 silver than the highest current order
				local defaultCommission = math.min(topPayingOrder.tipAmount + 100, maxGold);
				self.PaymentContainer.TipMoneyInputFrame:SetAmount(defaultCommission);
			end
		end
		self.requestCallback = nil;
	end);
	self:SendOrderRequest(request, requestCallback);
end

function ProfessionsCustomerOrderFormMixin:DisplayCurrentListings(offset, isSorted)
	self.CurrentListings.OrderList.LoadingSpinner:Hide();
	self.CurrentListings.OrderList.ScrollBox:Show();

	local orders = C_CraftingOrders.GetCustomerOrders();

	if #orders == 0 then
		self.CurrentListings.OrderList.ResultsText:SetText(PROFESSIONS_CUSTOMER_NO_ORDERS);
		self.CurrentListings.OrderList.ResultsText:Show();
	else
		self.CurrentListings.OrderList.ResultsText:Hide();
	end
	if not isSorted then
		table.sort(orders, function(lhs, rhs)
			local res, equal = Professions.ApplySortOrder(self.primarySort.order);
			if not equal then
				if self.primarySort.ascending then
					return res;
				else
					return not res;
				end
			end

			if self.secondarySort then
				res, equal = Professions.ApplySortOrder(self.secondarySort.order);
				if self.secondarySort.ascending then
					return res;
				else
					return equal or (not res);
				end
			end

			return true;
		end);
	end

	local dataProvider;
	if offset == 0 then
		dataProvider = CreateDataProvider();
	for _, order in ipairs(orders) do
		dataProvider:Insert({option = order});
	end
	self.CurrentListings.OrderList.ScrollBox:SetDataProvider(dataProvider);
	else
		dataProvider = self.CurrentListings.OrderList.ScrollBox:GetDataProvider();
		for idx = offset + 1, #orders do
			local order = orders[idx];
			dataProvider:Insert({option = order});
		end
	end
end

function ProfessionsCustomerOrderFormMixin:OrderRequestCallback(result, orderType, displayBuckets, expectMoreRows, offset, isSorted)
	self.expectMoreRows = expectMoreRows;

	self:DisplayCurrentListings(offset, isSorted);

	self.requestCallback = nil;
end

function ProfessionsCustomerOrderFormMixin:RequestMoreOrders()
	if (not self.expectMoreRows) or (not self.lastRequest) or (self.requestCallback ~= nil) then
		return;
	end

	local request = self.lastRequest;
	request.offset = self.numOrders;
	local requestCallback = C_FunctionContainers.CreateCallback(function(...) self:OrderRequestCallback(...); end);
	self:SendOrderRequest(request, requestCallback);
end

function ProfessionsCustomerOrderFormMixin:GetWhisperCrafterStatus()
	return self.whisperCrafterStatus;
end

function ProfessionsCustomerOrderFormMixin:SetWhisperCrafterStatus(status)
	self.whisperCrafterStatus = status;
end