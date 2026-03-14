# lex-cognitive-catalyst

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Models how certain thoughts and experiences act as chemical catalysts — accelerating cognitive reactions without being consumed. Catalysts lower the activation energy required for synthesis, decomposition, exchange, neutralization, and precipitation reactions between ideas. A potent catalyst enables reactions that would otherwise stall from insufficient energy input.

## Gem Info

- **Gem name**: `lex-cognitive-catalyst`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::CognitiveCatalyst`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_catalyst/
  cognitive_catalyst.rb
  version.rb
  client.rb
  helpers/
    constants.rb
    catalyst.rb
    catalyst_engine.rb
    reaction.rb
  runners/
    cognitive_catalyst.rb
```

## Key Constants

From `helpers/constants.rb`:

- `CATALYST_TYPES` — `%i[experience insight analogy pattern emotion]`
- `REACTION_TYPES` — `%i[synthesis decomposition exchange neutralization precipitation]`
- `MAX_CATALYSTS` = `500`, `MAX_REACTIONS` = `200`
- `ACTIVATION_ENERGY` = `0.6` (minimum energy to complete a reaction without a catalyst)
- `CATALYST_REDUCTION` = `0.3` (how much a catalyst lowers the activation energy threshold)
- `POTENCY_DECAY` = `0.02` (environmental wear — not from use)
- `SPECIFICITY_BONUS` = `0.15` (bonus when catalyst domain matches reaction domain)
- `POTENCY_LABELS` — `0.8+` = `:powerful`, `0.6` = `:strong`, `0.4` = `:moderate`, `0.2` = `:weak`, below = `:inert`
- `YIELD_LABELS` — `0.8+` = `:excellent` through below `0.2` = `:negligible`

## Runners

All methods in `Runners::CognitiveCatalyst`:

- `create_catalyst(catalyst_type:, domain:, potency: nil, specificity: nil)` — registers a new catalyst; validates against `CATALYST_TYPES`
- `create_reaction(reaction_type:, reactants:, activation_energy: nil)` — creates a pending reaction; validates against `REACTION_TYPES`
- `apply_catalyst(catalyst_id:, reaction_id:)` — associates a catalyst with a reaction, lowering effective activation energy
- `attempt_reaction(reaction_id:, energy_input:)` — attempts to complete a reaction; succeeds if `energy_input >= effective_threshold`; returns yield score
- `recharge(catalyst_id:, amount:)` — restores potency to a catalyst
- `list_catalysts` — all catalysts with current potency
- `catalyst_status` — aggregate report: totals, catalyzed rate, most potent

## Helpers

- `CatalystEngine` — manages catalysts and reactions. `apply_catalyst` attaches a catalyst to a reaction; `attempt_reaction` evaluates whether energy input meets the (optionally reduced) threshold.
- `Catalyst` — has `catalyst_type`, `domain`, `potency`, `specificity`. `potency` decays over time (environmental wear). Not consumed on use.
- `Reaction` — has `reaction_type`, `reactants`, `activation_energy`. Stores applied catalyst IDs. Effective threshold = `activation_energy - (CATALYST_REDUCTION * catalyst_potency) + SPECIFICITY_BONUS` if domains match.

## Integration Points

- `lex-cognitive-coherence` can provide the constraint network that reactions operate within — catalysts accelerate coherence maximization by lowering the cost of belief integration.
- `lex-memory` trace retrieval during `lex-dream` is a natural catalyst source: high-strength traces become experience catalysts for synthesis reactions during dream phases.
- `recharge` enables explicit catalyst maintenance — callers can recharge important catalysts (e.g., a core analogy) to keep them potent.

## Development Notes

- Catalyst potency decays from environmental wear (not from use) — catalysts are not consumed. `POTENCY_DECAY = 0.02` per decay cycle.
- `SPECIFICITY_BONUS` is added when catalyst domain matches reaction domain — rewarding domain-specific knowledge application.
- Invalid `catalyst_type` or `reaction_type` raises `ArgumentError` (from constants validation in the runner).
- Runners log all operations via `Legion::Logging.debug`/`warn`.
