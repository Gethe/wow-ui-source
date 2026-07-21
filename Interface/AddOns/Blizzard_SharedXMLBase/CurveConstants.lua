CurveConstants = {};

-- Curve that acts as the identity function for any input percentage value.
CurveConstants.ZeroToOne = C_CurveUtil.CreateCurve();
CurveConstants.ZeroToOne:AddPoint(0.0, 0.0);
CurveConstants.ZeroToOne:AddPoint(1.0, 1.0);

-- Curve that re-scales any percentage value from [0, 1] to [0, 100].
CurveConstants.ScaleTo100 = C_CurveUtil.CreateCurve();
CurveConstants.ScaleTo100:SetType(Enum.LuaCurveType.Linear);
CurveConstants.ScaleTo100:AddPoint(0.0, 0);
CurveConstants.ScaleTo100:AddPoint(1.0, 100);

-- Curve that reverses input percentage values from [0, 1] to [1, 0].
CurveConstants.Reverse = C_CurveUtil.CreateCurve();
CurveConstants.Reverse:SetType(Enum.LuaCurveType.Linear);
CurveConstants.Reverse:AddPoint(0.0, 1.0);
CurveConstants.Reverse:AddPoint(1.0, 0.0);

-- Curve that reverses input percentage values from [0, 1] to [100, 0].
CurveConstants.ReverseTo100 = C_CurveUtil.CreateCurve();
CurveConstants.ReverseTo100:SetType(Enum.LuaCurveType.Linear);
CurveConstants.ReverseTo100:AddPoint(0.0, 100);
CurveConstants.ReverseTo100:AddPoint(1.0, 0);
