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
        goalColors = d3.shuffle([
                                "#DD79FF", "#FFFC00",
                                "#00FF30", "#5168FF",
                                "#00C0FF", "#FF004B",
                                "#00CDCD", "#f83f00",
                                "#f800df", "#ff8d8f",
                                "#ffcd00", "#184fff",
                                "#ff7e00"
                                ])
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
                    .tickSize(width)

        xScale = d3.scale.ordinal()
                        .rangeRoundBands([0, width], .1)
        xAxis = d3.svg.axis()
                    .scale(xScale)
                    .orient("bottom")                                   

        legendHTML =
            """
            <div class='legend'>
              <h1>This is the legend!</h1>
            </div>
            """
        
        legend = d3.tip()
                  .attr("class", "d3-tip legend")
                  .html(legendHTML)
                  .direction('sw')
                  .offset([0, width - margin.right])

        # fadeIn = () ->
        #     @attr("style", "opacity:0;")
        #         .transition()
        #         .duration(4200)
        #         .attr("style", "opacity:1;")
        
        # chart.call(legend)
  
          # chart.on("mouseover", legend.show)
                      # chart.append("rect")
                      #      .attr({"x": width-160, "y": 0, "height": 101, "width": 160})
                      #      .classed("legend", true)
                      #      .call(fadeIn)
                      # chart.append("rect")
                      #      .classed("male-legend", true)
                      #      .attr({"x": width-140, "y": 20, "height": 16, "width": 16})
                      #      .call(fadeIn)
                      # chart.append("rect")
                      #      .attr({"x": width-140, "y": 46, "height": 16, "width": 16})
                      #      .classed("female-legend", true)
                      #      .call(fadeIn)
                      # chart.append("text")
                      #      .text("Male")
                      #      .classed("male-legend", true)
                      #      .attr({"x": width-120, "y": 32})
                      #      .call(fadeIn)
                      # chart.append("text")
                      #      .text("Female")
                      #      .classed("female-legend", true)
                      #      .attr({"x": width-120, "y": 58})
                      #      .call(fadeIn)
                      # chart.append("text")
                      #      .text("Player: ")
                      #      .classed("stat-legend", true)
                      #      .attr({"id": "player-legend", "x": width-340, "y": 12})
                      #      .call(fadeIn)
                      # chart.append("text")
                      #      .text("Goals : ")
                      #      .classed("stat-legend", true)
                      #      .attr({"id": "goals-legend", "x": width-140, "y": 12})
                      #      .call(fadeIn)
        # makeLegend()

        # grab data
        d3.json('data/goalscorers.json', (requestdata) ->
            scope.data = requestdata
            goalData = requestdata.map (d)-> [1..parseInt d.Goals]

            yMax = d3.max scope.data, (d) -> +(d.Goals)
            yMin = d3.min scope.data, (d) -> +(d.Goals)          
            yScale.domain [0, yMax + 30]
            xScale.domain scope.data.map (d) -> d.Player 
            
            yAxis.ticks(yScale.domain()[1])
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

        # Mouse over player-bar
            vidTipHTML = (d) ->
              """
              <div class='tip-container'>
                <div class='name'><h4>#{d.Player}<h4></div>
                <div class='youtube'>
                  <iframe width='280' height='158' src='http://www.youtube.com/embed/#{d.Vid}?rel=0&amp;vq=small&amp;modestbranding=1' frameborder='0'></iframe>
                </div>
              </div>
              """

            vidTip = d3.tip()
                    .attr("class", "d3-tip")
                    .html((d) -> vidTipHTML d )
                    .offset([10, 120])

            # showVidTip = ()

            playerGoals = chart.selectAll(".ranges")
                                .data(scope.data)
                                .enter().append("g")
                                .attr("id", (d, i) -> "group-#{i}")
                                .attr("class", (d) ->
                                    if d.Gender is "Male"
                                        "ranges Male"
                                    else
                                        "ranges Female"
                                        )
                                .call(vidTip)
                                .append("rect")
                                .attr("x", (d) -> 
                                  xScale(d.Player)) # adjust labels, not position of bars
                                .attr("y", (d) -> yScale(+d.Goals + barPadding)) # note that the yaxis is inverted! 0 = top
                                .attr("width", xScale.rangeBand())
                                .attr("height", 0)
                                .on("mouseover", (d, i) ->
                                  vidTip.show(scope.data[i])
                                  # goalNumber = Math.floor(yScale.invert(d3.event.y))
                                  # goalTick = d3.select("#goal-#{goalNumber}").style("display", "inline")
                                  )
                                .transition()
                                .duration(1800)
                                .ease("bounce")
                                .attr("height", (d) -> height - yScale(+d.Goals + barPadding)) # extra padding for top of goals
                                .style("fill", (d) ->
                                  # genderColors((d.Goals * rangeOfContrast) + manualDarkening)
                                  if d.Gender is "Female" then femaleColors((+d.Goals * 2.5) + 80)
                                  else if d.Gender is "Male" then maleColors((+d.Goals * 6) + 140 ))
                                
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

            # give ids to y axis ticks
            d3.selectAll("g.y.axis .tick")
              .attr("id", (d) -> "goal-#{d}")

            goalSprites = d3.selectAll("g.ranges")
                            .data(goalData)
                            .selectAll("circle")
                            .data((d)-> d)
                            .enter()
                            .append("circle")
                            .attr("r", "1.5")
                            .attr("cx", () ->
                                 rect = d3.select(@parentNode).select("rect")  
                                 padding = {left: 18, right: 18}
                                 # lets use rangeband instead
                                 max = +rect.attr("x") + xScale.rangeBand() - padding.right
                                 min = +rect.attr("x") + padding.left
                                 randomX = Math.random() * (max - min) + min 
                                 )
                             .attr("cy", (d) ->  yScale(d))
                             .classed("goal", true)
                             .style("opacity", 0)
                             .transition()
                             .delay((d,i)-> 
                                  1800 + i * ( i / 5 ) )
                             .style("opacity", 1)
                             .style("fill", () ->
                                goalColors[Math.floor(Math.random() * goalColors.length)]
                              )
        # Zoom
            zoom = d3.behavior
                     .zoom()
                     .scaleExtent [1,10]
                     .on("zoom", ->
                          chart.attr("transform", "translate(#{d3.event.translate}) scale(#{d3.event.scale})"))
            chart.call zoom

        # Flash y-axis ticks on goalSprite build.
            d3.selectAll(".y.axis .tick:nth-child(18) line, .y.axis .tick:nth-child(18) text")
              .attr("style", "opacity: 0.3; stroke-width:1px;")
              .transition()
              .delay(6000)
              .duration(2000)
              .attr("style", "opacity: 0.8; stroke-width: 2px;")
              .transition()
              .duration(4000)
              .attr("style", "opacity: 0.3; stroke-width: 1px;")

            return

            )
        scope.$on('$viewContentLoaded', () ->
          chart.call(legend)
          legend.show("data", chart.node())
          )
  )
