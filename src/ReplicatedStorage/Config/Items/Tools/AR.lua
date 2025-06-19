local Gun = {
	Name = "AR",
	Type = "Tool",
	Model = game.ReplicatedStorage.Assets.Items.AR,
	IdleAnimation = "",
	ActiveAnimation = "http://www.roblox.com/asset/?id=182393478",
	
	Damage = 7,
	AttackRange = 25,
	AttackCooldown = -1.3,
	Speed = -0.5,
	Knockback = 0,
	
	HumanZombieWinRatio = 6/1, -- it is actually zombie/human
	Power = 4
}

return Gun