do ($ = jQuery)->
  ###
   Focusable jQuery Expression
  ###
  focusable = (element, isTabIndexNotNaN) ->
    map = undefined
    mapName = undefined
    img = undefined
    nodeName = element.nodeName.toLowerCase()
    if "area" is nodeName
      map = element.parentNode
      mapName = map.name
      return false  if not element.href or not mapName or map.nodeName.toLowerCase() isnt "map"
      img = $("img[usemap=#" + mapName + "]")[0]
      return !!img and visible(img)
    # the element and all of its ancestors must be visible
    ((if /input|select|textarea|button|object/.test(nodeName) then not element.disabled else (if "a" is nodeName then element.href or isTabIndexNotNaN else isTabIndexNotNaN))) and visible(element)
  ###
   Visible Jquery Expression - possible duplication of the existing jQuery lib
  ###
  visible = (element) ->
    $.expr.filters.visible(element) and not $(element).parents().addBack().filter(->
      $.css(this, "visibility") is "hidden"
    ).length
  ###
   Binding to the ':' Jquery Expression
  ###
  $.extend $.expr[":"],
    data: (if $.expr.createPseudo then $.expr.createPseudo((dataName) ->
      (elem) ->
        !!$.data(elem, dataName)
    ) else (elem, i, match) ->
      !!$.data(elem, match[3])
    )
    focusable: (element) ->
      focusable element, not isNaN($.attr(element, "tabindex"))

    tabbable: (element) ->
      tabIndex = $.attr(element, "tabindex")
      isTabIndexNaN = isNaN(tabIndex)
      (isTabIndexNaN or tabIndex >= 0) and focusable(element, not isTabIndexNaN)
  undefined

do ($ = jQuery)->
  # init
  $(document).on 'click keypress', '[aria-controls]', (event)->
    event.stopPropagation() #lets control the event to ensure we can trap it outside
    if event.type is 'keypress' and event.which != '13'
      return
    _elm = $(@)
    $("#" + _elm.attr('aria-controls') ).trigger
      type : 'aria-cntrl-focus'
      trigelm : _elm
    undefined

  $(document).on 'aria-cntrl-focus', '[aria-hidden]', (event)->
    event.stopPropagation() #lets control the event to ensure we can trap it outside
    _elm = $(@)
    _caller = event.trigelm
    _elm.data('trgr-element', _caller)
    switch _elm.attr('aria-hidden')
      when 'true'
        _elm.attr 'aria-hidden', 'false'
        _caller.attr 'aria-expanded', 'true'
      when 'false'
        _elm.attr 'aria-hidden', 'true'
        _caller.attr 'aria-expanded', 'false'
    setTimeout (->
        _elm.find(':tabbable').first().focus()
    ),1

    undefined

  # lets make sure we close this as well outside clicks
  $(document).on 'click', (event)->
    if $(event.target).parents('[aria-hidden=false]').length < 1
      $('[aria-hidden=false]').each ()->
        _elm = $(@)
        _elm.attr 'aria-hidden', 'true'
        _elm.data('trgr-element').attr 'aria-expanded', 'false'
    undefined
  undefined