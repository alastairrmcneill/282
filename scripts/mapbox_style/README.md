# Mapbox style versioning

The app's two map styles live in Mapbox Studio, but their JSON is versioned here so
every change is traceable in git and any Studio experiment can be reverted from code.

| File | Style | URI |
|---|---|---|
| `two_eight_two_light.json` | TwoEightTwo Light | `mapbox://styles/alastairm94/cmrabh9j4003r01r08baw5o6a` |
| `two_eight_two_dark.json` | TwoEightTwo Dark | `mapbox://styles/alastairm94/cmpdpqwg2000001siaqwm3zx5` |

These URIs are referenced in `lib/screens/explore/screens/mapbox_map_screen.dart` and
`lib/screens/bulk_munro_updates/widgets/bulk_munro_map_screen.dart`.

## Setup

Put a Mapbox secret token (`sk.*` with `styles:read` + `styles:write` scopes) in
`.secret_token` in this directory (gitignored), or export `MAPBOX_SECRET_TOKEN`.

## Workflow

```sh
./pull.sh          # snapshot both live styles into the JSON files
./pull.sh light    # just one of them
git diff           # review what changed in Studio
git commit         # keep it

./push.sh dark     # restore the committed file to Mapbox (reverts Studio changes)
```

After editing in Studio: `pull`, review, commit.
To revert Studio to the last committed state: `git checkout` the file if needed, then `push`.

Notes:
- `created`/`modified` are stripped and keys are sorted so git diffs stay clean.
- The `imports[0].config["theme-data"]` value is a large base64 colour-grading LUT
  (one long line) — that's expected.
- The app clears the Mapbox device cache on debug launches (`main.dart`), so a full
  app restart always shows the latest pushed style.
