function CommunitiesGetCurrentLocale()
	local currentLocale = GetCVar("textLocale");
	local localeInfos = GetAvailableLocaleInfo();
	for _, localeInfo in ipairs(localeInfos) do
		if currentLocale == localeInfo.localeName then
			return localeInfo;
		end
	end
	return localeInfos[1];
end

function CommunitiesAddLanguageInitializer(description, localeInfo)
	description:AddInitializer(function(button, description, menu)
		button.fontString:Hide();
	
		local leftTexture1 = button.leftTexture1;
		local locTexture = button:AttachTexture();
		locTexture:SetPoint("LEFT", leftTexture1, "RIGHT", 8, -2);

		local atlas = LocaleUtil.GetLanguageAtlas(localeInfo.localeName);
		locTexture:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	end);
end

CommunitiesLanguageDropdownMixin = {};

function CommunitiesLanguageDropdownMixin:SetLocale(localeId)
	self.currentLocaleId = localeId;

	C_ClubFinder.SetRecruitmentLocale(localeId);
end

function CommunitiesLanguageDropdownMixin:IsLocale(localeId)
	return self.currentLocaleId == localeId;
end

function CommunitiesLanguageDropdownMixin:SetupMenu(localeId)
	if localeId then
		self:SetLocale(localeId);
	else
		local localeInfo = CommunitiesGetCurrentLocale();
		self:SetLocale(localeInfo.localeId);
	end

	self:SetSelectionText(function(selections)
		if #selections == 0 then
			self.Text:Show();
			self.Language:Hide();
			return nil;
		end

		local localeInfo = selections[1].data;
		local atlas = LocaleUtil.GetLanguageAtlas(localeInfo.localeName);
		self.Language:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
		self.Language:Show();
		self.Text:Hide();
		return nil;
	end);

	DropdownButtonMixin.SetupMenu(self, function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_COMMUNITIES_LANGUAGE");

		local function IsChecked(localeInfo)
			local localeId = localeInfo.localeId;
			return self:IsLocale(localeId);
		end

		local function SetChecked(localeInfo)
			self:SetLocale(localeInfo.localeId, not self:IsLocale(localeInfo));
		end

		local ignoreLocaleRestrictions = true;
		local localeInfos = GetAvailableLocaleInfo(ignoreLocaleRestrictions);
		for _, localeInfo in pairs(localeInfos) do
			local radio = rootDescription:CreateRadio("", IsChecked, SetChecked, localeInfo);
			CommunitiesAddLanguageInitializer(radio, localeInfo);
		end
	end);
end

function CommunitiesLanguageDropdownMixin:OnButtonStateChanged()
	WowStyle1DropdownMixin.OnButtonStateChanged(self);

	if self:IsEnabled() then
		self.Language:SetVertexColor(1,1,1);
	else
		self.Language:SetVertexColor(DISABLED_FONT_COLOR:GetRGB());
	end
end