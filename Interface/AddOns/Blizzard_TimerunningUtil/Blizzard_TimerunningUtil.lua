TimerunningUtil = {};

function TimerunningUtil.AddTinyIcon(text)
	return CreateAtlasMarkup("timerunning-glues-icon-small", 9, 12)..text;
end

function TimerunningUtil.AddSmallIcon(text)
	return CreateAtlasMarkup("timerunning-glues-icon", 12, 12)..text;
end

function TimerunningUtil.AddLargeIcon(text)
	return ("%s %s"):format(CreateAtlasMarkup("timerunning-glues-icon", 12, 12), text);
end
