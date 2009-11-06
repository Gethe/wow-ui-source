local VEHICLE_MAX_OVERLAY = 4;
local VEHICLE_MAX_ARTWORK = 10;
local VEHICLE_MAX_BORDER = 7;
local VEHICLE_MAX_BACKGROUND = 3;

VEHICLE_MAX_ACTIONBUTTONS = 6;

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
		["ActionButtonFrame"] = {
			point = "BOTTOMLEFT",
			relativePoint = "BOTTOMRIGHT",
			xOfs = -735,
			yOfs = 15,
		},
		["PitchSlider"] = {
			height = 80,
			width = 31,
			point = "BOTTOMLEFT",
			xOfs = 192,
			yOfs = 3,
			pitchHidden = 1,
		},
		["PitchSliderBG"] = {
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.46875, 0.50390625, 0.31640625, 0.62109375 },
			vertexColor = { 0, 0.85, 0.99 },
		},
		["PitchSliderOverlayThing"] = {
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.38671875, 0.46484375, 0.31640625, 0.62109375 },
		},
		["PitchSliderMarker"] = {
			height = 15,
			width = 30,
			point = "CENTER",
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.46875, 0.50390625, 0.45, 0.55 },
			vertexColor = { 1, 0, 0 },
		},
		["HealthBar"] = {
			height = 72,
			width = 33,
			point = "BOTTOMLEFT",
			xOfs = 96,
			yOfs = 10,
		},
		["HealthBarBackground"] = {
			height = 92,
			width = 38,
			point = "BOTTOMLEFT",
			xOfs = -2,
			yOfs = -9,
			texture = [[Interface\Vehicles\UI-Vehicles-FuelTank]],
			texCoord = { 0.5390625, 0.953125, 0.0, 1.0 },
		},
		["HealthBarOverlay"] = {
			height = 92,
			width = 44,
			point = "BOTTOMLEFT",
			xOfs = -5,
			yOfs = -9,
			texture = [[Interface\Vehicles\UI-Vehicles-FuelTank]],
			texCoord = { 0.015625, 0.4921875, 0.0, 1.0 },
		},
		["PowerBar"] = {
			height = 72,
			width = 33,
			point = "BOTTOMRIGHT",
			xOfs = -98,
			yOfs = 10,
		},
		["PowerBarBackground"] = {
			height = 92,
			width = 38,
			point = "BOTTOMLEFT",
			xOfs = -2,
			yOfs = -9,
			texture = [[Interface\Vehicles\UI-Vehicles-FuelTank]],
			texCoord = { 0.5390625, 0.953125, 0.0, 1.0 },
		},
		["PowerBarOverlay"] = {
			height = 92,
			width = 44,
			point = "BOTTOMLEFT",
			xOfs = -5,
			yOfs = -9,
			texture = [[Interface\Vehicles\UI-Vehicles-FuelTank]],
			texCoord = { 0.015625, 0.4921875, 0.0, 1.0 },
		},
		[1] = {	--Left end cap
			layer = "BACKGROUND",
			height = 74,
			width = 141,
			point = "BOTTOMLEFT",
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.0, 0.55078125, 0.0, 0.2890625 },
		},
		[2] = {	--Right end cap
			layer = "BACKGROUND",
			height = 74,
			width = 141,
			point = "BOTTOMRIGHT",
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.55078125, 0.0, 0.0, 0.2890625 },
		},
		[3] = {	--Left border
			layer = "ARTWORK",
			height = 96,
			width = 24,
			point = "BOTTOMLEFT",
			xOfs = 128,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.50390625, 0.59765625, 0.30859375, 0.68359375 },
		},
		[4] = {	--Pitch Buttons Background
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
		[5] = {	--Right border
			layer = "ARTWORK",
			height = 96,
			width = 24,
			point = "BOTTOMRIGHT",
			xOfs = -128,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.90625, 1.0, 0.30859375, 0.68359375 },
		},
		[6] = {	--Pitch Slider border
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
		[7] = {	--Action buttons background
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
		[8] = {	--Leave button background
			layer = "BORDER",
			height = 92,
			width = 54,
			point = "BOTTOMRIGHT",
			xOfs = -145,
			yOfs = -5,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.0, 0.2109375, 0.3203125, 0.6796875 },
		},
		[9] = {	--Border between micro buttons and leave button
			layer = "ARTWORK",
			height = 96,
			width = 26,
			point = "BOTTOMRIGHT",
			xOfs = -193,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.59765625, 0.69921875, 0.30859375, 0.68359375 },
		},
		[10] = {	--Border between micro buttons and action buttons
			layer = "ARTWORK",
			height = 96,
			width = 26,
			point = "BOTTOMRIGHT",
			xOfs = -335,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap]],
			texCoord = { 0.80078125, 0.90234375, 0.30859375, 0.68359375 },
		},
		[11] = {	--Border above pitch buttons
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
		[12] = {	--Border above action buttons
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
		[13] = {	--Border below action buttons
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
		[14] = {	--Border above leave button
			layer = "ARTWORK",
			height = 16,
			width = 41,
			point = "BOTTOMRIGHT",
			xOfs = -152,
			yOfs = 80,
			texture = [[Interface\Vehicles\UI-Vehicle-Frame-Border]],
			texCoord = { 0.1796875, 0.8203125, 0.0, 1.0 },
		},
		[15] = {	--Border above micro buttons
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
		[16] = {	--Left border
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
	["Natural"] = {
		["Overall"] = {
			yesPitchWidth = 942,
			noPitchWidth = 869,
			yesPitchHeight = 53,
			noPitchHeight = 53,
		},
		["PitchUpButton"] = {	--Pitch up button
			height = 35,
			width = 34,
			point = "BOTTOMLEFT",
			xOfs = 166,
			yOfs = 41,
			normalTexture = [[Interface\Vehicles\UI-Vehicles-Button-Pitch-Up]],
			normalTexCoord = { 0.21875, 0.765625, 0.234375, 0.78125 },
			pushedTexture = [[Interface\Vehicles\UI-Vehicles-Button-Pitch-Down]],
			pushedTexCoord = { 0.21875, 0.765625, 0.234375, 0.78125 },
			pitchHidden = 1,
		},
		["PitchDownButton"] = {	--Pitch up button
			height = 35,
			width = 34,
			point = "BOTTOMLEFT",
			xOfs = 166,
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
			xOfs = -177,
			yOfs = 15,
			normalTexture = [[Interface\Vehicles\UI-Vehicles-Button-Exit-Up]],
			normalTexCoord = { 0.140625, 0.859375, 0.140625, 0.859375 },
			pushedTexture = [[Interface\Vehicles\UI-Vehicles-Button-Exit-Down]],
			pushedTexCoord = { 0.140625, 0.859375, 0.140625, 0.859375 },
		},
		["ActionButtonFrame"] = {
			point = "BOTTOMLEFT",
			relativePoint = "BOTTOMRIGHT",
			xOfs = -820,
			yOfs = 26,
			scale = 0.85,
		},
		["PitchSlider"] = {
			height = 82,
			width = 31,
			point = "BOTTOMLEFT",
			xOfs = 204,
			yOfs = 0,
			pitchHidden = 1,
		},
		["PitchSliderBG"] = {
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 0.46875, 0.50390625, 0.31640625, 0.62109375 },
			vertexColor = { 0, 0.85, 0.99 },
		},
		["PitchSliderOverlayThing"] = {
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 0.38671875, 0.46484375, 0.31640625, 0.62109375 },
			vertexColor = { 1, 0, 0 },
		},
		["PitchSliderMarker"] = {
			height = 15,
			width = 30,
			point = "CENTER",
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 0.46875, 0.50390625, 0.45, 0.55 },
		},
		["HealthBar"] = {
			height = 74,
			width = 38,
			point = "BOTTOMLEFT",
			xOfs = 119,
			yOfs = 3,
		},
		["HealthBarBackground"] = {
			height = 83,
			width = 40,
			point = "BOTTOMLEFT",
			xOfs = -2,
			yOfs = -9,
			texture = [[Interface\Tooltips\UI-Tooltip-Background]],
			texCoord = { 0.0, 1.0, 0.0, 1.0 },
			vertexColor = { TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b },
		},
		["HealthBarOverlay"] = {
			height = 105,
			width = 46,
			point = "BOTTOMLEFT",
			xOfs = -5,
			yOfs = -9,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap-Organic-bottle]],
			texCoord = { 0.46484375, 0.66015625, 0.0390625, 0.9375 },
		},
		["PowerBar"] = {
			height = 74,
			width = 38,
			point = "BOTTOMRIGHT",
			xOfs = -119,
			yOfs = 3,
		},
		["PowerBarBackground"] = {
			height = 83,
			width = 40,
			point = "BOTTOMLEFT",
			xOfs = -2,
			yOfs = -9,
			texture = [[Interface\Tooltips\UI-Tooltip-Background]],
			texCoord = { 0.5390625, 0.953125, 0.0, 1.0 },
			vertexColor = { TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b },
		},
		["PowerBarOverlay"] = {
			height = 105,
			width = 46,
			point = "BOTTOMLEFT",
			xOfs = -5,
			yOfs = -9,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap-Organic-bottle]],
			texCoord = { 0.46484375, 0.66015625, 0.0390625, 0.9375 },
		},
		[1] = {	--Left end cap
			layer = "OVERLAY",
			height = 128,
			width = 114,
			point = "BOTTOMLEFT",
			xOfs = 5,
			yOfs = -15,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap-Organic-bottle]],
			texCoord = { 0.0, 0.4453125, 0.0, 1.0 },
		},
		[2] = {	--Right end cap
			layer = "OVERLAY",
			height = 128,
			width = 114,
			point = "BOTTOMRIGHT",
			xOfs = -6,
			yOfs = -15,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap-Organic-bottle]],
			texCoord = { 0.4453125, 0.0, 0.0, 1.0 },
		},
		[3] = {	--Top right buckle
			layer = "ARTWORK",
			height = 26,
			width = 92,
			point = "BOTTOMRIGHT",
			xOfs = -159,
			yOfs = 73,
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 0.640625, 1.0, 0.0546875, 0.15625 },
		},
		[4] = {	--Leave Seat Buckle
			layer = "BORDER",
			height = 91,
			width = 76,
			point = "BOTTOMRIGHT",
			xOfs = -161,
			yOfs = -10,
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 0.00390625, 0.30078125, 0.3203125, 0.67578125 },
		},
		[5] = {	--Action buttons background
			layer = "BACKGROUND",
			height = 85,
			width = 470,
			tile = true,
			point = "BOTTOMRIGHT",
			xOfs = -237,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 0.0, 1.8359375, 0.68359375, 1.0 },
		},
		[6] = {	--Top border
			layer = "BORDER",
			height = 16,
			width = 473,
			tile = true,
			point = "BOTTOMRIGHT",
			xOfs = -237,
			yOfs = 79,
			texture = [[Interface\Vehicles\UI-Vehicle-Frame-Border-Organic]],
			texCoord = { 0.0, 8.3125, 0.0, 1.0 },
		},
		[7] = {	--Border between micro buttons and action buttons
			layer = "BORDER",
			height = 84,
			width = 17,
			point = "BOTTOMRIGHT",
			xOfs = -363,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 0.93359375, 1.0, 0.3515625, 0.6796875 },
		},
		[8] = {	--Top left buckle
			layer = "ARTWORK",
			height = 25,
			width = 110,
			point = "BOTTOMLEFT",
			xOfs = 159,
			yOfs = 76,
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 0.0, 0.4296875, 0.0390625, 0.13671875 },
		},
		[9] = {	--Pitch Slider right border
			layer = "BORDER",
			height = 84,
			width = 18,
			point = "BOTTOMLEFT",
			xOfs = 221,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 0.859375, 0.9296875, 0.3515625, 0.6796875 },
			pitchHidden = 1,
		},
		[10] = {	--Pitch Slider left border
			layer = "BORDER",
			height = 84,
			width = 18,
			point = "BOTTOMLEFT",
			xOfs = 200,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 0.859375, 0.9296875, 0.3515625, 0.6796875 },
			pitchHidden = 1,
		},
		[11] = { --Pitch buttons border
			layer = "BORDER",
			height = 87,
			width = 48,
			point = "BOTTOMLEFT",
			xOfs = 160,
			yOfs = -3,
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 0.515625, 0.703125, 0.32421875, 0.6640625 },
			pitchHidden = 1,
		},
		[12] = {	--Bottom border
			layer = "BORDER",
			height = 16,
			width = 328,
			tile = true,
			point = "BOTTOMRIGHT",
			xOfs = -377,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicle-Frame-Border-Organic]],
			texCoord = { 0.0, 8.3125, 0.0, 1.0 },
		},
		[13] = {	--Bottom right buckle
			layer = "ARTWORK",
			height = 20,
			width = 77,
			point = "BOTTOMRIGHT",
			xOfs = -377,
			yOfs = -3,
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 0.640625, 1.0, 0.0546875, 0.15625 },
		},
		[14] = {	--Bottom left buckle
			layer = "ARTWORK",
			height = 20,
			width = 77,
			point = "BOTTOMRIGHT",
			xOfs = -629,
			yOfs = -3,
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 1.0, 0.640625, 0.0546875, 0.15625 },
		},
		[15] = {	--Top right buckle
			layer = "ARTWORK",
			height = 21,
			width = 31,
			point = "BOTTOMRIGHT",
			xOfs = -370,
			yOfs = 75,
			texture = [[Interface\Vehicles\UI-Vehicles-Elements-Organic]],
			texCoord = { 0.640625, 0.78125, 0.06640625, 0.15625 },
		},
		[16] = {	--Right vertical cap
			layer = "OVERLAY",
			height = 103,
			width = 9,
			point = "BOTTOMRIGHT",
			xOfs = -158,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap-Organic-bottle]],
			texCoord = { 0.71484375, 0.7578125, 0.0, 1.0 },
		},
		[17] = {	--Left vertical cap
			layer = "OVERLAY",
			height = 103,
			width = 9,
			point = "BOTTOMLEFT",
			xOfs = 158,
			yOfs = 0,
			texture = [[Interface\Vehicles\UI-Vehicles-Endcap-Organic-bottle]],
			texCoord = { 0.7578125, 0.71484375, 0.0, 1.0 },
		},
	},
}

