local splashFrameTextureRegions = {
	["LeftTexture"] = "splash-%s-topleft",
	["RightTexture"] = "splash-%s-right",
	["BottomTexture"] = "splash-%s-botleft",
};

SplashFrameMixin = { };

function SplashFrameMixin:OnLoad()
	self.screenInfo = nil;
	self:RegisterEvent("OPEN_SPLASH_SCREEN");
	AlertFrame:SetAlertsEnabled(false, "splashFrame");
end

function SplashFrameMixin:OnShow()
	C_TalkingHead.SetConversationsDeferred(true);
	AlertFrame:SetAlertsEnabled(false, "splashFrame");
	C_SplashScreen.AcknowledgeSplash();
end

function SplashFrameMixin:OnHide()
	self.screenInfo = nil;
	C_TalkingHead.SetConversationsDeferred(false);
	AlertFrame:SetAlertsEnabled(true, "splashFrame");
	ObjectiveTracker_Update();
end

function SplashFrameMixin:OnEvent(event, ...)
	if ( Kiosk.IsEnabled() ) then
		return;
	end
	if event == "OPEN_SPLASH_SCREEN" then
		self:SetupFrame(...);
	elseif event == "QUEST_LOG_UPDATE" then
		if( self:IsShown() and self.screenInfo)then
			self.RightFeature:SetStartQuestButtonDisplay(self.screenInfo);
		end
	end
end

function SplashFrameMixin:SetupFrame(screenInfo)
	if(not screenInfo) then
		AlertFrame:SetAlertsEnabled(true, "splashFrame");
		return;
	end

	if(screenInfo.soundKitID > 0) then 
		PlaySound(screenInfo.soundKitID);
	end 

	SetupTextureKitOnRegions(screenInfo.textureKit, self, splashFrameTextureRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	self.BottomTexture:SetSize(371, 137);

	if (screenInfo.screenType == Enum.SplashScreenType.WhatsNew) then
		self.Header:SetText(SPLASH_BASE_HEADER);
	elseif(screenInfo.screenType == Enum.SplashScreenType.SeasonRollOver) then
		self.Header:SetText(SPLASH_NEW_HEADER_SEASON);
	end

	self.Label:SetText(screenInfo.header);
	self.TopLeftFeature:Setup(screenInfo.topLeftFeatureTitle, screenInfo.topLeftFeatureDesc);
	self.BottomLeftFeature:Setup(screenInfo.bottomLeftFeatureTitle, screenInfo.bottomLeftFeatureDesc);
	self.RightFeature:Setup(screenInfo);
	self:Show();

	ObjectiveTracker_Update();
	if( QuestFrame:IsShown() )then
		HideUIPanel(QuestFrame);
	end

	self.screenInfo = screenInfo;
	self:RegisterEvent("QUEST_LOG_UPDATE");
end

function SplashFrameMixin:OpenQuestDialog()
	local questID = self.RightFeature.questID;
	ShowQuestOffer(questID);
	AutoQuestPopupTracker_RemovePopUp(questID);

	C_QuestLog.AddQuestWatch(questID, Enum.QuestWatchType.Automatic);
	C_SuperTrack.SetSuperTrackedQuestID(questID);
end

function SplashFrameMixin:Close()
	local questID = self.RightFeature.questID;
	local showQuestDialog = questID and (self.RightFeature.StartQuestButton:IsShown() and self.RightFeature.StartQuestButton:IsEnabled());
	HideUIPanel(self);

	if (showQuestDialog) then
		self:OpenQuestDialog();
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
end

StartQuestButtonMixin = { };

function StartQuestButtonMixin:SetButtonState(enabled)
	if (enabled) then
		self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self:SetScript("OnUpdate", nil);
	else
		self.Text:SetTextColor(GRAY_FONT_COLOR:GetRGB());
	end

	self.Texture:SetDesaturated(not enabled);
	self:SetEnabled(enabled);
end

function StartQuestButtonMixin:OnMouseUp()
	self.Text:SetPoint("CENTER", 20, 0);
end

function StartQuestButtonMixin:OnMouseDown()
	if( self:IsEnabled() ) then
		self.Text:SetPoint("CENTER", 22, -2);
	end
end

function StartQuestButtonMixin:OnEnter()
	self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
end

function StartQuestButtonMixin:OnLeave()
	self.Text:SetTextColor(DARKYELLOW_FONT_COLOR:GetRGB());
end

function StartQuestButtonMixin:OnClick()
	self:GetParent():GetParent():Close();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end


SplashFeatureFrameMixin = { };

function SplashFeatureFrameMixin:Setup(title, description)
	self.Title:SetText(title);
	self.Description:SetText(description);
end

SplashRightFeatureFrameMixin = { };

function SplashRightFeatureFrameMixin:GetQuestID(screenInfo)
	if (UnitFactionGroup("player") == "Horde") then
		return screenInfo.hordeQuestID;
	else
		return screenInfo.allianceQuestID;
	end
end

function SplashRightFeatureFrameMixin:ShouldShowQuestButton()
	if( self.questID ) then
		local autoQuest = false;
		for i = 1, GetNumAutoQuestPopUps() do
			local id, popUpType = GetAutoQuestPopUp(i);
			if( id == self.questID and popUpType ) then
				autoQuest = true;
				break;
			end
		end
		return autoQuest or C_QuestLog.GetLogIndexForQuestID(self.questID) ~= nil;
	end

	return false;
end

function SplashRightFeatureFrameMixin:Setup(screenInfo)
	self.questID = self:GetQuestID(screenInfo);
	self.Title:SetSize(310, 0);
	self.Title:SetMaxLines(1);
	self.Title:SetFontObjectsToTry("Game72Font", "Game60Font", "Game48Font", "Game46Font", "Game36Font", "Game32Font", "Game27Font", "Game24Font", "Game18Font");
	self.Title:SetText(screenInfo.rightFeatureTitle);
	self.Description:SetText(screenInfo.rightFeatureDesc);
	self:SetStartQuestButtonDisplay(screenInfo);
end

function SplashRightFeatureFrameMixin:SetStartQuestButtonDisplay(screenInfo)
	self.Title:ClearAllPoints();
	local showStartButton = self.questID ~= nil and screenInfo.shouldShowQuest and self:ShouldShowQuestButton(self.questID);
	if (showStartButton) then
		self.Description:ClearAllPoints();
		self.Description:SetPoint("BOTTOM", self.StartQuestButton, "TOP", 0, 25);
		self.Description:SetWidth(300);

		self.Title:SetPoint("BOTTOM", self.Description, "TOP", 0, 10);
	else
		self.Description:SetWidth(228);
		self.Title:SetPoint("BOTTOM", self.Description, "TOP", 0, 10);

		if (screenInfo.rightFeatureDescSubText) then
			self.Description:SetText(screenInfo.rightFeatureDescSubText);
			self.Description:ClearAllPoints();
			self.Description:SetPoint("TOP", self.Title, "BOTTOM", 0, -10);
		end
	end

	self.StartQuestButton:SetShown(showStartButton);
	self:GetParent().BottomCloseButton:SetShown(not showStartButton);
end