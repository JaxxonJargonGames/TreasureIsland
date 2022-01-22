for i, merchant in pairs(workspace.Merchants:GetChildren()) do
	for i, part in pairs(merchant:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
end
