require 'spec_helper'

describe Metasploit::Credential::Version do
  branch = `git rev-parse --abbrev-ref HEAD`

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

    context 'PREPRELEASE' do
      subject(:prerelease) do
        described_class::PRERELEASE
      end

      if branch == 'master'
        it 'does not have a PRERELEASE' do
          expect(defined? described_class::PRERELEASE).to be_nil
        end
      else
        feature_regex = /(feature|staging)\/(?<prerelease>.*)/
        match = branch.match(feature_regex)

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