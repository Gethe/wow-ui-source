
--------------------------------------------------
-- CHARACTER MODEL SCENE MIXIN
CharacterModelSceneMixin = CreateFromMixins(PanningModelSceneMixin);

function CharacterModelSceneMixin:OnMouseUp(button)
	PanningModelSceneMixin.OnMouseUp(self, button)
	if ( button == "LeftButton" ) then
		AutoEquipCursorItem();
	end	
end

function CharacterModelSceneMixin:OnReceiveDrag()
	AutoEquipCursorItem();
end
