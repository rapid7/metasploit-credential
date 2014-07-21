# Metasploit::Credential [![Build Status](https://travis-ci.org/rapid7/metasploit-credential.png)](https://travis-ci.org/rapid7/metasploit-credential)[![Code Climate](https://codeclimate.com/github/rapid7/metasploit-credential.png)](https://codeclimate.com/github/rapid7/metasploit-credential)[![Code Climate](https://codeclimate.com/github/rapid7/metasploit_data_models.png)](https://codeclimate.com/github/rapid7/metasploit_data_models)[![Dependency Status](https://gemnasium.com/rapid7/metasploit-credential.svg)](https://gemnasium.com/rapid7/metasploit-credential)[![Gem Version](https://badge.fury.io/rb/metasploit-credential.svg)](http://badge.fury.io/rb/metasploit-credential)

## Versioning

`Metasploit::Credential` is versioned using [semantic versioning 2.0](http://semver.org/spec/v2.0.0.html).  Each branch
should set `Metasploit::Credential::Version::PRERELEASE` to the branch name, while master should have no `PRERELEASE`
and the `PRERELEASE` section of `Metasploit::Credential::VERSION` does not exist.

## Documentation

`Metasploit::Credential` is documented using YARD.  For each `ActiveRecord::Base` descendant, it uses `RailsERD` to
generate an Entity-Relationship Diagram of all classes to which the descendant has a `belongs_to` relationship either
directly or indirectly.  In order to generate the diagrams as PNGs, graphviz is used, which may have issues when
use on OSX Mavericks.  If you get 'CoreTest performance note' messages when running 'rake yard', you should reinstall
graphviz as follows: `brew reinstall graphviz --with-bindings --with-freetype --with-librsvg --with-pangocairo`.

# Installation

Add this line to your application's `Gemfile`:

    gem 'metasploit-credential'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install metasploit-credential

## `Net::SSH`

`Metasploit::Credential::SSHKey` depends on `'net/ssh'`, but `metasploit-credential` does not declare the `net-ssh` gem
as a runtime dependency because [`metasploit-framework`](https://github.com/rapid7/metasploit-framework) includes
[its own version of `'net/ssh'`](https://github.com/rapid7/metasploit-framework/blob/master/lib/net/ssh.rb) which would
conflict with the gem.

If you're not using `metasploit-framework`, then you need add the `net-ssh` to your `Gemfile`:

    gem 'net-ssh'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install net-ssh

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
