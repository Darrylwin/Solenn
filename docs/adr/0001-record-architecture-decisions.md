# ADR 0001: Record architecture decisions

- Status: Accepted
- Date: 2026-10-25

## Context

The specification states that every choice is already made and that anything
that changes later must be traceable. Documentation lives in the repository
(the GitHub wiki is disabled).

## Decision

Architecture decisions are recorded as ADRs in `docs/adr/`, named
`NNNN-title.md`, from `0000-template.md` (Status, Context, Decision,
Consequences, Alternatives considered). An accepted ADR is immutable; it is
changed only by a new ADR that supersedes it. When the specification and an
accepted ADR disagree, the ADR wins and the specification is corrected in the
same PR.

An ADR is required for: a dependency of architectural weight, any change to a
layer rule or platform policy, any change to CI or release strategy, and any
decrease of a coverage threshold.

## Consequences

Decisions are reviewable in pull requests and versioned with the code. Changing
a decision costs one new ADR, which keeps the history readable.

## Alternatives considered

The GitHub wiki: rejected, since documentation lives in the repository.