local frameCount = { BACKGROUND = 1, BORDER = 1, ARTWORK = 1, OVERLAY = 1};
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
	for frametype, count in pairs(frameCount) do
		frameCount[frametype] = 1;
	end
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
			frame = _G["VehicleMenuBarArtFrame"..framedata.layer..frameCount[framedata.layer]];
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
			frame = _G["VehicleMenuBar"..framename]
			
			if ( framedata.height ) then
				frame:SetHeight(framedata.height);
				frame:SetWidth(framedata.width);
			end
			
			if ( framedata.normalTexture ) then
				frame:GetNormalTexture():SetTexture(framedata.normalTexture);
				frame:GetNormalTexture():SetTexCoord( unpack(framedata.normalTexCoord) );
			end
			
			if ( framedata.pushedTexture ) then
				frame:GetPushedTexture():SetTexture(framedata.pushedTexture);
				frame:GetPushedTexture():SetTexCoord( unpack(framedata.pushedTexCoord) );
			end
			
			if ( framedata.texture ) then
				frame:SetTexture(framedata.texture);
				frame:SetTexCoord( unpack(framedata.texCoord) );
			end
			
			if ( frame.SetVertexColor ) then
				if ( framedata.vertexColor ) then
					frame:SetVertexColor( unpack(framedata.vertexColor) );
				else
					frame:SetVertexColor( 1.0, 1.0, 1.0, 1.0 );
				end
			end
			
			if ( framedata.point ) then
				frame:ClearAllPoints();
				frame:SetPoint(framedata.point, ( framedata.relativeFrame or frame:GetParent() ) , ( framedata.relativePoint or framedata.point ), ( framedata.xOfs or 0 ) , ( framedata.yOfs or 0 ));
			end
			
			if ( frame.SetScale ) then
				frame:SetScale(framedata.scale or 1);
			end
			
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
	LFDMicroButton,
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
		
		UpdateMicroButtons();
		
	elseif ( skinName == "Mechanical" ) then
	
		for _, frame in pairs(MicroButtons) do
			frame:SetParent(VehicleMenuBarArtFrame);
			frame:Show();
		end
		CharacterMicroButton:ClearAllPoints();
		CharacterMicroButton:SetPoint("BOTTOMLEFT", VehicleMenuBar, "BOTTOMRIGHT", -340, 41);
		SocialsMicroButton:ClearAllPoints();
		SocialsMicroButton:SetPoint("TOPLEFT", CharacterMicroButton, "BOTTOMLEFT", 0, 20);
		
		UpdateMicroButtons();
	elseif ( skinName == "Natural" ) then
	
		for _, frame in pairs(MicroButtons) do
			frame:SetParent(VehicleMenuBarArtFrame);
			frame:Show();
		end
		CharacterMicroButton:ClearAllPoints();
		CharacterMicroButton:SetPoint("BOTTOMLEFT", VehicleMenuBar, "BOTTOMRIGHT", -365, 41);
		SocialsMicroButton:ClearAllPoints();
		SocialsMicroButton:SetPoint("TOPLEFT", CharacterMicroButton, "BOTTOMLEFT", 0, 20);
		
		UpdateMicroButtons();
	end
