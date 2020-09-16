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


--constructors i need in lua for predictionInput
function PredictionInput:__init(unit, delay)
  self.Unit = unit
  self.Delay= delay
end

function PredictionInput:__init(unit, delay, radius)
  self.Unit = unit
  self.Delay= delay
  self.Radius= radius
end

function PredictionInput:__init(unit, delay, radius, speed)
  self.Unit = unit
  self.Delay= delay
  self.Radius= radius
  self.Speed= speed
end

function PredictionInput:__init(unit, delay, radius, speed, collisionable)
  self.Unit = unit
  self.Delay= delay
  self.Radius= radius
  self.Speed= speed
  self.CollisionObjects= collisionable
end

function PredictionInput:getFrom() 
  if self._from:to2D():valid() then
    return self._from
  else
    return player.serverPos
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
    return player.serverPos
  end
end

  -- <summary>
  --     Gets the real radius.
  -- </summary>
  -- <value>The real radius.</value>

function PredictionInput:getRealRadius()
  if self.UseBoundingRadius then
    return self.Radius + self.Unit.boundingRadius
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


---------PREDICTION OUTPUT CONSTRUCTOR ---------------
function PredictionOutput:__init(input)
  self.Input = input
end
function PredictionOutput:__init(castPosition, unitPosition, hitchance)
  self._castPosition = castPosition
  self._unitPosition = unitPosition
  self.HitChance = hitchance
end
function PredictionOutput:__init(input, castPosition, unitPosition, hitchance)
  self.Input = input
  self._castPosition = castPosition
  self._unitPosition = unitPosition
  self.HitChance = hitchance
end


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
    return self.Input.Unit.serverPos
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
    return self.Input.Unit.serverPos
  end
end

function PredictionOutput:setUnitPosition(value)
  self._unitPosition = value;
end


-- <summary>
--     Class used for calculating the position of the given unit after a delay.
-- </summary>
local Prediction = class "Prediction"

---need to addd menu, will check later if neded



-- <summary>
--     Gets the prediction.
-- </summary>
-- <param name="unit">The unit.</param>
-- <param name="delay">The delay.</param>
-- <returns>PredictionOutput.</returns>
-- parameter is of type input with unit, delay,radius,speed, collisionable
function Prediction:getPrediction(unit,delay)
  return Prediction:getPrediction(predictionInput(unit,delay))
end

function Prediction:getPrediction(unit,delay, radius)
  return Prediction:getPrediction(predictionInput(unit,delay,radius))
end

function Prediction:getPrediction(unit,delay, radius,speed)
  return Prediction:getPrediction(predictionInput(unit,delay,radius,speed))
end
function Prediction:getPrediction(unit,delay, radius,speed, collisionable)
  return Prediction:getPrediction(predictionInput(unit,delay,radius,speed, collisionable))
end

function Prediction:getPrediction(input)
  return Prediction:getPrediction(input, true , true)
end



function Prediction:getDashingPrediction(input)
  local dashData = input.Unit.path
  local result= PredictionOutput(input)

  ---- here i need to make a check to see if the dash is not a blink
  if dashData.isDashing then
    local endP = dashData.endPos
    local getPositionOnPath()
  end
end

function Prediction:getImmobilePrediction( input, remainingImmobileT)
  local timeToReachTargetPosition = input.Delay + input.Unit.pos:dist(input.getFrom()) / input.Speed;
  if (timeToReachTargetPosition <= remainingImmobileT + input.getRealRadius() / input.Unit.moveSpeed) then
    return PredictionOutput(input.Unit.pos, input.Unit.pos, HitChance.Immobile)
  end
  -- if not, imma still cast there as chance are pretty high
  return PredictionOutput(input, input.Unit.serverPos, inputUnit.serverPos, HitChance.High)
end

--- here path is a table of vec2

function Prediction:getPositionOnPath(input, path, speed)
  -- kind of ternary operator
  if not speed then
    speed= -1
  end
  if math.abs(speed - (-1)) < 0.00000000001 then-- should compare to epsilon but should be fine here
    speed= input.Unit.moveSpeed
  else
    speed= speed
  end
  if #path <= 1 then
    return PredictionOutput(input, input.Unit.serverPos, input.Unit.serverPos, HitChance.VeryHigh)
  end
  local pLenght= path[0]:dist(path[1])
  --skillshots with only a de;ay
  if pLenght >= input.Delay * speed - input.getRealRadius() && math.abs(input.Speed - 100000000000) < 0.0000000001 then
    
  end
end
print("end of dobby pred")