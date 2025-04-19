
local LEFT_DIGSITE_CHECK_TIME = 0.5;
local MIN_FILL_BAR_PROGRESS = 0.1;
local MAX_FILL_BAR_PROGRESS = 0.1;
local DEFAULT_FILL_BAR_MAX = 6;

ArcheologyDigsiteProgressBarMixin = {};

function ArcheologyDigsiteProgressBarMixin:OnLoad()
	self.FillBar:SetMinMaxValues(0, DEFAULT_FILL_BAR_MAX);
	self.FillBar:SetValue(0);
	self:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST");
	self.FillBar.actualFill = 0;
	self.FillBar.fillBarMax = DEFAULT_FILL_BAR_MAX;
	self.timeSinceLeftDigsiteCheck = 0;
end

function ArcheologyDigsiteProgressBarMixin:OnUpdate(elapsed)
	self.timeSinceLeftDigsiteCheck = self.timeSinceLeftDigsiteCheck + elapsed;
	if ( self.timeSinceLeftDigsiteCheck >= LEFT_DIGSITE_CHECK_TIME ) then
		self.timeSinceLeftDigsiteCheck = self.timeSinceLeftDigsiteCheck - LEFT_DIGSITE_CHECK_TIME;
		if ( not CanScanResearchSite() ) then
			-- OnHide should catch this, but just in case the animation takes too long we put it here too.
			self:SetScript("OnUpdate", nil);
			self.AnimOut:Play();
		end
	end
end

function ArcheologyDigsiteProgressBarMixin:OnShow()
	self.timeSinceLeftDigsiteCheck = 0;
	self:SetScript("OnUpdate", self.OnUpdate);
	self:UnregisterEvent("ARCHAEOLOGY_SURVEY_CAST");
	self:RegisterEvent("ARCHAEOLOGY_FIND_COMPLETE");
	self:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE");
end

function ArcheologyDigsiteProgressBarMixin:OnHide()
	self:SetScript("OnUpdate", nil);
	self:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST");
	self:UnregisterEvent("ARCHAEOLOGY_FIND_COMPLETE");
	self:UnregisterEvent("ARTIFACT_DIGSITE_COMPLETE");
end

function ArcheologyDigsiteProgressBarMixin:OnEvent(event, ...)
	if ( event == "ARCHAEOLOGY_SURVEY_CAST" ) then
		local numFindsCompleted, totalFinds = ...;
		self:OnSurveyCast(numFindsCompleted, totalFinds);

	elseif ( event == "ARCHAEOLOGY_FIND_COMPLETE" ) then
		local numFindsCompleted, totalFinds = ...;
		self:OnFindComplete(numFindsCompleted, totalFinds);

	elseif ( event == "ARTIFACT_DIGSITE_COMPLETE" ) then
		local researchFieldID = ...;
		self:OnArtifactDigsiteComplete(researchFieldID);
	end
end

function ArcheologyDigsiteProgressBarMixin:OnSurveyCast(numFindsCompleted, totalFinds)
	self.FillBar.fillBarMax = totalFinds;
	self.FillBar:SetMinMaxValues(0, totalFinds);
	self.FillBar.actualFill = numFindsCompleted;
	self.FillBar:SetValue(numFindsCompleted);

	self.shouldShow = true;
	self:UpdateShownState();

	self.AnimIn:Play();
end

function ArcheologyDigsiteProgressBarMixin:OnFindComplete(numFindsCompleted, totalFinds)
	local _, maximum = self.FillBar:GetMinMaxValues();
	if ( numFindsCompleted == totalFinds ) then
		--This will be set up later, but to make sure the ArcheologyDigsiteProgressBar is not hidden
		--inbetween the time this finishes and the ARTIFACT_DIGSITE_COMPLETE event is processed, we 
		--stop OnUpdate from hiding it early.
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
		self.FillBar:SetScript("OnUpdate", self.FillBar.OnUpdate);
	end

	self.Flash:Show();
	self.Flash.AnimIn:Play();
end

function ArcheologyDigsiteProgressBarMixin:OnArtifactDigsiteComplete(researchFieldID)
	self:SetScript("OnUpdate", nil);
	self.researchFieldID = researchFieldID;
	self.AnimOutAndTriggerToast:Play();
end

function ArcheologyDigsiteProgressBarMixin:UpdateShownState()
	self:SetShown(self.shouldShow);
end

ArcheologyDigsiteProgressFillBarMixin = {};

function ArcheologyDigsiteProgressFillBarMixin:OnUpdate(elapsed)
	if ( self:GetValue() ~= self.actualFill ) then
		self:SetValue(GetSmoothProgressChange(self.actualFill, self:GetValue(), self.fillBarMax, elapsed, MIN_FILL_BAR_PROGRESS, MAX_FILL_BAR_PROGRESS));
	else
		self:SetScript("OnUpdate", nil);
	end
end

ArcheologyDigsiteProgressBarAnimOutMixin = {};

function ArcheologyDigsiteProgressBarAnimOutMixin:OnFinished()
	ArcheologyDigsiteProgressBar.shouldShow = false;
	ArcheologyDigsiteProgressBar:UpdateShownState();
end

ArcheologyDigsiteProgressBarAnimOutAndTriggerToastMixin = {};

function ArcheologyDigsiteProgressBarAnimOutAndTriggerToastMixin:OnFinished()
	DigsiteCompleteAlertSystem:AddAlert(GetArchaeologyRaceInfoByID(ArcheologyDigsiteProgressBar.researchFieldID));
	ArcheologyDigsiteProgressBar.shouldShow = false;
	ArcheologyDigsiteProgressBar:UpdateShownState();
end

ArcheologyDigsiteProgressBarFlashAnimInMixin = {};

function ArcheologyDigsiteProgressBarFlashAnimInMixin:OnFinished()
	ArcheologyDigsiteProgressBar.Flash:Hide();
end