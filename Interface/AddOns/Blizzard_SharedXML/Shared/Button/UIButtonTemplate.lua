
UIButtonMixin = {}

function UIButtonMixin:InitButton()
	if self.buttonArtKit then
		self:SetButtonArtKit(self.buttonArtKit);
	end

	if self.disabledTooltip then
		self:SetMotionScriptsWhileDisabled(true);
	end
end

function UIButtonMixin:OnClick(...)
	PlaySound(self.onClickSoundKit or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	if self.onClickHandler then
		self.onClickHandler(self, ...);
	end
end

function UIButtonMixin:OnEnter()
	self:RunCustomTextFormatter();

	if self.onEnterHandler and self.onEnterHandler(self) then
		return;
	end

	local defaultTooltipAnchor = "ANCHOR_RIGHT";
	if self:IsEnabled() then
		if self.tooltipTitle or self.tooltipText then
			local tooltip = GetAppropriateTooltip();
			tooltip:SetOwner(self, self.tooltipAnchor or defaultTooltipAnchor, self.tooltipOffsetX, self.tooltipOffsetY);

			if self.tooltipTitle then
				GameTooltip_SetTitle(tooltip, self.tooltipTitle, self.tooltipTitleColor);
			end

			if self.tooltipText then
				local wrap = true;
				if self.tooltipDisableWrapText then
					wrap = false;
				end

				GameTooltip_AddColoredLine(tooltip, self.tooltipText, self.tooltipTextColor or NORMAL_FONT_COLOR, wrap);
			end

			tooltip:Show();
		end
	else
		if self.disabledTooltip then
			local tooltip = GetAppropriateTooltip();
			GameTooltip_ShowDisabledTooltip(tooltip, self, self.disabledTooltip, self.disabledTooltipAnchor or defaultTooltipAnchor, self.disabledTooltipOffsetX, self.disabledTooltipOffsetY);
		end
	end
end

function UIButtonMixin:OnLeave()
	self:RunCustomTextFormatter();

	local tooltip = GetAppropriateTooltip();
	if not tooltip then
		return;
	end
	tooltip:Hide();
end

function UIButtonMixin:SetButtonArtKit(buttonArtKit)
	self.buttonArtKit = buttonArtKit;

	self:SetNormalAtlas(buttonArtKit);
	self:SetPushedAtlas(buttonArtKit.."-Pressed");
	self:SetDisabledAtlas(buttonArtKit.."-Disabled");
	self:SetHighlightAtlas(buttonArtKit.."-Highlight");
end

function UIButtonMixin:SetOnClickHandler(onClickHandler, onClickSoundKit)
	self.onClickHandler = onClickHandler;
	self.onClickSoundKit = onClickSoundKit;
end

function UIButtonMixin:GetOnClickSoundKit()
	return self.onClickSoundKit;
end

function UIButtonMixin:SetCustomTextFormatter(customTextFormatter)
	if self.customTextFormatter then
		self:ClearCustomTextFormatter();
	end

	self.customTextFormatter = customTextFormatter;

	local function OverrideScriptForFormatter(scriptName, scriptFunction)
		local originalHandler = self:GetScript(scriptName);
		self["original"..scriptName.."Script"] = originalHandler;
		self:SetScript(scriptName, function(...)
			if originalHandler then
				originalHandler(...);
			end

			scriptFunction(...);
		end);
	end

	OverrideScriptForFormatter("OnEnable", self.RunCustomTextFormatter);
	OverrideScriptForFormatter("OnDisable", self.RunCustomTextFormatter);

	self:RunCustomTextFormatter();
end

function UIButtonMixin:ClearCustomTextFormatter()
	self.customTextFormatter = nil;

	local function RestoreOriginalScriptHandler(scriptName)
		local memberName = "original"..scriptName.."Script";
		local originalHandler = self[memberName];
		self[memberName] = nil;
		if originalHandler then
			self:SetScript(scriptName, originalHandler);
		end
	end

	RestoreOriginalScriptHandler("OnEnable");
	RestoreOriginalScriptHandler("OnDisable");
end

function UIButtonMixin:RunCustomTextFormatter()
	if self.customTextFormatter then
		local highlight = self:IsMouseMotionFocus();
		local enabled = self:IsEnabled();
		self.Text:SetText(self.customTextFormatter(self, enabled, highlight));
		self:SetWidth(self:GetTextWidth() + 20); -- Add some padding to the width so that the text doesn't get cut off.
	end
end

function UIButtonMixin:SetOnEnterHandler(onEnterHandler)
	self.onEnterHandler = onEnterHandler;
end

function UIButtonMixin:SetTooltipInfo(tooltipTitle, tooltipText)
	self.tooltipTitle = tooltipTitle;
	self.tooltipText = tooltipText;
end

function UIButtonMixin:SetTooltipAnchor(tooltipAnchor, tooltipOffsetX, tooltipOffsetY)
	self.tooltipAnchor = tooltipAnchor;
	self.tooltipOffsetX = tooltipOffsetX;
	self.tooltipOffsetY = tooltipOffsetY;
end

function UIButtonMixin:SetDisabledTooltip(disabledTooltip, disabledTooltipAnchor, disabledTooltipOffsetX, disabledTooltipOffsetY)
	self.disabledTooltip = disabledTooltip;
	self.disabledTooltipAnchor = disabledTooltipAnchor;
	self.disabledTooltipOffsetX = disabledTooltipOffsetX;
	self.disabledTooltipOffsetY = disabledTooltipOffsetY;
	self:SetMotionScriptsWhileDisabled(disabledTooltip ~= nil);
end
