local MAX_OVERLAY = 3;
local MAX_ARTWORK = 10;
local MAX_BORDER = 5;

local MAX_ACTIONBUTTONS = 6;

local SkinsData = {
	["Mechanical"] = {
		["Overall"] = {
			yesPitchWidth = 970,
			noPitchWidth = 888,
			yesPitchHeight = 53,
			noPitchHeight = 53,
		},
		["PitchUpButton"] = {	--Pitch up button
			height = 36,
			width = 38,
			point = "BOTTOMLEFT",
			xOfs = 146,
			yOfs = 41,
			normalTexture = [[Interface\Vehicles\UI-Vehicles-Button-Pitch-Up]],
			normalTexCoord = { 0.21875, 0.765625, 0.234375, 0.78125 },
			pushedTexture = [[Interface\Vehicles\UI-Vehicles-Button-Pitch-Down]],
			pushedTexCoord = { 0.21875, 0.765625, 0.234375, 0.78125 },
			pitchHidden = 1,
		},
		["PitchDownButton"] = {	--Pitch up button
			height = 36,
			width = 38,
			point = "BOTTOMLEFT",
			xOfs = 146,
			yOfs = 3,
			normalTexture = [[Interface\Vehicles\UI-Vehicles-Button-PitchDown-Up]],
			normalTexCoord = { 0.21875, 0.765625, 0.234375, 0.78125 },
			pushedTexture = [[Interface\Vehicles\UI-Vehicles-Button-PitchDown-Down]],
			pushedTexCoord = { 0.21875, 0.765625, 0.234375, 0.78125 },
			pitchHidden = 1,
		},
		["LeaveButton"] = {	--Leave button
			height = 47,
			width = 50,
			point = "BOTTOMRIGHT",
			xOfs = -148,
			yOfs = 18,
			normalTexture = [[Interface\Vehicles\UI-Vehicles-Button-Exit-Up]],
			normalTexCoord = { 0.140625, 0.859375, 0.140625, 0.859375 },
			pushedTexture = [[Interface\Vehicles\UI-Vehicles-Button-Exit-Down]],
			pushedTexCoord = { 0.140625, 0.859375, 0.140625, 0.859375 },
		},
		["ActionButton1"] = {
			point = "BOTTOMLEFT",
			relativePoint = "BOTTOMRIGHT",
			xOfs = -735,
			yOfs = 15,
			onlyPosition = true,
		},
		["PitchSlider"] = {
			point = "BOTTOMLEFT",
			xOfs = 192,
			yOfs = 5,
			onlyPosition = true,
			pitchHidden = 1,
		},
		[1] = {	--Left end cap
			layer = "BORDER",
			height = 74,
			width = 141,
			point = "BOTTOMLEFT",
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.0, 0.55078125, 0.0, 0.2890625 },
		},
		[2] = {	--Right end cap
			layer = "BORDER",
			height = 74,
			width = 141,
			point = "BOTTOMRIGHT",
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.55078125, 0.0, 0.0, 0.2890625 },
		},
		[3] = {	--Left pump
			layer = "OVERLAY",
			height = 77,
			width = 58,
			point = "BOTTOMLEFT",
			xOfs = 92,
			yOfs = 13,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.5546875, 0.78125, 0.0, 0.30078125 },
		},
		[4] = {	--Right pump
			layer = "OVERLAY",
			height = 77,
			width = 58,
			point = "BOTTOMRIGHT",
			xOfs = -92,
			yOfs = 13,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.78125, 0.5546875, 0.0, 0.30078125 },
		},
		[5] = {	--Left border
			layer = "ARTWORK",
			height = 96,
			width = 24,
			point = "BOTTOMLEFT",
			xOfs = 128,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.50390625, 0.59765625, 0.30859375, 0.68359375 },
		},
		[6] = {	--Pitch Buttons Background
			layer = "BORDER",
			height = 92,
			width = 44,
			point = "BOTTOMLEFT",
			xOfs = 145,
			yOfs = -6,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.21484375, 0.38671875, 0.3203125, 0.6796875 },
			pitchHidden = 1,
		},
		[7] = {	--Right border
			layer = "ARTWORK",
			height = 96,
			width = 24,
			point = "BOTTOMRIGHT",
			xOfs = -128,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.90625, 1.0, 0.30859375, 0.68359375 },
		},
		[8] = {	--Pitch Slider border
			layer = "ARTWORK",
			height = 96,
			width = 52,
			point = "BOTTOMLEFT",
			xOfs = 182,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.59765625, 0.80078125, 0.30859375, 0.68359375 },
			pitchHidden = 1,
		},
		[9] = {	--Action buttons background
			layer = "BORDER",
			height = 85,
			width = 533,
			tile = true,
			point = "BOTTOMRIGHT",
			xOfs = -212,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.0, 2.08203125, 0.68359375, 1.0 },
		},
		[10] = {	--Leave button background
			layer = "BORDER",
			height = 92,
			width = 54,
			point = "BOTTOMRIGHT",
			xOfs = -145,
			yOfs = -5,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.0, 0.2109375, 0.3203125, 0.6796875 },
		},
		[11] = {	--Border between micro buttons and leave button
			layer = "ARTWORK",
			height = 96,
			width = 26,
			point = "BOTTOMRIGHT",
			xOfs = -193,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.59765625, 0.69921875, 0.30859375, 0.68359375 },
		},
		[12] = {	--Border between micro buttons and action buttons
			layer = "ARTWORK",
			height = 96,
			width = 26,
			point = "BOTTOMRIGHT",
			xOfs = -335,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.80078125, 0.90234375, 0.30859375, 0.68359375 },
		},
		[13] = {	--Border above pitch buttons
			layer = "ARTWORK",
			height = 16,
			width = 30,
			point = "BOTTOMLEFT",
			xOfs = 152,
			yOfs = 80,
			texture = [[Interface\Vehicles\UI-Vehicle-Frame-Border]],
			texCoord = { 0.25, 0.71875, 0.0, 1.0 },
			pitchHidden = 1,
		},
		[14] = {	--Border above action buttons
			layer = "ARTWORK",
			height = 16,
			width = 375,
			tile = true,
			point = "BOTTOMRIGHT",
			xOfs = -361,
			yOfs = 80,
			texture = [[Interface\Vehicles\UI-Vehicle-Frame-Border]],
			texCoord = { 0.0, 5.859375, 0.0, 1.0 },
		},
		[15] = {	--Border below action buttons
			layer = "ARTWORK",
			height = 16,
			width = 375,
			tile = true,
			point = "BOTTOMRIGHT",
			xOfs = -361,
			yOfs = -3,
			texture = [[Interface\Vehicles\UI-Vehicle-Frame-Border]],
			texCoord = { 0.0, 5.859375, 0.0, 1.0 },
		},
		[16] = {	--Border above leave button
			layer = "ARTWORK",
			height = 16,
			width = 41,
			point = "BOTTOMRIGHT",
			xOfs = -152,
			yOfs = 80,
			texture = [[Interface\Vehicles\UI-Vehicle-Frame-Border]],
			texCoord = { 0.1796875, 0.8203125, 0.0, 1.0 },
		},
		[17] = {	--Border above micro buttons
			layer = "ARTWORK",
			height = 16,
			width = 116,
			tile = true,
			point = "BOTTOMRIGHT",
			xOfs = -219,
			yOfs = 80,
			texture = [[Interface\Vehicles\UI-Vehicle-Frame-Border]],
			texCoord = { 0.0, 1.8125, 0.0, 1.0 },
		},
		[18] = {	--Left border
			layer = "ARTWORK",
			height = 50,
			width = 24,
			point = "BOTTOMLEFT",
			xOfs = 128,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.70703125, 0.80078125, 0.48828125, 0.68359375 },
			pitchHidden = 2,
		},
	},
}

