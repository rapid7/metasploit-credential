# Metasploit::Credential

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
