-- WoWHack-only implementation: expand Selection/SubTreeSelection nodes inline in the Delve challenges grid
-- instead of the default single-node display.

function DelveChallengesContainerFrameMixin.GetTemplateForTalentType(nodeInfo, _talentType, _useLarge)
	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Selection or nodeInfo.type == Enum.TraitNodeType.SubTreeSelection) then
		return "TalentButtonSelectExpandedTemplate";
	end

	return "TalentButtonDelveChallengeCircleTemplate";
end

local DelveChallengesContainerFrameMixin_OnLoad = DelveChallengesContainerFrameMixin.OnLoad;
function DelveChallengesContainerFrameMixin:OnLoad()
	DelveChallengesContainerFrameMixin_OnLoad(self);
	self.buttonsMethod = TalentFrameGridSelectionMixin.GetButtonsInDefaultOrder;
end
