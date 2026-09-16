function ShakeFrameRandom(frame, magnitude, duration, frequency)
	if frequency <= 0 then
		return;
	end

	local shake = {};
	for i = 1, math.ceil(duration / frequency) do
		local xVariation, yVariation = RandomFloatInRange(-magnitude, magnitude), RandomFloatInRange(-magnitude, magnitude);
		shake[i] = { x = xVariation, y = yVariation };
	end

	ShakeFrame(frame, shake, duration, frequency);
end

function ShakeFrame(frame, shake, maximumDuration, frequency)
	if ( frame.shakeTicker and not frame.shakeTicker:IsCancelled() ) then
		return;
	end

	local point, relativeFrame, relativePoint, x, y = frame:GetPoint(1);
	local shakeIndex = 1;
	local endTime = GetTime() + maximumDuration;
	frame.shakeTicker = C_Timer.NewTicker(frequency, function()
		local xVariation, yVariation = shake[shakeIndex].x, shake[shakeIndex].y;
		frame:SetPoint(point, relativeFrame, relativePoint, x + xVariation, y + yVariation);
		shakeIndex = shakeIndex + 1;
		if shakeIndex > #shake or GetTime() >= endTime then
			frame:SetPoint(point, relativeFrame, relativePoint, x, y);
			frame.shakeTicker:Cancel();
		end
	end);
end
