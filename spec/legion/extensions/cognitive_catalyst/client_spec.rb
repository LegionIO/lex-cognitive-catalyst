# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveCatalyst::Client do
  subject(:client) { described_class.new }

  it 'includes Runners::CognitiveCatalyst' do
    expect(client).to respond_to(:create_catalyst)
    expect(client).to respond_to(:create_reaction)
    expect(client).to respond_to(:apply_catalyst)
    expect(client).to respond_to(:attempt_reaction)
    expect(client).to respond_to(:recharge)
    expect(client).to respond_to(:list_catalysts)
    expect(client).to respond_to(:catalyst_status)
  end

  it 'can create and then apply a catalyst to a reaction' do
    engine = Legion::Extensions::CognitiveCatalyst::Helpers::CatalystEngine.new
    cat = client.create_catalyst(catalyst_type: :experience, domain: :learning,
                                 potency: 0.9, specificity: 0.9, engine: engine)
    rxn = client.create_reaction(reaction_type: :synthesis, reactants: %w[a b], engine: engine)
    result = client.apply_catalyst(catalyst_id: cat[:catalyst][:id],
                                   reaction_id: rxn[:reaction][:id],
                                   engine: engine)
    expect(result[:success]).to be true
    expect(result[:activation_energy]).to be < 0.6
  end

  it 'can complete a full catalyst workflow: create -> apply -> attempt -> report' do
    engine = Legion::Extensions::CognitiveCatalyst::Helpers::CatalystEngine.new
    cat = client.create_catalyst(catalyst_type: :insight, domain: :reasoning,
                                 potency: 1.0, specificity: 1.0, engine: engine)
    rxn = client.create_reaction(reaction_type: :decomposition,
                                 reactants: %w[complex_idea],
                                 activation_energy: 0.1,
                                 engine: engine)
    client.apply_catalyst(catalyst_id: cat[:catalyst][:id],
                          reaction_id: rxn[:reaction][:id],
                          engine: engine)
    result = client.attempt_reaction(reaction_id: rxn[:reaction][:id],
                                     energy_input: 0.8,
                                     engine: engine)
    expect(result[:completed]).to be true
    expect(result[:catalyzed]).to be true
    status = client.catalyst_status(engine: engine)
    expect(status[:catalyzed_count]).to eq(1)
    expect(status[:catalyzed_rate]).to eq(1.0)
  end

  it 'maintains separate state per client instance' do
    c1 = described_class.new
    c2 = described_class.new
    c1.create_catalyst(catalyst_type: :insight, domain: :d)
    s1 = c1.catalyst_status
    s2 = c2.catalyst_status
    expect(s1[:total_catalysts]).to eq(1)
    expect(s2[:total_catalysts]).to eq(0)
  end
end
