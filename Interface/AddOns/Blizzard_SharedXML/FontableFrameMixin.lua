-- Intended to simplify the management of a single font object sourced frame
FontableFrameMixin = {};

function FontableFrameMixin:SetFontObject(fontObject)
	if self.fontObject ~= fontObject then
		self.fontObject = fontObject;
		self.hasOwnFontObject = false;
		self:OnFontObjectUpdated();
	end
end

function FontableFrameMixin:GetFontObject()
	return self.fontObject;
end

function FontableFrameMixin:HasFontObject()
	return not not self.fontObject;
end

function FontableFrameMixin:SetFont(font, fontHeight, fontFlags)
	self:MakeFontObjectCustom();
	self.fontObject:SetFont(font, fontHeight, fontFlags);
	self:OnFontObjectUpdated();
end

function FontableFrameMixin:GetFont()
	if self.fontObject then
		return self.fontObject:GetFont();
	end
end

function FontableFrameMixin:SetTextColor(r, g, b, a)
	self:MakeFontObjectCustom();
	self.fontObject:SetTextColor(r, g, b, a);
	self:OnFontObjectUpdated();
end

function FontableFrameMixin:GetTextColor()
	if self.fontObject then
		return self.fontObject:GetTextColor();
	end
end

function FontableFrameMixin:SetShadowColor(r, g, b, a)
	self:MakeFontObjectCustom();
	self.fontObject:SetShadowColor(r, g, b, a);
	self:OnFontObjectUpdated();
end

function FontableFrameMixin:GetShadowColor()
	if self.fontObject then
		return self.fontObject:GetShadowColor();
	end
end

function FontableFrameMixin:SetShadowOffset(offsetX, offsetY)
	self:MakeFontObjectCustom();
	self.fontObject:SetShadowOffset(offsetX, offsetY);
	self:OnFontObjectUpdated();
end

function FontableFrameMixin:GetShadowOffset()
	if self.fontObject then
		return self.fontObject:GetShadowOffset();
	end
end

function FontableFrameMixin:SetSpacing(spacing)
	self:MakeFontObjectCustom();
	self.fontObject:SetSpacing(spacing);
	self:OnFontObjectUpdated();
end

function FontableFrameMixin:GetSpacing()
	if self.fontObject then
		return self.fontObject:GetSpacing();
	end
end

function FontableFrameMixin:SetJustifyH(justifyH)
	self:MakeFontObjectCustom();
	self.fontObject:SetJustifyH(justifyH);
	self:OnFontObjectUpdated();
end

function FontableFrameMixin:GetJustifyH()
	if self.fontObject then
		return self.fontObject:GetJustifyH();
	end
end

function FontableFrameMixin:SetJustifyV(justifyV)
	self:MakeFontObjectCustom();
	self.fontObject:SetJustifyV(justifyV);
	self:OnFontObjectUpdated();
end

function FontableFrameMixin:GetJustifyV()
	if self.fontObject then
		return self.fontObject:GetJustifyV();
	end
end

function FontableFrameMixin:SetIndentedWordWrap(indentWordWrap)
	self:MakeFontObjectCustom();
	self.fontObject:SetIndentedWordWrap(indentWordWrap);
	self:OnFontObjectUpdated();
end

function FontableFrameMixin:GetIndentedWordWrap()
	if self.fontObject then
		return self.fontObject:GetIndentedWordWrap();
	end
end

-- "protected" functions

-- Call this function on your frame's OnLoad with a unique font object name
function FontableFrameMixin:InitializeFontableFrame(name)
	self.fontObject = CreateFont(name);
end

function FontableFrameMixin:OnFontObjectUpdated()
	-- Override this function to respond to the font object changing
end

-- "private" functions
function FontableFrameMixin:MakeFontObjectCustom()
	if not self.hasOwnFontObject then
		local oldFontObject = self.fontObject;
		self.fontObject = CreateFont(tostring(self));
		if oldFontObject then
			self.fontObject:CopyFontObject(oldFontObject);
		end
		self.hasOwnFontObject = true;
	end
end