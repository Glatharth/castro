
--[[
    Thanks to Znote as I used his php script to figure out what is being sent to and from the client.
]]

-- What is this? {"count":0,"isreturner":true,"offset":0,"showrewardnews":false,"type":"news"}
-- Only shows up sometimes. First login after client start possibly?

--[[ According to slavidodo
    errors:
    1 => thechnical error
    2 => ?
    3 => login error
    4 => ?
    5 => ?
    6 => two factor error
]]

function tprint (tbl, indent)
    if not indent then indent = 0 end
    local toprint = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2 
    for k, v in pairs(tbl) do
      toprint = toprint .. string.rep(" ", indent)
      if (type(k) == "number") then
        toprint = toprint .. "[" .. k .. "] = "
      elseif (type(k) == "string") then
        toprint = toprint  .. k ..  "= "   
      end
      if (type(v) == "number") then
        toprint = toprint .. v .. ",\r\n"
      elseif (type(v) == "string") then
        toprint = toprint .. "\"" .. v .. "\",\r\n"
      elseif (type(v) == "table") then
        toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
      else
        toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
      end
    end
    toprint = toprint .. string.rep(" ", indent-2) .. "}"
    return toprint
  end

local function sendError(msg, code)
    http:write(json:marshal({
        errorCode = code or 3,
        errorMessage = msg})
    )
end

function post()
    -- Ignore request if body is too short
    if http.body:len() < 10 then
        return
    end

    -- Placeholders
    local account
    local characters = {}
    local gamePort = config:get('gameProtocolPort')

    -- Get request data
    local result = json:unmarshal(http.body)
    if not result then
        log.Error("")
        return
    end

    print(tprint(result))
    print(http:getRemoteAddress())
    local data
    if result.type == "cacheinfo" then
        local online = db:singleQuery("SELECT COUNT(*) FROM players_online")
        data = {
            playersonline = tonumber(online),
			twitchstreams = 0,
			twitchviewer = 0,
			gamingyoutubestreams = 0,
			gamingyoutubeviewer = 0
        }
    elseif result.type == "eventschedule" then
        data = {
            eventlist = {
                {
                    colordark = "#7A4C1F",
                    colorlight = "#935416",
                    description = "Tester",
                    displaypriority = 2,
                    enddate = 1604134800,
                    isseasonal = false,
                    name = "Tester Active",
                    startdate = 1602004800
                },
                {
                    colordark = "#235c00",
                    colorlight = "#2d7400",
                    description = "Tester",
                    displaypriority = 3,
                    enddate = 1604394000,
                    isseasonal = false,
                    name = "Tester Upcoming",
                    startdate = 1604134800
                },
            }
        }
    elseif result.type == "boostedcreature" then
        local boosted = db:singleQuery("SELECT raceid FROM boosted_creature")
        data = {
            boostedcreature = true,
            raceid = tonumber(boosted.raceid)
        }
    elseif result.type == "login" then
        -- Get account data
        local email = result["email"]
        local password = result["password"]

        
        -- Normal login
        account = db:singleQuery("SELECT id, password, lastday, premdays, secret FROM accounts WHERE email = ? AND password = ?", email, crypto:sha1(password))
        if not account then
            return sendError("Wrong account name or password.")
        end

        -- Two factor
        if account.secret ~= nil then
            if not validator:validQRToken(result.token, account.secret) then
                return sendError("Invalid two-factor token. Please try again.", 6)
            end
        end

        -- Get account characters
        local chars = db:query("SELECT name, sex, level, vocation, looktype, lookhead, lookbody, looklegs, lookfeet, lookaddons, deletion FROM players WHERE account_id = ?", tonumber(account.id))

        if not chars then
            return sendError("Character list is empty.")
        end

        for _, c in pairs(chars) do
            table.insert(characters, {
                worldid = 0,
                name = c.name,
                ismale = ((tonumber(c.sex) == 1) and true or false),
                tutorial = false,
                level = c.level,
                vocation = c.vocation,
                outfitid = c.looktype,
                headcolor = c.lookhead,
                torsocolor = c.lookbody,
                legscolor = c.looklegs,
                detailcolor = c.lookfeet,
                addonsflags = c.lookaddons,
                ishidden = ((tonumber(c.deletion) == 1) and true or false),
                istournamentparticipant = false,
                remainingdailytournamentplaytime = 0
            })
        end

        data = {
            session = {
                ["fpstracking"] = false,
                ["isreturner"] = true,
                ["returnernotification"] = false,
                ["showrewardnews"] = false,
                ["sessionkey"] = string.format("%s\n%s", email, password),
                ["lastlogintime"] = account.lastday,
                ["ispremium"] = (account.premdays > 0),
                ["premiumuntil"] = os.time() + (account.premdays * 86400),
                ["status"] = "active",
                ['tournamentticketpurchasestate'] = 0,
                ['optiontracking'] = false,
                ['emailcoderequest'] = false

            },
            playdata = {
                worlds = {
                    {
                        ["id"] = 0,
                        ["name"] = config:get("serverName"),
                        ["externaladdress"] = config:get("ip"),
                        ["externalport"] = gamePort,
                        ["previewstate"] = 0,
                        ["location"] = config:get("location"),
                        ["externaladdressunprotected"] = config:get("ip"),
                        ["externalportunprotected"] = gamePort,
                        ["externaladdressprotected"] = config:get("ip"),
                        ["externalportprotected"] = gamePort,
                        ["anticheatprotection"] = false,
                        ["pvptype"] = config:get("worldType"),
                        ["istournamentworld"] = false,
                        ["restrictedstore"] = false,
                        ["currenttournamentphase"] = 2
                    }
                },
                characters = characters
            }
        }
    end
    http:write(json:marshal(data))
end