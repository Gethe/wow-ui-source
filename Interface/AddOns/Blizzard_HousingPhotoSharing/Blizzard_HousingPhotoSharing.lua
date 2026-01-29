PHOTO_SHARING_TAB_LIST = {};
PHOTO_SHARING_TAB_LIST[1] = "PhotoSharingTitleEditBox";
PHOTO_SHARING_TAB_LIST[2] = "PhotoSharingDescriptionEditBox";

HousingPhotoSharingMixin = {};

function HousingPhotoSharingMixin:ResetEditBoxes()
	self.TitleFrame.PhotoSharingTitleEditBox:SetText("");
	self.TitleFrame.PhotoSharingTitleEditBox.TitleText:Show();

	self.DescriptionFrame.PhotoSharingDescriptionEditBox:SetText("");
	self.DescriptionFrame.PhotoSharingDescriptionEditBox.DescriptionText:Show();
end

function HousingPhotoSharingMixin:UpdatePublishButton()
	if C_HousingPhotoSharing.IsAuthorized() then
		self.ErrorTextFrame.ErrorText:Hide();
		self.PublishButton:SetText(PHOTO_SHARING_PREVIEW_PUBLISH);
		UIErrorsFrame:AddMessage(PHOTO_SHARING_SIGN_IN_NOTIFICATION, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
	else
		self.ErrorTextFrame.ErrorText:Show();
		self.PublishButton:SetText(PHOTO_SHARING_SIGN_IN);
		UIErrorsFrame:AddMessage(PHOTO_SHARING_DISCONNECT_NOTIFICATION, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
	end
end

function HousingPhotoSharingMixin:OnLoad()
	self:RegisterEvent("PHOTO_SHARING_SCREENSHOT_READY");
	self:RegisterEvent("PHOTO_SHARING_AUTHORIZATION_UPDATED");
	self:RegisterEvent("PHOTO_SHARING_PHOTO_UPLOAD_STATUS");

	self.HeaderTextFrame.HeaderText:SetFormattedText(PHOTO_SHARING_PREVIEW_HEADER, PHOTO_SHARING_PAGE_NAME_SHORT)

	self:UpdatePublishButton();
end

function HousingPhotoSharingMixin:OnShow()
	PlaySound(SOUNDKIT.PHOTO_SHARING_PREVIEW_OPEN);
end

function HousingPhotoSharingMixin:OnHide(noSound)
	-- We hide the preview if the player takes another snapshot while the preview is open, lets
	-- not play the frame close sound in that situation, because it mixes poorly with the shutter sound.
	if not noSound then
		PlaySound(SOUNDKIT.PHOTO_SHARING_PREVIEW_CLOSE);
	end

	self:ResetEditBoxes();
end

function HousingPhotoSharingMixin:OnEvent(event, ...)
	if event == "PHOTO_SHARING_SCREENSHOT_READY" then
		local noSound = true
		self:Hide(noSound); -- If the player presses take photo while the preview is open lets hide it during the shutter
		self:ResetEditBoxes();

		local FIXED_PREVIEW_HEIGHT = 450;
		local SHUTTER_DELAY = .80; -- seconds

		self.ScreenshotContainer.ScreenshotPreview:SetHeight(FIXED_PREVIEW_HEIGHT);
		self.ScreenshotContainer.ScreenshotPreview:SetWidth(FIXED_PREVIEW_HEIGHT * C_HousingPhotoSharing.GetCropRatio());

		C_HousingPhotoSharing.SetScreenshotPreviewTexture(self.ScreenshotContainer.ScreenshotPreview);

		-- Let the shutter animation mostly finish before showing the UI
		C_Timer.NewTimer(SHUTTER_DELAY, function()
			self:Show();
		end);
	elseif event == "PHOTO_SHARING_AUTHORIZATION_UPDATED" then
		self:UpdatePublishButton();
	elseif event == "PHOTO_SHARING_PHOTO_UPLOAD_STATUS" then
		local status = ...;
		if status == Enum.PhotoSharingUploadStatus.Success then
			UIErrorsFrame:AddMessage(PHOTO_SHARING_PUBLISHED, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		elseif status == Enum.PhotoSharingUploadStatus.CreatePinTooManyRequests then
			UIErrorsFrame:AddMessage(PHOTO_SHARING_PUBLISHED_ERROR_MAX_POSTS, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		else
			UIErrorsFrame:AddMessage(PHOTO_SHARING_PUBLISHED_ERROR, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		end
	end
end

HousingPhotoSharingSubmitButtonMixin = {};

function HousingPhotoSharingSubmitButtonMixin:OnClick()
	if C_HousingPhotoSharing.IsAuthorized() then
		local descriptionText = self:GetParent().DescriptionFrame.PhotoSharingDescriptionEditBox:GetText();
		local titleText = self:GetParent().TitleFrame.PhotoSharingTitleEditBox:GetText();

		if descriptionText == "" then
			descriptionText = PHOTO_SHARING_PREPOP_DESCRIPTION;
		end

		C_HousingPhotoSharing.UploadPhotoToService(titleText, descriptionText);
		self:GetParent():Hide();
	else
		C_HousingPhotoSharing.BeginAuthorizationFlow();
	end
end

HousingPhotoSharingCancelButtonMixin = {};

function HousingPhotoSharingCancelButtonMixin:OnClick()
	self:GetParent():Hide();
end
