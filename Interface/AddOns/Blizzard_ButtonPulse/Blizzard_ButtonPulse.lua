local pulseButtons = {};
local pulseFrame = CreateFrame("Frame");

local function UpdatePulseFrameState()
	if next(pulseButtons) then
		pulseFrame:Show();
	else
		pulseFrame:Hide();
	end
end

function SetButtonPulse(button, duration, pulseRate)
	button.pulseDuration = pulseRate;
	button.pulseTimeLeft = duration;
	button.pulseRate = pulseRate;
	button.pulseOn = 0;
	if not tContains(pulseButtons, button) then
		tinsert(pulseButtons, button);
	end
	UpdatePulseFrameState();
end

local function ButtonPulse_OnUpdate(self, elapsed)
	for _, button in pairs(pulseButtons) do
		if ( button.pulseTimeLeft > 0 ) then
			if ( button.pulseDuration < 0 ) then
				if ( button.pulseOn == 1 ) then
					button:UnlockHighlight();
					button.pulseOn = 0;
				else
					button:LockHighlight();
					button.pulseOn = 1;
				end
				button.pulseDuration = button.pulseRate;
			end
			button.pulseDuration = button.pulseDuration - elapsed;
			button.pulseTimeLeft = button.pulseTimeLeft - elapsed;
		else
			button:UnlockHighlight();
			button.pulseOn = 0;
			tDeleteItem(pulseButtons, button);
		end
	end

	UpdatePulseFrameState();
end

pulseFrame:SetScript("OnUpdate", ButtonPulse_OnUpdate);
pulseFrame:Hide();

function ButtonPulse_StopPulse(button)
	for _, pulseButton in pairs(pulseButtons) do
		if ( pulseButton == button ) then
			tDeleteItem(pulseButtons, button);
			break;
		end
	end
	UpdatePulseFrameState();
end
