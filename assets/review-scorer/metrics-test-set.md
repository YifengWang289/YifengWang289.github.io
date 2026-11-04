# Eval summary — test set · claude-haiku-5-5

## Overall

| Method | MAE [95% CI] | RMSE | Exact | ±1 star | Bias | QWK | Run agreement | $/1k reviews |
|---|---|---|---|---|---|---|---|---|
| Baseline: always 3★ | 1.20 [1.13–1.27] | 1.41 | 20% | 60% | +0.00 | 0.00 | — | — |
| Baseline: VADER sentiment | 0.97 [0.89–1.05] | 1.31 | 34% | 77% | -0.08 | 0.57 | — | — |
| Baseline: TF-IDF + ridge | 0.80 [0.74–0.86] | 1.04 | 33% | 87% | -0.03 | 0.61 | — | — |
| v0 · task only | 0.39 [0.34–0.44] | 0.69 | 65% | 96% | -0.24 | 0.88 | 95% | $0.048 |
| v1 · + rubric | 0.50 [0.45–0.55] | 0.77 | 55% | 95% | -0.28 | 0.85 | — | $0.180 |
| v2 · + few-shot (original) | 0.52 [0.47–0.57] | 0.77 | 52% | 96% | -0.29 | 0.84 | — | $0.517 |
| v3 · calibrated rubric | 0.44 [0.39–0.49] | 0.74 | 61% | 96% | -0.19 | 0.88 | — | $0.189 |
| v4 · anchored (from error analysis) | 0.41 [0.36–0.46] | 0.70 | 63% | 97% | -0.15 | 0.88 | 85% | $0.157 |

n = 500 reviews; LLM metrics averaged over runs; CI = bootstrap over reviews.

## Human ceiling (same 50 reviews, labeled blind)

| Method | MAE | Exact | ±1 star |
|---|---|---|---|
| Human re-label (ceiling) | 0.48 | 58% | 94% |
| Baseline: always 3★ | 1.20 | 20% | 60% |
| Baseline: VADER sentiment | 1.20 | 20% | 68% |
| Baseline: TF-IDF + ridge | 0.82 | 32% | 88% |
| v0 · task only | 0.54 | 56% | 92% |
| v1 · + rubric | 0.62 | 46% | 94% |
| v2 · + few-shot (original) | 0.56 | 52% | 94% |
| v3 · calibrated rubric | 0.54 | 54% | 94% |
| v4 · anchored (from error analysis) | 0.46 | 60% | 96% |

## Per true star (MAE / bias)

| Method | 1★ | 2★ | 3★ | 4★ | 5★ |
|---|---|---|---|---|---|
| Baseline: always 3★ | 2.00 / +2.00 | 1.00 / +1.00 | 0.00 / +0.00 | 1.00 / -1.00 | 2.00 / -2.00 |
| Baseline: VADER sentiment | 0.80 / +0.80 | 0.97 / +0.23 | 1.07 / -0.03 | 1.03 / -0.41 | 0.97 / -0.97 |
| Baseline: TF-IDF + ridge | 1.17 / +1.17 | 0.60 / +0.54 | 0.34 / -0.14 | 0.62 / -0.44 | 1.27 / -1.27 |
| v0 · task only | 0.17 / +0.17 | 0.34 / -0.24 | 0.70 / -0.57 | 0.53 / -0.33 | 0.22 / -0.22 |
| v1 · + rubric | 0.32 / +0.32 | 0.34 / -0.24 | 0.90 / -0.70 | 0.47 / -0.29 | 0.47 / -0.47 |
| v2 · + few-shot (original) | 0.35 / +0.35 | 0.31 / -0.21 | 0.86 / -0.64 | 0.43 / -0.33 | 0.63 / -0.63 |
| v3 · calibrated rubric | 0.14 / +0.14 | 0.49 / -0.35 | 0.84 / -0.52 | 0.55 / -0.07 | 0.17 / -0.17 |
| v4 · anchored (from error analysis) | 0.27 / +0.27 | 0.44 / -0.13 | 0.67 / -0.43 | 0.41 / -0.21 | 0.25 / -0.25 |

## Paired comparisons (Δ MAE, negative = second is better)

- v0 · task only → v1 · + rubric: +0.107 [+0.067, +0.149] (significant)
- v1 · + rubric → v2 · + few-shot (original): +0.016 [-0.016, +0.050] (not significant)
- v2 · + few-shot (original) → v3 · calibrated rubric: -0.078 [-0.126, -0.028] (significant)
- v3 · calibrated rubric → v4 · anchored (from error analysis): -0.030 [-0.067, +0.007] (not significant)
- Baseline: TF-IDF + ridge → v4 · anchored (from error analysis): -0.392 [-0.463, -0.321] (significant)

v0 · task only: 19 reviews off by ≥2 stars → errors_test_v0_bare.csv

v4 · anchored (from error analysis): 16 reviews off by ≥2 stars → errors_test_v4_anchored.csv
