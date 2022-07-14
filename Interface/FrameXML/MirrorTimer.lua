
MIRRORTIMER_NUMTIMERS = 3;

MirrorTimerAtlas = {
	EXHAUSTION = "ui-castingbar-filling-standard",
	BREATH = "ui-castingbar-filling-applyingcrafting",
	DEATH = "ui-castingbar-filling-standard",
	FEIGNDEATH = "ui-castingbar-filling-channel",
};

function MirrorTimer_Show(timer, value, maxvalue, scale, paused, label)

	-- Pick a free dialog to use
	local dialog = nil;
	-- Find an open dialog of the requested type
	for index = 1, MIRRORTIMER_NUMTIMERS, 1 do
		local frame = _G["MirrorTimer"..index];
		if ( frame:IsShown() and (frame.timer == timer) ) then
			dialog = frame;
			break;
		end
	end
	if ( not dialog ) then
		-- Find a free dialog
		for index = 1, MIRRORTIMER_NUMTIMERS, 1 do
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
	local text = dialog.Text;
	text:SetText(label);

	-- Set the status bar of the dialog
	local statusbar = dialog.StatusBar;
	statusbar:SetMinMaxValues(0, (maxvalue / 1000));
	statusbar:SetValue(dialog.value);
	statusbar:SetStatusBarTexture(MirrorTimerAtlas[timer]);

	dialog:Show();

	return dialog;
end

MirrorTimerMixin = { };

function MirrorTimerMixin:OnLoad()
	self:RegisterEvent("MIRROR_TIMER_PAUSE");
	self:RegisterEvent("MIRROR_TIMER_STOP");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.timer = nil;
end

function MirrorTimerMixin:OnEvent(event, ...)
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

function MirrorTimerMixin:OnUpdate(elapsed)
	if ( self.paused ) then
		return;
	end
	local statusbar = self.StatusBar;
	self.value = GetMirrorTimerProgress(self.timer)  / 1000;
	statusbar:SetValue(self.value);
end
