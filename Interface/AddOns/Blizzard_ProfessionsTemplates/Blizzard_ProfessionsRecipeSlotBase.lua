ProfessionsRecipeSlotBaseMixin = {};

function ProfessionsRecipeSlotBaseMixin:IsLoading()
	return self.continuableContainer and self.continuableContainer:AreAnyLoadsOutstanding();
end

function ProfessionsRecipeSlotBaseMixin:Init()
	self.unallocatable = nil;
	self.quantityAvailableCallback = nil;
	self.allocationItem = nil;
	self.CustomerState:Hide();

	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end
	self.continuableContainer = ContinuableContainer:Create();

	self.Button:SetScript("OnEnter", nil);
	self.Button:SetScript("OnClick", nil);
	self.Button:SetScript("OnMouseDown", nil);
	self.Button:Init();
end
