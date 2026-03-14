# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveCatalyst::Runners::CognitiveCatalyst do
  let(:client) { Legion::Extensions::CognitiveCatalyst::Client.new }
  let(:engine) { Legion::Extensions::CognitiveCatalyst::Helpers::CatalystEngine.new }

  def create_catalyst(client_instance = client, **opts)
    defaults = { catalyst_type: :insight, domain: :reasoning, engine: engine }
    client_instance.create_catalyst(**defaults.merge(opts))
  end

  def create_reaction(client_instance = client, **opts)
    defaults = { reaction_type: :synthesis, reactants: %w[idea_a idea_b], engine: engine }
    client_instance.create_reaction(**defaults.merge(opts))
  end

  describe '#create_catalyst' do
    it 'returns success: true' do
      result = create_catalyst
      expect(result[:success]).to be true
    end

    it 'includes catalyst hash in result' do
      result = create_catalyst
      expect(result[:catalyst]).to include(:id, :catalyst_type, :domain, :potency)
    end

    it 'uses default potency 0.5 when not specified' do
      result = create_catalyst
      expect(result[:catalyst][:potency]).to eq(0.5)
    end

    it 'uses custom potency when provided' do
      result = create_catalyst(potency: 0.9)
      expect(result[:catalyst][:potency]).to eq(0.9)
    end

    it 'uses custom specificity when provided' do
      result = create_catalyst(specificity: 0.8)
      expect(result[:catalyst][:specificity]).to eq(0.8)
    end

    it 'accepts all valid catalyst types' do
      Legion::Extensions::CognitiveCatalyst::Helpers::Constants::CATALYST_TYPES.each do |type|
        result = client.create_catalyst(catalyst_type: type, domain: :d, engine: engine)
        expect(result[:success]).to be true
      end
    end

    it 'returns success: false for invalid catalyst_type' do
      result = client.create_catalyst(catalyst_type: :invalid, domain: :d, engine: engine)
      expect(result[:success]).to be false
      expect(result[:reason]).to be_a(String)
    end
  end

  describe '#create_reaction' do
    it 'returns success: true' do
      result = create_reaction
      expect(result[:success]).to be true
    end

    it 'includes reaction hash in result' do
      result = create_reaction
      expect(result[:reaction]).to include(:id, :reaction_type, :reactants, :activation_energy)
    end

    it 'accepts all valid reaction types' do
      Legion::Extensions::CognitiveCatalyst::Helpers::Constants::REACTION_TYPES.each do |type|
        result = client.create_reaction(reaction_type: type, reactants: ['x'], engine: engine)
        expect(result[:success]).to be true
      end
    end

    it 'returns success: false for invalid reaction_type' do
      result = client.create_reaction(reaction_type: :explode, reactants: [], engine: engine)
      expect(result[:success]).to be false
    end

    it 'uses custom activation_energy' do
      result = create_reaction(activation_energy: 0.3)
      expect(result[:reaction][:activation_energy]).to eq(0.3)
    end
  end

  describe '#apply_catalyst' do
    it 'lowers activation energy and returns success' do
      cat    = create_catalyst
      rxn    = create_reaction
      result = client.apply_catalyst(catalyst_id: cat[:catalyst][:id],
                                     reaction_id: rxn[:reaction][:id],
                                     engine: engine)
      expect(result[:success]).to be true
      expect(result[:activation_energy]).to be < 0.6
    end

    it 'returns failure for unknown catalyst_id' do
      rxn    = create_reaction
      result = client.apply_catalyst(catalyst_id: 'bad',
                                     reaction_id: rxn[:reaction][:id],
                                     engine: engine)
      expect(result[:success]).to be false
    end

    it 'returns failure for unknown reaction_id' do
      cat    = create_catalyst
      result = client.apply_catalyst(catalyst_id: cat[:catalyst][:id],
                                     reaction_id: 'bad',
                                     engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#attempt_reaction' do
    it 'completes reaction with sufficient energy' do
      rxn    = create_reaction
      result = client.attempt_reaction(reaction_id: rxn[:reaction][:id],
                                       energy_input: 1.0,
                                       engine: engine)
      expect(result[:completed]).to be true
    end

    it 'does not complete with insufficient energy' do
      rxn    = create_reaction
      result = client.attempt_reaction(reaction_id: rxn[:reaction][:id],
                                       energy_input: 0.1,
                                       engine: engine)
      expect(result[:completed]).to be false
    end

    it 'includes yield data when completed' do
      rxn    = create_reaction
      result = client.attempt_reaction(reaction_id: rxn[:reaction][:id],
                                       energy_input: 1.0,
                                       engine: engine)
      expect(result).to include(:yield_value, :yield_label)
    end

    it 'returns not_found for unknown reaction' do
      result = client.attempt_reaction(reaction_id: 'missing', energy_input: 1.0, engine: engine)
      expect(result[:reason]).to eq(:not_found)
    end
  end

  describe '#recharge' do
    it 'increases catalyst potency' do
      cat    = create_catalyst(potency: 0.3)
      result = client.recharge(catalyst_id: cat[:catalyst][:id], amount: 0.2, engine: engine)
      expect(result[:success]).to be true
      expect(result[:potency]).to be > 0.3
    end

    it 'returns failure for unknown catalyst' do
      result = client.recharge(catalyst_id: 'bad', amount: 0.2, engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#list_catalysts' do
    it 'returns success: true' do
      result = client.list_catalysts(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns empty list initially' do
      result = client.list_catalysts(engine: engine)
      expect(result[:count]).to eq(0)
    end

    it 'reflects created catalysts' do
      create_catalyst
      create_catalyst(catalyst_type: :analogy)
      result = client.list_catalysts(engine: engine)
      expect(result[:count]).to eq(2)
    end

    it 'includes catalyst hashes in the list' do
      create_catalyst
      result = client.list_catalysts(engine: engine)
      expect(result[:catalysts].first).to include(:id, :catalyst_type, :potency)
    end
  end

  describe '#catalyst_status' do
    it 'returns success: true' do
      result = client.catalyst_status(engine: engine)
      expect(result[:success]).to be true
    end

    it 'includes report keys' do
      result = client.catalyst_status(engine: engine)
      expect(result).to include(:total_catalysts, :total_reactions, :completed,
                                :catalyzed_count, :catalyzed_rate, :avg_potency,
                                :powerful_count, :inert_count)
    end

    it 'reflects catalysts and reactions created' do
      create_catalyst
      create_reaction
      result = client.catalyst_status(engine: engine)
      expect(result[:total_catalysts]).to eq(1)
      expect(result[:total_reactions]).to eq(1)
    end

    it 'shows catalyzed_rate 0.0 initially' do
      result = client.catalyst_status(engine: engine)
      expect(result[:catalyzed_rate]).to eq(0.0)
    end

    it 'reflects completed reactions in report' do
      rxn    = create_reaction
      client.attempt_reaction(reaction_id: rxn[:reaction][:id], energy_input: 1.0, engine: engine)
      result = client.catalyst_status(engine: engine)
      expect(result[:completed]).to eq(1)
    end
  end
end
