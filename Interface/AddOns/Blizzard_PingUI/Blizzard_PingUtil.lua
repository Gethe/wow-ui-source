PingUtil = {};

function PingUtil:GetContextualPingTypeForUnit(unitToken)
    local isUnitUnfriendly = not PlayerUtil.HasFriendlyReaction(unitToken);
    return isUnitUnfriendly and Enum.PingSubjectType.AlertThreat or Enum.PingSubjectType.AlertNotThreat;
end