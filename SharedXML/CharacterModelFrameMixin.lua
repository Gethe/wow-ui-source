
--------------------------------------------------
-- CHARACTER MODEL FRAME MIXIN
CharacterModelFrameMixin = CreateFromMixins(ModelFrameMixin);

function CharacterModelFrameMixin:OnLoad()
	ModelFrameMixin.OnLoad(self, MODELFRAME_MAX_PLAYER_ZOOM);
end

function CharacterModelFrameMixin:PostMouseUp(button)
	if ( button == "LeftButton" ) then
		AutoEquipCursorItem();
	end	
end

function CharacterModelFrameMixin:OnReceiveDrag()
	AutoEquipCursorItem();
end
