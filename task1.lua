local socket = require("socket")

local server = assert(socket.bind("*", 8080))
server:settimeout(0) 

local clients = {} 
print("Server running on *:8080")

local function handle_client(client)
    client:settimeout(0) 
    while true do
        local line, err = client:receive()
        if not err then
            print("Received: " .. line)
            client:send("Echo: " .. line .. "\n")
        elseif err == "closed" then
            break
        elseif err ~= "timeout" then
            print("Error: " .. err)
            break
        end
        coroutine.yield()
    end
    client:close()
    print("Client disconnected")
end

while true do
    local client = server:accept()
    if client then
        print("New client connected")
        local co = coroutine.create(handle_client)
        clients[co] = client
        coroutine.resume(co, client)
    end

    for co, client in pairs(clients) do
        if coroutine.status(co) == "suspended" then
            coroutine.resume(co)
        elseif coroutine.status(co) == "dead" then
            clients[co] = nil 
        end
    end

    socket.sleep(0.01)
end
