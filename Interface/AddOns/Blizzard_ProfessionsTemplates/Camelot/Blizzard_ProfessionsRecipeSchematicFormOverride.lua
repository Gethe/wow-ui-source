-- Sized so two columns of basic reagents fit within the schematic form.
local REAGENT_SLOT_WIDTH = 160;

local REQUIRED_TOOLS_WIDTH = 250;

function ProfessionsRecipeSchematicFormMixin:GetDescriptionWidth()
	return 305;
end

function ProfessionsRecipeSchematicFormMixin:GetRequiredToolsTextLayout(_minimized)
	local multiline = true;
	return REQUIRED_TOOLS_WIDTH, multiline;
end

function ProfessionsRecipeSchematicFormMixin:OnReagentSlotCreated(slot)
	slot:SetWidth(REAGENT_SLOT_WIDTH);
end
