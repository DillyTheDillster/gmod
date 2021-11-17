function onPlayerDeath(victim, inflictor, attacker)
	if victim != attacker and attacker:IsPlayer() then
		local hsBonus = 0
		if victim.lastHitGroup and victim.lastHitGroup == HITGROUP_HEAD then
			hsBonus = 1
		end
		
		Janus.Levels:AddXP(attacker, 25 + (hsBonus*10))
	end
end
hook.Add("PlayerDeath", "Janus:PlayerDeathReward", onPlayerDeath)

function checkHeadshot(pPlayer, hitGroup)
	pPlayer.lastHitGroup = hitGroup
end
hook.Add("ScalePlayerDamage", "Janus:CheckHeadshotReward", checkHeadshot)