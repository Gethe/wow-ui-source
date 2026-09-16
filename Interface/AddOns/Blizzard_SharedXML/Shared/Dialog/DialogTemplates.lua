
DialogHeaderMixin = {};

function DialogHeaderMixin:OnLoad()
	if self.textString then
		self:Setup(self.textString);
	end
end

function DialogHeaderMixin:Setup(text)
	self.Text:SetText(text);
	self:UpdateWidth();
end

function DialogHeaderMixin:SetHeaderFont(font)
	self.Text:SetFontObject(font);
	self:UpdateWidth();
end

function DialogHeaderMixin:UpdateWidth()
	self:SetWidth(self.Text:GetWidth() + self.headerTextPadding);
end


