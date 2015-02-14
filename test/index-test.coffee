jest.autoMockOff()

React = require 'react/addons'
Component = require '../src/component'
mixins = require '../src/mixins.coffee'

{ TestUtils } = React.addons
describe 'Component', ->

  it 'should work', ->

    class FooComponent extends Component
      render: ->
        <label className='foo'>{@props.value}</label>

    foo = TestUtils.renderIntoDocument \
      <FooComponent value='bar' />

    expect(React.findDOMNode(foo).textContent).toEqual 'bar'


describe 'mixins', ->
  it 'adds mixin functionality', ->

    test = {}
    class FooComponent extends Component
      componentDidMount: -> test['component'] = yes
      render: -> <label />

    fooMixin =
      componentDidMount: -> test['fooMixin'] = yes

    mixins FooComponent, [fooMixin]

    obj = {}
    foo = TestUtils.renderIntoDocument \
      <FooComponent value='bar' test={obj} />

    console.log {test}

    expect(test['component']).toBe yes
    expect(test['fooMixin']).toBe yes


