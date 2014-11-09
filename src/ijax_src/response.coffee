class IjaxResponse

  constructor: (@options) ->
    @isResolved = false

  onResolve: (@onResolveCallback) ->
    @

  onLayoutReceive: (@onLayoutReceiveCallback) ->
    @

  onFrameReceive: (@onFrameReceiveCallback) ->
    @

  resolve: ->
    @isResolved = true
    @onResolveCallback?(@options)

  addLayout: (layoutHtml) ->
    @onLayoutReceiveCallback?(layoutHtml)

  addFrame: (frameId, frameHtml) ->
    @onFrameReceiveCallback?(frameId, frameHtml)

modula.export('ijax/response', IjaxResponse)
