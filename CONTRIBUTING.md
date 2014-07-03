# Contributing

## Forking

[Fork this repository](https://github.com/rapid7/metasploit-credential/fork)

## Branching

Branch names follow the format `TYPE/ISSUE/SUMMARY`.  You can create it with `git checkout -b TYPE/ISSUE/SUMMARY`.

### `TYPE`

`TYPE` can be `bug`, `chore`, or `feature`.

### `ISSUE`

`ISSUE` is either a [Github issue](https://github.com/rapid7/metasploit-credential/issues) or an issue from some other
issue tracking software.

### `SUMMARY`

`SUMMARY` is is short summary of the purpose of the branch composed of lower case words separated by '-' so that it is a valid `PRERELEASE` for the Gem version.

## Changes

### `PRERELEASE`

1. Update `PRERELEASE` to match the `SUMMARY` in the branch name.  If you branched from `master`, and [version.rb](lib/metasploit/credential/version.rb) does not have `PRERELEASE` defined, then adding the following lines after `PATCH`: 
```
# The prerelease version, scoped to the {PATCH} version number.
PRERELEASE = '<SUMMARY>'
```
2. `rake spec`
3.  Verify the specs pass, which indicates that `PRERELEASE` was updated correctly.
4. Commit the change `git commit -a`

### Your changes

Make your changes or however many commits you like, commiting each with `git commit`.

### Pre-Pull Request Testing

1. Run specs one last time before opening the Pull Request: `rake spec`
2. Verify there was no failures.

### Push

Push your branch to your fork on gitub: `git push push TYPE/ISSUE/SUMMARY`

### Pull Request

* [Create new Pull Request](https://github.com/rapid7/metasploit-credential/compare/)
* Add a Verification Steps comment

```
# Verification Steps

- [ ] `bundle install`

## `rake spec`
- [ ] `rake spec`
- [ ] VERIFY no failures
```
You should also include at least one scenario to manually check the changes outside of specs.

* Add a Post-merge Steps comment

The 'Post-merge Steps' are a reminder to the reviewer of the Pull Request of how to update the [`PRERELEASE`](lib/metasploit/credential/version.rb) so that [version_spec.rb](spec/lib/metasploit/credential/version_spec.rb) passes on the target branch after the merge.

DESTINATION is the name of the destination branch into which the merge is being made.  SOURCE_SUMMARY is the SUMMARY from TYPE/ISSUE/SUMMARY branch name for the SOURCE branch that is being made.

When merging to `master`:

```
# Post-merge Steps

Perform these steps prior to pushing to master or the build will be broke on master.

## Version
- [ ] Edit `lib/metasploit/credential/version.rb`
- [ ] Remove `PRERELEASE` and its comment as `PRERELEASE` is not defined on master.

## Gem build
- [ ] gem build *.gemspec
- [ ] VERIFY the gem has no '.pre' version suffix.

## RSpec
- [ ] `rake spec`
- [ ] VERIFY version examples pass without failures

## Commit & Push
- [ ] `git commit -a`
- [ ] `git push origin master`
```

When merging to DESTINATION other than `master`:

```
# Post-merge Steps

Perform these steps prior to pushing to DESTINATION or the build will be broke on DESTINATION.

## Version
- [ ] Edit `lib/metasploit/credential/version.rb`
- [ ] Change `PRERELEASE` from `SOURCE_SUMMARY` to `DESTINATION_SUMMARY` to match the branch (DESTINATION) summary (DESTINATION_SUMMARY)

## Gem build
- [ ] gem build *.gemspec
- [ ] VERIFY the prerelease suffix has change on the gem.

## RSpec
- [ ] `rake spec`
- [ ] VERIFY version examples pass without failures

## Commit & Push
- [ ] `git commit -a`
- [ ] `git push origin DESTINATION`
```

* Add a 'Release Steps' comment

The 'Release Steps' are a reminder to the reviewer of the Pull Request of how to release the gem.

```
# Release

Complete these steps on DESTINATION

## `VERSION`

### Compatible changes

If your change are compatible with the previous branch's API, then increment [`PATCH`](lib/metasploit/credential/version.rb).

### Incompatible changes

If your changes are incompatible with the previous branch's API, then increment [`MINOR`](lib/metasploit/credential/version.rb) and reset [`PATCH`](lib/metasploit/credential/version.rb) to `0`.

- [ ] Following the rules for [semantic versioning 2.0](http://semver.org/spec/v2.0.0.html), update [`MINOR`](lib/metasploit/credential/version.rb) and [`PATCH`](lib/metasploit/credential/version.rb) and commit the changes.

## Tagging

metasploit-credential is currently, private, so it is only tagged for internal use, instead of being released to
rubygems.

- [ ] `git tag --message 'Version MAJOR.MINOR.PATCH on the DESTINATION branch' 'vMAJOR.MINOR.PATCH-PRERELEASE'
- [ ] `git push`
- [ ] `git push --tags`
```

### Downstream dependencies

When releasing new versions, the following projects may need to be updated:

* [metasploit-framework](https://github.com/rapid7/metasploit-framework)
* [metasploit-pro-ui](https://github.com/rapid7/pro/tree/master/ui)
* [metasploit-pro-engine](https://github.com/rapid7/pro/tree/master/engine)
