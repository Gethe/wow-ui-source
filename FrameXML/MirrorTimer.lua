
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
			local frame = getglobal("MirrorTimer"..index);
			if ( frame:IsVisible() and (frame.timer == timer) ) then
				dialog = frame;
				break;
			end
		end
	end
	if ( not dialog ) then
		-- Find a free dialog
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = getglobal("MirrorTimer"..index);
			if ( not frame:IsVisible() ) then
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
	local text = getglobal(dialog:GetName().."Text");
	text:SetText(label);

	-- Set the status bar of the dialog
	local statusbar = getglobal(dialog:GetName().."StatusBar");
	local color = MirrorTimerColors[timer];
	statusbar:SetMinMaxValues(0, (maxvalue / 1000));
	statusbar:SetValue(dialog.value);
	statusbar:SetStatusBarColor(color.r, color.g, color.b);

	dialog:Show();

	return dialog;
end


function MirrorTimerFrame_OnLoad()
	this:RegisterEvent("MIRROR_TIMER_PAUSE");
	this:RegisterEvent("MIRROR_TIMER_STOP");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this.timer = nil;
end

function MirrorTimerFrame_OnEvent()
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		this:Hide();
		this.timer = nil;
	end
	if ( not this:IsVisible() or (arg1 ~= this.timer) ) then
		return;
	end
	if ( event == "MIRROR_TIMER_PAUSE" ) then
		if ( arg1 > 0 ) then
			this.paused = 1;
		else
			this.paused = nil;
		end
		return;
	end
	if ( event == "MIRROR_TIMER_STOP" ) then
		this:Hide();
		this.timer = nil;
	end
end

function MirrorTimerFrame_OnUpdate(elapsed)
	if ( this.paused ) then
		return;
	end
	local statusbar = getglobal(this:GetName().."StatusBar");
	this.value = (this.value + this.scale * elapsed);
	statusbar:SetValue(this.value);
end