end

function VehicleMenuBar_ReleaseSkins()
	VehicleMenuBar.currSkin = nil;
	for i=1, VEHICLE_MAX_BACKGROUND do
		_G["VehicleMenuBarArtFrameBACKGROUND"..i]:SetTexture(nil);
	end
	for i=1, VEHICLE_MAX_BORDER do
		_G["VehicleMenuBarArtFrameBORDER"..i]:SetTexture(nil);
	end
	for i=1, VEHICLE_MAX_ARTWORK do
		_G["VehicleMenuBarArtFrameARTWORK"..i]:SetTexture(nil);
	end
	for i=1, VEHICLE_MAX_OVERLAY do
		_G["VehicleMenuBarArtFrameOVERLAY"..i]:SetTexture(nil);
	end
	
	VehicleMenuBarPitchUpButton:GetNormalTexture():SetTexture(nil);
	VehicleMenuBarPitchUpButton:GetPushedTexture():SetTexture(nil);
	VehicleMenuBarPitchDownButton:GetNormalTexture():SetTexture(nil);
	VehicleMenuBarPitchDownButton:GetPushedTexture():SetTexture(nil);
	VehicleMenuBarLeaveButton:GetNormalTexture():SetTexture(nil);
	VehicleMenuBarLeaveButton:GetPushedTexture():SetTexture(nil);
	VehicleMenuBarPitchSliderBG:SetTexture(nil);
	VehicleMenuBarPitchSliderOverlayThing:SetTexture(nil);
	VehicleMenuBarPitchSliderMarker:SetTexture(nil);
