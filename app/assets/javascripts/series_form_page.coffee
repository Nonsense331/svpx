class SVPX.SeriesFormPage
  constructor: ->
    @initListeners()
    if $("#series_regex").val()
      @onRegexChange()

  initListeners: ->
    $('#series_regex').on 'keyup', @onRegexChange

  onRegexChange: ->
    $('.series').load("/series/videos_from_regex", regex: $('#series_regex').val())