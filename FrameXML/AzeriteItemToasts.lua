AzeriteItemLevelUpToastMixin = {};

function AzeriteItemLevelUpToastMixin:OnLoad()
	self:RegisterEvent("AZERITE_ITEM_POWER_LEVEL_CHANGED");

	self.itemFramePool = CreateFramePool("FRAME", self.UnlockItemsFrame, "AzeriteUnlockedItemTemplate");
end

function AzeriteItemLevelUpToastMixin:OnShow()
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function AzeriteItemLevelUpToastMixin:OnHide()
	self:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function AzeriteItemLevelUpToastMixin:OnEvent(event, ...)
	if event == "AZERITE_ITEM_POWER_LEVEL_CHANGED" then
		local azeriteItemLocation, oldPowerLevel, newPowerLevel, unlockedEmpoweredItemsInfo = ...;
		if oldPowerLevel < newPowerLevel then
			self:PlayAzeriteItemPowerToast(azeriteItemLocation, newPowerLevel, unlockedEmpoweredItemsInfo);
		end
	elseif event == "UI_MODEL_SCENE_INFO_UPDATED" then
		local forceUpdate = true;
		self:SetupModelScene(forceUpdate);
	end
end

function AzeriteItemLevelUpToastMixin:PlayAzeriteItemPowerToast(azeriteItemLocation, newPowerLevel, unlockedEmpoweredItemsInfo)
	local item = Item:CreateFromItemLocation(azeriteItemLocation);
	local EquippedOnly = function(unlockedEmpoweredItemInfo) return unlockedEmpoweredItemInfo.unlockedItem:IsEquipmentSlot() end;
	local IS_INDEXED = true;
	local equippedUnlockedEmpoweredItemsInfo = tFilter(unlockedEmpoweredItemsInfo, EquippedOnly, IS_INDEXED);

	local continuableContainer = ContinuableContainer:Create();
	continuableContainer:AddContinuable(item);

	for i, unlockedEmpoweredItemInfo in ipairs(equippedUnlockedEmpoweredItemsInfo) do
		continuableContainer:AddContinuable(Item:CreateFromItemLocation(unlockedEmpoweredItemInfo.unlockedItem));
	end

	continuableContainer:ContinueOnLoad(function()
		TopBannerManager_Show(self, { 
			name = item:GetItemName(), 
			itemColor = item:GetItemQualityColor(),
			text = AZERITE_ITEM_LEVELED_UP_TOAST:format(newPowerLevel), 
			unlockedEmpoweredItemsInfo = equippedUnlockedEmpoweredItemsInfo,
		}); 
	end);
end

function AzeriteItemLevelUpToastMixin:PlayBanner(data)
	self.ItemName:SetText(data.name);

	self.BottomLineLeft:SetAlpha(0);
	self.BottomLineRight:SetAlpha(0);
	self.ToastBG:SetAlpha(0);

	self.ItemName:SetAlpha(0);
	self.ItemName:SetVertexColor(data.itemColor.r, data.itemColor.g, data.itemColor.b);

	self.TextLabel:SetText(data.text);

	self.TextLabel:SetAlpha(0);
	self.SubTextLabel:SetAlpha(0);
	self.UnlockItemsFrame:SetAlpha(0);

	self:SetupModelScene();

	self:SetUpUnlockedEmpoweredItems(data.unlockedEmpoweredItemsInfo);

	self:SetAlpha(1);
	self:Show();
	
	self.ShowAnim:Play();
	PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_TOAST_TRAIT_AVAILABLE);
end

function AzeriteItemLevelUpToastMixin:SetupModelScene(forceUpdate)
	local AZERITE_ICON_EFFECT_MODEL_SCENE_ID = 111;
	self.IconEffect:SetFromModelSceneID(AZERITE_ICON_EFFECT_MODEL_SCENE_ID, forceUpdate);
	local iconEffectActor = self.IconEffect:GetActorByTag("effect");
	if iconEffectActor then
		iconEffectActor:SetModelByFileID(1688020); -- 7DU_ArgusRaid_TitanTrappedSoul01
	end
end

function AzeriteItemLevelUpToastMixin:SetUpUnlockedEmpoweredItems(unlockedEmpoweredItemsInfo)
	local SMALL_TOAST_SCALE = 1.0;
	local LARGE_TOAST_SCALE = 2.0;

	local toastHeight = 77;
	local hasUnlocks = #unlockedEmpoweredItemsInfo > 0;
	local effectiveScale = hasUnlocks and LARGE_TOAST_SCALE or SMALL_TOAST_SCALE;
	local effectiveToastHeight = toastHeight * effectiveScale;

	self.ShowAnim.BGScaleAnim:SetToScale(1, effectiveScale);
	self.ShowAnim.GlowLineBottomTranslation:SetOffset(0, -effectiveToastHeight);

	for i, region in ipairs(self.BottomRegions) do
		local point, parent, relativePoint, sourceX, sourceY = region:GetPoint();
		region:SetPoint(point, parent, relativePoint, sourceX, -effectiveToastHeight);
	end

	self.itemFramePool:ReleaseAll();
	self.UnlockItemsFrame:SetShown(hasUnlocks);

	for i, unlockedEmpoweredItemInfo in ipairs(unlockedEmpoweredItemsInfo) do
		local itemButton = self.itemFramePool:Acquire();
		local unlockedItem = Item:CreateFromItemLocation(unlockedEmpoweredItemInfo.unlockedItem);
		SetItemButtonTexture(itemButton, unlockedItem:GetItemIcon());
		local suppressOverlays = true;
		SetItemButtonQuality(itemButton, unlockedItem:GetItemQuality(), unlockedItem:GetItemID(), suppressOverlays);
		itemButton.layoutIndex = i;

		itemButton:Show();
	end

	if hasUnlocks then
		if #unlockedEmpoweredItemsInfo == 1 then
			local unlockedItem = Item:CreateFromItemLocation(unlockedEmpoweredItemsInfo[1].unlockedItem);
			local inventoryTypeName = unlockedItem:GetInventoryTypeName();
			self.SubTextLabel:SetFormattedText(AZERITE_ITEM_LEVELED_UP_TOAST_UNLOCKED_SINGLE, _G[inventoryTypeName]);
		else
			self.SubTextLabel:SetText(AZERITE_ITEM_LEVELED_UP_TOAST_UNLOCKED_MULTIPLE);
		end
		
		self.SubTextLabel:Show();
	else
		self.SubTextLabel:Hide();
	end

	self.UnlockItemsFrame:Layout();
end
function AzeriteItemLevelUpToastMixin:StopBanner()
	self.ShowAnim:Stop();
	self:Hide();
end

function AzeriteItemLevelUpToastMixin:OnAnimFinished()
	self:Hide();
	TopBannerManager_BannerFinished();
end