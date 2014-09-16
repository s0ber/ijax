IjaxRequest = modula.require('ijax/request')

describe 'IjaxRequest', ->
  beforeEach ->
    @originalCreateIframeRequest = IjaxRequest::createIframeRequest
    IjaxRequest::createIframeRequest = sinon.spy ->
      $('<iframe />')[0]

    @request = new IjaxRequest('/some_path')

  afterEach ->
    IjaxRequest::createIframeRequest = @originalCreateIframeRequest


  describe '#constructor', ->
    it 'sets unique id for request', ->
      @anotherRequest = new IjaxRequest('/some_another_path')

      expect(@request.id).to.be.not.undefined
      expect(@anotherRequest.id).to.be.not.undefined
      expect(@request.id).to.be.not.eql @anotherRequest.id

    it 'saves provided path in @path, but with format, request id and full page params specified', ->
      expect(@request.path).to.be.eql "/some_path?format=al&i_req_id=#{@request.id}&full_page=true"

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
    it 'creates iframe with @id in name/id and @path in src', ->
      @request = new IjaxRequest('/some_path')
      @request.createIframeRequest = @originalCreateIframeRequest

      iframe = @request.createIframeRequest(false)

      expect(iframe.style.display).to.be.eql 'none'
      expect(iframe.id).to.be.eql @request.id
      expect($(iframe).attr('name')).to.be.eql @request.id
      expect($(iframe).attr('src')).to.be.eql @request.path

  describe '#registerResponse', ->
    it 'creates new IjaxResponse object in @response', ->
      sinon.spy(@request, 'IjaxResponse')
      @request.registerResponse()

      expect(@request.IjaxResponse).to.be.calledOnce
      expect(@request.response).to.be.instanceOf @request.IjaxResponse

  describe '#resolve', ->
    it 'sets request as resolved', ->
      @request.resolve()
      expect(@request.isResolved).to.be.true

    it 'calls onDoneCallback with @response object provided to it', ->
      fn = sinon.spy()
      @request.done fn
      @request.response = {}
      @request.resolve()

      expect(fn).to.be.calledOnce
      expect(fn.lastCall.args).to.be.eql [@request.response]

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

      @request.isResolved = true
      @request.iframe = $('<iframe id="my_iframe" />')[0]

      @request.updateIframeStatus()
      expect(@request.removeIframe).to.be.calledOnce

    context 'request is not resolved', ->
      it 'shows error', ->
        sinon.spy(@request, 'showError')

        @request.isResolved = false
        @request.iframe = $('<iframe id="my_iframe" />')[0]

        @request.updateIframeStatus()
        expect(@request.showError).to.be.calledOnce

    context 'request is resolved', ->
      it "doesn't show error", ->
        sinon.spy(@request, 'showError')

        @request.isResolved = true
        @request.iframe = $('<iframe id="my_iframe" />')[0]

        @request.updateIframeStatus()
        expect(@request.showError).to.be.not.called

