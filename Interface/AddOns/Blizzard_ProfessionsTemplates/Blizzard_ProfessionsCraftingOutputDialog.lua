ProfessionsCraftingOutputDialogMixin = CreateFromMixins(CallbackRegistryMixin);

ProfessionsCraftingOutputDialogMixin:GenerateCallbackEvents(
{
    "OrderFinalized",
    "OrderRecraft",
});

function ProfessionsCraftingOutputDialogMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	local function OnCancel()
		self:Hide();
	end

	self.CloseButton:SetScript("OnClick", OnCancel);

	self.FinalizeButton:SetTextToFit(PROFESSIONS_CRAFTING_FINALIZE_ORDER);
	self.FinalizeButton:SetScript("OnClick", function(button, buttonName, down)
		local message = self.ScrollBoxContainer.ScrollingEditBox:GetInputText();
		self:TriggerEvent(ProfessionsCraftingOutputDialogMixin.Event.OrderFinalized, message);
		self:Hide();
	end);

	self.RecraftButton:SetTextToFit(PROFESSIONS_CRAFTING_RECRAFT);
	self.RecraftButton:SetScript("OnClick", function(button, buttonName, down)
		local message = self.ScrollBoxContainer.ScrollingEditBox:GetInputText();
		self:TriggerEvent(ProfessionsCraftingOutputDialogMixin.Event.OrderRecraft);
		self:Hide();
	end);

	self.Header:SetText(PROFESSIONS_CRAFTING_COMPLETE);
	self.Note:SetText(PROFESSIONS_CRAFTING_FORM_NOTE_TO_CUSTOMER);
end

function ProfessionsCraftingOutputDialogMixin:OnHide()
	self:UnregisterEvents();
end

function ProfessionsCraftingOutputDialogMixin:Init(transaction, quality)
	local recipeID = transaction:GetRecipeID();

	local reagents = nil;
	local outputItemInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, reagents, transaction:GetAllocationItemGUID());
	if outputItemInfo.hyperlink then
		local item = Item:CreateFromItemLink(outputItemInfo.hyperlink);
		self.RecipeName:SetText(item:GetItemName());
		self.RecipeName:SetTextColor(item:GetItemQualityColorRGB());
	else
		self.RecipeName:SetText(self.recipeSchematic.name);
		self.RecipeName:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end

	Professions.SetupOutputIcon(self.OutputIcon, transaction, outputItemInfo);

	local atlasSize = 25;
	local atlasMarkup = CreateAtlasMarkup(Professions.GetIconForQuality(quality), atlasSize, atlasSize);
	self.MinimumQuality:SetText(PROFESSIONS_CRAFTING_FORM_OUTPUT_QUALITY:format(atlasMarkup));

	local editBox = self.ScrollBoxContainer.ScrollingEditBox;
	editBox:SetDefaultTextEnabled(true);
	editBox:ClearText();

	self.OutputIcon:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.OutputIcon, "ANCHOR_RIGHT");

		local reagents = transaction:CreateOptionalCraftingReagentInfoTbl();
		self.OutputIcon:SetScript("OnUpdate", function() 
			GameTooltip:SetRecipeResultItem(recipeID, reagents, transaction:GetAllocationItemGUID());
		end);
	end);
	
	self.OutputIcon:SetScript("OnLeave", function()
		GameTooltip_Hide(); 
		self.OutputIcon:SetScript("OnUpdate", nil);
	end);

	self.OutputIcon:SetScript("OnClick", function()
		local link = C_TradeSkillUI.GetRecipeItemLink(recipeID);
		HandleModifiedItemClick(link);
	end);
end

function ProfessionsCraftingOutputDialogMixin:Open(transaction, quality)
	self:Init(transaction, quality);
	self:Show();
end