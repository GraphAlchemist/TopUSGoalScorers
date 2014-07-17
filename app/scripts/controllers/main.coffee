'use strict'

###*
 # @ngdoc function
 # @name soccercomparisonApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the soccercomparisonApp
###
angular.module('soccercomparisonApp')
  .controller 'MainCtrl', ['$scope'
  ($scope) ->

    $scope.showModal = -> $('#info-modal').modal('show')
    ]