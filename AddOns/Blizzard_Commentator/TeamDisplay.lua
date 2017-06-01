
g_TeamDefinitions = {};
g_TeamDisplaySavedVars = { lastGame = nil, currentGame = nil, };

local ADDON_NAME = ...;
local MIN_SCORE = 0;
local MAX_SCORE = 3;

CommentatorTeamDisplayMixin = {};

function CommentatorTeamDisplayMixin:OnLoad()
	self:RegisterEvent("ADDON_LOADED");
	
	if TeamDefiner then
		TeamDefiner:SetSavedVariable(g_TeamDefinitions);
	end
end

function CommentatorTeamDisplayMixin:OnEvent(event, ...)
	if event == "ADDON_LOADED" then
		if ADDON_NAME == ... then
			self:OnAddonLoaded();
			self:UnregisterEvent("ADDON_LOADED");
		end
	end
end

function CommentatorTeamDisplayMixin:OnAddonLoaded()
	self.loaded = true;

	self.savedVars = g_TeamDisplaySavedVars;
	if self.savedVars.currentGame then
		self.savedVars.lastGame = self.savedVars.currentGame;
	end
	self.savedVars.currentGame = nil;

	if C_Commentator.IsSpectating() then
		self:RefreshPlayerNamesAndScores();
	end
end

local function FindMostLikelyTeamName(teamIndex)
	local teamNameCounts = {};
	for playerIndex = 1, C_Commentator.GetNumPlayers(teamIndex) do
		local unitToken, playerName = C_Commentator.GetPlayerInfo(teamIndex, playerIndex);

		local teamName = g_TeamDefinitions[playerName];
		if teamName then
			teamNameCounts[teamName] = (teamNameCounts[teamName] or 0) + 1;
		end
	end

	local highCount = 0;
	local mostLikelyTeamName;
	for teamName, count in pairs(teamNameCounts) do
		if count > highCount then
			highCount = count;
			mostLikelyTeamName = teamName;
		end
	end

	return mostLikelyTeamName;
end

function CommentatorTeamDisplayMixin:TryToMatchPreviousGame(teamName)
	if teamName then
		local gameData = self.savedVars.currentGame or self.savedVars.lastGame;
		if gameData then
			for teamIndex, teamData in ipairs(gameData) do
				if teamData.teamName == teamName then
					return teamData;
				end
			end
		end
	end
end

function CommentatorTeamDisplayMixin:RefreshPlayerNamesAndScores()
	if not self.loaded or not C_Commentator.IsSpectating() then
		return;
	end
	
	local newTeams = {};
	
	for teamIndex = 1, C_Commentator.GetMaxNumTeams() do
		local mostLikelyTeamName = FindMostLikelyTeamName(teamIndex);
		local oldTeamData = self:TryToMatchPreviousGame(mostLikelyTeamName);

		newTeams[#newTeams + 1] = { teamName = mostLikelyTeamName, score = oldTeamData and oldTeamData.score or 0 };
	end

	self.savedVars.currentGame = newTeams;
	
	self:RefreshDisplay();
end

function CommentatorTeamDisplayMixin:RefreshDisplay()
	local currentGameData = self.savedVars.currentGame;
	if currentGameData then
		for teamIndex, teamData in ipairs(currentGameData) do
			self.ScoreLabels[teamIndex]:SetText(teamData.score);
			self.TeamNameLabels[teamIndex]:SetText(teamData.teamName);
		end
	end
end

function CommentatorTeamDisplayMixin:GetScore(teamIndex)
	if self.savedVars.currentGame and self.savedVars.currentGame[teamIndex] then
		return self.savedVars.currentGame[teamIndex].score;
	end
	return 0;
end

function CommentatorTeamDisplayMixin:SetScore(teamIndex, score)
	score = Clamp(score, MIN_SCORE, MAX_SCORE);

	if self.loaded and self.savedVars.currentGame and self.savedVars.currentGame[teamIndex] and self.savedVars.currentGame[teamIndex].score ~= score then
		self.savedVars.currentGame[teamIndex].score = score;

		self:RefreshDisplay();
	end
end

function CommentatorTeamDisplayMixin:AddScore(teamIndex)
	self:SetScore(teamIndex, self:GetScore(teamIndex) + 1);
end

function CommentatorTeamDisplayMixin:RemoveScore(teamIndex)
	self:SetScore(teamIndex, self:GetScore(teamIndex) - 1);
end

function CommentatorTeamDisplayMixin:ResetScore()
	for teamIndex = 1, C_Commentator.GetMaxNumTeams() do
		self:SetScore(teamIndex, 0);
	end
end

function CommentatorTeamDisplayMixin:SetDampeningValue(percent)
	if percent and percent > 0 then
		self.Dampening:SetText(COMMENTATOR_DAMPENING_PERCENT:format(percent));
		self.Dampening:Show();
		self.DampeningBg:Show();
	else
		self.Dampening:Hide();
		self.DampeningBg:Hide();
	end
end

do
	local lastDampeningValue = nil;
	function CommentatorTeamDisplayMixin:OnUpdate()
		if not GetBattlefieldWinner() then
			local percent = C_Commentator.GetDampeningPercent();
			if percent ~= lastDampeningValue then
				lastDampeningValue = percent;
				self:SetDampeningValue(percent);
			end
		else
			lastDampeningValue = nil;
			self:SetDampeningValue(nil);
		end
	end
end

function CommentatorTeamDisplayMixin:GetTeamName(teamIndex)
	if self.savedVars.currentGame and self.savedVars.currentGame[teamIndex] then
		return self.savedVars.currentGame[teamIndex].teamName;
	end
	return nil;
end

function CommentatorTeamDisplayMixin:UpdateTeamName(teamIndex, newTeamName)
	for i = 1, C_Commentator.GetMaxNumPlayersPerTeam() do
		local playerName = select(2, C_Commentator.GetPlayerInfo(teamIndex, i));
		if playerName then
			g_TeamDefinitions[playerName] = newTeamName;
		end
	end
	
	if TeamDefiner then
		for i = 1, C_Commentator.GetMaxNumPlayersPerTeam() do
			local playerName = select(2, C_Commentator.GetPlayerInfo(teamIndex, i));
			if playerName then
				g_TeamDefinitionUI[teamIndex][i] = select(2, playerName);
			end
		end
		
		TeamDefiner:SetTeamName(teamIndex, newTeamName);
	end
	
	self:RefreshPlayerNamesAndScores();
end

function CommentatorTeamDisplayMixin:AssignPlayerToTeam(playerName, teamName)
	g_TeamDefinitions[playerName] = teamName;
	self:RefreshPlayerNamesAndScores();
end