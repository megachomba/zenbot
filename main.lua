local orb = module.internal('orb')
local ts = module.internal('ts')
local pred = module.internal('pred')
local damage = module.internal('damage')
local evade= module.internal('evade')
local ToUpdate = {};
ToUpdate.Version = 2;
ToUpdate.UseHttps = true;
ToUpdate.Host = "github.com";
ToUpdate.VersionPath = "/megachomba/zenbot/blob/master/version.txt";
ToUpdate.ScriptPath =  "/megachomba/zenbot/blob/master/Dobbylee.zen";
ToUpdate.SavePath = zenbot.path .. "scripts\\" .. module.path("Dobbylee");
ToUpdate.CallbackUpdate = function(NewVersion, OldVersion)
    chat.print("<font color=\"#FF794C\"><b>Your File: </b></font> <font color=\"#FFDFBF\">Updated to "..NewVersion..". </b></font>");
    zenbot.reload();
end
ToUpdate.CallbackNoUpdate = function(OldVersion)
    chat.print("<font color=\"#FF794C\"><b>Your File: </b></font> <font color=\"#FFDFBF\">No Updates Found</b></font>");
    load_my_script();
end
ToUpdate.CallbackNewVersion = function(NewVersion)
    chat.print("<font color=\"#FF794C\"><b>Your File: </b></font> <font color=\"#FFDFBF\">New Version found ("..NewVersion.."). Please wait until its downloaded</b></font>");
end
ToUpdate.CallbackError = function(NewVersion)
    chat.print("<font color=\"#FF794C\"><b>Your File: </b></font> <font color=\"#FFDFBF\">Error while Downloading. Please try again.</b></font>");
end
ToUpdate.io = _G.io -- store io, it gets removed after your script runs

