class IjaxRequest

  IjaxResponse: modula.require('ijax/response')

  constructor: (path) ->
    @id = @_getGuid()
    @path = path
    @iframePath = @_updatePathParams(path, format: 'al', i_req_id: @id, full_page: true)

    @isResolved = false
    @isRejected = false

    @iframe = @createIframeRequest()
    @iframe.onload = _.bind(@updateIframeStatus, @)

  createIframeRequest: (appendToDom = true) ->
    src = @iframePath or 'javascript:false'

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

  _updatePathParams: (path, params) ->
    path

    for own key, value of params
      re = new RegExp("([?|&])#{key}=.*?(&|$)", 'i')
      separator = if path.indexOf('?') isnt -1 then '&' else '?'

      path =
        if re.test(path)
          path.replace(re, "$1#{key}=#{value}$2")
        else
          path + separator + key + '=' + value

    path

modula.export('ijax/request', IjaxRequest)