end

function VehicleMenuBar_UpdateActionBars()
	local frame;
	for i=1, VEHICLE_MAX_ACTIONBUTTONS do
		frame = _G["VehicleMenuBarActionButton"..i];
		frame:GetNormalTexture():SetHeight(105);
		frame:GetNormalTexture():SetWidth(105);
		frame = _G["VehicleMenuBarActionButton"..i.."HotKey"];
		frame:SetPoint("TOPLEFT", -20, -4);
		frame.SetPoint = function() end;	
	end
end

function VehicleActionButton_OnClick(self, button, down)
	if ( IsModifiedClick("CHATLINK") ) then
		local spellType, id, subType, spellID = GetActionInfo(self.action);
		if ( spellType == "spell" ) then
			if ( HandleModifiedItemClick(GetSpellLink(spellID)) ) then
				return;
			end
		end
	end
	SecureActionButton_OnClick(self, button, down);
end

function VehicleMenuBar_OnLoad(self)
	VehicleMenuBar_UpdateActionBars();
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
end

function VehicleMenuBar_OnEvent(self, event, ...)
	if ( event == "UNIT_ENTERED_VEHICLE" ) then
		UnitFrameHealthBar_Update(VehicleMenuBarHealthBar, "vehicle");
		UnitFrameManaBar_Update(VehicleMenuBarPowerBar, "vehicle");
	elseif ( event == "UNIT_DISPLAYPOWER" ) then	--For those crazy helicopter-cats that turn into bears
		UnitFrameManaBar_Update(VehicleMenuBarPowerBar, "vehicle");
	end
