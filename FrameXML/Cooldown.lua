
function CooldownFrame_SetTimer(this, start, duration, enable)
	if ( start > 0 and duration > 0 and enable > 0) then
		this.start = start;
		this.duration = duration;
		this.stopping = 0;
		this:SetSequence(0);
		this:Show();
	else
		this:Hide();
	end
end

function CooldownFrame_OnUpdateModel()
	if ( this.stopping == 0 ) then
		local finished = (GetTime() - this.start) / this.duration;
		if ( finished < 1.0 ) then
			local time = finished * 1000;
			this:SetSequenceTime(0, time);
			return;
		end
		this.stopping = 1;
		this:SetSequence(1);
		this:SetSequenceTime(1, 0);
	else
		this:AdvanceTime();
	end
end

function CooldownFrame_OnAnimFinished()
	if ( this.stopping == 1 ) then
		this:Hide();
	end
end
