shared_context 'Mdm::Workspace' do
  before(:each) do
    # TODO remove Rex usage from Mdm as it is not a declared dependency
    Mdm::Workspace.any_instance.stub(:valid_ip_or_range?).and_return(true)
  end
end