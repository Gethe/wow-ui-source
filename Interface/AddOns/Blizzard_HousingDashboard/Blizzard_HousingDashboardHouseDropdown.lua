HousingDashboardHouseDropdownMixin = {};
local HousesDropdownLifetimeEvents =
{
	"PLAYER_HOUSE_LIST_UPDATED",
};

function HousingDashboardHouseDropdownMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, HousesDropdownLifetimeEvents);
	self:LoadHouses();
end

function HousingDashboardHouseDropdownMixin:OnEvent(event, ...)
	if event == "PLAYER_HOUSE_LIST_UPDATED" then
		local houseInfoList = ...;
		self:OnHouseListUpdated(houseInfoList);
	end
end

function HousingDashboardHouseDropdownMixin:OnShow()
	self:LoadHouses();
end

function HousingDashboardHouseDropdownMixin:OnHide()
end

function HousingDashboardHouseDropdownMixin:LoadHouses()
	EventRegistry:TriggerEvent("HouseDropdown.HouseListLoading", true);
	C_Housing.GetPlayerOwnedHouses();
end

function HousingDashboardHouseDropdownMixin:OnHouseListUpdated(houseInfoList)
	EventRegistry:TriggerEvent("HouseDropdown.HouseListLoading", false);
	-- Don't bother thrashing everything if nothing in the list has changed
	-- Which is likely since we re-request this list on every OnShow
	if self.playerHouseList and tCompare(self.playerHouseList, houseInfoList, 2) then
		return;
	end

	self.playerHouseList = houseInfoList;
	EventRegistry:TriggerEvent("HouseDropdown.HouseListUpdated", self.playerHouseList);

	if #houseInfoList <= 0 then
		self.Dropdown:Hide();
		return;
	end

	self.Dropdown:Show();

	local oldSelectedHouseID = self.selectedHouseID;
	local oldSelectedHouseInfo = self.selectedHouseInfo;
	self.selectedHouseID = nil;
	self.selectedHouseInfo = nil;

	if oldSelectedHouseID and oldSelectedHouseInfo then
		local newSelectedHouseInfo = houseInfoList[oldSelectedHouseID];
		-- If we had something previously selected, and it still exists in the updated list, maintain that selection
		if newSelectedHouseInfo and oldSelectedHouseInfo.houseGUID == newSelectedHouseInfo.houseGUID then
			self.selectedHouseID = oldSelectedHouseID;
		end
	end

	if not self.selectedHouseID then
		-- If we don't have a previous selection, check if we're in a house or plot and default to that house.
		local currentHouseInfo = C_Housing.GetCurrentHouseInfo();
		if currentHouseInfo and currentHouseInfo.houseGUID then
			for houseInfoIndex, houseInfo in ipairs(houseInfoList) do
				if houseInfo.houseGUID == currentHouseInfo.houseGUID then
					self.selectedHouseID = houseInfoIndex;
					break;
				end
			end
		end
	end

	if not self.selectedHouseID then
		-- If we don't have a previous selection, check if we're in a neighborhood and default to a house that belongs there.
		local currentNeighborhoodGUID = C_Housing.GetCurrentNeighborhoodGUID();
		if currentNeighborhoodGUID then
			for houseInfoIndex, houseInfo in ipairs(houseInfoList) do
				if houseInfo.neighborhoodGUID == currentNeighborhoodGUID then
					self.selectedHouseID = houseInfoIndex;
					break;
				end
			end
		end
	end

	if not self.selectedHouseID then
		-- If we still don't have a selection, then default to a house in your active neighborhood
		local activeNeighborhoodGUID = C_NeighborhoodInitiative.GetActiveNeighborhood();
		if activeNeighborhoodGUID then
			for houseInfoIndex, houseInfo in ipairs(houseInfoList) do
				if houseInfo.neighborhoodGUID == activeNeighborhoodGUID then
					self.selectedHouseID = houseInfoIndex;
					break;
				end
			end
		end
	end

	-- Fallback to just using the first one in the list
	if not self.selectedHouseID then
		self.selectedHouseID = 1;
	end

	self.Dropdown:SetupMenu(function(dropdown, rootDescription)
		local extent = 20;
		local maxHousesShown = 8;
		local maxScrollExtent = extent * maxHousesShown;
		rootDescription:SetScrollMode(maxScrollExtent);

		local function IsSelected(houseInfoID)
			return houseInfoID == self.selectedHouseID;
		end;

		local function SetSelected(houseInfoID)
			self:OnHouseSelected(houseInfoID);
		end;

		for houseInfoIndex, houseInfo in ipairs(houseInfoList) do
			rootDescription:CreateRadio(houseInfo.houseName, IsSelected, SetSelected, houseInfoIndex);
		end
	end);

	self:OnHouseSelected(self.selectedHouseID);
end

function HousingDashboardHouseDropdownMixin:OnHouseSelected(houseInfoID)
	self.selectedHouseID = houseInfoID;
	self.selectedHouseInfo = self.playerHouseList[houseInfoID];
	EventRegistry:TriggerEvent("HouseDropdown.HouseSelected", self.selectedHouseID, self.selectedHouseInfo);
end
