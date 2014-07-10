'use strict'

###*
 # @ngdoc function
 # @name soccercomparisonApp.controller:AboutCtrl
 # @description
 # # AboutCtrl
 # Controller of the soccercomparisonApp
###
angular.module('soccercomparisonApp')
  .controller 'AboutCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
