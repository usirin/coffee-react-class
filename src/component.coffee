React = require 'react'
assign = require 'lodash.assign'

module.exports = class Component extends React.Component

  constructor: (props, shouldAutoBind = yes) ->

    super props

    # Set initial state to merged object from '@_getInitialState()'
    @state = assign {}, @_getInitialState(), @state

    @autoBind()  if shouldAutoBind


  bind: (methods) ->

    methods.forEach (method) => this[method].bind this


  autoBind: ->

    methods = Object
      .getOwnPropertyNames @constructor.prototype
      .filter (prop) => 'function' is typeof this[prop]

    @bind methods


  _getInitialState: -> {}


isFunction = (x) -> 'function' is typeof x

