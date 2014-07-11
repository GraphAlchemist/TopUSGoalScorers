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
        height = 800
        width = 1000
        chart = d3.select(element[0]).append('svg')
                                         .attr("id", "chart")
                                         .attr("height", height)
                                         .attr("width", width)
        yScale = d3.scale.linear()
                            .range([height, 0]) # note that the yaxis is inverted! 0 = top
        yAxis = d3.svg.axis()
                    .scale(yScale)
                    .orient("right")
                    .ticks(16)
                    .tickSize(width)

        xScale = d3.scale.ordinal()
                        .rangeRoundBands([0, width], .1)
        xAxis = d3.svg.axis()
                    .scale(xScale)
                    .orient("bottom")                           
        
        # grab data
        d3.csv('data/goalscorers.csv', (requestdata) ->
            scope.data = requestdata
            
            yMax = d3.max(scope.data, (d) -> +(d.Goals))            
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
                                .attr("id", (d) -> return d)
                                .attr("transform", (d, i)-> 
                                    data = scope.data[i]
                                    yIfTopEleven = (height - yScale(-data.Goals)) + 80

                                    x = xScale.rangeBand() - 40
                                    y = if parseInt(data.Goals) > 45 then yIfTopEleven else - 80
                                    return "translate(#{x},#{y}) rotate(-90)")

            playerGoals = chart.selectAll(".ranges")
                                .data(scope.data)
                                .enter().append("g")
                                .attr("id", (d,i) -> return "group-#{i}")
                                .attr("class", (d) ->
                                    if d.Gender is "Male"
                                        return "ranges Male"
                                    else
                                        return "ranges Female"
                                        )
                                .append("rect") # Leaving placeholder bars for styling/interaction
                                .attr("x", (d) -> xScale(d.Player) - 10)
                                .attr("y", (d) -> return yScale(d.Goals)) # note that the yaxis is inverted! 0 = top
                                .attr("width", xScale.rangeBand())
                                .attr("height", (d) -> height - yScale(+d.Goals))

            goalSprites = chart.selectAll("g.ranges")
                               .data(scope.data.map((d,i)->
                                  goals = [1..parseInt(d.Goals)]
                                  return goals ))
                               # .enter()
                               .selectAll("circle")
                               .data((d,i)-> return d)
                               .enter()
                               .append("circle")
                               .attr("r", "2")
                               .attr("cx", (d,i) ->
                                    rect = d3.select(this.parentNode).select("rect")  
                                    max = rect.attr("x")
                                    min = max - 5 
                            
                                    randomX = Math.random() * (max - min) + min 
                                    offset = 10
                            
                                    return  randomX + offset)
                               .attr("cy", (d,i) ->
                                    g = d3.select(this.parentNode)
                                    rect = g.select("rect")
                                    rectY = parseInt rect.attr("y")
                                    rectHeight = parseInt rect.attr("height")
                                    ballPadding = 5

                                    return rectY + rectHeight - (i * ballPadding) )

            return
            )

  )
