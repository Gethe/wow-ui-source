HelpPlate = {};

local function ResetHelpPlateTile(_pool, tile)
	tile:Reset();
end

local currentHelpInfo = nil;
local forTutorial = false;
local tilePool = CreateFramePool("Frame", nil, "HelpPlateTile", ResetHelpPlateTile);

local function FinalizeHide()
	currentHelpInfo = nil;
	HelpPlateCanvas:Hide();
	HelpPlateTooltip:Hide();
end

MainHelpPlateButtonMixin = {};

function MainHelpPlateButtonMixin:OnEnter()
	self:ShowTooltip();
end

function MainHelpPlateButtonMixin:OnLeave()
	HelpPlateTooltip:Hide();
end

function MainHelpPlateButtonMixin:OnMouseDown()
	self.I:SetPoint("CENTER", 1, -1);
end

function MainHelpPlateButtonMixin:OnMouseUp()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self.I:SetPoint("CENTER", 0, 0);
end

function MainHelpPlateButtonMixin:OnHide()
	HelpPlateTooltip:Hide();
end

function MainHelpPlateButtonMixin:ShowTooltip()
	HelpPlateTooltip.LingerAndFade:Stop();
	HelpPlateTooltip:InitFromMainHelpPlateButton(self);
end

HelpPlateButtonMixin = {};

function HelpPlateButtonMixin:OnLoad()
	local slideAnimGroup = self:CreateAnimationGroup();
	self.slideAnimGroup = slideAnimGroup;

	local translationAnimation = self.slideAnimGroup:CreateAnimation("Translation");
	translationAnimation = self.slideAnimGroup:CreateAnimation("Translation");
	translationAnimation:SetSmoothing("IN");
	slideAnimGroup.translationAnimation = translationAnimation;

	local alphaAnimation = self.slideAnimGroup:CreateAnimation("Alpha");
	alphaAnimation:SetFromAlpha(1);
	alphaAnimation:SetToAlpha(0);
	alphaAnimation:SetSmoothing("IN");
	slideAnimGroup.alphaAnimation = alphaAnimation;
end

function HelpPlateButtonMixin:OnShow()
	local slideAnimGroup = self.slideAnimGroup;

	local translationAnimation = slideAnimGroup.translationAnimation;
	local point, relative, relPoint, x, y = self:GetPoint(1);
	translationAnimation:SetOffset(-1 * x, -1 * y);
	translationAnimation:SetDuration(0.5);

	slideAnimGroup.alphaAnimation:SetDuration(0.5);

	local reverse = true;
	slideAnimGroup:Play(reverse);
end

function HelpPlateButtonMixin:OnHide()
	if self.forTutorial then
		self.HelpIGlow:Hide();
		self.BgGlow:Hide();
		self.Pulse:Stop();
	end
	
	self.forTutorial = false;
end

function HelpPlateButtonMixin:HideTutorial()
	if self.forTutorial then
		self.HelpIGlow:Hide();
		self.BgGlow:Hide();
		self.Pulse:Stop();
	end
end

function HelpPlateButtonMixin:OnEnter()
	self:HideTutorial();
end

function HelpPlateButtonMixin:ConfigureForTutorial()
	self.HelpIGlow:Show();
	self.BgGlow:Show();
	self.Pulse:Play();

	self.forTutorial = true;
end

function HelpPlateButtonMixin:AnimateOut(onFinishedCallback)
	if self.slideAnimGroup:IsPlaying() then
		self.slideAnimGroup:Stop();
	end

	self.slideAnimGroup:SetScript("OnFinished", function(animGroup)
		animGroup:SetScript("OnFinished", nil);
		onFinishedCallback(self);
	end);

	self.slideAnimGroup.translationAnimation:SetDuration(0.3);
	self.slideAnimGroup.alphaAnimation:SetDuration(0.3);
	self.slideAnimGroup:Play();
end

function HelpPlateButtonMixin:Reset()
	self.slideAnimGroup:SetScript("OnFinished", nil);
	self.slideAnimGroup:Stop();
end

HelpPlateBoxMixin = {};

function HelpPlateBoxMixin:OnLoad()
	for index, texture in ipairs(self.Textures) do
		texture:SetVertexColor(1, 0.82, 0);
	end
end

HelpPlateTileMixin = {};

function HelpPlateTileMixin:OnEnter()
	self.Button:HideTutorial();

	self.Box.BG:Hide();
	self.BoxHighlight:Show();
end

function HelpPlateTileMixin:OnLeave()
	self.Box.BG:Show();
	self.BoxHighlight:Hide();
end

function HelpPlateTileMixin:Reset()
	self.Button:Reset();
	self:ClearAllPoints();
	self:Hide();
end

HelpPlateTooltipMixin = {};

function HelpPlateTooltipMixin:OnLoad()
	self.Text:SetSpacing(4);
	SetClampedTextureRotation(self.ArrowLeft, 270);
	SetClampedTextureRotation(self.ArrowRight, 90);
	SetClampedTextureRotation(self.ArrowGlowLeft, 270);
	SetClampedTextureRotation(self.ArrowGlowRight, 90);

	self.LingerAndFade:SetScript("OnFinished", function(animGroup, requested)
		self:Hide();
	end);
end

function HelpPlateTooltipMixin:OnHide()
	self.tutorialHelpInfo = nil;
end

function HelpPlateTooltipMixin:HideTextures()
	self.ArrowUp:Hide();
	self.ArrowGlowUp:Hide();
	self.ArrowDown:Hide();
	self.ArrowGlowDown:Hide();
	self.ArrowLeft:Hide();
	self.ArrowGlowLeft:Hide();
	self.ArrowRight:Hide();
	self.ArrowGlowRight:Hide();