function VehicleMenuBar_SetSkin(skinName, pitchVisible)
	local skinTable = SkinsData[skinName];
	if ( not skinTable ) then
		skinTable = SkinsData["Mechanical"];
		skinName = "Mechanical";
	end
	if ( VehicleMenuBar.currSkin == skinName and VehicleMenuBar.currPitchVisible == pitchVisible ) then
		return;
	else
		VehicleMenuBar_ReleaseSkins();
	end
	VehicleMenuBar.currSkin = skinName;
	VehicleMenuBar.currPitchVisible = pitchVisible;
	local frameCount = { BORDER = 1, ARTWORK = 1, OVERLAY = 1};
	local frame, framedata
	
	if ( pitchVisible ) then
		VehicleMenuBar:SetWidth(skinTable.Overall.yesPitchWidth or 970);
		VehicleMenuBar:SetHeight(skinTable.Overall.yesPitchHeight or 53);
	else
		VehicleMenuBar:SetWidth(skinTable.Overall.noPitchWidth or 970);
		VehicleMenuBar:SetHeight(skinTable.Overall.noPitchHeight or 53);
	end
	
	for _, framedata in ipairs(skinTable) do
		if ( bit.band((framedata.pitchHidden or 0),(pitchVisible or 0)+1) == 0 ) then	--0 = never hide. 1 = hide when no pitch slider 2 = hide when pitch slider
			frame = getglobal("VehicleMenuBarArtFrame"..framedata.layer..frameCount[framedata.layer]);
			if ( not frame ) then
				error("Not enough vehicle art frames of type "..framedata.layer);
			end
			
			frameCount[framedata.layer] = frameCount[framedata.layer] + 1;
			
			frame:SetTexture(framedata.texture, framedata.tile);
			frame:SetHeight(framedata.height);
			frame:SetWidth(framedata.width);
			
			frame:ClearAllPoints()
			frame:SetPoint(framedata.point, ( framedata.relativeFrame or frame:GetParent() ) , ( framedata.relativePoint or framedata.point ), ( framedata.xOfs or 0 ) , ( framedata.yOfs or 0 ));
			
			frame:SetTexCoord( unpack(framedata.texCoord) );
		end
	end
	
	for framename, framedata in pairs(skinTable) do	--For buttons
		if ( type(framename) == "string" and framename ~= "Overall") then
			frame = getglobal("VehicleMenuBar"..framename)
			
			if ( not framedata.onlyPosition) then
				frame:SetHeight(framedata.height);
				frame:SetWidth(framedata.width);
				
				frame:GetNormalTexture():SetTexture(framedata.normalTexture);
				frame:GetNormalTexture():SetTexCoord( unpack(framedata.normalTexCoord) );
				
				frame:GetPushedTexture():SetTexture(framedata.pushedTexture);
				frame:GetPushedTexture():SetTexCoord( unpack(framedata.pushedTexCoord) );
			end
			
			frame:ClearAllPoints();
			frame:SetPoint(framedata.point, ( framedata.relativeFrame or frame:GetParent() ) , ( framedata.relativePoint or framedata.point ), ( framedata.xOfs or 0 ) , ( framedata.yOfs or 0 ));
			
			if ( bit.band((framedata.pitchHidden or 0),(pitchVisible or 0)+1) ~= 0 ) then	--0 = never hide. 1 = hide when no pitch slider 2 = hide when pitch slider
				frame:Hide();
			else
				frame:Show();
			end
		end
	end
	
	VehicleMenuBar_MoveMicroButtons(skinName);
