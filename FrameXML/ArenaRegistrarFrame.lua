MAX_TEAM_EMBLEMS = 102;
MAX_TEAM_BORDERS = 6;

local ARENA_TEAMSIZES = { 2, 3, 5 }

function ArenaRegistrar_OnLoad (self)
	self:RegisterEvent("PETITION_VENDOR_SHOW");
	self:RegisterEvent("PETITION_VENDOR_CLOSED");
	self:RegisterEvent("PETITION_VENDOR_UPDATE");
end

function ArenaRegistrar_OnEvent (self, event, ...)
	if ( event == "PETITION_VENDOR_SHOW" ) then
		ShowUIPanel(ArenaRegistrarFrame);
		if ( not ArenaRegistrarFrame:IsShown() ) then
			if ( not PVPBannerFrame:IsShown() ) then
				ClosePetitionVendor();
			end
		end
	elseif ( event == "PETITION_VENDOR_CLOSED" ) then
		HideUIPanel(ArenaRegistrarFrame);
		HideUIPanel(PVPBannerFrame);
	elseif ( event == "PETITION_VENDOR_UPDATE" ) then
		if ( HasFilledPetition() ) then
			ArenaRegistrarButton4:Show();
			ArenaRegistrarButton5:Show();
			ArenaRegistrarButton6:Show();
			RegistrationText:Show();
		else
			ArenaRegistrarButton4:Hide();
			ArenaRegistrarButton5:Hide();
			ArenaRegistrarButton6:Hide();
			RegistrationText:Hide();
		end
		--If we clicked a button then show the appropriate purchase frame
		if ( ArenaRegistrarPurchaseFrame.waitingForPetitionInfo ) then
			ArenaRegistrar_UpdatePrice();
			ArenaRegistrarPurchaseFrame.waitingForPetitionInfo = nil;
		end
	end
end

function ArenaRegistrar_OnShow (self)
	self.dontClose = nil;
	ArenaRegistrarFrame.bannerDesign = nil;
	ArenaRegistrarGreetingFrame:Show();
	ArenaRegistrarPurchaseFrame:Hide();
	SetPortraitTexture(ArenaRegistrarFramePortrait, "NPC");
	ArenaRegistrarFrameNpcNameText:SetText(UnitName("NPC"));
	PlaySound("igQuestListOpen");
end

function ArenaRegistrar_ShowPurchaseFrame (self)
	local id = self:GetID();
	local teamSize = ARENA_TEAMSIZES[id];
	ArenaRegistrarPurchaseFrame.id = id;
	PVPBannerFrame.teamSize = teamSize;
	if ( GetPetitionItemInfo(id) ) then
		ArenaRegistrar_UpdatePrice();
	else
		-- Waiting for the callback
		ArenaRegistrarPurchaseFrame.waitingForPetitionInfo = 1;
	end
end

function ArenaRegistrar_UpdatePrice ()
	local name, texture, price = GetPetitionItemInfo(ArenaRegistrarPurchaseFrame.id);
	MoneyFrame_Update("ArenaRegistrarMoneyFrame", price);
	ArenaRegistrarPurchaseFrame:Show();
	ArenaRegistrarGreetingFrame:Hide();
end

function ArenaRegistrar_TurnInPetition (self)
	local id = self:GetID();
	local teamSize = ARENA_TEAMSIZES[id];

	ArenaRegistrarFrame.bannerDesign = 1;
	ArenaRegistrarFrame.dontClose = 1;
	HideUIPanel(self:GetParent());
	SetPortraitTexture(PVPBannerFramePortrait,"npc");
	PVPBannerFrame.teamSize = teamSize;
	ShowUIPanel(PVPBannerFrame);
end

function PVPBannerFrame_SetBannerColor ()
	local r,g,b = ColorPickerFrame:GetColorRGB();
	PVPBannerFrameStandardBanner.r, PVPBannerFrameStandardBanner.g, PVPBannerFrameStandardBanner.b = r, g, b;
	PVPBannerFrameStandardBanner:SetVertexColor(r, g, b);
end

function PVPBannerFrame_SetEmblemColor ()
	local r,g,b = ColorPickerFrame:GetColorRGB();
	PVPBannerFrameStandardEmblem.r, PVPBannerFrameStandardEmblem.g, PVPBannerFrameStandardEmblem.b = r, g, b;
	PVPBannerFrameStandardEmblem:SetVertexColor(r, g, b);
end

function PVPBannerFrame_SetBorderColor ()
	local r,g,b = ColorPickerFrame:GetColorRGB();
	PVPBannerFrameStandardBorder.r, PVPBannerFrameStandardBorder.g, PVPBannerFrameStandardBorder.b = r, g, b;
	PVPBannerFrameStandardBorder:SetVertexColor(r, g, b);
end

