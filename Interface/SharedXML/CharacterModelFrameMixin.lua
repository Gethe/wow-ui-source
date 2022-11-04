
--------------------------------------------------
-- CHARACTER MODEL SCENE MIXIN
CharacterModelSceneMixin = CreateFromMixins(PanningModelSceneMixin);

local ProfessionEquipError =
{
	[Enum.Profession.Blacksmithing] = PROFESSIONS_AUTO_EQUIP_BLACKSMITHING_ONLY,
	[Enum.Profession.Leatherworking] = PROFESSIONS_AUTO_EQUIP_LEATHERWORKING_ONLY,
	[Enum.Profession.Alchemy] = PROFESSIONS_AUTO_EQUIP_ALCHEMY_ONLY,
	[Enum.Profession.Herbalism] = PROFESSIONS_AUTO_EQUIP_HERBALISM_ONLY,
	[Enum.Profession.Cooking] = PROFESSIONS_AUTO_EQUIP_COOKING_ONLY,
	[Enum.Profession.Mining] = PROFESSIONS_AUTO_EQUIP_MINING_ONLY,
	[Enum.Profession.Tailoring] = PROFESSIONS_AUTO_EQUIP_TAILORING_ONLY,
	[Enum.Profession.Engineering] = PROFESSIONS_AUTO_EQUIP_ENGINEERING_ONLY,
	[Enum.Profession.Enchanting] = PROFESSIONS_AUTO_EQUIP_ENCHANTING_ONLY,
	[Enum.Profession.Fishing] = PROFESSIONS_AUTO_EQUIP_FISHING_ONLY,
	[Enum.Profession.Skinning] = PROFESSIONS_AUTO_EQUIP_SKINNING_ONLY,
	[Enum.Profession.Jewelcrafting] = PROFESSIONS_AUTO_EQUIP_JEWELCRAFTING_ONLY,
	[Enum.Profession.Inscription] = PROFESSIONS_AUTO_EQUIP_INSCRIPTION_ONLY,
};

local function TryAutoEquipCursorItem()
	if CursorHasItem() then
		if C_PaperDollInfo.CanAutoEquipCursorItem() then
			AutoEquipCursorItem();
		else
			local profession = C_TradeSkillUI.GetProfessionForCursorItem();
			local tag = profession and ProfessionEquipError[profession] or nil;
			if tag then
				UIErrorsFrame:AddExternalErrorMessage(tag);
			end
		end
	end
end

function CharacterModelSceneMixin:OnMouseUp(button)
	PanningModelSceneMixin.OnMouseUp(self, button)
	if ( button == "LeftButton" ) then
		TryAutoEquipCursorItem();
	end	
end

function CharacterModelSceneMixin:OnReceiveDrag()
	TryAutoEquipCursorItem();
end
