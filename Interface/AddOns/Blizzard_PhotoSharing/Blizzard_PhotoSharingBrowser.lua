PhotoSharingBrowserMixin = {}

function PhotoSharingBrowserMixin:SetInitialLoading(initialLoading)
	self.initialLoading = initialLoading;
	self.SpinnerOverlay:SetShown(initialLoading);
end

function PhotoSharingBrowserMixin:GetInitialLoading()
	return self.initialLoading;
end

function PhotoSharingBrowserMixin:OnLoad()
	self:SetTitle(PHOTO_SHARING_BROWSER_TITLE);
	self:RegisterEvent("PHOTO_SHARING_AUTHORIZATION_NEEDED");
	self:RegisterEvent("SIMPLE_BROWSER_SOCIAL_CALLBACK_INVOKED");

	self.popupActive = false;
end

function PhotoSharingBrowserMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	PhotoSharingBrowser:NavigateHome("PhotoSharing");
	self:SetInitialLoading(true);
end

function PhotoSharingBrowserMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function PhotoSharingBrowserMixin:OnEvent(evt, callbackUrl, ...)
	if (evt == "PHOTO_SHARING_AUTHORIZATION_NEEDED") then
		self:Show();
	elseif (evt == "SIMPLE_BROWSER_SOCIAL_CALLBACK_INVOKED") then
		if self.popupActive == false then
			C_PhotoSharing.CompleteAuthorizationFlow(callbackUrl);
			self:Hide();
		end
	end
end	

PhotoSharingBrowserPopupMixin = {}

function PhotoSharingBrowserPopupMixin:SetInitialLoading(initialLoading)
	self.initialLoading = initialLoading;
	self.SpinnerOverlay:SetShown(initialLoading);
end

function PhotoSharingBrowserPopupMixin:GetInitialLoading()
	return self.initialLoading;
end

function PhotoSharingBrowserPopupMixin:OnLoad()
	self:SetTitle(PHOTO_SHARING_BROWSER_TITLE);
	self:RegisterEvent("SIMPLE_BROWSER_POPUP");
	self:RegisterEvent("SIMPLE_BROWSER_SOCIAL_CALLBACK_INVOKED");

	self.loginComplete = false;
end

function PhotoSharingBrowserPopupMixin:OnHide()
	-- Re-establish ownership of the shared cache
	PhotoSharingBrowser:Hide();
	PhotoSharingBrowser:Show();
	PhotoSharingBrowser:GetParent():SetInitialLoading(true);

	PhotoSharingBrowser:NavigateTo(C_PhotoSharing.GetPhotoSharingAuthURL());
end

function PhotoSharingBrowserPopupMixin:OnEvent(evt, url)
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
