'use strict'

describe 'Directive: viz', ->

  # load the directive's module
  beforeEach module 'soccercomparisonApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<viz></viz>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the viz directive'
