# Schema for the LLM

This file is what the agent's **system prompt** loads. The DDL in
`seed.sql` is what SQLite loads. They serve different audiences:

| File          | Reader  | Job                                              |
|---------------|---------|--------------------------------------------------|
| `seed.sql`    | SQLite  | Create the table, store the rows.                |
| `schema.md`   | the LLM | Understand the *meaning* so it can write good SQL. |

If you only give the LLM the DDL it knows the column names and types
but nothing else - it will hallucinate values like `vehicle = 'Falcon X'`
or guess that `success = 0` means success. That's the bug this file
prevents.

---

## Database

Single SQLite database with one table named `launches`. Each row is one
SpaceX rocket launch.

## Table: `launches`

| Column         | Type      | Description                                                                 |
|----------------|-----------|-----------------------------------------------------------------------------|
| `launch_id`    | INTEGER   | Primary key. Stable surrogate id, not meaningful.                           |
| `mission_name` | TEXT      | Human-readable name (e.g. `'Crew Dragon Demo-2'`, `'Europa Clipper'`).       |
| `vehicle`      | TEXT      | Rocket family. **One of:** `'Falcon 1'`, `'Falcon 9'`, `'Falcon Heavy'`, `'Starship'`. |
| `payload_type` | TEXT      | Kind of payload. **One of:** `'Test'`, `'Cargo'`, `'Crew'`, `'Satellite'`, `'Probe'`. |
| `payload_kg`   | INTEGER   | Mass of payload in kilograms. **`0` means no orbital payload** (e.g. Starship test flights). |
| `destination`  | TEXT      | Where it was going. **Examples:** `'LEO'`, `'ISS'`, `'L1'`, `'Heliocentric'`, `'Suborbital'`, `'Jupiter Transfer'`. |
| `success`      | INTEGER   | **`1` = succeeded, `0` = failed.** Treat as boolean.                         |
| `launch_date`  | DATE      | `YYYY-MM-DD` text. Use SQLite date functions for ranges.                    |
| `customer`     | TEXT      | Paying customer or operator. **Examples:** `'NASA'`, `'SpaceX'`, `'NOAA'`, `'Shift4'`, `'Iridium'`, `'MDA'`, `'DARPA'`. |

### Domain conventions

- Internal SpaceX flights (test campaigns, Starlink) have `customer = 'SpaceX'`.
- Crewed civilian missions (Inspiration4, Polaris Dawn) have `customer = 'Shift4'`.
- Test flights with no orbital payload have `payload_kg = 0` and usually `destination = 'Suborbital'`.
- `success` is the *launch* outcome, not the long-term mission outcome.

### Domain terms

These are short names users use that map to specific SQL filters. They are NOT inferable from the column types - they have to be written down.

| Term                  | SQL filter                                                                          |
|-----------------------|-------------------------------------------------------------------------------------|
| `heavy launch`        | `payload_kg > 5000`  (any mission with payload over 5,000 kg, regardless of vehicle) |
| `test campaign`       | `customer = 'SpaceX' AND payload_type = 'Test'`                                     |
| `civilian mission`    | `customer = 'Shift4'`                                                                |
| `government mission`  | `customer IN ('NASA', 'NOAA', 'DARPA')`                                              |
| `commercial mission`  | `customer NOT IN ('NASA', 'NOAA', 'DARPA', 'SpaceX', 'Shift4')`                     |

**Note on `heavy launch`**: although we have a rocket family called `'Falcon Heavy'`, a *heavy launch* in our terminology refers to any mission with a heavy payload, not a launch of the Falcon Heavy rocket. This is the kind of domain term that an LLM cannot guess from the column values - the word "heavy" overlaps with the rocket name and will mislead the model unless we say so explicitly.

---

## Few-shot examples (NL question -> SQL)

These are the most valuable tokens in this file. The LLM learns the
*shape* of correct queries from them.

**Q1: "How many successful launches has SpaceX done?"**
```sql
SELECT COUNT(*) AS n FROM launches WHERE success = 1;
```

**Q2: "Failure rate per vehicle, worst first."**
```sql
SELECT vehicle,
       ROUND(100.0 * SUM(1 - success) / COUNT(*), 1) AS failure_pct,
       COUNT(*) AS n_launches
FROM launches
GROUP BY vehicle
ORDER BY failure_pct DESC;
```

**Q3: "What is the heaviest payload ever launched?"**
```sql
SELECT mission_name, vehicle, payload_kg
FROM launches
ORDER BY payload_kg DESC
LIMIT 1;
```

**Q4: "List every crewed mission, newest first."**
```sql
SELECT mission_name, vehicle, launch_date, customer
FROM launches
WHERE payload_type = 'Crew'
ORDER BY launch_date DESC;
```

**Q5: "How many launches happened in 2021?"**
```sql
SELECT COUNT(*) AS n
FROM launches
WHERE strftime('%Y', launch_date) = '2021';
```

---

## Output rules for the LLM

- Return only valid SQLite SQL. One query.
- Plain text only. No JSON, no markdown code fences, no prose, no explanation.
- Do not invent table or column names; use only what is documented above.
- Include a `LIMIT` if the natural answer could be more than one row, unless the question asks for a count or aggregate.
