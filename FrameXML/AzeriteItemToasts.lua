AzeriteItemLevelUpToastMixin = {};

local TOAST_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(111, 1688020);	-- 7DU_ArgusRaid_TitanTrappedSoul01

function AzeriteItemLevelUpToastMixin:OnLoad()
	self:RegisterEvent("AZERITE_ITEM_POWER_LEVEL_CHANGED");

	self.itemFramePool = CreateFramePool("ItemButton", self.UnlockItemsFrame, "AzeriteUnlockedItemTemplate");
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
			newPowerLevel = newPowerLevel,
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

	self.itemFramePool:ReleaseAll();
	for i, frame in ipairs(self.UnlockItemsFrame.Frames) do
		frame:Hide();
	end

	self:SetupModelScene();

	local addedHeight, subText = self:SetUpAzeriteMilestoneUnlocks(data.newPowerLevel);
	if addedHeight == 0 then
		addedHeight, subText = self:SetUpUnlockedEmpoweredItems(data.unlockedEmpoweredItemsInfo);
	end

	local toastHeight = 77;
	local effectiveToastHeight = toastHeight + addedHeight;
	local effectiveScale = effectiveToastHeight / toastHeight;

	self.ShowAnim.BGScaleAnim:SetToScale(1, effectiveScale);
	self.ShowAnim.GlowLineBottomTranslation:SetOffset(0, -effectiveToastHeight);

	for i, region in ipairs(self.BottomRegions) do
		local point, parent, relativePoint, sourceX, sourceY = region:GetPoint();
		region:SetPoint(point, parent, relativePoint, sourceX, -effectiveToastHeight);
	end

	self.UnlockItemsFrame:SetShown(addedHeight > 0);
	self.UnlockItemsFrame:Layout();
	if addedHeight and subText then
		self.SubTextLabel:SetText(subText);
		self.SubTextLabel:Show();
	else
		self.SubTextLabel:Hide();
	end

	self:SetAlpha(1);
	self:Show();
	
	self.ShowAnim:Play();
	PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_TOAST_TRAIT_AVAILABLE);
end

function AzeriteItemLevelUpToastMixin:SetupModelScene(forceUpdate)
	StaticModelInfo.SetupModelScene(self.IconEffect, TOAST_MODEL_SCENE_INFO, forceUpdate);
end

function AzeriteItemLevelUpToastMixin:SetUpAzeriteMilestoneUnlocks(powerLevel)
	local height = 0;
	local subText;

	local milestoneInfo = AzeriteEssenceUtil.GetMilestoneAtPowerLevel(powerLevel);
	if milestoneInfo then
		if milestoneInfo.slot then
			self.UnlockItemsFrame.EssenceSlotFrame:Show();
			subText = NEW_AZERITE_ESSENCE_SLOT_UNLOCKED;
			height = 86;
		elseif milestoneInfo.rank then
			self.UnlockItemsFrame.EssenceRankedFrame:Show();
			local spellName, spellTexture = AzeriteEssenceUtil.GetMilestoneSpellInfo(milestoneInfo.ID);
			self.UnlockItemsFrame.EssenceRankedFrame.Icon:SetTexture(spellTexture);
			if milestoneInfo.requiredLevel == powerLevel then
				subText = NEW_AZERITE_ESSENCE_RANKED_UNLOCKED:format(spellName);
			else
				subText = NEW_AZERITE_ESSENCE_RANKED_RANK:format(spellName, milestoneInfo.rank);
			end
			height = 112;
		else
			self.UnlockItemsFrame.EssenceStaminaFrame:Show();
			subText = NEW_AZERITE_ESSENCE_MILESTONE_UNLOCKED;
			height = 83;
		end
	end

	return height, subText;
end

function AzeriteItemLevelUpToastMixin:SetUpUnlockedEmpoweredItems(unlockedEmpoweredItemsInfo)
	local hasUnlocks = #unlockedEmpoweredItemsInfo > 0;

	for i, unlockedEmpoweredItemInfo in ipairs(unlockedEmpoweredItemsInfo) do
		local itemButton = self.itemFramePool:Acquire();
		local unlockedItem = Item:CreateFromItemLocation(unlockedEmpoweredItemInfo.unlockedItem);
		SetItemButtonTexture(itemButton, unlockedItem:GetItemIcon());
		local suppressOverlays = true;
		SetItemButtonQuality(itemButton, unlockedItem:GetItemQuality(), unlockedItem:GetItemID(), suppressOverlays);
		itemButton.layoutIndex = i;

		itemButton:Show();
	end

	local height = 0;
	local subText;

	if hasUnlocks then
		if #unlockedEmpoweredItemsInfo == 1 then
			local unlockedItem = Item:CreateFromItemLocation(unlockedEmpoweredItemsInfo[1].unlockedItem);
			local inventoryTypeName = unlockedItem:GetInventoryTypeName();
			subText = string.format(AZERITE_ITEM_LEVELED_UP_TOAST_UNLOCKED_SINGLE, _G[inventoryTypeName]);
		else
			subText = AZERITE_ITEM_LEVELED_UP_TOAST_UNLOCKED_MULTIPLE;
		end
		height = 77;
	end

	return height, subText;
end
function AzeriteItemLevelUpToastMixin:StopBanner()
	self.ShowAnim:Stop();
	self:Hide();
end

function AzeriteItemLevelUpToastMixin:OnAnimFinished()
	self:Hide();
	TopBannerManager_BannerFinished();
end