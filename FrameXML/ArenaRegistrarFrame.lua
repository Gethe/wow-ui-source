MAX_TEAM_EMBLEMS = 102;
MAX_TEAM_BORDERS = 6;


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
	SetPortraitToTexture(PVPBannerFramePortrait,"Interface\\BattlefieldFrame\\UI-Battlefield-Icon");
	PVPBannerFrameStandardEmblem.id = random(MAX_TEAM_EMBLEMS);
	PVPBannerFrameStandardBorder.id = random(MAX_TEAM_BORDERS);
	self.teamName:SetText("");
	
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
	PVPBannerFrameStandardBorder:SetTexture("Interface\\PVPFrame\\PVP-Banner-2-Border-"..PVPBannerFrameStandardBorder.id);
	PVPBannerFrameStandardEmblem:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..PVPBannerFrameStandardEmblem.id);
	PVPBannerFrameStandardEmblemWatermark:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..PVPBannerFrameStandardEmblem.id);
end

function PVPBannerFrame_ColorPickerCancel(prevValues)
	if prevValues.tex then
		prevValues.tex:SetVertexColor(prevValues.r, prevValues.g, prevValues.b);
	end
end

function PVPBannerFrame_OpenColorPicker (button, texture)
	local prevR,prevG,prevB = texture:GetVertexColor();
	ColorPickerFrame.previousValues = {r = prevR, g = prevG, b = prevB, tex = texture};
	if ( texture == PVPBannerFrameStandardEmblem ) then
		ColorPickerFrame.func = PVPBannerFrame_SetEmblemColor;
	elseif ( texture == PVPBannerFrameStandardBanner ) then
		ColorPickerFrame.func = PVPBannerFrame_SetBannerColor;
	elseif ( texture == PVPBannerFrameStandardBorder ) then
		ColorPickerFrame.func = PVPBannerFrame_SetBorderColor;
	end
	ColorPickerFrame.cancelFunc = PVPBannerFrame_ColorPickerCancel;
	ColorPickerFrame:SetColorRGB(prevR,prevG,prevB);
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
		texture:SetTexture("Interface\\PVPFrame\\PVP-Banner-2-Border-"..texture.id);
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
		texture:SetTexture("Interface\\PVPFrame\\PVP-Banner-2-Border-"..texture.id);
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
	
	local teamName = self:GetParent().teamName:GetText();
	
	CreateArenaTeam(teamSize, teamName, bgColor.r, bgColor.g, bgColor.b, iconStyle, iconColor.r, iconColor.g, iconColor.b, borderStyle, borderColor.r, borderColor.g, borderColor.b);
	HideUIPanel(self:GetParent());
end