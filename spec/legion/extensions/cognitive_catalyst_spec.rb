# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveCatalyst do
  it 'defines VERSION' do
    expect(Legion::Extensions::CognitiveCatalyst::VERSION).to eq('0.1.0')
  end

  it 'defines CATALYST_TYPES' do
    expect(Legion::Extensions::CognitiveCatalyst::Helpers::Constants::CATALYST_TYPES)
      .to include(:experience, :insight, :analogy, :pattern, :emotion)
  end

  it 'defines REACTION_TYPES' do
    expect(Legion::Extensions::CognitiveCatalyst::Helpers::Constants::REACTION_TYPES)
      .to include(:synthesis, :decomposition, :exchange, :neutralization, :precipitation)
  end

  it 'defines MAX_CATALYSTS' do
    expect(Legion::Extensions::CognitiveCatalyst::Helpers::Constants::MAX_CATALYSTS).to eq(500)
  end

  it 'defines MAX_REACTIONS' do
    expect(Legion::Extensions::CognitiveCatalyst::Helpers::Constants::MAX_REACTIONS).to eq(200)
  end

  it 'defines ACTIVATION_ENERGY threshold' do
    expect(Legion::Extensions::CognitiveCatalyst::Helpers::Constants::ACTIVATION_ENERGY).to eq(0.6)
  end

  it 'defines CATALYST_REDUCTION' do
    expect(Legion::Extensions::CognitiveCatalyst::Helpers::Constants::CATALYST_REDUCTION).to eq(0.3)
  end

  it 'defines POTENCY_DECAY' do
    expect(Legion::Extensions::CognitiveCatalyst::Helpers::Constants::POTENCY_DECAY).to eq(0.02)
  end

  it 'defines SPECIFICITY_BONUS' do
    expect(Legion::Extensions::CognitiveCatalyst::Helpers::Constants::SPECIFICITY_BONUS).to eq(0.15)
  end

  it 'defines POTENCY_LABELS' do
    expect(Legion::Extensions::CognitiveCatalyst::Helpers::Constants::POTENCY_LABELS).to be_a(Hash)
  end

  it 'defines YIELD_LABELS' do
    expect(Legion::Extensions::CognitiveCatalyst::Helpers::Constants::YIELD_LABELS).to be_a(Hash)
  end
end
