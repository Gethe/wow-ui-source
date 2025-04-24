
CommunitiesGuildPerksButtonMixin = {};

function CommunitiesGuildPerksButtonMixin:Init(elementData)
	local name, spellID, iconTexture = GetGuildPerkInfo(elementData.index);
	self.Name:SetText(name);
	self.Icon:SetTexture(iconTexture);
	self.spellID = spellID;
end

function CommunitiesGuildPerksFrame_OnLoad(self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CommunitiesGuildPerksButtonTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	view:SetPadding(4,4,8,4,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", self, "TOPLEFT", 0, -4),
		CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -5, 0);
	};
	local scrollBoxAnchorsWithoutBar = {
		scrollBoxAnchorsWithBar[1],
		CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", 14, 0);
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
end

function CommunitiesGuildPerksFrame_OnShow(self)
	CommunitiesGuildPerks_Update(self);
end

function CommunitiesGuildPerksFrame_OnEvent(self, event, ...)
	if ( not self:IsShown() ) then
		return;
	end
end

function CommunitiesGuildPerksButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 36, 0);

	local spellLink = C_Spell.GetSpellLink(self.spellID);
	GameTooltip:SetHyperlink(spellLink);
end

function CommunitiesGuildPerksButton_OnLeave(self)
	GameTooltip:Hide();
end

function CommunitiesGuildPerksButton_OnClick(self)
	if ( IsModifiedClick("CHATLINK") ) then
		local spellLink = C_Spell.GetSpellLink(self.spellID);
		ChatEdit_LinkItem(nil, spellLink);
	end
end

function CommunitiesGuildPerks_Update(self)
	if (GetNumGuildPerks() > 0) then
		local dataProvider = CreateDataProviderByIndexCount(GetNumGuildPerks());
		self.ScrollBox:SetDataProvider(dataProvider);		
	else
		self:Hide();
	end
end