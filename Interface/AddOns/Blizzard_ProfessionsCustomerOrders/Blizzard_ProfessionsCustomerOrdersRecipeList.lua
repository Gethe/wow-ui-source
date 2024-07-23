
ProfessionsCustomerOrdersRecipeListElementMixin = CreateFromMixins(TableBuilderRowMixin);

function ProfessionsCustomerOrdersRecipeListElementMixin:OnLoad()
	self:RegisterEvent("CRAFTINGORDERS_CUSTOMER_FAVORITES_CHANGED");

	self.FavoriteButton:SetScript("OnLeave", function()
		GameTooltip_Hide();
		self:OnLineLeave();
	end);
	local function OnFavoriteButtonEnter(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		if not self:IsFavorite() and C_CraftingOrders.GetNumFavoriteCustomerOptions() >= Constants.CraftingOrderConsts.MAX_CRAFTING_ORDER_FAVORITE_RECIPES then
			GameTooltip_AddErrorLine(GameTooltip, PROFESSIONS_CRAFTING_ORDERS_FAVORITES_FULL);
		else
			GameTooltip_AddHighlightLine(GameTooltip, self:IsFavorite() and BATTLE_PET_UNFAVORITE or BATTLE_PET_FAVORITE);
		end
		GameTooltip:Show();
	end
	self.FavoriteButton:SetScript("OnEnter", OnFavoriteButtonEnter);
	self.FavoriteButton:SetScript("OnClick", function(frame)
		if not self:IsFavorite() and C_CraftingOrders.GetNumFavoriteCustomerOptions() >= Constants.CraftingOrderConsts.MAX_CRAFTING_ORDER_FAVORITE_RECIPES then
			return;
		end

		C_CraftingOrders.SetCustomerOptionFavorited(self.option.spellID, not self:IsFavorite());
		OnFavoriteButtonEnter(frame);
	 end);
end

function ProfessionsCustomerOrdersRecipeListElementMixin:OnEvent()
	self:UpdateFavoriteButton();
end

function ProfessionsCustomerOrdersRecipeListElementMixin:OnLineEnter()
	self.isMouseFocus = true;
	self.HighlightTexture:Show();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local reagents = {};
	local qualityIDs = C_TradeSkillUI.GetQualitiesForRecipe(self.option.spellID);
	GameTooltip:SetRecipeResultItem(self.option.spellID, reagents, nil, nil, qualityIDs and qualityIDs[1]);

	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	end

	self.FavoriteButton:Show();

	self:SetScript("OnUpdate", self.OnUpdate);
end

function ProfessionsCustomerOrdersRecipeListElementMixin:OnLineLeave()
	if self.FavoriteButton:IsMouseMotionFocus() then
		return;
	end

	self.isMouseFocus = false;
	self.HighlightTexture:Hide();
	GameTooltip:Hide();
	ResetCursor();
	self:SetScript("OnUpdate", nil);

	if not self:IsFavorite() then
		self.FavoriteButton:Hide();
	end
end

-- Set and cleared dynamically in OnEnter and OnLeave
function ProfessionsCustomerOrdersRecipeListElementMixin:OnUpdate()
	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function ProfessionsCustomerOrdersRecipeListElementMixin:OnClick(button)
	if button == "LeftButton" then
		local function UseItemLink(callback)
			local item = Item:CreateFromItemID(self.option.itemID);
			item:ContinueOnItemLoad(function()
				callback(item:GetItemLink());
			end);
		end

		if IsModifiedClick("DRESSUP") then
			UseItemLink(DressUpLink);
		elseif IsModifiedClick("CHATLINK") then
			UseItemLink(ChatEdit_InsertLink);
		else
			local unusableBOP = self.option.bindOnPickup and not self.option.canUse;
			EventRegistry:TriggerEvent("ProfessionsCustomerOrders.RecipeSelected", self.option.itemID, self.option.spellID, self.option.skillLineAbilityID, unusableBOP);
		end
	elseif button == "RightButton" then
		if self.contextMenuGenerator then
			MenuUtil.CreateContextMenu(self, self.contextMenuGenerator, self.option.spellID);
		end
	end
end

function ProfessionsCustomerOrdersRecipeListElementMixin:IsFavorite()
	return C_CraftingOrders.IsCustomerOptionFavorited(self.option.spellID);
end

function ProfessionsCustomerOrdersRecipeListElementMixin:UpdateFavoriteButton()
	local isFavorite = self:IsFavorite();
	local currAtlas = isFavorite and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off";
	self.FavoriteButton.NormalTexture:SetAtlas(currAtlas, TextureKitConstants.IgnoreAtlasSize);
	self.FavoriteButton.HighlightTexture:SetAtlas(currAtlas, TextureKitConstants.IgnoreAtlasSize);
	self.FavoriteButton.HighlightTexture:SetAlpha(isFavorite and 0.2 or 0.4);
	self.FavoriteButton:SetShown(isFavorite or self.isMouseFocus);
end

function ProfessionsCustomerOrdersRecipeListElementMixin:Init(elementData, contextMenuGenerator)
	self.option = elementData.option;
	self.contextMenuGenerator = contextMenuGenerator;
	self:UpdateFavoriteButton();
	self.HighlightTexture:Hide();
end

ProfessionsCustomerOrdersRecipeListMixin = {};

function ProfessionsCustomerOrdersRecipeListMixin:OnLoad()
	local pad = 5;
	local spacing = 1;
	local view = CreateScrollBoxListLinearView(pad, pad, pad, pad, spacing);
	view:SetElementInitializer("ProfessionsCustomerOrdersRecipeListElementTemplate", function(button, elementData)
		button:Init(elementData, self.contextMenuGenerator);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function ProfessionsCustomerOrdersRecipeListMixin:SetContextMenuGenerator(contextMenuGenerator)
	self.contextMenuGenerator = contextMenuGenerator;
end
