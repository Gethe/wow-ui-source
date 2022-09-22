ProfessionsRecraftSlotMixin = {};

function ProfessionsRecraftSlotMixin:OnLoad()
	self.InputSlot:SetScript("OnLeave", GameTooltip_Hide);
	self.OutputSlot:SetScript("OnLeave", GameTooltip_Hide);
end

function ProfessionsRecraftSlotMixin:Init(transaction)
	local item;
	local itemGUID = transaction:GetRecraftAllocation();
	if itemGUID then
		item = Item:CreateFromItemGUID(itemGUID);
	end
	self:SetItem(item);

	if item then
		self.DimArrow:Hide();
		self.AnimatedArrow.Anim:Restart();
		self.AnimatedArrow:Show();
	else
		self.AnimatedArrow.Anim:Stop();
		self.AnimatedArrow:Hide();
		self.DimArrow:Show();
	end

	local recipeID = transaction:GetRecipeID();
	self.InputSlot:SetCursorItemPredicate(function(draggedItemGUID)
		local itemGUIDs = C_TradeSkillUI.GetRecraftItems(recipeID);
		return tContains(itemGUIDs, draggedItemGUID);
	end)
end

function ProfessionsRecraftSlotMixin:SetItem(item)
	self.InputSlot:Init(item);

	if item then
		self.OutputSlot:Show();
		self.OutputSlot:Init(item);
	else
		self.OutputSlot:Hide();
	end
end

ProfessionsRecraftOutputSlotMixin = {};


function ProfessionsRecraftOutputSlotMixin:OnLoad()
	self:ClearNormalTexture();
end

function ProfessionsRecraftOutputSlotMixin:Init(item)
	self.ItemFrame:Show();

	SetItemButtonTexture(self, item:GetItemIcon());
	SetItemCraftingQualityOverlay(self, item:GetItemLink());
end

ProfessionsRecraftInputSlotMixin = {};

function ProfessionsRecraftInputSlotMixin:OnLoad()
	self:RegisterForClicks("RightButtonDown", "LeftButtonDown");
	self:RegisterForDrag("LeftButton");

	local scale = .65;
	self:GetNormalTexture():SetScale(scale);
	self:GetPushedTexture():SetScale(scale);

	self.BorderTexture = self:CreateTexture(nil, "OVERLAY");
	self.BorderTexture:SetPoint("CENTER", 0, 1);
	self.BorderTexture:SetDrawLayer("OVERLAY", 6);
	self.BorderTexture:SetScale(.65);
end

function ProfessionsRecraftInputSlotMixin:SetCursorItemPredicate(cursorItemPredicate)
	self.cursorItemPredicate = cursorItemPredicate;
end

function ProfessionsRecraftInputSlotMixin:Init(item)
	self:ClearNormalTexture();
	
	SetupTextureKitOnFrame("cyphersetupgrade", self.BorderTexture, "%s-leftitem-border-full", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	
	if item then
		SetItemButtonTexture(self, item:GetItemIcon());
		SetItemCraftingQualityOverlay(self, item:GetItemLink());
		self:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
		self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");
		self.Glow.EmptySlotGlow:Hide();
		self.Glow.PulseEmptySlotGlow:Stop();
	else
		SetItemButtonTexture(self, nil);
		ClearItemCraftingQualityOverlay(self)

		self:SetNormalAtlas("itemupgrade_greenplusicon", false);
		self:SetPushedAtlas("itemupgrade_greenplusicon_pressed", false);
		self:ClearHighlightTexture();
		self.Glow.EmptySlotGlow:Show();
		self.Glow.PulseEmptySlotGlow:Restart();
	end
end

function ProfessionsRecraftInputSlotMixin:OnReceiveDrag()
	local cursorItemLocation = C_Cursor.GetCursorItem();
	local cursorItemGUID = C_Item.GetItemGUID(cursorItemLocation);
	local learned = C_TradeSkillUI.IsOriginalCraftRecipeLearned(cursorItemGUID);
	if learned and self.cursorItemPredicate(cursorItemGUID) then
		Professions.TransitionToRecraft(cursorItemGUID);
	end
	ClearCursor();
end