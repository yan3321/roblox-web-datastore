local config = {["url"] = "1.2.3.4", ["port"] = 5050}

local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")

local nodeDatastore = {}

local objectStorage = {}

local datastores = {}

function nodeDatastore:GetDataStore(name)
    if not datastores[name] then
        local host = "http://" .. config["url"] .. ":" .. config["port"]
        local bindable = Instance.new("BindableEvent")
        local datastore = {}
        datastore["OnUpdate"] = bindable.Event
        datastore["GetCache"] = {}

        local topic = "nodeDatastore_" .. name

        local function Update(key, publish)
            datastore["GetCache"][key] = datastore:GetAsync(key, true)
            bindable:Fire(key)
            if publish then
                local publishSuccess, publishResult =
                    pcall(function()
                        local message = {
                            ["JobId"] = game.JobId,
                            ["Message"] = key
                        }
                        local encodedMessage = HttpService:JSONEncode(message)
                        MessagingService:PublishAsync(topic, encodedMessage)
                    end)
                if not publishSuccess then print(publishResult) end
            end
        end

        local function GetRequest(key)
            print("Making GET request for key: " .. key)
            local response = HttpService:RequestAsync(
                                 {
                    Url = host .. "/" .. "?" .. "key=" .. key,
                    Method = "GET"
                })
            if response.Success then
                print("Status code:", response.StatusCode,
                      response.StatusMessage)
                local body = response.Body
                print("GET Response data type:\n", typeof(body))
                print("GET Response body:\n", body)
                return body
            else
                error("The request failed:", response.StatusCode,
                      response.StatusMessage)
            end
        end

        local function PostRequest(key, value)
            print("Making POST request for key: " .. key)
            local response = HttpService:RequestAsync(
                                 {
                    Url = host .. "/" .. "?" .. "key=" .. key,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(value)
                })
            if response.Success then
                print("Status code:", response.StatusCode,
                      response.StatusMessage)
                print("POST Response body:\n", response.Body)
                return response.Body
            else
                error("The request failed:", response.StatusCode,
                      response.StatusMessage)
            end
        end

        function datastore:SetAsync(key, value)
            if key == nil then
                error("Key is nil. Must not be nil.")
                return false
            end
            local internalKey = name .. "_" .. key
            local success, message = pcall(PostRequest, internalKey, value)
            if success then
                Update(key, true)
                return true
            else
                return false
            end
        end

        function datastore:GetAsync(key, ignoreCache)
            if key == nil then
                error("Key is nil. Must not be nil.")
                return false
            end

            if not ignoreCache then
                local cached = datastore["GetCache"][key]
                if cached then
                    print("Retrieved cached value for key: " .. key .. ".")
                    return cached
                end
            end

            local internalKey = name .. "_" .. key
            local success, message = pcall(GetRequest, internalKey)
            if success then
                local body = message
                local decodedData = HttpService:JSONDecode(body)
                datastore["GetCache"][key] = decodedData
                return decodedData
            else
                return false
            end
        end

        pcall(function()
            MessagingService:SubscribeAsync(topic, function(data)
                local encodedmessage = data.Data
                local timeSent = data.Sent
                local decodedmessage = HttpService:JSONDecode(encodedmessage)
                local key = decodedmessage.Message
                if key then
                    if typeof(key) == "string" then
                        Update(key)
                    else
                        print("MessagingService recieved odd non key value.")
                    end
                end
            end)
        end)

        datastores[name] = datastore

    end
    return datastores[name]
end

return nodeDatastore