class SearchView extends Backbone.View
  template: ->  _.template($('#searchView').html())

  initialize: ->
    @state = app.state

    @listenTo @state, 'filters:changed', @render # TODO: One of these is not needed
    @listenTo @state, 'search:stopped', @render # TODO: One of these is not needed
    @render()

  events: 
    'click .view-mode': '_prepareForSearch'
    'click .input-mode > .search-action-icon': '_cancelSearch'
    'keyup .search-field-input': '_searchForTerm'

  render: ->
    compiled = @template()()
    @$el.html(compiled)

  _prepareForSearch: (ev) =>
    ev.preventDefault()
    @_activateSearch()

  _cancelSearch: (ev) ->
    ev.preventDefault() if ev.preventDefault?
    @_resetSearchField()
    @_deactivateSearch()
    @collection.trigger('search:stopped')

  _resetSearchField: =>
    input = @$el.find('.search-field-input')
    input.val('')

  _activateSearch: ->
    @$el.find('.view-mode').hide()
    @$el.find('.input-mode').show()
    @$el.find('.search-field-input').focus()

  _deactivateSearch: ->
    @$el.find('.input-mode').hide()
    @$el.find('.view-mode').show()

  _searchForTerm: (ev) =>
    term = ev.currentTarget.value
    return unless term.length > 1
    @_searchFilters(term)
    @_searchProjects(term)

  _searchProjects: (term) =>
    projectsFound = @collection.search(term)
    if projectsFound?.length > 0
      # NOTE: The event below is called on @collection
      @state.trigger('search:foundProjects', projectsFound) 

  _searchFilters: (term) =>
    filterGroups = @collection.prepareFilterGroups()

    _.each filterGroups, (group) => 
      group.values = @_filterValueObjects(group.values, term)
    # NOTE: The event below is called on @collection
    @state.trigger('search:foundFilters', filterGroups)

  _filterValueObjects: (valueObjects, term) ->
    _.filter(valueObjects, (object) => @_valueObjectMatchesTerm(object, term))

  _valueObjectMatchesTerm: (valueObject, term) ->
      re = new RegExp(term, 'i')
      re.test valueObject.long

