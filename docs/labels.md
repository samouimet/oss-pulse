# Label definitions (draft v0)

Draft. These are documented judgment calls, not objective truth. Each tool is
judged against its own recent history, not against other tools. Time windows
and thresholds are set later from real data and tested against tools with
known histories.

## Rules checked first
- **Archived repo:** labeled Dormant, no further logic.
- **Insufficient data:** a tool without enough history to compare against is
  labeled "Insufficient data" and not forced into a label.

## Labels
- **Growing:** new contributors arrive faster than others leave, and activity
  is rising. Issues and PRs still get answered, and releases keep shipping.
- **Mature:** activity is flat or changing slowly, but a steady core of
  contributors stays. Responses stay timely and releases continue, often
  across several supported versions. Quiet is not a warning sign.
- **Declining:** contributors leave faster than new ones arrive. Response
  times lengthen, the backlog ages upward, and releases slow down.
- **Dormant:** almost no human activity for an extended period, few or no
  releases, and new issues go unanswered.

## Warning flag (shown beside the label, not a label)
- **Concentrated:** a small number of people account for most of the activity,
  so the project is fragile even when it looks healthy.

## Open questions
- The time windows ("recent", "extended period").
- The thresholds and how to combine signals when they disagree.