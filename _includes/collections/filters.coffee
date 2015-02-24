class Filters extends Backbone.Collection
  model: Filter

  addCountries: ->
    _.each window.countries, (country) =>
      @add
        name: country.name
        short: country.iso3.toLowerCase()
        type: 'country'
        forFilter: 'location'

  nameFromShort: (short) ->
    @get(short).get('name')

  search: (term) ->
    @filter (indice) ->
      re = new RegExp term, "i"
      indice.get('name').match re

  validFilters: (filterName, filterValue) ->
    return true unless filterName? and filterValue?
    
    filterName = 'country' if _.contains(['host_location'], filterName)

    new Backbone.Collection(
      @where type: filterName
    ).where(
      short: filterValue
    ).length > 0

