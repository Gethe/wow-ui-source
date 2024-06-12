ArenaUtil = {};

function ArenaUtil.UnitExists(unitToken)
    if ArenaUtil.unitExistsOverides[unitToken] ~= nil then
        return ArenaUtil.unitExistsOverides[unitToken];
    else
        return UnitExists(unitToken);
    end
end

function ArenaUtil.IsArenaUnit(unitToken)
    if not unitToken then
        return false;
    end

    return string.find(unitToken, "arena");
end

do
    ArenaUtil.unitExistsOverides = {};

    EventRegistry:RegisterFrameEvent("ARENA_OPPONENT_UPDATE");
    EventRegistry:RegisterCallback("ARENA_OPPONENT_UPDATE",
    function(_, unitToken, unitEvent, ...)
        if unitEvent == "unseen" then
            ArenaUtil.unitExistsOverides[unitToken] = false;
        else
            ArenaUtil.unitExistsOverides[unitToken] = nil;
        end
    end, {});
end