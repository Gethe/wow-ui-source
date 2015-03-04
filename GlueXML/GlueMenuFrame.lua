
function GlueMenuFrame_Show()
	GlueMenuFrame:Show();
end
function GlueMenuFrame_Hide()
	GlueMenuFrame:Hide();
end

function GlueMenuFrame_OnShow(self)
	if SHOW_TERMINATION_WITHOUT_NOTICE_AGREEMENT then
		self.TOSButton:Show()
		self.ExitGameButton:SetPoint("TOP", self.TOSButton, "BOTTOM", 0, 10);
	else
		self.ExitGameButton:SetPoint("TOP", self.CinematicsButton, "BOTTOM", 0, 10);
		self.TOSButton:Hide()
	end
end