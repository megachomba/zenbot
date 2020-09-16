local orb = module.internal('orb')
local ts = module.internal('TS')
local pred = module.internal('pred')
local damage = module.internal('damage')

print("Dobby Pred loadaded")


  --- SET Z PORTED from lsharp geometry
function setZ(v, value)
  if value == nil then
    return vec3(v.x,v.y, game.mousePos.z)
  else
    return vec3(v.x,v.y, value)
  end
end

local  HitChance = {
-- <summary>
--     The target is immobile.
-- </summary>
Immobile = 8,

-- <summary>
--     The unit is dashing.
-- </summary>
Dashing = 7,

-- <summary>
--     Very high probability of hitting the target.
-- </summary>
VeryHigh = 6,

-- <summary>
--     High probability of hitting the target.
-- </summary>
High = 5,

-- <summary>
--     Medium probability of hitting the target.
-- </summary>
Medium = 4,

-- <summary>
--     Low probability of hitting the target.
-- </summary>
Low = 3,

-- <summary>
--     Impossible to hit the target.
-- </summary>
Impossible = 2,

-- <summary>
--     The target is out of range.
-- </summary>
OutOfRange = 1,

-- <summary>
--     The target is blocked by other units.
-- </summary>
Collision = 0
}
-- <summary>
--     The type of skillshot.
-- </summary>
local SkillshotType={
-- <summary>
--     The skillshot is linear.
-- </summary>
SkillshotLine,

-- <summary>
--     The skillshot is circular.
-- </summary>
SkillshotCircle,

-- <summary>
--     The skillshot is conical.
-- </summary>
SkillshotCone
}

-- <summary>
--     Objects that cause collision to the spell.
-- </summary>
local CollisionableObjects = {
-- <summary>
--     Minions.
-- </summary>
Minions,

-- <summary>
--     Enemy heroes.
-- </summary>
Heroes,

-- <summary>
--     Yasuo's Wind Wall (W)
-- </summary>
YasuoWall,

-- <summary>
--     Walls.
-- </summary>
Walls,

-- <summary>
--     Ally heroes.
-- </summary>
Allies
}

-- <summary>
--     Contains information necessary to calculate the prediction.
-- </summary>
local PredictionInput = class "PredictionInput"

-- <summary>
--     If set to <c>true</c> the prediction will hit as many enemy heroes as posible.
-- </summary>
PredictionInput.Aoe = false

-- <summary>
--     <c>true</c> if the spell collides with units.
-- </summary>
PredictionInput.Collision = false

-- <summary>
--     Array that contains the unit types that the skillshot can collide with.
-- </summary>
PredictionInput.CollisionObjects = {
  CollisionableObjects.Minions, CollisionableObjects.YasuoWall
}

-- <summary>
--     The skillshot delay in seconds.
-- </summary>
PredictionInput.Delay=0

-- <summary>
--     The skillshot width's radius or the angle in case of the cone skillshots.
-- </summary>
PredictionInput.Radius = 1

-- <summary>
--     The skillshot range in units.
-- </summary>
PredictionInput.Range = 100000

-- <summary>
--     The skillshot speed in units per second.
-- </summary>
PredictionInput.Speed = 100000

-- <summary>
--     The skillshot type.
-- </summary>
PredictionInput.Type = SkillshotType.SkillshotLine

-- <summary>
--     The unit that the prediction will made for.
-- </summary>
PredictionInput.Unit = objManager.player

-- <summary>
--     Set to true to increase the prediction radius by the unit bounding radius.
-- </summary>
PredictionInput.UseBoundingRadius = true

-- <summary>
--     The position that the skillshot will be launched from.
-- </summary>
PredictionInput._from = player.pos

-- <summary>
--     The position to check the range from.
-- </summary>
PredictionInput._rangeCheckFrom = player.pos

function PredictionInput:getFrom() 
  if self._from:to2D():valid() then
    return self._from
  else
    return objManager.player.pos
  end
end


function PredictionInput:setFrom(value) 
  self._from = value
end
  


-- <summary>
--     The position from where the range is checked.
-- </summary>
-- <value>The range check from.</value>


function PredictionInput:getRangeCheckFrom()
  if self._rangeCheckFrom:to2D():valid() then
    return self._rangeCheckFrom
  else
    return self._rangeCheckFrom
  end
end

  -- <summary>
  --     Gets the real radius.
  -- </summary>
  -- <value>The real radius.</value>

function PredictionInput:getRealRadius()
  if self.UseBoundingRadius then
    return self.Radius + self.Unit.BoundingRadius
  else
    return self.Radius
  end
end




-- <summary>
--     The output after calculating the prediction.
-- </summary>
local PredictionOutput = class "PredictionOutput"

-- <summary>
--     The list of the targets that the spell will hit (only if aoe was enabled).
-- </summary>
PredictionOutput.AoeTargetsHit ={};

-- <summary>
--     The list of the units that the skillshot will collide with.
-- </summary>
PredictionOutput.CollisionObjects = {};

-- <summary>
--     Returns the hitchance.
-- </summary>
PredictionOutput.Hitchance = HitChance.Impossible;

-- <summary>
--     The AoE target hit.
-- </summary>
PredictionOutput._aoeTargetsHitCount= 0

-- <summary>
--     The input
-- </summary>
PredictionOutput.Input = nil

-- <summary>
--     The calculated cast position
-- </summary>
PredictionOutput._castPosition = player.pos

-- <summary>
--     The predicted unit position
-- </summary>
PredictionOutput._unitPosition = player.pos

-- <summary>
--     The number of targets the skillshot will hit (only if aoe was enabled).
-- </summary>
-- <value>The aoe targets hit count.</value>
function PredictionOutput:getAoeTargetsHitCount()
  return math.max(self._aoeTargetsHitCount, self.AoeTargetsHit.Count);
end
-- <summary>
--     The position where the skillshot should be casted to increase the accuracy.
-- </summary>
-- <value>The cast position.</value>


      
function PredictionOutput:getCastPosition()
  if self._castPosition:valid() && self._castPosition:to2D():valid() then
    return setZ(self._castPosition)
  else
    return self.Input.Unit.pos
  end
end
function PredictionOutput:setCastPosition(value)
  self._castPosition = value;
end
      
-- <summary>
--     The position where the unit is going to be when the skillshot reaches his position.
-- </summary>
-- <value>The unit position.</value>
function PredictionOutput:getUnitPosition()
  if self._unitPosition:to2D():valid() then
    return setZ(self._unitPosition)
  else
    return self.Input.Unit.pos
  end
end

function PredictionOutput:setUnitPosition(value)
  self._unitPosition = value;
end
print("end of dobby pred")