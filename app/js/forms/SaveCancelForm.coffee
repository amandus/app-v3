# Form that has save and cancel buttons that fire save and cancel events.
# Save event will only be fired if validates

module.exports = Backbone.View.extend
  initialize: ->
    @contents = @options.contents
    @render()

  events: 
    'click #save_button': 'save'
    'click #cancel_button': 'cancel'

  validate: ->
    # Get all visible items
    items = _.filter(@contents, (c) ->
      c.visible and c.validate
    )
    return not _.any(_.map(items, (item) ->
      item.validate()
    ))

  render: ->
    @$el.html '''<div id="contents"></div>
    <div>
        <button id="save_button" type="button" class="btn btn-primary margined">Save</button>
        &nbsp;
        <button id="cancel_button" type="button" class="btn margined">Cancel</button>
    </div>'''
    
    # Add contents (questions, mostly)
    _.each @contents, (c) => @$('#contents').append c.$el
    this

  save: ->
    if @validate()
      @trigger 'save'

  cancel: ->
    @trigger 'cancel'
