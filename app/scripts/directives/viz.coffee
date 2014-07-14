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
        margin = {top: 20, left: 20, bottom: 20, right: 20}
        scaleFactor = 0.8
        height = angular.element(document).height() * scaleFactor - margin.top - margin.bottom
        width = angular.element(document).width() * scaleFactor- margin.left - margin.right

        chart = d3.select(element[0]).append('svg')
                                         .attr("id", "chart")
                                         .attr("height", height + margin.top + margin.bottom)
                                         .attr("width", width + margin.right + margin.left)
                                         .append('g')

        
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
            goalData = requestdata.map (d)-> [1..parseInt d.Goals ]

            yMax = d3.max scope.data, (d) -> +(d.Goals)
            yMin = d3.min scope.data, (d) -> +(d.Goals)          
            yScale.domain [0, yMax + 30]
            xScale.domain scope.data.map (d) -> d.Player 
            

            yAxisGroup = chart.append("g")
                                .attr("class", "y axis")
                                .call(yAxis)

            barPadding = 3 # this unit is in goals scored, as in yScale(barPadding)
            labelPadding = 5 # this unit is in goals scored, as in yScale(labelPadding)
            xAxisGroup = chart.append("g")
                                .attr("class", "x axis")
                                .attr("transform", "translate(0, #{height})")
                                .call(xAxis)
                              .selectAll("text")
                                .style("text-anchor", "start")
                                .attr("y", "-10")
                                .attr("x", xScale.rangeBand()/2)

            # colors
            femaleColors = d3.scale.linear()
                                    .domain [yMin, yMax]
                                    .range colorbrewer.Reds[3]
            maleColors = d3.scale.linear()
                                  .domain [yMin, yMax]
                                  .range colorbrewer.Blues[3]

            playerGoals = chart.selectAll(".ranges")
                                .data(scope.data)
                                .enter().append("g")
                                .attr("id", (d,i) -> "group-#{i}")
                                .attr("class", (d) ->
                                    if d.Gender is "Male"
                                        "ranges Male"
                                    else
                                        "ranges Female"
                                        )
                                .append("rect")
                                .attr("x", (d) -> xScale(d.Player)) # adjust labels, not position of bars
                                .attr("y", (d) -> yScale(+d.Goals + barPadding)) # note that the yaxis is inverted! 0 = top
                                .attr("width", xScale.rangeBand())
                                .attr("height", (d) -> height - yScale(+d.Goals + barPadding)) # extra padding for top of goals
                                .style("fill", (d) ->
                                  # genderColors((d.Goals * rangeOfContrast) + manualDarkening)
                                  if d.Gender is "Female" then femaleColors((+d.Goals * 2.5) + 80)
                                  else if d.Gender is "Male" then maleColors((+d.Goals * 6) + 140 )
                                  )

            # adjust labels to top left of bar
            d3.selectAll("g.x.axis .tick")
                .attr("id", (d) -> return d)
                .attr("transform", (d, i) ->
                  #put the tick on the top right corner of the rect
                  rect = d3.select("g#group-#{i} rect")
                  if not rect.empty()
                    x = rect.attr("x")
                    y = height - +rect.attr("y") 
                    "translate(#{x}, -#{y}) rotate(-30)")

        #O===========O
        #| Behaviors |
        #O===========O
        # Zoom
            zoom = d3.behavior
                     .zoom()
                     .scaleExtent [1,10]
                     .on("zoom", ->
                          chart.attr("transform", "translate(#{d3.event.translate}) scale(#{d3.event.scale})"))
            chart.call zoom

        # Mouse over player-bar
            tipHTML = (d) ->
              """
              <div class='tip-container'>
                <div class='name'><h4>#{d.Player}<h4></div>
                <div class='youtube'>
                  <!--<iframe width='280' height='158' src='http://www.youtube.com/embed/jCar99nTSxA?rel=0&qv=small' frameborder='0'></iframe>-->
                </div>
              </div>
              """

            tip = d3.tip()
                    .attr("class", "d3-tip")
                    .html((d)-> tipHTML d )
                    .offset([10, 120])
                    
            playerGoals.call tip
            playerGoals.on "mouseover", (d)-> tip.show d

        # Mouse over goalSprite
            d3.selectAll(".goal").on "mouseover", -> 
              d3.select(".youtube").html("Youtube vid of goal")

            goalSprites = chart.selectAll("g.ranges")
                               .data(goalData)
                               .selectAll("circle")
                               .data((d)-> d)
                               .enter()
                               .append("circle")
                               .attr("r", "1.0")
                               .attr("cx", () ->
                                    rect = d3.select(@parentNode).select("rect")  
                                    padding = {left: 12, right: 12}
                                    # lets use rangeband instead
                                    max = +rect.attr("x") + xScale.rangeBand() - padding.right
                                    min = +rect.attr("x") + padding.left
                                    randomX = Math.random() * (max - min) + min 
                                    )
                                .attr("cy", (d) ->  yScale(d))
                                .classed("goal", true)


            return

            )

  )
