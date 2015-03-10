---
---
baseurl = "{{ site.baseurl }}"
app = window.app = {}

# Models and Collections
{% include models/filter.coffee %}
{% include models/map-country.coffee %}
{% include models/project.coffee %}
{% include models/present-project.coffee %}
{% include collections/filters.coffee %}
{% include collections/map-countries.coffee %}
{% include collections/projects.coffee %}
{% include collections/projects-facets.coffee %} # Mixin

# Controllers and ViewModels
{% include controllers/state-manager.coffee %}
{% include controllers/persist-state.coffee %} # Mixin

# Views
{% include views/project-view.coffee %}
{% include views/explorer-view.coffee %}
{% include views/search-view.coffee %}
{% include views/filter-view.coffee %}
{% include views/content-view.coffee %}
{% include views/map-view.coffee %}
{% include views/stats-view.coffee %}
{% include views/list-view.coffee %}
{% include views/controls-view.coffee %}
{% include views/headlines-view.coffee %}


# Controllers
{% include routers/router.coffee %} # Router

# Utilities
{% include utils/utils.coffee%}

$(document).ready ->
  # Collections
  app.projects = new Projects
  app.filters = new Filters
  app.filters.populate(
    indices: preloadData.indices
    countries: preloadData.countries # TODO: Avoid duplication with above
  )

  app.projects.fetch
    success: (collection) ->
      app.state = new StateManager(observedCollection: collection)
      app.router = new Router()
      Backbone.history.start()