end

function VehicleMenuBarPitch_OnLoad(self)
	self:RegisterEvent("VEHICLE_ANGLE_UPDATE");

	self:RegisterForClicks("LeftButtonUp")
end

function VehicleMenuBarPitch_OnClick(self)
	local _, mouseY = GetCursorPosition();
	local selfScale = self:GetEffectiveScale();
	local pitch = (mouseY - (self:GetBottom()*selfScale) - 8)/((self:GetHeight()*selfScale)-20);
	VehicleAimRequestNormAngle(pitch);
end

function VehicleMenuBarPitch_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "VEHICLE_ANGLE_UPDATE" ) then
		VehicleMenuBarPitch_SetValue(arg1);

	end
end

function VehicleMenuBarPitch_SetValue(pitch)
	VehicleMenuBarPitchSliderMarker:SetPoint("CENTER",VehicleMenuBarPitchSlider, "BOTTOM", 0, pitch * (VehicleMenuBarPitchSlider:GetHeight() - 20) + 8 );
end

function VehicleMenuBarStatusBars_ShowTooltip(self)
	if ( GetMouseFocus() == self ) then
		local value = self:GetValue();
		local _, valueMax = self:GetMinMaxValues();
		if ( valueMax > 0 ) then
			local text = format("%s/%s (%s%%)", TextStatusBar_CapDisplayOfNumericValue(value), TextStatusBar_CapDisplayOfNumericValue(valueMax), tostring(math.ceil((value / valueMax) * 100)));
			GameTooltip:SetOwner(self, self.tooltipAnchorPoint);
			if ( self.prefix ) then
				GameTooltip:AddLine(self.prefix);
			end
			GameTooltip:AddLine(text, 1.0,1.0,1.0 );
			GameTooltip:Show();
		end
	end
