/** Format USD for dashboard display. */
export function formatUsd(n) {
  if (n == null || !Number.isFinite(n)) return "—";
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: n >= 1000 ? 0 : 2,
  }).format(n);
}

/**
 * Estimate ATE tester cost savings from pre-process run metrics.
 *
 * @param {object} p
 * @param {number} p.fullMs - full suite test time per die (ms)
 * @param {number} p.agentMs - with-agent test time per die (ms)
 * @param {number} p.ateRatePerHour - burdened ATE $/hour
 * @param {number} p.diesPerYear - production volume
 * @param {number} [p.savedMb] - peak vector RAM saved (MB)
 * @param {number} [p.savedPctRam] - RAM saved %
 */
export function computeCostSavings({
  fullMs,
  agentMs,
  ateRatePerHour,
  diesPerYear,
  savedMb,
  savedPctRam,
}) {
  const full = Number(fullMs) || 0;
  const agent = Number(agentMs) || 0;
  const rate = Math.max(0, Number(ateRatePerHour) || 0);
  const volume = Math.max(0, Number(diesPerYear) || 0);

  const savedMs = Math.max(0, full - agent);
  const timePct = full > 0 ? (100 * savedMs) / full : 0;
  const savedHoursPerDie = savedMs / 3_600_000;
  const fullHoursPerDie = full / 3_600_000;
  const agentHoursPerDie = agent / 3_600_000;

  const costFullPerDie = fullHoursPerDie * rate;
  const costAgentPerDie = agentHoursPerDie * rate;
  const costSavedPerDie = savedHoursPerDie * rate;

  const annualFull = costFullPerDie * volume;
  const annualAgent = costAgentPerDie * volume;
  const annualSaved = costSavedPerDie * volume;

  return {
    savedMs,
    timePct,
    savedHoursPerDie,
    costFullPerDie,
    costAgentPerDie,
    costSavedPerDie,
    annualFull,
    annualAgent,
    annualSaved,
    savedMb: Number(savedMb) || 0,
    savedPctRam: Number(savedPctRam) || 0,
    hasRun: full > 0,
  };
}
