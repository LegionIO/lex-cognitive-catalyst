# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveCatalyst::Helpers::Catalyst do
  subject(:catalyst) { described_class.new(catalyst_type: :insight, domain: :reasoning) }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(catalyst.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'assigns catalyst_type' do
      expect(catalyst.catalyst_type).to eq(:insight)
    end

    it 'assigns domain' do
      expect(catalyst.domain).to eq(:reasoning)
    end

    it 'defaults potency to 0.5' do
      expect(catalyst.potency).to eq(0.5)
    end

    it 'defaults specificity to 0.5' do
      expect(catalyst.specificity).to eq(0.5)
    end

    it 'defaults uses_count to 0' do
      expect(catalyst.uses_count).to eq(0)
    end

    it 'records created_at' do
      expect(catalyst.created_at).to be_a(Time)
    end

    it 'clamps potency above 1.0' do
      c = described_class.new(catalyst_type: :analogy, domain: :d, potency: 2.0)
      expect(c.potency).to eq(1.0)
    end

    it 'clamps potency below 0.0' do
      c = described_class.new(catalyst_type: :analogy, domain: :d, potency: -0.5)
      expect(c.potency).to eq(0.0)
    end

    it 'clamps specificity above 1.0' do
      c = described_class.new(catalyst_type: :analogy, domain: :d, specificity: 5.0)
      expect(c.specificity).to eq(1.0)
    end

    it 'accepts custom potency' do
      c = described_class.new(catalyst_type: :pattern, domain: :d, potency: 0.9)
      expect(c.potency).to eq(0.9)
    end
  end

  describe '#catalyze!' do
    it 'increments uses_count each call' do
      catalyst.catalyze!(:synthesis)
      catalyst.catalyze!(:synthesis)
      expect(catalyst.uses_count).to eq(2)
    end

    it 'returns activation_reduction = potency * specificity' do
      c = described_class.new(catalyst_type: :insight, domain: :d, potency: 0.8, specificity: 0.5)
      reduction = c.catalyze!(:synthesis)
      expect(reduction).to be_within(0.0001).of(0.4)
    end

    it 'does NOT reduce potency (catalysts are not consumed)' do
      original = catalyst.potency
      catalyst.catalyze!(:synthesis)
      expect(catalyst.potency).to eq(original)
    end

    it 'returns a float' do
      expect(catalyst.catalyze!(:exchange)).to be_a(Float)
    end

    it 'works with all reaction types' do
      Legion::Extensions::CognitiveCatalyst::Helpers::Constants::REACTION_TYPES.each do |rt|
        expect { catalyst.catalyze!(rt) }.not_to raise_error
      end
    end
  end

  describe '#degrade!' do
    it 'reduces potency by POTENCY_DECAY' do
      decay = Legion::Extensions::CognitiveCatalyst::Helpers::Constants::POTENCY_DECAY
      original = catalyst.potency
      catalyst.degrade!
      expect(catalyst.potency).to be_within(0.0001).of(original - decay)
    end

    it 'does not reduce potency below 0.0' do
      c = described_class.new(catalyst_type: :insight, domain: :d, potency: 0.01)
      c.degrade!
      expect(c.potency).to eq(0.0)
    end

    it 'can be called multiple times' do
      5.times { catalyst.degrade! }
      expect(catalyst.potency).to be >= 0.0
      expect(catalyst.potency).to be < 0.5
    end
  end

  describe '#recharge!' do
    it 'increases potency by amount' do
      c = described_class.new(catalyst_type: :insight, domain: :d, potency: 0.3)
      c.recharge!(0.2)
      expect(c.potency).to be_within(0.0001).of(0.5)
    end

    it 'clamps at 1.0' do
      c = described_class.new(catalyst_type: :insight, domain: :d, potency: 0.9)
      c.recharge!(0.5)
      expect(c.potency).to eq(1.0)
    end

    it 'returns the new potency' do
      result = catalyst.recharge!(0.1)
      expect(result).to be_a(Float)
    end
  end

  describe '#powerful?' do
    it 'returns true for potency >= 0.8' do
      c = described_class.new(catalyst_type: :insight, domain: :d, potency: 0.8)
      expect(c.powerful?).to be true
    end

    it 'returns false for potency < 0.8' do
      c = described_class.new(catalyst_type: :insight, domain: :d, potency: 0.7)
      expect(c.powerful?).to be false
    end
  end

  describe '#inert?' do
    it 'returns true for potency < 0.2' do
      c = described_class.new(catalyst_type: :insight, domain: :d, potency: 0.1)
      expect(c.inert?).to be true
    end

    it 'returns false for potency >= 0.2' do
      c = described_class.new(catalyst_type: :insight, domain: :d, potency: 0.2)
      expect(c.inert?).to be false
    end
  end

  describe '#specific?' do
    it 'returns true for specificity >= 0.7' do
      c = described_class.new(catalyst_type: :insight, domain: :d, specificity: 0.7)
      expect(c.specific?).to be true
    end

    it 'returns false for specificity < 0.7' do
      c = described_class.new(catalyst_type: :insight, domain: :d, specificity: 0.6)
      expect(c.specific?).to be false
    end
  end

  describe '#broad?' do
    it 'returns true for specificity < 0.3' do
      c = described_class.new(catalyst_type: :insight, domain: :d, specificity: 0.2)
      expect(c.broad?).to be true
    end

    it 'returns false for specificity >= 0.3' do
      c = described_class.new(catalyst_type: :insight, domain: :d, specificity: 0.3)
      expect(c.broad?).to be false
    end
  end

  describe '#potency_label' do
    it 'returns :powerful for potency >= 0.8' do
      c = described_class.new(catalyst_type: :insight, domain: :d, potency: 0.9)
      expect(c.potency_label).to eq(:powerful)
    end

    it 'returns :strong for potency in 0.6...0.8' do
      c = described_class.new(catalyst_type: :insight, domain: :d, potency: 0.7)
      expect(c.potency_label).to eq(:strong)
    end

    it 'returns :moderate for potency in 0.4...0.6' do
      c = described_class.new(catalyst_type: :insight, domain: :d, potency: 0.5)
      expect(c.potency_label).to eq(:moderate)
    end

    it 'returns :weak for potency in 0.2...0.4' do
      c = described_class.new(catalyst_type: :insight, domain: :d, potency: 0.3)
      expect(c.potency_label).to eq(:weak)
    end

    it 'returns :inert for potency < 0.2' do
      c = described_class.new(catalyst_type: :insight, domain: :d, potency: 0.1)
      expect(c.potency_label).to eq(:inert)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all required keys' do
      h = catalyst.to_h
      expect(h).to include(:id, :catalyst_type, :domain, :potency, :specificity,
                           :uses_count, :potency_label, :powerful, :inert,
                           :specific, :broad, :created_at)
    end

    it 'reflects current state' do
      catalyst.catalyze!(:synthesis)
      expect(catalyst.to_h[:uses_count]).to eq(1)
    end
  end
end
