MyClass = modula.require 'my_class'

describe 'MyClass', ->

  beforeEach ->
    @object = new MyClass()

  describe '#constructor', ->

    it 'sets @property to true', ->
      expect(@object.property).to.be.true
