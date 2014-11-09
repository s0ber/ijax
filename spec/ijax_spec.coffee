Ijax = modula.require 'ijax'

describe 'Ijax', ->

  beforeEach ->
    @ijax = new Ijax()

  describe '#constructor', ->
    it 'creates an object for storing all ijax requests', ->
      expect(@ijax.requests).to.be.eql {}

  describe '#get', ->
    beforeEach ->
      class @ijax.IjaxRequest
        id: '5'
        onResolve: ->

      sinon.spy(@ijax, 'IjaxRequest')

    it 'aborts current request', ->
      sinon.spy(@ijax, 'abortCurrentRequest')
      @ijax.get('some_path')
      expect(@ijax.abortCurrentRequest).to.be.calledOnce

    it 'creates new IjaxRequest object and saves it in @curRequest', ->
      @ijax.get('some_path')
      expect(@ijax.IjaxRequest).to.be.calledOnce
      expect(@ijax.curRequest).to.be.instanceOf @ijax.IjaxRequest

    it 'creates ijax request with providing a request path to constructor', ->
      @ijax.get('some_path')
      expect(@ijax.IjaxRequest.lastCall.args).to.be.eql ['some_path']

    it "saves created request in @requests hash by this requests's unique id", ->
      @ijax.get('some_path')
      expect(@ijax.requests['5']).to.be.equal @ijax.curRequest

    it 'returns a request', ->
      expect(@ijax.get('some_path')).to.be.equal @ijax.curRequest

  describe '#abortCurrentRequest', ->
    beforeEach ->
      @ijax.removeRequest = sinon.spy()

    context 'there is current request and this request is not resolved', ->
      it 'rejects this request', ->
        @ijax.curRequest =
          id: 5
          isResolved: false
          response: {isResolved: false}
          reject: sinon.spy()

        @ijax.abortCurrentRequest()
        expect(@ijax.curRequest.reject).to.be.calledOnce

    context 'there is current request and this request is resolved, but it response is unresolved', ->
      it 'rejects this request', ->
        @ijax.curRequest =
          id: 5
          isResolved: true
          response: {isResolved: false}
          reject: sinon.spy()

        @ijax.abortCurrentRequest()
        expect(@ijax.curRequest.reject).to.be.calledOnce

    context 'there is current request, which is resolved and which response is resolved', ->
      it "doesn't rejects this request", ->
        @ijax.curRequest =
          id: 5
          isResolved: true
          response: {isResolved: true}
          reject: sinon.spy()

        @ijax.abortCurrentRequest()
        expect(@ijax.curRequest.reject).to.be.not.called

    context 'there is current request, which is already rejected', ->
      it "doesn't rejects this request", ->
        @ijax.curRequest =
          id: 5
          isResolved: true
          response: {isResolved: false}
          isRejected: true
          reject: sinon.spy()

        @ijax.abortCurrentRequest()
        expect(@ijax.curRequest.reject).to.be.not.called

    it 'removes current request if it should be rejected', ->
      @ijax.curRequest =
        id: 5
        isResolved: false
        reject: ->

      @ijax.abortCurrentRequest()
      expect(@ijax.removeRequest.lastCall.args).to.be.eql [@ijax.curRequest]

  describe '#removeRequest', ->
    it "removes request from @requests by it's id", ->
      @ijax.requests =
        '5': {id: 5, isResolved: false}
        '10': {id: 10, isResolved: false}

      @ijax.removeRequest(@ijax.requests['10'])

      expect(@ijax.requests).to.be.eql
        '5': {id: 5, isResolved: false}

    it 'deletes request from @curRequest', ->
      @ijax.requests =
        '5': {id: 5, isResolved: false}
        '10': {id: 10, isResolved: false}

      @ijax.curRequest = @ijax.requests['10']
      @ijax.removeRequest(@ijax.requests['10'])
      expect(@ijax.curRequest?).to.be.false

  describe '#registerResponse', ->
    beforeEach ->
      @ijax.curRequest =
        registerResponse: sinon.spy()
        resolve: sinon.spy()

    it 'registers response for current request', ->
      @ijax.registerResponse()
      expect(@ijax.curRequest.registerResponse).to.be.calledOnce

    it 'resolves current request', ->
      @ijax.registerResponse()
      expect(@ijax.curRequest.resolve).to.be.calledOnce
      expect(@ijax.curRequest.registerResponse).to.be.calledBefore @ijax.curRequest.resolve

    context 'response options are passed', ->
      it 'registers response with provided response options', ->
        options = {a: 1, b: 2}
        @ijax.registerResponse('unique_id', options)
        expect(@ijax.curRequest.registerResponse).to.be.calledOnce
        expect(@ijax.curRequest.registerResponse.lastCall.args).to.be.eql [options]

  describe '#resolveResponse', ->
    beforeEach ->
      @ijax.removeRequest = sinon.spy()

      @ijax.curRequest =
        registerResponse: sinon.spy()
        resolve: sinon.spy()
        response:
          resolve: sinon.spy()

    it "resolves current request's response", ->
      @ijax.resolveResponse()
      expect(@ijax.curRequest.response.resolve).to.be.calledOnce

    it 'removes current request', ->
      @ijax.resolveResponse()
      expect(@ijax.removeRequest).to.be.calledOnce
      expect(@ijax.removeRequest.lastCall.args).to.be.eql [@ijax.curRequest]

  describe 'pushLayout', ->
    beforeEach ->
      @ijax.curRequest =
        response:
          addLayout: sinon.spy()
          addFrame: sinon.spy()

    it "provides layout to current request's response object", ->
      @ijax.pushLayout('some html here')
      expect(@ijax.curRequest.response.addLayout).to.be.calledOnce
      expect(@ijax.curRequest.response.addLayout.lastCall.args).to.be.eql ['some html here']

  describe 'pushFrame', ->
    beforeEach ->
      @ijax.curRequest =
        response:
          addLayout: sinon.spy()
          addFrame: sinon.spy()

    it "provides frame to current request's response object", ->
      @ijax.pushFrame(10, 'some html here')
      expect(@ijax.curRequest.response.addFrame).to.be.calledOnce
      expect(@ijax.curRequest.response.addFrame.lastCall.args).to.be.eql [10, 'some html here']

