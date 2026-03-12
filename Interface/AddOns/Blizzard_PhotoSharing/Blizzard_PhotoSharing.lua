PHOTO_SHARING_TAB_LIST = {};
PHOTO_SHARING_TAB_LIST[1] = "PhotoSharingTitleEditBox";
PHOTO_SHARING_TAB_LIST[2] = "PhotoSharingDescriptionEditBox";

PhotoSharingMixin = {};

function PhotoSharingMixin:ResetEditBoxes()
	self.TitleFrame.PhotoSharingTitleEditBox:SetText("");
	self.TitleFrame.PhotoSharingTitleEditBox.TitleText:Show();

	self.DescriptionFrame.PhotoSharingDescriptionEditBoxContainer.PhotoSharingDescriptionEditBox:SetText(" " .. PHOTO_SHARING_PREPOP_DESCRIPTION);
	self.DescriptionFrame.PhotoSharingDescriptionEditBoxContainer.PhotoSharingDescriptionEditBox:SetCursorPosition(0);
	self.DescriptionFrame.PhotoSharingDescriptionEditBoxContainer.PhotoSharingDescriptionEditBox:Hide();
	self.DescriptionFrame.DescriptionText:Show();
end

function PhotoSharingMixin:UpdatePublishButton(showNotification)
	local notification;
	if C_PhotoSharing.IsAuthorized() then
		self.ErrorTextFrame.ErrorText:Hide();
		self.PublishButton:SetText(PHOTO_SHARING_PREVIEW_PUBLISH);
		notification = PHOTO_SHARING_SIGN_IN_NOTIFICATION;
	else
		self.ErrorTextFrame.ErrorText:Show();
		self.PublishButton:SetText(PHOTO_SHARING_SIGN_IN);
		notification = PHOTO_SHARING_DISCONNECT_NOTIFICATION;
	end

	if showNotification then
		UIErrorsFrame:AddMessage(notification, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
	end
end

function PhotoSharingMixin:OnLoad()
	self:RegisterEvent("PHOTO_SHARING_SCREENSHOT_READY");
	self:RegisterEvent("PHOTO_SHARING_AUTHORIZATION_UPDATED");
	self:RegisterEvent("PHOTO_SHARING_PHOTO_UPLOAD_STATUS");

	self.HeaderTextFrame.HeaderText:SetFormattedText(PHOTO_SHARING_PREVIEW_HEADER, PHOTO_SHARING_PAGE_NAME_SHORT)

	self:UpdatePublishButton();
end

function PhotoSharingMixin:OnShow()
	PlaySound(SOUNDKIT.PHOTO_SHARING_PREVIEW_OPEN);
end

function PhotoSharingMixin:OnHide(noSound)
	-- We hide the preview if the player takes another snapshot while the preview is open, lets
	-- not play the frame close sound in that situation, because it mixes poorly with the shutter sound.
	if not noSound then
		PlaySound(SOUNDKIT.PHOTO_SHARING_PREVIEW_CLOSE);
	end

	self:ResetEditBoxes();
end

function PhotoSharingMixin:OnEvent(event, ...)
	if event == "PHOTO_SHARING_SCREENSHOT_READY" then
		local noSound = true
		self:Hide(noSound); -- If the player presses take photo while the preview is open lets hide it during the shutter
		self:ResetEditBoxes();

		local FIXED_PREVIEW_HEIGHT = 450;
		local SHUTTER_DELAY = .80; -- seconds

		self.ScreenshotContainer.ScreenshotPreview:SetHeight(FIXED_PREVIEW_HEIGHT);
		self.ScreenshotContainer.ScreenshotPreview:SetWidth(FIXED_PREVIEW_HEIGHT * C_PhotoSharing.GetCropRatio());

		C_PhotoSharing.SetScreenshotPreviewTexture(self.ScreenshotContainer.ScreenshotPreview);

		-- Let the shutter animation mostly finish before showing the UI
		C_Timer.NewTimer(SHUTTER_DELAY, function()
			self:Show();
		end);
	elseif event == "PHOTO_SHARING_AUTHORIZATION_UPDATED" then
		local showNotification = ...;
		self:UpdatePublishButton(showNotification);
	elseif event == "PHOTO_SHARING_PHOTO_UPLOAD_STATUS" then
		local status = ...;
		if status == Enum.PhotoSharingUploadStatus.Success then
			UIErrorsFrame:AddMessage(PHOTO_SHARING_PUBLISHED, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		elseif status == Enum.PhotoSharingUploadStatus.CreatePostTooManyRequests then
			UIErrorsFrame:AddMessage(PHOTO_SHARING_PUBLISHED_ERROR_MAX_POSTS, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		elseif status == Enum.PhotoSharingUploadStatus.Disabled then
			UIErrorsFrame:AddMessage(PHOTO_SHARING_UNAVAILABLE, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		else
			UIErrorsFrame:AddMessage(PHOTO_SHARING_PUBLISHED_ERROR, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		end
	end
end

PhotoSharingSubmitButtonMixin = {};

function PhotoSharingSubmitButtonMixin:OnClick()
	if C_PhotoSharing.IsAuthorized() then
		local descriptionText = self:GetParent().DescriptionFrame.PhotoSharingDescriptionEditBoxContainer.PhotoSharingDescriptionEditBox:GetText();
		local titleText = self:GetParent().TitleFrame.PhotoSharingTitleEditBox:GetText();
		C_PhotoSharing.UploadPhotoToService(titleText, descriptionText);
		self:GetParent():Hide();
	else
		C_PhotoSharing.BeginAuthorizationFlow();
	end
end

PhotoSharingCancelButtonMixin = {};

function PhotoSharingCancelButtonMixin:OnClick()
	self:GetParent():Hide();
end
