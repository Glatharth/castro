function get()
    local data = {}

    data.experience = config:get("rateExp")
    data.magic = config:get("rateMagic")
    data.skill = config:get("rateSkill")
    data.loot = config:get("rateLoot")
    data.protection = config:get("protectionLevel")
    data.redskull = config:get("killsToRedSkull")
    data.blackskull = config:get("killsToBlackSkull")
    data.worldType = config:get("worldType")
    data.timeToDecreaseFrags = time:newDuration(config:get("timeToDecreaseFrags") * math.pow(10, 6))
    data.whiteSkullTime = time:newDuration(config:get("whiteSkullTime") * math.pow(10, 6))


    http:render("serverinfo.html", data)
end
