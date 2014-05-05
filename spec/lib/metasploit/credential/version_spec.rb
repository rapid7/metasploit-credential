require 'spec_helper'

describe Metasploit::Credential::Version do
  context 'CONSTANTS' do
    context 'MAJOR' do
      subject(:major) do
        described_class::MAJOR
      end

      it 'is 0 because the API is not locked yet' do
        expect(major).to eq(0)
      end
    end

    context 'MINOR' do
      subject(:minor) do
        described_class::MINOR
      end

      it { should be_a Integer }
    end

    context 'PATCH' do
      subject(:patch) do
        described_class::PATCH
      end

      it { should be_a Integer }
    end

    pull_request = ENV['TRAVIS_PULL_REQUEST']

    # a pull request cannot check PRERELEASE because it will be tested in the target branch, but the source itself
    # is from the source branch and so has the source branch PRERELEASE.
    #
    # PRERELEASE can only be set appropriately for a merge by merging to the target branch and then updating PRERELEASE
    # on the target branch before committing and/or pushing to github and travis-ci.
    if pull_request.nil? || pull_request == 'false'
      context 'PREPRELEASE' do
        subject(:prerelease) do
          described_class::PRERELEASE
        end

        branch = ENV['TRAVIS_BRANCH']

        if branch.blank?
          branch = `git rev-parse --abbrev-ref HEAD`.strip
        end

        # can't check PRERELEASE in  detached HEAD state (when you do `git checkout SHA`) because then the commit isn't
        # isn't associated with a branch anymore.
        unless branch == 'HEAD'
          if branch == 'master'
            it 'does not have a PRERELEASE' do
              expect(defined? described_class::PRERELEASE).to be_nil
            end
          else
            branch_regex = /\A(bug|feature|staging)\/(?<prerelease>.*)\z/
            match = branch.match(branch_regex)

            if match
              it 'matches the branch relative name' do
                expect(prerelease).to eq(match[:prerelease])
              end
            else
              it 'has a abbreviated reference that can be parsed for prerelease' do
                fail "Do not know how to parse #{branch.inspect} for PRERELEASE"
              end
            end
          end
        end
      end
    end
  end

  context 'full' do
    subject(:full) do
      described_class.full
    end

    #
    # lets
    #

    let(:major) do
      1
    end

    let(:minor) do
      2
    end

    let(:patch) do
      3
    end

    before(:each) do
      stub_const("#{described_class}::MAJOR", major)
      stub_const("#{described_class}::MINOR", minor)
      stub_const("#{described_class}::PATCH", patch)
    end

    context 'with PRERELEASE' do
      let(:prerelease) do
        'prerelease'
      end

      before(:each) do
        stub_const("#{described_class}::PRERELEASE", prerelease)
      end

      it 'is <major>.<minor>.<patch>-<prerelease>' do
        expect(full).to eq("#{major}.#{minor}.#{patch}-#{prerelease}")
      end
    end

    context 'without PRERELEASE' do
      before(:each) do
        hide_const("#{described_class}::PRERELEASE")
      end

      it 'is <major>.<minor>.<patch>' do
        expect(full).to eq("#{major}.#{minor}.#{patch}")
      end
    end
  end
end