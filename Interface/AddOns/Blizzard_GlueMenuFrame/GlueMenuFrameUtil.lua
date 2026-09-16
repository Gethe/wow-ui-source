GlueMenuFrameUtil = {};

GlueMenuFrameUtil.GlueMenuContextKey = "GlueMenuFrame";

function GlueMenuFrameUtil.ShowMenu()
	if (Kiosk.IsEnabled()) then
		return;
	end

	GlueMenuFrame:Show();
end

function GlueMenuFrameUtil.HideMenu()
	PlaySound(SOUNDKIT.IG_MAINMENU_CONTINUE);
	GlueMenuFrame:Hide();
end

function GlueMenuFrameUtil.ToggleMenu()
	if GlueMenuFrame:IsShown() then
		GlueMenuFrameUtil.HideMenu();
	else
		GlueMenuFrameUtil.ShowMenu();
	end
end
