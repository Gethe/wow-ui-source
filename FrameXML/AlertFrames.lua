function AlertFrame_OnLoad (self)
	self:RegisterEvent("ACHIEVEMENT_EARNED");
end

function AlertFrame_OnEvent (self, event, ...)
	if ( event == "ACHIEVEMENT_EARNED" ) then
		local id = ...;
		
		if ( not AchievementFrame ) then
			AchievementFrame_LoadUI();
		end
		
		AchievementAlertFrame_ShowAlert(id);
	end
end

-- [[ AchievementAlertFrame ]] --
function AchievementAlertFrame_OnLoad (self)
	self:RegisterForClicks("LeftButtonUp");
	self.glow = getglobal(self:GetName().."Glow");
	self.shine = getglobal(self:GetName().."Shine");
	-- Setup a continous timescale since the table values are offsets
	self.fadeinDuration = 0.2;
	self.flashDuration = 0.5;
	self.shineStartTime = 0.3;
	self.shineDuration = 0.85;
	self.holdDuration = 3;
	self.fadeoutDuration = 1.5;
end

function AchievementAlertFrame_FixAnchors ()
	-- Temporary (here's hoping) workaround so that achievement alerts are anchored to loot roll windows. Eventually we want one system to handle placement for both alerts.
	if ( not AchievementAlertFrame1 ) then
		-- We haven't displayed any achievement alerts yet, so there's nothing to reanchor (read: this got called by LootFrame.lua)
		return;
	end
	
	
	local lastVisibleLootFrame;
	for i=1, NUM_GROUP_LOOT_FRAMES do
		local frame = getglobal("GroupLootFrame"..i);
		if ( frame and frame:IsShown() ) then
			lastVisibleLootFrame = frame;
		end
	end
	
	if ( lastVisibleLootFrame ) then
		AchievementAlertFrame1:SetPoint("BOTTOM", lastVisibleLootFrame, "TOP", 0, 10);
	else
		AchievementAlertFrame1:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 128);
	end
end

function AchievementAlertFrame_ShowAlert (achievementID)
	local frame = AchievementAlertFrame_GetAlertFrame();
	local _, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(achievementID);
	if ( not frame ) then
		-- We ran out of frames! Bail!
		return;
	end

	AchievementAlertFrame_FixAnchors();

	getglobal(frame:GetName() .. "Name"):SetText(name);
	
	local shield = getglobal(frame:GetName() .. "Shield");
	AchievementShield_SetPoints(points, shield.points, GameFontNormal, GameFontNormalSmall);
	if ( points == 0 ) then
		shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
	else
		shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
	end
	
	getglobal(frame:GetName() .. "IconTexture"):SetTexture(icon);
	frame.elapsed = 0;
	frame.state = nil;
	frame:SetAlpha(0);
	frame:Show();
	frame.id = achievementID;
	
	frame:SetScript("OnUpdate", AchievementAlertFrame_OnUpdate);
end

function AchievementAlertFrame_GetAlertFrame()
	local maxAlerts = 2;
	local name, frame, previousFrame;
	for i=1, maxAlerts do
		name = "AchievementAlertFrame"..i;
		frame = getglobal(name);
		if ( frame ) then
			if ( not frame:IsShown() ) then
				return frame;
			end
		else
			frame = CreateFrame("Button", name, UIParent, "AchievementAlertFrameTemplate");
			if ( not previousFrame ) then
				frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 128);
			else
				frame:SetPoint("BOTTOM", previousFrame, "TOP", 0, -10);
			end
			return frame;
		end
		previousFrame = frame;
	end
	return nil;
end

function AchievementAlertFrame_OnUpdate (self, elapsed)
	local state = self.state;
	local alpha;
	local deltaTime = elapsed;
	--initialize
	if ( not state ) then
		state = "fadein";
		self.glow:Show();
		self.glow:SetAlpha(0);
		self.totalElapsed = 0;
	end
	self.totalElapsed = self.totalElapsed+elapsed;
	elapsed = self.elapsed + elapsed;
	if ( state == "fadein" ) then
		if ( elapsed >= self.fadeinDuration ) then
			state = "flash";
			elapsed = 0;
			self:SetAlpha(1);
			self.glow:Show();
		else
			self:SetAlpha(elapsed/self.fadeinDuration);
			self.glow:SetAlpha(elapsed/self.fadeinDuration);
		end
	elseif ( state == "flash" ) then
		if ( elapsed >= self.flashDuration ) then
			state = "hold";
			elapsed = 0;
			self.glow:Hide();
		else
			self.glow:SetAlpha(1-(elapsed/self.flashDuration));
		end
	elseif ( state == "hold" ) then
		if ( elapsed >= self.holdDuration ) then
			state = "fadeout";
			elapsed = 0;
		end
	elseif ( state == "fadeout" ) then
		if ( elapsed >= self.fadeoutDuration ) then
			state = nil;
			self:SetScript("OnUpdate", nil);
			self:Hide();
			self.id = nil;
		else
			self:SetAlpha(1-(elapsed/self.fadeoutDuration));
		end
	end

	--Handle shine
	local normalizedTime = self.totalElapsed - self.shineStartTime;
	if ( normalizedTime >= 0 and normalizedTime <= self.shineDuration ) then
		if ( not self.shine:IsShown() ) then
			self.shine:Show();
			self.shine:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -8);
			self.shine:SetAlpha(1);
		end
		local target = 239;
		local _,_,_,x = self.shine:GetPoint();
		if ( x ~= target ) then
			x = x +(target-x)*(deltaTime/(self.shineDuration/3));
			if ( floor(abs(target - x)) >= 0 ) then
				x = target;
			end
		end
		
		self.shine:SetPoint("TOPLEFT", self, "TOPLEFT", x, -8);
		self.shine:SetAlpha(1);
		local startShineFade = 0.8*self.shineDuration;
		if ( normalizedTime >= startShineFade ) then
			self.shine:SetAlpha(1-((normalizedTime-startShineFade)/(self.shineDuration-startShineFade)));
		end
	else
		if ( self.shine:IsShown() ) then
			self.shine:Hide();
			self.vel = nil;
		end
	end

	self.state = state;
	self.elapsed = elapsed;
end

function AchievementAlertFrame_OnClick (self)
	local id = self.id;
	if ( not id ) then
		return;
	end
	
	self.elapsed = 0;
	CloseAllWindows();
	ShowUIPanel(AchievementFrame);
	
	local _, _, _, achCompleted = GetAchievementInfo(id);
	if ( achCompleted and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_INCOMPLETE].func) ) then
		AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
	elseif ( (not achCompleted) and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_COMPLETE].func) ) then
		AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
	end
	
	AchievementFrame_SelectAchievement(id)
end
