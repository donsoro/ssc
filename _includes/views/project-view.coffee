class ProjectView extends Backbone.View
  template: -> _.template($('#projectView').html())

  className: 'row'

  initialize: ->

  render: ->
    @presentedModel = new PresentProject(@model)
    compiled = @template()(project: @presentedModel.render())
    @$el.html(compiled)
    @