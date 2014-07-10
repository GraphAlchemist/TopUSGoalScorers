'use strict'

describe 'Service: Data', ->

  # load the service's module
  beforeEach module 'soccercomparisonApp'

  # instantiate service
  Data = {}
  beforeEach inject (_Data_) ->
    Data = _Data_

  it 'should do something', ->
    expect(!!Data).toBe true
