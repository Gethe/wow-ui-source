GlueDialogMixin = {};

local function GetContainerRegions(dialog)
	local button1 = dialog.Container.Button1;
	local button2 = dialog.Container.Button2;
	local button3 = dialog.Container.Button3;
	local alertIcon = dialog.Container.AlertIcon;
	local text = dialog.Container.Text;
	local htmlText = dialog.Container.HtmlText;
	local spinner = dialog.Container.Spinner;
	return button1, button2, button3, alertIcon, text, htmlText, spinner;
end

do
	local function SetupButton(dialog, button)
		button:SetOwningDialog(self);
		button:SetScript("OnClick", function(self, ...)
			StaticPopup_OnClick(dialog, self:GetID());
		end);
	end
	
	function GlueDialogMixin:OnLoad()
		local container = self.Container;
		container.BG.Top:SetAtlas(GlueDialogBackgroundTop, TextureKitConstants.UseAtlasSize);
		-- Bottom texture is assigned in SetBackground depending on dialogInfo .darken value.
		container.BG.Bottom:SetPoint("TOPLEFT", 8, -9);
		container.BG.Bottom:SetPoint("BOTTOMRIGHT", -8, 9);
		
		container.Text.origWidth = self.Container.Text:GetWidth();
		container.HtmlText.origWidth = self.Container.HtmlText:GetWidth();
		container.origWidth = self.Container:GetWidth();
		container.alertWidth = 600;
	
		SetupButton(self, container.Button1);
		SetupButton(self, container.Button2);
		SetupButton(self, container.Button3);

		StaticPopup_AddDialog(self);
	end
end

