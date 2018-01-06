
MIRRORTIMER_NUMTIMERS = 3;

MirrorTimerColors = { };
MirrorTimerColors["EXHAUSTION"] = {
	r = 1.00, g = 0.90, b = 0.00
};
MirrorTimerColors["BREATH"] = {
	r = 0.00, g = 0.50, b = 1.00
};
MirrorTimerColors["DEATH"] = {
	r = 1.00, g = 0.70, b = 0.00
};
MirrorTimerColors["FEIGNDEATH"] = {
	r = 1.00, g = 0.70, b = 0.00
};

function MirrorTimer_Show(timer, value, maxvalue, scale, paused, label)

	-- Pick a free dialog to use
	local dialog = nil;
	if ( not dialog ) then
		-- Find an open dialog of the requested type
		for index = 1, MIRRORTIMER_NUMTIMERS, 1 do
			local frame = _G["MirrorTimer"..index];
			if ( frame:IsShown() and (frame.timer == timer) ) then
				dialog = frame;
				break;
			end
		end
	end
	if ( not dialog ) then
		-- Find a free dialog
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = _G["MirrorTimer"..index];
			if ( not frame:IsShown() ) then
				dialog = frame;
				break;
			end
		end
	end
	if ( not dialog ) then
		return nil;
	end

	dialog.timer = timer;
	dialog.value = (value / 1000);
	dialog.scale = scale;
	if ( paused > 0 ) then
		dialog.paused = 1;
	else
		dialog.paused = nil;
	end

	-- Set the text of the dialog
	local text = _G[dialog:GetName().."Text"];
	text:SetText(label);

	-- Set the status bar of the dialog
	local statusbar = _G[dialog:GetName().."StatusBar"];
	local color = MirrorTimerColors[timer];
	statusbar:SetMinMaxValues(0, (maxvalue / 1000));
	statusbar:SetValue(dialog.value);
	statusbar:SetStatusBarColor(color.r, color.g, color.b);

	dialog:Show();

	return dialog;
end


function MirrorTimerFrame_OnLoad(self)
	self:RegisterEvent("MIRROR_TIMER_PAUSE");
	self:RegisterEvent("MIRROR_TIMER_STOP");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.timer = nil;
end

function MirrorTimerFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		for index=1, MIRRORTIMER_NUMTIMERS do
			local timer, value, maxvalue, scale, paused, label = GetMirrorTimerInfo(index);
			if ( timer ==  "UNKNOWN") then
				self:Hide();
				self.timer = nil;
			else
				MirrorTimer_Show(timer, value, maxvalue, scale, paused, label)
			end
		end
	end
	
	local arg1 = ...;
	if ( not self:IsShown() or (arg1 ~= self.timer) ) then
		return;
	end
	
	if ( event == "MIRROR_TIMER_PAUSE" ) then
		if ( arg1 > 0 ) then
			self.paused = 1;
		else
			self.paused = nil;
		end
		return;
	elseif ( event == "MIRROR_TIMER_STOP" ) then
		self:Hide();
		self.timer = nil;
	end
end

function MirrorTimerFrame_OnUpdate(frame, elapsed)
	if ( frame.paused ) then
		return;
	end
	local statusbar = _G[frame:GetName().."StatusBar"];
	frame.value = GetMirrorTimerProgress(frame.timer)  / 1000;
	statusbar:SetValue(frame.value);
end