end

----------Seat Indicator--------------
local numVehicleIndicatorButtons = 0;
function VehicleSeatIndicator_SetUpVehicle(vehicleIndicatorID)
	if ( vehicleIndicatorID == VehicleSeatIndicator.currSkin ) then
		return;
	end
	
	if ( vehicleIndicatorID == 0 ) then
		VehicleSeatIndicator_UnloadTextures();
		return;
	end
	
	local backgroundTexture, numSeatIndicators = GetVehicleUIIndicator(vehicleIndicatorID);
	
	VehicleSeatIndicator.currSkin = vehicleIndicatorID;
	
	VehicleSeatIndicatorBackgroundTexture:SetTexture(backgroundTexture);
	
	--These have been hard-coded in for now. FIXME (need something returned from GetVehicleUIIndicator that gives height/width)
	local totalHeight = 128; --VehicleSeatIndicatorBackgroundTexture:GetFileHeight();
	local totalWidth = 128; --VehicleSeatIndicatorBackgroundTexture:GetFileWidth();
	VehicleSeatIndicator:SetHeight(totalHeight);
	VehicleSeatIndicator:SetWidth(totalWidth);
	
	for i=1, numSeatIndicators do
		local button;
		if ( i > numVehicleIndicatorButtons ) then
			button = CreateFrame("Button", "VehicleSeatIndicatorButton"..i, VehicleSeatIndicator, "VehicleSeatIndicatorButtonTemplate");
			button:SetID(i)
			numVehicleIndicatorButtons = i;
		else
			button = _G["VehicleSeatIndicatorButton"..i];
		end
		
		local virtualSeatIndex, xOffset, yOffset = GetVehicleUIIndicatorSeat(vehicleIndicatorID, i);
		
		button.virtualID = virtualSeatIndex;
		button:SetPoint("CENTER", button:GetParent(), "TOPLEFT", xOffset*totalWidth, -yOffset*totalHeight);
		button:Show();
	end	
	
	for i=numSeatIndicators+1, numVehicleIndicatorButtons do
		local button = _G["VehicleSeatIndicatorButton"..i];
		button:Hide();
	end
	
	VehicleSeatIndicator:Show();
	DurabilityFrame_SetAlerts();
	VehicleSeatIndicator_Update();
	
	UIParent_ManageFramePositions();
