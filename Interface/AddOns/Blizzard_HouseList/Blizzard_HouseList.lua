HouseListFrameMixin = {}

local HouseListFrameShowingEvents =
{
	"VIEW_HOUSES_LIST_RECIEVED",
};

local HOUSE_ENTRY_EXPANDED_HEIGHT = 145;
local HOUSE_ENTRY_COLLAPSED_HEIGHT = 40;
local HOUSE_LIST_MIN_HEIGHT = 200;
local HOUSE_LIST_MAX_HEIGHT = 350;

function HouseListFrameMixin:OnLoad()
    local view = CreateScrollBoxListLinearView();
	view:SetElementExtentCalculator(function(dataIndex, elementData)
		if SelectionBehaviorMixin.IsElementDataIntrusiveSelected(elementData) then
			return HOUSE_ENTRY_EXPANDED_HEIGHT;
		else
			return HOUSE_ENTRY_COLLAPSED_HEIGHT;
		end
	end);
	local function HouseEntryInitializer(button, elementData)
		button:Init(elementData);
	end;
	view:SetElementInitializer("HouseEntryTemplate", HouseEntryInitializer);
	view:SetPadding(2,0,0,4,0);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	
	self.houseEntrySelectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox, SelectionBehaviorFlags.Deselectable, SelectionBehaviorFlags.Intrusive);
	self.houseEntrySelectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, function(o, elementData, selected)
		if selected then
			self:SetSelectedHouse(elementData);
		else
			self:SetSelectedHouse(nil);
		end

		local button = self.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end
	end, self);

	ScrollUtil.AddResizableChildrenBehavior(self.ScrollBox);
end

function HouseListFrameMixin:InitWithContextData(name, guid, bnetID, isGuildMember)
	self.Title:SetText(string.format(VIEW_HOUSES_TITLE, name));
	C_Housing.GetOthersOwnedHouses(guid, bnetID, not not isGuildMember);
	self.LoadingSpinner:Show();
	self.NoHousesText:Hide();
	self:OnHouseListUpdated(nil);
end

function HouseListFrameMixin:UpdateHeight(numElements)
    local height = (numElements * HOUSE_ENTRY_COLLAPSED_HEIGHT) + HOUSE_ENTRY_EXPANDED_HEIGHT;
    self:SetHeight(Clamp(height, HOUSE_LIST_MIN_HEIGHT, HOUSE_LIST_MAX_HEIGHT));
end

function HouseListFrameMixin:SetSelectedHouse(elementData)

end

function HouseListFrameMixin:OnEvent(event, ...)
    if event == "VIEW_HOUSES_LIST_RECIEVED" then
        local houseInfoList = ...;
        self:OnHouseListUpdated(houseInfoList);
        self.LoadingSpinner:Hide();
    end
end

function HouseListFrameMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, HouseListFrameShowingEvents);
end

function HouseListFrameMixin:OnHide()
    FrameUtil.UnregisterFrameForEvents(self, HouseListFrameShowingEvents);
end

function HouseListFrameMixin:OnHouseListUpdated(houseInfoList)
    local newDataProvider = CreateDataProvider();
    if houseInfoList then
        self.NoHousesText:SetShown(#houseInfoList <= 0);
        for houseInfoID = 1, #houseInfoList do
            newDataProvider:Insert({houseInfo = houseInfoList[houseInfoID], id = houseInfoID});
        end  
        self:UpdateHeight(#houseInfoList);
    else
        self:UpdateHeight(0);
    end
	self.ScrollBox:SetDataProvider(newDataProvider);
    self:SelectedFirstHouse(newDataProvider);
end

function HouseListFrameMixin:SelectedFirstHouse(dataProvider)
	if dataProvider then
		local elementData = dataProvider:FindElementDataByPredicate(function(elementData)
			return elementData.id == 1;
		end);
		if elementData then
            self.houseEntrySelectionBehavior:SelectElementData(elementData);
            self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
        end
    end
end

HouseEntryTemplateMixin = {}

function HouseEntryTemplateMixin:Init(elementData)
    self.id = elementData.id;
    self.houseInfo = elementData.houseInfo;

    self.HouseNameText:SetText(self.houseInfo.houseName);
    self.HouseOwnerText:SetText(self.houseInfo.ownerName);
    self.HouseLocationText:SetText(string.format(HOUSING_PLOT_NUMBER, self.houseInfo.plotID));
    self.HouseNeighborhoodText:SetText(self.houseInfo.neighborhoodName);

    self.VisitHouseButton:SetScript("OnClick", GenerateClosure(self.OnVisitHouseClicked, self));

    if SelectionBehaviorMixin.IsElementDataIntrusiveSelected(elementData) then
        self.selected = true;
		self:Expand();
	else
        self.selected = false;
		self:Collapse();
	end

	self.expandedDetails = {self.Spacer, self.HouseOwnerText, self.HouseOwnerLabel, self.HouseLocationText, self.HouseLocationLabel, self.HouseNeighborhoodText, self.HouseNeighborhoodLabel, self.VisitHouseButton};
    self:UpdatePlusMinusTexture();
end

function HouseEntryTemplateMixin:OnVisitHouseClicked()
	C_Housing.VisitHouse(self.houseInfo.neighborhoodGUID, self.houseInfo.houseGUID, self.houseInfo.plotID);
end

function HouseEntryTemplateMixin:SetSelected(selected)
	if selected then
        self:Expand();
    else
        self:Collapse();
    end
end

function HouseEntryTemplateMixin:Expand(elementData)
    self.collapsed = false;
    self:UpdatePlusMinusTexture();
	self:SetHeight(HOUSE_ENTRY_EXPANDED_HEIGHT);
	self.Background:SetAtlas("house-list-container-open");

    if self.expandedDetails then
        for _, expandedDetail in ipairs(self.expandedDetails) do
            expandedDetail:Show();
        end
    end
end

function HouseEntryTemplateMixin:Collapse(elementData)
    self.collapsed = true;
    self:UpdatePlusMinusTexture();
	self:SetHeight(HOUSE_ENTRY_COLLAPSED_HEIGHT);
	self.Background:SetAtlas("house-list-container-closed");

    if self.expandedDetails then
        for _, expandedDetail in ipairs(self.expandedDetails) do
            expandedDetail:Hide();
        end
    end
end

function HouseEntryTemplateMixin:OnClick()
    HouseListFrame.houseEntrySelectionBehavior:ToggleSelect(self);
end

function HouseEntryTemplateMixin:UpdatePlusMinusTexture()
	if ( self.collapsed ) then
		self.PlusMinus:SetAtlas("common-icon-plus")
	else
		self.PlusMinus:SetAtlas("common-icon-minus")
	end
end
