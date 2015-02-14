# Coffeescript React Class [![npm version](https://badge.fury.io/js/coffee-react-class.svg)](http://badge.fury.io/js/react-class-helper)

> React component as a coffee-script class (autobind, mixins, ...)

## Installation

`npm install coffee-react-class`

To see how to use Coffeescript class with React, please check this [post](http://facebook.github.io/react/blog/2015/01/27/react-v0.13.0-beta-1.html#es6-classes)


## Usage
This package provides two elements: `Component` and `mixins`. They can be used together or separately.


### Component

`Component` extends React's Component built-in class to provide [auto-binding](http://facebook.github.io/react/blog/2015/01/27/react-v0.13.0-beta-1.html#autobinding).

> React.createClass has a built-in magic feature that bound all methods to this automatically for you. This can be a little confusing for JavaScript developers that are not used to this feature in other classes, or it can be confusing when they move from React to other classes.

> Therefore we decided not to have this built-in into React's class model. You can still explicitly prebind methods in your constructor if you want.

<br>
So it means that currently you have to do this:

```coffee
React = require 'react'

class ButtonComponent extends React.Component

  constructor: (props) ->
    super props

    # comes from fat arrow.
    # @onClick = @onClick.bind this

  # notice the fat arrow here.
  # render shouldn't have fat arrow etc.
  # it's just confusing.
  onClick: => @setState clicked: yes

  render: -> <button onClick={@onClick}>My button</button>

```

<br>
With your component extending `Component` class, you can do this:

```coffee
# Note, I left React module because the JSX tags are transformed
# to `React.createElement` so we still need to import this module
React = require 'react'
{ Component } = require 'coffee-react-class'

# Extending `Component` instead of `React.Component`
class MyButton extends Component {
  constructor: (props) ->
    super props
    # Use `super(props, false);` to not autobind
    # Or `this.bind(['onClick']);` to bind only some methods

  # no fat arrow, or explicit binding.
  # Automatically bind to class instance
  onClick: -> @setState clicked: yes

  render: -> <button onClick={this.onClick}>My button</button>
}
```


### Mixins
`Mixins` provides **compatibility** with `React.createClass` mixins. Original idea from [react-mixin](https://github.com/brigand/react-mixin).

> Unfortunately, we will not launch any mixin support for ES6 classes in React. That would defeat the purpose of only using idiomatic JavaScript concepts.

> There is no standard and universal way to define mixins in JavaScript. In fact, several features to support mixins were dropped from ES6 today. There are a lot of libraries with different semantics. We think that there should be one way of defining mixins that you can use for any JavaScript class. React just making another doesn't help that effort.

But if you still want to use mixins with Coffeescript classes. See below how.

<br/>
`mixins(componentClass, mixins = [], options = {})`

- `componentClass`  Component factory (not class instance).
- `mixins`          Array of mixin objects.
- `options`
  - `defaultRule`   Default rule to apply to property not defined in `rules`  
  - `rules`         Map mixin properties to rules

```coffee
{
  rules: {
    # Lifecycle methods
    componentWillMount:        Mixins.MANY,
    componentDidMount:         Mixins.MANY,
    componentWillReceiveProps: Mixins.MANY,
    shouldComponentUpdate:     Mixins.ONCE,
    componentWillUpdate:       Mixins.MANY,
    componentDidUpdate:        Mixins.MANY,
    componentWillUnmount:      Mixins.MANY,

    # Compatibility hack
    getDefaultProps:           Mixins.MANY_MERGED,
    getInitialState:           Mixins.MANY_MERGED
  },
  defaultRule:                 Mixins.ONCE
}

```
<br/>
Built-in rules
- `Mixins.ONCE` Property can be defined only once in component or mixin
- `Mixins.MUlTI` Property can be defined multiple times in component or mixin, execution order is from left to right in mixins array and then component.
- `Mixins.MULTI_MERGED` Property can be defined multiple times in component or mixin, execution order is from left to right in mixins array and then component. Merge all results into one. Must returns objects or null.


<br/>
Example:

```coffee
React = require 'react'
{ Component, mixins } = require 'coffee-react-class'

// Define component
class MyButton extends Component

  constructor: (props) ->
    super props
    # `Component` class set `@state` from `_getInitialState()` automatically
    # If you use the built-in `React.Component` you have to call it explicitly
    # @state = _.assign({}, @_getInitialState());
  }

  # If you use the built-in `React.Component` you must declare
  # this method explicitly
  #
  # _getInitialState() {
  #   return {};
  # }

  onClick: -> @setState clicked: yes

  componentDidMount: -> console.log 'called `componentDidMount` from MyButton'

  render: -> <button onClick={this.onClick}>My button</button>

# Define some mixins
myMixin1 =
  componentDidMount: -> console.log 'called `componentDidMount` from Mixin1'

myMixin1 =
  componentDidMount: -> console.log 'called `componentDidMount` from Mixin2'

  # Objects are ignored except 'statics' and 'propTypes'
  # Ignore
  someObject: {} 

  # Merge into `MyButton.propTypes`
  propTypes:
    myProp: React.PropTypes.string

  # Merge into `MyButton`
  statics: 
    queries: {}

  # Merge into `MyButton.defaultProps`
  getDefaultProps: -> { myProp: 'myProp' }

  # Rename to `_getInitialState` to avoid React's warning
  # Call in component constructor and merge result
  getInitialState: -> { myState: 'myState'}

  # Throw error if defined in other mixin
  shouldComponentUpdate: -> yes

# Set mixins to component
mixins(MyButton, [myMixins1, myMixin2]);
```
