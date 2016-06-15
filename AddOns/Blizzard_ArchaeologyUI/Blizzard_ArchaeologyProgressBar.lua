
local LEFT_DIGSITE_CHECK_TIME = 0.5;
local MIN_FILL_BAR_PROGRESS = 0.1;
local MAX_FILL_BAR_PROGRESS = 0.1;

local DEFAULT_FILL_BAR_MAX = 6;
function ArcheologyDigsiteProgressBar_OnLoad(self)
	self.FillBar:SetMinMaxValues(0, DEFAULT_FILL_BAR_MAX);
	self.FillBar:SetValue(0);
	self:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST");
	self.FillBar.actualFill = 0;
	self.FillBar.fillBarMax = DEFAULT_FILL_BAR_MAX;
	self.timeSinceLeftDigsiteCheck = 0;
end

function ArcheologyDigsiteProgressBar_OnUpdate(self, elapsed)
	self.timeSinceLeftDigsiteCheck = self.timeSinceLeftDigsiteCheck + elapsed;
	if ( self.timeSinceLeftDigsiteCheck >= LEFT_DIGSITE_CHECK_TIME ) then
		self.timeSinceLeftDigsiteCheck = self.timeSinceLeftDigsiteCheck - LEFT_DIGSITE_CHECK_TIME;
		if ( not CanScanResearchSite() ) then
			--ArcheologyDigsiteProgressBar_OnHide should catch this, but just in case the animation takes too long we put it here too.
			self:SetScript("OnUpdate", nil);
			self.AnimOut:Play();
		end
	end
end

function ArcheologyDigsiteProgressBar_OnShow(self)
	self.timeSinceLeftDigsiteCheck = 0;
	self:SetScript("OnUpdate", ArcheologyDigsiteProgressBar_OnUpdate);
	self:UnregisterEvent("ARCHAEOLOGY_SURVEY_CAST");
	self:RegisterEvent("ARCHAEOLOGY_FIND_COMPLETE");
	self:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE");
	UIParent_ManageFramePositions();
end

function ArcheologyDigsiteProgressBar_OnHide(self)
	self:SetScript("OnUpdate", nil);
	self:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST");
	self:UnregisterEvent("ARCHAEOLOGY_FIND_COMPLETE");
	self:UnregisterEvent("ARTIFACT_DIGSITE_COMPLETE");
	UIParent_ManageFramePositions();
end

function ArcheologyDigsiteProgressBarFillBar_OnUpdate(self, elapsed)
	if ( self:GetValue() ~= self.actualFill ) then
		self:SetValue(GetSmoothProgressChange(self.actualFill, self:GetValue(), self.fillBarMax, elapsed, MIN_FILL_BAR_PROGRESS, MAX_FILL_BAR_PROGRESS));
	else
		self:SetScript("OnUpdate", nil);
	end
end

function ArcheologyDigsiteProgressBar_OnEvent(self, event, ...)
	if ( event == "ARCHAEOLOGY_SURVEY_CAST" ) then
		local numFindsCompleted, totalFinds = ...;
		self.FillBar.fillBarMax = totalFinds;
		self.FillBar:SetMinMaxValues(0, totalFinds);
		self.FillBar.actualFill = numFindsCompleted;
		self.FillBar:SetValue(numFindsCompleted);
		self:Show();
		self.AnimIn:Play();
		
	elseif ( event == "ARCHAEOLOGY_FIND_COMPLETE" ) then
		local numFindsCompleted, totalFinds = ...;
		
		local _, maximum = self.FillBar:GetMinMaxValues(); 
		if ( numFindsCompleted == totalFinds ) then
			--This will be set up later, but to make sure the ArcheologyDigsiteProgressBar is not hidden
			--inbetween the time this finishes and the ARTIFACT_DIGSITE_COMPLETE event is processed, we 
			--stop ArcheologyDigsiteProgressBar_OnUpdate from hiding it early.
			self:SetScript("OnUpdate", nil);
		end
		
		--If this is self.FillBar.actualFill is not one less than numFindsCompleted then the player must have moved
		--from one digsite to another without the progress bar getting reset by being shown and hid.  (This happens
		--if two digsites are on top of each other.)
		self.FillBar.actualFill = numFindsCompleted;
		if ( (self.FillBar.actualFill + 1) ~= numFindsCompleted ) then
			self.FillBar:SetMinMaxValues(0, totalFinds);
			self.FillBar:SetValue(numFindsCompleted);
		else
			self.FillBar:SetScript("OnUpdate", ArcheologyDigsiteProgressBarFillBar_OnUpdate);
		end
		
		self.Flash:Show();
		self.Flash.AnimIn:Play();
		
	elseif ( event == "ARTIFACT_DIGSITE_COMPLETE" ) then
		self:SetScript("OnUpdate", nil);
		self.researchFieldID = ...;
		self.AnimOutAndTriggerToast:Play();
	end
end