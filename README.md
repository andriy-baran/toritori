# Toritori

[![Maintainability](https://api.codeclimate.com/v1/badges/4e5138d5018b81671692/maintainability)](https://codeclimate.com/github/andriy-baran/toritori/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/4e5138d5018b81671692/test_coverage)](https://codeclimate.com/github/andriy-baran/toritori/test_coverage)

Simple tool to work with Abstract Factories.
It provides the DSL for defining a set factories and produce objects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'toritori'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install toritori

## Usage

### Basics
Add the module to the class
```ruby
require 'toritori'

class MyAbstractFactory
  include Toritori
end
```
It will provide an ablility to declare and refer individual factories
```ruby
# Declaration
MyAbstractFactory.factory(:chair)
MyAbstractFactory.factory(:table)
# Access all factories
MyAbstractFactory.factories # => { chair: #<Toritori::Factory @name: :chair>, table: #<Toritori::Factory @name: :table> }
# Access individual factory
MyAbstractFactory.chair_factory # => #<Toritori::Factory @name: :chair>
MyAbstractFactory.table_factory # => #<Toritori::Factory @name: :table>
```
Creating objects is also easy
```ruby
MyAbstractFactory.table_factory.create(<attrs>) # => #<Class>
```
To provide a specific class for factory to create instances
```ruby
Sofa = Struct.new(:width)

class MyAbstractFactory
  include Toritori

  factory :sofa, produces: Sofa
end

MyAbstractFactory.sofa_factory # =>
MyAbstractFactory.sofa_factory.create(2300) # => #<Sofa @width=2300>
```
The library defaults is to use `new` method for instantiation and bypass parameters from `create` method. But if you need to customize this behaviour
```ruby
class MyAbstractFactory
  include Toritori

  factory :file, produces: File do |file_name|
    # Every method is called on File
    open(file_name, 'r')
  end
end

MyAbstractFactory.file_factory.create('/dev/null') # => #<File @path='/dev/null'>
```
### Subclassing
For example:
```ruby
class ModernFactory < MyAbstractFactory
  factories # => { chair: #<Toritori::Factory @name: :chair>,
            #      table: #<Toritori::Factory @name: :table>,
            #      sofa: #<Toritori::Factory @name: :sofa, @base_class=Sofa> }
end
```
If we need to add a wifi option to sofa
```ruby
class ModernFactory < MyAbstractFactory
  sofa_factory.subclass do
    def add_wifi
      @wifi = true
    end

    attr_reader :wifi
  end
end

modern_sofa = ModernFactory.sofa_factory.create(2500)
modern_sofa.wifi # => nil
modern_sofa.add_wifi
modern_sofa.wifi # => true
```
If we need to add wifi option to initializer
```ruby
class ModernFactory < MyAbstractFactory
  # Update initialize method
  chair_factory.subclass do
    def initialize(width, wifi)
      super(width)
      @wifi = wifi
    end

    attr_reader :wifi
  end

  # Notify factory about new way to create objects
  chair_factory.subclass.init do |width, wifi:|
    new(width, wifi)
  end
end

modern_chair = ModernFactory.chair_factory.create(2500, wifi: false)
modern_chair.wifi # => false
```
The subclass (`ModernFactory`) will gen a copy of `factories` so you can customize sublasses without side effects on a base class (`MyAbstractFactory`).

Sometimes when subclass definition is big it is better to put it into a separate file. To make the library to use that sub-class:
```ruby
class ModernTable < MyAbstractFactory.table_factory.base_class
  # ... omitied ...
end

class ModernFactory < MyAbstractFactory
  # Update initialize method
  table_factory.subclass.base_class ModernTable

  table_factory.create # => #<ModernTable>
end
```
The sub-class should be a child of a base class we specified in factory of the parent abstract factory, otherwise you'll get `Toritori::SubclassError`. We recommend to have base classes (`produces:` option) for parent abstract factory defined explicitly to have an ability to refer them in sub-class files.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/andriy-baran/toritori. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/andriy-baran/toritori/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Toritori project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/andriy-baran/toritori/blob/master/CODE_OF_CONDUCT.md).
