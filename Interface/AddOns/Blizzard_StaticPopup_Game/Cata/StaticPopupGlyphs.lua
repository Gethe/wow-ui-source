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
		local name, count, _, _, cost = GetGlyphClearInfo();
		if count >= cost then
			dialog:SetFormattedText(CONFIRM_REMOVE_GLYPH, data.name, GREEN_FONT_COLOR_CODE, cost, name);
		else
			dialog:SetFormattedText(CONFIRM_REMOVE_GLYPH, data.name, RED_FONT_COLOR_CODE, cost, name);
			dialog:GetButton1():Disable();
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
	OnAccept = function(dialog, data) PlaceGlyphInSocket(data.id); end,
	OnCancel = function(dialog, data) end,
	OnShow = function(dialog, data)
		local name, count, _, _, cost = GetGlyphClearInfo();
		if count >= cost then
			dialog:SetFormattedText(CONFIRM_GLYPH_PLACEMENT, GREEN_FONT_COLOR_CODE, cost, name);
		else
			dialog:SetFormattedText(CONFIRM_GLYPH_PLACEMENT, RED_FONT_COLOR_CODE, cost, name);
			dialog:GetButton1():Disable();
		end
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}
