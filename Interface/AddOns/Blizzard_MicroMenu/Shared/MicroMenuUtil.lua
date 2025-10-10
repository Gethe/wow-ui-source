
MicroMenuUtil = {};

function MicroMenuUtil.GenerateButtonInfo(button, gameRule, callback)
	return { button = button, gameRule = gameRule, callback = callback };
end

function MicroMenuUtil.GenerateButtonGameRuleInfo(button, gameRule)
	local callback = nil;
	return MicroMenuUtil.GenerateButtonInfo(button, gameRule, callback);
end

function MicroMenuUtil.GenerateButtonCallbackInfo(button, callback)
	local gameRule = nil;
	return MicroMenuUtil.GenerateButtonInfo(button, gameRule, callback);
end
