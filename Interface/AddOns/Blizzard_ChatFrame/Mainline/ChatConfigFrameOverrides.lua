ChatConfigUtil = {};

-- Mainline and Camelot share ChatConfigFrame.lua, but only Mainline has a Pet Battle system. Camelot overrides this to hide the Pet Battle chat channels.
function ChatConfigUtil.HasPetBattleChannels()
	return true;
end