end

local MicroButtons = {
	CharacterMicroButton,
	SpellbookMicroButton,
	TalentMicroButton,
	AchievementMicroButton,
	QuestLogMicroButton,
	SocialsMicroButton,
	PVPMicroButton,
	LFGMicroButton,
	MainMenuMicroButton,
	HelpMicroButton,
	}
function VehicleMenuBar_MoveMicroButtons(skinName)
	if ( not skinName ) then
	
		for _, frame in pairs(MicroButtons) do
			frame:SetParent(MainMenuBarArtFrame);
			frame:Show();
		end
		
		CharacterMicroButton:ClearAllPoints();
		CharacterMicroButton:SetPoint("BOTTOMLEFT", 552, 2);
		SocialsMicroButton:ClearAllPoints();
		SocialsMicroButton:SetPoint("BOTTOMLEFT", QuestLogMicroButton, "BOTTOMRIGHT", -3, 0);
		
		UpdateTalentButton();
		
	elseif ( skinName == "Mechanical" ) then
	
		for _, frame in pairs(MicroButtons) do
			frame:SetParent(VehicleMenuBarArtFrame);
			frame:Show();
		end
		CharacterMicroButton:ClearAllPoints();
		CharacterMicroButton:SetPoint("BOTTOMLEFT", VehicleMenuBar, "BOTTOMRIGHT", -340, 41);
		SocialsMicroButton:ClearAllPoints();
		SocialsMicroButton:SetPoint("TOPLEFT", CharacterMicroButton, "BOTTOMLEFT", 0, 20);
		
		UpdateTalentButton();
	end
