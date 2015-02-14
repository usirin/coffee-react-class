invariant = require 'react/lib/invariant'
assign = require 'lodash.assign'

###*
 * Takes a component and mixes the given mixins.
 *
 * @param {Component} factory
 * @param {Array.<Object>} mixins
 * @param {Object=} options
 * @param {function=} options.defaultRule - default mixin rule
###
module.exports = mixins = (factory, mixins = [], options = {}) ->

  rules       = assign getDefaultRules(), options.rules
  defaultRule = options.defaultRule or mixins.ONCE

  mixins.reverse().forEach (mixin, index) ->
    Object.keys(mixin).forEach (propName) ->
      # Compatibility hack.
      # React doesn't like `getInitialState` anymore.
      # But let's keep supporting old mixins for now.
      propName = '_getInitialState'  if propName is 'getInitialState'

      rule          = rules[propName] or defaultRule
      prototypeProp = factory::[propName]
      mixinProp     = mixin[propName]

      switch propName
        when 'getDefaultProps'
          factory.defaultProps or= {}
          assign factory.defaultProps, (apply this, mixinProp)

        when 'propTypes'
          factory.propTypes or= {}
          assign factory.propTypes, mixinProp

        when 'statics'
          assign factory, mixinProp

        else
          if isFunction mixinProp
            factory::[propName] = rule prototypeProp, mixinProp, propName


###*
 * Get default rules for React class properties.
 *
 * @return {Object} rules
###
getDefaultRules = ->
  # Lifecycle methods
  componentWillMount        : mixins.MANY
  componentDidMount         : mixins.MANY
  componentWillReceiveProps : mixins.MANY
  shouldComponentUpdate     : mixins.ONCE
  componentWillUpdate       : mixins.MANY
  componentDidUpdate        : mixins.MANY
  componentWillUnmount      : mixins.MANY
  # Compatibility hack
  getDefaultProps           : mixins.MANY_MERGED
  getInitialState           : mixins.MANY_MERGED


###*
 * Type of mixin that can be defined only once.
 *
 * @param {Function} prototypeProp
 * @param {Function} mixinProp
 * @param {string} propName
###
mixins.ONCE = (prototypeProp, mixinProp, propName) ->

  invariant \
    (isDefinedOnce prototypeProp, mixinProp),
      """
      You are attempting to define `#{propName}` on your component more than once.
      This conflict may be due to a mixin.
      """

  return (args...) -> apply this, prototypeProp or mixinProp, args...


###*
 * Type of mixin that can be defined multiple times.
 *
 * @param {Function} prototypeProp
 * @param {Function} mixinProp
 * @param {string} propName
###
mixins.MANY = (prototypeProp, mixinProp, propName) ->
  return (args...) ->
    apply this, mixinProp, args...
    apply this, prototypeProp, args...


###*
 * Type of mixin that can be defined multiple times, and merges results.
 *
 * @param {Function} prototypeProp
 * @param {Function} mixinProp
 * @param {string} propName
###
mixins.MANY_MERGED = (prototypeProp, mixinProp, propName) ->

  return (args...) ->
    mixinResult     = (apply this, mixinProp, args...) or {}
    prototypeResult = (apply this, prototypeProp, args...) or {}

    invariant \
      ((isObject prototypeResult) and (isObject mixinResult)),
        "`#{propName}` must return an object or null."

    return assign {}, mixinResult, prototypeResult

###*
 * Helpers
###

getType       = (arg) -> Object.prototype.toString.call arg
isNull        = (arg) -> '[object Null]'      is getType arg
isUndefined   = (arg) -> '[object Undefined]' is getType arg
isObject      = (arg) -> '[object Object]'    is getType arg
isFunction    = (arg) -> '[object Function]'  is getType arg
isDefined     = (arg) -> not isUndefined(arg) and not isNull(arg)
isDefinedOnce = (args...) -> args.filter(isDefined).length is 1
apply         = (context, fn, args = []) -> isFunction(fn) and fn.apply self, args...

