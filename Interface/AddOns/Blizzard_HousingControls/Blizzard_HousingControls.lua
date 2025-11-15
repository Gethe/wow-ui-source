local HousingControlsEvents = {
	"HOUSE_PLOT_ENTERED",
	"HOUSE_PLOT_EXITED",
	"HOUSE_EDITOR_AVAILABILITY_CHANGED",
	"CURRENT_HOUSE_INFO_RECIEVED",
};

local HousingControlsShownEvents = {
	"HOUSE_EDITOR_MODE_CHANGED",
	"UPDATE_BINDINGS",
	"HOUSE_INFO_UPDATED",
};

HousingControlsMixin = {};

function HousingControlsMixin:OnLoad()
	self:UpdateControlVisibility(C_Housing.IsInsideHouseOrPlot());

	FrameUtil.RegisterFrameForEvents(self, HousingControlsEvents);
	FrameUtil.RegisterForTopLevelParentChanged(self);
end

function HousingControlsMixin:OnEvent(event, ...)
	if event == "HOUSE_PLOT_ENTERED" then
		self:UpdateControlVisibility(true);
	elseif event == "HOUSE_PLOT_EXITED" then
		self:UpdateControlVisibility(false);
	elseif event == "HOUSE_EDITOR_AVAILABILITY_CHANGED" or event == "HOUSE_INFO_UPDATED" or "CURRENT_HOUSE_INFO_RECIEVED" then
		self:UpdateControlVisibility(C_Housing.IsInsideHouseOrPlot());
	elseif event == "UPDATE_BINDINGS" or event == "HOUSE_EDITOR_MODE_CHANGED" then
		self:UpdateButtons();
	end
end

function HousingControlsMixin:UpdateControlVisibility(isInsideHouseOrPlot)
	-- Avoid showing controls until house editor is fully ready to process availability/switching of modes
	if isInsideHouseOrPlot and C_HouseEditor.IsHouseEditorStatusAvailable() then
		self:Show();
	else
		self:Hide();
	end

	self:UpdateActiveFrame();
	self:UpdateButtons();
end

function HousingControlsMixin:OnShow()
	self:UpdateButtons();
	FrameUtil.RegisterFrameForEvents(self, HousingControlsShownEvents);
end

function HousingControlsMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, HousingControlsShownEvents);
end

function HousingControlsMixin:UpdateActiveFrame()
	local isVisitor = C_HousingNeighborhood.IsPlayerInOtherPlayersPlot() or (C_Housing.IsInsideHouse() and not C_Housing.IsInsideOwnHouse());
	self.activeFrame = isVisitor and self.VisitorControlFrame or self.OwnerControlFrame;
	self.VisitorControlFrame:SetShown(isVisitor);
	self.VisitorControlFrame:UpdateOwnerInfomation();
	self.OwnerControlFrame:SetShown(not isVisitor);
end

function HousingControlsMixin:GetActiveFrame()
	return self.activeFrame;
end

function HousingControlsMixin:UpdateButtons()
	local activeFrame = self:GetActiveFrame();
	for _, button in ipairs(activeFrame.Buttons) do
		button:UpdateState();
	end
end

VisitorControlFrameMixin = {}

function VisitorControlFrameMixin:UpdateOwnerInfomation()
	local houseInfo = C_Housing.GetCurrentHouseInfo();
	if not houseInfo then
		self.OwnerNameText:SetText("");
		return;
	end

	self.ownerName = houseInfo.ownerName or "";
	self.OwnerNameText:SetText(string.format(HOUSING_DASHBOARD_OWNERS_HOUSE, self.ownerName));
end
