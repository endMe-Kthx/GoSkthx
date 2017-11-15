if GetObjectName(GetMyHero()) ~= "Vayne" then return end

require('MapPositionGOS')
require('Inspired')

local VayneMenu = MenuConfig("Vayne", "Vayne")
VayneMenu:Menu("Combo", "Combo")
VayneMenu.Combo:Menu("Q", "Tumble (Q)")
VayneMenu.Combo.Q:DropDown("Mode", "Mode", 1, {"Reset", "Normal"})
VayneMenu.Combo.Q:Boolean("Enabled", "Enabled", true)
VayneMenu.Combo.Q:Boolean("KeepInvis", "Don't AA While Stealthed/bugget better keep turned off", true)
VayneMenu.Combo.Q:Slider("KeepInvisdis", "Only if Distance <", 230, 0, 550, 1)

VayneMenu.Combo:Menu("E", "Condemn (E)")
VayneMenu.Combo.E:Boolean("Enabled", "Enabled", true)
VayneMenu.Combo.E:Slider("pushdistance", "E Push Distance", 400, 350, 490, 1)

VayneMenu.Combo:Menu("R", "Final Hour (R)")
VayneMenu.Combo.R:Boolean("Enabled", "Enabled", true)
VayneMenu.Combo.R:Slider("Rifthp", "if Target Health % <", 70, 1, 100, 1)
VayneMenu.Combo.R:Slider("Rifhp", "if Health % <", 55, 1, 100, 1)
VayneMenu.Combo.R:Slider("Rminally", "Minimum Allies in Range", 2, 0, 4, 1)
VayneMenu.Combo.R:Slider("Rallyrange", "Range", 1000, 1, 2000, 10)
VayneMenu.Combo.R:Slider("Rminenemy", "Minimum Enemies in Range", 2, 1, 5, 1)
VayneMenu.Combo.R:Slider("Renemyrange", "Range", 1000, 1, 2000, 10)
VayneMenu.Combo:Boolean("Items", "Use Items", true)
VayneMenu.Combo:Slider("myHP", "if HP % <", 50, 0, 100, 1)
VayneMenu.Combo:Slider("targetHP", "if Target HP % >", 20, 0, 100, 1)

VayneMenu:Menu("Misc", "Misc")
VayneMenu.Misc:Menu("EMenu", "AutoStun / disabled.") --lines 46-48 and lines 132-134
VayneMenu.Misc:Boolean("lowhp", "Peel with E when low health", true)

VayneMenu:Menu("Interrupt", "Interrupt (E)")

DelayAction(function()
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GetEnemyHeroes()) do
        if spell["Name"] == GetObjectName(k) then
        VayneMenu.Interrupt:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)   
        end
    end
  end
  
  --for _,k in pairs(GetEnemyHeroes()) do
  --VayneMenu.Misc.EMenu:Boolean(GetObjectName(k).."Pleb", ""..GetObjectName(k).."", true)
  --end
end, 1)
 
OnProcessSpell(function(unit, spell)
  if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) and IsReady(_E) then
    if CHANELLING_SPELLS[spell.name] then
      if IsInDistance(unit, 615) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and VayneMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() then 
      CastTargetSpell(unit, _E)
      end
    end
  end
end)

OnProcessSpellAttack(function(unit,spell)
  DelayAction(function()
  if unit == myHero and IOW:Mode() == "Combo" and spell.target ~= nil and VayneMenu.Combo.Q.Enabled:Value() and IsReady(_Q) then
    local AfterTumblePos = GetOrigin(myHero) + (Vector(GetMousePos()) - GetOrigin(myHero)):normalized() * 300
    local DistanceAfterTumble = GetDistance(AfterTumblePos, spell.target)
						  
    if DistanceAfterTumble < 800 and DistanceAfterTumble > 200 then
    CastSkillShot(_Q,GetMousePos())
    end
  
    if GetDistance(spell.target) > 630 and DistanceAfterTumble < 630 then
    CastSkillShot(_Q,GetMousePos())
    end
  end
  end, GetWindUp(myHero))
end)

local IsStealthed = false

