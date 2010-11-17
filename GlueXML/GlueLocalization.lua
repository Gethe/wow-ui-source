function Localize()
	-- Put all locale specific string adjustments here
	--SHOW_CONTEST_AGREEMENT = 1;

	-- Show termination of service without notice agreement
	--SHOW_TERMINATION_WITHOUT_NOTICE_AGREEMENT = 1;
end

function LocalizeFrames()
	-- Put all locale specific UI adjustments here
	WorldOfWarcraftRating:SetTexture("Interface\\Glues\\Login\\Glues-ESRBRating");
	WorldOfWarcraftRating:ClearAllPoints();
	WorldOfWarcraftRating:SetPoint("BOTTOMLEFT", "AccountLoginUI", "BOTTOMLEFT", 20, 45);
	WorldOfWarcraftRating:Show();

	-- Random name button is for English only
	ALLOW_RANDOM_NAME_BUTTON = true;
end
