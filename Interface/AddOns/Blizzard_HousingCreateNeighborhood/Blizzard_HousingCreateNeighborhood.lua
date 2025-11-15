local errorStrings = 
{
	[Enum.CreateNeighborhoodErrorType.None] = "",
	[Enum.CreateNeighborhoodErrorType.Profanity] = HOUSING_CREATENEIGHBORHOOD_ERROR_BADNAME,
	[Enum.CreateNeighborhoodErrorType.UndersizedGuild] = HOUSING_CREATENEIGHBORHOOD_ERROR_UNDERSIZED_GUILD,
	[Enum.CreateNeighborhoodErrorType.OversizedGuild] = HOUSING_CREATENEIGHBORHOOD_ERROR_OVERSIZED_GUILD,
};

--/////////////////////////////////////////////////////////////
HousingCreateNeighborhoodMixin = {}

function HousingCreateNeighborhoodMixin:CreateNeighborhoodBaseOnLoad()
    self:RegisterEvent("CREATE_NEIGHBORHOOD_RESULT");
	self.NeighborhoodNameEditBox:SetMaxLetters(50);
end

function HousingCreateNeighborhoodMixin:CreateNeighborhoodBaseOnEvent(event, ...)
    if event == "CREATE_NEIGHBORHOOD_RESULT" then
        local args = {...};
        local result = args[1];
        local neighborhoodName = args[2];
        if result == Enum.HousingResult.Success then
            HousingTopBannerFrame:SetBannerText(HOUSING_CREATENEIGHBORHOOD_TOAST, neighborhoodName);
            TopBannerManager_Show(HousingTopBannerFrame);
        else
            UIErrorsFrame:AddExternalErrorMessage(HOUSING_CREATENEIGHBORHOOD_SERVER_ERROR);
        end
    end
end

function HousingCreateNeighborhoodMixin:CreateNeighborhoodBaseOnShow()

end

--//////////////////////////////////////////////////////
HousingCreateNeighborhoodConfirmationMixin = {}

function HousingCreateNeighborhoodConfirmationMixin:CreateNeighborhoodConfirmationBaseOnLoad()
    self.CancelButton:SetText(HOUSING_CREATENEIGHBORHOOD_CANCELBUTTON);
end

--//////////////////////////////////////////////////////
HousingCreateCharterNeighborhoodConfirmationMixin = {}

local CharterConfirmationFrameShowingEvents =
{
	"CLOSE_CHARTER_CONFIRMATION_UI",
};

function HousingCreateCharterNeighborhoodConfirmationMixin:OnLoad()
	self.Title:SetText(HOUSING_CREATENEIGHBORHOOD_CREATECHARTER);
    self.ConfirmButton:SetText(HOUSING_CREATENEIGHBORHOOD_GUILD_CONFIRMBUTTON);
    self.ConfirmButton:SetScript("OnClick", function()
        C_Housing.OnCharterConfirmationAccepted();
        HideUIPanel(HousingCreateCharterNeighborhoodConfirmationFrame);
		PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_CHARTER_BUTTONS);
    end);
    self.CancelButton:SetScript("OnClick", function()
        HideUIPanel(HousingCreateCharterNeighborhoodConfirmationFrame);
		PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_CHARTER_BUTTONS);
    end);
end

function HousingCreateCharterNeighborhoodConfirmationMixin:SetCharterInfo(neighborhoodName, locationName)
    self.LocationText:SetText(locationName);
    self.NeighborhoodNameText:SetText(neighborhoodName);
end

function HousingCreateCharterNeighborhoodConfirmationMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, CharterConfirmationFrameShowingEvents);
	PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_CHARTER_OPEN);
end

function HousingCreateCharterNeighborhoodConfirmationMixin:OnHide()
    C_Housing.OnCharterConfirmationClosed();
    FrameUtil.UnregisterFrameForEvents(self, CharterConfirmationFrameShowingEvents);
	PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_CHARTER_CLOSE);
end

function HousingCreateCharterNeighborhoodConfirmationMixin:OnEvent(event, ...)
    if event == "CLOSE_CHARTER_CONFIRMATION_UI" then
        HideUIPanel(HousingCreateCharterNeighborhoodConfirmationFrame);
    end
end

