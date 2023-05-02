InspectRecipeMixin = {};

local InspectRecipeEvents =
{
	"BAG_UPDATE",
	"BAG_UPDATE_DELAYED",
};

function InspectRecipeMixin:OnLoad()
	self.SchematicForm.Background:Hide();
	self.SchematicForm.NineSlice:Hide();
end

function InspectRecipeMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, InspectRecipeEvents);

	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_OPEN);
end

function InspectRecipeMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, InspectRecipeEvents);

	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_CLOSE);
end

function InspectRecipeMixin:OnEvent(event, ...)
	if event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
		self.SchematicForm:Refresh();
	end
end

function InspectRecipeMixin:Open(recipeID)
	local professionInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID);
	self:SetTitle(professionInfo.professionName or professionInfo.parentProfessionName);
	self:SetPortraitToAsset(C_TradeSkillUI.GetTradeSkillTexture(professionInfo.professionID));

	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID);
	self.SchematicForm:Init(recipeInfo);
	self.SchematicForm.MinimalBackground:SetAtlas("Professions-MinimizedView-Background", TextureKitConstants.UseAtlasSize);
	self.SchematicForm.MinimalBackground:Show();
	
	ShowUIPanel(self);
end