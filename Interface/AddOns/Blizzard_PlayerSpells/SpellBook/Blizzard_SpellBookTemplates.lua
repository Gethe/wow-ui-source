SpellBookHeaderMixin = {};

function SpellBookHeaderMixin:Init(elementData)
	if elementData.text then
		self.Text:SetText(elementData.text);
	end
end

SpellBookCategoryTabMixin = {};

function SpellBookCategoryTabMixin:EnableNewSpellsGlow()
	if self:IsShown() then
		self:DisplayNewSpellsGlow();
	else
		self.newSpellsGlowOnNextShow = true;
	end
end

function SpellBookCategoryTabMixin:OnShow()
	if self.newSpellsGlowOnNextShow then
		self:DisplayNewSpellsGlow();
	end
end

function SpellBookCategoryTabMixin:OnHide()
	self.NewSpellsGlowAnim:Stop();
end

function SpellBookCategoryTabMixin:OnClick()
	TabSystemButtonMixin.OnClick(self);
	self.NewSpellsGlowAnim:Stop();
end

function SpellBookCategoryTabMixin:DisplayNewSpellsGlow()
	self.newSpellsGlowOnNextShow = false;
	self.NewSpellsGlowAnim:Restart();
end