--//////////////////////////////////////////////////////
HousingCreateGuildNeighborhoodConfirmationMixin = {}

function HousingCreateGuildNeighborhoodConfirmationMixin:OnLoad()
    self.ConfirmButton:SetText(HOUSING_CREATENEIGHBORHOOD_GUILD_CONFIRMBUTTON);
    self.NeighborhoodNameLabel:SetPoint("TOPLEFT", self.GuildLabel, "BOTTOMLEFT", 0, -8);
	self.Title:SetText(HOUSING_CREATENEIGHBORHOOD_CREATEGUILD);

    self.ConfirmButton:SetScript("OnClick", function()
        C_Housing.CreateGuildNeighborhood(HousingCreateGuildNeighborhoodFrame.NeighborhoodNameEditBox:GetText());
        HousingCreateGuildNeighborhoodFrame.ConfirmationFrame:Hide();
		PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_GUILD_BUTTON);
        HideUIPanel(HousingCreateGuildNeighborhoodFrame);
    end);
    self.CancelButton:SetScript("OnClick", function()
        HousingCreateGuildNeighborhoodFrame.ConfirmationFrame:Hide();
		PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_GUILD_BUTTON);
    end);
end

function HousingCreateGuildNeighborhoodConfirmationMixin:OnShow()
    self.LocationText:SetText(HousingCreateGuildNeighborhoodFrame.LocationText:GetText());
    self.GuildText:SetText(HousingCreateGuildNeighborhoodFrame.GuildText:GetText());
    self.NeighborhoodNameText:SetText(HousingCreateGuildNeighborhoodFrame.NeighborhoodNameEditBox:GetText());
end

--/////////////////////////////////////////////////
HousingCreateGuildNeighborhoodMixin = {}

function HousingCreateGuildNeighborhoodMixin:OnCreateNeighborhoodClicked()
	self.NeighborhoodNameError:Hide();
	self.NeighborhoodRequirementsError:Hide();
	C_Housing.ValidateNeighborhoodName(self.NeighborhoodNameEditBox:GetText());
	PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_GUILD_BUTTON);
end

function HousingCreateGuildNeighborhoodMixin:OnLoad()
    self.NeighborhoodNameLabel:SetPoint("TOPLEFT", self.GuildLabel, "BOTTOMLEFT", 0, -8);
	self.Title:SetText(HOUSING_CREATENEIGHBORHOOD_CREATEGUILD);
	self.NeighborhoodInfoText:SetText(HOUSING_CREATENEIGHBORHOOD_GUILD_INFODESCRIPTION);
    self.ConfirmButton:SetScript("OnClick", GenerateClosure(self.OnCreateNeighborhoodClicked, self));
    self.CancelButton:SetScript("OnClick", function()
        HideUIPanel(HousingCreateGuildNeighborhoodFrame);
		PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_GUILD_BUTTON);
    end);
end

local CreateGuildNeighborhoodFrameShowingEvents =
{
	"CLOSE_CREATE_GUILD_NEIGHBORHOOD_UI",
	"NEIGHBORHOOD_GUILD_SIZE_VALIDATED",
	"NEIGHBORHOOD_NAME_VALIDATED"
};

function HousingCreateGuildNeighborhoodMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, CreateGuildNeighborhoodFrameShowingEvents);
	C_Housing.ValidateCreateGuildNeighborhoodSize();
	PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_GUILD_OPEN);
end

function HousingCreateGuildNeighborhoodMixin:OnEvent(event, ...)
    if event == "CLOSE_CREATE_GUILD_NEIGHBORHOOD_UI" then
        HideUIPanel(HousingCreateGuildNeighborhoodFrame);
	elseif event == "NEIGHBORHOOD_GUILD_SIZE_VALIDATED" then
		local approved = ...;
		if approved == false then
			self.NeighborhoodRequirementsError:SetText(errorStrings[Enum.CreateNeighborhoodErrorType.UndersizedGuild]);
			self.NeighborhoodRequirementsError:Show();
		else
			self.NeighborhoodRequirementsError:Hide();
		end
	elseif event == "NEIGHBORHOOD_NAME_VALIDATED" then
		local approved = ...;
		if approved == false then
			self.NeighborhoodNameError:Show();
		else
			HousingCreateGuildNeighborhoodFrame.ConfirmationFrame:Show();
		end
    end
