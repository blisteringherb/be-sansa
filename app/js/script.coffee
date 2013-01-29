$ ->
  _.templateSettings = interpolate :/\{\{(.+?)\}\}/g

  (($) ->
    $.fn.serializeFormJSON = ->
      o = {}
      a = @serializeArray()
      $.each a, ->
        if o[@name]
          o[@name] = [o[@name]]  unless o[@name].push
          o[@name].push @value or ""
        else
          o[@name] = @value or ""

      o
  ) jQuery

  post = (form) ->
    $.ajax
      url: "/deploy"
      type: "POST"
      data: form
      dataType: "json"
      success: (data) ->
        $('.flash').html("<h3>The branch #{form.branch} has been deployed to #{form.environment}</h3>").removeClass("error instruction").addClass("info")
      error: (err) ->
        $('.flash').html("<h3>There was an error processing the request.</h3>").removeClass("info instruction").addClass("error")
    return

  $('input[type=submit]').click (e) ->
    form = $('form').serializeFormJSON()
    post(form)
    false

  $('select[name="project"]').change ->
    $('.flash').hide()
    getBranches($(@).val())

  getBranches = (project) ->
    $.ajax
      url: "/branches/" + project
      type: "GET"
      dataType: "json"
      success: (branches) ->
        $('.flash').removeClass("error info").addClass("instruction").html("<h3>Please select a branch</h3>").fadeIn 'slow'
        #template = $('#branch select').html()
        htmlstr = (_.template( '<option value="{{name}}">{{name}}</option>', b) for b in branches)
        $('#branch select').html htmlstr
        $('#branch, #environment, input[type=submit]').show()
      error: (err) ->
        $('.flash').html("<h3>There was an error processing the request.</h3>").addClass("error")
    return
