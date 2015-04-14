class StatsView extends Backbone.View
  template: -> _.template($('#statsView').html())

  initialize: ->
    @listenTo @collection, 'reset', @render
    _.template.partial.declare('stackedBarView', $('#partial-stackedBarView').html())

  render: ->
    compiled = @template()(
      collection: @collection
      stats: @_calculateStats()
    )
    @$el.html(compiled)
    @$el.find('.tooltip').tooltipster(theme: 'tooltipster-light')
    @

  _calculateStats: ->
    themeArray: @_createArrayFor('thematic_focus')
    roleArray: @_createArrayFor('undp_role_type')

  _createArrayFor: (type) ->
    output = [{name: null, value: 0},{name: null, value: 0},{name: null, value: 0}]
    raw = app.projects.prepareFilterGroupForType(type)
    total = _.inject(raw, (memo, value) -> 
      memo + value.activeCount
    , 0)
    array = _.map(raw, (i) ->
      name: i.value
      value: (i.activeCount / total) * 100
    )
    _.each(array, (e, i) ->
      output[i] = e
    )
    output
