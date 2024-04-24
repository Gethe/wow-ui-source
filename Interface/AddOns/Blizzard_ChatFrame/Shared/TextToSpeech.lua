SpeechToTextMixin = {};

function SpeechToTextMixin:OnLoad()
	SettingsCheckBoxControlMixin.OnLoad(self);

	self.SubTextContainer:SetPoint("TOPLEFT", self.CheckBox, "TOPRIGHT", 0, 0);
	self.SubTextContainer.SubText:ClearAllPoints();
	self.SubTextContainer.SubText:SetPoint("LEFT", self.CheckBox, "RIGHT", 8, 0);
end

TextToSpeechButtonMixin = {};

function TextToSpeechButtonFrame_OnLoad(self)
	local alertSystem = ChatAlertFrame:AddAutoAnchoredSubSystem(self);
	ChatAlertFrame:SetSubSystemAnchorPriority(alertSystem, 0);
end

function TextToSpeechButtonMixin:OnLoad()
	self:RegisterStateUpdateEvent("VARIABLES_LOADED");
	self:RegisterStateUpdateEvent("CVAR_UPDATE");
	self:AddStateAtlasFallback("chatframe-button-icon-TTS");
	self:SetAccessorFunction(function() return true; end);
	self:SetMutatorFunction(self.OnClick);
	self:SetVisibilityQueryFunction(self.IsTextToSpeechEnabled);
	VoiceToggleButtonMixin.OnLoad(self);

	self:UpdateVisibleState();
end

function TextToSpeechButtonMixin:IsTextToSpeechEnabled()
	return GetCVarBool("textToSpeech");
end

function TextToSpeechButtonMixin:ShowHint()
	if (self.cvarsLoaded and self:IsTextToSpeechEnabled() and HelpTip) then
		if(not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TEXT_TO_SPEECH)) then
			local helpTipInfo = {
				text = TEXT_TO_SPEECH_TUTORIAL,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_TEXT_TO_SPEECH,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				offsetX = -2,
				system = "Chat",
				systemPriority = 20,
			};
			HelpTip:Show(self, helpTipInfo);
		end
	end
end

function TextToSpeechButtonMixin:OnEvent(event, ...)
	PropertyBindingMixin.OnEvent(self, event, ...);

	local arg1 = ...;

	if ( event == "VARIABLES_LOADED" ) then
		self.cvarsLoaded = true;
	end

	if ( event == "VARIABLES_LOADED" or
		(event == "CVAR_UPDATE" and (arg1 == "ENABLE_TEXT_TO_SPEECH" or arg1 == "speechToText")) ) then
		TextToSpeechButton:ShowHint();
	end
end

function TextToSpeechButtonMixin:OnClick(button)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TEXT_TO_SPEECH, true);
	if(HelpTip) then 
		HelpTip:Hide(self, TEXT_TO_SPEECH_TUTORIAL);
	end
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