end
function VehicleMenuBar_ReleaseSkins()
	VehicleMenuBar.currSkin = nil;
	for i=1, MAX_BORDER do
		getglobal("VehicleMenuBarArtFrameBORDER"..i):SetTexture(nil);
	end
	for i=1, MAX_ARTWORK do
		getglobal("VehicleMenuBarArtFrameARTWORK"..i):SetTexture(nil);
	end
	for i=1, MAX_OVERLAY do
		getglobal("VehicleMenuBarArtFrameOVERLAY"..i):SetTexture(nil);
	end
	
	VehicleMenuBarPitchUpButton:GetNormalTexture():SetTexture(nil);
	VehicleMenuBarPitchUpButton:GetPushedTexture():SetTexture(nil);
	VehicleMenuBarPitchDownButton:GetNormalTexture():SetTexture(nil);
	VehicleMenuBarPitchDownButton:GetPushedTexture():SetTexture(nil);
	VehicleMenuBarLeaveButton:GetNormalTexture():SetTexture(nil);
	VehicleMenuBarLeaveButton:GetPushedTexture():SetTexture(nil);
end

function VehicleMenuBar_UpdateActionBars()
	local frame;
	for i=1, MAX_ACTIONBUTTONS do
		frame = getglobal("VehicleMenuBarActionButton"..i);
		frame:GetNormalTexture():SetHeight(105);
		frame:GetNormalTexture():SetWidth(105);
		frame = getglobal("VehicleMenuBarActionButton"..i.."HotKey");
		frame:SetPoint("TOPLEFT", -20, -4);
		frame.SetPoint = function() end;	
	end
end

function VehicleMenuBar_OnLoad(self)
	VehicleMenuBar_UpdateActionBars();
end

function VehicleMenuBarPitch_OnLoad(self)
	VehicleMenuBarPitchSliderBG:SetVertexColor(0.0, 0.85, 0.99);
	VehicleMenuBarPitchSliderMarker:SetVertexColor(1.0, 0, 0);
	self:RegisterEvent("VEHICLE_ANGLE_UPDATE");

	self:RegisterForClicks("LeftButtonUp")
end

function VehicleMenuBarPitch_OnClick(self)
	local _, mouseY = GetCursorPosition();
	local pitch = (mouseY - self:GetBottom() - 8)/(self:GetHeight()-20);
	VehicleAimRequestNormAngle(pitch);
end

function VehicleMenuBarPitch_OnEvent(self, event, ...)
	arg1 = ...;
	if ( event == "VEHICLE_ANGLE_UPDATE" ) then
		VehicleMenuBarPitch_SetValue(arg1);

	end
end

function VehicleMenuBarPitch_SetValue(pitch)
	VehicleMenuBarPitchSliderMarker:SetPoint("CENTER",VehicleMenuBarPitchSlider, "BOTTOM", 0, pitch * (VehicleMenuBarPitchSlider:GetHeight() - 20) + 8 );
end
--------------------------------------------------------------------
---------------------------DEBUG--------------------------------

function debug(msg)
	DEFAULT_CHAT_FRAME:AddMessage("VehicleMenuBar: "..msg, 1.0, 0 ,0 ,0)
end
function ValidateSkinsData(skintable)
	for skinname, skindata in pairs(skintable) do
		for num, framedata in ipairs(skindata) do
			if not framedata.layer then debug(skinname.." - "..num.." : ".."Missing layer"); return false; end
			if not framedata.texture then debug(skinname.." - "..num.." : ".."Missing texture"); return false; end
			if not framedata.height then debug(skinname.." - "..num.." : ".."Missing height"); return false; end
			if not framedata.width then debug(skinname.." - "..num.." : ".."Missing width"); return false; end
			if not framedata.point then debug(skinname.." - "..num.." : ".."Missing point"); return false; end
		end
		if not skindata.PitchUpButton then debug(skinname.." : ".."Missing PitchUpButton"); return false; end
	end
	return true;
end

function VehicleMenuBar_Debug()
	MainMenuBar:Hide()
	if ( ValidateSkinsData(SkinsData) ) then
		VehicleMenuBar_SetSkin("Mechanical");
	end
end
--------------------END DEBUG---------------------------------
-------------------------------------------------------------------