AzeriteItemLevelUpToastMixin = {};

function AzeriteItemLevelUpToastMixin:OnLoad()
	self:RegisterEvent("AZERITE_ITEM_POWER_LEVEL_CHANGED");
	self:RegisterEvent("AZERITE_EMPOWERED_ITEM_NEW_TIER_AVAILABLE");
end

function AzeriteItemLevelUpToastMixin:OnEvent(event, ...)
	if event == "AZERITE_ITEM_POWER_LEVEL_CHANGED" then
		local azeriteItemLocation, oldPowerLevel, newPowerLevel = ...;
		if oldPowerLevel < newPowerLevel then
			self:PlayAzeriteItemPowerToast(azeriteItemLocation, newPowerLevel);
		end
	elseif event == "AZERITE_EMPOWERED_ITEM_NEW_TIER_AVAILABLE" then
		local azeriteEmpoweredItemLocation, tierIndex = ...;
		if azeriteEmpoweredItemLocation:IsEquipmentSlot() then
			self:PlayAzeriteEmpoweredItemPowerToast(azeriteEmpoweredItemLocation);
		end
	end
end

function AzeriteItemLevelUpToastMixin:PlayAzeriteItemPowerToast(azeriteItemLocation, newPowerLevel)
	local item = Item:CreateFromItemLocation(azeriteItemLocation);

	item:ContinueOnItemLoad(function()
		TopBannerManager_Show(self, { 
			name = item:GetItemName(), 
			icon = item:GetItemIcon(),
			itemColor = item:GetItemQualityColor(),
			text = AZERITE_ITEM_LEVELED_UP_TOAST:format(newPowerLevel), 
			subText = "",
			tempColorInfo = { desaturate = false, color = CreateColor(.5, .5, 1), },
		}); 
	end);
end

function AzeriteItemLevelUpToastMixin:PlayAzeriteEmpoweredItemPowerToast(azeriteEmpoweredItemLocation, newPowerLevel)
	local item = Item:CreateFromItemLocation(azeriteEmpoweredItemLocation);

	item:ContinueOnItemLoad(function()
		TopBannerManager_Show(self, { 
			name = item:GetItemName(), 
			icon = item:GetItemIcon(),
			itemColor = item:GetItemQualityColor(),
			text = AZERITE_EMPOWERED_ITEM_TIER_AVAILABLE_TOAST, 
			subText = AZERITE_EMPOWERED_ITEM_TIER_AVAILABLE_SUB_TOAST,
			tempColorInfo = { desaturate = true, color = CreateColor(.65, .65, .8), },
		});
	end);
end

function AzeriteItemLevelUpToastMixin:PlayBanner(data)
	self.ItemName:SetText(data.name);
	self.Icon:SetTexture(data.icon);

	self.BottomLineLeft:SetAlpha(0);
	self.BottomLineRight:SetAlpha(0);

	self.ItemName:SetAlpha(0);
	self.ItemName:SetVertexColor(data.itemColor.r, data.itemColor.g, data.itemColor.b);
	

	self.TextLabel:SetText(data.text);
	self.SubTextLabel:SetText(data.subText);

	self.TextLabel:SetAlpha(0);
	self.SubTextLabel:SetAlpha(0);

	for i, region in ipairs{self:GetRegions()} do
		if region:GetObjectType() == "Texture" and self.Icon ~= region then -- Temp
			region:SetDesaturated(data.tempColorInfo.desaturate);
			region:SetVertexColor(data.tempColorInfo.color:GetRGB());
		end
	end

	self:SetAlpha(1);
	self:Show();
	
	self.ShowAnim:Play();
	PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_TOAST_TRAIT_AVAILABLE);
end

function AzeriteItemLevelUpToastMixin:StopBanner()
	self.ShowAnim:Stop();
	self:Hide();
end

function AzeriteItemLevelUpToastMixin:OnAnimFinished()
	self:Hide();
	TopBannerManager_BannerFinished();
end