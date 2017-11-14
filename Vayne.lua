if GetObjectName(GetMyHero()) ~= "Vayne" then return end

if not pcall( require, "MapPositionGOS" ) then PrintChat("You are missing Walls Library - Go download it and save it Common!") return end
if not pcall( require, "Inspired" ) then PrintChat("You are missing Inspired.lua - Go download it and save it Common!") return end

local VayneMenu = MenuConfig("Vayne", "Vayne")
VayneMenu:Menu("Combo", "Combo")
VayneMenu.Combo:Menu("Q", "Q Settings")
VayneMenu.Combo.Q:DropDown("Mode", "Q Mode", 1, {"Reset", "Ordinary"})
VayneMenu.Combo.Q:Boolean("Enabled", "Enabled", true)
VayneMenu.Combo.Q:Boolean("KeepInvis", "Don't attack while invis", true)
VayneMenu.Combo.Q:Slider("KeepInvisdis", "Distance to attack if out and invis", 250, 0, 550, 1)

VayneMenu.Combo:Menu("E", "ESettings")
VayneMenu.Combo.E:Boolean("Enabled", "Enabled", true)
VayneMenu.Combo.E:Slider("pushdistance", "Enabled", 400, 350, 490, 1)

VayneMenu.Combo:Menu("R", "R Settings")
VayneMenu.Combo.R:Boolean("Enabled", "Enabled", true)
VayneMenu.Combo.R:Slider("Rifthp", "Use R when the enemy is less HP", 70, 1, 100, 1)
VayneMenu.Combo.R:Slider("Rifhp", "Use R when my HP is less", 55, 1, 100, 1)
VayneMenu.Combo.R:Slider("Rminally", "Min. allies in range to use R", 2, 0, 4, 1)
VayneMenu.Combo.R:Slider("Rallyrange", "Ally range from you", 1000, 1, 2000, 10)
VayneMenu.Combo.R:Slider("Rminenemy", "Minimum enemies to use R", 2, 1, 5, 1)
VayneMenu.Combo.R:Slider("Renemyrange", "Enemy range from you", 1000, 1, 2000, 10)


VayneMenu:Menu("Misc", "Misc")
VayneMenu.Misc:Boolean("lowhp", "Low HP peel with E", true)


local InterruptMenu = MenuConfig("Interrupt", "Interrupt Menu")

DelayAction(function()

  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}

  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GetEnemyHeroes()) do
        if spell["Name"] == GetObjectName(k) then
        InterruptMenu:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)   
        end
    end
  end
		
end, 1)
  

local IsStealthed = false

OnTick(function(myHero)
    local target = GetCurrentTarget()

    if IOW:Mode() == "Combo" then
		if VayneMenu.Combo.Q.Mode:Value() == 2 and ValidTarget(target, 900) and VayneMenu.Combo.Q.Enabled:Value() then
            local AfterTumblePos = GetOrigin(myHero) + (Vector(GetMousePos()) - GetOrigin(myHero)):normalized() * 300
            local DistanceAfterTumble = GetDistance(AfterTumblePos, target)
			
            if GetDistance(target) > 0 and DistanceAfterTumble < 660 then
            CastSkillShot(_Q,GetMousePos())
            end
		end
		
	if IsReady(_E) and VayneMenu.Combo.E.Enabled:Value() and ValidTarget(target, 710) then
        StunThisPleb(target)
    end

        if IsReady(_R) and ValidTarget(target, VayneMenu.Combo.R.Renemyrange:Value()) and 100*GetCurrentHP(target)/GetMaxHP(target) <= VayneMenu.Combo.R.Rifthp:Value() and 100*GetCurrentHP(myHero)/GetMaxHP(myHero) <= VayneMenu.Combo.R.Rifhp:Value() and EnemiesAround(myHeroPos(), VayneMenu.Combo.R.Renemyrange:Value()) >= VayneMenu.Combo.R.Rminenemy:Value() and AlliesAround(myHeroPos(), VayneMenu.Combo.R.Rallyrange:Value()) >= VayneMenu.Combo.R.Rminally:Value() then
        CastSpell(_R)
	end
		
    if IsStealthed then
		IOW.attacksEnabled = false
		if ValidTarget(target, 550) and GetDistance(target) > VayneMenu.Combo.Q.KeepInvisdis:Value() then
			IOW.attacksEnabled = true
			elseif not IsStealthed then
			IOW.attacksEnabled = true
		end
	end
	
   end


   for i,enemy in pairs(GetEnemyHeroes()) do   

        if IsReady(_E) and VayneMenu.Misc.lowhp:Value() and GetPercentHP(myHero) <= 15 and EnemiesAround(myHeroPos(), 375) >= 1 then
        CastTargetSpell(enemy, _E)
        end

   end


end)

OnProcessSpell(function(unit, spell)
        if unit == myHero and spell.name:lower():find("attack") and IOW:Mode() == "Combo" and IsReady(_Q) then 
	        DelayAction(function() 
	        	for i,enemy in pairs(GetEnemyHeroes()) do
                           if enemy and VayneMenu.Combo.Q.Mode:Value() == 1 and VayneMenu.Combo.Q.Enabled:Value()then
                                local AfterTumblePos = GetOrigin(myHero) + (Vector(GetMousePos()) - GetOrigin(myHero)):normalized() * 300
                                local DistanceAfterTumble = GetDistance(AfterTumblePos, enemy)
						  
                                if (DistanceAfterTumble < 800 and DistanceAfterTumble > 200) or (GetDistance(myHero, enemy) > 0 and DistanceAfterTumble < 660) then
                                CastSkillShot(_Q,GetMousePos())
								end
                            end
                           
                            if enemy and VayneMenu.Combo.Q.Mode:Value() == 2 and VayneMenu.Combo.Q.Enabled:Value() then
                                local AfterTumblePos = GetOrigin(myHero) + (Vector(GetMousePos()) - GetOrigin(myHero)):normalized() * 300
                                local DistanceAfterTumble = GetDistance(AfterTumblePos, enemy)
  
                                if DistanceAfterTumble < 800 and DistanceAfterTumble > 200 then
                                CastSkillShot(_Q,GetMousePos())
                                end
                            end
                        end
                end, GetWindUp(myHero)*1000)	
      end
  
      if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) and IsReady(_E) then
        if CHANELLING_SPELLS[spell.name] then
          if IsInDistance(unit, 615) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and InterruptMenu[GetObjectName(unit).."Inter"]:Value() then 
          CastTargetSpell(unit, _E)
          end
        end
      end

end)

OnUpdateBuff(function(unit,buff)
  if unit == myHero and buff.Name == "vaynetumblefade" then 
  IsStealthed = true
  end
end)

OnRemoveBuff(function(unit,buff)
  if unit == myHero and buff.Name == "vaynetumblefade" then 
  IsStealthed = false
  end
end)

function StunThisPleb(unit)
        local EPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit),2000,250,1000,1,false,true)
        local PredPos = Vector(EPred.PredPos)
        local HeroPos = Vector(myHero)
        local maxERange = PredPos + (PredPos - HeroPos):normalized() * (VayneMenu.Combo.E.pushdistance:Value())
        local shootLine = Line(Point(PredPos.x, PredPos.y, PredPos.z), Point(maxERange.x, maxERange.y, maxERange.z))
       	for i, Pos in pairs(shootLine:__getPoints()) do
          if MapPosition:inWall(Pos) then
          CastTargetSpell(unit, _E) 
          end
        end
end


AddGapcloseEvent(_E, 550, true)

PrintChat("Vayne Edited loaded.")
PrintChat("End My suffering, kthx?")