function GlueDialogMixin:Init(which, text_arg1, text_arg2, data, insertedFrame)
	local dialogInfo = StaticPopupDialogs[which];
	local button1, button2, button3, alertIcon, text, htmlText, spinner = GetContainerRegions(self);

	self:SetBackground(dialogInfo.darken);

	self.Container:ClearAllPoints();
	if dialogInfo.anchorPoint then
		local x, y = dialogInfo.anchorOffsetX or 0, dialogInfo.anchorOffsetY or 0;
		self.Container:SetPoint(dialogInfo.anchorPoint, x, y);
	else
		self.Container:SetPoint("CENTER");
	end

	self.data = data;

	-- Set the text of the dialog
	self:ClearHtmlText();

	local useText;
	if dialogInfo.html then
		useText = htmlText;
		self:SetHtmlText(text_arg1 or dialogInfo.text);
		text:Hide();
	else
		useText = text;
		self:SetText(text_arg1 or dialogInfo.text);
		htmlText:Hide();
	end

	useText:Show();
	useText:ClearAllPoints();
	useText:SetPoint("TOP", 0, -23);

	-- Set the buttons of the dialog
	if dialogInfo.button3 then
		button1:ClearAllPoints();
		button2:ClearAllPoints();
		button3:ClearAllPoints();

		if dialogInfo.displayVertical then
			button3:SetPoint("BOTTOM", self.Container, "BOTTOM", 0, 18);
			button2:SetPoint("BOTTOM", button3, "TOP", 0, 10);
			button1:SetPoint("BOTTOM", button2, "TOP", 0, 10);
		else
			button1:SetPoint("BOTTOMLEFT", self.Container, "BOTTOMLEFT", 75, 18);
			button2:SetPoint("LEFT", button1, "RIGHT", 15, 0);
			button3:SetPoint("LEFT", button2, "RIGHT", 15, 0);
		end

		button1:SetText(dialogInfo.button1);
		button1:Show();
		button2:SetText(dialogInfo.button2);
		button2:Show();
		button3:SetText(dialogInfo.button3);
		button3:Show();
	elseif dialogInfo.button2 then
		button1:ClearAllPoints();
		button2:ClearAllPoints();

		if dialogInfo.displayVertical then
			button2:SetPoint("BOTTOM", self.Container, "BOTTOM", 0, 18);
			button1:SetPoint("BOTTOM", button2, "TOP", 0, 10);
		else
			button1:SetPoint("BOTTOMRIGHT", self.Container, "BOTTOM", -6, 18);
			button2:SetPoint("LEFT", button1, "RIGHT", 15, 0);
		end

		button1:SetText(dialogInfo.button1);
		button1:Show();
		button2:SetText(dialogInfo.button2);
		button2:Show();
		button3:Hide();
	elseif dialogInfo.button1 then
		button1:ClearAllPoints();
		button1:SetPoint("BOTTOM", self.Container, "BOTTOM", 0, 18);
		button1:SetText(dialogInfo.button1);
		button1:Show();
		button2:Hide();
		button3:Hide();
	else
		button1:Hide();
		button2:Hide();
		button3:Hide();
	end

	button1:UpdateWidth();
	button2:UpdateWidth();
	button3:UpdateWidth();

	-- Show or hide the alert icon
	if dialogInfo.showAlert then
		self.Container:SetDesiredWidth(self.Container.alertWidth);
		alertIcon:Show();
	else
		self.Container:SetDesiredWidth(self.Container.origWidth);
		alertIcon:Hide();
	end
	alertIcon:ClearAllPoints();
	if dialogInfo.alertTopCenterAlign == 1 then
		alertIcon:SetPoint("TOP", 0, -31);
		useText:ClearAllPoints();
		useText:SetPoint("TOP", alertIcon, "BOTTOM", 0, -19);
	else
		alertIcon:SetPoint("LEFT", 17, 0);
	end
	useText:SetDesiredWidth(useText.origWidth);

	-- Editbox setup
	if dialogInfo.hasEditBox then
		self.EditBox:Show();
		self.EditBox.Instructions:SetText(dialogInfo.editBoxInstructions or "");

		if dialogInfo.maxLetters then
			self.EditBox:SetMaxLetters(dialogInfo.maxLetters);
		end
		self.EditBox:SetText("");
		if dialogInfo.editBoxWidth then
			self.EditBox:SetDesiredWidth(dialogInfo.editBoxWidth);
		else
			self.EditBox:SetDesiredWidth(130);
		end

		self.EditBox:ClearAllPoints();
		if dialogInfo.editBoxYMargin then
			self.EditBox:SetPoint("TOP", text, "BOTTOM", 0, -dialogInfo.editBoxYMargin);
		else
			self.EditBox:SetPoint("CENTER");
		end
	else
		self.EditBox:Hide();
	end

	-- Spinner setup
	if dialogInfo.spinner then
		spinner:Show();
		spinner:ClearAllPoints();
		if dialogInfo.button1 or dialogInfo.button2 or dialogInfo.button3 then
			spinner:SetPoint("BOTTOM", 0, 54);
		else
			spinner:SetPoint("BOTTOM", 0, 16);
		end
	else
		spinner:Hide();
	end
end

function GlueDialogMixin:SetBackground(useDark)
	local BG = self.Container.BG;
	if useDark then
		BG.Bottom:SetAtlas("UI-DialogBox-Background-Dark", TextureKitConstants.UseAtlasSize);
	else
		BG.Bottom:SetAtlas("UI-Frame-DialogBox-BackgroundTile", TextureKitConstants.UseAtlasSize);
	end
end

function GlueDialogMixin:GetEditBox()
	return self.EditBox;
end

function GlueDialogMixin:GetButton1()
	return self.Container.Button1;
end

function GlueDialogMixin:GetButton2()
	return self.Container.Button2;
end

function GlueDialogMixin:GetButton3()
	return self.Container.Button3;
end

function GlueDialogMixin:GetTextFontString()
	return self.Container.Text;
end

function GlueDialogMixin:GetButton(index)
	if index == 1 then
		return self:GetButton1();
	elseif index == 2 then
		return self:GetButton2();
	elseif index == 3 then
		return self:GetButton3();
	end
	return nil;
end

