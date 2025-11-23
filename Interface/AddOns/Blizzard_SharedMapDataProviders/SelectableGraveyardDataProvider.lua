SelectableGraveyardDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function SelectableGraveyardDataProviderMixin:OnShow()
	self:RegisterEvent("CEMETERY_PREFERENCE_UPDATED");
	self:RegisterEvent("REQUEST_CEMETERY_LIST_RESPONSE");
end

function SelectableGraveyardDataProviderMixin:OnHide()
	self:UnregisterEvent("CEMETERY_PREFERENCE_UPDATED");
	self:UnregisterEvent("REQUEST_CEMETERY_LIST_RESPONSE");
end

function SelectableGraveyardDataProviderMixin:OnEvent(event, ...)
	if event == "CEMETERY_PREFERENCE_UPDATED" then
		self:RefreshAllData();
	elseif event == "REQUEST_CEMETERY_LIST_RESPONSE" then
		self:RefreshAllData();
	end
end

function SelectableGraveyardDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("SelectableGraveyardPinTemplate");
end

function SelectableGraveyardDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	local graveyards = C_DeathInfo.GetGraveyardsForMap(mapID);
	for i, graveyardInfo in ipairs(graveyards) do
		self:GetMap():AcquirePin("SelectableGraveyardPinTemplate", graveyardInfo);
	end
end

--[[ Pin ]]--
SelectableGraveyardPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_SELECTABLE_GRAVEYARD");

function SelectableGraveyardPinMixin:OnAcquired(graveyardInfo) -- override
	BaseMapPoiPinMixin.OnAcquired(self, graveyardInfo);

	self.graveyardID = graveyardInfo.graveyardID;
	self.isGraveyardSelectable = graveyardInfo.isGraveyardSelectable;
end

function SelectableGraveyardPinMixin:SetTexture(graveyardInfo) -- override
	BaseMapPoiPinMixin.SetTexture(self, graveyardInfo);

	self.Background:SetShown(self.isGraveyardSelectable);

	if GetCemeteryPreference() == self.graveyardID then
		self.Background:SetTexture("Interface\\WorldMap\\GravePicker-Selected");
	else
		self.Background:SetTexture("Interface\\WorldMap\\GravePicker-Unselected");
	end
end

function SelectableGraveyardPinMixin:OnMouseEnter() -- override
	BaseMapPoiPinMixin.OnMouseEnter(self);

	if self.isGraveyardSelectable then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local r, g, b = HIGHLIGHT_FONT_COLOR:GetRGB();

		if self.graveyardID == GetCemeteryPreference() then
			GameTooltip:SetText(GRAVEYARD_SELECTED);
			GameTooltip:AddLine(GRAVEYARD_SELECTED_TOOLTIP, r, g, b, true);
		else
			GameTooltip:SetText(GRAVEYARD_ELIGIBLE);
			GameTooltip:AddLine(GRAVEYARD_ELIGIBLE_TOOLTIP, r, g, b, true);
		end

		GameTooltip:Show();
	end
end

function SelectableGraveyardPinMixin:OnMouseLeave()  -- override
	BaseMapPoiPinMixin.OnMouseLeave(self);

	GameTooltip:Hide();
end

function SelectableGraveyardPinMixin:OnClick()
	if self.isGraveyardSelectable then
		SetCemeteryPreference(self.graveyardID);
	end
end