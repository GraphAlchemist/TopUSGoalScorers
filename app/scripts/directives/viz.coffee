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
        bounceDelay = 1200

        goalColors = { "Male": ["#FFF", "#008"], "Female": ["#FFF", "#700"] }
        
        margin = {top: 20, left: 20, bottom: 20, right: 20}
        scaleFactor = 0.8
        height = angular.element(document).height() * scaleFactor - margin.top - margin.bottom
        width = angular.element(document).width() * scaleFactor- margin.left - margin.right

        chart = d3.select(element[0]).append('svg')
                                         .attr("id", "chart-container")
                                         .attr("height", height + margin.top + margin.bottom)
                                         .attr("width", width + margin.right + margin.left)
                                         .append('g')
                                         .attr("id", "chart")

        
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

        scrubBar = chart.append("line")
                        .attr("id", "scrubBar")
                        .attr({"x1": 0, "y1": -1, "x2": width, "y2": -1})
        
        xAxisNum = chart.append("text")
                        .attr("id", "xAxisNum")
                        .attr({"x": width, "y": -1})

        chart.on("mousemove", ()->
          y = d3.mouse(this)[1]
          
          d3.select("#scrubBar").attr({"y1": y,"y2": y})
          d3.select("#xAxisNum").attr({"y": y}).text(y)
          )         

        colorLegendHTML =
            """
              <div id="color-legend" class="legend">
                <div id='male-legend'>
                  <div id='male-box'></div>
                  <h5 id='male-text'>Men's Team Players</h5>
                </div>
                <div id='female-legend'>
                  <div id='female-box'></div>
                  <h5 id='female-text'>Women's Team Players</h5>
                </div>
              </div>
            """
        
        colorLegend = d3.tip()
                  .attr("class", "d3-tip")
                  .html(colorLegendHTML)
                  .direction('sw')
                  .offset([margin.top, width - margin.right])

        playerLegendHTML = (d) ->
            """
              <div id="player-legend" class="legend">
                  <h2>Hover over a player to view stats.</h2>
              </div>
            """

        playerLegend = d3.tip()
                  .attr("class", "d3-tip")
                  .html(playerLegendHTML)
                  .direction('sw')
                  .offset([margin.top, (width - margin.right)/1.5])

        # grab data
        d3.json('data/goalscorers.json', (requestdata) ->
            scope.data = requestdata
            goalData = requestdata.map (d)-> [1..parseInt d.Goals]

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
                                .attr("id", (d, i) -> "group-#{i}")
                                .attr("class", (d) ->
                                    if d.Gender is "Male"
                                        "ranges Male"
                                    else
                                        "ranges Female"
                                        )
                                .append("rect")
                                .attr("x", (d) -> 
                                  xScale(d.Player)) # adjust labels, not position of bars
                                .attr("y", (d) -> yScale(+d.Goals + barPadding)) # note that the yaxis is inverted! 0 = top
                                .attr("width", xScale.rangeBand())
                                .attr("height", 0)
                                .on("mouseover", (d, i) ->
                                  playerData  = scope.data[i]
                                  playerHTML = """
                                                <h3>#{playerData.Player} scored #{playerData.Goals} goals in #{playerData.caps} games.</h3>
                                                <div class='youtube'>
                                                  <iframe width='280' height='158' src='http://www.youtube.com/embed/#{playerData.Vid}?rel=0&amp;vq=small&amp;modestbranding=1' frameborder='0'></iframe>
                                                </div>
                                               """
                                  d3.select("#player-legend").html(playerHTML)
                                  )
                                .transition()
                                .duration(bounceDelay)
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
                            .attr("r", "2.3")
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
                                  bounceDelay + i * ( i / 10 ) )
                             .style("opacity", 1)
                             .style("fill", (d) ->
                                gender = if d3.select(this.parentNode).classed("Male") then "Male" else "Female"
                                colors = goalColors[gender]
                                colors[Math.floor(Math.random() * 2)]
                              )
        # Zoom
            zoom = d3.behavior
                     .zoom()
                     .scaleExtent [1,10]
                     .on("zoom", ->
                          chart.attr("transform", "translate(#{d3.event.translate}) scale(#{d3.event.scale})")
                          return)
            d3.select("#chart-container").call(zoom)

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

            d3.select("#male-legend")
              .on("mouseenter", ->
                  d3.selectAll("g.ranges.Male rect")
                    .classed("legend-hover", true))
              .on("mouseleave", ->
                  d3.selectAll("g.ranges.Male rect")
                    .classed("legend-hover", false))

            d3.select("#female-legend")
              .on("mouseenter", ->
                  d3.selectAll("g.ranges.Female rect")
                    .classed("legend-hover", true))
              .on("mouseleave", ->
                  d3.selectAll("g.ranges.Female rect")
                    .classed("legend-hover", false))
            return

            )
        scope.$on('$viewContentLoaded', () ->
          chart.call(colorLegend)
          chart.call(playerLegend)
          colorLegend.show("data", chart.node())
          playerLegend.show("data", chart.node())
          )
  )
