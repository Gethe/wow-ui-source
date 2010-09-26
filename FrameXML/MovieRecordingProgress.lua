function MovieRecordingProgress_OnUpdate(self, elapsed)
	if(not MovieRecording_IsCompressing()) then
		self:Hide();
	else
		local recovering, progress = MovieRecording_GetProgress();
                MovieProgressBar:SetMinMaxValues(0, 1);
                MovieProgressBar:SetValue(progress);
		MovieProgressBarText:SetText(MOVIE_RECORDING_COMPRESSING.." "..floor(progress * 100).."%");
	end
end


