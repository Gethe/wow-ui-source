-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

function GetBattlefieldScore(playerIndex)
	local scoreInfo = C_PvP.GetScoreInfo(playerIndex);
	local name = nil;
	local killingBlows = 0;
	local honorableKills = 0;
	local deaths = 0;
	local honorGained = 0;
	local faction = 0;
	local raceName = nil;
	local className = nil;
	local classToken = nil;
	local damageDone = 0;
	local healingDone = 0;
	local rating = 0;
	local ratingChange = 0;
	local preMatchMMR = 0;
	local mmrChange = 0;
	local talentSpec = nil;
	local honorLevel = 0;

	if scoreInfo then
		name = scoreInfo.name;
		killingBlows = scoreInfo.killingBlows;
		honorableKills = scoreInfo.honorableKills;
		deaths = scoreInfo.deaths;
		honorGained = scoreInfo.honorGained;
		faction = scoreInfo.faction;
		raceName = scoreInfo.raceName;
		className = scoreInfo.className;
		classToken = scoreInfo.classToken;
		damageDone = scoreInfo.damageDone;
		healingDone = scoreInfo.healingDone;
		rating = scoreInfo.rating;
		ratingChange = scoreInfo.ratingChange;
		preMatchMMR = scoreInfo.preMatchMMR;
		mmrChange = scoreInfo.mmrChange;
		talentSpec = scoreInfo.talentSpec;
		honorLevel = scoreInfo.honorLevel;
	end

	return name, killingBlows, honorableKills, deaths, honorGained, faction, raceName, className, classToken,
		damageDone, healingDone, rating, ratingChange, preMatchMMR, mmrChange, talentSpec, honorLevel;
end

function GetBattlefieldStatData(playerIndex, statIndex)
	local scoreInfo = C_PvP.GetScoreInfo(playerIndex);
	local value = 0;

	if scoreInfo then
		local statInfo = scoreInfo.stats[statIndex];

		if statInfo then
			value = statInfo.pvpStatValue;
		end
	end

	return value;
end

function UnitIsSpellTarget(unit, target)
	if target == "player" then
		return PlayerIsSpellTarget(unit);
	end

	return false;
end
