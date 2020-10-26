
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

local function sendError(msg, code)
    http:write(json:marshal({errorCode = code or 3, errorMessage = msg}))
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

    if result.type ~= "login" then -- sometimes we get a request with type = "news" - What is this?
        return
    end

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
    local chars = db:query("SELECT name, sex FROM players WHERE account_id = ?", tonumber(account.id))

    if not chars then
        return sendError("Character list is empty.")
    end

    for _, c in pairs(chars) do
        table.insert(characters, {worldid = 0, name = c.name, ismale = ((tonumber(c.sex) == 1) and true or false), tutorial = false})
    end

    local data = {
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
    http:write(json:marshal(data))
end