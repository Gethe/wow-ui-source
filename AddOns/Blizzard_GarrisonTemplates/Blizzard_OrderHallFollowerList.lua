-- TODO: Move these to Blizzard_OrderHallMissionUI.lua
OrderHallFollowerList = { }

function OrderHallFollowerList:Setup(mainFrame, followerType, followerTemplate, initialOffsetX)
	GarrisonFollowerList.Setup(self, mainFrame, followerType, "OrderHallMissionFollowerListButtonTemplate", initialOffsetX);
end

OrderHallFollowerListButton = { }

function OrderHallFollowerListButton:GetFollowerList()
	return self:GetParent():GetParent():GetParent():GetParent();
end

