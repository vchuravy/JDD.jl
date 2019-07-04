
import HTTP.WebSockets: WebSocket
function handle_rpcs(ws::WebSocket)
    while !eof(ws)
        data = readavailable(ws)
        rpc = JSON2.read(IOBuffer(data))
        dispatch(rpc, ws)
    end
end

const _msg_id = Ref{Int}(0)
msg_id() = _msg_id[] += 1

function dispatch(rpc, ws)
    resp = @match rpc.method begin
        "Runtime.enable"  => Runtime.enable()
        "Runtime.runIfWaitingForDebugger"  => Runtime.runIfWaitingForDebugger()
        "Debugger.setPauseOnExceptions" => Debugger.setPauseOnExceptions(rpc.params)
        "Debugger.setAsyncCallStackDepth" => Debugger.setAsyncCallStackDepth(rpc.params)
        "Debugger.setBlackboxPatterns" => Debugger.setBlackboxPatterns(rpc.params)
        "Debugger.setBreakpointsActive" => Debugger.setBreakpointsActive(rpc.params)
        "Debugger.setBreakpointByUrl"  => Debugger.setBreakpointByUrl(rpc.params)
        "Debugger.enable" => Debugger.enable()
        _                 => dispatch_unhandled(rpc)
    end

    # each response has to hve the same id as the source
    resp = merge((;id = rpc.id), resp)
    @show resp
    io = IOBuffer()
    JSON2.write(io, resp)
    write(ws, take!(io))
end

function dispatch_unhandled(rpc)
    @info "Unhandled rpc" rpc
    return ()
end


module Debugger
    enable() = (;debuggerId = "0")
    setPauseOnExceptions(params) = ()
    setAsyncCallStackDepth(params) = ()
    setBlackboxPatterns(params) = ()
    setBreakpointsActive(params) = ()
    setBreakpointByUrl(params) = ()
    # pause
    # setSkipAllPauses
end

module Runtime
    enable() = ()
    runIfWaitingForDebugger() = ()
    getIsolateId() = ()
end