function PVPBannerFrame_OnShow (self)
	PVPBannerFrameStandardEmblem.id = random(MAX_TEAM_EMBLEMS);
	PVPBannerFrameStandardBorder.id = random(MAX_TEAM_BORDERS);

	local bannerColor = {r  = 0, g = 0, b = 0};
	local borderColor = {r  = 0, g = 0, b = 0};
	local emblemColor = {r  = 0, g = 0, b = 0};

	local Standard = {Banner = bannerColor, Border = borderColor, Emblem = emblemColor};

	for index, value in pairs(Standard) do
		for k, v in pairs(value) do
			value[k] = random(100) / 100;
		end
		_G["PVPBannerFrameStandard"..index]:SetVertexColor(value.r, value.g, value.b);
	end

	PVPBannerFrameStandardEmblemWatermark:SetAlpha(0.4);
	PVPBannerFrameStandardBanner:SetTexture("Interface\\PVPFrame\\PVP-Banner-"..PVPBannerFrame.teamSize);
	PVPBannerFrameStandardBorder:SetTexture("Interface\\PVPFrame\\PVP-Banner-"..PVPBannerFrame.teamSize.."-Border-"..PVPBannerFrameStandardBorder.id);
	PVPBannerFrameStandardEmblem:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..PVPBannerFrameStandardEmblem.id);
	PVPBannerFrameStandardEmblemWatermark:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..PVPBannerFrameStandardEmblem.id);
end

function PVPBannerFrame_OpenColorPicker (button, texture)
	local r,g,b = texture:GetVertexColor();
	if ( texture == PVPBannerFrameStandardEmblem ) then
		ColorPickerFrame.func = PVPBannerFrame_SetEmblemColor;
	elseif ( texture == PVPBannerFrameStandardBanner ) then
		ColorPickerFrame.func = PVPBannerFrame_SetBannerColor;
	elseif ( texture == PVPBannerFrameStandardBorder ) then
		ColorPickerFrame.func = PVPBannerFrame_SetBorderColor;
	end
	ColorPickerFrame:SetColorRGB(r, g, b);
	ShowUIPanel(ColorPickerFrame);
end

function PVPBannerCustomization_Left (self)
	local id = self:GetParent():GetID();

	local texture;
	if ( id == 1 ) then
		texture = PVPBannerFrameStandardEmblem;
		if ( texture.id == 1 ) then 
			texture.id = MAX_TEAM_EMBLEMS;
		else 
			texture.id = texture.id - 1;
		end
		texture:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..texture.id);
		PVPBannerFrameStandardEmblemWatermark:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..texture.id);
	else
		texture = PVPBannerFrameStandardBorder;
		if ( texture.id == 1 ) then 
			texture.id = MAX_TEAM_BORDERS;
		else 
			texture.id = texture.id - 1;
		end
		texture:SetTexture("Interface\\PVPFrame\\PVP-Banner-"..PVPBannerFrame.teamSize.."-Border-"..texture.id);
	end
	PlaySound("gsCharacterCreationLook");
end

function PVPBannerCustomization_Right (self)
	local id = self:GetParent():GetID();

	local texture;
	if ( id == 1 ) then
		texture = PVPBannerFrameStandardEmblem;
		if ( texture.id == MAX_TEAM_EMBLEMS ) then 
			texture.id = 1;
		else 
			texture.id = texture.id + 1;
		end
		texture:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..texture.id);
		PVPBannerFrameStandardEmblemWatermark:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..texture.id);
	else
		texture = PVPBannerFrameStandardBorder;
		if ( texture.id == MAX_TEAM_BORDERS ) then 
			texture.id = 1;
		else
			texture.id = texture.id + 1;
		end
		texture:SetTexture("Interface\\PVPFrame\\PVP-Banner-"..PVPBannerFrame.teamSize.."-Border-"..texture.id);
	end
	PlaySound("gsCharacterCreationLook");
end

function PVPBannerFrame_SaveBanner (self)
	local teamSize, iconStyle, borderStyle;

	local bgColor = {r = 0, g = 0, b = 0};
	local borderColor = {r = 0, g = 0, b = 0};
	local iconColor = {r = 0, g = 0, b = 0};
	
	local color = {bgColor, borderColor, iconColor};

	-- Get color values
	bgColor.r, bgColor.g, bgColor.b = PVPBannerFrameStandardBanner:GetVertexColor();
	borderColor.r, borderColor.g, borderColor.b = PVPBannerFrameStandardBorder:GetVertexColor();
	iconColor.r, iconColor.g, iconColor.b = PVPBannerFrameStandardEmblem:GetVertexColor();

	-- Get team size
	teamSize = PVPBannerFrame.teamSize;
	-- Get border style
	borderStyle = PVPBannerFrameStandardBorder.id;

	-- Get emblem style
	iconStyle = PVPBannerFrameStandardEmblem.id;
	TurnInArenaPetition(teamSize, bgColor.r, bgColor.g, bgColor.b, iconStyle, iconColor.r, iconColor.g, iconColor.b, borderStyle, borderColor.r, borderColor.g, borderColor.b);
	HideUIPanel(self:GetParent());
	ClosePetitionVendor();
end