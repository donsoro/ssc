app.utils = {}

# Create probably unique IDs
app.utils.PUID = ->
  @s4() + @s4() + @s4()

app.utils.validPUID = (uuid) ->
  regex = /.{12}/
  regex.test uuid

app.utils.s4 = ->
  Math.floor((1 + Math.random()) * 0x10000) .toString(16) .substring(1)

app.utils.getUrlParams = ->
  return null unless window.location.href.match(/\?/) # Can't get params if there aren't any
  window.location.href.slice(window.location.href.indexOf('?') + 1).split('&')

app.utils.getUrlParamsHash = ->
  hashes = app.utils.getUrlParams()
  _.object(
    _.map(hashes, (rawHash) ->
      hash = rawHash.split('=')
      [hash[0], hash[1]]
    ) 
  )

app.utils.generateEditingUrl = (id) ->
  "#{app.config.editor.url}/##{app.config.repo}/edit/gh-pages/_ssc_projects/#{id}.txt"  

app.utils.newProjectId = ->
  "xxx" + Math.floor(Math.random()*4294967295).toString(16)

