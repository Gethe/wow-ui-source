PingableTypeMixin = {
    IsPingable = true;
};

-- When contextually pinging, the default ping type for the ping we should send.
function PingableTypeMixin:GetContextualPingType()
    return nil;
end

-- The target that a UI ping redirects to, if the ping should be located over something (or nothing).
function PingableTypeMixin:GetTargetPingGUID()
    return nil;
end

PingableType_UnitFrameMixin = CreateFromMixins(PingableTypeMixin);

function PingableType_UnitFrameMixin:GetContextualPingType()
    return PingUtil:GetContextualPingTypeForUnit(self:GetTargetPingGUID());
end

function PingableType_UnitFrameMixin:GetTargetPingGUID()
    return UnitGUID(self.unit or self:GetAttribute("unit"));
end