end

function VehicleSeatIndicator_UnloadTextures()
	VehicleSeatIndicatorBackgroundTexture:SetTexture(nil);
	VehicleSeatIndicator:Hide()
	VehicleSeatIndicator.currSkin = nil;
	DurabilityFrame_SetAlerts();
	
	UIParent_ManageFramePositions();
end

local function SeatIndicator_PulseFunc(self, elapsed)
	return abs(sin(elapsed*360));
end

local SeatIndicator_PulseTable = {
	totalTime = 2,
	updateFunc = "SetAlpha",
	getPosFunc = SeatIndicator_PulseFunc,
}

function SeatIndicator_Pulse(self, isPlayer)
	self:Show();
	self:SetAlpha(0);
	SetUpAnimation(self, SeatIndicator_PulseTable, self.Hide);
end

function VehicleSeatIndicator_OnLoad(self)
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA");
	self:RegisterEvent("UNIT_ENTERING_VEHICLE");
	self:RegisterEvent("VEHICLE_PASSENGERS_CHANGED");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("PLAYER_LOSES_VEHICLE_DATA");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	UIDropDownMenu_Initialize( VehicleSeatIndicatorDropDown, VehicleSeatIndicatorDropDown_Initialize, "MENU");
end

function VehicleSeatIndicator_OnEvent(self, event, ...)
	local arg1, arg2, _, _, _, arg6 = ...;
	if ( event == "UNIT_ENTERED_VEHICLE" and arg1 == "player" ) then
		VehicleSeatIndicator_SetUpVehicle(arg6);
	elseif ( event == "PLAYER_GAINS_VEHICLE_DATA" and arg1 == "player" ) then
		VehicleSeatIndicator_SetUpVehicle(arg2);
	elseif ( event == "UNIT_ENTERING_VEHICLE" and arg1 == "player" ) then
		self.hasPulsedPlayer = false;
	elseif ( event == "VEHICLE_PASSENGERS_CHANGED" ) then
		VehicleSeatIndicator_Update();
	elseif ( (event == "UNIT_EXITED_VEHICLE" and arg1 == "player") or
	(event == "PLAYER_ENTERING_WORLD") or
	(event == "PLAYER_LOSES_VEHICLE_DATA" and arg1 == "player") ) then
		VehicleSeatIndicator_UnloadTextures();
	end