end

function HousingCreateGuildNeighborhoodMixin:OnHide()
    C_Housing.OnCreateGuildNeighborhoodClosed();
    FrameUtil.UnregisterFrameForEvents(self, CreateGuildNeighborhoodFrameShowingEvents);
	PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_GUILD_CLOSE);
end

function HousingCreateGuildNeighborhoodMixin:SetActiveLocationAndGuild(locationName)
    self.LocationText:SetText(locationName);
    local guildName = GetGuildInfo("player");
    self.GuildText:SetText(guildName);
end

--/////////////////////////////////////////////////////////////////
HousingCreateNeighborhoodCharterMixin = {}

--call to edit existing charters with the current settings from the charter
function HousingCreateNeighborhoodCharterMixin:SetCharterInfo(neighborhoodName)
    if neighborhoodName then
        self.NeighborhoodNameEditBox:SetText(neighborhoodName);
        self.CharterSettingsWarning:Show();
        self.isEditingCharter = true;
        self.ConfirmButton:SetText(HOUSING_CREATENEIGHBORHOOD_CONFIRMBUTTON);
    else
        self.NeighborhoodNameEditBox:SetText("");
        self.CharterSettingsWarning:Hide();
        self.isEditingCharter = false;
        self.ConfirmButton:SetText(HOUSING_CREATENEIGHBORHOOD_CHARTER_CONFIRMBUTTON);
    end
end

function HousingCreateNeighborhoodCharterMixin:OnConfirmClicked()
    self.NeighborhoodNameError:Hide();
	C_Housing.ValidateNeighborhoodName(self.NeighborhoodNameEditBox:GetText());
	PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_CHARTER_PURCHASE);
end

function HousingCreateNeighborhoodCharterMixin:OnLoad()
	self.Title:SetText(HOUSING_CREATENEIGHBORHOOD_CHARTER);
	self.NeighborhoodInfoText:SetText(HOUSING_CREATENEIGHBORHOOD_CHARTER_INFODESCRIPTION);
    self.ConfirmButton:SetText(HOUSING_CREATENEIGHBORHOOD_CHARTER_CONFIRMBUTTON);
    self.ConfirmButton:SetScript("OnClick", GenerateClosure(self.OnConfirmClicked, self));
    self.CancelButton:SetScript("OnClick", function()
        HideUIPanel(HousingCreateNeighborhoodCharterFrame);
		PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_CHARTER_CANCEL);
        self:SetCharterInfo(); --clear out any set info from editing existing charters
    end);
end

local CreateCharterNeighborhoodFrameShowingEvents =
{
	"CLOSE_CREATE_CHARTER_NEIGHBORHOOD_UI",
	"NEIGHBORHOOD_NAME_VALIDATED",
};

function HousingCreateNeighborhoodCharterMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, CreateCharterNeighborhoodFrameShowingEvents);
	PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_CHARTER_OPEN);
end

function HousingCreateNeighborhoodCharterMixin:OnEvent(event, ...)
    if event == "CLOSE_CREATE_CHARTER_NEIGHBORHOOD_UI" then
        HideUIPanel(HousingCreateNeighborhoodCharterFrame);
    elseif event == "NEIGHBORHOOD_NAME_VALIDATED" then
		local approved = ...;
		if approved == false then
			self.NeighborhoodNameError:Show();
		else	
			if self.isEditingCharter then
				C_Housing.EditNeighborhoodCharter(self.NeighborhoodNameEditBox:GetText());
			else
				C_Housing.CreateNeighborhoodCharter(self.NeighborhoodNameEditBox:GetText());
			end
			HideUIPanel(HousingCreateNeighborhoodCharterFrame);
			self:SetCharterInfo(); --clear out any set info from editing existing charters
		end
    end
end

function HousingCreateNeighborhoodCharterMixin:OnHide()
    C_Housing.OnCreateCharterNeighborhoodClosed();
    FrameUtil.UnregisterFrameForEvents(self, CreateCharterNeighborhoodFrameShowingEvents);
	PlaySound(SOUNDKIT.HOUSING_CREATE_NEIGHBORHOOD_CHARTER_CLOSE);
end

function HousingCreateNeighborhoodCharterMixin:SetActiveLocation(locationName)
    self.LocationText:SetText(locationName);
end