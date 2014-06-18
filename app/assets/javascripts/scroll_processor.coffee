class SVPX.ScrollProcessor
  @process: ->
    @restore()
    $(window).on 'scroll', => @onscroll()

  @onscroll: (event) ->
    localStorage.setItem @key, $(window).scrollTop()

  @restore: ->
    $(window).scrollTop localStorage.getItem(@key)

  @key: "scroll#{location.pathname}"