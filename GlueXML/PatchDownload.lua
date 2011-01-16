FADE_IN_TIME = 2;

function PatchDownload_OnLoad(self)
	self:SetSequence(0);
	self:SetCamera(0);

	self:RegisterEvent("PATCH_UPDATE_PROGRESS");
	self:RegisterEvent("PATCH_DOWNLOADED");
end

function PatchDownload_OnShow()
	PatchDownload_UpdateProgress();
	PatchDownload_UpdateButtons();
	PatchDownloadRestartButton:Enable();
end

function PatchDownload_UpdateButtons()
	local amtComplete = PatchDownloadProgress();
	if (amtComplete >= 1.0) then
		PatchDownloadCancelButton:Hide();
		PatchDownloadRestartButton:Show();
		PatchProgressText:Hide();
		PatchSuccessfulText:Show();
		PatchSuccessfulTitle:Show();
		DownloadingUpdateTitle:Hide();
	else
		PatchDownloadCancelButton:Show();
		PatchDownloadRestartButton:Hide();
		PatchProgressText:Show();
		PatchSuccessfulText:Hide();
		PatchSuccessfulTitle:Hide();
		DownloadingUpdateTitle:Show();
	end
end

function PatchDownload_OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		if ( PatchDownloadCancelButton:IsShown() ) then
			PatchDownload_Cancel();
		end
	elseif ( key == "ENTER" ) then
		if ( PatchDownloadRestartButton:IsShown() ) then
			PatchDownload_Restart();
		end
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function PatchDownload_UpdateProgress()
	local amtComplete = PatchDownloadProgress();
	PatchProgressText:SetFormattedText("%3.0f%%", amtComplete*100);
end

function PatchDownload_PatchDownloaded()
	PatchDownload_UpdateButtons();
	PatchDownload_UpdateProgress();
end

function PatchDownload_OnEvent(event)
	if ( event == "PATCH_UPDATE_PROGRESS" ) then
		PatchDownload_UpdateProgress();
	elseif ( event == "PATCH_DOWNLOADED" ) then
		PatchDownload_PatchDownloaded()
	end
end

function PatchDownload_Cancel()
	PatchDownloadCancel();
end

function PatchDownload_Restart()
	PatchDownloadRestartButton:Disable();
	PatchDownloadApply();
end