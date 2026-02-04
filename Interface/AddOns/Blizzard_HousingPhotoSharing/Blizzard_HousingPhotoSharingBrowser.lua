HousingPhotoSharingBrowserMixin = {}

function HousingPhotoSharingBrowserMixin:SetInitialLoading(initialLoading)
	self.initialLoading = initialLoading;
	self.SpinnerOverlay:SetShown(initialLoading);
end

function HousingPhotoSharingBrowserMixin:GetInitialLoading()
	return self.initialLoading;
end

function HousingPhotoSharingBrowserMixin:OnLoad()
	self:SetTitle(PHOTO_SHARING_BROWSER_TITLE);
	self:RegisterEvent("PHOTO_SHARING_AUTHORIZATION_NEEDED");
	self:RegisterEvent("SIMPLE_BROWSER_SOCIAL_CALLBACK_INVOKED");

	self.popupActive = false;
end

function HousingPhotoSharingBrowserMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	PhotoSharingBrowser:NavigateHome("HousingPhotoSharing");
	self:SetInitialLoading(true);
end

function HousingPhotoSharingBrowserMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function HousingPhotoSharingBrowserMixin:OnEvent(evt, callbackUrl, ...)
	if (evt == "PHOTO_SHARING_AUTHORIZATION_NEEDED") then
		self:Show();
	elseif (evt == "SIMPLE_BROWSER_SOCIAL_CALLBACK_INVOKED") then
		if self.popupActive == false then
			C_HousingPhotoSharing.CompleteAuthorizationFlow(callbackUrl);
			self:Hide();
		end
	end
end	

HousingPhotoSharingBrowserPopupMixin = {}

function HousingPhotoSharingBrowserPopupMixin:SetInitialLoading(initialLoading)
	self.initialLoading = initialLoading;
	self.SpinnerOverlay:SetShown(initialLoading);
end

function HousingPhotoSharingBrowserPopupMixin:GetInitialLoading()
	return self.initialLoading;
end

function HousingPhotoSharingBrowserPopupMixin:OnLoad()
	self:SetTitle(PHOTO_SHARING_BROWSER_TITLE);
	self:RegisterEvent("SIMPLE_BROWSER_POPUP");
	self:RegisterEvent("SIMPLE_BROWSER_SOCIAL_CALLBACK_INVOKED");

	self.loginComplete = false;
end

function HousingPhotoSharingBrowserPopupMixin:OnHide()
	-- Re-establish ownership of the shared cache
	PhotoSharingBrowser:Hide();
	PhotoSharingBrowser:Show();
	PhotoSharingBrowser:GetParent():SetInitialLoading(true);

	PhotoSharingBrowser:NavigateTo(C_HousingPhotoSharing.GetPhotoSharingAuthURL());
end

function HousingPhotoSharingBrowserPopupMixin:OnEvent(evt, url)
	if (evt == "SIMPLE_BROWSER_POPUP") then
		self.SpinnerOverlay:SetShown(false);
		self:Show();
		PhotoSharingBrowserPopup:NavigateTo(url);
		PhotoSharingBrowserPopup:SetFocus();
		PhotoSharingBrowser:GetParent().popupActive = true;
	elseif (evt == "SIMPLE_BROWSER_SOCIAL_CALLBACK_INVOKED") then
		PhotoSharingBrowser:GetParent().popupActive = false;
		self:Hide();
	end
end
