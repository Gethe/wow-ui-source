
OrderHallMission = { }

function OrderHallMission:UpdateCurrency()
end

function OrderHallMission:OnLoad()
	self.followerTypeID = LE_FOLLOWER_TYPE_GARRISON_7_0;
	self:OnLoadMainFrame();
end

function OrderHallMission:OnShow()
	self:OnShowMainFrame();
	AdventureMapMixin.OnShow(self.MissionTab);
end

function OrderHallMission:OnHide()
	self:OnHideMainFrame();
	AdventureMapMixin.OnHide(self.MissionTab);
end

function OrderHallMission:SelectTab(id)
	GarrisonFollowerMission.SelectTab(self, id);
	if (id == 1) then
		self.TitleText:SetText("[PH] Order Hall Missions");
		self.FollowerList:Hide();
	else
		self.TitleText:SetText("[PH] Order Hall Followers");
	end
end

function OrderHallMission:SetupMissionList()
end

function OrderHallMission:CheckCompleteMissions(onShow)
	-- go to the right tab if window is being open
	if ( onShow ) then
		self:SelectTab(1);
	end
end



OrderHallMissionAdventureMapMixin = { }

function AdventureMapMixin:SetupTitle()
end

function OrderHallMissionAdventureMapMixin:EvaluateLockReasons()
	if next(self.lockReasons) then
		-- TODO overlay frame

	else
		-- TODO overlay frame

	end
end

-- Don't call C_AdventureMap.Close here because we may be simply switching tabs. We call that method in OrderHallMission:OnHide() instead.
function OrderHallMissionAdventureMapMixin:OnShow()
end

function OrderHallMissionAdventureMapMixin:OnHide()
end
