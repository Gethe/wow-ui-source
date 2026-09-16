local function LocalizePlayerFrame(offsXVehicle, offsYVehicle, offsX, offsY)
	PlayerFrame_UpdatePlayerNameTextAnchor = function()
		if PlayerFrame.unit == "vehicle" then
			PlayerName:SetPoint("TOPLEFT", offsXVehicle, offsYVehicle);
		else
			PlayerName:SetPoint("TOPLEFT", offsX, offsY);
		end
	end
end

function LocalizePlayerFrame_zhCN()
	LocalizePlayerFrame(92, -26, 85, -26);
end

function LocalizePlayerFrame_zhTW()
	LocalizePlayerFrame(92, -27, 85, -27);
end
