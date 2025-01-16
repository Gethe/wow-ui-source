StaticPopupDialogs["CONFIRM_REMOVE_GLYPH"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		if ( talentGroup == GetActiveTalentGroup() ) then
			RemoveGlyphFromSocket(self.data.id);
		end
	end,
	OnCancel = function (self)
	end,
	OnShow = function(self)
		self.text:SetFormattedText(CONFIRM_GLYPH_REMOVAL, self.data.name);
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
		self.text:SetFormattedText(CONFIRM_GLYPH_PLACEMENT_NO_COST, self.data.name, self.data.currentName);
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}