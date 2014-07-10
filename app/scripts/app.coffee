'use strict'

###*
 # @ngdoc overview
 # @name soccercomparisonApp
 # @description
 # # soccercomparisonApp
 #
 # Main module of the application.
###
angular
  .module('soccercomparisonApp', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch'
  ])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/about',
        templateUrl: 'views/about.html'
        controller: 'AboutCtrl'
      .otherwise
        redirectTo: '/'