end

function HelpPlateTooltipMixin:Init(anchorToButton, tooltipText, tooltipDir)
	self:SetParent(GetAppropriateTopLevelParent());
	self:SetFrameStrata("FULLSCREEN_DIALOG");
	self:SetFrameLevel(2);

	self:HideTextures();
	self:ClearAllPoints();

	if tooltipDir == "UP" then
		self.ArrowUp:Show();
		self.ArrowGlowUp:Show();
		self:SetPoint("BOTTOM", anchorToButton, "TOP", 0, 10);
	elseif tooltipDir == "DOWN" then
		self.ArrowDown:Show();
		self.ArrowGlowDown:Show();
		self:SetPoint("TOP", anchorToButton, "BOTTOM", 0, -10);
	elseif tooltipDir == "LEFT" then
		self.ArrowLeft:Show();
		self.ArrowGlowLeft:Show();
		self:SetPoint("RIGHT", anchorToButton, "LEFT", -10, 0);
	elseif tooltipDir == "RIGHT" then
		self.ArrowRight:Show();
		self.ArrowGlowRight:Show();
		self:SetPoint("LEFT", anchorToButton, "RIGHT", 10, 0);
	end

	self.Text:SetText(tooltipText);
	self:SetHeight(self.Text:GetHeight() + 30);
	self:Show();
end

function HelpPlateTooltipMixin:InitFromMainHelpPlateButton(helpPlateButton)
	local tooltipText = helpPlateButton.mainHelpPlateButtonTooltipText or MAIN_HELP_BUTTON_TOOLTIP;
	self:Init(helpPlateButton, tooltipText, "RIGHT");
end

function HelpPlate.Show(helpInfo, parent, mainHelpButton)
	if currentHelpInfo then
		local fromUserInput = false;
		HelpPlate.Hide(fromUserInput);
	end

	currentHelpInfo = helpInfo;

	local viewedTiles = {};

	for index, info in ipairs(helpInfo) do
		local tile = tilePool:Acquire();
		tile:SetParent(HelpPlateCanvas);
		tile:ClearAllPoints();

		tile:SetScript("OnEnter", function()
			HelpPlateTileMixin.OnEnter(tile);

			local direction = info.ToolTipDir or "RIGHT";
			HelpPlateTooltip:Init(tile.Button, info.ToolTipText, direction);
		end);

		tile:SetScript("OnLeave", function()
			HelpPlateTileMixin.OnLeave(tile);

			HelpPlateTooltip:Hide();

			-- remind the player to use the main button to toggle the help plate
			-- but only if this is the first time they have opened the UI and are
			-- going through the initial tutorial
			viewedTiles[tile] = true;

			if forTutorial then
				for poolTile in tilePool:EnumerateActive() do
					if not viewedTiles[poolTile] then
						return;
					end
				end

				mainHelpButton:ShowTooltip();
			end
		end);

		local highlightInfo = info.HighLightBox;

		tile:ClearAllPoints();
		tile:SetSize(highlightInfo.width, highlightInfo.height);
		tile:SetPoint("TOPLEFT", highlightInfo.x, highlightInfo.y);
		tile:Show();
		
		local button = tile.Button;
		local buttonPos = info.ButtonPos;
		button:SetPoint("TOPLEFT", HelpPlateCanvas, "TOPLEFT", buttonPos.x, buttonPos.y);
		button:Show();
		
		if forTutorial then
			button:ConfigureForTutorial();
		end
	end

	HelpPlateCanvas:SetParent(GetAppropriateTopLevelParent());
	HelpPlateCanvas:SetFrameStrata("DIALOG");

	local framePos = helpInfo.FramePos;
	HelpPlateCanvas:SetPoint("TOPLEFT", parent, "TOPLEFT", framePos.x, framePos.y);

	local frameSize = helpInfo.FrameSize;
	HelpPlateCanvas:SetSize(frameSize.width, frameSize.height);
	HelpPlateCanvas:Show();
end

function HelpPlate.Hide(fromUserInput)
	if not currentHelpInfo then
		return;
	end

	forTutorial = false;

	if fromUserInput then
		for poolTile in tilePool:EnumerateActive() do
			poolTile.Button:AnimateOut(function(button)
				tilePool:Release(poolTile);

				if tilePool:GetNumActive() == 0 then
					FinalizeHide();
				end
			end);
		end
	else
		tilePool:ReleaseAll();

		FinalizeHide();
	end
end

function HelpPlate.GetEffectiveScale()
	-- Re-parent the canvas prior to querying scale to support cases where this
	-- function is being used to dynamically calculate help plate extents prior
	-- to showing, such as in the SpellBook. This resolves issues where help
	-- plates may appear at incorrect sizes on the very first use in a session.
	HelpPlateCanvas:SetParent(GetAppropriateTopLevelParent());
	return HelpPlateCanvas:GetEffectiveScale();
end

function HelpPlate.HideTooltip()
	HelpPlateTooltip:Hide();
end

function HelpPlate.IsShowingHelpInfo(helpInfo)
	return currentHelpInfo == helpInfo;
end

function HelpPlate.IsShowingTutorialTooltip(helpInfo)
	return HelpPlateTooltip.tutorialHelpInfo == helpInfo and HelpPlateTooltip:IsVisible();
end

function HelpPlate.ShowTutorialTooltip(helpInfo, mainHelpButton)
	if Kiosk.IsEnabled() then
		return;
	end

	forTutorial = true;

	HelpPlateTooltip:InitFromMainHelpPlateButton(mainHelpButton);
	HelpPlateTooltip.LingerAndFade:Play();
	HelpPlateTooltip.tutorialHelpInfo = helpInfo;
end
