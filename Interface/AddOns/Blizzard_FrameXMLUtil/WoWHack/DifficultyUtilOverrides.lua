DifficultyUtil.ID.TaleboundNormal = 240;
DifficultyUtil.ID.TaleboundVeteran = 234;
DifficultyUtil.ID.TaleboundHeroic = 238;
DifficultyUtil.ID.TaleboundMythic = 239;

local difficultyIDs = {
	DifficultyUtil.ID.TaleboundNormal,
	DifficultyUtil.ID.TaleboundVeteran,
	DifficultyUtil.ID.TaleboundHeroic,
	DifficultyUtil.ID.TaleboundMythic,
};

for _, difficultyID in ipairs(difficultyIDs) do
	local difficultyName = GetDifficultyInfo(difficultyID);
	DifficultyUtil.DifficultyNames[difficultyID] = difficultyName or "";
end
