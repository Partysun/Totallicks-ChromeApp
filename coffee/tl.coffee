"use strict"

init = ->
  window.searchstatus = false
  $("input:text:visible:first").focus()
  totallicks()
  #$("#search").val localStorage.tabname
  $('.logo').on "click", ->
    chrome.tabs.create({url: "http://totallicks.com"})
  $('#results').on "click", "li", ->
    path = $(this).find("a").attr('href')
    chrome.tabs.create({url: path})
  $('#features').on "click", "li", ->
    path = $(this).find("a").attr('href')
    chrome.tabs.create({url: path})

  $(document).on "mouseover", "#results li", ->
    window.indexLine = $(this).data("index")
    $("#results li:nth-child(#{window.indexLine})").addClass "over"
  $(document).on "mouseout", "#results li", ->
    $("#results li:nth-child(#{window.indexLine})").removeClass "over"
    
  input = $("input[type=text]")
  Mousetrap.bind "enter", ->
    if window.indexLine >= 1
       path = $('.over').find("a").attr('href')
       chrome.tabs.create({url: path})
    else
      if $('#search').val().length > 1 && window.searchstatus == false
        search()
  Mousetrap.bind "down", (e) ->
    if window.indexLine == 1
      $("#results li:nth-child(#{window.indexLine})").removeClass "over"
    if window.indexLine >= 1 && window.indexLine <= $('#results li').length - 1
      $("#results li:nth-child(#{window.indexLine})").removeClass "over"
      ++window.indexLine
      $("#results li:nth-child(#{window.indexLine})").addClass "over"
    if e.target is input[0]
      input.blur()
      window.indexLine = 1
      $("#results li:nth-child(#{window.indexLine})").addClass "over"
  Mousetrap.bind "up", ->
    if window.indexLine >= 1
      $("#results li:nth-child(#{window.indexLine})").removeClass "over"
      --window.indexLine
      $("#results li:nth-child(#{window.indexLine})").addClass "over"
    if window.indexLine == 0
      input.focus()
  $(document).on "click", "#dismiss", ->
    $('.help').remove()
    localStorage.help = false

search = (tabname = $("#search").val()) ->
  window.searchstatus = true
  $('#features').hide()
  # Added Spinner
  opts =
  lines: 9 # The number of lines to draw
  length: 18 # The length of each line
  width: 11 # The line thickness
  radius: 23 # The radius of the inner circle
  corners: 1 # Corner roundness (0..1)
  rotate: 0 # The rotation offset
  direction: 1 # 1: clockwise, -1: counterclockwise
  color: "#000" # #rgb or #rrggbb
  speed: 1 # Rounds per second
  trail: 58 # Afterglow percentage
  shadow: false # Whether to render a shadow
  hwaccel: false # Whether to use hardware acceleration
  className: "spinner" # The CSS class to assign to the spinner
  zIndex: 2e9 # The z-index (defaults to 2000000000)
  top: "auto" # Top position relative to parent in px
  left: "auto" # Left position relative to parent in px

  spinerTarget = $('#spinner')
  results = $('#results li')
  $('#results').empty()
  $('.help').remove()
  if results.length > 0
    results.remove()
  if tabname == ""
    $('#results').append "<div class='message warning'>Ups. Write something please.</div>"
    $("input[type=text]").focus()
    window.searchstatus = false
  else
    spinner = new Spinner(opts).spin()
    spinerTarget.append spinner.el
    $.ajax
      url: "http://totallicks.com/search/"
      type: "GET"
      dataType: "json"
      data:
        tab: tabname

      success: (data) ->
        spinner.stop()
        if data["success"] && data["feed"].length > 0
          count = 1
          for item in data["feed"]
            makeItem item, count
            ++count
          $('#results li:first-child').addClass "over"
          $("input[type=text]").blur()
          window.indexLine = 1
          help = localStorage.getItem 'help'
          if help == "true"
            $("<div class='help'>Use <span class='kbd'>↑</span> and <span class='kbd'>↓</span> to navigate, <span class='kbd'>enter</span> to view tabs <a href='#' id='dismiss' class='dismiss' title='Hide this notice forever' rel='nofollow'>&#10006;</a></div> ").insertBefore('#results')
        else
          $('#results').append "<div class='message warning'>No Results.</div>"
          window.indexLine = 0
          #$("input[type=text]").focus()
        window.searchstatus = false

totallicks = ->
  #source: ["ozzy_osbourne_crazy_train.gp4", "ozzy_osbourne_crazy_train", "Ozzy Osbourne - Crazy Train","Ozzy Osbourne - Crazy Train","Ozzy Osbourne - Crazy Train"]
  input = $("input[type=text]")
  handler = (e) ->
    if e.keyCode is 38 or e.keyCode is 40
      #pos = @selectionStart
      #@value = ((if e.keyCode is 38 then 1 else -1)) + parseInt(@value, 10)
      #@selectionStart = pos
      #@selectionEnd = pos
      #ignoreKey = true
      #setTimeout (->
        #ignoreKey = false
      #), 1
      e.preventDefault()

  input.keydown handler
  input.keypress handler
  input.keypress (e) ->
    #setInterval(->
      #search()
    #, 300)
  $("input[type=submit]").click ->
    search()

makeItem = (item, count) ->
  if item['artist'] != null && item['artist'] != ""
    $('#results').append "<li class='item' data-index='#{count}'> <a href='" + item['path'] + "'>&#9658; " + item['artist'] + " - " + item['name'] + "</a></li>"
  else
    $('#results').append "<li class='item' data-index='#{count}'> <a href='" + item['path'] + "'>&#9658; " + item['name'] + "</a></li>"

#onTabName = (request, sender, sendResponse) ->
  #localStorage.tabname = request.tabname
  #console.log request.tabname
  #$("#search").val localStorage.tabname
  #chrome.tabs.onUpdated.removeListener onTabName

#chrome.extension.onRequest.addListener onTabName

#searchTabOnTab = ->
  #chrome.tabs.getSelected null, (tab) ->
    #tabId = tab.id
    #tabUrl = tab.url
    #if tab.url.match(/songsterr/)
      #chrome.tabs.executeScript tabId,
        #code: "
        #var tabname = document.title;
        #chrome.extension.sendRequest({
           #'tabname': tabname,
        #});
        #"

$(document).ready ->
  help = localStorage.getItem 'help'
  if !help
    localStorage.help = true
  window.indexLine = 0
  setTimeout (->
    $("input[type=text]").focus()
  ), 500
  init()
