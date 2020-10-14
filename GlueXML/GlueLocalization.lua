function Localize()
	-- Put all locale specific string adjustments here
end

function LocalizeFrames()
	-- Put all locale specific UI adjustments here

	-- Random name button is for English only
	CharacterCreateFrame.NameChoiceFrame.RandomNameButton:SetShown(true);

	--TODO: Remove once the old char create is gone
	ALLOW_RANDOM_NAME_BUTTON = true;
end
