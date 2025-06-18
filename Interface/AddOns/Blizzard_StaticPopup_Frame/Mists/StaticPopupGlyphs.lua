StaticPopupDialogs["CONFIRM_REMOVE_GLYPH"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		if ( talentGroup == C_SpecializationInfo.GetActiveSpecGroup() ) then
			RemoveGlyphFromSocket(self.data.id);
		end
	end,
	OnCancel = function (self)
	end,
	OnShow = function(self)
		local name, count, _, _, cost = GetGlyphClearInfo();
		if cost == 0 then
			self.text:SetFormattedText(CONFIRM_REMOVE_GLYPH_NO_COST, self.data.name);
		elseif count >= cost then
			self.text:SetFormattedText(CONFIRM_REMOVE_GLYPH, self.data.name, GREEN_FONT_COLOR_CODE, cost, name);
		else
			self.text:SetFormattedText(CONFIRM_REMOVE_GLYPH, self.data.name, RED_FONT_COLOR_CODE, cost, name);
			self.button1:Disable();
		end
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_GLYPH_PLACEMENT"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) PlaceGlyphInSocket(self.data.id); end,
	OnCancel = function (self) end,
	OnShow = function(self)
		local name, count, _, _, cost = GetGlyphClearInfo();
		if cost == 0 then
			self.text:SetFormattedText(CONFIRM_GLYPH_PLACEMENT_NO_COST, self.data.name);
		elseif count >= cost then
			self.text:SetFormattedText(CONFIRM_GLYPH_PLACEMENT, self.data.name, GREEN_FONT_COLOR_CODE, cost, name);
		else
			self.text:SetFormattedText(CONFIRM_GLYPH_PLACEMENT, self.data.name, RED_FONT_COLOR_CODE, cost, name);
			self.button1:Disable();
		end
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}