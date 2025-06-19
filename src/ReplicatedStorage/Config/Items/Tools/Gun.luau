local Gun = {
	Name = "Gun",
	Type = "Tool",
	Model = game.ReplicatedStorage.Assets.Items.Gun,
	IdleAnimation = "",
	ActiveAnimation = "http://www.roblox.com/asset/?id=182393478",
	
	Damage = 16,
	AttackRange = 20,
	AttackCooldown = -0.5,
	Speed = 0,
	Knockback = 1,
	
	HumanZombieWinRatio = 5/2, -- it is actually zombie/human
	Power = 3
}

return Gun