OnTick(function(myHero)
    local target = GetCurrentTarget()
    local BRK = GetItemSlot(myHero,3153) > 0 and GetItemSlot(myHero,3153) or GetItemSlot(myHero,3144) > 0 and GetItemSlot(myHero,3144) or nil
    local YMG = GetItemSlot(myHero,3142) > 0 and GetItemSlot(myHero,3142) or nil
    local mousePos = GetMousePos()

    if IOW:Mode() == "Combo" then
        
        if VayneMenu.Combo.Q.Mode:Value() == 2 and target ~= nil and VayneMenu.Combo.Q.Enabled:Value() then
          local AfterTumblePos = GetOrigin(myHero) + (Vector(mousePos) - GetOrigin(myHero)):normalized() * 300
          local DistanceAfterTumble = GetDistance(AfterTumblePos, target)
  
          if GetDistance(target) > 630 and DistanceAfterTumble < 630 then
          CastSkillShot(_Q,mousePos)
          end
        end
		
		if IsReady(_E) and VayneMenu.Combo.E.Enabled:Value() and ValidTarget(target, 710) then
        StunThisPleb(target)
        end

        if IsReady(_R) and VayneMenu.Combo.R.Enabled:Value() and ValidTarget(target, VayneMenu.Combo.R.Renemyrange:Value()) and GetPercentHP(target) <= VayneMenu.Combo.R.Rifthp:Value() and GetPercentHP(myHero) <= VayneMenu.Combo.R.Rifhp:Value() and EnemiesAround(GetOrigin(myHero), VayneMenu.Combo.R.Renemyrange:Value()) >= VayneMenu.Combo.R.Rminenemy:Value() and AlliesAround(GetOrigin(myHero), VayneMenu.Combo.R.Rallyrange:Value()) >= VayneMenu.Combo.R.Rminally:Value() then
        CastSpell(_R)
	end
	
		---- bug with this, doesn't go back to attacking if still in KeepInvisdis but not invisible[
    if IsStealthed then
		IOW.attacksEnabled = false
		if ValidTarget(target, 660) and GetDistance(target) > VayneMenu.Combo.Q.KeepInvisdis:Value() then --- maybe should add (or not IsStealthed) here
			IOW.attacksEnabled = true
		elseif not IsStealthed then
			IOW.attacksEnabled = true
		end
	end
	   --- the bug is between those comments]
   end


	for i,enemy in pairs(GetEnemyHeroes()) do
        
        if IOW:Mode() == "Combo" then	
		  if BRK and IsReady(BRK) and VayneMenu.Combo.Items:Value() and ValidTarget(enemy, 550) and GetPercentHP(myHero) < VayneMenu.Combo.myHP:Value() and GetPercentHP(enemy) > VayneMenu.Combo.targetHP:Value() then
          CastTargetSpell(enemy, BRK)
          end

          if YMG and IsReady(YMG) and VayneMenu.Combo.Items:Value() and ValidTarget(enemy, 600) then
          CastSpell(YMG)
          end	
        end
        
	end
        
	--if IsReady(_E) and VayneMenu.Misc.EMenu[GetObjectName(enemy).."Pleb"]:Value() and ValidTarget(enemy, 710) then --- expected user data or some shit idk? problem with GetObjectName
    --    StunThisPleb(enemy)
    --end

    if IsReady(_E) and VayneMenu.Misc.lowhp:Value() and GetPercentHP(myHero) <= 15 and ValidTarget(enemy,375) and getDistance(enemy) < 351   then
        CastTargetSpell(enemy, _E)
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
        local EPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit),2000,250,GetCastRange(myHero,_E),1,false,true)
        local PredPos = Vector(EPred.PredPos)
        local HeroPos = Vector(myHero)
        local maxERange = PredPos - (PredPos - HeroPos) * ( - VayneMenu.Combo.E.pushdistance:Value() / GetDistance(EPred.PredPos))
        local shootLine = Line(Point(PredPos.x, PredPos.y, PredPos.z), Point(maxERange.x, maxERange.y, maxERange.z))
       	for i, Pos in pairs(shootLine:__getPoints()) do
          if MapPosition:inWall(Pos) then
          CastTargetSpell(unit, _E) 
          end
        end
end


AddGapcloseEvent(_E, 550, true, VayneMenu)

PrintChat(string.format("<font color='#1244EA'>Vayne:</font> <font color='#FFFFFF'> Script Loaded! </font>"))
PrintChat("Have Fun: " ..GetObjectBaseName(myHero)) 
PrintChat("This Script Was Originally Made By Deftsu, Now Revamped And Updated By Some Dumb Fuck, kthx")
