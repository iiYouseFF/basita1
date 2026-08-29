# OpenCode Multi-Stack Project Rules

## Architecture Guidelines
- **Frontend**: Flutter with Clean Architecture (Data, Domain, Presentation).
- **Backend - Relational**: Supabase (PostgreSQL, Auth, Storage, Edge Functions).
- **Backend - NoSQL/Telemetry**: Firebase (Firestore, Analytics, Crashlytics).
- **Design System**: Figma tokens (Colors, Typography, Spacing).

## MCP Execution Rules
1. **Figma**: When generating UI, fetch component node details and styles first via the Figma MCP before writing Dart code.
2. **Supabase**: Always verify database schemas, table definitions, and Row Level Security (RLS) policies using the Supabase MCP before writing data repositories.
3. **Firebase**: Inspect Firestore collection structures and ensure error handling routes to Firebase Crashlytics.
4. **Git**: Keep changes atomic. Create dedicated git branches for new feature implementations.