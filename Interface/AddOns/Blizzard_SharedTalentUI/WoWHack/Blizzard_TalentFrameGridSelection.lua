-- WoWHack-only: talent frame grid that expands Selection/SubTreeSelection nodes inline,
-- displaying each entry as its own grid button instead of a single collapsed node.

TalentFrameGridSelectionMixin = {};

function TalentFrameGridSelectionMixin:GetButtonsInDefaultOrder()
	local buttons = TalentFrameBaseMixin.GetButtonsInDefaultOrder(self);
	local finalButtons = {};
	for _, button in ipairs(buttons) do
		local nodeInfo = button:GetNodeInfo();
		local isExpandableSelection = (nodeInfo.type == Enum.TraitNodeType.Selection or nodeInfo.type == Enum.TraitNodeType.SubTreeSelection) and button.SelectionFrame ~= nil;
		if isExpandableSelection then
			for _i, selection in ipairs(button.SelectionFrame.selectionFrameArray) do
				selection:Show();
				table.insert(finalButtons, selection);
			end
		else
			table.insert(finalButtons, button);
		end
	end

	return finalButtons;
end
