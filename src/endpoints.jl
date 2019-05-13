
import HTTP.Handlers: HandlerFunction, handle

function handle(::HandlerFunction{typeof(handle_rpcs)}, http::HTTP.Stream)
    HTTP.WebSockets.upgrade(handle_rpcs, http)
end

function version(req::HTTP.Request)
    host, port = INSTANCE[]
    resp = Dict(
        "Protocol-Version" => "1.3",
        "webSocketDebuggerUrl" => "ws://$host:$port/ws",
        )
    return HTTP.Response(200, JSON2.write(resp))
end

function main(req::HTTP.Request)
    host, port = INSTANCE[]
    resp = [
        Dict(
             "webSocketDebuggerUrl" => "ws://$host:$port/ws"
            ),
            ]
    return HTTP.Response(200, JSON2.write(resp))
end
