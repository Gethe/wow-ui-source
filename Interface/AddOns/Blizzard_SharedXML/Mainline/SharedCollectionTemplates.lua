WarbandSceneEntryMixin = {};

function WarbandSceneEntryMixin:OnMouseUp(button, upInside)
	local warbandSceneID = self:GetWarbandSceneID();
	if button == "RightButton" and upInside and warbandSceneID and warbandSceneID ~= C_WarbandScene.GetRandomEntryID() and self:GetIsOwned() then
		MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
			rootDescription:SetTag("MENU_WARBANDSCENE_FAVORITE");

			local isFavorite = self:GetIsFavorite();
			if isFavorite then
				rootDescription:CreateButton(BATTLE_PET_UNFAVORITE, function()
					self:SetIsFavorite(false);
				end);
			else
				rootDescription:CreateButton(BATTLE_PET_FAVORITE, function()
					self:SetIsFavorite(true);
				end);
			end
		end);
	end
end

function WarbandSceneEntryMixin:OnEnter()
	if self.warbandSceneInfo then
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		SharedCollectionUtil.ShowWarbandSceneEntryTooltip(tooltip, self.warbandSceneInfo, self:GetIsOwned());
	end
end

function WarbandSceneEntryMixin:OnLeave()
	local tooltip = GetAppropriateTooltip();
	tooltip:Hide();
end

function WarbandSceneEntryMixin:Init(elementData)
	self.elementData = elementData;
	self:UpdateWarbandSceneData();
end

function WarbandSceneEntryMixin:UpdateWarbandSceneData()
	if not self.elementData then
		return;
	end

	self.warbandSceneInfo = C_WarbandScene.GetWarbandSceneEntry(self.elementData.warbandSceneID);

	if self.warbandSceneInfo then
		self.Name:SetText(self.warbandSceneInfo.name);
		self.Icon:SetAtlas(self.warbandSceneInfo.textureKit, TextureKitConstants.UseAtlasSize);
		self.Icon:SetDesaturated(not self:GetIsOwned());
		self.SlotFavorite:SetShown(self:GetIsFavorite());
	end
end

function WarbandSceneEntryMixin:GetWarbandSceneID()
	if self.warbandSceneInfo then
		return self.warbandSceneInfo.warbandSceneID;
	end
	return nil;
end

function WarbandSceneEntryMixin:GetIsOwned()
	return self.warbandSceneInfo and C_WarbandScene.HasWarbandScene(self.warbandSceneInfo.warbandSceneID);
end

function WarbandSceneEntryMixin:GetIsFavorite()
	return self.warbandSceneInfo and C_WarbandScene.IsFavorite(self.warbandSceneInfo.warbandSceneID);
end

function WarbandSceneEntryMixin:SetIsFavorite(state)
	if self.warbandSceneInfo then
		C_WarbandScene.SetFavorite(self.warbandSceneInfo.warbandSceneID, state);
	end
end