cb.add(cb.load,
    function()
        module.load("Dobbylee", "update")(
            ToUpdate.Version,
            ToUpdate.UseHttps,
            ToUpdate.Host,
            ToUpdate.VersionPath,
            ToUpdate.ScriptPath,
            ToUpdate.SavePath,
            ToUpdate.CallbackUpdate,
            ToUpdate.CallbackNoUpdate,
            ToUpdate.CallbackNewVersion,
            ToUpdate.CallbackError,
            ToUpdate.io
        );
    end
)
zenbot.auth()("14fa75c1d9f32fba16a9", function(authed, time_remaining)
  if (authed) then
    local d = math.floor(time_remaining / (3600*24))
    local h = math.floor(time_remaining % (3600*24) / 3600)
    local m = math.floor(time_remaining % 3600 / 60)
    local s = time_remaining % 60
    print("Time left: ".. d .. "d:" .. h .. "h:" .. m .. "m:" .. s .. "s")
    local menu = menu("Dobby Lee", "Lee Sin")

    menu:header("combo_header", "Combo")
    
    menu:boolean("q_combat", "use Q", true)
    menu:boolean("e_combat", "use E", true)
    menu:boolean("w1_combat", "use W1 (only if in AA range)", true)
    menu:boolean("q2_finisher", "use Q2 to execute", true)
    menu:boolean("r_finisher", "use R to execute", true)
    menu:boolean("smite_minion", "use smite on minion for q+smite target", true)
    menu:boolean("use_tiamat", "use Tiamat (disable on activator)", true)
    menu:boolean("safe_insec", "use safeInsec", true)
    menu:slider("enemy_count", "Enemey count for safe insec",1,0,5,1)
    menu:slider("enemy_count_range", "Enemey search radius for safe insec",1000,0,4000,100)
    menu:keybind("insec_key", "insec key (hold or toggle)", "A", "Z", true)
    menu:boolean("disable_evade", "Disable evade while insec (recomended)", true)
    menu:header("drawings","drawings")
    menu:boolean("wq_draw", "draw W+Q range", true)
    menu:boolean("q_draw", "draw Q range", true)
    menu:boolean("e_draw", "draw E range", true)
    menu:boolean("draw_insec", "draw selected INSEC target", true)
    print("Dobby lee Loaded!")
    
    
    local  q_pred_input = {
      delay = 0.2,
      radius= 60,
      speed= 1800,
      range = 1200,
      boundingRadiusMod=1,
      collision = {
        wall = true,
        minion = true,
        hero= true,
      },
    }
    local  q_pred_input_no_collision = {
      delay = 0.2,
      radius= 60,
      speed= 1800,
      range = 1200,
      boundingRadiusMod=1,
      collision = {
        wall = true,
        hero= true,
      },
    }
    local w_pred_input = {
      --radius = 300,
      --witdh= 100,
      speed= 1750,
      --range = 1200,  
    }
    local e_pred_input = {
      radius = 425,
      --witdh= 100,
      --speed= 1750,
      range = 425,  
    }
    
    local active_pred_input = nil
    local currentSelectedInsecTarget = nil
    local insecState = nil
    local globalClosestAlly = nil
    local timeR= 0
    local timeRforSafe = 0
    local delayRFlash= 0.01
    local imInQ2 = false
    local imInQ2Object = nil
    
    local lastQ= nil
    local didQhit = false
    local didQdeleted= false
    local Q1LastAttepmt = nil
    
    
    
    local minionfound = nil
    local gapcloseCandidate = nil
    local lastWardPlaced = nil
    local fleeState= nil
    local fleeWard= nil
    local evadeWasActive=false
    local q1timer= 0 
    local wherePlaceWard= nil
    local tiamatState= nil

    local wtimer=nil
    local etimer= nil
    local networkdelay= 0.02
    local minionToSmite= nil
    local smiteState= nil
    -------------------------- MATH FUNCTIONS -----------------------------------------
    
    local function angle(a,b,c)
      --[[--local ab = { b.x - a.x, b.y - a.y };
      local abx
      local aby
      local cbx
      local cby
      abx= b.x - a.x
      aby=b.y - a.y
      --local cb = { b.x - c.x, b.y - c.y };
      cbx=  b.x - c.x
      cby=  b.y - c.y
      local dot = (abx * cbx + aby * cby) -- dot product
      local cross = (abx * cby - aby * cbx) -- cross product
      print("")
      --local alpha = math.atan2(cross, dot)
      local alpha = math.atan(cross, dot)
      local pi = 3.141592
      return  math.deg(math.floor(alpha * 180 / pi + 0.5))]]
      local deg = math.deg(math.atan(c.y - b.y, c.x - b.x) - math.atan(a.y - b.y, a.x - b.x))
    
        if deg < -180 then
            deg = deg + 360
        elseif deg < 0 then
            deg = -deg
        end
    
        return deg
    end
    
    
    
    
    
    
    
    ------- LOGIC ------------------------
    
    
    
    
    
    local function getFlash()
      if( player:spellState( SpellSlot.Summoner1 ) == SpellState.Ready && player:spellSlot( SpellSlot.Summoner1 ).name == "SummonerFlash") then
        return SpellSlot.Summoner1
      end
      if( player:spellState( SpellSlot.Summoner2 ) == SpellState.Ready && player:spellSlot( SpellSlot.Summoner2 ).name == "SummonerFlash" ) then
        return SpellSlot.Summoner2
      end
      return nil
    end
    
    local function getSmite()
      if( player:spellState( SpellSlot.Summoner1 ) == SpellState.Ready && (player:spellSlot( SpellSlot.Summoner1 ).name == "SummonerSmite" or player:spellSlot( SpellSlot.Summoner1 ).name == "S5_SummonerSmiteDuel"  or player:spellSlot( SpellSlot.Summoner1 ).name == "S5_SummonerSmitePlayerGanker" )) then
        return SpellSlot.Summoner1
      end
      if( player:spellState( SpellSlot.Summoner2 ) == SpellState.Ready && (player:spellSlot( SpellSlot.Summoner2 ).name == "SummonerSmite" or player:spellSlot( SpellSlot.Summoner2 ).name == "S5_SummonerSmiteDuel"  or player:spellSlot( SpellSlot.Summoner2 ).name == "S5_SummonerSmitePlayerGanker" )) then
        return SpellSlot.Summoner2
      end
      return nil
    end

    local function getTiamat()
      -- we check if we have wards

      for i = 0, 6 do
          local item_id = player:itemID( i )
          if( (item_id == 3077 or item_id== 3748 or item_id==3074) && player:spellState( SpellSlot.Item1 + i ) == SpellState.Ready ) then
              return SpellSlot.Item1 + i
          end
      end
      return nil
    end
    
    local function getTrinket()
      -- we check if we have wards
      if( player:spellState( SpellSlot.Trinket ) == SpellState.Ready && player:spellSlot( SpellSlot.Trinket ).name == "TrinketTotemLvl1" ) then
        return SpellSlot.Trinket
      end
    
      for i = 0, 6 do
          local item_id = player:itemID( i )
          if( item_id == 2055 && player:spellState( SpellSlot.Item1 + i ) == SpellState.Ready ) then
              return SpellSlot.Item1 + i
          end
      end
      return nil
    end
    --wardashfunction
    local  function wq(position)
      if player:spellSlot(1).state ~= 0 or w1hit then
        return false
      end
      if getTrinket() then
        if player:castSpell("pos", getTrinket(), position) && player:castSpell("pos", 1, position) then
          print("i should've ward dashed")
          return true
        end
      end 
      return false
    end
    
    
    local function trace_filter(seg, obj)
      print("tracefilted called?")
      if seg.startPos:dist(seg.endPos) > active_pred_input.range then
        print("seg range problem")
        return false 
      end
      if pred.trace.linear.hardlock(active_pred_input, seg, obj) then
        print("hardlock")
        return true
      end
      if pred.trace.linear.hardlockmove(active_pred_input, seg, obj) then
        print("hardlockMove")
        return true
      end
      if (not orb.core.can_spell(0.2)) then
        print("new option fking")
        return false
      end
      --[[need to check this, coz he checks if target path has updated between 0.033, and 0.500 ms ago wich is weird to return true ]]
      if pred.trace.newpath(obj,  0.033, 0.500) then
        print("newpath")
        return true
      end
      return true
    end
    --[[ fonctions that returns if target  returned from target selector is at a certain dist ]]
    local function q_target_filter(res, obj, dist)
      local seg, seg2 = pred.linear.get_prediction(active_pred_input, obj)
      --print("some debug", obj.name)
      if not seg then
        print("there is no seg, imma check if there is a seg2 with only a minion")
        if menu.smite_minion:get() then
          if seg2 && seg2.hitchance == Hitchance.Collision then
            -- i check if i have smite and if there is only one minion in the way
            print("seg2 has colision, let me check the count",#seg2.collisionObjects)
            if seg2.collisionObjects && (#seg2.collisionObjects == 1) then
              -- here i  found a path where there is only a minion inbtween, gonna check if i can smite it
              for k, minion in pairs(seg2.collisionObjects) do
                if (minion.isLaneMinion or minion.isSuperMinion or minion.isSiegeMinion) && (minion.health > 0)  && getSmite() then
                  -- i check if mmy smite dmg is enough
                  local dmgToMinion = damage.spell(player, minion, getSmite())
                  print("smite dmg", dmgToMinion)
                  if dmgToMinion < minion.health then
                    print("minion too much health")
                    return false
                  else
                    print("found smiteable minion, now i need to make all other seg checks")
                    if not trace_filter(seg2, obj) then 
                      print("tracefilter seg2 returning false")
                      return false 
                    end
                    if seg2.endPos:dist(player.pos2D) > active_pred_input.range then 
                      print("target to far for seg2")
                      return false
                    end
                    -- im going to predict if minion will be in range when Q hits it
                    print("i can Q1 there, now i check if minion will be in range")
                    local minionSeg= pred.linear.get_prediction(active_pred_input, minion)
                    if not minionSeg then
                      print("no minion seg")
                      return false
                    end
                    if not trace_filter(minionSeg, minion) then 
                      print("tracefilter returning false")
                      return false 
                    end
                    -- here i check if minion will be in smite range
                    if minionSeg.endPos:dist(player.pos2D) > 499 then 
                      return false
                    end
                    print("FINAL, found minion to smite",minion.name)
                    res.pos = seg2.endPos
                    res.target= obj
                    minionToSmite= minion
                    return true
                  end
                else
                  return false
                end
              end
            else 
              return false
            end
          end
        end
        return false 
      end
      if not trace_filter(seg, obj) then 
        print("tracefilter returning false")
        return false 
      end
      if seg.endPos:dist(player.pos2D) > active_pred_input.range then 
        return false
      end
      res.pos = seg.endPos
      res.target= obj
      print("XXXXXXXXXXXXXXXXXXXXXXXXX      X", obj.name)
            -- i check if my target selected is the one i wanted to insec
      --[[if obj.name == ts.selected_target().name then
        print("the target to whom imma gonna Q is the one i want to insec")
        res.itsInsecTarget= true
      end]]
      return true
    end
    
    local function e_target_filter(res, obj, dist)
      local seg = pred.linear.get_prediction(active_pred_input, obj)
      if not seg then
        return false 
      end
      if not trace_filter(seg, obj) then 
        print("tracefilter returning false")
        return false 
      end
      res.pos = seg.endPos
      res.target= obj
      -- i check if my target selected is the one i wanted to insec
      --[[if obj.name == ts.selected_target().name then
        print("the target to whom imma gonna Q is the one i want to insec")
        res.itsInsecTarget= true
      end]]
      return true
    end
    
    local function e1_logic()
      -- if im in insec, i just get out
      if menu.insec_key:get() then
        return false
      end
      if player:spellSlot(2).state ~= 0 then return end
      if (not orb.core.can_action()) then
        return false
      end
      active_pred_input= e_pred_input
      local res = ts.get_result(e_target_filter)
      if res.pos then
        if res.pos:dist(player.pos2D) > 425 then
          return false
        end
        local dmg= damage.spell(player, res.target, SpellSlot.E)
        -- imma check if my auto deals more dmg than my E
        local aadmg=damage.autoattack(player, res.target, true)
        if dmg > aadmg then
          print("stronger E")
          player:castSpell("self", 2)
          return true
        end
        if dmg >= res.target.health then
          print("EXECUTE E")
           player:castSpell("self", 2)
           return true
        end
        -- calculating if target will get out of E range
        local afterping= pred.core.get_pos_after_time(res.target, 0.25 + network.latency)
        if afterping then
          -- putting 400 coz 425 kinda misses
          if afterping:dist(player.pos2D) > 400 then
            print("caster E")
            player:castSpell("self", 2)
            return true
          end
        end
        
        if player.buff["blindmonkpassive_cosmetic"] && not player.buff["blindmonkemanager"] then
          return false
        end
        if player.buff["blindmonkpassive_cosmetic"] && player.buff["blindmonkemanager"] &&  ((player.buff["blindmonkemanager"].endTime -game.time  ) > 0.2) then
          return false
        end

        local t= network.latency + networkdelay
        --if wtimer && (game.time - wtimer) > t
        print("caster E")
        player:castSpell("self", 2)
        return true
      end
      return false
    end
    
    local function q1_logic()
      --print("my state in Q1", insecState, os.clock())
      --print("name of my Q1", player:spellSlot(0).name ,"q1hit?", q1hit )
      if player:spellSlot(0).state ~= 0 or player:spellSlot(0).name== "BlindMonkQTwo" then return end
      if (not orb.core.can_action()) then
        return false
      end
      -- i check if im in safe INsec, so i avoid spamming Q1
    
    
      --putting my target as only focus if there is a hard focus
      print("before res")
      active_pred_input= q_pred_input
      local res = ts.get_result(q_target_filter)
      print("my res", res.pos)
      -- here imma check if there is no Q1 prediction , then imma check if there is a pos without colision
      --[[if not res.pos then
        print("cant Q, checking if i can smite a minion")
        active_pred_input= q_pred_input_no_collision
        res = ts.get_result(q_target_filter)
        counter = 0
        for index in pairs(res.minions) do
          print(index.name)
          counter = counter + 1
        end
        print("my minion count",res, res.minions, counter )
        if res.minions && (#res.minions == 1) then
          -- here i  found a path where there is only a minion inbtween, gonna check if i can smite it
          for minion in res.minions do
            if (minion.isLaneMinion or minion.isSuperMinion or minion.isSiegeMinion) && (minion.health > 0)  && getSmite() then
              -- i check if mmy smite dmg is enough
              local dmgToMinion = damage.spell(player, minon, getSmite())
              print("smite dmg", dmgToMinion)
              if dmgToMinion < minion.health then
                res= nil
              else
                print("found smiteable minion")
                minionToSmite= minion
                break
              end
            else
              res=nil
            end
          end
        else 
          res= nil
        end
      end]]

      if  res && res.pos then
        if menu.insec_key:get() then 
          if insecState=="SAFEINSEC" or insecState=="SAFEINSECRFLASH"  or insecState ~= nil then
            return false
          end
            --R CHECK, if there is no R dont Q2
          if player:spellSlot(3).state ~= 0 then
            return false
          end
          -- i check if the res target is the insec target
          if res.target == currentSelectedInsecTarget   then --or  currentSelectedInsecTarget == nil then
            --- IMMA CHECK IF THERE IS MULTIPLE PEOPLE CLOSE TO MY TARGET TO SAFE INSEC
            -- if it does i change insec state, if not i do normal Q
            if menu.safe_insec:get() then
              local enemiesClose = 0
              for champion in objManager.iheroes do
                --print("target name", champion.name, "dist", champion.pos2D:dist(currentSelectedInsecTarget.pos2D) , "is enemy", champion.isEnemy, " not Dead", (not champion.isDead), "dif from target", champion.id  ~= currentSelectedInsecTarget.id, "the id? ",  champion.index, "range?", menu.enemy_count_range:get())
                if champion.isEnemy &&  (champion.health > 0 )  && (champion.index  ~= res.target.index) then
                  if champion.pos2D:dist(res.target.pos2D) < menu.enemy_count_range:get() then
                    enemiesClose= enemiesClose + 1
                  end
                end
              end
              --print("safeinsec", enemiesClose, "i have flash?", getflash())
              if (enemiesClose >=  menu.enemy_count:get() ) && getFlash() then
                print("conditions met for safeInsec")
                player:castSpell("pos", 0, vec3(res.pos.x, 0, res.pos.z))
                Q1LastAttepmt= "SAFEINSEC"
                -- checking that Q1 did actually fire
                if player:spellSlot(0).state == SpellSlot.Cooldown then
                  insecState= "SAFEINSEC"
                  return true
                else
                  return false
                end
              end
            end
            print(" the target imma gonna Q is the insecTarget")
            player:castSpell("pos", 0, vec3(res.pos.x, 0, res.pos.z))
            Q1LastAttepmt= "INSECQ1"
            -- here retrurning true coz i indeed casted a Q
            return true
            -- here imma check spellslot to see if Q did actually fire
            --[[if player:spellSlot(0).state == SpellSlot.Cooldown then
              print("my Q did ACTUALLY FIRE , CHANGING STATE TO INSECQ1")
              insecState="INSECQ1"
              return true
            else
              -- q did not fire, returning false
              return false
            end]]
          else
            print("FAKKKKKKKKKKKKKKKKKKKKKEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE")
    
            return false
          end
        end
        -- not in sec mode, i throw normal Q to target

        --i check if i can kill with Q1+Q2 instant
        local afterQ1health= res.target.health - damage.spell(player,res.target, SpellSlot.Q) 
        local leeQ2Dmg = (30 + (25 * player:spellSlot(0).level)) + player.totalBonusAttackDamage
        local totalQ2dmg= leeQ2Dmg + (100 - (100 * afterQ1health ) / res.target.maxHealth)
        local dmgMulti = 100/(100 + res.target.armor)
        local finalQ2Dmg = dmgMulti * totalQ2dmg
        if finalQ2Dmg +  damage.spell(player,res.target, SpellSlot.Q)  > res.target.health then  
          print("casting simple Q1+Q2 at ", os.clock(), res.pos.x, res.pos.z )
          player:castSpell("pos", 0, vec3(res.pos.x, 0, res.pos.z))
          Q1LastAttepmt=nil
          return true
        end
        -- here imma check if i can kill with Q1+R2+Q2
        local afterQ1Rhealth= res.target.health - damage.spell(player,res.target, SpellSlot.Q)  - damage.spell(player,res.target, SpellSlot.R)
        leeQ2Dmg = (30 + (25 * player:spellSlot(0).level)) + player.totalBonusAttackDamage
        totalQ2dmg= leeQ2Dmg + (100 - (100 * afterQ1Rhealth ) / res.target.maxHealth)
        dmgMulti = 100/(100 + res.target.armor)
        finalQ2Dmg = dmgMulti * totalQ2dmg
        if (finalQ2Dmg +  damage.spell(player,res.target, SpellSlot.Q) + damage.spell(player,res.target, SpellSlot.R)  > res.target.health) && player:spellSlot(3).state==0 then  
          print("casting simple Q+r+q2 at ", os.clock(), res.pos.x, res.pos.z )
          player:castSpell("pos", 0, vec3(res.pos.x, 0, res.pos.z))
          Q1LastAttepmt=nil
          return true
        end

        -- PASSIVE MANAGEMENT
        if player.buff["blindmonkpassive_cosmetic"] && not player.buff["blindmonkqmanager"]  && player:isInAutoAttackRange(res.target, 50) then
          return false
        end
        

        

        print("casting simple Q at ", os.clock(), res.pos.x, res.pos.z )
        player:castSpell("pos", 0, vec3(res.pos.x, 0, res.pos.z))
        Q1LastAttepmt=nil
        return true
        --[[if player:spellSlot(0).state == SpellSlot.Cooldown then
          return true
        else
          return false
        end]]
      end
    
    
       -- here im make checks for Q to gapclose if its a champion, i return false for now
       -- first i calculate champions candidates close to my target
       -- if we are here we already have position after Q 
       if menu.insec_key:get() then 
        if insecState=="SAFEINSEC" or insecState=="SAFEINSECRFLASH"  or insecState ~= nil then
          return false
        end
          --R CHECK, if there is no R dont Q2
        if player:spellSlot(3).state ~= 0 then
          return false
        end
        -- calculate all minions and enemies that are in range
        print("before objmanagerloop")
        for obj in objManager.heroes{team = TEAM_ENEMEY, valid_target = true} do
          --print(obj.isEnemy , obj.isMinion , obj.isHero  ,  (not obj.isDead))
          if ((obj.health > 0 )) then
            if obj.pos2D:dist(player.pos2D) < 1500 then
              print("found a minion / champ in Q range", obj.name)
              local seg = pred.linear.get_prediction(active_pred_input, obj)
              print("after seg in found minion", seg)
               --print(seg , seg.endPos , trace_filter(seg, obj) , (seg.endPos:dist(player.pos2D) < active_pred_input.range))
              if seg && seg.endPos && trace_filter(seg, obj) && (seg.endPos:dist(player.pos2D) < active_pred_input.range) then
                print("found a minion / champ in Q range, i calculate expected distance after Q2")
                -- calculate time needed for q1+q2
                local timeQ1= player.pos2D:dist(seg.endPos) / active_pred_input.speed
                -- calculating timeQ2 is hard coz i have no clue where it will be ,
                -- so here i make an approximation of timeQ2 = timeQ1
                local seg2= pred.core.get_pos_after_time(obj, timeQ1* 2)
    
                -- now i calculate where i think insec target will be after timeQ1*2 + timeW1 max range
                -- range of 580 is to be able to ward dash, coz ward is 600 range
                local timeW1= 580 / w_pred_input.speed
                local insecTargetPos = pred.core.get_pos_after_time(currentSelectedInsecTarget, timeQ1* 2 + timeW1)
                local minDist= 1000000
                local closestAlly= nil  
    
                for champion in objManager.iheroes do
                  if (champion.isAlly && not champion.isMe && (champion.health > 0 )) then
                    if champion.pos2D:dist(currentSelectedInsecTarget.pos2D) < minDist then
                      closestAlly= champion
                      minDist= champion.pos2D:dist(currentSelectedInsecTarget.pos2D)
                    end
                  end
                end
                print("Q1 GAPCLOSE : my closest ally is at", closestAlly.pos2D, "distance", minDist)
                local wqPos=insecTargetPos:extend(closestAlly.pos2D, -200)
    
                -- now i change distance between seg2 and wq. if i have flash i can gapclose ult flash, 
                -- so thats a range of 670 ( coz i need to short range coz i need to flash after ult)
                -- if i dont have flash im looking for a direct ward dash, so thats 
                local distance = seg2:dist(wqPos)
                print("dinstance to wqpos", distance)
                if getFlash() && distance < 980 then
                  print(" XXXXXxxxxXXXXXXXXXXXXX ", obj.name, "CANDIDATEEEEEEEE")
                  print(" the target imma gonna Q is used to gapclose")
                  player:castSpell("pos", 0, vec3(seg.endPos.x, 0, seg.endPos.z))
                  Q1LastAttepmt= "INSECQ1"
                  gapcloseCandidate = obj
                  return true
                end
                if distance < 580 then
                  print(" XXXXXxxxxXXXXXXXXXXXXX ", obj.name, "CANDIDATEEEEEEEE")
                  print(" the target imma gonna Q is used to gapclose")
                  player:castSpell("pos", 0, vec3(seg.endPos.x, 0, seg.endPos.z))
                  Q1LastAttepmt= "INSECQ1"
                  gapcloseCandidate = obj
                  return true
                end
              end
            end
          end
        end



        for obj in objManager.minions{team = TEAM_ENEMEY, valid_target = true} do
          --print(obj.isEnemy , obj.isMinion , obj.isHero  ,  (not obj.isDead))
          if ((obj.health > 0 )) then
            if obj.pos2D:dist(player.pos2D) < 1500 then
              print("found a minion / champ in Q range", obj.name)
              local seg = pred.linear.get_prediction(active_pred_input, obj)
              print("after seg in found minion", seg)
               --print(seg , seg.endPos , trace_filter(seg, obj) , (seg.endPos:dist(player.pos2D) < active_pred_input.range))
              if seg && seg.endPos && trace_filter(seg, obj) && (seg.endPos:dist(player.pos2D) < active_pred_input.range) then
                print("found a minion / champ in Q range, i calculate expected distance after Q2")
                -- calculate time needed for q1+q2
                local timeQ1= player.pos2D:dist(seg.endPos) / active_pred_input.speed
                -- calculating timeQ2 is hard coz i have no clue where it will be ,
                -- so here i make an approximation of timeQ2 = timeQ1
                local seg2= pred.core.get_pos_after_time(obj, timeQ1* 2)
    
                -- now i calculate where i think insec target will be after timeQ1*2 + timeW1 max range
                -- range of 580 is to be able to ward dash, coz ward is 600 range
                local timeW1= 580 / w_pred_input.speed
                local insecTargetPos = pred.core.get_pos_after_time(currentSelectedInsecTarget, timeQ1* 2 + timeW1)
                local minDist= 1000000
                local closestAlly= nil  
    
                for champion in objManager.iheroes do
                  if (champion.isAlly && not champion.isMe && (champion.health > 0 )) then
                    if champion.pos2D:dist(currentSelectedInsecTarget.pos2D) < minDist then
                      closestAlly= champion
                      minDist= champion.pos2D:dist(currentSelectedInsecTarget.pos2D)
                    end
                  end
                end
                print("Q1 GAPCLOSE : my closest ally is at", closestAlly.pos2D, "distance", minDist)
                local wqPos=insecTargetPos:extend(closestAlly.pos2D, -200)
    
                -- now i change distance between seg2 and wq. if i have flash i can gapclose ult flash, 
                -- so thats a range of 670 ( coz i need to short range coz i need to flash after ult)
                -- if i dont have flash im looking for a direct ward dash, so thats 
                local distance = seg2:dist(wqPos)
                print("dinstance to wqpos", distance)
                if getFlash() && distance < 770 then
                  print(" XXXXXxxxxXXXXXXXXXXXXX ", obj.name, "CANDIDATEEEEEEEE")
                  print(" the target imma gonna Q is used to gapclose")
                  player:castSpell("pos", 0, vec3(seg.endPos.x, 0, seg.endPos.z))
                  Q1LastAttepmt= "INSECQ1"
                  gapcloseCandidate = obj
                  return true
                end
                if distance < 375 then
                  print(" XXXXXxxxxXXXXXXXXXXXXX ", obj.name, "CANDIDATEEEEEEEE")
                  print(" the target imma gonna Q is used to gapclose")
                  player:castSpell("pos", 0, vec3(seg.endPos.x, 0, seg.endPos.z))
                  Q1LastAttepmt= "INSECQ1"
                  gapcloseCandidate = obj
                  return true
                end
              end
            end
          end
        end
      end
      print("NO CONDFITIONS FOR Q ---------------------------------------")
      return false
    end
    local function q2_logic()
      --print("my state in Q2", insecState, os.clock())
      if player:spellSlot(0).state ~= 0 or  player:spellSlot(0).name== "BlindMonkQOne"  then return false end
      if (not orb.core.can_action()) then
        return false
      end  
      if menu.insec_key:get() then
        --check if enemy Q2 in safeInsecisnotflying
        if insecState=="SAFEINSECQ2" then
          if ( os.clock() - timeRforSafe ) > 0.8 then
            print("casting Q2 on safe")
            player:castSpell("self", 0)
            timeRforSafe= 0
            return true
          else 
            -- i return false if its too early to Q2
            return false
          end
        end
    
        --R CHECK, if there is no R dont Q2
        if player:spellSlot(3).state ~= 0 then
          return false
        end
        -- imma Q2 on enemy only if insec is on and the target is the selected target
        --if insecState == "SAFEINSEC" or insecState=="SAFEINSECRFLASH" or insecState== nil then
        if insecState == "SAFEINSEC" or insecState=="SAFEINSECRFLASH" then
          return false
        end
        print("im in Q2, i check if the enemy is the target i one to insec", insecState)
        local function ts_func(result, target, distance)
          result[#result + 1] = target
          return true
        end
        local result = ts.loop(ts_func)
        print(result)
    
    
    
        for obj in objManager.heroes{team = TEAM_ENEMEY, valid_target = true} do
          --print(obj.isEnemy , obj.isMinion , obj.isHero  ,  (not obj.isDead))
          if (obj.isEnemy && obj.isVisible && (obj.isLaneMinion or obj.isSuperMinion or obj.isSiegeMinion or obj.isHero ) &&  (obj.health > 0)) then
            for i = 0, obj.buffManager.count - 1 do
              local buff = obj.buffManager:get(i)
              if (buff.valid) then
                if buff.name == "BlindMonkQOne" then
                  if obj.pos2D:dist(player.pos2D) > 1300 then 
                    print("distance to far", distance)
                    return false 
                  end
                  print("found someone that is Q marked")
                  print(" my selected target", currentSelectedInsecTarget)
                  if obj.index ==  currentSelectedInsecTarget.index then
                    print("the target to whom imma gonna Q is the one i want to insec")
                    insecState = "Q2TARGET"
                    player:castSpell("self", 0)
                    return true
                  end
                  --print(" is there a gapclosecandidate", gapcloseCandidate, " comparing index", obj.index==gapcloseCandidate.index)
                  if gapcloseCandidate  then
                    print("Q2 gapclose, lets see how it goes")
                    insecState = "Q2TARGET"
                    player:castSpell("self", 0)
                    return true
                  end
                end
              end
            end
          end
        end

        for obj in objManager.minions{team = TEAM_ENEMEY, valid_target = true} do
          --print(obj.isEnemy , obj.isMinion , obj.isHero  ,  (not obj.isDead))
          if (obj.isEnemy && obj.isVisible && (obj.isLaneMinion or obj.isSuperMinion or obj.isSiegeMinion or obj.isHero ) &&  (obj.health > 0)) then
            for i = 0, obj.buffManager.count - 1 do
              local buff = obj.buffManager:get(i)
              if (buff.valid) then
                if buff.name == "BlindMonkQOne" then
                  if obj.pos2D:dist(player.pos2D) > 1300 then 
                    print("distance to far", distance)
                    return false 
                  end
                  print("found someone that is Q marked")
                  print(" my selected target", currentSelectedInsecTarget)
                  if obj.index ==  currentSelectedInsecTarget.index then
                    print("the target to whom imma gonna Q is the one i want to insec")
                    insecState = "Q2TARGET"
                    player:castSpell("self", 0)
                    return true
                  end
                  --print(" is there a gapclosecandidate", gapcloseCandidate, " comparing index", obj.index==gapcloseCandidate.index)
                  if gapcloseCandidate  then
                    print("Q2 gapclose, lets see how it goes")
                    insecState = "Q2TARGET"
                    player:castSpell("self", 0)
                    return true
                  end
                end
              end
            end
          end
        end
        --print if im here, means the target i want to Q2 is not the primary target
        -- im changing insec state back to nil now, but have to put here the gapclose logic
        print("reseting insecstate coz wrong target (for now")
        if insecState=="INSECQ1" then
          insecState= nil
          return false
        end
      end
      -- here max dmg combo
      -- i first check if there is an 
      -- imma check if the target thas buff is in AA range

      --[[print("game time", game.time, "endtime",player:spellSlot(0).cooldownEndTime, "gametime-cooldownEndTime",(game.time-player:spellSlot(0).cooldownEndTime))
      if player.buff["blindmonkpassive_cosmetic"]  && ((player:spellSlot(0).cooldownEndTime-game.time) > 0.2) then
        return false
      end]]
      for obj in objManager.heroes{team = TEAM_ENEMEY, valid_target = true} do
        --print(obj.isEnemy , obj.isMinion , obj.isHero  ,  (not obj.isDead))
        if (obj.isEnemy && obj.isVisible && (obj.isLaneMinion or obj.isSuperMinion or obj.isSiegeMinion or obj.isHero ) &&  (obj.health > 0)) then
          for i = 0, obj.buffManager.count - 1 do
            local buff = obj.buffManager:get(i)
            if (buff.valid) then
              if buff.name == "BlindMonkQOne" then
                -- here calculations for Q2 execute
                if (menu.q2_finisher:get() && obj.isHero && (damage.spell(player, obj, SpellSlot.Q) > obj.health) && (player.pos2D:dist(obj.pos2D) < 1300 )) then
                  print("Q2 EXECUTE")
                  player:castSpell("self", 0)
                  return true 
                end
                if player:isInAutoAttackRange(obj ,50 ) then 
                  print(buff.endTime - game.time)
                  if player.buff["blindmonkpassive_cosmetic"] && ((buff.endTime - game.time) > 0.2) then
                    return false
                  end
                  print("throwing Q2 coz whoever is Q2 marked is in autorange")
                  player:castSpell("self", 0)
                  return true 
                end
              end
            end
          end
        end
      end
      return false
    end
    
    local function w1_logic()
      --print("my state in W1", insecState, os.clock())
      if player:spellSlot(1).state ~= 0 or player:spellSlot(1).name=="BlindMonkWTwo" then
        return false
      end
      if (not orb.core.can_action()) then
        return
      end
      active_pred_input= w_pred_input  
      -- imma check here if i have no currentselected target, than the target to insec is the one from default ts
      --[[if currentSelectedInsecTarget == nil then
        for target in ts.get_targets() do
          -- this should be changed to calculate expexted distance to player and not current distance to player
          if target.pos2D:dist(player.pos2D) < 550 then
            print(" this target is selected for W1 logic",target.name )
            currentSelectedInsecTarget= target
            break
          end
        end
      end]]
      
      if menu.insec_key:get() then
        if currentSelectedInsecTarget == nil then
          return false
        end
        -- checking if i have R
        if player:spellSlot(3).state ~= 0 then
          return false
        end
    
        if insecState== "FANCYWARDUSEW" && lastWardPlaced then
          print("im in FANCYWARDUSEW, spamming W")
          player:castSpell("obj", 1, lastWardPlaced)
          return true
        end
        if insecState== "RFLASHWARDUSEW" && lastWardPlaced then
          print("im in RFLASHWARDUSEW, spamming W")
          player:castSpell("obj", 1, lastWardPlaced)
          return true
        end
        if insecState== "INSECWCASTMINION" && ( not minionFound) then
          player:castSpell("obj",1, minionFound)
          print("casting W to minion AGAIN")
          return true
        end
        -- imma check if im mid air of Q and im aiming final insec target
        if insecState == "Q2TARGET" or insecState== nil  or insecState == "SAFEINSEC" then
          -- i will check closest ally
          local minDist= 1000000
          local closestAlly= nil   
         
    
          for champion in objManager.iheroes do
            if (champion.isAlly && not champion.isMe && (champion.health > 0 )) then
              if champion.pos2D:dist(currentSelectedInsecTarget.pos2D) < minDist then
                closestAlly= champion
                minDist= champion.pos2D:dist(currentSelectedInsecTarget.pos2D)
              end
            end
          end
          print("my closest ally is at", closestAlly.pos2D, "distance", minDist)
          -- i calculate the WQ position
          if closestAlly then
            print("currentSelectedInsecTarget.pos2D", currentSelectedInsecTarget.pos2D, "closestAlly.pos2D", closestAlly.pos2D)
    
            -- SAFE INSEC
            --            i calculate a position in range for kickflash
            if insecState == "SAFEINSEC" then
              -- first i get expected pos after W
              local seg = pred.linear.get_prediction(active_pred_input, currentSelectedInsecTarget)
              --print("is there a seg to gapclose,",  seg.endPos, "distance, ", seg.endPos:dist(player.pos2D), "insecState", insecState)
              if not seg then 
                return false
              end
              print("there is a sec to wardash on safeInsec")
              -- now i calculate a point between that position and me to be able to kickflash
              wqPos=currentSelectedInsecTarget.pos2D:extend(player.pos2D, 320)
    
              if wqPos:dist(player.pos2D) > 590 then
                print(" ward dash position to far for WQ", wqPos:dist(player.pos2D))
                return false
              end
              if getFlash() &&  wq(wqPos) then
                print(" im going to wardDash for safe insec as dinstance ==",  wqPos:dist(player.pos2D))
                insecState="SAFEINSECRFLASH"
                globalClosestAlly=closestAlly
                return true
              end
    
            end
            -- i get prediction positioning after ward dash
            local seg = pred.linear.get_prediction(active_pred_input, currentSelectedInsecTarget)
            if not seg then 
              return false
            end
            wqPos=seg.endPos:extend(closestAlly.pos2D, -150)
            if wqPos:dist(player.pos2D) > 500 then
              print("too far to ward dash yet", wqPos:dist(player.pos2D))
              -- here im going to check if im not in Q2, and that im too far away to ward dash,imma try to gapclose with ward dash
              -- first i calculate distance to enemy from player, see if i can get close enough to kick flash
              -- REQUIREMENTS : HAVE FLASH and NOT Q2
              
              if insecState=="Q2TARGET" then
                return false
              end

              print("is there a seg to gapclose,",  wqPos, "distance, ", wqPos:dist(player.pos2D), "insecState", insecState)
              print("after not seg")
              if  (insecState == nil) then
                -- ward dash range + R range, wich is 500 + 370
                print("i should be in")
                -- calcs to avoid putting ward on top of enemy
                print(" gapclose DISTANCE",wqPos:dist(player.pos2D) )
                -- TEEEEEEEEEEST FANCY GAPCLOSE WITH WARD + FLASH + Q if dist is superior to 670 but inferior to ward+dash+flash (1000)
                if wqPos:dist(player.pos2D) < 650 then
                  -- need to shorten distance to be able to ward dash there
                  --gapClosePos= player.pos2D:extend(wqPos, 580)
                  if getFlash()  && getTrinket() then
                    -- here i ward then flash then W, hope all works
    
                    local flashypos = player.pos2D:extend(wqPos, 400)
                    player:castSpell("pos", getFlash(), flashypos)
                    --player:castSpell("pos",1, wqPos)
                    --insecState="FANCYWARD"
                    insecState="FANCYFLASH"
                    wherePlaceWard=wqPos
                    globalClosestAlly=closestAlly
                    return true
                  end
                end
                if wqPos:dist(player.pos2D) < 900 then
                  -- need to shorten distance to be able to ward dash there
                  --gapClosePos= player.pos2D:extend(wqPos, 580)
                  gapClosePos= seg.endPos:extend(player.pos2D, 200)
                  if getFlash()  then
                    insecState="RFLASHCASTWARD"
                    wherePlaceWard=gapClosePos
                    globalClosestAlly=closestAlly
                    return true
                  end
                end
              end
              return false
            end
            -- if im here im in range to wardDash, so i try it
    
            print("my wqpos is ",wqPos)
    
    
    
            --- here the logic to find a minion or a ward in certain angle , can be heavy in calcs
            minionFound = nil
            for minion in objManager.minions{ team = TEAM_ALLY, dist = 2000, valid_target = true, wards= true } do
              -- imma check first if minion predic is range for kick after i arrive
              print("------------------------------------------------------------------------", minion.name)
              if minion.name== "SightWard" or minion.name== "JammerDevice"  then
                if (minion.pos2D:dist(currentSelectedInsecTarget.pos2D) < 370) && (minion.pos2D:dist(currentSelectedInsecTarget.pos2D)  > 80)  then
                  print("found a WARD close enough, checking now angle")
                  local angle = angle( wqPos ,currentSelectedInsecTarget.pos2D,minion.pos2D)
                  print("the angle is ", angle)
                  if (-50 < angle) &&  (angle < 50) then
                    print(" THIS WARD IS angle " , angle, "saving him")
                    minionFound = minion
                  end
                end
              else
                local seg = pred.linear.get_prediction(active_pred_input, minion)
                if seg then
                  if seg.endPos then
                    if (seg.endPos:dist(currentSelectedInsecTarget.pos2D) < 370) && (seg.endPos:dist(currentSelectedInsecTarget.pos2D)  > 80)  then
                      print("found a minion close enough, checking now angle")
                      -- need to transformate here
                      seg.endPos.y=seg.endPos.z
                      local angle = angle( wqPos ,currentSelectedInsecTarget.pos2D,seg.endPos)
                      print("the angle is ", angle)
                      if (-50 < angle) &&  (angle < 50) then
                        print(" THIS MINION IS angle " , angle, "saving him")
                        minionFound = minion
                      end
                    end
                  end
                end
              end
            end
            if minionFound then
              print("the minion i found is at a distance of ",minionFound.pos2D:dist(player.pos2D) ," < ? 580 " )
              if minionFound.pos2D:dist(player.pos2D) < 580 then
                player:castSpell("obj",1, minionFound)
                print("casting W to minion ----------------------------------------")
                insecState="INSECWCASTMINION"
                return true
              end
            end
            if wq(wqPos) && not minionFound then
              insecState="READYR"
              return true
            else
    
              if not minionFound then
                -- if i cant ward dash for some reason, i will kick flash, so put state to kickflashR , with ally pos global changed
                -- i will do last second calculation of kickflash for maximum accurarcy
                insecState="RFLASH"
                globalClosestAlly=closestAlly
                return false
              end
            end
            return false
          end
        end
      end


      -- normal W combo
      if menu.w1_combat:get() then
        for target in ts.get_targets() do
          --print(target.charName)
          if player.buff["blindmonkpassive_cosmetic"] && not player.buff["blindmonkwmanager"]  then
            return false
          end
        
          -- imma check if there is an ally champion that is in range
          range = player:getAutoAttackRange(player)
          for champion in objManager.iheroes do
            if (champion.isAlly && not champion.isMe && (champion.health > 0 ) && (champion.pos2D:dist(target) < range ) && (player.pos2D:dist(champion) < 1200) ) then
              print("W ally")
              player:castSpell("obj", 1, champion)
              return true
            end
          end

          if player:isInAutoAttackRange(target,50 ) then
            print("W self")
            player:castSpell("self", SpellSlot.W)
            return true
          end
        end
      end
      return false
    end

    local function w2_logic()
      if player:spellSlot(1).state ~= 0 or player:spellSlot(1).name=="BlindMonkWOne" then
        return false
      end
      if (not orb.core.can_action()) then
        return
      end
      for target in ts.get_targets() do
        --print(target.charName)
        if player.buff["blindmonkpassive_cosmetic"] && player.buff["blindmonkwmanager"] &&  ((player.buff["blindmonkwmanager"].endTime-game.time) > 0.2)  then
          return false
        end
        if player:isInAutoAttackRange(target,50 ) then
          print("W self")
          player:castSpell("self", SpellSlot.W)
          return true
        end
      end
      return false
    end
    
    
    local function flashAfterR()
      if timeR == 0 then
        return false
      else
        --print("time passed",  os.clock() - timeR )
        if ( ( os.clock() - timeR ) > delayRFlash ) && (insecState=="RFLASHPART2" or insecState=="SAFEINSECRFLASHPART2") then
    
          --[[if currentSelectedInsecTarget == nil then
            for target in ts.get_targets() do
              -- this should be changed to calculate expexted distance to player and not current distance to player
              if target.pos2D:dist(player.pos2D) < 391 then
                print(" this target is selected for W1 logic",target.name )
                currentSelectedInsecTarget= target
                break
              end
            end
          end]]
          if currentSelectedInsecTarget == nil then
            return false
          end
          if getFlash() then
            -- i calculate here the flash pos
            flashPos= currentSelectedInsecTarget.pos2D:extend(globalClosestAlly.pos2D, -25)
            if flashPos:dist(player.pos2D) > 390 then
             print(" Flash position to far away from player",flashPos:dist(player.pos2D) )
             return false
            end        
            player:castSpell("pos", getFlash(), flashPos)
            if  not player:spellSlot(getFlash()).state == SpellSlot.Cooldown then
              return false
            end
            print("casted flash",  os.clock() - timeR ,"after R")
            if insecState=="RFLASHPART2" then
              insecState= "FINISHED"
            end
            if insecState=="SAFEINSECRFLASHPART2" then
              insecState= "SAFEINSECQ2"
            end
            
    
            timerR= 0
            return true
          end
        end
      end
      return false
    end
    
    
    
    local function r_kill()
      if not menu.r_finisher:get() then
        return false
      end
      ts.get_targets()
      for target in ts.get_targets() do
        --print(target.charName)
        if damage.spell(player,target, SpellSlot.R) > target.health &&  (target.pos2D:dist(player.pos2D) < 370 ) then
          print("R finisher")
          player:castSpell("obj", SpellSlot.R, target)
          if not player:spellSlot(SpellSlot.R) == SpellSlot.Cooldown then
            return false
          end
          return true
        end
        --- R+Q2 execute combo
          -- imma check if the target has the Q2 buff and Q2 is ready
        if player:spellSlot(0).name=="BlindMonkQTwo" and target.buff["BlindMonkQOne"] then
          local afterRhealth= target.health - damage.spell(player,target, SpellSlot.R) 
          local leeQ2Dmg = (30 + (25 * player:spellSlot(0).level)) + player.totalBonusAttackDamage
          local totalQ2dmg= leeQ2Dmg + (100 - (100 * afterRhealth ) / target.maxHealth)
          local dmgMulti = 100/(100 + target.armor)
          local finalQ2Dmg = dmgMulti * totalQ2dmg
          --print("expected DAMAGE OF FINAL Q2", finalQ2Dmg)
          if  ((finalQ2Dmg+ damage.spell(player,target, SpellSlot.R)) > target.health) && target.pos2D:dist(player.pos2D) < 370  then
            print("cast  R+Q2 execute")
            player:castSpell("obj", SpellSlot.R, target)
            return true
          end
        end
      end
      return false
    end
    local function r_logic()
      if player:spellSlot(3).state ~= 0  then
        return false
      end
      if (not orb.core.can_action()) then
        return
      end
      --print kill priority
      if r_kill() then return true end
     
      if menu.insec_key:get() then
        --BAD
        --[[if currentSelectedInsecTarget == nil then
          for target in ts.get_targets() do
            -- this should be changed to calculate expexted distance to player and not current distance to player
            if target.pos2D:dist(player.pos2D) < 375 then
              print(" this target is selected for R1 logic",target.name )
              currentSelectedInsecTarget= target
              break
            end
          end
        end]]
        if currentSelectedInsecTarget == nil then
          return false
        end
        if insecState==nil && currentSelectedInsecTarget.pos2D:dist(player.pos2D) < 340 && getFlash() then
          --calculate closestally
          local minDist= 1000000
          local closestAlly= nil   
         
    
          for champion in objManager.iheroes do
            if (champion.isAlly && not champion.isMe && (champion.health > 0 )) then
              if champion.pos2D:dist(currentSelectedInsecTarget.pos2D) < minDist then
                closestAlly= champion
                minDist= champion.pos2D:dist(currentSelectedInsecTarget.pos2D)
              end
            end
          end
          if closestAlly then
            globalClosestAlly=closestAlly
            insecState="RFLASH"
            return true 
          end

        end
        --print("my state in R", insecState, os.clock())
        if (insecState=="RFLASH" or insecState== "SAFEINSECRFLASH") then
          print("im in R state,",insecState)
          if currentSelectedInsecTarget.pos2D:dist(player.pos2D) > 370 then
            print("R to far to cast in R flash", currentSelectedInsecTarget.pos2D:dist(player.pos2D))
            return false
          else
             -- i check if flash is ready
             print("do i have flash", getFlash())
             --if im in SAFEINSECRFLASH i dont care what state is Q
             if insecState== "SAFEINSECRFLASH" then
              if getFlash() then
                if player:castSpell("obj", SpellSlot.R, currentSelectedInsecTarget)  then
                  if not player:spellSlot(SpellSlot.R) == SpellSlot.Cooldown then
                    return false
                  end
                  print("it should've casted R for RFLASH in SafeInsec")
                  return true
                end
              end
             end
             --print(" some stats", player:spellSlot(0).state, )
             print("checking conditions to cast Rflash")
             print("not in Q2 not aviable?", player:spellSlot(0).name== "BlindMonkQTwo" or  player:spellSlot(0).name== "BlindMonkQOne" )
             if getFlash() && ( (player:spellSlot(0).name== "BlindMonkQTwo" or  player:spellSlot(0).name== "BlindMonkQOne" )) then
              if player:castSpell("obj", SpellSlot.R, currentSelectedInsecTarget)  then
                if not player:spellSlot(SpellSlot.R) == SpellSlot.Cooldown then
                  return false
                end
                print("it should've casted R for RFLASH")
                return true
              end
            end
          end
        end
        if insecState=="READYR" then
          print("casting R","insecState",insecState )
          player:castSpell("obj", SpellSlot.R, currentSelectedInsecTarget)
          if not player:spellSlot(SpellSlot.R) == SpellSlot.Cooldown then
            return false
          end
    
          return true
        end
      end
      print("----------------end of R, return false")
      return false
    end



    local function q_farm()
      if player:spellSlot(0).state ~= 0  then
        return false
      end
      -- checking if im in passive
      if player.buff["blindmonkpassive_cosmetic"] && not player.buff["blindmonkqmanager"] then
        return false
      end
      if player.buff["blindmonkpassive_cosmetic"] && player.buff["blindmonkqmanager"] &&  ((player.buff["blindmonkqmanager"].endTime-game.time) > 0.2) then
        return false
      end
      local jungleTarget=orb.core.get_target(1200)
      if jungleTarget && jungleTarget.valid && (jungleTarget.isNeutral or jungleTarget.isMonster) && (jungleTarget.health > 0)  && (jungleTarget.pos2D:dist(player.pos2D) < 1200) then
        player:castSpell("pos", 0, jungleTarget.pos)
        return true
      end
    end
    local function w_farm()
      if player:spellSlot(1).state ~= 0  then
        return false
      end
      -- checking if im in passive
      if player.buff["blindmonkpassive_cosmetic"] && not player.buff["blindmonkwmanager"] then
        return false
      end
      if player.buff["blindmonkpassive_cosmetic"] && player.buff["blindmonkwmanager"] &&  ((player.buff["blindmonkwmanager"].endTime -game.time  ) > 0.2) then
        return false
      end
      local jungleTarget=orb.core.get_target(player:getAutoAttackRange(player))
      if jungleTarget && jungleTarget.valid && (jungleTarget.isNeutral or jungleTarget.isMonster) && (jungleTarget.health > 0) && (jungleTarget.pos2D:dist(player.pos2D)  < player:getAutoAttackRange(player))  then
        player:castSpell("self", 1)
        return true
      end
    end
    local function e_farm()
      if player:spellSlot(2).state ~= 0  then
        return false
      end
      -- checking if im in passive
      if player.buff["blindmonkpassive_cosmetic"] && not player.buff["blindmonkemanager"] then
        return false
      end
      if player.buff["blindmonkpassive_cosmetic"] && player.buff["blindmonkemanager"] &&  ((player.buff["blindmonkemanager"].endTime -game.time  ) > 0.2) then
        return false
      end
      local jungleTarget=orb.core.get_target(425)
      if jungleTarget && jungleTarget.valid && (jungleTarget.isNeutral or jungleTarget.isMonster) && (jungleTarget.health > 0)  && jungleTarget.pos2D:dist(player.pos2D) < 425 then
        player:castSpell("self", 2)
        return true
      end
    end
    
    local function combo()
      if (flashAfterR()) then
        return true
      end
      if r_logic() then
        return true
      end
      if q1_logic() then
        return true
      end
      if q2_logic() then
        return true
      end
      if w1_logic() then
        return true
      end
      if w2_logic() then
        return true
      end
      if menu.e_combat:get() then
        if e1_logic() then
          return true
        end
      end
      --[[if e1_logic() and menu.e_combat:get() then
        return true
      end]]
    end
    
    ---------------------------FARMING -------------------------------------
    local function farm()
      if q_farm() then 
        return true
      end
      if w_farm() then
        return true
      end
      if e_farm() then
        return true
      end
    end
    
    local function flee()
      -- checking if i have W up
      if player:spellSlot(1).state ~= 0 or player:spellSlot(1).name=="BlindMonkWTwo" then
        return false
      end
      if fleeState=="FLEEWARDW" && fleeWard then
        player:castSpell("obj", 1, fleeWard)
        return true
      end
      dist= game.mousePos2D:dist(player.pos2D)
      if dist > 600 then
        return false
      end
      --if wq(game.mousePos2D) then
      if getTrinket() then
        player:castSpell("pos", getTrinket(), game.mousePos2D)
        print("placing ward in flee")
        fleeState="FLEEWARD"
        return true
      end
    end
    
    
    local function on_tick()
      -- set selected insec target
      --print(player:spellSlot(0).state)
      currentSelectedInsecTarget = ts.selected_target()
    
      if currentSelectedInsecTarget &&  not (currentSelectedInsecTarget:isValidTarget(10000,true,player.pos,false,false,true,false))  then
        print("apparently currentSelectedTarget is not valid")
        currentSelectedInsecTarget= nil
      end
      -- smiteable minion check
      if minionToSmite && getSmite() && smiteState=="SMITEIT" then
        if minionToSmite.pos2D:dist(player.pos2D) <= 399 then
          player:castSpell("obj",getSmite(),minionToSmite)
          return true
        end
      end
      -- titanic check
      if tiamatState == "USETIAMAT" && getTiamat()  then
          player:castSpell("self", getTiamat())
          print("spamming tiamat")
          return true
      end

      if menu.insec_key:get() then
        -- i check if my player is cc
        if (player.buff[Buff.Stun]) then
          print("got CC, reseting insecState")
          insecState=nil
        end
        -- i check if evade is enabled, in that case i disable it
        if not evade.core.is_paused() && menu.disable_evade:get() then
          evadeWasActive= true
          evade.core.set_enabled(false)
        end
        if insecState == "RFLASHCASTWARD" && getTrinket() && player:spellSlot(1).name ~= "BlindMonkWTwo" then
          player:castSpell("pos", getTrinket(),wherePlaceWard)
            print("spamming ward for RFLASHCASTWARD")
            return true
        end
        if insecState == "FANCYWARD" && wherePlaceWard && player:spellSlot(1).name ~= "BlindMonkWTwo" then
          if getTrinket() then
            player:castSpell("pos", getTrinket(),wherePlaceWard)
            print("spamming ward for flashy W")
            return true
          end
        end
          -- here imma change state of insec if i throwed a Q and it never landed, comparing it to if i have 
        -- Q2 to spellsot
        if insecState == "INSECQ1" && didQdeleted && player:spellSlot(0).name ~= "BlindMonkQTwo" then
          print("my Q didnt land on anything on simple insec, reseting state")
          insecState= nil
          didQdeleted = false
        end
        if insecState== "Q2TARGET" && gapcloseCandidate && gapcloseCandidate.valid  &&  gapcloseCandidate.health > 0 then
          -- imma check if this target doesnt have buff anymore, in that case i reset insecstate to allow gapclose
          for i = 0, gapcloseCandidate.buffManager.count - 1 do
            local buff = gapcloseCandidate.buffManager:get(i)
            if (buff.valid) then
              if buff.name=="BlindMonkQOne" then
                print("GACLOSE CANDIDATE RESET INSEC STATE")
                insecState= nil
                gapcloseCandidate= nil
              end
            end
          end
        end
        if insecState=="WAITARRIVECLOSETOMINION"  && minionFound then
          --print("distance to target minion,", player.pos2D:dist(minionFound.pos2D) )
          if player.pos2D:dist(minionFound.pos2D) < 40 then
            print("close enough to minion, changing state to ready r")
            insecState="READYR"
          end
        end
      end
      if not menu.insec_key:get() then
        --reseting here some values of insec
        --print("reset insecState")
        if evadeWasActive then
          evade.core.set_enabled(true)
        end
        timeRforSafe= 0
        timeR= 0
        insecState= nil
        didQdeleted= false
        lastWardPlaced= nil
      end
      if orb.menu.combat.key:get() then
        combo()
      end
      if orb.core.is_mode_active(OrbwalkingMode.Flee) then
        flee()
      end
      if  not orb.core.is_mode_active(OrbwalkingMode.Flee) then
        fleeWard= nil
        fleeState = nil
      end
      if orb.core.is_mode_active(OrbwalkingMode.LaneClear) then
        farm()
      end
    end
    local function on_draw()
    end
    
    local f = function(spell)
      print(spell.owner.isMe, spell.name)
      if (spell.owner.isMe && (spell.name == "SummonerSmite" or spell.name == "S5_SummonerSmiteDuel"  or spell.name == "S5_SummonerSmitePlayerGanker" ) && spell.target == minionToSmite) then
        print("smite detected")
        minionToSmite= nil
      end
      if (spell.owner.isMe && (spell.name == "ItemTiamatCleave" or spell.name == "ItemTitanicHydraCleave") && tiamatState == "USETIAMAT") then
        print("tiamat detected: changing state to nil")
        tiamatState= nil
      end
      if (spell.owner.isMe && spell.name == "SummonerFlash" && insecState == "FANCYFLASH") then
        print("FLASHDETECT: changing state to FANCYWARD")
        insecState= "FANCYWARD"
      end
      if(spell.owner.isMe && spell.name == "BlindMonkWOne" && fleeState == "FLEEWARDW") then
        print("W1DETECTED:  fleestate change" )
        fleeState= "FINISH"
      end
      if(spell.owner.isMe && spell.name == "BlindMonkWOne" && insecState == "RFLASHWARDUSEW") then
        print("W1DETECTED:  insecstate change" )
        insecState= "RFLASH"
      end
      if(spell.owner.isMe && spell.name == "BlindMonkWOne" && insecState == "FANCYWARDUSEW") then
        print("W1DETECTED:  insecstate change" )
        insecState= "READYR"
      end
      
      if(spell.owner.isMe && spell.name == "BlindMonkWOne" && insecState == "INSECWCASTMINION") then
        print("W1DETECTED:  insecstate change" )
        insecState= "WAITARRIVECLOSETOMINION"
      end
      if(spell.owner.isMe && spell.name == "BlindMonkQOne" && insecState == nil) then
        -- this is here for manual Q's
        print("Q1DETECTED:  insecstate is ", nil, "and my Q1LastAttepmt was " , Q1LastAttepmt )
        --print(" insecstate was", nil, " " "and i detected a Q, changing by SPell to insecQ1")
        if Q1LastAttepmt == "INSECQ1" then
          insecState= "INSECQ1"
        end
        if Q1LastAttepmt == "SAFEINSEC" then
          insecState= "SAFEINSEC"
        end
        
        --insecState="INSECQ1"
      end
      if(spell.owner.isMe && spell.name == "BlindMonkQTwo") then
        imInQ2 = true
        imInQ2Object = spell
        print(".castEndTime", spell.castEndTime)
      end
      if (spell.owner.isMe) && spell.name == "BlindMonkRKick"  &&  (insecState=="RFLASH" or insecState=="SAFEINSECRFLASH" )   then
        if insecState=="RFLASH" then
          print("R detected, changing state to RFLASHPART2")
        insecState="RFLASHPART2"
        end
        if insecState=="SAFEINSECRFLASH" then
          print("R detected, changing state to SAFEINSECRFLASHPART2")
        insecState="SAFEINSECRFLASHPART2"
        end
        timeR=os.clock()
        timeRforSafe=os.clock()
      end
      if (spell.owner.isMe) && spell.name == "BlindMonkRKick" && insecState=="READYR" then
        insecState= "FINISHED"
      end
    end
    
    local f2 = function(object)
      if object ==lastQ then
        print("deleted")
        didQdeleted = true
        lastQ = nil
        Q1LastAttepmt=nil
        minionToSmite=nil
        smiteState=nil
      end
      -- do not access anything besides object.ptr
      -- object.valid will be false
      -- mySavedObject == object works
    end
    local on_create_object = function(o)
      if(o && o.owner && o.owner.isMe && (o.name == "SightWard" or o.name == "JammerDevice") && fleeState == "FLEEWARD") then
        print("warddetected:  fleestate change" )
        fleeState= "FLEEWARDW"
        fleeWard=o
      end
      if(o && o.owner && o.owner.isMe && (o.name == "SightWard" or o.name == "JammerDevice") && insecState == "RFLASHCASTWARD") then
        print("warddetected:  insecstate change" )
        insecState= "RFLASHWARDUSEW"
        lastWardPlaced=o
      end
      if(o && o.owner && o.owner.isMe && (o.name == "SightWard"  or o.name == "JammerDevice") && insecState == "FANCYWARD") then
        print("warddetected:  insecstate change" )
        insecState= "FANCYWARDUSEW"
        lastWardPlaced=o
      end
      if o and o.isMissile and o.name=="BlindMonkQOne" then 
        lastQ=o
        print(player:spellSlot(0).name)
        print(player:spellSlot(1).name)
        print(player:spellSlot(3).name)
        print(player:spellSlot(4).name)
        smiteState="SMITEIT"
        print("Q1 missile, smite minion if you can")
      end 
    end
    local function on_draw()
      if menu.q_draw:get() then
        graphics.draw_circle(player.pos2D, q_pred_input.range , -1, graphics.argb(180, 0, 254, 0))
      end
      if menu.e_draw:get() then
        graphics.draw_circle(player.pos2D, 425, -1, graphics.argb(180, 120, 45, 122))
      end
      if menu.wq_draw:get() then
        graphics.draw_circle(player.pos2D, 600, -1, graphics.argb(180, 255, 45, 0))
      end
      if menu.draw_insec:get() then
        if ts.selected_target() then
          screenPos= graphics.world_to_screen(vec3(ts.selected_target().pos2D.x, 0,ts.selected_target().pos2D.y))
          graphics.draw_text_2D("INSEC TARGET", 55, screenPos.x,  screenPos.y, graphics.argb(255, 255, 0, 0))
        end
      end
    end

    local on_after_attack = function(last_target)
      print(menu.use_tiamat:get(), orb.core.is_mode_active(OrbwalkingMode.LaneClear))
      if (menu.use_tiamat:get() and last_target and (last_target.isHero or last_target.isNeutral )   and last_target:dist(player.pos2D) < 400 && getTiamat() && (orb.menu.combat.key:get() or orb.core.is_mode_active(OrbwalkingMode.LaneClear))) then
            player:castSpell("self", getTiamat()) -- example Jax W
            tiamatState="USETIAMAT"
      end
    end
    cb.add(cb.after_attack, on_after_attack)
    cb.add(cb.create_object, on_create_object)
    cb.add(cb.delete_object, f2)
    cb.add(cb.spell, f)
    
    cb.add(cb.tick, on_tick)
    cb.add(cb.draw, on_draw)
  else
      print("No Auth!")
  end
end)


