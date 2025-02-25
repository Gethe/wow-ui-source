CommandLineUtil = {};

function CommandLineUtil.ScoreStrings(searchText, otherString)
	-- lower is better

	local subStringStartIndex, subStringEndIndex = otherString:find(searchText, 1, true);
	local hasSubString = not not subStringStartIndex;

	local editDistance = CalculateStringEditDistance(searchText, otherString);
	if not hasSubString and editDistance == math.max(#searchText, #otherString) then
		return 100; -- not even close
	end
	
	local subStringScore = hasSubString and -#searchText * 10 or 0;
	local startOfMatchScore = hasSubString and ClampedPercentageBetween(subStringStartIndex, 15, 1) * -2 * #searchText or 0;

	return editDistance + subStringScore + startOfMatchScore;
end

function CommandLineUtil.BinaryInsert(t, value)
	local startIndex = 1;
	local endIndex = #t;
	local midIndex = 1;
	local preInsert = true;

	while startIndex <= endIndex do
		midIndex = math.floor((startIndex + endIndex) / 2);

		if value.score < t[midIndex].score then
			endIndex = midIndex - 1;
			preInsert = true;
		else
			startIndex = midIndex + 1;
			preInsert = false;
		end
	end

	table.insert(t, midIndex + (preInsert and 0 or 1), value);
end