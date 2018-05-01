AzeriteEmpoweredItemPowerMixin = {};

function AzeriteEmpoweredItemPowerMixin:Setup(owningTierFrame, empoweredItemLocation, azeritePowerID, baseAngle)
	self:CancelItemLoadCallback();

	self.owningTierFrame = owningTierFrame;
	self.empoweredItemLocation = empoweredItemLocation;
	self.azeritePowerID = azeritePowerID;
	self.baseAngle = baseAngle;

	self:Update();

	self.canBeSelected = nil;

	local spellTexture = GetSpellTexture(self:GetSpellID()); 
	self.Icon:SetTexture(spellTexture);
end

function AzeriteEmpoweredItemPowerMixin:Update()
	self.azeritePowerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(self.empoweredItemLocation, self.azeritePowerID);
end

function AzeriteEmpoweredItemPowerMixin:IsFinalPower()
	return self:GetTierIndex() == 1;
end

function AzeriteEmpoweredItemPowerMixin:GetBaseAngle()
	return self.baseAngle;
end

function AzeriteEmpoweredItemPowerMixin:UpdateStyle()
	self.CanSelectGlow:SetShown(self:CanBeSelected());
	self.Arrow:SetShown(self:CanBeSelected());

	self.CanSelectGlowAnim:Stop();
	self.CanSelectArrowAnim:Stop();

	self:SetFrameStrata(self:IsFinalPower() and "HIGH" or "MEDIUM");

	if self:IsFinalPower() then
		self:SetSize(120, 120);
		self.Icon:SetSize(120, 120);
		self.CircleMask:SetSize(120, 120);
	else
		self:SetSize(70, 70);
		self.Icon:SetSize(80, 80);
		self.CircleMask:SetSize(70, 70);
	end

	if self:IsSelected() then
		self.Icon:SetAlpha(1);
		self.Icon:SetDesaturation(0);
		if self:IsFinalPower() then
			self.IconBorder:SetAtlas("Azerite-CenterTrait-Ring", true);
		else
			self.IconBorder:SetAtlas("Azerite-TraitSelected-Ring", true);
		end
		self.IconBorder:SetDesaturation(0);
	elseif self:CanBeSelected() then
		self.Icon:SetAlpha(1);
		self.Icon:SetDesaturation(0);
		if self:IsFinalPower() then
			self.IconBorder:SetAtlas("Azerite-CenterTrait-Ring", true);
		else
			self.IconBorder:SetAtlas("Azerite-Trait-Ring-Open", true);
		end
		self.IconBorder:SetDesaturation(0);
	else
		self.Icon:SetDesaturation(1);
		self.Icon:SetAlpha(.5);
		self.IconBorder:SetDesaturation(1);

		if self:IsFinalPower() then
			self.IconBorder:SetAtlas("Azerite-CenterTrait-Ring", true);
		else
			self.IconBorder:SetAtlas("Azerite-Trait-Ring", true);
		end
	end

	if self:CanBeSelected() then
		self.CanSelectGlowAnim:Play();
		self.CanSelectArrowAnim:Play();
	end
end

function AzeriteEmpoweredItemPowerMixin:GetAzeritePowerID()
	return self.azeritePowerID;
end

function AzeriteEmpoweredItemPowerMixin:GetSpellID()
	return self.azeritePowerInfo.spellID;
end

function AzeriteEmpoweredItemPowerMixin:GetTierIndex()
	return self.azeritePowerInfo.tierIndex;
end

function AzeriteEmpoweredItemPowerMixin:IsSelected()
	return self.azeritePowerInfo.selected;
end

function AzeriteEmpoweredItemPowerMixin:CanBeSelected()
	return self.canBeSelected;
end

function AzeriteEmpoweredItemPowerMixin:SetCanBeSelected(canBeSelected)
	self.canBeSelected = canBeSelected;

	self:UpdateStyle();
end

function AzeriteEmpoweredItemPowerMixin:CancelItemLoadCallback()
	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end
end

function AzeriteEmpoweredItemPowerMixin:OnEnter()
	self:CancelItemLoadCallback();
	local item = Item:CreateFromItemLocation(self.empoweredItemLocation);

	self.itemDataLoadedCancelFunc = item:ContinueWithCancelOnItemLoad(function()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local itemID = item:GetItemID();
		local itemLevel = item:GetCurrentItemLevel();
		GameTooltip:SetAzeritePower(itemID, itemLevel, self:GetAzeritePowerID());
		self.UpdateTooltip = self.OnEnter;
	end);
end

function AzeriteEmpoweredItemPowerMixin:OnLeave()
	self:CancelItemLoadCallback();

	GameTooltip:Hide();
end

function AzeriteEmpoweredItemPowerMixin:OnClick()
	if IsModifiedClick("CHATLINK") then
		ChatEdit_InsertLink(GetSpellLink(self:GetSpellID()));
		return;
	end

	if not C_Item.IsBound(self.empoweredItemLocation) then
		StaticPopup_Show("CONFIRM_AZERITE_EMPOWERED_BIND", nil, nil, {empoweredItemLocation = self.empoweredItemLocation, azeritePowerID = self:GetAzeritePowerID()});
		return;
	end

	if C_AzeriteEmpoweredItem.SelectPower(self.empoweredItemLocation, self:GetAzeritePowerID()) then
		self.owningTierFrame:OnPowerSelected(self);
	end
end