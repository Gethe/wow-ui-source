function MovieRecordingProgress_OnUpdate()
	if(not MovieRecording_IsCompressing()) then
		this:Hide();
	else
		local recovering, progress = MovieRecording_GetProgress();
		MovieProgressBar:SetValue(progress);
		MovieProgressBarText:SetText(MOVIE_RECORDING_COMPRESSING.." "..floor(progress * 100).."%");
	end
end


