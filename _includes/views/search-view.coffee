class SearchView extends Backbone.View
  template: ->  _.template($('#searchView').html())

  initialize: ->
    @state = app.state
    @listenTo @state, 'search:start', @_activateSearch
    @listenTo @state, 'change:filterState', @_cancelSearch
    @listenTo @state, 'search:cancel', @_cancelSearch
    @render()

  events: 
    'click .view-mode': '_prepareForSearch'
    'click .input-mode > .search-action-icon': '_cancelSearch'
    'keyup .search-field-input': '_handleSearchInput'
    'keyup :input': '_checkForEscape'

  _checkForEscape: (ev) ->
    @_cancelSearch(ev) if ev.keyCode == 27

  render: ->
    compiled = @template()()
    @$el.html(compiled)
    @state.set('searchTerm', null) if @state.get('searchTerm')

  _prepareForSearch: (ev) =>
    ev.preventDefault()
    @_activateSearch()

  _cancelSearch: (ev) ->
    ev.preventDefault() if ev?.preventDefault?

    return unless @state.get('searchTerm')?
    @_resetSearchField()
    @_deactivateSearch()
    @state.trigger('search:stopped')

  _resetSearchField: =>
    input = @$el.find('.search-field-input')
    input.val('')

  _activateSearch: ->
    @$el.find('.view-mode').addClass('hidden')
    @$el.find('.input-mode').removeClass('hidden')
    @$el.find('.search-field-input').focus()

  _deactivateSearch: ->
    @$el.find('.input-mode').addClass('hidden')
    @$el.find('.view-mode').removeClass('hidden')

  _handleSearchInput: (ev) =>
    searchTerm = ev?.currentTarget.value
    @state.set('searchTerm', searchTerm)
    @_searchTerm(searchTerm)

  _searchTerm: (searchTerm) =>
    @_searchFilters(searchTerm)
    @_searchProjects(searchTerm)

  _searchProjects: (term) =>
    projectsFound = @collection.search(term)
    @state.trigger('search:foundProjects', projectsFound) 

  _searchFilters: (term) =>
    filterGroups = @collection.presentFilterGroups()

    _.each filterGroups, (group) => 
      group.values = @_filterValueObjects(group.values, term)
    @state.trigger('search:foundFilters', filterGroups)

  _filterValueObjects: (valueObjects, term) ->
    _.filter(valueObjects, (object) => @_valueObjectMatchesTerm(object, term))

  _valueObjectMatchesTerm: (valueObject, term) ->
      re = new RegExp(term, 'i')
      re.test valueObject.long
