local HousingControlsEvents = {
	"HOUSE_PLOT_ENTERED",
	"HOUSE_PLOT_EXITED",
	"HOUSE_EDITOR_AVAILABILITY_CHANGED",
};

local HousingControlsShownEvents = {
	"HOUSE_EDITOR_MODE_CHANGED",
	"UPDATE_BINDINGS",
	"HOUSE_INFO_UPDATED",
};

HousingControlsMixin = {};

function HousingControlsMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, HousingControlsEvents);
	FrameUtil.RegisterForTopLevelParentChanged(self);

	self:UpdateControlVisibility(C_Housing.IsInsideHouseOrPlot());
end

function HousingControlsMixin:OnEvent(event, ...)
	if event == "HOUSE_PLOT_ENTERED" then
		self:UpdateControlVisibility(true);
	elseif event == "HOUSE_PLOT_EXITED" then
		self:UpdateControlVisibility(false);
	elseif event == "HOUSE_EDITOR_AVAILABILITY_CHANGED" or event == "HOUSE_INFO_UPDATED" then
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
	self:UpdateButtons();
end

function HousingControlsMixin:OnShow()
	self:UpdateButtons();
	FrameUtil.RegisterFrameForEvents(self, HousingControlsShownEvents);
end

function HousingControlsMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, HousingControlsShownEvents);
end

function HousingControlsMixin:UpdateButtons()
	for _, button in ipairs(self.Buttons) do
		button:UpdateState();
	end
end