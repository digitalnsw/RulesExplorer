# frozen_string_literal: true

RSpec.describe VariablesFetchService do

  # This is the name of a variable which is expected to exist on the OpenFisca
  # server the tests will connect to
  let(:an_openfisca_variable_name) { 'acc__is_receiving_compensation' }

  describe '.variables_list' do
    subject { described_class.variables_list }

    it 'fetches over 200 variable descriptions' do
      # The count at time of writing is about 220 but we just want to make sure
      # we find the correct magnitude of data in future
      expect(subject.count).to be > 200
    end
  end

  describe '.variable' do
    subject { described_class.variable(name: an_openfisca_variable_name) }

    it 'retrieves a variable with the expected attributes' do
      # I wouldn't normally bother with this kind of test but I understand OpenFisca is
      # under active development and the response could change unexpectedly
      expect(subject.keys).to match_array(
        %w[defaultValue definitionPeriod description entity id references source valueType]
      )
    end
  end

  describe '.fetch' do
    let(:variable) { Variable.new(name: an_openfisca_variable_name) }
    subject { described_class.fetch(variable) }

    it 'retrieves a variable with the expected attributes' do
      expect(subject.attributes.keys).to match_array(
        %w[id name href spec created_at updated_at namespace value_type_id entity_id unit description]
      )
      expect(subject.spec.keys).to match_array(
        %w[defaultValue definitionPeriod description entity id references source valueType]
      )
    end

    it 'loads the example variable into the database' do
      expect { subject }.to change { Variable.count }.by(1)
      expect(Variable.find_by(name: variable.name)).not_to be_nil
    end
  end
end
