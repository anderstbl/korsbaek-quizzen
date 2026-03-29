# Matador-quizzen 🎭

**Test din viden om Matador – den klassiske danske TV-serie fra 1929–1947.**

🔗 **[matador-quizzen.vercel.app](https://matador-quizzen.vercel.app)**

---

## Om projektet

Matador-quizzen er en browserbaseret quiz dedikeret til DR's ikoniske TV-serie *Matador* (1978–1982). Spillet trækker spørgsmål fra en live database og holder styr på en global highscore-liste, så du kan måle dig med andre Korsbæk-kendere.

Designet er inspireret af seriens æra – art deco, guldfarvede ornamenter, filmkorn og seriffen skrift fra 1930'erne.

## Features

- **Flere spørgsmålstyper** – udfyld citater, gæt hvem der sagde det, sand/falsk-påstande, faktaspørgsmål og billedspørgsmål
- **Combo & speedbonus** – svar hurtigt og rigtigt i træk for at score ekstra point
- **Global highscore** – Top 100 over Matadors bedste kendere, gemt i Supabase
- **Del din score** – knap til deling på sociale medier med Open Graph-preview
- **Art Deco design** – guldfarvede dekorationer, filmkornsoverlay og 1930'er-typografi
- **Mobilvenlig** – responsivt layout der virker på alle skærmstørrelser

## Teknisk stack

| Del | Teknologi |
|-----|-----------|
| Frontend | Vanilla HTML/CSS/JavaScript (én fil) |
| Hosting | [Vercel](https://vercel.com) |
| Database & API | [Supabase](https://supabase.com) (PostgreSQL + REST) |
| Fonte | Playfair Display, Oswald, Crete Round (Google Fonts) |

Ingen build-trin, ingen afhængigheder – åbn `index.html` direkte i en browser under udvikling.

## Databasestruktur

Se [`schema.sql`](schema.sql) for den fulde Supabase-opsætning. Kort fortalt:

**`questions`** – spørgsmål med type, kategori, svarmuligheder, forklaring og evt. billede-URL
**`scores`** – spillernavne, point, korrekte svar, max combo og speed bonuses

Row Level Security er aktiveret: anonyme brugere kan læse spørgsmål og scores, og indsætte nye scores.

## Lokal udvikling

```bash
git clone git@github.com:anderstbl/matador-quizzen.git
cd matador-quizzen
open index.html   # eller brug en lokal server, f.eks. Live Server i VS Code
```

Spillet henter spørgsmål og scores fra den delte Supabase-instans, så det virker uden yderligere opsætning.

## Deployment

Projektet deployes automatisk til Vercel ved push til `main`.

---

*Lavet med kærlighed til Korsbæk.*
