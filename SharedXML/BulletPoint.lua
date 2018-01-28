---------------
--NOTE - Please do not change this section without talking to Dan
local _, tbl = ...;
if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	end

	setfenv(1, tbl);
	
	Import("pairs");
	
	function Mixin(object, ...)
		for i = 1, select("#", ...) do
			local mixin = select(i, ...);
			for k, v in pairs(mixin) do
				object[k] = v;
			end
		end

		return object;
	end

	function CreateFromMixins(...)
		return Mixin({}, ...)
	end
end
----------------

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