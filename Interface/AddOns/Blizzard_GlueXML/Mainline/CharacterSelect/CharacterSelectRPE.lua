RPEChooseExperienceMixin = { };

function RPEChooseExperienceMixin:OnLoad()
	self.SkipPanel.HeaderText:SetText(RPE_EXPERIENCE_SKIP_HEADER);
	self.SkipPanel.SelectButton:SetScript("OnClick", DoEnterWorld);

	self.PlayPanel.HeaderText:SetText(RPE_EXPERIENCE_PLAY_HEADER);
	self.PlayPanel.SubHeaderText:SetText(GREEN_FONT_COLOR:WrapTextInColorCode(RECOMMENDED));
	self.PlayPanel.SelectButton:SetScript("OnClick", DoEnterWorldRPE);

	self.PlayPanel.InfoButton:SetScript("OnEnter", function()
		GlueTooltip:SetOwner(self.PlayPanel.InfoButton, "ANCHOR_TOP");
		GameTooltip_AddNormalLine(GlueTooltip, RPE_EXPERIENCE_PLAY_TOOLTIP);
		GlueTooltip:Show();
	end);
	self.PlayPanel.InfoButton:SetScript("OnLeave", function()
		GlueTooltip:Hide();
	end);
end

function RPEChooseExperienceMixin:OnShow()
	-- Skip panel subheader text is the character location
	local characterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);
	local info = CharacterSelectUtil.GetCharacterInfoTable(characterID);
	local zone = info.areaName;
	if zone then
		self.SkipPanel.SubHeaderText:SetFormattedText(RPE_EXPERIENCE_LOCATION, zone);
	else
		self.SkipPanel.SubHeaderText:SetText("");
	end

	local offsetX, offsetY, width, height = 0, 0, 254, 84;
	GlowEmitterFactory:Show(self.PlayPanel.SelectButton, GlowEmitterMixin.Anims.GreenGlow, offsetX, offsetY, width, height);
end

function RPEChooseExperienceMixin:OnHide()
	GlowEmitterFactory:Hide(self.PlayPanel.SelectButton);
end
