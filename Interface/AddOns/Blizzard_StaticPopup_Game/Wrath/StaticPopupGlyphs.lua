StaticPopupDialogs["CONFIRM_REMOVE_GLYPH"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		if ( talentGroup == C_SpecializationInfo.GetActiveSpecGroup() ) then
			RemoveGlyphFromSocket(data.id);
		end
	end,
	OnCancel = function(dialog, data)
	end,
	OnShow = function(dialog, data)
		dialog:SetFormattedText(CONFIRM_GLYPH_REMOVAL, data.name);
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_GLYPH_PLACEMENT"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data) PlaceGlyphInSocket(data.id); end,
	OnCancel = function(dialog, data) end,
	OnShow = function(dialog, data)
		dialog:SetFormattedText(CONFIRM_GLYPH_PLACEMENT_NO_COST, data.name, data.currentName);
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}