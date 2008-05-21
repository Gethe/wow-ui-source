
STATSFRAME_UPDATE_TIME = 0.5;

function ToggleStats()
	if ( StatsFrame:IsShown() ) then
		StatsFrame:Hide();
	else
		StatsFrame:Show();
	end
end

function StatsFrame_OnLoad(self)
	self.updateTime = 0;
end

function StatsFrame_OnUpdate(self, elapsed)
	local updateTime = self.updateTime - elapsed;
	if ( updateTime <= 0 ) then
		updateTime = STATSFRAME_UPDATE_TIME;
		StatsFrameText:SetText(GetDebugStats());
	end
	self.updateTime = updateTime;
end
