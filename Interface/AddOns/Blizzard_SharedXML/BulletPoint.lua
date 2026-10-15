
BulletPointMixin = CreateFromMixins(ContentFrameMixin);

function BulletPointMixin:MarkDirty()
	self.dirty = true;
end

function BulletPointMixin:IsDirty()
	return self.dirty;
end

function BulletPointMixin:SetContent(content)
	self.Text:SetText(content);
	self:UpdateHeight();
	self:MarkDirty();
end

function BulletPointMixin:UpdateHeight()
	self:SetHeight(self:GetEffectiveHeight());
	self:GetParent():MarkDirty();
	if self.Text:IsRectValid() then
		self.dirty = false;
	else
		self:MarkDirty();
	end
end

function BulletPointMixin:GetEffectiveHeight()
	return self.Text:GetHeight(true);
end

function BulletPointMixin:OnUpdate()
	if self:IsDirty() and self:IsRectValid() then
		self:UpdateHeight();
	end
end

BulletPointWithTextureMixin = CreateFromMixins(BulletPointMixin)

function BulletPointWithTextureMixin:OnLoad()
	self.Text:ClearAllPoints();
	self.Text:SetPoint("TOPLEFT", self.Texture, "TOPRIGHT", self.bulletPointTextureOffset, 0);
	self.Text:SetPoint("TOPRIGHT", self, "TOPRIGHT");
end

function BulletPointWithTextureMixin:GetEffectiveHeight()
	return math.max(self.Texture:GetHeight(), BulletPointMixin.GetEffectiveHeight(self));
end
