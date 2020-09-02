CreditsFrameMixin = {};

function CreditsFrameMixin:OnShow()
	StopGlueAmbience();
	self.expansion = GetClientDisplayExpansionLevel();
	self.maxExpansion = LE_EXPANSION_LEVEL_CURRENT;
	self:Update();
end

function CreditsFrameMixin:OnHide()
	self.ExpansionList:Hide();
	ShowCursor();
end

function CreditsFrameMixin:Update()
	PlayGlueMusic(SafeGetExpansionData(GLUE_CREDITS_SOUND_KITS, self.expansion));
	local expansionInfo = GetExpansionDisplayInfo(self.expansion);
	if expansionInfo then
		self.Logo:SetTexture(expansionInfo.logo);
	end

	self:SetSpeed(CREDITS_SCROLL_RATE_PLAY);
	self.ScrollFrame:SetVerticalScroll(0);
	self.ScrollFrame.scroll = 0;
	self.ScrollFrame:UpdateMax();

	self:UpdateArt();

	-- Set Credits Text
	self.ScrollFrame.Text:SetText(GetCreditsText(self.expansion));
end

function CreditsFrameMixin:Switch(expansion)
	self.expansion = expansion;
	self:Update();
end

function CreditsFrameMixin:UpdateArt()

	self.KeyArt:ClearAllPoints();
	local keyArt = ("CreditsScreen-Keyart-%d"):format(self.expansion);
	local info = C_Texture.GetAtlasInfo(keyArt);
	if (info) then
		local x = -(self:GetRight() - self.ScrollFrame:GetLeft() + 100) / 2;
		self.KeyArt:SetPoint("TOP", self, "TOP", x, -50);
		self.KeyArt:SetAtlas(keyArt, true);
		self.KeyArt:SetScale((GetScreenHeight() - 120) / info.height);
	end

	-- The following anchors the background textures to the entire screen regardless of GlueParent
	local topParent = GlueParent:GetParent();
	local backgroundTile = ("CreditsScreen-Background-%d"):format(self.expansion);
	self.Background:SetAtlas(backgroundTile, true);
	self.Background:ClearAllPoints();
	self.Background:SetAllPoints(topParent);

	self.UpperGradient:ClearAllPoints();
	self.UpperGradient:SetPoint("TOP", topParent, "TOP");
	self.UpperGradient:SetPoint("LEFT", topParent, "LEFT");
	self.UpperGradient:SetPoint("RIGHT", topParent, "RIGHT");

	self.LowerGradient:ClearAllPoints();
	self.LowerGradient:SetPoint("BOTTOM", topParent, "BOTTOM");
	self.LowerGradient:SetPoint("LEFT", topParent, "LEFT");
	self.LowerGradient:SetPoint("RIGHT", topParent, "RIGHT");

end

function CreditsFrameMixin:SetSpeed(speed)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	CREDITS_SCROLL_RATE = speed;
	self:UpdateSpeedButtons();
end

function CreditsFrameMixin:SetSpeedButtonActive(button, active)
	if ( active ) then
		button:LockHighlight();
		button:GetHighlightTexture():SetAlpha(0.5);
	else
		button:UnlockHighlight();
		button:GetHighlightTexture():SetAlpha(1);
	end
end

function CreditsFrameMixin:UpdateSpeedButtons()
	local activeButton;
	if ( CREDITS_SCROLL_RATE == CREDITS_SCROLL_RATE_REWIND ) then
		activeButton = CreditsFrameRewindButton;
	elseif ( CREDITS_SCROLL_RATE == CREDITS_SCROLL_RATE_PAUSE ) then
		activeButton = CreditsFramePauseButton;
	elseif ( CREDITS_SCROLL_RATE == CREDITS_SCROLL_RATE_PLAY ) then
		activeButton = CreditsFramePlayButton;
	elseif ( CREDITS_SCROLL_RATE == CREDITS_SCROLL_RATE_FASTFORWARD ) then
		activeButton = CreditsFrameFastForwardButton;
	end

	self:SetSpeedButtonActive(CreditsFrameRewindButton, activeButton == CreditsFrameRewindButton);
	self:SetSpeedButtonActive(CreditsFramePauseButton, activeButton ==  CreditsFramePauseButton);
	self:SetSpeedButtonActive(CreditsFramePlayButton, activeButton == CreditsFramePlayButton);
	self:SetSpeedButtonActive(CreditsFrameFastForwardButton, activeButton == CreditsFrameFastForwardButton);
