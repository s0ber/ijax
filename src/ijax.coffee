window.Ijax = class

  constructor: ->
    @IjaxRequest = modula.require('ijax/request')
    @requests = {}

  get: (path) ->
    @abortCurrentRequest()

    @curRequest = request = new @IjaxRequest(path)
    @requests[request.id] = request
    request

  abortCurrentRequest: ->
    return unless @curRequest?
    hasUnresolvedRequest = not @curRequest.isResolved
    hasUnresolvedResponse = not @curRequest.response?.isResolved

    if (hasUnresolvedRequest or hasUnresolvedResponse) and not @curRequest.isRejected
      @curRequest.reject()
      @removeRequest(@curRequest)

  removeRequest: (request) ->
    delete @requests[request.id]
    delete @curRequest

  registerResponse: (requestId, responseOptions) ->
    @curRequest.registerResponse(responseOptions)
    @curRequest.resolve()

  resolveResponse: ->
    @curRequest.response.resolve()
    @removeRequest(@curRequest)

  pushLayout: (html) ->
    @curRequest.response.addLayout(html)

  pushFrame: (frameId, frameHtml) ->
    @curRequest.response.addFrame(frameId, frameHtml)

modula.export('ijax', Ijax)
