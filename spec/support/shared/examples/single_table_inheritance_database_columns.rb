shared_examples_for 'single table inheritance database columns' do
  it { should have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { should have_db_column(:type).of_type(:string).with_options(null: false) }
end