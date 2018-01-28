AzeriteEmpoweredItemPowerMixin = {};

function AzeriteEmpoweredItemPowerMixin:Setup(empoweredItemLocation, azeritePowerInfo)
	self.empoweredItemLocation = empoweredItemLocation;
	self.azeritePowerInfo = azeritePowerInfo;

	self.canBeSelected = nil;

	local spellTexture = GetSpellTexture(self:GetSpellID()); 
	self.Icon:SetTexture(spellTexture);
end

function AzeriteEmpoweredItemPowerMixin:UpdateStyle()
	self.CanSelectGlow:SetShown(self:CanBeSelected());

	self.CanSelectAnim:Stop();

	if self:IsSelected() then
		self.Icon:SetSize(52, 52);
		self.Icon:SetAlpha(1);
		self.Icon:SetDesaturation(0);
		self.CircleMask:SetSize(52, 52);
		self.IconBorder:SetAtlas("Artifacts-PerkRing-MainProc", true);
		self.IconBorder:SetDesaturation(0);
	elseif self:CanBeSelected() then
		self.Icon:SetSize(45, 45);
		self.Icon:SetAlpha(1);
		self.Icon:SetDesaturation(0);
		self.CircleMask:SetSize(45, 45);
		self.IconBorder:SetAtlas("Artifacts-PerkRing-Small", true);
		self.IconBorder:SetDesaturation(0);
	else
		self.Icon:SetSize(45, 45);
		self.Icon:SetDesaturation(1);
		self.Icon:SetAlpha(.5);
		self.CircleMask:SetSize(45, 45);
		self.IconBorder:SetAtlas("Artifacts-PerkRing-Small", true);
		self.IconBorder:SetDesaturation(1);
	end

	if self:CanBeSelected() then
		self.CanSelectAnim:Play();
	end
end

function AzeriteEmpoweredItemPowerMixin:GetAzeritePowerID()
	return self.azeritePowerInfo.azeritePowerID;
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

function AzeriteEmpoweredItemPowerMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetSpellByID(self:GetSpellID());

	self.UpdateTooltip = self.OnEnter;
end

function AzeriteEmpoweredItemPowerMixin:OnClick()
	if IsModifiedClick("CHATLINK") then
		ChatEdit_InsertLink(GetSpellLink(self:GetSpellID()));
		return;
	end

	if not C_Item.IsBound(self.empoweredItemLocation) then
		StaticPopup_Show("CONFIRM_AZERITE_EMPOWERED_BIND", nil, nil, {empoweredItemLocation = self.empoweredItemLocation, azeritePowerID =  self:GetAzeritePowerID()});
		return;
	end

	C_AzeriteEmpoweredItem.SelectPower(self.empoweredItemLocation, self:GetAzeritePowerID());
end