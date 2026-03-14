# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveCatalyst::Helpers::CatalystEngine do
  subject(:engine) { described_class.new }

  let(:constants) { Legion::Extensions::CognitiveCatalyst::Helpers::Constants }

  def build_catalyst(potency: 0.7, specificity: 0.6)
    engine.create_catalyst(catalyst_type: :insight, domain: :reasoning,
                           potency: potency, specificity: specificity)
  end

  def build_reaction(activation_energy: nil)
    opts = { reaction_type: :synthesis, reactants: %w[a b] }
    opts[:activation_energy] = activation_energy if activation_energy
    engine.create_reaction(**opts)
  end

  describe '#create_catalyst' do
    it 'creates and returns a Catalyst' do
      result = build_catalyst
      expect(result).to be_a(Legion::Extensions::CognitiveCatalyst::Helpers::Catalyst)
    end

    it 'stores the catalyst' do
      build_catalyst
      expect(engine.all_catalysts.size).to eq(1)
    end

    it 'accepts all valid catalyst types' do
      constants::CATALYST_TYPES.each do |type|
        expect { engine.create_catalyst(catalyst_type: type, domain: :d) }.not_to raise_error
      end
    end

    it 'raises ArgumentError for invalid catalyst_type' do
      expect { engine.create_catalyst(catalyst_type: :invalid, domain: :d) }.to raise_error(ArgumentError)
    end

    it 'evicts oldest when at MAX_CATALYSTS capacity' do
      max = constants::MAX_CATALYSTS
      max.times { |i| engine.create_catalyst(catalyst_type: :insight, domain: "d#{i}") }
      engine.create_catalyst(catalyst_type: :analogy, domain: :overflow)
      expect(engine.all_catalysts.size).to eq(max)
    end
  end

  describe '#create_reaction' do
    it 'creates and returns a Reaction' do
      result = build_reaction
      expect(result).to be_a(Legion::Extensions::CognitiveCatalyst::Helpers::Reaction)
    end

    it 'stores the reaction' do
      build_reaction
      expect(engine.all_reactions.size).to eq(1)
    end

    it 'accepts all valid reaction types' do
      constants::REACTION_TYPES.each do |type|
        expect { engine.create_reaction(reaction_type: type, reactants: ['x']) }.not_to raise_error
      end
    end

    it 'raises ArgumentError for invalid reaction_type' do
      expect { engine.create_reaction(reaction_type: :explode, reactants: []) }.to raise_error(ArgumentError)
    end

    it 'evicts oldest when at MAX_REACTIONS capacity' do
      max = constants::MAX_REACTIONS
      max.times { |i| engine.create_reaction(reaction_type: :synthesis, reactants: ["r#{i}"]) }
      engine.create_reaction(reaction_type: :exchange, reactants: [:overflow])
      expect(engine.all_reactions.size).to eq(max)
    end
  end

  describe '#apply_catalyst' do
    let(:catalyst) { build_catalyst }
    let(:reaction) { build_reaction }

    it 'returns success with updated activation_energy' do
      result = engine.apply_catalyst(catalyst_id: catalyst.id, reaction_id: reaction.id)
      expect(result[:success]).to be true
      expect(result[:activation_energy]).to be < constants::ACTIVATION_ENERGY
    end

    it 'returns catalyst_not_found for unknown catalyst' do
      result = engine.apply_catalyst(catalyst_id: 'bad', reaction_id: reaction.id)
      expect(result[:reason]).to eq(:catalyst_not_found)
    end

    it 'returns reaction_not_found for unknown reaction' do
      result = engine.apply_catalyst(catalyst_id: catalyst.id, reaction_id: 'bad')
      expect(result[:reason]).to eq(:reaction_not_found)
    end

    it 'returns already_completed for a done reaction' do
      engine.attempt_reaction(reaction_id: reaction.id, energy_input: 1.0)
      result = engine.apply_catalyst(catalyst_id: catalyst.id, reaction_id: reaction.id)
      expect(result[:reason]).to eq(:already_completed)
    end
  end

  describe '#attempt_reaction' do
    let(:reaction) { build_reaction }

    it 'completes the reaction when energy is sufficient' do
      result = engine.attempt_reaction(reaction_id: reaction.id, energy_input: 1.0)
      expect(result[:completed]).to be true
    end

    it 'does not complete when energy is insufficient' do
      result = engine.attempt_reaction(reaction_id: reaction.id, energy_input: 0.1)
      expect(result[:completed]).to be false
    end

    it 'returns not_found for unknown reaction' do
      result = engine.attempt_reaction(reaction_id: 'missing', energy_input: 1.0)
      expect(result[:reason]).to eq(:not_found)
    end

    it 'returns already_completed for a done reaction' do
      engine.attempt_reaction(reaction_id: reaction.id, energy_input: 1.0)
      result = engine.attempt_reaction(reaction_id: reaction.id, energy_input: 1.0)
      expect(result[:reason]).to eq(:already_completed)
    end

    it 'includes yield_value and yield_label' do
      result = engine.attempt_reaction(reaction_id: reaction.id, energy_input: 1.0)
      expect(result).to include(:yield_value, :yield_label)
    end
  end

  describe '#degrade_all!' do
    it 'reduces potency of all catalysts' do
      c = build_catalyst(potency: 0.8)
      engine.degrade_all!
      expect(c.potency).to be < 0.8
    end

    it 'does nothing when no catalysts exist' do
      expect { engine.degrade_all! }.not_to raise_error
    end
  end

  describe '#recharge_catalyst' do
    let(:catalyst) { build_catalyst(potency: 0.3) }

    it 'increases potency' do
      result = engine.recharge_catalyst(catalyst_id: catalyst.id, amount: 0.2)
      expect(result[:success]).to be true
      expect(result[:potency]).to be_within(0.001).of(0.5)
    end

    it 'returns not_found for unknown catalyst' do
      result = engine.recharge_catalyst(catalyst_id: 'bad', amount: 0.1)
      expect(result[:reason]).to eq(:not_found)
    end

    it 'includes potency_label in result' do
      result = engine.recharge_catalyst(catalyst_id: catalyst.id, amount: 0.6)
      expect(result).to include(:potency_label)
    end
  end

  describe '#all_catalysts' do
    it 'returns empty array initially' do
      expect(engine.all_catalysts).to eq([])
    end

    it 'returns all stored catalysts' do
      2.times { build_catalyst }
      expect(engine.all_catalysts.size).to eq(2)
    end
  end

  describe '#all_reactions' do
    it 'returns empty array initially' do
      expect(engine.all_reactions).to eq([])
    end

    it 'returns all stored reactions' do
      2.times { build_reaction }
      expect(engine.all_reactions.size).to eq(2)
    end
  end

  describe '#completed_reactions' do
    it 'returns only completed reactions' do
      r1 = build_reaction
      r2 = build_reaction
      engine.attempt_reaction(reaction_id: r1.id, energy_input: 1.0)
      engine.attempt_reaction(reaction_id: r2.id, energy_input: 0.1)
      expect(engine.completed_reactions.size).to eq(1)
    end
  end

  describe '#catalyzed_rate' do
    it 'returns 0.0 when no reactions completed' do
      expect(engine.catalyzed_rate).to eq(0.0)
    end

    it 'returns 1.0 when all completed reactions were catalyzed' do
      catalyst = build_catalyst(potency: 1.0, specificity: 1.0)
      reaction = build_reaction(activation_energy: 0.01)
      engine.apply_catalyst(catalyst_id: catalyst.id, reaction_id: reaction.id)
      engine.attempt_reaction(reaction_id: reaction.id, energy_input: 1.0)
      expect(engine.catalyzed_rate).to eq(1.0)
    end

    it 'returns 0.0 when no completed reactions were catalyzed' do
      reaction = build_reaction
      engine.attempt_reaction(reaction_id: reaction.id, energy_input: 1.0)
      expect(engine.catalyzed_rate).to eq(0.0)
    end

    it 'returns fractional rate for mixed completions' do
      r1 = build_reaction
      r2 = build_reaction
      engine.attempt_reaction(reaction_id: r1.id, energy_input: 1.0)
      catalyst = build_catalyst(potency: 1.0, specificity: 1.0)
      engine.apply_catalyst(catalyst_id: catalyst.id, reaction_id: r2.id)
      engine.attempt_reaction(reaction_id: r2.id, energy_input: 1.0)
      expect(engine.catalyzed_rate).to be_within(0.01).of(0.5)
    end
  end

  describe '#catalyst_report' do
    it 'returns a report hash with all required keys' do
      report = engine.catalyst_report
      expect(report).to include(
        :total_catalysts, :total_reactions, :completed, :catalyzed_count,
        :catalyzed_rate, :avg_potency, :powerful_count, :inert_count
      )
    end

    it 'counts powerful catalysts' do
      build_catalyst(potency: 0.9)
      build_catalyst(potency: 0.5)
      report = engine.catalyst_report
      expect(report[:powerful_count]).to eq(1)
    end

    it 'counts inert catalysts' do
      engine.create_catalyst(catalyst_type: :insight, domain: :d, potency: 0.1)
      engine.create_catalyst(catalyst_type: :insight, domain: :d, potency: 0.5)
      report = engine.catalyst_report
      expect(report[:inert_count]).to eq(1)
    end

    it 'computes avg_potency' do
      engine.create_catalyst(catalyst_type: :insight, domain: :d, potency: 0.4)
      engine.create_catalyst(catalyst_type: :insight, domain: :d, potency: 0.6)
      report = engine.catalyst_report
      expect(report[:avg_potency]).to be_within(0.01).of(0.5)
    end

    it 'returns avg_potency of 0.0 when no catalysts' do
      report = engine.catalyst_report
      expect(report[:avg_potency]).to eq(0.0)
    end
  end
end
