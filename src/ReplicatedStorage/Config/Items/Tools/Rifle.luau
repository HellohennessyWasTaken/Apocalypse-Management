local Gun = {
	Name = "Rifle",
	Type = "Tool",
	Model = game.ReplicatedStorage.Assets.Items.Tools.Rifle,
	IdleAnimation = "",
	ActiveAnimation = "http://www.roblox.com/asset/?id=182393478",
	Sound = "Shoot",

	Meta = {
		Nickname = "Rifle",
		Damage = 42,
		AttackRange = 40,
		AttackCooldown = 0.25,
		Speed = -1,
		Knockback = 6,
		
		HumanZombieWinRatio = 4/1, -- it is actually zombie/human
		Power = 4,
	}
}

return Gun