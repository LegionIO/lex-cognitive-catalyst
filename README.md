# lex-cognitive-catalyst

Cognitive catalysis acceleration for LegionIO. Models how certain thoughts and experiences act as chemical catalysts — accelerating cognitive reactions without being consumed.

## What It Does

Catalysts lower the activation energy required for cognitive reactions. An insight, analogy, or recurring pattern can make otherwise-stalled synthesis reactions complete with much less energy. Unlike consumed reagents, catalysts remain available for repeated use (though their potency decays from environmental wear).

Five reaction types are supported: synthesis (combining ideas), decomposition (breaking down assumptions), exchange (swapping belief components), neutralization (resolving opposing forces), and precipitation (crystallizing vague concepts into concrete ones). Applying the right catalyst — especially one with matching domain specificity — dramatically increases reaction yield.

## Usage

```ruby
client = Legion::Extensions::CognitiveCatalyst::Client.new

catalyst = client.create_catalyst(
  catalyst_type: :analogy,
  domain: :problem_solving,
  potency: 0.9,
  specificity: 0.8
)

reaction = client.create_reaction(
  reaction_type: :synthesis,
  reactants: ['concept_a', 'concept_b'],
  activation_energy: 0.7
)

client.apply_catalyst(catalyst_id: catalyst[:catalyst][:id],
                      reaction_id: reaction[:reaction][:id])
client.attempt_reaction(reaction_id: reaction[:reaction][:id], energy_input: 0.5)
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
