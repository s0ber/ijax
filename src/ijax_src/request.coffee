class IjaxRequest

  IjaxResponse: modula.require('ijax/response')

  constructor: (path) ->
    @id = @_getGuid()
    @path = path

    @isResolved = false
    @isRejected = false

    @iframe = @createIframeRequest()
    @iframe.onload = _.bind(@updateIframeStatus, @)

  createIframeRequest: (appendToDom = true) ->
    src = @path or 'javascript:false'

    tmpElem = document.createElement('div')
    tmpElem.innerHTML = "<iframe name=\"#{@id}\" id=\"#{@id}\" src=\"#{src}\">"

    iframe = tmpElem.firstChild
    iframe.style.display = 'none'

    document.body.appendChild(iframe) if appendToDom
    iframe

  registerResponse: (responseOptions) ->
    responseOptions = _.extend(path: @path, responseOptions)
    @response = new @IjaxResponse(responseOptions)

  done: (@onDoneCallback) ->
    @

  fail: (@onFailCallback) ->
    @

  resolve: ->
    @isResolved = true
    if Ijax.config().onRequestResolve(@response, @response.options, @path) is false
      @reject()
    else
      @onDoneCallback?(@response)

  reject: ->
    @isRejected = true
    @onFailCallback?()
    @removeIframe()

  updateIframeStatus: ->
    @removeIframe()
    if not @isResolved or not @response.isResolved
      @showError()

  showError: ->
    Ijax.config().onResponseFail(@path)

  removeIframe: ->
    @iframe.parentNode?.removeChild(@iframe)

  _getGuid: ->
    @_s4() + @_s4() + '-' + @_s4() + '-' + @_s4() + '-' + @_s4() + '-' + @_s4() + @_s4() + @_s4()

  _s4: ->
    Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1)

modula.export('ijax/request', IjaxRequest)
