
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
    meth = @match rpc.method begin
        "Runtime.enable"                    => Runtime.enable
        "Runtime.runIfWaitingForDebugger"   => Runtime.runIfWaitingForDebugger
        "Runtime.getHeapUsage"              => Runtime.getHeapUsage
        "Debugger.setPauseOnExceptions"     => Debugger.setPauseOnExceptions
        "Debugger.setAsyncCallStackDepth"   => Debugger.setAsyncCallStackDepth
        "Debugger.setBlackboxPatterns"      => Debugger.setBlackboxPatterns
        "Debugger.setBreakpointsActive"     => Debugger.setBreakpointsActive
        "Debugger.setBreakpointByUrl"       => Debugger.setBreakpointByUrl
        "Debugger.enable" => Debugger.enable
        _                 => nothing 
    end
    resp = if meth === nothing
        Base.invokelatest(dispatch_unhandled, rpc)
    else
        try 
        if isdefined(rpc, :params)
            Base.invokelatest(meth, rpc.params)
        else
            Base.invokelatest(meth)
        end
        catch e
            Base.showerror(stderr,e,Base.catch_backtrace())
            ()
        end
    end

    # each response has to hve the same id as the source
    resp = (;id = rpc.id, result = resp)
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
    enable(params) = (;debuggerId = "0")
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
    getHeapUsage(params)= (;usedSize = 1024, totalSize = 4096)
end
