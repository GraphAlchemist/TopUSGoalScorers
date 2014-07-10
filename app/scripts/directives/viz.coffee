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
        padding = {top: 50, left: 50, right: 50, bottom: 50}
        height = 1000
        width = 1000
        chart = d3.select(element[0]).append('svg')
                                         .attr("id", "chart")
        yScale = d3.scale.linear()
                            .range([height, 0]) # note that the yaxis is inverted! 0 = top
        yAxis = d3.svg.axis()
                    .scale(yScale)
                    .orient("left")

        xScale = d3.scale.ordinal()
                        .rangeRoundBands([0, width], .1)
        xAxis = d3.svg.axis()
                    .scale(xScale)
                    .orient("bottom")                           
        
        # grab data
        d3.csv('data/goalscorers.csv', (requestdata) ->
            scope.data = requestdata
            
            yMax = d3.max(scope.data, (d) -> +d.Goals)            
            yScale.domain([0, yMax])
            xScale.domain(scope.data.map((d) -> 
                d.Player)) 
            

            yAxisGroup = chart.append("g")
                                .attr("class", "y axis")
                                .call(yAxis)

            # each player should be a label on the graph
            playerSpacing = width / 20 # 1 player occupies a space of 20px on the x axis   

            xAxisGroup = chart.append("g")
                                .attr("class", "x axis")
                                .attr("transform", "translate(0, #{height})")
                                .call(xAxis)
                              .selectAll("text")
                                .attr("transform", "rotate(-90)")

            playerGoals = chart.selectAll(".ranges")
                                .data(scope.data)
                                .enter().append("g")
                                .attr("class", (d) ->
                                    if d.Gender is "Male"
                                        return "ranges Male"
                                    else
                                        return "ranges Female"
                                        )
                                .append("rect") # place holder bars - as discussed, each goal should be a data point e.g a <circle>
                                .attr("width", xScale.rangeBand())
                                .attr("height", (d) -> height - yScale(+d.Goals))
                                .attr("x", (d) -> xScale(d.Player))
                                .attr("y", (d) -> yScale(d.Goals)) # note that the yaxis is inverted! 0 = top
                                


            return
            )
  )
