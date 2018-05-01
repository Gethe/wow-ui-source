
function GuildPerksFrame_OnLoad(self)
	self.Container.update = function ()
		GuildPerks_Update(self);
	end;
	
	HybridScrollFrame_CreateButtons(self.Container, "GuildPerksButtonTemplate", 8, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM");
end

function GuildPerksFrame_OnShow(self)
	GuildPerks_Update(self);
end

function GuildPerksFrame_OnEvent(self, event, ...)
	if ( not self:IsShown() ) then
		return;
	end
end

function GuildPerksButton_OnEnter(self)
	self:GetParent().activeButton = self;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 36, 0);
	GameTooltip:SetHyperlink(GetSpellLink(self.spellID));
end

function GuildPerksButton_OnLeave(self)
	self:GetParent().activeButton = nil;
	GameTooltip:Hide();
end

function GuildPerksButton_OnClick(self)
	if ( IsModifiedClick("CHATLINK") ) then
		ChatEdit_LinkItem(nil, GetSpellLink(self.spellID));
	end
end

function GuildPerks_Update(self)
	local scrollFrame = self.Container;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index;
	local numPerks = GetNumGuildPerks();

	local totalHeight = numPerks * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	local buttonWidth = scrollFrame.buttonWidth;
	if( totalHeight > displayedHeight )then
		scrollFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, scrollFrame.yOffset);
		scrollFrame:SetWidth( scrollFrame.width );
		scrollFrame:SetHeight( scrollFrame.height );
	else
		buttonWidth = scrollFrame.buttonWidthNoScroll;
		scrollFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, scrollFrame.yOffsetNoScroll);
		scrollFrame:SetWidth( scrollFrame.widthNoScroll );
		scrollFrame:SetHeight( scrollFrame.heightNoScroll );
	end
	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		if ( index <= numPerks ) then
			local name, spellID, iconTexture = GetGuildPerkInfo(index);
			button.Name:SetText(name);
			button.Icon:SetTexture(iconTexture);
			button.spellID = spellID;
			button:Show();
			button:SetWidth(buttonWidth);
		else
			button:Hide();
		end
	end
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);

	-- update tooltip
	if ( scrollFrame.activeButton ) then
		GuildPerksButton_OnEnter(scrollFrame.activeButton);
	end
end