end

function CreditsFrameMixin:OnUpdate(elapsed)
	if ( not self.ScrollFrame:IsShown() ) then
		return;
	end

	self.ScrollFrame.scroll = self.ScrollFrame.scroll + (CREDITS_SCROLL_RATE * elapsed);
	self.ScrollFrame.scroll = max(self.ScrollFrame.scroll, 1);

	if ( self.ScrollFrame.scroll >= self.ScrollFrame.scrollMax ) then
		GlueParent_CloseSecondaryScreen();
		return;
	end

	self.ScrollFrame:SetVerticalScroll(self.ScrollFrame.scroll);
end

function CreditsFrameMixin:OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		if self.ExpansionList:IsShown() then
			self.ExpansionList:Hide();
		else
			GlueParent_CloseSecondaryScreen();
		end
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function CreditsFrameMixin:ToggleExpansionList()
	if not self.ExpansionList:IsShown() then
		self.ExpansionList:OpenExpansionList(self.expansion, self.maxExpansion);
	else
		self.ExpansionList:Hide();
	end
end

CreditsScrollFrameMixin = {}

function CreditsScrollFrameMixin:OnScrollRangeChanged()
	self:UpdateMax();
end

function CreditsScrollFrameMixin:UpdateMax()
	self.scrollMax = self:GetVerticalScrollRange() + 768;
end

CreditsExpansionListMixin = {}

function CreditsExpansionListMixin:OnOKClicked()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	CreditsFrame:Switch(self.expansion);
	self:Hide();
end

function CreditsExpansionListMixin:OnCancelClicked()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	self:Hide();
end

function CreditsExpansionListMixin:SetSelectedExpansion(expansion)
	for button in self.buttonPool:EnumerateActive() do
		button.Selection:SetShown(expansion == button:GetID());
	end
	self.expansion = expansion;
end

function CreditsExpansionListMixin:OpenExpansionList(selectedExpansion, maxExpansion)
	self.expansion = selectedExpansion;
	if not self.buttonPool then
		self.buttonPool = CreateFramePool("BUTTON", self, "CreditsFrameExpansionsButtonTemplate");
	end

	self.buttonPool:ReleaseAll();

	local prevButton = nil;
	local minWidth = 200;
	local maxWidth = minWidth;
	local buttonSpacing = 5;
	for i=0,maxExpansion do
		local button = self.buttonPool:Acquire();
		button:SetID(i);
		if i == 0 then
			button:SetPoint("TOP", self, "TOP", 0, -35);
			button:SetText(WORLD_OF_WARCRAFT);
		else
			button:SetPoint("TOP", prevButton, "BOTTOM", 0, -buttonSpacing);
			button:SetText(_G["EXPANSION_NAME" .. i]);
		end
		local width = button:GetTextWidth();
		maxWidth = math.max(width, maxWidth);
		button:SetWidth(width);
		button:Show();
		prevButton = button;
	end
	for button in self.buttonPool:EnumerateActive() do
		button:SetWidth(maxWidth);
	end

	local minOKCancelButtonWidth = 80;
	local buttonBorderWidth = 10;
	local buttonTextWidth = math.max(minOKCancelButtonWidth, math.max(self.OKButton:GetTextWidth(), self.CancelButton:GetTextWidth())) + buttonBorderWidth * 2;
	self.OKButton:SetWidth(buttonTextWidth);
	self.CancelButton:SetWidth(buttonTextWidth);

	local frameWidth = math.max(maxWidth, 2 * buttonTextWidth) + 60;

	self:SetWidth(frameWidth);
	self:SetHeight((maxExpansion + 1) * (prevButton:GetHeight() + buttonSpacing) + 100);

	self:SetSelectedExpansion(self.expansion);
	self:Show();
end