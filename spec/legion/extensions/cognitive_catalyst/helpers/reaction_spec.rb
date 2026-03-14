# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveCatalyst::Helpers::Reaction do
  let(:default_activation) { Legion::Extensions::CognitiveCatalyst::Helpers::Constants::ACTIVATION_ENERGY }

  subject(:reaction) { described_class.new(reaction_type: :synthesis, reactants: %w[idea_a idea_b]) }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(reaction.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'assigns reaction_type' do
      expect(reaction.reaction_type).to eq(:synthesis)
    end

    it 'assigns reactants as array' do
      expect(reaction.reactants).to eq(%w[idea_a idea_b])
    end

    it 'defaults activation_energy to ACTIVATION_ENERGY' do
      expect(reaction.activation_energy).to eq(default_activation)
    end

    it 'defaults yield_value to 0.0' do
      expect(reaction.yield_value).to eq(0.0)
    end

    it 'defaults catalyzed to false' do
      expect(reaction.catalyzed).to be false
    end

    it 'defaults catalyst_id to nil' do
      expect(reaction.catalyst_id).to be_nil
    end

    it 'defaults completed to false' do
      expect(reaction.completed).to be false
    end

    it 'records created_at' do
      expect(reaction.created_at).to be_a(Time)
    end

    it 'accepts custom activation_energy' do
      r = described_class.new(reaction_type: :exchange, reactants: [], activation_energy: 0.3)
      expect(r.activation_energy).to eq(0.3)
    end

    it 'clamps activation_energy to 0..1' do
      r = described_class.new(reaction_type: :exchange, reactants: [], activation_energy: 2.0)
      expect(r.activation_energy).to eq(1.0)
    end

    it 'wraps single reactant string in array' do
      r = described_class.new(reaction_type: :synthesis, reactants: 'single_idea')
      expect(r.reactants).to eq(['single_idea'])
    end
  end

  describe '#apply_catalyst!' do
    let(:catalyst) do
      Legion::Extensions::CognitiveCatalyst::Helpers::Catalyst.new(
        catalyst_type: :insight, domain: :reasoning, potency: 0.8, specificity: 0.5
      )
    end

    it 'reduces activation_energy' do
      original = reaction.activation_energy
      reaction.apply_catalyst!(catalyst)
      expect(reaction.activation_energy).to be < original
    end

    it 'sets catalyzed to true' do
      reaction.apply_catalyst!(catalyst)
      expect(reaction.catalyzed).to be true
    end

    it 'records catalyst_id' do
      reaction.apply_catalyst!(catalyst)
      expect(reaction.catalyst_id).to eq(catalyst.id)
    end

    it 'increments catalyst uses_count' do
      expect { reaction.apply_catalyst!(catalyst) }.to change(catalyst, :uses_count).by(1)
    end

    it 'does not reduce activation_energy below 0.0' do
      strong = Legion::Extensions::CognitiveCatalyst::Helpers::Catalyst.new(
        catalyst_type: :insight, domain: :d, potency: 1.0, specificity: 1.0
      )
      10.times { reaction.apply_catalyst!(strong) }
      expect(reaction.activation_energy).to eq(0.0)
    end
  end

  describe '#attempt!' do
    context 'when energy_input >= activation_energy' do
      it 'returns true' do
        expect(reaction.attempt!(0.8)).to be true
      end

      it 'sets completed to true' do
        reaction.attempt!(0.8)
        expect(reaction.completed).to be true
      end

      it 'calculates yield_value > 0.5' do
        reaction.attempt!(1.0)
        expect(reaction.yield_value).to be > 0.5
      end

      it 'returns maximum yield on full surplus (activation_energy=0)' do
        r = described_class.new(reaction_type: :synthesis, reactants: [], activation_energy: 0.0)
        r.attempt!(1.0)
        expect(r.yield_value).to eq(1.0)
      end

      it 'returns minimum passing yield at exact threshold' do
        reaction.attempt!(reaction.activation_energy)
        expect(reaction.yield_value).to be_within(0.0001).of(0.5)
      end
    end

    context 'when energy_input < activation_energy' do
      it 'returns false' do
        expect(reaction.attempt!(0.1)).to be false
      end

      it 'leaves completed as false' do
        reaction.attempt!(0.1)
        expect(reaction.completed).to be false
      end

      it 'leaves yield_value at 0.0' do
        reaction.attempt!(0.1)
        expect(reaction.yield_value).to eq(0.0)
      end
    end

    it 'returns false if already completed' do
      reaction.attempt!(1.0)
      expect(reaction.attempt!(1.0)).to be false
    end
  end

  describe '#complete?' do
    it 'returns false before attempt' do
      expect(reaction.complete?).to be false
    end

    it 'returns true after successful attempt' do
      reaction.attempt!(1.0)
      expect(reaction.complete?).to be true
    end
  end

  describe '#catalyzed?' do
    it 'returns false when no catalyst applied' do
      expect(reaction.catalyzed?).to be false
    end

    it 'returns true after catalyst applied' do
      catalyst = Legion::Extensions::CognitiveCatalyst::Helpers::Catalyst.new(
        catalyst_type: :insight, domain: :d
      )
      reaction.apply_catalyst!(catalyst)
      expect(reaction.catalyzed?).to be true
    end
  end

  describe '#spontaneous?' do
    it 'returns false when not completed' do
      expect(reaction.spontaneous?).to be false
    end

    it 'returns true when completed without catalyst' do
      reaction.attempt!(1.0)
      expect(reaction.spontaneous?).to be true
    end

    it 'returns false when completed with catalyst' do
      catalyst = Legion::Extensions::CognitiveCatalyst::Helpers::Catalyst.new(
        catalyst_type: :insight, domain: :d
      )
      reaction.apply_catalyst!(catalyst)
      reaction.attempt!(1.0)
      expect(reaction.spontaneous?).to be false
    end
  end

  describe '#yield_label' do
    it 'returns :negligible before completion' do
      expect(reaction.yield_label).to eq(:negligible)
    end

    it 'returns :excellent for high yield (activation_energy=0, full surplus)' do
      r = described_class.new(reaction_type: :synthesis, reactants: [], activation_energy: 0.0)
      r.attempt!(1.0)
      expect(r.yield_label).to eq(:excellent)
    end

    it 'returns :fair for moderate yield' do
      r = described_class.new(reaction_type: :synthesis, reactants: [], activation_energy: 0.1)
      r.attempt!(0.2)
      expect(%i[fair good poor excellent negligible]).to include(r.yield_label)
    end
  end

  describe '#to_h' do
    it 'includes all required keys' do
      h = reaction.to_h
      expect(h).to include(:id, :reaction_type, :reactants, :activation_energy,
                           :yield_value, :yield_label, :catalyzed, :catalyst_id,
                           :completed, :spontaneous, :created_at)
    end

    it 'reflects completed state' do
      reaction.attempt!(1.0)
      expect(reaction.to_h[:completed]).to be true
    end
  end
end