function GlueDialogMixin:Resize(which)
	local dialogInfo = self.dialogInfo;
	local button1, button2, button3, alertIcon, text, htmlText, spinner = GetContainerRegions(self);

	-- Get the width of the text to aid in determining the width of the dialog
	local textWidth = 0;
	if dialogInfo.html then
		textWidth = select(3, htmlText:GetBoundsRect());
	else
		textWidth = text:GetWidth();
	end

	-- size the width first
	if dialogInfo.displayVertical then
		local borderPadding = 32;
		local backgroundWidth = math.max(button1:GetWidth(), textWidth);
		self.Container:SetDesiredWidth(backgroundWidth + borderPadding);
	elseif dialogInfo.button3 then
		local displayWidth = 75 + button1:GetWidth() + 15 + button2:GetWidth() + 15 + button3:GetWidth() + 75;
		self.Container:SetDesiredWidth(displayWidth);
		text:SetDesiredWidth(displayWidth - 40);
	end

	-- Get the height of the string
	local textHeight, _;
	if dialogInfo.html then
		_,_,_,textHeight = htmlText:GetBoundsRect();
	else
		textHeight = text:GetHeight();
	end

	-- now size the dialog box height
	local displayHeight = 16 + textHeight;
	if dialogInfo.displayVertical then
		if dialogInfo.button1 then
			displayHeight = displayHeight + 25 + button1:GetHeight() + 25;
			if dialogInfo.button2 then
				displayHeight = displayHeight + 10 + button2:GetHeight();
				if dialogInfo.button3 then
					displayHeight = displayHeight + 10 + button3:GetHeight();
				end
			end
		end

		if dialogInfo.spinner then
			displayHeight = displayHeight + spinner:GetHeight();
		end
	else
		if dialogInfo.button1 then
			displayHeight = displayHeight + 13 + button1:GetHeight() + 25;
		else
			displayHeight = displayHeight + 25;
		end

		if dialogInfo.hasEditBox then
			displayHeight = displayHeight + 13 + self.EditBox:GetHeight();
			if dialogInfo.editBoxYMargin then
				displayHeight = displayHeight + dialogInfo.editBoxYMargin;
			end
			if dialogInfo.editBoxInstructions then
				displayHeight = displayHeight + 3 + self.EditBox.Instructions:GetHeight();
			end
		end

		if dialogInfo.spinner then
			displayHeight = displayHeight + spinner:GetHeight();
		end
	end
	if dialogInfo.alertTopCenterAlign == 1 then
		displayHeight = displayHeight + alertIcon:GetHeight() + 36;
	end

	self.Container:SetHeight(math.floor(displayHeight + 0.5));

	local boundsLeft, boundsBottom, boundsWidth, boundsHeight = self.Container:GetBoundsRect();
	local currentContainerWidth, currentContainerHeight = self.Container:GetSize();
	local containerWidth = math.max(currentContainerWidth, boundsWidth);
	local containerHeight = math.max(currentContainerHeight, boundsHeight);
	self.Container:SetSize(containerWidth, containerHeight);
end

function GlueDialogMixin:SetText(text)
	self.Container.Text:SetText(text);
end

function GlueDialogMixin:SetFormattedText(...)
	self.Container.Text:SetFormattedText(...);
end

function GlueDialogMixin:ClearHtmlText()
	self.Container.HtmlText.text = nil;
end

function GlueDialogMixin:SetHtmlText(text)
	self.Container.HtmlText:SetText(text);
	self.Container.HtmlText.text = text;
end

function GlueDialogMixin:GetText(text)
	return self.Container.Text:GetText();
end

function GlueDialogMixin:GetHtmlText(text)
	return self.Container.HtmlText.text;
end

function GlueDialogMixin:OnUpdate(elapsed)
	StaticPopup_OnUpdate(self, elapsed);
end

function GlueDialogMixin:OnShow()
	StaticPopup_OnShow(self);
end

function GlueDialogMixin:OnHide()
	StaticPopup_OnHide(self);
end

function GlueDialogMixin:OnHyperlinkClick(...)
	StaticPopup_OnHyperlinkClick(self, ...);
end

function GlueDialogMixin:OnHyperlinkEnter(...)
	StaticPopup_OnHyperlinkEnter(self, ...);
end

function GlueDialogMixin:OnHyperlinkLeave(...)
	StaticPopup_OnHyperlinkLeave(self, ...);
end
