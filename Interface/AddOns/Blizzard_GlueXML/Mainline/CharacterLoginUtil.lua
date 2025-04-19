CharacterLoginUtil = {
    NewAlliedRaces = {};
};

function CharacterLoginUtil.EvaluateNewAlliedRaces()
    wipe(CharacterLoginUtil.NewAlliedRaces);

    local firstLogin = GetCVar("seenAlliedRaceUnlocks") == "0";
    if firstLogin then
        SetCVar("seenAlliedRaceUnlocks", "1");
    end

    local races = C_CharacterCreation.GetAvailableRaces();
    for _, raceInfo in ipairs(races) do
        if raceInfo.isAlliedRace and raceInfo.enabled then
            if firstLogin then
                SetCVarBitfield("seenAlliedRaceUnlocks", raceInfo.raceID, true);
            elseif not GetCVarBitfield("seenAlliedRaceUnlocks", raceInfo.raceID) then
                table.insert(CharacterLoginUtil.NewAlliedRaces, raceInfo.raceID);
            end
        end
    end
end

function CharacterLoginUtil.HasNewAlliedRaces()
    return TableHasAnyEntries(CharacterLoginUtil.NewAlliedRaces);
end

function CharacterLoginUtil.IsNewAlliedRace(raceID)
    return tContains(CharacterLoginUtil.NewAlliedRaces, raceID);
end

function CharacterLoginUtil.MarkNewAlliedRaceSeen(raceID)
    for i, newRaceID in ipairs(CharacterLoginUtil.NewAlliedRaces) do
        if raceID == newRaceID then
            SetCVarBitfield("seenAlliedRaceUnlocks", raceID, true);
            table.remove(CharacterLoginUtil.NewAlliedRaces, i);
            return;
        end
    end
end