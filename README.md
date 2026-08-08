# 🌍 SehatVerse

**Har Umar. Har Level. Better Health.**  
*Khelo. Seekho. Apni Sehat Ko Level Up Karo.*

A gamified health-learning platform: age-personalized worlds, a Sehat City map of learning zones, adaptive quizzes, XP/levels/streaks/badges, a Myth Buster tower, and a private Gratitude Jar.

---

## What's in this build

Building all five layers (React web, Flutter mobile, Node.js, FastAPI, Supabase) to a fully running state isn't something one pass can do end to end — there's no server here to deploy them onto or install dependencies against. So this build is split into two tiers:

### ✅ Fully working: `web/index.html`
A single-file, dependency-free web app implementing the **Priority 1 + 2** core loop end to end, playable immediately in any browser:
- **Age selection** (all 7 groups, distinct visual themes) → style/theme picker → avatar + companion creation
- **Sehat City** map with all 13 zones (locked/unlocked by level)
- Three fully playable zones with real content: **Hygiene Haven** and **Poshan Park** (2-level adaptive quizzes with explanations), and the **Myth Buster Tower** (fact-or-myth crystals)
- **Gratitude Jar**, daily missions, XP/leveling, streak, and a Trophy Room of unlockable badges

State lives in memory for this demo (per artifact platform rules, no `localStorage`). Wire it to Supabase (schema below) for persistence across sessions — the data shapes already match.

### 🧱 Scaffolded, not wired up: everything else
These are structured starting points, not running services — they need a real environment (npm/pip installs, a Supabase project, a Flutter SDK) to go further:
- `supabase/schema.sql` — complete, ready to run as-is in a Supabase project's SQL editor, including Row Level Security policies
- `backend/node/` — Express service stubs for `/auth`, `/profile`, `/progress`, `/badges`, `/tasks`, `/streak`, `/zones`, querying Supabase
- `backend/fastapi/` — FastAPI service stubs for `/quiz`, `/adaptive-learning`, `/recommendations`, `/myth-buster`, `/emergency-learning`, including a working difficulty-ladder algorithm (`services.py`)
- `mobile/` — Flutter skeleton with the same age-group data and first onboarding screen, ready to extend screen-by-screen

---

## Folder Structure

```
sehatverse/
├── web/
│   └── index.html          ← open this to try the demo
├── mobile/
│   ├── lib/
│   │   ├── models/age_group.dart
│   │   ├── screens/age_selection_screen.dart
│   │   └── main.dart
│   └── pubspec.yaml
├── backend/
│   ├── node/          (server.js, routes.js, services.js)
│   └── fastapi/       (main.py, routes.py, services.py)
├── supabase/
│   └── schema.sql
└── README.md
```

---

## Adaptive Quiz Logic

```
User answers question
        ↓
3 correct in a row → difficulty steps up (foundation → challenge → expert → master)
2 wrong in a row   → difficulty steps down
        ↓
Save attempt, award XP, update "Learning Progress" (never called a risk score)
```
Implemented in `backend/fastapi/services.py::score_attempt`.

---

## Content Safety Notes Carried Through the Build
- Every health topic is framed as educational information, never diagnosis or personalized treatment advice.
- Emergency content teaches *recognize → get appropriate help → stay safe*, with no graphic imagery.
- Gender/style selection only affects cosmetics (avatar, colors) — it never gates or changes health content.
- Progress bars are labeled "Learning Progress," not a medical score.

---

## Suggested Next Steps
1. Stand up a Supabase project, run `supabase/schema.sql`, seed `zones`/`badges`/`questions` from the content already in `web/index.html`'s `CONFIG` section (it's structured to map 1:1 onto the tables).
2. Point `backend/node` and `backend/fastapi` at that project via env vars and get `/auth/onboard` + `/quiz/next` returning real rows.
3. Swap `web/index.html`'s in-memory `state` object for calls to those two services.
4. Build out the remaining Flutter screens against the same API.
5. Expand the 10 remaining Sehat City zones (Emergency HQ, Wellness Garden, Fitness Arena, etc.) using the same quiz-bank + badge pattern already proven out in Hygiene Haven / Poshan Park.