end
function VehicleSeatIndicator_Update()
	if ( not VehicleSeatIndicator.currSkin ) then
		return;
	end
	for i=1, numVehicleIndicatorButtons do
		local button = _G["VehicleSeatIndicatorButton"..i];
		if ( button:IsShown() ) then
			local controlType, occupantName = UnitVehicleSeatInfo("player", button.virtualID);
			if ( occupantName ) then
				button.occupantName = occupantName;
				if ( occupantName == UnitName("player") ) then
					_G["VehicleSeatIndicatorButton"..i.."PlayerIcon"]:Show();
					_G["VehicleSeatIndicatorButton"..i.."AllyIcon"]:Hide();
					if ( not VehicleSeatIndicator.hasPulsedPlayer ) then
						SeatIndicator_Pulse(_G["VehicleSeatIndicatorButton"..i.."PulseTexture"], true);
						VehicleSeatIndicator.hasPulsedPlayer = true;
					end
				else
					_G["VehicleSeatIndicatorButton"..i.."PlayerIcon"]:Hide();
					_G["VehicleSeatIndicatorButton"..i.."AllyIcon"]:Show();
				end
			else
				_G["VehicleSeatIndicatorButton"..i.."PlayerIcon"]:Hide();
				_G["VehicleSeatIndicatorButton"..i.."AllyIcon"]:Hide();
			end
		end
	end
end

function VehicleSeatIndicatorButton_OnClick(self, button)
	local seatIndex = self.virtualID;
	if ( button == "RightButton" and CanEjectPassengerFromSeat(seatIndex)) then
		ToggleDropDownMenu(1, seatIndex, VehicleSeatIndicatorDropDown, self:GetName(), 0, -5);
	else
		UnitSwitchToVehicleSeat("player", seatIndex);
	end
end

function VehicleSeatIndicatorButton_OnEnter(self)
	if ( not self:IsEnabled() ) then
		return;
	end
	
	local controlType, occupantName, serverName, ejectable, canSwitchSeats = UnitVehicleSeatInfo("player", self.virtualID);
	local highlight = _G[self:GetName().."Highlight"]
	
	if ( not UnitUsingVehicle("player") ) then	--UnitUsingVehicle also returns true when we are transitioning between seats in a vehicle.
		highlight:Hide();
		if ( occupantName ) then
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(occupantName);
		end
		return;
	end
	
	if ( not canSwitchSeats or not CanSwitchVehicleSeat() ) then
		highlight:Hide();
		SetCursor(nil);
		if ( occupantName ) then
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(occupantName);
		end
	elseif ( controlType == "None" ) then
		if ( occupantName ) then
			highlight:Hide();
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(occupantName);
		else
			highlight:Show();
			SetCursor("Interface\\CURSOR\\vehichleCursor");
		end
	elseif ( controlType == "Root" ) then
		if ( occupantName ) then
			highlight:Hide();
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(occupantName);
		else
			highlight:Show();
			SetCursor("Interface\\CURSOR\\Driver");
		end
	elseif ( controlType == "Child" ) then
		if ( occupantName ) then
			highlight:Hide();
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(occupantName);
		else
			highlight:Show();
			SetCursor("Interface\\CURSOR\\Gunner");
		end
	end
end

function VehicleSeatIndicatorButton_OnLeave(self)
	GameTooltip:Hide();
	SetCursor(nil);
end

function VehicleSeatIndicatorDropDown_OnClick()
	EjectPassengerFromSeat(UIDROPDOWNMENU_MENU_VALUE);
	PlaySound("UChatScrollButton");
end

function VehicleSeatIndicatorDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.text = EJECT_PASSENGER;
	info.func = VehicleSeatIndicatorDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
end