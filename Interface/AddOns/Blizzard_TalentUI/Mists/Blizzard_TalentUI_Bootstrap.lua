function ToggleTalentFrame()
	if ( not C_SpecializationInfo.CanPlayerUseTalentSpecUI() ) then
		return;
	end

	if TalentFrame_LoadUI() then
		if ( PlayerTalentFrame:IsShown() ) then
			HideUIPanel(PlayerTalentFrame);
		else
			ShowUIPanel(PlayerTalentFrame);
		end
	end
end

function ToggleGlyphFrame()
	if ( UnitLevel("player") < SHOW_INSCRIPTION_LEVEL ) then
		return;
	end

	if GlyphFrame_LoadUI() then
		GlyphFrame_Toggle();
	end
end

function OpenGlyphFrame()
	if ( UnitLevel("player") < SHOW_INSCRIPTION_LEVEL ) then
		return;
	end

	if GlyphFrame_LoadUI() then
		GlyphFrame_Open();
	end
end
