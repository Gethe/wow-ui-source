-- Can be overridden in external addons.
COMMENTATOR_SCORE_LIMIT = COMMENTATOR_SCORE_LIMIT or 3;

CommentatorScoreboardMixin = {};

function CommentatorScoreboardMixin:OnLoad()
	self.ScoreLabels = {self.ScoreLeft.Label, self.ScoreRight.Label};
	self.TeamNameLabels = {self.Team1Name, self.Team2Name};

	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("ADDONS_UNLOADING");
	self:RegisterEvent("COMMENTATOR_TEAM_NAME_UPDATE");
	self:RegisterEvent("COMMENTATOR_HISTORY_FLUSHED");
end

function CommentatorScoreboardMixin:OnEvent(event, ...)
	if event == "ADDON_LOADED" then
		local addOnName = ...;
		if addOnName == "Blizzard_Commentator" then
			self:UnregisterEvent("ADDON_LOADED");
			if CommentatorSave.history then
				C_Commentator.SetCommentatorHistory(CommentatorSave.history);
			end
		end
	elseif event == "ADDONS_UNLOADING" then
		CommentatorSave.history = C_Commentator.GetCommentatorHistory();
	elseif event == "COMMENTATOR_TEAM_NAME_UPDATE" or event == "COMMENTATOR_HISTORY_FLUSHED" then
		self:Reinitialize();
	end
end

function CommentatorScoreboardMixin:OnShow()
	self:Reinitialize();
end

function CommentatorScoreboardMixin:Reinitialize()
	if not C_Commentator.IsSpectating() then
		return;
	end

	local scores = self:GetScores();
	for teamIndex = 1, 2 do
		local teamName = self:GetTeamName(teamIndex);
		self.TeamNameLabels[teamIndex]:SetText(teamName);
		self.ScoreLabels[teamIndex]:SetText(scores[teamName]);
	end
end

function CommentatorScoreboardMixin:GetScores()
	local names = self:GetTeamNames();
	local series = C_Commentator.GetOrCreateSeries(names[1], names[2]);
	
	local teams = {};
	for teamIndex = 1, 2 do
		local team = series.teams[teamIndex];
		teams[team.name] = team.score;
	end
	return teams;
end

function CommentatorScoreboardMixin:GetDefaultTeamName(teamIndex)
	return teamIndex == 1 and COMMENTATOR_TEAM_NAME_1 or COMMENTATOR_TEAM_NAME_2;
end

function CommentatorScoreboardMixin:GetTeamName(teamIndex)
	return C_Commentator.FindTeamNameInCurrentInstance(teamIndex) or self:GetDefaultTeamName(teamIndex);
end

function CommentatorScoreboardMixin:GetTeamNames()
	local names = {};
	for teamIndex = 1, 2 do
		local name = self:GetTeamName(teamIndex);
		table.insert(names, name);
	end	
	return names;
end

function CommentatorScoreboardMixin:GetScore(teamName)
	local scores = self:GetScores();
	local score = scores[teamName];
	return score or 0;
end

function CommentatorScoreboardMixin:SetScore(teamName, score)
	local names = self:GetTeamNames();
	local teamName1 = names[1];
	local teamName2 = names[2];
	if teamName == teamName1 or teamName == teamName2 then
		score = Clamp(score, 0, COMMENTATOR_SCORE_LIMIT);
		C_Commentator.SetSeriesScore(teamName1, teamName2, teamName, score);
		
		for teamIndex = 1, 2 do
			local score = self:GetScore(names[teamIndex]);
			local scoreLabel = self.ScoreLabels[teamIndex];
			scoreLabel:SetText(score);
		end
	end
end

function CommentatorScoreboardMixin:AddScore(teamIndex)
	local teamName = self:GetTeamName(teamIndex);
	self:SetScore(teamName, self:GetScore(teamName) + 1);
end

function CommentatorScoreboardMixin:RemoveScore(teamIndex)
	local teamName = self:GetTeamName(teamIndex);
	self:SetScore(teamName, self:GetScore(teamName) - 1);
end

function CommentatorScoreboardMixin:ResetScores()
	local names = self:GetTeamNames();
	C_Commentator.ResetSeriesScores(names[1], names[2]);
end

function CommentatorScoreboardMixin:SetMatchDuration(seconds)
	local visible = seconds >= 0.0;
	if visible then
		self.Clock.Label:SetFormattedText(SecondsToClock(seconds));
	end
	self.Clock:SetShown(visible);
end

function CommentatorScoreboardMixin:OnUpdate()
	if GetBattlefieldWinner() then
		self.Logo:Show();
		self.Dampener:Hide();
		self.currentDampening = nil;
	else
		local percent = C_Commentator.GetDampeningPercent();
		if percent > 0 then
			if not self.Dampener:IsShown() then
				self.Logo:Hide();
				self.Dampener:Show();
				self.Dampener.FadeCycle:Play();
			end

			if self.currentDampening ~= percent then
				self.currentDampening = percent;
				self.Dampener.Label:SetText(COMMENTATOR_DAMPENING_PERCENT_ABS:format(percent));
			end
		end
	end
end