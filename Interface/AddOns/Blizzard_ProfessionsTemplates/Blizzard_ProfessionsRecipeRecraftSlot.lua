ProfessionsRecraftSlotMixin = {};

function ProfessionsRecraftSlotMixin:OnLoad()
	self.InputSlot:SetScript("OnLeave", GameTooltip_Hide);
	self.OutputSlot:SetScript("OnLeave", GameTooltip_Hide);
end

function ProfessionsRecraftSlotMixin:Init(transaction)
	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end
	self.continuableContainer = ContinuableContainer:Create();
	
	self.InputSlot:SetScript("OnLeave", GameTooltip_Hide);
	self.OutputSlot:SetScript("OnLeave", GameTooltip_Hide);
	
	local function OnItemsLoaded()
		local itemGUID = transaction:GetRecraftAllocation();
		local item = ItemUtil.TransformItemGUIDToItem(itemGUID);
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
	end
	self.continuableContainer:ContinueOnLoad(OnItemsLoaded);

	local recipeID = transaction:GetRecipeID();
	self.InputSlot:SetCursorItemPredicate(function(draggedItemGUID)
		local itemGUIDs = C_TradeSkillUI.GetRecraftItems(recipeID);
		return tContains(itemGUIDs, draggedItemGUID);
	end)
end

function ProfessionsRecraftSlotMixin:SetItem(item)
	self.InputSlot:Init(item);
	self.OutputSlot:Init(item);
end

ProfessionsRecraftInputSlotMixin = {};

function ProfessionsRecraftInputSlotMixin:OnLoad()
	self:RegisterForClicks("RightButtonDown", "LeftButtonDown");
	self:RegisterForDrag("LeftButton");
end

function ProfessionsRecraftInputSlotMixin:SetCursorItemPredicate(cursorItemPredicate)
	self.cursorItemPredicate = cursorItemPredicate;
end

function ProfessionsRecraftInputSlotMixin:Init(item)
	local textureFormat = item and "%s-leftitem-border-full" or "%s-leftitem-border-empty";
	SetupTextureKitOnFrame("cyphersetupgrade", self.ButtonFrame, textureFormat, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize)
		
	self:ClearNormalTexture();

	if item then
		self:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
		self.Glow.EmptySlotGlow:Hide();
		self.Glow.PulseEmptySlotGlow:Stop();
		SetItemButtonTexture(self, item:GetItemIcon());
	else
		SetItemButtonTexture(self, nil);
		self:SetNormalAtlas("itemupgrade_greenplusicon");
		self:SetPushedAtlas("itemupgrade_greenplusicon_pressed");
		self.Glow.EmptySlotGlow:Show();
		self.Glow.PulseEmptySlotGlow:Restart();
	end
end

function ProfessionsRecraftInputSlotMixin:OnReceiveDrag()
	local cursorItemLocation = C_Cursor.GetCursorItem();
	local cursorItemGUID = C_Item.GetItemGUID(cursorItemLocation);
	if self.cursorItemPredicate(cursorItemGUID) then
		Professions.TransitionToRecraft(cursorItemGUID);
		ClearCursor();
	end
end


ProfessionsRecraftOutputSlotMixin = {};

function ProfessionsRecraftOutputSlotMixin:Init(item)
	local textureFormat = item and "%s-rightitem-border-full" or "%s-rightitem-border-empty";
	SetupTextureKitOnFrame("cyphersetupgrade", self.ButtonFrame, textureFormat, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	
	self:ClearNormalTexture();

	if item then
		SetItemButtonTexture(self, item:GetItemIcon());
	else
		SetItemButtonTexture(self, nil);
	end
end