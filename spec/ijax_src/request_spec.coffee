IjaxRequest = modula.require('ijax/request')

describe 'IjaxRequest', ->

  beforeEach ->
    sinon.stub(IjaxRequest::, 'createIframeRequest').returns $('<iframe />')[0]
    @request = new IjaxRequest('/some_path')

  afterEach ->
    IjaxRequest::createIframeRequest.restore?()

  describe '#constructor', ->
    it 'sets unique id for request', ->
      @anotherRequest = new IjaxRequest('/some_another_path')

      expect(@request.id).to.be.not.undefined
      expect(@anotherRequest.id).to.be.not.undefined
      expect(@request.id).to.be.not.eql @anotherRequest.id

    it 'saves provided path in @path, but with format, request id and full page params specified', ->
      expect(@request.path).to.be.eql "/some_path"

    it 'saves path with format, request id and full page params specified in @iframePath', ->
      expect(@request.iframePath).to.be.eql "/some_path?format=al&i_req_id=#{@request.id}&full_page=true"

    it 'creates isResolved and isRejected false flags', ->
      expect(@request.isResolved).to.be.false
      expect(@request.isRejected).to.be.false

    it 'creates new iframe and saves reference to it in @iframe', ->
      expect(@request.createIframeRequest).to.be.calledOnce
      expect(@request.iframe).to.have.property('tagName', 'IFRAME')

    it 'adds onload callback to iframe', ->
      sinon.spy(IjaxRequest::, 'updateIframeStatus')
      @anotherRequest = new IjaxRequest('/some_path')

      @anotherRequest.iframe.onload()
      expect(@anotherRequest.updateIframeStatus).to.be.calledOnce

      IjaxRequest::updateIframeStatus.restore()

  describe '#done', ->
    it 'saves provided callback in @onDoneCallback', ->
      fn = sinon.spy()
      @request.done(fn)
      expect(@request.onDoneCallback).to.be.equal fn

    it 'returns request', ->
      expect(@request.done(->)).to.be.equal @request

  describe '#fail', ->
    it 'saves provided callback in @onFailCallback', ->
      fn = sinon.spy()
      @request.fail(fn)
      expect(@request.onFailCallback).to.be.equal fn

    it 'returns request', ->
      expect(@request.fail(->)).to.be.equal @request

  describe '#createIframeRequest', ->
    it 'creates iframe with @id in name/id and @iframePath in src', ->
      @request = new IjaxRequest('/some_path')
      @request.createIframeRequest.restore()

      iframe = @request.createIframeRequest(false)

      expect(iframe.style.display).to.be.eql 'none'
      expect(iframe.id).to.be.eql @request.id
      expect($(iframe).attr('name')).to.be.eql @request.id
      expect($(iframe).attr('src')).to.be.eql @request.iframePath

  describe '#registerResponse', ->
    it 'creates new IjaxResponse object in @response', ->
      sinon.spy(@request, 'IjaxResponse')
      @request.registerResponse()

      expect(@request.IjaxResponse).to.be.calledOnce
      expect(@request.response).to.be.instanceOf @request.IjaxResponse

    it 'provides response options with request path to IjaxResponse constructor', ->
      sinon.spy(@request, 'IjaxResponse')
      options = {a: 1, b: 2}
      @request.registerResponse(options)

      expect(@request.IjaxResponse).to.be.calledOnce
      expect(@request.IjaxResponse.lastCall.args).to.be.eql [{path: '/some_path', a: 1, b: 2}]

  describe '#resolve', ->
    it 'sets request as resolved', ->
      @request.registerResponse()
      @request.resolve()
      expect(@request.isResolved).to.be.true

    it 'calls onDoneCallback with @response object provided to it', ->
      fn = sinon.spy()
      @request.done fn
      @request.response = {}
      @request.resolve()

      expect(fn).to.be.calledOnce
      expect(fn.lastCall.args).to.be.eql [@request.response]

    it "calls configured Ijax.config().onRequestResolve callback with response, it's options and request path provided", ->
      sinon.spy(Ijax.config(), 'onRequestResolve')
      @request.registerResponse()
      @request.resolve()

      expect(Ijax.config().onRequestResolve).to.be.calledOnce
      expect(Ijax.config().onRequestResolve.lastCall.args).to.be.eql [@request.response, @request.response.options, @request.path]
      Ijax.config().onRequestResolve.restore()

    context 'Ijax.config().onRequestResolve returns false', ->
      it "doesn't call @onResolveCallback", ->
        Ijax.configure(onRequestResolve: -> false)
        fn = sinon.spy()
        @request.done fn
        @request.registerResponse()
        @request.resolve()
        expect(fn).to.be.not.called

        Ijax.configure(onRequestResolve: -> true)
        @request.resolve()
        expect(fn).to.be.calledOnce
        Ijax._config = null

      it 'rejects request', ->
        Ijax.configure(onRequestResolve: -> false)
        fn = sinon.spy()
        sinon.spy(@request, 'reject')
        @request.done fn
        @request.registerResponse()
        @request.resolve()
        expect(@request.reject).to.be.calledOnce
        Ijax._config = null

      it "doesn't show error", ->
        Ijax.configure(onRequestResolve: -> false)
        fn = sinon.spy()
        sinon.spy(@request, 'showError')
        @request.done fn
        @request.registerResponse()
        @request.resolve()
        expect(@request.showError).to.be.not.called
        Ijax._config = null

  describe '#reject', ->
    it 'sets request as rejected', ->
      @request.reject()
      expect(@request.isRejected).to.be.true

    it 'calls @onFailCallback', ->
      fn = sinon.spy()
      @request.fail fn
      @request.response = {}
      @request.reject()

      expect(fn).to.be.calledOnce

    it 'removes iframe', ->
      sinon.spy(@request, 'removeIframe')
      @request.reject()
      expect(@request.removeIframe).to.be.calledOnce

  describe '#removeIframe', ->
    it 'removes iframe from DOM', ->
      $iframe = $('<iframe id="my_iframe" />')
      $('body').append($iframe)

      @request.iframe = $iframe[0]
      expect($('#my_iframe').length).to.be.eql 1
      @request.removeIframe()
      expect($('#my_iframe').length).to.be.eql 0

  describe '#updateIframeStatus', ->
    it 'removes iframe', ->
      sinon.spy(@request, 'removeIframe')

      @request.iframe = $('<iframe id="my_iframe" />')[0]
      @request.registerResponse()
      @request.resolve()
      @request.response.resolve()

      @request.updateIframeStatus()
      expect(@request.removeIframe).to.be.calledOnce

    context 'request is not resolved', ->
      it 'shows error', ->
        sinon.spy(@request, 'showError')

        @request.iframe = $('<iframe id="my_iframe" />')[0]
        @request.updateIframeStatus()

        expect(@request.showError).to.be.calledOnce

    context 'response is not resolved', ->
      it 'shows error', ->
        sinon.spy(@request, 'showError')

        @request.iframe = $('<iframe id="my_iframe" />')[0]
        @request.registerResponse()
        @request.resolve()

        @request.updateIframeStatus()
        expect(@request.showError).to.be.calledOnce

    context 'request and response are resolved', ->
      it "doesn't show error", ->
        sinon.spy(@request, 'showError')

        @request.iframe = $('<iframe id="my_iframe" />')[0]
        @request.registerResponse()
        @request.resolve()
        @request.response.resolve()

        @request.updateIframeStatus()
        expect(@request.showError).to.be.not.called

  describe '#showError', ->
    it "calls configured Ijax.config().onResponseFail callback with request path provided", ->
      sinon.spy(Ijax.config(), 'onResponseFail')
      @request.showError()
      expect(Ijax.config().onResponseFail).to.be.calledOnce
      expect(Ijax.config().onResponseFail.lastCall.args).to.be.eql [@request.path]
      Ijax._config = null
