class MapView extends Backbone.View

  initialize: ->
    @state = app.state

    @listenTo @collection, 'reset', @render

    # `preloadData` is bootstrapped into index.html
    @countries = new MapCountries(preloadData.countries) 

  render: ->
    @_createMap() unless @_mapObject?
    @_updateMapValues()
    # @_zoomToActiveRegions()

  setActive: ->
    @_createMap() unless @_mapObject?
    @_mapObject.updateSize()

  _createMap: =>
    @$el.vectorMap(@_mapSettings())
    @_mapObject = @$el.vectorMap('get', 'mapObject')
    @maxScale = @_mapObject.scale # TODO: Handle zoom and resizing better
    window.m = @ # TODO: @prod Remove debugging global

  _updateMapValues: ->
    values = @_prepareDataForMap()
    @_mapObject.series.regions[0].setValues(values)

  _clickRegion: (code) =>
    if @selectedRegionCode == code # TODO: Too unreliable as a check - need to refer to viewModel
      @_deselectRegion(code)
    else
      @_selectRegion(code)

  _selectRegion: (code) =>
    @_mapObject.clearSelectedRegions()
    @_mapObject.tip.hide()
    @_mapObject.setSelectedRegions(code)
    # @_mapObject.setFocus(regions: [code], animate: true) # TODO: Restore or remove map#setFocus
    @selectedRegionCode = code

    country = @countries.iso3FromMapShort(code)
    @state.addFilter(facetName: 'country', facetValue: country.toLowerCase()) if country?
    # @_mapObject.resize()

  _deselectRegion: (code) =>
    @selectedRegionCode = ''
    @_mapObject.clearSelectedRegions()
    @_resetZoom()

    country = @countries.iso3FromMapShort(code)
    @state.removeFilter(facetName: 'country', facetValue: country.toLowerCase()) if country?

  _resetZoom: ->
    @_mapObject.setFocus(
      scale: @maxScale
      x: 0
      y: 0
      animate: true
    )

  _prepareDataForMap: ->
    locationCounts = @collection.prepareFilterGroupForType('country')

    data = {}
    @countries.map( (country) ->
      iso3 = country.get('iso3').toLowerCase()
      map_short = country.get('map_short')

      hasValue = _.findWhere(locationCounts, value: iso3)
      activeCount = hasValue?.activeCount || 0
      
      data[map_short] = activeCount
    )
    data

  _mapSettings: ->
    values = @_prepareDataForMap()
    
    map: 'world_mill_en'
    backgroundColor: 'white'
    series:
      regions: [
        values: values
        scale: ['#B8B8B8', '#1057A7']
        normalizeFunction: 'polynomial'
        legend:
          horizontal: true,
          title: 'Projects per country',
          labelRender: (value) -> value
      ]
    regionsSelectableOne: true
    regionStyle:
      selected:
        fill: '#f7be00'
    onRegionClick: (ev, code) =>
      @_clickRegion(code)
    onRegionTipShow: (e, el, code) =>
      countryIso3 = @countries.iso3FromMapShort(code)
      activeCount = app.projects.projectCountForFacetValue('country', countryIso3)
      el.html("#{el.html()} (#{activeCount} projects)") if activeCount isnt 0

  _zoomToActiveRegions: ->
    activeRegions = _.map(@collection.getLocations(), (location) =>
      @countries.mapShortFromIso3(location)
    )

    @_mapObject.setFocus(regions: activeRegions, animate: true)


