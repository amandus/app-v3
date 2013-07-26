Page = require("../Page")
DiarrCasePage = require("./DiarrCasePage")
DiarrCaseListPage = require("./DiarrCaseListPage")
# NewTestPage = require("./NewTestPage")
# NewSourcePage = require("./NewSourcePage")

class MainPage extends Page
  events: 
    'click #new_diarr_case' : 'addDiarrCase'
    'click #recent_diarr_cases' : 'recentDiarrCases'
  activate: ->
    @setTitle "Broadstreet"

    # Rerender on error/success of sync
    if @sync?
      @listenTo @sync, "success error", =>
        @render()

    @render()

  deactivate: ->
    # Stop listening to events
    if @sync?
      @stopListening @sync

  render: ->
    data = {}
    data.login = @login
    data.version = @version
    data.lastSyncDate = @sync.lastSuccessDate() if @sync?
    data.lastSyncMessage = @sync.lastSuccessMessage() if @sync?

    @$el.html templates['pages/MainPage'](data)
    
    # menu = []
    # if NewSourcePage.canOpen(@ctx)
    #   menu.push({ text: "Add Water Source", click: => @addSource() })
    # if NewTestPage.canOpen(@ctx)
    #   menu.push({ text: "Start Water Test", click: => @addTest() })
    # if NewSurveyPage.canOpen(@ctx)
    #   menu.push({ text: "Start Survey", click: => @addSurvey() })
    # if menu.length > 0
    #   @setupButtonBar [{ icon: "plus.png", menu: menu }]

  addDiarrCase: ->
    @pager.openPage(DiarrCasePage)
  
  recentDiarrCases: ->
    @pager.openPage(DiarrCaseListPage)

  addSurvey: ->
    @pager.openPage(NewSurveyPage)

  addTest: ->
    @pager.openPage(NewTestPage)

  addSource: ->
    @pager.openPage(NewSourcePage)

module.exports = MainPage