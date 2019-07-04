module JDD

using Debugger
using HTTP
using HTTP.WebSockets
using JSON2
using Rematch

const INSTANCE = Ref{Tuple{String, Int}}()

include("rpcs.jl")
include("endpoints.jl")

function server(;host=HTTP.Sockets.localhost, port=9229)
  @info "Starting server on" host port
  INSTANCE[] = (string(host), port)

  ROUTER = HTTP.Router()
  HTTP.@register(ROUTER, "GET", "/json/version", version)
  HTTP.@register(ROUTER, "GET", "/json", main)
  HTTP.@register(ROUTER, "GET", "/json/list", main)
  HTTP.@register(ROUTER, "GET", "/ws", handle_rpcs)

  println("""
      Debugger started
        to begin debugging open: chrome-devtools://devtools/bundled/js_app.html?experiments=true&ws=$host:$port/ws
      """)
  HTTP.serve(ROUTER, host, port)
end

end # module
