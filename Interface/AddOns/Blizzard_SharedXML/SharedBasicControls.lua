
if not IsInGlobalEnvironment() then
	-- Don't want to load this file into the secure environment
	return;
end

BaseTextTimerMixin = {};

function BaseTextTimerMixin:StartTimer(timeInSeconds, updateFrequency, hideOnFinish, notAbbreviated, formatString)
	if not self.TimerText then
		error("BaseTextTimers require a font string child with parentKey set to TimerText");
		return;
	end

	if timeInSeconds <= 0 then
		self:StopTimer();
		return;
	end

	self:Show();
	self.hideOnFinish = hideOnFinish;
	self.notAbbreviated = notAbbreviated;
	self.formatString = formatString;
	self.currentTime = GetTime();
	self.updateFrequency = updateFrequency;
	self.nextUpdateCountdown = 0;
	self.endTime = self.currentTime + timeInSeconds;
	self:SetScript("OnUpdate", self.OnUpdate);
end

function BaseTextTimerMixin:StopTimer()
	if not self.currentTime then
		-- Timer was never started...just hide it
		self:Hide();
		return;
	end

	self.currentTime = 0;
	self.endTime = 0;
	self.nextUpdateCountdown = 0;
	self:UpdateTimerText();
end

function BaseTextTimerMixin:UpdateTimerText()
	self.remainingTime = max(self.endTime - self.currentTime, 0);

	local formattedTime = SecondsToTime(self.remainingTime, false, self.notAbbreviated, 1, true);
	local timerText = CLASS_TRIAL_TIMER_DIALOG_TEXT_NO_REMAINING_TIME;

	if self.formatString then
		self.TimerText:SetText(self.formatString:format(formattedTime));
	else
		self.TimerText:SetText(formattedTime);
	end

	if self.remainingTime <= 0 then
		self.TimerText:SetText("");
		if self.hideOnFinish then
			self:Hide();
		end
		self:SetScript("OnUpdate", nil);
	end
end

function BaseTextTimerMixin:OnUpdate(elapsed)
	self.nextUpdateCountdown = self.nextUpdateCountdown - elapsed;
	if self.nextUpdateCountdown <= 0 then
		self.nextUpdateCountdown = self.updateFrequency;
		self.currentTime = GetTime();
		self:UpdateTimerText();
	end
end

BaseExpandableDialogMixin = {};

function BaseExpandableDialogMixin:SetupTextureKit(textureKit, textureKitRegionInfo)
	SetupTextureKitsFromRegionInfo(textureKit, self, textureKitRegionInfo);
end

-- override as needed
function BaseExpandableDialogMixin:OnCloseClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	self:Hide();
end

function BaseExpandableDialogMixin_OnCloseClick(self)
	self:GetParent():OnCloseClick();
end

BaseNineSliceDialogMixin = {};

local textureKitRegionInfo = {
	["ParchmentTop"] = {formatString= "%s-Top", useAtlasSize=true},
	["ParchmentMiddle"] = {formatString="%s-Middle", useAtlasSize = false},
	["ParchmentBottom"] = {formatString="%s-Bottom", useAtlasSize = true},
}

function BaseNineSliceDialogMixin:OnLoad()
	NineSliceUtil.ApplyUniqueCornersLayout(self.Border, self.nineSliceTextureKit);
	SetupTextureKitsFromRegionInfo(self.parchmentTextureKit, self.Contents, textureKitRegionInfo)

	self:SetPoint("TOP", UIParent, "TOP", 0, self.topYOffset);

	self.Contents.ParchmentTop:SetPoint("TOP", self, "TOP", self.parchmentXOffset, -self.parchmentYPaddingTop);
	self.Contents.ParchmentBottom:SetPoint("BOTTOM", self, "BOTTOM", self.parchmentXOffset, self.parchmentYPaddingBottom);

	if self.centerBackgroundTexture then
		self.CenterBackground:SetPoint("TOPLEFT", self, "TOPLEFT", self.centerBackgroundXPadding, -self.centerBackgroundYPadding);
		self.CenterBackground:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.centerBackgroundXPadding, self.centerBackgroundYPadding);
		self.CenterBackground:SetAtlas(self.centerBackgroundTexture);
		self.CenterBackground:Show();
	else
		self.CenterBackground:Hide();
	end
end

function BaseNineSliceDialogMixin:OnShow()
	local parent = GetAppropriateTopLevelParent();
	self.Underlay:SetPoint("TOPLEFT", parent, "TOPLEFT");
	self.Underlay:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT");
	self.Underlay:SetFrameLevel(self:GetFrameLevel() - 1);
	self.Underlay:SetShown(self.showUnderlay);
end

function BaseNineSliceDialogMixin:Display(title, description, onCloseCvar)
	self.Contents.Title:SetText(title:upper());
	self.Contents.Description:SetText(description);
	self.Contents.DescriptionDuplicate:SetText(description);
	self:Show();
	self.onCloseCvar = onCloseCvar;
end

-- override as needed
function BaseNineSliceDialogMixin:OnCloseClick()
	if self.onCloseCvar then
		SetCVar(self.onCloseCvar, "1");
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	self:Hide();
end

function BaseNineSliceDialog_OnCloseClick(self)
	self:GetParent():GetParent():OnCloseClick();
end

function SetBasicMessageDialogText(text, force)
	if ( force or not BasicMessageDialog:IsShown()) then
		BasicMessageDialog.Text:SetText(text);
		BasicMessageDialog:Show();
	end
end