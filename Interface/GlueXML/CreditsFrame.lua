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
	self:ResetPools();
end

function CreditsFrameMixin:ResetPools()
	if not self.normalPool then
		self.normalPool = CreateFontStringPool(self.ClipFrame, "ARTWORK", 0, "CreditsNormal");
	end
	if not self.header1Pool then
		self.header1Pool = CreateFontStringPool(self.ClipFrame, "ARTWORK", 0, "CreditsHeader1");
	end
	if not self.header2Pool then
		self.header2Pool = CreateFontStringPool(self.ClipFrame, "ARTWORK", 0, "CreditsHeader2");
	end

	self.normalPool:ReleaseAll();
	self.header1Pool:ReleaseAll();
	self.header2Pool:ReleaseAll();

	self.strings = {};
end

function CreditsFrameMixin:GetFontStringPool(type)
	if type == "H1" then
		return self.header1Pool;
	elseif type == "H2" then
		return self.header2Pool;
	else
		return self.normalPool;
	end
end

function CreditsFrameMixin:GetCreditsFontString(data)
	local fontString = self:GetFontStringPool(data.type):Acquire();
	fontString:SetText(data.text);
	fontString:SetWidth(self.creditsTextWidth);
	fontString:SetJustifyH(data.align);
	fontString:Show();
	return fontString;
end

function CreditsFrameMixin:ReleaseCreditsFontString(data, fontString)
	self:GetFontStringPool(data.type):Release(fontString);
end

function CreditsFrameMixin:JumpToCreditsIndex(position)
	self:ResetPools();

	local screenHeight = self:GetHeight();
	local left = self.ScrollFrame:GetLeft() - self:GetLeft();

	self.startIdx = Clamp(position, 1, #self.data);
	self.startPos = 0;
	self.pixelAlignedRemainder = 0;
	local startPos = self.startPos;
	for i = self.startIdx, #self.data do
		assert(not self.strings[i]);
		local fontString = self:GetCreditsFontString(self.data[i]);
		self.strings[i] = fontString;
		fontString:SetPoint("TOPLEFT", CreditsFrame, "TOPLEFT", left, startPos + fontString:GetSpacing());
		startPos = startPos - fontString:GetHeight() - fontString:GetSpacing();
		if startPos < -screenHeight then
			break;
		end
	end

	self.Slider:SetValue(self.startIdx);
end


function CreditsFrameMixin:Update()
	PlayCreditsMusic(SafeGetExpansionData(GLUE_CREDITS_SOUND_KITS, self.expansion));
	local expansionInfo = GetExpansionDisplayInfo(self.expansion);
	if expansionInfo then
		self.Logo:SetTexture(expansionInfo.logo);
	end

	self:SetSpeed(CREDITS_SCROLL_RATE_PLAY);

	self:UpdateArt();

	self.creditsTextWidth = self.ScrollFrame:GetWidth();

	-- Set Credits Text
	self.ScrollFrame.Text:SetText(GetCreditsText(self.expansion));
	self.data = self.ScrollFrame.Text:GetTextData();
	self.Slider:SetMinMaxValues(1, #self.data);
	self.ScrollFrame.Text:SetText("");

	self:JumpToCreditsIndex(1);
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
		self.KeyArt:SetScale((self:GetHeight() - 120) / info.height);
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
	local scrollIdx = self.scrollIdx;
	if scrollIdx then
		self.scrollIdx = nil;
		local startIdx = math.floor(scrollIdx);
		self:JumpToCreditsIndex(startIdx);
		return;
	end

	local screenHeight = self:GetHeight();
	local left = self.ScrollFrame:GetLeft() - self:GetLeft();

	if CREDITS_SCROLL_RATE ~= 0 then
		local offset = self.pixelAlignedRemainder + CREDITS_SCROLL_RATE * elapsed;
		local pixelAlignedOffset = PixelUtil.GetNearestPixelSize(offset, 1);
		self.pixelAlignedRemainder = offset - pixelAlignedOffset;
		self.startPos = self.startPos + pixelAlignedOffset;
	end

	if CREDITS_SCROLL_RATE < 0 then
		local startPos = self.startPos;
		local prevString = self.strings[self.startIdx];
		while (prevString:GetTop() - self:GetTop() < screenHeight and self.startIdx > 1) do
			self.startIdx = self.startIdx - 1;
			self.Slider:SetValue(self.startIdx);
			assert(not self.strings[self.startIdx]);
			local fontString = self:GetCreditsFontString(self.data[self.startIdx]);
			self.strings[self.startIdx] = fontString;
			self.startPos = self.startPos + fontString:GetHeight() + fontString:GetSpacing();
			fontString:SetPoint("TOPLEFT", CreditsFrame, "TOPLEFT", left, self.startPos - fontString:GetSpacing());
			prevString = fontString;
		end

		if (self.startIdx == 1 and self.startPos <= 0) then
			self.startPos = 0;
			CREDITS_SCROLL_RATE = 0;
			self:UpdateSpeedButtons();
			return;
		end
	end

	local startPos = self.startPos;
	local lastIdx;
	for i = self.startIdx, #self.data do
		local fontString = self.strings[i];
		if not fontString then
			fontString = self:GetCreditsFontString(self.data[i]);
			self.strings[i] = fontString;
		end
		if not fontString then
			break;
		end
		fontString:SetPoint("TOPLEFT", CreditsFrame, "TOPLEFT", left, startPos - fontString:GetSpacing());
		startPos = startPos - fontString:GetHeight() - fontString:GetSpacing();
		if fontString:GetBottom() - self:GetBottom() > screenHeight then
			self.startIdx = i + 1;
			self.Slider:SetValue(self.startIdx);
			self.startPos = self.startPos - fontString:GetHeight() - fontString:GetSpacing();
			self:ReleaseCreditsFontString(self.data[i], fontString);
			self.strings[i] = nil;
			if self.startIdx >= #self.data then
				GlueParent_CloseSecondaryScreen();
				return;
			end
		end
		if startPos < -screenHeight then
			lastIdx = i;
			break;
		end
	end
	if lastIdx then
		for i = lastIdx + 1, #self.data do
			if self.strings[i] then
				self:ReleaseCreditsFontString(self.data[i], self.strings[i]);
				self.strings[i] = nil;
			else
				break;
			end
		end
	end
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