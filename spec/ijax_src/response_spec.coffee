IjaxResponse = modula.require('ijax/response')

describe 'IjaxResponse', ->

  beforeEach ->
    @responseOptions = {a: 1, b: 2}
    @response = new IjaxResponse(@responseOptions)

  describe '#constructor', ->
    it 'sets @isResolved flag as false', ->
      expect(@response.isResolved).to.be.false

    it 'saves provided options in @options', ->
      expect(@response.options).to.be.equal @responseOptions

  describe '#onResolve', ->
    it 'saves provided callback in @onResolveCallback', ->
      fn = ->
      @response.onResolve fn
      expect(@response.onResolveCallback).to.be.equal fn

    it 'returns response object (for chaining)', ->
      expect(@response.onResolve(->)).to.be.equal @response

  describe '#resolve', ->
    it 'sets response as resolved', ->
      @response.resolve()
      expect(@response.isResolved).to.be.true

    it 'calls @onResolveCallback with response options provided', ->
      fn = sinon.spy()
      @response.onResolve fn
      @response.resolve()
      expect(fn).to.be.calledOnce
      expect(fn.lastCall.args).to.be.eql [@responseOptions]

  describe 'onLayoutReceive', ->
    it 'saves provided callback in @onResolveCallback', ->
      fn = ->
      @response.onLayoutReceive fn
      expect(@response.onLayoutReceiveCallback).to.be.equal fn

    it 'returns response object (for chaining)', ->
      expect(@response.onLayoutReceive(->)).to.be.equal @response

  describe '#addLayout', ->
    it 'calls @onLayoutReceiveCallback passing arguments to it', ->
      fn = sinon.spy()
      @response.onLayoutReceive fn
      @response.addLayout('some layout html')
      expect(fn).to.be.calledOnce
      expect(fn.lastCall.args).to.be.eql ['some layout html']

  describe 'onFrameReceive', ->
    it 'saves provided callback in @onResolveCallback', ->
      fn = ->
      @response.onFrameReceive fn
      expect(@response.onFrameReceiveCallback).to.be.equal fn

    it 'returns response object (for chaining)', ->
      expect(@response.onFrameReceive(->)).to.be.equal @response

  describe '#addFrame', ->
    it 'calls @onFrameReceiveCallback passing arguments to it', ->
      fn = sinon.spy()
      @response.onFrameReceive fn
      @response.addFrame(10, 'some frame html')
      expect(fn).to.be.calledOnce
      expect(fn.lastCall.args).to.be.eql [10, 'some frame html']

