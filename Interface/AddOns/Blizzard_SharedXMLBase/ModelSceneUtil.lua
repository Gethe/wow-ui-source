
ModelSceneUtil = {};

local CHARACTER_SHEET_MODEL_SCENE_ID = 595;
function ModelSceneUtil.SetUpCharacterSheetScene(modelScene)
	modelScene:ReleaseAllActors();
	modelScene:TransitionToModelSceneID(CHARACTER_SHEET_MODEL_SCENE_ID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);

	local form = GetShapeshiftFormID();
	local creatureDisplayID = C_PlayerInfo.GetDisplayID();
	local nativeDisplayID = C_PlayerInfo.GetNativeDisplayID();
	if form and creatureDisplayID ~= 0 and not UnitOnTaxi("player") then
		local actorTag = ANIMAL_FORMS[form] and ANIMAL_FORMS[form].actorTag or nil;
		if actorTag then
			local actor = modelScene:GetPlayerActor(actorTag);
			if actor then
				-- We need to SetModelByCreatureDisplayID() for Shapeshift forms if:
				-- 1. We have a form active (already checked above)
				-- 2. The display granted by that form is *not* our native Player display (e.g. anything *but* Glyph of Stars)
				-- 3. The Player is *not* mirror imaged
				-- 4. The Player *is* currently their native race (e.g. *not* using a transform Toy of some kind)
				local displayIDIsNative = (creatureDisplayID == nativeDisplayID);
				local displayRaceIsNative = C_PlayerInfo.IsDisplayRaceNative();
				local isMirrorImage = C_PlayerInfo.IsMirrorImage();
				local useShapeshiftDisplayID = (not displayIDIsNative and not isMirrorImage and displayRaceIsNative);
				if useShapeshiftDisplayID then
					actor:SetModelByCreatureDisplayID(creatureDisplayID, true);
					actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
					return;
				end
			end
		end
	end

	local actor = modelScene:GetPlayerActor();
	if actor then
		local inAlternateForm = select(2, C_PlayerInfo.GetAlternateFormInfo());
		local sheatheWeapon = GetSheathState() == 1;
		local autodress = true;
		local hideWeapon = false;
		local useNativeForm = not inAlternateForm;
		actor:SetModelByUnit("player", sheatheWeapon, autodress, hideWeapon, useNativeForm);
		actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
	end
end
