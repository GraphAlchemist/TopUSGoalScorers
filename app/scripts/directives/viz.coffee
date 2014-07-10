'use strict'

###*
 # @ngdoc directive
 # @name soccercomparisonApp.directive:viz
 # @description
 # # viz
###
angular.module('soccercomparisonApp')
  .directive('viz', ->
    restrict: 'E'
    link: (scope, element, attrs) ->
        # grab data
        d3.csv('data/goalscorers.csv', (requestdata) ->
            scope.data = requestdata
            height = 1000
            axisHeight = 500
            yMax = d3.max(scope.data, (d) -> +d.Goals)
            yScale = d3.scale.linear()
                                .range([height, 0])
                                .domain([0, yMax])

            yAxis = d3.svg.axis()
                            .scale(yScale)
                            .orient("left")

            chart = d3.select(element[0]).append('svg')
                                         .attr("id", "chart")

            yAxisGroup = chart.append("g")
                                .attr("class", "y axis")
                                .call(yAxis)

            # each player should be a label on the graph
            playerSpacing = 20 # 1 player occupies a space of 20px on the x axis   
            xScale = d3.scale.linear()
                                .range([0, (scope.data.length + 1) * playerSpacing])

            xAxis = d3.svg.axis()
                            # .tickValues(scope.data, (d, i) -> i)
                            .scale(xScale)
                            .orient("bottom")

            xAxisGroup = chart.append("g")
                                .attr("class", "x axis")
                                .attr("transform", "translate(0, #{axisHeight})")
                                .call(xAxis) 
            return
            )
  )
