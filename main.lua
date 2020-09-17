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

-- this returns a table of vec2, ported from utility CS
function CutPath( path, distance)
  local result = {}
  local Distance = distance;
  if (distance < 0) then 
    path[0] = path[0] + distance * (path[1] - path[0]):norm();
    return path;
  end
  for i = 0, #path.Count - 1 do 
    local dist = path[i]:dist(path[i + 1])
    if (dist > Distance) then
      table.insert(result, path[i] + Distance * (path[i + 1] - path[i]).norm())
      for j= i+1, #path do
        table.insert( result,path[j] )
      end
      break
    end
    Distance = Distance - dist;
  end
  if (#result.Count > 0) then
    return result
  else
    local last = {}
    table.insert( last,path[#path] )
    return last
  end
end

 ----------- COllsinion ported from geometry
-- <summary>
        --     Gets the vectors movement collision.
        -- </summary>
        -- <param name="startPoint1">The start point1.</param>
        -- <param name="endPoint1">The end point1.</param>
        -- <param name="v1">The v1.</param>
        -- <param name="startPoint2">The start point2.</param>
        -- <param name="v2">The v2.</param>
        -- <param name="delay">The delay.</param>
        -- <returns></returns>
function VectorMovementCollision(startPoint1,endPoint1,v1,startPoint2,v2,delay)
  if not delay then
    delay= 0
  end
  local sP1x = startPoint1.X
  local sP1y = startPoint1.Y
  local eP1x = endPoint1.X
  local eP1y = endPoint1.Y
  local sP2x = startPoint2.X
  local sP2y = startPoint2.Y
  local d = eP1x - sP1x
  local e = eP1y - sP1y
  local dist = math.sqrt(d * d + e * e)
  local t1 = nil
  local S
  local K
  if math.abs(dist) > 0.0000000000001 then
    S= v1 * d / dist
  else
    S=0
  end
  if (math.abs(dist) >  0.0000000000001) then
    K= v1 * e / dist
  else
    K = 0
  end
  local r = sP2x - sP1x
  local j = sP2y - sP1y
  local  c = r * r + j * j
  if (dist > 0) then
    if (math.abs(v1 - 1000000000) < 0.0000000000001) then
      local t = dist / v1
      if (2 * t >= 0) then
        t1=t
      else
        t1=nil
      end
    elseif (math.abs(v2 - 1000000000) < 0.0000000000001) then
      t1 = 0
    else
      local a = S * S + K * K - v2 * v2 
      local b = -r * S - j * K
      if (math.abs(a) < 0.0000000000001) then
        if (math.abs(b) < 0.0000000000001) then
          if math.Abs(c) <  0.0000000000001 then
            t1=0
          else
            t1=nil
          end
        else
          local t = -c / (2 * b)
          if  (v2 * t >= 0) then
            t1=t
          else
            t1= nil
          end
        end    
      else
        local sqr = b * b - a * c;
        if (sqr >= 0) then
          local nom = math.sqrt(sqr)
          local t = (-nom - b) / a
          if v2 * t >= 0 then
            t1= t
          else
            t1= nil
          end
          t = (nom - b) / a
          if v2 * t >= 0 then
            t2= t
          else
            t2= nil
          end
          if ((t2) && (t1)) then
            if (t1 >= delay && t2 >= delay) then
              t1 = Math.Min(t1, t2)
            elseif (t2 >= delay) then
              t1 = t2
            end
          end
        end
      end
    end
  elseif (math.abs(dist) < 0.0000000000001) then
    t1 = 0
  end
  local vector
  if t1 then
    vector= vec2(sP1x + S * t1, sP1y + K * t1)
  else
    vector= vec2(0,0)
  end
  local newObject = {t1, vector}
end


--- import from from dobby LEE

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
SkillshotLine= 1,

-- <summary>
--     The skillshot is circular.
-- </summary>
SkillshotCircle= 2,

-- <summary>
--     The skillshot is conical.
-- </summary>
SkillshotCone=3
}

-- <summary>
--     Objects that cause collision to the spell.
-- </summary>
local CollisionableObjects = {
-- <summary>
--     Minions.
-- </summary>
Minions=1,

-- <summary>
--     Enemy heroes.
-- </summary>
Heroes=2,

-- <summary>
--     Yasuo's Wind Wall (W)
-- </summary>
YasuoWall=3,

-- <summary>
--     Walls.
-- </summary>
Walls=4,

-- <summary>
--     Ally heroes.
-- </summary>
Allies=5
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
PredictionInput.Unit = player

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
--[[
function PredictionInput:__init(...)
  self["__init" .. select("#", ...)](self, ...)
end
function PredictionInput:__init0(unit, delay)
  self.Unit = unit
  self.Delay= delay
end

function PredictionInput:__init1(unit, delay, radius)
  self.Unit = unit
  self.Delay= delay
  self.Radius= radius
end

function PredictionInput:__init2(unit, delay, radius, speed)
  self.Unit = unit
  self.Delay= delay
  self.Radius= radius
  self.Speed= speed
end
]]
function PredictionInput:__init(unit, delay, radius, speed, collisionable)
  self.Unit = unit
  self.Delay= delay or 0 --default
  self.Radius= radius or 0 --default
  self.Speed= speed or 0 -- default
  self.CollisionObjects= collisionable or {}
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
function PredictionInput:setRangeCheckFrom(value)
  self._rangeCheckFrom= value
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
--[[
function PredictionInput:__init(...)
  self["__init" .. select("#", ...)](self, ...)
end
function PredictionOutput:__init0(input)
  self.Input = input
end
function PredictionOutput:__init1(castPosition, unitPosition, hitchance)
  self._castPosition = castPosition
  self._unitPosition = unitPosition
  self.HitChance = hitchance
end]]
function PredictionOutput:__init(input, castPosition, unitPosition, hitchance)
  self.Input = input
  if castPosition then self._castPosition = castPosition end
  if unitPosition then  self._unitPosition = unitPosition end
  if hitchance then self.HitChance = hitchance end

end


-- <summary>
--     The number of targets the skillshot will hit (only if aoe was enabled).
-- </summary>
-- <value>The aoe targets hit count.</value>
function PredictionOutput:getAoeTargetsHitCount()
  return math.max(self._aoeTargetsHitCount, #(self.AoeTargetsHit));
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
    --local getPositionOnPath()
  end
end

function Prediction:getImmobilePrediction( input, remainingImmobileT)
  local timeToReachTargetPosition = input.Delay + input.Unit.pos:dist(input:getFrom()) / input.Speed;
  if (timeToReachTargetPosition <= remainingImmobileT + input:getRealRadius() / input.Unit.moveSpeed) then
    return PredictionOutput(nil, input.Unit.serverPos, input.Unit.pos, HitChance.Immobile)
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
  if pLenght >= input.Delay * speed - input:getRealRadius() && math.abs(input.Speed - 100000000000) < 0.0000000001 then
    local tDistance = input.Delay * speed - input:getRealRadius()
    for i= 0,#path do
      local a= path[i]
      local b= path[i+1]
      local d = a:dist(b)
      if  d >= tDistance then
        local direction= (b-a).norm()
        local cp = vec2(a.x + direction.x * tDistance, a.y + direction.y * tDistance)
        local intermediateValue
        if i == #path-2 then
          intermediateValue =  math.min(tDistance, input:getRealRadius(), d)
        else
          intermediateValue = tDistance + input:getRealRadius()
        end
        local p = a + direction * intermediateValue
        local hitchance
        if pred.trace.newpath(input.Unit, 0 , 0.1) then
          hitchance= HitChance.VeryHigh
        else
          hitchance= HitChance.High
        end
        return PredictionOutput(input, vec3(cp), vec3(p), hitchance)
        --function PredictionOutput:__init(input, castPosition, unitPosition, hitchance)
      end
      tDistance= tDistance-d
    end
  end
  if pLenght >= input.Delay * speed - input:getRealRadius() && math.abs(input.Speed - 100000000000) > 0.0000000001 then
    if input.Type == SkillshotType.SkillshotLine or input.Type == SkillshotType.SkillshotCone then
      local d= input.Delay * speed - input:getRealRadius()
      if input:getFrom():distSqr(input.Unit.serverPos) < 200 * 200 then
        d= input.Delay * speed
      end
    end
    path = CutPath(path, d)
    local tT = 0
    for i = 0, #path-1 do
      local a= path[i]
      local b= path[i+1]
      local tB = a:dist(b) / speed
      local direction = (b-a).norm()
      a= a - speed * tT * direction
      local sol = VectorMovementCollision(a, b, speed,input:getFrom():to2D(), input.Speed,tT)
      local t = sol[0]
      local pos = sol[1]
      if pos:valid() and t >= tT and t <= tT + tB then
        if pos:distSqr(b) < 20 then 
          break
        end
        local p = pos + input:getRealRadius() * direction
        if input.Type ==  SkillshotType.SkillshotLine && false then
          local alpha = (input:getFrom():to2D() - p):angle(a-b)
          if alpha > 30 and alpha < 180 - 30 then
            local beta = math.asin( input:getRealRadius()/ p:dist(input:getFrom()))
            local cp1= input:getFrom():to2D() + (p -  input:getFrom():to2D()).rotate(beta)
            local cp2= input:getFrom():to2D() + (p -  input:getFrom():to2D()).rotate(-beta)
            if cp1:distSqr(pos) < cp2:distSqr(pos) then
              pos= cp1
            else
              pos= cp2
            end
          end
        end
        local hitchance
        if pred.trace.newpath(input.Unit, 0 , 0.1) then
          hitchance= HitChance.VeryHigh
        else
          hitchance= HitChance.High
        end
        return {input, pos:to3D(), p:to3D(), hitchance}
      end
    end
  end
  local position = path[#path]
  return {input, position:to3D(), position:to3D(), HitChance.Medium}
end
print("end of dobby pred")