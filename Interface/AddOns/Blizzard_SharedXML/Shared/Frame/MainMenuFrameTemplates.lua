
MainMenuFrameMixin = {};

local function HideAndClearAnchorsAndLayoutIndex(framePool, frame)
	Pool_HideAndClearAnchors(framePool, frame);
	frame.layoutIndex = nil;
end

function MainMenuFrameMixin:OnLoad()
	if self.dialogHeaderFont then
		self.Header:SetHeaderFont(self.dialogHeaderFont);
	end

	self.buttonPool = CreateFramePool("BUTTON", self, self.buttonTemplate, HideAndClearAnchorsAndLayoutIndex);
	self:Reset();
end

function MainMenuFrameMixin:Reset()
	self.buttonPool:ReleaseAll();
	self.sectionSpacing = nil;
	self.nextLayoutIndex = 1;
end

function MainMenuFrameMixin:AddButton(text, callback, isDisabled, disabledText)
	local newButton = self.buttonPool:Acquire();

	newButton.layoutIndex = self.nextLayoutIndex;
	self.nextLayoutIndex = self.nextLayoutIndex + 1;
	newButton.topPadding = self.sectionSpacing;
	self.sectionSpacing = nil;

	newButton:SetText(text);
	newButton:SetScript("OnClick", callback);

	newButton:SetMotionScriptsWhileDisabled(true);
	newButton:SetEnabled(not isDisabled);
	if isDisabled and disabledText then
		newButton:SetScript("OnEnter", function()
			local tooltip = GetAppropriateTooltip();
			tooltip:SetOwner(newButton, "ANCHOR_RIGHT");
			tooltip:SetText(text);
			GameTooltip_AddErrorLine(tooltip, disabledText);
			tooltip:Show();
		end);

		newButton:SetScript("OnLeave", function()
			GetAppropriateTooltip():Hide();
		end);
	else
		newButton:SetScript("OnEnter", nil);
		newButton:SetScript("OnLeave", nil);
	end

	newButton:Show();

	self:MarkDirty();

	return newButton;
end

function MainMenuFrameMixin:AddSection(customSpacing)
	self.sectionSpacing = customSpacing or 20;
end

function MainMenuFrameMixin:AddCloseButton(customText, customSpacing)
	self:AddSection(customSpacing);
	self:AddButton(customText or CLOSE, function()
		PlaySound(SOUNDKIT.IG_MAINMENU_CONTINUE);
		self:CloseMenu();
	end);
end

function MainMenuFrameMixin:CloseMenu()
	self:Hide();
end
