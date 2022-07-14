ProfessionsCustomerOrdersRecipeListElementMixin = {};

function ProfessionsCustomerOrdersRecipeListElementMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetRecipeResultItem(self.option.spellID);

	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	end

	self:SetScript("OnUpdate", self.OnUpdate);
end

function ProfessionsCustomerOrdersRecipeListElementMixin:OnLeave()
	GameTooltip:Hide();
	ResetCursor();
	self:SetScript("OnUpdate", nil);
end

-- Set and cleared dynamically in OnEnter and OnLeave
function ProfessionsCustomerOrdersRecipeListElementMixin:OnUpdate()
	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function ProfessionsCustomerOrdersRecipeListElementMixin:OnClick()
	local function UseItemLink(callback)
		local item = Item:CreateFromItemID(self.option.itemID);
		item:ContinueOnItemLoad(function()
			callback(item:GetItemLink());
		end);
	end

	if IsModifiedClick("DRESSUP") then
		UseItemLink(DressUpLink);
	elseif IsModifiedClick("CHATLINK") then
		UseItemLink(ChatEdit_InsertLink);
	else
		EventRegistry:TriggerEvent("ProfessionsCustomerOrders.RecipeSelected", C_TradeSkillUI.GetRecipeSchematic(self.option.spellID));
	end
end

function ProfessionsCustomerOrdersRecipeListElementMixin:Init(elementData)
	self.option = elementData.option;
end

ProfessionsCustomerOrdersRecipeListMixin = {};

function ProfessionsCustomerOrdersRecipeListMixin:OnLoad()
	local pad = 5;
	local spacing = 1;
	local view = CreateScrollBoxListLinearView(pad, pad, pad, pad, spacing);
	view:SetElementInitializer("ProfessionsCustomerOrdersRecipeListElementTemplate", function(button, elementData)
		button:Init(elementData);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end