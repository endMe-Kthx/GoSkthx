if GetObjectName(GetMyHero()) ~= "Vayne" then return end

if not pcall( require, "MapPositionGOS" ) then PrintChat("You are missing Walls Library - Go download it and save it Common!") return end
if not pcall( require, "Inspired" ) then PrintChat("You are missing Inspired.lua - Go download it and save it Common!") return end

local VayneMenu = MenuConfig("Vayne", "Vayne")
VayneMenu:Menu("Combo", "Combo")
VayneMenu.Combo:Menu("Q", "Tomble (Q)")
VayneMenu.Combo.Q:Boolean("Enabled", "Enabled", true)

VayneMenu.Combo:Menu("E", "Condemn (E)")
VayneMenu.Combo.E:Boolean("Enabled", "Enabled", true)
VayneMenu.Combo.E:Slider("pushdistance", "E Push Distance", 400, 350, 490, 1)


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


OnTick(function(myHero)
    local target = GetCurrentTarget()

	if IOW:Mode() == "Combo" then
	
	if IsReady(_E) and VayneMenu.Combo.E.Enabled:Value() and ValidTarget(target, 710) then
        StunThisPleb(target)
    end
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


PrintChat("uMM, good Vain Scriptu? - made by a wild nib. kthx")
