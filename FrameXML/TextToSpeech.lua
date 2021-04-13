-- Toggle button for the text to speech config window
TextToSpeechButtonMixin = {}

function TextToSpeechButtonMixin:OnLoad()
	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("CVAR_UPDATE");

	local alertSystem = ChatAlertFrame:AddAutoAnchoredSubSystem(self);
	ChatAlertFrame:SetSubSystemAnchorPriority(alertSystem, 0);

	self:UpdateVisibility();
end

function TextToSpeechButtonMixin:UpdateVisibility()
	if (self.cvarsLoaded and GetCVarBool("textToSpeech")) then
		if(not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TEXT_TO_SPEECH)) then
			local helpTipInfo = {
				text = TEXT_TO_SPEECH_TUTORIAL,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_TEXT_TO_SPEECH,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				offsetX = -2,
			};
			HelpTip:Show(self, helpTipInfo);
		end

		self:SetAlpha(1);
	else
		self:SetAlpha(0);
	end
end

function TextToSpeechButtonMixin:OnEvent(event, ...)
	local arg1 = ...;

	if ( event == "VARIABLES_LOADED" ) then
		self.cvarsLoaded = true;
	end

	if ( event == "VARIABLES_LOADED" or
		(event == "CVAR_UPDATE" and arg1 == "ENABLE_TEXT_TO_SPEECH") ) then
		TextToSpeechButton:UpdateVisibility();
	end
end

function TextToSpeechButtonMixin:OnClick(button)
	HelpTip:Hide(self, TEXT_TO_SPEECH_TUTORIAL);
	ToggleTextToSpeechFrame();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function TextToSpeechButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, TEXT_TO_SPEECH_CONFIG);
	GameTooltip:Show();
end

function TextToSpeechButtonMixin:OnLeave()
	GameTooltip:Hide();
end
