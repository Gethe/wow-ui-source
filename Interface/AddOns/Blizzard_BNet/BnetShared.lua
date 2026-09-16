function BNet_GetClientAtlas(atlasPrefix, clientName)
	if ( clientName ) then
		-- Try to get the atlas
		local atlas = atlasPrefix..clientName;
		if ( C_Texture.GetAtlasInfo(atlas) ) then
			return atlas;
		end
	end

	-- If you couldn't get the atlas then just return the default bnet client
	return atlasPrefix.."App";
end

function BNet_GetClientEmbeddedAtlas(client, width, height, xOffset, yOffset)
	width = width or 0;
	height = height or width;
	xOffset = xOffset or 0;
	yOffset = yOffset or 0;
	local atlas = BNet_GetClientAtlas("UI-ChatIcon-", client);

	return CreateAtlasMarkup(atlas, width, height, xOffset, yOffset);
end

function BNet_GetBattlenetClientAtlas(client)
	return BNet_GetClientAtlas("Battlenet-ClientIcon-", client);
end

function BNet_GetClientEmbeddedTexture(texture, fileWidth, fileHeight, width, height, xOffset, yOffset)
	width = width or 0;
	height = height or width;
	xOffset = xOffset or 0;
	yOffset = yOffset or 0;
	
	return CreateTextureMarkup(texture, fileWidth, fileHeight, width, height, 0, 1, 0, 1, xOffset, yOffset);
end