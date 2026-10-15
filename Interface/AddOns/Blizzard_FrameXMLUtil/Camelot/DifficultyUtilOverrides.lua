function DifficultyUtil.HasAnyUserSelectableDifficulties()
	local isUserSelectable = false;
	for key, id in pairs(DifficultyUtil.ID) do
		isUserSelectable = select(11, GetDifficultyInfo(id));
		if(isUserSelectable) then
			return true;
		end
	end
	return false;
end
