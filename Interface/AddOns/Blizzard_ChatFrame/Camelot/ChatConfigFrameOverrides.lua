ChatConfigUtil = {};

-- Camelot has no Pet Battle system, so its chat config shouldn't offer the Pet Battle channels.
function ChatConfigUtil.HasPetBattleChannels()
	return false;
end
