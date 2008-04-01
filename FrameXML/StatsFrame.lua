
STATSFRAME_UPDATE_TIME = 0.5;

function ToggleStats()
	if ( StatsFrame:IsVisible() ) then
		StatsFrame:Hide();
	else
		StatsFrame:Show();
	end
end

function StatsFrame_OnLoad()
	this.updateTime = 0;
end

function StatsFrame_OnUpdate(elapsed)
	local updateTime = this.updateTime - elapsed;
	if ( updateTime <= 0 ) then
		updateTime = STATSFRAME_UPDATE_TIME;
		StatsFrameText:SetText(GetDebugStats());
	end
	this.updateTime = updateTime;
end
